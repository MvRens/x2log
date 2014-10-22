object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'X'#178'Log Test'
  ClientHeight = 544
  ClientWidth = 647
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
    Top = 176
    Width = 631
    Height = 327
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    ActivePage = tsNamedPipe
    Align = alClient
    Images = ilsObservers
    TabOrder = 0
    ExplicitWidth = 595
    object tsEvent: TTabSheet
      Caption = 'Event'
      ExplicitWidth = 587
      object mmoEvent: TMemo
        AlignWithMargins = True
        Left = 8
        Top = 40
        Width = 607
        Height = 251
        Margins.Left = 8
        Margins.Top = 40
        Margins.Right = 8
        Margins.Bottom = 8
        Align = alClient
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
        ExplicitWidth = 571
      end
      object btnEventStart: TButton
        Left = 8
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Start'
        TabOrder = 1
        OnClick = btnEventStartClick
      end
      object btnEventStop: TButton
        Left = 89
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Stop'
        TabOrder = 2
        OnClick = btnEventStopClick
      end
    end
    object tsFile: TTabSheet
      Caption = 'File'
      ExplicitWidth = 587
      DesignSize = (
        623
        299)
      object lblFilename: TLabel
        Left = 12
        Top = 64
        Width = 46
        Height = 13
        Caption = 'Filename:'
      end
      object btnFileStart: TButton
        Left = 8
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Start'
        TabOrder = 0
        OnClick = btnFileStartClick
      end
      object btnFileStop: TButton
        Left = 89
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Stop'
        TabOrder = 1
        OnClick = btnFileStopClick
      end
      object edtFilename: TEdit
        Left = 88
        Top = 61
        Width = 525
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 2
        Text = 'X2LogTest\Test.log'
      end
      object rbProgramData: TRadioButton
        Left = 88
        Top = 88
        Width = 113
        Height = 17
        Caption = 'Program Data'
        Checked = True
        TabOrder = 3
        TabStop = True
      end
      object rbUserData: TRadioButton
        Left = 88
        Top = 111
        Width = 113
        Height = 17
        Caption = 'User Application Data'
        TabOrder = 4
      end
      object rbAbsolute: TRadioButton
        Left = 88
        Top = 134
        Width = 113
        Height = 17
        Caption = 'Absolute path'
        TabOrder = 5
      end
    end
    object tsNamedPipe: TTabSheet
      Caption = 'Named Pipe'
      ExplicitWidth = 587
      DesignSize = (
        623
        299)
      object lblPipeName: TLabel
        Left = 8
        Top = 64
        Width = 53
        Height = 13
        Caption = 'Pipe name:'
      end
      object lblNamedPipeServers: TLabel
        Left = 8
        Top = 108
        Width = 73
        Height = 13
        Caption = 'Active servers:'
      end
      object btnNamedPipeStart: TButton
        Left = 8
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Start'
        TabOrder = 0
        OnClick = btnNamedPipeStartClick
      end
      object btnNamedPipeStop: TButton
        Left = 89
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Stop'
        TabOrder = 1
        OnClick = btnNamedPipeStopClick
      end
      object edtPipeName: TEdit
        Left = 88
        Top = 61
        Width = 525
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 2
        Text = 'X2LogTest'
      end
      object btnNamedPipeRefresh: TButton
        Left = 538
        Top = 96
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = '&Refresh'
        TabOrder = 3
        OnClick = btnNamedPipeRefreshClick
        ExplicitLeft = 502
      end
      object lbNamedPipeServers: TListBox
        Left = 8
        Top = 132
        Width = 605
        Height = 157
        Anchors = [akLeft, akTop, akRight, akBottom]
        ItemHeight = 13
        TabOrder = 4
        ExplicitWidth = 569
      end
    end
  end
  object pnlButtons: TPanel
    AlignWithMargins = True
    Left = 8
    Top = 511
    Width = 631
    Height = 25
    Margins.Left = 8
    Margins.Top = 0
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 595
    object btnClose: TButton
      Left = 556
      Top = 0
      Width = 75
      Height = 25
      Align = alRight
      Cancel = True
      Caption = 'Close'
      TabOrder = 1
      OnClick = btnCloseClick
      ExplicitLeft = 520
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
    object btnLock: TButton
      AlignWithMargins = True
      Left = 151
      Top = 0
      Width = 64
      Height = 25
      Margins.Left = 6
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alLeft
      Cancel = True
      Caption = 'Lock'
      TabOrder = 2
      OnClick = btnLockClick
    end
    object btnUnlock: TButton
      AlignWithMargins = True
      Left = 221
      Top = 0
      Width = 64
      Height = 25
      Margins.Left = 6
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alLeft
      Cancel = True
      Caption = 'Unlock'
      TabOrder = 3
      OnClick = btnUnlockClick
    end
  end
  object pcDispatch: TPageControl
    AlignWithMargins = True
    Left = 8
    Top = 32
    Width = 631
    Height = 104
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 0
    ActivePage = tsTimer
    Align = alTop
    TabOrder = 2
    ExplicitWidth = 595
    object tsText: TTabSheet
      Caption = 'Text'
      ExplicitWidth = 587
      DesignSize = (
        623
        76)
      object lblMessage: TLabel
        Left = 16
        Top = 15
        Width = 46
        Height = 13
        Caption = 'Message:'
      end
      object btnError: TButton
        Left = 335
        Top = 39
        Width = 75
        Height = 21
        Caption = 'Error'
        TabOrder = 0
        OnClick = btnLogClick
      end
      object btnInfo: TButton
        Left = 173
        Top = 39
        Width = 75
        Height = 21
        Caption = 'Info'
        TabOrder = 1
        OnClick = btnLogClick
      end
      object btnVerbose: TButton
        Left = 92
        Top = 39
        Width = 75
        Height = 21
        Caption = 'Verbose'
        TabOrder = 2
        OnClick = btnLogClick
      end
      object btnWarning: TButton
        Left = 254
        Top = 39
        Width = 75
        Height = 21
        Caption = 'Warning'
        TabOrder = 3
        OnClick = btnLogClick
      end
      object edtMessage: TEdit
        Left = 92
        Top = 12
        Width = 513
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 4
        Text = 'Hello world!'
        OnKeyDown = edtMessageKeyDown
        ExplicitWidth = 477
      end
      object btnCategory: TButton
        Left = 416
        Top = 39
        Width = 101
        Height = 21
        Caption = 'With category'
        TabOrder = 5
        OnClick = btnCategoryClick
      end
    end
    object tsException: TTabSheet
      Caption = 'Exception'
      ImageIndex = 1
      ExplicitWidth = 587
      DesignSize = (
        623
        76)
      object lblException: TLabel
        Left = 16
        Top = 15
        Width = 51
        Height = 13
        Caption = 'Exception:'
      end
      object btnException: TButton
        Left = 92
        Top = 39
        Width = 75
        Height = 21
        Caption = '&Send'
        TabOrder = 0
        OnClick = btnExceptionClick
      end
      object edtException: TEdit
        Left = 92
        Top = 12
        Width = 513
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
        Text = 'Horrible things are happening.'
        OnKeyDown = edtExceptionKeyDown
        ExplicitWidth = 477
      end
    end
    object tsBinary: TTabSheet
      Caption = 'Binary'
      ImageIndex = 2
      ExplicitWidth = 587
      object btnBinaryRawByteString: TButton
        Left = 12
        Top = 15
        Width = 152
        Height = 21
        Caption = 'Binary (RawByteString)'
        TabOrder = 0
        OnClick = btnBinaryRawByteStringClick
      end
      object btnGraphic: TButton
        Left = 170
        Top = 15
        Width = 79
        Height = 21
        Caption = 'Graphic'
        TabOrder = 1
        OnClick = btnGraphicClick
      end
    end
    object tsTimer: TTabSheet
      Caption = 'Timer'
      ImageIndex = 3
      ExplicitWidth = 587
      object lblTimer: TLabel
        Left = 8
        Top = 12
        Width = 580
        Height = 13
        Caption = 
          'Send out a series of log messages at regular intervals. Tests an' +
          ' issue with the thread queue in the named pipe observer.'
      end
      object lblInterval: TLabel
        Left = 8
        Top = 43
        Width = 92
        Height = 13
        Caption = 'Interval (seconds):'
      end
      object edtInterval: TEdit
        Left = 130
        Top = 40
        Width = 89
        Height = 21
        TabOrder = 0
        Text = '1'
      end
      object btnTimerStart: TButton
        Left = 228
        Top = 38
        Width = 75
        Height = 25
        Caption = 'Start'
        TabOrder = 1
        OnClick = btnTimerStartClick
      end
      object btnTimerStop: TButton
        Left = 309
        Top = 38
        Width = 75
        Height = 25
        Caption = 'Stop'
        Enabled = False
        TabOrder = 2
        OnClick = btnTimerStopClick
      end
    end
  end
  object pnlDispatch: TPanel
    AlignWithMargins = True
    Left = 8
    Top = 0
    Width = 631
    Height = 24
    Margins.Left = 8
    Margins.Top = 0
    Margins.Right = 8
    Margins.Bottom = 0
    Align = alTop
    Alignment = taLeftJustify
    BevelOuter = bvNone
    Caption = 'Dispatch'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    ExplicitWidth = 595
    object bvlDispatch: TBevel
      Left = 80
      Top = 12
      Width = 513
      Height = 9
      Shape = bsTopLine
    end
  end
  object pnlObservers: TPanel
    AlignWithMargins = True
    Left = 8
    Top = 144
    Width = 631
    Height = 24
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 0
    Align = alTop
    Alignment = taLeftJustify
    BevelOuter = bvNone
    Caption = 'Observers'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    ExplicitWidth = 595
    object bvlObservers: TBevel
      Left = 80
      Top = 12
      Width = 513
      Height = 9
      Shape = bsTopLine
    end
  end
  object ilsObservers: TImageList
    Height = 12
    Width = 12
    Left = 552
    Top = 176
    Bitmap = {
      494C01010200140054000C000C00FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000300000000C00000001002000000000000009
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000788D
      F400274DEA00274DEA001C41E5001C37D8007380E20000000000000000000000
      000000000000000000000000000074C97D001EA7330017A83000139F29001695
      220071BB76000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000004C6EF7003C6B
      FF003C6BFF003162FF003162FF002855F5001B3EE1003C4FD700000000000000
      0000000000000000000043BE560028C1520026BF4F0026BF4F0021BA44001BB0
      3800139F290039A0400000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000819BFD004876FF004674
      FF004674FF004674FF003C6BFF003162FF002D5CFC001B3EE1007380E2000000
      0000000000007CD58B0030C9610030C961002FC85F0028C1520028C1520026BF
      4F001BB03800139F290071BB7600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000517EFE005484FF005484
      FF005484FF004B79FF004674FF004674FF003162FF002855F5001D38D8000000
      00000000000046CC6A0038D16B0038D16B0038D16B0036CE690030C9610028C1
      520028C152001BB0380016952200000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000749EFF006295FF006295
      FF006295FF005B8CFF005484FF004674FF004674FF003162FF001C41E5000000
      0000000000005CDC850041DA740041DA740041DA740038D16B0038D16B0030C9
      610028C1520021BA4400139F2900000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000089B1FF0071A6FF0071A6
      FF006DA2FF006599FF005B8CFF005484FF004674FF003C6BFF00274DEA000000
      0000000000006EE5940049E27C0049E27C0049E27C0041DA740041DA740038D1
      6B0030C9610028C152001BB03800000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000007CA7FF008EBFFF0080B8
      FF007AB2FF0071A6FF006295FF005B8CFF004674FF003C6BFF00294EEA000000
      00000000000067E28D0067EE940053EC860053EC860049E27C0041DA740038D1
      6B0030C9610028C152001EA73300000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000009FBCFF00ADD6FF0091CB
      FF0080B8FF007AB2FF006A9FFF005D90FF004B79FF004674FF00788DF4000000
      00000000000095EAAF008AF6AE0061F5920056EF89004EE7810046DF790041DA
      740036CE69002CC55A0074C97D00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000089B1FF00B4DF
      FF0091CBFF007AB2FF006DA2FF006295FF00517EFE004876FF00000000000000
      0000000000000000000079E99D008EFBB20068F396004FE9830047E07A003DD6
      700036CE690046C45D0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000A3C0
      FF0089B1FF008EBFFF007CA7FF005484FF00819BFD0000000000000000000000
      000000000000000000000000000099EEB3006EE5940070E998005CE1870048D1
      6F0081DB93000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      28000000300000000C0000000100010000000000600000000000000000000000
      000000000000000000000000FFFFFF00FFFFFF0000000000E07E070000000000
      C03C030000000000801801000000000080180100000000008018010000000000
      801801000000000080180100000000008018010000000000C03C030000000000
      E07E070000000000FFFFFF000000000000000000000000000000000000000000
      000000000000}
  end
  object Timer: TTimer
    Enabled = False
    Interval = 10000
    OnTimer = TimerTimer
    Left = 464
    Top = 176
  end
end
