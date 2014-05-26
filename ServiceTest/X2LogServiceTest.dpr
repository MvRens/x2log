program X2LogServiceTest;

uses
  Vcl.SvcMgr,
  ServiceDMU in 'source\ServiceDMU.pas' {ServiceDM: TService};

{$R *.RES}


begin
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;

  Application.CreateForm(TServiceDM, ServiceDM);
  Application.Run;
end.
