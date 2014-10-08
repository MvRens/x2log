unit X2Log.Observer.Custom;

interface
uses
  Classes,
  SysUtils,

  X2Log.Intf;


type
  TX2LogLevels = set of TX2LogLevel;

  TX2LogCustomObserver = class(TInterfacedObject, IX2LogBase, IX2LogObserver)
  private
    FLogLevels: TX2LogLevels;
  protected
    procedure DoLog(ALevel: TX2LogLevel; ADateTime: TDateTime; const AMessage: string; ADetails: IX2LogDetails); virtual; abstract;

    property LogLevels: TX2LogLevels read FLogLevels;
  public
    constructor Create(ALogLevels: TX2LogLevels = X2LogLevelsDefault);

    { IX2LogBase }
    procedure Log(ALevel: TX2LogLevel; const AMessage: string; ADetails: IX2LogDetails = nil); overload;
    procedure Log(ALevel: TX2LogLevel; ADateTime: TDateTime; const AMessage: string; ADetails: IX2LogDetails = nil); overload;
  end;


implementation


{ TX2LogCustomObserver }
constructor TX2LogCustomObserver.Create(ALogLevels: TX2LogLevels);
begin
  inherited Create;

  FLogLevels := ALogLevels;
end;


procedure TX2LogCustomObserver.Log(ALevel: TX2LogLevel; const AMessage: string; ADetails: IX2LogDetails);
begin
  Log(ALevel, Now, AMessage, ADetails);
end;


procedure TX2LogCustomObserver.Log(ALevel: TX2LogLevel; ADateTime: TDateTime; const AMessage: string; ADetails: IX2LogDetails);
begin
  if ALevel in LogLevels then
    DoLog(ALevel, ADateTime, AMessage, ADetails);
end;

end.

