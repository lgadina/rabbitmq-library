{$i ampq2.inc}
unit ampq_intf;

{$IfDef FPC}
 {$mode objfpc}{$H+}
{$EndIf}

interface

uses
  Classes, SysUtils, amqp_types, amqp_classes;

type
  IAMQPChannel = interface;
{$IfDef USE_CONSUMER_THREAD}
  IAMQPChannelStat = interface;
{$EndIf}
  IAMQPConnection = interface;
  IAMQPMessage = interface;
  IAMQPChannelAck = interface;

  TAMQPConsumerMethod = procedure (AChannel: IAMQPChannel; AMQPMessage: IAMQPMessage; var SendAck: Boolean) of object;

  IAMQPQueue = interface
  ['{D460FA01-A169-456D-98F0-BBFD7B9E3B3C}']
    Function Count: Integer;
    Function AtLeast(ACount: Integer): Boolean;
    procedure Clear;
  end;

  { IAMQPConnection }

  IAMQPConnection = interface
  ['{FE0F59C9-0145-456A-BDE9-E2D6ADD75927}']
    procedure MessageException(AChannel: IAMQPChannel; AMessage: IAMQPMessage; AException: Exception);
    function GetMaxSize: Integer;
    function GetTimeout: Integer;
    procedure WriteFrame(AFrame: IAMQPFrame);
    function IsOpen: boolean;
    procedure InternalDisconnect(ACloseConnection: Boolean);
    procedure ServerDisconnect(ACode: Integer; AMessage: String);
    procedure CloseChannel(AChannel: IAMQPChannel);
    property Timeout: Integer read GetTimeout;
    property MaxSize: Integer read GetMaxSize;
  end;

 {$IfDef USE_CONSUMER_THREAD}
  { IAMQPConnectionStat }

  IAMQPConnectionStat = interface
  ['{22D65DC2-1D52-4F7F-BF28-08B39632A558}']
    function GetConsumerThreadCount: Integer;
    procedure IncConsumerCount;
    procedure DecConsumerCount;
    property ConsumerThreadCount: Integer read GetConsumerThreadCount;
  end;
 {$EndIf}

  IAMQPMessageQueue = interface(IAMQPQueue)
  ['{3E44FF6E-F0FF-4D31-A698-831BC4F513AA}']
    Function Push(AItem: IAMQPMessage): IAMQPMessage;
    Function Pop: IAMQPMessage;
    Function Peek: IAMQPMessage;
  end;


  { IAMQPChannelAck }

  IAMQPChannelAck = interface
  ['{CCB65C30-7D07-4929-9EE0-18620AC259BB}']
   function GetChannelId: Word;
   property ChannelId: Word read GetChannelId;
   Procedure BasicReject( AMessage: IAMQPMessage; ARequeue: Boolean = True ); overload;
   Procedure BasicReject( ADeliveryTag: UInt64; ARequeue: Boolean = True ); overload;
   procedure BasicNAck( AMessage: IAMQPMessage; ARequeue: Boolean = True;  AMultiple: Boolean = False ); Overload;
   Procedure BasicNAck( ADeliveryTag: UInt64; ARequeue: Boolean = True; AMultiple: Boolean = False ); Overload;
   Procedure BasicAck( AMessage: IAMQPMessage; AMultiple: Boolean = False ); Overload;
   Procedure BasicAck( ADeliveryTag: UInt64; AMultiple: Boolean = False ); Overload;
   Procedure MessageException(AMessage: IAMQPMessage; AException: Exception);
  end;

  { IAMQPChannel }

  IAMQPChannel = interface(IAMQPChannelAck)
  ['{CC242ECA-AA64-4301-A0BD-6C877A9F3DD0}']
    function GetId: Word;
    function GetIsOpen: Boolean;
    //function GetQueue: TAMQPFrameQueue;
    procedure ReceiveFrame(AFrame: IAMQPFrame);
    procedure PushFrame(AFrame: IAMQPFrame);
    function PopFrame: IAMQPFrame;
    procedure ChannelClosed;
    property Id: Word read GetId;
    //property Queue: TAMQPFrameQueue read GetQueue;
    property IsOpen: Boolean read GetIsOpen;
    procedure ConfirmSelect(ANoWait: Boolean);
    procedure CancelConsumers;
    Procedure ExchangeDeclare( AExchangeName, AType: String; AProperties: IAMQPProperties = nil; APassive: Boolean = False; ADurable : Boolean = True; AAutoDelete:
              Boolean = False; AInternal: Boolean = False; ANoWait: Boolean = False); overload;
    Procedure ExchangeDeclare( AExchangeName: String; AType: TAMQPExchangeType; AProperties: IAMQPProperties = nil; APassive: Boolean = False; ADurable : Boolean = True; AAutoDelete:
              Boolean = False; AInternal: Boolean = False; ANoWait: Boolean = False); overload;
    procedure ExchangeBind(ADestination, ASource: String; ARoutingKey: String = ''; ANoWait: Boolean = false); overload;
    procedure ExchangeBind(ADestination, ASource: String; AProperties: IAMQPProperties = nil; ARoutingKey: String = ''; ANoWait: Boolean = false); overload;
    Procedure ExchangeDelete( AExchangeName: String; AIfUnused: Boolean = True; ANoWait: Boolean = False );

    Procedure QueueDeclare( AQueueName: String; APassive: Boolean = False; ADurable: Boolean = True; AExclusive: Boolean = False;
                            AAutoDelete: Boolean = False; ANoWait: Boolean = False ); overload;
    Procedure QueueDeclare( AQueueName: String; AProperties: IAMQPProperties; APassive: Boolean = False; ADurable: Boolean = True; AExclusive: Boolean = False;
                            AAutoDelete: Boolean = False; ANoWait: Boolean = False ); overload;

    Procedure QueueBind( AQueueName, AExchangeName, ARoutingKey: String; AProperties: IAMQPProperties = nil; ANoWait: Boolean = False );
    function QueuePurge( AQueueName: String; ANoWait: Boolean = False ): Int64;
    function QueueDelete( AQueueName: String; AIfUnused: Boolean = True; AIfEmpty: Boolean = True; ANoWait: Boolean = False ): Int64;
    Procedure QueueUnBind( AQueueName, AExchangeName, ARoutingKey: String; AProperties: IAMQPProperties = nil );

    Procedure BasicPublish( AExchange, ARoutingKey: String; AMsg: IAMQPMessage ); Overload;
    Procedure BasicPublish( AMsg: IAMQPMessage ); Overload;
    Procedure BasicPublish(AExchange, ARoutingKey: AnsiString; AMandatory, AImmediate: Boolean; AContentType,
      AContentEncoding, ACorrelationId, AReplyTo, AExpiration, AMessageId, AType, AUserId, AAppId, AClusterId: AnsiString;
      ABody: TAMQPBody; ADeliveryMode: TAMQPDeliveryMode; APriority: Byte; ATimeStamp: TDateTime; AHeaders: IAMQPHeaders); overload;
    procedure BasicPublish(AExchange, ARoutingKey: String; AMandatory, AImmediate: Boolean;
              AContentType, AContentEncoding, ACorrelationId, AReplyTo, AExpiration,
              AMessageId, AType, AUserId, AAppId, AClusterId: String; ABody: Pointer;
              ABodySize: UInt64; ADeliveryMode: TAMQPDeliveryMode; APriority: Byte;
              ATimeStamp: TDateTime; AHeaders: IAMQPHeaders); overload;

    function BasicQOS(APrefetchSize, APrefetchCount: UInt64; AGlobal: Boolean = false): Boolean;

    function BasicGet(AQueueName: String; ANoAck: Boolean): IAMQPMessage;
    procedure BasicCancel(AConsumerTag: AnsiString; ANoWait: Boolean);
    procedure BasicConsume(AMessageQueue: IAMQPMessageQueue; AQueueName: String; var AConsumerTag: String; ANoLocal, ANoAck, AExclusive, ANoWait: Boolean); overload;
    Procedure BasicConsume( AMessageHandler: TAMQPConsumerMethod; AQueueName: String; var AConsumerTag: String; ANoLocal: Boolean = False;
                            ANoAck: Boolean = False; AExclusive: Boolean = False; ANoWait: Boolean = False ); Overload;
  end;

 {$IfDef USE_CONSUMER_THREAD}
  { IAMQPChannelStat }

  IAMQPChannelStat = interface
  ['{0E5110AE-5A64-4B9C-A45B-A9337EE80CDB}']
    function GetConsumerThreadCount: Integer;
    function GetChannelThreadCount: Integer;
    procedure IncConsumerThread;
    procedure DecConsumerThread;
    property ConsumerThreadCount: Integer read GetConsumerThreadCount;
    property ChannelThreadCount: Integer read GetChannelThreadCount;
  end;
 {$EndIf}

  { IAMQPMessage }

  IAMQPMessage = interface
  ['{23A8D576-7FE7-4393-87C3-B078CB987DF7}']
    function GetAppId: AnsiString;
    function GetBody: TAMQPBody;
    function GetBodyAsString: AnsiString;
{$IfDef FPC}
    function GetBodyHash: String;
{$EndIf}
    function GetBodySize: UInt64;
    function GetChannel: IAMQPChannelAck;
    function GetClusterId: AnsiString;
    function GetContentEncoding: AnsiString;
    function GetContentType: AnsiString;
    function GetCorrelationId: AnsiString;
    function GetDeliveryMode: TAMQPDeliveryMode;
    function GetDeliveryTag: UInt64;
    function GetExchange: AnsiString;
    function GetExpiration: AnsiString;
    function GetHdrAsBoolean(AName: AnsiString): Boolean;
    function GetHdrAsNumber(AName: AnsiString): Double;
    function GetHdrAsString(AName: AnsiString): AnsiString;
    function Getheaders: IAMQPHeaders;
    function GetMessageCount: Integer;
    function GetMessageId: AnsiString;
    function GetPriority: Byte;
    function GetpropFlags: Word;
    function GetRedelivered: Boolean;
    function GetReplyTo: AnsiString;
    function GetRoutingKey: AnsiString;
    function GetTimestamp: TDateTime;
    function GetType: AnsiString;
    function GetUserId: AnsiString;
    function GetWeight: Word;
    procedure SetAppId(AValue: AnsiString);
    procedure SetBodyAsString(AValue: AnsiString);
    procedure SetBodySize(const Value: UInt64);
    procedure SetChannel(AValue: IAMQPChannelAck);
    procedure SetClusterId(AValue: AnsiString);
    procedure SetContentEncoding(AValue: AnsiString);
    procedure SetContentType(AValue: AnsiString);
    procedure SetCorrelationId(AValue: AnsiString);
    procedure SetDeliveryMode(AValue: TAMQPDeliveryMode);
    procedure SetExchange(AValue: AnsiString);
    procedure SetExpiration(AValue: AnsiString);
    procedure SetHdrAsBoolean(AName: AnsiString; AValue: Boolean);
    procedure SetHdrAsNumber(AName: AnsiString; AValue: Double);
    procedure SetHdrAsString(AName: AnsiString; AValue: AnsiString);
    procedure SetHeaders(AValue: IAMQPHeaders);
    procedure SetMessageId(AValue: AnsiString);
    procedure SetPriority(AValue: Byte);
    procedure SetpropFlags(AValue: Word);
    procedure SetReplyTo(AValue: AnsiString);
    procedure SetRoutingKey(AValue: AnsiString);
    procedure SetTimestamp(AValue: TDateTime);
    procedure SetType(AValue: AnsiString);
    procedure SetUserId(AValue: AnsiString);
    procedure SetWeight(AValue: Word);
    procedure AssignFromContentHeader(AContentHeader: IAMQPContentHeader);
    procedure Assign(ASource: IAMQPMessage);
    procedure LoadBody(ABody: IAMQPContentBody);
    procedure LoadBodyFromStream(AStream: TStream; ASize: Int64);
    procedure LoadBodyFromString(AValue: AnsiString);
    procedure SaveBodyToStream(AStream: TStream);
    procedure SaveBodyToFile(AFileName: AnsiString);
    procedure AddHeaderString(AName, AValue: AnsiString);
    procedure AddHeaderBoolean(AName: AnsiString; AValue: Boolean);
    procedure AddHeaderNumber(AName: AnsiString; AValue: Double);
    procedure DeleteHeader(AName: AnsiString);
    procedure BodyFromBytes(ABytes: TBytes);
    procedure Ack;
    procedure NoAck(ARequeue: Boolean = True);

    property DeliveryTag: UInt64 read GetDeliveryTag;
    property Redelivered: Boolean read GetRedelivered;
    property Exchange: AnsiString read GetExchange write SetExchange;
    property RoutingKey: AnsiString read GetRoutingKey write SetRoutingKey;
    property MessageCount: Integer read GetMessageCount;
    property weight: Word read GetWeight write SetWeight;
    property BodySize: UInt64 read GetBodySize write SetBodySize;
    property propFlags: Word read GetpropFlags write SetpropFlags;
    property contentType: AnsiString read GetContentType write SetContentType;
    property contentEncoding: AnsiString read GetContentEncoding write SetContentEncoding;
    property headers: IAMQPHeaders read Getheaders write SetHeaders;
    property deliveryMode: TAMQPDeliveryMode read GetDeliveryMode write SetDeliveryMode;
    property priority: Byte read GetPriority write SetPriority;
    property correlationId: AnsiString read GetCorrelationId write SetCorrelationId;
    property replyTo: AnsiString read GetReplyTo write SetReplyTo;
    property expiration: AnsiString read GetExpiration write SetExpiration;
    property messageId: AnsiString read GetMessageId write SetMessageId;
    property timestamp: TDateTime read GetTimestamp write SetTimestamp;
    property &type: AnsiString read GetType write SetType;
    property userId: AnsiString read GetUserId write SetUserId;
    property appId: AnsiString read GetAppId write SetAppId;
    property clusterId: AnsiString read GetClusterId write SetClusterId;
    property Body: TAMQPBody read GetBody;
    property BodyAsString: AnsiString read GetBodyAsString write SetBodyAsString;
    property HdrAsString[AName: AnsiString]: AnsiString read GetHdrAsString write SetHdrAsString;
    property HdrAsBoolean[AName: AnsiString]: Boolean read GetHdrAsBoolean write SetHdrAsBoolean;
    property HdrAsNumber[AName: AnsiString]: Double read GetHdrAsNumber write SetHdrAsNumber;
{$IfDef FPC}
    property BodyHash: String read GetBodyHash;
{$EndIf}
    property Channel: IAMQPChannelAck read GetChannel write SetChannel;
  end;

implementation

end.

