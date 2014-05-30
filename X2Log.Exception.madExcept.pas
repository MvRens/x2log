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
    procedure Execute(AException: Exception; var AMessage: string; var ADetails: IX2LogDetails); override;
  end;


implementation
uses
  madExcept,

  X2Log.Details.Default;


{ TX2LogmadExceptExceptionStrategy }
procedure TX2LogmadExceptExceptionStrategy.Execute(AException: Exception; var AMessage: string; var ADetails: IX2LogDetails);
begin
  inherited Execute(AException, AMessage, ADetails);

  ADetails := TX2LogStringDetails.CreateIfNotEmpty(madExcept.CreateBugReport(etNormal, AException));
end;

end.
