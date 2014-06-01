unit X2Log.Client.NamedPipe;

interface
uses
  System.Classes,
  System.Generics.Collections,

  X2Log.Intf,
  X2Log.Client.Base;


type
  TX2LogNamedPipeClient = class(TX2LogBaseClient, IX2LogBase)
  private
    FWorkerThread: TThread;
  protected
    property WorkerThread: TThread read FWorkerThread;
  public
    constructor Create(const APipeName: string);
    destructor Destroy; override;
  end;


implementation
uses
  System.SyncObjs,
  System.SysUtils,
  System.Types,
  Winapi.Windows,

  X2Log.Details.Default,
  X2Log.Details.Registry,
  X2Log.Util.Stream;


type
  TX2LogNamedPipeClientWorkerThread = class(TThread)
  private
    FClient: TX2LogNamedPipeClient;
    FPipeName: string;

    FTerminateEvent: TEvent;
    FReadEvent: TEvent;
    FPipeHandle: THandle;
    FOverlappedRead: TOverlapped;
    FReadBuffer: array[0..4095] of Byte;
    FMessageData: TMemoryStream;
  protected
    procedure Execute; override;
    procedure TerminatedSet; override;

    procedure ConnectPipe;
    procedure ReadPipe;
    procedure ClosePipe;

    procedure ReadMessage;
    procedure HandleMessage;

    property Client: TX2LogNamedPipeClient read FClient;
    property PipeName: string read FPipeName;

    property ReadEvent: TEvent read FReadEvent;
    property TerminateEvent: TEvent read FTerminateEvent;
    property PipeHandle: THandle read FPipeHandle;
    property MessageData: TMemoryStream read FMessageData;
  public
    constructor Create(AClient: TX2LogNamedPipeClient; const APipeName: string);
    destructor Destroy; override;
  end;


const
  PipeNamePrefix = '\\.\pipe\';

  TimeoutBusyPipe = 5000;
  TimeoutNoPipe = 1000;

  ClearBufferTreshold = 4096;


{ TX2LogNamedPipeClient }
constructor TX2LogNamedPipeClient.Create(const APipeName: string);
begin
  inherited Create;

  FWorkerThread := TX2LogNamedPipeClientWorkerThread.Create(Self, APipeName);
end;


destructor TX2LogNamedPipeClient.Destroy;
begin
  FreeAndNil(FWorkerThread);

  inherited Destroy;
end;


{ TX2LogNamedPipeClientWorkerThread }
constructor TX2LogNamedPipeClientWorkerThread.Create(AClient: TX2LogNamedPipeClient; const APipeName: string);
begin
  FTerminateEvent := TEvent.Create(nil, True, False, '');
  FReadEvent := TEvent.Create(nil, True, False, '');
  FMessageData := TMemoryStream.Create;

  FClient := AClient;
  FPipeName := APipeName;

  inherited Create(False);
end;


destructor TX2LogNamedPipeClientWorkerThread.Destroy;
begin
  inherited Destroy;

  FreeAndNil(FMessageData);
  FreeAndNil(FReadEvent);
  FreeAndNil(FTerminateEvent);
end;


procedure TX2LogNamedPipeClientWorkerThread.Execute;
begin
  FPipeHandle := INVALID_HANDLE_VALUE;
  try
    while not Terminated do
    begin
      ConnectPipe;

      if not Terminated then
        ReadPipe;
    end;
  finally
    ClosePipe;
  end;
end;


procedure TX2LogNamedPipeClientWorkerThread.TerminatedSet;
begin
  inherited TerminatedSet;

  TerminateEvent.SetEvent;
end;


procedure TX2LogNamedPipeClientWorkerThread.ConnectPipe;
var
  lastError: Cardinal;
  mode: Cardinal;

begin
  while not Terminated do
  begin
    FPipeHandle := CreateFile(PChar(PipeNamePrefix + PipeName), GENERIC_READ or FILE_WRITE_ATTRIBUTES,
                        0, nil, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, 0);

    if PipeHandle = INVALID_HANDLE_VALUE then
    begin
      lastError := GetLastError;

      case lastError of
        ERROR_PIPE_BUSY:
          { Pipe exists but is connecting to another client, wait for a new slot }
          WaitNamedPipe(PChar(PipeNamePrefix + PipeName), TimeoutBusyPipe);

        ERROR_FILE_NOT_FOUND:
          { Pipe does not exist, try again later }
          WaitForSingleObject(TerminateEvent.Handle, TimeoutNoPipe);
      else
        RaiseLastOSError;
      end;
    end else
    begin
      { Change to message mode }
      mode := PIPE_READMODE_MESSAGE;
      if not SetNamedPipeHandleState(PipeHandle, mode, nil, nil) then
        RaiseLastOSError;

      break;
    end;
  end;
end;


procedure TX2LogNamedPipeClientWorkerThread.ReadPipe;
var
  events: array[0..1] of THandle;
  waitResult: Cardinal;
  bytesTransferred: Cardinal;

begin
  events[0] := TerminateEvent.Handle;
  events[1] := ReadEvent.Handle;

  FOverlappedRead.hEvent := readEvent.Handle;
  ReadMessage;

  while (not Terminated) and (PipeHandle <> INVALID_HANDLE_VALUE) do
  begin
    waitResult := WaitForMultipleObjects(Length(events), @events, False, INFINITE);

    case waitResult of
      WAIT_OBJECT_0:
        { Terminated }
        break;

      WAIT_OBJECT_0 + 1:
        { Read event completed }
        if GetOverlappedResult(PipeHandle, FOverlappedRead, bytesTransferred, False) then
        begin
          MessageData.WriteBuffer(FReadBuffer[0], bytesTransferred);
          HandleMessage;
          ReadMessage;
        end else
        begin
          if GetLastError = ERROR_MORE_DATA then
          begin
            MessageData.WriteBuffer(FReadBuffer[0], bytesTransferred);
            ReadMessage;
          end else
          begin
            ClosePipe;
            break;
          end;
        end;
    end;
  end;
end;


procedure TX2LogNamedPipeClientWorkerThread.ClosePipe;
begin
  if PipeHandle <> INVALID_HANDLE_VALUE then
  begin
    CloseHandle(PipeHandle);
    FPipeHandle := INVALID_HANDLE_VALUE;
  end;
end;


procedure TX2LogNamedPipeClientWorkerThread.ReadMessage;
var
  bytesRead: Cardinal;
  lastError: Cardinal;

begin
  while PipeHandle <> INVALID_HANDLE_VALUE do
  begin
    if ReadFile(PipeHandle, FReadBuffer, SizeOf(FReadBuffer), bytesRead, @FOverlappedRead) then
    begin
      { Immediate result }
      MessageData.WriteBuffer(FReadBuffer[0], bytesRead);
      HandleMessage;
    end else
    begin
      { More data, pending I/O or an actual error }
      lastError := GetLastError;

      if lastError = ERROR_IO_PENDING then
        break
      else if lastError = ERROR_MORE_DATA then
        MessageData.WriteBuffer(FReadBuffer[0], SizeOf(FReadBuffer))
      else
      begin
        ClosePipe;
        break;
      end;
    end;
  end;
end;


procedure TX2LogNamedPipeClientWorkerThread.HandleMessage;
var
  header: TX2LogMessageHeaderV1;
  headerDiff: Integer;
  msg: string;
  details: IX2LogDetails;
  serializerIID: TGUID;
  detailsSize: Cardinal;
  detailsStream: TMemoryStream;
  serializer: IX2LogDetailsSerializer;

begin
  if MessageData.Size > 0 then
  begin
    try
      { Header }
      MessageData.Position := 0;
      MessageData.ReadBuffer(header, SizeOf(header));

      if header.ID <> X2LogMessageHeader then
        raise EReadError.Create('Invalid header ID');

      headerDiff := SizeOf(header) - header.Size;
      if headerDiff > 0 then
      begin
        { A larger, most likely newer version, header }
        MessageData.Seek(headerDiff, soFromCurrent)
      end else if headerDiff < 0 then
        raise EReadError.Create('Header too small');

      { Message }
      msg := TStreamUtil.ReadString(MessageData);

      { Details }
      details := nil;

      MessageData.ReadBuffer(serializerIID, SizeOf(TGUID));
      if serializerIID <> GUID_NULL then
      begin
        detailsSize := TStreamUtil.ReadCardinal(MessageData);
        if detailsSize > 0 then
        begin
          if TX2LogDetailsRegistry.GetSerializer(serializerIID, serializer) then
          begin
            detailsStream := TMemoryStream.Create;
            try
              detailsStream.CopyFrom(MessageData, detailsSize);
              detailsStream.Position := 0;

              details := serializer.Deserialize(detailsStream);
            finally
              FreeAndNil(detailsStream);
            end;
          end else
            MessageData.Seek(detailsSize, soFromCurrent);
        end;
      end;

      Client.Log(header.Level, msg, details);
    except
      on E:EReadError do
        ClosePipe;

      on E:Exception do
        RaiseLastOSError;
    end;

    if MessageData.Size > ClearBufferTreshold then
      MessageData.Clear
    else
      MessageData.Position := 0;
  end;
end;

end.
