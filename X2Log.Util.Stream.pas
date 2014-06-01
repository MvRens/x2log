unit X2Log.Util.Stream;

interface
uses
  System.Classes,
  System.SysUtils;

type
  TStreamUtil = class(TObject)
  protected
    class function GetEncoding(AEncoding: TEncoding): TEncoding;
  public
    class function ReadCardinal(AStream: TStream): Cardinal;
    class procedure WriteCardinal(AStream: TStream; AValue: Cardinal);

    class function ReadString(AStream: TStream; AEncoding: TEncoding = nil): string;
    class procedure WriteString(AStream: TStream; const AValue: string; AEncoding: TEncoding = nil);
  end;

implementation


{ TStreamUtil }
class function TStreamUtil.GetEncoding(AEncoding: TEncoding): TEncoding;
begin
  if Assigned(AEncoding) then
    Result := AEncoding
  else
    Result := TEncoding.UTF8;
end;


class function TStreamUtil.ReadCardinal(AStream: TStream): Cardinal;
begin
  AStream.ReadBuffer(Result, SizeOf(Cardinal));
end;


class procedure TStreamUtil.WriteCardinal(AStream: TStream; AValue: Cardinal);
begin
  AStream.WriteBuffer(AValue, SizeOf(Cardinal));
end;


class function TStreamUtil.ReadString(AStream: TStream; AEncoding: TEncoding): string;
var
  bytes: TBytes;
  bytesLength: Cardinal;

begin
  bytesLength := ReadCardinal(AStream);
  if bytesLength > 0 then
  begin
    SetLength(bytes, bytesLength);
    AStream.ReadBuffer(bytes[0], bytesLength);

    Result := GetEncoding(AEncoding).GetString(bytes);
  end else
    Result := '';
end;


class procedure TStreamUtil.WriteString(AStream: TStream; const AValue: string; AEncoding: TEncoding);
var
  bytes: TBytes;
  bytesLength: Cardinal;

begin
  bytes := GetEncoding(AEncoding).GetBytes(AValue);
  bytesLength := Length(bytes);

  WriteCardinal(AStream, bytesLength);
  if bytesLength > 0 then
    AStream.WriteBuffer(bytes[0], bytesLength);
end;

end.
