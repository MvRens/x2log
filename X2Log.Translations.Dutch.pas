unit X2Log.Translations.Dutch;

interface
implementation
uses
  X2Log.Constants;


procedure TranslateConstants;
begin
  SetLogResourceString(@LogLevelVerbose, 'Uitgebreid');
  SetLogResourceString(@LogLevelInfo, 'Informatie');
  SetLogResourceString(@LogLevelWarning, 'Waarschuwing');
  SetLogResourceString(@LogLevelError, 'Fout');

  SetLogResourceString(@LogFileNameDateFormat, 'ddmmyyyy_hhnn');
  SetLogResourceString(@LogFileLineDateFormat, 'dd-mm-yy hh:nn');
  SetLogResourceString(@LogFileLineDetails, ' (details: %s)');

  SetLogResourceString(@LogMonitorFormCaption, '%s - Live Log');
  SetLogResourceString(@LogMonitorFormColumnTime, 'Tijd');
  SetLogResourceString(@LogMonitorFormColumnCategory, 'Categorie');
  SetLogResourceString(@LogMonitorFormColumnMessage, 'Melding');

  SetLogResourceString(@LogMonitorFormButtonClear, 'Wissen');
  SetLogResourceString(@LogMonitorFormButtonPause, 'Pauzeren');
  SetLogResourceString(@LogMonitorFormButtonCopyDetails, 'Kopiëren');
  SetLogResourceString(@LogMonitorFormButtonSaveDetails, 'Opslaan');
  SetLogResourceString(@LogMonitorFormButtonWordWrapDetails, 'Terugloop');

  SetLogResourceString(@LogMonitorFormButtonFilter, 'Filter:');

  SetLogResourceString(@LogMonitorFormMenuFile, 'Bestand');
  SetLogResourceString(@LogMonitorFormMenuFileSaveAs, 'Opslaan als...');
  SetLogResourceString(@LogMonitorFormMenuFileClose, 'Sluiten');
  SetLogResourceString(@LogMonitorFormMenuLog, 'Log');
  SetLogResourceString(@LogMonitorFormMenuDetails, 'Details');
  SetLogResourceString(@LogMonitorFormMenuWindow, 'Venster');
  SetLogResourceString(@LogMonitorFormMenuWindowAlwaysOnTop, 'Altijd op voorgrond');

  SetLogResourceString(@LogMonitorFormMessageHeader, 'Melding');
  SetLogResourceString(@LogMonitorFormDetailHeader, 'Details');
  SetLogResourceString(@LogMonitorFormKeyHeader, 'Naam');
  SetLogResourceString(@LogMonitorFormValueHeader, 'Waarde');

  SetLogResourceString(@LogMonitorFormStatusPaused, 'Gepauzeerd: %d melding(en) overgeslagen');

  SetLogResourceString(@LogMonitorFormSaveDetailsFilter, 'Alle bestanden (*.*)|*.*');
  SetLogResourceString(@LogMonitorFormSaveDetailsSaveAs, 'Log bestanden (*.log)|*.log|Alle bestanden (*.*)|*.*');
end;


initialization
  TranslateConstants;

end.
