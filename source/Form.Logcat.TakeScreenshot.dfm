object FormTakeScreenshot: TFormTakeScreenshot
  Left = 0
  Top = 0
  Caption = 'Logcat Take Screenshot'
  ClientHeight = 809
  ClientWidth = 652
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object PanelTop: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 646
    Height = 40
    Align = alTop
    TabOrder = 1
    ExplicitWidth = 644
    object ButtonRecapture: TButton
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 100
      Height = 32
      Action = ActionRecapture
      Align = alLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object ButtonRotateLeft: TButton
      AlignWithMargins = True
      Left = 110
      Top = 4
      Width = 100
      Height = 32
      Action = ActionRotateLeft
      Align = alLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object ButtonRotateRight: TButton
      AlignWithMargins = True
      Left = 216
      Top = 4
      Width = 100
      Height = 32
      Action = ActionRotateRight
      Align = alLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
    end
    object ButtonCopyToClipboard: TButton
      AlignWithMargins = True
      Left = 322
      Top = 4
      Width = 120
      Height = 32
      Action = ActionCopyToClipboard
      Align = alLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
    end
  end
  object PanelBottom: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 765
    Width = 646
    Height = 41
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 757
    ExplicitWidth = 644
    object ButtonCancel: TButton
      AlignWithMargins = True
      Left = 534
      Top = 4
      Width = 108
      Height = 33
      Align = alRight
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 0
      OnClick = ButtonCancelClick
      ExplicitLeft = 532
    end
    object ButtonSave: TButton
      AlignWithMargins = True
      Left = 420
      Top = 4
      Width = 108
      Height = 33
      Action = ActionSave
      Align = alRight
      Default = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      ExplicitLeft = 418
    end
  end
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 46
    Width = 652
    Height = 716
    Align = alClient
    TabOrder = 2
    ExplicitWidth = 650
    ExplicitHeight = 708
    object ImageScreenshot: TImage
      Left = 0
      Top = 0
      Width = 648
      Height = 712
      Align = alClient
      Center = True
      Proportional = True
      ExplicitLeft = 232
      ExplicitTop = 376
      ExplicitWidth = 105
      ExplicitHeight = 105
    end
  end
  object SaveScreenshotFile: TSavePictureDialog
    Filter = 'Portable Network Graphics (*.png)|*.png|Bitmaps (*.bmp)|*.bmp'
    Left = 416
    Top = 398
  end
  object ActionListScreenshot: TActionList
    OnUpdate = ActionListScreenshotUpdate
    Left = 280
    Top = 190
    object ActionRecapture: TAction
      Caption = 'Recapture'
      Hint = 'Recapture Screenshot from Device'
      OnExecute = ActionRecaptureExecute
    end
    object ActionRotateLeft: TAction
      Caption = 'Rotate Left'
      Hint = 'Rotate Screenshot to Left'
      OnExecute = ActionRotateLeftExecute
    end
    object ActionRotateRight: TAction
      Caption = 'Rotate Right'
      Hint = 'Rotate Screenshot to Right'
      OnExecute = ActionRotateRightExecute
    end
    object ActionCopyToClipboard: TAction
      Caption = 'Copy to Clipboard'
      Hint = 'Copy Screenshot into Clipboard'
      OnExecute = ActionCopyToClipboardExecute
    end
    object ActionSave: TAction
      Caption = 'Save'
      Hint = 'Save Screenshot into File'
      OnExecute = ActionSaveExecute
    end
  end
end
