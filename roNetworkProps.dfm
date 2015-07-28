object NetworkPropWin: TNetworkPropWin
  Left = 267
  Top = 149
  Width = 353
  Height = 383
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Network properties'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  DesignSize = (
    337
    345)
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 38
    Height = 16
    Caption = '&Name:'
    FocusControl = aName
  end
  object Label2: TLabel
    Left = 8
    Top = 48
    Width = 68
    Height = 16
    Caption = '&Description:'
    FocusControl = aDescription
  end
  object Label3: TLabel
    Left = 8
    Top = 136
    Width = 117
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = '&Preferred nickname:'
    FocusControl = aNick
  end
  object Label4: TLabel
    Left = 8
    Top = 176
    Width = 264
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = '&Alternate nicknames: (seperate with space '#39' '#39')'
    FocusControl = aAltNick
  end
  object Label5: TLabel
    Left = 8
    Top = 216
    Width = 113
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = '&Full name (or URL):'
    FocusControl = aFullName
  end
  object Label6: TLabel
    Left = 8
    Top = 256
    Width = 167
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = 'E-mail address (login@host):'
    FocusControl = aEmail
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
  object aDescription: TMemo
    Left = 8
    Top = 64
    Width = 313
    Height = 69
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'aDescription')
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object aNick: TEdit
    Left = 8
    Top = 152
    Width = 305
    Height = 24
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 2
    Text = 'aNick'
  end
  object aAltNick: TEdit
    Left = 8
    Top = 192
    Width = 313
    Height = 24
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 3
    Text = 'aAltNick'
  end
  object aFullName: TEdit
    Left = 8
    Top = 232
    Width = 313
    Height = 24
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 4
    Text = 'aFullName'
  end
  object aEmail: TEdit
    Left = 8
    Top = 272
    Width = 313
    Height = 24
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 5
    Text = 'aEmail'
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
    TabOrder = 7
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
    TabOrder = 8
  end
  object btnConnect: TButton
    Left = 8
    Top = 304
    Width = 89
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Connect'
    TabOrder = 6
    OnClick = btnConnectClick
  end
end
