unit X2Log.Details.Default;

interface
uses
  System.Classes,
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
  BinaryDetailsSerializerIID: TGUID = '{05F6E8BD-118E-41B3-B626-1F190CC2A7D3}';
  GraphicDetailsSerializerIID: TGUID = '{BD31E42A-83DC-4947-A862-79ABAE8D5056}';



type
  TX2LogStringDetailsSerializer = class(TInterfacedObject, IX2LogDetailsSerializer)
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


initialization
  TX2LogDetailsRegistry.Register(StringDetailsSerializerIID, TX2LogStringDetailsSerializer.Create);
  TX2LogDetailsRegistry.Register(BinaryDetailsSerializerIID, TX2LogBinaryDetailsSerializer.Create);
  TX2LogDetailsRegistry.Register(GraphicDetailsSerializerIID, TX2LogGraphicDetailsSerializer.Create);

end.

