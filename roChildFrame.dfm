object Frame1: TFrame1
  Left = 0
  Top = 0
  Width = 313
  Height = 251
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object cfPanMain: TPanel
    Left = 0
    Top = 0
    Width = 313
    Height = 251
    Align = alClient
    BorderWidth = 2
    TabOrder = 0
    DesignSize = (
      313
      251)
    object imgResize: TImage
      Left = 297
      Top = 235
      Width = 16
      Height = 16
      Anchors = [akRight, akBottom]
      Picture.Data = {
        07544269746D6170F6000000424DF60000000000000076000000280000001000
        000010000000010004000000000080000000C40E0000C40E0000100000000000
        0000000000000000800000800000008080008000000080008000808000008080
        8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
        FF00DDDDDDDDDDDDDDDDD00DD00DD00DDDDDDDD0DDD0DDD0DDDDDDDD0DDD0DDD
        0DDDDDDDD0DDD0DDD0DDDDDDDD0DDD0DDD0DDDDDDDD0DDD0DD0DDDDDDDDD0DDD
        0DDDDDDDDDDDD0DDD0DDDDDDDDDDDD0DDD0DDDDDDDDDDDD0DD0DDDDDDDDDDDDD
        0DDDDDDDDDDDDDDDD0DDDDDDDDDDDDDDDD0DDDDDDDDDDDDDDD0DDDDDDDDDDDDD
        DDDD}
      Transparent = True
      Visible = False
    end
    object cfPanHeader: TPanel
      Left = 3
      Top = 3
      Width = 307
      Height = 18
      Align = alTop
      BevelOuter = bvNone
      Color = clActiveCaption
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clCaptionText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      object cfIconImg: TImage
        Left = 2
        Top = 1
        Width = 16
        Height = 16
      end
      object cfPanCaption: TLabel
        Left = 22
        Top = 2
        Width = 63
        Height = 13
        Caption = 'ChildFrame'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clCaptionText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
  end
  object cfMainMenu: TMainMenu
    Images = MainWin.ImageList1
    Left = 8
    Top = 24
  end
  object cfActionList: TActionList
    Images = MainWin.ImageList1
    Left = 40
    Top = 24
  end
end
