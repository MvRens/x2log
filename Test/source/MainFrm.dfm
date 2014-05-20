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
    Top = 169
    Width = 595
    Height = 305
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    ActivePage = tsEvent
    Align = alClient
    TabOrder = 0
    OnChange = pcObserversChange
    ExplicitTop = 113
    ExplicitHeight = 361
    object tsEvent: TTabSheet
      Caption = 'Event Observer '
      ExplicitHeight = 333
      object mmoEvent: TMemo
        AlignWithMargins = True
        Left = 8
        Top = 8
        Width = 571
        Height = 261
        Margins.Left = 8
        Margins.Top = 8
        Margins.Right = 8
        Margins.Bottom = 8
        Align = alClient
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
        ExplicitHeight = 317
      end
    end
    object tsFile: TTabSheet
      Caption = 'File Observer'
      ImageIndex = 1
      ExplicitHeight = 333
    end
    object tsNamedPipe: TTabSheet
      Caption = 'Named Pipe Observer'
      ImageIndex = 2
      ExplicitHeight = 333
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
      TabOrder = 1
      OnClick = btnCloseClick
    end
    object btnMonitorForm: TButton
      Left = 0
      Top = 0
      Width = 145
      Height = 25
      Align = alLeft
      Cancel = True
      Caption = 'Monitor Form Observer'
      TabOrder = 0
      OnClick = btnMonitorFormClick
    end
  end
  object GroupBox1: TGroupBox
    AlignWithMargins = True
    Left = 8
    Top = 8
    Width = 595
    Height = 153
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 0
    Align = alTop
    Caption = ' Dispatch '
    TabOrder = 2
    DesignSize = (
      595
      153)
    object lblMessage: TLabel
      Left = 16
      Top = 32
      Width = 46
      Height = 13
      Caption = 'Message:'
    end
    object lblException: TLabel
      Left = 16
      Top = 99
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
    object btnVerbose: TButton
      Left = 92
      Top = 56
      Width = 75
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Verbose'
      TabOrder = 1
      OnClick = btnLogClick
    end
    object edtException: TEdit
      Left = 92
      Top = 96
      Width = 402
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      Text = 'Horrible things are happening.'
      OnKeyDown = edtExceptionKeyDown
    end
    object btnException: TButton
      Left = 92
      Top = 123
      Width = 75
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Caption = '&Send'
      TabOrder = 3
      OnClick = btnExceptionClick
    end
    object btnInfo: TButton
      Left = 173
      Top = 56
      Width = 75
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Info'
      TabOrder = 4
      OnClick = btnLogClick
    end
    object btnWarning: TButton
      Left = 254
      Top = 56
      Width = 75
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Warning'
      TabOrder = 5
      OnClick = btnLogClick
    end
    object btnError: TButton
      Left = 335
      Top = 56
      Width = 75
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Error'
      TabOrder = 6
      OnClick = btnLogClick
    end
  end
end
