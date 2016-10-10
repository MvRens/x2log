unit X2Log.Decorator;

interface
uses
  System.SysUtils,

  X2Log.Intf;


type
  TX2LogCategoryDecoratorClass = class of TX2LogCategoryDecorator;

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
  end;


implementation
uses
  X2Log.Constants,
  X2Log.Details.Default,
  X2Log.Exception.Default;



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
    Result := (TX2LogCategoryDecoratorClass(Self.ClassType)).Create(DecoratedLog, GetCategory(ACategory));
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


procedure TX2LogCategoryDecorator.VerboseS(const AMessage: string; ANamedParams: array of const);
begin
  if Assigned(DecoratedLog) then
    DecoratedLog.Log(TX2LogLevel.Verbose, Now, AMessage, CategoryName, TX2LogDictionaryDetails.CreateIfNotEmpty(ANamedParams));
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


procedure TX2LogCategoryDecorator.InfoS(const AMessage: string; ANamedParams: array of const);
begin
  if Assigned(DecoratedLog) then
    DecoratedLog.Log(TX2LogLevel.Info, Now, AMessage, CategoryName, TX2LogDictionaryDetails.CreateIfNotEmpty(ANamedParams));
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


procedure TX2LogCategoryDecorator.WarningS(const AMessage: string; ANamedParams: array of const);
begin
  if Assigned(DecoratedLog) then
    DecoratedLog.Log(TX2LogLevel.Warning, Now, AMessage, CategoryName, TX2LogDictionaryDetails.CreateIfNotEmpty(ANamedParams));
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


procedure TX2LogCategoryDecorator.ErrorS(const AMessage: string; ANamedParams: array of const);
begin
  if Assigned(DecoratedLog) then
    DecoratedLog.Log(TX2LogLevel.Error, Now, AMessage, CategoryName, TX2LogDictionaryDetails.CreateIfNotEmpty(ANamedParams));
end;


procedure TX2LogCategoryDecorator.Exception(AException: Exception; const AMessage: string);
begin
  if Assigned(DecoratedLog) then
    DecoratedLog.ExceptionEx(AException, AMessage, CategoryName);
end;


procedure TX2LogCategoryDecorator.ExceptionEx(AException: Exception; const AMessage, ACategory: string);
begin
  if Assigned(DecoratedLog) then
    DecoratedLog.ExceptionEx(AException, AMessage, GetCategory(ACategory));
end;


function TX2LogCategoryDecorator.GetCategory(const ACategory: string): string;
begin
  Result := CategoryName;

  if Length(ACategory) > 0 then
    Result := Result + LogCategorySeparator + ACategory;
end;

end.
