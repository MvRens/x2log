unit X2Log.Observer.LogFile;

interface
uses
  System.Classes,
  System.Generics.Collections,
  System.SyncObjs,

  X2Log.Intf,
  X2Log.Observer.Custom,
  X2Log.Observer.CustomThreaded;


type
  TX2LogFileObserver = class(TX2LogCustomThreadedObserver)
  private
    FOutputFileName: string;
    FLogDetails: Boolean;
  protected
    function CreateWorkerThread: TX2LogObserverWorkerThread; override;

    property OutputFileName: string read FOutputFileName;
    property LogDetails: Boolean read FLogDetails;
  public
    constructor Create(const AOutputFileName: string; ALogLevels: TX2LogLevels = X2LogLevelsDefault; ALogDetails: Boolean = True);
    constructor CreateInProgramData(const AOutputFileName: string; ALogLevels: TX2LogLevels = X2LogLevelsDefault; ALogDetails: Boolean = True);
    constructor CreateInUserAppData(const AOutputFileName: string; ALogLevels: TX2LogLevels = X2LogLevelsDefault; ALogDetails: Boolean = True);
  end;


  TX2LogFileWorkerThread = class(TX2LogObserverWorkerThread)
  private
    FOutputFileName: string;
    FLogDetails: Boolean;
  protected
    function GetFileName(AEntry: TX2LogQueueEntry): string; virtual;
    procedure ProcessEntry(AEntry: TX2LogQueueEntry); override;

    property OutputFileName: string read FOutputFileName;
    property LogDetails: Boolean read FLogDetails;
  public
    constructor Create(const AOutputFileName: string; ALogDetails: Boolean = True);
  end;


implementation
uses
  System.IOUtils,
  System.SysUtils,
  System.Win.ComObj,
  Winapi.SHFolder,
  Winapi.Windows,

  X2Log.Constants;



{ TX2LogFileObserver }
constructor TX2LogFileObserver.Create(const AOutputFileName: string; ALogLevels: TX2LogLevels; ALogDetails: Boolean);
begin
  FOutputFileName := AOutputFileName;
  FLogDetails := ALogDetails;

  inherited Create(ALogLevels);
end;


constructor TX2LogFileObserver.CreateInProgramData(const AOutputFileName: string; ALogLevels: TX2LogLevels; ALogDetails: Boolean);
var
  path: PWideChar;

begin
  GetMem(path, MAX_PATH);
  try
    OleCheck(SHGetFolderPath(0, CSIDL_COMMON_APPDATA, 0, SHGFP_TYPE_CURRENT, path));
    Create(IncludeTrailingPathDelimiter(path) + AOutputFileName, ALogLevels, ALogDetails);
  finally
    FreeMem(path);
  end;
end;


constructor TX2LogFileObserver.CreateInUserAppData(const AOutputFileName: string; ALogLevels: TX2LogLevels; ALogDetails: Boolean);
var
  path: PWideChar;

begin
  GetMem(path, MAX_PATH);
  try
    OleCheck(SHGetFolderPath(0, CSIDL_APPDATA, 0, SHGFP_TYPE_CURRENT, path));
    Create(IncludeTrailingPathDelimiter(path) + AOutputFileName, ALogLevels, ALogDetails);
  finally
    FreeMem(path);
  end;
end;


function TX2LogFileObserver.CreateWorkerThread: TX2LogObserverWorkerThread;
begin
  Result := TX2LogFileWorkerThread.Create(OutputFileName, LogDetails);
end;


{ TX2LogFileWorkerThread }
constructor TX2LogFileWorkerThread.Create(const AOutputFileName: string; ALogDetails: Boolean);
begin
  FOutputFileName := AOutputFileName;
  FLogDetails := ALogDetails;

  inherited Create;
end;


procedure TX2LogFileWorkerThread.ProcessEntry(AEntry: TX2LogQueueEntry);
var
  fileName: string;
  baseReportFileName: string;
  errorMsg: string;
  detailsExtension: string;
  detailsFile: THandle;
  detailsFileStream: THandleStream;
  detailsFileName: string;
  detailsNumber: Integer;
  writer: TStreamWriter;
  logDetailsStreamable: IX2LogDetailsStreamable;

begin
  fileName := GetFileName(AEntry);
  ForceDirectories(ExtractFilePath(fileName));

  if Length(AEntry.Category) > 0 then
    errorMsg := Format(GetLogResourceString(@LogFileLineCategory), [AEntry.Message, AEntry.Category])
  else
    errorMsg := Format(GetLogResourceString(@LogFileLineNoCategory), [AEntry.Message]);

  if LogDetails and Supports(AEntry.Details, IX2LogDetailsStreamable, logDetailsStreamable) then
  begin
    detailsExtension := ExtractFileExt(fileName);
    baseReportFileName := ChangeFileExt(fileName, '_' + FormatDateTime(GetLogResourceString(@LogFileNameDateFormat), AEntry.DateTime));
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

    //      ErrorLogs.Add(reportFileName);

          errorMsg := Format(GetLogResourceString(@LogFileLineDetails), [errorMsg, ExtractFileName(detailsFileName)]);
          break;
        end;
      until False;
    end;
  end;

  { Append line to log file }
  writer := TFile.AppendText(fileName);
  try
    writer.WriteLine('[' + FormatDateTime(GetLogResourceString(@LogFileLineDateFormat), AEntry.DateTime) + '] ' +
                     GetLogLevelText(AEntry.Level) + ': ' + errorMsg);
  finally
    FreeAndNil(writer);
  end;
end;


function TX2LogFileWorkerThread.GetFileName(AEntry: TX2LogQueueEntry): string;
begin
  Result := FOutputFileName;
end;

end.
