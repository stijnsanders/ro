inherited ConnectionWin: TConnectionWin
  Left = 368
  Top = 198
  Width = 446
  Height = 352
  Caption = 'ConnectionWin'
  Font.Name = 'Verdana'
  Icon.Data = {
    0000010001001010100000000000280100001600000028000000100000002000
    00000100040000000000C0000000000000000000000000000000000000000000
    000000008000008000000080800080000000800080008080000080808000C0C0
    C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    77777777770000000000000007000000FFFFFFFF07000000F000000F07000000
    F088880F07000000F088880F07000000F000000F07000000F087880F07000000
    F000000F07000000FFFFFFFF07000000FFFF000000000000FFFF0FF000000000
    FFFF0F0000000000FFFF0000000000000000000000000000000000000000F003
    0000E0030000E0030000E0030000E0030000E0030000E0030000E0030000E003
    0000E0030000E0070000E00F0000E01F0000E03F0000E07F0000FFFF0000}
  Menu = MainMenu1
  OldCreateOrder = True
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Com: TMemo
    Left = 0
    Top = 273
    Width = 430
    Height = 21
    Align = alBottom
    TabOrder = 0
    WantTabs = True
    WordWrap = False
    OnChange = ComChange
    OnKeyDown = ComKeyDown
    OnKeyPress = ComKeyPress
  end
  object Web1: TRestrictedWebBrowser
    Left = 0
    Top = 0
    Width = 430
    Height = 273
    TabStop = False
    Align = alClient
    PopupMenu = PopupMenu1
    TabOrder = 1
    OnBeforeNavigate2 = Web1BeforeNavigate2
    OnDocumentComplete = Web1DocumentComplete
    ControlData = {
      4C000000712C0000371C00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object ActionList1: TActionList
    Images = MainWin.ImageList1
    Left = 8
    Top = 8
    object aConnect: TAction
      Category = 'Connect'
      Caption = 'Connect'
      Hint = 'Open current connection'
      ImageIndex = 25
      OnExecute = aConnectExecute
    end
    object aDisconnect: TAction
      Category = 'Connect'
      Caption = 'Disconnect'
      Hint = 'Close current connection'
      ImageIndex = 26
      OnExecute = aDisconnectExecute
    end
    object aTTime: TAction
      Category = 'View'
      Caption = 'Time tags'
      Hint = 'Toggle time tags'
      ImageIndex = 34
      ShortCut = 116
      OnExecute = aTTimeExecute
    end
    object aTCode: TAction
      Category = 'View'
      Caption = 'Codes'
      Hint = 'Toggle codes'
      ImageIndex = 35
      ShortCut = 117
      OnExecute = aTCodeExecute
    end
    object aTSystem: TAction
      Category = 'View'
      Caption = 'System messages'
      Hint = 'Toggle system messages'
      ImageIndex = 36
      ShortCut = 118
      OnExecute = aTSystemExecute
    end
  end
  object MainMenu1: TMainMenu
    Images = MainWin.ImageList1
    Left = 40
    Top = 8
    object Connection1: TMenuItem
      Caption = 'Connection'
      GroupIndex = 20
      object aConnect1: TMenuItem
        Action = aConnect
      end
      object aDisconnect1: TMenuItem
        Action = aDisconnect
      end
    end
    object View1: TMenuItem
      Caption = 'View'
      GroupIndex = 20
      object aTTime1: TMenuItem
        Action = aTTime
      end
      object aTCode1: TMenuItem
        Action = aTCode
      end
      object aTSystem1: TMenuItem
        Action = aTSystem
      end
    end
  end
  object OpenDialog1: TOpenDialog
    InitialDir = '.'
    Left = 72
    Top = 8
  end
  object PopupMenu1: TPopupMenu
    Left = 104
    Top = 8
    object Copy1: TMenuItem
      Caption = 'Copy'
      OnClick = Copy1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Selectall1: TMenuItem
      Caption = 'Select all'
      OnClick = Selectall1Click
    end
  end
end
