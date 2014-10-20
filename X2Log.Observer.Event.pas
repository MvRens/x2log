unit X2Log.Observer.Event;

interface
uses
  X2Log.Intf,
  X2Log.Observer.Custom;


type
  TX2LogEvent = procedure(Sender: TObject; Level: TX2LogLevel; DateTime: TDateTime; const Msg, Category: string; Details: IX2LogDetails) of object;


  TX2LogEventObserver = class(TX2LogCustomObserver)
  private
    FOnLog: TX2LogEvent;
    FRunInMainThread: Boolean;
  protected
    procedure DoLog(ALevel: TX2LogLevel; ADateTime: TDateTime; const AMessage, ACategory: string; ADetails: IX2LogDetails); override;
  public
    constructor Create(ALogLevels: TX2LogLevels = X2LogLevelsDefault); overload;
    constructor Create(AOnLog: TX2LogEvent; ALogLevels: TX2LogLevels = X2LogLevelsDefault); overload;

    property RunInMainThread: Boolean read FRunInMainThread write FRunInMainThread default True;

    property OnLog: TX2LogEvent read FOnLog write FOnLog;
  end;


implementation
uses
  System.Classes;


{ TX2LogEventObserver }
constructor TX2LogEventObserver.Create(ALogLevels: TX2LogLevels);
begin
  inherited Create(ALogLevels);

  FRunInMainThread := True;
end;


constructor TX2LogEventObserver.Create(AOnLog: TX2LogEvent; ALogLevels: TX2LogLevels);
begin
  Create(ALogLevels);

  FOnLog := AOnLog;
end;


procedure TX2LogEventObserver.DoLog(ALevel: TX2LogLevel; ADateTime: TDateTime; const AMessage, ACategory: string; ADetails: IX2LogDetails);
begin
  if Assigned(FOnLog) then
  begin
    if RunInMainThread then
    begin
      TThread.Queue(nil,
        procedure
        begin
          if Assigned(FOnLog) then
            FOnLog(Self, ALevel, ADateTime, AMessage, ACategory, ADetails);
        end);
    end else
      FOnLog(Self, ALevel, ADateTime, AMessage, ACategory, ADetails);
  end;
end;

end.
