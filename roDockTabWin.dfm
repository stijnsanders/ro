object DockTabWin: TDockTabWin
  Left = 340
  Top = 152
  Width = 238
  Height = 215
  Caption = 'Tabbed toolboxes'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDockOver = FormDockOver
  OnGetSiteInfo = FormGetSiteInfo
  OnResize = FormResize
  OnShow = FormShow
  DesignSize = (
    230
    188)
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 230
    Height = 188
    Align = alClient
    DockSite = True
    MultiLine = True
    PopupMenu = pm1
    TabOrder = 0
    OnDockOver = PageControl1DockOver
    OnGetSiteInfo = PageControl1GetSiteInfo
    OnUnDock = PageControl1UnDock
  end
  object Button1: TButton
    Left = 214
    Top = 0
    Width = 16
    Height = 16
    Anchors = [akTop, akRight]
    Caption = '...'
    PopupMenu = pm1
    TabOrder = 1
    OnClick = Button1Click
  end
  object pm1: TPopupMenu
    Left = 176
    Top = 8
    object Rename1: TMenuItem
      Caption = '&Rename...'
      OnClick = Rename1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Hide1: TMenuItem
      Caption = '&Hide'
      OnClick = Hide1Click
    end
  end
end
