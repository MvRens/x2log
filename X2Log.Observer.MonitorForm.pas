unit X2Log.Observer.MonitorForm;

// #ToDo3 -oMvR: 20-5-2014: pause button

interface
uses
  System.Classes,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ImgList,
  VirtualTrees,
  Winapi.Messages,

  X2Log.Intf, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.ToolWin;


const
  CM_REENABLE = WM_APP + 1;


type
  TX2LogObserverMonitorForm = class(TForm, IX2LogObserver)
    vstLog: TVirtualStringTree;
    ilsLog: TImageList;
    splDetails: TSplitter;
    HeaderControl1: THeaderControl;
    pnlDetails: TPanel;
    reDetails: TRichEdit;
    pnlLog: TPanel;
    tbLog: TToolBar;
    tbDetails: TToolBar;
    pnlBorder: TPanel;
    tbClear: TToolButton;
    tbSaveDetails: TToolButton;
    sbStatus: TStatusBar;

    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure vstLogInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstLogFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstLogGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstLogGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstLogFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
    procedure tbClearClick(Sender: TObject);
  private class var
    FInstances: TDictionary<IX2Log,TX2LogObserverMonitorForm>;
  private
    FFreeOnClose: Boolean;
    FLogToAttach: IX2Log;
    FLogAttached: Boolean;
  protected
    class function GetInstance(ALog: IX2Log; out AForm: TX2LogObserverMonitorForm): Boolean;
    class procedure RemoveInstance(AForm: TX2LogObserverMonitorForm);
    class procedure CleanupInstances;

    procedure CreateParams(var Params: TCreateParams); override;

    procedure WMEnable(var Msg: TWMEnable); message WM_ENABLE;
    procedure CMReenable(var Msg: TMessage); message CM_REENABLE;

    property LogToAttach: IX2Log read FLogToAttach;
    property LogAttached: Boolean read FLogAttached;
  public
    class function Instance(ALog: IX2Log): TX2LogObserverMonitorForm;

    class procedure ShowInstance(ALog: IX2Log);
    class procedure CloseInstance(ALog: IX2Log);

    constructor Create(AOwner: TComponent; ALogToAttach: IX2Log = nil); reintroduce;
    destructor Destroy; override;

    { IX2LogObserver }
    procedure Log(ALevel: TX2LogLevel; const AMessage: string; const ADetails: string = '');

    property FreeOnClose: Boolean read FFreeOnClose write FFreeOnClose;
  end;


implementation
uses
  System.DateUtils,
  System.SysUtils,
  Winapi.Windows,

  X2Log.Constants;


{$R *.dfm}


type
  TLogEntryNodeData = record
    Time: TDateTime;
    Level: TX2LogLevel;
    Message: string;
    Details: string;

    procedure Initialize(ALevel: TX2LogLevel; const AMessage, ADetails: string);
  end;

  PLogEntryNodeData = ^TLogEntryNodeData;


const
  ColumnLevel = 0;
  ColumnTime = 1;
  ColumnMessage = 2;


{ TLogEntryNode }
procedure TLogEntryNodeData.Initialize(ALevel: TX2LogLevel; const AMessage, ADetails: string);
begin
  Time := Now;
  Level := ALevel;
  Message := AMessage;
  Details := ADetails;
end;


{ TX2LogObserverMonitorForm }
class function TX2LogObserverMonitorForm.Instance(ALog: IX2Log): TX2LogObserverMonitorForm;
var
  log: IX2Log;

begin
  { Explicit cast ensures we're getting the same pointer every time if, for example,
    the implementing interface is a descendant of IX2Log }
  log := (ALog as IX2Log);

  if not Assigned(FInstances) then
    FInstances := TDictionary<IX2Log,TX2LogObserverMonitorForm>.Create;

  if not FInstances.TryGetValue(log, Result) then
  begin
    Result := TX2LogObserverMonitorForm.Create(nil, log);
    Result.FreeOnClose := True;

    FInstances.Add(log, Result);
  end;
end;


class procedure TX2LogObserverMonitorForm.ShowInstance(ALog: IX2Log);
begin
  Instance(ALog).Show;
end;


class procedure TX2LogObserverMonitorForm.CloseInstance(ALog: IX2Log);
var
  monitorForm: TX2LogObserverMonitorForm;

begin
  if GetInstance(ALog, monitorForm) then
    monitorForm.Close;
end;


class function TX2LogObserverMonitorForm.GetInstance(ALog: IX2Log; out AForm: TX2LogObserverMonitorForm): Boolean;
begin
  Result := False;

  if Assigned(FInstances) then
    Result := FInstances.TryGetValue(ALog as IX2Log, AForm);
end;


class procedure TX2LogObserverMonitorForm.RemoveInstance(AForm: TX2LogObserverMonitorForm);
var
  log: IX2Log;

begin
  if Assigned(FInstances) then
  begin
    for log in FInstances.Keys do
    begin
      if FInstances[log] = AForm then
      begin
        FInstances.Remove(log);
        break;
      end;
    end;
  end;
end;


class procedure TX2LogObserverMonitorForm.CleanupInstances;
begin
  if Assigned(FInstances) then
    FreeAndNil(FInstances);
end;


constructor TX2LogObserverMonitorForm.Create(AOwner: TComponent; ALogToAttach: IX2Log);
var
  captionFormat: string;

begin
  inherited Create(AOwner);

  FLogToAttach := ALogToAttach;

  captionFormat := GetLogResourceString(@LogMonitorFormCaption);
  if Pos('%s', captionFormat) > 0 then
    Caption := Format(captionFormat, [Application.Title])
  else
    Caption := captionFormat;

  vstLog.NodeDataSize := SizeOf(TLogEntryNodeData);
  vstLog.Header.Columns[ColumnTime].Text := GetLogResourceString(@LogMonitorFormColumnTime);
  vstLog.Header.Columns[ColumnMessage].Text := GetLogResourceString(@LogMonitorFormColumnMessage);

  tbClear.Caption := GetLogResourceString(@LogMonitorFormButtonClear);
  tbSaveDetails.Caption := GetLogResourceString(@LogMonitorFormButtonSaveDetails);
end;


procedure TX2LogObserverMonitorForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  Params.WndParent := 0;
end;


destructor TX2LogObserverMonitorForm.Destroy;
begin
  if Assigned(FLogToAttach) and FLogAttached then
    FLogToAttach.Detach(Self);

  RemoveInstance(Self);

  inherited Destroy;
end;


procedure TX2LogObserverMonitorForm.FormShow(Sender: TObject);
begin
  if Assigned(FLogToAttach) and (not FLogAttached) then
  begin
    FLogToAttach.Attach(Self);
    FLogAttached := True;
  end;
end;


procedure TX2LogObserverMonitorForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FLogToAttach) and FLogAttached then
  begin
    FLogToAttach.Detach(Self);
    FLogAttached := False;
  end;

  if FreeOnClose then
    Action := caFree
  else
    Action := caHide;
end;


procedure TX2LogObserverMonitorForm.Log(ALevel: TX2LogLevel; const AMessage, ADetails: string);
var
  node: PVirtualNode;
  nodeData: PLogEntryNodeData;

begin
// #ToDo1 -oMvR: 20-5-2014: thread safety; Log is not guaranteed to be called in the main thread!
  if GetCurrentThreadId <> MainThreadID then
    exit;

  node := vstLog.AddChild(nil);
  nodeData := vstLog.GetNodeData(node);
  nodeData^.Initialize(ALevel, AMessage, ADetails);

  tbClear.Enabled := True;
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


procedure TX2LogObserverMonitorForm.vstLogInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
                                                   var InitialStates: TVirtualNodeInitStates);
var
  nodeData: PLogEntryNodeData;

begin
  nodeData := Sender.GetNodeData(Node);
  Initialize(nodeData^);
end;


procedure TX2LogObserverMonitorForm.vstLogFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  nodeData: PLogEntryNodeData;

begin
  nodeData := Sender.GetNodeData(Node);
  Finalize(nodeData^);
end;


procedure TX2LogObserverMonitorForm.vstLogGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                                                  TextType: TVSTTextType; var CellText: string);
var
  nodeData: PLogEntryNodeData;

begin
  CellText := '';
  nodeData := Sender.GetNodeData(Node);

  case Column of
    ColumnTime:
      CellText := DateTimeToStr(nodeData^.Time);

    ColumnMessage:
      CellText := nodeData^.Message;
  end;
end;


procedure TX2LogObserverMonitorForm.vstLogGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
                                                        Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
  nodeData: PLogEntryNodeData;

begin
  if Kind in [ikNormal, ikSelected] then
  begin
    nodeData := Sender.GetNodeData(Node);

    case Column of
      ColumnLevel:
        case nodeData^.Level of
          TX2LogLevel.Verbose:    ImageIndex := 0;
          TX2LogLevel.Info:       ImageIndex := 1;
          TX2LogLevel.Warning:    ImageIndex := 2;
          TX2LogLevel.Error:      ImageIndex := 3;
        end;

      ColumnMessage:
        if Length(nodeData^.Details) > 0 then
          ImageIndex := 4;
    end;
  end;
end;


procedure TX2LogObserverMonitorForm.vstLogFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
var
  nodeData: PLogEntryNodeData;

begin
  if Assigned(Node) then
  begin
    nodeData := Sender.GetNodeData(Node);
    reDetails.Text := nodeData^.Details;
  end else
    reDetails.Text := '';
end;


procedure TX2LogObserverMonitorForm.tbClearClick(Sender: TObject);
begin
  vstLog.Clear;
  tbClear.Enabled := False;
end;

end.
