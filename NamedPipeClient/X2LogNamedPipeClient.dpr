program X2LogNamedPipeClient;

uses
//  FastMM4,
  Vcl.Forms,
  X2Log.Intf,
  X2Log.Client.NamedPipe,
  X2Log.Observer.MonitorForm;

{$R *.res}

var
  client: IX2LogObservable;

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'X²Log Named Pipe Client';

  client := TX2LogNamedPipeClient.Create('X2LogTest');
  try
    with TX2LogObserverMonitorForm.Create(nil, client) do
    try
      ShowModal;
    finally
      Free;
    end;
  finally
    client := nil;
  end;
end.
