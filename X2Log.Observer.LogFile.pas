unit X2Log.Observer.LogFile;

interface
uses
  System.Classes,
  System.Generics.Collections,
  System.SyncObjs,

  X2Log.Intf,
  X2Log.Observer.Custom,
  X2Log.Observer.CustomThreaded,
  X2Log.TextFormatter.Intf;


type
  TX2LogFileObserver = class(TX2LogCustomThreadedObserver)
  private
    FOutputFileName: string;
    FLogDetails: Boolean;
    FTextFormatter: IX2LogTextFormatter;
  protected
    function GetTextFormatter: IX2LogTextFormatter; virtual;
    function CreateWorkerThread: TX2LogObserverWorkerThread; override;

    property OutputFileName: string read FOutputFileName;
    property LogDetails: Boolean read FLogDetails;
  public
    constructor Create(const AOutputFileName: string; ALogLevels: TX2LogLevels = X2LogLevelsDefault; ALogDetails: Boolean = True; ATextFormatter: IX2LogTextFormatter = nil);
    constructor CreateInProgramData(const AOutputFileName: string; ALogLevels: TX2LogLevels = X2LogLevelsDefault; ALogDetails: Boolean = True; ATextFormatter: IX2LogTextFormatter = nil);
    constructor CreateInUserAppData(const AOutputFileName: string; ALogLevels: TX2LogLevels = X2LogLevelsDefault; ALogDetails: Boolean = True; ATextFormatter: IX2LogTextFormatter = nil);
  end;


  TX2LogFileWorkerThread = class(TX2LogObserverWorkerThread)
  private
    FOutputFileName: string;
    FLogDetails: Boolean;
    FTextFormatter: IX2LogTextFormatter;
  protected
    function GetFileName(AEntry: TX2LogQueueEntry): string; virtual;
    procedure ProcessEntry(AEntry: TX2LogQueueEntry); override;

    property OutputFileName: string read FOutputFileName;
    property LogDetails: Boolean read FLogDetails;
    property TextFormatter: IX2LogTextFormatter read FTextFormatter;
  public
    constructor Create(const AOutputFileName: string; ATextFormatter: IX2LogTextFormatter; ALogDetails: Boolean = True);
  end;


implementation
uses
  System.IOUtils,
  System.SysUtils,
  System.Win.ComObj,
  Winapi.SHFolder,
  Winapi.Windows,

  X2Log.Constants,
  X2Log.TextFormatter.Default;


type
  TX2LogFileTextFormatterHelper = class(TInterfacedObject, IX2LogTextFormatterHelper)
  private
    FEntry: TX2LogQueueEntry;
    FLogFileName: string;
    FLogDetails: Boolean;
  protected
    { IX2LogTextFormatterHelper }
    function GetDetailsFilename: string;
    function SaveDetailsToStream(AStream: TStream): Boolean;

    property Entry: TX2LogQueueEntry read FEntry;
    property LogFileName: string read FLogFileName;
    property LogDetails: Boolean read FLogDetails;
  public
    constructor Create(AEntry: TX2LogQueueEntry; const ALogFileName: string; ALogDetails: Boolean);
  end;


{ TX2LogFileObserver }
constructor TX2LogFileObserver.Create(const AOutputFileName: string; ALogLevels: TX2LogLevels; ALogDetails: Boolean; ATextFormatter: IX2LogTextFormatter);
begin
  FOutputFileName := AOutputFileName;
  FLogDetails := ALogDetails;
  FTextFormatter := ATextFormatter;
  if not Assigned(FTextFormatter) then
    FTextFormatter := TX2LogDefaultTextFormatter.Create;

  inherited Create(ALogLevels);
end;


constructor TX2LogFileObserver.CreateInProgramData(const AOutputFileName: string; ALogLevels: TX2LogLevels; ALogDetails: Boolean; ATextFormatter: IX2LogTextFormatter);
var
  path: PWideChar;

begin
  GetMem(path, MAX_PATH);
  try
    OleCheck(SHGetFolderPath(0, CSIDL_COMMON_APPDATA, 0, SHGFP_TYPE_CURRENT, path));
    Create(IncludeTrailingPathDelimiter(path) + AOutputFileName, ALogLevels, ALogDetails, ATextFormatter);
  finally
    FreeMem(path);
  end;
end;


constructor TX2LogFileObserver.CreateInUserAppData(const AOutputFileName: string; ALogLevels: TX2LogLevels; ALogDetails: Boolean; ATextFormatter: IX2LogTextFormatter);
var
  path: PWideChar;

begin
  GetMem(path, MAX_PATH);
  try
    OleCheck(SHGetFolderPath(0, CSIDL_APPDATA, 0, SHGFP_TYPE_CURRENT, path));
    Create(IncludeTrailingPathDelimiter(path) + AOutputFileName, ALogLevels, ALogDetails, ATextFormatter);
  finally
    FreeMem(path);
  end;
end;


function TX2LogFileObserver.CreateWorkerThread: TX2LogObserverWorkerThread;
begin
  Result := TX2LogFileWorkerThread.Create(OutputFileName, GetTextFormatter, LogDetails);
end;


function TX2LogFileObserver.GetTextFormatter: IX2LogTextFormatter;
begin
  Result := FTextFormatter;
end;


{ TX2LogFileWorkerThread }
constructor TX2LogFileWorkerThread.Create(const AOutputFileName: string; ATextFormatter: IX2LogTextFormatter; ALogDetails: Boolean);
begin
  FOutputFileName := AOutputFileName;
  FLogDetails := ALogDetails;
  FTextFormatter := ATextFormatter;

  inherited Create;
end;


procedure TX2LogFileWorkerThread.ProcessEntry(AEntry: TX2LogQueueEntry);
var
  fileName: string;
  line: string;
  writer: TStreamWriter;

begin
  fileName := GetFileName(AEntry);
  if not ForceDirectories(ExtractFilePath(fileName)) then
    exit;

  line := TextFormatter.GetText(TX2LogFileTextFormatterHelper.Create(AEntry, fileName, LogDetails),
                                AEntry.Level, AEntry.DateTime, AEntry.Message, AEntry.Category, AEntry.Details);

  try
    { Append line to log file }
    writer := TFile.AppendText(fileName);
    try
      writer.WriteLine(line);
    finally
      FreeAndNil(writer);
    end;
  except
    { If we retry for an amount of time the buffers will just backlog,
      so for now just carry on. }
    on E:EInOutError do;
  end;
end;


function TX2LogFileWorkerThread.GetFileName(AEntry: TX2LogQueueEntry): string;
begin
  Result := FOutputFileName;
end;


{ TX2LogFileTextFormatterHelper }
constructor TX2LogFileTextFormatterHelper.Create(AEntry: TX2LogQueueEntry; const ALogFileName: string; ALogDetails: Boolean);
begin
  inherited Create;

  FEntry := AEntry;
  FLogFileName := ALogFileName;
  FLogDetails := ALogDetails;
end;


function TX2LogFileTextFormatterHelper.GetDetailsFilename: string;
var
  logDetailsStreamable: IX2LogDetailsStreamable;
  baseReportFileName: string;
  detailsExtension: string;
  detailsFile: THandle;
  detailsFileStream: THandleStream;
  detailsFileName: string;
  detailsNumber: Integer;

begin
  Result := '';
  if not LogDetails then
    exit;

  if Supports(Entry.Details, IX2LogDetailsStreamable, logDetailsStreamable) then
  begin
    detailsExtension := ExtractFileExt(LogFileName);
    baseReportFileName := ChangeFileExt(LogFileName, '_' + FormatDateTime(GetLogResourceString(@LogFileNameDateFormat), Entry.DateTime));
    detailsFileName := baseReportFileName + detailsExtension;
    detailsNumber := 0;

    if ForceDirectories(ExtractFilePath(detailsFileName)) then
    begin
      repeat
        { TFileStream lacks the ability to create a file only when it does not exist }
        detailsFile := CreateFile(PChar(detailsFileName), GENERIC_READ or GENERIC_WRITE,
                                 FILE_SHARE_READ or FILE_SHARE_WRITE, nil, CREATE_NEW,
                                 FILE_ATTRIBUTE_NORMAL, 0);

        if detailsFile = INVALID_HANDLE_VALUE then
        begin
          if GetLastError = ERROR_FILE_EXISTS then
          begin
            { Generate a new file name }
            Inc(detailsNumber);
            detailsFileName := Format('%s_%d%s', [baseReportFileName, detailsNumber,
                                                 detailsExtension]);
          end else
            break;
        end else
        begin
          { Details file succesfully generated }
          try
            detailsFileStream := THandleStream.Create(detailsFile);
            try
              logDetailsStreamable.SaveToStream(detailsFileStream);
            finally
              FreeAndNil(detailsFileStream);
            end;
          finally
            CloseHandle(detailsFile);
          end;

          Result := detailsFileName;
          break;
        end;
      until False;
    end;
  end;
end;


function TX2LogFileTextFormatterHelper.SaveDetailsToStream(AStream: TStream): Boolean;
var
  logDetailsStreamable: IX2LogDetailsStreamable;

begin
  Result := Supports(Entry.Details, IX2LogDetailsStreamable, logDetailsStreamable);
  if Result then
    logDetailsStreamable.SaveToStream(AStream);
end;

end.
