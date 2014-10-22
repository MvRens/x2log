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
    FFileName: string;
  protected
    function CreateWorkerThread: TX2LogObserverWorkerThread; override;
  public
    constructor Create(const AFileName: string; ALogLevels: TX2LogLevels = X2LogLevelsDefault);
    constructor CreateInProgramData(const AFileName: string; ALogLevels: TX2LogLevels = X2LogLevelsDefault);
    constructor CreateInUserAppData(const AFileName: string; ALogLevels: TX2LogLevels = X2LogLevelsDefault);
  end;


implementation
uses
  System.IOUtils,
  System.SysUtils,
  System.Win.ComObj,
  Winapi.SHFolder,
  Winapi.Windows,

  X2Log.Constants;


type
  TX2LogFileWorkerThread = class(TX2LogObserverWorkerThread)
  private
    FFileName: string;
  protected
    procedure ProcessEntry(AEntry: TX2LogQueueEntry); override;

    property FileName: string read FFileName;
  public
    constructor Create(const AFileName: string);
  end;



{ TX2LogFileObserver }
constructor TX2LogFileObserver.Create(const AFileName: string; ALogLevels: TX2LogLevels);
begin
  FFileName := AFileName;

  inherited Create(ALogLevels);
end;


constructor TX2LogFileObserver.CreateInProgramData(const AFileName: string; ALogLevels: TX2LogLevels);
var
  path: PWideChar;

begin
  GetMem(path, MAX_PATH);
  try
    OleCheck(SHGetFolderPath(0, CSIDL_COMMON_APPDATA, 0, SHGFP_TYPE_CURRENT, path));
    Create(IncludeTrailingPathDelimiter(path) + AFileName, ALogLevels);
  finally
    FreeMem(path);
  end;
end;


constructor TX2LogFileObserver.CreateInUserAppData(const AFileName: string; ALogLevels: TX2LogLevels);
var
  path: PWideChar;

begin
  GetMem(path, MAX_PATH);
  try
    OleCheck(SHGetFolderPath(0, CSIDL_APPDATA, 0, SHGFP_TYPE_CURRENT, path));
    Create(IncludeTrailingPathDelimiter(path) + AFileName, ALogLevels);
  finally
    FreeMem(path);
  end;
end;


function TX2LogFileObserver.CreateWorkerThread: TX2LogObserverWorkerThread;
begin
  Result := TX2LogFileWorkerThread.Create(FFileName);
end;


{ TX2LogFileWorkerThread }
constructor TX2LogFileWorkerThread.Create(const AFileName: string);
begin
  FFileName := AFileName;

  inherited Create;
end;


procedure TX2LogFileWorkerThread.ProcessEntry(AEntry: TX2LogQueueEntry);
var
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
  ForceDirectories(ExtractFilePath(FileName));

  if Length(AEntry.Category) > 0 then
    errorMsg := Format(GetLogResourceString(@LogFileLineCategory), [AEntry.Message, AEntry.Category])
  else
    errorMsg := Format(GetLogResourceString(@LogFileLineNoCategory), [AEntry.Message]);

  if Supports(AEntry.Details, IX2LogDetailsStreamable, logDetailsStreamable) then
  begin
    detailsExtension := ExtractFileExt(FileName);
    baseReportFileName := ChangeFileExt(FileName, '_' + FormatDateTime(GetLogResourceString(@LogFileNameDateFormat), AEntry.DateTime));
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
  writer := TFile.AppendText(FileName);
  try
    writer.WriteLine('[' + FormatDateTime(GetLogResourceString(@LogFileLineDateFormat), AEntry.DateTime) + '] ' +
                     GetLogLevelText(AEntry.Level) + ': ' + errorMsg);
  finally
    FreeAndNil(writer);
  end;
end;

end.
