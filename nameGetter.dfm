object Form3: TForm3
  Left = 803
  Top = 327
  Width = 235
  Height = 149
  Caption = 'Name'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object StaticText1: TStaticText
    Left = 64
    Top = 16
    Width = 83
    Height = 17
    Caption = 'Pls enter u name'
    TabOrder = 0
  end
  object Edit1: TEdit
    Left = 48
    Top = 40
    Width = 121
    Height = 21
    TabOrder = 1
  end
  object Button1: TButton
    Left = 64
    Top = 72
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 2
    OnClick = Button1Click
  end
end
