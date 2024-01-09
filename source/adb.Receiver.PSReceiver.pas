unit adb.Receiver.PSReceiver;

interface

uses
    System.RegularExpressions
  , System.Diagnostics
  , System.Generics.Collections
  , adb.AndroidDebugBridge
  , adb.Receiver.MultiLineReceiver
  ;


type

  TCallbackPID = reference to procedure(const [ref] AData: TPair<integer, string>);
  ///<summary>
  /// A receiver able to parse the result of the execution of<p/>
  /// {@link #PS_COMMAND} on a device.
  ///</sumamry>
  TPSReceiver = class(TMultiLineReceiver)
  public const
    PS_COMMAND = 'ps -A -o PID,NAME -w';
    PS_COMMAND_PID = 'ps -p %d -o PID,NAME -w';
  private const
//    RX_PS = '\w+\s+(?<pid>\d+)\s+\d+\s+\d+\s+\d+\s+[\d\w]+\s+\d+\s+\w\s+(?<name>.+)';
    RX_PS = '(?<pid>\d+)\s(?<name>.+)';
  private
    FPSPattern: TRegEx;
    FIsCancelled: boolean;
    SW: TStopwatch;

    FCallbackPID: TCallbackPID;
  public
    constructor Create(CallbackPID: TCallbackPID);

    procedure ProcessNewLines(const [ref] Lines: TArray<string>); override;
    function IsCancelled: boolean; override;
    procedure Flush; override;
    procedure Done; override;
  end;

implementation

uses
    System.SysUtils
  , adb.Device
  ;

{ TPSReceiver }

constructor TPSReceiver.Create(CallbackPID: TCallbackPID);
begin
  inherited Create;

  FPSPattern := TRegEx.Create(RX_PS, [roNotEmpty, roCompiled]);
  FIsCancelled := false;

  FCallbackPID := CallbackPID;
end;

procedure TPSReceiver.Done;
begin
  inherited;

end;

procedure TPSReceiver.Flush;
begin
  if SW.IsRunning then
  begin
    FIsCancelled := SW.ElapsedMilliseconds > 100;
  end
  else
  begin
    SW.Reset;
    SW.Start;
    FIsCancelled := false;
  end;
end;

function TPSReceiver.IsCancelled: boolean;
begin
  result := FIsCancelled;
end;

procedure TPSReceiver.ProcessNewLines(const [ref] Lines: TArray<string>);
begin
  SW.Stop;
  SW.Reset;
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

      if Assigned(FCallbackPID) then
        FCallbackPID(TPair<integer, string>.Create(pid, pname));
    end;
  end;

end;

end.
