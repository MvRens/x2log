unit X2Log.Global;

interface
uses
  System.SysUtils,

  X2Log,
  X2Log.Intf;


type
  TX2GlobalLog = class(TObject)
  private
    class var FInstance: IX2Log;
  protected
    class procedure CleanupInstance;
  public
    class function Instance: IX2Log;

    { Facade for IX2Log }
    class procedure Attach(AObserver: IX2LogObserver);
    class procedure Detach(AObserver: IX2LogObserver);

    class procedure SetExceptionStrategy(AStrategy: IX2LogExceptionStrategy);

    { Facade for IX2LogBase }
    class procedure Log(ALevel: TX2LogLevel; const AMessage: string; const ACategory: string = ''; ADetails: IX2LogDetails = nil); overload;
    class procedure Log(ALevel: TX2LogLevel; ADateTime: TDateTime; const AMessage: string; const ACategory: string = ''; ADetails: IX2LogDetails = nil); overload;

    class function Category(const ACategory: string): IX2Log;

    class procedure Verbose(const AMessage: string; const ADetails: string = '');
    class procedure VerboseEx(const AMessage: string; ADetails: IX2LogDetails = nil);

    class procedure Info(const AMessage: string; const ADetails: string = '');
    class procedure InfoEx(const AMessage: string; ADetails: IX2LogDetails = nil);

    class procedure Warning(const AMessage: string; const ADetails: string = '');
    class procedure WarningEx(const AMessage: string; ADetails: IX2LogDetails = nil);

    class procedure Error(const AMessage: string; const ADetails: string = '');
    class procedure ErrorEx(const AMessage: string; ADetails: IX2LogDetails = nil);

    class procedure Exception(AException: Exception; const AMessage: string = '');
  end;


implementation
uses
  X2Log.Details.Default;


{ TX2GlobalLog }
class function TX2GlobalLog.Instance: IX2Log;
begin
  if not Assigned(FInstance) then
    FInstance := TX2Log.Create;

  Result := FInstance;
end;


class procedure TX2GlobalLog.CleanupInstance;
begin
  FInstance := nil;
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


class function TX2GlobalLog.Category(const ACategory: string): IX2Log;
begin
  Result := Instance.Category(ACategory);
end;


class procedure TX2GlobalLog.Log(ALevel: TX2LogLevel; const AMessage, ACategory: string; ADetails: IX2LogDetails);
begin
  Instance.Log(ALevel, AMessage, ACategory, ADetails);
end;


class procedure TX2GlobalLog.Log(ALevel: TX2LogLevel; ADateTime: TDateTime; const AMessage, ACategory: string; ADetails: IX2LogDetails);
begin
  Instance.Log(ALevel, ADateTime, AMessage, ACategory, ADetails);
end;


class procedure TX2GlobalLog.Verbose(const AMessage, ADetails: string);
begin
  Instance.Verbose(AMessage, ADetails);
end;


class procedure TX2GlobalLog.VerboseEx(const AMessage: string; ADetails: IX2LogDetails);
begin
  Instance.VerboseEx(AMessage, ADetails);
end;


class procedure TX2GlobalLog.Info(const AMessage, ADetails: string);
begin
  Instance.Info(AMessage, ADetails);
end;


class procedure TX2GlobalLog.InfoEx(const AMessage: string; ADetails: IX2LogDetails);
begin
  Instance.InfoEx(AMessage, ADetails);
end;


class procedure TX2GlobalLog.Warning(const AMessage, ADetails: string);
begin
  Instance.Warning(AMessage, ADetails);
end;


class procedure TX2GlobalLog.WarningEx(const AMessage: string; ADetails: IX2LogDetails);
begin
  Instance.WarningEx(AMessage, ADetails);
end;


class procedure TX2GlobalLog.Error(const AMessage, ADetails: string);
begin
  Instance.Error(AMessage, ADetails);
end;


class procedure TX2GlobalLog.ErrorEx(const AMessage: string; ADetails: IX2LogDetails);
begin
  Instance.ErrorEx(AMessage, ADetails);
end;


class procedure TX2GlobalLog.Exception(AException: Exception; const AMessage: string);
begin
  Instance.Exception(AException, AMessage);
end;


initialization
finalization
  TX2GlobalLog.CleanupInstance;

end.
