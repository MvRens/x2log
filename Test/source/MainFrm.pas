unit MainFrm;

interface
uses
  System.Classes,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.ImgList,
  Vcl.StdCtrls,

  X2Log.Intf;

  
type
  TMainForm = class(TForm)
    btnClose: TButton;
    btnVerbose: TButton;
    edtMessage: TEdit;
    lblMessage: TLabel;
    mmoEvent: TMemo;
    pcObservers: TPageControl;
    pnlButtons: TPanel;
    tsEvent: TTabSheet;
    tsFile: TTabSheet;
    lblException: TLabel;
    edtException: TEdit;
    btnException: TButton;
    tsNamedPipe: TTabSheet;
    btnMonitorForm: TButton;
    btnInfo: TButton;
    btnWarning: TButton;
    btnError: TButton;
    btnEventStart: TButton;
    btnEventStop: TButton;
    ilsObservers: TImageList;
    btnFileStart: TButton;
    btnFileStop: TButton;
    btnNamedPipeStart: TButton;
    btnNamedPipeStop: TButton;
    edtFilename: TEdit;
    lblFilename: TLabel;
    rbProgramData: TRadioButton;
    rbUserData: TRadioButton;
    rbAbsolute: TRadioButton;
    edtPipeName: TEdit;
    lblPipeName: TLabel;
    btnBinaryRawByteString: TButton;
    pcDispatch: TPageControl;
    tsText: TTabSheet;
    tsException: TTabSheet;
    tsBinary: TTabSheet;
    pnlDispatch: TPanel;
    bvlDispatch: TBevel;
    pnlObservers: TPanel;
    bvlObservers: TBevel;
    btnGraphic: TButton;
    lblNamedPipeServers: TLabel;
    btnNamedPipeRefresh: TButton;
    lbNamedPipeServers: TListBox;
    btnLock: TButton;
    btnUnlock: TButton;
    btnCategory: TButton;
    tsTimer: TTabSheet;
    lblTimer: TLabel;
    lblInterval: TLabel;
    edtInterval: TEdit;
    btnTimerStart: TButton;
    btnTimerStop: TButton;
    Timer: TTimer;
    tsRollingFile: TTabSheet;
    lblRollingFileName: TLabel;
    btnRollingFileStart: TButton;
    btnRollingFileStop: TButton;
    edtRollingFileName: TEdit;
    rbRollingProgramData: TRadioButton;
    rbRollingUserData: TRadioButton;
    rbRollingAbsolute: TRadioButton;
    lblRollingDays: TLabel;
    edtRollingDays: TEdit;
    tsStructured: TTabSheet;
    btnValueTypes: TButton;
    pnlFileTextFormatter: TPanel;
    rbFileTextFormatterDefault: TRadioButton;
    rbFileTextFormatterJson: TRadioButton;
    pnlRollingFileTextFormatter: TPanel;
    rbRollingFileTextFormatterDefault: TRadioButton;
    rbRollingFileTextFormatterJson: TRadioButton;
    btnStructuredException: TButton;
    
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnLogClick(Sender: TObject);
    procedure edtExceptionKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtMessageKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnExceptionClick(Sender: TObject);
    procedure btnMonitorFormClick(Sender: TObject);
    procedure btnLockClick(Sender: TObject);
    procedure btnUnlockClick(Sender: TObject);
    procedure btnEventStartClick(Sender: TObject);
    procedure btnEventStopClick(Sender: TObject);
    procedure btnFileStartClick(Sender: TObject);
    procedure btnFileStopClick(Sender: TObject);
    procedure btnNamedPipeStartClick(Sender: TObject);
    procedure btnNamedPipeStopClick(Sender: TObject);
    procedure btnBinaryRawByteStringClick(Sender: TObject);
    procedure btnGraphicClick(Sender: TObject);
    procedure btnNamedPipeRefreshClick(Sender: TObject);
    procedure btnCategoryClick(Sender: TObject);
    procedure btnTimerStartClick(Sender: TObject);
    procedure btnTimerStopClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure btnRollingFileStartClick(Sender: TObject);
    procedure btnRollingFileStopClick(Sender: TObject);
    procedure btnValueTypesClick(Sender: TObject);
    procedure btnStructuredExceptionClick(Sender: TObject);
  private
    FLog: IX2Log;
    FEventObserver: IX2LogObserver;
    FFileObserver: IX2LogObserver;
    FRollingFileObserver: IX2LogObserver;
    FNamedPipeObserver: IX2LogObserver;
  protected
    procedure DoLog(Sender: TObject; Level: TX2LogLevel; DateTime: TDateTime; const Msg, Category: string; Details: IX2LogDetails);
  end;


implementation
uses
  System.SysUtils,
  Vcl.Imaging.Jpeg,
  Winapi.Windows,

  X2Log,
  X2Log.Client.NamedPipe,
  X2Log.Constants,
  X2Log.Details.Default,
  X2Log.Details.Intf,
  X2Log.Exception.madExceptHandler,
  X2Log.Observer.Event,
  X2Log.Observer.LogFile,
  X2Log.Observer.MonitorForm,
  X2Log.Observer.NamedPipe,
  X2Log.Observer.RollingLogFile,
  X2Log.TextFormatter.Intf,
  X2Log.TextFormatter.Json,
  X2Log.Global;


{$R *.dfm}


{ TMainForm }
procedure TMainForm.FormCreate(Sender: TObject);
begin
  { Testing the localization (Dutch) }
  SetLogResourceString(@LogLevelVerbose, 'Uitgebreid');
  SetLogResourceString(@LogLevelInfo, 'Informatie');
  SetLogResourceString(@LogLevelWarning, 'Waarschuwing');
  SetLogResourceString(@LogLevelError, 'Fout');

  SetLogResourceString(@LogMonitorFormColumnTime, 'Tijd');
  SetLogResourceString(@LogMonitorFormColumnMessage, 'Melding');

  SetLogResourceString(@LogMonitorFormButtonClear, 'Wissen');
  SetLogResourceString(@LogMonitorFormButtonPause, 'Pauzeren');
  SetLogResourceString(@LogMonitorFormButtonCopyDetails, 'Kopieren');
  SetLogResourceString(@LogMonitorFormButtonSaveDetails, 'Opslaan');
  SetLogResourceString(@LogMonitorFormStatusPaused, 'Gepauzeerd: %d melding(en) overgeslagen');

  SetLogResourceString(@LogMonitorFormSaveDetailsFilter, 'Alle bestanden (*.*)|*.*');

  FLog := TX2Log.Create;
  FLog.SetExceptionStrategy(TX2LogmadExceptExceptionStrategy.Create);

  pcDispatch.ActivePageIndex := 0;
  pcObservers.ActivePageIndex := 0;

  DefaultMaxEntries := 10;
end;


procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FLog := nil;
end;


procedure TMainForm.DoLog(Sender: TObject; Level: TX2LogLevel; DateTime: TDateTime; const Msg, Category: string; Details: IX2LogDetails);
var
  text: string;
  logDetailsText: IX2LogDetailsText;

begin
  text := GetLogLevelText(Level) + ': ' + Category + ': ' + Msg;

  if Supports(Details, IX2LogDetailsText, logDetailsText) then
    text := text + ' (' + logDetailsText.AsString + ')';

  mmoEvent.Lines.Add(text);
end;


procedure TMainForm.edtMessageKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    btnException.Click;
    Key := 0;
  end;
end;


procedure TMainForm.edtExceptionKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    btnException.Click;
    Key := 0;
  end;
end;


procedure TMainForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;


procedure TMainForm.btnLogClick(Sender: TObject);
begin
  if Sender = btnVerbose then
    FLog.Verbose(edtMessage.Text)
  else if Sender = btnInfo then
    FLog.Info(edtMessage.Text)
  else if Sender = btnWarning then
    FLog.Warning(edtMessage.Text)
  else if Sender = btnError then
    FLog.Error(edtMessage.Text);
end;


procedure TMainForm.btnBinaryRawByteStringClick(Sender: TObject);
begin
  FLog.InfoEx(edtMessage.Text, TX2LogBinaryDetails.Create(#0#1#2#3'Test'#12'Some more data'));
end;


procedure TMainForm.btnGraphicClick(Sender: TObject);
var
  graphic: TJPEGImage;
  resourceStream: TResourceStream;

begin
  graphic := TJPEGImage.Create;
  try
    resourceStream := TResourceStream.Create(SysInit.HInstance, 'GraphicDetails', RT_RCDATA);
    try
      graphic.LoadFromStream(resourceStream);
    finally
      FreeAndNil(resourceStream);
    end;

    FLog.InfoEx('Graphic', TX2LogGraphicDetails.Create(graphic));
  finally
    FreeAndNil(graphic);
  end;
end;


procedure TMainForm.btnExceptionClick(Sender: TObject);
begin
  try
    { Throw an actual exception, don't just create it, to allow
      strategies like madExcept to do their stack trace }
    raise EAbort.Create(edtException.Text);
  except
    on E:Exception do
      FLog.Exception(E);
  end;
end;


procedure TMainForm.btnCategoryClick(Sender: TObject);

  procedure Category2(ALog: IX2Log);
  begin
    ALog.Info(edtMessage.Text);
  end;


  procedure Category1(ALog: IX2Log);
  begin
    ALog.Info('Category 1');
    Category2(ALog.Category('Sub-category'));
    ALog.Info('/Category 1');
  end;


begin
  FLog.Info('Categories');
  Category1(FLog.Category('Test'));
  FLog.Info('/Categories');
end;


procedure TMainForm.btnMonitorFormClick(Sender: TObject);
begin
  TX2LogObserverMonitorForm.ShowInstance(FLog);
end;


procedure TMainForm.btnLockClick(Sender: TObject);
begin
  TX2LogObserverMonitorForm.LockInstance(FLog);
end;


procedure TMainForm.btnUnlockClick(Sender: TObject);
begin
  TX2LogObserverMonitorForm.UnlockInstance(FLog);
end;


procedure TMainForm.btnEventStartClick(Sender: TObject);
begin
  if not Assigned(FEventObserver) then
  begin
    FEventObserver := TX2LogEventObserver.Create(DoLog);
    FLog.Attach(FEventObserver);

    tsEvent.ImageIndex := 1;
  end;
end;


procedure TMainForm.btnEventStopClick(Sender: TObject);
begin
  if Assigned(FEventObserver) then
  begin
    FLog.Detach(FEventObserver);
    FEventObserver := nil;

    tsEvent.ImageIndex := 0;
  end;
end;


procedure TMainForm.btnFileStartClick(Sender: TObject);
var
  textFormatter: IX2LogTextFormatter;

begin
  if not Assigned(FFileObserver) then
  begin
    textFormatter := nil;
    if rbFileTextFormatterJson.Checked then
      textFormatter := TX2LogJsonTextFormatter.Create;

    if rbProgramData.Checked then
      FFileObserver := TX2LogFileObserver.CreateInProgramData(edtFilename.Text, X2LogLevelsDefault, True, textFormatter)
    else if rbUserData.Checked then
      FFileObserver := TX2LogFileObserver.CreateInUserAppData(edtFilename.Text, X2LogLevelsDefault, True, textFormatter)
    else
      FFileObserver := TX2LogFileObserver.Create(edtFilename.Text, X2LogLevelsDefault, True, textFormatter);

    FLog.Attach(FFileObserver);

    tsFile.ImageIndex := 1;
  end;
end;


procedure TMainForm.btnFileStopClick(Sender: TObject);
begin
  if Assigned(FFileObserver) then
  begin
    FLog.Detach(FFileObserver);
    FFileObserver := nil;

    tsFile.ImageIndex := 0;
  end;
end;


procedure TMainForm.btnRollingFileStartClick(Sender: TObject);
var
  days: Integer;
  textFormatter: IX2LogTextFormatter;

begin
  if not Assigned(FRollingFileObserver) then
  begin
    textFormatter := nil;
    if rbFileTextFormatterJson.Checked then
      textFormatter := TX2LogJsonTextFormatter.Create;

    days := StrToIntDef(edtRollingDays.Text, 7);

    if rbRollingProgramData.Checked then
      FRollingFileObserver := TX2RollingLogFileObserver.CreateInProgramData(edtFilename.Text, days, X2LogLevelsDefault, True, textFormatter)
    else if rbRollingUserData.Checked then
      FRollingFileObserver := TX2RollingLogFileObserver.CreateInUserAppData(edtFilename.Text, days, X2LogLevelsDefault, True, textFormatter)
    else
      FRollingFileObserver := TX2RollingLogFileObserver.Create(edtFilename.Text, days, X2LogLevelsDefault, True, textFormatter);

    FLog.Attach(FRollingFileObserver);

    tsRollingFile.ImageIndex := 1;
  end;
end;


procedure TMainForm.btnRollingFileStopClick(Sender: TObject);
begin
  if Assigned(FRollingFileObserver) then
  begin
    FLog.Detach(FRollingFileObserver);
    FRollingFileObserver := nil;

    tsRollingFile.ImageIndex := 0;
  end;
end;


procedure TMainForm.btnNamedPipeStartClick(Sender: TObject);
begin
  if not Assigned(FNamedPipeObserver) then
  begin
    FNamedPipeObserver := TX2LogNamedPipeObserver.Create(edtPipeName.Text);
    FLog.Attach(FNamedPipeObserver);

    tsNamedPipe.ImageIndex := 1;
  end;
end;


procedure TMainForm.btnNamedPipeStopClick(Sender: TObject);
begin
  if Assigned(FNamedPipeObserver) then
  begin
    FLog.Detach(FNamedPipeObserver);
    FNamedPipeObserver := nil;

    tsNamedPipe.ImageIndex := 0;
  end;
end;


procedure TMainForm.btnNamedPipeRefreshClick(Sender: TObject);
var
  server: TX2LogNamedPipeServerInfo;

begin
  lbNamedPipeServers.Items.BeginUpdate;
  try
    lbNamedPipeServers.Items.Clear;

    for server in TX2LogNamedPipeClient.ActiveServers do
      lbNamedPipeServers.Items.Add(server.DisplayName + ' (' + server.PipeName + ')');
  finally
    lbNamedPipeServers.Items.EndUpdate;
  end;
end;


procedure TMainForm.btnTimerStartClick(Sender: TObject);
begin
  Timer.Interval := StrToIntDef(edtInterval.Text, 5) * 1000;
  Timer.Enabled := True;

  btnTimerStart.Enabled := False;
  btnTimerStop.Enabled := True;
end;


procedure TMainForm.btnTimerStopClick(Sender: TObject);
begin
  Timer.Enabled := False;

  btnTimerStart.Enabled := True;
  btnTimerStop.Enabled := False;
end;


procedure TMainForm.TimerTimer(Sender: TObject);
begin
  FLog.Warning('Batch start');
  FLog.Info('Message 1');
  FLog.Info('Message 2');
  FLog.Info('Message 3');
end;


procedure TMainForm.btnValueTypesClick(Sender: TObject);
begin
  FLog.InfoS('Testing the various value types',
    ['String', 'Hello world!',
     'DateTime', LogDT,
     'Has the large hadron collider destroyed the world yet?', False,
     'Float', 3.1415,
     'Integer', 89740987342]);
end;


procedure TMainForm.btnStructuredExceptionClick(Sender: TObject);
begin
  try
    raise Exception.Create('Stuff''s broken!');
  except
    on E:Exception do
      FLog.ExceptionS(e, 'I totally expected that.', ['HasExtraInfo', False]);
  end;
end;

end.
