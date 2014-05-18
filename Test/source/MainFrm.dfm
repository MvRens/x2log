object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'X'#178'Log Test'
  ClientHeight = 515
  ClientWidth = 611
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pcObservers: TPageControl
    AlignWithMargins = True
    Left = 8
    Top = 113
    Width = 595
    Height = 361
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    ActivePage = tsNamedPipe
    Align = alClient
    TabOrder = 0
    OnChange = pcObserversChange
    object tsEvent: TTabSheet
      Caption = 'Event Observer '
      object mmoEvent: TMemo
        AlignWithMargins = True
        Left = 8
        Top = 8
        Width = 571
        Height = 317
        Margins.Left = 8
        Margins.Top = 8
        Margins.Right = 8
        Margins.Bottom = 8
        Align = alClient
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object tsFile: TTabSheet
      Caption = 'File Observer'
      ImageIndex = 1
    end
    object tsNamedPipe: TTabSheet
      Caption = 'Named Pipe Observer'
      ImageIndex = 2
    end
  end
  object pnlButtons: TPanel
    AlignWithMargins = True
    Left = 8
    Top = 482
    Width = 595
    Height = 25
    Margins.Left = 8
    Margins.Top = 0
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnClose: TButton
      Left = 520
      Top = 0
      Width = 75
      Height = 25
      Align = alRight
      Cancel = True
      Caption = 'Close'
      TabOrder = 0
    end
  end
  object GroupBox1: TGroupBox
    AlignWithMargins = True
    Left = 8
    Top = 8
    Width = 595
    Height = 97
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 0
    Align = alTop
    Caption = ' Dispatch '
    TabOrder = 2
    DesignSize = (
      595
      97)
    object lblMessage: TLabel
      Left = 16
      Top = 32
      Width = 46
      Height = 13
      Caption = 'Message:'
    end
    object lblException: TLabel
      Left = 16
      Top = 59
      Width = 51
      Height = 13
      Caption = 'Exception:'
    end
    object edtMessage: TEdit
      Left = 92
      Top = 29
      Width = 402
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = 'Hello world!'
      OnKeyDown = edtMessageKeyDown
    end
    object btnSend: TButton
      Left = 500
      Top = 29
      Width = 75
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Caption = '&Send'
      TabOrder = 1
      OnClick = btnSendClick
    end
    object edtException: TEdit
      Left = 92
      Top = 56
      Width = 402
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      Text = 'Horrible things are happening.'
      OnKeyDown = edtExceptionKeyDown
    end
    object btnException: TButton
      Left = 500
      Top = 56
      Width = 75
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Caption = '&Send'
      TabOrder = 3
      OnClick = btnExceptionClick
    end
  end
end
