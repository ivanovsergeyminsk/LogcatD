unit adb.AndroidDebugBridge;

interface

uses
    System.Net.Socket
  , System.SysUtils
  , System.Process
  , System.Generics.Collections
  , System.Threading
  , System.Types.Nullable
  , adb.RawImage
  , Common.Debug
  ;

type
  EAndroidDebugBridge = class(Exception);
  EIllegalArgument    = class(EAndroidDebugBridge);
  EInvalidParameter   = class(EAndroidDebugBridge);
  EIOException        = class(EAndroidDebugBridge);
  EParseException     = class(EAndroidDebugBridge);
  EInstallException   = class(EAndroidDebugBridge);

  TAndroidDebugBridge        = class;

  IDeviceMonitor             = interface;
  IDevice                    = interface;
  IClient                    = interface;
  IClientData                = interface;


  IDebugBridgeChangeListener = interface;
  IDeviceChangeListener      = interface;
  IShellOutputReceiver       = interface; 
  ILogReceiver               = interface;

  {$SCOPEDENUMS ON}

  TDeviceChange = (
    ChangeState,
    ChangeClientList,
    ChangeBuildInfo
  );
  TDeviceChanges = set of TDeviceChange;

  TClientChange = (
    ChangeName,
    ChangeDebuugerStatus,
    ChangePort,
    ChangeThreadMode,
    ChangeThreadData,
    ChangeHeapMode,
    ChangeHeapData,
    ChangeNativeHeapData,
    ChangeThreadStacktract,
    ChangeHeapAllocations,
    ChangeHeapAllocationStatus,
    ChangeMethodProfilingStatus
  );
  TClientChanges = set of TClientChange;

  TDeviceState = (
    BOOTLOADER,
    OFFLINE,
    ONLINE,
    RECOVERY,
    AUTHORIZING
  );

  TDeviceStateHelper = record helper for TDeviceState
    class function GetState(State: string): TDeviceState; static;

    function ToString: string;
  end;   

  ///<summary> Namespace of a Unix Domain Socket created on the device. </summary>
  TDeviceUnixSocketNamespace = (
    &ABSTRACT,
    FILESYSTEM,
    RESERVED
  );

  TDeviceUnixSocketNamespaceHelper = record helper for TDeviceUnixSocketNamespace
    function GetType: string;
  end;


  {$SCOPEDENUMS OFF}
  
  /// Classes which implement this interface provide a method that deals
  /// with {@link AndroidDebugBridge} changes.
  IDebugBridgeChangeListener = interface
  ['{67188EB7-EE73-461D-93CD-34B2E1D5B520}']

    /// Sent when a new {@link AndroidDebugBridge} is connected.
    /// <p/>
    /// This is sent from a non UI thread.
    /// @param bridge the new {@link AndroidDebugBridge} object.
    procedure BridgeChanged(Bridge: TAndroidDebugBridge);
  end;

  /// Classes which implement this interface provide methods that deal
  /// with {@link IDevice} addition, deletion, and changes.
  IDeviceChangeListener = interface
  ['{0E46046B-69B8-4560-82F4-E1A2BEEA2171}']

    /// Sent when the a device is connected to the {@link AndroidDebugBridge}.
    /// <p/>
    /// This is sent from a non UI thread.
    /// @param device the new device.
    procedure DeviceConnected(Device: IDevice);

    /// Sent when the a device is connected to the {@link AndroidDebugBridge}.
    /// <p/>
    /// This is sent from a non UI thread.
    /// @param device the new device.
    procedure DeviceDisconnected(Device: IDevice);

    /// Sent when a device data changed, or when clients are started/terminated on the device.
    /// <p/>
    /// This is sent from a non UI thread.
    /// @param device the device that was updated.
    /// @param changeMask the mask describing what changed. It can contain any of the following
    /// values: {@link IDevice#CHANGE_BUILD_INFO}, {@link IDevice#CHANGE_STATE},
    /// {@link IDevice#CHANGE_CLIENT_LIST}
    procedure DeviceChanged(Device: IDevice; Change: TDeviceChanges);
  end;

  /// Classes which implement this interface provide methods that deal with out from a remote shell
  /// command on a device/emulator.
  IShellOutputReceiver = interface
  ['{CD3EF2CF-6538-429D-B283-0B58D8B0186E}']
    /// Called every time some new data is available.
    /// @param data The new data.
    /// @param offset The offset at which the new data starts.
    /// @param length The length of the new data.
    procedure AddOutput(const [ref] Data: TArray<byte>; offset, ALength: integer);

    /// Called at the end of the process execution (unless the process was
    /// canceled). This allows the receiver to terminate and flush whatever
    /// data was not yet processed.
    procedure Flush;

    /// Cancel method to stop the execution of the remote shell command.
    /// @return true to cancel the execution of the command.
    function IsCancelled: boolean;
  end;



  ///<summary>
  /// A Device monitor. This connects to the Android Debug Bridge and get device and
  /// debuggable process information from it.
  ///</summary>
  IDeviceMonitor = interface
  ['{2E7A5475-CB68-4871-9997-82C19D170DCB}']
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

  ///<summary> A Device. It can be a physical device or an emulator. </summary>
  IDevice = interface
  ['{2DB6BF9A-2144-484A-AACB-DB27967D14AC}']
    ///<summary> Returns the serial number of the device. </summary>
    function GetSerialNumber: string;

    ///<summary>
    /// Returns the name of the AVD the emulator is running.
    /// <p/>This is only valid if {@link #isEmulator()} returns true.
    /// <p/>If the emulator is not running any AVD (for instance it's running from an Android source
    /// tree build), this method will return "<code>&lt;build&gt;</code>".
    /// @return the name of the AVD or <code>null</code> if there isn't any.
    ///</summary>
    function GetAvdName: string;

    ///<summary> Returns the state of the device. </summary>
    function GetState: TDeviceState;

    ///<summary> Returns the device properties. It contains the whole output of 'getprop' </summary>
    function GetProperties: TDictionary<string, string>;

    ///<summary> Returns the number of property for this device. </summary>
    function GetPropertyCount: integer;

    ///<summary>
    /// Returns the cached property value.
    /// @param name the name of the value to return.
    /// @return the value or <code>null</code> if the property does not exist or has not yet been
    /// cached.
    ///</summary>
    function GetProperty(Name: string): string;

    ///<summary> Returns <code>true></code> if properties have been cached </summary>
    function ArePropertiesSet: boolean;

    ///<summary>
    /// A variant of {@link #getProperty(String)} that will attempt to retrieve the given
    /// property from device directly, without using cache.
    /// @param name the name of the value to return.
    /// @return the value or <code>null</code> if the property does not exist
    /// @throws TimeoutException in case of timeout on the connection.
    /// @throws AdbCommandRejectedException if adb rejects the command
    /// @throws ShellCommandUnresponsiveException in case the shell command doesn't send output for a
    ///             given time.
    /// @throws IOException in case of I/O error on the connection.
    ///</summary>
    function GetPropertySync(Name: string): string;

    ///<summary>
    /// A combination of {@link #getProperty(String)} and {@link #getPropertySync(String)} that
    /// will attempt to retrieve the property from cache if available, and if not, will query the
    /// device directly.
    /// @param name the name of the value to return.
    /// @return the value or <code>null</code> if the property does not exist
    /// @throws TimeoutException in case of timeout on the connection.
    /// @throws AdbCommandRejectedException if adb rejects the command
    /// @throws ShellCommandUnresponsiveException in case the shell command doesn't send output for a
    ///             given time.
    /// @throws IOException in case of I/O error on the connection.
    ///</summary>
    function GetPropertyCacheOrSync(Name: string): string;

    /// Returns a mount point.
    /// @param name the name of the mount point to return
    /// @see #MNT_EXTERNAL_STORAGE
    /// @see #MNT_ROOT
    /// @see #MNT_DATA
    function GetMountPoint(Name: string): string;

    ///<summary>
    /// Returns if the device is ready.
    /// @return <code>true</code> if {@link #getState()} returns {@link DeviceState#ONLINE}.
    ///</summary>
    function IsOnline: boolean;

    ///<summary> Returns <code>true</code> if the device is an emulator. </summary>
    function IsEmulator: boolean;

    ///<summary>
    /// Returns if the device is offline.
    /// @return <code>true</code> if {@link #getState()} returns {@link DeviceState#OFFLINE}.
    ///</summary>
    function IsOffline: boolean;

    ///<summary>
    /// Returns if the device is in bootloader mode.
    /// @return <code>true</code> if {@link #getState()} returns {@link DeviceState#BOOTLOADER}.
    ///</summary>
    function IsBootLoader: boolean;

    function GetScreenshot: Nullable<TRawImage>;

    /// Executes a shell command on the device, and sends the result to a <var>receiver</var>
    /// <p/>This is similar to calling
    /// <code>executeShellCommand(command, receiver, DdmPreferences.getTimeOut())</code>.
    ///
    /// @param command the shell command to execute
    /// @param receiver the {@link IShellOutputReceiver} that will receives the output of the shell
    ///             command
    /// @throws TimeoutException in case of timeout on the connection.
    /// @throws AdbCommandRejectedException if adb rejects the command
    /// @throws ShellCommandUnresponsiveException in case the shell command doesn't send output
    ///            for a given time.
    /// @throws IOException in case of I/O error on the connection.
    ///
    /// @see #executeShellCommand(String, IShellOutputReceiver, int)
    /// @see DdmPreferences#getTimeOut()
    procedure ExecuteShellCommand(Command: string; Receiver: IShellOutputReceiver); overload;

    ///<summary>
    /// Runs the event log service and outputs the event log to the {@link LogReceiver}.
    /// <p/>This call is blocking until {@link LogReceiver#isCancelled()} returns true.
    /// @param receiver the receiver to receive the event log entries.
    /// @throws TimeoutException in case of timeout on the connection. This can only be thrown if the
    /// timeout happens during setup. Once logs start being received, no timeout will occur as it's
    /// not possible to detect a difference between no log and timeout.
    /// @throws AdbCommandRejectedException if adb rejects the command
    /// @throws IOException in case of I/O error on the connection.
    ///</summary>
    procedure RunEventLogService(Receiver: ILogReceiver);

    ///<summary>
    /// Runs the log service for the given log and outputs the log to the {@link LogReceiver}.
    /// <p/>This call is blocking until {@link LogReceiver#isCancelled()} returns true.
    /// @param logname the logname of the log to read from.
    /// @param receiver the receiver to receive the event log entries.
    /// @throws TimeoutException in case of timeout on the connection. This can only be thrown if the
    ///            timeout happens during setup. Once logs start being received, no timeout will
    ///            occur as it's not possible to detect a difference between no log and timeout.
    /// @throws AdbCommandRejectedException if adb rejects the command
    /// @throws IOException in case of I/O error on the connection.
    ///</summary>
    procedure RunLogService(Logname: string; Receiver: ILogReceiver);

    ///<summary>
    /// Creates a port forwarding between a local and a remote port.
    /// @param localPort the local port to forward
    /// @param remotePort the remote port.
    /// @throws TimeoutException in case of timeout on the connection.
    /// @throws AdbCommandRejectedException if adb rejects the command
    /// @throws IOException in case of I/O error on the connection.    
    ///</summary>
    procedure CreateForward(LocalPort, RemotePort: integer); overload;

    ///<summary>
    /// Creates a port forwarding between a local TCP port and a remote Unix Domain Socket.
    /// @param localPort the local port to forward
    /// @param remoteSocketName name of the unix domain socket created on the device
    /// @param namespace namespace in which the unix domain socket was created
    /// @throws TimeoutException in case of timeout on the connection.
    /// @throws AdbCommandRejectedException if adb rejects the command
    /// @throws IOException in case of I/O error on the connection.
    ///</summary>
    procedure CreateForward(LocalPort: integer; RemoteSocketName: string; Namespace: TDeviceUnixSocketNamespace); overload;

    ///<summary>
    /// Removes a port forwarding between a local and a remote port.
    /// @param localPort the local port to forward
    /// @param remotePort the remote port.
    /// @throws TimeoutException in case of timeout on the connection.
    /// @throws AdbCommandRejectedException if adb rejects the command
    /// @throws IOException in case of I/O error on the connection.
    ///</summary>
    procedure RemoveForward(LocalPort, RemotePort: integer); overload;

    ///<summary>
    /// Removes an existing port forwarding between a local and a remote port.
    /// @param localPort the local port to forward
    /// @param remoteSocketName the remote unix domain socket name.
    /// @param namespace namespace in which the unix domain socket was created
    /// @throws TimeoutException in case of timeout on the connection.
    /// @throws AdbCommandRejectedException if adb rejects the command
    /// @throws IOException in case of I/O error on the connection.
    ///</summary>
    procedure RemoveForward(LocalPort: integer; RemoteSocketName: string; Namespace: TDeviceUnixSocketNamespace); overload;

    ///<summary>
    /// Returns the name of the client by pid or <code>null</code> if pid is unknown
    /// @param pid the pid of the client.
    ///</summary>
    function GetClientName(Pid: integer): string;

    ///<summary>
    /// Reboot the device.
    /// @param into the bootloader name to reboot into, or null to just reboot the device.
    /// @throws TimeoutException in case of timeout on the connection.
    /// @throws AdbCommandRejectedException if adb rejects the command
    /// @throws IOException
    ///</summary>
    procedure Reboot(Into: string);

    ///<summary>
    /// Return the device's battery level, from 0 to 100 percent.
    /// <p/>
    /// The battery level may be cached. Only queries the device for its
    /// battery level if 5 minutes have expired since the last successful query.
    /// @return the battery level or <code>null</code> if it could not be retrieved
    ///</summary>
    function GetBatteryLevel: integer; overload;

    ///<summary>
    /// Return the device's battery level, from 0 to 100 percent.
    /// <p/>
    /// The battery level may be cached. Only queries the device for its
    /// battery level if <code>freshnessMs</code> ms have expired since the last successful query.
    /// @param freshnessMs
    /// @return the battery level or <code>null</code> if it could not be retrieved
    /// @throws ShellCommandUnresponsiveException    
    ///</summary>
    function GetBatteryLevel(FreshnessMs: int64): integer; overload;
  end;

  ///<summary>
  /// Receiver able to provide low level parsing for device-side log services.
  ///</summary>
  ILogReceiver = interface
  ['{B6BBAF77-DF33-4CD2-8655-69911B0F354C}']
    ///<summary>
    /// Parses new data coming from the log service.
    /// @param data the data buffer
    /// @param offset the offset into the buffer signaling the beginning of the new data.
    /// @param length the length of the new data.
    ///</summary>
    procedure ParseNewData(const [ref] Data; Offset, ALength: integer);

    ///<summary> Returns whether this receiver is canceling the remote service.</summary>
    function IsCancelled: boolean;

    ///<summary>Cancels the current remote service.</summary>
    procedure Cancel;
  end;

  ///<summary>
  /// This represents a single client, usually a Dalvik VM process.
  /// <p/>This class gives access to basic client information, as well as methods to perform actions
  /// on the client.
  /// <p/>More detailed information, usually updated in real time, can be access through the
  /// {@link ClientData} class. Each <code>Client</code> object has its own <code>ClientData</code>
  /// accessed through {@link #getClientData()}.
  ///</summary>
  IClient = interface
  ['{CD772B62-4269-4D7A-9E57-D150CFDFDB3A}']
    ///<summary> Returns the {@link IDevice} on which this Client is running. </summary>
    function GetDevice: IDevice;
    ///<summary> Returns the {@link ClientData} object containing this client information. </summary>
    function GetClientData: IClientData;
  end;

  ///<sumamry>Contains the data of a {@link Client}.</simamry>
  IClientData = interface
  ['{4FE6AC52-1F25-450B-85DF-F80C08A99D75}']
    ///<summary>  Returns the process ID. </summary>
    function GetPid: integer;
    ///<summary>
    /// Returns the client description.
    /// <p/>This is generally the name of the package defined in the
    /// <code>AndroidManifest.xml</code>.
    /// @return the client description or <code>null</code> if not the description was not yet
    /// sent by the client.
    ///</summary>
    function GetClientDescription: string;
  end;

  TAndroidDebugBridge = class
  public const
    ADB_HOST = '127.0.0.1';
    ADB_PORT = 5037;
  private const
    SERVER_PORT_ENV_VAR = 'ANDROID_ADB_SERVER_PORT';
  private
    class var FSelf: TAndroidDebugBridge;
    class var FClassLock: TObject;
    class var FThreadPool: TThreadPool;

    class var FInitialized: boolean;

    class var FHostAddr: TIPAddress;
    class var FSocketAddr: TNetEndpoint;
    class var FLock: TObject;

    class var FBridgeListeners: TList<IDebugBridgeChangeListener>;
    class var FDeviceListeners: TList<IDeviceChangeListener>;

    class constructor Create;
    class destructor Destroy;

    /// Instantiates FSocketAddr with the address of the host's adb process.
    class procedure InitAdbSocketAddr; static;

    /// Determines port where ADB is expected by looking at an env variable.
    /// <p/>
    /// The value for the environment variable ANDROID_ADB_SERVER_PORT is validated,
    /// IllegalArgumentException is thrown on illegal values.
    /// <p/>
    /// @return The port number where the host's adb should be expected or started.
    /// @throws IllegalArgumentException if ANDROID_ADB_SERVER_PORT has a non-numeric value.
    class function DetermineAndValidateAdbPort: integer; static;
  private
    FAdbOsLocation: string;
    FVersionCheck: boolean;
    FStarted: boolean;
    FDeviceMonitor: IDeviceMonitor;
  private
    /// Creates a new bridge.
    /// @param osLocation the location of the command line tool
    /// @throws InvalidParameterException
    constructor Create(OSLocation: string);

    /// Queries adb for its version number and checks it against {@link #MIN_VERSION_NUMBER} and
    /// {@link #MAX_VERSION_NUMBER}
    procedure CheckAdbVersion;

    /// Stops the adb host side server.
    /// @return true if success
    function StopAdb: boolean;
  public
    class procedure Init(ClientSupport: boolean); static;

    /// Initialized the library only if needed.
    /// @param clientSupport Indicates whether the library should enable the monitoring and
    ///                      interaction with applications running on the devices.
    /// @see #init(boolean)
    class procedure InitIfNeeded(ClientSupport: boolean); static;

    /// Terminates the ddm library. This must be called upon application termination.
    class procedure Terminate; static;

    /// Returns whether the ddmlib is setup to support monitoring and interacting with
    /// {@link Client}s running on the {@link IDevice}s.
    class function GetClientSupport: boolean;

    /// Returns the socket address of the ADB server on the host.
    class function GetSocketAddress: TNetEndpoint; static;


    /// Creates a {@link AndroidDebugBridge} that is not linked to any particular executable.
    /// <p/>This bridge will expect adb to be running. It will not be able to start/stop/restart
    /// adb.
    /// <p/>If a bridge has already been started, it is directly returned with no changes (similar
    /// to calling {@link #getBridge()}).
    /// @return a connected bridge.
//    class function CreateBridge: TAndroidDebugBridge; overload; static;

    /// Creates a new debug bridge from the location of the command line tool.
    /// <p/>
    /// Any existing server will be disconnected, unless the location is the same and
    /// <code>forceNewBridge</code> is set to false.
    /// @param osLocation the location of the command line tool 'adb'
    /// @param forceNewBridge force creation of a new bridge even if one with the same location
    /// already exists.
    /// @return a connected bridge.
    class function CreateBridge(OSLocation: string; ForceNewBridge: boolean): TAndroidDebugBridge; overload; static;

    /// Returns the current debug bridge. Can be <code>null</code> if none were created.
    class function GetBridge: TAndroidDebugBridge;

    /// Disconnects the current debug bridge, and destroy the object.
    /// <p/>This also stops the current adb host server.
    /// <p/>
    /// A new object will have to be created with {@link #createBridge(String, boolean)}.
    class procedure DisconnectBridge; static;

    /// Adds the listener to the collection of listeners who will be notified when a new
    /// {@link AndroidDebugBridge} is connected, by sending it one of the messages defined
    /// in the {@link IDebugBridgeChangeListener} interface.
    /// @param listener The listener which should be notified.
    class procedure AddDebugBridgeChangeListener(Listener: IDebugBridgeChangeListener); static;

    /// Removes the listener from the collection of listeners who will be notified when a new
    /// {@link AndroidDebugBridge} is started.
    /// @param listener The listener which should no longer be notified.
    class procedure RemoveDebugBridgeChangeListener(Listener: IDebugBridgeChangeListener); static;

    /// Adds the listener to the collection of listeners who will be notified when a {@link IDevice}
    /// is connected, disconnected, or when its properties or its {@link Client} list changed,
    /// by sending it one of the messages defined in the {@link IDeviceChangeListener} interface.
    /// @param listener The listener which should be notified.
    class procedure AddDeviceChangeListener(Listener: IDeviceChangeListener); static;

    /// Removes the listener from the collection of listeners who will be notified when a
    /// {@link IDevice} is connected, disconnected, or when its properties or its {@link Client}
    /// list changed.
    /// @param listener The listener which should no longer be notified.
    class procedure RemoveDeviceChangeListener(Listener: IDeviceChangeListener); static;

    class function GetThreadPool: TThreadPool; static;

    /// Returns the singleton lock used by this class to protect any access to the listener.
    /// <p/>
    /// This includes adding/removing listeners, but also notifying listeners of new bridges,
    /// devices, and clients.
    class function GetLock: TObject; static;


    /// Returns the devices.
    /// @see #hasInitialDeviceList()
    function GetDevices: TArray<IDevice>;

    /// Returns whether the bridge has acquired the initial list from adb after being created.
    /// <p/>Calling {@link #getDevices()} right after {@link #createBridge(String, boolean)} will
    /// generally result in an empty list. This is due to the internal asynchronous communication
    /// mechanism with <code>adb</code> that does not guarantee that the {@link IDevice} list has been
    /// built before the call to {@link #getDevices()}.
    /// <p/>The recommended way to get the list of {@link IDevice} objects is to create a
    /// {@link IDeviceChangeListener} object.
    function HasInitialDeviceList: boolean;

    /// Starts the debug bridge.
    /// @return true if success.
    function Start: boolean;

    /// Kills the debug bridge, and the adb host server.
    /// @return true if success
    function Stop: boolean;

    /// Restarts adb, but not the services around it.
    /// @return true if success.
    function Restart: boolean;

    /// Starts the adb host side server.
    /// @return true if success
    function StartAdb: boolean;

    /// Returns the {@link DeviceMonitor} object.
    function GetDeviceMonitor: IDeviceMonitor;


    /// Notify the listener of a new {@link IDevice}.
    /// <p/>
    /// The notification of the listeners is done in a synchronized block. It is important to
    /// expect the listeners to potentially access various methods of {@link IDevice} as well as
    /// {@link #getDevices()} which use internal locks.
    /// <p/>
    /// For this reason, any call to this method from a method of {@link DeviceMonitor},
    /// {@link IDevice} which is also inside a synchronized block, should first synchronize on
    /// the {@link AndroidDebugBridge} lock. Access to this lock is done through {@link #getLock()}.
    /// @param device the new <code>IDevice</code>.
    /// @see #getLock()
    procedure DeviceConnected(Device: IDevice);

    /// Notify the listener of a disconnected {@link IDevice}.
    /// <p/>
    /// The notification of the listeners is done in a synchronized block. It is important to
    /// expect the listeners to potentially access various methods of {@link IDevice} as well as
    /// {@link #getDevices()} which use internal locks.
    /// <p/>
    /// For this reason, any call to this method from a method of {@link DeviceMonitor},
    /// {@link IDevice} which is also inside a synchronized block, should first synchronize on
    /// the {@link AndroidDebugBridge} lock. Access to this lock is done through {@link #getLock()}.
    /// @param device the disconnected <code>IDevice</code>.
    /// @see #getLock()
    procedure DeviceDisconnected(Device: IDevice);

    /// Notify the listener of a modified {@link IDevice}.
    /// <p/>
    /// The notification of the listeners is done in a synchronized block. It is important to
    /// expect the listeners to potentially access various methods of {@link IDevice} as well as
    /// {@link #getDevices()} which use internal locks.
    /// <p/>
    /// For this reason, any call to this method from a method of {@link DeviceMonitor},
    /// {@link IDevice} which is also inside a synchronized block, should first synchronize on
    /// the {@link AndroidDebugBridge} lock. Access to this lock is done through {@link #getLock()}.
    /// @param device the modified <code>IDevice</code>.
    /// @see #getLock()
    procedure DeviceChanged(Device: IDevice; Change: TDeviceChanges);

  end;

const
  NO_STATIC_PORT = -1;

  //IDevice
  MNT_EXTERNAL_STORAGE  = 'EXTERNAL_STORAGE';
  MNT_ROOT              = 'ANDROID_ROOT';
  MNT_DATA              = 'MNT_DATA';


implementation

uses
    adb.DeviceMonitor
  ;

{ TDeviceStateHelper }

class function TDeviceStateHelper.GetState(State: string): TDeviceState;
begin
  if State.ToLower.Equals('bootloader') then
    exit(TDeviceState.BOOTLOADER);
  if State.ToLower.Equals('offline') then
    exit(TDeviceState.OFFLINE);
  if State.ToLower.Equals('device') then
    exit(TDeviceState.ONLINE);
  if State.ToLower.Equals('recovery') then
    exit(TDeviceState.RECOVERY);
  if State.ToLower.Equals('authorizing') then
    exit(TDeviceState.AUTHORIZING);

  raise Exception.Create('Unknown DeviceState: '+State);
end;

function TDeviceStateHelper.ToString: string;
begin
  case self of
    TDeviceState.BOOTLOADER:   result := 'BOOTLOADER';
    TDeviceState.OFFLINE:      result := 'OFFLINE';
    TDeviceState.ONLINE:       result := 'ONLINE';
    TDeviceState.RECOVERY:     result := 'RECOVERY';
    TDeviceState.AUTHORIZING:  result := 'AUTHORIZING';
  end;
end;  

{ TAndroidDebugBridge }

class procedure TAndroidDebugBridge.AddDebugBridgeChangeListener(
  Listener: IDebugBridgeChangeListener);
begin
  TMonitor.Enter(FLock);
  try
    if not FBridgeListeners.Contains(Listener) then
    begin
      FBridgeListeners.Add(Listener);
      if FSelf <>  nil then
        try
          Listener.BridgeChanged(FSelf);
        except
          on E: Exception do
            TDebug.WriteLine('E: "AndroidDebugBridge" '+E.ClassName+':'+E.Message);
        end;
    end;
  finally
    TMonitor.Exit(FLock);
  end;
end;

class procedure TAndroidDebugBridge.AddDeviceChangeListener(Listener: IDeviceChangeListener);
begin
  TMonitor.Enter(FLock);
  try
    if not FDeviceListeners.Contains(Listener) then
      FDeviceListeners.Add(Listener);
  finally
    TMonitor.Exit(FLock);
  end;
end;

class constructor TAndroidDebugBridge.Create;
begin
  FThreadPool  := TThreadPool.Create;

  FClassLock   := TObject.Create;
  FInitialized := false;

  FSocketAddr := TNetEndpoint.Create(TIPAddress.Create('127.0.0.1'), 5037);
  FLock := TObject.Create;

  FBridgeListeners := TList<IDebugBridgeChangeListener>.Create;
  FDeviceListeners := TList<IDeviceChangeListener>.Create;
end;

//class function TAndroidDebugBridge.CreateBridge: TAndroidDebugBridge;
//begin
//  TMonitor.Enter(FLock);
//  try
//    if FSelf <> nil then
//      exit(FSelf);
//
//    try
//      FSelf := TAndroidDebugBridge.Create;
//      FSelf.Start;
//    except
//      on E: Exception do
//        FreeAndNil(FSelf);
//    end;
//
//    // because the listeners could remove themselves from the list while processing
//    // their event callback, we make a copy of the list and iterate on it instead of
//    // the main list.
//    // This mostly happens when the application quits.
//    var ListenersCopy := FBridgeListeners.ToArray;
//
//    // notify the listeners of the change
//    for var Listener in ListenersCopy do
//    begin
//      try
//        // we attempt to catch any exception so that a bad listener doesn't kill our
//        // thread
//        Listener.BridgeChanged(FSelf);
//      except
//        on E: Exception do
//          TDebug.WriteLine('E: "AndroidDebugBridge" '+E.ClassName+':'+E.Message);
//      end;
//    end;
//
//    result := FSelf;
//  finally
//    TMonitor.Exit(FLock);
//  end;
//end;

procedure TAndroidDebugBridge.CheckAdbVersion;
begin
  // default is bad check
  FVersionCheck := false;

  if FAdbOsLocation.IsEmpty then
    exit;

  TDebug.WriteLine('D: "AndroidDebugBridge" '+format('Checking "%s" version', [FAdbOsLocation]));
  var CommandResult: AnsiString;
  if RunCommand(FAdbOsLocation, ['version'], CommandResult, [] , swoHIDE) then
  begin
    {$MESSAGE WARN 'TODO: CheckAdbVersion'}
  end;
end;

constructor TAndroidDebugBridge.Create(OSLocation: string);
begin
  if OSLocation.IsEmpty then
    raise EInvalidParameter.Create('OSLocation');

  FAdbOsLocation := OSLocation;
  FStarted       := false;

  CheckAdbVersion;
  FVersionCheck := true;
end;

class function TAndroidDebugBridge.CreateBridge(OSLocation: string; ForceNewBridge: boolean): TAndroidDebugBridge;
begin
  TMonitor.Enter(FLock);
  try
    if FSelf <> nil then
    begin
      if (not FSelf.FAdbOsLocation.IsEmpty) and (FSelf.FAdbOsLocation.Equals(OSLocation)) and (not ForceNewBridge) then
        exit(FSelf)
      else
        // stop the current server
        FSelf.Stop;
    end;

    try
      FSelf := TAndroidDebugBridge.Create(OSLocation);
      FSelf.Start;
    except
      on E: Exception do
        FreeAndNil(FSelf);
    end;

    // because the listeners could remove themselves from the list while processing
    // their event callback, we make a copy of the list and iterate on it instead of
    // the main list.
    // This mostly happens when the application quits.
    var ListenersCopy := FBridgeListeners.ToArray;

    // notify the listeners of the change
    for var Listener in ListenersCopy do
    begin
      try
        // we attempt to catch any exception so that a bad listener doesn't kill our
        // thread
        Listener.BridgeChanged(FSelf);
      except
        on E: Exception do
          TDebug.WriteLine('E: "AndroidDebugBridge" '+E.ClassName+':'+E.Message);
      end;
    end;

    result := FSelf;
  finally
    TMonitor.Exit(FLock);
  end;
end;

class destructor TAndroidDebugBridge.Destroy;
begin
  FDeviceListeners.Free;
  FBridgeListeners.Free;
  FLock.Free;
  FClassLock.Free;
  FThreadPool.Free;
end;

class function TAndroidDebugBridge.DetermineAndValidateAdbPort: integer;
begin
  var AdbEnvVar: string;
  var LResult := ADB_PORT;
  try
    AdbEnvVar := GetEnvironmentVariable(SERVER_PORT_ENV_VAR).Trim;
    if not AdbEnvVar.IsEmpty then
      LResult := Integer.Parse(AdbEnvVar);

    if LResult <= 0 then
    begin
      var errMsg := format('env var %s: illegal value "%s"', [SERVER_PORT_ENV_VAR, GetEnvironmentVariable(SERVER_PORT_ENV_VAR)]);
      raise EIllegalArgument.Create(errMsg);
    end;

  except
    on E: Exception do
    begin
      var errMsg := format('env var %s: illegal value "%s"', [SERVER_PORT_ENV_VAR, GetEnvironmentVariable(SERVER_PORT_ENV_VAR)]);
      raise EIllegalArgument.Create(errMsg);
    end;
  end;

  result := LResult;
end;

procedure TAndroidDebugBridge.DeviceChanged(Device: IDevice; Change: TDeviceChanges);
begin
  // because the listeners could remove themselves from the list while processing
  // their event callback, we make a copy of the list and iterate on it instead of
  // the main list.
  // This mostly happens when the application quits.
  var ListenersCopy: TArray<IDeviceChangeListener>;
  TMonitor.Enter(FLock);
  try
    ListenersCopy := FDeviceListeners.ToArray;
  finally
    TMonitor.Exit(FLock);
  end;

  // Notify the listeners
  for var Listener in ListenersCopy do
  begin
    try
      Listener.DeviceChanged(Device, Change);
    except
      on E: Exception do
        TDebug.WriteLine('E: "AndroidDebugBridge" '+E.ClassName+':'+E.Message);
    end;
  end;
end;

procedure TAndroidDebugBridge.DeviceConnected(Device: IDevice);
begin
  // because the listeners could remove themselves from the list while processing
  // their event callback, we make a copy of the list and iterate on it instead of
  // the main list.
  // This mostly happens when the application quits.
  var ListenersCopy: TArray<IDeviceChangeListener>;
  TMonitor.Enter(FLock);
  try
    ListenersCopy := FDeviceListeners.ToArray;
  finally
    TMonitor.Exit(FLock);
  end;

  // Notify the listeners
  for var Listener in ListenersCopy do
  begin
    try
      Listener.DeviceConnected(Device);
    except
      on E: Exception do
        TDebug.WriteLine('E: "AndroidDebugBridge" '+E.ClassName+':'+E.Message);
    end;
  end;
end;

procedure TAndroidDebugBridge.DeviceDisconnected(Device: IDevice);
begin
  // because the listeners could remove themselves from the list while processing
  // their event callback, we make a copy of the list and iterate on it instead of
  // the main list.
  // This mostly happens when the application quits.
  var ListenersCopy: TArray<IDeviceChangeListener>;
  TMonitor.Enter(FLock);
  try
    ListenersCopy := FDeviceListeners.ToArray;
  finally
    TMonitor.Exit(FLock);
  end;

  // Notify the listeners
  for var Listener in ListenersCopy do
  begin
    try
      Listener.DeviceDisconnected(Device);
    except
      on E: Exception do
        TDebug.WriteLine('E: "AndroidDebugBridge" '+E.ClassName+':'+E.Message);
    end;
  end;
end;

class procedure TAndroidDebugBridge.DisconnectBridge;
begin
  TMonitor.Enter(FLock);
  try
    if FSelf <> nil then
    begin
      FSelf.Stop;
      FreeAndNil(FSelf);

      // because the listeners could remove themselves from the list while processing
      // their event callback, we make a copy of the list and iterate on it instead of
      // the main list.
      // This mostly happens when the application quits.
      var ListenersCopy := FBridgeListeners.ToArray;

      // notify the listeners of the change
      for var Listener in ListenersCopy do
      begin
        try
          // we attempt to catch any exception so that a bad listener doesn't kill our
          // thread
          Listener.BridgeChanged(FSelf);
        except
          on E: Exception do
            TDebug.WriteLine('E: "AndroidDebugBridge" '+E.ClassName+':'+E.Message);
        end;
      end;

    end;
  finally
    TMonitor.Exit(FLock);
  end;
end;

class function TAndroidDebugBridge.GetBridge: TAndroidDebugBridge;
begin
  result := FSelf;
end;

class function TAndroidDebugBridge.GetClientSupport: boolean;
begin
  result := false;
end;

function TAndroidDebugBridge.GetDeviceMonitor: IDeviceMonitor;
begin
  result := FDeviceMonitor;
end;

function TAndroidDebugBridge.GetDevices: TArray<IDevice>;
begin
  TMonitor.Enter(FLock);
  try
    if FDeviceMonitor <> nil then
      result := TDeviceMonitor(FDeviceMonitor).GetDevices
    else
      result := [];
  finally
    TMonitor.Exit(FLock);
  end;
end;

class function TAndroidDebugBridge.GetLock: TObject;
begin
  result := FLock;
end;

class function TAndroidDebugBridge.GetSocketAddress: TNetEndpoint;
begin
  result := FSocketAddr;
end;

class function TAndroidDebugBridge.GetThreadPool: TThreadPool;
begin
  result := FThreadPool;
end;

function TAndroidDebugBridge.HasInitialDeviceList: boolean;
begin
  if FDeviceMonitor <> nil then
    result := TDeviceMonitor(FDeviceMonitor).HasInitialDeviceList
  else
    result := false;
end;

class procedure TAndroidDebugBridge.Init(ClientSupport: boolean);
begin
  TMonitor.Enter(FClassLock);
  try
    if FInitialized then
      raise Exception.Create('TAndroidDebugBridge.init() has already been called.');

    FInitialized := true;
//    FClientSupport := ClientSupport;

    // Determine port and instantiate socket address.
    InitAdbSocketAddr;

  finally
    TMonitor.Exit(FClassLock);
  end;
end;

class procedure TAndroidDebugBridge.InitAdbSocketAddr;
begin
  try
    var AdbPort := DetermineAndValidateAdbPort;
    FHostAddr   := TIPAddress.Create(ADB_HOST);
    FSocketAddr := TNetEndpoint.Create(FHostAddr, AdbPort);
  except
    on E: Exception do
      // localhost should always be known.
  end;
end;

class procedure TAndroidDebugBridge.InitIfNeeded(ClientSupport: boolean);
begin
  TMonitor.Enter(FClassLock);
  try
    if FInitialized then
      exit;

    Init(ClientSupport);
  finally
    TMonitor.Exit(FClassLock);
  end;
end;

class procedure TAndroidDebugBridge.RemoveDebugBridgeChangeListener(
  Listener: IDebugBridgeChangeListener);
begin
  TMonitor.Enter(FLock);
  try
    FBridgeListeners.Remove(Listener);
  finally
    TMonitor.Exit(FLock);
  end;
end;

class procedure TAndroidDebugBridge.RemoveDeviceChangeListener(Listener: IDeviceChangeListener);
begin
  TMonitor.Enter(FLock);
  try
    FDeviceListeners.Remove(Listener);
  finally
    TMonitor.Exit(FLock);
  end;
end;

function TAndroidDebugBridge.Restart: boolean;
begin
  if FAdbOsLocation.IsEmpty then
  begin
    TDebug.WriteLine('E: "AndroidDebugBridge" Cannot restart adb when AndroidDebugBridge is created without the location of adb.');
    exit(false);
  end;

  if not FVersionCheck then
  begin
    TDebug.WriteLine('E: "AndroidDebugBridge" Attempting to restart adb, but version check failed!');
    exit(false);
  end;

  TMonitor.Enter(self);
  try
    StopAdb;
    var restated := StartAdb;
    if restated and (FDeviceMonitor = nil) then
    begin
      FDeviceMonitor := TDeviceMonitor.Create(self);
      TDeviceMonitor(FDeviceMonitor).Start;
    end;

    result := restated;
  finally
    TMonitor.Exit(self);
  end;

end;

function TAndroidDebugBridge.Start: boolean;
begin
  if (not FAdbOsLocation.IsEmpty) and ((not FVersionCheck) or (not StartAdb)) then
    exit(false);

  FStarted := true;

  FDeviceMonitor := TDeviceMonitor.Create(self);
  TDeviceMonitor(FDeviceMonitor).Start;

  result := true;
end;

function TAndroidDebugBridge.StartAdb: boolean;
begin
  TMonitor.Enter(self);
  try
    if FAdbOsLocation.IsEmpty then
    begin
      TDebug.WriteLine('E: "AndroidDebugBridge" Cannot start adb when AndroidDebugBridge is created without the location of adb.');
      exit(false);
    end;

    var CommandResult: AnsiString;
    if RunCommand(FAdbOsLocation, ['start-server'], CommandResult, [], swoHIDE) then
    begin
      result := true;
      TDebug.WriteLine('D: "AndroidDebugBridge" ''adb start-server'' succeeded');
    end
    else
    begin
      result := false;
      TDebug.WriteLine('E: "AndroidDebugBridge" ''adb start-server'' failed -- run manually if necessary');
    end;
  finally
    TMonitor.Exit(self);
  end;
end;

function TAndroidDebugBridge.Stop: boolean;
begin
  // if we haven't started we return false;
  if not FStarted then
    exit(false);

  // kill the monitoring services
  TDeviceMonitor(FDeviceMonitor).Stop;
  FDeviceMonitor := nil;

  if not StopAdb then
    exit(false);

  FStarted := false;
  result := true;
end;

function TAndroidDebugBridge.StopAdb: boolean;
begin
  if FAdbOsLocation.IsEmpty then
  begin
    TDebug.WriteLine('E: "AndroidDebugBridge" Cannot stop adb when AndroidDebugBridge is created without the location of adb.');
    exit(false);
  end;

  var CommandResult: AnsiString;
  if RunCommand(FAdbOsLocation, ['kill-server'], CommandResult, [], swoHIDE) then
  begin
    result := true;
    TDebug.WriteLine('D: "AndroidDebugBridge" ''adb kill-server'' succeeded');
  end
  else
  begin
    result := false;
    TDebug.WriteLine('E: "AndroidDebugBridge" ''adb kill-server'' failed -- run manually if necessary');
  end;
end;

class procedure TAndroidDebugBridge.Terminate;
begin
  TMonitor.Enter(FClassLock);
  try
    // kill the monitoring services
    if (FSelf <> nil) then
    begin
      if FSelf.FDeviceMonitor <> nil then
        TDeviceMonitor(FSelf.FDeviceMonitor).Stop;

      FSelf.FDeviceMonitor := nil;
      FreeAndNil(FSelf);
    end;

    FInitialized := false;
  finally
    TMonitor.Exit(FClassLock);
  end;
end;

{ TDeviceUnixSocketNamespaceHelper }

function TDeviceUnixSocketNamespaceHelper.GetType: string;
begin
  case self of
    TDeviceUnixSocketNamespace.ABSTRACT:    result := 'localabstract';
    TDeviceUnixSocketNamespace.FILESYSTEM:  result := 'localfilesystem';
    TDeviceUnixSocketNamespace.RESERVED:    result := 'localreserved';
  end;
end;

end.
