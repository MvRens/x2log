unit X2Log.Constants;

interface
uses
  X2Log.Intf;


resourcestring
  LogLevelVerbose = 'Verbose';
  LogLevelInfo = 'Info';
  LogLevelWarning = 'Warning';
  LogLevelError = 'Error';

  LogCategorySeparator = ' - ';

  // Note: currently not translatable
  LogCategoryDefault = '';


  {
    X2Log.Observer.LogFile
  }

  { Date format used to determine the file name of detail files }
  LogFileNameDateFormat = 'yyyymmdd_hhnn';

  { Date format used in log files }
  LogFileLineDateFormat = 'yyyy-mm-dd hh:nn';

  { The text added to the message if details are stored externally }
  LogFileLineDetails = ' (details: %s)';


  {
    X2Log.Observer.MonitorForm
  }

  { Caption of the monitor form. %s is optional and will be replaced
    with the application's title }
  LogMonitorFormCaption = '%s - Live Log';

  { Caption of the columns in the live log view }
  LogMonitorFormColumnTime = 'Time';
  LogMonitorFormColumnCategory = 'Category';
  LogMonitorFormColumnMessage = 'Message';

  { Caption of the toolbar buttons }
  LogMonitorFormButtonClear = 'Clear';
  LogMonitorFormButtonPause = 'Pause';
  LogMonitorFormButtonCopyDetails = 'Copy';
  LogMonitorFormButtonSaveDetails = 'Save';
  LogMonitorFormButtonWordWrapDetails = 'Word wrap';

  LogMonitorFormButtonFilter = 'Filter:';

  { Caption of the menu items which are not on the toolbar }
  LogMonitorFormMenuFile = 'File';
  LogMonitorFormMenuFileSaveAs = 'Save as...';
  LogMonitorFormMenuFileClose = 'Close';
  LogMonitorFormMenuLog = 'Log';
  LogMonitorFormMenuDetails = 'Details';
  LogMonitorFormMenuWindow = 'Window';
  LogMonitorFormMenuWindowAlwaysOnTop = 'Always on top';


  { Status messages }
  LogMonitorFormStatusPaused = 'Paused: %d log message(s) skipped';

  { Filter for Save details buttons }
  LogMonitorFormSaveDetailsFilter = 'All files (*.*)|*.*';

  { Filter for Save as menu item }
  LogMonitorFormSaveDetailsSaveAs = 'Log files (*.log)|*.log|All files (*.*)|*.*';


  function GetLogLevelText(ALogLevel: TX2LogLevel): string;

  function GetLogResourceString(AResourceString: Pointer): string;
  procedure SetLogResourceString(AResourceString: Pointer; const AValue: string);


implementation
uses
  System.Generics.Collections,
  System.SysUtils;


type
  TResourceStringDictionary = TDictionary<Pointer,string>;

var
  LogResourceStringMap: TResourceStringDictionary;



function GetLogLevelText(ALogLevel: TX2LogLevel): string;
begin
  case ALogLevel of
    TX2LogLevel.Verbose:    Result := GetLogResourceString(@LogLevelVerbose);
    TX2LogLevel.Info:       Result := GetLogResourceString(@LogLevelInfo);
    TX2LogLevel.Warning:    Result := GetLogResourceString(@LogLevelWarning);
    TX2LogLevel.Error:      Result := GetLogResourceString(@LogLevelError);
  end;
end;


function GetLogResourceString(AResourceString: Pointer): string;
begin
  TMonitor.Enter(LogResourceStringMap);
  try
    if LogResourceStringMap.ContainsKey(AResourceString) then
      Result := LogResourceStringMap[AResourceString]
    else
      Result := LoadResString(AResourceString);
  finally
    TMonitor.Exit(LogResourceStringMap);
  end;
end;


procedure SetLogResourceString(AResourceString: Pointer; const AValue: string);
begin
  TMonitor.Enter(LogResourceStringMap);
  try
    LogResourceStringMap.AddOrSetValue(AResourceString, AValue);
  finally
    TMonitor.Exit(LogResourceStringMap);
  end;
end;


initialization
  LogResourceStringMap := TResourceStringDictionary.Create;

finalization
  FreeAndNil(LogResourceStringMap);

end.
