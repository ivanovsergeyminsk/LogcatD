unit adb.Receiver.MultiLineReceiver;

interface

uses
    adb.AndroidDebugBridge
  , System.Generics.Collections
  , System.SysUtils
  ;

type
  TCallbackIsCanelled = reference to function(): boolean;
  TCallbackProcessNewLines = reference to procedure(const [ref] Lines: TArray<string>);

  TMultiLineReceiver = class abstract(TInterfacedObject, IShellOutputReceiver)
  private
    FTrimLines: boolean;
    // unfinished message line, stored for next packet
    FUnfinishedLine: string;
    FArray: TList<string>;
  public
    class function Construct(CallbackIsCancelled: TCallbackIsCanelled; CallbackProcesNewLines: TCallbackProcessNewLines): IShellOutputReceiver; static;

    constructor Create;
    destructor Destroy; override;

    // IShellOutputReceiver
    procedure AddOutput(const [ref] Data: TArray<byte>; Offset, Length: integer); virtual;
    procedure Flush; virtual;
    function IsCancelled: boolean; virtual;


    /// Set the trim lines flag.
    /// @param trim whether the lines are trimmed, or not.
    procedure SetTrimLine(Trim: boolean);

    /// Terminates the process. This is called after the last lines have been through
    /// {@link #processNewLines(String[])}.
    procedure Done; virtual;

    /// Called when new lines are being received by the remote process.
    /// <p/>It is guaranteed that the lines are complete when they are given to this method.
    /// @param lines The array containing the new lines.
    procedure ProcessNewLines(const [ref] Lines: TArray<string>); virtual; abstract;
  end;

implementation

type
  TConstructMultiLineReceiver = class(TMultiLineReceiver)
  strict private
    FCallbackIsCancelled: TCallbackIsCanelled;
    FCallbackProcesNewLines: TCallbackProcessNewLines;
  public
    constructor Create(CallbackIsCancelled: TCallbackIsCanelled; CallbackProcesNewLines: TCallbackProcessNewLines);
    function IsCancelled: boolean; override;
    procedure ProcessNewLines(const [ref] Lines: TArray<string>); override;
  end;

{ TMultiLineReceiver }

procedure TMultiLineReceiver.AddOutput(const [ref] Data: TArray<byte>; Offset, Length: integer);
begin
  if not IsCancelled then
  begin
    var s: string;
    try
      s := TEncoding.UTF8.GetString(Data, Offset, Length);
    except
      on E: Exception do
      begin
        // normal encoding didn't work, try the default one
        s := StringOf(Data);
      end;
    end;

    // ok we've got a string
    // if we had an unfinished line we add it.
    if not FUnfinishedLine.IsEmpty then
    begin
      s := FUnfinishedLine + s;
      FUnfinishedLine := string.Empty;
    end;

    FArray.Clear;
    var start: integer := 0;
    var mv: integer    := 2;
    repeat
      var index := s.IndexOf(#13#10, start);
      if index = -1 then
      begin
        index := s.IndexOf(#10, start);
        mv := 1;
      end;
      if index = -1 then
      begin
        index := s.IndexOf(#13, start);
        mv := 1;
      end;

      // if \r\n was not found, this is an unfinished line
      // and we store it to be processed for the next packet
      if index = -1 then
      begin
        FUnfinishedLine := s.Substring(start);
        break;
      end;

      // so we found a \r\n;
      // extract the line
      var line := s.Substring(start, index-start);
      if FTrimLines then
        line := line.Trim;
      FArray.Add(line);

      // move start to after the \r\n we found
      start := index + mv;
    until false;

    if FArray.Count <> 0 then
    begin
      // at this point we've split all the lines.
      // make the array
      var lines := FArray.ToArray;

      // send it for final processing
      ProcessNewLines(lines);
    end;
  end;
end;

class function TMultiLineReceiver.Construct(CallbackIsCancelled: TCallbackIsCanelled; CallbackProcesNewLines: TCallbackProcessNewLines): IShellOutputReceiver;
begin
  result := TConstructMultiLineReceiver.Create(CallbackIsCancelled, CallbackProcesNewLines);
end;

constructor TMultiLineReceiver.Create;
begin
  FTrimLines := true;
  FArray := TList<string>.Create;
end;

destructor TMultiLineReceiver.Destroy;
begin
  FArray.Free;

  inherited;
end;

procedure TMultiLineReceiver.Done;
begin
  // do nothing.
end;

procedure TMultiLineReceiver.Flush;
begin
  if not FUnfinishedLine.IsEmpty then
    ProcessNewLines([FUnfinishedLine]);

  Done;
end;

function TMultiLineReceiver.IsCancelled: boolean;
begin
  result := true;
end;

procedure TMultiLineReceiver.SetTrimLine(Trim: boolean);
begin
  FTrimLines := Trim;
end;

{ TConstructMultiLineReceiver }

constructor TConstructMultiLineReceiver.Create(CallbackIsCancelled: TCallbackIsCanelled; CallbackProcesNewLines: TCallbackProcessNewLines);
begin
  inherited Create;
  FCallbackIsCancelled    := CallbackIsCancelled;
  FCallbackProcesNewLines := CallbackProcesNewLines;
end;

function TConstructMultiLineReceiver.IsCancelled: boolean;
begin
  if assigned(FCallbackIsCancelled) then
    result := FCallbackIsCancelled
  else
    result := Inherited IsCancelled;
end;

procedure TConstructMultiLineReceiver.ProcessNewLines(const [ref] Lines: TArray<string>);
begin
  if assigned(FCallbackProcesNewLines) then
    FCallbackProcesNewLines(Lines);
end;

end.
