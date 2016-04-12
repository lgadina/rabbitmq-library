
unit amqp_types;
{$ifdef FPC}
  {$mode delphi}
  {$RANGECHECKS OFF}
{$endif}
interface

uses classes, contnrs;

const
  AMQP_FRAME_EMPTY = 0;
  AMQP_FRAME_METHOD = 1;
  AMQP_FRAME_HEADER = 2;
  AMQP_FRAME_BODY = 3;
  AMQP_FRAME_HEARTBEAT = 8;
  AMQP_FRAME_DISCONNECT = AMQP_FRAME_METHOD or AMQP_FRAME_HEARTBEAT;
  AMQP_SIGN = $50514D41;
  AMQP_FRAME_HEADER_SIZE = 7;

type
  TAMQPExchangeType = ( etDirect, etTopic, etFanout, etHeaders );

Const
  AMQPExchangeTypeStr : Array[TAMQPExchangeType] of string = ( 'direct', 'topic', 'fanout', 'headers' );

type
  amqp_octet = byte;

  amqp_2octet = word;
  amqp_4octet = LongWord;
  amqp_8octet = UInt64;
  amqp_boolean = Boolean;
  amqp_bit = amqp_boolean;

  amqp_short_short_uint = amqp_octet;
  amqp_short_short_int = ShortInt;
  amqp_short_uint = amqp_2octet;
  amqp_class_id = amqp_short_uint;
  amqp_short_int = SmallInt;

  amqp_long_uint = amqp_4octet;
  amqp_long_int = Int32;
  amqp_long_long_uint = amqp_8octet;
  amqp_long_long_int = Int64;
  amqp_float = single;
  amqp_double = double;
  amqp_timestamp = amqp_long_long_uint;
  amqp_string_char = AnsiChar;

  amqp_protocol_header = record
    sign: LongWord;
    protocolMajor: amqp_octet;
    protocolMinor: amqp_octet;
    versionMajor: amqp_octet;
    versionMinor: amqp_octet;
  end;

  { IAMQPObject }

  IAMQPObject = interface
  ['{17D28537-E3F3-460A-9146-E6195D402365}']
    function GetAsDebugString: String;
    function GetAsString: AnsiString;
    function GetName: String;
    function GetSize: amqp_long_long_uint;
    function GetRefCount: Integer;
    function GetClassName: String;
    procedure SetAsString(const Value: AnsiString);
    procedure Assign(aobject: IAMQPObject);
    procedure SetName(AValue: String);
    procedure Write(AStream: TStream);
    procedure Read(AStream: TStream);
    property Size: amqp_long_long_uint read GetSize;

    property AsString: AnsiString read GetAsString write SetAsString;
    property AsDebugString: String read GetAsDebugString;
    property Name: String read GetName write SetName;
  end;

  { TAMQPInterfacedObject }

  TAMQPInterfacedObject = class(TObject, IUnknown)
  protected
     frefcount : longint;
     function QueryInterface(constref iid : tguid;out obj) : longint; virtual; cdecl;
     function _AddRef : longint;cdecl;
     function _Release : longint;cdecl;
   public
     procedure AfterConstruction;override;
     procedure BeforeDestruction;override;
     class function NewInstance : TObject;override;
     property RefCount : longint read frefcount;
  end;


  { amqp_object }

  amqp_object = class(TInterfacedObject, IAMQPObject)
  private
    FName: String;
    function GetAsString: AnsiString;
    function GetName: String;
    procedure SetAsString(const Value: AnsiString);
    procedure SetName(AValue: String);
  protected
    function GetClassName: String;
    procedure WriteOctet(AStream: TStream; AValue: amqp_octet);
    procedure WriteShortShortUInt(AStream: TStream;
      AValue: amqp_short_short_uint);
    procedure WriteShortShortInt(AStream: TStream;
      AValue: amqp_short_short_int);
    procedure WriteBoolean(AStream: TStream; AValue: amqp_boolean);

    procedure Write2Octet(AStream: TStream; AValue: amqp_2octet);
    procedure WriteShortInt(AStream: TStream; AValue: amqp_short_int);
    procedure WriteShortUInt(AStream: TStream; AValue: amqp_short_uint);

    procedure Write4Octet(AStream: TStream; AValue: amqp_4octet);
    procedure WriteLongUInt(AStream: TStream; AValue: amqp_long_uint);
    procedure WriteLongInt(AStream: TStream; AValue: amqp_long_int);

    procedure Write8Octet(AStream: TStream; AValue: amqp_8octet);
    procedure WriteLongLongUInt(AStream: TStream; AValue: amqp_long_long_uint);
    procedure WriteLongLongInt(AStream: TStream; AValue: amqp_long_long_int);

    procedure WriteFloat(AStream: TStream; AValue: amqp_float);
    procedure WriteDouble(AStream: TStream; AValue: amqp_double);
    procedure WriteChar(AStream: TStream; AValue: amqp_string_char);

    function ReadOctet(AStream: TStream): amqp_octet;
    function ReadShortShortUInt(AStream: TStream): amqp_short_short_uint;
    function ReadShortShortInt(AStream: TStream): amqp_short_short_int;
    function ReadBoolean(AStream: TStream): amqp_boolean;

    function Read2Octet(AStream: TStream): amqp_2octet;
    function ReadShortUInt(AStream: TStream): amqp_short_uint;
    function ReadShortInt(AStream: TStream): amqp_short_int;

    function Read4Octet(AStream: TStream): amqp_4octet;
    function ReadLongUInt(AStream: TStream): amqp_long_uint;
    function ReadLongInt(AStream: TStream): amqp_long_int;

    function Read8Octet(AStream: TStream): amqp_8octet;
    function ReadLongLongUInt(AStream: TStream): amqp_long_long_uint;
    function ReadLongLongInt(AStream: TStream): amqp_long_long_int;

    function ReadFloat(AStream: TStream): amqp_float;
    function ReadDouble(AStream: TStream): amqp_double;
    function ReadChar(AStream: TStream): amqp_string_char;

    procedure DoWrite(AStream: TStream); virtual; abstract;
    procedure DoRead(AStream: TStream); virtual; abstract;
    function GetSize: amqp_long_long_uint; virtual; abstract;
    function GetRefCount: Integer;
    function GetAsDebugString: String; virtual;
  public
    constructor Create(AName: String = ''); virtual;
    destructor Destroy; override;
    procedure Assign(aobject: IAMQPObject); virtual; abstract;
    procedure Write(AStream: TStream);
    procedure Read(AStream: TStream);
    property Size: amqp_long_long_uint read GetSize;
    property AsString: AnsiString read GetAsString write SetAsString;
    property Name: String read GetName write SetName;
  end;

  amqp_object_class = class of amqp_object;

  IAMQPDecimal = interface(IAMQPObject)
  ['{C950B739-8176-4191-9B18-5F9283DB019B}']
    function Getscale: amqp_octet;
    function Getvalue: amqp_long_uint;
    procedure Setscale(const Value: amqp_octet);
    procedure Setvalue(const Value: amqp_long_uint);
    property scale: amqp_octet read Getscale write Setscale;
    property Value: amqp_long_uint read Getvalue write Setvalue;
  end;

  { amqp_decimal }

  amqp_decimal = class(amqp_object, IAMQPDecimal)
  private
    Fvalue: amqp_long_uint;
    Fscale: amqp_octet;
    function Getscale: amqp_octet;
    function Getvalue: amqp_long_uint;
    procedure Setscale(const Value: amqp_octet);
    procedure Setvalue(const Value: amqp_long_uint);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: IAMQPObject); override;
    property scale: amqp_octet read Getscale write Setscale;
    property Value: amqp_long_uint read Getvalue write Setvalue;
  end;

  IAMQPShortStr = interface(IAMQPObject)
  ['{F510DCEA-01F4-41C5-93AB-015B12FA4486}']
    function GetLen: amqp_short_short_uint;
    function Getval: AnsiString;
    procedure setval(const Value: AnsiString);
    property len: amqp_short_short_uint read GetLen;
    property val: AnsiString read Getval write setval;
  end;

  { amqp_short_str }

  amqp_short_str = class(amqp_object, IAMQPShortStr)
  private
    fval: AnsiString;
    flen: amqp_short_short_uint;
    function GetLen: amqp_short_short_uint;
    function Getval: AnsiString;
    procedure setval(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    destructor Destroy; override;
    procedure Assign(aobject: IAMQPObject); override;
    property len: amqp_short_short_uint read GetLen;
    property val: AnsiString read Getval write setval;
  end;

  amqp_exchange_name = amqp_short_str;

  IAMQPExchangeName = IAMQPShortStr;

  IAMQPConsumerTag = IAMQPShortStr;
  amqp_delivery_tag = amqp_long_long_uint;
  amqp_message_count = amqp_long_uint;
  amqp_method_id = amqp_short_uint;
  amqp_no_ack = amqp_bit;
  amqp_no_local = amqp_bit;
  amqp_no_wait = amqp_bit;
  IAMQPPath = amqp_short_str;

  { IAMQPLongStr }

  IAMQPLongStr = interface(IAMQPObject)
  ['{F5C8B4E3-6453-4F6E-9832-6C53255F244E}']
    function Getlen: amqp_long_uint;
    function Getval: AnsiString;
    procedure setval(const Value: AnsiString);
    property val: AnsiString read Getval write setval;
  end;

  { amqp_long_str }

  amqp_long_str = class(amqp_object, IAMQPLongStr)
  private
    fval: AnsiString;
    flen: amqp_long_uint;
    function Getlen: amqp_long_uint;
    function Getval: AnsiString;
    procedure setval(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: IAMQPObject); override;
    property len: amqp_long_uint read Getlen;
    property val: AnsiString read Getval write setval;
  end;

  amqp_field_array = class;
  amqp_table = class;

  { IAMQPFieldValue }
  IAMQPArray = interface;
  IAMQPTable = interface;

  IAMQPFieldValue = interface(IAMQPObject)
  ['{C86D5787-FA64-4D10-ACF7-8D857B972422}']
    function GetAsArray: IAMQPArray;
    function GetAsBoolean: Boolean;
    function GetAsDecimal: IAMQPDecimal;
    function GetAsDouble: amqp_double;
    function GetAsFloat: amqp_float;
    function GetAsLongInt: amqp_long_int;
    function GetAsLongLongInt: amqp_long_long_int;
    function GetAsLongLongUInt: amqp_long_long_uint;
    function GetAsLongString: AnsiString;
    function GetAsLongUInt: amqp_long_uint;
    function GetAsShortInt: amqp_short_int;
    function GetAsShortShortInt: amqp_short_short_int;
    function GetAsShortShortUInt: amqp_short_short_uint;
    function GetAsShortString: AnsiString;
    function GetAsShortUInt: amqp_short_uint;
    function GetAsTable: IAMQPTable;
    function Getkind: amqp_string_char;
    function GetVal: IAMQPObject;
    procedure SetAsArray(AValue: IAMQPArray);
    procedure SetAsBoolean(const Value: Boolean);
    procedure SetAsDouble(const Value: amqp_double);
    procedure SetAsFloat(const Value: amqp_float);
    procedure SetAsLongInt(const Value: amqp_long_int);
    procedure SetAsLongLongInt(const Value: amqp_long_long_int);
    procedure SetAsLongLongUInt(const Value: amqp_long_long_uint);
    procedure SetAsLongString(const Value: AnsiString);
    procedure SetAsLongUInt(const Value: amqp_long_uint);
    procedure SetAsShortInt(const Value: amqp_short_int);
    procedure SetAsShortShortInt(const Value: amqp_short_short_int);
    procedure SetAsShortShortUInt(const Value: amqp_short_short_uint);
    procedure SetAsShortString(const Value: AnsiString);
    procedure SetAsShortUInt(const Value: amqp_short_uint);
    procedure SetAsTable(AValue: IAMQPTable);
    procedure setKind(const Value: amqp_string_char);
    property kind: amqp_string_char read Getkind write setKind;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property AsShortShortUInt: amqp_short_short_uint read GetAsShortShortUInt
      write SetAsShortShortUInt;
    property AsShortShortInt: amqp_short_short_int read GetAsShortShortInt
      write SetAsShortShortInt;
    property AsShortUInt: amqp_short_uint read GetAsShortUInt
      write SetAsShortUInt;
    property AsShortInt: amqp_short_int read GetAsShortInt write SetAsShortInt;
    property AsLongUInt: amqp_long_uint read GetAsLongUInt write SetAsLongUInt;
    property AsLongInt: amqp_long_int read GetAsLongInt write SetAsLongInt;
    property AsLongLongUInt: amqp_long_long_uint read GetAsLongLongUInt
      write SetAsLongLongUInt;
    property AsLongLongInt: amqp_long_long_int read GetAsLongLongInt
      write SetAsLongLongInt;
    property AsFloat: amqp_float read GetAsFloat write SetAsFloat;
    property AsDouble: amqp_double read GetAsDouble write SetAsDouble;
    property AsDecimalValue: IAMQPDecimal read GetAsDecimal;
    property AsShortString: AnsiString read GetAsShortString
      write SetAsShortString;
    property AsLongString: AnsiString read GetAsLongString
      write SetAsLongString;
    property AsArray: IAMQPArray read GetAsArray write SetAsArray;
    property AsTable: IAMQPTable read GetAsTable write SetAsTable;
    function Clone: IAMQPFieldValue;
    property val: IAMQPObject read GetVal;
  end;

  { amqp_field_value }



  amqp_field_value = class(amqp_object, IAMQPFieldValue)
  private
    fkind: amqp_string_char;
    fval: IAMQPObject;
    function GetAsShortString: AnsiString;
    function Getkind: amqp_string_char;
    function GetVal: IAMQPObject;
    procedure SetAsArray(AValue: IAMQPArray);
    procedure SetAsShortString(const Value: AnsiString);
    function GetAsLongString: AnsiString;
    procedure SetAsLongString(const Value: AnsiString);
    function GetAsBoolean: Boolean;
    procedure SetAsBoolean(const Value: Boolean);
    procedure DestroyVal;
    function GetAsDecimal: IAMQPDecimal;
    function GetAsDouble: amqp_double;
    function GetAsFloat: amqp_float;
    function GetAsLongInt: amqp_long_int;
    function GetAsLongLongInt: amqp_long_long_int;
    function GetAsLongLongUInt: amqp_long_long_uint;
    function GetAsLongUInt: amqp_long_uint;
    function GetAsShortInt: amqp_short_int;
    function GetAsShortShortInt: amqp_short_short_int;
    function GetAsShortShortUInt: amqp_short_short_uint;
    function GetAsShortUInt: amqp_short_uint;
    procedure SetAsDouble(const Value: amqp_double);
    procedure SetAsFloat(const Value: amqp_float);
    procedure SetAsLongInt(const Value: amqp_long_int);
    procedure SetAsLongLongInt(const Value: amqp_long_long_int);
    procedure SetAsLongLongUInt(const Value: amqp_long_long_uint);
    procedure SetAsLongUInt(const Value: amqp_long_uint);
    procedure SetAsShortInt(const Value: amqp_short_int);
    procedure SetAsShortShortInt(const Value: amqp_short_short_int);
    procedure SetAsShortShortUInt(const Value: amqp_short_short_uint);
    procedure SetAsShortUInt(const Value: amqp_short_uint);
    function GetAsArray: IAMQPArray;
    function GetAsTable: IAMQPTable;
    procedure SetAsTable(AValue: IAMQPTable);
    procedure setKind(const Value: amqp_string_char);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
    function CreateVal: IAMQPObject;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property kind: amqp_string_char read Getkind write setKind;
    property val: IAMQPObject read GetVal;
    procedure Assign(aobject: IAMQPObject); override;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property AsShortShortUInt: amqp_short_short_uint read GetAsShortShortUInt
      write SetAsShortShortUInt;
    property AsShortShortInt: amqp_short_short_int read GetAsShortShortInt
      write SetAsShortShortInt;
    property AsShortUInt: amqp_short_uint read GetAsShortUInt
      write SetAsShortUInt;
    property AsShortInt: amqp_short_int read GetAsShortInt write SetAsShortInt;
    property AsLongUInt: amqp_long_uint read GetAsLongUInt write SetAsLongUInt;
    property AsLongInt: amqp_long_int read GetAsLongInt write SetAsLongInt;
    property AsLongLongUInt: amqp_long_long_uint read GetAsLongLongUInt
      write SetAsLongLongUInt;
    property AsLongLongInt: amqp_long_long_int read GetAsLongLongInt
      write SetAsLongLongInt;
    property AsFloat: amqp_float read GetAsFloat write SetAsFloat;
    property AsDouble: amqp_double read GetAsDouble write SetAsDouble;
    property AsDecimalValue: IAMQPDecimal read GetAsDecimal;
    property AsShortString: AnsiString read GetAsShortString
      write SetAsShortString;
    property AsLongString: AnsiString read GetAsLongString
      write SetAsLongString;
    property AsArray: IAMQPArray read GetAsArray write SetAsArray;
    property AsTable: IAMQPTable read GetAsTable write SetAsTable;
    function Clone: IAMQPFieldValue;
  end;

  { IAMQPFieldBoolean }

  IAMQPBoolean = interface(IAMQPObject)
  ['{58881DF7-0194-45E2-B19A-E96AE859B668}']
    function Getvalue: Boolean;
    procedure Setvalue(AValue: Boolean);
    property Value: Boolean read Getvalue write Setvalue;
  end;

  { amqp_field_boolean }

  amqp_field_boolean = class(amqp_object, IAMQPBoolean)
  private
    Fvalue: Boolean;
    function Getvalue: Boolean;
    procedure Setvalue(AValue: Boolean);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: IAMQPObject); override;
    property Value: Boolean read Getvalue write Setvalue;
  end;

  { IAMQPShortShortUInt }

  IAMQPShortShortUInt = interface(IAMQPObject)
  ['{721DC01F-D0C7-4EF2-8566-C60683B32055}']
    function Getvalue: amqp_short_short_uint;
    procedure Setvalue(AValue: amqp_short_short_uint);
    property Value: amqp_short_short_uint read Getvalue write Setvalue;
  end;

  { amqp_field_short_short_uint }

  amqp_field_short_short_uint = class(amqp_object)
  private
    Fvalue: amqp_short_short_uint;
    function Getvalue: amqp_short_short_uint;
    procedure Setvalue(AValue: amqp_short_short_uint);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: IAMQPObject); override;
    property Value: amqp_short_short_uint read Getvalue write Setvalue;
  end;

  IAMQPShortShortInt = interface(IAMQPObject)
  ['{8523424B-1209-4ED3-A07C-6C9681ED99C4}']
    function Getvalue: amqp_short_short_int;
    procedure Setvalue(AValue: amqp_short_short_int);
    property Value: amqp_short_short_int read Getvalue write Setvalue;
  end;

  { amqp_field_short_short_int }

  amqp_field_short_short_int = class(amqp_object, IAMQPShortShortInt)
  private
    Fvalue: amqp_short_short_int;
    function Getvalue: amqp_short_short_int;
    procedure Setvalue(AValue: amqp_short_short_int);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: IAMQPObject); override;
    property Value: amqp_short_short_int read Getvalue write Setvalue;
  end;

  IAMQPShortInt = interface(IAMQPObject)
  ['{28256B32-406A-4E79-A030-1C7C0D56BE61}']
    function Getvalue: amqp_short_int;
    procedure Setvalue(AValue: amqp_short_int);
    property Value: amqp_short_int read Getvalue write Setvalue;
  end;

  { amqp_field_short_int }

  amqp_field_short_int = class(amqp_object, IAMQPShortInt)
  private
    Fvalue: amqp_short_int;
    function Getvalue: amqp_short_int;
    procedure Setvalue(AValue: amqp_short_int);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: IAMQPObject); override;
    property Value: amqp_short_int read Getvalue write Setvalue;
  end;

  IAMQPShortUInt = interface(IAMQPObject)
  ['{28256B32-406A-4E79-A030-1C7C0D56BE61}']
    function Getvalue: amqp_short_uint;
    procedure Setvalue(AValue: amqp_short_uint);
    property Value: amqp_short_uint read Getvalue write Setvalue;
  end;

  { amqp_field_short_uint }

  amqp_field_short_uint = class(amqp_object, IAMQPShortUInt)
  private
    Fvalue: amqp_short_uint;
    function Getvalue: amqp_short_uint;
    procedure Setvalue(AValue: amqp_short_uint);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: IAMQPObject); override;
    property Value: amqp_short_uint read Getvalue write Setvalue;
  end;

  IAMQPLongUInt = interface(IAMQPObject)
  ['{28256B32-406A-4E79-A030-1C7C0D56BE61}']
    function Getvalue: amqp_long_uint;
    procedure Setvalue(AValue: amqp_long_uint);
    property Value: amqp_long_uint read Getvalue write Setvalue;
  end;

  { amqp_field_long_uint }

  amqp_field_long_uint = class(amqp_object, IAMQPLongUInt)
  private
    Fvalue: amqp_long_uint;
    function Getvalue: amqp_long_uint;
    procedure Setvalue(AValue: amqp_long_uint);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: IAMQPObject); override;
    property Value: amqp_long_uint read Getvalue write Setvalue;
  end;

  IAMQPLongInt = interface(IAMQPObject)
  ['{28256B32-406A-4E79-A030-1C7C0D56BE61}']
    function Getvalue: amqp_long_int;
    procedure Setvalue(AValue: amqp_long_int);
    property Value: amqp_long_int read Getvalue write Setvalue;
  end;


  { amqp_field_long_int }

  amqp_field_long_int = class(amqp_object, IAMQPLongInt)
  private
    Fvalue: amqp_long_int;
    function Getvalue: amqp_long_int;
    procedure Setvalue(AValue: amqp_long_int);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: IAMQPObject); override;
    property Value: amqp_long_int read Getvalue write Setvalue;
  end;

  { IAMQPLongLongUInt }

  IAMQPLongLongUInt = interface(IAMQPObject)
  ['{C49840C2-B7CC-4DC4-8627-DF2BD0F3C735}']
    function Getwrite: amqp_long_long_uint;
    procedure Setvalue(AValue: amqp_long_long_uint);
    property Value: amqp_long_long_uint read Getwrite write Setvalue;
  end;

  { amqp_field_long_long_uint }

  amqp_field_long_long_uint = class(amqp_object, IAMQPLongLongUInt)
  private
    Fvalue: amqp_long_long_uint;
    function Getwrite: amqp_long_long_uint;
    procedure Setvalue(AValue: amqp_long_long_uint);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: IAMQPObject); override;
    property Value: amqp_long_long_uint read Getwrite write Setvalue;
  end;

  IAMQPLongLongInt = interface(IAMQPObject)
  ['{C49840C2-B7CC-4DC4-8627-DF2BD0F3C735}']
    function Getwrite: amqp_long_long_int;
    procedure Setvalue(AValue: amqp_long_long_int);
    property Value: amqp_long_long_int read Getwrite write Setvalue;
  end;


  { amqp_field_long_long_int }

  amqp_field_long_long_int = class(amqp_object, IAMQPLongLongInt)
  private
    Fvalue: amqp_long_long_int;
    function Getwrite: amqp_long_long_int;
    procedure Setvalue(AValue: amqp_long_long_int);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: IAMQPObject); override;
    property Value: amqp_long_long_int read Getwrite write Setvalue;
  end;

  { IAMQPFloat }

  IAMQPFloat = interface(IAMQPObject)
  ['{C49840C2-B7CC-4DC4-8627-DF2BD0F3C735}']
    function GetValue: amqp_float;
    procedure Setvalue(AValue: amqp_float);
    property Value: amqp_float read GetValue write Setvalue;
  end;


  { amqp_field_float }

  amqp_field_float = class(amqp_object, IAMQPFloat)
  private
    Fvalue: amqp_float;
    function GetValue: amqp_float;
    procedure Setvalue(AValue: amqp_float);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: IAMQPObject); override;
    property Value: amqp_float read GetValue write Setvalue;
  end;

  IAMQPDouble = interface(IAMQPObject)
  ['{C49840C2-B7CC-4DC4-8627-DF2BD0F3C735}']
    function GetValue: amqp_double;
    procedure Setvalue(AValue: amqp_double);
    property Value: amqp_double read GetValue write Setvalue;
  end;


  { amqp_field_double }

  amqp_field_double = class(amqp_object)
  private
    Fvalue: amqp_double;
    function GetValue: amqp_double;
    procedure Setvalue(AValue: amqp_double);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: IAMQPObject); override;
    property Value: amqp_double read GetValue write Setvalue;
  end;

  IAMQPTimestamp = interface(IAMQPLongLongUInt)
  ['{664B6772-9EC8-4913-81EC-A097147ADCA2}']
  end;

  amqp_field_timestamp = class(amqp_field_long_long_uint, IAMQPTimestamp);

  { IAMQPFieldPair }

  IAMQPFieldPair = interface(IAMQPObject)
  ['{7B00FF62-AB07-4625-933D-D8F9A3FABEDE}']
    function GetFieldName: IAMQPShortStr;
    function GetFieldValue: IAMQPFieldValue;
    property field_name: IAMQPShortStr read GetFieldName;
    property field_value: IAMQPFieldValue read GetFieldValue;
    function clone: IAMQPFieldPair;
  end;

  { amqp_field_pair }

  amqp_field_pair = class(amqp_object, IAMQPFieldPair)
  private
    ffield_name: IAMQPShortStr;
    ffield_value: IAMQPFieldValue;
    function GetFieldName: IAMQPShortStr;
    function GetFieldValue: IAMQPFieldValue;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property field_name: IAMQPShortStr read GetFieldName;
    property field_value: IAMQPFieldValue read GetFieldValue;
    function clone: IAMQPFieldPair;
    procedure Assign(aobject: IAMQPObject); override;
  end;

  { IAMQPArray }

  IAMQPArray = interface(IAMQPObject)
  ['{D647310A-B610-42F5-8CFA-9E0CE685CEC1}']
    function GetCount: Integer;
    function GetItems(index: Integer): IAMQPFieldValue;
    property Items[index: Integer]: IAMQPFieldValue read GetItems; default;
    property Count: Integer read GetCount;
    function Add: IAMQPFieldValue;
    procedure Delete(Index: Integer);
    procedure Clear;
  end;

  { amqp_field_array }

  amqp_field_array = class(amqp_object, IAMQPArray)
  private
    FArray: TInterfaceList;
    function GetCount: Integer;
    function GetItems(Index: Integer): IAMQPFieldValue;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    procedure Assign(AObject: IAMQPObject); override;
    property Items[index: Integer]: IAMQPFieldValue read GetItems; default;
    property Count: Integer read GetCount;
    function Add: IAMQPFieldValue;
    procedure Delete(Index: Integer);
    procedure Clear;
  end;


  { IAMQPTable }

  IAMQPTable = interface(IAMQPObject)
  ['{BDF02326-3237-45D0-85C2-F465A8C04B74}']
    function GetCount: Integer;
    function GetItems(index: Integer): IAMQPFieldPair;
    property Items[index: Integer]: IAMQPFieldPair read GetItems; default;
    function FieldByName(AFieldName: AnsiString): IAMQPFieldPair;
    function StringByName(AFieldName: AnsiString): AnsiString;
    function IndexOfField(AFieldName: AnsiString): Integer;
    function IsFieldExist(AFieldName: AnsiString): Boolean;
    property Count: Integer read GetCount;
    function Add: IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: AnsiString): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_boolean): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_short_short_uint): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_short_short_int): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_short_uint): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_short_int): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_long_uint): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_long_int): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_long_long_uint): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_long_long_int): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_float): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_double): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: IAMQPTable): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: IAMQPArray): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AScale: amqp_octet; AValue: amqp_long_uint): IAMQPFieldPair; overload;
    procedure Delete(Index: Integer);
    procedure Clear;

  end;

  { amqp_table }

  amqp_table = class(amqp_object, IAMQPTable)
  private
    FTable: TInterfaceList;
    function GetCount: Integer;
    function GetItems(Index: Integer): IAMQPFieldPair;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    procedure Assign(aobject: IAMQPObject); override;
    property Items[index: Integer]: IAMQPFieldPair read GetItems; default;
    function FieldByName(AFieldName: AnsiString): IAMQPFieldPair;
    function StringByName(AFieldName: AnsiString): AnsiString;
    function IndexOfField(AFieldName: AnsiString): Integer;
    function IsFieldExist(AFieldName: AnsiString): Boolean;
    property Count: Integer read GetCount;
    function Add: IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: AnsiString): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_boolean): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_short_short_uint): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_short_short_int): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_short_uint): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_short_int): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_long_uint): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_long_int): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_long_long_uint): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_long_long_int): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_float): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_double): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: IAMQPTable): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AValue: IAMQPArray): IAMQPFieldPair; overload;
    function Add(aFieldName: AnsiString; AScale: amqp_octet; AValue: amqp_long_uint): IAMQPFieldPair; overload;
    procedure Delete(Index: Integer);
    procedure Clear;

  end;

  amqp_peer_properties = amqp_table;
  IAMQPProperties = IAMQPTable;
  amqp_queue_name = amqp_short_str;
  IAMQPQueueName = IAMQPShortStr;

  amqp_redelivered = amqp_bit;
  amqp_reply_code = amqp_short_uint;

  amqp_reply_text = amqp_short_str;

  IAMQPRelyText = IAMQPShortStr;

  //amqp_method = class;
  amqp_content_header = class;
  amqp_content_body = class;
  amqp_heartbeat = class;
  amqp_channel = amqp_short_uint;

  IAMQPContainer = interface;
  IAMQPContentHeader = interface;
  IAMQPContentBody = interface;
  IAMQPHeartbeat = interface;
  IAMQPMethod = interface;

  { IAMQPFrame }

  IAMQPFrame = interface(IAMQPObject)
  ['{5659F43B-640A-4345-B143-41694B5E8E75}']
    function GetAsContentBody: IAMQPContentBody;
    function GetAsContentHeader: IAMQPContentHeader;
    function GetAsHeartBeat: IAMQPHeartbeat;
    function GetAsContainer: IAMQPContainer;
    function GetAsMethod: IAMQPMethod;
    function Getchannel: amqp_channel;
    function GetFrame_type: amqp_octet;
    function Getpayload: IAMQPObject;
    procedure Setchannel(AValue: amqp_channel);
    procedure SetPayload(AValue: IAMQPObject);
    procedure Set_FrameType(AValue: amqp_octet);
    property frame_type: amqp_octet read GetFrame_type write Set_FrameType;
    property channel: amqp_channel read Getchannel write Setchannel;
    property payload: IAMQPObject read Getpayload write SetPayload;
    property AsContainer: IAMQPContainer read GetAsContainer;
    property AsMethod: IAMQPMethod read GetAsMethod;
    property AsContentHeader: IAMQPContentHeader read GetAsContentHeader;
    property AsContentBody: IAMQPContentBody read GetAsContentBody;
    property AsHeartbeat: IAMQPHeartbeat read GetAsHeartBeat;
  end;

  { amqp_frame }

  amqp_frame = class(amqp_object, IAMQPFrame)
  private
    fframe_type: amqp_octet;
    fsize: amqp_long_uint;
    fchannel: amqp_channel;
    fpayload: IAMQPObject;
    fendofframe: amqp_octet;
    function GetAsContainer: IAMQPContainer;
    function GetAsContentHeader: IAMQPContentHeader;
    function GetAsContentBody: IAMQPContentBody;
    function GetAsHeartBeat: IAMQPHeartbeat;
    function GetAsMethod: IAMQPMethod;
    function Getchannel: amqp_channel;
    function GetFrame_type: amqp_octet;
    function Getpayload: IAMQPObject;
    procedure Setchannel(AValue: amqp_channel);
    procedure SetPayload(AValue: IAMQPObject);
    procedure Set_FrameType(AValue: amqp_octet);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
    function GetAsDebugString: String; override;
//    function QueryInterface(constref iid: tguid; out obj): longint; override; cdecl;
  public
    constructor Create(AName: String = ''); override;
    constructor CreateFromString(const AValue: AnsiString);
    constructor CreateFromStream(AStream: TStream);
    destructor Destroy; override;
    property frame_type: amqp_octet read GetFrame_type write Set_FrameType;
    property channel: amqp_channel read Getchannel write Setchannel;
    property payload: IAMQPObject read Getpayload write SetPayload;
    property AsContainer: IAMQPContainer read GetAsContainer;
    property AsMethod: IAMQPMethod read GetAsMethod;
    property AsContentHeader: IAMQPContentHeader read GetAsContentHeader;
    property AsContentBody: IAMQPContentBody read GetAsContentBody;
    property AsHeartbeat: IAMQPHeartbeat read GetAsHeartBeat;
  end;

  { IAMQPMethod }

  { IAMQPContainer }

  IAMQPContainer = interface(IAMQPObject)
  ['{41614D6F-EBE1-4F94-B6DF-D0601C45F51D}']
    function Getclass_id: amqp_short_uint;
    function Getmethod: IAMQPObject;
    function Getmethod_id: amqp_short_uint;
    procedure setclass_id(const Value: amqp_short_uint);
    procedure setmethod_id(const Value: amqp_short_uint);
    property class_id: amqp_short_uint read Getclass_id write setclass_id;
    property method_id: amqp_short_uint read Getmethod_id write setmethod_id;
    property method: IAMQPObject read Getmethod;
  end;

  { amqp_container }

  amqp_container = class(amqp_object, IAMQPContainer)
  private
    fmethod_id: amqp_short_uint;
    fclass_id: amqp_short_uint;
    fmethod: IAMQPObject;
    function Getclass_id: amqp_short_uint;
    function Getmethod: IAMQPObject;
    function Getmethod_id: amqp_short_uint;
    procedure setclass_id(const Value: amqp_short_uint);
    procedure setmethod_id(const Value: amqp_short_uint);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
    procedure DestroyMethod;
    procedure CreateMethod;
    function GetAsDebugString: String; override;
//    function QueryInterface(constref iid: tguid; out obj): longint; override; cdecl;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property class_id: amqp_short_uint read Getclass_id write setclass_id;
    property method_id: amqp_short_uint read Getmethod_id write setmethod_id;
    property method: IAMQPObject read Getmethod;
  end;

  IAMQPMethod = interface(IAMQPObject)
  ['{566B1143-808C-4120-8B48-1CFCBAD259A3}']
    function GetClassId: amqp_short_uint;
    function GetMethodId: amqp_short_uint;
    function GetOwner: IAMQPContainer;
    property class_id: amqp_short_uint read GetClassId;
    property method_id: amqp_short_uint read GetMethodId;
    property Container: IAMQPContainer read GetOwner;
  end;

  { amqp_custom_method }

  amqp_custom_method = class(amqp_object, IAMQPMethod)
  private
     FOwner: IAMQPContainer;
     function GetOwner: IAMQPContainer;
  protected
    class function new_frame(achannel: amqp_short_uint): IAMQPFrame;
    function GetClassId: amqp_short_uint;
    function GetMethodId: amqp_short_uint;
  public
    constructor Create(AName: String = ''); override;
    class function class_id: amqp_short_uint; virtual; abstract;
    class function method_id: amqp_short_uint; virtual; abstract;
    class function create_frame(achannel: amqp_short_uint): IAMQPFrame; virtual;
    property Container: IAMQPContainer read GetOwner;
  end;

  amqp_method_class = class of amqp_custom_method;

  { amqp_method_start }

  { IAMQPMethodStart }

  IAMQPMethodStart = interface(IAMQPMethod)
  ['{82D7D1E0-9E24-465E-9D2D-57BE8DB3F0C9}']
    function Getlocales: AnsiString;
    function Getmechanisms: AnsiString;
    function GetProperties: IAMQPTable;
    function Getversion_major: amqp_octet;
    function Getversion_minor: amqp_octet;
    procedure SetLocales(const Value: AnsiString);
    procedure Setmechanisms(const Value: AnsiString);
    property version_major: amqp_octet read Getversion_major;
    property version_minor: amqp_octet read Getversion_minor;
    property properties: IAMQPTable read GetProperties;
    property mechanisms: AnsiString read Getmechanisms write Setmechanisms;
    property locales: AnsiString read Getlocales write SetLocales;
  end;


  amqp_method_start = class(amqp_custom_method, IAMQPMethodStart)
  private
    fmechanisms: IAMQPLongStr;
    flocales: IAMQPLongStr;
    fproperties: IAMQPTable;
    fversion_minor: amqp_octet;
    fversion_major: amqp_octet;
    function Getlocales: AnsiString;
    function Getmechanisms: AnsiString;
    function GetProperties: IAMQPTable;
    function Getversion_major: amqp_octet;
    function Getversion_minor: amqp_octet;
    procedure SetLocales(const Value: AnsiString);
    procedure Setmechanisms(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property version_major: amqp_octet read Getversion_major;
    property version_minor: amqp_octet read Getversion_minor;
    property properties: IAMQPTable read GetProperties;
    property mechanisms: AnsiString read Getmechanisms write Setmechanisms;
    property locales: AnsiString read Getlocales write SetLocales;
    class function class_id: amqp_short_uint; override;
    class function method_id: amqp_short_uint; override;
  end;


  { IAMQPMethodStartOk }

  IAMQPMethodStartOk = interface(IAMQPMethod)
  ['{A59E5DF9-5FC1-4F01-883B-133C3D088FC8}']
    function Getlocale: AnsiString;
    function Getmechanisms: AnsiString;
    function Getproperties: IAMQPTable;
    function Getresponse: AnsiString;
    procedure SetLocale(const Value: AnsiString);
    procedure Setmechanisms(const Value: AnsiString);
    procedure Setproperties(AValue: IAMQPTable);
    procedure setResponse(const Value: AnsiString);

    property properties: IAMQPTable read Getproperties write Setproperties;
    property mechanisms: AnsiString read Getmechanisms write Setmechanisms;
    property response: AnsiString read Getresponse write setResponse;
    property locale: AnsiString read Getlocale write SetLocale;
  end;

  { amqp_method_start_ok }

  amqp_method_start_ok = class(amqp_custom_method, IAMQPMethodStartOk)
  private
    fmechanisms: IAMQPShortStr;
    fresponse: IAMQPLongStr;
    flocale: IAMQPShortStr;
    fproperties: IAMQPTable;
    function Getlocale: AnsiString;
    function Getmechanisms: AnsiString;
    function Getproperties: IAMQPTable;
    function Getresponse: AnsiString;
    procedure SetLocale(const Value: AnsiString);
    procedure Setmechanisms(const Value: AnsiString);
    procedure Setproperties(AValue: IAMQPTable);
    procedure setResponse(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property properties: IAMQPTable read Getproperties write Setproperties;
    property mechanisms: AnsiString read Getmechanisms write Setmechanisms;
    property response: AnsiString read Getresponse write setResponse;
    property locale: AnsiString read Getlocale write SetLocale;
    class function create_frame(achannel: amqp_short_uint;
      aproperties: amqp_table; amechanisms, aresponce, alocale: AnsiString)
      : IAMQPFrame; reintroduce;
    class function class_id: amqp_short_uint; override;
    class function method_id: amqp_short_uint; override;
  end;

  { IAMQPMethodSecure }

  IAMQPMethodSecure = interface(IAMQPMethod)
  ['{A2F0EA24-2F58-4951-90AD-EB0993E296BE}']
    function Getchallenge: AnsiString;
    procedure SetChallenge(const Value: AnsiString);
    property challenge: AnsiString read Getchallenge write SetChallenge;
  end;

  { amqp_method_secure }

  amqp_method_secure = class(amqp_custom_method, IAMQPMethodSecure)
  private
    fchallenge: IAMQPLongStr;
    function Getchallenge: AnsiString;
    procedure SetChallenge(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property challenge: AnsiString read Getchallenge write SetChallenge;
    class function class_id: amqp_short_uint; override;
    class function method_id: amqp_short_uint; override;

  end;

  { IAMQPMethodSecureOk }

  IAMQPMethodSecureOk = interface(IAMQPMethod)
  ['{23755D84-D2D2-42A4-AEE2-407621A8EBA3}']
    function Getresponse: AnsiString;
    procedure SetResponse(const Value: AnsiString);
    property repsonse: AnsiString read Getresponse write SetResponse;
  end;
  { amqp_method_secure_ok }

  amqp_method_secure_ok = class(amqp_custom_method, IAMQPMethodSecureOk)
  private
    fresponse: IAMQPLongStr;
    function Getresponse: AnsiString;
    procedure SetResponse(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); reintroduce; override;
    destructor Destroy; override;
    property repsonse: AnsiString read Getresponse write SetResponse;
    class function class_id: amqp_short_uint; override;
    class function method_id: amqp_short_uint; override;
  end;

  { IAMQPMethodTune }

  IAMQPMethodTune = interface(IAMQPMethod)
  ['{38886A43-ABD5-4545-BA9E-0CD5C44934AB}']
    function GetchannelMax: amqp_short_uint;
    function GetframeMax: amqp_long_uint;
    function GetheartBeat: amqp_short_uint;
    property channelMax: amqp_short_uint read GetchannelMax;
    property frameMax: amqp_long_uint read GetframeMax;
    property heartBeat: amqp_short_uint read GetheartBeat;
  end;

  { amqp_method_tune }

  amqp_method_tune = class(amqp_custom_method, IAMQPMethodTune)
  private
    fframeMax: amqp_long_uint;
    fheartBeat: amqp_short_uint;
    fchannelMax: amqp_short_uint;
    function GetchannelMax: amqp_short_uint;
    function GetframeMax: amqp_long_uint;
    function GetheartBeat: amqp_short_uint;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    property channelMax: amqp_short_uint read GetchannelMax;
    property frameMax: amqp_long_uint read GetframeMax;
    property heartBeat: amqp_short_uint read GetheartBeat;
    class function class_id: amqp_short_uint; override;
    class function method_id: amqp_short_uint; override;
  end;

  { IAMQPMethodTuneOk }

  IAMQPMethodTuneOk = interface(IAMQPMethodTune)
  ['{11B314EF-C5E9-4EE0-830F-C279AE7C7CE2}']
  procedure SetchannelMax(AValue: amqp_short_uint);
  procedure SetframeMax(AValue: amqp_long_uint);
  procedure SetheartBeat(AValue: amqp_short_uint);
  property channelMax: amqp_short_uint read GetchannelMax write SetchannelMax;
  property frameMax: amqp_long_uint read GetframeMax write SetframeMax;
  property heartBeat: amqp_short_uint read GetheartBeat write SetheartBeat;
  end;

  { amqp_method_tune_ok }

  amqp_method_tune_ok = class(amqp_method_tune, IAMQPMethodTuneOk)
  protected
    procedure SetchannelMax(AValue: amqp_short_uint);
    procedure SetframeMax(AValue: amqp_long_uint);
    procedure SetheartBeat(AValue: amqp_short_uint);
  public
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      achannelMax: amqp_short_uint; aframeMax: amqp_long_uint;
      aheartBeat: amqp_short_uint): IAMQPFrame; reintroduce;
  end;

  { IAMQPMethodOpen }

  IAMQPMethodOpen = interface(IAMQPMethod)
  ['{89B6DE05-85ED-403E-971C-0EB27F63DEDE}']
    function GetInsist: amqp_bit;
    function GetvirtualHost: AnsiString;
    procedure SetInsist(AValue: amqp_bit);
    procedure SetvirtualHost(const Value: AnsiString);
    function GetCapabilites: AnsiString;
    procedure SetCapabilites(const Value: AnsiString);

    property virtualHost: AnsiString read GetvirtualHost write SetvirtualHost;
    property Capabilites: AnsiString read GetCapabilites write SetCapabilites;
    property Insist: amqp_bit read GetInsist write SetInsist;
  end;

  { amqp_method_open }

  amqp_method_open = class(amqp_custom_method, IAMQPMethodOpen)
  private
    fvirtualHost: IAMQPShortStr;
    fCapabilites:  IAMQPShortStr;
    fInsist: amqp_bit;
    function GetInsist: amqp_bit;
    function GetvirtualHost: AnsiString;
    procedure SetInsist(AValue: amqp_bit);
    procedure SetvirtualHost(const Value: AnsiString);
    function GetCapabilites: AnsiString;
    procedure SetCapabilites(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); reintroduce; override;
    destructor Destroy; override;
    property virtualHost: AnsiString read GetvirtualHost write SetvirtualHost;
    property Capabilites: AnsiString read GetCapabilites write SetCapabilites;
    property Insist: amqp_bit read GetInsist write SetInsist;
    class function class_id: amqp_short_uint; override;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aVirtualHost: AnsiString): IAMQPFrame; reintroduce;
  end;

  { IAMQPMethodOpenOk }

  IAMQPMethodOpenOk = interface(IAMQPMethod)
  ['{74164591-2C58-4CA7-8DF5-8D4642F5DB99}']
    function getKnownHosts: AnsiString;
    procedure setKnownHosts(const Value: AnsiString);
    property KnownHosts: AnsiString read getKnownHosts write setKnownHosts;
  end;

  { amqp_method_open_ok }

  amqp_method_open_ok = class(amqp_custom_method, IAMQPMethodOpenOk)
  private
    fKnownHosts: IAMQPShortStr;
    function getKnownHosts: AnsiString;
    procedure setKnownHosts(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); reintroduce; override;
    destructor Destroy; override;
    property KnownHosts: AnsiString read getKnownHosts write setKnownHosts;
    class function class_id: amqp_short_uint; override;
    class function method_id: amqp_short_uint; override;
  end;

  { IAMQPMethodClose }

  IAMQPMethodClose = interface(IAMQPMethod)
  ['{58B44682-1380-436C-85C0-CE8ECCBDD423}']
    function Getrclassid: amqp_short_uint;
    function GetReplyCode: amqp_short_uint;
    function GetReplyText: AnsiString;
    function Getrmethodid: amqp_short_uint;
    procedure Setrclassid(AValue: amqp_short_uint);
    procedure SetReplyCode(AValue: amqp_short_uint);
    procedure SetReplyText(const Value: AnsiString);
    procedure Setrmethodid(AValue: amqp_short_uint);
    property replyCode: amqp_short_uint read GetReplyCode write SetReplyCode;
    property replyText: AnsiString read GetReplyText write SetReplyText;
    property rclassid: amqp_short_uint read Getrclassid write Setrclassid;
    property rmethodid: amqp_short_uint read Getrmethodid write Setrmethodid;
  end;

  { amqp_method_close }

  amqp_method_close = class(amqp_custom_method, IAMQPMethodClose)
  private
    frmethodid: amqp_short_uint;
    frclassid: amqp_short_uint;
    fReplyText: IAMQPShortStr;
    fReplyCode: amqp_short_uint;
    function Getrclassid: amqp_short_uint;
    function GetReplyCode: amqp_short_uint;
    function GetReplyText: AnsiString;
    function Getrmethodid: amqp_short_uint;
    procedure Setrclassid(AValue: amqp_short_uint);
    procedure SetReplyCode(AValue: amqp_short_uint);
    procedure SetReplyText(const Value: AnsiString);
    procedure Setrmethodid(AValue: amqp_short_uint);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
    function GetAsDebugString: String; override;
  public
    constructor Create(AName: String = ''); reintroduce; override;
    destructor Destroy; override;
    property replyCode: amqp_short_uint read GetReplyCode write SetReplyCode;
    property replyText: AnsiString read GetReplyText write SetReplyText;
    property rclassid: amqp_short_uint read Getrclassid write Setrclassid;
    property rmethodid: amqp_short_uint read Getrmethodid write Setrmethodid;
    class function class_id: amqp_short_uint; override;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel, aReplyCode: amqp_short_uint;
      aReplyText: AnsiString; aClassId, AMethodId: amqp_short_uint): IAMQPFrame; reintroduce;
  end;

  IAMQPMethodCloseOk = interface(IAMQPMethod)
  ['{08881381-711B-453D-ADB9-0FDD97B70497}']
  end;

  amqp_method_close_ok = class(amqp_custom_method, IAMQPMethodCloseOk)
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    class function class_id: amqp_short_uint; override;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint): IAMQPFrame; reintroduce;
  end;

  { IAMQPMethodChannelClass }

  IAMQPMethodChannel = interface(IAMQPMethod)
  ['{E53AA460-C102-4BF9-B2A9-489E2E98B679}']
  end;

  amqp_method_channel_class = class(amqp_custom_method, IAMQPMethodChannel)
  protected
    function GetSize: amqp_long_long_uint; override;
  public
    class function class_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint): IAMQPFrame;
      reintroduce; virtual;
  end;

  { IAMQPChannelOpen }

  IAMQPChannelOpen = interface(IAMQPMethodChannel)
  ['{74198844-4C07-482D-9A40-A7AC9F1273B4}']
  function GetOutOfBand: AnsiString;
  procedure SetOutOfBand(const Value: AnsiString);
  property OutOfBand: AnsiString read GetOutOfBand write SetOutOfBand;
  end;

  { amqp_method_channel_open }

  amqp_method_channel_open = class(amqp_method_channel_class, IAMQPChannelOpen)
  private
    fOutOfBand: IAMQPShortStr;
    function GetOutOfBand: AnsiString;
    procedure SetOutOfBand(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); reintroduce; override;
    destructor Destroy; override;
    property OutOfBand: AnsiString read GetOutOfBand write SetOutOfBand;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aoutofband: AnsiString): IAMQPFrame; reintroduce;
  end;

  { IAMQPMethodChannelOpenOk }

  IAMQPChannelOpenOk = interface(IAMQPMethodChannel)
  ['{6B252021-0563-46DF-8A7B-A4E0F403D5D1}']
    function getChannelId: AnsiString;
    procedure SetChannelId(const Value: AnsiString);
    property ChannelId: AnsiString read getChannelId write SetChannelId;
  end;

  { amqp_method_channel_open_ok }

  amqp_method_channel_open_ok = class(amqp_method_channel_class, IAMQPChannelOpenOk)
  private
    FChannelId: IAMQPLongStr;
    function getChannelId: AnsiString;
    procedure SetChannelId(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property ChannelId: AnsiString read getChannelId write SetChannelId;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      achannelid: AnsiString): IAMQPFrame; reintroduce;
  end;

  { IAMQPMethodChannelFlow }

  IAMQPMethodChannelFlow = interface(IAMQPMethodChannel)
  ['{CBD642B4-4433-477D-909F-2C588179695E}']
    function Getactive: amqp_boolean;
    procedure Setactive(AValue: amqp_boolean);
    property active: amqp_boolean read Getactive write Setactive;
  end;

  { amqp_method_channel_flow }

  amqp_method_channel_flow = class(amqp_method_channel_class, IAMQPMethodChannelFlow)
  private
    factive: amqp_boolean;
    function Getactive: amqp_boolean;
    procedure Setactive(AValue: amqp_boolean);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    property active: amqp_boolean read Getactive write Setactive;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aactive: amqp_bit): IAMQPFrame; reintroduce; virtual;
  end;

  IAMQPMethodChannelFlowOk = interface(IAMQPMethodChannelFlow)
  ['{78864FAC-D84C-48AB-B9EE-0D605358CC9C}']
  end;

  amqp_method_channel_flow_ok = class(amqp_method_channel_flow, IAMQPMethodChannelFlowOk)
  public
    class function method_id: amqp_short_uint; override;
  end;

  { IAMQPChannelClose }

  IAMQPChannelClose = interface(IAMQPMethodChannel)
  ['{EB955E9F-FC03-4BBF-9F25-939540E04312}']
    function Getrclassid: amqp_short_uint;
    function GetReplyCode: amqp_short_uint;
    function GetReplyText: AnsiString;
    function Getrmethodid: amqp_short_uint;
    procedure Setrclassid(AValue: amqp_short_uint);
    procedure SetReplyCode(AValue: amqp_short_uint);
    procedure SetReplyText(const Value: AnsiString);
    procedure Setrmethodid(AValue: amqp_short_uint);
    property replyCode: amqp_short_uint read GetReplyCode write SetReplyCode;
    property replyText: AnsiString read GetReplyText write SetReplyText;
    property rclassid: amqp_short_uint read Getrclassid write Setrclassid;
    property rmethodid: amqp_short_uint read Getrmethodid write Setrmethodid;
  end;

  { amqp_method_channel_close }

  amqp_method_channel_close = class(amqp_method_channel_class, IAMQPChannelClose)
  private
    frmethodid: amqp_short_uint;
    frclassid: amqp_short_uint;
    fReplyText: IAMQPShortStr;
    fReplyCode: amqp_short_uint;
    function Getrclassid: amqp_short_uint;
    function GetReplyCode: amqp_short_uint;
    function GetReplyText: AnsiString;
    function Getrmethodid: amqp_short_uint;
    procedure Setrclassid(AValue: amqp_short_uint);
    procedure SetReplyCode(AValue: amqp_short_uint);
    procedure SetReplyText(const Value: AnsiString);
    procedure Setrmethodid(AValue: amqp_short_uint);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property replyCode: amqp_short_uint read GetReplyCode write SetReplyCode;
    property replyText: AnsiString read GetReplyText write SetReplyText;
    property rclassid: amqp_short_uint read Getrclassid write Setrclassid;
    property rmethodid: amqp_short_uint read Getrmethodid write Setrmethodid;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel, aReplyCode: amqp_short_uint;
      aReplyText: AnsiString; aClassId,
  AMethodId: amqp_short_uint): IAMQPFrame; reintroduce; virtual;
  end;

  IAMQPChannelCloseOk = interface(IAMQPMethodChannel)
  ['{60E248AB-D489-4E43-B66B-B407EE697095}']
  end;

  { amqp_method_channel_close_ok }

  amqp_method_channel_close_ok = class(amqp_method_channel_class, IAMQPChannelCloseOk)
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
  public
    class function method_id: amqp_short_uint; override;
  end;

  IAMQPExchange = interface(IAMQPMethod)
  ['{7A8CEBB2-FBC0-40B5-BB3B-ADA1C088A6CE}']
  end;

  { amqp_method_exchange_class }

  amqp_method_exchange_class = class(amqp_custom_method, IAMQPExchange)
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    class function class_id: amqp_short_uint; override;
  end;

  { IAMQPExchangeDeclareOk }

  IAMQPExchangeDeclareOk = interface(IAMQPExchange)
  ['{91AC85D1-86FA-4709-A5CB-ADEBEEB465A6}']
    function Getticket: amqp_2octet;
    procedure Setticket(AValue: amqp_2octet);
    property ticket: amqp_2octet read Getticket write Setticket;
  end;

  { amqp_method_exchange_declare_ok }

  amqp_method_exchange_declare_ok = class(amqp_method_exchange_class, IAMQPExchangeDeclareOk)
  private
    fticket: amqp_2octet;
    function Getticket: amqp_2octet;
    procedure Setticket(AValue: amqp_2octet);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    property ticket: amqp_2octet read Getticket write Setticket;
    class function method_id: amqp_short_uint; override;
  end;

  IAMQPMethodExchangeDeclare = interface(IAMQPExchangeDeclareOk)
  ['{6D985260-7BDE-4CC1-BD39-54665E400BA4}']
    function Getarguments: IAMQPProperties;
    function getFlag(const Index: Integer): amqp_bit;
    procedure Setarguments(AValue: IAMQPProperties);
    procedure SetFlag(const Index: Integer; const Value: amqp_bit);
    function Get_type: AnsiString;
    function Getexchange: AnsiString;
    procedure Set_type(const Value: AnsiString);
    procedure Setexchange(const Value: AnsiString);
    property exchange: AnsiString read Getexchange write Setexchange;
    property _type: AnsiString read Get_type write Set_type;
    property passive: amqp_bit index 1 read getFlag write SetFlag;
    property durable: amqp_bit index 2 read getFlag write SetFlag;
    property auto_delete: amqp_bit index 3 read getFlag write SetFlag;
    property internal: amqp_bit index 4 read getFlag write SetFlag;
    property nowait: amqp_bit index 5 read getFlag write SetFlag;
    property arguments: IAMQPProperties read Getarguments write Setarguments;
  end;

  { amqp_method_exchange_declare }

  amqp_method_exchange_declare = class(amqp_method_exchange_declare_ok, IAMQPMethodExchangeDeclare)
  private
    Fexchange: IAMQPExchangeName;
    F_type: IAMQPShortStr;
    FFlags: amqp_octet;
    Farguments: IAMQPProperties;
    function Getarguments: IAMQPProperties;
    function getFlag(const Index: Integer): amqp_bit;
    procedure Setarguments(AValue: IAMQPProperties);
    procedure SetFlag(const Index: Integer; const Value: amqp_bit);
    function Get_type: AnsiString;
    function Getexchange: AnsiString;
    procedure Set_type(const Value: AnsiString);
    procedure Setexchange(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property exchange: AnsiString read Getexchange write Setexchange;
    property _type: AnsiString read Get_type write Set_type;
    property passive: amqp_bit index 1 read getFlag write SetFlag;
    property durable: amqp_bit index 2 read getFlag write SetFlag;
    property auto_delete: amqp_bit index 3 read getFlag write SetFlag;
    property internal: amqp_bit index 4 read getFlag write SetFlag;
    property nowait: amqp_bit index 5 read getFlag write SetFlag;
    property arguments: IAMQPProperties read Getarguments write Setarguments;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint; aexchange,
      atype: AnsiString; apassive, adurable, aauto_delete, ainternal,
      anowait: Boolean; aargs: IAMQPProperties): IAMQPFrame; reintroduce; virtual;
  end;

  IAMQPExchangeDeleteOk = interface(IAMQPExchange)
  ['{9BE509F4-5C92-478A-A543-1E84178285D8}']
  end;

  amqp_method_exchange_delete_ok = class(amqp_method_exchange_class, IAMQPExchangeDeleteOk)
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint): IAMQPFrame;
      reintroduce; virtual;
  end;

  { IAMQPMethodExchangeDelete }

  IAMQPMethodExchangeDelete = interface(IAMQPExchangeDeleteOk)
  ['{4556DBC8-89F0-450B-8668-C22973DBB9DC}']
    function getFlag(const Index: Integer): amqp_bit;
    function Getticket: amqp_short_uint;
    procedure SetFlag(const Index: Integer; const Value: amqp_bit);
    function Getexchange: AnsiString;
    procedure Setexchange(const Value: AnsiString);
    procedure Setticket(AValue: amqp_short_uint);
    property ticket: amqp_short_uint read Getticket write Setticket;
    property exchange: AnsiString read Getexchange write Setexchange;
    property if_unused: amqp_bit index 1 read getFlag write SetFlag;
    property no_wait: amqp_bit index 2 read getFlag write SetFlag;
  end;

  { amqp_method_exchange_delete }

  amqp_method_exchange_delete = class(amqp_method_exchange_delete_ok, IAMQPMethodExchangeDelete)
  private
    fticket: amqp_short_uint;
    Fexchange: IAMQPExchangeName;
    fFlag: amqp_octet;
    function getFlag(const Index: Integer): amqp_bit;
    function Getticket: amqp_short_uint;
    procedure SetFlag(const Index: Integer; const Value: amqp_bit);
    function Getexchange: AnsiString;
    procedure Setexchange(const Value: AnsiString);
    procedure Setticket(AValue: amqp_short_uint);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property ticket: amqp_short_uint read Getticket write Setticket;
    property exchange: AnsiString read Getexchange write Setexchange;
    property if_unused: amqp_bit index 1 read getFlag write SetFlag;
    property no_wait: amqp_bit index 2 read getFlag write SetFlag;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint; aexchange: AnsiString;
      aifUnused, anowait: amqp_bit): IAMQPFrame; reintroduce; virtual;
  end;

  { IAMQPMethodExchangeBind }

  IAMQPMethodExchangeBind = interface(IAMQPExchange)
  ['{1EB522EA-C2BE-4CB6-AC58-5BE992604551}']
    function GetArguments: IAMQPProperties;
    function Getdestination: AnsiString;
    function Getno_wait: amqp_bit;
    function Getroutingkey: AnsiString;
    function Getsource: AnsiString;
    function getticket: amqp_short_uint;
    procedure SetArguments(AValue: IAMQPProperties);
    procedure Setdestination(AValue: AnsiString);
    procedure Setno_wait(AValue: amqp_bit);
    procedure Setroutingkey(AValue: AnsiString);
    procedure Setsource(AValue: AnsiString);
    procedure setticket(AValue: amqp_short_uint);

    property ticket: amqp_short_uint read getticket write setticket;
    property destination: AnsiString read Getdestination write Setdestination;
    property source: AnsiString read Getsource write Setsource;
    property routingkey: AnsiString read Getroutingkey write Setroutingkey;
    property no_wait: amqp_bit read Getno_wait write Setno_wait;
    property arguments: IAMQPProperties read GetArguments write SetArguments;

  end;

  { amqp_method_exchange_bind }

  amqp_method_exchange_bind = class(amqp_method_exchange_class, IAMQPMethodExchangeBind)
  private
    Farguments: IAMQPProperties;
    fdestination: IAMQPExchangeName;
    Fno_wait: amqp_bit;
    fsource: IAMQPExchangeName;
    froutingkey: IAMQPExchangeName;
    fticket: amqp_short_uint;
    function GetArguments: IAMQPProperties;
    function Getdestination: AnsiString;
    function Getno_wait: amqp_bit;
    function Getroutingkey: AnsiString;
    function Getsource: AnsiString;
    function getticket: amqp_short_uint;
    procedure SetArguments(AValue: IAMQPProperties);
    procedure Setdestination(AValue: AnsiString);
    procedure Setno_wait(AValue: amqp_bit);
    procedure Setroutingkey(AValue: AnsiString);
    procedure Setsource(AValue: AnsiString);
    procedure setticket(AValue: amqp_short_uint);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property ticket: amqp_short_uint read getticket write setticket;
    property destination: AnsiString read Getdestination write Setdestination;
    property source: AnsiString read Getsource write Setsource;
    property routingkey: AnsiString read Getroutingkey write Setroutingkey;
    property no_wait: amqp_bit read Getno_wait write Setno_wait;
    property arguments: IAMQPProperties read GetArguments write SetArguments;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aticket: amqp_short_uint; adestination, asource, aroutingkey: AnsiString;
      anowait: amqp_boolean; aargs: IAMQPProperties): IAMQPFrame;
      reintroduce; virtual;
  end;

  IAMQPExchangeBindOk = interface(IAMQPExchange)
  ['{C6DDF580-4684-4018-91FB-C711AC9F22BE}']
  end;

  { amqp_method_exchange_bind_ok }

  amqp_method_exchange_bind_ok = class(amqp_method_exchange_class, IAMQPExchangeBindOk)
  public
    class function method_id: amqp_short_uint; override;
  end;

  { IAMQPExchangeUnBind }

  IAMQPExchangeUnBind = interface(IAMQPMethodExchangeBind)
  ['{24FB3164-1020-46C4-8D42-0E23DA9C46E8}']
  end;

  { amqp_method_exchange_unbind }

  amqp_method_exchange_unbind = class(amqp_method_exchange_bind, IAMQPExchangeUnBind)
  public
    class function method_id: amqp_short_uint; override;
  end;

  { IAMQPExchangeUnBindOk }

  IAMQPExchangeUnBindOk = interface(IAMQPExchange)
  ['{A91835B2-42DD-4ED4-8FB3-C01009373823}']
  end;


  { amqp_method_exchange_unbind_ok }

  amqp_method_exchange_unbind_ok = class(amqp_method_exchange_class, IAMQPExchangeUnBindOk)
  public
    class function method_id: amqp_short_uint; override;
  end;

  { IAMQPQueue }

  IAMQPQueue = interface(IAMQPMethod)
  ['{FD7B33A6-0A30-468E-A3EE-EF65BBE881A9}']
  end;

  amqp_method_queue_class = class(amqp_custom_method, IAMQPQueue)
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    class function class_id: amqp_short_uint; override;
  end;

  { IAMQPMethodQueueDeclare }

  IAMQPMethodQueueDeclare = interface(IAMQPQueue)
  ['{D136FD72-0D0B-433A-86CA-311155E0AEF2}']
    function Getarguments: IAMQPProperties;
    function getFlag(const Index: Integer): amqp_bit;
    function Getticket: amqp_short_uint;
    procedure Setarguments(AValue: IAMQPProperties);
    procedure SetFlag(const Index: Integer; const Value: amqp_bit);
    function Getqueue: AnsiString;
    procedure Setqueue(const Value: AnsiString);
    procedure Setticket(AValue: amqp_short_uint);
    property ticket: amqp_short_uint read Getticket write Setticket;
    property queue: AnsiString read Getqueue write Setqueue;
    property passive: amqp_bit index 1 read getFlag write SetFlag;
    property durable: amqp_bit index 2 read getFlag write SetFlag;
    property exclusive: amqp_bit index 3 read getFlag write SetFlag;
    property auto_delete: amqp_bit index 4 read getFlag write SetFlag;
    property no_wait: amqp_bit index 5 read getFlag write SetFlag;
    property arguments: IAMQPProperties read Getarguments write Setarguments;
  end;

  { amqp_method_queue_declare }

  amqp_method_queue_declare = class(amqp_method_queue_class, IAMQPMethodQueueDeclare)
  private
    fticket: amqp_short_uint;
    Fqueue: IAMQPQueueName;
    Farguments: IAMQPProperties;
    fFlag: amqp_octet;
    function Getarguments: IAMQPProperties;
    function getFlag(const Index: Integer): amqp_bit;
    function Getticket: amqp_short_uint;
    procedure Setarguments(AValue: IAMQPProperties);
    procedure SetFlag(const Index: Integer; const Value: amqp_bit);
    function Getqueue: AnsiString;
    procedure Setqueue(const Value: AnsiString);
    procedure Setticket(AValue: amqp_short_uint);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property ticket: amqp_short_uint read Getticket write Setticket;
    property queue: AnsiString read Getqueue write Setqueue;
    property passive: amqp_bit index 1 read getFlag write SetFlag;
    property durable: amqp_bit index 2 read getFlag write SetFlag;
    property exclusive: amqp_bit index 3 read getFlag write SetFlag;
    property auto_delete: amqp_bit index 4 read getFlag write SetFlag;
    property no_wait: amqp_bit index 5 read getFlag write SetFlag;
    property arguments: IAMQPProperties read Getarguments write Setarguments;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel, aticket: amqp_short_uint;
      aqueue: AnsiString; apassive, adurable, aexclusive, aautodelete,
      anowait: amqp_bit; aargs: IAMQPProperties): IAMQPFrame; reintroduce;
  virtual;
  end;

  { IAMQPMethodQueueDeclareOk }

  IAMQPMethodQueueDeclareOk = interface(IAMQPQueue)
  ['{BD5CAF43-9772-40F8-896C-3ABC72048DB1}']
    function Getconsumer_count: amqp_long_uint;
    function Getmessage_count: amqp_message_count;
    function Getqueue: AnsiString;
    procedure Setconsumer_count(AValue: amqp_long_uint);
    procedure Setmessage_count(AValue: amqp_message_count);
    procedure Setqueue(const Value: AnsiString);
    property queue: AnsiString read Getqueue write Setqueue;
    property message_count: amqp_message_count read Getmessage_count
      write Setmessage_count;
    property consumer_count: amqp_long_uint read Getconsumer_count
      write Setconsumer_count;

  end;

  { amqp_method_queue_declare_ok }

  amqp_method_queue_declare_ok = class(amqp_method_queue_class, IAMQPMethodQueueDeclareOk)
  private
    Fqueue: IAMQPQueueName;
    Fmessage_count: amqp_message_count;
    Fconsumer_count: amqp_long_uint;
    function Getconsumer_count: amqp_long_uint;
    function Getmessage_count: amqp_message_count;
    function Getqueue: AnsiString;
    procedure Setconsumer_count(AValue: amqp_long_uint);
    procedure Setmessage_count(AValue: amqp_message_count);
    procedure Setqueue(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property queue: AnsiString read Getqueue write Setqueue;
    property message_count: amqp_message_count read Getmessage_count
      write Setmessage_count;
    property consumer_count: amqp_long_uint read Getconsumer_count
      write Setconsumer_count;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint; aqueue: AnsiString;
      amessage_count: amqp_message_count;
  aconsumer_count: amqp_long_uint): IAMQPFrame; reintroduce; virtual;
  end;

  { IAMQPQueueBind }

  IAMQPQueueBind = interface(IAMQPQueue)
  ['{BE98D78A-B508-4F2E-B7FE-18751AB2655A}']
    function Getarguments: IAMQPProperties;
    function Getexchange: AnsiString;
    function Getnowait: amqp_boolean;
    function Getqueue: AnsiString;
    function GetroutingKey: AnsiString;
    function Getticket: amqp_short_uint;
    procedure Setarguments(AValue: IAMQPProperties);
    procedure Setexchange(const Value: AnsiString);
    procedure Setnowait(AValue: amqp_boolean);
    procedure Setqueue(const Value: AnsiString);
    procedure SetroutingKey(const Value: AnsiString);
    procedure Setticket(AValue: amqp_short_uint);
    property ticket: amqp_short_uint read Getticket write Setticket;
    property queue: AnsiString read Getqueue write Setqueue;
    property exchange: AnsiString read Getexchange write Setexchange;
    property routingKey: AnsiString read GetroutingKey write SetroutingKey;
    property nowait: amqp_boolean read Getnowait write Setnowait;
    property arguments: IAMQPProperties read Getarguments write Setarguments;
  end;

  { amqp_method_queue_bind }

  amqp_method_queue_bind = class(amqp_method_queue_class, IAMQPQueueBind)
  private
    fticket: amqp_short_uint;
    Fqueue: IAMQPQueueName;
    Fexchange: IAMQPExchangeName;
    FroutingKey: IAMQPShortStr;
    Fnowait: amqp_boolean;
    Farguments: IAMQPProperties;
    function Getarguments: IAMQPProperties;
    function Getexchange: AnsiString;
    function Getnowait: amqp_boolean;
    function Getqueue: AnsiString;
    function GetroutingKey: AnsiString;
    function Getticket: amqp_short_uint;
    procedure Setarguments(AValue: IAMQPProperties);
    procedure Setexchange(const Value: AnsiString);
    procedure Setnowait(AValue: amqp_boolean);
    procedure Setqueue(const Value: AnsiString);
    procedure SetroutingKey(const Value: AnsiString);
    procedure Setticket(AValue: amqp_short_uint);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property ticket: amqp_short_uint read Getticket write Setticket;
    property queue: AnsiString read Getqueue write Setqueue;
    property exchange: AnsiString read Getexchange write Setexchange;
    property routingKey: AnsiString read GetroutingKey write SetroutingKey;
    property nowait: amqp_boolean read Getnowait write Setnowait;
    property arguments: IAMQPProperties read Getarguments write Setarguments;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aticket: amqp_short_uint; aqueue, aexchange, aroutingkey: AnsiString;
      anowait: amqp_boolean; aargs: IAMQPProperties): IAMQPFrame; reintroduce; virtual;
  end;

  IAMQPQueueBindOk = interface(IAMQPQueue)
  ['{33132025-39A8-4613-B330-BB4534FF304E}']
  end;

  amqp_method_queue_bind_ok = class(amqp_method_queue_class, IAMQPQueueBindOk)
  public
    class function method_id: amqp_short_uint; override;
  end;

  IAMQPMethodQueueUnBind = interface(IAMQPQueueBind)
  ['{C9D0D42E-736F-4824-843A-4C7FBC827EED}']
  end;

  amqp_method_queue_unbind = class(amqp_method_queue_bind, IAMQPMethodQueueUnBind)
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aticket: amqp_short_uint; aqueue, aexchange, aroutingkey: AnsiString;
      aargs: IAMQPProperties): IAMQPFrame; reintroduce; virtual;
  end;


  { IAMQPQueueUnBindOk }

  IAMQPQueueUnBindOk = interface(IAMQPQueue)
  ['{9312E60A-E410-4C34-9176-0530DED177C7}']
  end;


  amqp_method_queue_unbind_ok = class(amqp_method_queue_class, IAMQPQueueUnBindOk)
  public
    class function method_id: amqp_short_uint; override;
  end;

  { IAMQPMethodQueuePurge }

  IAMQPQueuePurge = interface(IAMQPQueue)
  ['{79DBEEDA-7266-4016-881B-C939A8CA1F7B}']
    function Getnowait: amqp_boolean;
    function Getqueue: AnsiString;
    function Getticket: amqp_short_uint;
    procedure Setnowait(AValue: amqp_boolean);
    procedure Setqueue(const Value: AnsiString);
    procedure Setticket(AValue: amqp_short_uint);

    property ticket: amqp_short_uint read Getticket write Setticket;
    property queue: AnsiString read Getqueue write Setqueue;
    property nowait: amqp_boolean read Getnowait write Setnowait;

  end;

  { amqp_method_queue_purge }

  amqp_method_queue_purge = class(amqp_method_queue_class, IAMQPQueuePurge)
  private
    Fnowait: amqp_boolean;
    Fqueue: IAMQPQueueName;
    fticket: amqp_short_uint;
    function Getnowait: amqp_boolean;
    function Getqueue: AnsiString;
    function Getticket: amqp_short_uint;
    procedure Setnowait(AValue: amqp_boolean);
    procedure Setqueue(const Value: AnsiString);
    procedure Setticket(AValue: amqp_short_uint);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property ticket: amqp_short_uint read Getticket write Setticket;
    property queue: AnsiString read Getqueue write Setqueue;
    property nowait: amqp_boolean read Getnowait write Setnowait;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aticket: amqp_short_uint; aqueue: AnsiString;
      anowait: amqp_boolean): IAMQPFrame; reintroduce; virtual;
  end;

  { IAMQPMethodQueuePurgeOk }

  IAMQPQueuePurgeOk = interface(IAMQPQueue)
  ['{0CA549A2-8D99-45CA-AAE3-071841ED4C58}']
    function Getmessage_count: amqp_message_count;
    procedure Setmessage_count(AValue: amqp_message_count);
    property message_count: amqp_message_count read Getmessage_count
      write Setmessage_count;
  end;

  { amqp_method_queue_purge_ok }

  amqp_method_queue_purge_ok = class(amqp_method_queue_class, IAMQPQueuePurgeOk)
  private
    Fmessage_count: amqp_message_count;
    function Getmessage_count: amqp_message_count;
    procedure Setmessage_count(AValue: amqp_message_count);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    property message_count: amqp_message_count read Getmessage_count
      write Setmessage_count;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      amessage_count: amqp_message_count): IAMQPFrame; reintroduce; virtual;
  end;

  { IAMQPMethodQueueDelete }

  IAMQPQueueDelete = interface(IAMQPQueue)
  ['{860253A0-597D-4522-B949-4913F67E21F5}']
    function getFlag(const Index: Integer): amqp_bit;
    function Getticket: amqp_short_uint;
    procedure SetFlag(const Index: Integer; const Value: amqp_bit);
    function Getqueue: AnsiString;
    procedure Setqueue(const Value: AnsiString);
    procedure Setticket(AValue: amqp_short_uint);

    property ticket: amqp_short_uint read Getticket write Setticket;
    property queue: AnsiString read Getqueue write Setqueue;
    property ifUnused: amqp_bit index 1 read getFlag write SetFlag;
    property ifempty: amqp_bit index 2 read getFlag write SetFlag;
    property no_wait: amqp_bit index 3 read getFlag write SetFlag;
  end;

  { amqp_method_queue_delete }

  amqp_method_queue_delete = class(amqp_method_queue_class, IAMQPQueueDelete)
  private
    fticket: amqp_short_uint;
    Fqueue: IAMQPQueueName;
    fFlag: amqp_octet;
    function getFlag(const Index: Integer): amqp_bit;
    function Getticket: amqp_short_uint;
    procedure SetFlag(const Index: Integer; const Value: amqp_bit);
    function Getqueue: AnsiString;
    procedure Setqueue(const Value: AnsiString);
    procedure Setticket(AValue: amqp_short_uint);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property ticket: amqp_short_uint read Getticket write Setticket;
    property queue: AnsiString read Getqueue write Setqueue;
    property ifUnused: amqp_bit index 1 read getFlag write SetFlag;
    property ifempty: amqp_bit index 2 read getFlag write SetFlag;
    property no_wait: amqp_bit index 3 read getFlag write SetFlag;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel, aticket: amqp_short_uint;
      aqueue: AnsiString; aifUnused, aIfEmpty, anowait: amqp_bit): IAMQPFrame; reintroduce; virtual;
  end;

  IAMQPQueueDeleteOk = interface(IAMQPQueuePurgeOk)
  ['{9B612978-BDC5-47BC-AE7D-466E674974B0}']
  end;

  amqp_method_queue_delete_ok = class(amqp_method_queue_purge_ok, IAMQPQueueDeleteOk)
  public
    class function method_id: amqp_short_uint; override;
  end;


  IAMQPContentType = IAMQPShortStr;
  IAMQPContentEncoding = IAMQPShortStr;
  IAMQPHeaders = IAMQPTable;
  amqp_delivery_mode = amqp_octet;
  amqp_priority = amqp_octet;
  IAMQPCorrelationId = IAMQPShortStr;
  IAMQPReplyTo = IAMQPShortStr;
  IAMQPExpiration = IAMQPShortStr;
  IAMQPMessageId = IAMQPShortStr;
  IAMQPType = IAMQPShortStr;
  IAMQPUserId = IAMQPShortStr;
  IAMQPAppId = IAMQPShortStr;
  IAMQPReserved = IAMQPShortStr;

  IAMQPEmptyMethod = interface(IAMQPMethod)
  ['{32D696E9-EB7E-4A8B-9232-2CB00EC2D38F}']
  end;

  amqp_empty_method = class(amqp_custom_method, IAMQPEmptyMethod)
  protected
    procedure DoRead(AStream: TStream); override;
  public
   class function class_id: amqp_short_uint; override;
   class function method_id: amqp_short_uint; override;
  end;

  IAMQPBasic = interface(IAMQPMethod)
  ['{C9FE0855-A9D6-417A-A290-6485DFA43CDA}']
  end;

  amqp_method_basic_class = class(amqp_custom_method, IAMQPBasic)
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    class function class_id: amqp_short_uint; override;
  end;

  { IAMQPBasicQOS }

  IAMQPBasicQOS = interface(IAMQPBasic)
  ['{CA67CC8F-C2C9-4439-8F4A-308080945626}']
    function Getglobal: amqp_bit;
    function GetprefetchCount: amqp_short_uint;
    function Getprefetchsize: amqp_long_uint;
    procedure Setglobal(AValue: amqp_bit);
    procedure SetprefetchCount(AValue: amqp_short_uint);
    procedure Setprefetchsize(AValue: amqp_long_uint);
    property prefetchsize: amqp_long_uint read Getprefetchsize  write Setprefetchsize;
    property prefetchCount: amqp_short_uint read GetprefetchCount write SetprefetchCount;
    property global: amqp_bit read Getglobal write Setglobal;
  end;

  { amqp_method_basic_qos }

  amqp_method_basic_qos = class(amqp_method_basic_class, IAMQPBasicQOS)
  private
    Fprefetchsize: amqp_long_uint;
    FprefetchCount: amqp_short_uint;
    Fglobal: amqp_bit;
    function Getglobal: amqp_bit;
    function GetprefetchCount: amqp_short_uint;
    function Getprefetchsize: amqp_long_uint;
    procedure Setglobal(AValue: amqp_bit);
    procedure SetprefetchCount(AValue: amqp_short_uint);
    procedure Setprefetchsize(AValue: amqp_long_uint);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    property prefetchsize: amqp_long_uint read Getprefetchsize  write Setprefetchsize;
    property prefetchCount: amqp_short_uint read GetprefetchCount write SetprefetchCount;
    property global: amqp_bit read Getglobal write Setglobal;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aprefetchsize: amqp_long_uint; aprefetchcount: amqp_short_uint;
  aglobal: amqp_bit): IAMQPFrame; reintroduce; virtual;
  end;

  IAMQPBasicQOSOk = interface(IAMQPBasic)
  ['{90578803-E443-473F-9DA9-01B2F0E1170B}']
  end;

  amqp_method_basic_qos_ok = class(amqp_method_basic_class, IAMQPBasicQOSOk)
  public
    class function method_id: amqp_short_uint; override;
  end;

  IAMQPBasicConsumeOk = interface(IAMQPBasic)
  ['{7B369870-8A8A-4E0E-8322-8C05F4C08460}']
  function GetconsumerTag: AnsiString;
  procedure SetconsumerTag(const Value: AnsiString);

  property consumerTag: AnsiString read GetconsumerTag
    write SetconsumerTag;

  end;

  { amqp_method_basic_consume_ok }

  amqp_method_basic_consume_ok = class(amqp_method_basic_class, IAMQPBasicConsumeOk)
  private
    FconsumerTag: IAMQPConsumerTag;
    function GetconsumerTag: AnsiString;
    procedure SetconsumerTag(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property consumerTag: AnsiString read GetconsumerTag
      write SetconsumerTag;
    class function create_frame(achannel: amqp_short_uint;
      aconsumerTag: AnsiString): IAMQPFrame; reintroduce; virtual;
    class function method_id: amqp_short_uint; override;
  end;

  { IAMQPBasicConsume }

  IAMQPBasicConsume = interface(IAMQPBasicConsumeOk)
  ['{8CA438F4-9B5A-4A3B-9E4F-490F31FE60E2}']
    function Getarguments: IAMQPProperties;
    function getFlag(const Index: Integer): amqp_bit;
    function Getticket: amqp_short_uint;
    procedure Setarguments(AValue: IAMQPProperties);
    procedure SetFlag(const Index: Integer; const Value: amqp_bit);
    function Getqueue: AnsiString;
    procedure Setqueue(const Value: AnsiString);
    procedure Setticket(AValue: amqp_short_uint);
    property ticket: amqp_short_uint read Getticket write Setticket;
    property queue: AnsiString read Getqueue write Setqueue;
    property noLocal: amqp_bit index 1 read getFlag write SetFlag;
    property noAck: amqp_bit index 2 read getFlag write SetFlag;
    property exclusive: amqp_bit index 3 read getFlag write SetFlag;
    property nowait: amqp_bit index 1 read getFlag write SetFlag;
    property arguments: IAMQPProperties read Getarguments write Setarguments;
  end;

  amqp_method_basic_consume = class(amqp_method_basic_consume_ok, IAMQPBasicConsume)
  private
    fticket: amqp_short_uint;
    Fqueue: IAMQPQueueName;
    fFlag: amqp_octet;
    Farguments: IAMQPProperties;
    function Getarguments: IAMQPProperties;
    function getFlag(const Index: Integer): amqp_bit;
    function Getticket: amqp_short_uint;
    procedure Setarguments(AValue: IAMQPProperties);
    procedure SetFlag(const Index: Integer; const Value: amqp_bit);
    function Getqueue: AnsiString;
    procedure Setqueue(const Value: AnsiString);
    procedure Setticket(AValue: amqp_short_uint);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property ticket: amqp_short_uint read Getticket write Setticket;
    property queue: AnsiString read Getqueue write Setqueue;
    property noLocal: amqp_bit index 1 read getFlag write SetFlag;
    property noAck: amqp_bit index 2 read getFlag write SetFlag;
    property exclusive: amqp_bit index 3 read getFlag write SetFlag;
    property nowait: amqp_bit index 1 read getFlag write SetFlag;
    property arguments: IAMQPProperties read Getarguments write Setarguments;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aticket: amqp_short_uint; aqueue, aconsumerTag: AnsiString; aNoLocal,
      aNoAck, aexclusive, anowait: amqp_bit;
      aargs: amqp_peer_properties): IAMQPFrame; reintroduce; virtual;
  end;

  { IAMQPBasicCancel }

  IAMQPBasicCancel = interface(IAMQPBasicConsumeOk)
  ['{83451FF8-D7AA-4278-BE6E-9EDAD91B98C5}']
    function Getnowait: amqp_bit;
    procedure Setnowait(AValue: amqp_bit);
    property nowait: amqp_bit read Getnowait write Setnowait;
  end;

  { amqp_method_basic_cancel }

  amqp_method_basic_cancel = class(amqp_method_basic_consume_ok, IAMQPBasicCancel)
  private
    Fnowait: amqp_bit;
    function Getnowait: amqp_bit;
    procedure Setnowait(AValue: amqp_bit);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    property nowait: amqp_bit read Getnowait write Setnowait;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aconsumerTag: AnsiString; anowait: amqp_bit): IAMQPFrame; reintroduce;
  virtual;
  end;

  { IAMQPBasicCancelOk }

  IAMQPBasicCancelOk = interface(IAMQPBasicConsumeOk)
  ['{B592151F-EB51-4498-B4FA-AF65EB84CE59}']
  end;

  amqp_method_basic_cancel_ok = class(amqp_method_basic_consume_ok, IAMQPBasicCancelOk)
  public
    class function method_id: amqp_short_uint; override;
  end;

  IAMQPBasicCustomReturn = interface(IAMQPBasic)
  ['{C34CDD28-CF6C-4513-A163-90DD7D28886E}']
    function Getexchange: AnsiString;
    function GetroutingKey: AnsiString;
    procedure Setexchange(const Value: AnsiString);
    procedure SetroutingKey(const Value: AnsiString);
    property exchange: AnsiString read Getexchange write Setexchange;
    property routingKey: AnsiString read GetroutingKey write SetroutingKey;
  end;

  { amqp_method_basic_custom_return }

  amqp_method_basic_custom_return = class(amqp_method_basic_class, IAMQPBasicCustomReturn)
  private
    Fexchange: IAMQPExchangeName;
    FroutingKey: IAMQPShortStr;
    function Getexchange: AnsiString;
    function GetroutingKey: AnsiString;
    procedure Setexchange(const Value: AnsiString);
    procedure SetroutingKey(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property exchange: AnsiString read Getexchange write Setexchange;
    property routingKey: AnsiString read GetroutingKey write SetroutingKey;
  end;

  { IAMQPBasicPublish }

  IAMQPBasicPublish = interface(IAMQPBasicCustomReturn)
  ['{09981EAC-0A9F-4286-A58B-D13A9A9A066C}']
    function getFlag(const Index: Integer): amqp_bit;
    function Getticket: amqp_short_uint;
    procedure SetFlag(const Index: Integer; const Value: amqp_bit);
    procedure Setticket(AValue: amqp_short_uint);

    property ticket: amqp_short_uint read Getticket write Setticket;
    property mandatory: amqp_bit index 1 read getFlag write SetFlag;
    property immediate: amqp_bit index 2 read getFlag write SetFlag;
  end;

  { amqp_method_basic_publish }

  amqp_method_basic_publish = class(amqp_method_basic_custom_return, IAMQPBasicPublish)
  private
    fticket: amqp_short_uint;
    fFlag: amqp_octet;
    function getFlag(const Index: Integer): amqp_bit;
    function Getticket: amqp_short_uint;
    procedure SetFlag(const Index: Integer; const Value: amqp_bit);
    procedure Setticket(AValue: amqp_short_uint);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property ticket: amqp_short_uint read Getticket write Setticket;
    property mandatory: amqp_bit index 1 read getFlag write SetFlag;
    property immediate: amqp_bit index 2 read getFlag write SetFlag;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel, aticket: amqp_short_uint; aexchange,
      aroutingkey: AnsiString; aMandatory, aImmediate: amqp_bit): IAMQPFrame;
  reintroduce; virtual;
  end;

  { IAMQPBasicReturn }

  IAMQPBasicReturn = interface(IAMQPBasicCustomReturn)
  ['{376B2398-6813-4851-A765-DED167D7E45C}']
    function GetReplyCode: amqp_reply_code;
    function GetReplyText: AnsiString;
    procedure SetReplyCode(AValue: amqp_reply_code);
    procedure SetReplyText(const Value: AnsiString);

    property replyCode: amqp_reply_code read GetReplyCode write SetReplyCode;
    property replyText: AnsiString read GetReplyText write SetReplyText;

  end;

  { amqp_method_basic_return }

  amqp_method_basic_return = class(amqp_method_basic_custom_return, IAMQPBasicReturn)
  private
    fReplyCode: amqp_reply_code;
    fReplyText: IAMQPRelyText;
    function GetReplyCode: amqp_reply_code;
    function GetReplyText: AnsiString;
    procedure SetReplyCode(AValue: amqp_reply_code);
    procedure SetReplyText(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property replyCode: amqp_reply_code read GetReplyCode write SetReplyCode;
    property replyText: AnsiString read GetReplyText write SetReplyText;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aReplyCode: amqp_reply_code; aReplyText, aexchange,
  aroutingkey: AnsiString): IAMQPFrame; reintroduce; virtual;
  end;

  { IAMQPBasicDeliver }

  IAMQPBasicDeliver = interface(IAMQPBasicCustomReturn)
  ['{DAE65D12-97D9-4CB6-8E12-83557EF603F4}']
    function GetconsumerTag: AnsiString;
    function GetdeliveryTag: amqp_delivery_tag;
    function Getredelivered: amqp_redelivered;
    procedure SetconsumerTag(const Value: AnsiString);
    procedure SetdeliveryTag(AValue: amqp_delivery_tag);
    procedure Setredelivered(AValue: amqp_redelivered);

    property consumerTag: AnsiString read GetconsumerTag write SetconsumerTag;
    property deliveryTag: amqp_delivery_tag read GetdeliveryTag write SetdeliveryTag;
    property redelivered: amqp_redelivered read Getredelivered write Setredelivered;

  end;

  { amqp_method_basic_deliver }

  amqp_method_basic_deliver = class(amqp_method_basic_custom_return, IAMQPBasicDeliver)
  private
    FconsumerTag: IAMQPConsumerTag;
    FdeliveryTag: amqp_delivery_tag;
    Fredelivered: amqp_redelivered;
    function GetconsumerTag: AnsiString;
    function GetdeliveryTag: amqp_delivery_tag;
    function Getredelivered: amqp_redelivered;
    procedure SetconsumerTag(const Value: AnsiString);
    procedure SetdeliveryTag(AValue: amqp_delivery_tag);
    procedure Setredelivered(AValue: amqp_redelivered);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property consumerTag: AnsiString read GetconsumerTag write SetconsumerTag;
    property deliveryTag: amqp_delivery_tag read GetdeliveryTag write SetdeliveryTag;
    property redelivered: amqp_redelivered read Getredelivered write Setredelivered;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aconsumerTag: AnsiString; aDeliveryTag: amqp_delivery_tag;
      aRedelivered: amqp_redelivered; aexchange,
      aroutingkey: AnsiString): IAMQPFrame; reintroduce; virtual;
  end;

  { amqp_content_header }

  { IAMQPContentHeader }

  IAMQPContentHeader = interface(IAMQPObject)
  ['{71413C4B-0CC9-4579-A691-6003A4E9FE59}']
    function GetappId: AnsiString;
    function GetbodySize: amqp_long_long_uint;
    function Getclass_id: amqp_short_uint;
    function GetclusterId: AnsiString;
    function GetcontentEncoding: AnsiString;
    function GetcontentType: AnsiString;
    function GetcorrelationId: AnsiString;
    function GetdeliveryMode: amqp_delivery_mode;
    function Getexpiration: AnsiString;
    function Getheaders: IAMQPHeaders;
    function GetmessageId: AnsiString;
    function Getpriority: amqp_octet;
    function GetpropFlags: amqp_short_uint;
    function GetreplyTo: AnsiString;
    function Gettimestamp: amqp_timestamp;
    function Gettype: AnsiString;
    function GetuserId: AnsiString;
    function Getweight: amqp_short_uint;
    procedure SetappId(const Value: AnsiString);
    procedure SetbodySize(AValue: amqp_long_long_uint);
    procedure Setclass_id(AValue: amqp_short_uint);
    procedure SetclusterId(const Value: AnsiString);
    procedure SetcontentEncoding(const Value: AnsiString);
    procedure SetcontentType(const Value: AnsiString);
    procedure SetcorrelationId(const Value: AnsiString);
    procedure SetdeliveryMode(const Value: amqp_delivery_mode);
    procedure Setexpiration(const Value: AnsiString);
    procedure SetHeaders(AValue: IAMQPHeaders);
    procedure SetmessageId(const Value: AnsiString);
    procedure Setpriority(const Value: amqp_octet);
    procedure SetpropFlags(AValue: amqp_short_uint);
    procedure SetreplyTo(const Value: AnsiString);
    procedure Settimestamp(const Value: amqp_timestamp);
    procedure SetType(const Value: AnsiString);
    procedure SetuserId(const Value: AnsiString);
    procedure Setweight(AValue: amqp_short_uint);
    function Clone: IAMQPContentHeader;
    property class_id: amqp_short_uint read Getclass_id write Setclass_id;
    property weight: amqp_short_uint read Getweight write Setweight;
    property bodySize: amqp_long_long_uint read GetbodySize write SetbodySize;
    property propFlags: amqp_short_uint read GetpropFlags write SetpropFlags;
    property contentType: AnsiString read GetcontentType write SetcontentType;
    property contentEncoding: AnsiString read GetcontentEncoding write SetcontentEncoding;
    property headers: IAMQPHeaders read Getheaders write SetHeaders;
    property deliveryMode: amqp_delivery_mode read GetdeliveryMode write SetdeliveryMode;
    property priority: amqp_octet read Getpriority write Setpriority;
    property correlationId: AnsiString read GetcorrelationId  write SetcorrelationId;
    property replyTo: AnsiString read GetreplyTo write SetreplyTo;
    property expiration: AnsiString read Getexpiration write Setexpiration;
    property messageId: AnsiString read GetmessageId write SetmessageId;
    property timestamp: amqp_timestamp read Gettimestamp write Settimestamp;
    property _type: AnsiString read Gettype write SetType;
    property userId: AnsiString read GetuserId write SetuserId;
    property appId: AnsiString read GetappId write SetappId;
    property clusterId: AnsiString read GetclusterId write SetclusterId;

  end;

  amqp_content_header = class(amqp_object, IAMQPContentHeader)
  private
    fclass_id: amqp_short_uint;
    Fweight: amqp_short_uint;
    FbodySize: amqp_long_long_uint;
    FpropFlags: amqp_short_uint;
    Fheaders: IAMQPHeaders;
    FdeliveryMode: amqp_delivery_mode;
    FcontentType: IAMQPContentType;
    FcontentEncoding: IAMQPContentEncoding;
    Fpriority: amqp_octet;
    FcorrelationId: IAMQPCorrelationId;
    FreplyTo: IAMQPReplyTo;
    Fexpiration: IAMQPExpiration;
    FmessageId: IAMQPMessageId;
    Ftimestamp: amqp_timestamp;
    F_type: IAMQPType;
    FuserId: IAMQPUserId;
    FappId: IAMQPAppId;
    FclusterId: IAMQPShortStr;
    function GetappId: AnsiString;
    function GetbodySize: amqp_long_long_uint;
    function Getclass_id: amqp_short_uint;
    function GetclusterId: AnsiString;
    function GetcontentEncoding: AnsiString;
    function GetcontentType: AnsiString;
    function GetcorrelationId: AnsiString;
    function GetdeliveryMode: amqp_delivery_mode;
    function Getexpiration: AnsiString;
    function Getheaders: IAMQPHeaders;
    function GetmessageId: AnsiString;
    function Getpriority: amqp_octet;
    function GetpropFlags: amqp_short_uint;
    function GetreplyTo: AnsiString;
    function Gettimestamp: amqp_timestamp;
    function Gettype: AnsiString;
    function GetuserId: AnsiString;
    function Getweight: amqp_short_uint;
    procedure SetappId(const Value: AnsiString);
    procedure SetbodySize(AValue: amqp_long_long_uint);
    procedure Setclass_id(AValue: amqp_short_uint);
    procedure SetclusterId(const Value: AnsiString);
    procedure SetcontentEncoding(const Value: AnsiString);
    procedure SetcontentType(const Value: AnsiString);
    procedure SetcorrelationId(const Value: AnsiString);
    procedure SetdeliveryMode(const Value: amqp_delivery_mode);
    procedure Setexpiration(const Value: AnsiString);
    procedure SetHeaders(AValue: IAMQPHeaders);
    procedure SetmessageId(const Value: AnsiString);
    procedure Setpriority(const Value: amqp_octet);
    procedure SetpropFlags(AValue: amqp_short_uint);
    procedure SetreplyTo(const Value: AnsiString);
    procedure Settimestamp(const Value: amqp_timestamp);
    procedure SetType(const Value: AnsiString);
    procedure SetuserId(const Value: AnsiString);
    procedure Setweight(AValue: amqp_short_uint);

  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    procedure Assign(aobject: IAMQPObject); override;
    function Clone: IAMQPContentHeader;
    property class_id: amqp_short_uint read Getclass_id write Setclass_id;
    property weight: amqp_short_uint read Getweight write Setweight;
    property bodySize: amqp_long_long_uint read GetbodySize write SetbodySize;
    property propFlags: amqp_short_uint read GetpropFlags write SetpropFlags;
    property contentType: AnsiString read GetcontentType write SetcontentType;
    property contentEncoding: AnsiString read GetcontentEncoding write SetcontentEncoding;
    property headers: IAMQPHeaders read Getheaders write SetHeaders;
    property deliveryMode: amqp_delivery_mode read GetdeliveryMode write SetdeliveryMode;
    property priority: amqp_octet read Getpriority write Setpriority;
    property correlationId: AnsiString read GetcorrelationId  write SetcorrelationId;
    property replyTo: AnsiString read GetreplyTo write SetreplyTo;
    property expiration: AnsiString read Getexpiration write Setexpiration;
    property messageId: AnsiString read GetmessageId write SetmessageId;
    property timestamp: amqp_timestamp read Gettimestamp write Settimestamp;
    property _type: AnsiString read Gettype write SetType;
    property userId: AnsiString read GetuserId write SetuserId;
    property appId: AnsiString read GetappId write SetappId;
    property clusterId: AnsiString read GetclusterId write SetclusterId;
    class function create_frame(achannel: amqp_short_uint; abodySize: amqp_long_long_uint): amqp_frame;
  end;

  { IAMQPContentBody }

  IAMQPContentBody = interface(IAMQPObject)
  ['{47004BB8-3F4B-4C05-9F85-2E4171CC2182}']
    function GetData: Pointer;
    function Getlen: amqp_long_uint;
    property len: amqp_long_uint read Getlen;
    property Data: Pointer read GetData;
  end;

  { amqp_content_body }

  amqp_content_body = class(amqp_object, IAMQPContentBody)
  private
    flen: amqp_long_uint;
    FData: Pointer;
    function GetData: Pointer;
    function Getlen: amqp_long_uint;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(aLen: amqp_long_uint; AData: Pointer); reintroduce; virtual;
    destructor Destroy; override;
    property len: amqp_long_uint read Getlen;
    property Data: Pointer read GetData;
    class function create_frame(achannel: amqp_short_uint; alen: amqp_long_uint; adata: Pointer): amqp_frame;
  end;

  { IAMQPBasicGet }

  IAMQPBasicGet = interface(IAMQPBasic)
  ['{1EB7024D-F173-4559-BEB4-AC2B127EE20C}']
    function GetnoAck: amqp_no_ack;
    function Getticket: amqp_short_uint;
    procedure SetnoAck(AValue: amqp_no_ack);
    procedure Setqueue(const Value: AnsiString);
    function Getqueue: AnsiString;
    procedure Setticket(AValue: amqp_short_uint);

    property ticket: amqp_short_uint read Getticket write Setticket;
    property queue: AnsiString read Getqueue write Setqueue;
    property noAck: amqp_no_ack read GetnoAck write SetnoAck;

  end;

  { amqp_method_basic_get }

  amqp_method_basic_get = class(amqp_method_basic_class, IAMQPBasicGet)
  private
    Fticket: amqp_short_uint;
    Fqueue: IAMQPQueueName;
    FnoAck: amqp_no_ack;
    function GetnoAck: amqp_no_ack;
    function Getticket: amqp_short_uint;
    procedure SetnoAck(AValue: amqp_no_ack);
    procedure Setqueue(const Value: AnsiString);
    function Getqueue: AnsiString;
    procedure Setticket(AValue: amqp_short_uint);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property ticket: amqp_short_uint read Getticket write Setticket;
    property queue: AnsiString read Getqueue write Setqueue;
    property noAck: amqp_no_ack read GetnoAck write SetnoAck;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel, aticket: amqp_short_uint;
      aqueue: AnsiString; aNoAck: amqp_no_ack): IAMQPFrame; reintroduce;
  virtual;
  end;

  { IAMQPBasicGetOk }

  IAMQPBasicGetOk = interface(IAMQPBasic)
  ['{95F56CF0-C865-4D10-9C40-19C9AA1F4ED8}']
  function GetdeliveryTag: amqp_delivery_tag;
  function GetExchange: AnsiString;
  function GetmessageCount: amqp_message_count;
  function Getredelivered: amqp_redelivered;
  procedure SetdeliveryTag(AValue: amqp_delivery_tag);
  procedure SetExchange(const Value: AnsiString);
  function GetRoutingKey: AnsiString;
  procedure SetmessageCount(AValue: amqp_message_count);
  procedure Setredelivered(AValue: amqp_redelivered);
  procedure SetRoutingKey(const Value: AnsiString);
  property deliveryTag: amqp_delivery_tag read GetdeliveryTag write SetdeliveryTag;
  property redelivered: amqp_redelivered read Getredelivered write Setredelivered;
  property exchange: AnsiString read GetExchange write SetExchange;
  property routingKey: AnsiString read GetRoutingKey write SetRoutingKey;
  property messageCount: amqp_message_count read GetmessageCount write SetmessageCount;

  end;

  { amqp_method_basic_get_ok }

  amqp_method_basic_get_ok = class(amqp_method_basic_class,IAMQPBasicGetOk)
  private
    FdeliveryTag: amqp_delivery_tag;
    Fredelivered: amqp_redelivered;
    Fexchange: IAMQPExchangeName;
    FRoutingKey: IAMQPShortStr;
    FmessageCount: amqp_message_count;
    function GetdeliveryTag: amqp_delivery_tag;
    function GetExchange: AnsiString;
    function GetmessageCount: amqp_message_count;
    function Getredelivered: amqp_redelivered;
    procedure SetdeliveryTag(AValue: amqp_delivery_tag);
    procedure SetExchange(const Value: AnsiString);
    function GetRoutingKey: AnsiString;
    procedure SetmessageCount(AValue: amqp_message_count);
    procedure Setredelivered(AValue: amqp_redelivered);
    procedure SetRoutingKey(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property deliveryTag: amqp_delivery_tag read GetdeliveryTag write SetdeliveryTag;
    property redelivered: amqp_redelivered read Getredelivered write Setredelivered;
    property exchange: AnsiString read GetExchange write SetExchange;
    property routingKey: AnsiString read GetRoutingKey write SetRoutingKey;
    property messageCount: amqp_message_count read GetmessageCount write SetmessageCount;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      adeliveryTag: amqp_delivery_tag; aredelivered: amqp_redelivered;
      aexchange, aroutingKey: AnsiString; amessagecount: amqp_message_count): IAMQPFrame; reintroduce; virtual;
  end;

  { IAMQPBasicGetEmpty }

  IAMQPBasicGetEmpty = interface(IAMQPBasic)
  ['{55A699F3-21BE-43B4-A0A5-C53FEE43B2B0}']
    function getClusterId: AnsiString;
    procedure setClusterId(const Value: AnsiString);
    property clusterId: AnsiString read getClusterId write setClusterId;
  end;

  { amqp_method_basic_get_empty }

  amqp_method_basic_get_empty = class(amqp_method_basic_class, IAMQPBasicGetEmpty)
  private
    fclusterid: IAMQPShortStr;
    function getClusterId: AnsiString;
    procedure setClusterId(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(AName: String = ''); override;
    destructor Destroy; override;
    property clusterId: AnsiString read getClusterId write setClusterId;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aclusterId: AnsiString): IAMQPFrame; reintroduce; virtual;
  end;

  { IAMQPBasicAck }

  IAMQPBasicAck = interface(IAMQPBasic)
  ['{159BA896-E5A9-41C3-B7AA-9F53FD60E5DF}']
    function GetdeliveryTag: amqp_delivery_tag;
    procedure SetdeliveryTag(AValue: amqp_delivery_tag);
    function getFlag(const Index: Integer): amqp_bit;
    procedure setFlag(const Index: Integer; const Value: amqp_bit);
    property deliveryTag: amqp_delivery_tag read GetdeliveryTag write SetdeliveryTag;
    property mulitple: amqp_bit index 1 read getFlag write setFlag;
  end;

  { amqp_method_basic_ack }

  amqp_method_basic_ack = class(amqp_method_basic_class, IAMQPBasicAck)
  private
    FdeliveryTag: amqp_delivery_tag;
    fFlag: amqp_octet;
    function GetdeliveryTag: amqp_delivery_tag;
    procedure SetdeliveryTag(AValue: amqp_delivery_tag);
  protected
    function getFlag(const Index: Integer): amqp_bit; virtual;
    procedure setFlag(const Index: Integer; const Value: amqp_bit); virtual;
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    property deliveryTag: amqp_delivery_tag read GetdeliveryTag write SetdeliveryTag;
    property mulitple: amqp_bit index 1 read getFlag write setFlag;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      adeliveryTag: amqp_delivery_tag; amultiple: amqp_bit): IAMQPFrame;
  reintroduce; virtual;
  end;

  IAMQPBasicReject = interface(IAMQPBasicAck)
  ['{CA3A8775-C321-419F-ACD0-446AE36050BF}']
  end;

  amqp_method_basic_reject = class(amqp_method_basic_ack, IAMQPBasicReject)
  public
    class function method_id: amqp_short_uint; override;
  end;

  { IAMQPBasicRecoverAsync }

  IAMQPBasicRecoverAsync = interface(IAMQPBasic)
  ['{CAB96694-8CEB-4E27-B538-AE14996DF66C}']
    function Getrequeue: amqp_bit;
    procedure Setrequeue(AValue: amqp_bit);
    property requeue: amqp_bit read Getrequeue write Setrequeue;
  end;

  { amqp_method_basic_recover_async }

  amqp_method_basic_recover_async = class(amqp_method_basic_class, IAMQPBasicRecoverAsync)
  private
    Frequeue: amqp_bit;
    function Getrequeue: amqp_bit;
    procedure Setrequeue(AValue: amqp_bit);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    property requeue: amqp_bit read Getrequeue write Setrequeue;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      arequeue: amqp_bit): IAMQPFrame; reintroduce; virtual;
  end;

  IAMQPBasicRecover = interface(IAMQPBasicRecoverAsync)
  ['{D4581B21-6EC5-48F7-AE54-E9D4536DA857}']
  end;

  amqp_method_basic_recover = class(amqp_method_basic_recover_async, IAMQPBasicRecover)
  public
    class function method_id: amqp_short_uint; override;
  end;

  IAMQPBasicRecoverOk = interface(IAMQPBasic)
  ['{4D93E65B-A7A4-42F1-93B0-E55CF2510562}']
  end;

  amqp_method_basic_recover_ok = class(amqp_method_basic_class, IAMQPBasicRecoverOk)
  public
    class function method_id: amqp_short_uint; override;
  end;

  IAMQPBasicNAck = interface(IAMQPBasicAck)
  ['{DE3174AF-102A-45CB-B519-0CF87C610783}']
   property requeue: amqp_bit index 2 read getFlag write setFlag;
  end;

  amqp_method_basic_nack = class(amqp_method_basic_ack, IAMQPBasicNAck)
  protected
    function getFlag(const Index: Integer): amqp_bit; override;
    procedure setFlag(const Index: Integer; const Value: amqp_bit); override;
  public
    property requeue: amqp_bit index 2 read getFlag write setFlag;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      adeliveryTag: amqp_delivery_tag; amultiple,
  arequeue: amqp_bit): IAMQPFrame; reintroduce; virtual;
  end;

  IAMQPTx = interface(IAMQPMethod)
  ['{A67BB006-E7BB-491A-A85A-2E97608D8A51}']
  end;

  amqp_method_tx_class = class(amqp_custom_method, IAMQPTx)
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    class function class_id: amqp_short_uint; override;
  end;

  IAMQPTxSelect = interface(IAMQPTx)
  ['{3D10384F-67AE-4618-871E-1227F9FA1F8A}']
  end;

  amqp_method_tx_select = class(amqp_method_tx_class, IAMQPTxSelect)
  public
    class function method_id: amqp_short_uint; override;
  end;

  IAMQPTxSelectOk = interface(IAMQPTx)
  ['{4BAE0681-0F01-47B5-A4B3-79D56288981B}']
  end;

  amqp_method_tx_select_ok = class(amqp_method_tx_class, IAMQPTxSelectOk)
  public
    class function method_id: amqp_short_uint; override;
  end;

  IAMQPTxCommit = interface(IAMQPTx)
  ['{D4D6E87A-2CF0-4864-B347-1004BF7F3EF1}']
  end;

  amqp_method_tx_commit = class(amqp_method_tx_class, IAMQPTxCommit)
  public
    class function method_id: amqp_short_uint; override;
  end;

  IAMQPTxCommitOk = interface(IAMQPTx)
  ['{E1F732DA-90C8-4AD4-BDA0-55492D218D2C}']
  end;

  amqp_method_tx_commit_ok = class(amqp_method_tx_class, IAMQPTxCommitOk)
  public
    class function method_id: amqp_short_uint; override;
  end;

  IAMQPTxRollback = interface(IAMQPTx)
  ['{616345F3-DA0A-42B1-BD8F-7398C195822E}']
  end;

  amqp_method_tx_rollback = class(amqp_method_tx_class, IAMQPTxRollback)
  public
    class function method_id: amqp_short_uint; override;
  end;

  IAMQPTxRollbackOk = interface(IAMQPTx)
  ['{08FBA542-7D5E-4C53-8CA1-9FC4AE4D4BF4}']
  end;

  amqp_method_tx_rollback_ok = class(amqp_method_tx_class, IAMQPTxRollbackOk)
  public
    class function method_id: amqp_short_uint; override;
  end;

  IAMQPConfirm = interface(IAMQPMethod)
  ['{21A61083-E925-406C-955D-B3D4CC9BAF6E}']
  end;

  { amqp_method_confirm_class }

  amqp_method_confirm_class = class(amqp_custom_method, IAMQPConfirm)
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    class function class_id: amqp_short_uint; override;
  end;

  { IAMQPConfirmSelect }

  IAMQPConfirmSelect = interface(IAMQPConfirm)
  ['{14529E63-2225-45DD-B7E1-E0815ED02CA6}']
    function getFlag(const Index: Integer): amqp_bit;
    procedure SetFlag(const Index: Integer; const Value: amqp_bit);
    property nowait: amqp_bit index 1 read getFlag write SetFlag;
  end;

  { amqp_method_confirm_select }

  amqp_method_confirm_select = class(amqp_method_confirm_class, IAMQPConfirmSelect)
  private
    FFlags: amqp_octet;
    function getFlag(const Index: Integer): amqp_bit;
    procedure SetFlag(const Index: Integer; const Value: amqp_bit);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    property nowait: amqp_bit index 1 read getFlag write SetFlag;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint; aNoWait: Boolean): IAMQPFrame; reintroduce; virtual;
  end;

  IAMQPConfirmSelectOk = interface(IAMQPConfirmSelect)
  ['{C73551BD-E9D3-45EE-8037-968FCDA84546}']
  end;

  { amqp_method_confirm_select_ok }

  amqp_method_confirm_select_ok = class(amqp_method_confirm_select, IAMQPConfirmSelectOk)
  public
    class function method_id: amqp_short_uint; override;
  end;

  IAMQPHeartbeat = interface(IAMQPObject)
  ['{8C033184-382D-46C5-8D3E-5F6CC6BBB5BF}']
  end;

  amqp_heartbeat = class(amqp_object, IAMQPHeartbeat)
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    class function create_frame(achannel: amqp_short_uint): amqp_frame;
  end;

function Swap2Octet(AValue: amqp_2octet): amqp_2octet;
function Swap4Octet(AValue: amqp_4octet): amqp_4octet;
function Swap8Octet(AValue: amqp_8octet): amqp_8octet;
function SwapFloat(AValue: amqp_float): amqp_float;
function SwapDouble(AValue: amqp_double): amqp_double;
procedure SwapBuf(InBuf, OutBuf: Pointer; len: byte);

function new_amqp_protocol(AProtocolIdMajor, AProtocolIdMinor, AVersionMajor,
  AVersionMinor: amqp_octet): amqp_protocol_header;

implementation

uses sysutils, variants, amqp_message;

var
  famqp_method_factory: TStringList = nil;

const
  AMQP_BASIC_CONTENT_TYPE_FLAG = (1 shl 15);
  AMQP_BASIC_CONTENT_ENCODING_FLAG = (1 shl 14);
  AMQP_BASIC_HEADERS_FLAG = (1 shl 13);
  AMQP_BASIC_DELIVERY_MODE_FLAG = (1 shl 12);
  AMQP_BASIC_PRIORITY_FLAG = (1 shl 11);
  AMQP_BASIC_CORRELATION_ID_FLAG = (1 shl 10);
  AMQP_BASIC_REPLY_TO_FLAG = (1 shl 9);
  AMQP_BASIC_EXPIRATION_FLAG = (1 shl 8);
  AMQP_BASIC_MESSAGE_ID_FLAG = (1 shl 7);
  AMQP_BASIC_TIMESTAMP_FLAG = (1 shl 6);
  AMQP_BASIC_TYPE_FLAG = (1 shl 5);
  AMQP_BASIC_USER_ID_FLAG = (1 shl 4);
  AMQP_BASIC_APP_ID_FLAG = (1 shl 3);
  AMQP_BASIC_CLUSTER_ID_FLAG = (1 shl 2);

type

  { TAMQPDebugObject }

  TAMQPDebugObject = class
  private
    fclass: amqp_object_class;
    fcount: Int64;
  public
    property &Class: amqp_object_class read fclass write fclass;
    property count: Int64 read fcount write fcount;
  end;

  { TAMQPDebugObjectList }

  TAMQPDebugObjectList = class(TFPObjectHashTable)
  private
    function GetItems(const index: string): TAMQPDebugObject;
  protected
    Procedure DoIterate(Item: TObject; const Key: string; var Continue: Boolean);
  public
    destructor Destroy; override;
    property Items[const index: string]: TAMQPDebugObject read GetItems; default;
    procedure Add(const AKey: String; AObjClass: amqp_object_class);
  end;

var
  FDebugList: TAMQPDebugObjectList;

function DebugList: TAMQPDebugObjectList;
begin
 if FDebugList = nil then
   FDebugList :=TAMQPDebugObjectList.Create;
 Result := FDebugList;
end;

function SetBit(AByte: amqp_octet; ABit: amqp_octet; AState: Boolean)
  : amqp_octet;
begin
  if AState then
    Result := AByte or (1 shl ABit)
  else
    Result := AByte and (not(1 shl ABit));
end;

function GetBit(AByte: amqp_octet; ABit: amqp_octet): Boolean;
begin
  Result := (AByte and (1 shl ABit)) <> 0;
end;

procedure register_amqp_method(amethod_class: amqp_method_class);
var
  nm: AnsiString;
begin
  nm := Format('%d-%d', [amethod_class.class_id, amethod_class.method_id]);
  if famqp_method_factory = nil then
    famqp_method_factory := TStringList.Create;
  if famqp_method_factory.IndexOf(nm) = -1 then
    famqp_method_factory.AddObject(nm, Pointer(amethod_class));
end;

function amqp_method_factory(aclass_id, amethod_id: amqp_short_uint)
  : amqp_method_class;
var
  idx: Integer;
begin
  Result := nil;
  if (famqp_method_factory <> nil) then
  begin
    idx := famqp_method_factory.IndexOf
      (Format('%d-%d', [aclass_id, amethod_id]));
    if idx > -1 then
      Result := amqp_method_class(famqp_method_factory.Objects[idx]);
  end;

end;

function TAMQPDebugObjectList.GetItems(const index: string): TAMQPDebugObject;
begin
  Result := TAMQPDebugObject(inherited Items[Index]);
end;

procedure TAMQPDebugObjectList.DoIterate(Item: TObject; const Key: string;
  var Continue: Boolean);
begin
  Continue := True;
  with TAMQPDebugObject(Item) do
   if count > 0 then
      Writeln(Key,':', &Class.ClassName, ':', count);
end;

destructor TAMQPDebugObjectList.Destroy;
begin
  Iterate(DoIterate);
  inherited Destroy;
end;

procedure TAMQPDebugObjectList.Add(const AKey: String; AObjClass: amqp_object_class);
var Item: TAMQPDebugObject;
begin
  Item := TAMQPDebugObject.Create;
  Item.&Class := AObjClass;
  Item.count := 1;
  inherited Add(AKey, Item);
end;

{ TAMQPInterfacedObject }

function TAMQPInterfacedObject.QueryInterface(constref iid: tguid;
  out obj): longint; cdecl;
begin
  if getinterface(iid,obj) then
    result:=S_OK
  else
    result:=longint(E_NOINTERFACE);
end;

function TAMQPInterfacedObject._AddRef: longint; cdecl;
begin
  _addref:=interlockedincrement(frefcount);
end;

function TAMQPInterfacedObject._Release: longint; cdecl;
begin
 _Release:=interlockeddecrement(frefcount);
 if _Release=0 then
   self.destroy;
end;

function declocked(var l : longint) : boolean;assembler; nostackframe;
  asm
{$ifdef FPC_PIC}
     movq       IsMultithread@GOTPCREL(%rip),%rax
     cmpl       $0,(%rax)
{$else FPC_PIC}
     cmpl       $0,IsMultithread(%rip)
{$endif FPC_PIC}
{$ifndef win64}
     mov        %rdi, %rcx
{$endif win64}
     jz         .Ldeclockednolock
     lock
     decl       (%rcx)
     jmp        .Ldeclockedend
.Ldeclockednolock:
     decl       (%rcx)
.Ldeclockedend:
     setzb      %al
  end;


procedure TAMQPInterfacedObject.AfterConstruction;
begin
  declocked(frefcount);
end;

procedure TAMQPInterfacedObject.BeforeDestruction;
begin
 if frefcount<>0 then
   RunError(204);
end;

class function TAMQPInterfacedObject.NewInstance: TObject;
begin
 NewInstance:=inherited NewInstance;
 if NewInstance<>nil then
   TAMQPInterfacedObject(NewInstance).frefcount:=1;
end;

{ amqp_method_confirm_select_ok }

class function amqp_method_confirm_select_ok.method_id: amqp_short_uint;
begin
  Result := 11;
end;

{ amqp_method_confirm_select }

function amqp_method_confirm_select.getFlag(const Index: Integer): amqp_bit;
begin
 Result := GetBit(FFlags, Index - 1);
end;

procedure amqp_method_confirm_select.SetFlag(const Index: Integer;
  const Value: amqp_bit);
begin
  SetBit(FFlags, Index - 1, Value);
end;

procedure amqp_method_confirm_select.DoWrite(AStream: TStream);
begin
  inherited DoWrite(AStream);
  WriteOctet(AStream, FFlags);
end;

procedure amqp_method_confirm_select.DoRead(AStream: TStream);
begin
  inherited DoRead(AStream);
  FFlags := ReadOctet(AStream);
end;

function amqp_method_confirm_select.GetSize: amqp_long_long_uint;
begin
  Result := inherited GetSize + SizeOf(FFlags);
end;

class function amqp_method_confirm_select.method_id: amqp_short_uint;
begin
  Result := 10;
end;

class function amqp_method_confirm_select.create_frame(
  achannel: amqp_short_uint; aNoWait: Boolean): IAMQPFrame;
begin
  Result := new_frame(achannel);
  with Result.AsContainer.method as IAMQPConfirmSelect do
   nowait := aNoWait;
end;

{ amqp_method_confirm_class }

procedure amqp_method_confirm_class.DoWrite(AStream: TStream);
begin

end;

procedure amqp_method_confirm_class.DoRead(AStream: TStream);
begin

end;

function amqp_method_confirm_class.GetSize: amqp_long_long_uint;
begin
  Result := 0;
end;

class function amqp_method_confirm_class.class_id: amqp_short_uint;
begin
  Result := 85;
end;

{ amqp_method_exchange_unbind_ok }

class function amqp_method_exchange_unbind_ok.method_id: amqp_short_uint;
begin
  Result := 51;
end;

{ amqp_method_exchange_unbind }

class function amqp_method_exchange_unbind.method_id: amqp_short_uint;
begin
  Result := 40;
end;

{ amqp_method_exchange_bind_ok }

class function amqp_method_exchange_bind_ok.method_id: amqp_short_uint;
begin
  Result := 31;
end;

{ amqp_method_exchange_bind }

function amqp_method_exchange_bind.Getdestination: AnsiString;
begin
  Result := fdestination.val;
end;

function amqp_method_exchange_bind.Getno_wait: amqp_bit;
begin
  Result := Fno_wait;
end;

function amqp_method_exchange_bind.GetArguments: IAMQPProperties;
begin
  Result := Farguments;
end;

function amqp_method_exchange_bind.Getroutingkey: AnsiString;
begin
 Result := froutingkey.val;
end;

function amqp_method_exchange_bind.Getsource: AnsiString;
begin
 Result := fsource.val;
end;

function amqp_method_exchange_bind.getticket: amqp_short_uint;
begin
  Result := fticket;
end;

procedure amqp_method_exchange_bind.SetArguments(AValue: IAMQPProperties);
begin
  if AValue <> nil then
    Farguments.Assign(AValue)
  else
    Farguments.Clear;
end;

procedure amqp_method_exchange_bind.Setdestination(AValue: AnsiString);
begin
 fdestination.val := AValue;
end;

procedure amqp_method_exchange_bind.Setno_wait(AValue: amqp_bit);
begin
  Fno_wait := AValue;
end;

procedure amqp_method_exchange_bind.Setroutingkey(AValue: AnsiString);
begin
 froutingkey.val := AValue;
end;

procedure amqp_method_exchange_bind.Setsource(AValue: AnsiString);
begin
 fsource.val := AValue;
end;

procedure amqp_method_exchange_bind.setticket(AValue: amqp_short_uint);
begin
  fticket := AValue;
end;

procedure amqp_method_exchange_bind.DoWrite(AStream: TStream);
begin
 WriteShortUInt(AStream, fticket);
 fdestination.Write(AStream);
 fsource.Write(AStream);
 froutingkey.Write(AStream);
 WriteBoolean(AStream, Fno_wait);
 Farguments.Write(AStream);
end;

procedure amqp_method_exchange_bind.DoRead(AStream: TStream);
begin
 fticket := Read2Octet(AStream);
 fdestination.Read(AStream);
 fsource.Read(AStream);
 FroutingKey.Read(AStream);
 Fno_wait := ReadBoolean(AStream);
 Farguments.Read(AStream);
end;

function amqp_method_exchange_bind.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(fticket) + fdestination.Size + fsource.Size + froutingkey.Size + sizeof(Fno_wait) + Farguments.Size;
end;

constructor amqp_method_exchange_bind.Create;
begin
  inherited;
  fdestination := amqp_exchange_name.Create;
  fsource := amqp_exchange_name.Create;
  froutingkey := amqp_exchange_name.Create;
  Farguments := amqp_peer_properties.Create;
  fticket := 0;
end;

destructor amqp_method_exchange_bind.Destroy;
begin
  fdestination := nil;
  fsource := nil;
  froutingkey := nil;
  Farguments := nil;
  inherited Destroy;
end;

class function amqp_method_exchange_bind.method_id: amqp_short_uint;
begin
  Result := 30;
end;

class function amqp_method_exchange_bind.create_frame(
  achannel: amqp_short_uint; aticket: amqp_short_uint; adestination, asource,
  aroutingkey: AnsiString; anowait: amqp_boolean;
  aargs: IAMQPProperties): IAMQPFrame;
begin
 Result := new_frame(achannel);
 with Result.AsContainer.method as IAMQPMethodExchangeBind do
 begin
   ticket := aticket;
   destination := adestination;
   source := asource;
   routingKey := aroutingkey;
   no_wait := anowait;
   arguments := aargs;
 end;
end;

{ amqp_field_value }

procedure amqp_field_value.Assign(aobject: IAMQPObject);
var Obj: IAMQPFieldValue;
begin
  if Supports(aobject, IAMQPFieldValue, Obj) then
  begin
    kind := Obj.kind;
    if fval <> nil then
      fval.Assign(Obj.val);
  end;
end;

function amqp_field_value.Clone: IAMQPFieldValue;
begin
 Result := amqp_field_value.Create;
 Result.kind := Self.kind;
 if Self.val <> nil then
  Result.val.Assign(Self.val);
end;

constructor amqp_field_value.Create(AName: String = '');
begin
  inherited;
  fval := nil;
end;

function amqp_field_value.CreateVal: IAMQPObject;
begin
  Result := nil;
  case fkind of
    't':
      Result := amqp_field_boolean.Create;
    'b':
      Result := amqp_field_short_short_int.Create;
    'B':
      Result := amqp_field_short_short_uint.Create;
    'U':
      Result := amqp_field_short_int.Create;
    'u':
      Result := amqp_field_short_uint.Create;
    'I':
      Result := amqp_field_long_int.Create;
    'i':
      Result := amqp_field_long_uint.Create;
    'L':
      Result := amqp_field_long_long_int.Create;
    'l':
      Result := amqp_field_long_long_uint.Create;
    'f':
      Result := amqp_field_float.Create;
    'd':
      Result := amqp_field_double.Create;
    'D':
      Result := amqp_decimal.Create;
    's':
      Result := amqp_short_str.Create(name+'.field_value');
    'S':
      Result := amqp_long_str.Create;
    'A':
      Result := amqp_field_array.Create;
    'T':
      Result := amqp_field_timestamp.Create;
    'F':
      Result := amqp_table.Create;
    'V':
      Result := nil;
  end;

end;

destructor amqp_field_value.Destroy;
begin
  fval := nil;
  inherited;
end;

procedure amqp_field_value.DestroyVal;
begin
  fval := nil;
end;

procedure amqp_field_value.DoRead(AStream: TStream);
begin
  fkind := ReadChar(AStream);
  fval := nil;
  fval := CreateVal;
  if fval <> nil then
    fval.Read(AStream);
end;

procedure amqp_field_value.DoWrite(AStream: TStream);
begin
  WriteChar(AStream, fkind);
  if val <> nil then
    val.Write(AStream);
end;

function amqp_field_value.GetAsArray: IAMQPArray;
begin
  Result := nil;
  if (fkind = 'A') and (val <> nil) then
    Result := amqp_field_array(fval)
  else if (fkind = '') then
  begin
    DestroyVal;
    fval := amqp_field_array.Create;
    Result := amqp_field_array(fval);
    fkind := 'A';
  end;
end;

function amqp_field_value.GetAsBoolean: Boolean;
begin
  Result := False;
  if (fkind = 't') and (val <> nil) then
    Result := amqp_field_boolean(fval).Value;
end;

function amqp_field_value.GetAsDecimal: IAMQPDecimal;
begin
  Result := nil;
  if (fkind = 'D') and (val <> nil) then
    Result := val as IAMQPDecimal
  else
  begin
     fval := nil;
     fkind := 'D';
     fval := amqp_decimal.Create;
     Result := val as IAMQPDecimal;
  end;
end;

function amqp_field_value.GetAsDouble: amqp_double;
begin
  Result := 0;
  if (fkind = 'd') and (val <> nil) then
    Result := (val as IAMQPDecimal).Value;
end;

function amqp_field_value.GetAsFloat: amqp_float;
begin
  Result := 0;
  if (fkind = 'f') and (val <> nil) then
    Result := (val as IAMQPFloat).Value;
end;

function amqp_field_value.GetAsLongInt: amqp_long_int;
begin
  Result := 0;
  if (fkind = 'I') and (val <> nil) then
    Result := (val as IAMQPLongInt).Value;
end;

function amqp_field_value.GetAsLongLongInt: amqp_long_long_int;
begin
  Result := 0;
  if (fkind = 'L') and (val <> nil) then
    Result := (val as IAMQPLongLongInt).Value;
end;

function amqp_field_value.GetAsLongLongUInt: amqp_long_long_uint;
begin
  Result := 0;
  if (fkind = 'l') and (val <> nil) then
    Result := (val as IAMQPLongLongUInt).Value;
end;

function amqp_field_value.GetAsLongString: AnsiString;
begin
  Result := '';
  if (fkind = 'S') and (val <> nil) then
    Result := (val as IAMQPLongStr).val;
end;

function amqp_field_value.GetAsLongUInt: amqp_long_uint;
begin
  Result := 0;
  if (fkind = 'i') and (val <> nil) then
    Result := (val as IAMQPLongUInt).Value;
end;

function amqp_field_value.GetAsShortInt: amqp_short_int;
begin
  Result := 0;
  if (fkind = 'U') and (val <> nil) then
    Result := (val as IAMQPShortInt).Value;
end;

function amqp_field_value.GetAsShortShortInt: amqp_short_short_int;
begin
  Result := 0;
  if (fkind = 'b') and (val <> nil) then
    Result := (val as IAMQPShortShortInt).Value;
end;

function amqp_field_value.GetAsShortShortUInt: amqp_short_short_uint;
begin
  Result := 0;
  if (fkind = 'B') and (val <> nil) then
    Result := (val as IAMQPShortShortUInt).Value;
end;

function amqp_field_value.GetAsShortString: AnsiString;
begin
  Result := '';
  if (fkind = 's') and (val <> nil) then
    Result := (val as IAMQPShortStr).val;
end;

function amqp_field_value.Getkind: amqp_string_char;
begin
  Result := fkind;
end;

function amqp_field_value.GetVal: IAMQPObject;
begin
  Result := fval;
end;

procedure amqp_field_value.SetAsArray(AValue: IAMQPArray);
begin
 if (fkind <> 'A') or (fval = nil) then
 begin
   DestroyVal;
   fval := amqp_field_array.Create;
   fkind := 'A';
 end;
 fval.Assign(AValue);
end;

function amqp_field_value.GetAsShortUInt: amqp_short_uint;
begin
  Result := 0;
  if (fkind = 'u') and (val <> nil) then
    Result := (val as IAMQPShortUInt).Value;
end;

function amqp_field_value.GetAsTable: IAMQPTable;
begin
  Result := nil;
  if (fkind = 'F') and (val <> nil) then
    Result := fval as IAMQPTable
  else if (fkind = '') or (fkind = #0) then
  begin
    DestroyVal;
    fval := amqp_table.Create;
    Result := fval as IAMQPTable;
    fkind := 'F';
  end;
end;

procedure amqp_field_value.SetAsTable(AValue: IAMQPTable);
begin
  if (fval = nil) or (fkind <> 'F') then
  begin
   DestroyVal;
   fval := amqp_table.Create;
   fkind := 'F';;
  end;
  fval.Assign(AValue);
end;

function amqp_field_value.GetSize: amqp_long_long_uint;
begin
  Result := 0;
  if fval <> nil then
    Result := fval.Size;
  Result := Result + sizeof(fkind);
end;

procedure amqp_field_value.SetAsBoolean(const Value: Boolean);
begin
  DestroyVal;
  fkind := 't';
  fval := amqp_field_boolean.Create;
  amqp_field_boolean(fval).Value := Value;
end;

procedure amqp_field_value.SetAsDouble(const Value: amqp_double);
begin
  DestroyVal;
  fkind := 'd';
  fval := amqp_field_double.Create;
  (fval as IAMQPDouble).Value := Value;
end;

procedure amqp_field_value.SetAsFloat(const Value: amqp_float);
begin
  DestroyVal;
  fkind := 'f';
  fval := amqp_field_float.Create;
  (fval as IAMQPFloat).Value := Value;
end;

procedure amqp_field_value.SetAsLongInt(const Value: amqp_long_int);
begin
  DestroyVal;
  fkind := 'I';
  fval := amqp_field_long_int.Create;
  (fval as IAMQPLongInt).Value := Value;
end;

procedure amqp_field_value.SetAsLongLongInt(const Value: amqp_long_long_int);
begin
  DestroyVal;
  fkind := 'L';
  fval := amqp_field_long_long_int.Create;
  (fval as IAMQPLongLongInt).Value := Value;
end;

procedure amqp_field_value.SetAsLongLongUInt(const Value: amqp_long_long_uint);
begin
  DestroyVal;
  fkind := 'l';
  fval := amqp_field_long_long_uint.Create;
  (fval as IAMQPLongLongUInt).Value := Value;
end;

procedure amqp_field_value.SetAsLongString(const Value: AnsiString);
begin
  if fval <> nil then
    fval := nil;
  fval := amqp_long_str.Create;
  fkind := 'S';
  (fval as IAMQPLongStr).val := Value;
end;

procedure amqp_field_value.SetAsLongUInt(const Value: amqp_long_uint);
begin
  DestroyVal;
  fkind := 'i';
  fval := amqp_field_long_uint.Create;
  (fval as IAMQPLongUInt).Value := Value;
end;

procedure amqp_field_value.SetAsShortInt(const Value: amqp_short_int);
begin
  DestroyVal;
  fkind := 'U';
  fval := amqp_field_short_int.Create;
  (fval as IAMQPShortInt).Value := Value;
end;

procedure amqp_field_value.SetAsShortShortInt(const Value
  : amqp_short_short_int);
begin
  DestroyVal;
  fkind := 'b';
  fval := amqp_field_short_short_int.Create;
  (fval as IAMQPShortShortInt).Value := Value;

end;

procedure amqp_field_value.SetAsShortShortUInt(const Value
  : amqp_short_short_uint);
begin
  DestroyVal;
  fkind := 'B';
  fval := amqp_field_short_short_uint.Create;
  (fval as IAMQPShortShortUInt).Value := Value;

end;

procedure amqp_field_value.SetAsShortString(const Value: AnsiString);
begin
  fval := nil;
  fval := amqp_short_str.Create(name+'.field');
  fkind := 's';
  (fval as IAMQPShortStr).val := Value;
end;

procedure amqp_field_value.SetAsShortUInt(const Value: amqp_short_uint);
begin
  DestroyVal;
  fkind := 'u';
  fval := amqp_field_short_uint.Create;
  (fval as IAMQPShortUInt).Value := Value;
end;

procedure amqp_field_value.setKind(const Value: amqp_string_char);
begin
  if fkind <> Value then
  begin
    fkind := Value;
    fval := nil;
    fval := CreateVal;
  end;
end;

{ amqp_short_str }

type
  ByteArray = array [0 .. 0] of byte;
  PByteArray = ^ByteArray;


procedure SwapBuf(InBuf, OutBuf: Pointer; len: byte);
var
  i: byte;
  pIn: PByteArray absolute InBuf;
  pOut: PByteArray absolute OutBuf;
begin
  for i := 0 to len - 1 do
    pOut^[len - i - 1] := pIn^[i];
end;

function Swap2Octet(AValue: amqp_2octet): amqp_2octet;
begin
  SwapBuf(@AValue, @Result, sizeof(amqp_2octet));
end;

function Swap4Octet(AValue: amqp_4octet): amqp_4octet;
begin
  SwapBuf(@AValue, @Result, sizeof(amqp_4octet));
end;

function Swap8Octet(AValue: amqp_8octet): amqp_8octet;
begin
  SwapBuf(@AValue, @Result, sizeof(amqp_8octet));
end;

function SwapFloat(AValue: amqp_float): amqp_float;
begin
  SwapBuf(@AValue, @Result, sizeof(AValue));
end;

function SwapDouble(AValue: amqp_double): amqp_double;
begin
  SwapBuf(@AValue, @Result, sizeof(AValue));
end;

{ amqp_object }

constructor amqp_object.Create(AName: String = '');
var dObj: TAMQPDebugObject;
begin
  FName := AName;
  if FName = '' then
    FName := ClassName;
  dObj := DebugList.Items[FName];
  if dObj = nil then
    DebugList.Add(FName, amqp_object_class(Self.ClassType))
  else
   dObj.count := dObj.count + 1;
end;

destructor amqp_object.Destroy;
var dObj: TAMQPDebugObject;
begin
//  WriteLn(ClassName,'.Create');
  dObj := DebugList.Items[FName];
  if dObj <> nil then
   dObj.count := dObj.count - 1;
  inherited Destroy;
end;

function amqp_object.GetAsString: AnsiString;
var
  Buf: TMemoryStream;
begin
  Buf := TMemoryStream.Create;
  try
    write(Buf);
    SetLength(Result, Buf.Size);
    Buf.Position := 0;
    Buf.Read(Result[1], Buf.Size)
  finally
    Buf.Free;
  end;
end;

function amqp_object.GetName: String;
begin
  Result := FName;
end;

procedure amqp_object.Read(AStream: TStream);
begin
  DoRead(AStream);
end;

function amqp_object.Read2Octet(AStream: TStream): amqp_2octet;
begin
  AStream.Read(Result, sizeof(Result));
  Result := Swap2Octet(Result);
end;

function amqp_object.Read4Octet(AStream: TStream): amqp_4octet;
begin
  AStream.Read(Result, sizeof(Result));
  Result := Swap4Octet(Result);
end;

function amqp_object.Read8Octet(AStream: TStream): amqp_8octet;
begin
  AStream.Read(Result, sizeof(Result));
  Result := Swap8Octet(Result);
end;

function amqp_object.ReadBoolean(AStream: TStream): amqp_boolean;
begin
  Result := Boolean(ReadOctet(AStream));
end;

function amqp_object.ReadChar(AStream: TStream): amqp_string_char;
begin
  AStream.Read(Result, sizeof(Result));
end;

function amqp_object.GetRefCount: Integer;
begin
  Result := Self.RefCount;
end;

function amqp_object.GetAsDebugString: String;
begin
  Result := ClassName;
end;

function amqp_object.ReadDouble(AStream: TStream): amqp_double;
begin
  AStream.Read(Result, sizeof(Result));
  Result := SwapDouble(Result);
end;

function amqp_object.ReadFloat(AStream: TStream): amqp_float;
begin
  AStream.Read(Result, sizeof(Result));
  Result := SwapFloat(Result);
end;

function amqp_object.ReadLongInt(AStream: TStream): amqp_long_int;
begin
  Result := Read4Octet(AStream);
end;

function amqp_object.ReadLongLongInt(AStream: TStream): amqp_long_long_int;
begin
  Result := Read8Octet(AStream);
end;

function amqp_object.ReadLongLongUInt(AStream: TStream): amqp_long_long_uint;
begin
  Result := Read8Octet(AStream);
end;

function amqp_object.ReadLongUInt(AStream: TStream): amqp_long_uint;
begin
  Result := Read4Octet(AStream);
end;

function amqp_object.ReadOctet(AStream: TStream): amqp_octet;
begin
  AStream.Read(Result, sizeof(Result));
end;

function amqp_object.ReadShortInt(AStream: TStream): amqp_short_int;
begin
  Result := Read2Octet(AStream);
end;

function amqp_object.ReadShortShortInt(AStream: TStream): amqp_short_short_int;
begin
  AStream.Read(Result, sizeof(Result));
end;

function amqp_object.ReadShortShortUInt(AStream: TStream)
  : amqp_short_short_uint;
begin
  Result := ReadOctet(AStream);
end;

function amqp_object.ReadShortUInt(AStream: TStream): amqp_short_uint;
begin
  Result := Read2Octet(AStream);
end;

procedure amqp_object.SetAsString(const Value: AnsiString);
var
  Buf: TMemoryStream;
begin
  Buf := TMemoryStream.Create;
  try
    if Value <> '' then
      Buf.Write(Value[1], Length(Value));
    Buf.Position := 0;
    DoRead(Buf);
  finally
    Buf.Free;
  end;
end;

procedure amqp_object.SetName(AValue: String);
begin
  FName := AValue;
end;

function amqp_object.GetClassName: String;
begin
  Result := ClassName;
end;

procedure amqp_object.Write(AStream: TStream);
begin
  DoWrite(AStream);
end;

procedure amqp_object.Write2Octet(AStream: TStream; AValue: amqp_2octet);
begin
  AValue := Swap2Octet(AValue);
  AStream.Write(AValue, sizeof(AValue));
end;

procedure amqp_object.Write4Octet(AStream: TStream; AValue: amqp_4octet);
begin
  AValue := Swap4Octet(AValue);
  AStream.Write(AValue, sizeof(AValue));
end;

procedure amqp_object.Write8Octet(AStream: TStream; AValue: amqp_8octet);
begin
  AValue := Swap8Octet(AValue);
  AStream.Write(AValue, sizeof(AValue));
end;

procedure amqp_object.WriteBoolean(AStream: TStream; AValue: amqp_boolean);
begin
  WriteOctet(AStream, byte(AValue));
end;

procedure amqp_object.WriteChar(AStream: TStream; AValue: amqp_string_char);
begin
  AStream.Write(AValue, sizeof(AValue));
end;

procedure amqp_object.WriteDouble(AStream: TStream; AValue: amqp_double);
begin
  AValue := SwapDouble(AValue);
  AStream.Write(AValue, sizeof(AValue));
end;

procedure amqp_object.WriteFloat(AStream: TStream; AValue: amqp_float);
begin
  AValue := SwapFloat(AValue);
  AStream.Write(AValue, sizeof(AValue));
end;

procedure amqp_object.WriteLongInt(AStream: TStream; AValue: amqp_long_int);
begin
  Write4Octet(AStream, AValue);
end;

procedure amqp_object.WriteLongLongInt(AStream: TStream;
  AValue: amqp_long_long_int);
begin
  Write8Octet(AStream, AValue);
end;

procedure amqp_object.WriteLongLongUInt(AStream: TStream;
  AValue: amqp_long_long_uint);
begin
  Write8Octet(AStream, AValue);
end;

procedure amqp_object.WriteLongUInt(AStream: TStream; AValue: amqp_long_uint);
begin
  Write4Octet(AStream, AValue);
end;

procedure amqp_object.WriteOctet(AStream: TStream; AValue: amqp_octet);
begin
  AStream.Write(AValue, sizeof(AValue));
end;

procedure amqp_object.WriteShortInt(AStream: TStream; AValue: amqp_short_int);
begin
  Write2Octet(AStream, AValue);
end;

procedure amqp_object.WriteShortShortInt(AStream: TStream;
  AValue: amqp_short_short_int);
begin
  AStream.Write(AValue, sizeof(AValue));
end;

procedure amqp_object.WriteShortShortUInt(AStream: TStream;
  AValue: amqp_short_short_uint);
begin
  WriteOctet(AStream, AValue);
end;

procedure amqp_object.WriteShortUInt(AStream: TStream; AValue: amqp_short_uint);
begin
  Write2Octet(AStream, AValue);
end;

{ amqp_decimal }

procedure amqp_decimal.Assign(aobject: IAMQPObject);
var Obj: IAMQPDecimal;
begin
  if Supports(aobject, IAMQPDecimal, Obj) then
  begin
    Fvalue := Obj.Value;
    Fscale := Obj.scale;
  end;
end;

procedure amqp_decimal.DoRead(AStream: TStream);
begin
  Fvalue := ReadLongUInt(AStream);
  Fscale := ReadOctet(AStream);
end;

procedure amqp_decimal.DoWrite(AStream: TStream);
begin
  WriteLongUInt(AStream, Fvalue);
  WriteOctet(AStream, Fscale);
end;

function amqp_decimal.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(Fvalue) + sizeof(Fscale);
end;

procedure amqp_decimal.Setscale(const Value: amqp_octet);
begin
  Fscale := Value;
end;

function amqp_decimal.Getscale: amqp_octet;
begin
  Result := Fscale;
end;

function amqp_decimal.Getvalue: amqp_long_uint;
begin
 Result := Fvalue;
end;

procedure amqp_decimal.Setvalue(const Value: amqp_long_uint);
begin
  Fvalue := Value;
end;

{ amqp_short_str }

procedure amqp_short_str.Assign(aobject: IAMQPObject);
var Obj: IAMQPShortStr;
begin
 if Supports(aobject, IAMQPShortStr, Obj) then
    setval(Obj.val);
end;

procedure amqp_short_str.DoRead(AStream: TStream);
begin
  flen := ReadShortShortUInt(AStream);
  if flen > 0 then
  begin
    SetLength(fval, flen);
    AStream.Read(fval[1], flen);
  end;
end;

procedure amqp_short_str.DoWrite(AStream: TStream);
begin
  WriteShortShortUInt(AStream, flen);
  if flen > 0 then
    AStream.Write(fval[1], flen);
end;

function amqp_short_str.GetSize: amqp_long_long_uint;
begin
  Result := flen + sizeof(flen);
end;

destructor amqp_short_str.Destroy;
begin
  setval('');
  inherited Destroy;
end;

procedure amqp_short_str.setval(const Value: AnsiString);
begin
  fval := Value;
  flen := Length(Value);
end;

function amqp_short_str.GetLen: amqp_short_short_uint;
begin
  Result := flen;
end;

function amqp_short_str.Getval: AnsiString;
begin
 Result := fval;
end;

{ amqp_long_str }

procedure amqp_long_str.Assign(aobject: IAMQPObject);
var Obj: IAMQPLongStr;
begin
  if Supports(aobject, IAMQPLongStr, Obj) then
    setval(Obj.val);
end;

procedure amqp_long_str.DoRead(AStream: TStream);
begin
  flen := ReadLongUInt(AStream);
  if flen > 0 then
  begin
    SetLength(fval, flen);
    AStream.Read(fval[1], flen);
  end;
end;

procedure amqp_long_str.DoWrite(AStream: TStream);
begin
  WriteLongUInt(AStream, flen);
  if flen > 0 then
    AStream.Write(fval[1], flen);
end;

function amqp_long_str.GetSize: amqp_long_long_uint;
begin
  Result := flen + sizeof(flen);
end;

procedure amqp_long_str.setval(const Value: AnsiString);
begin
  fval := Value;
  flen := Length(fval);
end;

function amqp_long_str.Getlen: amqp_long_uint;
begin
  Result := flen;
end;

function amqp_long_str.Getval: AnsiString;
begin
 Result := fval;
end;

{ amqp_field_boolean }

procedure amqp_field_boolean.Assign(aobject: IAMQPObject);
var Obj: IAMQPBoolean;
begin
  if Supports(aobject, IAMQPBoolean, Obj) then
    Fvalue := Obj.Value
end;

procedure amqp_field_boolean.DoRead(AStream: TStream);
begin
  Fvalue := ReadBoolean(AStream);
end;

function amqp_field_boolean.Getvalue: Boolean;
begin
  Result := Fvalue;
end;

procedure amqp_field_boolean.Setvalue(AValue: Boolean);
begin
 Fvalue := AValue;
end;

procedure amqp_field_boolean.DoWrite(AStream: TStream);
begin
  WriteBoolean(AStream, Fvalue);
end;

function amqp_field_boolean.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(Fvalue);
end;

{ amqp_field_short_short_uint }

procedure amqp_field_short_short_uint.Assign(aobject: IAMQPObject);
var Obj: IAMQPShortShortUInt;
begin
  if Supports(aobject, IAMQPShortShortUInt, Obj) then
    Fvalue := Obj.Value;
end;

procedure amqp_field_short_short_uint.DoRead(AStream: TStream);
begin
  Fvalue := ReadShortShortUInt(AStream);
end;

function amqp_field_short_short_uint.Getvalue: amqp_short_short_uint;
begin
  Result := Fvalue;
end;

procedure amqp_field_short_short_uint.Setvalue(AValue: amqp_short_short_uint);
begin
 Fvalue := AValue;
end;

procedure amqp_field_short_short_uint.DoWrite(AStream: TStream);
begin
  WriteShortShortUInt(AStream, Fvalue);
end;

function amqp_field_short_short_uint.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(Fvalue);
end;

{ amqp_field_short_short_int }

procedure amqp_field_short_short_int.Assign(aobject: IAMQPObject);
var Obj: IAMQPShortShortInt;
begin
  if Supports(aobject, IAMQPShortShortInt, Obj) then
    Fvalue := Obj.Value;
end;

procedure amqp_field_short_short_int.DoRead(AStream: TStream);
begin
  Fvalue := ReadShortShortInt(AStream);
end;

function amqp_field_short_short_int.Getvalue: amqp_short_short_int;
begin
  Result :=  Fvalue;
end;

procedure amqp_field_short_short_int.Setvalue(AValue: amqp_short_short_int);
begin
 Fvalue := AValue;
end;

procedure amqp_field_short_short_int.DoWrite(AStream: TStream);
begin
  WriteShortShortInt(AStream, Fvalue);
end;

function amqp_field_short_short_int.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(Fvalue);
end;

{ amqp_field_short_int }

procedure amqp_field_short_int.Assign(aobject: IAMQPObject);
var Obj: IAMQPShortInt;
begin
  if Supports(aobject, IAMQPShortInt, Obj) then
    Fvalue := Obj.Value;
end;

procedure amqp_field_short_int.DoRead(AStream: TStream);
begin
  Fvalue := ReadShortInt(AStream);
end;

function amqp_field_short_int.Getvalue: amqp_short_int;
begin
  Result := Fvalue;
end;

procedure amqp_field_short_int.Setvalue(AValue: amqp_short_int);
begin
 Fvalue := AValue;
end;

procedure amqp_field_short_int.DoWrite(AStream: TStream);
begin
  WriteShortInt(AStream, Fvalue);
end;

function amqp_field_short_int.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(Fvalue);
end;

{ amqp_field_short_uint }

procedure amqp_field_short_uint.Assign(aobject: IAMQPObject);
var Obj: IAMQPShortUInt;
begin
  if Supports(aobject, IAMQPShortUInt, Obj) then
    Fvalue := Obj.Value;
end;

procedure amqp_field_short_uint.DoRead(AStream: TStream);
begin
  Fvalue := ReadShortUInt(AStream);
end;

function amqp_field_short_uint.Getvalue: amqp_short_uint;
begin
  Result := Fvalue;
end;

procedure amqp_field_short_uint.Setvalue(AValue: amqp_short_uint);
begin
 Fvalue := AValue;
end;

procedure amqp_field_short_uint.DoWrite(AStream: TStream);
begin
  WriteShortUInt(AStream, Fvalue);
end;

function amqp_field_short_uint.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(Fvalue);
end;

{ amqp_field_long_uint }

procedure amqp_field_long_uint.Assign(aobject: IAMQPObject);
var Obj: IAMQPLongUInt;
begin
  if Supports(aobject, IAMQPLongUInt, Obj) then
    Fvalue := Obj.Value;
end;

procedure amqp_field_long_uint.DoRead(AStream: TStream);
begin
  Fvalue := ReadLongUInt(AStream);
end;

function amqp_field_long_uint.Getvalue: amqp_long_uint;
begin
  Result := Fvalue;
end;

procedure amqp_field_long_uint.Setvalue(AValue: amqp_long_uint);
begin
 Fvalue :=  AValue;
end;

procedure amqp_field_long_uint.DoWrite(AStream: TStream);
begin
  WriteLongUInt(AStream, Fvalue);
end;

function amqp_field_long_uint.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(Fvalue);
end;

{ amqp_field_long_int }

procedure amqp_field_long_int.Assign(aobject: IAMQPObject);
var Obj: IAMQPLongInt;
begin
  if Supports(aobject, IAMQPLongInt, Obj) then
    Fvalue := Obj.Value;
end;

procedure amqp_field_long_int.DoRead(AStream: TStream);
begin
  Fvalue := ReadLongInt(AStream);
end;

function amqp_field_long_int.Getvalue: amqp_long_int;
begin
  Result := Fvalue;
end;

procedure amqp_field_long_int.Setvalue(AValue: amqp_long_int);
begin
 Fvalue := AValue;
end;

procedure amqp_field_long_int.DoWrite(AStream: TStream);
begin
  WriteLongInt(AStream, Fvalue);
end;

function amqp_field_long_int.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(Fvalue);
end;

{ amqp_field_long_long_uint }

procedure amqp_field_long_long_uint.Assign(aobject: IAMQPObject);
var Obj: IAMQPLongLongUInt;
begin
  if Supports(aobject, IAMQPLongLongUInt, Obj) then
    Fvalue := Obj.Value;
end;

procedure amqp_field_long_long_uint.DoRead(AStream: TStream);
begin
  Fvalue := ReadLongLongUInt(AStream);
end;

function amqp_field_long_long_uint.Getwrite: amqp_long_long_uint;
begin
  Result := Fvalue;
end;

procedure amqp_field_long_long_uint.Setvalue(AValue: amqp_long_long_uint);
begin
 Fvalue := AValue;
end;

procedure amqp_field_long_long_uint.DoWrite(AStream: TStream);
begin
  WriteLongLongUInt(AStream, Fvalue);
end;

function amqp_field_long_long_uint.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(Fvalue);
end;

{ amqp_field_long_long_int }

procedure amqp_field_long_long_int.Assign(aobject: IAMQPObject);
var Obj: IAMQPLongLongInt;
begin
  if Supports(aobject, IAMQPLongLongInt, Obj) then
    Fvalue := Obj.Value;
end;

procedure amqp_field_long_long_int.DoRead(AStream: TStream);
begin
  Fvalue := ReadLongLongInt(AStream);
end;

function amqp_field_long_long_int.Getwrite: amqp_long_long_int;
begin
  Result := Fvalue;
end;

procedure amqp_field_long_long_int.Setvalue(AValue: amqp_long_long_int);
begin
 Fvalue := AValue;
end;

procedure amqp_field_long_long_int.DoWrite(AStream: TStream);
begin
  WriteLongLongInt(AStream, Fvalue);
end;

function amqp_field_long_long_int.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(Fvalue);
end;

{ amqp_field_float }

procedure amqp_field_float.Assign(aobject: IAMQPObject);
var Obj: IAMQPFloat;
begin
  if Supports(aobject, IAMQPFloat, Obj) then
    Fvalue := Obj.Value;
end;

procedure amqp_field_float.DoRead(AStream: TStream);
begin
  Fvalue := ReadFloat(AStream);
end;

function amqp_field_float.GetValue: amqp_float;
begin
  Result := Fvalue;
end;

procedure amqp_field_float.Setvalue(AValue: amqp_float);
begin
 Fvalue := AValue;
end;

procedure amqp_field_float.DoWrite(AStream: TStream);
begin
  WriteFloat(AStream, Fvalue);
end;

function amqp_field_float.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(Fvalue);
end;

{ amqp_field_double }

procedure amqp_field_double.Assign(aobject: IAMQPObject);
var Obj: IAMQPDouble;
begin
  if Supports(aobject, IAMQPDouble, Obj) then
    Fvalue := Obj.Value;
end;

procedure amqp_field_double.DoRead(AStream: TStream);
begin
  Fvalue := ReadDouble(AStream);
end;

function amqp_field_double.GetValue: amqp_double;
begin
  Result := Fvalue;
end;

procedure amqp_field_double.Setvalue(AValue: amqp_double);
begin
 Fvalue := AValue;
end;

procedure amqp_field_double.DoWrite(AStream: TStream);
begin
  WriteDouble(AStream, Fvalue);
end;

function amqp_field_double.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(Fvalue);
end;

{ amqp_field_pair }

procedure amqp_field_pair.Assign(aobject: IAMQPObject);
var Obj: IAMQPFieldPair;
begin
  if Supports(aobject, IAMQPFieldPair, Obj) then
  begin
    ffield_name.Assign(Obj.field_name);
    ffield_value.Assign(Obj.field_value);
  end;
end;

function amqp_field_pair.clone: IAMQPFieldPair;
begin
  Result := amqp_field_pair.Create;
  Result.field_name.Assign(ffield_name);
  Result.field_value.Assign(ffield_value);
end;

constructor amqp_field_pair.Create;
begin
  inherited;
  ffield_name := amqp_short_str.Create(name+'.field_name');
  ffield_value := amqp_field_value.Create(name+'.field_value');
end;

destructor amqp_field_pair.Destroy;
begin
  ffield_name := nil;
  ffield_value := nil;
  inherited;
end;

procedure amqp_field_pair.DoRead(AStream: TStream);
begin
  ffield_name.Read(AStream);
  ffield_value.Read(AStream);
end;

function amqp_field_pair.GetFieldName: IAMQPShortStr;
begin
  Result := ffield_name;
end;

function amqp_field_pair.GetFieldValue: IAMQPFieldValue;
begin
 Result := ffield_value;
end;

procedure amqp_field_pair.DoWrite(AStream: TStream);
begin
  ffield_name.Write(AStream);
  ffield_value.Write(AStream);
end;

function amqp_field_pair.GetSize: amqp_long_long_uint;
begin
  Result := ffield_name.Size + ffield_value.Size;
end;

{ amqp_field_array }

function amqp_field_array.Add: IAMQPFieldValue;
begin
  Result := amqp_field_value.Create;
  FArray.Add(Result);
end;

procedure amqp_field_array.Assign(AObject: IAMQPObject);
var
  i: Integer;
  Obj: IAMQPArray;
begin
  FArray.Clear;
  if Supports(AObject, IAMQPArray, Obj) then
    for i := 0 to Obj.Count - 1 do
      FArray.Add(Obj[i].clone);
end;

procedure amqp_field_array.Clear;
begin
  FArray.Clear;
end;

constructor amqp_field_array.Create;
begin
  inherited;
  FArray := TInterfaceList.Create;
end;

procedure amqp_field_array.Delete(Index: Integer);
begin
  FArray.Delete(index);
end;

destructor amqp_field_array.Destroy;
begin
  FArray.Free;
  inherited;
end;

procedure amqp_field_array.DoRead(AStream: TStream);
var
  t, k: amqp_long_int;
  val: IAMQPFieldValue;
begin
  FArray.Clear;
  t := ReadLongInt(AStream);
  k := 0;
  repeat
    val := Add;
    val.Read(AStream);
    k := k + val.Size;
  until k >= t;
end;

procedure amqp_field_array.DoWrite(AStream: TStream);
var
  s: amqp_long_int;
  i: Integer;
begin
  s := GetSize - sizeof(amqp_long_int);
  WriteLongInt(AStream, s);
  for i := 0 to Count - 1 do
    Items[i].Write(AStream);
end;

function amqp_field_array.GetCount: Integer;
begin
  Result := FArray.Count;
end;

function amqp_field_array.GetItems(Index: Integer): IAMQPFieldValue;
begin
  Result := amqp_field_value(FArray[index]);
end;

function amqp_field_array.GetSize: amqp_long_long_uint;
var
  i: Integer;
begin
  Result := sizeof(amqp_long_int);
  for i := 0 to Count - 1 do
    Result := Result + Items[i].Size;
end;

{ amqp_table }

function amqp_table.Add: IAMQPFieldPair;
begin
  Result := amqp_field_pair.Create;
  FTable.Add(Result);
end;

function amqp_table.Add(aFieldName: AnsiString;
  AValue: AnsiString): IAMQPFieldPair;
begin
 Result := Add;
 if IndexOfField(aFieldName) = -1 then
 begin
  Result.field_name.val := aFieldName;
  result.field_value.AsLongString := AValue;
 end;
end;

function amqp_table.Add(aFieldName: AnsiString;
  AValue: amqp_boolean): IAMQPFieldPair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsBoolean := AValue;
end;

procedure amqp_table.Assign(aobject: IAMQPObject);
var
  i: Integer;
  obj: IAMQPTable;
begin
  FTable.Clear;
  if Supports(aobject, IAMQPTable, Obj) then
    for i := 0 to Obj.Count - 1 do
      FTable.Add(Obj[i].clone);
end;

procedure amqp_table.Clear;
begin
  FTable.Clear;
end;

constructor amqp_table.Create;
begin
  inherited;
  FTable := TInterfaceList.Create;
end;

procedure amqp_table.Delete(Index: Integer);
begin
  FTable.Delete(index);
end;

destructor amqp_table.Destroy;
begin
  FTable.Free;
  inherited;
end;

procedure amqp_table.DoRead(AStream: TStream);
var
  len, k: amqp_long_uint;
  p: IAMQPFieldPair;
begin
  len := ReadLongUInt(AStream);
  k := 0;
  if len > 0 then
    repeat
      p := Add;
      p.Read(AStream);
      k := k + p.Size;
    until k >= len;
end;

procedure amqp_table.DoWrite(AStream: TStream);
var
  len: amqp_long_uint;
  i: Integer;
begin
  len := GetSize - sizeof(amqp_long_uint);
  WriteLongUInt(AStream, len);
  for i := 0 to Count - 1 do
    Items[i].Write(AStream);
end;

function amqp_table.FieldByName(AFieldName: AnsiString): IAMQPFieldPair;
var i: Integer;
begin
 Result := nil;
 i := IndexOfField(AFieldName);
 if i > -1 then
  Result := Items[i];
end;

function amqp_table.StringByName(AFieldName: AnsiString): AnsiString;
var fld: IAMQPFieldPair;
begin
  Result := '';
  fld := FieldByName(AFieldName);
  if fld <> nil then
    Result := fld.field_value.AsLongString;
end;

function amqp_table.IndexOfField(AFieldName: AnsiString): Integer;
var i: Integer;
begin
 Result := -1;
 for I := 0 to FTable.Count - 1 do
   if AFieldName = Items[i].field_name.val then
    begin
      result := i;
      Break;
    end;
end;

function amqp_table.IsFieldExist(AFieldName: AnsiString): Boolean;
begin
  Result := IndexOfField(AFieldName) > -1;
end;

function amqp_table.GetCount: Integer;
begin
  Result := FTable.Count;
end;

function amqp_table.GetItems(Index: Integer): IAMQPFieldPair;
begin
  Result := FTable[index] as IAMQPFieldPair;
end;

function amqp_table.GetSize: amqp_long_long_uint;
var
  i: Integer;
begin
  Result := sizeof(amqp_long_uint);
  for i := 0 to Count - 1 do
    Result := Result + Items[i].Size;
end;

function amqp_table.Add(aFieldName: AnsiString;
  AValue: amqp_short_int): IAMQPFieldPair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsShortInt := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString;
  AValue: amqp_long_uint): IAMQPFieldPair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsLongUInt := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString;
  AValue: amqp_long_int): IAMQPFieldPair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsLongInt := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString;
  AValue: amqp_short_short_uint): IAMQPFieldPair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsShortShortUInt := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString;
  AValue: amqp_short_short_int): IAMQPFieldPair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsShortShortInt := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString;
  AValue: amqp_short_uint): IAMQPFieldPair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsShortUInt := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString;
  AValue: amqp_long_long_uint): IAMQPFieldPair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsShortInt := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString; AValue: IAMQPTable): IAMQPFieldPair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsTable := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString; AValue: IAMQPArray): IAMQPFieldPair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsArray := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString; AScale: amqp_octet;
  AValue: amqp_long_uint): IAMQPFieldPair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsDecimalValue.scale := AScale;
 result.field_value.AsDecimalValue.Value := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString;
  AValue: amqp_long_long_int): IAMQPFieldPair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsLongLongUInt := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString;
  AValue: amqp_float): IAMQPFieldPair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsFloat := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString;
  AValue: amqp_double): IAMQPFieldPair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsDouble := AValue;
end;

{ amqp_frame }

constructor amqp_frame.CreateFromStream(AStream: TStream);
//var p: Int64;
begin
 fpayload := nil;
// p := AStream.Position;;
// with TFileStream.Create('1.dat', fmCreate) do
//  begin
//    CopyFrom(AStream, AStream.Size);
//    Free;
//  end;
// AStream.Position := p;
 Read(AStream);
end;

constructor amqp_frame.CreateFromString(const AValue: AnsiString);
begin
 fpayload := nil;
 SetAsString(AValue);
end;

destructor amqp_frame.Destroy;
begin
// if (fpayload <> nil) and (fpayload.GetRefCount > 1) then
// Writeln(fpayload.GetClassName, ':', fpayload.GetRefCount);

  fpayload := nil;

  inherited;
end;

procedure amqp_frame.DoRead(AStream: TStream);
//var pos, sz: Integer;
begin
//  Pos:= AStream.Position;
//  TMemoryStream(AStream).SaveToFile(formatdatetime('ddmmyyyyhhmmsszzz', now)+'.bin');
//  AStream.Position := Pos;
//  sz := AStream.Size;
  fframe_type := ReadOctet(AStream);
  if ((fframe_type > AMQP_FRAME_EMPTY) and (fframe_type <= AMQP_FRAME_HEARTBEAT)) then
   begin
    fchannel := ReadShortUInt(AStream);
    fsize := ReadLongUInt(AStream);
   end else
    fframe_type :=  AMQP_FRAME_EMPTY;
  case fframe_type of
    AMQP_FRAME_EMPTY:
     fpayload := amqp_empty_method.Create;
    AMQP_FRAME_METHOD:
      fpayload := amqp_container.Create;
    AMQP_FRAME_HEADER:
      begin
        fpayload := amqp_content_header.Create;
      end;
    AMQP_FRAME_BODY:
      fpayload := amqp_content_body.Create(fsize, nil);
    AMQP_FRAME_HEARTBEAT:
      fpayload := amqp_heartbeat.Create;
  end;
  if fpayload <> nil then
  begin
    fpayload.Read(AStream);
    fendofframe := ReadOctet(AStream);
  end
  else
  repeat
    fendofframe := ReadOctet(AStream);
  until (fendofframe = $ce) or (AStream.Position >= AStream.Size);
end;

procedure amqp_frame.DoWrite(AStream: TStream);
begin
  WriteOctet(AStream, fframe_type);
  WriteShortUInt(AStream, fchannel);
  if fpayload <> nil then
    fsize := fpayload.Size
  else
    fsize := 0;
  WriteLongUInt(AStream, fsize);
  if fpayload <> nil then
    fpayload.Write(AStream);
  WriteOctet(AStream, $CE);
end;

function amqp_frame.GetAsContentBody: IAMQPContentBody;
begin
 if not Supports(fpayload, IAMQPContentBody, Result) then
  Result := nil;
end;

function amqp_frame.GetAsContentHeader: IAMQPContentHeader;
begin
 if not Supports(fpayload, IAMQPContentHeader, Result) then
  Result := nil;
end;

function amqp_frame.GetAsHeartBeat: IAMQPHeartbeat;
begin
  if not Supports(fpayload, IAMQPHeartbeat, Result) then
   Result := nil;
end;

function amqp_frame.GetAsMethod: IAMQPMethod;
var Container: IAMQPContainer;
begin
  Result := nil;
  if Supports(fpayload, IAMQPContainer, Container) then
   Supports(Container.method, IAMQPMethod, Result);
end;

function amqp_frame.Getchannel: amqp_channel;
begin
  Result := fchannel;
end;

function amqp_frame.GetFrame_type: amqp_octet;
begin
 Result := fframe_type;
end;

function amqp_frame.Getpayload: IAMQPObject;
begin
 Result := fpayload;
end;

procedure amqp_frame.Setchannel(AValue: amqp_channel);
begin
 fchannel := AValue;
end;

procedure amqp_frame.SetPayload(AValue: IAMQPObject);
begin
  fpayload := AValue;
end;

procedure amqp_frame.Set_FrameType(AValue: amqp_octet);
begin
  fframe_type := AValue;
end;

function amqp_frame.GetAsContainer: IAMQPContainer;
begin
  if not (Supports(fpayload, IAMQPContainer, Result)) then
    Result := nil;
end;

function amqp_frame.GetSize: amqp_long_long_uint;
begin
  Result := 0;
  if fpayload <> nil then
    Result := Result + fpayload.Size;
end;

function amqp_frame.GetAsDebugString: String;
begin
  Result := 'Channel:' + fchannel.ToString+':'+ClassName;
  if fpayload <> nil then
    Result := Result + '.' + fpayload.AsDebugString;
end;

constructor amqp_frame.Create;
begin
  inherited;
end;

//function amqp_frame.QueryInterface(constref iid: tguid; out obj): longint;
//  cdecl;
//begin
//  Result := inherited QueryInterface(iid, obj);
//  if Result <> S_OK then
//    begin
//      if fpayload <> nil then
//        Result := fpayload.QueryInterface(iid, obj);
//    end;
//end;

{ amqp_method_start_ok }

class function amqp_method_start.class_id: amqp_short_uint;
begin
  Result := 10;
end;

constructor amqp_method_start.Create;
begin
  inherited;
  fproperties := amqp_table.Create;
  fmechanisms := amqp_long_str.Create;
  flocales := amqp_long_str.Create;
end;

destructor amqp_method_start.Destroy;
begin
  flocales := nil;
  fmechanisms := nil;
  fproperties := nil;
  inherited;
end;

procedure amqp_method_start.DoRead(AStream: TStream);
begin
  fversion_major := ReadOctet(AStream);
  fversion_minor := ReadOctet(AStream);
  fproperties.Read(AStream);
  fmechanisms.Read(AStream);
  flocales.Read(AStream)
end;

procedure amqp_method_start.DoWrite(AStream: TStream);
begin

end;

function amqp_method_start.Getlocales: AnsiString;
begin
 result := flocales.val;
end;

function amqp_method_start.Getmechanisms: AnsiString;
begin
 Result := fmechanisms.val;
end;

function amqp_method_start.GetProperties: IAMQPTable;
begin
  Result := fproperties;
end;

function amqp_method_start.Getversion_major: amqp_octet;
begin
  Result := fversion_major;
end;

function amqp_method_start.Getversion_minor: amqp_octet;
begin
 Result := fversion_minor;
end;

function amqp_method_start.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(fversion_major) + sizeof(fversion_minor) + fproperties.Size +
    fmechanisms.Size + flocales.Size;
end;

class function amqp_method_start.method_id: amqp_short_uint;
begin
  Result := 10;
end;

procedure amqp_method_start.SetLocales(const Value: AnsiString);
begin
 flocales.val := Value;
end;

procedure amqp_method_start.Setmechanisms(const Value: AnsiString);
begin
 fmechanisms.val := Value;
end;

{ amqp_method_start_ok }

class function amqp_method_start_ok.class_id: amqp_short_uint;
begin
  Result := 10;
end;

constructor amqp_method_start_ok.Create;
begin
  inherited;
  fproperties := amqp_table.Create;
  fmechanisms := amqp_short_str.Create(name+'.fmechanisms');
  fresponse := amqp_long_str.Create(name+'.fresponse');
  flocale := amqp_short_str.Create(name+'.flocale');
end;

class function amqp_method_start_ok.create_frame(achannel: amqp_short_uint;
  aproperties: amqp_table; amechanisms, aresponce,
  alocale: AnsiString): IAMQPFrame;
var
  f: IAMQPFieldPair;
begin
  Result := new_frame(achannel);

  with (Result.AsContainer.method as IAMQPMethodStartOk) do
  begin
    mechanisms := amechanisms;
    response := aresponce;
    locale := alocale;
    if aproperties <> nil then
    properties :=  aproperties;
    f := properties.Add;
    f.field_name.val := 'product';
    f.field_value.AsLongString := 'rabbitmq-pas';
    f := properties.Add;
    f.field_name.val := 'information';
    f.field_value.AsLongString := 'See http://www.esphere.ru';
  end;
end;

destructor amqp_method_start_ok.Destroy;
begin
  fproperties := nil;
  fmechanisms := nil;
  fresponse := nil;
  flocale := nil;
  inherited;
end;

procedure amqp_method_start_ok.DoRead(AStream: TStream);
begin

end;

procedure amqp_method_start_ok.DoWrite(AStream: TStream);
begin
  fproperties.Write(AStream);
  fmechanisms.Write(AStream);
  fresponse.Write(AStream);
  flocale.Write(AStream);
end;

function amqp_method_start_ok.Getlocale: AnsiString;
begin
 Result := flocale.val;
end;

function amqp_method_start_ok.Getmechanisms: AnsiString;
begin
 Result := fmechanisms.val;
end;

function amqp_method_start_ok.Getproperties: IAMQPTable;
begin
  Result := fproperties;
end;

function amqp_method_start_ok.Getresponse: AnsiString;
begin
 Result := fresponse.val;
end;

function amqp_method_start_ok.GetSize: amqp_long_long_uint;
begin
  Result := fmechanisms.Size + fproperties.Size + flocale.Size + fresponse.Size;
end;

class function amqp_method_start_ok.method_id: amqp_short_uint;
begin
  Result := 11;
end;

procedure amqp_method_start_ok.SetLocale(const Value: AnsiString);
begin
 flocale.val := Value;
end;

procedure amqp_method_start_ok.Setmechanisms(const Value: AnsiString);
begin
 fmechanisms.val := Value;
end;

procedure amqp_method_start_ok.Setproperties(AValue: IAMQPTable);
begin
  if AValue <> nil then
    fproperties.Assign(AValue)
  else
   fproperties.Clear;
end;

procedure amqp_method_start_ok.setResponse(const Value: AnsiString);
begin
 fresponse.val := Value;
end;

{ amqp_container }

constructor amqp_container.Create;
begin
  inherited;
  fmethod := nil;
end;

procedure amqp_container.CreateMethod;
var
  method_class: amqp_method_class;
begin
  DestroyMethod;
  method_class := amqp_method_factory(fclass_id, fmethod_id);
  if method_class <> nil then
    fmethod := method_class.Create
  else
    raise exception.Createfmt('unknown method (%d) or class (%d)',
      [fmethod_id, fclass_id]);
end;

function amqp_container.GetAsDebugString: String;
begin
  Result := ClassName;
  if fmethod <> nil then
    Result := Result + '.'+fmethod.AsDebugString;
end;

//function amqp_container.QueryInterface(constref iid: tguid; out obj): longint;
//  cdecl;
//begin
//  Result := inherited QueryInterface(iid, obj);
//  if Result <> S_OK then
//   begin
//     if fmethod <> nil then
//       Result := fmethod.QueryInterface(iid, obj);
//   end;
//end;

destructor amqp_container.Destroy;
begin
  if fmethod <> nil then
    fmethod := nil;
  inherited;
end;

procedure amqp_container.DestroyMethod;
begin
  fmethod := nil;
end;

procedure amqp_container.DoRead(AStream: TStream);
begin
  fclass_id := ReadShortUInt(AStream);
  fmethod_id := ReadShortUInt(AStream);
  CreateMethod;
  if fmethod <> nil then
    fmethod.Read(AStream);
end;

procedure amqp_container.DoWrite(AStream: TStream);
begin
  WriteShortUInt(AStream, fclass_id);
  WriteShortUInt(AStream, fmethod_id);
  if fmethod <> nil then
    fmethod.Write(AStream);
end;

function amqp_container.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(fclass_id) + sizeof(fmethod_id);
  if fmethod <> nil then
    Result := Result + fmethod.Size;
end;

procedure amqp_container.setclass_id(const Value: amqp_short_uint);
begin
  if Value <> fclass_id then
  begin
    DestroyMethod;
    fclass_id := Value;
  end;
end;

function amqp_container.Getmethod: IAMQPObject;
begin
  Result := fmethod;
end;

function amqp_container.Getclass_id: amqp_short_uint;
begin
  Result := fclass_id;
end;

function amqp_container.Getmethod_id: amqp_short_uint;
begin
 Result := fmethod_id;
end;

procedure amqp_container.setmethod_id(const Value: amqp_short_uint);
begin
  if Value <> fmethod_id then
  begin
    DestroyMethod;
    fmethod_id := Value;
    CreateMethod;
  end;
end;

{ amqp_method_secure }

class function amqp_method_secure.class_id: amqp_short_uint;
begin
  Result := 10;
end;

constructor amqp_method_secure.Create;
begin
  inherited;
  fchallenge := amqp_long_str.Create;
end;

destructor amqp_method_secure.Destroy;
begin
  fchallenge := nil;
  inherited;
end;

procedure amqp_method_secure.DoRead(AStream: TStream);
begin
  fchallenge.Read(AStream);
end;

procedure amqp_method_secure.DoWrite(AStream: TStream);
begin

end;

function amqp_method_secure.Getchallenge: AnsiString;
begin
 Result := fchallenge.val;
end;

function amqp_method_secure.GetSize: amqp_long_long_uint;
begin
  Result := fchallenge.Size;
end;

class function amqp_method_secure.method_id: amqp_short_uint;
begin
  Result := 20;
end;

procedure amqp_method_secure.SetChallenge(const Value: AnsiString);
begin
 fchallenge.val := Value;
end;

{ amqp_method_secure_ok }

class function amqp_method_secure_ok.class_id: amqp_short_uint;
begin
  Result := 10;
end;

constructor amqp_method_secure_ok.Create;
begin
  inherited;
  fresponse := amqp_long_str.Create;
end;

destructor amqp_method_secure_ok.Destroy;
begin
  fresponse := nil;
  inherited;
end;

procedure amqp_method_secure_ok.DoRead(AStream: TStream);
begin

end;

procedure amqp_method_secure_ok.DoWrite(AStream: TStream);
begin
  fresponse.Write(AStream);
end;

function amqp_method_secure_ok.Getresponse: AnsiString;
begin
 Result := fresponse.val;
end;

function amqp_method_secure_ok.GetSize: amqp_long_long_uint;
begin
  Result := fresponse.Size;
end;

class function amqp_method_secure_ok.method_id: amqp_short_uint;
begin
  Result := 21;
end;

procedure amqp_method_secure_ok.SetResponse(const Value: AnsiString);
begin
 fresponse.val := Value;
end;

{ amqp_custom_method }

constructor amqp_custom_method.Create;
begin
 inherited;
end;

class function amqp_custom_method.create_frame(achannel: amqp_short_uint)
  : IAMQPFrame;
begin
  Result := new_frame(achannel);
end;

function amqp_custom_method.GetOwner: IAMQPContainer;
begin
  Result := FOwner;
end;

class function amqp_custom_method.new_frame(achannel: amqp_short_uint)
  : IAMQPFrame;
var Obj: amqp_frame;
begin
  Obj := amqp_frame.Create;
  With Obj do
  begin
   frame_type := AMQP_FRAME_METHOD;
   channel := achannel;
   payload := amqp_container.Create;
   (payload as IAMQPContainer).class_id := class_id;
   (payload as IAMQPContainer).method_id := method_id;
  end;
  Result := Obj;
end;

function amqp_custom_method.GetClassId: amqp_short_uint;
begin
  Result := class_id;
end;

function amqp_custom_method.GetMethodId: amqp_short_uint;
begin
 Result := method_id;
end;

{ amqp_method_tune }

class function amqp_method_tune.class_id: amqp_short_uint;
begin
  Result := 10;
end;

procedure amqp_method_tune.DoRead(AStream: TStream);
begin
  fchannelMax := ReadShortUInt(AStream);
  fframeMax := ReadLongUInt(AStream);
  fheartBeat := ReadShortUInt(AStream)
end;

function amqp_method_tune.GetchannelMax: amqp_short_uint;
begin
  Result := fchannelMax;
end;

function amqp_method_tune.GetframeMax: amqp_long_uint;
begin
 Result := fframeMax;
end;

function amqp_method_tune.GetheartBeat: amqp_short_uint;
begin
 Result := fheartBeat;
end;

procedure amqp_method_tune.DoWrite(AStream: TStream);
begin
  WriteShortUInt(AStream, fchannelMax);
  WriteLongUInt(AStream, fframeMax);
  WriteShortUInt(AStream, fheartBeat);
end;

function amqp_method_tune.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(fchannelMax) + sizeof(fframeMax) + sizeof(fheartBeat);
end;

class function amqp_method_tune.method_id: amqp_short_uint;
begin
  Result := 30;
end;

{ amqp_method_tune_ok }

class function amqp_method_tune_ok.create_frame(achannel: amqp_short_uint;
  achannelMax: amqp_short_uint; aframeMax: amqp_long_uint;
  aheartBeat: amqp_short_uint): IAMQPFrame;
begin
  Result := new_frame(achannel);
  with (Result.AsContainer.method as IAMQPMethodTuneOk) do
  begin
    channelMax := achannelMax;
    frameMax := aframeMax;
    heartBeat := aheartBeat;
  end;
end;

procedure amqp_method_tune_ok.SetchannelMax(AValue: amqp_short_uint);
begin
  fchannelMax := AValue;
end;

procedure amqp_method_tune_ok.SetframeMax(AValue: amqp_long_uint);
begin
 fframeMax := AValue;
end;

procedure amqp_method_tune_ok.SetheartBeat(AValue: amqp_short_uint);
begin
 fheartBeat := AValue;
end;

class function amqp_method_tune_ok.method_id: amqp_short_uint;
begin
  Result := 31;
end;

{ amqp_method_open }

class function amqp_method_open.class_id: amqp_short_uint;
begin
  Result := 10;
end;

constructor amqp_method_open.Create;
begin
  inherited;
  fvirtualHost := amqp_short_str.Create(name+'.fvirtualHost');
  fCapabilites := amqp_short_str.Create(name+'.fCapabilites');
end;

class function amqp_method_open.create_frame(achannel: amqp_short_uint;
  aVirtualHost: AnsiString): IAMQPFrame;
begin
  Result := new_frame(achannel);
  with Result.AsContainer.method as IAMQPMethodOpen do
  begin
    virtualHost := aVirtualHost;
    Insist := True;
  end;
end;

destructor amqp_method_open.Destroy;
begin
  fvirtualHost := nil;
  fCapabilites := nil;
  inherited;
end;

procedure amqp_method_open.DoRead(AStream: TStream);
begin
  fvirtualHost.Read(AStream);
  fCapabilites.Read(AStream);
  fInsist := ReadBoolean(AStream);
end;

procedure amqp_method_open.DoWrite(AStream: TStream);
begin
  fvirtualHost.Write(AStream);
  fCapabilites.Write(AStream);
  WriteBoolean(AStream, fInsist);
end;

function amqp_method_open.GetCapabilites: AnsiString;
begin
 Result := fCapabilites.val;
end;

function amqp_method_open.GetSize: amqp_long_long_uint;
begin
  Result := fvirtualHost.Size + fCapabilites.Size + sizeof(fInsist);
end;

function amqp_method_open.GetvirtualHost: AnsiString;
begin
 result := fvirtualHost.val;
end;

function amqp_method_open.GetInsist: amqp_bit;
begin
  Result := fInsist;
end;

procedure amqp_method_open.SetInsist(AValue: amqp_bit);
begin
 fInsist := AValue;
end;

class function amqp_method_open.method_id: amqp_short_uint;
begin
  Result := 40;
end;

procedure amqp_method_open.SetCapabilites(const Value: AnsiString);
begin
 fCapabilites.val := Value;
end;

procedure amqp_method_open.SetvirtualHost(const Value: AnsiString);
begin
 fvirtualHost.val := Value;
end;

{ amqp_method_open_ok }

class function amqp_method_open_ok.class_id: amqp_short_uint;
begin
  Result := 10;
end;

constructor amqp_method_open_ok.Create;
begin
  inherited;
  fKnownHosts := amqp_short_str.Create(name+'.KnownHosts');
end;

destructor amqp_method_open_ok.Destroy;
begin
  fKnownHosts := nil;
  inherited;
end;

procedure amqp_method_open_ok.DoRead(AStream: TStream);
begin
  fKnownHosts.Read(AStream);
end;

procedure amqp_method_open_ok.DoWrite(AStream: TStream);
begin
  fKnownHosts.Write(AStream);
end;

function amqp_method_open_ok.getKnownHosts: AnsiString;
begin
 Result := fKnownHosts.val;
end;

function amqp_method_open_ok.GetSize: amqp_long_long_uint;
begin
  Result := fKnownHosts.Size;
end;

class function amqp_method_open_ok.method_id: amqp_short_uint;
begin
  Result := 41;
end;

procedure amqp_method_open_ok.setKnownHosts(const Value: AnsiString);
begin
 fKnownHosts.val := Value;
end;

{ amqp_method_close }

class function amqp_method_close.class_id: amqp_short_uint;
begin
  Result := 10;
end;

constructor amqp_method_close.Create;
begin
  inherited;
  fReplyText := amqp_short_str.Create(name+'.fReplyText');
end;

class function amqp_method_close.create_frame(achannel,
  aReplyCode: amqp_short_uint; aReplyText: AnsiString;
  aClassId, AMethodId: amqp_short_uint): IAMQPFrame;
begin
  Result := new_frame(achannel);
  with Result.AsContainer.method as IAMQPMethodClose do
  begin
    replyCode := aReplyCode;
    replyText := aReplyText;
    rclassid := aClassId;
    rmethodid := AMethodId;
  end;
end;

destructor amqp_method_close.Destroy;
begin
  fReplyText := nil;
  inherited;
end;

procedure amqp_method_close.DoRead(AStream: TStream);
begin
  fReplyCode := ReadShortUInt(AStream);
  fReplyText.Read(AStream);
  frclassid := ReadShortUInt(AStream);
  frmethodid := ReadShortUInt(AStream);
end;

procedure amqp_method_close.DoWrite(AStream: TStream);
begin
  WriteShortUInt(AStream, fReplyCode);
  fReplyText.Write(AStream);
  WriteShortUInt(AStream, frclassid);
  WriteShortUInt(AStream, frmethodid);
end;

function amqp_method_close.GetReplyText: AnsiString;
begin
 Result := fReplyText.val;
end;

function amqp_method_close.Getrclassid: amqp_short_uint;
begin
  Result := frclassid;
end;

function amqp_method_close.GetReplyCode: amqp_short_uint;
begin
 Result := fReplyCode;
end;

function amqp_method_close.Getrmethodid: amqp_short_uint;
begin
 Result := frmethodid;
end;

procedure amqp_method_close.Setrclassid(AValue: amqp_short_uint);
begin
  frclassid := AValue;
end;

procedure amqp_method_close.SetReplyCode(AValue: amqp_short_uint);
begin
 fReplyCode := AValue;
end;

function amqp_method_close.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(fReplyCode) + fReplyText.Size + sizeof(frclassid) +
    sizeof(frmethodid);
end;

function amqp_method_close.GetAsDebugString: String;
begin
  Result := inherited GetAsDebugString +':ReplyCode:'+fReplyCode.ToString+':ReplyText:'+fReplyText.val;
end;

class function amqp_method_close.method_id: amqp_short_uint;
begin
  Result := 50;
end;

procedure amqp_method_close.SetReplyText(const Value: AnsiString);
begin
 fReplyText.val := Value;
end;

procedure amqp_method_close.Setrmethodid(AValue: amqp_short_uint);
begin
  frmethodid := AValue;
end;

{ amqp_method_close_ok }

class function amqp_method_close_ok.class_id: amqp_short_uint;
begin
  Result := 10;
end;

class function amqp_method_close_ok.create_frame(achannel: amqp_short_uint)
  : IAMQPFrame;
begin
  Result := new_frame(achannel);
end;

procedure amqp_method_close_ok.DoRead(AStream: TStream);
begin

end;

procedure amqp_method_close_ok.DoWrite(AStream: TStream);
begin

end;

function amqp_method_close_ok.GetSize: amqp_long_long_uint;
begin
  Result := 0;
end;

class function amqp_method_close_ok.method_id: amqp_short_uint;
begin
  Result := 51;
end;

{ amqp_method_channel_open }

constructor amqp_method_channel_open.Create;
begin
  inherited;
  fOutOfBand := amqp_short_str.Create(name+'.fOutOfBand');
end;

class function amqp_method_channel_open.create_frame(achannel: amqp_short_uint; aoutofband: AnsiString): IAMQPFrame;
begin
 result := new_frame(achannel);
 with Result.AsContainer.method as IAMQPChannelOpen do
  outofband := aoutofband;
end;

destructor amqp_method_channel_open.Destroy;
begin
  fOutOfBand := nil;
  inherited;
end;

procedure amqp_method_channel_open.DoRead(AStream: TStream);
begin
  fOutOfBand.Read(AStream);
end;

procedure amqp_method_channel_open.DoWrite(AStream: TStream);
begin
  fOutOfBand.Write(AStream);
end;

function amqp_method_channel_open.GetOutOfBand: AnsiString;
begin
  result := fOutOfBand.val;
end;

function amqp_method_channel_open.GetSize: amqp_long_long_uint;
begin
  result := fOutOfBand.Size;
end;

class function amqp_method_channel_open.method_id: amqp_short_uint;
begin
  Result := 10;
end;

procedure amqp_method_channel_open.SetOutOfBand(const Value: AnsiString);
begin
 fOutOfBand.val := Value;
end;

{ amqp_method_channel_open_ok }

constructor amqp_method_channel_open_ok.Create;
begin
  inherited;
  FChannelId := amqp_long_str.Create;
end;

class function amqp_method_channel_open_ok.create_frame(achannel: amqp_short_uint; achannelid: AnsiString): IAMQPFrame;
begin
 result := new_frame(achannel);
 with Result.AsContainer.method as IAMQPChannelOpenOk do
  ChannelId := achannelid;
end;

destructor amqp_method_channel_open_ok.Destroy;
begin
  FChannelId := nil;
  inherited;
end;

procedure amqp_method_channel_open_ok.DoRead(AStream: TStream);
begin
  FChannelId.Read(AStream);
end;

procedure amqp_method_channel_open_ok.DoWrite(AStream: TStream);
begin
  FChannelId.Write(AStream);
end;

function amqp_method_channel_open_ok.getChannelId: AnsiString;
begin
 result := FChannelId.val;
end;

function amqp_method_channel_open_ok.GetSize: amqp_long_long_uint;
begin
  Result := FChannelId.Size;
end;

class function amqp_method_channel_open_ok.method_id: amqp_short_uint;
begin
  Result := 11;
end;

procedure amqp_method_channel_open_ok.SetChannelId(const Value: AnsiString);
begin
 FChannelId.val := Value;
end;

{ amqp_method_channel_class }

class function amqp_method_channel_class.class_id: amqp_short_uint;
begin
  Result := 20;
end;

class function amqp_method_channel_class.create_frame(achannel: amqp_short_uint)
  : IAMQPFrame;
begin
  Result := new_frame(achannel);
end;

function amqp_method_channel_class.GetSize: amqp_long_long_uint;
begin
  Result := 0;
end;

{ amqp_method_channel_flow }

class function amqp_method_channel_flow.create_frame(achannel: amqp_short_uint;
  aactive: amqp_bit): IAMQPFrame;
begin
  Result := new_frame(achannel);
  with Result.AsContainer.method as IAMQPMethodChannelFlow do
    active := aactive;
end;

procedure amqp_method_channel_flow.DoRead(AStream: TStream);
begin
  factive := ReadBoolean(AStream)
end;

function amqp_method_channel_flow.Getactive: amqp_boolean;
begin
  Result := factive;
end;

procedure amqp_method_channel_flow.Setactive(AValue: amqp_boolean);
begin
 factive := AValue;
end;

procedure amqp_method_channel_flow.DoWrite(AStream: TStream);
begin
  WriteBoolean(AStream, factive);
end;

function amqp_method_channel_flow.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(factive);
end;

class function amqp_method_channel_flow.method_id: amqp_short_uint;
begin
  Result := 20;
end;

{ amqp_method_channel_flow_ok }

class function amqp_method_channel_flow_ok.method_id: amqp_short_uint;
begin
  Result := 21;
end;

{ amqp_method_channel_close }

constructor amqp_method_channel_close.Create;
begin
  inherited;
  fReplyText := amqp_short_str.Create(name+'.fReplyText');
end;

class function amqp_method_channel_close.create_frame(achannel,
  aReplyCode: amqp_short_uint; aReplyText: AnsiString;
  aClassId, AMethodId: amqp_short_uint): IAMQPFrame;
begin
  Result := inherited create_frame(achannel);
  with Result.AsContainer.method as IAMQPChannelClose do
  begin
    replyCode := aReplyCode;
    replyText := aReplyText;
    rclassid := aClassId;
    rmethodid := AMethodId;
  end;
end;

destructor amqp_method_channel_close.Destroy;
begin
  fReplyText := nil;
  inherited;
end;

procedure amqp_method_channel_close.DoRead(AStream: TStream);
begin
  fReplyCode := ReadShortUInt(AStream);
  fReplyText.Read(AStream);
  frclassid := ReadShortUInt(AStream);
  frmethodid := ReadShortUInt(AStream);
end;

procedure amqp_method_channel_close.DoWrite(AStream: TStream);
begin
  WriteShortUInt(AStream, fReplyCode);
  fReplyText.Write(AStream);
  WriteShortUInt(AStream, frclassid);
  WriteShortUInt(AStream, frmethodid);
end;

function amqp_method_channel_close.GetReplyText: AnsiString;
begin
 result := fReplyText.val;
end;

function amqp_method_channel_close.Getrclassid: amqp_short_uint;
begin
  Result := frclassid;
end;

function amqp_method_channel_close.GetReplyCode: amqp_short_uint;
begin
  Result := fReplyCode;
end;

function amqp_method_channel_close.Getrmethodid: amqp_short_uint;
begin
 Result := frmethodid;
end;

procedure amqp_method_channel_close.Setrclassid(AValue: amqp_short_uint);
begin
 frclassid := AValue;
end;

procedure amqp_method_channel_close.SetReplyCode(AValue: amqp_short_uint);
begin
 fReplyCode := AValue;
end;

function amqp_method_channel_close.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(fReplyCode) + fReplyText.Size + sizeof(frclassid) +
    sizeof(frmethodid);
end;

class function amqp_method_channel_close.method_id: amqp_short_uint;
begin
  Result := 40;
end;

procedure amqp_method_channel_close.SetReplyText(const Value: AnsiString);
begin
 fReplyText.val := Value;
end;

procedure amqp_method_channel_close.Setrmethodid(AValue: amqp_short_uint);
begin
 frmethodid := AValue;
end;

{ amqp_method_channel_close_ok }

procedure amqp_method_channel_close_ok.DoWrite(AStream: TStream);
begin

end;

procedure amqp_method_channel_close_ok.DoRead(AStream: TStream);
begin

end;

class function amqp_method_channel_close_ok.method_id: amqp_short_uint;
begin
  Result := 41;
end;

{ amqp_method_exchange_class }

procedure amqp_method_exchange_class.DoWrite(AStream: TStream);
begin

end;

procedure amqp_method_exchange_class.DoRead(AStream: TStream);
begin

end;

function amqp_method_exchange_class.GetSize: amqp_long_long_uint;
begin
  Result := 0;
end;

class function amqp_method_exchange_class.class_id: amqp_short_uint;
begin
  Result := 40;
end;

{ amqp_method_exchange_declare }

constructor amqp_method_exchange_declare.Create;
begin
  inherited;
  Fexchange := amqp_exchange_name.Create;
  F_type := amqp_short_str.Create(name+'.type');
  Farguments := amqp_table.Create(name+'.arguments');
  FFlags := 0;
end;

class function amqp_method_exchange_declare.create_frame
  (achannel: amqp_short_uint; aexchange, atype: AnsiString;
  apassive, adurable, aauto_delete, ainternal, anowait: Boolean;
  aargs: IAMQPProperties): IAMQPFrame;
begin
  Result := new_frame(achannel);
  with Result.AsContainer.method as IAMQPMethodExchangeDeclare do
  begin
    exchange := aexchange;
    _type := atype;
    passive := apassive;
    durable := adurable;
    auto_delete := aauto_delete;
    internal := ainternal;
    nowait := anowait;
    arguments := aargs;
  end;
end;

destructor amqp_method_exchange_declare.Destroy;
begin
  Fexchange := nil;
  F_type := nil;
  Farguments := nil;
  inherited;
end;

procedure amqp_method_exchange_declare.DoRead(AStream: TStream);
begin
  inherited;
  Fexchange.Read(AStream);
  F_type.Read(AStream);
  FFlags := ReadOctet(AStream);
  Farguments.Read(AStream);
end;

procedure amqp_method_exchange_declare.DoWrite(AStream: TStream);
begin
  inherited;
  Fexchange.Write(AStream);
  F_type.Write(AStream);
  WriteOctet(AStream, FFlags);
  Farguments.Write(AStream);
end;

function amqp_method_exchange_declare.Getexchange: AnsiString;
begin
 Result := Fexchange.val;
end;

function amqp_method_exchange_declare.getFlag(const Index: Integer): amqp_bit;
begin
  case index of
    1:
      Result := (FFlags and 1) <> 0;
    2:
      Result := (FFlags and 2) <> 0;
    3:
      Result := (FFlags and 4) <> 0;
    4:
      Result := (FFlags and 8) <> 0;
    5:
      Result := (FFlags and 16) <> 0;
  end;
end;

procedure amqp_method_exchange_declare.Setarguments(AValue: IAMQPProperties);
begin
  if AValue <> nil then
    Farguments.Assign(AValue)
  else
   Farguments.Clear;
end;

function amqp_method_exchange_declare.Getarguments: IAMQPTable;
begin
  Result := Farguments;
end;

function amqp_method_exchange_declare.GetSize: amqp_long_long_uint;
begin
  Result := inherited GetSize + Fexchange.Size + F_type.Size + sizeof(FFlags) +
    Farguments.Size;
end;

function amqp_method_exchange_declare.Get_type: AnsiString;
begin
 Result := F_type.val;
end;

class function amqp_method_exchange_declare.method_id: amqp_short_uint;
begin
  Result := 10;
end;

procedure amqp_method_exchange_declare.Setexchange(const Value: AnsiString);
begin
 Fexchange.val := Value;
end;

procedure amqp_method_exchange_declare.SetFlag(const Index: Integer;
  const Value: amqp_bit);
begin
  FFlags := SetBit(FFlags, index - 1, Value);
end;

procedure amqp_method_exchange_declare.Set_type(const Value: AnsiString);
begin
 F_type.val := Value;
end;

{ amqp_method_exchange_declare_ok }

procedure amqp_method_exchange_declare_ok.DoRead(AStream: TStream);
begin
  fticket := Read2Octet(AStream);
end;

function amqp_method_exchange_declare_ok.Getticket: amqp_2octet;
begin
  Result := fticket;
end;

procedure amqp_method_exchange_declare_ok.Setticket(AValue: amqp_2octet);
begin
 fticket := AValue;
end;

procedure amqp_method_exchange_declare_ok.DoWrite(AStream: TStream);
begin
  Write2Octet(AStream, fticket);
end;

function amqp_method_exchange_declare_ok.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(fticket);
end;

class function amqp_method_exchange_declare_ok.method_id: amqp_short_uint;
begin
  Result := 11;
end;

{ amqp_method_exchange_delete_ok }

class function amqp_method_exchange_delete_ok.create_frame
  (achannel: amqp_short_uint): IAMQPFrame;
begin
  Result := new_frame(achannel);
end;

procedure amqp_method_exchange_delete_ok.DoRead(AStream: TStream);
begin

end;

procedure amqp_method_exchange_delete_ok.DoWrite(AStream: TStream);
begin

end;

function amqp_method_exchange_delete_ok.GetSize: amqp_long_long_uint;
begin
  Result := 0;
end;

class function amqp_method_exchange_delete_ok.method_id: amqp_short_uint;
begin
  Result := 21;
end;

{ amqp_method_exchange_delete }

constructor amqp_method_exchange_delete.Create;
begin
  inherited;
  Fexchange := amqp_exchange_name.Create;
  fFlag := 0;
end;

class function amqp_method_exchange_delete.create_frame
  (achannel: amqp_short_uint; aexchange: AnsiString;
  aifUnused, anowait: amqp_bit): IAMQPFrame;
begin
  Result := new_frame(achannel);
  with Result.AsContainer.method as IAMQPMethodExchangeDelete do
  begin
    exchange := aexchange;
    if_unused := aifUnused;
    no_wait := anowait;
  end;
end;

destructor amqp_method_exchange_delete.Destroy;
begin
  Fexchange := nil;
  inherited;
end;

procedure amqp_method_exchange_delete.DoRead(AStream: TStream);
begin
  inherited;
  fticket := Read2Octet(AStream);
  Fexchange.Read(AStream);
  fFlag := ReadOctet(AStream);
end;

procedure amqp_method_exchange_delete.DoWrite(AStream: TStream);
begin
  inherited;
  Write2Octet(AStream, fticket);
  Fexchange.Write(AStream);
  WriteOctet(AStream, fFlag);
end;

function amqp_method_exchange_delete.Getexchange: AnsiString;
begin
 result := Fexchange.val;
end;

function amqp_method_exchange_delete.getFlag(const Index: Integer): amqp_bit;
begin
  Result := GetBit(fFlag, index - 1)
end;

function amqp_method_exchange_delete.Getticket: amqp_short_uint;
begin
  Result := fticket;
end;

function amqp_method_exchange_delete.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(fticket) + Fexchange.Size + sizeof(fFlag);
end;

class function amqp_method_exchange_delete.method_id: amqp_short_uint;
begin
  Result := 20;
end;

procedure amqp_method_exchange_delete.Setexchange(const Value: AnsiString);
begin
 Fexchange.val := Value;
end;

procedure amqp_method_exchange_delete.Setticket(AValue: amqp_short_uint);
begin
  fticket := AValue;
end;

procedure amqp_method_exchange_delete.SetFlag(const Index: Integer;
  const Value: amqp_bit);
begin
  fFlag := SetBit(fFlag, index - 1, Value);
end;

{ amqp_method_queue_class }

class function amqp_method_queue_class.class_id: amqp_short_uint;
begin
  Result := 50;
end;

procedure amqp_method_queue_class.DoRead(AStream: TStream);
begin

end;

procedure amqp_method_queue_class.DoWrite(AStream: TStream);
begin

end;

function amqp_method_queue_class.GetSize: amqp_long_long_uint;
begin
  Result := 0;
end;

{ amqp_method_queue_declare }

constructor amqp_method_queue_declare.Create;
begin
  inherited;
  Fqueue := amqp_queue_name.Create;
  Farguments := amqp_peer_properties.Create;
  fFlag := 0;
  fticket := 0;
end;

class function amqp_method_queue_declare.create_frame(achannel,
  aticket: amqp_short_uint; aqueue: AnsiString; apassive, adurable, aexclusive,
  aautodelete, anowait: amqp_bit; aargs: IAMQPProperties): IAMQPFrame;
begin
  Result := new_frame(achannel);
  with Result.AsContainer.method as IAMQPMethodQueueDeclare do
  begin
    ticket := aticket;
    queue := aqueue;
    durable := adurable;
    exclusive := aexclusive;
    auto_delete := aautodelete;
    no_wait := anowait;
    arguments := aargs;
  end;
end;

destructor amqp_method_queue_declare.Destroy;
begin
  Fqueue := nil;
  Farguments := nil;
  inherited;
end;

procedure amqp_method_queue_declare.DoRead(AStream: TStream);
begin
  fticket := ReadShortUInt(AStream);
  Fqueue.Read(AStream);
  fFlag := ReadOctet(AStream);
  Farguments.Read(AStream);
end;

procedure amqp_method_queue_declare.DoWrite(AStream: TStream);
begin
  WriteShortUInt(AStream, fticket);
  Fqueue.Write(AStream);
  WriteOctet(AStream, fFlag);
  Farguments.Write(AStream);
end;

function amqp_method_queue_declare.getFlag(const Index: Integer): amqp_bit;
begin
  Result := GetBit(fFlag, index - 1);
end;

function amqp_method_queue_declare.Getarguments: IAMQPProperties;
begin
  Result := Farguments;
end;

function amqp_method_queue_declare.Getticket: amqp_short_uint;
begin
 Result := fticket;
end;

procedure amqp_method_queue_declare.Setarguments(AValue: IAMQPProperties);
begin
 if AValue <> nil then
   Farguments.Assign(AValue)
 else
   Farguments.Clear;
end;

function amqp_method_queue_declare.Getqueue: AnsiString;
begin
 Result := Fqueue.val;
end;

function amqp_method_queue_declare.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(fticket) + Fqueue.Size + sizeof(fFlag) + Farguments.Size;
end;

class function amqp_method_queue_declare.method_id: amqp_short_uint;
begin
  Result := 10;
end;

procedure amqp_method_queue_declare.SetFlag(const Index: Integer;
  const Value: amqp_bit);
begin
  fFlag := SetBit(fFlag, index - 1, Value);
end;

procedure amqp_method_queue_declare.Setqueue(const Value: AnsiString);
begin
 Fqueue.val := Value;
end;

procedure amqp_method_queue_declare.Setticket(AValue: amqp_short_uint);
begin
 fticket := AValue;
end;

{ amqp_method_queue_declare_ok }

constructor amqp_method_queue_declare_ok.Create;
begin
  inherited;
  Fqueue := amqp_queue_name.Create;
  Fconsumer_count := 0;
  Fmessage_count := 0;
end;

class function amqp_method_queue_declare_ok.create_frame
  (achannel: amqp_short_uint; aqueue: AnsiString;
  amessage_count: amqp_message_count; aconsumer_count: amqp_long_uint)
  : IAMQPFrame;
begin
  Result := new_frame(achannel);
  with Result.AsContainer.method as IAMQPMethodQueueDeclareOk do
  begin
    queue := aqueue;
    message_count := amessage_count;
    consumer_count := aconsumer_count;
  end;
end;

destructor amqp_method_queue_declare_ok.Destroy;
begin
  Fqueue := nil;
  inherited;
end;

procedure amqp_method_queue_declare_ok.DoRead(AStream: TStream);
begin
  Fqueue.Read(AStream);
  Fmessage_count := ReadLongUInt(AStream);
  Fconsumer_count := ReadLongUInt(AStream);
end;

procedure amqp_method_queue_declare_ok.DoWrite(AStream: TStream);
begin
  Fqueue.Write(AStream);
  WriteLongUInt(AStream, Fmessage_count);
  WriteLongUInt(AStream, Fconsumer_count);
end;

function amqp_method_queue_declare_ok.Getqueue: AnsiString;
begin
 Result := Fqueue.val;
end;

function amqp_method_queue_declare_ok.Getconsumer_count: amqp_long_uint;
begin
  Result := Fconsumer_count;
end;

function amqp_method_queue_declare_ok.Getmessage_count: amqp_message_count;
begin
 Result := Fmessage_count;
end;

procedure amqp_method_queue_declare_ok.Setconsumer_count(
  AValue: amqp_long_uint);
begin
 Fconsumer_count := AValue;
end;

procedure amqp_method_queue_declare_ok.Setmessage_count(
  AValue: amqp_message_count);
begin
 Fmessage_count := AValue;
end;

function amqp_method_queue_declare_ok.GetSize: amqp_long_long_uint;
begin
  Result := Fqueue.Size + sizeof(Fmessage_count) + sizeof(Fconsumer_count);
end;

class function amqp_method_queue_declare_ok.method_id: amqp_short_uint;
begin
  Result := 11;
end;

procedure amqp_method_queue_declare_ok.Setqueue(const Value: AnsiString);
begin
 Fqueue.val := Value;
end;

{ amqp_method_queue_bind }

constructor amqp_method_queue_bind.Create;
begin
  inherited;
  Fqueue := amqp_queue_name.Create;
  Fexchange := amqp_exchange_name.Create(name+'.Fexchange');
  FroutingKey := amqp_short_str.Create(name+'.FroutingKey');
  Farguments := amqp_peer_properties.Create(name+'.Farguments');
end;

class function amqp_method_queue_bind.create_frame(achannel: amqp_short_uint;
  aticket: amqp_short_uint; aqueue, aexchange, aroutingkey: AnsiString;
  anowait: amqp_boolean; aargs: IAMQPProperties): IAMQPFrame;
begin
  Result := new_frame(achannel);
  with Result.AsContainer.method as IAMQPQueueBind do
  begin
    ticket := aticket;
    queue := aqueue;
    exchange := aexchange;
    routingKey := aroutingkey;
    nowait := anowait;
    arguments := aargs;
  end;
end;

destructor amqp_method_queue_bind.Destroy;
begin
  Fqueue := nil;
  Fexchange := nil;
  FroutingKey := nil;
  Farguments := nil;
  inherited;
end;

procedure amqp_method_queue_bind.DoRead(AStream: TStream);
begin
  fticket := Read2Octet(AStream);
  Fqueue.Read(AStream);
  Fexchange.Read(AStream);
  FroutingKey.Read(AStream);
  Fnowait := ReadBoolean(AStream);
  Farguments.Read(AStream);
end;

procedure amqp_method_queue_bind.DoWrite(AStream: TStream);
begin
  Write2Octet(AStream, fticket);
  Fqueue.Write(AStream);
  Fexchange.Write(AStream);
  FroutingKey.Write(AStream);
  WriteBoolean(AStream, Fnowait);
  Farguments.Write(AStream);
end;

function amqp_method_queue_bind.Getexchange: AnsiString;
begin
 result := Fexchange.val;
end;

function amqp_method_queue_bind.Getarguments: IAMQPProperties;
begin
  Result := Farguments;
end;

function amqp_method_queue_bind.Getnowait: amqp_boolean;
begin
 Result := Fnowait;
end;

function amqp_method_queue_bind.Getqueue: AnsiString;
begin
 Result := Fqueue.val;
end;

function amqp_method_queue_bind.GetroutingKey: AnsiString;
begin
 Result := FroutingKey.val;
end;

function amqp_method_queue_bind.Getticket: amqp_short_uint;
begin
  Result := fticket;
end;

procedure amqp_method_queue_bind.Setarguments(AValue: IAMQPProperties);
begin
 if AValue <> nil then
   Farguments.Assign(AValue)
 else
  Farguments.Clear;
end;

function amqp_method_queue_bind.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(fticket) + Fqueue.Size + Fexchange.Size + FroutingKey.Size +
    sizeof(Fnowait) + Farguments.Size;
end;

class function amqp_method_queue_bind.method_id: amqp_short_uint;
begin
  Result := 20;
end;

procedure amqp_method_queue_bind.Setexchange(const Value: AnsiString);
begin
 Fexchange.val := Value;
end;

procedure amqp_method_queue_bind.Setnowait(AValue: amqp_boolean);
begin
 Fnowait := AValue;
end;

procedure amqp_method_queue_bind.Setqueue(const Value: AnsiString);
begin
 Fqueue.val := Value;
end;

procedure amqp_method_queue_bind.SetroutingKey(const Value: AnsiString);
begin
 FroutingKey.val := Value;
end;

procedure amqp_method_queue_bind.Setticket(AValue: amqp_short_uint);
begin
  fticket := AValue;
end;

{ amqp_method_queue_bind_ok }

class function amqp_method_queue_bind_ok.method_id: amqp_short_uint;
begin
  Result := 21;
end;

{ amqp_method_queue_unbind }

class function amqp_method_queue_unbind.create_frame(achannel: amqp_short_uint;
  aticket: amqp_short_uint; aqueue, aexchange, aroutingkey: AnsiString;
  aargs: IAMQPProperties): IAMQPFrame;
begin
  Result := new_frame(achannel);
  with Result.AsContainer.method as IAMQPMethodQueueUnBind do
  begin
    ticket := aticket;
    queue := aqueue;
    exchange := aexchange;
    routingKey := aroutingkey;
    arguments := aargs;
  end;
end;

procedure amqp_method_queue_unbind.DoRead(AStream: TStream);
begin
  fticket := Read2Octet(AStream);
  Fqueue.Read(AStream);
  Fexchange.Read(AStream);
  FroutingKey.Read(AStream);
  Farguments.Read(AStream);
end;

procedure amqp_method_queue_unbind.DoWrite(AStream: TStream);
begin
  Write2Octet(AStream, fticket);
  Fqueue.Write(AStream);
  Fexchange.Write(AStream);
  FroutingKey.Write(AStream);
  Farguments.Write(AStream);
end;

function amqp_method_queue_unbind.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(fticket) + Fqueue.Size + Fexchange.Size + FroutingKey.Size +
    Farguments.Size;
end;

class function amqp_method_queue_unbind.method_id: amqp_short_uint;
begin
  Result := 50;
end;

{ amqp_method_queue_unbind_ok }

class function amqp_method_queue_unbind_ok.method_id: amqp_short_uint;
begin
  Result := 51;
end;

{ amqp_method_queue_purge }

constructor amqp_method_queue_purge.Create;
begin
  inherited;
  Fqueue := amqp_queue_name.Create;
end;

class function amqp_method_queue_purge.create_frame(achannel: amqp_short_uint;
  aticket: amqp_short_uint; aqueue: AnsiString; anowait: amqp_boolean)
  : IAMQPFrame;
begin
  Result := new_frame(achannel);
  with Result.AsContainer.method as IAMQPQueuePurge do
  begin
    ticket := aticket;
    queue := aqueue;
    nowait := anowait;
  end;
end;

destructor amqp_method_queue_purge.Destroy;
begin
  Fqueue := nil;
  inherited;
end;

procedure amqp_method_queue_purge.DoRead(AStream: TStream);
begin
  fticket := ReadShortUInt(AStream);
  Fqueue.Read(AStream);
  Fnowait := ReadBoolean(AStream);
end;

procedure amqp_method_queue_purge.DoWrite(AStream: TStream);
begin
  WriteShortUInt(AStream, fticket);
  Fqueue.Write(AStream);
  WriteBoolean(AStream, Fnowait);
end;

function amqp_method_queue_purge.Getqueue: AnsiString;
begin
 Result := Fqueue.val;
end;

function amqp_method_queue_purge.Getnowait: amqp_boolean;
begin
  Result := Fnowait;
end;

function amqp_method_queue_purge.Getticket: amqp_short_uint;
begin
 Result := fticket;
end;

procedure amqp_method_queue_purge.Setnowait(AValue: amqp_boolean);
begin
 Fnowait := AValue;
end;

function amqp_method_queue_purge.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(fticket) + Fqueue.Size + sizeof(Fnowait)
end;

class function amqp_method_queue_purge.method_id: amqp_short_uint;
begin
  Result := 30;
end;

procedure amqp_method_queue_purge.Setqueue(const Value: AnsiString);
begin
 Fqueue.val := Value;
end;

procedure amqp_method_queue_purge.Setticket(AValue: amqp_short_uint);
begin
 fticket := AValue;
end;

{ amqp_method_queue_purge_ok }

class function amqp_method_queue_purge_ok.create_frame
  (achannel: amqp_short_uint; amessage_count: amqp_message_count): IAMQPFrame;
begin
  Result := new_frame(achannel);
  with Result.AsContainer.method as IAMQPQueuePurgeOk  do
    message_count := amessage_count;
end;

procedure amqp_method_queue_purge_ok.DoRead(AStream: TStream);
begin
  Fmessage_count := ReadLongUInt(AStream)
end;

function amqp_method_queue_purge_ok.Getmessage_count: amqp_message_count;
begin
  Result := Fmessage_count;
end;

procedure amqp_method_queue_purge_ok.Setmessage_count(
  AValue: amqp_message_count);
begin
 Fmessage_count := AValue;
end;

procedure amqp_method_queue_purge_ok.DoWrite(AStream: TStream);
begin
  WriteLongUInt(AStream, Fmessage_count);
end;

function amqp_method_queue_purge_ok.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(Fmessage_count);
end;

class function amqp_method_queue_purge_ok.method_id: amqp_short_uint;
begin
  Result := 31;
end;

{ amqp_method_queue_delete }

constructor amqp_method_queue_delete.Create;
begin
  inherited;
  Fqueue := amqp_queue_name.Create;
end;

class function amqp_method_queue_delete.create_frame(achannel,
  aticket: amqp_short_uint; aqueue: AnsiString;
  aifUnused, aIfEmpty, anowait: amqp_bit): IAMQPFrame;
begin
  Result := new_frame(achannel);
  with Result.AsContainer.method as IAMQPQueueDelete do
  begin
    ticket := aticket;
    queue := aqueue;
    ifUnused := aifUnused;
    ifempty := aIfEmpty;
    no_wait := anowait;
  end;
end;

destructor amqp_method_queue_delete.Destroy;
begin
  Fqueue := nil;
  inherited;
end;

procedure amqp_method_queue_delete.DoRead(AStream: TStream);
begin
  fticket := ReadShortUInt(AStream);
  Fqueue.Read(AStream);
  fFlag := ReadOctet(AStream)
end;

procedure amqp_method_queue_delete.DoWrite(AStream: TStream);
begin
  WriteShortUInt(AStream, fticket);
  Fqueue.Write(AStream);
  WriteOctet(AStream, fFlag);
end;

function amqp_method_queue_delete.getFlag(const Index: Integer): amqp_bit;
begin
  Result := GetBit(fFlag, index - 1)
end;

function amqp_method_queue_delete.Getticket: amqp_short_uint;
begin
  Result := fticket;
end;

function amqp_method_queue_delete.Getqueue: AnsiString;
begin
 Result := Fqueue.val;
end;

function amqp_method_queue_delete.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(fticket) + Fqueue.Size + sizeof(fFlag);
end;

class function amqp_method_queue_delete.method_id: amqp_short_uint;
begin
  Result := 40;
end;

procedure amqp_method_queue_delete.SetFlag(const Index: Integer;
  const Value: amqp_bit);
begin
  fFlag := SetBit(fFlag, index - 1, Value)
end;

procedure amqp_method_queue_delete.Setqueue(const Value: AnsiString);
begin
 Fqueue.val := Value;
end;

procedure amqp_method_queue_delete.Setticket(AValue: amqp_short_uint);
begin
  fticket := AValue;
end;

{ amqp_method_queue_delete_ok }

class function amqp_method_queue_delete_ok.method_id: amqp_short_uint;
begin
  Result := 41;
end;

{ amqp_method_basic_class }

class function amqp_method_basic_class.class_id: amqp_short_uint;
begin
  Result := 60;
end;

procedure amqp_method_basic_class.DoRead(AStream: TStream);
begin

end;

procedure amqp_method_basic_class.DoWrite(AStream: TStream);
begin

end;

function amqp_method_basic_class.GetSize: amqp_long_long_uint;
begin
  Result := 0;
end;

{ amqp_method_basic_qos }

class function amqp_method_basic_qos.create_frame(achannel: amqp_short_uint;
  aprefetchsize: amqp_long_uint; aprefetchcount: amqp_short_uint;
  aglobal: amqp_bit): IAMQPFrame;
begin
  Result := new_frame(achannel);
  with Result.AsContainer.method as IAMQPBasicQOS do
  begin
    prefetchsize := aprefetchsize;
    prefetchCount := aprefetchcount;
    global := aglobal;
  end;
end;

procedure amqp_method_basic_qos.DoRead(AStream: TStream);
begin
  Fprefetchsize := ReadLongUInt(AStream);
  FprefetchCount := ReadShortUInt(AStream);
  Fglobal := ReadBoolean(AStream);
end;

function amqp_method_basic_qos.Getglobal: amqp_bit;
begin
  Result := Fglobal;
end;

function amqp_method_basic_qos.GetprefetchCount: amqp_short_uint;
begin
 Result := FprefetchCount;
end;

function amqp_method_basic_qos.Getprefetchsize: amqp_long_uint;
begin
 Result := Fprefetchsize;
end;

procedure amqp_method_basic_qos.Setglobal(AValue: amqp_bit);
begin
 Fglobal := AValue;
end;

procedure amqp_method_basic_qos.SetprefetchCount(AValue: amqp_short_uint);
begin
 FprefetchCount := AValue;
end;

procedure amqp_method_basic_qos.Setprefetchsize(AValue: amqp_long_uint);
begin
 Fprefetchsize := AValue;
end;

procedure amqp_method_basic_qos.DoWrite(AStream: TStream);
begin
  WriteLongUInt(AStream, Fprefetchsize);
  WriteShortUInt(AStream, FprefetchCount);
  WriteBoolean(AStream, Fglobal);
end;

function amqp_method_basic_qos.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(Fprefetchsize) + sizeof(FprefetchCount) + sizeof(Fglobal);
end;

class function amqp_method_basic_qos.method_id: amqp_short_uint;
begin
  Result := 10;
end;

{ amqp_method_basic_qos_ok }

class function amqp_method_basic_qos_ok.method_id: amqp_short_uint;
begin
  Result := 11;
end;

{ amqp_method_basic_consume }

constructor amqp_method_basic_consume.Create;
begin
  inherited;
  Fqueue := amqp_queue_name.Create;
  Farguments := amqp_peer_properties.Create;
  fFlag := 0;
  fticket := 0;

end;

class function amqp_method_basic_consume.create_frame(achannel: amqp_short_uint;
  aticket: amqp_short_uint; aqueue, aconsumerTag: AnsiString;
  aNoLocal, aNoAck, aexclusive, anowait: amqp_bit; aargs: amqp_peer_properties)
  : IAMQPFrame;
begin
  Result := new_frame(achannel);
  with Result.AsContainer.method as IAMQPBasicConsume do
  begin
    ticket := aticket;
    queue := aqueue;
    consumerTag := aconsumerTag;
    noLocal := aNoLocal;
    noAck := aNoAck;
    nowait := anowait;
    exclusive := aexclusive;
    arguments := aargs;
  end;
end;

destructor amqp_method_basic_consume.Destroy;
begin
  Fqueue := nil;
  Farguments := nil;
  inherited;
end;

procedure amqp_method_basic_consume.DoRead(AStream: TStream);
begin
  fticket := ReadShortUInt(AStream);
  Fqueue.Read(AStream);
  inherited DoRead(AStream);
  fFlag := ReadOctet(AStream);
  Farguments.Read(AStream);
end;

procedure amqp_method_basic_consume.DoWrite(AStream: TStream);
begin
  WriteShortUInt(AStream, fticket);
  Fqueue.Write(AStream);
  inherited DoWrite(AStream);
  WriteOctet(AStream, fFlag);
  Farguments.Write(AStream);
end;

function amqp_method_basic_consume.getFlag(const Index: Integer): amqp_bit;
begin
  Result := GetBit(fFlag, index - 1);
end;

function amqp_method_basic_consume.Getarguments: IAMQPProperties;
begin
  Result := Farguments;
end;

function amqp_method_basic_consume.Getticket: amqp_short_uint;
begin
 Result := fticket;
end;

procedure amqp_method_basic_consume.Setarguments(AValue: IAMQPProperties);
begin
 if AValue <> nil then
  Farguments.Assign(AValue)
 else
  Farguments.Clear;
end;

function amqp_method_basic_consume.Getqueue: AnsiString;
begin
 Result := Fqueue.val;
end;

function amqp_method_basic_consume.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(fticket) + Fqueue.Size + inherited GetSize + sizeof(fFlag) +
    Farguments.Size;
end;

class function amqp_method_basic_consume.method_id: amqp_short_uint;
begin
  Result := 20;
end;

procedure amqp_method_basic_consume.SetFlag(const Index: Integer;
  const Value: amqp_bit);
begin
  fFlag := SetBit(fFlag, index - 1, Value);
end;

procedure amqp_method_basic_consume.Setqueue(const Value: AnsiString);
begin
 Fqueue.val := Value;
end;

procedure amqp_method_basic_consume.Setticket(AValue: amqp_short_uint);
begin
 fticket := AValue;
end;

{ amqp_method_basic_consume_ok }

constructor amqp_method_basic_consume_ok.Create;
begin
  inherited;
  FconsumerTag := amqp_short_str.Create(Name+'.FconsumerTag');
end;

class function amqp_method_basic_consume_ok.create_frame
  (achannel: amqp_short_uint; aconsumerTag: AnsiString): IAMQPFrame;
begin
  Result := new_frame(achannel);
  with Result.AsContainer.method as IAMQPBasicConsumeOk do
    consumerTag := aconsumerTag;
end;

destructor amqp_method_basic_consume_ok.Destroy;
begin
  FconsumerTag := nil;
  inherited;
end;

procedure amqp_method_basic_consume_ok.DoRead(AStream: TStream);
begin
  FconsumerTag.Read(AStream);
end;

procedure amqp_method_basic_consume_ok.DoWrite(AStream: TStream);
begin
  FconsumerTag.Write(AStream);
end;

function amqp_method_basic_consume_ok.GetconsumerTag: AnsiString;
begin
 Result := FconsumerTag.val
end;

function amqp_method_basic_consume_ok.GetSize: amqp_long_long_uint;
begin
  Result := FconsumerTag.Size;
end;

class function amqp_method_basic_consume_ok.method_id: amqp_short_uint;
begin
  Result := 21;
end;

procedure amqp_method_basic_consume_ok.SetconsumerTag(const Value: AnsiString);
begin
 FconsumerTag.val := Value;
end;

{ amqp_method_basic_cancel }

class function amqp_method_basic_cancel.create_frame(achannel: amqp_short_uint;
  aconsumerTag: AnsiString; anowait: amqp_bit): IAMQPFrame;
begin
  Result := new_frame(achannel);
  with Result.AsContainer.method as IAMQPBasicCancel do
  begin
    consumerTag := aconsumerTag;
    nowait := anowait;
  end;
end;

procedure amqp_method_basic_cancel.DoRead(AStream: TStream);
begin
  inherited;
  Fnowait := ReadBoolean(AStream);
end;

function amqp_method_basic_cancel.Getnowait: amqp_bit;
begin
  Result := Fnowait;
end;

procedure amqp_method_basic_cancel.Setnowait(AValue: amqp_bit);
begin
 Fnowait := AValue;
end;

procedure amqp_method_basic_cancel.DoWrite(AStream: TStream);
begin
  inherited;
  WriteBoolean(AStream, Fnowait);
end;

function amqp_method_basic_cancel.GetSize: amqp_long_long_uint;
begin
  Result := inherited GetSize + sizeof(Fnowait);
end;

class function amqp_method_basic_cancel.method_id: amqp_short_uint;
begin
  Result := 30;
end;

{ amqp_method_basic_cancel_ok }

class function amqp_method_basic_cancel_ok.method_id: amqp_short_uint;
begin
  Result := 31;
end;

{ amqp_method_basic_publish }

constructor amqp_method_basic_publish.Create;
begin
  inherited;
  fFlag := 0;
end;

class function amqp_method_basic_publish.create_frame(achannel,
  aticket: amqp_short_uint; aexchange, aroutingkey: AnsiString;
  aMandatory, aImmediate: amqp_bit): IAMQPFrame;
begin
  Result := new_frame(achannel);
  with Result.AsContainer.method as IAMQPBasicPublish do
  begin
    ticket := aticket;
    exchange := aexchange;
    routingKey := aroutingkey;
    mandatory := aMandatory;
    immediate := aImmediate;
  end;
end;

destructor amqp_method_basic_publish.Destroy;
begin
  inherited;
end;

procedure amqp_method_basic_publish.DoRead(AStream: TStream);
begin
  fticket := ReadShortUInt(AStream);
  inherited DoRead(AStream);
  fFlag := ReadOctet(AStream);
end;

procedure amqp_method_basic_publish.DoWrite(AStream: TStream);
begin
  WriteShortUInt(AStream, fticket);
  inherited DoWrite(AStream);
  WriteOctet(AStream, fFlag);
end;

function amqp_method_basic_publish.getFlag(const Index: Integer): amqp_bit;
begin
  Result := GetBit(fFlag, index - 1);
end;

function amqp_method_basic_publish.Getticket: amqp_short_uint;
begin
  Result := fticket;
end;

function amqp_method_basic_publish.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(fticket) + inherited GetSize + sizeof(fFlag);
end;

class function amqp_method_basic_publish.method_id: amqp_short_uint;
begin
  Result := 40;
end;

procedure amqp_method_basic_publish.SetFlag(const Index: Integer;
  const Value: amqp_bit);
begin
  fFlag := SetBit(fFlag, index - 1, Value);
end;

procedure amqp_method_basic_publish.Setticket(AValue: amqp_short_uint);
begin
 fticket := AValue;
end;

{ amqp_method_basic_custom_return }

constructor amqp_method_basic_custom_return.Create;
begin
  inherited;
  Fexchange := amqp_exchange_name.Create(name+'.Fexchange');
  FroutingKey := amqp_short_str.Create(name+'.FroutingKey');
end;

destructor amqp_method_basic_custom_return.Destroy;
begin
  Fexchange := nil;
  FroutingKey := nil;
  inherited;
end;

procedure amqp_method_basic_custom_return.DoRead(AStream: TStream);
begin
  Fexchange.Read(AStream);
  FroutingKey.Read(AStream);
end;

procedure amqp_method_basic_custom_return.DoWrite(AStream: TStream);
begin
  Fexchange.Write(AStream);
  FroutingKey.Write(AStream);
end;

function amqp_method_basic_custom_return.Getexchange: AnsiString;
begin
 Result := Fexchange.val;
end;

function amqp_method_basic_custom_return.GetroutingKey: AnsiString;
begin
 Result := FroutingKey.val;
end;

function amqp_method_basic_custom_return.GetSize: amqp_long_long_uint;
begin
  Result := Fexchange.Size + FroutingKey.Size;
end;

procedure amqp_method_basic_custom_return.Setexchange(const Value: AnsiString);
begin
 Fexchange.val := Value;
end;

procedure amqp_method_basic_custom_return.SetroutingKey(const Value: AnsiString);
begin
 FroutingKey.val := Value;
end;

{ amqp_method_basic_return }

constructor amqp_method_basic_return.Create;
begin
  inherited;
  fReplyText := amqp_reply_text.Create;
end;

class function amqp_method_basic_return.create_frame(achannel: amqp_short_uint;
  aReplyCode: amqp_reply_code; aReplyText, aexchange, aroutingkey: AnsiString)
  : IAMQPFrame;
begin
  Result := new_frame(achannel);
  with Result.AsContainer.method as IAMQPBasicReturn do
  begin
    ReplyCode := aReplyCode;
    ReplyText := aReplyText;
    exchange := aexchange;
    routingKey := aroutingkey;
  end;
end;

destructor amqp_method_basic_return.Destroy;
begin
  fReplyText := nil;
  inherited;
end;

procedure amqp_method_basic_return.DoRead(AStream: TStream);
begin
  fReplyCode := ReadShortUInt(AStream);
  fReplyText.Read(AStream);
  inherited;
end;

procedure amqp_method_basic_return.DoWrite(AStream: TStream);
begin
  WriteShortUInt(AStream, fReplyCode);
  fReplyText.Write(AStream);
  inherited;
end;

function amqp_method_basic_return.GetReplyText: AnsiString;
begin
 Result := fReplyText.val;
end;

function amqp_method_basic_return.GetReplyCode: amqp_reply_code;
begin
  Result := fReplyCode;
end;

procedure amqp_method_basic_return.SetReplyCode(AValue: amqp_reply_code);
begin
 fReplyCode := AValue;
end;

function amqp_method_basic_return.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(fReplyCode) + fReplyText.Size + inherited GetSize;
end;

class function amqp_method_basic_return.method_id: amqp_short_uint;
begin
  Result := 50;
end;

procedure amqp_method_basic_return.SetReplyText(const Value: AnsiString);
begin
 fReplyText.val := Value;
end;

{ amqp_method_basic_deliver }

constructor amqp_method_basic_deliver.Create;
begin
  inherited;
  FconsumerTag := amqp_short_str.Create(Name+'.FconsumerTag');
end;

class function amqp_method_basic_deliver.create_frame(achannel: amqp_short_uint;
  aconsumerTag: AnsiString; aDeliveryTag: amqp_delivery_tag;
  aRedelivered: amqp_redelivered; aexchange, aroutingkey: AnsiString)
  : IAMQPFrame;
begin
  Result := new_frame(achannel);
  with Result.AsContainer.method as IAMQPBasicDeliver do
  begin
    consumerTag := aconsumerTag;
    deliveryTag := aDeliveryTag;
    redelivered := aRedelivered;
    exchange := aexchange;
    routingKey := aroutingkey;
  end;
end;

destructor amqp_method_basic_deliver.Destroy;
begin
  FconsumerTag := nil;
  inherited;
end;

procedure amqp_method_basic_deliver.DoRead(AStream: TStream);
begin
  FconsumerTag.Read(AStream);
  FdeliveryTag := ReadLongLongUInt(AStream);
  Fredelivered := ReadBoolean(AStream);
  inherited;
end;

procedure amqp_method_basic_deliver.DoWrite(AStream: TStream);
begin
  FconsumerTag.Write(AStream);
  WriteLongLongUInt(AStream, FdeliveryTag);
  WriteBoolean(AStream, Fredelivered);
  inherited;
end;

function amqp_method_basic_deliver.GetconsumerTag: AnsiString;
begin
 Result := FconsumerTag.val;
end;

function amqp_method_basic_deliver.GetdeliveryTag: amqp_delivery_tag;
begin
  Result := FdeliveryTag;
end;

function amqp_method_basic_deliver.Getredelivered: amqp_redelivered;
begin
 Result := Fredelivered;
end;

function amqp_method_basic_deliver.GetSize: amqp_long_long_uint;
begin
  Result := FconsumerTag.Size + sizeof(FdeliveryTag) + sizeof(Fredelivered) +
    inherited GetSize;
end;

class function amqp_method_basic_deliver.method_id: amqp_short_uint;
begin
  Result := 60;
end;

procedure amqp_method_basic_deliver.SetconsumerTag(const Value: AnsiString);
begin
 FconsumerTag.val := Value;
end;

procedure amqp_method_basic_deliver.SetdeliveryTag(AValue: amqp_delivery_tag);
begin
 FdeliveryTag := AValue;
end;

procedure amqp_method_basic_deliver.Setredelivered(AValue: amqp_redelivered);
begin
 Fredelivered := AValue;
end;

{ amqp_content_header }

procedure amqp_content_header.Assign(aobject: IAMQPObject);
var Src: IAMQPContentHeader;
begin
 if Supports(aobject, IAMQPContentHeader, Src) then
  begin
    class_id := src.class_id;
    weight := src.weight;
    bodySize := src.bodySize;
    propFlags := src.propFlags;
    contentType := src.contentType;
    contentEncoding := src.contentEncoding;
    headers := src.headers;
    deliveryMode := src.deliveryMode;
    priority := src.priority;
    correlationId := src.correlationId;
    replyTo := src.replyTo;
    expiration := src.expiration;
    messageId := src.messageId;
    timestamp := src.timestamp;
    _type := src._type;
    userId := src.userId;
    appId := src.appId;
    clusterId := src.clusterId;

  end;
end;

function amqp_content_header.Clone: IAMQPContentHeader;
begin
 Result := amqp_content_header.Create;
 Result.Assign(Self);
end;

constructor amqp_content_header.Create;
begin
  inherited;
  Fheaders := amqp_table.Create(name+'.Fheaders');
  FcontentType := amqp_short_str.Create(name+'.FcontentType');
  FcontentEncoding := amqp_short_str.Create(name+'.FcontentEncoding');
  FcorrelationId := amqp_short_str.Create(name+'.FcorrelationId');
  FreplyTo := amqp_short_str.Create(name+'.FreplyTo');
  Fexpiration := amqp_short_str.Create(name+'.Fexpiration');
  FmessageId := amqp_short_str.Create(name+'.FmessageId');
  F_type := amqp_short_str.Create(name+'.f_type');
  FuserId := amqp_short_str.Create(name+'.fuserid');
  FappId := amqp_short_str.Create(name+'.fappid');
  FclusterId := amqp_short_str.Create(name+'.fcluster_id');
  FdeliveryMode := 1;
  FpropFlags := AMQP_BASIC_HEADERS_FLAG or AMQP_BASIC_DELIVERY_MODE_FLAG;
  Fweight := 0;
end;

class function amqp_content_header.create_frame(achannel: amqp_short_uint; abodySize: amqp_long_long_uint): amqp_frame;
var Obj: amqp_frame;
begin

 Obj := amqp_frame.Create;
 with Obj do
 begin
  frame_type := AMQP_FRAME_HEADER;
  channel := achannel;
  payload := amqp_content_header.Create;
  with payload as IAMQPContentHeader do
  begin
    class_id := amqp_method_basic_class.class_id;
    weight := 0;
    bodySize := abodySize;
  end;
 end;
 Result := Obj;
end;

destructor amqp_content_header.Destroy;
begin
  Fheaders := nil;
  FcontentType := nil;
  FcontentEncoding := nil;
  FcorrelationId := nil;
  FreplyTo := nil;
  Fexpiration := nil;
  FmessageId := nil;
  F_type := nil;
  FuserId := nil;
  FappId := nil;
  FclusterId := nil;
  inherited;
end;

procedure amqp_content_header.DoRead(AStream: TStream);
begin
  fclass_id := ReadShortUInt(AStream);
  Fweight := ReadShortUInt(AStream);
  FbodySize := ReadLongLongUInt(AStream);
  FpropFlags := ReadShortUInt(AStream);
  if (FpropFlags and AMQP_BASIC_CONTENT_TYPE_FLAG) > 0 then
    FcontentType.Read(AStream);
  if (FpropFlags and AMQP_BASIC_CONTENT_ENCODING_FLAG) > 0 then
    FcontentEncoding.Read(AStream);
  if (FpropFlags and AMQP_BASIC_HEADERS_FLAG) > 0 then
    Fheaders.Read(AStream);
  if (FpropFlags and AMQP_BASIC_DELIVERY_MODE_FLAG) > 0 then
    FdeliveryMode := ReadOctet(AStream);
  if (FpropFlags and AMQP_BASIC_PRIORITY_FLAG) > 0 then
    Fpriority := ReadOctet(AStream);
  if (FpropFlags and AMQP_BASIC_CORRELATION_ID_FLAG) > 0 then
    FcorrelationId.Read(AStream);
  if (FpropFlags and AMQP_BASIC_REPLY_TO_FLAG) > 0 then
    FreplyTo.Read(AStream);
  if (FpropFlags and AMQP_BASIC_EXPIRATION_FLAG) > 0 then
    Fexpiration.Read(AStream);
  if (FpropFlags and AMQP_BASIC_MESSAGE_ID_FLAG) > 0 then
    FmessageId.Read(AStream);
  if (FpropFlags and AMQP_BASIC_TIMESTAMP_FLAG) > 0 then
    Ftimestamp := ReadLongLongUInt(AStream);
  if (FpropFlags and AMQP_BASIC_TYPE_FLAG) > 0 then
    F_type.Read(AStream);
  if (FpropFlags and AMQP_BASIC_USER_ID_FLAG) > 0 then
    FuserId.Read(AStream);
  if (FpropFlags and AMQP_BASIC_APP_ID_FLAG) > 0 then
    FappId.Read(AStream);
  if (FpropFlags and AMQP_BASIC_CLUSTER_ID_FLAG) > 0 then
    FclusterId.Read(AStream);
end;

procedure amqp_content_header.DoWrite(AStream: TStream);
begin
  WriteShortUInt(AStream, fclass_id);
  WriteShortUInt(AStream, Fweight);
  WriteLongLongUInt(AStream, FbodySize);
  WriteShortUInt(AStream, FpropFlags);
  if (FpropFlags and AMQP_BASIC_CONTENT_TYPE_FLAG) > 0 then
    FcontentType.Write(AStream);
  if (FpropFlags and AMQP_BASIC_CONTENT_ENCODING_FLAG) > 0 then
    FcontentEncoding.Write(AStream);
  if (FpropFlags and AMQP_BASIC_HEADERS_FLAG) > 0 then
    Fheaders.Write(AStream);
  if (FpropFlags and AMQP_BASIC_DELIVERY_MODE_FLAG) > 0 then
    WriteOctet(AStream, FdeliveryMode);
  if (FpropFlags and AMQP_BASIC_PRIORITY_FLAG) > 0 then
    WriteOctet(AStream, Fpriority);
  if (FpropFlags and AMQP_BASIC_CORRELATION_ID_FLAG) > 0 then
    FcorrelationId.Write(AStream);
  if (FpropFlags and AMQP_BASIC_REPLY_TO_FLAG) > 0 then
    FreplyTo.Write(AStream);
  if (FpropFlags and AMQP_BASIC_EXPIRATION_FLAG) > 0 then
    Fexpiration.Write(AStream);
  if (FpropFlags and AMQP_BASIC_MESSAGE_ID_FLAG) > 0 then
    FmessageId.Write(AStream);
  if (FpropFlags and AMQP_BASIC_TIMESTAMP_FLAG) > 0 then
    WriteLongLongUInt(AStream, Ftimestamp);
  if (FpropFlags and AMQP_BASIC_TYPE_FLAG) > 0 then
    F_type.Write(AStream);
  if (FpropFlags and AMQP_BASIC_USER_ID_FLAG) > 0 then
    FuserId.Write(AStream);
  if (FpropFlags and AMQP_BASIC_APP_ID_FLAG) > 0 then
    FappId.Write(AStream);
  if (FpropFlags and AMQP_BASIC_CLUSTER_ID_FLAG) > 0 then
    FclusterId.Write(AStream);
end;

function amqp_content_header.GetappId: AnsiString;
begin
  Result := FappId.val;
end;

function amqp_content_header.GetbodySize: amqp_long_long_uint;
begin
  Result := FbodySize;
end;

function amqp_content_header.Getclass_id: amqp_short_uint;
begin
 Result := fclass_id;
end;

function amqp_content_header.GetclusterId: AnsiString;
begin
  Result := FclusterId.val;
end;

function amqp_content_header.GetcontentEncoding: AnsiString;
begin
  Result := FcontentEncoding.val;
end;

function amqp_content_header.GetcontentType: AnsiString;
begin
  Result := FcontentType.val;
end;

function amqp_content_header.GetcorrelationId: AnsiString;
begin
  Result := FcorrelationId.val;
end;

function amqp_content_header.GetdeliveryMode: amqp_delivery_mode;
begin
 Result := FdeliveryMode;
end;

function amqp_content_header.Getexpiration: AnsiString;
begin
  Result := Fexpiration.val;
end;

function amqp_content_header.Getheaders: IAMQPHeaders;
begin
 Result := Fheaders;
end;

function amqp_content_header.GetmessageId: AnsiString;
begin
  Result := FmessageId.val;
end;

function amqp_content_header.Getpriority: amqp_octet;
begin
 Result := Fpriority;
end;

function amqp_content_header.GetpropFlags: amqp_short_uint;
begin
 Result := FpropFlags;
end;

function amqp_content_header.GetreplyTo: AnsiString;
begin
  Result := FreplyTo.val;
end;

function amqp_content_header.Gettimestamp: amqp_timestamp;
begin
 Result := Ftimestamp;
end;

function amqp_content_header.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(fclass_id) + sizeof(Fweight) + sizeof(FbodySize) +
    sizeof(FpropFlags);
  if (FpropFlags and AMQP_BASIC_CONTENT_TYPE_FLAG) > 0 then
    Result := Result + FcontentType.Size;
  if (FpropFlags and AMQP_BASIC_CONTENT_ENCODING_FLAG) > 0 then
    Result := Result + FcontentEncoding.Size;
  if (FpropFlags and AMQP_BASIC_HEADERS_FLAG) > 0 then
    Result := Result + Fheaders.Size;
  if (FpropFlags and AMQP_BASIC_DELIVERY_MODE_FLAG) > 0 then
    Result := Result + sizeof(FdeliveryMode);
  if (FpropFlags and AMQP_BASIC_PRIORITY_FLAG) > 0 then
    Result := Result + sizeof(Fpriority);
  if (FpropFlags and AMQP_BASIC_CORRELATION_ID_FLAG) > 0 then
    Result := Result + FcorrelationId.Size;
  if (FpropFlags and AMQP_BASIC_REPLY_TO_FLAG) > 0 then
    Result := Result + FreplyTo.Size;
  if (FpropFlags and AMQP_BASIC_EXPIRATION_FLAG) > 0 then
    Result := Result + Fexpiration.Size;
  if (FpropFlags and AMQP_BASIC_MESSAGE_ID_FLAG) > 0 then
    Result := Result + FmessageId.Size;
  if (FpropFlags and AMQP_BASIC_TIMESTAMP_FLAG) > 0 then
    Result := Result + sizeof(Ftimestamp);
  if (FpropFlags and AMQP_BASIC_TYPE_FLAG) > 0 then
    Result := Result + F_type.Size;
  if (FpropFlags and AMQP_BASIC_USER_ID_FLAG) > 0 then
    Result := Result + FuserId.Size;
  if (FpropFlags and AMQP_BASIC_APP_ID_FLAG) > 0 then
    Result := Result + FappId.Size;
  if (FpropFlags and AMQP_BASIC_CLUSTER_ID_FLAG) > 0 then
    Result := Result + FclusterId.Size;
end;

function amqp_content_header.Gettype: AnsiString;
begin
  Result := F_type.val;
end;

function amqp_content_header.GetuserId: AnsiString;
begin
  Result := FuserId.val;
end;

function amqp_content_header.Getweight: amqp_short_uint;
begin
 Result := Fweight;
end;

procedure amqp_content_header.SetappId(const Value: AnsiString);
begin
  if Value <> '' then
    FpropFlags := FpropFlags or AMQP_BASIC_APP_ID_FLAG
  else
    FpropFlags := FpropFlags and (not AMQP_BASIC_APP_ID_FLAG);
  FappId.val := Value;
end;

procedure amqp_content_header.SetbodySize(AValue: amqp_long_long_uint);
begin
 FbodySize := AValue;
end;

procedure amqp_content_header.Setclass_id(AValue: amqp_short_uint);
begin
 fclass_id := AValue;
end;

procedure amqp_content_header.SetclusterId(const Value: AnsiString);
begin
  if Value <> '' then
    FpropFlags := FpropFlags or AMQP_BASIC_CLUSTER_ID_FLAG
  else
    FpropFlags := FpropFlags and (not AMQP_BASIC_CLUSTER_ID_FLAG);
  FclusterId.val := Value;
end;

procedure amqp_content_header.SetcontentEncoding(const Value: AnsiString);
begin
  if Value <> '' then
    FpropFlags := FpropFlags or AMQP_BASIC_CONTENT_ENCODING_FLAG
  else
    FpropFlags := FpropFlags and (not AMQP_BASIC_CONTENT_ENCODING_FLAG);
  FcontentEncoding.val := Value;
end;

procedure amqp_content_header.SetcontentType(const Value: AnsiString);
begin
  if Value <> '' then
    FpropFlags := FpropFlags or AMQP_BASIC_CONTENT_TYPE_FLAG
  else
    FpropFlags := FpropFlags and (not AMQP_BASIC_CONTENT_TYPE_FLAG);
  FcontentType.val := Value;
end;

procedure amqp_content_header.SetcorrelationId(const Value: AnsiString);
begin
  if Value <> '' then
    FpropFlags := FpropFlags or AMQP_BASIC_CORRELATION_ID_FLAG
  else
    FpropFlags := FpropFlags and (not AMQP_BASIC_CORRELATION_ID_FLAG);
  FcorrelationId.val := Value;
end;

procedure amqp_content_header.SetdeliveryMode(const Value: amqp_delivery_mode);
begin
  if Value <> 0 then
    FpropFlags := FpropFlags or AMQP_BASIC_DELIVERY_MODE_FLAG
  else
    FpropFlags := FpropFlags and (not AMQP_BASIC_DELIVERY_MODE_FLAG);
  FdeliveryMode := Value;
end;

procedure amqp_content_header.Setexpiration(const Value: AnsiString);
begin
  if Value <> '' then
    FpropFlags := FpropFlags or AMQP_BASIC_EXPIRATION_FLAG
  else
    FpropFlags := FpropFlags and (not AMQP_BASIC_EXPIRATION_FLAG);
  Fexpiration.val := Value;
end;

procedure amqp_content_header.SetHeaders(AValue: IAMQPHeaders);
begin
 if AValue <> nil then
   Fheaders.Assign(AValue)
 else
  Fheaders.Clear;
 if Fheaders.Count > 0 then
   FpropFlags := FpropFlags or AMQP_BASIC_HEADERS_FLAG
 else
   FpropFlags := FpropFlags and (not AMQP_BASIC_HEADERS_FLAG);
end;

procedure amqp_content_header.SetmessageId(const Value: AnsiString);
begin
  if Value <> '' then
    FpropFlags := FpropFlags or AMQP_BASIC_MESSAGE_ID_FLAG
  else
    FpropFlags := FpropFlags and (not AMQP_BASIC_MESSAGE_ID_FLAG);
  FmessageId.val := Value;
end;

procedure amqp_content_header.Setpriority(const Value: amqp_octet);
begin
  if Value <> 0 then
    FpropFlags := FpropFlags or AMQP_BASIC_PRIORITY_FLAG
  else
    FpropFlags := FpropFlags and (not AMQP_BASIC_PRIORITY_FLAG);
  Fpriority := Value;
end;

procedure amqp_content_header.SetpropFlags(AValue: amqp_short_uint);
begin
 FpropFlags := AValue;
end;

procedure amqp_content_header.SetreplyTo(const Value: AnsiString);
begin
  if Value <> '' then
    FpropFlags := FpropFlags or AMQP_BASIC_REPLY_TO_FLAG
  else
    FpropFlags := FpropFlags and (not AMQP_BASIC_REPLY_TO_FLAG);
  FreplyTo.val := Value;
end;

procedure amqp_content_header.Settimestamp(const Value: amqp_timestamp);
begin
  if Value <> 0 then
    FpropFlags := FpropFlags or AMQP_BASIC_TIMESTAMP_FLAG
  else
    FpropFlags := FpropFlags and (not AMQP_BASIC_TIMESTAMP_FLAG);
  Ftimestamp := Value;
end;

procedure amqp_content_header.SetType(const Value: AnsiString);
begin
  if Value <> '' then
    FpropFlags := FpropFlags or AMQP_BASIC_TYPE_FLAG
  else
    FpropFlags := FpropFlags and (not AMQP_BASIC_TYPE_FLAG);
  F_type.val := Value;
end;

procedure amqp_content_header.SetuserId(const Value: AnsiString);
begin
  if Value <> '' then
    FpropFlags := FpropFlags or AMQP_BASIC_USER_ID_FLAG
  else
    FpropFlags := FpropFlags and (not AMQP_BASIC_USER_ID_FLAG);
  FuserId.val := Value;
end;

procedure amqp_content_header.Setweight(AValue: amqp_short_uint);
begin
 Fweight := AValue;
end;

{ amqp_content_body }

constructor amqp_content_body.Create(aLen: amqp_long_uint;
  AData: Pointer);
begin
  inherited Create;
  flen := aLen;
  FData := AllocMem(flen);
  if AData <> nil then
    Move(AData^, FData^, alen);
end;

class function amqp_content_body.create_frame(achannel: amqp_short_uint; alen: amqp_long_uint;
  adata: Pointer): amqp_frame;
var Obj: amqp_frame;
begin
  Obj := amqp_frame.Create;
  with Obj do
   begin
    fframe_type := AMQP_FRAME_BODY;
    channel := achannel;
    fpayload := amqp_content_body.Create(alen, adata);
   end;
  Result := Obj;
end;

destructor amqp_content_body.Destroy;
begin
  FreeMem(FData);
  inherited;
end;

procedure amqp_content_body.DoRead(AStream: TStream);
begin
  AStream.Read(FData^, flen);
end;

function amqp_content_body.GetData: Pointer;
begin
  Result := FData;
end;

function amqp_content_body.Getlen: amqp_long_uint;
begin
 Result := flen;
end;

procedure amqp_content_body.DoWrite(AStream: TStream);
begin
  AStream.Write(FData^, flen);
end;

function amqp_content_body.GetSize: amqp_long_long_uint;
begin
  Result := flen;
end;

{ amqp_method_basic_get }

constructor amqp_method_basic_get.Create;
begin
 inherited;
 Fqueue := amqp_queue_name.Create;
end;

class function amqp_method_basic_get.create_frame(achannel, aticket: amqp_short_uint; aqueue: AnsiString;
  aNoAck: amqp_no_ack): IAMQPFrame;
begin
 Result := new_frame(achannel);
 with Result.AsContainer.method as IAMQPBasicGet do
  begin
    ticket := aticket;
    queue := aqueue;
    noAck := aNoAck;
  end;
end;

destructor amqp_method_basic_get.Destroy;
begin
  Fqueue := nil;
  inherited;
end;

procedure amqp_method_basic_get.DoRead(AStream: TStream);
begin
  Fticket := ReadShortUInt(AStream);
  Fqueue.Read(AStream);
  FnoAck := ReadBoolean(AStream);
end;

procedure amqp_method_basic_get.DoWrite(AStream: TStream);
begin
  WriteShortUInt(AStream, Fticket);
  Fqueue.Write(AStream);
  WriteBoolean(AStream, FnoAck);
end;

function amqp_method_basic_get.Getqueue: AnsiString;
begin
 Result := Fqueue.val;
end;

procedure amqp_method_basic_get.Setticket(AValue: amqp_short_uint);
begin
  Fticket := AValue;
end;

function amqp_method_basic_get.GetSize: amqp_long_long_uint;
begin
 Result := SizeOf(Fticket) + Fqueue.Size + SizeOf(FnoAck);
end;

class function amqp_method_basic_get.method_id: amqp_short_uint;
begin
 Result := 70;
end;

procedure amqp_method_basic_get.Setqueue(const Value: AnsiString);
begin
 Fqueue.val := Value;
end;

function amqp_method_basic_get.GetnoAck: amqp_no_ack;
begin
  Result := FnoAck;
end;

function amqp_method_basic_get.Getticket: amqp_short_uint;
begin
 Result := Fticket;
end;

procedure amqp_method_basic_get.SetnoAck(AValue: amqp_no_ack);
begin
 FnoAck := AValue;
end;

{ amqp_method_basic_get_ok }

constructor amqp_method_basic_get_ok.Create;
begin
  inherited;
 Fexchange := amqp_exchange_name.Create;
 FRoutingKey := amqp_short_str.Create;
end;

class function amqp_method_basic_get_ok.create_frame(achannel: amqp_short_uint; adeliveryTag: amqp_delivery_tag;
  aredelivered: amqp_redelivered; aexchange, aroutingKey: AnsiString; amessagecount: amqp_message_count): IAMQPFrame;
begin
 Result := new_frame(achannel);
 with Result.AsContainer.method as IAMQPBasicGetOk do
  begin
    deliveryTag := adeliveryTag;
    redelivered := aredelivered;
    exchange := aexchange;
    routingKey := aroutingKey;
    messageCount := amessagecount;
  end;
end;

destructor amqp_method_basic_get_ok.Destroy;
begin
 Fexchange := nil;
 FRoutingKey := nil;
 inherited;
end;

procedure amqp_method_basic_get_ok.DoRead(AStream: TStream);
begin
 FdeliveryTag := ReadLongLongUInt(AStream);
 Fredelivered := ReadBoolean(AStream);
 Fexchange.Read(AStream);
 FRoutingKey.Read(AStream);
 FmessageCount := ReadLongUInt(AStream)
end;

procedure amqp_method_basic_get_ok.DoWrite(AStream: TStream);
begin
 WriteLongLongUInt(AStream, FdeliveryTag);
 WriteBoolean(AStream, Fredelivered);
 Fexchange.Write(AStream);
 FRoutingKey.Write(AStream);
 WriteLongUInt(AStream, FmessageCount);
end;

function amqp_method_basic_get_ok.GetExchange: AnsiString;
begin
 Result := Fexchange.val;
end;

function amqp_method_basic_get_ok.GetdeliveryTag: amqp_delivery_tag;
begin
  Result := FdeliveryTag;
end;

function amqp_method_basic_get_ok.GetmessageCount: amqp_message_count;
begin
 Result := FmessageCount;
end;

function amqp_method_basic_get_ok.Getredelivered: amqp_redelivered;
begin
 Result := Fredelivered;
end;

procedure amqp_method_basic_get_ok.SetdeliveryTag(AValue: amqp_delivery_tag);
begin
 fdeliveryTag := AValue;
end;

function amqp_method_basic_get_ok.GetRoutingKey: AnsiString;
begin
 Result := FRoutingKey.val;
end;

procedure amqp_method_basic_get_ok.SetmessageCount(AValue: amqp_message_count);
begin
 FmessageCount := AValue;
end;

procedure amqp_method_basic_get_ok.Setredelivered(AValue: amqp_redelivered);
begin
 Fredelivered := AValue;
end;

function amqp_method_basic_get_ok.GetSize: amqp_long_long_uint;
begin
 Result := SizeOf(FdeliveryTag) +  sizeOf(Fredelivered) + Fexchange.Size + FRoutingKey.Size + SizeOf(FmessageCount);
end;

class function amqp_method_basic_get_ok.method_id: amqp_short_uint;
begin
 Result := 71;
end;

procedure amqp_method_basic_get_ok.SetExchange(const Value: AnsiString);
begin
 Fexchange.val := Value;
end;

procedure amqp_method_basic_get_ok.SetRoutingKey(const Value: AnsiString);
begin
 FRoutingKey.val := Value;
end;

{ amqp_method_basic_get_empty }

constructor amqp_method_basic_get_empty.Create;
begin
 inherited;
 fclusterid := amqp_short_str.Create;
end;

class function amqp_method_basic_get_empty.create_frame(achannel: amqp_short_uint; aclusterId: AnsiString): IAMQPFrame;
begin
 Result := new_frame(achannel);
 with Result.AsContainer.method as IAMQPBasicGetEmpty do
    clusterId := aclusterId;
end;

destructor amqp_method_basic_get_empty.Destroy;
begin
  fclusterid := nil;
  inherited;
end;

procedure amqp_method_basic_get_empty.DoRead(AStream: TStream);
begin
 fclusterid.Read(AStream);
end;

procedure amqp_method_basic_get_empty.DoWrite(AStream: TStream);
begin
 fclusterid.Write(AStream);
end;

function amqp_method_basic_get_empty.getClusterId: AnsiString;
begin
 Result := FClusterId.Val;
end;

function amqp_method_basic_get_empty.GetSize: amqp_long_long_uint;
begin
 result := fclusterid.Size;
end;

class function amqp_method_basic_get_empty.method_id: amqp_short_uint;
begin
 Result := 72;
end;

procedure amqp_method_basic_get_empty.setClusterId(const Value: AnsiString);
begin
 FClusterId.Val := Value;
end;

{ amqp_method_basic_ack }

class function amqp_method_basic_ack.create_frame(achannel: amqp_short_uint; adeliveryTag: amqp_delivery_tag;
  amultiple: amqp_bit): IAMQPFrame;
begin
 result := new_frame(achannel);
 with Result.AsContainer.method as IAMQPBasicAck do
  begin
    deliveryTag := adeliveryTag;
    mulitple := amultiple;
  end;
end;

procedure amqp_method_basic_ack.DoRead(AStream: TStream);
begin
  FdeliveryTag := ReadLongLongUInt(AStream);
  fFlag := ReadOctet(AStream);
end;

procedure amqp_method_basic_ack.DoWrite(AStream: TStream);
begin
 WriteLongLongUInt(AStream, FdeliveryTag);
 WriteOctet(AStream, fFlag);
end;

function amqp_method_basic_ack.GetdeliveryTag: amqp_delivery_tag;
begin
  Result := FdeliveryTag;
end;

procedure amqp_method_basic_ack.SetdeliveryTag(AValue: amqp_delivery_tag);
begin
 FdeliveryTag := AValue;
end;

function amqp_method_basic_ack.getFlag(const Index: Integer): amqp_bit;
begin
 Result := GetBit(fFlag, Index - 1);
end;

function amqp_method_basic_ack.GetSize: amqp_long_long_uint;
begin
 result := SizeOf(FdeliveryTag) + SizeOf(fFlag)
end;

class function amqp_method_basic_ack.method_id: amqp_short_uint;
begin
 Result := 80;
end;

procedure amqp_method_basic_ack.setFlag(const Index: Integer; const Value: amqp_bit);
begin
 fFlag := SetBit(fFlag, Index-1, Value);
end;

{ amqp_method_basic_reject }

class function amqp_method_basic_reject.method_id: amqp_short_uint;
begin
 Result := 90;
end;

{ amqp_method_basic_recover_async }

class function amqp_method_basic_recover_async.create_frame(achannel: amqp_short_uint; arequeue: amqp_bit): IAMQPFrame;
begin
 Result := new_frame(achannel);
 with Result.AsContainer.method as IAMQPBasicRecoverAsync do
  requeue := arequeue;
end;

procedure amqp_method_basic_recover_async.DoRead(AStream: TStream);
begin
 Frequeue := ReadBoolean(AStream);
end;

function amqp_method_basic_recover_async.Getrequeue: amqp_bit;
begin
  Result := Frequeue;
end;

procedure amqp_method_basic_recover_async.Setrequeue(AValue: amqp_bit);
begin
 Frequeue := AValue;
end;

procedure amqp_method_basic_recover_async.DoWrite(AStream: TStream);
begin
 WriteBoolean(AStream, Frequeue);
end;

function amqp_method_basic_recover_async.GetSize: amqp_long_long_uint;
begin
 Result := SizeOf(Frequeue);
end;

class function amqp_method_basic_recover_async.method_id: amqp_short_uint;
begin
 Result := 100;
end;

{ amqp_method_basic_recover }

class function amqp_method_basic_recover.method_id: amqp_short_uint;
begin
 Result := 110;
end;

{ amqp_method_basic_recover_ok }

class function amqp_method_basic_recover_ok.method_id: amqp_short_uint;
begin
 Result := 111;
end;

{ amqp_method_basic_nack }

class function amqp_method_basic_nack.create_frame(achannel: amqp_short_uint; adeliveryTag: amqp_delivery_tag;
  amultiple, arequeue: amqp_bit): IAMQPFrame;
begin
 result := new_frame(achannel);
 with Result.AsContainer.method as IAMQPBasicNAck do
  begin
    deliveryTag := adeliveryTag;
    mulitple := amultiple;
    requeue := arequeue;
  end;
end;

function amqp_method_basic_nack.getFlag(const Index: Integer): amqp_bit;
begin
 result := inherited getFlag(Index);
end;

class function amqp_method_basic_nack.method_id: amqp_short_uint;
begin
 Result := 120;
end;

procedure amqp_method_basic_nack.setFlag(const Index: Integer; const Value: amqp_bit);
begin
 inherited setFlag(Index, Value);
end;

{ amqp_method_tx_class }

class function amqp_method_tx_class.class_id: amqp_short_uint;
begin
 Result := 90;
end;

procedure amqp_method_tx_class.DoRead(AStream: TStream);
begin

end;

procedure amqp_method_tx_class.DoWrite(AStream: TStream);
begin

end;

function amqp_method_tx_class.GetSize: amqp_long_long_uint;
begin
 result := 0;
end;

{ amqp_method_tx_select }

class function amqp_method_tx_select.method_id: amqp_short_uint;
begin
 Result := 10;
end;

{ amqp_method_tx_select_ok }

class function amqp_method_tx_select_ok.method_id: amqp_short_uint;
begin
 Result := 11;
end;

{ amqp_method_tx_commit }

class function amqp_method_tx_commit.method_id: amqp_short_uint;
begin
 Result := 20;
end;

{ amqp_method_tx_commit_ok }

class function amqp_method_tx_commit_ok.method_id: amqp_short_uint;
begin
 Result := 21;
end;

{ amqp_method_tx_rollback }

class function amqp_method_tx_rollback.method_id: amqp_short_uint;
begin
 Result := 30;
end;

{ amqp_method_tx_rollback_ok }

class function amqp_method_tx_rollback_ok.method_id: amqp_short_uint;
begin
 Result := 31;
end;

{ amqp_heartbeat }

class function amqp_heartbeat.create_frame(achannel: amqp_short_uint): amqp_frame;
var Obj: amqp_frame;
begin
 obj := amqp_frame.Create;
 with Obj do
  begin
       fframe_type := AMQP_FRAME_HEARTBEAT;
       fchannel := achannel;
       fpayload := amqp_heartbeat.Create;
  end;
 Result := Obj;
end;

procedure amqp_heartbeat.DoRead(AStream: TStream);
begin

end;

procedure amqp_heartbeat.DoWrite(AStream: TStream);
begin

end;

function amqp_heartbeat.GetSize: amqp_long_long_uint;
begin
 result := 0;
end;

{ amqp_empty_method }

class function amqp_empty_method.class_id: amqp_short_uint;
begin
 Result := 0;
end;

procedure amqp_empty_method.DoRead(AStream: TStream);
begin

end;

class function amqp_empty_method.method_id: amqp_short_uint;
begin
 Result := 0;
end;

function new_amqp_protocol(AProtocolIdMajor, AProtocolIdMinor, AVersionMajor,
  AVersionMinor: amqp_octet): amqp_protocol_header;
begin
  with result do
  begin
    sign := AMQP_SIGN;
    protocolmajor := AProtocolIdMajor;
    protocolminor := AProtocolIdMinor;
    versionmajor := AVersionMajor;
    versionminor := AVersionMinor;
  end;
end;


initialization

register_amqp_method(amqp_method_start);
register_amqp_method(amqp_method_start_ok);
register_amqp_method(amqp_method_secure);
register_amqp_method(amqp_method_secure_ok);
register_amqp_method(amqp_method_tune);
register_amqp_method(amqp_method_tune_ok);
register_amqp_method(amqp_method_open);
register_amqp_method(amqp_method_open_ok);
register_amqp_method(amqp_method_close);
register_amqp_method(amqp_method_close_ok);
register_amqp_method(amqp_method_channel_open);
register_amqp_method(amqp_method_channel_open_ok);
register_amqp_method(amqp_method_channel_flow);
register_amqp_method(amqp_method_channel_flow_ok);
register_amqp_method(amqp_method_channel_close);
register_amqp_method(amqp_method_channel_close_ok);
register_amqp_method(amqp_method_exchange_declare_ok);
register_amqp_method(amqp_method_exchange_declare);
register_amqp_method(amqp_method_exchange_delete_ok);
register_amqp_method(amqp_method_exchange_delete);
register_amqp_method(amqp_method_exchange_bind);
register_amqp_method(amqp_method_exchange_bind_ok);
register_amqp_method(amqp_method_exchange_unbind);
register_amqp_method(amqp_method_exchange_unbind_ok);
register_amqp_method(amqp_method_queue_declare);
register_amqp_method(amqp_method_queue_declare_ok);
register_amqp_method(amqp_method_queue_bind);
register_amqp_method(amqp_method_queue_bind_ok);
register_amqp_method(amqp_method_queue_unbind);
register_amqp_method(amqp_method_queue_unbind_ok);
register_amqp_method(amqp_method_queue_purge);
register_amqp_method(amqp_method_queue_purge_ok);
register_amqp_method(amqp_method_queue_delete);
register_amqp_method(amqp_method_queue_delete_ok);
register_amqp_method(amqp_method_basic_qos);
register_amqp_method(amqp_method_basic_qos_ok);
register_amqp_method(amqp_method_basic_consume);
register_amqp_method(amqp_method_basic_consume_ok);
register_amqp_method(amqp_method_basic_cancel);
register_amqp_method(amqp_method_basic_cancel_ok);
register_amqp_method(amqp_method_basic_publish);
register_amqp_method(amqp_method_basic_return);
register_amqp_method(amqp_method_basic_deliver);
register_amqp_method(amqp_method_basic_get);
register_amqp_method(amqp_method_basic_get_ok);
register_amqp_method(amqp_method_basic_get_empty);
register_amqp_method(amqp_method_basic_ack);
register_amqp_method(amqp_method_basic_reject);
register_amqp_method(amqp_method_basic_recover_async);
register_amqp_method(amqp_method_basic_recover);
register_amqp_method(amqp_method_basic_recover_ok);
register_amqp_method(amqp_method_basic_nack);
register_amqp_method(amqp_method_tx_select);
register_amqp_method(amqp_method_tx_select_ok);
register_amqp_method(amqp_method_tx_commit);
register_amqp_method(amqp_method_tx_commit_ok);
register_amqp_method(amqp_method_tx_rollback);
register_amqp_method(amqp_method_tx_rollback_ok);
register_amqp_method(amqp_method_confirm_select);
register_amqp_method(amqp_method_confirm_select_ok);
register_amqp_method(amqp_empty_method);

finalization

if famqp_method_factory <> nil then
 begin
  famqp_method_factory.Clear;
  FreeAndNil(famqp_method_factory);
 end;

if FDebugList <> nil then
 FreeAndNil(FDebugList);
end.
