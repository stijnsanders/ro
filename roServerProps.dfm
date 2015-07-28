object ServerPropWin: TServerPropWin
  Left = 307
  Top = 148
  Width = 354
  Height = 383
  Caption = 'Server properties'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Verdana'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  DesignSize = (
    338
    345)
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 42
    Height = 16
    Caption = '&Name:'
    FocusControl = aName
  end
  object Label2: TLabel
    Left = 8
    Top = 176
    Width = 71
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = '&Hostname:'
    FocusControl = aHost
  end
  object Label3: TLabel
    Left = 8
    Top = 216
    Width = 254
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = 'Default&port: (leave empty for random)'
    FocusControl = aPort
  end
  object Label4: TLabel
    Left = 8
    Top = 48
    Width = 79
    Height = 16
    Caption = '&Description:'
    FocusControl = aDescription
  end
  object Label5: TLabel
    Left = 8
    Top = 256
    Width = 206
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = '&Available ports: (use '#39','#39' and '#39'-'#39')'
    FocusControl = aPorts
  end
  object aName: TEdit
    Left = 8
    Top = 24
    Width = 313
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Text = 'aName'
  end
  object aHost: TEdit
    Left = 8
    Top = 192
    Width = 313
    Height = 24
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 2
    Text = 'aHost'
  end
  object aPort: TEdit
    Left = 8
    Top = 232
    Width = 313
    Height = 24
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 3
    Text = 'aPort'
  end
  object aDescription: TMemo
    Left = 8
    Top = 64
    Width = 313
    Height = 109
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'aDesription')
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object aPorts: TEdit
    Left = 8
    Top = 272
    Width = 313
    Height = 24
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 4
    Text = 'aPorts'
  end
  object btnOk: TButton
    Left = 136
    Top = 304
    Width = 89
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 5
  end
  object btnCancel: TButton
    Left = 232
    Top = 304
    Width = 89
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 6
  end
  object btnConnect: TButton
    Left = 8
    Top = 304
    Width = 89
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Connect'
    TabOrder = 7
    OnClick = btnConnectClick
  end
end
