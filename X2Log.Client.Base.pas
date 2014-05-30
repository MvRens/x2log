unit X2Log.Client.Base;

interface
uses
  System.Classes,
  System.Generics.Collections,

  X2Log.Intf;


type
  TX2LogBaseClient = class(TInterfacedPersistent, IX2LogBase, IX2LogObservable)
  private
    FObservers: TList<IX2LogObserver>;
  protected
    property Observers: TList<IX2LogObserver> read FObservers;
  public
    constructor Create;
    destructor Destroy; override;

    { IX2LogBase }
    procedure Log(ALevel: TX2LogLevel; const AMessage: string; ADetails: IX2LogDetails = nil); virtual;


    { IX2LogObservable }
    procedure Attach(AObserver: IX2LogObserver);
    procedure Detach(AObserver: IX2LogObserver);
  end;


implementation
uses
  System.SysUtils;


{ TX2LogBaseClient }
constructor TX2LogBaseClient.Create;
begin
  inherited Create;

  FObservers := TList<IX2LogObserver>.Create;
end;


destructor TX2LogBaseClient.Destroy;
begin
  FreeAndNil(FObservers);

  inherited Destroy;
end;


procedure TX2LogBaseClient.Attach(AObserver: IX2LogObserver);
begin
  { Explicit cast ensures we're getting the same pointer in Attach and Detach
    if, for example, the implementing interface is a descendant of IX2LogObserver }
  Observers.Add(AObserver as IX2LogObserver);
end;


procedure TX2LogBaseClient.Detach(AObserver: IX2LogObserver);
begin
  Observers.Remove(AObserver as IX2LogObserver);
end;


procedure TX2LogBaseClient.Log(ALevel: TX2LogLevel; const AMessage: string; ADetails: IX2LogDetails);
var
  observer: IX2LogObserver;

begin
  for observer in Observers do
    observer.Log(ALevel, AMessage, ADetails);
end;

end.

