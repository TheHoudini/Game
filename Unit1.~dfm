object Form1: TForm1
  Left = 228
  Top = 118
  Width = 613
  Height = 865
  Anchors = [akLeft, akBottom]
  Caption = 'Game'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  OnPaint = FormPaint
  OnResize = FormResize
  OnShortCut = FormShortCut
  DesignSize = (
    597
    826)
  PixelsPerInch = 96
  TextHeight = 13
  object log: TMemo
    Left = 48
    Top = 712
    Width = 521
    Height = 33
    Anchors = [akBottom]
    Enabled = False
    Lines.Strings = (
      'log')
    TabOrder = 0
  end
  object lblScore: TLabeledEdit
    Left = 48
    Top = 760
    Width = 121
    Height = 21
    Anchors = [akBottom]
    EditLabel.Width = 38
    EditLabel.Height = 13
    EditLabel.Caption = 'lblScore'
    Enabled = False
    TabOrder = 1
  end
  object btnConvAdd: TBitBtn
    Left = 168
    Top = 760
    Width = 75
    Height = 25
    Anchors = [akBottom]
    Caption = 'Add Conv'
    TabOrder = 2
    OnClick = btnConvAddClick
  end
  object btnConvRem: TButton
    Left = 168
    Top = 784
    Width = 75
    Height = 25
    Anchors = [akBottom]
    Caption = 'Remove Conv'
    TabOrder = 3
    OnClick = btnConvRemClick
  end
  object btnIncSpeed: TButton
    Left = 264
    Top = 760
    Width = 75
    Height = 25
    Caption = 'Inc Speed'
    TabOrder = 4
    OnClick = btnIncSpeedClick
  end
  object Button1: TButton
    Left = 264
    Top = 784
    Width = 75
    Height = 25
    Caption = 'Dec Speed'
    TabOrder = 5
    OnClick = Button1Click
  end
  object RefreshTimer: TTimer
    Interval = 10
    OnTimer = RefreshTimerTimer
  end
  object Generator: TTimer
    Interval = 200
    OnTimer = GeneratorTimer
    Left = 32
  end
end
