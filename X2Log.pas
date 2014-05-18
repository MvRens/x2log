unit X2Log;

interface
uses
  System.Classes,
  System.Generics.Collections,
  System.SysUtils,

  X2Log.Intf;


type
  TX2Log = class(TInterfacedObject, IX2Log, IX2LogMethods)
  private
    FExceptionStrategy: IX2LogExceptionStrategy;
    FObservers: TList<IX2LogObserver>;
  private
    property ExceptionStrategy: IX2LogExceptionStrategy read FExceptionStrategy;
    property Observers: TList<IX2LogObserver> read FObservers;
  public
    constructor Create;
    destructor Destroy; override;

    { IX2Log }
    procedure Attach(AObserver: IX2LogObserver);
    procedure Detach(AObserver: IX2LogObserver);

    procedure SetExceptionStrategy(AStrategy: IX2LogExceptionStrategy);

    { IX2LogMethods }
    procedure Log(ALevel: TX2LogLevel; const AMessage: string; const ADetails: string = '');

    procedure Verbose(const AMessage: string; const ADetails: string = '');
    procedure Info(const AMessage: string; const ADetails: string = '');
    procedure Warning(const AMessage: string; const ADetails: string = '');
    procedure Error(const AMessage: string; const ADetails: string = '');
    procedure Exception(AException: Exception; const AMessage: string = ''; const ADetails: string = '');
  end;
  

implementation
uses
  X2Log.Exception.Default;


{ TX2Log }
constructor TX2Log.Create;
begin
  inherited Create;

  FObservers := TList<IX2LogObserver>.Create;
  SetExceptionStrategy(nil);
end;


destructor TX2Log.Destroy;
begin
  FreeAndNil(FObservers);

  inherited Destroy;
end;


procedure TX2Log.Attach(AObserver: IX2LogObserver);
begin
  { Explicit cast ensures we're getting the same pointer in Attach and Detach
    if, for example, the implementing interface is a descendant of IX2LogObserver }
  Observers.Add(AObserver as IX2LogObserver);
end;


procedure TX2Log.Detach(AObserver: IX2LogObserver);
begin
  Observers.Remove(AObserver as IX2LogObserver);
end;


procedure TX2Log.SetExceptionStrategy(AStrategy: IX2LogExceptionStrategy);
begin
  if Assigned(AStrategy) then
    FExceptionStrategy := AStrategy
  else
    FExceptionStrategy := TX2LogDefaultExceptionStrategy.Create;
end;


procedure TX2Log.Log(ALevel: TX2LogLevel; const AMessage, ADetails: string);
var
  observer: IX2LogObserver;

begin
  for observer in Observers do
    observer.Log(ALevel, AMessage, ADetails);
end;


procedure TX2Log.Verbose(const AMessage, ADetails: string);
begin
  Log(TX2LogLevel.Verbose, AMessage, ADetails);
end;


procedure TX2Log.Info(const AMessage, ADetails: string);
begin
  Log(TX2LogLevel.Info, AMessage, ADetails);
end;


procedure TX2Log.Warning(const AMessage, ADetails: string);
begin
  Log(TX2LogLevel.Warning, AMessage, ADetails);
end;


procedure TX2Log.Error(const AMessage, ADetails: string);
begin
  Log(TX2LogLevel.Error, AMessage, ADetails);
end;


procedure TX2Log.Exception(AException: Exception; const AMessage, ADetails: string);
var
  msg: string;
  details: string;

begin
  msg := AMessage;
  details := ADetails;

  ExceptionStrategy.Execute(AException, msg, details);
  Log(TX2LogLevel.Error, msg, details);
end;

end.
