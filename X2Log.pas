unit X2Log;

interface
uses
  System.Classes,
  System.Generics.Collections,
  System.SysUtils,

  X2Log.Intf,
  X2Log.Client.Base;


type
  TX2Log = class(TX2LogBaseClient, IX2Log)
  private
    FExceptionStrategy: IX2LogExceptionStrategy;
  private
    property ExceptionStrategy: IX2LogExceptionStrategy read FExceptionStrategy;
  public
    constructor Create;

    { IX2Log }
    procedure SetExceptionStrategy(AStrategy: IX2LogExceptionStrategy);

    procedure Verbose(const AMessage: string; const ADetails: string = '');
    procedure Info(const AMessage: string; const ADetails: string = '');
    procedure Warning(const AMessage: string; const ADetails: string = '');
    procedure Error(const AMessage: string; const ADetails: string = '');
    procedure Exception(AException: Exception; const AMessage: string = ''; const ADetails: string = '');
  end;
  

implementation
uses
  X2Log.Exception.Default;


{ TX2Log }
constructor TX2Log.Create;
begin
  inherited Create;

  SetExceptionStrategy(nil);
end;


procedure TX2Log.SetExceptionStrategy(AStrategy: IX2LogExceptionStrategy);
begin
  if Assigned(AStrategy) then
    FExceptionStrategy := AStrategy
  else
    FExceptionStrategy := TX2LogDefaultExceptionStrategy.Create;
end;


procedure TX2Log.Verbose(const AMessage, ADetails: string);
begin
  Log(TX2LogLevel.Verbose, AMessage, ADetails);
end;


procedure TX2Log.Info(const AMessage, ADetails: string);
begin
  Log(TX2LogLevel.Info, AMessage, ADetails);
end;


procedure TX2Log.Warning(const AMessage, ADetails: string);
begin
  Log(TX2LogLevel.Warning, AMessage, ADetails);
end;


procedure TX2Log.Error(const AMessage, ADetails: string);
begin
  Log(TX2LogLevel.Error, AMessage, ADetails);
end;


procedure TX2Log.Exception(AException: Exception; const AMessage, ADetails: string);
var
  msg: string;
  details: string;

begin
  msg := AMessage;
  details := ADetails;

  ExceptionStrategy.Execute(AException, msg, details);
  Log(TX2LogLevel.Error, msg, details);
end;

end.
