unit Frame.Logcat;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, DM.Logcat, Vcl.Menus, VirtualTrees, SVGIconImageList,
  SVGIconImage, Vcl.Buttons, System.Actions, Vcl.ActnList, Vcl.Clipbrd, Vcl.ExtDlgs

  , System.Generics.Collections
  , System.Threading
  , System.SyncObjs
  , System.DateUtils
  , System.Types
  , System.Math
  , System.StrUtils
  , System.IOUtils
  , adb.AndroidDebugBridge
  , adb.Logcat
  , Common.Debug
  , Form.Logcat.TakeScreenshot
  ;

type
  TFrameLogcat = class(TFrame, IDeviceChangeListener, ILogcatListener)
    PanelTop: TPanel;
    PanelLeft: TPanel;
    ButtonedEditFIlter: TButtonedEdit;
    PopupMenuHistory: TPopupMenu;
    SplitterTop: TSplitter;
    PopupMenuDevices: TPopupMenu;
    PanelDevice: TPanel;
    VirtualStringLogcat: TVirtualStringTree;
    SpeedButtonStartStop: TSpeedButton;
    SpeedButtonClearLogs: TSpeedButton;
    ComboBoxLevel: TComboBox;
    ActionListLogcat: TActionList;
    ActionStartStop: TAction;
    SVGIconImageOnline: TSVGIconImage;
    SpeedButtonFilter: TSpeedButton;
    ActionClearLogs: TAction;
    ActionClearFilters: TAction;
    SpeedButtonAutoScroll: TSpeedButton;
    ActionAutoScroll: TAction;
    SpeedButtonSoftWrap: TSpeedButton;
    PopupMenuTree: TPopupMenu;
    Copy1: TMenuItem;
    ActionCopyLogMessages: TAction;
    Savetofile1: TMenuItem;
    ActionSaveToFile: TAction;
    SaveTextLog: TSaveTextFileDialog;
    SpeedButtonTakeScreenshot: TSpeedButton;
    SpeedButtonRecordScreen: TSpeedButton;
    ActionTakeScreenshot: TAction;
    ActionSoftWrap: TAction;
    ComboBoxDevices: TComboBox;
    procedure ImageDeviceClick(Sender: TObject);
    procedure VirtualStringLogcatGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    procedure VirtualStringLogcatDrawText(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      const Text: string; const CellRect: TRect; var DefaultDraw: Boolean);
    procedure ButtonedEditFilterChange(Sender: TObject);
    procedure ActionStartStopUpdate(Sender: TObject);
    procedure ActionStartStopExecute(Sender: TObject);
    procedure ActionListLogcatUpdate(Action: TBasicAction;
      var Handled: Boolean);
    procedure ActionClearLogsExecute(Sender: TObject);
    procedure ActionClearFiltersUpdate(Sender: TObject);
    procedure ActionClearFiltersExecute(Sender: TObject);
    procedure ActionAutoScrollExecute(Sender: TObject);
    procedure ActionCopyLogMessagesExecute(Sender: TObject);
    procedure ActionSaveToFileExecute(Sender: TObject);
    procedure ActionTakeScreenshotExecute(Sender: TObject);
    procedure ActionTakeScreenshotUpdate(Sender: TObject);
    procedure ActionSoftWrapExecute(Sender: TObject);
    procedure ComboBoxDevicesDropDown(Sender: TObject);
    procedure ComboBoxDevicesSelect(Sender: TObject);
    procedure ComboBoxDevicesCloseUp(Sender: TObject);
  private const
    COLUMN_TIME = 0;
    COLUMN_PID  = 1;
    COLUMN_TID  = 2;
    COLUMN_APP  = 3;
    COLUMN_TAG  = 4;
    COLUMN_LVL  = 5;
    COLUMN_TXT  = 6;

    CS_SOFTWRAP = 140;

    DEFAULT_FILTER = '-tag=:adb_services -package=:netd';
  private
    FBridge: TAndroidDebugBridge;

    FMapDeviceMenuItem: TDictionary<IDevice, TMenuItem>;
    FMapMenuItemDevice: TDictionary<TMenuItem, IDevice>;

    FDevices: TList<IDevice>;

    FSelectedDevice: IDevice;
    FLogcat: ILogcatReceiverTask;
    FTaskLogcat: ITask;

    FIsStartedLog: boolean;
    FStartLogTime: TDateTime;
    FMRW: TLightweightMREW;
    FLogList: TList<TLogcatMessage>;
    FFilters: TList<TLogcatFilter>;

    FIsAutoScroll: boolean;
    FIsSoftWarp: boolean;

    function IsFilterMatches(const [ref] Msg: TLogcatMessage): boolean;
    function TryGetLogMessage(Idx: int64; out Msg: TLogcatMessage): boolean;

    procedure RefreshVirtualTreeByFilters;
    procedure RecalcVirtualTreeScroll;
    procedure DoSoftWrapNode(Node: PVirtualNode);

    function GetDisplayTextDevice(Device: IDevice): string;
    procedure DoMenuItemDeviceClick(Sender: TObject);

    function GetDefaultFilter: TList<TLogcatFilter>;
  private
    //IDeviceChangeListener
    procedure DeviceConnected(Device: IDevice);
    procedure DeviceDisconnected(Device: IDevice);
    procedure DeviceChanged(Device: IDevice; Change: TDeviceChanges);

    procedure DeviceChangedState(Device: IDevice);

    //ILogcatListener
    procedure Log(const [ref] MsgList: TArray<TLogcatMessage>);
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure LogStop;
  end;

implementation

{$R *.dfm}

uses
    System.Win.Registry
  ;

function TryGetAdbLocation(out adbOsLocale: string): boolean;
  const BDSKey = 'Software\Embarcadero\BDS\';
  const PlatformSDKKey = '\PlatformSDKs\';
begin
  adbOsLocale := string.Empty;
  var Registry := TRegistry.Create(KEY_READ);
  try
    Registry.RootKey := HKEY_CURRENT_USER;

    // False because we do not want to create it if it doesn't exist
    if not Registry.OpenKey(BDSKey, False) then
      exit(false);

    var VerN := TStringList.Create;
    try
      Registry.GetKeyNames(VerN);
      for var KeyVer in VerN do
      begin
        if not Registry.OpenKey(KeyVer+PlatformSDKKey, false) then
          continue;

        var PlatformN := TStringList.Create;
        try
          Registry.GetKeyNames(PlatformN);
          for var PlatfVer in PlatformN do
          begin
            if not Registry.OpenKey(PlatfVer, false) then
              continue;

            if Registry.ValueExists('SDKAdbPath') then
            begin
              adbOsLocale := Registry.ReadString('SDKAdbPath');
              if not adbOsLocale.Trim.IsEmpty then
                exit(true);
            end;
          end;
        finally
          PlatformN.Free;
        end;
    end;
   finally
    VerN.Free;
   end;

    result := not adbOsLocale.Trim.IsEmpty;
  finally
   Registry.Free;
  end;
end;


{ TFrameLogcat }

procedure TFrameLogcat.ActionAutoScrollExecute(Sender: TObject);
begin
  FIsAutoScroll := not FIsAutoScroll;
end;

procedure TFrameLogcat.ActionClearFiltersExecute(Sender: TObject);
begin
  ButtonedEditFilter.Clear;
  ComboBoxLevel.ItemIndex := 0;
  FMRW.BeginWrite;
  try
    FreeAndNil(FFilters);
  finally
    FMRW.EndWrite;
  end;

  RefreshVirtualTreeByFilters;
end;

procedure TFrameLogcat.ActionClearFiltersUpdate(Sender: TObject);
begin
  ActionClearFilters.Enabled := assigned(FFilters);
end;

procedure TFrameLogcat.ActionClearLogsExecute(Sender: TObject);
begin
  FMRW.BeginWrite;
  try
    FLogList.Clear;
    VirtualStringLogcat.Clear;
  finally
    FMRW.EndWrite;
  end;
end;

procedure TFrameLogcat.ActionCopyLogMessagesExecute(Sender: TObject);
begin
  var Msgs: TArray<string>;
  for var Node in VirtualStringLogcat.SelectedNodes do
  begin
    var Msg: TLogcatMessage;
    if not TryGetLogMessage(Node.Index, msg) then
      continue;

    Msgs := Msgs+[Msg.ToString];
  end;

  Clipboard.AsText := string.Join(sLineBreak, Msgs);
end;

procedure TFrameLogcat.ActionListLogcatUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  If assigned(FSelectedDevice) then
  begin
    if FSelectedDevice.GetState = TDeviceState.OFFLINE then
    begin
      SVGIconImageOnline.ImageIndex := 4;
    end
    else
    begin
      if FSelectedDevice.IsOnline then
        SVGIconImageOnline.ImageIndex := 3
      else
        SVGIconImageOnline.ImageIndex := 4;
    end;
  end
  else
  begin
    if PopupMenuDevices.Items.Count = 0 then
      SVGIconImageOnline.ImageIndex := 2
    else
      SVGIconImageOnline.ImageIndex := 2;
  end;

  if assigned(FFilters) then
  begin
    if FFilters.Count > 0 then
      SpeedButtonFilter.ImageIndex := 6
    else
      SpeedButtonFilter.ImageIndex := 5;
  end
  else
  begin
    SpeedButtonFilter.ImageIndex := 5;
  end;

  if FIsAutoScroll then
  begin
    if ActionAutoScroll.ImageIndex <> 11 then
    begin
      ActionAutoScroll.ImageIndex := 11;
      SpeedButtonAutoScroll.ImageIndex := 11;
      SpeedButtonAutoScroll.Invalidate;
    end;
  end
  else
  begin
    if ActionAutoScroll.ImageIndex <> 10 then
    begin
      ActionAutoScroll.ImageIndex := 10;
      SpeedButtonAutoScroll.ImageIndex := 10;
      SpeedButtonAutoScroll.Invalidate;
    end;
  end;
end;

procedure TFrameLogcat.ActionSaveToFileExecute(Sender: TObject);
begin
  var Logs: TArray<TLogcatMessage>;
  FMRW.BeginRead;
  try
    Logs := FLogList.ToArray;
  finally
    FMRW.EndRead;
  end;

  var LFilters := FFilters.ToArray;

  var LogText: TArray<string>;
  for var Msg in Logs do
  begin
    if not TLogcatFilter.Matches(LFilters, Msg) then
      continue;

    LogText := LogText + [Msg.ToString];
  end;

  if not SaveTextLog.Execute then
    exit;
  var FileName := SaveTextLog.FileName;

  TFile.WriteAllLines(FileName, LogText);
end;

procedure TFrameLogcat.ActionSoftWrapExecute(Sender: TObject);
begin
  FIsSoftWarp := not FIsSoftWarp;
  RefreshVirtualTreeByFilters;
end;

procedure TFrameLogcat.ActionStartStopExecute(Sender: TObject);
begin
  if not Assigned(FSelectedDevice) then
    exit;

  if FIsStartedLog then
  begin
    LogStop;
    exit;
  end;

  FIsStartedLog := true;

  FLogcat := TLogcatReceiverTask.Create(FSelectedDevice);
  FLogcat.AddLogcatListener(Self);
  FStartLogTime := Now;

  FTaskLogcat := TTask.Run(
    procedure
    begin
      try
        FLogcat.Run;
      except
        on E: Exception do
        begin
          LogStop;
        end;
      end;
    end);
end;

procedure TFrameLogcat.ActionStartStopUpdate(Sender: TObject);
begin
  if assigned(FTaskLogcat) and FIsStartedLog then
  begin
    ActionStartStop.ImageIndex := 9;
    SpeedButtonStartStop.ImageIndex := 9;
  end
  else
  begin
    ActionStartStop.ImageIndex := 8;
    SpeedButtonStartStop.ImageIndex := 8;
  end;

  if Assigned(FSelectedDevice) then
  begin
    ActionStartStop.Enabled := not (FSelectedDevice.GetState = TDeviceState.OFFLINE);
  end
  else
    ActionStartStop.Enabled := false
end;

procedure TFrameLogcat.ActionTakeScreenshotExecute(Sender: TObject);
begin
  if not Assigned(FSelectedDevice) then
    exit;

  if FSelectedDevice.IsOffline then
    exit;

  var Form := TFormTakeScreenshot.Create(Application, FSelectedDevice);
  Form.Show;
end;

procedure TFrameLogcat.ActionTakeScreenshotUpdate(Sender: TObject);
begin
  if Assigned(FSelectedDevice) then
  begin
    ActionTakeScreenshot.Enabled := not (FSelectedDevice.GetState = TDeviceState.OFFLINE);
  end
  else
    ActionTakeScreenshot.Enabled := false
end;

procedure TFrameLogcat.AfterConstruction;
begin
  inherited;
  FIsStartedLog := false;
  FIsAutoScroll := true;
  FIsSoftWarp   := true;

  FDevices := TList<IDevice>.Create;
  FMapDeviceMenuItem := TDictionary<IDevice, TMenuItem>.Create;
  FMapMenuItemDevice := TDictionary<TMenuItem, IDevice>.Create;
  FLogList := TList<TLogcatMessage>.Create;

  FFilters := GetDefaultFilter;

  TAndroidDebugBridge.InitIfNeeded(true);
  TAndroidDebugBridge.AddDeviceChangeListener(self);

  var adbOsLocale: string;
  if TryGetAdbLocation(adbOsLocale) then
    FBridge := TAndroidDebugBridge.CreateBridge(adbOsLocale, false)
  else
    FBridge := nil;
end;

procedure TFrameLogcat.BeforeDestruction;
begin
  if assigned(FLogcat) then
  begin
    LogStop;
    TTask.WaitForAll([FTaskLogcat]);
  end;

  if assigned(FBridge) then
    FBridge.Stop;

  TAndroidDebugBridge.RemoveDeviceChangeListener(self);
  TAndroidDebugBridge.Terminate;
  FLogList.Free;
  FMapDeviceMenuItem.Free;
  FMapMenuItemDevice.Free;
  FDevices.Free;
  FreeAndNil(FFilters);
  inherited;
end;

procedure TFrameLogcat.ButtonedEditFilterChange(Sender: TObject);
begin
  FreeAndNil(FFilters);
  var FilterText: string := DEFAULT_FILTER +' '+ ButtonedEditFilter.Text;
  var LogLevel: TLogLevel := TLogLevel(ifthen(ComboboxLevel.ItemIndex = 0, 0, ComboboxLevel.ItemIndex+1));

  FFilters := TLogcatFilter.FromString(FilterText, LogLevel);

  RefreshVirtualTreeByFilters;
end;

procedure TFrameLogcat.ComboBoxDevicesCloseUp(Sender: TObject);
begin
  if assigned(FSelectedDevice) and (ComboBoxDevices.ItemIndex = -1) then
  begin
    ComboBoxDevices.ItemIndex := ComboBoxDevices.Items.IndexOfObject(FSelectedDevice as TObject);
  end;
end;

procedure TFrameLogcat.ComboBoxDevicesDropDown(Sender: TObject);
begin
 with ComboBoxDevices do
  begin
    Items.BeginUpdate;
    Items.Clear;
    for var Device in FDevices do
      Items.AddObject(GetDisplayTextDevice(Device), Device as TObject);

    Items.EndUpdate;
  end;
end;

procedure TFrameLogcat.ComboBoxDevicesSelect(Sender: TObject);
begin
  var NewSelected := TInterfacedObject(ComboBoxDevices.Items.Objects[ComboBoxDevices.ItemIndex]) as IDevice;
  if NewSelected = nil then
    exit;

  if (FSelectedDevice <> nil) and (FSelectedDevice <> NewSelected) then
    LogStop;

  FSelectedDevice := NewSelected;
end;

procedure TFrameLogcat.DeviceChanged(Device: IDevice; Change: TDeviceChanges);
begin
  if TDeviceChange.ChangeState in Change then
    TThread.Queue(nil, procedure begin
      DeviceChangedState(Device);
    end);
end;

procedure TFrameLogcat.DeviceChangedState(Device: IDevice);
begin
  var Text := format('%s (%s, %s) [%s]', [Device.GetSerialNumber, 'Android 9', 'API 28', Device.GetState.ToString]);
  var ImageDevice: integer;
  if Device.IsOnline then
    ImageDevice := 3
  else
    ImageDevice := 4;

  var MenuItem: TMenuItem;
  if FMapDeviceMenuItem.TryGetValue(Device, MenuItem) then
  begin
    MenuItem.Caption    := Text;
    MenuItem.ImageIndex := ImageDevice;
  end;

  if FSelectedDevice = Device then
  begin
    ComboBoxDevices.Text := Text;
  end;
end;

procedure TFrameLogcat.DeviceConnected(Device: IDevice);
begin
  TThread.Queue(nil, procedure begin
    var Text := format('%s (%s, %s) [%s]', [Device.GetSerialNumber, 'Android 9', 'API 28', Device.GetState.ToString]);
    var ImageDevice: integer;
    if Device.IsOnline then
      ImageDevice := 3
    else
      ImageDevice := 4;

    FDevices.Add(Device);
  end);
end;

procedure TFrameLogcat.DeviceDisconnected(Device: IDevice);
begin
  TThread.Queue(nil, procedure begin
    var ImageDevice: integer;
    if Device.IsOnline then
      ImageDevice := 3
    else
      ImageDevice := 4;


    FDevices.Remove(Device);
    if FSelectedDevice = Device then
    begin
      LogStop;
      FSelectedDevice := nil;
    end;
  end);
end;

procedure TFrameLogcat.DoMenuItemDeviceClick(Sender: TObject);
begin
  var Device: IDevice;
  if FMapMenuItemDevice.TryGetValue(TMenuItem(Sender), Device) then
  begin
    FSelectedDevice := Device;

    var Text := format('%s (%s, %s) [%s]', [Device.GetSerialNumber, 'Android 9', 'API 28', Device.GetState.ToString]);
  end;
end;

procedure TFrameLogcat.DoSoftWrapNode(Node: PVirtualNode);
begin
  var Msg: TLogcatMessage;
  if not TryGetLogMessage(Node.Index, Msg) then
    exit;

  var LText := WrapText(Msg.Message, CS_SOFTWRAP);
  VirtualStringLogcat.Canvas.Font := VirtualStringLogcat.Font;

  var TextW: integer := 0;
  var Splitted := LText.Split([sLineBreak]);

  var TextH: integer := VirtualStringLogcat.Canvas.TextHeight(Splitted[0]);
  for var item in Splitted do
    TextW := Max(VirtualStringLogcat.Canvas.TextWidth(item), TextW);

  if FIsSoftWarp then
    TextH := TextH * Length(Splitted);

  VirtualStringLogcat.Header.Columns.Items[COLUMN_TXT].MaxWidth := max(VirtualStringLogcat.Header.Columns.Items[COLUMN_TXT].MaxWidth, TextW+1);
  VirtualStringLogcat.Header.Columns.Items[COLUMN_TXT].Width := max(VirtualStringLogcat.Header.Columns.Items[COLUMN_TXT].Width, TextW);
  Node.NodeHeight := TextH+VirtualStringLogcat.TextMargin;
end;

function TFrameLogcat.GetDefaultFilter: TList<TLogcatFilter>;
begin
  result := TLogcatFilter.FromString(DEFAULT_FILTER, TLogLevel.NONE)
end;

function TFrameLogcat.GetDisplayTextDevice(Device: IDevice): string;
  const RO_MODEL = 'ro.product.model';
        RO_BRAND = 'ro.product.brand';
        RO_BUILD = 'ro.build.version.release';
        RO_SDK   = 'ro.build.version.sdk';
begin
  if not assigned(Device) then
    exit(String.Empty);

  result := format('%s %s (%s) Android %s, API %s',
    [Device.GetProperty(RO_BRAND),
     Device.GetProperty(RO_MODEL),
     Device.GetSerialNumber,
     Device.GetProperty(RO_BUILD),
     Device.GetProperty(RO_SDK)
    ]);
end;

procedure TFrameLogcat.ImageDeviceClick(Sender: TObject);
begin
  var AbsoluteRect := PanelDevice.ClientToScreen(PanelDevice.ClientRect);
  PopupMenuDevices.Popup(AbsoluteRect.Left, AbsoluteRect.Bottom);
end;

function TFrameLogcat.IsFilterMatches(const [ref] Msg: TLogcatMessage): boolean;
begin
  if not assigned(FFilters) then
    exit(True);

  result := TLogcatFilter.Matches(FFilters.ToArray, Msg);
end;

procedure TFrameLogcat.Log(const [ref] MsgList: TArray<TLogcatMessage>);
begin
  for var Msg in MsgList do
  begin
    if not FIsStartedLog then
      break;

    FMRW.BeginWrite;
    try
      FLogList.Add(Msg);
    finally
      FMRW.EndWrite;
    end;
  end;

  TThread.Synchronize(nil,
  procedure
  begin
    VirtualStringLogcat.BeginUpdate;
    try
      var NeedCount := FLogList.Count - VirtualStringLogcat.RootNode.ChildCount;
      for var I := 0 to NeedCount-1 do
      begin
        var Node: PVirtualNode := VirtualStringLogcat.AddChild(nil);

        Exclude(Node.States, vsFiltered);

        var Msg: TLogcatMessage;
        if not TryGetLogMessage(Node.Index, Msg) then
          continue;

        if not IsFilterMatches(Msg) then
          Include(Node.States, vsFiltered);
      end;

      RecalcVirtualTreeScroll;
    finally
      VirtualStringLogcat.EndUpdate;
    end;

    if FIsAutoScroll then
      VirtualStringLogcat.ScrollIntoView(VirtualStringLogcat.GetLast, false, false);
  end);

  sleep(10);
end;

procedure TFrameLogcat.LogStop;
begin
  FIsStartedLog := false;
  if assigned(FLogcat) then
  begin
    FLogcat.RemoveLogcatListener(self);
    FLogcat.Stop;
  end;
end;

procedure TFrameLogcat.RecalcVirtualTreeScroll;
begin
  VirtualStringLogcat.BeginUpdate;
  try
    VirtualStringLogcat.RootNode.TotalHeight := VirtualStringLogcat.DefaultNodeHeight;
    var Node := VirtualStringLogcat.GetFirst();
    while assigned(Node) do
    begin
      DoSoftWrapNode(Node);
      if not (vsFiltered in Node.States) then
        inc(VirtualStringLogcat.RootNode.TotalHeight, Node.NodeHeight);

      Node := VirtualStringLogcat.GetNext(Node);
    end;

    VirtualStringLogcat.RootNode.TotalHeight := VirtualStringLogcat.RootNode.TotalHeight + VirtualStringLogcat.BottomSpace;
    VirtualStringLogcat.UpdateScrollBars(true);
  finally
    VirtualStringLogcat.EndUpdate;
  end;
end;

procedure TFrameLogcat.RefreshVirtualTreeByFilters;
begin
  VirtualStringLogcat.BeginUpdate;
  VirtualStringLogcat.RootNode.TotalHeight := VirtualStringLogcat.DefaultNodeHeight;
  var Node := VirtualStringLogcat.GetFirst();
  while assigned(Node) do
  begin
    var Msg: TLogcatMessage;
    if not TryGetLogMessage(Node.Index, Msg) then
      continue;

    DoSoftWrapNode(Node);

    Exclude(Node.States, vsFiltered);

    if not IsFilterMatches(Msg) then
      Include(Node.States, vsFiltered)
    else
      inc(VirtualStringLogcat.RootNode.TotalHeight, Node.NodeHeight);

    Node := VirtualStringLogcat.GetNext(Node);
  end;
  VirtualStringLogcat.RootNode.TotalHeight := VirtualStringLogcat.RootNode.TotalHeight + VirtualStringLogcat.BottomSpace;
  VirtualStringLogcat.UpdateScrollBars(true);

  if FIsAutoScroll then
    VirtualStringLogcat.ScrollIntoView(VirtualStringLogcat.GetLast, false, false)
  else
  begin
    Node := nil;
    for var N in VirtualStringLogcat.SelectedNodes do
      Node := N;

    if assigned(Node) then
      VirtualStringLogcat.ScrollIntoView(Node, false, false)
  end;
  VirtualStringLogcat.EndUpdate;
end;

function TFrameLogcat.TryGetLogMessage(Idx: int64; out Msg: TLogcatMessage): boolean;
begin
  FMRW.BeginRead;
  try
    if not InRange(Idx, 0, FLogList.Count - 1) then
      exit(False);

    if FLogList.Count = 0 then
      exit(False);

    Msg := FLogList[Idx];
    result := true;
  finally
    FMRW.EndRead;
  end;
end;

procedure TFrameLogcat.VirtualStringLogcatDrawText(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  const Text: string; const CellRect: TRect; var DefaultDraw: Boolean);
begin
  var Msg: TLogcatMessage;
  if not TryGetLogMessage(Node.Index, Msg) then
    exit;

  if not (vsSelected in Node.States) then
  begin
    case Msg.LogLevel of
      NONE:     TargetCanvas.Font.Color := clWhite;
      VERBOSE:  TargetCanvas.Font.Color := clInfoBk;
      DEBUG:    TargetCanvas.Font.Color := clWebSandyBrown;
      INFO:     TargetCanvas.Font.Color := clWebLightSeaGreen;
      WARN:     TargetCanvas.Font.Color := clWebOrange;
      ERROR:    TargetCanvas.Font.Color := clWebRed;
      ASSERT:   TargetCanvas.Font.Color := clWhite;
    end;
  end;

  if Column = COLUMN_TXT then
  begin
    var LRect := CellRect;
    var Txt   := ifthen(FIsSoftWarp, WrapText(Msg.Message, CS_SOFTWRAP), Msg.Message);
    TargetCanvas.TextRect(LRect, Txt, [tfLeft, tfTop, tfWordBreak]);
    DefaultDraw := false;
  end
  else
  begin
    var LRect := CellRect;
    var Txt   := Text;
    TargetCanvas.TextRect(LRect, Txt, [tfLeft, tfTop]);
    DefaultDraw := false;
  end;
end;

procedure TFrameLogcat.VirtualStringLogcatGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
begin
  var Msg: TLogcatMessage;
  if not TryGetLogMessage(Node.Index, Msg) then
    exit;

  case Column of
    COLUMN_TIME:  CellText := Msg.Time;
    COLUMN_PID:   CellText := Msg.Pid;
    COLUMN_TID:   CellText := Msg.Tid;
    COLUMN_APP:   CellText := Msg.AppName;
    COLUMN_TAG:   CellText := Msg.Tag;
    COLUMN_LVL:   CellText := Msg.LogLevel.GetPriorityLetter;
    COLUMN_TXT:   CellText := Msg.Message;
  end;

end;

end.
