unit MainFrm;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;


type
  TMainForm = class(TForm)
    mmoLog: TMemo;

    procedure FormCreate(Sender: TObject);
  private
    FClientThread: TThread;

    procedure DoMessage(Sender: TObject; Msg: TStream);
  end;


implementation
uses
  System.SyncObjs,

  X2Log.Intf;


{$R *.dfm}


type
  TClientMessageEvent = procedure(Sender: TObject; Msg: TStream) of object;

  TClientThread = class(TThread)
  private
    FTerminateEvent: TEvent;
    FPipe: THandle;
    FOverlappedRead: TOverlapped;
    FReadBuffer: array[0..4095] of Byte;
    FMessage: TMemoryStream;
    FOnMessage: TClientMessageEvent;
  protected
    procedure Execute; override;
    procedure TerminatedSet; override;

    procedure ReadMessage;
    procedure HandleMessage;

    procedure DoMessage;
  public
    constructor Create;
    destructor Destroy; override;

    property OnMessage: TClientMessageEvent read FOnMessage write FOnMessage;
  end;


{ TMainForm }
procedure TMainForm.FormCreate(Sender: TObject);
begin
  FClientThread := TClientThread.Create;
  (FClientThread as TClientThread).OnMessage := DoMessage;
end;


procedure TMainForm.DoMessage(Sender: TObject; Msg: TStream);

  function ReadString: string;
  var
    size: Cardinal;

  begin
    Msg.ReadBuffer(size, SizeOf(cardinal));
    if size > 0 then
    begin
      SetLength(Result, size);
      Msg.ReadBuffer(Result[1], size * SizeOf(Char));
    end else
      Result := '';
  end;

var
  level: TX2LogLevel;
  logMsg: string;
  detail: string;

begin
  Msg.ReadBuffer(level, SizeOf(TX2LogLevel));
  logMsg := ReadString;
  detail := ReadString;

  mmoLog.Lines.Add(logMsg + ' (' + detail + ')');
end;


const
  FILE_WRITE_ATTRIBUTES  = $0100;

{ TClientThread }
constructor TClientThread.Create;
begin
  FTerminateEvent := TEvent.Create(nil, True, False, '');
  FMessage := TMemoryStream.Create;

  inherited Create(False);
end;

destructor TClientThread.Destroy;
begin
  FreeAndNil(FMessage);
  FreeAndNil(FTerminateEvent);

  inherited Destroy;
end;


procedure TClientThread.Execute;
var
  mode: Cardinal;
  readEvent: TEvent;
  events: array[0..1] of THandle;
  waitResult: Cardinal;
  bytesTransferred: Cardinal;

begin
  while not Terminated do
  begin
    FPipe := CreateFile('\\.\pipe\X2LogTest', GENERIC_READ or FILE_WRITE_ATTRIBUTES,
                        0, nil, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, 0);

    if FPipe = INVALID_HANDLE_VALUE then
    begin
      if GetLastError = ERROR_PIPE_BUSY then
      begin
        if not WaitNamedPipe('\\.\pipe\X2LogTest', 5000) then
          exit;
      end else
        RaiseLastOSError;
    end else
      break;
  end;

  if Terminated then
    exit;

  mode := PIPE_READMODE_MESSAGE;
  if not SetNamedPipeHandleState(FPipe, mode, nil, nil) then
    exit;

  readEvent := TEvent.Create(nil, False, False, '');
  events[0] := FTerminateEvent.Handle;
  events[1] := readEvent.Handle;

  FOverlappedRead.hEvent := readEvent.Handle;
  ReadMessage;

  while not Terminated do
  begin
    waitResult := WaitForMultipleObjects(Length(events), @events, False, INFINITE);

    case waitResult of
      WAIT_OBJECT_0:
        { Terminated }
        break;

      WAIT_OBJECT_0 + 1:
        { Read event completed }
        if GetOverlappedResult(FPipe, FOverlappedRead, bytesTransferred, False) then
        begin
          FMessage.WriteBuffer(FReadBuffer[0], bytesTransferred);
          HandleMessage;
          ReadMessage;
        end else
        begin
          if GetLastError = ERROR_MORE_DATA then
          begin
            FMessage.WriteBuffer(FReadBuffer[0], bytesTransferred);
            ReadMessage;
          end else
            break;
        end;
    end;
  end;

  CloseHandle(FPipe);
end;


procedure TClientThread.ReadMessage;
var
  bytesRead: Cardinal;
  lastError: Cardinal;

begin
  while True do
  begin
    if ReadFile(FPipe, FReadBuffer, SizeOf(FReadBuffer), bytesRead, @FOverlappedRead) then
    begin
      { Immediate result }
      FMessage.WriteBuffer(FReadBuffer[0], bytesRead);
      HandleMessage;
    end else
    begin
      { More data, pending I/O or an actual error }
      lastError := GetLastError;

      if lastError = ERROR_IO_PENDING then
        break
      else if lastError = ERROR_MORE_DATA then
        FMessage.WriteBuffer(FReadBuffer[0], SizeOf(FReadBuffer))
      else
        break;
    end;
  end;
end;


procedure TClientThread.HandleMessage;
begin
  if FMessage.Size > 0 then
  begin
    FMessage.Position := 0;
    Synchronize(DoMessage);
    FMessage.Clear;
  end;
end;


procedure TClientThread.TerminatedSet;
begin
  inherited TerminatedSet;

  FTerminateEvent.SetEvent;
end;


procedure TClientThread.DoMessage;
begin
  if Assigned(FOnMessage) then
    FOnMessage(Self, FMessage);
end;

end.
