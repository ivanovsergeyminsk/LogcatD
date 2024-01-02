unit adb.Receiver.PSReceiver;

interface

uses
    System.RegularExpressions
  , adb.AndroidDebugBridge
  , adb.Receiver.MultiLineReceiver
  ;


type
  ///<summary>
  /// A receiver able to parse the result of the execution of<p/>
  /// {@link #PS_COMMAND} on a device.
  ///</sumamry>
  TPSReceiver = class(TMultiLineReceiver)
  public const
    PS_COMMAND = 'ps';
  private const
    RX_PS = '\w+\s+(?<pid>\d+)\s+\d+\s+\d+\s+\d+\s+[\d\w]+\s+\d+\s+\w\s+(?<name>.+)';
  private
    /// indicates if we need to read the first
    FDevice: IDevice;
    FPSPattern: TRegEx;
    FIsCancelled: boolean;
  public
    constructor Create(Device: IDevice);

    procedure ProcessNewLines(const [ref] Lines: TArray<string>); override;
    function IsCancelled: boolean; override;
    procedure Done; override;
  end;

implementation

uses
    System.SysUtils
  , adb.Device
  ;

{ TPSReceiver }

constructor TPSReceiver.Create(Device: IDevice);
begin
  inherited Create;

  FDevice := Device;
  FPSPattern := TRegEx.Create(RX_PS, [roNotEmpty, roCompiled]);
  FIsCancelled := false;
end;

procedure TPSReceiver.Done;
begin
  inherited;

end;

function TPSReceiver.IsCancelled: boolean;
begin
  result := FIsCancelled;
end;

procedure TPSReceiver.ProcessNewLines(const [ref] Lines: TArray<string>);
begin
  // We receive an array of lines. We're expecting
  // to have the build info in the first line, and the build
  // date in the 2nd line. There seems to be an empty line
  // after all that.

  for var Line in Lines do
  begin
    if Line.IsEmpty then
      continue;

    var m := FPSPattern.Match(Line);
    if m.Success then
    begin
      var pid   := m.Groups['pid'].Value.ToInteger;
      var pname := m.Groups['name'].Value;

        TDevice(FDevice).SetClientInfo(pid, pname);
    end;
  end;

  FIsCancelled := true;
end;

end.
