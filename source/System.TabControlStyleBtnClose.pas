unit System.TabControlStyleBtnClose;

interface

uses
    Vcl.ComCtrls
  , Vcl.Graphics
  , Vcl.Styles
  , Vcl.Themes
  , Vcl.Controls
  , System.Classes
  , Winapi.Windows
  , Winapi.Messages
  ;

type
  TTabControlStyleHookBtnClose = class(TTabControlStyleHook)
  private
    FHotIndex       : Integer;
    FWidthModified  : Boolean;
    procedure WMMouseMove(var Message: TMessage); message WM_MOUSEMOVE;
    procedure WMLButtonUp(var Message: TWMMouse); message WM_LBUTTONUP;
    function GetButtonCloseRect(Index: Integer):TRect;
    function GetTabRect(Index: integer): TRect;
  strict protected
    procedure DrawTab(Canvas: TCanvas; Index: Integer); override;
    procedure MouseEnter; override;
    procedure MouseLeave; override;
  public
    constructor Create(AControl: TWinControl); override;
  end;

 TCloseTabSheet = class(TTabSheet)
  protected
    FIsShowCloseButton: boolean;
    FOnClose: TNotifyEvent;
    FOnClick: TNotifyEvent;
    procedure DoClose; virtual;
    procedure DoClick; virtual;
  public
    constructor Create(AOwner:TComponent); override;
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property IsShowCloseButton: boolean read FIsShowCloseButton write FIsShowCloseButton;
  end;


implementation


constructor TCloseTabSheet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIsShowCloseButton := false;
end;

procedure TCloseTabSheet.DoClick;
begin
  if Assigned(FOnClick) then
    FOnClick(Self);
end;

procedure TCloseTabSheet.DoClose;
begin
  if not FIsShowCloseButton then
    exit;

  if Assigned(FOnClose) then
    FOnClose(Self);
end;

constructor TTabControlStyleHookBtnClose.Create(AControl: TWinControl);
begin
  inherited;
  FHotIndex:=-1;
  FWidthModified:=False;
end;

procedure TTabControlStyleHookBtnClose.DrawTab(Canvas: TCanvas; Index: Integer);
var
  Details : TThemedElementDetails;
  ButtonR : TRect;
  FButtonState: TThemedWindow;
begin
  inherited;

  if TPageControl(Control).Pages[Index] is TCloseTabSheet then
  begin
    if not TCloseTabSheet(TPageControl(Control).Pages[Index]).IsShowCloseButton then
      exit;

    if (FHotIndex>=0) and (Index=FHotIndex) then
      FButtonState := twSmallCloseButtonHot
    else
    if Index = TabIndex then
      FButtonState := twSmallCloseButtonNormal
    else
      FButtonState := twSmallCloseButtonDisabled;

    Details := StyleServices.GetElementDetails(FButtonState);

    ButtonR:= GetButtonCloseRect(Index);
    if ButtonR.Bottom - ButtonR.Top > 0 then
     StyleServices.DrawElement(Canvas.Handle, Details, ButtonR);
  end;
end;

procedure TTabControlStyleHookBtnClose.WMLButtonUp(var Message: TWMMouse);
Var
  LPoint : TPoint;
  LIndex : Integer;
begin
  LPoint:=Message.Pos;
  for LIndex := 0 to TabCount-1 do
   if PtInRect(GetButtonCloseRect(LIndex), LPoint) then
   begin
      if Control is TPageControl then
      begin
        if TPageControl(Control).Pages[LIndex] is TCloseTabSheet then
        begin
          if TCloseTabSheet(TPageControl(Control).Pages[LIndex]).IsShowCloseButton then
            TCloseTabSheet(TPageControl(Control).Pages[LIndex]).DoClose
          else
            TCloseTabSheet(TPageControl(Control).Pages[LIndex]).DoClick
        end
      end;
      break;
   end
   else
   if PtInRect(GetTabRect(LIndex), LPoint) then
   begin
    if TPageControl(Control).Pages[LIndex] is TCloseTabSheet then
      TCloseTabSheet(TPageControl(Control).Pages[LIndex]).DoClick
   end;

end;

procedure TTabControlStyleHookBtnClose.WMMouseMove(var Message: TMessage);
Var
  LPoint : TPoint;
  LIndex : Integer;
  LHotIndex : Integer;
begin
  inherited;
  LHotIndex:=-1;
  LPoint:=TWMMouseMove(Message).Pos;
  for LIndex := 0 to TabCount-1 do
   if PtInRect(GetButtonCloseRect(LIndex), LPoint) then
   begin
      LHotIndex:=LIndex;
      break;
   end;

   if (FHotIndex<>LHotIndex) then
   begin
     FHotIndex:=LHotIndex;
     Invalidate;
   end;
end;

function TTabControlStyleHookBtnClose.GetButtonCloseRect(Index: Integer): TRect;
var
  FButtonState: TThemedWindow;
  Details : TThemedElementDetails;
  ButtonR : TRect;
begin
  Result := GetTabRect(Index);
  FButtonState := twSmallCloseButtonNormal;

  Details := StyleServices.GetElementDetails(FButtonState);
  if not StyleServices.GetElementContentRect(0, Details, Result, ButtonR) then
    ButtonR := Rect(0, 0, 0, 0);

  Result.Left :=Result.Right - (ButtonR.Width) - 5;
  Result.Width:=ButtonR.Width;
end;

function TTabControlStyleHookBtnClose.GetTabRect(Index: integer): TRect;
var
  R : TRect;
begin
  R := TabRect[Index];
  if R.Left < 0 then Exit;

  if TabPosition in [tpTop, tpBottom] then
  begin
    if Index = TabIndex then
      InflateRect(R, 0, 2);
  end
  else
  if Index = TabIndex then
    Dec(R.Left, 2)
  else
    Dec(R.Right, 2);

  Result := R;
end;

procedure TTabControlStyleHookBtnClose.MouseEnter;
begin
  inherited;
  FHotIndex := -1;
end;

procedure TTabControlStyleHookBtnClose.MouseLeave;
begin
  inherited;
  if FHotIndex >= 0 then
  begin
    FHotIndex := -1;
    Invalidate;
  end;
end;

initialization
  TStyleManager.Engine.RegisterStyleHook(TCustomTabControl, TTabControlStyleHookBtnClose);
  TStyleManager.Engine.RegisterStyleHook(TTabControl, TTabControlStyleHookBtnClose);

end.
