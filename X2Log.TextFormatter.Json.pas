unit X2Log.TextFormatter.Json;

interface
uses
  X2Log.JsonDataObjects,

  X2Log.Details.Intf,
  X2Log.Intf,
  X2Log.TextFormatter.Intf;

type
  {
    Default:
      X2Log naming convention is used for the property names

    Kibana:
      Logstash/Kibana compatible (message, @timestamp, @version) property names
  }
  TX2LogJsonStyle = (Default, Kibana);


  TX2LogJsonTextFormatter = class(TInterfacedObject, IX2LogTextFormatter)
  private
    FSingleLine: Boolean;
    FStyle: TX2LogJsonStyle;
  protected
    function GetText(AHelper: IX2LogTextFormatterHelper; ALevel: TX2LogLevel; ADateTime: TDateTime; const AMessage: string; const ACategory: string; ADetails: IX2LogDetails): string;
    procedure AddDictionaryDetails(AObject: TJsonObject; ADetails: IX2LogDetailsDictionary);

    property SingleLine: Boolean read FSingleLine;
    property Style: TX2LogJsonStyle read FStyle;
  public
    constructor Create(ASingleLine: Boolean = True; AStyle: TX2LogJsonStyle = TX2LogJsonStyle.Default);
  end;


implementation
uses
  System.SysUtils;


{ TX2LogJsonTextFormatter }
constructor TX2LogJsonTextFormatter.Create(ASingleLine: Boolean; AStyle: TX2LogJsonStyle);
begin
  inherited Create;

  FSingleLine := ASingleLine;
  FStyle := AStyle;
end;


function TX2LogJsonTextFormatter.GetText(AHelper: IX2LogTextFormatterHelper; ALevel: TX2LogLevel; ADateTime: TDateTime;
                                         const AMessage, ACategory: string; ADetails: IX2LogDetails): string;
const
  LogLevelName: array[TX2LogLevel] of string = ('verbose', 'info', 'warning', 'error');

var
  line: TJsonObject;
  dictionaryDetails: IX2LogDetailsDictionary;
  detailsFileName: string;

begin
  line := TJsonObject.Create;
  try
    case Style of
      Default:
        begin
          line.D['dateTime'] := ADateTime;
          line.S['message'] := AMessage;
        end;

      Kibana:
        begin
          line.S['@version'] := '1';
          line.D['@timestamp'] := ADateTime;
          line.S['message'] := AMessage;
        end;
    end;

    line.S['level'] := LogLevelName[ALevel];
    line.S['category'] := ACategory;

    if Supports(ADetails, IX2LogDetailsDictionary, dictionaryDetails) then
    begin
      AddDictionaryDetails(line, dictionaryDetails);
    end else
    begin
      detailsFileName := AHelper.GetDetailsFilename;
      if Length(detailsFileName) > 0 then
        line.S['details'] := ExtractFileName(detailsFileName);
    end;

    Result := line.ToJSON(SingleLine);
  finally
    FreeAndNil(line);
  end;
end;


procedure TX2LogJsonTextFormatter.AddDictionaryDetails(AObject: TJsonObject; ADetails: IX2LogDetailsDictionary);
var
  key: string;
  jsonKey: string;
  valueType: TX2LogValueType;

begin
  for key in ADetails.Keys do
  begin
    jsonKey := key;
    while AObject.Contains(jsonKey) do
      jsonKey := '_' + jsonKey;

    valueType := ADetails.ValueType[key];

    case valueType of
      StringValue: AObject.S[jsonKey] := ADetails.StringValue[key];
      BooleanValue: AObject.B[jsonKey] := ADetails.BooleanValue[key];
      IntValue: AObject.L[jsonKey] := ADetails.IntValue[key];
      FloatValue: AObject.F[jsonKey] := ADetails.FloatValue[key];
      DateTimeValue: AObject.D[jsonKey] := ADetails.DateTimeValue[key];
    else
      AObject.S[jsonKey] := Format('<error: unknown ValueType %d>', [Ord(valueType)]);
    end;
  end;
end;

end.
