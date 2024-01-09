unit adb.Device;

interface

uses
    System.SysUtils
  , System.DateUtils
  , System.IOUtils
  , System.SyncObjs
  , System.Types.Nullable
  , System.Net.Socket
  , System.Generics.Collections
  , System.RegularExpressions
  , System.Process
  , System.Threading
  , adb.AndroidDebugBridge
  , adb.AdbHelper
  , adb.Preferences
  , adb.RawImage
  , adb.DeviceMonitor
  , adb.Receiver.MultiLineReceiver
  , adb.Receiver.CollectingOutputReceiver
  , adb.Receiver.NullOutputReceiver
  , adb.Receiver.PSReceiver
  , Common.Debug
  ;

type
  TDevice = class(TInterfacedObject, IDevice)
  private const
    UNKNOWN_PACKAGE = string.Empty;
    RX_EMULATOR_SN = 'emulator-(\d+)';

    INSTALL_TIMEOUT = 2*60*1000; // 2 minutes
    BATTERY_TIMEOUT = 2*1000; // 2 seconds
    GETPROP_TIMEOUT = 2*1000; // 2 seconds
  private
    FMonitor: TDeviceMonitor;
    FSerialNumber: string;
    FAvdName: string;
    FState: TDeviceState;
    FProperties: TDictionary<string, string>;
    FProcessInfo: TDictionary<integer, string>;
    FMREWProcessInfo: TLightweightMREW;
    FReleaseEvent: TEvent;

    FArePropertiesSet: boolean;
    FLastBatteryLevel: Nullable<integer>;
    FLastBatteryCheckTime: int64;

    procedure ClearClientInfo;
    procedure AddClientInfo(Client: IClient);
    procedure UpdateClientInfo(Client: IClient; Change: TClientChanges);

  private
    FProcessMonitorLoop: ITask;
    procedure ProcessMonitorLoop;
  public
    procedure SetState(Value: TDeviceState);
    procedure Update(Change: TDeviceChanges); overload;
    procedure ExecuteShellCommand(Command: string; Receiver: IShellOutputReceiver; MaxTimeToOutputResponse: integer); overload;
    procedure AddProperty(ALabel, AValue: string);
    procedure SetClientInfo(Pid: integer; PkgName: string);
  public
    constructor Create(Monitor: TDeviceMonitor; SerialNumber: string; DeviceState: TDeviceState);
    destructor Destroy; override;

    //IDevice
    function GetSerialNumber: string;
    function GetAvdName: string;
    function GetState: TDeviceState;
    function GetProperties: TDictionary<string, string>;
    function GetPropertyCount: integer;
    function GetProperty(Name: string): string;
    function ArePropertiesSet: boolean;
    function GetPropertySync(Name: string): string;
    function GetPropertyCacheOrSync(Name: string): string;
    function IsOnline: boolean;
    function IsEmulator: boolean;
    function IsOffline: boolean;
    function IsBootLoader: boolean;
    function GetScreenshot: Nullable<TRawImage>;
    procedure ExecuteShellCommand(Command: string; Receiver: IShellOutputReceiver); overload;
    procedure RunEventLogService(Receiver: ILogReceiver);
    procedure RunLogService(Logname: string; Receiver: ILogReceiver);
    procedure CreateForward(LocalPort, RemotePort: integer); overload;
    procedure CreateForward(LocalPort: integer; RemoteSocketName: string; Namespace: TDeviceUnixSocketNamespace); overload;
    procedure RemoveForward(LocalPort, RemotePort: integer); overload;
    procedure RemoveForward(LocalPort: integer; RemoteSocketName: string; Namespace: TDeviceUnixSocketNamespace); overload;
    function GetClientName(Pid: integer): string;
    procedure Reboot(Into: string);
    function GetBatteryLevel: integer; overload;
    function GetBatteryLevel(FreshnessMs: int64): integer; overload;
  end;


implementation

type
  ///<summary>Output receiver for "dumpsys battery" command line.</summary>
  TBatteryReceiver = class(TMultiLineReceiver)
  private const
    RX_BATTERY_LEVEL = '\s*level: (\d+)';
    RX_SCALE = '\s*scale: (\d+)';
  private
    FBatteryLevel: Nullable<integer>;
    FBatteryScale: Nullable<integer>;
  public
    constructor Create;
    procedure ProcessNewLines(const [ref] Lines: TArray<string>); override;
    function IsCancelled: boolean; override;

    ///<summary>Get the parsed percent battery level.</summary>
    function GetBatteryLevel: Nullable<integer>;
  end;

  ///<summary>Output receiver for "pm install package.apk" command line.</summary>
  TInstallReceiver = class(TMultiLineReceiver)
  private const
    SUCCESS_OUTPUT = 'Success';
    RX_FAILURE_PATTERN = 'Failure\s+\[(.*)\]';
  private
    FErrorMessage: string;
  public
    procedure ProcessNewLines(const [ref] Lines: TArray<string>); override;
    function IsCancelled: boolean; override;

    function GetErrorMessage: string;
  end;

{$REGION 'TBatteryReceiver'}
constructor TBatteryReceiver.Create;
begin
  inherited;
  FBatteryLevel := nil;
  FBatteryScale := nil;
end;

function TBatteryReceiver.GetBatteryLevel: Nullable<integer>;
begin
  if FBatteryLevel.HasValue and FBatteryLevel.HasValue then
    result := (FBatteryLevel.Value * 100) div FBatteryScale.Value
  else
    result := nil;
end;

procedure TBatteryReceiver.ProcessNewLines(const [ref] Lines: TArray<string>);
begin
  for var Line in Lines do
  begin
    if TRegEx.IsMatch(RX_BATTERY_LEVEL, Line) then
      try
        FBatteryLevel := Integer.Parse(TRegEx.Match(RX_BATTERY_LEVEL, Line).Groups.Item[1].Value)
      except
        on E: Exception do
        begin
          {$MESSAGE WARN 'TODO: log exception'}
        end;
      end;

    if TRegEx.IsMatch(RX_SCALE, Line) then
      try
        FBatteryScale := INteger.Parse(TRegEx.Match(RX_SCALE, Line).Groups.Item[1].Value)
      except
        on E: Exception do
        begin
          {$MESSAGE WARN 'TODO: log exception'}
        end;
      end;

  end;
end;

function TBatteryReceiver.IsCancelled: Boolean;
begin
  result := false;
end;

{$ENDREGION}

{$REGION 'TInstallReceiver'}

function TInstallReceiver.IsCancelled: boolean;
begin
  result := false;
end;

procedure TInstallReceiver.ProcessNewLines(const [ref] Lines: TArray<string>);
begin
  for var Line in Lines do
  begin
    if not Line.IsEmpty then
    begin
      if Line.StartsWith(SUCCESS_OUTPUT) then
        FErrorMessage := string.Empty
      else
      begin
        if TRegEx.IsMatch(RX_FAILURE_PATTERN, Line) then
          FErrorMessage := TRegEx.Match(RX_FAILURE_PATTERN, Line).Groups.Item[1].Value;
      end;
    end;
  end;
end;

function TInstallReceiver.GetErrorMessage: string;
begin
  result := FErrorMessage;
end;

{$ENDREGION}

{ TDevice }

procedure TDevice.AddClientInfo(Client: IClient);
begin
  var cd := Client.GetClientData;
  SetClientInfo(cd.GetPid, cd.GetClientDescription);
end;

procedure TDevice.AddProperty(ALabel, AValue: string);
begin
  FProperties.AddOrSetValue(ALabel, AValue);
end;

function TDevice.ArePropertiesSet: boolean;
begin
  result := FArePropertiesSet;
end;

procedure TDevice.ClearClientInfo;
begin
  FMREWProcessInfo.BeginWrite;
  try
    FProcessInfo.Clear;
  finally
    FMREWProcessInfo.EndWrite;
  end;
end;

constructor TDevice.Create(Monitor: TDeviceMonitor; SerialNumber: string;
  DeviceState: TDeviceState);
begin
  FMonitor      := Monitor;
  FSerialNumber := SerialNumber;
  FState        := DeviceState;

  FProperties   := TDictionary<string, string>.Create;
  FProcessInfo   := TDictionary<integer, string>.Create;

  FArePropertiesSet     := false;
  FLastBatteryLevel     := nil;
  FLastBatteryCheckTime := 0;

  FReleaseEvent := TEvent.Create;
  FReleaseEvent.ResetEvent;

  FProcessMonitorLoop := TTask.Run(ProcessMonitorLoop);
end;

procedure TDevice.CreateForward(LocalPort: integer; RemoteSocketName: string; Namespace: TDeviceUnixSocketNamespace);
begin
  TAdbHelper.CreateForward(TAndroidDebugBridge.GetSocketAddress, self, format('tcp:%d', [LocalPort]), format('%s:%s', [Namespace.GetType, RemoteSocketName]));
end;

procedure TDevice.CreateForward(LocalPort, RemotePort: integer);
begin
  TAdbHelper.CreateForward(TAndroidDebugBridge.GetSocketAddress, self, format('tcp:%d', [LocalPort]), format('tcp:%d', [RemotePort]));
end;

destructor TDevice.Destroy;
begin
  FReleaseEvent.SetEvent;

  if assigned(FProcessMonitorLoop) then
    TTask.WaitForAll([FProcessMonitorLoop]);

  FProcessMonitorLoop := nil;
  FReleaseEvent.Free;
  FProperties.Free;
  FProcessInfo.Free;
  FMonitor := nil;
  inherited;
end;

procedure TDevice.ExecuteShellCommand(Command: string; Receiver: IShellOutputReceiver; MaxTimeToOutputResponse: integer);
begin
  TAdbHelper.ExecuteRemoteCommand(TAndroidDebugBridge.GetSocketAddress, Command, self, Receiver, maxTimeToOutputResponse);
end;

procedure TDevice.ExecuteShellCommand(Command: string; Receiver: IShellOutputReceiver);
begin
  TAdbHelper.ExecuteRemoteCommand(TAndroidDebugBridge.GetSocketAddress, Command, self, Receiver, TAdbPreferences.GetTimeout);
end;

function TDevice.GetAvdName: string;
begin
  result := FAvdName;
end;

function TDevice.GetBatteryLevel(FreshnessMs: int64): integer;
begin
  if FLastBatteryLevel.HasValue and
    (FLastBatteryCheckTime > Now.ToUnix -  FreshnessMs)
  then
    exit(FLastBatteryLevel.Value);

  var Receiver := TBatteryReceiver.Create;
  ExecuteShellCommand('dumpsys battery', Receiver, BATTERY_TIMEOUT);
  FLastBatteryLevel := Receiver.GetBatteryLevel;
  FLastBatteryCheckTime := Now.ToUnix;
  result := FLastBatteryLevel.Value;
end;

function TDevice.GetClientName(Pid: integer): string;
begin
//  var RecentData: string := UNKNOWN_PACKAGE;
//  ExecuteShellCommand(format(TPSReceiver.PS_COMMAND_PID, [Pid]), TPSReceiver.Create(self,
//    procedure(const [ref] AData: TPair<integer, string>)
//    begin
//      RecentData := AData.Value;
////      TDebug.WriteLine('"W: ProcessMonitorLoop" '+AData.Key.ToString+':'+Adata.Value);
//    end
//  ));

//  result := RecentData;

  FMREWProcessInfo.BeginRead;
  try
    if not FProcessInfo.TryGetValue(pid, result) then
      result := UNKNOWN_PACKAGE;
  finally
    FMREWProcessInfo.EndRead;
  end;
end;


function TDevice.GetBatteryLevel: integer;
begin
  // use default of 5 minutes
  result := GetBatteryLevel(5 * 60 * 1000);
end;

function TDevice.GetProperties: TDictionary<string, string>;
begin
  result := TDictionary<string, string>.Create(FProperties.ToArray);
end;

function TDevice.GetProperty(Name: string): string;
begin
  if not FProperties.TryGetValue(Name, Result) then
    result := string.Empty;
end;

function TDevice.GetPropertyCacheOrSync(Name: string): string;
begin
  if FArePropertiesSet then
    result := GetProperty(Name)
  else
    result := GetPropertySync(Name);
end;

function TDevice.GetPropertyCount: integer;
begin
  result := FProperties.Count;
end;

function TDevice.GetPropertySync(Name: string): string;
begin
  var Latch := TCountdownEvent.Create(1);
  try
    var receiver := TCollectingOutputReceiver.Create(Latch);
    ExecuteShellCommand(format('getprop %s', [Name.QuotedString]), receiver, GETPROP_TIMEOUT);
    try
      Latch.WaitFor(GETPROP_TIMEOUT);
    except
      on E: Exception do
        exit(string.Empty);
    end;

    result := receiver.GetOutput.Trim;
  finally
    Latch.Free;
  end;
end;

//function TDevice.GetScreenshot: Nullable<TRawImage>;
//begin
//  result := TAdbHelper.GetFrameBuffer(TAndroidDebugBridge.GetSocketAddress, self);
//end;

function TDevice.GetScreenshot: Nullable<TRawImage>;
begin
  result := TAdbHelper.GetFrameBuffer(TAndroidDebugBridge.GetSocketAddress, self);
end;

function TDevice.GetSerialNumber: string;
begin
  result := FSerialNumber;
end;

function TDevice.GetState: TDeviceState;
begin
  result := FState;
end;

function TDevice.IsBootLoader: boolean;
begin
  result := FState = TDeviceState.BOOTLOADER;
end;

function TDevice.IsEmulator: boolean;
begin
  result := TRegEx.IsMatch(FSerialNumber, RX_EMULATOR_SN);
end;

function TDevice.IsOffline: boolean;
begin
  result := FState = TDeviceState.OFFLINE;
end;

function TDevice.IsOnline: boolean;
begin
  result := FState = TDeviceState.ONLINE;
end;

procedure TDevice.ProcessMonitorLoop;
begin
  while FReleaseEvent.WaitFor(1000) <> wrSignaled do
  begin
    if GetState <> TDeviceState.ONLINE then
      break;

    var RecentData := TDictionary<integer, string>.Create;
    try
      ExecuteShellCommand(TPSReceiver.PS_COMMAND, TPSReceiver.Create(self,
        procedure(const [ref] AData: TPair<integer, string>)
        begin
          RecentData.AddOrSetValue(AData.Key, AData.Value);
        end
      ));

      FMREWProcessInfo.BeginWrite;
      try
        var OldData := FProcessInfo.ToArray;
        for var Data in OldData do
          if not RecentData.ContainsKey(Data.Key) then
            FProcessInfo.Remove(Data.Key);

        for var Data in RecentData do
          FProcessInfo.AddOrSetValue(Data.Key, Data.Value);

      finally
        FMREWProcessInfo.EndWrite;
      end;

    finally
      RecentData.Free;
    end;
  end;
end;

procedure TDevice.Reboot(Into: string);
begin
  TAdbHelper.Reboot(Into, TAndroidDebugBridge.GetSocketAddress, self);
end;

procedure TDevice.RemoveForward(LocalPort: integer; RemoteSocketName: string;
  Namespace: TDeviceUnixSocketNamespace);
begin
  TAdbHelper.RemoveForward(TAndroidDebugBridge.GetSocketAddress, self, format('tcp:%d', [LocalPort]), format('%s:%s', [Namespace.GetType, RemoteSocketName]));
end;

procedure TDevice.RemoveForward(LocalPort, RemotePort: integer);
begin
  TAdbHelper.RemoveForward(TAndroidDebugBridge.GetSocketAddress, self, format('tcp:%d', [LocalPort]), format('tcp:%d', [RemotePort]));
end;

procedure TDevice.RunEventLogService(Receiver: ILogReceiver);
begin
  TAdbHelper.RunEventLogService(TAndroidDebugBridge.GetSocketAddress, self, Receiver);
end;

procedure TDevice.RunLogService(Logname: string; Receiver: ILogReceiver);
begin
  TAdbHelper.RunLogService(TAndroidDebugBridge.GetSocketAddress, self, Logname, Receiver);
end;

procedure TDevice.SetClientInfo(Pid: integer; PkgName: string);
begin
  if PkgName.Trim.IsEmpty then
    PkgName := UNKNOWN_PACKAGE;

  FMREWProcessInfo.BeginWrite;
  try
    FProcessInfo.AddOrSetValue(Pid, PkgName);
  finally
    FMREWProcessInfo.EndWrite;
  end;
end;

procedure TDevice.SetState(Value: TDeviceState);
begin
  FState := Value;
end;

procedure TDevice.Update(Change: TDeviceChanges);
begin
  if TDeviceChange.ChangeBuildInfo in Change then
    FArePropertiesSet := true;

  FMonitor.GetServer.DeviceChanged(self, Change);
end;

procedure TDevice.UpdateClientInfo(Client: IClient; Change: TClientChanges);
begin
  if TClientChange.ChangeName in Change then
    AddClientInfo(Client);
end;

end.
