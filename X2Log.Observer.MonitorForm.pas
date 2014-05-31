unit X2Log.Observer.MonitorForm;

interface
uses
  System.Classes,
  System.Generics.Collections,
  System.Types,
  Vcl.ActnList, 
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.ImgList,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  VirtualTrees,
  Winapi.Messages,

  X2Log.Intf;


const
  CM_REENABLE = WM_APP + 1;


type
  TX2LogObserverMonitorForm = class;
  TMonitorFormDictionary = TObjectDictionary<IX2LogObservable,TX2LogObserverMonitorForm>;


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
    sdDetails: TSaveDialog;

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
    procedure actSaveDetailsExecute(Sender: TObject);
    procedure actPauseExecute(Sender: TObject);
    procedure ToolbarCustomDraw(Sender: TToolBar; const ARect: TRect; var DefaultDraw: Boolean);
  private class var
    FInstances: TMonitorFormDictionary;
  private
    FFreeOnClose: Boolean;
    FLogObservable: IX2LogObservable;
    FLogAttached: Boolean;
    FPausedLogCount: Integer;
    FDetails: IX2LogDetails;

    function GetPaused: Boolean;
  protected
    class function GetInstance(ALog: IX2LogObservable; out AForm: TX2LogObserverMonitorForm): Boolean;
    class procedure RemoveInstance(AForm: TX2LogObserverMonitorForm);
    class procedure CleanupInstances;

    procedure CreateParams(var Params: TCreateParams); override;

    procedure WMEnable(var Msg: TWMEnable); message WM_ENABLE;
    procedure CMReenable(var Msg: TMessage); message CM_REENABLE;

    procedure UpdateUI;
    procedure UpdateStatus;

    procedure SetDetails(ADetails: IX2LogDetails);
    procedure SetBinaryDetails(ADetails: IX2LogDetailsBinary);

    property Details: IX2LogDetails read FDetails;
    property LogObservable: IX2LogObservable read FLogObservable;
    property LogAttached: Boolean read FLogAttached;
    property Paused: Boolean read GetPaused;
    property PausedLogCount: Integer read FPausedLogCount write FPausedLogCount;
  public
    class function Instance(ALog: IX2LogObservable): TX2LogObserverMonitorForm;

    class procedure ShowInstance(ALog: IX2LogObservable);
    class procedure CloseInstance(ALog: IX2LogObservable);

    constructor Create(AOwner: TComponent; ALogObservable: IX2LogObservable = nil); reintroduce;
    destructor Destroy; override;

    { IX2LogObserver }
    procedure Log(ALevel: TX2LogLevel; const AMessage: string; ADetails: IX2LogDetails);

    property FreeOnClose: Boolean read FFreeOnClose write FFreeOnClose;
  end;


implementation
uses
  System.DateUtils,
  System.Math,
  System.SysUtils,
  Vcl.Clipbrd,
  Vcl.Themes,
  Winapi.Windows,

  X2Log.Constants;


{$R *.dfm}


type
  TLogEntryNodeData = record
    Time: TDateTime;
    Level: TX2LogLevel;
    Message: string;
    Details: IX2LogDetails;

    procedure Initialize(ALevel: TX2LogLevel; const AMessage: string; ADetails: IX2LogDetails);
  end;

  PLogEntryNodeData = ^TLogEntryNodeData;


const
  ColumnLevel = 0;
  ColumnTime = 1;
  ColumnMessage = 2;


{ TLogEntryNode }
procedure TLogEntryNodeData.Initialize(ALevel: TX2LogLevel; const AMessage: string; ADetails: IX2LogDetails);
begin
  Self.Time := Now;
  Self.Level := ALevel;
  Self.Message := AMessage;
  Self.Details := ADetails;
end;


{ TX2LogObserverMonitorForm }
class function TX2LogObserverMonitorForm.Instance(ALog: IX2LogObservable): TX2LogObserverMonitorForm;
var
  log: IX2LogObservable;

begin
  { Explicit cast ensures we're getting the same pointer every time if, for example,
    the implementing interface is a descendant of IX2Log }
  log := (ALog as IX2LogObservable);

  if not Assigned(FInstances) then
    FInstances := TMonitorFormDictionary.Create([doOwnsValues]);

  if not FInstances.TryGetValue(log, Result) then
  begin
    Result := TX2LogObserverMonitorForm.Create(nil, log);
    Result.FreeOnClose := True;

    FInstances.Add(log, Result);
  end;
end;


class procedure TX2LogObserverMonitorForm.ShowInstance(ALog: IX2LogObservable);
begin
  Instance(ALog).Show;
end;


class procedure TX2LogObserverMonitorForm.CloseInstance(ALog: IX2LogObservable);
var
  monitorForm: TX2LogObserverMonitorForm;

begin
  if GetInstance(ALog, monitorForm) then
    monitorForm.Close;
end;


class function TX2LogObserverMonitorForm.GetInstance(ALog: IX2LogObservable; out AForm: TX2LogObserverMonitorForm): Boolean;
begin
  Result := False;

  if Assigned(FInstances) then
    Result := FInstances.TryGetValue(ALog as IX2Log, AForm);
end;


class procedure TX2LogObserverMonitorForm.RemoveInstance(AForm: TX2LogObserverMonitorForm);
var
  log: IX2LogObservable;

begin
  if Assigned(FInstances) then
  begin
    for log in FInstances.Keys do
    begin
      if FInstances[log] = AForm then
      begin
        FInstances.ExtractPair(log);
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


constructor TX2LogObserverMonitorForm.Create(AOwner: TComponent; ALogObservable: IX2LogObservable);
var
  captionFormat: string;

begin
  inherited Create(AOwner);

  FLogObservable := ALogObservable;

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

  sdDetails.Filter := GetLogResourceString(@LogMonitorFormSaveDetailsFilter);

  UpdateUI;
end;


procedure TX2LogObserverMonitorForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  Params.WndParent := 0;
end;


destructor TX2LogObserverMonitorForm.Destroy;
begin
  if Assigned(FLogObservable) and FLogAttached then
    FLogObservable.Detach(Self);

  RemoveInstance(Self);

  inherited Destroy;
end;


procedure TX2LogObserverMonitorForm.FormShow(Sender: TObject);
begin
  if Assigned(FLogObservable) and (not FLogAttached) then
  begin
    FLogObservable.Attach(Self);
    FLogAttached := True;
  end;
end;


procedure TX2LogObserverMonitorForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FLogObservable) and FLogAttached then
  begin
    FLogObservable.Detach(Self);
    FLogAttached := False;
  end;

  if FreeOnClose then
    Action := caFree
  else
    Action := caHide;
end;


procedure TX2LogObserverMonitorForm.Log(ALevel: TX2LogLevel; const AMessage: string; ADetails: IX2LogDetails);
var
  node: PVirtualNode;
  nodeData: PLogEntryNodeData;

begin
  { Ensure thread safety; TThread.Queue will run the procedure immediately
    if Log is called from the main thread, or queue it asynchronously }
  TThread.Queue(nil,
    procedure
    var
      scroll: Boolean;

    begin
      if not Paused then
      begin
        scroll := (vstLog.RootNodeCount > 0) and (vstLog.BottomNode = vstLog.GetLast);

        node := vstLog.AddChild(nil);
        nodeData := vstLog.GetNodeData(node);
        nodeData^.Initialize(ALevel, AMessage, ADetails);

        if scroll then
          vstLog.ScrollIntoView(node, False);

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
begin
  actClear.Enabled := (vstLog.RootNodeCount > 0);
end;


procedure TX2LogObserverMonitorForm.UpdateStatus;
begin
  if Paused then
    sbStatus.SimpleText := ' ' + Format(GetLogResourceString(@LogMonitorFormStatusPaused), [PausedLogCount])
  else
    sbStatus.SimpleText := '';
end;


procedure TX2LogObserverMonitorForm.SetDetails(ADetails: IX2LogDetails);
var
  logDetailsBinary: IX2LogDetailsBinary;
  logDetailsText: IX2LogDetailsText;

begin
  FDetails := ADetails;

  if Assigned(Details) then
  begin
    if Supports(ADetails, IX2LogDetailsBinary, logDetailsBinary) then
      SetBinaryDetails(logDetailsBinary)

    else if Supports(ADetails, IX2LogDetailsText, logDetailsText) then
      reDetails.Text := logDetailsText.AsString;
  end else
    reDetails.Clear;


  actCopyDetails.Enabled := Supports(ADetails, IX2LogDetailsCopyable);
  actSaveDetails.Enabled := Supports(ADetails, IX2LogDetailsStreamable);
end;


procedure TX2LogObserverMonitorForm.SetBinaryDetails(ADetails: IX2LogDetailsBinary);
const
  BufferSize = 4096;

  BytesPerLine = 16;
  HexSplitPos = 7;
  HexSplitSpacing = 1;

  HexDigits = 2;
  TextDigits = 1;
  HexSpacing = 0;
  HexTextSpacing = 2;

  ReadableCharacters = [32..126, 161..255];
  UnreadableCharacter = '.';


  procedure ResetLine(var ALine: string);
  var
    linePos: Integer;

  begin
    for linePos := 1 to Length(ALine) do
      ALine[linePos] := ' ';
  end;


var
  stream: TStream;
  buffer: array[0..Pred(BufferSize)] of Byte;
  readBytes: Integer;
  linePosition: Integer;
  line: string;
  bufferIndex: Integer;
  hexValue: string;
  hexPos: Integer;
  textPos: Integer;

begin
  stream := ADetails.AsStream;
  linePosition := 0;

  SetLength(line, (BytesPerLine * (HexDigits + HexSpacing + TextDigits)) + HexTextSpacing +
                  IfThen(HexSplitPos < BytesPerLine, HexSplitSpacing, 0));
  ResetLine(line);

  reDetails.Lines.BeginUpdate;
  try
    reDetails.Lines.Clear;

    while True do
    begin
      readBytes := stream.Read(buffer, SizeOf(buffer));
      if readBytes = 0 then
        break;

      for bufferIndex := 0 to Pred(readBytes) do
      begin
        hexValue := IntToHex(buffer[bufferIndex], HexDigits);

        if linePosition >= BytesPerLine then
        begin
          reDetails.Lines.Add(line);

          ResetLine(line);
          linePosition := 0;
        end;

        hexPos := (linePosition * (HexDigits + HexSpacing));
        if linePosition > HexSplitPos then
          Inc(hexPos, HexSplitSpacing);

        line[hexPos + 1] := hexValue[1];
        line[hexPos + 2] := hexValue[2];

        textPos := (BytesPerLine * (HexDigits + HexSpacing)) + HexTextSpacing + (linePosition * TextDigits);
        if HexSplitPos < BytesPerLine then
          Inc(textPos, HexSplitSpacing);

        if buffer[bufferIndex] in ReadableCharacters then
          line[textPos] := Chr(buffer[bufferIndex])
        else
          line[textPos] := UnreadableCharacter;

        Inc(linePosition);
      end;
    end;

    if linePosition > 0 then
      reDetails.Lines.Add(line);
  finally
    reDetails.Lines.EndUpdate;
  end;
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
        if Assigned(nodeData^.Details) then
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
    SetDetails(nodeData^.Details);
  end else
    SetDetails(nil);

  UpdateUI;
end;


procedure TX2LogObserverMonitorForm.actClearExecute(Sender: TObject);
begin
  vstLog.Clear;
  UpdateUI;
end;


procedure TX2LogObserverMonitorForm.actCopyDetailsExecute(Sender: TObject);
var
  logDetailsCopyable: IX2LogDetailsCopyable;

begin
  if Supports(Details, IX2LogDetailsCopyable, logDetailsCopyable) then
    logDetailsCopyable.CopyToClipboard;
end;


procedure TX2LogObserverMonitorForm.actSaveDetailsExecute(Sender: TObject);
var
  logDetailsStreamable: IX2LogDetailsStreamable;
  outputStream: TFileStream;

begin
  if Supports(Details, IX2LogDetailsStreamable, logDetailsStreamable) then
  begin
    if sdDetails.Execute then
    begin
      outputStream := TFileStream.Create(sdDetails.FileName, fmCreate or fmShareDenyWrite);
      try
        logDetailsStreamable.SaveToStream(outputStream);
      finally
        FreeAndNil(outputStream);
      end;
    end;
  end;
end;


procedure TX2LogObserverMonitorForm.actPauseExecute(Sender: TObject);
begin
  PausedLogCount := 0;
  UpdateStatus;
end;


procedure TX2LogObserverMonitorForm.ToolbarCustomDraw(Sender: TToolBar; const ARect: TRect; var DefaultDraw: Boolean);
var
  element: TThemedElementDetails;
  rect: TRect;

begin
  if StyleServices.Enabled then
  begin
    rect := Sender.ClientRect;
    if Assigned(Self.Menu) then
      Dec(rect.Top, GetSystemMetrics(SM_CYMENU));

    element := StyleServices.GetElementDetails(trRebarRoot);
    StyleServices.DrawElement(Sender.Canvas.Handle, element, rect);
  end;
end;


initialization
finalization
  TX2LogObserverMonitorForm.CleanupInstances;

end.
