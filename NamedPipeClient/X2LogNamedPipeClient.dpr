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
  observerForm: TX2LogObserverMonitorForm;

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'X²Log Named Pipe Client';

  client := TX2LogNamedPipeClient.Create('X2LogTest');
  try
    observerForm := TX2LogObserverMonitorForm.Instance(client);
    observerForm.ShowModal;
  finally
    client := nil;
  end;
end.
