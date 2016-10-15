unit X2Log.Observer.RollingLogFile;

interface
uses
  System.SysUtils,

  X2Log.Intf,
  X2Log.Observer.CustomThreaded,
  X2Log.Observer.LogFile,
  X2Log.TextFormatter.Intf;


const
  X2LogDefaultDays = 5;


type
  TX2RollingLogFileObserver = class(TX2LogFileObserver)
  private
    FDays: Integer;
  protected
    function CreateWorkerThread: TX2LogObserverWorkerThread; override;

    property Days: Integer read FDays;
  public
    constructor Create(const AFileName: string; ADays: Integer = X2LogDefaultDays; ALogLevels: TX2LogLevels = X2LogLevelsDefault; ALogDetails: Boolean = True; ATextFormatter: IX2LogTextFormatter = nil);
    constructor CreateInProgramData(const AFileName: string; ADays: Integer = X2LogDefaultDays; ALogLevels: TX2LogLevels = X2LogLevelsDefault; ALogDetails: Boolean = True; ATextFormatter: IX2LogTextFormatter = nil);
    constructor CreateInUserAppData(const AFileName: string; ADays: Integer = X2LogDefaultDays; ALogLevels: TX2LogLevels = X2LogLevelsDefault; ALogDetails: Boolean = True; ATextFormatter: IX2LogTextFormatter = nil);
  end;


  TX2RollingLogFileWorkerThread = class(TX2LogFileWorkerThread)
  private
    FDays: Integer;
    FLastCleanupDate: TDateTime;
    FFormatSettings: TFormatSettings;
    FDateFormat: string;
  protected
    function GetFileName(AEntry: TX2LogQueueEntry): string; override;
    function GetDateFileName(ADate: TDateTime): string;

    procedure ProcessEntry(AEntry: TX2LogQueueEntry); override;
    procedure CleanupLogFiles; virtual;

    property Days: Integer read FDays;
    property LastCleanupDate: TDateTime read FLastCleanupDate write FLastCleanupDate;
  public
    constructor Create(const AFileName: string; ADays: Integer; ATextFormatter: IX2LogTextFormatter; ALogDetails: Boolean = True);
  end;


implementation
uses
  System.DateUtils,
  System.IOUtils,
  System.StrUtils,
  System.Types,

  X2Log.Constants;


{ TX2RollingLogFileObserver }
constructor TX2RollingLogFileObserver.Create(const AFileName: string; ADays: Integer; ALogLevels: TX2LogLevels; ALogDetails: Boolean; ATextFormatter: IX2LogTextFormatter);
begin
  FDays := ADays;

  inherited Create(AFileName, ALogLevels, ALogDetails, ATextFormatter);
end;


constructor TX2RollingLogFileObserver.CreateInProgramData(const AFileName: string; ADays: Integer; ALogLevels: TX2LogLevels; ALogDetails: Boolean; ATextFormatter: IX2LogTextFormatter);
begin
  FDays := ADays;

  inherited CreateInProgramData(AFileName, ALogLevels, ALogDetails, ATextFormatter);
end;


constructor TX2RollingLogFileObserver.CreateInUserAppData(const AFileName: string; ADays: Integer; ALogLevels: TX2LogLevels; ALogDetails: Boolean; ATextFormatter: IX2LogTextFormatter);
begin
  FDays := ADays;

  inherited CreateInUserAppData(AFileName, ALogLevels, ALogDetails, ATextFormatter);
end;


function TX2RollingLogFileObserver.CreateWorkerThread: TX2LogObserverWorkerThread;
begin
  Result := TX2RollingLogFileWorkerThread.Create(OutputFileName, Days, GetTextFormatter, LogDetails);
end;


{ TX2RollingLogFileWorkerThread }
constructor TX2RollingLogFileWorkerThread.Create(const AFileName: string; ADays: Integer; ATextFormatter: IX2LogTextFormatter; ALogDetails: Boolean);
begin
  FDays := ADays;
  FFormatSettings := TFormatSettings.Create;
  FDateFormat := GetLogResourceString(@RollingLogFileDateFormat);

  inherited Create(AFileName, ATextFormatter, ALogDetails);
end;


function TX2RollingLogFileWorkerThread.GetFileName(AEntry: TX2LogQueueEntry): string;
begin
  Result := GetDateFileName(AEntry.DateTime);
end;


function TX2RollingLogFileWorkerThread.GetDateFileName(ADate: TDateTime): string;
var
  baseFileName: string;

begin
  baseFileName := OutputFileName;
  Result := ChangeFileExt(baseFileName, '') + '.' +
            FormatDateTime(FDateFormat, ADate, FFormatSettings) +
            ExtractFileExt(baseFileName);
end;


procedure TX2RollingLogFileWorkerThread.ProcessEntry(AEntry: TX2LogQueueEntry);
begin
  if not SameDate(Date, LastCleanupDate) then
  begin
    CleanupLogFiles;
    LastCleanupDate := Date;
  end;

  inherited ProcessEntry(AEntry);
end;


procedure TX2RollingLogFileWorkerThread.CleanupLogFiles;
var
  baseFileName: string;
  fileMask: string;
  validFileNames: TStringDynArray;
  day: Integer;
  filePath: string;
  fileName: string;

begin
  baseFileName := OutputFileName;
  fileMask := ChangeFileExt(ExtractFileName(baseFileName), '') + '.*' +
              ExtractFileExt(baseFileName);

  { The date format can be customized, so instead of parsing back the file
    names, use a whitelist }
  SetLength(validFileNames, Days);
  for day := 0 to Pred(Days) do
    validFileNames[day] := ExtractFileName(GetDateFileName(IncDay(Date, -day)));

  for filePath in TDirectory.GetFiles(ExtractFilePath(baseFileName), fileMask) do
  begin
    fileName := ExtractFileName(filePath);

    if IndexText(fileName, validFileNames) = -1 then
      DeleteFile(filePath);
  end;
end;

end.
