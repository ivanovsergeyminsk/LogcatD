object FrameLogcat: TFrameLogcat
  Left = 0
  Top = 0
  Width = 1267
  Height = 443
  Margins.Bottom = 4
  Align = alClient
  Color = clWindow
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object PanelTop: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 0
    Width = 1261
    Height = 33
    Margins.Top = 0
    Margins.Bottom = 0
    Align = alTop
    ParentBackground = False
    TabOrder = 0
    object SplitterTop: TSplitter
      Left = 400
      Top = 1
      Height = 31
      ExplicitLeft = 441
      ExplicitTop = 4
    end
    object SpeedButtonFilter: TSpeedButton
      Left = 403
      Top = 1
      Width = 23
      Height = 31
      Action = ActionClearFilters
      Align = alLeft
      Images = DMLogcat.SVGIconImageList
      ExplicitLeft = 424
      ExplicitTop = 8
      ExplicitHeight = 22
    end
    object ButtonedEditFIlter: TButtonedEdit
      AlignWithMargins = True
      Left = 429
      Top = 4
      Width = 677
      Height = 24
      Hint = 'Filter'
      Margins.Bottom = 4
      Align = alClient
      LeftButton.DropDownMenu = PopupMenuHistory
      LeftButton.Hint = 'Show history'
      LeftButton.ImageIndex = 0
      LeftButton.ImageName = 'Filter'
      LeftButton.Visible = True
      ParentColor = True
      ParentShowHint = False
      RightButton.Hint = 'Clear filter'
      RightButton.ImageIndex = 1
      RightButton.ImageName = 'Cross'
      RightButton.Visible = True
      ShowHint = True
      TabOrder = 0
      TextHint = 'pid:<filter> package:<filter> tag:<filter> message:<filter>'
      OnChange = ButtonedEditFIlterChange
      ExplicitHeight = 23
    end
    object PanelDevice: TPanel
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 393
      Height = 25
      Align = alLeft
      BevelEdges = []
      Ctl3D = True
      UseDockManager = False
      ParentBackground = False
      ParentColor = True
      ParentCtl3D = False
      ShowCaption = False
      TabOrder = 1
      OnClick = ImageDeviceClick
      object LabelDevice: TLabel
        Left = 34
        Top = 1
        Width = 358
        Height = 23
        Hint = 'Connected devices'
        Align = alClient
        Caption = 'Click to select a device'
        ParentShowHint = False
        ShowHint = True
        Layout = tlCenter
        OnClick = ImageDeviceClick
        ExplicitWidth = 119
        ExplicitHeight = 15
      end
      object SVGIconImageOnline: TSVGIconImage
        Left = 1
        Top = 1
        Width = 33
        Height = 23
        AutoSize = False
        ImageList = DMLogcat.SVGIconImageList
        Align = alLeft
      end
    end
    object ComboBoxLevel: TComboBox
      AlignWithMargins = True
      Left = 1112
      Top = 5
      Width = 145
      Height = 23
      Hint = 'Minimal log Level'
      Margins.Top = 4
      Margins.Bottom = 0
      Align = alRight
      Style = csDropDownList
      ItemIndex = 0
      ParentColor = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      Text = 'All'
      OnChange = ButtonedEditFIlterChange
      Items.Strings = (
        'All'
        'VERBOSE'
        'DEBUG'
        'INFO'
        'WARN'
        'ERROR'
        'ASSERT')
    end
  end
  object PanelLeft: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 33
    Width = 41
    Height = 407
    Margins.Top = 0
    Margins.Right = 0
    Align = alLeft
    ParentBackground = False
    TabOrder = 1
    object SpeedButtonStartStop: TSpeedButton
      Left = 1
      Top = 41
      Width = 39
      Height = 40
      Action = ActionStartStop
      Align = alTop
      Images = DMLogcat.SVGIconImageList
      ParentShowHint = False
      ShowHint = True
      ExplicitTop = 1
    end
    object SpeedButtonClearLogs: TSpeedButton
      Left = 1
      Top = 1
      Width = 39
      Height = 40
      Action = ActionClearLogs
      Align = alTop
      ParentShowHint = False
      ShowHint = True
      ExplicitLeft = -4
    end
    object SpeedButtonAutoScroll: TSpeedButton
      Left = 1
      Top = 81
      Width = 39
      Height = 40
      Action = ActionAutoScroll
      Align = alTop
      Images = DMLogcat.SVGIconImageList
      ParentShowHint = False
      ShowHint = True
      ExplicitLeft = 2
      ExplicitTop = 127
    end
    object SpeedButtonSoftWrap: TSpeedButton
      Left = 1
      Top = 121
      Width = 39
      Height = 40
      Action = ActionSoftWrap
      Align = alTop
      Images = DMLogcat.SVGIconImageList
      ParentShowHint = False
      ShowHint = True
      ExplicitLeft = -1
    end
    object SpeedButtonTakeScreenshot: TSpeedButton
      Left = 1
      Top = 161
      Width = 39
      Height = 40
      Action = ActionTakeScreenshot
      Align = alTop
      Images = DMLogcat.SVGIconImageList
      ParentShowHint = False
      ShowHint = True
      ExplicitLeft = -1
      ExplicitTop = 155
    end
    object SpeedButtonRecordScreen: TSpeedButton
      Left = 1
      Top = 201
      Width = 39
      Height = 40
      Hint = 'Record Screen'
      Align = alTop
      ImageIndex = 0
      ImageName = 'logo'
      Images = DMLogcat.SVGIconImageList
      ParentShowHint = False
      ShowHint = True
      Visible = False
      ExplicitLeft = -1
      ExplicitTop = 247
    end
  end
  object VirtualStringLogcat: TVirtualStringTree
    AlignWithMargins = True
    Left = 47
    Top = 36
    Width = 1217
    Height = 404
    Align = alClient
    Colors.BorderColor = 2697513
    Colors.DisabledColor = clGray
    Colors.DropMarkColor = 14581296
    Colors.DropTargetColor = 14581296
    Colors.DropTargetBorderColor = 14581296
    Colors.FocusedSelectionColor = 14581296
    Colors.FocusedSelectionBorderColor = 14581296
    Colors.GridLineColor = 2697513
    Colors.HeaderHotColor = clBlack
    Colors.HotColor = 15987699
    Colors.SelectionRectangleBlendColor = 14581296
    Colors.SelectionRectangleBorderColor = 14581296
    Colors.SelectionTextColor = clBlack
    Colors.TreeLineColor = 9471874
    Colors.UnfocusedColor = clGray
    Colors.UnfocusedSelectionColor = 2368548
    Colors.UnfocusedSelectionBorderColor = 2368548
    Header.AutoSizeIndex = 0
    Header.Height = 23
    Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    ParentColor = True
    PopupMenu = PopupMenuTree
    TabOrder = 2
    TreeOptions.PaintOptions = [toHideFocusRect, toShowHorzGridLines, toShowRoot, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect]
    OnDrawText = VirtualStringLogcatDrawText
    OnGetText = VirtualStringLogcatGetText
    Touch.InteractiveGestures = [igPan, igPressAndTap]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
    Columns = <
      item
        Position = 0
        Text = 'Time'
        Width = 143
      end
      item
        Position = 1
        Text = 'Pid'
        Width = 60
      end
      item
        Position = 2
        Text = 'Tid'
        Width = 60
      end
      item
        Position = 3
        Text = 'AppName'
        Width = 154
      end
      item
        Position = 4
        Text = 'Tag'
        Width = 164
      end
      item
        Position = 5
        Text = 'Level'
        Width = 59
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coShowDropMark, coVisible, coAllowFocus, coEditable, coStyleColor]
        Position = 6
        Text = 'Message'
        Width = 10000
      end>
  end
  object PopupMenuHistory: TPopupMenu
    Left = 296
    Top = 96
  end
  object PopupMenuDevices: TPopupMenu
    Left = 160
    Top = 96
  end
  object ActionListLogcat: TActionList
    Images = DMLogcat.SVGIconImageList
    OnUpdate = ActionListLogcatUpdate
    Left = 256
    Top = 176
    object ActionClearFilters: TAction
      Hint = 'Clear Filter'
      ImageIndex = 6
      ImageName = 'clearFilter'
      OnExecute = ActionClearFiltersExecute
      OnUpdate = ActionClearFiltersUpdate
    end
    object ActionClearLogs: TAction
      Hint = 'Clear Log Messages'
      ImageIndex = 7
      ImageName = 'clearLogs'
      OnExecute = ActionClearLogsExecute
    end
    object ActionStartStop: TAction
      Hint = 'Start/Pause logging'
      ImageIndex = 8
      ImageName = 'startLogs'
      OnExecute = ActionStartStopExecute
      OnUpdate = ActionStartStopUpdate
    end
    object ActionAutoScroll: TAction
      Hint = 'Autscroll'
      ImageIndex = 11
      ImageName = 'autoscrollOn'
      OnExecute = ActionAutoScrollExecute
    end
    object ActionSoftWrap: TAction
      Hint = 'SoftWrap'
      ImageIndex = 12
      ImageName = 'softWrap'
      OnExecute = ActionSoftWrapExecute
    end
    object ActionTakeScreenshot: TAction
      Hint = 'Take Screenshot'
      ImageIndex = 13
      ImageName = 'takeScreenshot'
      OnExecute = ActionTakeScreenshotExecute
      OnUpdate = ActionTakeScreenshotUpdate
    end
    object ActionCopyLogMessages: TAction
      Caption = 'Copy'
      Hint = 'Copy Log Messages'
      OnExecute = ActionCopyLogMessagesExecute
    end
    object ActionSaveToFile: TAction
      Caption = 'Save to...'
      Hint = 'Save to File'
      OnExecute = ActionSaveToFileExecute
    end
  end
  object PopupMenuTree: TPopupMenu
    Left = 448
    Top = 136
    object Copy1: TMenuItem
      Action = ActionCopyLogMessages
    end
    object Savetofile1: TMenuItem
      Action = ActionSaveToFile
    end
  end
  object SaveTextLog: TSaveTextFileDialog
    Left = 96
    Top = 208
  end
end
