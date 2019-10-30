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
    FInlineFields: Boolean;
    FInlineDetails: Boolean;
    FStyle: TX2LogJsonStyle;
  protected
    function GetText(AHelper: IX2LogTextFormatterHelper; ALevel: TX2LogLevel; ADateTime: TDateTime; const AMessage: string; const ACategory: string; ADetails: IX2LogDetails): string;
    procedure AddDictionaryDetails(AObject: TJsonObject; ADetails: IX2LogDetailsDictionary);

    property SingleLine: Boolean read FSingleLine;
    property InlineFields: Boolean read FInlineFields;
    property InlineDetails: Boolean read FInlineDetails;
    property Style: TX2LogJsonStyle read FStyle;
  public
    {
      If AInlineFields is False, dictionary keys/values will be added to a
      "fields" object instead of directly in the message, similar to Serilog's
      Elasticsearch sink option with the same name.

      If AInlineDetails is False, the details will be written to a separate file and
      the detailsFile value will contain the file name.
    }
    constructor Create(ASingleLine: Boolean = True; AStyle: TX2LogJsonStyle = TX2LogJsonStyle.Default; AInlineFields: Boolean = True; AInlineDetails: Boolean = True);
  end;


implementation
uses
  Soap.EncdDecd,
  System.Classes,
  System.NetEncoding,
  System.SysUtils;


{ TX2LogJsonTextFormatter }
constructor TX2LogJsonTextFormatter.Create(ASingleLine: Boolean; AStyle: TX2LogJsonStyle; AInlineFields, AInlineDetails: Boolean);
begin
  inherited Create;

  FSingleLine := ASingleLine;
  FInlineFields := AInlineFields;
  FInlineDetails := AInlineDetails;
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
  detailsStream: TMemoryStream;
  encodedStream: TStringStream;

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
      if InlineFields then
        AddDictionaryDetails(line, dictionaryDetails)
      else
        AddDictionaryDetails(line.O['fields'], dictionaryDetails);
    end else
    begin
      if InlineDetails then
      begin
        detailsStream := TMemoryStream.Create;
        try
          if AHelper.SaveDetailsToStream(detailsStream) then
          begin
            detailsStream.Position := 0;
            encodedStream := TStringStream.Create;
            try
              EncodeStream(detailsStream, encodedStream);
              line.S['details'] := encodedStream.DataString;
            finally
              FreeAndNil(encodedStream);
            end;
          end;
        finally
          FreeAndNil(detailsStream);
        end;
      end else
      begin
        detailsFileName := AHelper.GetDetailsFilename;
        if Length(detailsFileName) > 0 then
          line.S['detailsFile'] := ExtractFileName(detailsFileName);
      end;
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
