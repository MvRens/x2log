unit X2Log.Intf.NamedPipe;

interface
uses
  X2Log.Intf;

type
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
