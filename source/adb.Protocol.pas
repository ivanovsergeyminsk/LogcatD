unit adb.Protocol;

interface

uses
    System.Net.Socket
//  , System.Net.Selector
  , System.SysUtils
  , System.Threading
  , System.SyncObjs
  , System.Classes
  , System.Generics.Collections
  , Common.Debug
  ;


type
//  TAdbClient    = class;
  TAdbCommand   = class;

  TAdbResponse = record
    OKAY: boolean; // first 4 bytes in response were "OKAY"?
    Msg: string;   // diagnostic string if #okay is false
  end;

  TCommandCallback = reference to procedure(const [ref] Data: TArray<byte>; var IsDone: boolean);
  TCmdCallback     = reference to procedure(const [ref] Data: TArray<byte>);
//  TAdbClient = class
//  strict private type
//    TQCommand = record
//      Command   : string;
//      Callback  : TCommandCallback;
//
//      constructor New(ACommand: string; ACallback: TCommandCallback);
//    end;
//  strict private
//    FAdbFile: string;
//
//    FQueueCommand: TThreadedQueue<TQCommand>;
//
//    FSocket: TSocket;
//
//    FSelector: TSelector;
//
//    FCommandTask: ITask;
//
//    FSelectorTask: ITask;
//    FReleaseEvent: TEvent;
//    FReadDoneEvent: TEvent;
//
//    procedure DoCommandTask;
//    procedure DoSelectorTask;
//
//    procedure DoCommand(Command: TAdbCommand; Callback: TCommandCallback);
//  protected
//
//  public
//    constructor Create(AdbFile: string);
//    destructor Destroy; override;
//
//    procedure StartServer;
//    procedure KillServer;
//
//    procedure Version(Callback: TCommandCallback);
//    procedure Kill(Callback: TCommandCallback);
//
//    procedure HostTrackDevices(Callback: TCommandCallback);
//  end;

  TAdbCommand = class abstract
  strict protected
    function GetPayload: string; virtual; abstract;
  protected
    function GetCommand: AnsiString;
  end;

  ///<summary>
  ///  Ask the ADB server for its internal version number.
  ///</summary>
  TAdbCommandHostVersion = class(TAdbCommand)
  strict private const
    CMD_TEXT = 'host:version';
  protected
    function GetPayload: string; override;
  end;

  ///<summary>
  ///  Ask the ADB server to quit immediately. This is used when the
  ///  ADB client detects that an obsolete server is running after an upgrade.
  ///</summary>
  TAdbCommandHostKill = class(TAdbCommand)
  strict private const
    CMD_TEXT = 'host:kill';
  protected
    function GetPayload: string; override;
  end;

  ///<summary>
  ///  Ask to return the list of available Android devices and their
  ///  state. devices-l includes the device paths in the state.
  ///  After the OKAY, this is followed by a 4-byte hex len,
  ///  and a string that will be dumped as-is by the client, then
  //  the connection is closed
  ///</summary>
  TAdbCommandHostDevices = class(TAdbCommand)
  strict private const
    CMD_TEXT1 = 'host:devices';
    CMD_TEXT2 = 'host:devices-l';
  strict private
    FIsIncludeDevicePath: boolean;
  protected
    function GetPayload: string; override;
  public
    constructor Create(IsIncludeDevicePath: boolean = false);
  end;

  ///<summary>
  ///  This is a variant of host:devices which doesn't close the
  ///  connection. Instead, a new device list description is sent
  ///  each time a device is added/removed or the state of a given
  ///  device changes (hex4 + content). This allows tools like DDMS
  ///  to track the state of connected devices in real-time without
  ///  polling the server repeatedly.
  ///</summary>
  TAdbCommandHostTrackDevices = class(TAdbCommand)
  strict private const
    CMD_TEXT = 'host:track-devices';
  protected
    function GetPayload: string; override;
  end;

  ///<summary>
  ///  This is a special query that is sent to the ADB server when a
  ///  new emulator starts up. <port> is a decimal number corresponding
  ///  to the emulator's ADB control port, i.e. the TCP port that the
  ///  emulator will forward automatically to the adbd daemon running
  ///  in the emulator system.
  ///  This mechanism allows the ADB server to know when new emulator
  ///  instances start.
  ///</summary>
  TAdbCommandHostEmulator = class(TAdbCommand)
  strict private const
    CMD_TEXT = 'host:emulator:%d';
  strict private
    FPort: word;
  protected
    function GetPayload: string; override;
  public
    constructor Create(Port: word);
  end;

  ///<summary>
  ///  Ask to switch the connection to the device/emulator identified by
  ///  <serial-number>. After the OKAY response, every client request will
  ///  be sent directly to the adbd daemon running on the device.
  ///  (Used to implement the -s option)
  ///</summary>
  TAdbCommandHostTransport = class(TAdbCommand)
  strict private const
    CMD_TEXT = 'host:transport:%s';
  strict private
    FSerialNumber: string;
  protected
    function GetPayload: string; override;
  public
    constructor Create(SerialNumber: string);
  end;

  ///<summary>
  ///  Ask to switch the connection to one device connected through USB
  ///  to the host machine. This will fail if there are more than one such
  ///  devices. (Used to implement the -d convenience option)
  ///</summary>
  TAdbCommandHostTransportUsb = class(TAdbCommand)
  strict private const
    CMD_TEXT = 'host:transport-usb';
  protected
    function GetPayload: string; override;
  end;

  ///<summary>
  ///  Ask to switch the connection to one emulator connected through TCP.
  ///  This will fail if there is more than one such emulator instance
  ///  running. (Used to implement the -e convenience option)
  ///</summary>
  TAdbCommandHostTransportLocal = class(TAdbCommand)
  strict private const
    CMD_TEXT = 'host:transport-local';
  protected
    function GetPayload: string; override;
  end;

  ///<summary>
  ///  Another host:transport variant. Ask to switch the connection to
  ///  either the device or emulator connect to/running on the host.
  ///  Will fail if there is more than one such device/emulator available.
  ///  (Used when neither -s, -d or -e are provided)
  ///</summary>
  TAdbCommandHostTransportAny = class(TAdbCommand)
  strict private const
    CMD_TEXT = 'host:transport-any';
  protected
    function GetPayload: string; override;
  end;

  ///<summary>
  ///  This is a special form of query, where the 'host-serial:<serial-number>:'
  ///  prefix can be used to indicate that the client is asking the ADB server
  ///  for information related to a specific device. <request> can be in one
  ///  of the format described below.
  ///</summary>
  TAdbCommandHostSerial = class(TAdbCommand)
  strict private const
    CMD_TEXT = 'host-serial:%s:%s';
  strict private
    FSerialNumber: string;
    FRequest: string;
  protected
    function GetPayload: string; override;
  public
    constructor Create(SerialNumber, Request: string);
  end;

  ///<summary>
  ///  A variant of host-serial used to target the single USB device connected
  ///  to the host. This will fail if there is none or more than one.
  ///</summary>
  TAdbCommandHostUsb = class(TAdbCommand)
  strict private const
    CMD_TEXT = 'host-usb:%s';
  strict private
    FRequest: string;
  protected
    function GetPayload: string; override;
  public
    constructor Create(Request: string);
  end;

  ///<summary>
  ///  A variant of host-serial used to target the single emulator instance
  ///  running on the host. This will fail if there is none or more than one.
  ///</summary>
  TAdbCommandHostLocal = class(TAdbCommand)
  strict private const
    CMD_TEXT = 'host-local:%s';
  strict private
    FRequest: string;
  protected
    function GetPayload: string; override;
  public
    constructor Create(Request: string);
  end;

  ///<summary>
  ///  When asking for information related to a device, 'host:' can also be
  ///  interpreted as 'any single device or emulator connected to/running on
  ///  the host'.
  ///</summary>
  TAdbCommandHostRequest = class(TAdbCommand)
  strict private const
    CMD_TEXT = 'host:%s';
  strict private
    FRequest: string;
  protected
    function GetPayload: string; override;
  public
    constructor Create(Request: string);
  end;

  TAdbCommandTrackJdwp = class(TAdbCommand)
  strict private const
    CMD_TEXT = 'track-jdwp';
  protected
    function GetPayload: string; override;
  end;

  TAdbCommandJwdp = class(TAdbCommand)
  strict private const
    CMD_TEXT = 'jdwp:%d';
  strict private
    FPid: integer;
  protected
    function GetPayload: string; override;
  public
    constructor Create(pid: integer);
  end;

  //LOCAL SERVICES

  TAdbCommandShell = class(TAdbCommand)
  strict private const
    CMD_TEXT = 'shell:%s';
  strict private
    FRequest: string;
  protected
   function GetPayload: string; override;
  public
    constructor Create(Request: string);
  end;

  TAdbFrameBuffer = class(TAdbCommand)
  strict private const
    CMD_TEXT = 'framebuffer:';
  protected
   function GetPayload: string; override;
  end;

  TAdbCommandReboot = class(TAdbCommand)
  strict private const
    CMD_TEXT = 'reboot:%s';
  strict private
    FInto: string;
  protected
   function GetPayload: string; override;
  public
    constructor Create(Into: string);
  end;

  TAdbCommandLog = class(TAdbCommand)
  strict private const
    CMD_TEXT = 'log:%s';
  strict private
    FLogName: string;
  protected
   function GetPayload: string; override;
  public
    constructor Create(LogName: string);
  end;

  TAdbCommandSync = class(TAdbCommand)
  strict private const
    CMD_TEXT = 'sync:';
  protected
    function GetPayload: string; override;
  end;


//  ///<summary>
//  ///  Ask the ADB server for its internal version number.
//  ///</summary>
//  TAdbCommandHostVersion = class(TAdbCommand)
//  strict private const
//    CMD_TEXT = 'host:version';
//  protected
//    function GetPayload: string; override;
//  end;

implementation

uses
    System.Process
  , System.Rtti
//  , Winapi.Winsock2
  ;

{ TAdbCommand }

function TAdbCommand.GetCommand: AnsiString;
begin
  var Prepared := format('%s%s', [IntToHex(GetPayload.Length, 4), GetPayload]);

  result := AnsiString(TEncoding.ASCII.GetString(TEncoding.Convert(TEncoding.Default, TEncoding.ASCII, BytesOf(Prepared))));
end;

{ TAdbCommandHostVersion }

function TAdbCommandHostVersion.GetPayload: string;
begin
  result := CMD_TEXT;
end;

{ TAdbCommandHostDevices }

constructor TAdbCommandHostDevices.Create(IsIncludeDevicePath: boolean);
begin
  FIsIncludeDevicePath := IsIncludeDevicePath;
end;

function TAdbCommandHostDevices.GetPayload: string;
begin
  if FIsIncludeDevicePath then
    result := CMD_TEXT2
  else
    result := CMD_TEXT1;
end;

{ TAdbCommandHostTrackDevices }

function TAdbCommandHostTrackDevices.GetPayload: string;
begin
  result := CMD_TEXT;
end;

{ TAdbCommandHostEmulator }

constructor TAdbCommandHostEmulator.Create(Port: word);
begin
  FPort := Port;
end;

function TAdbCommandHostEmulator.GetPayload: string;
begin
  result := format(CMD_TEXT, [FPort]);
end;

{ TAdbCommandHostTransport }

constructor TAdbCommandHostTransport.Create(SerialNumber: string);
begin
  FSerialNumber := SerialNumber;
end;

function TAdbCommandHostTransport.GetPayload: string;
begin
  result := format(CMD_TEXT, [FSerialNumber]);
end;

{ TAdbCommandHostTransportUsb }

function TAdbCommandHostTransportUsb.GetPayload: string;
begin
  result := CMD_TEXT;
end;

{ TAdbCommandHostTransportLocal }

function TAdbCommandHostTransportLocal.GetPayload: string;
begin
  result := CMD_TEXT;
end;

{ TAdbCommandHostTransportAny }

function TAdbCommandHostTransportAny.GetPayload: string;
begin
  result := CMD_TEXT;
end;

{ TAdbCommandHostSerial }

constructor TAdbCommandHostSerial.Create(SerialNumber, Request: string);
begin
  FSerialNumber := SerialNumber;
  FRequest      := Request;
end;

function TAdbCommandHostSerial.GetPayload: string;
begin
  result := Format(CMD_TEXT, [FSerialNumber, FRequest]);
end;

{ TAdbCommandHostUsb }

constructor TAdbCommandHostUsb.Create(Request: string);
begin
  FRequest := Request;
end;

function TAdbCommandHostUsb.GetPayload: string;
begin
  result := format(CMD_TEXT, [FRequest]);
end;

{ TAdbCommandHostLocal }

constructor TAdbCommandHostLocal.Create(Request: string);
begin
  FRequest := Request;
end;

function TAdbCommandHostLocal.GetPayload: string;
begin
  result := Format(CMD_TEXT, [FRequest]);
end;

{ TAdbCommandHostRequest }

constructor TAdbCommandHostRequest.Create(Request: string);
begin
  FRequest := Request;
end;

function TAdbCommandHostRequest.GetPayload: string;
begin
  result := Format(CMD_TEXT, [FRequest]);
end;

//{ TAdbClient }
//
//constructor TAdbClient.Create(AdbFile: string);
//begin
//  FAdbFile        := AdbFile;
//
//  FQueueCommand   := TThreadedQueue<TQCommand>.Create;
//  FSelector       := TSelector.Create;
//  FReleaseEvent   := TEvent.Create;
//  FReadDoneEvent  := TEvent.Create;
//  FSelectorTask   := TTask.Run(DoSelectorTask);
//  FCommandTask    := TTask.Run(DoCommandTask);
//
//  FSocket         := TSocket.Create(TSocketType.TCP);
//end;
//
//destructor TAdbClient.Destroy;
//begin
//  FReleaseEvent.SetEvent;
//  FReadDoneEvent.SetEvent;
//  TTask.WaitForAll([FSelectorTask, FCommandTask]);
//
//  FQueueCommand.Free;
//  FReadDoneEvent.Free;
//  FReleaseEvent.Free;
//  FSelector.Free;
//  FSocket.Free;
//  inherited;
//end;
//
//procedure TAdbClient.DoCommand(Command: TAdbCommand; Callback: TCommandCallback);
//begin
//  if assigned(Command) then
//  begin
//    FQueueCommand.PushItem(TQCommand.New(String(Command.GetCommand), Callback));
//    Command.Free;
//  end;
//end;
//
//procedure TAdbClient.DoCommandTask;
//begin
//  while FReleaseEvent.WaitFor(0) = wrTimeout do
//  begin
//    var QCommand: TQCommand;
//    if FQueueCommand.PopItem(QCommand) = wrSignaled then
//    begin
//
//      var IsWriteDone := false;
//      repeat
//        if not (TSocketState.Connected in FSocket.State) then
//        begin
//          FSocket.Connect('', '127.0.0.1', '', 5037);
//        end;
//
//        try
//          var ReadyWrite := TFDSet.Create(FSocket);
//          if TSocket.Select(nil, @ReadyWrite, nil, INFINITE) = wrSignaled then
//            if ReadyWrite.IsSet(FSocket) then
//              FSocket.Send(QCommand.Command);
//
//          IsWriteDone := true;
//        except
//          on E: ESocketError do
//          begin
//            FSocket.Close;
//            IsWriteDone := false;
//          end;
//        end;
//      until IsWriteDone or (FReleaseEvent.WaitFor(0) = wrSignaled);
//
//      if FReleaseEvent.WaitFor(0) = wrSignaled then
//        break;
//
//
//      var IsReadDone := false;
//      repeat
//        var ReadyRead := TFDSet.Create(FSocket);
//        if TSocket.Select(@ReadyRead, nil, nil, INFINITE) = wrSignaled then
//          if ReadyRead.IsSet(FSocket) then
//          begin
//            var Data: TArray<byte>;
//            Data := FSocket.Receive(-1, [TSocketFlag.WAITALL]);
//            QCommand.Callback(Data, IsReadDone);
//          end;
//      until IsReadDone or (FReleaseEvent.WaitFor(0) = wrSignaled);
//    end;
//
//  end;


//  var DoCurrentCallback: TCmdCallback :=
//    procedure(const [ref] Data: TArray<byte>)
//    begin
//      var IsDone := false;
//
//      if assigned(FCurrentCallback) then
//        FCurrentCallback(Data, IsDone);
//    end;
//
//
//  FReadDoneEvent.SetEvent;
//
//  while FReleaseEvent.WaitFor(0) = wrTimeout do
//  begin
//    if FReadDoneEvent.WaitFor = wrSignaled then
//    begin
//      try
//        var QCommand: TQCommand;
//        if FQueueCommand.PopItem(QCommand) = wrSignaled then
//        begin
//          if not (TSocketState.Connected in FSocket.State) then
//          begin
//            FSelector.Remove(FSocket);
//            FSocket.Connect('', '127.0.0.1', '', 5037);
//            FSelector.Add(FSocket, [OP_READ], TValue.From<TCmdCallback>(DoCurrentCallback));
//          end;
//
//          FReadDoneEvent.ResetEvent;
//
//          FCurrentCallback := QCommand.Callback;
//          FSocket.Send(QCommand.Command);
//        end;
//      except
//        on E: Exception do
//          TDebug.WriteLine('[TAdbClient.DoCommandTask] '+E.ClassName+':'+E.Message);
//      end;
//
//    end;
//  end;
//end;

//procedure TAdbClient.DoSelectorTask;
//begin
//  while FReleaseEvent.WaitFor(0) = wrTimeout do
//  begin
//    try
//      FSelector.Select(1000,
//        procedure(Key: TSelectionKey)
//        begin
//          Key.Selector.ResetEvent;
//          if Key.IsRead then
//          begin
//            var Data: TArray<byte>;
//            if Key.Socket.ReceiveLength > 0 then
//              Data := Key.Socket.Receive;
//
//            if not Key.Attachment.IsEmpty then
//            begin
//              if Key.Attachment.IsType<TCmdCallback> then
//              begin
//                var Callback := Key.Attachment.AsType<TCmdCallback>;
//                Callback(Data);
//              end;
//            end;
//
//            FReadDoneEvent.SetEvent;
//          end;
//        end);
//    except
//      on E: Exception do
//        TDebug.WriteLine('[TAdbClient.DoSelectorTask] '+E.ClassName+':'+E.Message)
//    end;
//  end;
//end;
//
//procedure TAdbClient.HostTrackDevices(Callback: TCommandCallback);
//begin
//  DoCommand(TAdbCommandHostTrackDevices.Create, Callback);
//end;
//
//procedure TAdbClient.Kill(Callback: TCommandCallback);
//begin
//  DoCommand(TAdbCommandHostKill.Create, Callback);
//end;
//
//procedure TAdbClient.KillServer;
//var
//  CommandResult: AnsiString;
//begin
//  RunCommand(FAdbFile, ['kill-server'], CommandResult);
//end;
//
//procedure TAdbClient.StartServer;
//var
//  CommandResult: AnsiString;
//begin
//  RunCommand(FAdbFile, ['start-server'], CommandResult);
//end;
//
//procedure TAdbClient.Version(Callback: TCommandCallback);
//begin
//  DoCommand(TAdbCommandHostVersion.Create, Callback);
//end;

{ TAdbCommandHostKill }

function TAdbCommandHostKill.GetPayload: string;
begin
  result := CMD_TEXT;
end;

//{ TAdbClient.TQCommand }
//
//constructor TAdbClient.TQCommand.New(ACommand: string; ACallback: TCommandCallback);
//begin
//  Command   := ACommand;
//  Callback  := ACallback;
//end;

{ TAdbCommandTrackJdwp }

function TAdbCommandTrackJdwp.GetPayload: string;
begin
  result := CMD_TEXT;
end;

{ TAdbCommandJwdp }

constructor TAdbCommandJwdp.Create(pid: integer);
begin
  FPid := pid;
end;

function TAdbCommandJwdp.GetPayload: string;
begin
  result := Format(CMD_TEXT, [FPid]);
end;

{ TAdbCommandShell }

constructor TAdbCommandShell.Create(Request: string);
begin
  FRequest := Request;
end;

function TAdbCommandShell.GetPayload: string;
begin
  result := format(CMD_TEXT, [FRequest]);
end;

{ TAdbFrameBuffer }

function TAdbFrameBuffer.GetPayload: string;
begin
  result := CMD_TEXT;
end;

{ TAdbCommandReboot }

constructor TAdbCommandReboot.Create(Into: string);
begin
  FInto := Into;
end;

function TAdbCommandReboot.GetPayload: string;
begin
  result := format(CMD_TEXT, [FInto]);
end;

{ TAdbCommandLog }

constructor TAdbCommandLog.Create(LogName: string);
begin
  FLogName := LogName;
end;

function TAdbCommandLog.GetPayload: string;
begin
  result := format(CMD_TEXT, [FLogName]);
end;

{ TAdbCommandSync }

function TAdbCommandSync.GetPayload: string;
begin
  result := CMD_TEXT;
end;

end.
