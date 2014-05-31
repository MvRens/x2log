unit X2Log.Details.Default;

interface
uses
  System.Classes,

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


implementation
uses
  System.SysUtils,
  Vcl.ClipBrd,

  X2Log.Constants,
  X2Log.Details.Registry;


const
  StringDetailsSerializerIID: TGUID = '{4223C30E-6E80-4D66-9EDC-F8688A7413D2}';
  BinaryDetailsSerializerIID: TGUID = '{05F6E8BD-118E-41B3-B626-1F190CC2A7D3}';



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


{ TX2LogStringDetailsSerializer }
procedure TX2LogStringDetailsSerializer.Serialize(ADetails: IX2LogDetails; AStream: TStream);
var
  bytes: TBytes;
  bytesLength: Cardinal;

begin
  bytes := TEncoding.UTF8.GetBytes((ADetails as IX2LogDetailsText).AsString);
  bytesLength := Length(bytes);

  AStream.WriteBuffer(bytesLength, SizeOf(Cardinal));
  if bytesLength > 0 then
    AStream.WriteBuffer(bytes[0], bytesLength);
end;


function TX2LogStringDetailsSerializer.Deserialize(AStream: TStream): IX2LogDetails;
var
  bytes: TBytes;
  bytesLength: Cardinal;

begin
  AStream.ReadBuffer(bytesLength, SizeOf(Cardinal));
  if bytesLength > 0 then
  begin
    SetLength(bytes, bytesLength);
    AStream.ReadBuffer(bytes[0], bytesLength);

    Result := TX2LogStringDetails.Create(TEncoding.UTF8.GetString(bytes));
  end else
    { Do not return nil; the fact that Deserialize is called means an
      empty Details was serialized. }
    Result := TX2LogStringDetails.Create('');
end;


{ TX2LogBinaryDetailsSerializer }
procedure TX2LogBinaryDetailsSerializer.Serialize(ADetails: IX2LogDetails; AStream: TStream);
var
  stream: TStream;
  streamSize: Cardinal;

begin
  stream := (ADetails as IX2LogDetailsBinary).AsStream;
  streamSize := stream.Size;

  AStream.WriteBuffer(streamSize, SizeOf(Cardinal));
  if streamSize > 0 then
    AStream.CopyFrom(stream, streamSize);
end;


function TX2LogBinaryDetailsSerializer.Deserialize(AStream: TStream): IX2LogDetails;
var
  streamSize: Cardinal;

begin
  AStream.ReadBuffer(streamSize, SizeOf(Cardinal));
  if streamSize > 0 then
    Result := TX2LogBinaryDetails.Create(AStream, streamSize)
  else
    { Do not return nil; the fact that Deserialize is called means an
      empty Details was serialized. }
    Result := TX2LogBinaryDetails.Create;
end;


initialization
  TX2LogDetailsRegistry.Register(StringDetailsSerializerIID, TX2LogStringDetailsSerializer.Create);
  TX2LogDetailsRegistry.Register(BinaryDetailsSerializerIID, TX2LogBinaryDetailsSerializer.Create);

end.

