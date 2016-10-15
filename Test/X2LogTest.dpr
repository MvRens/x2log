program X2LogTest;

{$R *.dres}

uses
  Forms,
  MainFrm in 'source\MainFrm.pas' {MainForm},
  X2Log.Intf in '..\X2Log.Intf.pas',
  X2Log in '..\X2Log.pas',
  X2Log.Observer.Event in '..\X2Log.Observer.Event.pas',
  X2Log.Observer.Custom in '..\X2Log.Observer.Custom.pas',
  X2Log.Exception.Default in '..\X2Log.Exception.Default.pas',
  X2Log.Exception.madExceptHandler in '..\X2Log.Exception.madExceptHandler.pas',
  X2Log.Observer.LogFile in '..\X2Log.Observer.LogFile.pas',
  X2Log.Constants in '..\X2Log.Constants.pas',
  X2Log.Observer.NamedPipe in '..\X2Log.Observer.NamedPipe.pas',
  X2Log.Observer.CustomThreaded in '..\X2Log.Observer.CustomThreaded.pas',
  X2Log.Observer.MonitorForm in '..\X2Log.Observer.MonitorForm.pas' {X2LogObserverMonitorForm},
  X2Log.Global in '..\X2Log.Global.pas',
  X2Log.Client.NamedPipe in '..\X2Log.Client.NamedPipe.pas',
  X2Log.Client.Base in '..\X2Log.Client.Base.pas',
  X2Log.Details.Default in '..\X2Log.Details.Default.pas',
  X2Log.Details.Registry in '..\X2Log.Details.Registry.pas',
  X2Log.Details.Intf in '..\X2Log.Details.Intf.pas',
  X2Log.Util.Stream in '..\X2Log.Util.Stream.pas',
  X2Log.Decorator in '..\X2Log.Decorator.pas',
  X2Log.Observer.RollingLogFile in '..\X2Log.Observer.RollingLogFile.pas',
  X2Log.Intf.NamedPipe in '..\X2Log.Intf.NamedPipe.pas',
  X2Log.TextFormatter.Intf in '..\X2Log.TextFormatter.Intf.pas',
  X2Log.TextFormatter.Default in '..\X2Log.TextFormatter.Default.pas',
  X2Log.TextFormatter.Json in '..\X2Log.TextFormatter.Json.pas';

{$R *.res}

var
  MainForm: TMainForm;
  
begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'X²LogTest';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
