unit X2Log.TextFormatter.Intf;

interface
uses
  System.Classes,

  X2Log.Intf;

type
  IX2LogTextFormatterHelper = interface
    ['{D1A1DAD5-0F96-491F-8BD5-0B9D0BE87C32}']
    function GetDetailsFilename: string;
    function SaveDetailsToStream(AStream: TStream): Boolean;
  end;

  IX2LogTextFormatter = interface
    ['{C49BE49D-8563-4097-A2B7-0869F27F5EDD}']
    function GetText(AHelper: IX2LogTextFormatterHelper; ALevel: TX2LogLevel; ADateTime: TDateTime; const AMessage: string; const ACategory: string; ADetails: IX2LogDetails): string;
  end;

implementation

end.
