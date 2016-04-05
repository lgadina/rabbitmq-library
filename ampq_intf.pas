unit ampq_intf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  IAMQPObject = interface
  ['{17D28537-E3F3-460A-9146-E6195D402365}']
    function GetAsString: AnsiString;
    function GetSize: amqp_long_long_uint;
    procedure SetAsString(const Value: AnsiString);
    procedure Assign(aobject: IAMQPObject);
    procedure Write(AStream: TStream);
    procedure Read(AStream: TStream);
    property Size: amqp_long_long_uint read GetSize;
    property AsString: AnsiString read GetAsString write SetAsString;
  end;


implementation

end.

