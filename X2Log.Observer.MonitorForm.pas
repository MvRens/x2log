unit X2Log.Observer.MonitorForm;

interface
uses
  System.Classes,
  System.Generics.Collections,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.ImgList,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  VirtualTrees,
  Winapi.Messages,

  X2Log.Intf, Vcl.ActnList;


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
    tbCopyDetails: TToolButton;
    alLog: TActionList;
    actClear: TAction;
    actCopyDetails: TAction;
    actSaveDetails: TAction;
    actPause: TAction;
    tbPause: TToolButton;

    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure vstLogInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstLogFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstLogGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstLogGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var LineBreakStyle: TVTTooltipLineBreakStyle; var HintText: string);
    procedure vstLogGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstLogFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
    procedure actClearExecute(Sender: TObject);
    procedure actCopyDetailsExecute(Sender: TObject);
    procedure actPauseExecute(Sender: TObject);
  private class var
    FInstances: TDictionary<IX2Log,TX2LogObserverMonitorForm>;
  private
    FFreeOnClose: Boolean;
    FLogToAttach: IX2Log;
    FLogAttached: Boolean;
    FPausedLogCount: Integer;

    function GetPaused: Boolean;
  protected
    class function GetInstance(ALog: IX2Log; out AForm: TX2LogObserverMonitorForm): Boolean;
    class procedure RemoveInstance(AForm: TX2LogObserverMonitorForm);
    class procedure CleanupInstances;

    procedure CreateParams(var Params: TCreateParams); override;

    procedure WMEnable(var Msg: TWMEnable); message WM_ENABLE;
    procedure CMReenable(var Msg: TMessage); message CM_REENABLE;

    procedure UpdateUI;
    procedure UpdateStatus;

    property LogToAttach: IX2Log read FLogToAttach;
    property LogAttached: Boolean read FLogAttached;
    property Paused: Boolean read GetPaused;
    property PausedLogCount: Integer read FPausedLogCount write FPausedLogCount;
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
  Vcl.Clipbrd,
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
  tbCopyDetails.Caption := GetLogResourceString(@LogMonitorFormButtonCopyDetails);
  tbSaveDetails.Caption := GetLogResourceString(@LogMonitorFormButtonSaveDetails);

  UpdateUI;
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
  { Ensure thread safety; TThread.Queue will run the procedure immediately
    if Log is called from the main thread, or queue it asynchronously }
  TThread.Queue(nil,
    procedure
    begin
      if not Paused then
      begin
        node := vstLog.AddChild(nil);
        nodeData := vstLog.GetNodeData(node);
        nodeData^.Initialize(ALevel, AMessage, ADetails);

        UpdateUI;
      end else
      begin
        PausedLogCount := PausedLogCount + 1;
        UpdateStatus;
      end;
    end);
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


procedure TX2LogObserverMonitorForm.UpdateUI;
var
  hasDetails: Boolean;

begin
  actClear.Enabled := (vstLog.RootNodeCount > 0);

  hasDetails := (Length(reDetails.Text) > 0);
  actCopyDetails.Enabled := hasDetails;
  actSaveDetails.Enabled := hasDetails;
end;


procedure TX2LogObserverMonitorForm.UpdateStatus;
begin
  if Paused then
    sbStatus.SimpleText := ' ' + Format(GetLogResourceString(@LogMonitorFormStatusPaused), [PausedLogCount])
  else
    sbStatus.SimpleText := '';
end;


function TX2LogObserverMonitorForm.GetPaused: Boolean;
begin
  Result := actPause.Checked;
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


procedure TX2LogObserverMonitorForm.vstLogGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                                                  var LineBreakStyle: TVTTooltipLineBreakStyle; var HintText: string);
var
  nodeData: PLogEntryNodeData;

begin
  if Column = ColumnLevel then
  begin
    nodeData := Sender.GetNodeData(Node);
    HintText := GetLogLevelText(nodeData^.Level);
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

  UpdateUI;
end;


procedure TX2LogObserverMonitorForm.actClearExecute(Sender: TObject);
begin
  vstLog.Clear;
  UpdateUI;
end;


procedure TX2LogObserverMonitorForm.actCopyDetailsExecute(Sender: TObject);
begin
  if Length(reDetails.Text) > 0 then
    Clipboard.AsText := reDetails.Text;
end;


procedure TX2LogObserverMonitorForm.actPauseExecute(Sender: TObject);
begin
  PausedLogCount := 0;
  UpdateStatus;
end;

end.
