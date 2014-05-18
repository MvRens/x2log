unit X2Log.Observer.Event;

interface
uses
  X2Log.Intf,
  X2Log.Observer.Custom;


type
  TX2LogEvent = procedure(Sender: TObject; Level: TX2LogLevel; const Msg, Details: string) of object;


  TX2LogEventObserver = class(TX2LogCustomObserver)
  private
    FOnLog: TX2LogEvent;
  protected
    procedure DoLog(ALevel: TX2LogLevel; const AMessage: string; const ADetails: string = ''); override;
  public
    constructor Create(ALogLevels: TX2LogLevels = X2LogLevelsDefault); overload;
    constructor Create(AOnLog: TX2LogEvent; ALogLevels: TX2LogLevels = X2LogLevelsDefault); overload;

    property OnLog: TX2LogEvent read FOnLog write FOnLog;
  end;


implementation


{ TX2LogEventObserver }
constructor TX2LogEventObserver.Create(ALogLevels: TX2LogLevels);
begin
  inherited Create(ALogLevels);
end;


constructor TX2LogEventObserver.Create(AOnLog: TX2LogEvent; ALogLevels: TX2LogLevels);
begin
  Create(ALogLevels);

  FOnLog := AOnLog;
end;


procedure TX2LogEventObserver.DoLog(ALevel: TX2LogLevel; const AMessage, ADetails: string);
begin
  if Assigned(FOnLog) then
    FOnLog(Self, ALevel, AMessage, ADetails);
end;

end.
