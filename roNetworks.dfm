inherited NetworkWin: TNetworkWin
  Left = 349
  Width = 380
  Height = 368
  Caption = 'Networks'
  Icon.Data = {
    0000010001001010100000000000280100001600000028000000100000002000
    00000100040000000000C0000000000000000000000000000000000000000000
    0000000080000080000000808000800000008000800080800000C0C0C0008080
    80000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    0000000000000000088800888000000000080000800000080608806088800000
    0600006000800006666666666080000006000060000000000608006080000008
    0608806088800000060000600080000666666666608000000600006000000000
    060800608000000000000000000000000000000000000000000000000000FFFF
    0000F8C70000F0870000E0010000C0010000C0010000C0030000F0870000E001
    0000C0010000C0010000C0030000F0870000F18F0000FFFF0000FFFF0000}
  Menu = MainMenu1
  OldCreateOrder = True
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object oView: TTreeView
    Left = 0
    Top = 0
    Width = 364
    Height = 310
    Align = alClient
    Images = MainWin.ImageList1
    Indent = 19
    PopupMenu = PopupMenu1
    RightClickSelect = True
    SortType = stText
    TabOrder = 0
    OnDblClick = oViewDblClick
    OnDeletion = oViewDeletion
    OnEdited = oViewEdited
    OnExpanding = oViewExpanding
  end
  object MainMenu1: TMainMenu
    Images = MainWin.ImageList1
    Left = 40
    Top = 8
    object Network1: TMenuItem
      Caption = '&Network'
      GroupIndex = 20
      object Addnetwork1: TMenuItem
        Action = aNewNetwork
      end
      object Newserver1: TMenuItem
        Action = aNewServer
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object Connect1: TMenuItem
        Action = aConnect
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object Properties1: TMenuItem
        Action = aProperties
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Delete1: TMenuItem
        Action = aDelete
      end
    end
  end
  object ActionList1: TActionList
    Images = MainWin.ImageList1
    Left = 8
    Top = 8
    object aNewNetwork: TAction
      Category = 'Network'
      Caption = 'Add network...'
      ImageIndex = 31
      OnExecute = aNewNetworkExecute
    end
    object aNewServer: TAction
      Category = 'Network'
      Caption = 'Add server...'
      ImageIndex = 27
      OnExecute = aNewServerExecute
    end
    object aDelete: TAction
      Category = 'Network'
      Caption = 'Delete'
      ImageIndex = 15
      OnExecute = aDeleteExecute
    end
    object aProperties: TAction
      Category = 'Network'
      Caption = 'Properties...'
      ImageIndex = 33
      OnExecute = aPropertiesExecute
    end
    object aConnect: TAction
      Category = 'Network'
      Caption = 'Connect'
      ImageIndex = 25
      OnExecute = aConnectExecute
    end
  end
  object PopupMenu1: TPopupMenu
    Images = MainWin.ImageList1
    OnPopup = PopupMenu1Popup
    Left = 72
    Top = 8
    object Addnetwork2: TMenuItem
      Action = aNewNetwork
    end
    object Addserver1: TMenuItem
      Action = aNewServer
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object Connect2: TMenuItem
      Action = aConnect
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Delete2: TMenuItem
      Action = aDelete
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object Properties2: TMenuItem
      Action = aProperties
      Default = True
    end
  end
end
