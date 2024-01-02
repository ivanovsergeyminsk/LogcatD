unit Form.Logcat;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DockForm, Vcl.Themes, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Buttons, Frame.Logcat;

type
  TFormLogcat = class(TDockableForm)
    FrameLogcat1: TFrameLogcat;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}


procedure TFormLogcat.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FrameLogcat1.LogStop;
  Action := TCloseAction.caFree;
end;

end.
