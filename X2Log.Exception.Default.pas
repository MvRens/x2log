unit X2Log.Exception.Default;

interface
uses
  System.SysUtils,

  X2Log.Intf;


type
  TX2LogDefaultExceptionStrategy = class(TInterfacedObject, IX2LogExceptionStrategy)
  public
    { IX2LogExceptionStrategy }
    procedure Execute(AException: Exception; var AMessage: string; var ADetails: IX2LogDetails); virtual;
  end;


implementation


{ TX2LogDefaultExceptionStrategy }
procedure TX2LogDefaultExceptionStrategy.Execute(AException: Exception; var AMessage: string; var ADetails: IX2LogDetails);
begin
  if Length(AMessage) > 0 then
    AMessage := AMessage + ': ';

  AMessage := AMessage + AException.Message;
end;

end.
