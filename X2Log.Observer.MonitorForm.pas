unit X2Log.Observer.MonitorForm;

interface
uses
  Vcl.Controls,
  Vcl.Forms,
  Winapi.Messages,

  X2Log.Intf;


const
  CM_REENABLE = WM_APP + 1;


type
  TX2LogObserverMonitorForm = class(TForm, IX2LogObserver)
  protected
    procedure CreateParams(var Params: TCreateParams); override;

    procedure WMEnable(var Msg: TWMEnable); message WM_ENABLE;
    procedure CMReenable(var Msg: TMessage); message CM_REENABLE;
  public
    { IX2LogObserver }
    procedure Log(ALevel: TX2LogLevel; const AMessage: string; const ADetails: string = '');
  end;


implementation
uses
  Winapi.Windows;


{$R *.dfm}


{ TX2LogObserverMonitorForm }
procedure TX2LogObserverMonitorForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  Params.WndParent := 0;
end;


procedure TX2LogObserverMonitorForm.Log(ALevel: TX2LogLevel; const AMessage, ADetails: string);
begin
  //
end;


procedure TX2LogObserverMonitorForm.WMEnable(var Msg: TWMEnable);
begin
  if not Msg.Enabled then
    { Modal forms disable all other forms, ensure we're still accessible }
    PostMessage(Self.Handle, CM_REENABLE, 0, 0);
end;


procedure TX2LogObserverMonitorForm.CMReenable(var Msg: TMessage);
begin
  EnableWindow(Self.Handle, True);
end;

end.
