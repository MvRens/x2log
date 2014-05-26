unit ServiceDMU;

interface
uses
  System.Classes,
  System.SysUtils,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  Vcl.SvcMgr,
  Winapi.Messages,
  Winapi.Windows;


type
  TServiceDM = class(TService)
    tmrLog: TTimer;

    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure tmrLogTimer(Sender: TObject);
  public
    function GetServiceController: TServiceController; override;
  end;


var
  ServiceDM: TServiceDM;


implementation
uses
  X2Log.Intf,
  X2Log.Global,
  X2Log.Observer.NamedPipe;

{$R *.DFM}


procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ServiceDM.Controller(CtrlCode);
end;


function TServiceDM.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;


procedure TServiceDM.ServiceStart(Sender: TService; var Started: Boolean);
begin
  TX2GlobalLog.Attach(TX2LogNamedPipeObserver.Create('X2LogService', X2LogLevelsAll));
end;


procedure TServiceDM.tmrLogTimer(Sender: TObject);
var
  level: TX2LogLevel;

begin
  level := TX2LogLevel(Random(Ord(High(TX2LogLevel))));
  TX2GlobalLog.Log(level, 'Ping!');
end;

end.
