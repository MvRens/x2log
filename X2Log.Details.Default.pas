unit X2Log.Details.Default;

interface
uses
  System.Classes,
  System.Generics.Collections,
  Vcl.Graphics,

  X2Log.Details.Intf,
  X2Log.Intf;


type
  TX2LogStringDetails = class(TInterfacedObject, IX2LogDetails, IX2LogDetailsText,
                                                 IX2LogDetailsCopyable, IX2LogDetailsStreamable)
  private
    FText: string;
  public
    class function CreateIfNotEmpty(const AText: string): TX2LogStringDetails;

    constructor Create(const AText: string);

    { IX2LogDetails }
    function GetSerializerIID: TGUID;

    { IX2LogDetailsText }
    function GetAsString: string;

    { IX2LogDetailsCopyable }
    procedure CopyToClipboard;

    { IX2LogDetailsStreamable }
    procedure SaveToStream(AStream: TStream);
  end;


  TX2LogDictionaryValueClass = class of TX2LogDictionaryValue;

  TX2LogDictionaryValue = class(TObject)
  private
    FValueType: TX2LogValueType;
  protected
    constructor Create(AValueType: TX2LogValueType; AStream: TStream = nil; ASize: Cardinal = 0); overload; virtual;

    procedure LoadFromStream(AStream: TStream; ASize: Cardinal); virtual; abstract;
    procedure SaveToStream(AStream: TStream); virtual; abstract;

    function GetDisplayValue: string; virtual; abstract;

    property DisplayValue: string read GetDisplayValue;
    property ValueType: TX2LogValueType read FValueType;
  end;


  IX2LogDetailsDictionaryAccess = interface(IX2LogDetailsDictionary)
    ['{60C46488-9DBD-4596-8BE9-916C61006F0E}']
    function GetValue(const Key: string): TX2LogDictionaryValue;

    property Value[const Key: string]: TX2LogDictionaryValue read GetValue;
  end;

  TX2LogValueDictionary = TObjectDictionary<string, TX2LogDictionaryValue>;


  TX2LogDictionaryDetails = class(TInterfacedObject, IX2LogDetails, IX2LogDetailsDictionary,
                                                     IX2LogDetailsDictionaryAccess)
  private
    FValues: TX2LogValueDictionary;
  protected
    constructor CreateOwned(AValues: TX2LogValueDictionary);

    { IX2LogDetailsDictionaryAccess }
    function GetValue(const Key: string): TX2LogDictionaryValue;
  public
    class function CreateIfNotEmpty(AValues: array of const): TX2LogDictionaryDetails;

    constructor Create(AValues: array of const);
    destructor Destroy; override;

    { IX2LogDetails }
    function GetSerializerIID: TGUID;

    { IX2LogDetailsDictionary }
    function GetKeys: TEnumerable<string>;
    function GetValueType(const Key: string): TX2LogValueType;
    function GetDisplayValue(const Key: string): string;

    function GetStringValue(const Key: string): string;
    function GetBooleanValue(const Key: string): Boolean;
    function GetIntValue(const Key: string): Int64;
    function GetFloatValue(const Key: string): Extended;
    function GetDateTimeValue(const Key: string): TDateTime;
  end;


  TX2LogBinaryDetails = class(TInterfacedObject, IX2LogDetails, IX2LogDetailsBinary,
                                                 IX2LogDetailsStreamable)
  private
    FData: TStream;
  protected
    property Data: TStream read FData;
  public
    constructor Create; overload;
    constructor Create(ACopyFrom: TStream; ACount: Integer = 0); overload;
    constructor Create(AData: RawByteString); overload;
    destructor Destroy; override;

    { IX2LogDetails }
    function GetSerializerIID: TGUID;

    { IX2LogDetailsBinary }
    function GetAsStream: TStream;

    { IX2LogDetailsStreamable }
    procedure SaveToStream(AStream: TStream);
  end;



  TX2LogGraphicDetails = class(TInterfacedObject, IX2LogDetails, IX2LogDetailsGraphic,
                                                  IX2LogDetailsCopyable, IX2LogDetailsStreamable)
  private
    FGraphic: TGraphic;
  protected
    { Dummy parameter to prevent 'Duplicate constructor inaccessible from C++' warning }
    constructor CreateOwned(AGraphic: TGraphic; ADummy: Integer = 0);
  public
    class function CreateIfNotEmpty(AGraphic: TGraphic): TX2LogGraphicDetails;

    constructor Create(AGraphic: TGraphic);
    destructor Destroy; override;

    { IX2LogDetails }
    function GetSerializerIID: TGUID;

    { IX2LogDetailsGraphic }
    function GetAsGraphic: TGraphic;

    { IX2LogDetailsCopyable }
    procedure CopyToClipboard;

    { IX2LogDetailsStreamable }
    procedure SaveToStream(AStream: TStream);
  end;


implementation
uses
  System.SysUtils,
  Vcl.ClipBrd,
  Winapi.Windows,

  X2Log.Constants,
  X2Log.Details.Registry,
  X2Log.Util.Stream;


const
  StringDetailsSerializerIID: TGUID = '{4223C30E-6E80-4D66-9EDC-F8688A7413D2}';
  DictionaryDetailsSerializerIID: TGUID = '{1D28FF6E-8AA7-41FA-96D7-0CE921D9CA2E}';
  BinaryDetailsSerializerIID: TGUID = '{05F6E8BD-118E-41B3-B626-1F190CC2A7D3}';
  GraphicDetailsSerializerIID: TGUID = '{BD31E42A-83DC-4947-A862-79ABAE8D5056}';



type
  TX2LogStringDetailsSerializer = class(TInterfacedObject, IX2LogDetailsSerializer)
  public
    { IX2LogDetailsSerializer }
    procedure Serialize(ADetails: IX2LogDetails; AStream: TStream);
    function Deserialize(AStream: TStream): IX2LogDetails;
  end;


  TX2LogDictionaryDetailsSerializer = class(TInterfacedObject, IX2LogDetailsSerializer)
  public
    { IX2LogDetailsSerializer }
    procedure Serialize(ADetails: IX2LogDetails; AStream: TStream);
    function Deserialize(AStream: TStream): IX2LogDetails;
  end;


  TX2LogBinaryDetailsSerializer = class(TInterfacedObject, IX2LogDetailsSerializer)
  public
    { IX2LogDetailsSerializer }
    procedure Serialize(ADetails: IX2LogDetails; AStream: TStream);
    function Deserialize(AStream: TStream): IX2LogDetails;
  end;


  TX2LogGraphicDetailsSerializer = class(TInterfacedObject, IX2LogDetailsSerializer)
  public
    { IX2LogDetailsSerializer }
    procedure Serialize(ADetails: IX2LogDetails; AStream: TStream);
    function Deserialize(AStream: TStream): IX2LogDetails;
  end;


  TX2LogDictionaryStringValue = class(TX2LogDictionaryValue)
  private
    FValue: string;
  protected
    constructor Create(const AValue: string); overload;

    procedure LoadFromStream(AStream: TStream; ASize: Cardinal); override;
    procedure SaveToStream(AStream: TStream); override;

    function GetDisplayValue: string; override;

    property Value: string read FValue write FValue;
  end;


  TX2LogDictionaryBooleanValue = class(TX2LogDictionaryValue)
  private
    FValue: Boolean;
  protected
    constructor Create(AValue: Boolean); overload;

    procedure LoadFromStream(AStream: TStream; ASize: Cardinal); override;
    procedure SaveToStream(AStream: TStream); override;

    function GetDisplayValue: string; override;

    property Value: Boolean read FValue write FValue;
  end;


  TX2LogDictionaryIntValue = class(TX2LogDictionaryValue)
  private
    FValue: Int64;
  protected
    constructor Create(AValue: Int64); overload;

    procedure LoadFromStream(AStream: TStream; ASize: Cardinal); override;
    procedure SaveToStream(AStream: TStream); override;

    function GetDisplayValue: string; override;

    property Value: Int64 read FValue write FValue;
  end;


  TX2LogDictionaryFloatValue = class(TX2LogDictionaryValue)
  private
    FValue: Extended;
  protected
    constructor Create(AValue: Extended); overload;

    procedure LoadFromStream(AStream: TStream; ASize: Cardinal); override;
    procedure SaveToStream(AStream: TStream); override;

    function GetDisplayValue: string; override;

    property Value: Extended read FValue write FValue;
  end;


  TX2LogDictionaryDateTimeValue = class(TX2LogDictionaryValue)
  private
    FValue: TDateTime;
  protected
    constructor Create(AValue: TDateTime); overload;

    procedure LoadFromStream(AStream: TStream; ASize: Cardinal); override;
    procedure SaveToStream(AStream: TStream); override;

    function GetDisplayValue: string; override;

    property Value: TDateTime read FValue write FValue;
  end;


{ TX2LogStringDetails }
class function TX2LogStringDetails.CreateIfNotEmpty(const AText: string): TX2LogStringDetails;
begin
  if Length(AText) > 0 then
    Result := Self.Create(AText)
  else
    Result := nil;
end;


constructor TX2LogStringDetails.Create(const AText: string);
begin
  inherited Create;

  FText := AText;
end;


function TX2LogStringDetails.GetSerializerIID: TGUID;
begin
  Result := StringDetailsSerializerIID;
end;


function TX2LogStringDetails.GetAsString: string;
begin
  Result := FText;
end;


procedure TX2LogStringDetails.CopyToClipboard;
begin
  Clipboard.AsText := GetAsString;
end;


procedure TX2LogStringDetails.SaveToStream(AStream: TStream);
var
  writer: TStreamWriter;

begin
  writer := TStreamWriter.Create(AStream, TEncoding.UTF8);
  try
    writer.Write(GetAsString);
  finally
    FreeAndNil(writer);
  end;
end;


{ TX2LogDictionaryDetails }
class function TX2LogDictionaryDetails.CreateIfNotEmpty(AValues: array of const): TX2LogDictionaryDetails;
begin
  if Length(AValues) > 0 then
    Result := TX2LogDictionaryDetails.Create(AValues)
  else
    Result := nil;
end;


constructor TX2LogDictionaryDetails.CreateOwned(AValues: TX2LogValueDictionary);
begin
  inherited Create;

  FValues := AValues;
end;


constructor TX2LogDictionaryDetails.Create(AValues: array of const);
var
  paramIndex: Integer;
  param: TVarRec;
  key: string;
  value: TX2LogDictionaryValue;
  logDateTime: IX2LogDateTime;

begin
  inherited Create;

  FValues := TX2LogValueDictionary.Create([doOwnsValues]);

  if Length(AValues) mod 2 = 1 then
    raise Exception.Create('AParams must contains a multiple of 2 number of items');

  paramIndex := 0;
  while paramIndex < High(AValues) do
  begin
    param := AValues[paramIndex];

    case param.VType of
      vtChar:           key := string(param.VChar);
      vtString:         key := string(param.VString^);
      vtPChar:          key := string(param.VPChar);
      vtAnsiString:     key := string(PChar(param.VAnsiString));
      vtWideChar:       key := string(param.VWideChar);
      vtPWideChar:      key := string(param.VPWideChar);
      vtWideString:     key := string(WideString(param.VWideString));
      {$IF CompilerVersion >= 23}
      vtUnicodeString:  key := string(UnicodeString(param.VUnicodeString));
      {$IFEND}
    else
      raise Exception.CreateFmt('Parameter name at index %d is not a string value',
                                [paramIndex div 2]);
    end;

    Inc(paramIndex);

    param := AValues[paramIndex];
    case param.VType of
      vtInteger:        value := TX2LogDictionaryIntValue.Create(param.VInteger);
      vtBoolean:        value := TX2LogDictionaryBooleanValue.Create(param.VBoolean);
      vtChar:           value := TX2LogDictionaryStringValue.Create(string(param.VChar));
      vtExtended:       value := TX2LogDictionaryFloatValue.Create(param.VExtended^);
      vtString:         value := TX2LogDictionaryStringValue.Create(string(param.VString^));
      vtPChar:          value := TX2LogDictionaryStringValue.Create(string(param.VPChar));
      vtWideChar:       value := TX2LogDictionaryStringValue.Create(param.VWideChar);
      vtPWideChar:      value := TX2LogDictionaryStringValue.Create(param.VPWideChar);
      vtAnsiString:     value := TX2LogDictionaryStringValue.Create(PChar(param.VAnsiString));
      vtCurrency:       value := TX2LogDictionaryFloatValue.Create(param.VCurrency^);
      vtInterface:
        if Supports(IInterface(param.VInterface), IX2LogDateTime, logDateTime) then
          value := TX2LogDictionaryDateTimeValue.Create(logDateTime.Value)
        else
          raise Exception.CreateFmt('Unsupported value type %d at index %d', [param.VType, paramIndex]);

      vtWideString:     value := TX2LogDictionaryStringValue.Create(WideString(param.VWideString));
      vtInt64:          value := TX2LogDictionaryIntValue.Create(param.VInt64^);
      {$IF CompilerVersion >= 23}
      vtUnicodeString:  value := TX2LogDictionaryStringValue.Create(UnicodeString(param.VUnicodeString));
      {$IFEND}
    else
      raise Exception.CreateFmt('Unsupported value type %d at index %d', [param.VType, paramIndex]);
    end;

    FValues.Add(key, value);

    Inc(paramIndex);
  end;
end;


destructor TX2LogDictionaryDetails.Destroy;
begin
  FreeAndNil(FValues);

  inherited Destroy;
end;


function TX2LogDictionaryDetails.GetSerializerIID: TGUID;
begin
  Result := DictionaryDetailsSerializerIID;
end;


function TX2LogDictionaryDetails.GetKeys: TEnumerable<string>;
begin
  Result := FValues.Keys;
end;


function TX2LogDictionaryDetails.GetValueType(const Key: string): TX2LogValueType;
begin
  Result := FValues[Key].ValueType;
end;


function TX2LogDictionaryDetails.GetDisplayValue(const Key: string): string;
begin
  Result := FValues[Key].DisplayValue;
end;


function TX2LogDictionaryDetails.GetStringValue(const Key: string): string;
begin
  Result := (FValues[Key] as TX2LogDictionaryStringValue).Value;
end;


function TX2LogDictionaryDetails.GetBooleanValue(const Key: string): Boolean;
begin
  Result := (FValues[Key] as TX2LogDictionaryBooleanValue).Value;
end;


function TX2LogDictionaryDetails.GetIntValue(const Key: string): Int64;
begin
  Result := (FValues[Key] as TX2LogDictionaryIntValue).Value;
end;


function TX2LogDictionaryDetails.GetFloatValue(const Key: string): Extended;
begin
  Result := (FValues[Key] as TX2LogDictionaryFloatValue).Value;
end;


function TX2LogDictionaryDetails.GetDateTimeValue(const Key: string): TDateTime;
begin
  Result := (FValues[Key] as TX2LogDictionaryDateTimeValue).Value;
end;


function TX2LogDictionaryDetails.GetValue(const Key: string): TX2LogDictionaryValue;
begin
  Result := FValues[Key];
end;


{ TX2LogBinaryDetails }
constructor TX2LogBinaryDetails.Create;
begin
  inherited Create;

  FData := TMemoryStream.Create;
end;


constructor TX2LogBinaryDetails.Create(ACopyFrom: TStream; ACount: Integer);
begin
  inherited Create;

  FData := TMemoryStream.Create;
  FData.CopyFrom(ACopyFrom, ACount);
end;


constructor TX2LogBinaryDetails.Create(AData: RawByteString);
begin
  inherited Create;

  FData := TStringStream.Create(AData);
end;


destructor TX2LogBinaryDetails.Destroy;
begin
  FreeAndNil(FData);

  inherited Destroy;
end;


function TX2LogBinaryDetails.GetSerializerIID: TGUID;
begin
  Result := BinaryDetailsSerializerIID;
end;


function TX2LogBinaryDetails.GetAsStream: TStream;
begin
  Data.Position := 0;
  Result := Data;
end;


procedure TX2LogBinaryDetails.SaveToStream(AStream: TStream);
begin
  AStream.CopyFrom(Data, 0);
end;


{ TX2LogGraphicDetails }
class function TX2LogGraphicDetails.CreateIfNotEmpty(AGraphic: TGraphic): TX2LogGraphicDetails;
begin
  if Assigned(AGraphic) and (not AGraphic.Empty) then
    Result := Self.Create(AGraphic)
  else
    Result := nil;
end;


constructor TX2LogGraphicDetails.Create(AGraphic: TGraphic);
begin
  inherited Create;

  if not Assigned(AGraphic) then
    raise EInvalidGraphic.Create('AGraphic can not be nil');

  FGraphic := TGraphicClass(AGraphic.ClassType).Create;
  FGraphic.Assign(AGraphic);
end;


constructor TX2LogGraphicDetails.CreateOwned(AGraphic: TGraphic; ADummy: Integer);
begin
  inherited Create;

  FGraphic := AGraphic;
end;


destructor TX2LogGraphicDetails.Destroy;
begin
  FreeAndNil(FGraphic);

  inherited;
end;


function TX2LogGraphicDetails.GetSerializerIID: TGUID;
begin
  Result := GraphicDetailsSerializerIID;
end;


procedure TX2LogGraphicDetails.CopyToClipboard;
var
  format: Word;
  data: NativeUInt;
  palette: HPALETTE;

begin
  GetAsGraphic.SaveToClipboardFormat(format, data, palette);
end;


procedure TX2LogGraphicDetails.SaveToStream(AStream: TStream);
begin
  FGraphic.SaveToStream(AStream);
end;


function TX2LogGraphicDetails.GetAsGraphic: TGraphic;
begin
  Result := FGraphic;
end;


{ TX2LogStringDetailsSerializer }
procedure TX2LogStringDetailsSerializer.Serialize(ADetails: IX2LogDetails; AStream: TStream);
begin
  TStreamUtil.WriteString(AStream, (ADetails as IX2LogDetailsText).AsString);
end;


function TX2LogStringDetailsSerializer.Deserialize(AStream: TStream): IX2LogDetails;
begin
  Result := TX2LogStringDetails.Create(TStreamUtil.ReadString(AStream));
end;


{ TX2LogDictionaryDetailsSerializer }
procedure TX2LogDictionaryDetailsSerializer.Serialize(ADetails: IX2LogDetails; AStream: TStream);
var
  details: IX2LogDetailsDictionaryAccess;
  key: string;
  value: TX2LogDictionaryValue;
  payload: TMemoryStream;

begin
  details := (ADetails as IX2LogDetailsDictionaryAccess);

  payload := TMemoryStream.Create;
  try
    for key in details.Keys do
    begin
      TStreamUtil.WriteString(AStream, key);

      value := details.Value[key];
      TStreamUtil.WriteByte(AStream, Ord(value.ValueType));

      payload.Clear;
      value.SaveToStream(payload);

      TStreamUtil.WriteCardinal(AStream, payload.Size);
      if payload.Size > 0 then
        AStream.CopyFrom(payload, 0);
    end;
  finally
    FreeAndNil(payload);
  end;

  TStreamUtil.WriteString(AStream, '');
end;


function TX2LogDictionaryDetailsSerializer.Deserialize(AStream: TStream): IX2LogDetails;
var
  values: TX2LogValueDictionary;
  key: string;
  valueType: TX2LogValueType;
  payloadSize: Cardinal;
  valueClass: TX2LogDictionaryValueClass;

begin
  Result := nil;

  values := TX2LogValueDictionary.Create([doOwnsValues]);
  try
    while True do
    begin
      key := TStreamUtil.ReadString(AStream);
      if Length(key) = 0 then
        break;

      valueType := TX2LogValueType(TStreamUtil.ReadByte(AStream));
      payloadSize := TStreamUtil.ReadCardinal(AStream);

      valueClass := nil;
      case valueType of
        StringValue:    valueClass := TX2LogDictionaryStringValue;
        BooleanValue:   valueClass := TX2LogDictionaryBooleanValue;
        IntValue:       valueClass := TX2LogDictionaryIntValue;
        FloatValue:     valueClass := TX2LogDictionaryFloatValue;
        DateTimeValue:  valueClass := TX2LogDictionaryDateTimeValue;
      else
        AStream.Seek(payloadSize, soFromCurrent);
      end;

      if Assigned(valueClass) then
        values.Add(key, valueClass.Create(valueType, AStream));
    end;

    Result := TX2LogDictionaryDetails.CreateOwned(values);
  finally
    FreeAndNil(values);
  end;
end;


{ TX2LogBinaryDetailsSerializer }
procedure TX2LogBinaryDetailsSerializer.Serialize(ADetails: IX2LogDetails; AStream: TStream);
var
  stream: TStream;

begin
  stream := (ADetails as IX2LogDetailsBinary).AsStream;

  TStreamUtil.WriteCardinal(AStream, stream.Size);
  if stream.Size > 0 then
    AStream.CopyFrom(stream, stream.Size);
end;


function TX2LogBinaryDetailsSerializer.Deserialize(AStream: TStream): IX2LogDetails;
var
  streamSize: Cardinal;

begin
  streamSize := TStreamUtil.ReadCardinal(AStream);
  if streamSize > 0 then
    Result := TX2LogBinaryDetails.Create(AStream, streamSize)
  else
    { Do not return nil; the fact that Deserialize is called means an
      empty Details was serialized. }
    Result := TX2LogBinaryDetails.Create;
end;


{ TX2LogGraphicDetailsSerializer }
procedure TX2LogGraphicDetailsSerializer.Serialize(ADetails: IX2LogDetails; AStream: TStream);
var
  graphic: TGraphic;

begin
  graphic := (ADetails as IX2LogDetailsGraphic).AsGraphic;
  TStreamUtil.WriteString(AStream, graphic.ClassName);
  graphic.SaveToStream(AStream);
end;


function TX2LogGraphicDetailsSerializer.Deserialize(AStream: TStream): IX2LogDetails;
var
  graphicClass: TGraphicClass;
  graphic: TGraphic;

begin
  Result := nil;
  graphicClass := TGraphicClass(GetClass(TStreamUtil.ReadString(AStream)));
  if Assigned(graphicClass) then
  begin
    graphic := graphicClass.Create;
    try
      graphic.LoadFromStream(AStream);
      Result := TX2LogGraphicDetails.CreateOwned(graphic);
    except
      FreeAndNil(graphic);
      raise;
    end;
  end;
end;


{ TX2LogDictionaryValue }
constructor TX2LogDictionaryValue.Create(AValueType: TX2LogValueType; AStream: TStream; ASize: Cardinal);
begin
  inherited Create;

  FValueType := AValueType;

  if Assigned(AStream) then
    LoadFromStream(AStream, ASize);
end;


{ TX2LogDictionaryStringValue }
constructor TX2LogDictionaryStringValue.Create(const AValue: string);
begin
  inherited Create(StringValue);

  Value := AValue;
end;


procedure TX2LogDictionaryStringValue.LoadFromStream(AStream: TStream; ASize: Cardinal);
begin
  Value := TStreamUtil.ReadString(AStream, nil, False, ASize);
end;


procedure TX2LogDictionaryStringValue.SaveToStream(AStream: TStream);
begin
  TStreamUtil.WriteString(AStream, Value, nil, False);
end;


function TX2LogDictionaryStringValue.GetDisplayValue: string;
begin
  Result := Value;
end;


{ TX2LogDictionaryBooleanValue }
constructor TX2LogDictionaryBooleanValue.Create(AValue: Boolean);
begin
  inherited Create(BooleanValue);

  Value := AValue;
end;


procedure TX2LogDictionaryBooleanValue.LoadFromStream(AStream: TStream; ASize: Cardinal);
begin
  if ASize <> SizeOf(Boolean) then
    raise EInvalidOperation.CreateFmt('Size (%d) does not match Boolean', [ASize]);

  AStream.ReadBuffer(FValue, ASize);
end;


procedure TX2LogDictionaryBooleanValue.SaveToStream(AStream: TStream);
begin
  AStream.WriteBuffer(Value, SizeOf(Boolean));
end;


function TX2LogDictionaryBooleanValue.GetDisplayValue: string;
begin
  Result := BoolToStr(Value, True);
end;


{ TX2LogDictionaryIntValue }
constructor TX2LogDictionaryIntValue.Create(AValue: Int64);
begin
  inherited Create(IntValue);

  Value := AValue;
end;


procedure TX2LogDictionaryIntValue.LoadFromStream(AStream: TStream; ASize: Cardinal);
begin
  if ASize <> SizeOf(Int64) then
    raise EInvalidOperation.CreateFmt('Size (%d) does not match Int64', [ASize]);

  AStream.ReadBuffer(FValue, ASize);
end;


procedure TX2LogDictionaryIntValue.SaveToStream(AStream: TStream);
begin
  AStream.WriteBuffer(Value, SizeOf(Int64));
end;


function TX2LogDictionaryIntValue.GetDisplayValue: string;
begin
  Result := IntToStr(Value);
end;


{ TX2LogDictionaryFloatValue }
constructor TX2LogDictionaryFloatValue.Create(AValue: Extended);
begin
  inherited Create(FloatValue);

  Value := AValue;
end;


procedure TX2LogDictionaryFloatValue.LoadFromStream(AStream: TStream; ASize: Cardinal);
begin
  if ASize <> SizeOf(Extended) then
    raise EInvalidOperation.CreateFmt('Size (%d) does not match Extended', [ASize]);

  AStream.ReadBuffer(FValue, ASize);
end;


procedure TX2LogDictionaryFloatValue.SaveToStream(AStream: TStream);
begin
  AStream.WriteBuffer(Value, SizeOf(Extended));
end;


function TX2LogDictionaryFloatValue.GetDisplayValue: string;
begin
  Result := FormatFloat('0.########', Value);
end;


{ TX2LogDictionaryDateTimeValue }
constructor TX2LogDictionaryDateTimeValue.Create(AValue: TDateTime);
begin
  inherited Create(DateTimeValue);

  Value := AValue;
end;


procedure TX2LogDictionaryDateTimeValue.LoadFromStream(AStream: TStream; ASize: Cardinal);
begin
  if ASize <> SizeOf(TDateTime) then
    raise EInvalidOperation.CreateFmt('Size (%d) does not match TDateTime', [ASize]);

  AStream.ReadBuffer(FValue, ASize);
end;


procedure TX2LogDictionaryDateTimeValue.SaveToStream(AStream: TStream);
begin
  AStream.WriteBuffer(Value, SizeOf(TDateTime));
end;


function TX2LogDictionaryDateTimeValue.GetDisplayValue: string;
begin
  Result := DateTimeToStr(Value);
end;


initialization
  TX2LogDetailsRegistry.Register(StringDetailsSerializerIID, TX2LogStringDetailsSerializer.Create);
  TX2LogDetailsRegistry.Register(DictionaryDetailsSerializerIID, TX2LogDictionaryDetailsSerializer.Create);
  TX2LogDetailsRegistry.Register(BinaryDetailsSerializerIID, TX2LogBinaryDetailsSerializer.Create);
  TX2LogDetailsRegistry.Register(GraphicDetailsSerializerIID, TX2LogGraphicDetailsSerializer.Create);

end.

