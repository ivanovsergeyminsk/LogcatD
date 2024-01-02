unit adb.RawImage;

interface

uses
    System.Classes
  , System.SysUtils
  , System.Generics.Collections
  ;

type
  TRawImage = record
  private
    /// creates a mask value based on a length and offset.
    /// <p/>This value is compatible with org.eclipse.swt.graphics.PaletteData
    function GetMask(ALength, Offset: integer): integer; overload;

    /// Creates a mask value based on a length.
    /// @param length
    /// @return
    class function GetMask(ALength: integer): integer; overload; static;
  public
    Version: UInt32;
    Bpp: UInt32;
    ColorSpace: UInt32;
    Size: UInt32;
    Width: UInt32;
    Height: UInt32;
    RedOffset: UInt32;
    RedLength: UInt32;
    BlueOffset: UInt32;
    BlueLength: UInt32;
    GreenOffset: UInt32;
    GreenLength: UInt32;
    AlphaOffset: UInt32;
    AlphaLength: UInt32;

    Data: TArray<byte>;

    /// Reads the header of a RawImage from a {@link ByteBuffer}.
    /// <p/>The way the data is sent over adb is defined in system/core/adb/framebuffer_service.c
    /// @param version the version of the protocol.
    /// @param buf the buffer to read from.
    /// @return true if success
    function ReadHeader(AVersion: integer; const [ref] Buffer: TArray<byte>): boolean;

    /// Returns the mask value for the red color.
    /// <p/>This value is compatible with org.eclipse.swt.graphics.PaletteData
    function GetRedMask: integer;

    /// Returns the mask value for the green color.
    /// <p/>This value is compatible with org.eclipse.swt.graphics.PaletteData
    function GetGreenMask: integer;

    /// Returns the mask value for the blue color.
    /// <p/>This value is compatible with org.eclipse.swt.graphics.PaletteData
    function GetBlueMask: integer;

    /// Returns a rotated version of the image
    /// The image is rotated counter-clockwise.
    function GetRotated: TRawImage;

    /// Returns an ARGB integer value for the pixel at <var>index</var> in {@link #data}.
    function GetARGB(index: integer): integer;

    /// Returns the size of the header for a specific version of the framebuffer adb protocol.
    /// @param version the version of the protocol
    /// @return the number of int that makes up the header.
    class function GetHeaderSize(AVersion: integer): integer; static;
  end;

implementation

uses
    adb.AndroidDebugBridge
  ;

{ TRawImage }

function TRawImage.GetARGB(index: integer): integer;
begin
  var value: integer;
  if Bpp = 16 then
  begin
    value := Data[index] and $00FF;
    value := value or ((Data[index+1] shl 8) and $0FF00);
  end
  else if Bpp = 32 then
  begin
    value := Data[index] and $00FF;
    value := value or ((Data[index+1] and $00FF) shl 8);
    value := value or ((Data[index+2] and $00FF) shl 16);
    value := value or ((Data[index+3] and $00FF) shl 24);
  end
  else
    raise EAndroidDebugBridge.Create('RawImage.getARGB(int) only works in 16 and 32 bit mode.');

  var r := ((value shr RedOffset) and GetMask(RedLength)) shl (8 - RedLength);
  var g := ((value shr GreenOffset) and GetMask(GreenLength)) shl (8 - GreenLength);
  var b := ((value shr BlueOffset) and GetMask(BlueLength)) shl (8 - BlueLength);
  var a: integer;
  if AlphaLength = 0 then
    a := $FF // force alpha to opaque if there's no alpha value in the framebuffer.
  else
    a := ((value shr AlphaOffset) and GetMask(AlphaLength)) shl (8 - AlphaLength);

  result := a shl 24 or r shl 16 or g shl 8 or b;
end;

function TRawImage.GetBlueMask: integer;
begin
  result := GetMask(BlueLength, BlueOffset);
end;

function TRawImage.GetGreenMask: integer;
begin
  result := GetMask(GreenLength, GreenOffset);
end;

class function TRawImage.GetHeaderSize(AVersion: integer): integer;
begin
  case AVersion of
    // compatibility mode
    16: result := 3*4;  // size, width, height
     2: result := 4*13;
     1: result := 12*4; // bpp, size, width, height, 4*(length, offset)
  else  result := 0;
  end;
end;

class function TRawImage.GetMask(ALength: integer): integer;
begin
  result := (1 shl ALength) - 1;
end;

function TRawImage.GetMask(ALength, Offset: integer): integer;
begin
  var AResult := GetMask(ALength) shl offset;

  // if the bpp is 32 bits then we need to invert it because the buffer is in little endian
  if Bpp = 32 then
    AResult := Swap(AResult);

  result := AResult;
end;

function TRawImage.GetRedMask: integer;
begin
  result := GetMask(RedLength, RedOffset);
end;

function TRawImage.GetRotated: TRawImage;
begin
  result := self;
  result.Data := [];

  var count := length(Self.Data);
  SetLength(result.Data, count);

  var byteCount := Self.Bpp shr 3; // bpp is in bits, we want bytes to match our array
  var w := self.Width;
  var h := self.Height;
  for var y := 0 to h-1 do
    for var x := 0 to w-1 do
      TArray.Copy<byte>(self.Data, result.Data, (y*w+x)*byteCount, ((w-x-1)*h+y)*byteCount, byteCount);
end;

function TRawImage.ReadHeader(AVersion: integer; const [ref] Buffer: TArray<byte>): boolean;
begin
  Self.Version := AVersion;

  var Reader := TBinaryReader.Create(TBytesStream.Create(Buffer), nil, true);
  try

    if Version = 16 then
    begin
      // compatibility mode with original protocol
      self.Bpp := 16;
      self.ColorSpace := 0;
      // read actual values
      self.Size   := Reader.ReadUInt32;
      self.Width  := Reader.ReadUInt32;
      self.Height := Reader.ReadUInt32;

      // create default values for the rest. Format is 565
      self.RedOffset    := 11;
      self.RedLength    := 5;
      self.GreenOffset  := 5;
      self.GreenLength  := 6;
      self.BlueOffset   := 0;
      self.BlueLength   := 5;
      self.AlphaOffset  := 0;
      self.AlphaLength  := 0;
    end
    else if Version = 2 then
    begin
      self.Bpp          := Reader.ReadUInt32;
      self.ColorSpace   := Reader.ReadUInt32;
      self.Size         := Reader.ReadUInt32;
      self.Width        := Reader.ReadUInt32;
      self.Height       := Reader.ReadUInt32;
      self.RedOffset    := Reader.ReadUInt32;
      self.RedLength    := Reader.ReadUInt32;
      self.BlueOffset   := Reader.ReadUInt32;
      self.BlueLength   := Reader.ReadUInt32;
      self.GreenOffset  := Reader.ReadUInt32;
      self.GreenLength  := Reader.ReadUInt32;
      self.AlphaOffset  := Reader.ReadUInt32;
      Self.AlphaLength  := Reader.ReadUInt32;
    end
    else if Version = 1 then
    begin
      self.Bpp          := Reader.ReadUInt32;
      self.ColorSpace   := 0;
      self.Size         := Reader.ReadUInt32;
      self.Width        := Reader.ReadUInt32;
      self.Height       := Reader.ReadUInt32;
      self.RedOffset    := Reader.ReadUInt32;
      self.RedLength    := Reader.ReadUInt32;
      self.BlueOffset   := Reader.ReadUInt32;
      self.BlueLength   := Reader.ReadUInt32;
      self.GreenOffset  := Reader.ReadUInt32;
      self.GreenLength  := Reader.ReadUInt32;
      self.AlphaOffset  := Reader.ReadUInt32;
      Self.AlphaLength  := Reader.ReadUInt32;
    end
    else
      // unsupported protocol!
      exit(false);

    result := true;
  finally
    Reader.Free;
  end;
end;

end.
