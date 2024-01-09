unit Form.Logcat;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DockForm, Vcl.Themes, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Buttons, Frame.Logcat, Vcl.ComCtrls, System.TabControlStyleBtnClose,
  System.Utility.IntAllocator;

type
  TFormLogcat = class(TDockableForm)
    PageControlLogcat: TPageControl;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FIntAllocator: TIntAllocator;
    procedure DoClickEmptyTab(Sender: TObject);

    procedure DoCloseTabSheet(Sender: TObject);
    procedure NewEmptyPage;
    procedure NewPage;

    procedure UpdateCloseButtons;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

{$IFDEF BPL}
uses
    ToolsAPI
  ;
{$ENDIF}


procedure TFormLogcat.DoClickEmptyTab(Sender: TObject);
begin
  NewPage;
  if not (Sender is TTabSheet) then
    exit;

  var tabsheet := Sender as TTabSheet;
  tabsheet.PageIndex := PageControlLogcat.PageCount - 1;
  PageControlLogcat.ActivePageIndex := tabsheet.PageIndex-1;

  UpdateCloseButtons;
end;

procedure TFormLogcat.DoCloseTabSheet(Sender: TObject);
begin
  if not (Sender is TTabSheet) then
    exit;

  var tabsheet := Sender as TTabSheet;

  if PageControlLogcat.PageCount = 2 then
    exit;

  FIntAllocator.Free(tabsheet.Tag);
  tabsheet.Parent := nil;
  tabsheet.Free;

  if PageControlLogcat.ActivePageIndex = PageControlLogcat.PageCount-1 then
    PageControlLogcat.ActivePageIndex := PageControlLogcat.PageCount-2;

  UpdateCloseButtons;
end;

procedure TFormLogcat.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TFormLogcat.FormCreate(Sender: TObject);
begin
  FIntAllocator := TIntAllocator.Create(1, 100);
  NewEmptyPage;
  DoClickEmptyTab(PageControlLogcat.Pages[0]);

  {$IFDEF BPL}
  var ThemingServices : IOTAIDEThemingServices;
  if Supports(BorlandIDEServices, IOTAIDEThemingServices, ThemingServices) then
  begin
    ThemingServices.ApplyTheme(self);
  end;
  {$ENDIF}
end;

procedure TFormLogcat.FormDestroy(Sender: TObject);
begin
  FIntAllocator.Free;
end;

procedure TFormLogcat.NewEmptyPage;
begin
  var TabSheet := TCloseTabSheet.Create(Self);
  TabSheet.Caption := '+';
  TabSheet.PageControl := PageControlLogcat;
  TabSheet.OnClick := DoClickEmptyTab;
end;

procedure TFormLogcat.NewPage;
begin
  var TabSheet := TCloseTabSheet.Create(Self);
  var FrameLogcat := TFrameLogcat.Create(TabSheet);
  FrameLogcat.Parent := TabSheet;
  TabSheet.IsShowCloseButton := true;
  TabSheet.Tag := FIntAllocator.Allocate;
  TabSheet.Caption := format('Logcat (%d)          ', [TabSheet.Tag]);
  TabSheet.PageControl := PageControlLogcat;
  TabSheet.OnClose := DoCloseTabSheet;
end;

procedure TFormLogcat.UpdateCloseButtons;
begin
  for var I := 0 to PageControlLogcat.PageCount-2 do
    (PageControlLogcat.Pages[0] as TCloseTabSheet).IsShowCloseButton := true;

  if PageControlLogcat.PageCount = 2 then
    (PageControlLogcat.Pages[0] as TCloseTabSheet).IsShowCloseButton := false;

  PageControlLogcat.Invalidate;
end;

end.
