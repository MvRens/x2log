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
  protected
    property ExceptionStrategy: IX2LogExceptionStrategy read FExceptionStrategy;
  public
    constructor Create;

    { IX2Log }
    procedure SetExceptionStrategy(AStrategy: IX2LogExceptionStrategy);

    function Category(const ACategory: string): IX2Log;

    procedure Verbose(const AMessage: string; const ADetails: string = '');
    procedure VerboseEx(const AMessage: string; ADetails: IX2LogDetails = nil);
    procedure VerboseS(const AMessage: string; ANamedParams: array of const);

    procedure Info(const AMessage: string; const ADetails: string = '');
    procedure InfoEx(const AMessage: string; ADetails: IX2LogDetails = nil);
    procedure InfoS(const AMessage: string; ANamedParams: array of const);

    procedure Warning(const AMessage: string; const ADetails: string = '');
    procedure WarningEx(const AMessage: string; ADetails: IX2LogDetails = nil);
    procedure WarningS(const AMessage: string; ANamedParams: array of const);

    procedure Error(const AMessage: string; const ADetails: string = '');
    procedure ErrorEx(const AMessage: string; ADetails: IX2LogDetails = nil);
    procedure ErrorS(const AMessage: string; ANamedParams: array of const);

    procedure Exception(AException: Exception; const AMessage: string = '');
    procedure ExceptionEx(AException: Exception; const AMessage: string = ''; const ACategory: string = '');
    procedure ExceptionS(AException: Exception; const AMessage: string; ANamedParams: array of const);
  end;


implementation
uses
  X2Log.Constants,
  X2Log.Decorator,
  X2Log.Details.Default,
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


function TX2Log.Category(const ACategory: string): IX2Log;
begin
  Result := TX2LogCategoryDecorator.Create(Self, ACategory);
end;


procedure TX2Log.Verbose(const AMessage, ADetails: string);
begin
  Log(TX2LogLevel.Verbose, AMessage, LogCategoryDefault, TX2LogStringDetails.CreateIfNotEmpty(ADetails));
end;


procedure TX2Log.VerboseEx(const AMessage: string; ADetails: IX2LogDetails);
begin
  Log(TX2LogLevel.Verbose, AMessage, LogCategoryDefault, ADetails);
end;


procedure TX2Log.VerboseS(const AMessage: string; ANamedParams: array of const);
begin
  Log(TX2LogLevel.Verbose, Now, AMessage, LogCategoryDefault, TX2LogDictionaryDetails.CreateIfNotEmpty(ANamedParams));
end;


procedure TX2Log.Info(const AMessage, ADetails: string);
begin
  Log(TX2LogLevel.Info, AMessage, LogCategoryDefault, TX2LogStringDetails.CreateIfNotEmpty(ADetails));
end;


procedure TX2Log.InfoEx(const AMessage: string; ADetails: IX2LogDetails);
begin
  Log(TX2LogLevel.Info, AMessage, LogCategoryDefault, ADetails);
end;


procedure TX2Log.InfoS(const AMessage: string; ANamedParams: array of const);
begin
  Log(TX2LogLevel.Info, Now, AMessage, LogCategoryDefault, TX2LogDictionaryDetails.CreateIfNotEmpty(ANamedParams));
end;


procedure TX2Log.Warning(const AMessage, ADetails: string);
begin
  Log(TX2LogLevel.Warning, AMessage, LogCategoryDefault, TX2LogStringDetails.CreateIfNotEmpty(ADetails));
end;


procedure TX2Log.WarningEx(const AMessage: string; ADetails: IX2LogDetails);
begin
  Log(TX2LogLevel.Warning, AMessage, LogCategoryDefault, ADetails);
end;


procedure TX2Log.WarningS(const AMessage: string; ANamedParams: array of const);
begin
  Log(TX2LogLevel.Warning, Now, AMessage, LogCategoryDefault, TX2LogDictionaryDetails.CreateIfNotEmpty(ANamedParams));
end;


procedure TX2Log.Error(const AMessage, ADetails: string);
begin
  Log(TX2LogLevel.Error, AMessage, LogCategoryDefault, TX2LogStringDetails.CreateIfNotEmpty(ADetails));
end;


procedure TX2Log.ErrorEx(const AMessage: string; ADetails: IX2LogDetails);
begin
  Log(TX2LogLevel.Error, AMessage, LogCategoryDefault, ADetails);
end;


procedure TX2Log.ErrorS(const AMessage: string; ANamedParams: array of const);
begin
  Log(TX2LogLevel.Error, Now, AMessage, LogCategoryDefault, TX2LogDictionaryDetails.CreateIfNotEmpty(ANamedParams));
end;


procedure TX2Log.Exception(AException: Exception; const AMessage: string);
begin
  ExceptionEx(AException, AMessage, LogCategoryDefault);
end;


procedure TX2Log.ExceptionEx(AException: Exception; const AMessage, ACategory: string);
var
  msg: string;
  exceptionMsg: string;
  detailsText: TStringBuilder;
  details: IX2LogDetails;

begin
  msg := AMessage;
  details := nil;

  detailsText := TStringBuilder.Create;
  try
    ExceptionStrategy.Execute(AException, exceptionMsg,
      procedure(const AKey, AValue: string)
      begin
        detailsText.Append(AKey).Append(': ').Append(AValue).AppendLine;
      end);

    if Length(exceptionMsg) > 0 then
    begin
      if Length(msg) > 0 then
        msg := msg + ': ';

      msg := msg + exceptionMsg;
    end;

    details := TX2LogStringDetails.CreateIfNotEmpty(detailsText.ToString);
  finally
    FreeAndNil(detailsText);
  end;

  Log(TX2LogLevel.Error, msg, ACategory, details);
end;


procedure TX2Log.ExceptionS(AException: Exception; const AMessage: string; ANamedParams: array of const);
var
  details: IX2LogDetailsDictionaryWriter;
  exceptionMsg: string;

begin
  details := TX2LogDictionaryDetails.CreateIfNotEmpty(ANamedParams);

  ExceptionStrategy.Execute(AException, exceptionMsg,
    procedure(const AKey, AValue: string)
    begin
      if not Assigned(details) then
        details := TX2LogDictionaryDetails.Create([]);

      details.SetStringValue(AKey, AValue);
    end);


  if Length(exceptionMsg) > 0 then
  begin
    if not Assigned(details) then
      details := TX2LogDictionaryDetails.Create([]);

    details.SetStringValue('Message', exceptionMsg);
  end;


  Log(TX2LogLevel.Error, Now, AMessage, LogCategoryDefault, details);
end;

end.
