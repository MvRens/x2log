unit X2Log.Observer.NamedPipe;

interface
uses
  X2Log.Intf,
  X2Log.Observer.Custom,
  X2Log.Observer.CustomThreaded;


type
  TX2LogNamedPipeObserver = class(TX2LogCustomThreadedObserver)
  private
    FPipeName: string;
  protected
    function CreateWorkerThread: TX2LogObserverWorkerThread; override;
  public
    constructor Create(const APipeName: string; ALogLevels: TX2LogLevels = X2LogLevelsDefault);
  end;


implementation
uses
  System.Generics.Collections,
  System.SyncObjs,
  System.SysUtils,
  Winapi.Windows;


type
  EX2LogSilentException = class(Exception);
  EX2LogPipeDisconnected = class(EX2LogSilentException);

  TX2LogNamedPipeClientState = (Listening, Connected, Writing);

  TX2LogNamedPipeClient = class(TObject)
  private
    FOverlapped: TOverlapped;
    FPipe: THandle;
    FState: TX2LogNamedPipeClientState;
    FOverlappedEvent: TEvent;
    FWriteQueue: TObjectQueue<TX2LogQueueEntry>;
    FWriteBuffer: Pointer;
    FWriteBufferSize: Integer;
  protected
    function DoSend(AEntry: TX2LogQueueEntry): Boolean;
    procedure ClearWriteBuffer;
  public
    constructor Create(APipe: THandle);
    destructor Destroy; override;

    procedure Send(AEntry: TX2LogQueueEntry);
    procedure SendNext;

    procedure Disconnect;

    property Pipe: THandle read FPipe;
    property Overlapped: TOverlapped read FOverlapped;
    property OverlappedEvent: TEvent read FOverlappedEvent;
    property State: TX2LogNamedPipeClientState read FState write FState;
  end;


  TX2LogNamedPipeWorkerThread = class(TX2LogObserverWorkerThread)
  private
    FClients: TObjectList<TX2LogNamedPipeClient>;
    FPipeName: string;
  protected

    procedure WaitForEntry; override;
    procedure ProcessEntry(AEntry: TX2LogQueueEntry); override;
    procedure ProcessClientEvent(AClientIndex: Integer);

    procedure AddListener;
    procedure RemoveClient(AClientIndex: Integer);
    procedure Setup; override;
    procedure Cleanup; override;

    property Clients: TObjectList<TX2LogNamedPipeClient> read FClients;
    property PipeName: string read FPipeName;
  public
    constructor Create(const APipeName: string);
    destructor Destroy; override;
  end;


{ TX2LogNamedPipeObserver }
constructor TX2LogNamedPipeObserver.Create(const APipeName: string; ALogLevels: TX2LogLevels);
begin
  FPipeName := APipeName;

  inherited Create(ALogLevels);
end;


function TX2LogNamedPipeObserver.CreateWorkerThread: TX2LogObserverWorkerThread;
begin
  Result := TX2LogNamedPipeWorkerThread.Create(FPipeName);
end;


{ TX2LogNamedPipeClient }
constructor TX2LogNamedPipeClient.Create(APipe: THandle);
begin
  inherited Create;

  FPipe := APipe;
  FState := Listening;

  FOverlappedEvent := TEvent.Create(nil, False, False, '');
  FOverlapped.hEvent := FOverlappedEvent.Handle;
end;


destructor TX2LogNamedPipeClient.Destroy;
begin
  FreeAndNil(FOverlappedEvent);

  if FPipe <> INVALID_HANDLE_VALUE then
    DisconnectNamedPipe(FPipe);

  ClearWriteBuffer;

  inherited Destroy;
end;


procedure TX2LogNamedPipeClient.Send(AEntry: TX2LogQueueEntry);
begin
  if not Assigned(FWriteBuffer) then
    DoSend(AEntry)
  else
  begin
    if not Assigned(FWriteQueue) then
      FWriteQueue := TObjectQueue<TX2LogQueueEntry>.Create(True);

    FWriteQueue.Enqueue(TX2LogQueueEntry.Create(AEntry));
  end;
end;


procedure TX2LogNamedPipeClient.SendNext;
var
  entry: TX2LogQueueEntry;

begin
  ClearWriteBuffer;

  while FWriteQueue.Count > 0 do
  begin
    entry := FWriteQueue.Extract;
    try
      { Returns False when IO is pending }
      if not DoSend(entry) then
        break;
    finally
      FreeAndNil(entry);
    end;
  end;
end;


procedure TX2LogNamedPipeClient.Disconnect;
begin
  if FPipe <> INVALID_HANDLE_VALUE then
  begin
    CancelIo(FPipe);
    DisconnectNamedPipe(FPipe);

    FPipe := INVALID_HANDLE_VALUE;
  end;
end;


function TX2LogNamedPipeClient.DoSend(AEntry: TX2LogQueueEntry): Boolean;

  procedure AppendToBuffer(var APointer: PByte; const ASource; ASize: Cardinal); overload; inline;
  begin
    Move(ASource, APointer^, ASize);
    Inc(APointer, ASize);
  end;

  procedure AppendToBuffer(var APointer: PByte; const ASource: string); overload; inline;
  var
    sourceLength: Cardinal;

  begin
    sourceLength := Length(ASource);
    AppendToBuffer(APointer, sourceLength, SizeOf(Cardinal));
    AppendToBuffer(APointer, PChar(ASource)^, sourceLength * SizeOf(Char));
  end;


var
  bytesWritten: Cardinal;
  bufferPointer: PByte;
  lastError: Cardinal;

begin
  ClearWriteBuffer;

  FWriteBufferSize := SizeOf(TX2LogLevel) +
                      SizeOf(Cardinal) + (Length(AEntry.Message) * SizeOf(Char)) +
                      SizeOf(Cardinal) + (Length(AEntry.Details) * SizeOf(Char));

  GetMem(FWriteBuffer, FWriteBufferSize);

  bufferPointer := FWriteBuffer;
  AppendToBuffer(bufferPointer, AEntry.Level, SizeOf(TX2LogLevel));
  AppendToBuffer(bufferPointer, AEntry.Message);
  AppendToBuffer(bufferPointer, AEntry.Details);

  Result := WriteFile(Pipe, FWriteBuffer^, FWriteBufferSize, bytesWritten, @Overlapped);
  if not Result then
  begin
    lastError := GetLastError;
    if lastError in [ERROR_NO_DATA, ERROR_PIPE_NOT_CONNECTED] then
      raise EX2LogPipeDisconnected.Create('Client disconnected');

    if lastError = ERROR_IO_PENDING then
      State := Writing
    else
    begin
      ClearWriteBuffer;
      RaiseLastOSError;
    end;
  end else
  begin
    ClearWriteBuffer;
    State := Connected;
  end;
end;


procedure TX2LogNamedPipeClient.ClearWriteBuffer;
begin
  if Assigned(FWriteBuffer) then
  begin
    FreeMem(FWriteBuffer, FWriteBufferSize);
    FWriteBuffer := nil;
  end;
end;



{ TX2LogNamedPipeWorkerThread }
constructor TX2LogNamedPipeWorkerThread.Create(const APipeName: string);
begin
  FPipeName := APipeName;
  FClients := TObjectList<TX2LogNamedPipeClient>.Create(True);

  inherited Create;
end;


destructor TX2LogNamedPipeWorkerThread.Destroy;
begin
  inherited Destroy;

  FreeAndNil(FClients);
end;


procedure TX2LogNamedPipeWorkerThread.Setup;
begin
  inherited Setup;

  AddListener;
end;


procedure TX2LogNamedPipeWorkerThread.Cleanup;
var
  client: TX2LogNamedPipeClient;

begin
  for client in Clients do
    client.Disconnect;

  inherited Cleanup;
end;


procedure TX2LogNamedPipeWorkerThread.WaitForEntry;
var
  eventHandles: array of THandle;
  clientIndex: Integer;
  waitResult: Cardinal;

begin
  repeat
    SetLength(eventHandles, Clients.Count + 1);
    for clientIndex := 0 to Pred(Clients.Count) do
      eventHandles[clientIndex] := Clients[clientIndex].OverlappedEvent.Handle;

    eventHandles[Clients.Count] := LogQueueSignal.Handle;

    waitResult := WaitForMultipleObjects(Length(eventHandles), @eventHandles[0], False, INFINITE);
    if waitResult in [WAIT_OBJECT_0..WAIT_OBJECT_0 + Pred(High(eventHandles))] then
    begin
      { Connect or write I/O completed }
      clientIndex := waitResult - WAIT_OBJECT_0;
      if (clientIndex >= 0) and (clientIndex < Clients.Count) then
        ProcessClientEvent(clientIndex);
    end else if waitResult = Cardinal(WAIT_OBJECT_0 + High(eventHandles)) then
    begin
      { Entry queued }
      break;
    end else if waitResult in [WAIT_ABANDONED_0..WAIT_ABANDONED_0 + High(eventHandles)] then
    begin
      { Client event abandoned }
      clientIndex := waitResult - WAIT_ABANDONED_0;
      if (clientIndex >= 0) and (clientIndex < Clients.Count) then
        RemoveClient(clientIndex)
      else if clientIndex = Clients.Count then
        Terminate;
    end else if waitResult = WAIT_FAILED then
      RaiseLastOSError;
  until False;
end;


procedure TX2LogNamedPipeWorkerThread.ProcessEntry(AEntry: TX2LogQueueEntry);
var
  clientIndex: Integer;
  client: TX2LogNamedPipeClient;

begin
  { Broadcast to connected clients }
  for clientIndex := Pred(Clients.Count) downto 0 do
  begin
    client := Clients[clientIndex];

    if client.State <> Listening then
    try
      client.Send(AEntry);
    except
      on E:EX2LogPipeDisconnected do
        RemoveClient(clientIndex);
    end;
  end;
end;


procedure TX2LogNamedPipeWorkerThread.ProcessClientEvent(AClientIndex: Integer);
var
  client: TX2LogNamedPipeClient;
  bytesTransferred: Cardinal;

begin
  client := Clients[AClientIndex];

  case client.State of
    Listening:
      { Client connected }
      if GetOverlappedResult(client.Pipe, client.Overlapped, bytesTransferred, False) then
      begin
        client.State := Connected;
        AddListener;
      end else
        RemoveClient(AClientIndex);

    Writing:
      { Write operation completed }
      if GetOverlappedResult(client.Pipe, client.Overlapped, bytesTransferred, False) and
         (bytesTransferred > 0) then
      begin
        try
          client.SendNext;
        except
          on E:EX2LogPipeDisconnected do
            RemoveClient(AClientIndex);
        end;
      end else
        RemoveClient(AClientIndex);
  end;
end;


procedure TX2LogNamedPipeWorkerThread.AddListener;
const
  BufferSize = 4096;
  DefaultTimeout = 5000;

var
  pipe: THandle;
  client: TX2LogNamedPipeClient;

begin
  pipe := CreateNamedPipe(PChar('\\.\pipe\' + PipeName), PIPE_ACCESS_OUTBOUND or FILE_FLAG_OVERLAPPED,
                          PIPE_TYPE_MESSAGE or PIPE_READMODE_MESSAGE or PIPE_WAIT, PIPE_UNLIMITED_INSTANCES,
                          BufferSize, BufferSize, DefaultTimeout, nil);

  if pipe <> INVALID_HANDLE_VALUE then
  begin
    client := TX2LogNamedPipeClient.Create(pipe);

    if not ConnectNamedPipe(client.Pipe, @client.Overlapped) then
    begin
      case GetLastError of
        ERROR_IO_PENDING:
          Clients.Add(client);

        ERROR_PIPE_CONNECTED:
          begin
            client.State := Connected;
            Clients.Add(client);
          end;
      else
        { Error occured }
        FreeAndNil(client);
      end;
    end;
  end;
end;


procedure TX2LogNamedPipeWorkerThread.RemoveClient(AClientIndex: Integer);
begin
  Clients.Delete(AClientIndex);
end;

end.
