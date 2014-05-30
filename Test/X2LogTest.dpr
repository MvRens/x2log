program X2LogTest;

uses
  Forms,
  MainFrm in 'source\MainFrm.pas' {MainForm},
  X2Log.Intf in '..\X2Log.Intf.pas',
  X2Log in '..\X2Log.pas',
  X2Log.Observer.Event in '..\X2Log.Observer.Event.pas',
  X2Log.Observer.Custom in '..\X2Log.Observer.Custom.pas',
  X2Log.Exception.Default in '..\X2Log.Exception.Default.pas',
  X2Log.Exception.madExcept in '..\X2Log.Exception.madExcept.pas',
  X2Log.Observer.LogFile in '..\X2Log.Observer.LogFile.pas',
  X2Log.Constants in '..\X2Log.Constants.pas',
  X2Log.Observer.NamedPipe in '..\X2Log.Observer.NamedPipe.pas',
  X2Log.Observer.CustomThreaded in '..\X2Log.Observer.CustomThreaded.pas',
  X2Log.Observer.MonitorForm in '..\X2Log.Observer.MonitorForm.pas' {X2LogObserverMonitorForm},
  X2Log.Global in '..\X2Log.Global.pas',
  X2Log.Client.NamedPipe in '..\X2Log.Client.NamedPipe.pas',
  X2Log.Client.Base in '..\X2Log.Client.Base.pas',
  X2Log.Details.Default in '..\X2Log.Details.Default.pas';

{$R *.res}

var
  MainForm: TMainForm;
  
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'X²LogTest';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
