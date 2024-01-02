object FormScreenRecorder: TFormScreenRecorder
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Logcat Screen Recorder Options'
  ClientHeight = 212
  ClientWidth = 364
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  TextHeight = 15
  object LabelText: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 358
    Height = 15
    Align = alTop
    Alignment = taCenter
    Caption = 'The length of the recording can be up to 3 mintues.'
    ExplicitLeft = 32
    ExplicitTop = 48
    ExplicitWidth = 271
  end
  object Label1: TLabel
    Left = 24
    Top = 40
    Width = 81
    Height = 15
    Caption = 'Bit rate (Mbps):'
  end
  object Label2: TLabel
    Left = 24
    Top = 80
    Width = 129
    Height = 15
    Caption = 'Resolution (% of native):'
  end
  object EditBitRate: TEdit
    Left = 192
    Top = 37
    Width = 121
    Height = 23
    NumbersOnly = True
    TabOrder = 0
    Text = '4'
  end
  object ComboBoxResolution: TComboBox
    Left = 192
    Top = 77
    Width = 121
    Height = 23
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 1
    Text = '100'
    Items.Strings = (
      '100'
      '50'
      '30')
  end
  object Panel1: TPanel
    Left = 0
    Top = 171
    Width = 364
    Height = 41
    Align = alBottom
    TabOrder = 2
    ExplicitLeft = 192
    ExplicitTop = 192
    ExplicitWidth = 185
    object ButtonSave: TButton
      AlignWithMargins = True
      Left = 138
      Top = 4
      Width = 108
      Height = 33
      Align = alRight
      Caption = 'Start Recording'
      Default = True
      TabOrder = 0
      ExplicitLeft = 420
    end
    object ButtonCancel: TButton
      AlignWithMargins = True
      Left = 252
      Top = 4
      Width = 108
      Height = 33
      Align = alRight
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 1
      ExplicitLeft = 534
    end
  end
end
