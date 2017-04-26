unit X2Log.Exception.Default;

interface
uses
  System.SysUtils,

  X2Log.Intf;


type
  TX2LogDefaultExceptionStrategy = class(TInterfacedObject, IX2LogExceptionStrategy)
  public
    { IX2LogExceptionStrategy }
    procedure Execute(AException: Exception; out AMessage: string; AAddDetails: TX2LogExceptionDetailsProc); virtual;
  end;


implementation


{ TX2LogDefaultExceptionStrategy }
procedure TX2LogDefaultExceptionStrategy.Execute(AException: Exception; out AMessage: string; AAddDetails: TX2LogExceptionDetailsProc);
begin
  AMessage := AException.Message;
end;

end.
