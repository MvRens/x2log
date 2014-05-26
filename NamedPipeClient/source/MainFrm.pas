unit MainFrm;

interface
uses
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,

  X2Log.Intf;


type
  TMainForm = class(TForm)
    mmoLog: TMemo;

    procedure FormCreate(Sender: TObject);
  private
    FClient: IX2LogObservable;
    FObserver: IX2LogObserver;
  protected
    procedure DoLog(Sender: TObject; Level: TX2LogLevel; const Msg, Details: string);
  end;


implementation
uses
  System.SysUtils,

  X2Log.Constants,
  X2Log.Client.NamedPipe,
  X2Log.Observer.Event;


{$R *.dfm}


{ TMainForm }
procedure TMainForm.FormCreate(Sender: TObject);
begin
  FClient := TX2LogNamedPipeClient.Create('X2LogTest');
  FObserver := TX2LogEventObserver.Create(DoLog);
  FClient.Attach(FObserver);
end;


procedure TMainForm.DoLog(Sender: TObject; Level: TX2LogLevel; const Msg, Details: string);
begin
  mmoLog.Lines.Add(DateTimeToStr(Now) + ' ' + GetLogLevelText(Level) + ': ' + Msg + ' (' + Details + ')');
end;

end.
