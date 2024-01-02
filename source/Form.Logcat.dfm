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
  TextHeight = 15
  inline FrameLogcat1: TFrameLogcat
    Left = 0
    Top = 0
    Width = 1084
    Height = 457
    Margins.Bottom = 4
    Align = alClient
    Color = clWindow
    ParentBackground = False
    ParentColor = False
    TabOrder = 0
    ExplicitWidth = 1084
    ExplicitHeight = 457
    inherited PanelTop: TPanel
      Width = 1078
      StyleElements = [seFont, seClient, seBorder]
      ExplicitWidth = 1076
      inherited SpeedButtonFilter: TSpeedButton
        Glyph.Data = {00000000}
      end
      inherited ButtonedEditFIlter: TButtonedEdit
        Width = 494
        StyleElements = [seFont, seClient, seBorder]
        ExplicitWidth = 492
      end
      inherited PanelDevice: TPanel
        StyleElements = [seFont, seClient, seBorder]
        inherited LabelDevice: TLabel
          Width = 358
          Height = 23
          StyleElements = [seFont, seClient, seBorder]
        end
      end
      inherited ComboBoxLevel: TComboBox
        Left = 929
        StyleElements = [seFont, seClient, seBorder]
        ExplicitLeft = 927
      end
    end
    inherited PanelLeft: TPanel
      Height = 421
      StyleElements = [seFont, seClient, seBorder]
      ExplicitHeight = 413
      inherited SpeedButtonStartStop: TSpeedButton
        Glyph.Data = {00000000}
      end
      inherited SpeedButtonAutoScroll: TSpeedButton
        Glyph.Data = {00000000}
      end
      inherited SpeedButtonTakeScreenshot: TSpeedButton
        Glyph.Data = {00000000}
      end
    end
    inherited VirtualStringLogcat: TVirtualStringTree
      Width = 1034
      Height = 418
      Colors.HeaderHotColor = clBlack
      Colors.HotColor = 5658198
      Colors.SelectionTextColor = clBlack
      Header.Background = 5658198
      ExplicitWidth = 1034
      ExplicitHeight = 418
    end
    inherited ActionListLogcat: TActionList
      inherited ActionStartStop: TAction
        Hint = 'Start/Stop Loging'
      end
      inherited ActionClearLogs: TAction
        Hint = 'Clear Log Messages'
      end
      inherited ActionClearFilters: TAction
        Hint = 'Clear Filters'
      end
      inherited ActionAutoScroll: TAction
        Hint = 'Autoscroll'
      end
      inherited ActionTakeScreenshot: TAction
        Hint = 'Take Screenshot'
      end
      inherited ActionCopyLogMessages: TAction
        Hint = 'Copy Log Messages'
      end
      inherited ActionSaveToFile: TAction
        Hint = 'Save to File'
      end
    end
  end
end
