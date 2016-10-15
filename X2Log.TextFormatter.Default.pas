unit X2Log.TextFormatter.Default;

interface
uses
  X2Log.Details.Intf,
  X2Log.Intf,
  X2Log.TextFormatter.Intf;


type
  TX2LogDefaultTextFormatter = class(TInterfacedObject, IX2LogTextFormatter)
  protected
    function GetText(AHelper: IX2LogTextFormatterHelper; ALevel: TX2LogLevel; ADateTime: TDateTime; const AMessage: string; const ACategory: string; ADetails: IX2LogDetails): string;

    function GetDictionaryDisplayValues(ADetails: IX2LogDetailsDictionary): string;
  end;


implementation
uses
  System.SysUtils,

  X2Log.Constants;


{ TX2LogDefaultTextFormatter }
function TX2LogDefaultTextFormatter.GetText(AHelper: IX2LogTextFormatterHelper; ALevel: TX2LogLevel; ADateTime: TDateTime;
                                            const AMessage, ACategory: string; ADetails: IX2LogDetails): string;
var
  line: string;
  dictionaryDetails: IX2LogDetailsDictionary;
  detailsFileName: string;

begin
  if Length(ACategory) > 0 then
    line := Format(GetLogResourceString(@LogFileLineCategory), [AMessage, ACategory])
  else
    line := Format(GetLogResourceString(@LogFileLineNoCategory), [AMessage]);

  if Supports(ADetails, IX2LogDetailsDictionary, dictionaryDetails) then
  begin
    line := Format(GetLogResourceString(@LogFileLineStructured), [line, GetDictionaryDisplayValues(dictionaryDetails)]);
  end else
  begin
    detailsFileName := AHelper.GetDetailsFilename;
    if Length(detailsFileName) > 0 then
      line := Format(GetLogResourceString(@LogFileLineDetails), [line, ExtractFileName(detailsFileName)]);
  end;

  Result := '[' + FormatDateTime(GetLogResourceString(@LogFileLineDateFormat), ADateTime) + '] ' +
            GetLogLevelText(ALevel) + ': ' + line;

end;


function TX2LogDefaultTextFormatter.GetDictionaryDisplayValues(ADetails: IX2LogDetailsDictionary): string;
var
  displayValues: TStringBuilder;
  key: string;

begin
  displayValues := TStringBuilder.Create;
  try
    for key in ADetails.Keys do
    begin
      if displayValues.Length > 0 then
        displayValues.Append(', ');

      displayValues.Append(key).Append(': ').Append(ADetails.DisplayValue[key]);
    end;

    Result := displayValues.ToString;
  finally
    FreeAndNil(displayValues);
  end;
end;

end.
