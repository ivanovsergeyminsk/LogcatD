unit adb.DeviceMonitor;

interface

uses
    System.Net.Socket
  , System.Net.SocketHelper
//  , System.Net.Selector
  , System.Generics.Collections
  , System.Classes
  , System.SysUtils
  , System.SyncObjs
  , System.Threading
  , System.Rtti
  , Common.Debug

  , adb.AndroidDebugBridge
  , adb.Protocol
  , adb.Receiver.MultiLineReceiver
  , adb.Receiver.GetPropReceiver
  ;

type
  TDeviceMonitor = class(TInterfacedObject, IDeviceMonitor)
  private
    FLengthBuffer:  TArray<byte>;
    FLengthBuffer2: TArray<byte>;
    FQuit: TEvent;
    FServer: TAndroidDebugBridge;
    FMainAdbConnection: TSocket;
    FMonitoring: boolean;
    FConnectionAttempt: integer;
    FRestartAttemptCount: integer;
    FInitialDeviceListDone: boolean;
    FDevices: TList<IDevice>;

    ///<summary>
    /// Fills a buffer from a socket.<p/>
    /// @param socket<p/>
    /// @param buffer<p/>
    /// @return the content of the buffer as a string, or null if it failed to convert the buffer.<p/>
    /// @return ETimeoutException
    /// @throws EIOException
    ///</summary>
    function Read(Socket: TSocket; var Buffer: TArray<byte>): string;

    ///<summary>
    /// Reads the length of the next message from a socket.<p/>
    /// @param socket The {@link SocketChannel} to read from.<p/>
    /// @return the length, or 0 (zero) if no data is available from the socket.<p/>
    /// @throws EIOException if the connection failed.
    ///</summary>
    function ReadLength(Socket: TSocket; var Buffer: TArray<byte>): integer;

    ///<summary>Sleeps for a little bit.</summary>
    procedure WaitABit;
    /// Updates the device list with the new items received from the monitoring service.
    procedure UpdateDevices(NewList: TList<IDevice>);

    procedure RemoveDevice(Device: IDevice);

    /// Queries a device for its build info.
    /// @param device the device to query.
    procedure QueryNewDeviceForInfo(Device: IDevice);
    procedure QueryNewDeviceForMountingPoint(Device: IDevice; Name: string);

    ///<summary>Attempts to connect to the debug bridge server.</summary>
    ///<returns>A connect socket if success, nil otherwise</returns>
    function OpenAdbConnection: TSocket;
  private
    //MONITOR LOOP
    FDeviceMonitorLoop: ITask;
    ///<summary>
    /// Monitors the devices. This connects to the Debug Bridge
    ///</summary>
    procedure DeviceMonitorLoop;
    procedure OpenConnection;
    ///<summary>
    /// @throws IOException
    ///</summary>
    function SendDeviceListMonitoringRequest: boolean;
    ///<summary>
    /// Processes an incoming device message from the socket
    /// @param socket
    /// @param length
    /// @throws ETimeoutException
    /// @throws IOException
    ///<sumamry>
    procedure ProcessIncomingDeviceData(ALength: integer);
    procedure HandleExpectionInMonitorLoop(E: Exception);
  public
    ///<summary>
    /// Creates a new {@link DeviceMonitor} object and links it to the running
    /// {@link AndroidDebugBridge} object.<p/>
    /// @param server the running {@link AndroidDebugBridge}.
    ///</summary>
    constructor Create(Server: TAndroidDebugBridge);
    destructor Destroy; override;

    ///<summary>Starts the monitoring.</summary>
    procedure Start;
    ///<summary>Stops the monitoring.</summary>
    procedure Stop;
    ///<sumamry>Returns if the monitor is currently connected to the debug bridge server.</summary>
    function IsMonitoring: boolean;

    function HasInitialDeviceList: boolean;
    ///<summary>Returns the devices.</summary>
    function GetDevices: TArray<IDevice>;

    function GetServer: TAndroidDebugBridge;
  end;

implementation

uses
    adb.Device
  , adb.AdbHelper
  ;

type
  TAdbCommandX = class(TAdbCommand);

{ TDeviceMonitor }

constructor TDeviceMonitor.Create(Server: TAndroidDebugBridge);
begin
  inherited Create;
  SetLength(FLengthBuffer, 4);
  SetLength(FLengthBuffer2, 4);
  FQuit := TEvent.Create;
  FServer := nil;
  FMainAdbConnection := nil;
  FMonitoring := false;
  FConnectionAttempt := 0;
  FRestartAttemptCount := 0;
  FInitialDeviceListDone := false;
  FDevices := TList<IDevice>.Create;
  FServer := Server;
end;

destructor TDeviceMonitor.Destroy;
begin
  FDevices.Free;
  FQuit.Free;
  inherited;
end;

procedure TDeviceMonitor.DeviceMonitorLoop;
begin
  repeat
    try
      if FMainAdbConnection = nil then
        OpenConnection;

      if (FMainAdbConnection <> nil) and (not FMonitoring) then
        FMonitoring := SendDeviceListMonitoringRequest;

      if FMonitoring then
      begin
        // read the length of the incoming message
        var IncomingLength := ReadLength(FMainAdbConnection, FLengthBuffer);
        if IncomingLength >= 0 then
        begin
          // read the incoming message
          ProcessIncomingDeviceData(IncomingLength);
          // flag the fact that we have build the list at least once.
          FInitialDeviceListDone := true;
        end;
      end;

    except
      on E: ETimeoutException do
      begin
        TDebug.WriteLine('"W: DeviceMonitor" Adb connection Error: timeout');
        if FQuit.WaitFor(0) = wrSignaled then
          break;
        continue;
      end;
      on E: Exception do
        HandleExpectionInMonitorLoop(E);
    end;
  until FQuit.WaitFor(0) = wrSignaled;
end;

function TDeviceMonitor.GetDevices: TArray<IDevice>;
begin
  TMonitor.Enter(FDevices);
  try
    result := FDevices.ToArray;
  finally
    TMonitor.Exit(FDevices);
  end;
end;

function TDeviceMonitor.GetServer: TAndroidDebugBridge;
begin
  result := FServer;
end;

procedure TDeviceMonitor.HandleExpectionInMonitorLoop(E: Exception);
begin
  if FQuit.WaitFor(0) <> wrSignaled then
  begin
    if E is ETimeoutException then
      TDebug.WriteLine('"E: DeviceMonitor" Adb connection Error: timeout')
    else
      TDebug.WriteLine('"E: DeviceMonitor" Adb connection Error: '+E.Message);

    FMonitoring := false;
    if FMainAdbConnection <> nil then
    begin
      try
        FMainAdbConnection.Close;
      except
        on E: Exception do
          // we can safely ignore that one.
      end;
      FreeAndNIl(FMainAdbConnection);

      // remove all devices from list
      // because we are going to call mServer.deviceDisconnected which will acquire this
      // lock we lock it first, so that the AndroidDebugBridge lock is always locked
      // first.

      TMonitor.Enter(TAndroidDebugBridge.GetLock);
      try
        TMonitor.Enter(FDevices);
        try
          while FDevices.Count <> 0 do
          begin
            var Device := FDevices.Last;
            RemoveDevice(Device);
            FServer.DeviceDisconnected(Device);
          end;
        finally
          TMonitor.Exit(FDevices);
        end;
      finally
        TMonitor.Exit(TAndroidDebugBridge.GetLock);
      end;
    end;
  end;
end;

function TDeviceMonitor.HasInitialDeviceList: boolean;
begin
  result := FInitialDeviceListDone;
end;

function TDeviceMonitor.IsMonitoring: boolean;
begin
  result := FMonitoring;
end;

function TDeviceMonitor.OpenAdbConnection: TSocket;
begin
  TDebug.WriteLine('"D: DeviceMonitor" Connecting to adb for Device List Monitoring...');

  result := TSocket.Create(TSocketType.TCP);
  try
    result.Connect(TAndroidDebugBridge.GetSocketAddress);
    result.SetTcpNoDelay(true);
  except
    on E: Exception do
      FreeAndNil(result);
  end;
end;

procedure TDeviceMonitor.OpenConnection;
begin
  TDebug.WriteLine('"D: DeviceMonitor" Opening adb connection');
  FMainAdbConnection := OpenAdbConnection;
  if FMainAdbConnection = nil then
  begin
    inc(FConnectionAttempt);
    TDebug.WriteLine('E: "DevliceMonitor" Connection attempts: '+FConnectionAttempt.ToString);
    if FConnectionAttempt > 10 then
    begin
      if not FServer.StartAdb then
      begin
        inc(FRestartAttemptCount);
        TDebug.WriteLine('E: "DevliceMonitor" adb restart attempts: '+FRestartAttemptCount.ToString);
      end
      else
        FRestartAttemptCount := 0;
    end;

    WaitABit;
  end
  else
  begin
    TDebug.WriteLine('"D: DeviceMonitor" Connected to adb for device monitoring');
    FConnectionAttempt := 0;
  end;
end;

procedure TDeviceMonitor.ProcessIncomingDeviceData(ALength: integer);
begin
  var List := TList<IDevice>.Create;
  try
    if ALength > 0 then
    begin
      var buff: TArray<byte>;
      SetLength(buff, ALength);
      var LResult := Read(FMainAdbConnection, buff);
      var devices := LResult.Split([#10]);

      for var d in devices do
      begin
        TDebug.WriteLine('"D: DeviceMonitor" Device '+ d);
        var param := d.Split([#09]);
        if Length(param) = 2 then
        begin
          // new adb uses only serial numbers to identify devices
          var Device := TDevice.Create(self, param[0], TDeviceState.GetState(param[1]));
          List.Add(Device);
        end;
      end;
    end;

    // now merge the new devices with the old ones.
    UpdateDevices(List);
  finally
    List.Free;
  end;
end;


procedure TDeviceMonitor.QueryNewDeviceForInfo(Device: IDevice);
begin
  {$MESSAGE WARN 'TODO: implement'}
  exit;
  // TODO: do this in a separate thread.
  try
    // first get the list of properties.
    Device.ExecuteShellCommand(TGetPropReceiver.GETPROP_COMMAND, TGetPropReceiver.Create(Device));

    QueryNewDeviceForMountingPoint(Device, MNT_EXTERNAL_STORAGE);
    QueryNewDeviceForMountingPoint(Device, MNT_DATA);
    QueryNewDeviceForMountingPoint(Device, MNT_ROOT);

    // now get the emulator Virtual Device name (if applicable).
    if Device.IsEmulator then
    begin
      {$MESSAGE WARN 'TODO: EmulatorConsole console'}
    end;
  except
    on E: Exception do
    begin
      {$MESSAGE WARN 'TODO: LOG'}
      TDebug.WriteLine('"E: DeviceMonitor" QueryNewDeviceForInfo: '+ E.ClassName+':'+E.Message);
      (*
        } catch (TimeoutException e) {
            Log.w("DeviceMonitor", String.format("Connection timeout getting info for device %s",
                    device.getSerialNumber()));

        } catch (AdbCommandRejectedException e) {
            // This should never happen as we only do this once the device is online.
            Log.w("DeviceMonitor", String.format(
                    "Adb rejected command to get  device %1$s info: %2$s",
                    device.getSerialNumber(), e.getMessage()));

        } catch (ShellCommandUnresponsiveException e) {
            Log.w("DeviceMonitor", String.format(
                    "Adb shell command took too long returning info for device %s",
                    device.getSerialNumber()));

        } catch (IOException e) {
            Log.w("DeviceMonitor", String.format(
                    "IO Error getting info for device %s",
                    device.getSerialNumber()));
      *)
    end;
  end;
end;

procedure TDeviceMonitor.QueryNewDeviceForMountingPoint(Device: IDevice; Name: string);
begin
  Device.ExecuteShellCommand('echo $'+Name, TMultiLineReceiver.Construct(
    function(): boolean
    begin
      result := false;
    end,

    procedure(const [ref] Lines: TArray<string>)
    begin
      for var Line in Lines do
      begin
        if not Line.IsEmpty then
          // this should be the only one.
          TDevice(Device).SetMountingPoint(Name, Line);
      end;
    end
  ));
end;

function TDeviceMonitor.Read(Socket: TSocket; var Buffer: TArray<byte>): string;
begin
  try
    Socket.Receive(Buffer, Length(Buffer));
    result := TEncoding.ASCII.GetString(Buffer);
  except
    on E: EEncodingError do
      // we'll return null below.
      result := string.Empty;

    on E: ESocketError do
    begin
      if E.Code =  10060 then
        Exception.RaiseOuterException(ETimeoutException.Create('TDeviceMonitor.Read: '+E.Message))
      else
        Exception.RaiseOuterException(EIOException.Create('TDeviceMonitor.Read: '+E.Message));
    end;

    on E: Exception do
      Exception.RaiseOuterException(EIOException.Create('TDeviceMonitor.Read: '+E.Message));
  end;
end;

function TDeviceMonitor.ReadLength(Socket: TSocket; var Buffer: TArray<byte>): integer;
begin
  var msg: string := Read(Socket, Buffer);

  if not msg.IsEmpty then
  begin
    try
      result := Integer.Parse('$'+msg);
      exit;
    except
      on E: Exception do
        //we'll throw an exception below.
    end;
  end;

  raise EIOException.Create('Unable to read length');
end;

procedure TDeviceMonitor.RemoveDevice(Device: IDevice);
begin
  FDevices.Remove(Device);
end;

function TDeviceMonitor.SendDeviceListMonitoringRequest: boolean;
begin
  result := false;

  var Request: TArray<byte>;
  var Command := TAdbCommandHostTrackDevices.Create;
  try
    request := BytesOf(TAdbCommandX(Command).GetCommand);
  finally
    Command.Free;
  end;

  try
    TAdbHelper.Write(FMainAdbConnection, request);
    var Response := TAdbHelper.ReadAdbResponse(FMainAdbConnection, false);
    if not Response.OKAY then
      // request was refused by adb!
      TDebug.WriteLine('"E: DeviceMonitor" adb refused request: '+ Response.Msg);

    result := Response.OKAY;
  except
    on E: Exception do
    begin
      TDebug.WriteLine('"E: DeviceMonitor" Sending Tracking request failed!');
      FMainAdbConnection.Close;
      FreeAndNil(FMainAdbConnection);
      Exception.RaiseOuterException(EIOException.Create('Sending Tracking request failed!'));
    end;
  end;
end;

procedure TDeviceMonitor.Start;
begin
  FDeviceMonitorLoop := TTask.Run(
    procedure
    begin
      TThread.CurrentThread.NameThreadForDebugging('Device List Monitor');
      DeviceMonitorLoop;
    end,
    TAndroidDebugBridge.GetThreadPool
  );
end;

procedure TDeviceMonitor.Stop;
begin
  FQuit.SetEvent;
  // wakeup the main loop thread by closing the main connection to adb.
  try
    if FMainAdbConnection <> nil then
    begin
      FMainAdbConnection.Close;
      FreeAndNil(FMainAdbConnection);
    end;
  except
    on E: Exception do
  end;

  TTask.WaitForAll([FDeviceMonitorLoop]);
end;

procedure TDeviceMonitor.UpdateDevices(NewList: TList<IDevice>);
begin
  // because we are going to call mServer.deviceDisconnected which will acquire this lock
  // we lock it first, so that the AndroidDebugBridge lock is always locked first.
  TMonitor.Enter(TAndroidDebugBridge.GetLock);
  try
    // array to store the devices that must be queried for information.
    // it's important to not do it inside the synchronized loop as this could block
    // the whole workspace (this lock is acquired during build too).
    var DevicesToQuery: TArray<IDevice>;
    TMonitor.Enter(FDevices);
    try
      // For each device in the current list, we look for a matching the new list.
      // * if we find it, we update the current object with whatever new information
      //   there is
      //   (mostly state change, if the device becomes ready, we query for build info).
      //   We also remove the device from the new list to mark it as "processed"
      // * if we do not find it, we remove it from the current list.
      // Once this is done, the new list contains device we aren't monitoring yet, so we
      // add them to the list, and start monitoring them.

      for var d := 0 to FDevices.Count-1 do
      begin
        var Device := FDevices[d];

        // look for a similar device in the new list.
        var count := NewList.Count;
        var FoundMatch := false;
        for var dd := 0 to count-1 do
        begin
          var NewDevice := NewList[dd];
           // see if it matches in id and serial number.
          if NewDevice.GetSerialNumber.Equals(Device.GetSerialNumber) then
          begin
            FoundMatch := true;

            // update the state if needed.
            if Device.GetState <> NewDevice.GetState then
            begin
              TDevice(Device).SetState(NewDevice.GetState);
              TDevice(Device).Update([TDeviceChange.ChangeState]);

              // if the device just got ready/online, we need to start
              // monitoring it.

              if Device.IsOnline then
              begin
                if TAndroidDebugBridge.GetClientSupport then
                begin
//                  if not StartMonitoringDevice(Device) then
//                    TDebug.WriteLine('"E: DeviceMonitor" Failed to start monitoring '+Device.GetSerialNumber);
                end;

                if Device.GetPropertyCount = 0 then
                  DevicesToQuery := DevicesToQuery + [Device];
              end;
            end;

            // remove the new device from the list since it's been used
            NewList.Delete(dd);
            break;
          end;
        end;

        if not FoundMatch then
        begin
          // the device is gone, we need to remove it, and keep current index
          // to process the next one.
          RemoveDevice(Device);
          FServer.DeviceDisconnected(Device);
        end;
      end;

      // at this point we should still have some new devices in newList, so we
      // process them.
      for var NewDevice in NewList do
      begin
        // add them to the list
        FDevices.Add(NewDevice);
        FServer.DeviceConnected(NewDevice);

        // start monitoring them.
        if TAndroidDebugBridge.GetClientSupport then
        begin
//          if NewDevice.IsOnline then
//            StartMonitoringDevice(NewDevice);
        end;

        // look for their build info.
        if NewDevice.IsOnline then
          DevicesToQuery := DevicesToQuery + [NewDevice];
      end;
    finally
      TMonitor.Exit(FDevices);
    end;

    // query the new devices for info.
    for var d in DevicesToQuery do
      QueryNewDeviceForInfo(d);

  finally
    TMonitor.Exit(TAndroidDebugBridge.GetLock);
  end;

  NewList.Clear;
end;

procedure TDeviceMonitor.WaitABit;
begin
  try
    TThread.Sleep(1000);
  except
    on E: Exception do
      exit;
  end;
end;

end.
