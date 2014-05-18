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
  X2Log.Observer.CustomThreaded in '..\X2Log.Observer.CustomThreaded.pas';

{$R *.res}

var
  MainForm: TMainForm;
  
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
