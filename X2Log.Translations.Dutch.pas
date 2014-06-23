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
  SetLogResourceString(@LogMonitorFormColumnMessage, 'Melding');

  SetLogResourceString(@LogMonitorFormButtonClear, 'Wissen');
  SetLogResourceString(@LogMonitorFormButtonPause, 'Pauzeren');
  SetLogResourceString(@LogMonitorFormButtonCopyDetails, 'Kopiëren');
  SetLogResourceString(@LogMonitorFormButtonSaveDetails, 'Opslaan');
  SetLogResourceString(@LogMonitorFormStatusPaused, 'Gepauzeerd: %d melding(en) overgeslagen');

  SetLogResourceString(@LogMonitorFormSaveDetailsFilter, 'Alle bestanden (*.*)|*.*');
end;


initialization
  TranslateConstants;

end.
