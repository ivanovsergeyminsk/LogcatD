unit adb.Device.Client;

interface

uses
    System.Net.Socket
//  , System.Net.Selector
  , System.Rtti
  , adb.AndroidDebugBridge
  ;

type
  TClient = class(TInterfacedObject, IClient)
  private const
    ST_INIT         = 1;
    ST_NOT_JDWP     = 2;
    ST_AWAIT_SHAKE  = 10;
    ST_NEED_DDM_PKT = 11;
    ST_NOT_DDM      = 12;
    ST_READY        = 13;
    ST_ERROR        = 20;
    ST_DISCONNECTED = 21;
  private
    FChannel: TSocket;
    FDevice: IDevice;
    FClientData: IClientData;
    FDebuggerListenPort: integer;
    FConnState: integer;

    FThreadUpdateEnabled: boolean;
    FHeapUpdateEnabled: boolean;
  public
    constructor Create(Device: IDevice; Channel: TSocket; Pid: integer);
    destructor Destroy; override;

    //IClient
    function GetDevice: IDevice;
    function GetClientData: IClientData;

    ///<summary>
    /// Registers the client with a Selector.
    ///<summary>
//    procedure &Register(Selector: TSelector);

    ///<summary>
    /// Initiate the JDWP handshake.
    /// On failure, closes the socket and returns false.
    ///</summary>
    function SendHandshake: boolean;

    ///<summary>
    /// Tell the client to open a server socket channel and listen for
    /// connections on the specified port.
    ///</summary>
    procedure ListenForDebugger(ListenPort: integer);

//    procedure Update(Change: TClientChanges);

    ///<summary>
    /// Close the client socket channel.  If there is a debugger associated
    ///with us, close that too.
    /// Closing a channel automatically unregisters it from the selector.
    /// However, we have to iterate through the selector loop before it
    /// actually lets them go and allows the file descriptors to close.
    /// The caller is expected to manage that.
    /// @param notify Whether or not to notify the listeners of a change.
    ///</summary>
    procedure Close(Notify: boolean);
  end;

implementation

uses
    System.SysUtils
  , adb.ClientData
  , adb.Preferences
  , adb.Device
  ;

{ TClient }

procedure TClient.Close(Notify: boolean);
begin
  {$MESSAGE WARN 'TODO: TClient.Close'}
end;

constructor TClient.Create(Device: IDevice; Channel: TSocket; Pid: integer);
begin
  {$MESSAGE WARN 'TODO: TClient.Create'}
  FDevice   := Device;
  FChannel  := Channel;

//  mReadBuffer = ByteBuffer.allocate(INITIAL_BUF_SIZE);
//  mWriteBuffer = ByteBuffer.allocate(WRITE_BUF_SIZE);
//  mOutstandingReqs = new HashMap<Integer,ChunkHandler>();

  FConnState  := ST_INIT;
  FClientData := TClientData.Create(Pid);
  FThreadUpdateEnabled := TAdbPreferences.GetInitialThreadUpdate;
  FHeapUpdateEnabled   := TAdbPreferences.GetInitialHeapUpdate;
end;

destructor TClient.Destroy;
begin
  FClientData := nil;
  FDevice     := nil;
  inherited;
end;

function TClient.GetClientData: IClientData;
begin
  result := FClientData;
end;


function TClient.GetDevice: IDevice;
begin
  result := FDevice;
end;




//procedure TClient.ListenForDebugger(ListenPort: integer);
//begin
//  FDebuggerListenPort := ListenPort;
//  {$MESSAGE WARN 'TODO: TClient.ListenForDebugger'}
//end;

//procedure TClient.Register(Selector: TSelector);
//begin
//  if FChannel <> nil then
//    Selector.Add(FChannel, [OP_READ], TValue.From<IClient>(self));
//end;


function TClient.SendHandshake: boolean;
begin
  {$MESSAGE WARN 'TODO: TClient.SendHandshake'}
end;



//procedure TClient.Update(Change: TClientChanges);
//begin
//  TDevice(FDevice).Update(self, Change);
//end;

end.
