unit adb.Receiver.CollectingOutputReceiver;

interface

uses
    System.SyncObjs
  , System.SysUtils
  , adb.AndroidDebugBridge
  ;

type
  TCollectingOutputReceiver = class(TInterfacedObject, IShellOutputReceiver)
  private
    FCompletionLatch: TCountdownEvent;
    FOutputBuffer: TStringBuilder;
    FIsCanceled: boolean;
  public
    constructor Create(CommandCompleteLatch: TCountdownEvent);
    destructor Destroy; override;

    //IShellOutputReceiver
    procedure AddOutput(const [ref] Data: TArray<byte>; offset, ALength: integer);
    procedure Flush;
    function IsCancelled: boolean;

    function GetOutput: string;

    ///<summary>Cancel the output collection</summary>
    procedure Cancel;
  end;

implementation

{ TCollectingOutputReceiver }

procedure TCollectingOutputReceiver.AddOutput(const [ref] Data: TArray<byte>; offset, ALength: integer);
begin
  if not IsCancelled then
  begin
    var s: string;
    try
      s := TEncoding.UTF8.GetString(Data, offset, ALength);
    except
      s := StringOf(Data);
    end;
    FOutputBuffer.Append(s);
  end;
end;

procedure TCollectingOutputReceiver.Cancel;
begin

end;

constructor TCollectingOutputReceiver.Create(CommandCompleteLatch: TCountdownEvent);
begin
  FOutputBuffer := TStringBuilder.Create;
  FIsCanceled := false;
  FCompletionLatch := CommandCompleteLatch;
end;

destructor TCollectingOutputReceiver.Destroy;
begin
  FOutputBuffer.Free;
  inherited;
end;

procedure TCollectingOutputReceiver.Flush;
begin
  if FCompletionLatch <> nil then
    FCompletionLatch.Signal;
end;

function TCollectingOutputReceiver.GetOutput: string;
begin
  result := FOutputBuffer.ToString;
end;

function TCollectingOutputReceiver.IsCancelled: boolean;
begin
  result := FIsCanceled;
end;

end.
