unit X2Log;

interface
uses
  System.Classes,
  System.Generics.Collections,
  System.SysUtils,

  X2Log.Intf,
  X2Log.Client.Base;


type
  IX2LogExceptionCategory = interface
    ['{ED076237-65AA-4B0C-8A25-4A6B28D2F0CB}']
    procedure Exception(AException: Exception; const AMessage: string = ''; const ACategory: string = '');
  end;


  TX2Log = class(TX2LogBaseClient, IX2Log, IX2LogExceptionCategory)
  private
    FExceptionStrategy: IX2LogExceptionStrategy;
  protected
    { IX2LogExceptionCategory }
    procedure Exception(AException: Exception; const AMessage: string = ''; const ACategory: string = ''); overload; virtual;

    property ExceptionStrategy: IX2LogExceptionStrategy read FExceptionStrategy;
  public
    constructor Create;

    { IX2Log }
    procedure SetExceptionStrategy(AStrategy: IX2LogExceptionStrategy);

    function Category(const ACategory: string): IX2Log;

    procedure Verbose(const AMessage: string; const ADetails: string = '');
    procedure VerboseEx(const AMessage: string; ADetails: IX2LogDetails = nil);

    procedure Info(const AMessage: string; const ADetails: string = '');
    procedure InfoEx(const AMessage: string; ADetails: IX2LogDetails = nil);

    procedure Warning(const AMessage: string; const ADetails: string = '');
    procedure WarningEx(const AMessage: string; ADetails: IX2LogDetails = nil);

    procedure Error(const AMessage: string; const ADetails: string = '');
    procedure ErrorEx(const AMessage: string; ADetails: IX2LogDetails = nil);

    procedure Exception(AException: Exception; const AMessage: string = ''); overload;
  end;


  TX2LogCategoryDecorator = class(TInterfacedObject, IX2Log)
  private
    FCategoryName: string;
    FDecoratedLog: IX2Log;
  protected
    function GetCategory(const ACategory: string = ''): string;

    property CategoryName: string read FCategoryName write FCategoryName;
    property DecoratedLog: IX2Log read FDecoratedLog;
  public
    constructor Create(ADecoratedLog: IX2Log; const ACategory: string);

    { IX2LogBase }
    procedure Log(ALevel: TX2LogLevel; const AMessage: string; const ACategory: string = ''; ADetails: IX2LogDetails = nil); overload;
    procedure Log(ALevel: TX2LogLevel; ADateTime: TDateTime; const AMessage: string; const ACategory: string = ''; ADetails: IX2LogDetails = nil); overload;

    { IX2LogObservable }
    procedure Attach(AObserver: IX2LogObserver);
    procedure Detach(AObserver: IX2LogObserver);

    { IX2Log }
    procedure SetExceptionStrategy(AStrategy: IX2LogExceptionStrategy);

    function Category(const ACategory: string): IX2Log;

    procedure Verbose(const AMessage: string; const ADetails: string = '');
    procedure VerboseEx(const AMessage: string; ADetails: IX2LogDetails = nil);

    procedure Info(const AMessage: string; const ADetails: string = '');
    procedure InfoEx(const AMessage: string; ADetails: IX2LogDetails = nil);

    procedure Warning(const AMessage: string; const ADetails: string = '');
    procedure WarningEx(const AMessage: string; ADetails: IX2LogDetails = nil);

    procedure Error(const AMessage: string; const ADetails: string = '');
    procedure ErrorEx(const AMessage: string; ADetails: IX2LogDetails = nil);

    procedure Exception(AException: Exception; const AMessage: string = '');
  end;



implementation
uses
  X2Log.Constants,
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


procedure TX2Log.Info(const AMessage, ADetails: string);
begin
  Log(TX2LogLevel.Info, AMessage, LogCategoryDefault, TX2LogStringDetails.CreateIfNotEmpty(ADetails));
end;


procedure TX2Log.InfoEx(const AMessage: string; ADetails: IX2LogDetails);
begin
  Log(TX2LogLevel.Info, AMessage, LogCategoryDefault, ADetails);
end;


procedure TX2Log.Warning(const AMessage, ADetails: string);
begin
  Log(TX2LogLevel.Warning, AMessage, LogCategoryDefault, TX2LogStringDetails.CreateIfNotEmpty(ADetails));
end;


procedure TX2Log.WarningEx(const AMessage: string; ADetails: IX2LogDetails);
begin
  Log(TX2LogLevel.Warning, AMessage, LogCategoryDefault, ADetails);
end;


procedure TX2Log.Error(const AMessage, ADetails: string);
begin
  Log(TX2LogLevel.Error, AMessage, LogCategoryDefault, TX2LogStringDetails.CreateIfNotEmpty(ADetails));
end;


procedure TX2Log.ErrorEx(const AMessage: string; ADetails: IX2LogDetails);
begin
  Log(TX2LogLevel.Error, AMessage, LogCategoryDefault, ADetails);
end;


procedure TX2Log.Exception(AException: Exception; const AMessage: string);
begin
  Exception(AException, AMessage, LogCategoryDefault);
end;


procedure TX2Log.Exception(AException: Exception; const AMessage, ACategory: string);
var
  msg: string;
  details: IX2LogDetails;

begin
  msg := AMessage;
  details := nil;

  ExceptionStrategy.Execute(AException, msg, details);
  Log(TX2LogLevel.Error, msg, LogCategoryDefault, details);
end;


{ TX2LogCategoryDecorator }
constructor TX2LogCategoryDecorator.Create(ADecoratedLog: IX2Log; const ACategory: string);
begin
  inherited Create;

  FDecoratedLog := ADecoratedLog;
  FCategoryName := ACategory;
end;


procedure TX2LogCategoryDecorator.Log(ALevel: TX2LogLevel; const AMessage, ACategory: string; ADetails: IX2LogDetails);
begin
  if Assigned(DecoratedLog) then
    DecoratedLog.Log(ALevel, AMessage, GetCategory(ACategory), ADetails);
end;


procedure TX2LogCategoryDecorator.Log(ALevel: TX2LogLevel; ADateTime: TDateTime; const AMessage, ACategory: string; ADetails: IX2LogDetails);
begin
  if Assigned(DecoratedLog) then
    DecoratedLog.Log(ALevel, AMessage, GetCategory(ACategory), ADetails);
end;


procedure TX2LogCategoryDecorator.Attach(AObserver: IX2LogObserver);
begin
  if Assigned(DecoratedLog) then
    DecoratedLog.Attach(AObserver);
end;


procedure TX2LogCategoryDecorator.Detach(AObserver: IX2LogObserver);
begin
  if Assigned(DecoratedLog) then
    DecoratedLog.Detach(AObserver);
end;


procedure TX2LogCategoryDecorator.SetExceptionStrategy(AStrategy: IX2LogExceptionStrategy);
begin
  if Assigned(DecoratedLog) then
    DecoratedLog.SetExceptionStrategy(AStrategy);
end;


function TX2LogCategoryDecorator.Category(const ACategory: string): IX2Log;
begin
  if Assigned(DecoratedLog) then
    Result := Self.Create(DecoratedLog, GetCategory(ACategory));
end;


procedure TX2LogCategoryDecorator.Verbose(const AMessage, ADetails: string);
begin
  if Assigned(DecoratedLog) then
    DecoratedLog.Log(TX2LogLevel.Verbose, AMessage, CategoryName, TX2LogStringDetails.CreateIfNotEmpty(ADetails));
end;


procedure TX2LogCategoryDecorator.VerboseEx(const AMessage: string; ADetails: IX2LogDetails);
begin
  if Assigned(DecoratedLog) then
    DecoratedLog.Log(TX2LogLevel.Verbose, AMessage, CategoryName, ADetails);
end;


procedure TX2LogCategoryDecorator.Info(const AMessage, ADetails: string);
begin
  if Assigned(DecoratedLog) then
    DecoratedLog.Log(TX2LogLevel.Info, AMessage, CategoryName, TX2LogStringDetails.CreateIfNotEmpty(ADetails));
end;


procedure TX2LogCategoryDecorator.InfoEx(const AMessage: string; ADetails: IX2LogDetails);
begin
  if Assigned(DecoratedLog) then
    DecoratedLog.Log(TX2LogLevel.Info, AMessage, CategoryName, ADetails);
end;


procedure TX2LogCategoryDecorator.Warning(const AMessage, ADetails: string);
begin
  if Assigned(DecoratedLog) then
    DecoratedLog.Log(TX2LogLevel.Warning, AMessage, CategoryName, TX2LogStringDetails.CreateIfNotEmpty(ADetails));
end;


procedure TX2LogCategoryDecorator.WarningEx(const AMessage: string; ADetails: IX2LogDetails);
begin
  if Assigned(DecoratedLog) then
    DecoratedLog.Log(TX2LogLevel.Warning, AMessage, CategoryName, ADetails);
end;


procedure TX2LogCategoryDecorator.Error(const AMessage, ADetails: string);
begin
  if Assigned(DecoratedLog) then
    DecoratedLog.Log(TX2LogLevel.Error, AMessage, CategoryName, TX2LogStringDetails.CreateIfNotEmpty(ADetails));
end;


procedure TX2LogCategoryDecorator.ErrorEx(const AMessage: string; ADetails: IX2LogDetails);
begin
  if Assigned(DecoratedLog) then
    DecoratedLog.Log(TX2LogLevel.Error, AMessage, CategoryName, ADetails);
end;


procedure TX2LogCategoryDecorator.Exception(AException: Exception; const AMessage: string);
var
  exceptionCategory: IX2LogExceptionCategory;

begin
  if not Assigned(DecoratedLog) then
    exit;

  if Supports(DecoratedLog, IX2LogExceptionCategory, exceptionCategory) then
    exceptionCategory.Exception(AException, AMessage, CategoryName)
  else
    DecoratedLog.Log(TX2LogLevel.Error, AMessage, CategoryName);
end;


function TX2LogCategoryDecorator.GetCategory(const ACategory: string): string;
begin
  Result := CategoryName;

  if Length(ACategory) > 0 then
    Result := Result + LogCategorySeparator + ACategory;
end;

end.
