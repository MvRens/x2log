unit X2Log.Observer.CustomThreaded;

interface
uses
  System.Classes,
  System.Generics.Collections,
  System.SyncObjs,

  X2Log.Intf,
  X2Log.Observer.Custom;


type
  TX2LogObserverWorkerThread = class;


  TX2LogCustomThreadedObserver = class(TX2LogCustomObserver)
  private
    FWorkerThread: TX2LogObserverWorkerThread;
  protected
    function CreateWorkerThread: TX2LogObserverWorkerThread; virtual; abstract;

    procedure DoLog(ALevel: TX2LogLevel; ADateTime: TDateTime; const AMessage: string; ADetails: IX2LogDetails); override;

    property WorkerThread: TX2LogObserverWorkerThread read FWorkerThread;
  public
    constructor Create(ALogLevels: TX2LogLevels = X2LogLevelsDefault);
    destructor Destroy; override;
  end;


  TX2LogQueueEntry = class(TPersistent)
  private
    FDetails: IX2LogDetails;
    FLevel: TX2LogLevel;
    FDateTime: TDateTime;
    FMessage: string;
  public
    constructor Create(ALevel: TX2LogLevel; ADateTime: TDateTime; const AMessage: string; ADetails: IX2LogDetails); overload;
    constructor Create(AEntry: TX2LogQueueEntry); overload;

    procedure Assign(Source: TPersistent); override;

    property DateTime: TDateTime read FDateTime;
    property Details: IX2LogDetails read FDetails;
    property Level: TX2LogLevel read FLevel;
    property Message: string read FMessage;
  end;


  TX2LogObserverWorkerThread = class(TThread)
  private
    FFileName: string;
    FLogQueue: TObjectQueue<TX2LogQueueEntry>;
    FLogQueueSignal: TEvent;
    FThreadStartSignal: TEvent;
  protected
    procedure Execute; override;
    procedure TerminatedSet; override;

    procedure Setup; virtual;
    procedure Cleanup; virtual;

    procedure WaitForEntry; virtual;
    procedure ProcessEntry(AEntry: TX2LogQueueEntry); virtual; abstract;

    property FileName: string read FFileName;
    property LogQueue: TObjectQueue<TX2LogQueueEntry> read FLogQueue;
    property LogQueueSignal: TEvent read FLogQueueSignal;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Log(ALevel: TX2LogLevel; ADateTime: TDateTime; const AMessage: string; ADetails: IX2LogDetails);
  end;


implementation
uses
  System.SysUtils;


{ TX2LogCustomThreadedObserver }
constructor TX2LogCustomThreadedObserver.Create(ALogLevels: TX2LogLevels);
begin
  inherited Create(ALogLevels);

  FWorkerThread := CreateWorkerThread;
end;


destructor TX2LogCustomThreadedObserver.Destroy;
begin
  FreeAndNil(FWorkerThread);

  inherited Destroy;
end;


procedure TX2LogCustomThreadedObserver.DoLog(ALevel: TX2LogLevel; ADateTime: TDateTime; const AMessage: string; ADetails: IX2LogDetails);
begin
  WorkerThread.Log(ALevel, ADateTime, AMessage, ADetails);
end;



{ TX2LogQueueEntry }
constructor TX2LogQueueEntry.Create(ALevel: TX2LogLevel; ADateTime: TDateTime; const AMessage: string; ADetails: IX2LogDetails);
begin
  inherited Create;

  FLevel := ALevel;
  FDateTime := ADateTime;
  FMessage := AMessage;
  FDetails := ADetails;
end;


constructor TX2LogQueueEntry.Create(AEntry: TX2LogQueueEntry);
begin
  inherited Create;

  Assign(AEntry);
end;


procedure TX2LogQueueEntry.Assign(Source: TPersistent);
var
  entrySource: TX2LogQueueEntry;

begin
  if Source is TX2LogQueueEntry then
  begin
    entrySource := TX2LogQueueEntry(Source);

    FLevel := entrySource.Level;
    FDateTime := entrySource.DateTime;
    FMessage := entrySource.Message;
    FDetails := entrySource.Details;
  end else
    inherited Assign(Source);
end;


{ TX2LogObserverWorkerThread }
constructor TX2LogObserverWorkerThread.Create;
begin
  FThreadStartSignal := TEvent.Create(nil, True, False, '');
  FLogQueueSignal := TEvent.Create(nil, False, False, '');
  FLogQueue := TObjectQueue<TX2LogQueueEntry>.Create(True);

  inherited Create(False);
end;


destructor TX2LogObserverWorkerThread.Destroy;
begin
  { For very short-lived observers (for example, the "Save as" functionality
    of the observer form) the WorkerThread can be destroyed before the thread
    has a chance to properly start and clear out it's queue. }
  FThreadStartSignal.WaitFor(INFINITE);

  inherited Destroy;

  FreeAndNil(FLogQueue);
  FreeAndNil(FLogQueueSignal);
  FreeAndNil(FThreadStartSignal);
end;


procedure TX2LogObserverWorkerThread.Log(ALevel: TX2LogLevel; ADateTime: TDateTime; const AMessage: string; ADetails: IX2LogDetails);
begin
  TMonitor.Enter(LogQueue);
  try
    LogQueue.Enqueue(TX2LogQueueEntry.Create(ALevel, ADateTime, AMessage, ADetails));
  finally
    TMonitor.Exit(LogQueue);
  end;

  LogQueueSignal.SetEvent;
end;


procedure TX2LogObserverWorkerThread.Execute;
var
  entry: TX2LogQueueEntry;

begin
  FThreadStartSignal.SetEvent;
  NameThreadForDebugging('TX2LogObserverWorkerThread');

  Setup;
  try
    while True do
    begin
      { When Terminated, flush the queue }
      if not Terminated then
        WaitForEntry;

      entry := nil;
      TMonitor.Enter(LogQueue);
      try
        if LogQueue.Count > 0 then
          entry := LogQueue.Extract;
      finally
        TMonitor.Exit(LogQueue);
      end;

      if Assigned(entry) then
      try
        ProcessEntry(entry);
      finally
        FreeAndNil(entry);
      end else if Terminated then
        break;
    end;
  finally
    Cleanup;
  end;
end;


procedure TX2LogObserverWorkerThread.Setup;
begin
end;


procedure TX2LogObserverWorkerThread.Cleanup;
begin
end;


procedure TX2LogObserverWorkerThread.WaitForEntry;
begin
  case LogQueueSignal.WaitFor(INFINITE) of
    wrAbandoned,
    wrError:
      Terminate;
  end;
end;


procedure TX2LogObserverWorkerThread.TerminatedSet;
begin
  LogQueueSignal.SetEvent;

  inherited TerminatedSet;
end;

end.
