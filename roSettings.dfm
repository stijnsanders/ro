object SetsWin: TSetsWin
  Left = 341
  Top = 118
  Width = 425
  Height = 391
  Caption = 'Settings'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  DesignSize = (
    409
    353)
  PixelsPerInch = 96
  TextHeight = 16
  object Button1: TButton
    Left = 208
    Top = 312
    Width = 89
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object Button2: TButton
    Left = 304
    Top = 312
    Width = 89
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object panWeb: TPanel
    Left = 8
    Top = 8
    Width = 385
    Height = 297
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 2
    object Web1: TRestrictedWebBrowser
      Left = 0
      Top = 0
      Width = 385
      Height = 297
      Align = alClient
      TabOrder = 0
      ControlData = {
        4C000000CA270000B21E00000000000000000000000000000000000000000000
        000000004C000000000000000000000001000000E0D057007335CF11AE690800
        2B2E126208000000000000004C0000000114020000000000C000000000000046
        8000000000000000000000000000000000000000000000000000000000000000
        00000000000000000100000000000000000000000000000000000000}
    end
  end
end
