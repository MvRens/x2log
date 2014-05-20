unit X2Log.Global;

interface
uses
  System.SysUtils,

  X2Log.Intf;


type
  TX2GlobalLog = class(TObject)
  private class var
    FInstance: IX2Log;
  protected
    class procedure CleanupInstance;
  public
    class function Instance: IX2Log;

    { Facade for IX2Log }
    class procedure Attach(AObserver: IX2LogObserver);
    class procedure Detach(AObserver: IX2LogObserver);

    class procedure SetExceptionStrategy(AStrategy: IX2LogExceptionStrategy);

    { Facade for IX2LogMethods }
    class procedure Log(ALevel: TX2LogLevel; const AMessage: string; const ADetails: string = '');

    class procedure Verbose(const AMessage: string; const ADetails: string = '');
    class procedure Info(const AMessage: string; const ADetails: string = '');
    class procedure Warning(const AMessage: string; const ADetails: string = '');
    class procedure Error(const AMessage: string; const ADetails: string = '');
    class procedure Exception(AException: Exception; const AMessage: string = ''; const ADetails: string = '');
  end;


implementation
uses
  X2Log;


{ TX2GlobalLog }
class function TX2GlobalLog.Instance: IX2Log;
begin
  if not Assigned(FInstance) then
    FInstance := TX2Log.Create;

  Result := FInstance;
end;


class procedure TX2GlobalLog.CleanupInstance;
begin
  if Assigned(FInstance) then
    FreeAndNil(FInstance);
end;


class procedure TX2GlobalLog.Attach(AObserver: IX2LogObserver);
begin
  Instance.Attach(AObserver);
end;


class procedure TX2GlobalLog.Detach(AObserver: IX2LogObserver);
begin
  instance.Detach(AObserver);
end;


class procedure TX2GlobalLog.SetExceptionStrategy(AStrategy: IX2LogExceptionStrategy);
begin
  Instance.SetExceptionStrategy(AStrategy);
end;


class procedure TX2GlobalLog.Log(ALevel: TX2LogLevel; const AMessage, ADetails: string);
begin
  Instance.Log(ALevel, AMessage, ADetails);
end;


class procedure TX2GlobalLog.Verbose(const AMessage, ADetails: string);
begin
  Instance.Verbose(AMessage, ADetails);
end;


class procedure TX2GlobalLog.Info(const AMessage, ADetails: string);
begin
  Instance.Info(AMessage, ADetails);
end;


class procedure TX2GlobalLog.Warning(const AMessage, ADetails: string);
begin
  Instance.Warning(AMessage, ADetails);
end;


class procedure TX2GlobalLog.Error(const AMessage, ADetails: string);
begin
  Instance.Error(AMessage, ADetails);
end;


class procedure TX2GlobalLog.Exception(AException: Exception; const AMessage, ADetails: string);
begin
  Instance.Exception(AException, AMessage, ADetails);
end;


initialization
finalization
  TX2GlobalLog.CleanupInstance;

end.
