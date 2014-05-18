unit X2Log.Observer.Custom;

interface
uses
  Classes,
  SysUtils,

  X2Log.Intf;


const
  X2LogLevelsAll = [Low(TX2LogLevel)..High(TX2LogLevel)];
  X2LogLevelsDefault = X2LogLevelsAll - [Verbose];

type
  TX2LogLevels = set of TX2LogLevel;

  TX2LogCustomObserver = class(TInterfacedObject, IX2LogObserver)
  private
    FLogLevels: TX2LogLevels;
  protected
    procedure DoLog(ALevel: TX2LogLevel; const AMessage: string; const ADetails: string = ''); virtual; abstract;

    { IX2LogObserver }
    procedure Log(ALevel: TX2LogLevel; const AMessage: string; const ADetails: string = ''); virtual;

    property LogLevels: TX2LogLevels read FLogLevels;
  public
    constructor Create(ALogLevels: TX2LogLevels = X2LogLevelsDefault);
  end;


implementation


{ TX2LogCustomObserver }
constructor TX2LogCustomObserver.Create(ALogLevels: TX2LogLevels);
begin
  inherited Create;

  FLogLevels := ALogLevels;
end;


procedure TX2LogCustomObserver.Log(ALevel: TX2LogLevel; const AMessage, ADetails: string);
begin
  if ALevel in LogLevels then
    DoLog(ALevel, AMessage, ADetails);
end;

end.

