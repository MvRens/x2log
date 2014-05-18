unit X2Log.Intf;

interface
uses
  System.SysUtils;

type
  TX2LogLevel = (Verbose, Info, Warning, Error);


  IX2LogMethods = interface
    ['{1949E8DC-6DC5-43DC-B678-55CF8274E79D}']
    procedure Log(ALevel: TX2LogLevel; const AMessage: string; const ADetails: string = '');
  end;


  IX2LogObserver = interface(IX2LogMethods)
    ['{CBC5C18E-84EE-43F4-8DBE-C66D06FCDE74}']
  end;


  IX2LogExceptionStrategy = interface
    ['{C0B7950E-BE0A-4A21-A7C5-F8322FD4E205}']
    procedure Execute(AException: Exception; var AMessage: string; var ADetails: string);
  end;


  IX2Log = interface(IX2LogMethods)
    ['{A6FF38F9-EDA8-4C76-9C95-2C0317560D78}']
    procedure Attach(AObserver: IX2LogObserver);
    procedure Detach(AObserver: IX2LogObserver);

    procedure SetExceptionStrategy(AStrategy: IX2LogExceptionStrategy);

    procedure Verbose(const AMessage: string; const ADetails: string = '');
    procedure Info(const AMessage: string; const ADetails: string = '');
    procedure Warning(const AMessage: string; const ADetails: string = '');
    procedure Error(const AMessage: string; const ADetails: string = '');
    procedure Exception(AException: Exception; const AMessage: string = ''; const ADetails: string = '');
  end;
  

implementation

end.
