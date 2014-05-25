program X2LogNamedPipeClient;

uses
  Vcl.Forms,
  MainFrm in 'source\MainFrm.pas' {MainForm},
  X2Log.Intf in '..\X2Log.Intf.pas',
  X2Log.Client.NamedPipe in '..\X2Log.Client.NamedPipe.pas',
  X2Log.Client.Base in '..\X2Log.Client.Base.pas',
  X2Log.Observer.Event in '..\X2Log.Observer.Event.pas',
  X2Log.Constants in '..\X2Log.Constants.pas',
  X2Log.Observer.Custom in '..\X2Log.Observer.Custom.pas';

{$R *.res}

var
  MainForm: TMainForm;

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
