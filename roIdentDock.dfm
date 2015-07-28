inherited IdentDock: TIdentDock
  Left = 707
  Top = 198
  Caption = 'identd listener (port 113)'
  OldCreateOrder = True
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 16
  object Web1: TRestrictedWebBrowser
    Left = 0
    Top = 0
    Width = 296
    Height = 180
    Align = alClient
    TabOrder = 0
    OnBeforeNavigate2 = Web1BeforeNavigate2
    OnDocumentComplete = Web1DocumentComplete
    ControlData = {
      4C000000981E00009B1200000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object PopupMenu1: TPopupMenu
    Images = MainWin.ImageList1
    Left = 8
    Top = 8
    object StartStopserver1: TMenuItem
      Action = aListen
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object imetags1: TMenuItem
      Action = aTTime
    end
    object Wordwrap1: TMenuItem
      Action = aWordWrap
    end
  end
  object ActionList1: TActionList
    Images = MainWin.ImageList1
    Left = 40
    Top = 8
    object aListen: TAction
      Caption = 'Start server'
      OnExecute = aListenExecute
    end
    object aTTime: TAction
      Caption = 'Time tags'
      ImageIndex = 34
      OnExecute = aTTimeExecute
    end
    object aWordWrap: TAction
      Caption = 'Word wrap'
      OnExecute = aWordWrapExecute
    end
  end
end
