unit DM.Logcat;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, Vcl.ImgList, Vcl.Controls,
  SVGIconImageListBase, SVGIconImageList, VCL.Forms, System.Actions, Vcl.ActnList

  {$IFDEF BPL}
  , ToolsAPI
  {$ENDIF}
  , adb.AndroidDebugBridge
  ;

type
  {$IFDEF BPL}
  TDMLogcat = class(TDataModule, INTAIDEThemingServicesNotifier)
  {$ELSE}
  TDMLogcat = class(TDataModule)
  {$ENDIF}
    SVGIconImageList: TSVGIconImageList;
    ActionList: TActionList;
    ActionAndroidMonitor: TAction;
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure ActionAndroidMonitorExecute(Sender: TObject);
  private
    FBridge: TAndroidDebugBridge;
  {$IFDEF BPL}
    { Private declarations }
    procedure InjectMenu;
    procedure RegisterFormIDE;

    procedure FormLogcatDestroy(Sender: TObject);

    //INTAIDEThemingServicesNotifier
    procedure ChangingTheme();
    procedure ChangedTheme();
  protected
    // IOTANotifier
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
  {$ENDIF}
  public
    { Public declarations }
  end;

{$IFDEF BPL}
procedure Register;
{$ENDIF}

{$IFNDEF BPL}
var
  DMLogcat: TDMLogcat;
{$ENDIF}

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
    System.Win.Registry
  , Winapi.Windows
  {$IFDEF BPL}
  , VCL.Dialogs
  , VCL.Menus
  , Form.Logcat
  , Form.Logcat.TakeScreenshot
  {$ENDIF}
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

{$IFDEF BPL}
var
  DMLogcat: TDMLogcat;

procedure Register;
begin
  DMLogcat := TDMLogcat.Create(Application);
end;

procedure FindMenuItem(AMenuBreadcrumbs: TArray<string>);

  procedure IterateMenuItems(MenuItems: TMenuItem);
  var
    I, J: Integer;
    ArrayLength: Cardinal;
    Caption: String;
  begin
    for I := 0 To MenuItems.Count - 1 do
    begin
      Caption := StringReplace(MenuItems[I].Caption, '&', '', []);
      if Uppercase(AMenuBreadcrumbs[0]) = Uppercase(Caption) then
      begin
        ArrayLength := Length(AMenuBreadcrumbs);
        if ArrayLength = 1 then
          ShowMessage(MenuItems[I].Name)
        else
        begin
          for J := 1 to ArrayLength - 1 do
            AMenuBreadcrumbs[J - 1] := AMenuBreadcrumbs[J];
          SetLength(AMenuBreadcrumbs, ArrayLength - 1);
          IterateMenuItems(MenuItems.Items[I]);
        end;
        break;
      end;
    end;
  end;

var
  NTAServices: INTAServices;
begin
  if Supports(BorlandIDEServices, INTAServices, NTAServices) then
    IterateMenuItems(NTAServices.MainMenu.Items);
end;

{$ENDIF}

procedure TDMLogcat.ActionAndroidMonitorExecute(Sender: TObject);
begin
  {$IFDEF BPL}
//  if not assigned(FormLogcat) then
//  begin
    var FormLogcat := TFormLogcat.Create(Application);
    FormLogcat.OnDestroy := FormLogcatDestroy;
//  end;

  ChangedTheme;
  FormLogcat.Show;
  {$ENDIF}
end;

{$IFDEF BPL}
procedure TDMLogcat.AfterSave;
begin
  // do nothing stub implementation
end;

procedure TDMLogcat.BeforeSave;
begin
  // do nothing stub implementation
end;

procedure TDMLogcat.ChangedTheme;
begin
//  var ThemingServices : IOTAIDEThemingServices;
//  if Supports(BorlandIDEServices, IOTAIDEThemingServices, ThemingServices) then
//  begin
//    if assigned(FormLogcat) then
//    begin
//      ThemingServices.ApplyTheme(FormLogcat);
//    end;
//
//  end;
end;

procedure TDMLogcat.ChangingTheme;
begin
  // do nothing stub implementation
end;

{$ENDIF}

procedure TDMLogcat.DataModuleCreate(Sender: TObject);
begin
  TAndroidDebugBridge.InitIfNeeded(true);

  var adbOsLocale: string;
  if TryGetAdbLocation(adbOsLocale) then
    TAndroidDebugBridge.CreateBridge(adbOsLocale, false);

  {$IFDEF BPL}
  InjectMenu;
  RegisterFormIDE;
  {$ENDIF}
end;

procedure TDMLogcat.DataModuleDestroy(Sender: TObject);
begin
  TAndroidDebugBridge.Terminate;

  {$IFDEF BPL}
//  FreeAndNil(FormLogcat);
  {$ENDIF}
end;

{$IFDEF BPL}
procedure TDMLogcat.Destroyed;
begin
   // do nothing stub implementation
end;

procedure TDMLogcat.FormLogcatDestroy(Sender: TObject);
begin
//  FormLogcat := nil;
end;

procedure TDMLogcat.InjectMenu;
begin
  var NTAServices: INTAServices;
  if Supports(BorlandIDEServices, INTAServices, NTAServices) then
  begin
    var AndroidMonitorMenuItem := TMenuItem.Create(nil);
    AndroidMonitorMenuItem.Name := 'AndroidMonitorMenuItem';
    AndroidMonitorMenuItem.Caption := 'Android Monitor';
    AndroidMonitorMenuItem.ImageIndex := 16;
    AndroidMonitorMenuItem.Action := ActionAndroidMonitor;
    NTAServices.AddActionMenu('ViewToolWindowsItem', nil, AndroidMonitorMenuItem, False, True);
  end;
end;

procedure TDMLogcat.Modified;
begin
  // do nothing stub implementation
end;

procedure TDMLogcat.RegisterFormIDE;
begin
  var ThemingServices : IOTAIDEThemingServices;
  if Supports(BorlandIDEServices, IOTAIDEThemingServices, ThemingServices) then
  begin
    ThemingServices.RegisterFormClass(TFormLogcat);
    ThemingServices.RegisterFormClass(TFormTakeScreenshot);
//    ThemingServices.AddNotifier(Self);
  end;
end;

{$ENDIF}

end.
