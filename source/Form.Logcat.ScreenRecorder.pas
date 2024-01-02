unit Form.Logcat.ScreenRecorder;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFormScreenRecorder = class(TForm)
    LabelText: TLabel;
    Label1: TLabel;
    EditBitRate: TEdit;
    Label2: TLabel;
    ComboBoxResolution: TComboBox;
    Panel1: TPanel;
    ButtonSave: TButton;
    ButtonCancel: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
