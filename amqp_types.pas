unit amqp_types;

interface

uses classes, contnrs;

const
  AMQP_FRAME_EMPTY = 0;
  AMQP_FRAME_METHOD = 1;
  AMQP_FRAME_HEADER = 2;
  AMQP_FRAME_BODY = 3;
  AMQP_FRAME_HEARTBEAT = 8;

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

  amqp_object = class
  private
    function GetAsString: AnsiString;
    procedure SetAsString(const Value: AnsiString);
  protected
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
  public
    constructor Create; virtual;
    procedure Assign(aobject: amqp_object); virtual; abstract;
    procedure Write(AStream: TStream);
    procedure Read(AStream: TStream);
    property Size: amqp_long_long_uint read GetSize;
    property AsString: AnsiString read GetAsString write SetAsString;
  end;

  amqp_decumal = class(amqp_object)
  private
    Fvalue: amqp_long_uint;
    Fscale: amqp_octet;
    procedure Setscale(const Value: amqp_octet);
    procedure Setvalue(const Value: amqp_long_uint);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: amqp_object); override;
    property scale: amqp_octet read Fscale write Setscale;
    property Value: amqp_long_uint read Fvalue write Setvalue;
  end;

  amqp_short_str = class(amqp_object)
  private
    fval: AnsiString;
    flen: amqp_short_short_uint;
    procedure setval(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: amqp_object); override;
    property len: amqp_short_short_uint read flen;
    property val: AnsiString read fval write setval;
  end;

  amqp_exchange_name = amqp_short_str;
  amqp_consumer_tag = amqp_short_str;
  amqp_delivery_tag = amqp_long_long_uint;
  amqp_message_count = amqp_long_uint;
  amqp_method_id = amqp_short_uint;
  amqp_no_ack = amqp_bit;
  amqp_no_local = amqp_bit;
  amqp_no_wait = amqp_bit;
  amqp_path = amqp_short_str;

  amqp_long_str = class(amqp_object)
  private
    fval: AnsiString;
    flen: amqp_long_uint;
    procedure setval(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: amqp_object); override;
    property len: amqp_long_uint read flen;
    property val: AnsiString read fval write setval;
  end;

  amqp_field_array = class;
  amqp_table = class;

  amqp_field_value = class(amqp_object)
  private
    fkind: amqp_string_char;
    fval: amqp_object;
    function GetAsShortString: AnsiString;
    procedure SetAsShortString(const Value: AnsiString);
    function GetAsLongString: AnsiString;
    procedure SetAsLongString(const Value: AnsiString);
    function GetAsBoolean: Boolean;
    procedure SetAsBoolean(const Value: Boolean);
    procedure DestroyVal;
    function GetAsDecimal: amqp_decumal;
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
    function GetAsArray: amqp_field_array;
    function GetAsTable: amqp_table;
    procedure setKind(const Value: amqp_string_char);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
    function CreateVal: amqp_object;
  public
    constructor Create;
    destructor Destroy; override;
    property kind: amqp_string_char read fkind write setKind;
    property val: amqp_object read fval;
    procedure Assign(aobject: amqp_object); override;
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
    property AsDecimalValue: amqp_decumal read GetAsDecimal;
    property AsShortString: AnsiString read GetAsShortString
      write SetAsShortString;
    property AsLongString: AnsiString read GetAsLongString
      write SetAsLongString;
    property AsArray: amqp_field_array read GetAsArray;
    property AsTable: amqp_table read GetAsTable;
    function Clone: amqp_field_value;
  end;

  amqp_field_boolean = class(amqp_object)
  private
    Fvalue: Boolean;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: amqp_object); override;
    property Value: Boolean read Fvalue write Fvalue;
  end;

  amqp_field_short_short_uint = class(amqp_object)
  private
    Fvalue: amqp_short_short_uint;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: amqp_object); override;
    property Value: amqp_short_short_uint read Fvalue write Fvalue;
  end;

  amqp_field_short_short_int = class(amqp_object)
  private
    Fvalue: amqp_short_short_int;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: amqp_object); override;
    property Value: amqp_short_short_int read Fvalue write Fvalue;
  end;

  amqp_field_short_int = class(amqp_object)
  private
    Fvalue: amqp_short_int;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: amqp_object); override;
    property Value: amqp_short_int read Fvalue write Fvalue;
  end;

  amqp_field_short_uint = class(amqp_object)
  private
    Fvalue: amqp_short_uint;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: amqp_object); override;
    property Value: amqp_short_uint read Fvalue write Fvalue;
  end;

  amqp_field_long_uint = class(amqp_object)
  private
    Fvalue: amqp_long_uint;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: amqp_object); override;
    property Value: amqp_long_uint read Fvalue write Fvalue;
  end;

  amqp_field_long_int = class(amqp_object)
  private
    Fvalue: amqp_long_int;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: amqp_object); override;
    property Value: amqp_long_int read Fvalue write Fvalue;
  end;

  amqp_field_long_long_uint = class(amqp_object)
  private
    Fvalue: amqp_long_long_uint;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: amqp_object); override;
    property Value: amqp_long_long_uint read Fvalue write Fvalue;
  end;

  amqp_field_long_long_int = class(amqp_object)
  private
    Fvalue: amqp_long_long_int;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: amqp_object); override;
    property Value: amqp_long_long_int read Fvalue write Fvalue;
  end;

  amqp_field_float = class(amqp_object)
  private
    Fvalue: amqp_float;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: amqp_object); override;
    property Value: amqp_float read Fvalue write Fvalue;
  end;

  amqp_field_double = class(amqp_object)
  private
    Fvalue: amqp_double;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    procedure Assign(aobject: amqp_object); override;
    property Value: amqp_double read Fvalue write Fvalue;
  end;

  amqp_field_timestamp = class(amqp_field_long_uint);

  amqp_field_pair = class(amqp_object)
  private
    ffield_name: amqp_short_str;
    ffield_value: amqp_field_value;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create;
    destructor Destroy; override;
    property field_name: amqp_short_str read ffield_name;
    property field_value: amqp_field_value read ffield_value;
    function clone: amqp_field_pair;
    procedure Assign(aobject: amqp_object); override;
  end;

  amqp_field_array = class(amqp_object)
  private
    FArray: TObjectList;
    function GetCount: Integer;
    function GetItems(Index: Integer): amqp_field_value;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(AObject: amqp_object); override;
    property Items[index: Integer]: amqp_field_value read GetItems; default;
    property Count: Integer read GetCount;
    function Add: amqp_field_value;
    procedure Delete(Index: Integer);
    procedure Clear;
  end;

  amqp_table = class(amqp_object)
  private
    FTable: TObjectList;
    function GetCount: Integer;
    function GetItems(Index: Integer): amqp_field_pair;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(aobject: amqp_object); override;
    property Items[index: Integer]: amqp_field_pair read GetItems; default;
    function FieldByName(AFieldName: AnsiString): amqp_field_pair;
    property Count: Integer read GetCount;
    function Add: amqp_field_pair; overload;
    function Add(aFieldName: AnsiString; AValue: AnsiString): amqp_field_pair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_boolean): amqp_field_pair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_short_short_uint): amqp_field_pair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_short_short_int): amqp_field_pair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_short_uint): amqp_field_pair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_short_int): amqp_field_pair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_long_uint): amqp_field_pair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_long_int): amqp_field_pair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_long_long_uint): amqp_field_pair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_long_long_int): amqp_field_pair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_float): amqp_field_pair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_double): amqp_field_pair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_table): amqp_field_pair; overload;
    function Add(aFieldName: AnsiString; AValue: amqp_field_array): amqp_field_pair; overload;
    function Add(aFieldName: AnsiString; AScale: amqp_octet; AValue: amqp_long_uint): amqp_field_pair; overload;
    procedure Delete(Index: Integer);
    procedure Clear;

  end;

  amqp_peer_properties = amqp_table;
  amqp_queue_name = amqp_short_str;
  amqp_redelivered = amqp_bit;
  amqp_reply_code = amqp_short_uint;
  amqp_reply_text = amqp_short_str;

  amqp_method = class;
  amqp_content_header = class;
  amqp_content_body = class;
  amqp_heartbeat = class;

  amqp_frame = class(amqp_object)
  private
    fframe_type: amqp_octet;
    fsize: amqp_long_uint;
    fchannel: amqp_short_uint;
    fpayload: amqp_object;
    fendofframe: amqp_octet;
    function GetAsMethod: amqp_method;
    function GetAsContentHeader: amqp_content_header;
    function GetAsContentBody: amqp_content_body;
    function GetAsHeartBeat: amqp_heartbeat;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    property frame_type: amqp_octet read fframe_type;
    property channel: amqp_short_uint read fchannel write fchannel;
    property payload: amqp_object read fpayload;
    property AsMethod: amqp_method read GetAsMethod;
    property AsContentHeader: amqp_content_header read GetAsContentHeader;
    property AsContentBody: amqp_content_body read GetAsContentBody;
    property AsHeartbeat: amqp_heartbeat read GetAsHeartBeat;
  end;

  amqp_method = class(amqp_object)
  private
    fmethod_id: amqp_short_uint;
    fclass_id: amqp_short_uint;
    fmethod: amqp_object;
    procedure setclass_id(const Value: amqp_short_uint);
    procedure setmethod_id(const Value: amqp_short_uint);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
    procedure DestroyMethod;
    procedure CreateMethod;
  public
    constructor Create;
    destructor Destroy; override;
    property class_id: amqp_short_uint read fclass_id write setclass_id;
    property method_id: amqp_short_uint read fmethod_id write setmethod_id;
    property method: amqp_object read fmethod;
  end;

  amqp_custom_method = class(amqp_object)
  protected
    class function new_frame(achannel: amqp_short_uint): amqp_frame;
  public
    constructor Create; override;
    class function class_id: amqp_short_uint; virtual; abstract;
    class function method_id: amqp_short_uint; virtual; abstract;
    class function create_frame(achannel: amqp_short_uint): amqp_frame; virtual;
  end;

  amqp_method_class = class of amqp_custom_method;

  amqp_method_start = class(amqp_custom_method)
  private
    fmechanisms: amqp_long_str;
    flocales: amqp_long_str;
    fproperties: amqp_table;
    fversion_minor: amqp_octet;
    fversion_major: amqp_octet;
    function Getlocales: AnsiString;
    function Getmechanisms: AnsiString;
    procedure SetLocales(const Value: AnsiString);
    procedure Setmechanisms(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property version_major: amqp_octet read fversion_major;
    property version_minor: amqp_octet read fversion_minor;
    property properties: amqp_table read fproperties;
    property mechanisms: AnsiString read Getmechanisms write Setmechanisms;
    property locales: AnsiString read Getlocales write SetLocales;
    class function class_id: amqp_short_uint; override;
    class function method_id: amqp_short_uint; override;
  end;

  amqp_method_start_ok = class(amqp_custom_method)
  private
    fmechanisms: amqp_short_str;
    fresponse: amqp_long_str;
    flocale: amqp_short_str;
    fproperties: amqp_table;
    function Getlocale: AnsiString;
    function Getmechanisms: AnsiString;
    function Getresponse: AnsiString;
    procedure SetLocale(const Value: AnsiString);
    procedure Setmechanisms(const Value: AnsiString);
    procedure setResponse(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property properties: amqp_table read fproperties;
    property mechanisms: AnsiString read Getmechanisms write Setmechanisms;
    property response: AnsiString read Getresponse write setResponse;
    property locale: AnsiString read Getlocale write SetLocale;
    class function create_frame(achannel: amqp_short_uint;
      aproperties: amqp_table; amechanisms, aresponce, alocale: AnsiString)
      : amqp_frame;
    class function class_id: amqp_short_uint; override;
    class function method_id: amqp_short_uint; override;
  end;

  amqp_method_secure = class(amqp_custom_method)
  private
    fchallenge: amqp_long_str;
    function Getchallenge: AnsiString;
    procedure SetChallenge(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property challenge: AnsiString read Getchallenge write SetChallenge;
    class function class_id: amqp_short_uint; override;
    class function method_id: amqp_short_uint; override;

  end;

  amqp_method_secure_ok = class(amqp_custom_method)
  private
    fresponse: amqp_long_str;
    function Getresponse: AnsiString;
    procedure SetResponse(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property repsonse: AnsiString read Getresponse write SetResponse;
    class function class_id: amqp_short_uint; override;
    class function method_id: amqp_short_uint; override;
  end;

  amqp_method_tune = class(amqp_custom_method)
  private
    fframeMax: amqp_long_uint;
    fheartBeat: amqp_short_uint;
    fchannelMax: amqp_short_uint;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    property channelMax: amqp_short_uint read fchannelMax;
    property frameMax: amqp_long_uint read fframeMax;
    property heartBeat: amqp_short_uint read fheartBeat;
    class function class_id: amqp_short_uint; override;
    class function method_id: amqp_short_uint; override;
  end;

  amqp_method_tune_ok = class(amqp_method_tune)
  public
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      achannelMax: amqp_short_uint; aframeMax: amqp_long_uint;
      aheartBeat: amqp_short_uint): amqp_frame;
  end;

  amqp_method_open = class(amqp_custom_method)
  private
    fvirtualHost: amqp_short_str;
    fCapabilites:  amqp_short_str;
    fInsist: amqp_bit;
    function GetvirtualHost: AnsiString;
    procedure SetvirtualHost(const Value: AnsiString);
    function GetCapabilites: AnsiString;
    procedure SetCapabilites(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property virtualHost: AnsiString read GetvirtualHost write SetvirtualHost;
    property Capabilites: AnsiString read GetCapabilites write SetCapabilites;
    property Insist: amqp_bit read fInsist write fInsist;
    class function class_id: amqp_short_uint; override;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aVirtualHost: AnsiString): amqp_frame;
  end;

  amqp_method_open_ok = class(amqp_custom_method)
  private
    fKnownHosts: amqp_short_str;
    function getKnownHosts: AnsiString;
    procedure setKnownHosts(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property KnownHosts: AnsiString read getKnownHosts write setKnownHosts;
    class function class_id: amqp_short_uint; override;
    class function method_id: amqp_short_uint; override;
  end;

  amqp_method_close = class(amqp_custom_method)
  private
    frmethodid: amqp_short_uint;
    frclassid: amqp_short_uint;
    fReplyText: amqp_short_str;
    fReplyCode: amqp_short_uint;
    function GetReplyText: AnsiString;
    procedure SetReplyText(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property replyCode: amqp_short_uint read fReplyCode write fReplyCode;
    property replyText: AnsiString read GetReplyText write SetReplyText;
    property rclassid: amqp_short_uint read frclassid;
    property rmethodid: amqp_short_uint read frmethodid;
    class function class_id: amqp_short_uint; override;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aReplyCode: amqp_short_uint; aReplyText: AnsiString;
      aClassId, AMethodId: amqp_short_uint): amqp_frame;
  end;

  amqp_method_close_ok = class(amqp_custom_method)
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    class function class_id: amqp_short_uint; override;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint): amqp_frame;
  end;

  amqp_method_channel_class = class(amqp_custom_method)
  protected
    function GetSize: amqp_long_long_uint; override;
  public
    class function class_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint): amqp_frame; virtual;
  end;

  amqp_method_channel_open = class(amqp_method_channel_class)
  private
    fOutOfBand: amqp_short_str;
    function GetOutOfBand: AnsiString;
    procedure SetOutOfBand(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property OutOfBand: AnsiString read GetOutOfBand write SetOutOfBand;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint; aoutofband: AnsiString): amqp_frame;
  end;

  amqp_method_channel_open_ok = class(amqp_method_channel_class)
  private
    FChannelId: amqp_long_str;
    function getChannelId: AnsiString;
    procedure SetChannelId(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property ChannelId: AnsiString read getChannelId write SetChannelId;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint; achannelid: AnsiString): amqp_frame;
  end;

  amqp_method_channel_flow = class(amqp_method_channel_class)
  private
    factive: amqp_boolean;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    property active: amqp_boolean read factive write factive;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint; aactive: amqp_bit)
      : amqp_frame; reintroduce; virtual;
  end;

  amqp_method_channel_flow_ok = class(amqp_method_channel_flow)
  public
    class function method_id: amqp_short_uint; override;
  end;

  amqp_method_channel_close = class(amqp_method_channel_class)
  private
    frmethodid: amqp_short_uint;
    frclassid: amqp_short_uint;
    fReplyText: amqp_short_str;
    fReplyCode: amqp_short_uint;
    function GetReplyText: AnsiString;
    procedure SetReplyText(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property replyCode: amqp_short_uint read fReplyCode write fReplyCode;
    property replyText: AnsiString read GetReplyText write SetReplyText;
    property rclassid: amqp_short_uint read frclassid;
    property rmethodid: amqp_short_uint read frmethodid;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aReplyCode: amqp_short_uint; aReplyText: AnsiString;
      aClassId, AMethodId: amqp_short_uint): amqp_frame; reintroduce; virtual;
  end;

  amqp_method_channel_close_ok = class(amqp_method_channel_class)
  public
    class function method_id: amqp_short_uint; override;
  end;

  amqp_method_exchange_class = class(amqp_custom_method)
  public
    class function class_id: amqp_short_uint; override;
  end;

  amqp_method_exchange_declare_ok = class(amqp_method_exchange_class)
  private
    fticket: amqp_2octet;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    property ticket: amqp_2octet read fticket write fticket;
    class function method_id: amqp_short_uint; override;
  end;

  amqp_method_exchange_declare = class(amqp_method_exchange_declare_ok)
  private
    Fexchange: amqp_exchange_name;
    F_type: amqp_short_str;
    FFlags: amqp_octet;
    Farguments: amqp_table;
    function getFlag(const Index: Integer): amqp_bit;
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
    constructor Create; override;
    destructor Destroy; override;
    property exchange: AnsiString read Getexchange write Setexchange;
    property _type: AnsiString read Get_type write Set_type;
    property passive: amqp_bit index 1 read getFlag write SetFlag;
    property durable: amqp_bit index 2 read getFlag write SetFlag;
    property auto_delete: amqp_bit index 3 read getFlag write SetFlag;
    property internal: amqp_bit index 4 read getFlag write SetFlag;
    property nowait: amqp_bit index 5 read getFlag write SetFlag;
    property arguments: amqp_table read Farguments;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aexchange, atype: AnsiString; apassive, adurable, aauto_delete, ainternal,
      anowait: Boolean; aargs: amqp_table): amqp_frame; reintroduce; virtual;
  end;

  amqp_method_exchange_delete_ok = class(amqp_method_exchange_class)
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint): amqp_frame;
      reintroduce; virtual;
  end;

  amqp_method_exchange_delete = class(amqp_method_exchange_delete_ok)
  private
    fticket: amqp_short_uint;
    Fexchange: amqp_exchange_name;
    fFlag: amqp_octet;
    function getFlag(const Index: Integer): amqp_bit;
    procedure SetFlag(const Index: Integer; const Value: amqp_bit);
    function Getexchange: AnsiString;
    procedure Setexchange(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property ticket: amqp_short_uint read fticket write fticket;
    property exchange: AnsiString read Getexchange write Setexchange;
    property if_unused: amqp_bit index 1 read getFlag write SetFlag;
    property no_wait: amqp_bit index 2 read getFlag write SetFlag;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aexchange: AnsiString; aifUnused, anowait: amqp_bit): amqp_frame;
      reintroduce; virtual;
  end;

  amqp_method_queue_class = class(amqp_custom_method)
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    class function class_id: amqp_short_uint; override;
  end;

  amqp_method_queue_declare = class(amqp_method_queue_class)
  private
    fticket: amqp_short_uint;
    Fqueue: amqp_queue_name;
    Farguments: amqp_peer_properties;
    fFlag: amqp_octet;
    function getFlag(const Index: Integer): amqp_bit;
    procedure SetFlag(const Index: Integer; const Value: amqp_bit);
    function Getqueue: AnsiString;
    procedure Setqueue(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property ticket: amqp_short_uint read fticket write fticket;
    property queue: AnsiString read Getqueue write Setqueue;
    property passive: amqp_bit index 1 read getFlag write SetFlag;
    property durable: amqp_bit index 2 read getFlag write SetFlag;
    property exclusive: amqp_bit index 3 read getFlag write SetFlag;
    property auto_delete: amqp_bit index 4 read getFlag write SetFlag;
    property no_wait: amqp_bit index 5 read getFlag write SetFlag;
    property arguments: amqp_peer_properties read Farguments;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aticket: amqp_short_uint; aqueue: AnsiString;
      apassive, adurable, aexclusive, aautodelete, anowait: amqp_bit;
      aargs: amqp_peer_properties): amqp_frame; reintroduce; virtual;
  end;

  amqp_method_queue_declare_ok = class(amqp_method_queue_class)
  private
    Fqueue: amqp_queue_name;
    Fmessage_count: amqp_message_count;
    Fconsumer_count: amqp_long_uint;
    function Getqueue: AnsiString;
    procedure Setqueue(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property queue: AnsiString read Getqueue write Setqueue;
    property message_count: amqp_message_count read Fmessage_count
      write Fmessage_count;
    property consumer_count: amqp_long_uint read Fconsumer_count
      write Fconsumer_count;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint; aqueue: AnsiString;
      amessage_count: amqp_message_count; aconsumer_count: amqp_long_uint)
      : amqp_frame; reintroduce; virtual;
  end;

  amqp_method_queue_bind = class(amqp_method_queue_class)
  private
    fticket: amqp_short_uint;
    Fqueue: amqp_queue_name;
    Fexchange: amqp_exchange_name;
    FroutingKey: amqp_short_str;
    Fnowait: amqp_boolean;
    Farguments: amqp_peer_properties;
    function Getexchange: AnsiString;
    function Getqueue: AnsiString;
    function GetroutingKey: AnsiString;
    procedure Setexchange(const Value: AnsiString);
    procedure Setqueue(const Value: AnsiString);
    procedure SetroutingKey(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property ticket: amqp_short_uint read fticket write fticket;
    property queue: AnsiString read Getqueue write Setqueue;
    property exchange: AnsiString read Getexchange write Setexchange;
    property routingKey: AnsiString read GetroutingKey write SetroutingKey;
    property nowait: amqp_boolean read Fnowait write Fnowait;
    property arguments: amqp_peer_properties read Farguments;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aticket: amqp_short_uint; aqueue, aexchange, aroutingkey: AnsiString;
      anowait: amqp_boolean; aargs: amqp_peer_properties): amqp_frame;
      reintroduce; virtual;
  end;

  amqp_method_queue_bind_ok = class(amqp_method_queue_class)
  public
    class function method_id: amqp_short_uint; override;
  end;

  amqp_method_queue_unbind = class(amqp_method_queue_bind)
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aticket: amqp_short_uint; aqueue, aexchange, aroutingkey: AnsiString;
      aargs: amqp_peer_properties): amqp_frame; reintroduce; virtual;
  end;

  amqp_method_queue_unbind_ok = class(amqp_method_queue_class)
  public
    class function method_id: amqp_short_uint; override;
  end;

  amqp_method_queue_purge = class(amqp_method_queue_class)
  private
    Fnowait: amqp_boolean;
    Fqueue: amqp_queue_name;
    fticket: amqp_short_uint;
    function Getqueue: AnsiString;
    procedure Setqueue(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property ticket: amqp_short_uint read fticket write fticket;
    property queue: AnsiString read Getqueue write Setqueue;
    property nowait: amqp_boolean read Fnowait write Fnowait;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aticket: amqp_short_uint; aqueue: AnsiString; anowait: amqp_boolean)
      : amqp_frame; reintroduce; virtual;
  end;

  amqp_method_queue_purge_ok = class(amqp_method_queue_class)
  private
    Fmessage_count: amqp_message_count;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    property message_count: amqp_message_count read Fmessage_count
      write Fmessage_count;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      amessage_count: amqp_message_count): amqp_frame; reintroduce; virtual;
  end;

  amqp_method_queue_delete = class(amqp_method_queue_class)
  private
    fticket: amqp_short_uint;
    Fqueue: amqp_queue_name;
    fFlag: amqp_octet;
    function getFlag(const Index: Integer): amqp_bit;
    procedure SetFlag(const Index: Integer; const Value: amqp_bit);
    function Getqueue: AnsiString;
    procedure Setqueue(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property ticket: amqp_short_uint read fticket write fticket;
    property queue: AnsiString read Getqueue write Setqueue;
    property ifUnused: amqp_bit index 1 read getFlag write SetFlag;
    property ifempty: amqp_bit index 2 read getFlag write SetFlag;
    property no_wait: amqp_bit index 3 read getFlag write SetFlag;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aticket: amqp_short_uint; aqueue: AnsiString;
      aifUnused, aIfEmpty, anowait: amqp_bit): amqp_frame; reintroduce; virtual;
  end;

  amqp_method_queue_delete_ok = class(amqp_method_queue_purge_ok)
  public
    class function method_id: amqp_short_uint; override;
  end;

  amqp_content_type = amqp_short_str;
  amqp_content_encoding = amqp_short_str;
  amqp_headers = amqp_table;
  amqp_delivery_mode = amqp_octet;
  amqp_priority = amqp_octet;
  amqp_correlation_id = amqp_short_str;
  amqp_reply_to = amqp_short_str;
  amqp_expiration = amqp_short_str;
  amqp_message_id = amqp_short_str;
  amqp_type = amqp_short_str;
  amqp_user_id = amqp_short_str;
  amqp_app_id = amqp_short_str;
  amqp_reserved = amqp_short_str;

  amqp_empty_method = class(amqp_custom_method)
  public
   class function class_id: amqp_short_uint; override;
   class function method_id: amqp_short_uint; override;
  end;

  amqp_method_basic_class = class(amqp_custom_method)
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    class function class_id: amqp_short_uint; override;
  end;

  amqp_method_basic_qos = class(amqp_method_basic_class)
  private
    Fprefetchsize: amqp_long_uint;
    FprefetchCount: amqp_short_uint;
    Fglobal: amqp_bit;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    property prefetchsize: amqp_long_uint read Fprefetchsize
      write Fprefetchsize;
    property prefetchCount: amqp_short_uint read FprefetchCount
      write FprefetchCount;
    property global: amqp_bit read Fglobal write Fglobal;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aprefetchsize: amqp_long_uint; aprefetchcount: amqp_short_uint;
      aglobal: amqp_bit): amqp_frame; reintroduce; virtual;
  end;

  amqp_method_basic_qos_ok = class(amqp_method_basic_class)
  public
    class function method_id: amqp_short_uint; override;
  end;

  amqp_method_basic_consume_ok = class(amqp_method_basic_class)
  private
    FconsumerTag: amqp_consumer_tag;
    function GetconsumerTag: AnsiString;
    procedure SetconsumerTag(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property consumerTag: AnsiString read GetconsumerTag
      write SetconsumerTag;
    class function create_frame(achannel: amqp_short_uint;
      aconsumerTag: AnsiString): amqp_frame; reintroduce; virtual;
    class function method_id: amqp_short_uint; override;
  end;

  amqp_method_basic_consume = class(amqp_method_basic_consume_ok)
  private
    fticket: amqp_short_uint;
    Fqueue: amqp_queue_name;
    fFlag: amqp_octet;
    Farguments: amqp_peer_properties;
    function getFlag(const Index: Integer): amqp_bit;
    procedure SetFlag(const Index: Integer; const Value: amqp_bit);
    function Getqueue: AnsiString;
    procedure Setqueue(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property ticket: amqp_short_uint read fticket write fticket;
    property queue: AnsiString read Getqueue write Setqueue;
    property noLocal: amqp_bit index 1 read getFlag write SetFlag;
    property noAck: amqp_bit index 2 read getFlag write SetFlag;
    property exclusive: amqp_bit index 3 read getFlag write SetFlag;
    property nowait: amqp_bit index 1 read getFlag write SetFlag;
    property arguments: amqp_peer_properties read Farguments;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aticket: amqp_short_uint; aqueue, aconsumerTag: AnsiString;
      aNoLocal, aNoAck, aexclusive, anowait: amqp_bit;
      aargs: amqp_peer_properties): amqp_frame; reintroduce; virtual;
  end;

  amqp_method_basic_cancel = class(amqp_method_basic_consume_ok)
  private
    Fnowait: amqp_bit;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    property nowait: amqp_bit read Fnowait write Fnowait;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aconsumerTag: AnsiString; anowait: amqp_bit): amqp_frame;
      reintroduce; virtual;
  end;

  amqp_method_basic_cancel_ok = class(amqp_method_basic_consume_ok)
  public
    class function method_id: amqp_short_uint; override;
  end;

  amqp_method_basic_custom_return = class(amqp_method_basic_class)
  private
    Fexchange: amqp_exchange_name;
    FroutingKey: amqp_short_str;
    function Getexchange: AnsiString;
    function GetroutingKey: AnsiString;
    procedure Setexchange(const Value: AnsiString);
    procedure SetroutingKey(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property exchange: AnsiString read Getexchange write Setexchange;
    property routingKey: AnsiString read GetroutingKey write SetroutingKey;
  end;

  amqp_method_basic_publish = class(amqp_method_basic_custom_return)
  private
    fticket: amqp_short_uint;
    fFlag: amqp_octet;
    function getFlag(const Index: Integer): amqp_bit;
    procedure SetFlag(const Index: Integer; const Value: amqp_bit);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property ticket: amqp_short_uint read fticket write fticket;
    property mandatory: amqp_bit index 1 read getFlag write SetFlag;
    property immediate: amqp_bit index 2 read getFlag write SetFlag;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aticket: amqp_short_uint; aexchange, aroutingkey: AnsiString;
      aMandatory, aImmediate: amqp_bit): amqp_frame; reintroduce; virtual;
  end;

  amqp_method_basic_return = class(amqp_method_basic_custom_return)
  private
    fReplyCode: amqp_reply_code;
    fReplyText: amqp_reply_text;
    function GetReplyText: AnsiString;
    procedure SetReplyText(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property replyCode: amqp_reply_code read fReplyCode write fReplyCode;
    property replyText: AnsiString read GetReplyText write SetReplyText;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aReplyCode: amqp_reply_code; aReplyText, aexchange,
      aroutingkey: AnsiString): amqp_frame; reintroduce; virtual;
  end;

  amqp_method_basic_deliver = class(amqp_method_basic_custom_return)
  private
    FconsumerTag: amqp_consumer_tag;
    FdeliveryTag: amqp_delivery_tag;
    Fredelivered: amqp_redelivered;
    function GetconsumerTag: AnsiString;
    procedure SetconsumerTag(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property consumerTag: AnsiString read GetconsumerTag
      write SetconsumerTag;
    property deliveryTag: amqp_delivery_tag read FdeliveryTag
      write FdeliveryTag;
    property redelivered: amqp_redelivered read Fredelivered write Fredelivered;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint;
      aconsumerTag: AnsiString; aDeliveryTag: amqp_delivery_tag;
      aRedelivered: amqp_redelivered; aexchange, aroutingkey: AnsiString)
      : amqp_frame; reintroduce; virtual;
  end;

  amqp_content_header = class(amqp_object)
  private
    fclass_id: amqp_short_uint;
    Fweight: amqp_short_uint;
    FbodySize: amqp_long_long_uint;
    FpropFlags: amqp_short_uint;
    Fheaders: amqp_table;
    FdeliveryMode: amqp_delivery_mode;
    FcontentType: amqp_short_str;
    FcontentEncoding: amqp_short_str;
    Fpriority: amqp_octet;
    FcorrelationId: amqp_correlation_id;
    FreplyTo: amqp_reply_to;
    Fexpiration: amqp_expiration;
    FmessageId: amqp_message_id;
    Ftimestamp: amqp_timestamp;
    F_type: amqp_type;
    FuserId: amqp_user_id;
    FappId: amqp_app_id;
    FclusterId: amqp_short_str;
    function GetappId: AnsiString;
    function GetclusterId: AnsiString;
    function GetcontentEncoding: AnsiString;
    function GetcontentType: AnsiString;
    function GetcorrelationId: AnsiString;
    function Getexpiration: AnsiString;
    function GetmessageId: AnsiString;
    function GetreplyTo: AnsiString;
    function Gettype: AnsiString;
    function GetuserId: AnsiString;
    procedure SetappId(const Value: AnsiString);
    procedure SetclusterId(const Value: AnsiString);
    procedure SetcontentEncoding(const Value: AnsiString);
    procedure SetcontentType(const Value: AnsiString);
    procedure SetcorrelationId(const Value: AnsiString);
    procedure SetdeliveryMode(const Value: amqp_delivery_mode);
    procedure Setexpiration(const Value: AnsiString);
    procedure SetmessageId(const Value: AnsiString);
    procedure Setpriority(const Value: amqp_octet);
    procedure SetreplyTo(const Value: AnsiString);
    procedure Settimestamp(const Value: amqp_timestamp);
    procedure SetType(const Value: AnsiString);
    procedure SetuserId(const Value: AnsiString);

  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property class_id: amqp_short_uint read fclass_id write fclass_id;
    property weight: amqp_short_uint read Fweight write Fweight;
    property bodySize: amqp_long_long_uint read FbodySize write FbodySize;
    property propFlags: amqp_short_uint read FpropFlags write FpropFlags;
    property contentType: AnsiString read GetcontentType write SetcontentType;
    property contentEncoding: AnsiString read GetcontentEncoding
      write SetcontentEncoding;
    property headers: amqp_table read Fheaders;
    property deliveryMode: amqp_delivery_mode read FdeliveryMode
      write SetdeliveryMode;
    property priority: amqp_octet read Fpriority write Setpriority;
    property correlationId: AnsiString read GetcorrelationId
      write SetcorrelationId;
    property replyTo: AnsiString read GetreplyTo write SetreplyTo;
    property expiration: AnsiString read Getexpiration write Setexpiration;
    property messageId: AnsiString read GetmessageId write SetmessageId;
    property timestamp: amqp_timestamp read Ftimestamp write Settimestamp;
    property _type: AnsiString read Gettype write SetType;
    property userId: AnsiString read GetuserId write SetuserId;
    property appId: AnsiString read GetappId write SetappId;
    property clusterId: AnsiString read GetclusterId write SetclusterId;
    class function create_frame(achannel: amqp_short_uint; aclassid, aweight: amqp_short_uint; abodySize: amqp_long_long_uint): amqp_frame;
  end;

  amqp_content_body = class(amqp_object)
  private
    flen: amqp_long_uint;
    FData: Pointer;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create(aLen: amqp_long_uint); reintroduce; virtual;
    destructor Destroy; override;
    property len: amqp_long_uint read flen;
    property Data: Pointer read FData;
    class function create_frame(achannel: amqp_short_uint; alen: amqp_long_uint; adata: Pointer): amqp_frame;
  end;

  amqp_method_basic_get = class(amqp_method_basic_class)
  private
    Fticket: amqp_short_uint;
    Fqueue: amqp_queue_name;
    FnoAck: amqp_no_ack;
    procedure Setqueue(const Value: AnsiString);
    function Getqueue: AnsiString;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property ticket: amqp_short_uint read Fticket write Fticket;
    property queue: AnsiString read Getqueue write Setqueue;
    property noAck: amqp_no_ack read FnoAck write FnoAck;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint; aticket: amqp_short_uint; aqueue: AnsiString;  aNoAck: amqp_no_ack): amqp_frame; reintroduce; virtual;
  end;

  amqp_method_basic_get_ok = class(amqp_method_basic_class)
  private
    FdeliveryTag: amqp_delivery_tag;
    Fredelivered: amqp_redelivered;
    Fexchange: amqp_exchange_name;
    FRoutingKey: amqp_short_str;
    FmessageCount: amqp_message_count;
    function GetExchange: AnsiString;
    procedure SetExchange(const Value: AnsiString);
    function GetRoutingKey: AnsiString;
    procedure SetRoutingKey(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property deliveryTag: amqp_delivery_tag read FdeliveryTag write FdeliveryTag;
    property redelivered: amqp_redelivered read Fredelivered write Fredelivered;
    property exchange: AnsiString read GetExchange write SetExchange;
    property routingKey: AnsiString read GetRoutingKey write SetRoutingKey;
    property messageCount: amqp_message_count read FmessageCount write FmessageCount;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint; adeliveryTag: amqp_delivery_tag; aredelivered: amqp_redelivered; aexchange, aroutingKey: AnsiString;  amessagecount: amqp_message_count): amqp_frame; reintroduce; virtual;
  end;

  amqp_method_basic_get_empty = class(amqp_method_basic_class)
  private
    fclusterid: amqp_short_str;
    function getClusterId: AnsiString;
    procedure setClusterId(const Value: AnsiString);
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property clusterId: AnsiString read getClusterId write setClusterId;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint; aclusterId: AnsiString): amqp_frame; reintroduce; virtual;
  end;

  amqp_method_basic_ack = class(amqp_method_basic_class)
  private
    FdeliveryTag: amqp_delivery_tag;
    fFlag: amqp_octet;
  protected
    function getFlag(const Index: Integer): amqp_bit; virtual;
    procedure setFlag(const Index: Integer; const Value: amqp_bit); virtual;
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    property deliveryTag: amqp_delivery_tag read FdeliveryTag write FdeliveryTag;
    property mulitple: amqp_bit index 1 read getFlag write setFlag;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint; adeliveryTag: amqp_delivery_tag; amultiple: amqp_bit): amqp_frame; reintroduce; virtual;
  end;

  amqp_method_basic_reject = class(amqp_method_basic_ack)
  public
    class function method_id: amqp_short_uint; override;
  end;

  amqp_method_basic_recover_async = class(amqp_method_basic_class)
  private
    Frequeue: amqp_bit;
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    property requeue: amqp_bit read Frequeue write Frequeue;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint; arequeue: amqp_bit): amqp_frame; reintroduce; virtual;
  end;

  amqp_method_basic_recover = class(amqp_method_basic_recover_async)
  public
    class function method_id: amqp_short_uint; override;
  end;

  amqp_method_basic_recover_ok = class(amqp_method_basic_class)
  public
    class function method_id: amqp_short_uint; override;
  end;

  amqp_method_basic_nack = class(amqp_method_basic_ack)
  protected
    function getFlag(const Index: Integer): amqp_bit;
    procedure setFlag(const Index: Integer; const Value: amqp_bit);
  public
    property requeue: amqp_bit index 2 read getFlag write setFlag;
    class function method_id: amqp_short_uint; override;
    class function create_frame(achannel: amqp_short_uint; adeliveryTag: amqp_delivery_tag; amultiple, arequeue: amqp_bit): amqp_frame; reintroduce; virtual;
  end;

  amqp_method_tx_class = class(amqp_custom_method)
  protected
    procedure DoWrite(AStream: TStream); override;
    procedure DoRead(AStream: TStream); override;
    function GetSize: amqp_long_long_uint; override;
  public
    class function class_id: amqp_short_uint; override;
  end;

  amqp_method_tx_select = class(amqp_method_tx_class)
  public
    class function method_id: amqp_short_uint; override;
  end;

  amqp_method_tx_select_ok = class(amqp_method_tx_class)
  public
    class function method_id: amqp_short_uint; override;
  end;

  amqp_method_tx_commit = class(amqp_method_tx_class)
  public
    class function method_id: amqp_short_uint; override;
  end;

  amqp_method_tx_commit_ok = class(amqp_method_tx_class)
  public
    class function method_id: amqp_short_uint; override;
  end;

  amqp_method_tx_rollback = class(amqp_method_tx_class)
  public
    class function method_id: amqp_short_uint; override;
  end;

  amqp_method_tx_rollback_ok = class(amqp_method_tx_class)
  public
    class function method_id: amqp_short_uint; override;
  end;

  amqp_heartbeat = class(amqp_object)
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

implementation

uses sysutils, variants;

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

{ amqp_field_value }

procedure amqp_field_value.Assign(aobject: amqp_object);
begin
  if aobject is amqp_field_value then
  begin
    kind := amqp_field_value(aobject).kind;
    if fval <> nil then
      fval.Assign(amqp_field_value(aobject).val);
  end;
end;

function amqp_field_value.Clone: amqp_field_value;
begin
 Result := amqp_field_value.Create;
 Result.kind := Self.kind;
 if Self.val <> nil then
  Result.val.Assign(Self.val);
end;

constructor amqp_field_value.Create;
begin
  fval := nil;
end;

function amqp_field_value.CreateVal: amqp_object;
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
      Result := amqp_decumal.Create;
    's':
      Result := amqp_short_str.Create;
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
  if fval <> nil then
    fval.Free;
  inherited;
end;

procedure amqp_field_value.DestroyVal;
begin
  if fval <> nil then
    fval.Free;
  fval := nil;
end;

procedure amqp_field_value.DoRead(AStream: TStream);
begin
  fkind := ReadChar(AStream);
  if val <> nil then
    fval.Free;
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

function amqp_field_value.GetAsArray: amqp_field_array;
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

function amqp_field_value.GetAsDecimal: amqp_decumal;
begin
  Result := nil;
  if (fkind = 'D') and (val <> nil) then
    Result := amqp_decumal(val)
  else
  begin
    if val <> NIL then
     val.Free;
     fkind := 'D';
     fval := amqp_decumal.Create;
     Result := amqp_decumal(val);
  end;
end;

function amqp_field_value.GetAsDouble: amqp_double;
begin
  Result := 0;
  if (fkind = 'd') and (val <> nil) then
    Result := amqp_field_double(val).Value;
end;

function amqp_field_value.GetAsFloat: amqp_float;
begin
  Result := 0;
  if (fkind = 'f') and (val <> nil) then
    Result := amqp_field_float(val).Value;
end;

function amqp_field_value.GetAsLongInt: amqp_long_int;
begin
  Result := 0;
  if (fkind = 'I') and (val <> nil) then
    Result := amqp_field_long_int(val).Value;
end;

function amqp_field_value.GetAsLongLongInt: amqp_long_long_int;
begin
  Result := 0;
  if (fkind = 'L') and (val <> nil) then
    Result := amqp_field_long_long_int(val).Value;
end;

function amqp_field_value.GetAsLongLongUInt: amqp_long_long_uint;
begin
  Result := 0;
  if (fkind = 'l') and (val <> nil) then
    Result := amqp_field_long_long_uint(val).Value;
end;

function amqp_field_value.GetAsLongString: AnsiString;
begin
  Result := '';
  if (fkind = 'S') and (val <> nil) then
    Result := amqp_long_str(val).val;
end;

function amqp_field_value.GetAsLongUInt: amqp_long_uint;
begin
  Result := 0;
  if (fkind = 'i') and (val <> nil) then
    Result := amqp_field_long_uint(val).Value;
end;

function amqp_field_value.GetAsShortInt: amqp_short_int;
begin
  Result := 0;
  if (fkind = 'U') and (val <> nil) then
    Result := amqp_field_short_short_int(val).Value;
end;

function amqp_field_value.GetAsShortShortInt: amqp_short_short_int;
begin
  Result := 0;
  if (fkind = 'b') and (val <> nil) then
    Result := amqp_field_short_short_int(val).Value;
end;

function amqp_field_value.GetAsShortShortUInt: amqp_short_short_uint;
begin
  Result := 0;
  if (fkind = 'B') and (val <> nil) then
    Result := amqp_field_short_short_uint(val).Value;
end;

function amqp_field_value.GetAsShortString: AnsiString;
begin
  Result := '';
  if (fkind = 's') and (val <> nil) then
    Result := amqp_short_str(val).val;
end;

function amqp_field_value.GetAsShortUInt: amqp_short_uint;
begin
  Result := 0;
  if (fkind = 'u') and (val <> nil) then
    Result := amqp_field_short_uint(val).Value;
end;

function amqp_field_value.GetAsTable: amqp_table;
begin
  Result := nil;
  if (fkind = 'F') and (val <> nil) then
    Result := amqp_table(fval)
  else if (fkind = '') then
  begin
    DestroyVal;
    fval := amqp_table.Create;
    Result := amqp_table(fval);
    fkind := 'F';
  end;
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
  amqp_field_double(fval).Value := Value;
end;

procedure amqp_field_value.SetAsFloat(const Value: amqp_float);
begin
  DestroyVal;
  fkind := 'f';
  fval := amqp_field_float.Create;
  amqp_field_float(fval).Value := Value;
end;

procedure amqp_field_value.SetAsLongInt(const Value: amqp_long_int);
begin
  DestroyVal;
  fkind := 'I';
  fval := amqp_field_long_int.Create;
  amqp_field_long_int(fval).Value := Value;
end;

procedure amqp_field_value.SetAsLongLongInt(const Value: amqp_long_long_int);
begin
  DestroyVal;
  fkind := 'L';
  fval := amqp_field_long_long_int.Create;
  amqp_field_long_long_int(fval).Value := Value;
end;

procedure amqp_field_value.SetAsLongLongUInt(const Value: amqp_long_long_uint);
begin
  DestroyVal;
  fkind := 'l';
  fval := amqp_field_long_long_uint.Create;
  amqp_field_long_long_uint(fval).Value := Value;
end;

procedure amqp_field_value.SetAsLongString(const Value: AnsiString);
begin
  if fval <> nil then
    fval.Free;
  fval := amqp_long_str.Create;
  fkind := 'S';
  amqp_short_str(fval).val := Value;
end;

procedure amqp_field_value.SetAsLongUInt(const Value: amqp_long_uint);
begin
  DestroyVal;
  fkind := 'i';
  fval := amqp_field_long_uint.Create;
  amqp_field_long_uint(fval).Value := Value;
end;

procedure amqp_field_value.SetAsShortInt(const Value: amqp_short_int);
begin
  DestroyVal;
  fkind := 'U';
  fval := amqp_field_short_int.Create;
  amqp_field_short_int(fval).Value := Value;
end;

procedure amqp_field_value.SetAsShortShortInt(const Value
  : amqp_short_short_int);
begin
  DestroyVal;
  fkind := 'b';
  fval := amqp_field_short_short_int.Create;
  amqp_field_short_short_int(fval).Value := Value;

end;

procedure amqp_field_value.SetAsShortShortUInt(const Value
  : amqp_short_short_uint);
begin
  DestroyVal;
  fkind := 'B';
  fval := amqp_field_short_short_uint.Create;
  amqp_field_short_short_uint(fval).Value := Value;

end;

procedure amqp_field_value.SetAsShortString(const Value: AnsiString);
begin
  if fval <> nil then
    fval.Free;
  fval := amqp_short_str.Create;
  fkind := 's';
  amqp_short_str(fval).val := Value;
end;

procedure amqp_field_value.SetAsShortUInt(const Value: amqp_short_uint);
begin
  DestroyVal;
  fkind := 'u';
  fval := amqp_field_short_uint.Create;
  amqp_field_short_uint(fval).Value := Value;
end;

procedure amqp_field_value.setKind(const Value: amqp_string_char);
begin
  if fkind <> Value then
  begin
    fkind := Value;
    if fval <> nil then
      fval.Free;
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

constructor amqp_object.Create;
begin

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
  finally
    Buf.Free;
  end;
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

{ amqp_decumal }

procedure amqp_decumal.Assign(aobject: amqp_object);
begin
  if aobject is amqp_decumal then
  begin
    Fvalue := amqp_decumal(aobject).Value;
    Fscale := amqp_decumal(aobject).scale;
  end;
end;

procedure amqp_decumal.DoRead(AStream: TStream);
begin
  Fvalue := ReadLongUInt(AStream);
  Fscale := ReadOctet(AStream);
end;

procedure amqp_decumal.DoWrite(AStream: TStream);
begin
  WriteLongUInt(AStream, Fvalue);
  WriteOctet(AStream, Fscale);
end;

function amqp_decumal.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(Fvalue) + sizeof(Fscale);
end;

procedure amqp_decumal.Setscale(const Value: amqp_octet);
begin
  Fscale := Value;
end;

procedure amqp_decumal.Setvalue(const Value: amqp_long_uint);
begin
  Fvalue := Value;
end;

{ amqp_short_str }

procedure amqp_short_str.Assign(aobject: amqp_object);
begin
  if aobject is amqp_short_str then
    val := amqp_short_str(aobject).val;
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

procedure amqp_short_str.setval(const Value: AnsiString);
begin
  fval := Value;
  flen := Length(Value);
end;

{ amqp_long_str }

procedure amqp_long_str.Assign(aobject: amqp_object);
begin
  if aobject is amqp_long_str then
    val := amqp_long_str(aobject).val;
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

{ amqp_field_boolean }

procedure amqp_field_boolean.Assign(aobject: amqp_object);
begin
  if aobject is amqp_field_boolean then
    Fvalue := amqp_field_boolean(aobject).Value
end;

procedure amqp_field_boolean.DoRead(AStream: TStream);
begin
  Fvalue := ReadBoolean(AStream);
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

procedure amqp_field_short_short_uint.Assign(aobject: amqp_object);
begin
  if aobject is amqp_field_short_short_uint then
    Fvalue := amqp_field_short_short_uint(aobject).Value;
end;

procedure amqp_field_short_short_uint.DoRead(AStream: TStream);
begin
  Fvalue := ReadShortShortUInt(AStream);
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

procedure amqp_field_short_short_int.Assign(aobject: amqp_object);
begin
  if aobject is amqp_field_short_short_int then
    Fvalue := amqp_field_short_int(aobject).Value;
end;

procedure amqp_field_short_short_int.DoRead(AStream: TStream);
begin
  Fvalue := ReadShortShortInt(AStream);
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

procedure amqp_field_short_int.Assign(aobject: amqp_object);
begin
  if aobject is amqp_field_short_int then
    Fvalue := amqp_field_short_int(aobject).Value;
end;

procedure amqp_field_short_int.DoRead(AStream: TStream);
begin
  Fvalue := ReadShortInt(AStream);
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

procedure amqp_field_short_uint.Assign(aobject: amqp_object);
begin
  if aobject is amqp_field_short_uint then
    Fvalue := amqp_field_short_uint(aobject).Value;
end;

procedure amqp_field_short_uint.DoRead(AStream: TStream);
begin
  Fvalue := ReadShortUInt(AStream);
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

procedure amqp_field_long_uint.Assign(aobject: amqp_object);
begin
  if aobject is amqp_field_long_uint then
    Fvalue := amqp_field_long_uint(aobject).Value;
end;

procedure amqp_field_long_uint.DoRead(AStream: TStream);
begin
  Fvalue := ReadLongUInt(AStream);
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

procedure amqp_field_long_int.Assign(aobject: amqp_object);
begin
  if aobject is amqp_field_long_int then
    Fvalue := amqp_field_long_int(aobject).Value;
end;

procedure amqp_field_long_int.DoRead(AStream: TStream);
begin
  Fvalue := ReadLongInt(AStream);
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

procedure amqp_field_long_long_uint.Assign(aobject: amqp_object);
begin
  if aobject is amqp_field_long_long_uint then
    Fvalue := amqp_field_long_long_uint(aobject).Value;
end;

procedure amqp_field_long_long_uint.DoRead(AStream: TStream);
begin
  Fvalue := ReadLongLongUInt(AStream);
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

procedure amqp_field_long_long_int.Assign(aobject: amqp_object);
begin
  if aobject is amqp_field_long_long_int then
    Fvalue := amqp_field_long_long_int(aobject).Value;
end;

procedure amqp_field_long_long_int.DoRead(AStream: TStream);
begin
  Fvalue := ReadLongLongInt(AStream);
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

procedure amqp_field_float.Assign(aobject: amqp_object);
begin
  if aobject is amqp_field_float then
    Fvalue := amqp_field_float(aobject).Value;
end;

procedure amqp_field_float.DoRead(AStream: TStream);
begin
  Fvalue := ReadFloat(AStream);
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

procedure amqp_field_double.Assign(aobject: amqp_object);
begin
  if aobject is amqp_field_double then
    Fvalue := amqp_field_double(aobject).Value;
end;

procedure amqp_field_double.DoRead(AStream: TStream);
begin
  Fvalue := ReadDouble(AStream);
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

procedure amqp_field_pair.Assign(aobject: amqp_object);
begin
  if aobject is amqp_field_pair then
  begin
    ffield_name.Assign(amqp_field_pair(aobject).field_name);
    ffield_value.Assign(amqp_field_pair(aobject).ffield_value);
  end;
end;

function amqp_field_pair.clone: amqp_field_pair;
begin
  Result := amqp_field_pair.Create;
  Result.field_name.Assign(ffield_name);
  Result.field_value.Assign(ffield_value);
end;

constructor amqp_field_pair.Create;
begin
  ffield_name := amqp_short_str.Create;
  ffield_value := amqp_field_value.Create;
end;

destructor amqp_field_pair.Destroy;
begin
  ffield_value.Free;
  ffield_name.Free;
  inherited;
end;

procedure amqp_field_pair.DoRead(AStream: TStream);
begin
  ffield_name.Read(AStream);
  ffield_value.Read(AStream);
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

function amqp_field_array.Add: amqp_field_value;
begin
  Result := amqp_field_value.Create;
  FArray.Add(Result);
end;

procedure amqp_field_array.Assign(AObject: amqp_object);
var
  i: Integer;
begin
  FArray.Clear;
  if aobject <> nil then
    for i := 0 to amqp_field_array(aobject).Count - 1 do
      FArray.Add(amqp_field_array(aobject)[i].clone);
end;

procedure amqp_field_array.Clear;
begin
  FArray.Clear;
end;

constructor amqp_field_array.Create;
begin
  FArray := TObjectList.Create;
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
  val: amqp_field_value;
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

function amqp_field_array.GetItems(Index: Integer): amqp_field_value;
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

function amqp_table.Add: amqp_field_pair;
begin
  Result := amqp_field_pair.Create;
  FTable.Add(Result);
end;

function amqp_table.Add(aFieldName, AValue: AnsiString): amqp_field_pair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsShortString := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString; AValue: amqp_boolean): amqp_field_pair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsBoolean := AValue;
end;

procedure amqp_table.Assign(aobject: amqp_object);
var
  i: Integer;
begin
  FTable.Clear;
  if aobject <> nil then
    for i := 0 to amqp_table(aobject).Count - 1 do
      FTable.Add(amqp_table(aobject)[i].clone);
end;

procedure amqp_table.Clear;
begin
  FTable.Clear;
end;

constructor amqp_table.Create;
begin
  FTable := TObjectList.Create;
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
  p: amqp_field_pair;
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

function amqp_table.FieldByName(AFieldName: AnsiString): amqp_field_pair;
var i: Integer;
begin
 Result := nil;
 for I := 0 to FTable.Count - 1 do
   if AFieldName = Items[i].field_name.val then
    begin
      result := Items[i];
      Break;
    end;
end;

function amqp_table.GetCount: Integer;
begin
  Result := FTable.Count;
end;

function amqp_table.GetItems(Index: Integer): amqp_field_pair;
begin
  Result := amqp_field_pair(FTable[index]);
end;

function amqp_table.GetSize: amqp_long_long_uint;
var
  i: Integer;
begin
  Result := sizeof(amqp_long_uint);
  for i := 0 to Count - 1 do
    Result := Result + Items[i].Size;
end;

function amqp_table.Add(aFieldName: AnsiString; AValue: amqp_short_int): amqp_field_pair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsShortInt := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString; AValue: amqp_long_uint): amqp_field_pair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsLongUInt := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString; AValue: amqp_long_int): amqp_field_pair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsLongInt := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString; AValue: amqp_short_short_uint): amqp_field_pair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsShortShortUInt := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString; AValue: amqp_short_short_int): amqp_field_pair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsShortShortInt := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString; AValue: amqp_short_uint): amqp_field_pair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsShortUInt := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString; AValue: amqp_long_long_uint): amqp_field_pair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsShortInt := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString; AValue: amqp_table): amqp_field_pair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsTable.Assign(AValue);
end;

function amqp_table.Add(aFieldName: AnsiString; AValue: amqp_field_array): amqp_field_pair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsArray.Assign(AValue);
end;

function amqp_table.Add(aFieldName: AnsiString; AScale: amqp_octet; AValue: amqp_long_uint): amqp_field_pair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsDecimalValue.scale := AScale;
 result.field_value.AsDecimalValue.Value := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString; AValue: amqp_long_long_int): amqp_field_pair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsLongLongUInt := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString; AValue: amqp_float): amqp_field_pair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsFloat := AValue;
end;

function amqp_table.Add(aFieldName: AnsiString; AValue: amqp_double): amqp_field_pair;
begin
 Result := Add;
 Result.field_name.val := aFieldName;
 result.field_value.AsDouble := AValue;
end;

{ amqp_frame }

procedure amqp_frame.DoRead(AStream: TStream);
begin
  fframe_type := ReadOctet(AStream);
  fchannel := ReadShortUInt(AStream);
  fsize := ReadLongUInt(AStream);
  case fframe_type of
    AMQP_FRAME_METHOD:
      fpayload := amqp_method.Create;
    AMQP_FRAME_HEADER:
      fpayload := amqp_content_header.Create;
    AMQP_FRAME_BODY:
      fpayload := amqp_content_body.Create(fsize);
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

function amqp_frame.GetAsContentBody: amqp_content_body;
begin
 if (fpayload <> nil) and (fpayload is amqp_content_body) then
  Result := amqp_content_body(fpayload)
 else
  Result := nil;
end;

function amqp_frame.GetAsContentHeader: amqp_content_header;
begin
 if (fpayload <> nil) and (fpayload is amqp_content_header) then
  Result := amqp_content_header(fpayload)
 else
  Result := nil;
end;

function amqp_frame.GetAsHeartBeat: amqp_heartbeat;
begin
  if (fpayload <> nil) and (fpayload is amqp_heartbeat) then
    Result := amqp_heartbeat(payload)
  else
    Result := nil;
end;

function amqp_frame.GetAsMethod: amqp_method;
begin
  if (fpayload <> nil) and (fpayload is amqp_method) then
    Result := amqp_method(payload)
  else
    Result := nil;
end;

function amqp_frame.GetSize: amqp_long_long_uint;
begin
  Result := 0;
  if fpayload <> nil then
    Result := Result + fpayload.Size;
end;

{ amqp_method_start_ok }

class function amqp_method_start.class_id: amqp_short_uint;
begin
  Result := 10;
end;

constructor amqp_method_start.Create;
begin
  fproperties := amqp_table.Create;
  fmechanisms := amqp_long_str.Create;
  flocales := amqp_long_str.Create;
end;

destructor amqp_method_start.Destroy;
begin
  flocales.Free;
  fmechanisms.Free;
  fproperties.Free;
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
  fproperties := amqp_table.Create;
  fmechanisms := amqp_short_str.Create;
  fresponse := amqp_long_str.Create;
  flocale := amqp_short_str.Create;
end;

class function amqp_method_start_ok.create_frame(achannel: amqp_short_uint;
  aproperties: amqp_table; amechanisms, aresponce, alocale: AnsiString)
  : amqp_frame;
var
  f: amqp_field_pair;
begin
  Result := new_frame(achannel);
  with amqp_method_start_ok(Result.AsMethod.method) do
  begin
    mechanisms := amechanisms;
    response := aresponce;
    locale := alocale;
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
  fproperties.Free;
  fmechanisms.Free;
  fresponse.Free;
  flocale.Free;
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

procedure amqp_method_start_ok.setResponse(const Value: AnsiString);
begin
 fresponse.val := Value;
end;

{ amqp_method }

constructor amqp_method.Create;
begin
  fmethod := nil;
end;

procedure amqp_method.CreateMethod;
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

destructor amqp_method.Destroy;
begin
  if fmethod <> nil then
    fmethod.Free;
  inherited;
end;

procedure amqp_method.DestroyMethod;
begin
  if fmethod <> nil then
    fmethod.Free;
  fmethod := nil;
end;

procedure amqp_method.DoRead(AStream: TStream);
begin
  fclass_id := ReadShortUInt(AStream);
  fmethod_id := ReadShortUInt(AStream);
  CreateMethod;
  if fmethod <> nil then
    fmethod.Read(AStream);
end;

procedure amqp_method.DoWrite(AStream: TStream);
begin
  WriteShortUInt(AStream, fclass_id);
  WriteShortUInt(AStream, fmethod_id);
  if fmethod <> nil then
    fmethod.Write(AStream);
end;

function amqp_method.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(fclass_id) + sizeof(fmethod_id);
  if fmethod <> nil then
    Result := Result + fmethod.Size;
end;

procedure amqp_method.setclass_id(const Value: amqp_short_uint);
begin
  if Value <> fclass_id then
  begin
    DestroyMethod;
    fclass_id := Value;
  end;
end;

procedure amqp_method.setmethod_id(const Value: amqp_short_uint);
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
  fchallenge := amqp_long_str.Create;
end;

destructor amqp_method_secure.Destroy;
begin
  fchallenge.Free;
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
  fresponse := amqp_long_str.Create;
end;

destructor amqp_method_secure_ok.Destroy;
begin
  fresponse.Free;
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

end;

class function amqp_custom_method.create_frame(achannel: amqp_short_uint)
  : amqp_frame;
begin
  Result := new_frame(achannel);
end;

class function amqp_custom_method.new_frame(achannel: amqp_short_uint)
  : amqp_frame;
begin
  Result := amqp_frame.Create;
  Result.fframe_type := AMQP_FRAME_METHOD;
  Result.channel := achannel;
  Result.fpayload := amqp_method.Create;
  amqp_method(Result.fpayload).class_id := class_id;
  amqp_method(Result.fpayload).method_id := method_id;
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
  aheartBeat: amqp_short_uint): amqp_frame;
begin
  Result := new_frame(achannel);
  with amqp_method_tune_ok(Result.AsMethod.method) do
  begin
    fchannelMax := achannelMax;
    fframeMax := aframeMax;
    fheartBeat := aheartBeat;
  end;
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
  fvirtualHost := amqp_short_str.Create;
  fCapabilites := amqp_short_str.Create;
end;

class function amqp_method_open.create_frame(achannel: amqp_short_uint;
  aVirtualHost: AnsiString): amqp_frame;
begin
  Result := new_frame(achannel);
  with amqp_method_open(Result.AsMethod.method) do
  begin
    virtualHost := aVirtualHost;
    fInsist := True;
  end;
end;

destructor amqp_method_open.Destroy;
begin
  fvirtualHost.Free;
  fCapabilites.Free;
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
  fKnownHosts := amqp_short_str.Create;
end;

destructor amqp_method_open_ok.Destroy;
begin
  fKnownHosts.Free;
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
  fReplyText := amqp_short_str.Create;
end;

class function amqp_method_close.create_frame(achannel,
  aReplyCode: amqp_short_uint; aReplyText: AnsiString;
  aClassId, AMethodId: amqp_short_uint): amqp_frame;
begin
  Result := new_frame(achannel);
  with amqp_method_close(Result.AsMethod.method) do
  begin
    replyCode := aReplyCode;
    replyText := aReplyText;
    frclassid := aClassId;
    frmethodid := AMethodId;
  end;
end;

destructor amqp_method_close.Destroy;
begin
  fReplyText.Free;
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

function amqp_method_close.GetSize: amqp_long_long_uint;
begin
  Result := sizeof(fReplyCode) + fReplyText.Size + sizeof(frclassid) +
    sizeof(frmethodid);
end;

class function amqp_method_close.method_id: amqp_short_uint;
begin
  Result := 50;
end;

procedure amqp_method_close.SetReplyText(const Value: AnsiString);
begin
 fReplyText.val := Value;
end;

{ amqp_method_close_ok }

class function amqp_method_close_ok.class_id: amqp_short_uint;
begin
  Result := 10;
end;

class function amqp_method_close_ok.create_frame(achannel: amqp_short_uint)
  : amqp_frame;
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
  fOutOfBand := amqp_short_str.Create;
end;

class function amqp_method_channel_open.create_frame(achannel: amqp_short_uint; aoutofband: AnsiString): amqp_frame;
begin
 result := new_frame(achannel);
 with amqp_method_channel_open(Result.AsMethod.method) do
  outofband := aoutofband;
end;

destructor amqp_method_channel_open.Destroy;
begin
  fOutOfBand.Free;
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

class function amqp_method_channel_open_ok.create_frame(achannel: amqp_short_uint; achannelid: AnsiString): amqp_frame;
begin
 result := new_frame(achannel);
 with amqp_method_channel_open_ok(Result.AsMethod.method) do
  ChannelId := achannelid;
end;

destructor amqp_method_channel_open_ok.Destroy;
begin
  FChannelId.Free;
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
  : amqp_frame;
begin
  Result := new_frame(achannel);
end;

function amqp_method_channel_class.GetSize: amqp_long_long_uint;
begin
  Result := 0;
end;

{ amqp_method_channel_flow }

class function amqp_method_channel_flow.create_frame(achannel: amqp_short_uint;
  aactive: amqp_bit): amqp_frame;
begin
  Result := new_frame(achannel);
  with amqp_method_channel_flow(Result.AsMethod.method) do
    active := aactive;
end;

procedure amqp_method_channel_flow.DoRead(AStream: TStream);
begin
  factive := ReadBoolean(AStream)
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
  fReplyText := amqp_short_str.Create;
end;

class function amqp_method_channel_close.create_frame(achannel,
  aReplyCode: amqp_short_uint; aReplyText: AnsiString;
  aClassId, AMethodId: amqp_short_uint): amqp_frame;
begin
  Result := inherited create_frame(achannel);
  with amqp_method_channel_close(Result.AsMethod.method) do
  begin
    replyCode := aReplyCode;
    replyText := aReplyText;
    frclassid := aClassId;
    frmethodid := AMethodId;
  end;
end;

destructor amqp_method_channel_close.Destroy;
begin
  fReplyText.Free;
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

{ amqp_method_channel_close_ok }

class function amqp_method_channel_close_ok.method_id: amqp_short_uint;
begin
  Result := 41;
end;

{ amqp_method_exchange_class }

class function amqp_method_exchange_class.class_id: amqp_short_uint;
begin
  Result := 40;
end;

{ amqp_method_exchange_declare }

constructor amqp_method_exchange_declare.Create;
begin
  inherited;
  Fexchange := amqp_exchange_name.Create;
  F_type := amqp_short_str.Create;
  Farguments := amqp_table.Create;
  FFlags := 0;
end;

class function amqp_method_exchange_declare.create_frame
  (achannel: amqp_short_uint; aexchange, atype: AnsiString;
  apassive, adurable, aauto_delete, ainternal, anowait: Boolean;
  aargs: amqp_table): amqp_frame;
begin
  Result := new_frame(achannel);
  with amqp_method_exchange_declare(Result.AsMethod.method) do
  begin
    exchange := aexchange;
    _type := atype;
    passive := apassive;
    durable := adurable;
    auto_delete := aauto_delete;
    internal := ainternal;
    nowait := anowait;
    if aargs <> nil then
      arguments.Assign(aargs)
    else
      arguments.Clear;
  end;
end;

destructor amqp_method_exchange_declare.Destroy;
begin
  Fexchange.Free;
  F_type.Free;
  Farguments.Free;
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
  (achannel: amqp_short_uint): amqp_frame;
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
  aifUnused, anowait: amqp_bit): amqp_frame;
begin
  Result := new_frame(achannel);
  with amqp_method_exchange_delete(Result.AsMethod.method) do
  begin
    exchange := aexchange;
    if_unused := aifUnused;
    no_wait := anowait;
  end;
end;

destructor amqp_method_exchange_delete.Destroy;
begin
  Fexchange.Free;
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
  aautodelete, anowait: amqp_bit; aargs: amqp_peer_properties): amqp_frame;
begin
  Result := new_frame(achannel);
  with amqp_method_queue_declare(Result.AsMethod.method) do
  begin
    ticket := aticket;
    queue := aqueue;
    durable := adurable;
    exclusive := aexclusive;
    auto_delete := aautodelete;
    no_wait := anowait;
    if aargs <> nil then
      arguments.Assign(aargs);
  end;
end;

destructor amqp_method_queue_declare.Destroy;
begin
  Fqueue.Free;
  Farguments.Free;
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
  : amqp_frame;
begin
  Result := new_frame(achannel);
  with amqp_method_queue_declare_ok(Result.AsMethod.method) do
  begin
    queue := aqueue;
    message_count := amessage_count;
    consumer_count := aconsumer_count;
  end;
end;

destructor amqp_method_queue_declare_ok.Destroy;
begin
  Fqueue.Free;
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
  Fexchange := amqp_exchange_name.Create;
  FroutingKey := amqp_short_str.Create;
  Farguments := amqp_peer_properties.Create;
end;

class function amqp_method_queue_bind.create_frame(achannel: amqp_short_uint;
  aticket: amqp_short_uint; aqueue, aexchange, aroutingkey: AnsiString;
  anowait: amqp_boolean; aargs: amqp_peer_properties): amqp_frame;
begin
  Result := new_frame(achannel);
  with amqp_method_queue_bind(Result.AsMethod.method) do
  begin
    fticket := aticket;
    queue := aqueue;
    exchange := aexchange;
    routingKey := aroutingkey;
    nowait := anowait;
    if aargs <> nil then
      arguments.Assign(aargs);
  end;
end;

destructor amqp_method_queue_bind.Destroy;
begin
  Fqueue.Free;
  Fexchange.Free;
  FroutingKey.Free;
  Farguments.Free;
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

function amqp_method_queue_bind.Getqueue: AnsiString;
begin
 Result := Fqueue.val;
end;

function amqp_method_queue_bind.GetroutingKey: AnsiString;
begin
 Result := FroutingKey.val;
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

procedure amqp_method_queue_bind.Setqueue(const Value: AnsiString);
begin
 Fqueue.val := Value;
end;

procedure amqp_method_queue_bind.SetroutingKey(const Value: AnsiString);
begin
 FroutingKey.val := Value;
end;

{ amqp_method_queue_bind_ok }

class function amqp_method_queue_bind_ok.method_id: amqp_short_uint;
begin
  Result := 21;
end;

{ amqp_method_queue_unbind }

class function amqp_method_queue_unbind.create_frame(achannel: amqp_short_uint;
  aticket: amqp_short_uint; aqueue, aexchange, aroutingkey: AnsiString;
  aargs: amqp_peer_properties): amqp_frame;
begin
  Result := new_frame(achannel);
  with amqp_method_queue_unbind(Result.AsMethod.method) do
  begin
    fticket := aticket;
    queue := aqueue;
    exchange := aexchange;
    routingKey := aroutingkey;
    if aargs <> nil then
      Farguments.Assign(aargs);
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
  : amqp_frame;
begin
  Result := new_frame(achannel);
  with amqp_method_queue_purge(Result.AsMethod.method) do
  begin
    ticket := aticket;
    queue := aqueue;
    nowait := anowait;
  end;
end;

destructor amqp_method_queue_purge.Destroy;
begin
  Fqueue.Free;
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

{ amqp_method_queue_purge_ok }

class function amqp_method_queue_purge_ok.create_frame
  (achannel: amqp_short_uint; amessage_count: amqp_message_count): amqp_frame;
begin
  Result := new_frame(achannel);
  with amqp_method_queue_purge_ok(Result.AsMethod.method) do
    Fmessage_count := amessage_count;
end;

procedure amqp_method_queue_purge_ok.DoRead(AStream: TStream);
begin
  Fmessage_count := ReadLongUInt(AStream)
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
  aifUnused, aIfEmpty, anowait: amqp_bit): amqp_frame;
begin
  Result := new_frame(achannel);
  with amqp_method_queue_delete(Result.AsMethod.method) do
  begin
    fticket := aticket;
    Fqueue.val := aqueue;
    ifUnused := aifUnused;
    ifempty := aIfEmpty;
    no_wait := anowait;
  end;
end;

destructor amqp_method_queue_delete.Destroy;
begin
  Fqueue.Free;
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
  aglobal: amqp_bit): amqp_frame;
begin
  Result := new_frame(achannel);
  with amqp_method_basic_qos(Result.AsMethod.method) do
  begin
    Fprefetchsize := aprefetchsize;
    FprefetchCount := aprefetchcount;
    Fglobal := aglobal;
  end;
end;

procedure amqp_method_basic_qos.DoRead(AStream: TStream);
begin
  Fprefetchsize := ReadLongUInt(AStream);
  FprefetchCount := ReadShortUInt(AStream);
  Fglobal := ReadBoolean(AStream);
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
  : amqp_frame;
begin
  Result := new_frame(achannel);
  with amqp_method_basic_consume(Result.AsMethod.method) do
  begin
    ticket := aticket;
    queue := aqueue;
    consumerTag := aconsumerTag;
    noLocal := aNoLocal;
    noAck := aNoAck;
    nowait := anowait;
    exclusive := aexclusive;
    Farguments.Assign(aargs);
  end;
end;

destructor amqp_method_basic_consume.Destroy;
begin
  Fqueue.Free;
  Farguments.Free;
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

{ amqp_method_basic_consume_ok }

constructor amqp_method_basic_consume_ok.Create;
begin
  inherited;
  FconsumerTag := amqp_consumer_tag.Create;
end;

class function amqp_method_basic_consume_ok.create_frame
  (achannel: amqp_short_uint; aconsumerTag: AnsiString): amqp_frame;
begin
  Result := new_frame(achannel);
  with amqp_method_basic_consume_ok(Result.AsMethod.method) do
  begin
    FconsumerTag.val := aconsumerTag;
  end;
end;

destructor amqp_method_basic_consume_ok.Destroy;
begin
  FconsumerTag.Free;
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
  aconsumerTag: AnsiString; anowait: amqp_bit): amqp_frame;
begin
  Result := new_frame(achannel);
  with amqp_method_basic_cancel(Result.AsMethod.method) do
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
  aMandatory, aImmediate: amqp_bit): amqp_frame;
begin
  Result := new_frame(achannel);
  with amqp_method_basic_publish(Result.AsMethod.method) do
  begin
    fticket := aticket;
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

{ amqp_method_basic_custom_return }

constructor amqp_method_basic_custom_return.Create;
begin
  inherited;
  Fexchange := amqp_exchange_name.Create;
  FroutingKey := amqp_short_str.Create;
end;

destructor amqp_method_basic_custom_return.Destroy;
begin
  Fexchange.Free;
  FroutingKey.Free;
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
  : amqp_frame;
begin
  Result := new_frame(achannel);
  with amqp_method_basic_return(Result.AsMethod.method) do
  begin
    ReplyCode := aReplyCode;
    ReplyText := aReplyText;
    exchange := aexchange;
    routingKey := aroutingkey;
  end;
end;

destructor amqp_method_basic_return.Destroy;
begin
  fReplyText.Free;
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
  FconsumerTag := amqp_consumer_tag.Create;
end;

class function amqp_method_basic_deliver.create_frame(achannel: amqp_short_uint;
  aconsumerTag: AnsiString; aDeliveryTag: amqp_delivery_tag;
  aRedelivered: amqp_redelivered; aexchange, aroutingkey: AnsiString)
  : amqp_frame;
begin
  Result := new_frame(achannel);
  with amqp_method_basic_deliver(Result.AsMethod.method) do
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
  FconsumerTag.Free;
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

{ amqp_content_header }

constructor amqp_content_header.Create;
begin
  inherited;
  Fheaders := amqp_table.Create;
  FcontentType := amqp_short_str.Create;
  FcontentEncoding := amqp_short_str.Create;
  FcorrelationId := amqp_correlation_id.Create;
  FreplyTo := amqp_reply_to.Create;
  Fexpiration := amqp_expiration.Create;
  FmessageId := amqp_message_id.Create;
  F_type := amqp_type.Create;
  FuserId := amqp_user_id.Create;
  FappId := amqp_app_id.Create;
  FclusterId := amqp_short_str.Create;
  FdeliveryMode := 1;
  FpropFlags := AMQP_BASIC_HEADERS_FLAG or AMQP_BASIC_DELIVERY_MODE_FLAG;
  Fweight := 0;
end;

class function amqp_content_header.create_frame(achannel, aclassid, aweight: amqp_short_uint;
  abodySize: amqp_long_long_uint): amqp_frame;
begin
 result := amqp_frame.Create;
 Result.fframe_type := AMQP_FRAME_HEADER;
 Result.fchannel := achannel;
 result.fpayload := amqp_content_header.Create;
 with amqp_content_header(Result.payload) do
  begin
    class_id := aclassid;
    weight := aweight;
    bodySize := abodySize;
  end;
end;

destructor amqp_content_header.Destroy;
begin
  Fheaders.Free;
  FcontentEncoding.Free;
  FcorrelationId.Free;
  FcontentType.Free;
  FreplyTo.Free;
  Fexpiration.Free;
  FmessageId.Free;
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

function amqp_content_header.Getexpiration: AnsiString;
begin
  Result := Fexpiration.val;
end;

function amqp_content_header.GetmessageId: AnsiString;
begin
  Result := FmessageId.val;
end;

function amqp_content_header.GetreplyTo: AnsiString;
begin
  Result := FreplyTo.val;
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

procedure amqp_content_header.SetappId(const Value: AnsiString);
begin
  if Value <> '' then
    FpropFlags := FpropFlags or AMQP_BASIC_APP_ID_FLAG
  else
    FpropFlags := FpropFlags and (not AMQP_BASIC_APP_ID_FLAG);
  FappId.val := Value;
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

{ amqp_content_body }

constructor amqp_content_body.Create(aLen: amqp_long_uint);
begin
  inherited Create;
  flen := aLen;
  FData := AllocMem(flen);
end;

class function amqp_content_body.create_frame(achannel: amqp_short_uint; alen: amqp_long_uint;
  adata: Pointer): amqp_frame;
begin
  Result := amqp_frame.Create;
  Result.fframe_type := AMQP_FRAME_BODY;
  Result.channel := achannel;
  Result.fpayload := amqp_content_body.Create(alen);
  Move(AData^, amqp_content_body(Result.payload).Data^, alen);
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
  aNoAck: amqp_no_ack): amqp_frame;
begin
 Result := new_frame(achannel);
 with amqp_method_basic_get(Result.AsMethod.method) do
  begin
    ticket := aticket;
    queue := aqueue;
    noAck := aNoAck;
  end;
end;

destructor amqp_method_basic_get.Destroy;
begin
  Fqueue.Free;
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

{ amqp_method_basic_get_ok }

constructor amqp_method_basic_get_ok.Create;
begin
  inherited;
 Fexchange := amqp_exchange_name.Create;
 FRoutingKey := amqp_short_str.Create;
end;

class function amqp_method_basic_get_ok.create_frame(achannel: amqp_short_uint; adeliveryTag: amqp_delivery_tag;
  aredelivered: amqp_redelivered; aexchange, aroutingKey: AnsiString; amessagecount: amqp_message_count): amqp_frame;
begin
 Result := new_frame(achannel);
 with amqp_method_basic_get_ok(Result.AsMethod.method) do
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
 Fexchange.Free;
 FRoutingKey.Free;
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

function amqp_method_basic_get_ok.GetRoutingKey: AnsiString;
begin
 Result := FRoutingKey.val;
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

class function amqp_method_basic_get_empty.create_frame(achannel: amqp_short_uint; aclusterId: AnsiString): amqp_frame;
begin
 Result := new_frame(achannel);
 with amqp_method_basic_get_empty(Result.AsMethod.method) do
    clusterId := aclusterId;
end;

destructor amqp_method_basic_get_empty.Destroy;
begin
  fclusterid.Free;
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
  amultiple: amqp_bit): amqp_frame;
begin
 result := new_frame(achannel);
 with amqp_method_basic_ack(Result.AsMethod.method) do
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

class function amqp_method_basic_recover_async.create_frame(achannel: amqp_short_uint; arequeue: amqp_bit): amqp_frame;
begin
 Result := new_frame(achannel);
 with amqp_method_basic_recover_async(Result.AsMethod.method) do
  requeue := arequeue;
end;

procedure amqp_method_basic_recover_async.DoRead(AStream: TStream);
begin
 Frequeue := ReadBoolean(AStream);
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
  amultiple, arequeue: amqp_bit): amqp_frame;
begin
 result := new_frame(achannel);
 with amqp_method_basic_nack(Result.AsMethod.method) do
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
begin
 Result := amqp_frame.Create;
 Result.fframe_type := AMQP_FRAME_HEARTBEAT;
 Result.fchannel := achannel;
 Result.fpayload := amqp_heartbeat.Create;
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

class function amqp_empty_method.method_id: amqp_short_uint;
begin
 Result := 0;
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

finalization

if famqp_method_factory <> nil then
  FreeAndNil(famqp_method_factory);

end.
