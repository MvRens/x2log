unit X2Log.Intf;

interface
uses
  System.Classes,
  System.SysUtils;


type
  TX2LogLevel = (Verbose, Info, Warning, Error);
  TX2LogLevels = set of TX2LogLevel;


const
  X2LogLevelsAll = [Low(TX2LogLevel)..High(TX2LogLevel)];
  X2LogLevelsDefault = X2LogLevelsAll - [Verbose];


type
  { Details }
  IX2LogDetails = interface
    ['{86F24F52-CE1F-4A79-936F-A5805D84E18A}']
    function GetSerializerIID: TGUID;

    property SerializerIID: TGUID read GetSerializerIID;
  end;


  IX2LogDetailsSerializer = interface
    ['{E75F6F4E-A671-4622-878C-F59C64FB1320}']
    procedure Serialize(ADetails: IX2LogDetails; AStream: TStream);
    function Deserialize(AStream: TStream): IX2LogDetails;
  end;


  IX2LogDetailsCopyable = interface
    ['{BA93B3CD-4F05-4887-A585-78093E0B31C9}']
    procedure CopyToClipboard;
  end;


  IX2LogDetailsStreamable = interface
    ['{7DD0756D-F06E-4267-A433-04BEFF4FA955}']
    procedure SaveToStream(AStream: TStream);
  end;


  { Logging }
  IX2LogBase = interface
    ['{1949E8DC-6DC5-43DC-B678-55CF8274E79D}']
    procedure Log(ALevel: TX2LogLevel; const AMessage: string; const ACategory: string = ''; ADetails: IX2LogDetails = nil); overload;
    procedure Log(ALevel: TX2LogLevel; ADateTime: TDateTime; const AMessage: string; const ACategory: string = ''; ADetails: IX2LogDetails = nil); overload;
  end;


  IX2LogObserver = interface(IX2LogBase)
    ['{CBC5C18E-84EE-43F4-8DBE-C66D06FCDE74}']
  end;


  IX2LogExceptionStrategy = interface
    ['{C0B7950E-BE0A-4A21-A7C5-F8322FD4E205}']
    procedure Execute(AException: Exception; var AMessage: string; var ADetails: IX2LogDetails);
  end;


  IX2LogObservable = interface(IX2LogBase)
    ['{50B47D5D-11E4-40E0-BBC4-8BA70697C1F9}']
    procedure Attach(AObserver: IX2LogObserver);
    procedure Detach(AObserver: IX2LogObserver);
  end;


  IX2Log = interface(IX2LogObservable)
    ['{A6FF38F9-EDA8-4C76-9C95-2C0317560D78}']
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
    procedure ExceptionEx(AException: Exception; const AMessage: string = ''; const ACategory: string = '');
  end;
  


  TX2LogMessageHeaderV1 = packed record
    ID: Word;
    Version: Byte;
    Size: Word;
    DateTime: TDateTime;
    Level: TX2LogLevel;

    {
    Payload:

      CategoryLength: Cardinal
      Category: WideString
      MessageLength: Cardinal
      Message: WideString
      DetailsLength: Cardinal
      Details: WideString
    }
  end;


  TX2LogMessageHeader = TX2LogMessageHeaderV1;

const
  X2LogMessageHeader: Word = $B258;
  X2LogMessageVersion: Byte = 1;


implementation

end.
