unit System.Utility.IntAllocator;

interface

uses
    System.Classes
  , System.SysUtils
  ;

type
  ///<summary>
  /// <p>
  ///  A class for allocating integers from a given range that uses a
  /// {@link BitSet} representation of the free integers.
  /// </p>
  ///
  /// <h2>Concurrency Semantics:</h2>
  /// This class is <b><i>not</i></b> thread safe.
  ///
  /// <h2>Implementation notes:</h2>
  /// <p>This was originally an ordered chain of non-overlapping Intervals,
  /// together with a fixed size array cache for freed integers.
  /// </p>
  /// <p>
  /// {@link #reserve(int)} was expensive in this scheme, whereas in the
  /// present implementation it is O(1), as is {@link #free(int)}.
  /// </p>
  /// <p>Although {@link #allocate()} is slightly slower than O(1) and in the
  /// worst case could be O(N), the use of a "<code>lastIndex</code>" field
  /// for starting the next scan for free integers means this is negligible.
  /// </p>
  /// <p>The data representation overhead is O(N) where N is the size of the
  /// allocation range. One <code>long</code> is used for every 64 integers in the
  /// range.
  /// </p>
  /// <p>Very little Object creation and destruction occurs in use.</p>
  ///</summary>
  TIntAllocator = class
  private type
    TBitstHelper = class helper for TBits
      function NextClearBit(FromIndex: integer): integer;
      function NextSetBit(FromIndex: integer): integer;
      procedure &Set(FromIndex, ToIndex: integer);
    end;
  strict private
    FLoRange: integer; // the integer bit 0 represents
    FHiRange: integer; // one more than the integer the highest bit represents
    FNumberOfBits: integer;
    FLastIndex: integer;
    FFreeSet: TBits;

    procedure StringInterval(sb: TStringBuilder; i1, i2: integer);
  public
    constructor Create(Bottom, Top: integer);
    destructor Destroy; override;

    ///<summary>
    /// Allocate an unallocated integer from the range, or return -1 if no
    /// more integers are available.
    /// @return the allocated integer, or -1
    ///</summary>
    function Allocate: integer;

    ///<summary>
    /// Make the provided integer available for allocation again. This operation
    /// runs in O(1) time.
    /// No error checking is performed, so if you double free or free an
    /// integer that was not originally allocated the results are undefined.
    /// @param reservation the previously allocated integer to free
    ///</summary>
    procedure Free(Reservation: integer); overload;

    ///<summary>
    /// Attempt to reserve the provided ID as if it had been allocated. Returns
    /// true if it is available, false otherwise.
    /// This operation runs in O(1) time.
    /// @param reservation the integer to be allocated, if possible
    /// @return <code><b>true</b></code> if allocated, <code><b>false</b></code>
    /// if already allocated
    ///</summary>
    function Reserve(Reservation: integer): boolean;

    function ToString: string; override;
  end;

implementation

{ TIntAllocator }

function TIntAllocator.Allocate: integer;
begin
  var SetIndex := FFreeSet.NextSetBit(0);
  if SetIndex < 0 then // means none found in trailing part
    SetIndex := FFreeSet.NextSetBit(0);

  if SetIndex < 0 then
    exit(-1);

  FLastIndex := SetIndex;
  FFreeSet[SetIndex] := false;
  result := SetIndex + FLoRange;
end;

constructor TIntAllocator.Create(Bottom, Top: integer);
begin
  FLoRange := Bottom;
  FHiRange := Top + 1;
  FNumberOfBits := FHiRange - FLoRange;
  FFreeSet := TBits.Create;
  FFreeSet.Size := FNumberOfBits;
  FFreeSet.&Set(0, FNumberOfBits);
end;

destructor TIntAllocator.Destroy;
begin
  FFreeSet.Free;
  inherited;
end;

procedure TIntAllocator.Free(Reservation: integer);
begin
  FFreeSet[Reservation - FLoRange] := true;
end;

function TIntAllocator.Reserve(Reservation: integer): boolean;
begin
  var Index := Reservation - FLoRange;
  if FFreeSet[Index] then //FREE
  begin
    FFreeSet[Index] := false;
    exit(true);
  end;

  result := false;
end;

procedure TIntAllocator.StringInterval(sb: TStringBuilder; i1, i2: integer);
begin
  sb.Append(i1+FLoRange);
  if i1+1 <> i2 then
    sb.Append('..').Append(i2-1 + FLoRange);
end;

function TIntAllocator.ToString: string;
begin
  var sb := TStringBuilder.Create('IntAllocator{allocated = [');
  try
    var FirstClearBit := FFreeSet.NextClearBit(0);
    if FirstClearBit < FNumberOfBits then
    begin
      var FirstSetAfterThat := FFreeSet.NextSetBit(FirstClearBit + 1);
      if FirstSetAfterThat < 0 then
        FirstSetAfterThat := FNumberOfBits;

      StringInterval(sb, FirstClearBit, FirstSetAfterThat);
      var Idx := FFreeSet.NextClearBit(FirstSetAfterThat+1);
      while Idx < FNumberOfBits do
      begin
        var NextSet := FFreeSet.NextSetBit(Idx);
        if NextSet < 0 then
          NextSet := FNumberOfBits;
        StringInterval(sb.Append(', '), Idx, NextSet);
        Idx := FFreeSet.NextClearBit(NextSet + 1);
      end;

    end;

    sb.Append(']}');
    result := sb.ToString;
  finally
    sb.Free;
  end;
end;


{ TIntAllocator.TBitstHelper }

procedure TIntAllocator.TBitstHelper.&Set(FromIndex, ToIndex: integer);
begin
  for var I := FromIndex to ToIndex do
    self[I] := true;
end;

function TIntAllocator.TBitstHelper.NextClearBit(FromIndex: integer): integer;
begin
  for var I := FromIndex to self.Size-1 do
    if not self.Bits[I] then
      exit(I);

  result := self.Size;
end;

function TIntAllocator.TBitstHelper.NextSetBit(FromIndex: integer): integer;
begin
  for var I := FromIndex to self.Size-1 do
    if self.Bits[I] then
      exit(I);

  result := -1;
end;

end.
