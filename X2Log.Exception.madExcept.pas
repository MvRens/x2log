unit X2Log.Exception.madExcept;

interface
uses
  System.SysUtils,

  X2Log.Intf,
  X2Log.Exception.Default;


type
  TX2LogmadExceptExceptionStrategy = class(TX2LogDefaultExceptionStrategy)
  public
    { IX2LogExceptionStrategy }
    procedure Execute(AException: Exception; var AMessage: string; var ADetails: string); override;
  end;


implementation
uses
  madExcept;


{ TX2LogmadExceptExceptionStrategy }
procedure TX2LogmadExceptExceptionStrategy.Execute(AException: Exception; var AMessage, ADetails: string);
begin
  inherited Execute(AException, AMessage, ADetails);

  if Length(ADetails) > 0 then
    ADetails := ADetails + #13#10;

  ADetails := ADetails + madExcept.CreateBugReport(etNormal, AException);
end;

end.
