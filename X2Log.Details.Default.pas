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
    constructor Create(ACopyFrom: TStream); overload;
    constructor Create(AData: RawByteString); overload;
    destructor Destroy; override;

    { IX2LogDetailsBinary }
    function GetAsStream: TStream;

    { IX2LogDetailsStreamable }
    procedure SaveToStream(AStream: TStream);
  end;


implementation
uses
  System.SysUtils,
  Vcl.ClipBrd;


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
  textStream: TStringStream;

begin
  textStream := TStringStream.Create(GetAsString, TEncoding.ANSI, False);
  try
    AStream.CopyFrom(textStream, 0);
  finally
    FreeAndNil(textStream);
  end;
end;


{ TX2LogBinaryDetails }
constructor TX2LogBinaryDetails.Create(ACopyFrom: TStream);
begin
  inherited Create;

  FData := TMemoryStream.Create;
  FData.CopyFrom(ACopyFrom, ACopyFrom.Size - ACopyFrom.Position);
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


function TX2LogBinaryDetails.GetAsStream: TStream;
begin
  Data.Position := 0;
  Result := Data;
end;


procedure TX2LogBinaryDetails.SaveToStream(AStream: TStream);
begin
  AStream.CopyFrom(Data, 0);
end;

end.
