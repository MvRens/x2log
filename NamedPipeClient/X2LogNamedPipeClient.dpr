program X2LogNamedPipeClient;

uses
  Vcl.Forms,
  MainFrm in 'source\MainFrm.pas' {MainForm},
  X2Log.Intf in '..\X2Log.Intf.pas';

{$R *.res}

var
  MainForm: TMainForm;

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
