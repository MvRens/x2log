unit X2Log.Details.Registry;

interface
uses
  System.Generics.Collections,

  X2Log.Intf;


type
  TSerializerDictionary = TDictionary<TGUID, IX2LogDetailsSerializer>;

  TX2LogDetailsRegistry = class(TObject)
  private
    class var FSerializers: TSerializerDictionary;
  protected
    class function Serializers: TSerializerDictionary;

    class procedure CleanupSerializers;
  public
    class procedure Register(AIID: TGUID; ASerializer: IX2LogDetailsSerializer);
    class procedure Unregister(AIID: TGUID);

    class function GetSerializer(ASerializerIID: TGUID; out ASerializer: IX2LogDetailsSerializer): Boolean; overload;
    class function GetSerializer(ADetails: IX2LogDetails; out ASerializer: IX2LogDetailsSerializer): Boolean; overload;
  end;


implementation
uses
  System.SysUtils,
  System.Types;


{ TX2LogDetailsRegistry }
class procedure TX2LogDetailsRegistry.Register(AIID: TGUID; ASerializer: IX2LogDetailsSerializer);
begin
  Serializers.Add(AIID, ASerializer);
end;


class function TX2LogDetailsRegistry.GetSerializer(ADetails: IX2LogDetails; out ASerializer: IX2LogDetailsSerializer): Boolean;
begin
  Result := Assigned(ADetails) and
            (ADetails.SerializerIID <> GUID_NULL) and
            GetSerializer(ADetails.SerializerIID, ASerializer);
end;


class procedure TX2LogDetailsRegistry.Unregister(AIID: TGUID);
begin
  Serializers.Remove(AIID);
end;


class function TX2LogDetailsRegistry.GetSerializer(ASerializerIID: TGUID; out ASerializer: IX2LogDetailsSerializer): Boolean;
begin
  Result := Serializers.TryGetValue(ASerializerIID, ASerializer);
end;


class function TX2LogDetailsRegistry.Serializers: TSerializerDictionary;
begin
  if not Assigned(FSerializers) then
    FSerializers := TSerializerDictionary.Create;

  Result := FSerializers;
end;


class procedure TX2LogDetailsRegistry.CleanupSerializers;
begin
  FreeAndNil(FSerializers);
end;


initialization
finalization
  TX2LogDetailsRegistry.CleanupSerializers;

end.
