unit X2Log.Details.Intf;

interface
uses
  System.Classes,
  Vcl.Graphics,

  X2Log.Intf;


type
  IX2LogDetailsText = interface(IX2LogDetails)
    ['{D5F194E9-8633-4575-801D-E8983124118F}']
    function GetAsString: string;

    property AsString: string read GetAsString;
  end;


  IX2LogDetailsDictionary = interface(IX2LogDetails)
    ['{24211DC0-F359-466B-A9CD-AF6AA3AE85F4}']
    function GetValue(const Key: string): Variant;

    property Values[const Key: string]: Variant read GetValue;
  end;


  IX2LogDetailsBinary = interface(IX2LogDetails)
    ['{265739E7-BB65-434B-BCD3-BB89B936A854}']
    function GetAsStream: TStream;

    { Note: Stream Position will be reset by GetAsStream }
    property AsStream: TStream read GetAsStream;
  end;


  IX2LogDetailsGraphic = interface(IX2LogDetails)
    ['{ED8200AA-0D0F-4D8D-BE7D-A32AC7D630AF}']
    function GetAsGraphic: TGraphic;

    property AsGraphic: TGraphic read GetAsGraphic;
  end;


implementation

end.
