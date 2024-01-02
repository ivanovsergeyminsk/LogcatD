unit Form.Logcat.TakeScreenshot;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Clipbrd, Vcl.ExtDlgs,
  System.Actions, Vcl.ActnList

  {$IFDEF BPL}
  , DockForm
  {$ENDIF}
  , adb.AndroidDebugBridge
  , adb.RawImage
  , System.Types.Nullable
  , System.IOUtils
  ;

type
  {$IFDEF BPL}
  TFormTakeScreenshot = class(TDockableForm)
  {$ELSE}
  TFormTakeScreenshot = class(TForm)
  {$ENDIF}
    PanelTop: TPanel;
    ButtonRecapture: TButton;
    ButtonRotateLeft: TButton;
    ButtonRotateRight: TButton;
    ButtonCopyToClipboard: TButton;
    PanelBottom: TPanel;
    ButtonCancel: TButton;
    ButtonSave: TButton;
    ScrollBox1: TScrollBox;
    ImageScreenshot: TImage;
    SaveScreenshotFile: TSavePictureDialog;
    ActionListScreenshot: TActionList;
    ActionRecapture: TAction;
    ActionRotateLeft: TAction;
    ActionRotateRight: TAction;
    ActionCopyToClipboard: TAction;
    ActionSave: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ButtonRotateLeftClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ActionRecaptureExecute(Sender: TObject);
    procedure ActionRotateLeftExecute(Sender: TObject);
    procedure ActionRotateRightExecute(Sender: TObject);
    procedure ActionCopyToClipboardExecute(Sender: TObject);
    procedure ActionSaveExecute(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure ActionListScreenshotUpdate(Action: TBasicAction;
      var Handled: Boolean);
  private
    FIsStartedTakeScreenshot: boolean;
    FDevice: IDevice;

    FTimeScreenshot: TDatetime;
    FScreenRaw: Nullable<TRawImage>;
    FScreenshot: TBitmap;

    procedure DoTakeScreenshot;
  public
    constructor Create(AOwner: TComponent; ADevice: IDevice); overload;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

uses
    Winapi.GDIPAPI
  , Winapi.GDIPOBJ
  , Winapi.GDIPUTIL
  , System.Math
  , System.DateUtils
{$IFDEF BPL}
  , ToolsAPI
{$ENDIF}
  ;

procedure RotateBitmap(Bmp: TBitmap; RotateType: TRotateFlipType; AdjustSize: Boolean; BkColor: TColor = clNone);
var
  NewSize: TSize;
begin
  var Tmp := TGPBitmap.Create(Bmp.Handle, Bmp.Palette);
  try
    TMP.RotateFlip(RotateType);

    if AdjustSize then
    begin
      NewSize.cx := Bmp.Height;
      NewSize.cy := Bmp.Width;
      Bmp.Width := NewSize.cx;
      Bmp.Height := NewSize.cy;
    end;

    var hbmp: HBitmap;
    Tmp.GetHBITMAP(0, hbmp);
    Bmp.Handle := hbmp;
  finally
    Tmp.Free;
  end;
end;


procedure TFormTakeScreenshot.ActionCopyToClipboardExecute(Sender: TObject);
var
  AFormat : Word;
  AData : THandle;
  APalette : HPALETTE;
begin
  if not FScreenRaw.HasValue then
    exit;

  ImageScreenshot.Picture.SaveToClipBoardFormat(AFormat, AData, APalette);
  ClipBoard.SetAsHandle(AFormat,AData);
end;

procedure TFormTakeScreenshot.ActionListScreenshotUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  ActionRecapture.Enabled       := assigned(FDevice) and (FDevice.IsOnline);
  ActionRotateLeft.Enabled      := FScreenRaw.HasValue;
  ActionRotateRight.Enabled     := FScreenRaw.HasValue;
  ActionCopyToClipboard.Enabled := FScreenRaw.HasValue;
  ActionSave.Enabled            := FScreenRaw.HasValue;
end;

procedure TFormTakeScreenshot.ActionRecaptureExecute(Sender: TObject);
begin
  DoTakeScreenshot;
end;

procedure TFormTakeScreenshot.ActionRotateLeftExecute(Sender: TObject);
begin
  if FScreenRaw.HasValue then
  begin
    RotateBitmap(ImageScreenshot.Picture.Bitmap, TRotateFlipType.Rotate270FlipNone, true);
  end;
end;

procedure TFormTakeScreenshot.ActionRotateRightExecute(Sender: TObject);
begin
  if FScreenRaw.HasValue then
  begin
    RotateBitmap(ImageScreenshot.Picture.Bitmap, TRotateFlipType.Rotate90FlipNone, true);
  end;
end;

procedure TFormTakeScreenshot.ActionSaveExecute(Sender: TObject);
begin
  if not FScreenRaw.HasValue then
    exit;

  SaveScreenshotFile.FileName := FTimeScreenshot.Format('yyyymmdd_hhnnsszzz')+'.png';
  if not SaveScreenshotFile.Execute then
    exit;

  var FileName := SaveScreenshotFile.FileName;
  ImageScreenshot.Picture.SaveToFile(FileName);
end;

procedure TFormTakeScreenshot.ButtonCancelClick(Sender: TObject);
begin
  self.Close;
end;

procedure TFormTakeScreenshot.ButtonRotateLeftClick(Sender: TObject);
begin
  if FScreenRaw.HasValue then
  begin
    RotateBitmap(ImageScreenshot.Picture.Bitmap, TRotateFlipType.Rotate270FlipNone, true);
  end;
end;

constructor TFormTakeScreenshot.Create(AOwner: TComponent; ADevice: IDevice);
begin
  inherited Create(AOwner);
  FDevice := ADevice;
  FIsStartedTakeScreenshot := true;

  FScreenshot := TBitmap.Create;
end;

destructor TFormTakeScreenshot.Destroy;
begin
  FScreenshot.Free;
  inherited;
end;

procedure TFormTakeScreenshot.DoTakeScreenshot;
begin
  if FDevice.IsOffline then
    exit;

  FScreenRaw :=  FDevice.GetScreenshot;
  FTimeScreenshot := Now;
  if FScreenRaw.HasValue then
  begin
    var RawImage := FScreenRaw.Value;
    FScreenshot.Handle := CreateBitmap(RawImage.Width, RawImage.Height, RawImage.ColorSpace, RawImage.Bpp, @RawImage.Data[0]);
    ImageScreenshot.Picture.Bitmap.Assign(FScreenshot);
  end;
end;

procedure TFormTakeScreenshot.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TFormTakeScreenshot.FormCreate(Sender: TObject);
begin
  {$IFDEF BPL}
  var ThemingServices : IOTAIDEThemingServices;
  if Supports(BorlandIDEServices, IOTAIDEThemingServices, ThemingServices) then
  begin
    ThemingServices.ApplyTheme(self);
  end;
  {$ENDIF}
end;

procedure TFormTakeScreenshot.FormShow(Sender: TObject);
begin
  try
    if FIsStartedTakeScreenshot then
    begin
      if FDevice.IsOffline then
        exit;

      DoTakeScreenshot;
    end;
  finally
    FIsStartedTakeScreenshot :=  false;
  end;
end;

procedure TFormTakeScreenshot.Timer1Timer(Sender: TObject);
begin
  if not assigned(FDevice) then
    exit;
  if FDevice.IsOffline then
    exit;

  DoTakeScreenshot;
end;

end.
