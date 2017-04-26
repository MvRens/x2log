unit X2Log.Exception.madExceptHandler;

interface
uses
  System.SysUtils,

  X2Log.Intf,
  X2Log.Exception.Default;


type
  TX2LogmadExceptExceptionStrategy = class(TX2LogDefaultExceptionStrategy)
  public
    { IX2LogExceptionStrategy }
    procedure Execute(AException: Exception; out AMessage: string; AAddDetails: TX2LogExceptionDetailsProc); override;
  end;


implementation
uses
  madExcept,

  X2Log.Details.Default;


{ TX2LogmadExceptExceptionStrategy }
procedure TX2LogmadExceptExceptionStrategy.Execute(AException: Exception; out AMessage: string; AAddDetails: TX2LogExceptionDetailsProc);
var
  bugReport: string;

begin
  inherited Execute(AException, AMessage, AAddDetails);

  bugReport := madExcept.CreateBugReport(etNormal, AException);
  if Length(bugReport) > 0 then
    AAddDetails('StackTrace', bugReport);
end;

end.
