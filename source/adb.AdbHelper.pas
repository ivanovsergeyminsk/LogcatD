unit adb.AdbHelper;

interface

uses
    System.SysUtils
  , System.Net.Socket
  , System.Net.SocketHelper
  , System.Classes
  , System.Math
  , System.Types
  , System.Types.Nullable
  , Common.Debug

  , adb.AndroidDebugBridge
  , adb.Protocol
  , adb.Preferences
  , adb.RawImage
  ;

type
  EAdbException = class(Exception);
  ETimeoutException = class(EAdbException);
  EAdbCommandRejectedException = class(EAdbException);
  EShellCommandUnresponsiveException = class(EAdbException);

  /// Response from ADB.
  TAdbResponse = record
    OKAY: boolean; // first 4 bytes in response were "OKAY"?
    Msg: string; // diagnostic string if #okay is false
  end;

  TAdbHelper = class
  const
    WAIT_TIME = 5; // spin-wait sleep, in ms
  public

    /// Executes a shell command on the device and retrieve the output. The output is
    /// handed to <var>rcvr</var> as it arrives.
    ///
    /// @param adbSockAddr the {@link InetSocketAddress} to adb.
    /// @param command the shell command to execute
    /// @param device the {@link IDevice} on which to execute the command.
    /// @param rcvr the {@link IShellOutputReceiver} that will receives the output of the shell
    ///            command
    /// @param maxTimeToOutputResponse max time between command output. If more time passes
    ///            between command output, the method will throw
    ///            {@link ShellCommandUnresponsiveException}. A value of 0 means the method will
    ///            wait forever for command output and never throw.
    /// @throws TimeoutException in case of timeout on the connection when sending the command.
    /// @throws AdbCommandRejectedException if adb rejects the command
    /// @throws ShellCommandUnresponsiveException in case the shell command doesn't send any output
    ///            for a period longer than <var>maxTimeToOutputResponse</var>.
    /// @throws IOException in case of I/O error on the connection.
    ///
    /// @see DdmPreferences#getTimeOut()
    class procedure ExecuteRemoteCommand(AdbSockAddr: TNetEndpoint; Command: string; Device: IDevice; Receiver: IShellOutputReceiver; maxTimeToOutputResponse: integer); static;

    /// Retrieve the frame buffer from the device.
    /// @throws TimeoutException in case of timeout on the connection.
    /// @throws AdbCommandRejectedException if adb rejects the command
    /// @throws IOException in case of I/O error on the connection.
    class function GetFrameBuffer(AdbSockAddr: TNetEndpoint; Device: IDevice): Nullable<TRawImage>; static;

    /// Reboot the device.
    ///
    /// @param into what to reboot into (recovery, bootloader).  Or null to just reboot.
    /// @throws TimeoutException in case of timeout on the connection.
    /// @throws AdbCommandRejectedException if adb rejects the command
    /// @throws IOException in case of I/O error on the connection.
    class procedure Reboot(Into: string; AdbSockAddr: TNetEndpoint; Device: IDevice); static;

    /// Runs the Event log service on the {@link Device}, and provides its output to the
    /// {@link LogReceiver}.
    /// <p/>This call is blocking until {@link LogReceiver#isCancelled()} returns true.
    /// @param adbSockAddr the socket address to connect to adb
    /// @param device the Device on which to run the service
    /// @param rcvr the {@link LogReceiver} to receive the log output
    /// @throws TimeoutException in case of timeout on the connection.
    /// @throws AdbCommandRejectedException if adb rejects the command
    /// @throws IOException in case of I/O error on the connection.
    class procedure RunEventLogService(AdbSockAddr: TNetEndpoint; Device: IDevice; Receiver: ILogReceiver);

    /// Runs a log service on the {@link Device}, and provides its output to the {@link LogReceiver}.
    /// <p/>This call is blocking until {@link LogReceiver#isCancelled()} returns true.
    /// @param adbSockAddr the socket address to connect to adb
    /// @param device the Device on which to run the service
    /// @param logName the name of the log file to output
    /// @param rcvr the {@link LogReceiver} to receive the log output
    /// @throws TimeoutException in case of timeout on the connection.
    /// @throws AdbCommandRejectedException if adb rejects the command
    /// @throws IOException in case of I/O error on the connection.
    class procedure RunLogService(AdbSockAddr: TNetEndpoint; Device: IDevice; LogName: string; Receiver: ILogReceiver);

    class function FormAdbRequest(req: string): TArray<byte>; static;
    class procedure Write(Channel: TSocket; const [ref] Data: TArray<byte>); static;
    class procedure Read(Channel: TSocket; var Data: TArray<byte>; ALength, Timeout: integer); overload; static;
    class procedure Read(Channel: TSocket; var Data: TArray<byte>); overload; static;
    class function ReadAdbResponse(Channel: TSocket; ReadDiagString: boolean): TAdbResponse; static;

    /// Checks to see if the first four bytes in "reply" are OKAY.
    class function IsOkay(const [ref] Reply: TArray<byte>): boolean; static;

    /// Converts an ADB reply to a string.
    class function ReplyToString(const [ref] Reply: TArray<byte>): string;  static;


    // tells adb to talk to a specific device
    //
    // @param adbChan the socket connection to adb
    // @param device The device to talk to.
    // @throws TimeoutException in case of timeout on the connection.
    // @throws AdbCommandRejectedException if adb rejects the command
    // @throws IOException in case of I/O error on the connection.
    class procedure SetDevice(Channel: TSocket; Device: IDevice); static;

    //* Creates and connects a new pass-through socket, from the host to a port on
    //* the device.
    //*
    //* @param adbSockAddr
    //* @param device the device to connect to. Can be null in which case the connection will be
    //* to the first available device.
    //* @param pid the process pid to connect to.
    //* @throws TimeoutException in case of timeout on the connection.
    //* @throws AdbCommandRejectedException if adb rejects the command
    //* @throws IOException in case of I/O error on the connection.
    class function CreatePassThroughConnection(AdbSockAddr: TNetEndpoint; Device: IDevice; Pid: integer): TSocket; static;

    /// Creates a port forwarding between a local and a remote port.
    /// @param adbSockAddr the socket address to connect to adb
    /// @param device the device on which to do the port forwarding
    /// @param localPortSpec specification of the local port to forward, should be of format
    ///                             tcp:<port number>
    /// @param remotePortSpec specification of the remote port to forward to, one of:
    ///                             tcp:<port>
    ///                             localabstract:<unix domain socket name>
    ///                             localreserved:<unix domain socket name>
    ///                             localfilesystem:<unix domain socket name>
    ///                             dev:<character device name>
    ///                             jdwp:<process pid> (remote only)
    /// @throws TimeoutException in case of timeout on the connection.
    /// @throws AdbCommandRejectedException if adb rejects the command
    /// @throws IOException in case of I/O error on the connection.
    class procedure CreateForward(AdbSockAddr: TNetEndpoint; Device: IDevice; LocalPortSpec, RemotePortSpec: string); static;

    /// Remove a port forwarding between a local and a remote port.
    /// @param adbSockAddr the socket address to connect to adb
    /// @param device the device on which to remove the port forwarding
    /// @param localPortSpec specification of the local port that was forwarded, should be of format
    ///                             tcp:<port number>
    /// @param remotePortSpec specification of the remote port forwarded to, one of:
    ///                             tcp:<port>
    ///                             localabstract:<unix domain socket name>
    ///                             localreserved:<unix domain socket name>
    ///                             localfilesystem:<unix domain socket name>
    ///                             dev:<character device name>
    ///                             jdwp:<process pid> (remote only)
    /// @throws TimeoutException in case of timeout on the connection.
    /// @throws AdbCommandRejectedException if adb rejects the command
    /// @throws IOException in case of I/O error on the connection.
    class procedure RemoveForward(AdbSockAddr: TNetEndpoint; Device: IDevice; LocalPortSpec, RemotePortSpec: string); static;
  end;

implementation

type
  TAdbCommandX = class(TAdbCommand);

{ TAdbHelper }

class procedure TAdbHelper.CreateForward(AdbSockAddr: TNetEndpoint; Device: IDevice; LocalPortSpec, RemotePortSpec: string);
begin
  var Channel := TSocket.Create;
  try
    Channel.Connect(AdbSockAddr);
    var Command := TAdbCommandHostSerial.Create(Device.GetSerialNumber, format('forward:$s;%s', [LocalPortSpec, RemotePortSpec]));
    try
      Write(Channel, BytesOf(TAdbCommandX(Command).GetCommand));
    finally
      Command.Free;
    end;

    var Response := ReadAdbResponse(Channel, false);
    if not Response.OKAY then
      raise EAdbCommandRejectedException.Create(Response.Msg);

  finally
    Channel.Close;
    Channel.Free;
  end;
end;

class function TAdbHelper.CreatePassThroughConnection(AdbSockAddr: TNetEndpoint; Device: IDevice; Pid: integer): TSocket;
begin
  var Channel := TSocket.Create;
  try
    Channel.Connect(AdbSockAddr);
    Channel.SetTcpNoDelay(true);
//    Channel.ConfigureBlocking(false);

    // if the device is not -1, then we first tell adb we're looking to
    // talk to a specific device
    SetDevice(Channel, Device);

    var Command := TAdbCommandJwdp.Create(Pid);
    try
      write(Channel, BytesOf(TAdbCommandX(Command).GetCommand));
    finally
      Command.Free;
    end;

    var Response := ReadAdbResponse(Channel, false);
    if not Response.OKAY then
      raise EAdbCommandRejectedException.Create(Response.Msg);
  except
    on E: Exception do
    begin
      FreeAndNil(Channel);
      Exception.RaiseOuterException(EIOException.Create(E.Message));
    end;
  end;

  result := Channel;
end;

class procedure TAdbHelper.ExecuteRemoteCommand(AdbSockAddr: TNetEndpoint;
  Command: string; Device: IDevice; Receiver: IShellOutputReceiver;
  maxTimeToOutputResponse: integer);
begin
  var Channel := TSocket.Create(TSocketType.TCP);
  try
    Channel.ConnectTimeout := maxTimeToOutputResponse;
    Channel.SendTimeout    := maxTimeToOutputResponse;
    Channel.ReceiveTimeout := maxTimeToOutputResponse;

    Channel.Connect(AdbSockAddr);
    TDebug.WriteLine('"W: ExecuteRemoteCommand" '+Command+' connected');

    SetDevice(Channel, Device);
    TDebug.WriteLine('"W: ExecuteRemoteCommand" '+Command+' SetDivice');

    var Cmd := TAdbCommandShell.Create(Command);
    try
      Write(Channel, BytesOf(TAdbCommandX(Cmd).GetCommand));
    finally
      FreeAndNil(cmd);
    end;
    TDebug.WriteLine('"W: ExecuteRemoteCommand" '+Command+' TAdbCommandShell');

    var Response := ReadAdbResponse(Channel, false);
    if not Response.OKAY then
      raise EAdbCommandRejectedException.Create(Response.Msg);
    TDebug.WriteLine('"W: ExecuteRemoteCommand" '+Command+' Response');

    var Data: TArray<byte>;
    while true do
    begin
      if assigned(Receiver) and Receiver.IsCancelled then
        break;
      Data := [];
      SetLength(Data, 16384);
      var NeedCount := min(Channel.ReceiveLength, 16384);
      var count := Channel.Receive(Data, NeedCount);

      if count = 0 then
      begin
        TDebug.WriteLine('"W: ExecuteRemoteCommand" '+Command+' Reciver.Flush');
        Receiver.Flush;
      end
      else
      begin
        // send data to receiver if present
        if Receiver <> nil then
        begin
          TDebug.WriteLine('"W: ExecuteRemoteCommand" '+Command+' Receiver.AddOutput');
          Receiver.AddOutput(Data, 0, count);
        end;
      end;
    end;
  finally
    Channel.Close;
    FreeAndNil(Channel);
  end;
end;

class function TAdbHelper.FormAdbRequest(req: string): TArray<byte>;
begin
  var resultStr := String.Format('%04X%s', [req.Length, req]);
  result := TEncoding.Convert(TEncoding.Default, TEncoding.ASCII, BytesOf(resultStr));

  Assert(length(result) = (req.Length+4));
end;

class function TAdbHelper.GetFrameBuffer(AdbSockAddr: TNetEndpoint; Device: IDevice): Nullable<TRawImage>;
begin
  var ImageParams: TRawImage;

  var Channel := TSocket.Create;
  try
    Channel.Connect(AdbSockAddr);
    SetDevice(Channel, Device);

    var Command := TAdbFrameBuffer.Create;
    try
      Write(Channel, BytesOf(TAdbCommandX(Command).GetCommand));
    finally
      Command.Free;
    end;

    var Response := ReadAdbResponse(Channel, false);
    if not Response.OKAY then
      raise EAdbCommandRejectedException.Create(Response.Msg);

    var Reply: TArray<byte>;
    SetLength(Reply, 4);
    Read(Channel, Reply);
//
    var version := TBitConverter.InTo<UInt32>(Reply);

//     get the header size (this is a count of int)
    var HeaderSize := TRawImage.GetHeaderSize(version);

//     read the header
    Reply := [];
    SetLength(Reply, HeaderSize);
    read(Channel, Reply);

    // fill the RawImage with the header
    if not ImageParams.ReadHeader(version, Reply) then
      exit(nil);

    Reply := [];

    write(Channel, [0]);
    SetLength(Reply, ImageParams.Size);
    Read(Channel, Reply);
    version := Channel.ReceiveLength;

    ImageParams.Data := Reply;
  finally
   Channel.Close;
   Channel.Free;
  end;

  result := ImageParams;
end;

class function TAdbHelper.IsOkay(const [ref] Reply: TArray<byte>): boolean;
begin
  if Length(Reply) < 4 then
    exit(false);

  result := (Reply[0] = ord('O')) and (Reply[1] = ord('K')) and
            (Reply[2] = ord('A')) and (Reply[3] = ord('Y'));
end;

class procedure TAdbHelper.Read(Channel: TSocket; var Data: TArray<byte>; ALength, Timeout: integer);
begin
  var Limit := ifthen(ALength <> -1, ALength, Length(Data));

  Channel.ReceiveTimeout := Timeout;
  Channel.Receive(Data, Limit);
end;

class procedure TAdbHelper.Read(Channel: TSocket; var Data: TArray<byte>);
begin
  Read(Channel, Data, -1, TAdbPreferences.GetTimeout);
end;

class function TAdbHelper.ReadAdbResponse(Channel: TSocket; ReadDiagString: boolean): TAdbResponse;
begin
  var Reply: TArray<byte>;
  SetLength(Reply, 4);
  Read(Channel, Reply);

  if IsOkay(Reply) then
    Result.OKAY := true
  else
  begin
    ReadDiagString := true; // look for a reason after the FAIL
    Result.OKAY := false;
  end;


  // not a loop -- use "while" so we can use "break"
  try
    while ReadDiagString do
    begin
      var LenBuf: TArray<byte>;
      SetLength(LenBuf, 4);
      Read(Channel, LenBuf);

      var LenStr: string := ReplyToString(LenBuf);

      var len: integer;
      try
        len := Integer.Parse(LenStr);
      except
        on E: Exception do
          break;
      end;

      var msg: TArray<byte>;
      SetLength(msg, len);
      Read(Channel, msg);

      result.Msg := ReplyToString(msg);

      break;
    end;

  except
    on E: Exception do
      // ignore those, since it's just reading the diagnose string, the response will
      // contain okay==false anyway.
  end;
end;

class procedure TAdbHelper.Reboot(Into: string; AdbSockAddr: TNetEndpoint; Device: IDevice);
begin
  var Channel := TSocket.Create(TSocketType.TCP);
  try
    Channel.Connect(AdbSockAddr);

    SetDevice(Channel, Device);

    var Cmd := TAdbCommandReboot.Create(Into);
    try
      Write(Channel, BytesOf(TAdbCommandX(Cmd).GetCommand));
    finally
      FreeAndNil(cmd);
    end;
  finally
    Channel.Close;
    FreeAndNil(Channel);
  end;
end;

class procedure TAdbHelper.RemoveForward(AdbSockAddr: TNetEndpoint; Device: IDevice; LocalPortSpec, RemotePortSpec: string);
begin
  var Channel := TSocket.Create;
  try
    Channel.Connect(AdbSockAddr);
    var Command := TAdbCommandHostSerial.Create(Device.GetSerialNumber, format('killforward:$s;%s', [LocalPortSpec, RemotePortSpec]));
    try
      Write(Channel, BytesOf(TAdbCommandX(Command).GetCommand));
    finally
      Command.Free;
    end;

    var Response := ReadAdbResponse(Channel, false);
    if not Response.OKAY then
      raise EAdbCommandRejectedException.Create(Response.Msg);

  finally
    Channel.Close;
    Channel.Free;
  end;
end;

class function TAdbHelper.ReplyToString(const [ref] Reply: TArray<byte>): string;
begin
  try
    result := TEncoding.ASCII.GetString(Reply);
  except
    on E: Exception do
      result := string.Empty;
  end;
end;

class procedure TAdbHelper.RunEventLogService(AdbSockAddr: TNetEndpoint; Device: IDevice; Receiver: ILogReceiver);
begin
  RunLogService(AdbSockAddr, Device, 'events', Receiver);
end;

class procedure TAdbHelper.RunLogService(AdbSockAddr: TNetEndpoint; Device: IDevice; LogName: string; Receiver: ILogReceiver);
begin
  var Channel := TSocket.Create(TSocketType.TCP);
  try
    Channel.Connect(AdbSockAddr);

    SetDevice(Channel, Device);

    var Cmd := TAdbCommandLog.Create(LogName);
    try
      Write(Channel, BytesOf(TAdbCommandX(Cmd).GetCommand));
    finally
      FreeAndNil(cmd);
    end;

    var Response := ReadAdbResponse(Channel, false);
    if not Response.OKAY then
      raise EAdbCommandRejectedException.Create(Response.Msg);

    var Data: TArray<byte>;
    SetLength(Data, 16384);
    while true do
    begin
      if assigned(Receiver) and Receiver.IsCancelled then
        break;

      var NeedCound := min(Channel.ReceiveLength, 16384);
      var count := Channel.Receive(Data, NeedCound);

      if count = 0 then
      begin
//        Receiver.Flush;
        break;
      end
      else
      begin
        // send data to receiver if present
        if Receiver <> nil then
          Receiver.ParseNewData(Data, 0, count);
      end;
    end;
  finally
    Channel.Close;
    FreeAndNil(Channel);
  end;
end;

class procedure TAdbHelper.SetDevice(Channel: TSocket; Device: IDevice);
begin
  // if the device is not -1, then we first tell adb we're looking to talk
  // to a specific device
  if Device <> nil then
  begin
    var Command := TAdbCommandHostTransport.Create(Device.GetSerialNumber);
    try
      Write(Channel, BytesOf(TAdbCommandX(Command).GetCommand));
    finally
      Command.Free;
    end;

    var Response := ReadAdbResponse(Channel, false);
    if not Response.OKAY then
      raise EAdbCommandRejectedException.Create(Response.Msg);
  end;

end;

class procedure TAdbHelper.Write(Channel: TSocket; const [ref] Data: TArray<byte>);
begin
  Channel.SendTimeout := TAdbPreferences.GetTimeout;
  Channel.Send(Data);
end;


end.
