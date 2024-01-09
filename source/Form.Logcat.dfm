object FormLogcat: TFormLogcat
  Left = 0
  Top = 0
  Caption = 'Logcat'
  ClientHeight = 457
  ClientWidth = 1084
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object PageControlLogcat: TPageControl
    Left = 0
    Top = 0
    Width = 1084
    Height = 457
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 1082
    ExplicitHeight = 449
  end
end
