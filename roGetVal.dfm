object GetValWin: TGetValWin
  Left = 269
  Top = 166
  Width = 321
  Height = 103
  BorderIcons = [biMinimize, biMaximize]
  Caption = 'GetValWin'
  Color = clBtnFace
  Constraints.MaxHeight = 103
  Constraints.MinHeight = 103
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  DesignSize = (
    305
    65)
  PixelsPerInch = 96
  TextHeight = 16
  object Val: TEdit
    Left = 8
    Top = 8
    Width = 289
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Text = 'Val'
  end
  object Button1: TButton
    Left = 112
    Top = 32
    Width = 89
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 208
    Top = 32
    Width = 89
    Height = 25
    Anchors = [akTop, akRight]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
