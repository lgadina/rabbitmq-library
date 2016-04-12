unit amqp_connection;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IdTCPClient, amqp_types, contnrs, syncobjs, amqp_message, ipc, ctypes;

type

  TAMQPSemaphore = cint;

  { TSingletonImplementation }

  TSingletonImplementation = class(TObject, IInterface)
  protected
    function QueryInterface(constref IID: TGUID; out Obj): HResult; cdecl;
    function _AddRef: Integer; cdecl;
    function _Release: Integer; cdecl;
  end;

  EBlockedQueueException = class(Exception);
  EBlockedQueueTimeout = class(EBlockedQueueException);
  AMQPException = class(Exception);

  { TAMQPQueue }
  TAMQPChannelList = class;
  TAMQPChannelThreadList = class;
  IAMQPChannel = interface;
  IAMQPChannelStat = interface;

  TAMQPQueue = class(TInterfacedObject)
  private
    FList: TInterfaceList;
  protected
    Procedure PushItem(AItem: IUnknown); virtual;
    Function PopItem: IUnknown; virtual;
    Function PeekItem: IUnknown; virtual;
    property List: TInterfaceList read FList;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    Function Count: Integer;
    Function AtLeast(ACount: Integer): Boolean;
    Function Push(AItem: IUnknown): IUnknown;
    Function Pop: IUnknown;
    Function Peek: IUnknown;
    procedure Clear;
  end;

  { TAMQPBlockedQueued }

  TAMQPBlockedQueued = class(TAMQPQueue)
  strict private
    FEvent: TEvent;
    FTimeout: Integer;
  public
    constructor Create(ATimeOut: Integer); reintroduce; virtual;
    destructor Destroy; override;
    Function Push(AItem: IUnknown): IUnknown;
    Function Pop: IUnknown;
    property Timeout: Integer read FTimeout write FTimeout;
  end;

  { GAMQPFrameList }

  generic GAMQPFrameList<T> = class(TInterfaceList)
  private
    function GetItems(Index: Integer): T;
  public
    property Items[Index: Integer]: T read GetItems; default;
    function Extract(AItem: T): T;
  end;

  TAMQPFrameList = specialize GAMQPFrameList<IAMQPFrame>;


  { TAMQPFrameQueue }

  TAMQPFrameQueue = class(TAMQPBlockedQueued)
  private
  public
    Function Push(AItem: IAMQPFrame): IAMQPFrame;
    Function Pop: IAMQPFrame;
    Function Peek: IAMQPFrame;
  end;

  { TAMQPMessageQueue }

  TAMQPMessageQueue = class(TAMQPBlockedQueued)
  public
    Function Push(AItem: IAMQPMessage): IAMQPMessage;
    Function Pop: IAMQPMessage;
    Function Peek: IAMQPMessage;
  end;

  IAMQPConnection = interface;
  { TAMQPThread }

  TAMQPThread = class(TThread)
  strict private
    FConnection: IAMQPConnection;
    FTCP: TIdTCPClient;
    FMainQueue: TAMQPFrameQueue;
    FChannelList: TAMQPChannelThreadList;
  protected
    function FindChannel(AChannels: TAMQPChannelList; AChannelId: Word): IAMQPChannel;
    procedure Execute; override;
    function ReadFrame: IAMQPFrame;
    procedure SendFrameToMainChannel(AFrame: IAMQPFrame);
    procedure SendFrameToChannel(AFrame: IAMQPFrame);
    procedure SendHeartbeat;
    Procedure ServerDisconnect(ACode: Integer; Msg: String );
    procedure Disconnect(E: Exception);
    procedure SignalCloseToChannel;
  public
    constructor Create(AConnection: IAMQPConnection; ATCP: TIdTCPClient; AMainQueue: TAMQPFrameQueue; AChannelList: TAMQPChannelThreadList);
  end;

  TAMQPConsumerMethod = procedure (AChannel: IAMQPChannel; AMQPMessage: IAMQPMessage; var SendAck: Boolean) of object;

  { TAMQPConsumer }

  TAMQPConsumer = class
  strict private
    type

        { TConsumeThread }

        TConsumeThread = class(TThread)
        private
          FConsumer: TAMQPConsumer;
          FMessage: IAMQPMessage;
          FSendAck: Boolean;
          FSemaphore: TAMQPSemaphore;
        protected
          procedure Execute; override;
        public
         constructor Create(AConsumer: TAMQPConsumer; AMessage: IAMQPMessage; ASemaphore: TAMQPSemaphore = -1);
         destructor Destroy; override;
        end;

  private
    FConsumerTag: String;
    FMessageHandler: TAMQPConsumerMethod;
    FMessageQueue: TAMQPMessageQueue;
    FQueueName: String;
    FLock: TCriticalSection;
    FSemaphore: TAMQPSemaphore;
    FChannel: IAMQPChannel;
    FChannelStat: IAMQPChannelStat;
  protected
    procedure DoReceive(AChannel: IAMQPChannel; AMessage: IAMQPMessage; out SendAck: Boolean);
    procedure DoIncStat;
    procedure DoDecStat;
    procedure Lock;
    procedure Unlock;

  public
    Property QueueName      : String            read FQueueName;
    Property ConsumerTag    : String            read FConsumerTag;
    Property MessageHandler : TAMQPConsumerMethod   read FMessageHandler write FMessageHandler;
    Property MessageQueue   : TAMQPMessageQueue read FMessageQueue;
    Procedure Receive( AMessage: IAMQPMessage );
    Constructor Create( AChannel: IAMQPChannel; AQueueName, AConsumerTag: String; AMessageHandler: TAMQPConsumerMethod; AMessageQueue: TAMQPMessageQueue; ASemaphore: TAMQPSemaphore );
    Destructor Destroy; Override;
  end;

  TAMQPConsumerList = class;

  { TAMQPConsumerListEnumerator }

  TAMQPConsumerListEnumerator = class
  private
    FList: TAMQPConsumerList;
    FPosition: Integer;
  public
    constructor Create(AList: TAMQPConsumerList);
    function GetCurrent: TAMQPConsumer;
    function MoveNext: Boolean;
    property Current: TAMQPConsumer read GetCurrent;
  end;

  { TAMQPConsumerList }

  TAMQPConsumerList = class(TObjectList)
  private
    function GetConsumer(AConsumerTag: String): TAMQPConsumer;
    function GetItems(Index: Integer): TAMQPConsumer;
  public
    function GetEnumerator: TAMQPConsumerListEnumerator;
    property Items[Index: Integer]: TAMQPConsumer read GetItems;
    property Consumer[AConsumerTag: String]: TAMQPConsumer read GetConsumer; default;
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

  { IAMQPConnectionStat }

  IAMQPConnectionStat = interface
  ['{22D65DC2-1D52-4F7F-BF28-08B39632A558}']
    function GetConsumerThreadCount: Integer;
    procedure IncConsumerCount;
    procedure DecConsumerCount;
    property ConsumerThreadCount: Integer read GetConsumerThreadCount;
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
                            AAutoDelete: Boolean = False; ANoWait: Boolean = False );
    Procedure QueueDeclare( AQueueName: String; AProperties: IAMQPProperties; APassive: Boolean = False; ADurable: Boolean = True; AExclusive: Boolean = False;
                            AAutoDelete: Boolean = False; ANoWait: Boolean = False );

    Procedure QueueBind( AQueueName, AExchangeName, ARoutingKey: String; AProperties: IAMQPProperties = nil; ANoWait: Boolean = False );
    function QueuePurge( AQueueName: String; ANoWait: Boolean = False ): Int64;
    function QueueDelete( AQueueName: String; AIfUnused: Boolean = True; AIfEmpty: Boolean = True; ANoWait: Boolean = False ): Int64;
    Procedure QueueUnBind( AQueueName, AExchangeName, ARoutingKey: String; AProperties: IAMQPProperties = nil );

    Procedure BasicPublish( AExchange, ARoutingKey: String; AMsg: IAMQPMessage ); Overload;
    Procedure BasicPublish( AMsg: IAMQPMessage ); Overload;
    Procedure BasicPublish(AExchange, ARoutingKey: AnsiString; AMandatory, AImmediate: Boolean; AContentType,
      AContentEncoding, ACorrelationId, AReplyTo, AExpiration, AMessageId, AType, AUserId, AAppId, AClusterId: AnsiString;
      ABody: TAMQPBody; ADeliveryMode: TAMQPDeliveryMode; APriority: Byte; ATimeStamp: TDateTime; AHeaders: IAMQPHeaders);
    procedure BasicPublish(AExchange, ARoutingKey: String; AMandatory, AImmediate: Boolean;
              AContentType, AContentEncoding, ACorrelationId, AReplyTo, AExpiration,
              AMessageId, AType, AUserId, AAppId, AClusterId: String; ABody: Pointer;
              ABodySize: UInt64; ADeliveryMode: TAMQPDeliveryMode; APriority: Byte;
              ATimeStamp: TDateTime; AHeaders: IAMQPHeaders);

    function BasicQOS(APrefetchSize, APrefetchCount: UInt64; AGlobal: Boolean = false): Boolean;

    function BasicGet(AQueueName: String; ANoAck: Boolean): IAMQPMessage;
    procedure BasicCancel(AConsumerTag: AnsiString; ANoWait: Boolean);
    procedure BasicConsume(AMessageQueue: TAMQPMessageQueue; AQueueName: String; var AConsumerTag: String; ANoLocal, ANoAck, AExclusive, ANoWait: Boolean);
    Procedure BasicConsume( AMessageHandler: TAMQPConsumerMethod; AQueueName: String; var AConsumerTag: String; ANoLocal: Boolean = False;
                            ANoAck: Boolean = False; AExclusive: Boolean = False; ANoWait: Boolean = False ); Overload;
  end;

  { IAMQPChannelStat }

  IAMQPChannelStat = interface
  ['{0E5110AE-5A64-4B9C-A45B-A9337EE80CDB}']
    function GetConsumerThreadCount: Integer;
    procedure IncConsumerThread;
    procedure DecConsumerThread;
    property ConsumerThreadCount: Integer read GetConsumerThreadCount;
  end;


  { TAMQPChannelListEnumerator }

  TAMQPChannelListEnumerator = class
  private
    FList: TAMQPChannelList;
    FPosition: Integer;
  public
    constructor Create(AList: TAMQPChannelList);
    function GetCurrent: IAMQPChannel;
    function MoveNext: Boolean;
    property Current: IAMQPChannel read GetCurrent;
  end;

  { TAMQPChannelList }

  TAMQPChannelList = class(TInterfaceList)
  private
    function GetItems(Index: Integer): IAMQPChannel;
  public
    property Items[Index: Integer]: IAMQPChannel read GetItems; default;
    function GetEnumerator: TAMQPChannelListEnumerator;
  end;

  { TAMQPChannelThreadList }

  TAMQPChannelThreadList = class
  private
    FList: TAMQPChannelList;
    FLock: TRTLCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(Item: IAMQPChannel);
    procedure Clear;
    function  LockList: TAMQPChannelList;
    procedure Remove(Item: IAMQPChannel);
    procedure UnlockList;
  end;

  { TAMQPChannel }

  TAMQPChannel = class(TInterfacedObject, IAMQPChannel, IAMQPChannelAck, IAMQPChannelStat)
  strict private
    FConnection: IAMQPConnection;
    FConnectionStat: IAMQPConnectionStat;
    FID: Word;
    FConfirmSelect: Boolean;
    FQueue: TAMQPFrameQueue;
    FConsumers: TAMQPConsumerList;
    FDeliverConsumer: TAMQPConsumer;
    FDeliverQueue: TAMQPFrameList;
    FTimeout: Integer;
    FSemaphore: TAMQPSemaphore;
    function GetConsumerThreadCount: Integer;
    function GetIsOpen: boolean;
    function GetQueue: TAMQPFrameQueue;
    function GetTimeout: Integer;
    procedure SetTimeout(AValue: Integer);
  protected
    procedure AddConsumer(AQueueName: String; var AConsumerTag: String; AMessageHandler: TAMQPConsumerMethod; AMessageQueue: TAMQPMessageQueue);
    procedure RemoveConsumer(AConsumerTag: String);
    Function HasCompleteMessageInQueue( AQueue: TAMQPFrameList): Boolean;
    procedure CheckDeliveryComplete;
    Function GetMessageFromQueue( AQueue: TAMQPFrameList): IAMQPMessage;
    procedure DoReceiveFrame(AFrame: IAMQPFrame);
    procedure ReceiveFrame(AFrame: IAMQPFrame);
    procedure PushFrame(AFrame: IAMQPFrame);
    procedure Deliver(AFrame: IAMQPFrame);
    function GetId: Word;
    procedure ChannelClosed;
    procedure CheckOpen;
    procedure WriteFrame(AFrame: IAMQPFrame);
    procedure MessageException(AMessage: IAMQPMessage; AException: Exception);
    function PopFrame: IAMQPFrame;
    function ReadMethod(AExpected: array of TGUID): IAMQPFrame;
    procedure UnexpectedFrameReceived( AFrame: IAMQPFrame);
    function GetChannelId: Word;
    procedure CancelConsumers;
    procedure IncConsumerThread;
    procedure DecConsumerThread;
    property ConsumerThreadCount: Integer read GetConsumerThreadCount;
  public
    constructor Create(AConnection: IAMQPConnection; AChannelId: Word; ASemaphore: TAMQPSemaphore);
    destructor Destroy; override;
    property Id: Word read GetId;
    property Queue: TAMQPFrameQueue read GetQueue;

    property IsOpen: boolean read GetIsOpen;
    property Timeout: Integer read GetTimeout write SetTimeout;

    Procedure ExchangeDeclare( AExchangeName, AType: String; AProperties: IAMQPProperties = nil; APassive: Boolean = False; ADurable : Boolean = True; AAutoDelete:
              Boolean = False; AInternal: Boolean = False; ANoWait: Boolean = False); overload;
    Procedure ExchangeDeclare( AExchangeName: String; AType: TAMQPExchangeType; AProperties: IAMQPProperties = nil; APassive: Boolean = False; ADurable : Boolean = True; AAutoDelete:
              Boolean = False; AInternal: Boolean = False; ANoWait: Boolean = False); overload;
    procedure ExchangeBind(ADestination, ASource: String; ARoutingKey: String = ''; ANoWait: Boolean = false); overload;
    procedure ExchangeBind(ADestination, ASource: String; AProperties: IAMQPProperties = nil; ARoutingKey: String = ''; ANoWait: Boolean = false); overload;
    Procedure ExchangeDelete( AExchangeName: String; AIfUnused: Boolean = True; ANoWait: Boolean = False );

    Procedure QueueDeclare( AQueueName: String; APassive: Boolean = False; ADurable: Boolean = True; AExclusive: Boolean = False;
                            AAutoDelete: Boolean = False; ANoWait: Boolean = False );
    Procedure QueueDeclare( AQueueName: String; AProperties: IAMQPProperties; APassive: Boolean = False; ADurable: Boolean = True; AExclusive: Boolean = False;
                            AAutoDelete: Boolean = False; ANoWait: Boolean = False );

    Procedure QueueBind( AQueueName, AExchangeName, ARoutingKey: String; AProperties: IAMQPProperties = nil; ANoWait: Boolean = False );
    function QueuePurge( AQueueName: String; ANoWait: Boolean = False ): Int64;
    function QueueDelete( AQueueName: String; AIfUnused: Boolean = True; AIfEmpty: Boolean = True; ANoWait: Boolean = False ): Int64;
    Procedure QueueUnBind( AQueueName, AExchangeName, ARoutingKey: String; AProperties: IAMQPProperties = nil );

    Procedure BasicPublish( AExchange, ARoutingKey: String; AMsg: IAMQPMessage ); Overload;
    Procedure BasicPublish( AMsg: IAMQPMessage ); Overload;
    Procedure BasicPublish(AExchange, ARoutingKey: AnsiString; AMandatory, AImmediate: Boolean; AContentType,
      AContentEncoding, ACorrelationId, AReplyTo, AExpiration, AMessageId, AType, AUserId, AAppId, AClusterId: AnsiString;
      ABody: TAMQPBody; ADeliveryMode: TAMQPDeliveryMode; APriority: Byte; ATimeStamp: TDateTime; AHeaders: IAMQPHeaders);
    procedure BasicPublish(AExchange, ARoutingKey: String; AMandatory, AImmediate: Boolean;
              AContentType, AContentEncoding, ACorrelationId, AReplyTo, AExpiration,
              AMessageId, AType, AUserId, AAppId, AClusterId: String; ABody: Pointer;
              ABodySize: UInt64; ADeliveryMode: TAMQPDeliveryMode; APriority: Byte;
              ATimeStamp: TDateTime; AHeaders: IAMQPHeaders);

    procedure ConfirmSelect(ANoWait: Boolean);
    function BasicQOS(APrefetchSize, APrefetchCount: UInt64; AGlobal: Boolean = false): Boolean;

    function BasicGet(AQueueName: String; ANoAck: Boolean): IAMQPMessage;
    procedure BasicCancel(AConsumerTag: AnsiString; ANoWait: Boolean);
    procedure BasicConsume(AMessageQueue: TAMQPMessageQueue; AQueueName: String; var AConsumerTag: String; ANoLocal, ANoAck, AExclusive, ANoWait: Boolean);
    Procedure BasicConsume( AMessageHandler: TAMQPConsumerMethod; AQueueName: String; var AConsumerTag: String; ANoLocal: Boolean = False;
                            ANoAck: Boolean = False; AExclusive: Boolean = False; ANoWait: Boolean = False ); Overload;


    Procedure BasicReject( AMessage: IAMQPMessage; ARequeue: Boolean = True ); overload;
    Procedure BasicReject( ADeliveryTag: UInt64; ARequeue: Boolean = True ); overload;
    procedure BasicNAck( AMessage: IAMQPMessage; ARequeue: Boolean = True;  AMultiple: Boolean = False ); Overload;
    Procedure BasicNAck( ADeliveryTag: UInt64; ARequeue: Boolean = True; AMultiple: Boolean = False ); Overload;
    Procedure BasicAck( AMessage: IAMQPMessage; AMultiple: Boolean = False ); Overload;
    Procedure BasicAck( ADeliveryTag: UInt64; AMultiple: Boolean = False ); Overload;

  end;

  TAMQPOnChannelClose = procedure(AObject: TObject; AChannel: IAMQPChannel) of object;
  TAMQPOnMessageException = procedure(AObject: TObject; AChannel: IAMQPChannel; AMessage: IAMQPMessage; AException: Exception) of object;

  { TAMQPConnection }

  TAMQPConnection = class(TSingletonImplementation, IAMQPConnection, IAMQPConnectionStat)
  private
    FOnChannelClose: TAMQPOnChannelClose;
    FOnChannelCloseServer: TAMQPOnChannelClose;
    FOnMessageException: TAMQPOnMessageException;
    FTCP: TIdTCPClient;
    FHost: String;
    FPort: Word;
    FUsername: String;
    FPassword: String;
    FVirtualhost: String;
    FThread: TAMQPThread;
    FMainQueue: TAMQPFrameQueue;
    FIsOpen: Boolean;
    FServerDisconnected: Boolean;
    FChannelList: TAMQPChannelThreadList;
    Ftimeout: Integer;
    FMaxSize: Integer;
    FSemaphore: cint;
    FMaxThread: Word;
    FConsumerThreadCount: Cardinal;
    function GetConsumerThreadCount: Integer;
    function GetHost: String;
    function GetMaxSize: Integer;
    function GetMaxThread: Word;
    function GetPassword: String;
    function GetPort: Word;
    function GetTimeOut: Integer;
    function GetUsername: String;
    function GetVirtualHost: String;
    procedure SetHost(AValue: String);
    procedure SetMaxSize(AValue: Integer);
    procedure SetMaxThread(AValue: Word);
    procedure SetPassword(AValue: String);
    procedure SetPort(AValue: Word);
    procedure SetTimeout(AValue: Integer);
    procedure SetUsername(AValue: String);
    procedure SetVirtualHost(AValue: String);
  protected
    procedure IncConsumerCount;
    procedure DecConsumerCount;
    function ThreadRunning: Boolean;
    function ReadFrame: IAMQPFrame;
    function ReadMethod(AExpected: array of TGUID): IAMQPFrame;
    procedure DoOnChannelClose(AChannel: IAMQPChannel);
    procedure DoOnChannelCloseServer(AChannel: IAMQPChannel);
    procedure DoOnMessageException(AChannel: IAMQPChannel; AMessage: IAMQPMessage; AException: Exception);
    procedure WriteFrame(AFrame: IAMQPFrame);
    procedure CloseConnection;
    procedure CloseAllChannels;
    procedure InternalDisconnect(ACloseConnection: Boolean);
    procedure ServerDisconnect(ACode: Integer; AMessage: String);
    procedure ProtocolError(AErrorMessage: String; AFrame: IAMQPFrame);
    property ConsumerThreadCount: Integer read GetConsumerThreadCount;
    function MakeChannel: IAMQPChannel;
    procedure CloseChannelOnServer(AChannel: IAMQPChannel);
    Function ChannelNeedsToBeClosedOnServer(AChannel: IAMQPChannel): Boolean;
    procedure MessageException(AChannel: IAMQPChannel; AMessage: IAMQPMessage; AException: Exception);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Connect;
    procedure Disconnect;
    property MaxThread: Word read GetMaxThread write SetMaxThread;
    property Host: String read GetHost write SetHost;
    property Port: Word read GetPort write SetPort;
    property VirtualHost: String read GetVirtualHost write SetVirtualHost;
    property Username: String read GetUsername write SetUsername;
    property Password: String read GetPassword write SetPassword;
    property Timeout: Integer read GetTimeOut write SetTimeout;
    function IsOpen: boolean;
    function IsConnected: Boolean;
    function OpenChannel: IAMQPChannel;
    property MaxSize: Integer read GetMaxSize write SetMaxSize;
    procedure CloseChannel(AChannel: IAMQPChannel);
    property OnChannelClose: TAMQPOnChannelClose read FOnChannelClose write FOnChannelClose;
    property OnChannelCloseServer: TAMQPOnChannelClose read FOnChannelCloseServer write FOnChannelCloseServer;
    property OnMessageException: TAMQPOnMessageException read FOnMessageException write FOnMessageException;
  end;

implementation

uses IdGlobal, IdException, IdExceptionCore, IdStack, dateutils;

const
     cConsumerLock : TSEMbuf = (sem_num:0;sem_op:-1;sem_flg:0);
     cConsumerInlock: TSEMbuf = (sem_num:0;sem_op:1;sem_flg:0);

{$IfDef AMQP_DEBUG}
var
  DbgLock: TRTLCriticalSection;

procedure DbgWriteln(AMsg: String);
begin
 EnterCriticalsection(DbgLock);
 try
  Writeln(AMsg);
 finally
  LeaveCriticalsection(DbgLock);
 end;
end;

{$EndIf}

function DumpIObj(AObj: IUnknown): String;
var S: IAMQPObject;
begin
 Result := PtrInt(Pointer(AObj)).ToString;
 if Supports(AObj, IAMQPObject, S) then
  Result := Result + ':' + s.AsDebugString;
end;

{ TAMQPConsumer.TConsumeThread }

procedure TAMQPConsumer.TConsumeThread.Execute;
begin
 {$IfDef AMQP_DEBUG}
  DbgWriteln(ToString+'.Execute:'+FConsumer.FConsumerThreadCount.ToString+':'+FConsumer.ConsumerTag);
 {$EndIf}
 try
  FConsumer.DoReceive(FConsumer.FChannel,  FMessage, FSendAck);
 finally
  Terminate;
 end;
end;

constructor TAMQPConsumer.TConsumeThread.Create(AConsumer: TAMQPConsumer;
  AMessage: IAMQPMessage; ASemaphore: TAMQPSemaphore = -1);
begin
  FSemaphore := ASemaphore;
  FConsumer := AConsumer;

  FMessage := AMessage;
  FreeOnTerminate := True;
  {$IfDef AMQP_DEBUG}
  DbgWriteln(ToString+'.Create:'+FConsumer.FConsumerThreadCount.ToString()+':'+FConsumer.ConsumerTag);
  {$EndIf}
   if FSemaphore > -1 then
    if semop(FSemaphore, @cConsumerLock, 1) = -1 then
      RaiseLastOSError(GetLastOSError);
  FConsumer.DoIncStat;
  inherited Create(False);
end;

destructor TAMQPConsumer.TConsumeThread.Destroy;
begin
 if FSendAck then
  FMessage.Ack;
 {$IfDef AMQP_DEBUG}
 DbgWriteln(ToString+'.Destroy:'+FConsumer.FConsumerThreadCount.ToString()+':'+FConsumer.ConsumerTag);
 {$EndIf}
 try
  if Assigned(FConsumer) then
    FConsumer.DoDecStat;
 except
   on E: Exception do ;
 end;
  if FSemaphore > -1 then
   if semop(FSemaphore, @cConsumerInlock, 1) = -1 then
     RaiseLastOSError(GetLastOSError);
 inherited Destroy;
end;


{ TAMQPChannelThreadList }

constructor TAMQPChannelThreadList.Create;
begin
  FList := TAMQPChannelList.Create;
  InitCriticalSection(FLock);
end;

destructor TAMQPChannelThreadList.Destroy;
begin
  FList.Free;
  DoneCriticalsection(FLock);
  inherited Destroy;
end;

procedure TAMQPChannelThreadList.Add(Item: IAMQPChannel);
begin
 LockList;
 try
   FList.Add(Item);
 finally
  UnlockList;
 end;
end;

procedure TAMQPChannelThreadList.Clear;
begin
  LockList;
  try
    FList.Clear;
  finally
   UnlockList;
  end;
end;

function TAMQPChannelThreadList.LockList: TAMQPChannelList;
begin
  Result := FList;
  system.EnterCriticalsection(FLock);
end;

procedure TAMQPChannelThreadList.Remove(Item: IAMQPChannel);
begin
 LockList;
 try
   FList.Remove(Item);
 finally
  UnlockList;
 end;
end;

procedure TAMQPChannelThreadList.UnlockList;
begin
  system.LeaveCriticalsection(FLock);
end;

{ TAMQPFrameList }

function GAMQPFrameList.GetItems(Index: Integer): T;
begin
  Result := inherited Items[Index] as T;
end;

function GAMQPFrameList.Extract(AItem: T): T;
begin
  Result := AItem;
  Remove(AItem);
end;

{ TAMQPConsumerListEnumerator }

constructor TAMQPConsumerListEnumerator.Create(AList: TAMQPConsumerList);
begin
  FList := AList;
  FPosition := -1;
end;

function TAMQPConsumerListEnumerator.GetCurrent: TAMQPConsumer;
begin
 Result :=FList.Items[FPosition];
end;

function TAMQPConsumerListEnumerator.MoveNext: Boolean;
begin
 inc(FPosition);
 Result := FPosition < FList.Count;
end;

{ TAMQPConsumerList }

function TAMQPConsumerList.GetConsumer(AConsumerTag: String): TAMQPConsumer;
var Obj: TAMQPConsumer;
begin
 for Obj in Self do
   if AConsumerTag = Obj.ConsumerTag then
    Exit(Obj);
 Result := nil;
end;

function TAMQPConsumerList.GetItems(Index: Integer): TAMQPConsumer;
begin
  Result := TAMQPConsumer(inherited Items[Index]);
end;

function TAMQPConsumerList.GetEnumerator: TAMQPConsumerListEnumerator;
begin
  Result := TAMQPConsumerListEnumerator.Create(Self);
end;


{ TAMQPChannelListEnumerator }

constructor TAMQPChannelListEnumerator.Create(AList: TAMQPChannelList);
begin
  FList := AList;
  FPosition := -1;
end;

function TAMQPChannelListEnumerator.GetCurrent: IAMQPChannel;
begin
 Result := FList[FPosition];
end;

function TAMQPChannelListEnumerator.MoveNext: Boolean;
begin
 Inc(FPosition);
 Result := FPosition < FList.Count;
end;

{ TAMQPChannelList }

function TAMQPChannelList.GetItems(Index: Integer): IAMQPChannel;
begin
  Result := inherited Items[Index] as IAMQPChannel;
end;

function TAMQPChannelList.GetEnumerator: TAMQPChannelListEnumerator;
begin
  Result := TAMQPChannelListEnumerator.Create(Self);
end;

{ TAMQPChannel }

function TAMQPChannel.GetQueue: TAMQPFrameQueue;
begin
  Result := FQueue;
end;

function TAMQPChannel.GetTimeout: Integer;
begin
  Result := FTimeout;
end;

procedure TAMQPChannel.SetTimeout(AValue: Integer);
begin
 FTimeout := AValue;
end;

procedure TAMQPChannel.AddConsumer(AQueueName: String;
  var AConsumerTag: String; AMessageHandler: TAMQPConsumerMethod;
  AMessageQueue: TAMQPMessageQueue);
var
  Consumer: TAMQPConsumer;
begin
 if AConsumerTag = '' then
  AConsumerTag := TGuid.NewGuid.ToString(True);

  for Consumer in FConsumers do
    if (Consumer.ConsumerTag = AConsumerTag) then
      raise AMQPException.Create('Duplicate consumer');
  FConsumers.Add(TAMQPConsumer.Create(Self, AQueueName, AConsumerTag, AMessageHandler, AMessageQueue, FSemaphore ) );
end;

procedure TAMQPChannel.RemoveConsumer(AConsumerTag: String);
var Consumer: TAMQPConsumer;
begin
 Consumer := FConsumers[AConsumerTag];
 if Consumer <> nil then
  FConsumers.Remove(Consumer);
end;

function TAMQPChannel.HasCompleteMessageInQueue(
  AQueue: TAMQPFrameList): Boolean;
var
  HeaderFrame: IAMQPFrame;
  Size, Received: UInt64;
  Index: Integer;
  ContentHdr: IAMQPContentHeader;
begin
  Result := False;
  if AQueue.Count >= 2 then
  Begin
  //DeliverFrame := AQueue[0]; <-- Dont need this frame here
    HeaderFrame  := AQueue[1];
    {$ifdef AMQP_DEBUG}
    DbgWriteLn(ToString+'.HasCompleteMessageInQueue:'+DumpIObj(HeaderFrame));
    {$endif}
    if HeaderFrame.frame_type = AMQP_FRAME_HEADER then
    begin
      ContentHdr := HeaderFrame.AsContentHeader;
      Size         := ContentHdr.bodySize;
      Received     := 0;
      Index := 2;
      While (Index < AQueue.Count) and
            (AQueue[Index].frame_type = AMQP_FRAME_BODY) and
            (Received < Size) do
      Begin
        Received := Received + AQueue[Index].AsContentBody.len;
        Inc( Index );
      End;
      Result := (Received >= Size);
    end;
  End;
end;

procedure TAMQPChannel.CheckDeliveryComplete;
begin
  if HasCompleteMessageInQueue( FDeliverQueue ) then
  Try
    FDeliverConsumer.Receive( GetMessageFromQueue( FDeliverQueue ) );
  Finally
    FDeliverConsumer := nil;
  End;
end;

function TAMQPChannel.GetMessageFromQueue(AQueue: TAMQPFrameList): IAMQPMessage;
var
  DeliverFrame : IAMQPFrame;
  HeaderFrame  : IAMQPFrame;
  BodyFrame    : IAMQPFrame;
  ContentHdr   : IAMQPContentHeader;
  sz: Int64;
  bodySz: Int64;
begin
  DeliverFrame := FDeliverQueue.Extract( FDeliverQueue[0] );
  HeaderFrame  := FDeliverQueue.Extract( FDeliverQueue[0] );
  Result := TAMQPMessage.CreateBasicDeliver(DeliverFrame.AsMethod as IAMQPBasicDeliver);
  Result.Channel := Self;
  ContentHdr := HeaderFrame.AsContentHeader;
  Result.AssignFromContentHeader(ContentHdr);
  BodySz := ContentHdr.bodySize;
  sz := 0;
  Try
    Repeat
      BodyFrame := FDeliverQueue.Extract( FDeliverQueue[0] );
      Result.LoadBody(BodyFrame.AsContentBody);
      sz := BodyFrame.AsContentBody.len + sz;
      BodyFrame := nil;
    Until Sz >= bodySz;
  Finally
    DeliverFrame := nil;
    HeaderFrame  := nil;
  End;
end;

procedure TAMQPChannel.DoReceiveFrame(AFrame: IAMQPFrame);
begin
  if AFrame.AsContainer <> nil then
  begin
   if AFrame.AsContainer.method <> nil then
    begin
     if Supports(AFrame.AsMethod, IAMQPBasicDeliver) then
       Deliver(AFrame)
     else
     if Assigned(FDeliverConsumer) then
     begin
       FDeliverQueue.Add(AFrame);
       CheckDeliveryComplete;
     end
     else
      FQueue.Push(AFrame);
   end;
  end else
  if (AFrame.frame_type = AMQP_FRAME_HEADER) or (AFrame.frame_type = AMQP_FRAME_BODY) then
  begin
   FDeliverQueue.Add(AFrame);
   CheckDeliveryComplete;
  end
  else
   FQueue.Push(AFrame);
end;

function TAMQPChannel.GetIsOpen: boolean;
begin
  Result := FConnection <> nil;
end;

function TAMQPChannel.GetConsumerThreadCount: Integer;
begin
  if FConnectionStat <> nil then
   Result := FConnectionStat.ConsumerThreadCount;
end;

procedure TAMQPChannel.ReceiveFrame(AFrame: IAMQPFrame);
begin
  DoReceiveFrame(AFrame);
end;

procedure TAMQPChannel.PushFrame(AFrame: IAMQPFrame);
begin
  {$ifdef AMQP_DEBUG}
  DbgWriteLn(ClassName+'.PushFrame:'+DumpIObj(AFrame));
  {$EndIf}
  FQueue.Push(AFrame);
end;

procedure TAMQPChannel.Deliver(AFrame: IAMQPFrame);
var D: IAMQPBasicDeliver;

begin
  if Supports(AFrame.AsMethod, IAMQPBasicDeliver, D) then
   begin
     FDeliverConsumer := FConsumers[d.consumerTag];
     if FDeliverConsumer <> nil then
       //raise AMQPException.CreateFmt('No consumer for consumer-tag: %s', [d.consumerTag]);
      FDeliverQueue.Add(AFrame);
   end;
end;

function TAMQPChannel.GetId: Word;
begin
  Result := FID;
end;

procedure TAMQPChannel.ChannelClosed;
begin
  FConnectionStat := nil;
  FConnection := nil;

  {$ifdef AMQP_DEBUG}
  DbgWriteLn(ToString+'.ChannelClosed:'+FID.ToString);
  {$EndIf}
  FConsumers.Clear;
end;

procedure TAMQPChannel.CheckOpen;
begin
  if FConnection = nil then
    raise AMQPException.Create('Channel is not open');
  if not FConnection.IsOpen then
    raise AMQPException.Create('Connection is not open');
end;

procedure TAMQPChannel.WriteFrame(AFrame: IAMQPFrame);
begin
  CheckOpen;
  FConnection.WriteFrame(AFrame);
end;

procedure TAMQPChannel.MessageException(AMessage: IAMQPMessage;
  AException: Exception);
begin
  if FConnection <> nil then
   FConnection.MessageException(Self, AMessage, AException);
end;

function TAMQPChannel.ReadMethod(AExpected: array of TGUID): IAMQPFrame;
var MethodIsExpected: Boolean;
    Method: TGuid;
begin
  CheckOpen;
  repeat
    try
     Result := FQueue.Pop;
    except
      on E: EBlockedQueueTimeout do
       begin

       end
      else
       raise;
    end;
  until Result.frame_type <> AMQP_FRAME_HEARTBEAT;

  if (Result.AsContainer.method = nil) then
    raise AMQPException.Create('Frame does not contain a method');

  MethodIsExpected := False;
  for Method in AExpected do
    if Supports(Result.AsContainer.method, Method) then
      MethodIsExpected := True;

  if not MethodIsExpected then
    UnexpectedFrameReceived(Result);
end;

procedure TAMQPChannel.UnexpectedFrameReceived(AFrame: IAMQPFrame);
var
  TempConnection: IAMQPConnection;
  cc: IAMQPChannelClose;
  frame: IAMQPFrame;
begin
  if Supports(AFrame.AsContainer.method,  IAMQPChannelClose, cc) then
  Begin
    TempConnection := FConnection;
    frame := amqp_method_channel_close_ok.create_frame(FID);
    TempConnection.WriteFrame(frame);
    FConnection := nil; //to signal that this channel is closed
    FConnectionStat := nil;
    TempConnection.CloseChannel( Self );
    raise AMQPException.CreateFmt( 'Channel closed unexpectedly be server: %d %s',
                                   [ cc.replyCode,
                                     cc.replyText ] );
  End
  else
    raise AMQPException.CreateFmt( 'Unexpected class/method: %d.%d',
                                   [ AFrame.AsContainer.class_id, AFrame.AsContainer.method_id ] );
end;

function TAMQPChannel.GetChannelId: Word;
begin
  Result := GetId;
end;

procedure TAMQPChannel.CancelConsumers;
begin
  while FConsumers.Count > 0 do
   BasicCancel(FConsumers.Items[0].ConsumerTag, False);
end;

procedure TAMQPChannel.IncConsumerThread;
begin
  if FConnectionStat <> nil then
   FConnectionStat.IncConsumerCount;
end;

procedure TAMQPChannel.DecConsumerThread;
begin
  if FConnectionStat <> nil then
   FConnectionStat.DecConsumerCount;
end;

constructor TAMQPChannel.Create(AConnection: IAMQPConnection; AChannelId: Word; ASemaphore: TAMQPSemaphore);
begin
  FSemaphore := ASemaphore;
  FConnection := AConnection;
  FConfirmSelect := False;
  FID := AChannelId;
  FTimeout := AConnection.Timeout;
  FQueue := TAMQPFrameQueue.Create(FTimeout);
  FConsumers := TAMQPConsumerList.Create;
  FDeliverQueue := TAMQPFrameList.Create;
  FConfirmSelect := False;
  FConnection.QueryInterface(IAMQPConnectionStat, FConnectionStat);
end;

destructor TAMQPChannel.Destroy;
begin
  FQueue.Free;
  FConsumers.Free;
  FDeliverQueue.Free;
  {$ifdef AMQP_DEBUG}
  DbgWriteLn(ClassName+'.Destroy:'+FID.ToString);
  {$EndIf}
  inherited Destroy;
end;

procedure TAMQPChannel.ExchangeDeclare(AExchangeName, AType: String; AProperties: IAMQPProperties = nil;
    APassive: Boolean = False; ADurable : Boolean = True; AAutoDelete: Boolean = False;
    AInternal: Boolean = False; ANoWait: Boolean = False);
begin
   WriteFrame(amqp_method_exchange_declare.create_frame(FID, AExchangeName, AType, APassive, ADurable, AAutoDelete, AInternal, ANoWait, AProperties));
   if not ANoWait then
     ReadMethod([IAMQPExchangeDeclareOk]);
end;

procedure TAMQPChannel.ExchangeDeclare(AExchangeName: String;
  AType: TAMQPExchangeType; AProperties: IAMQPProperties; APassive: Boolean;
  ADurable: Boolean; AAutoDelete: Boolean; AInternal: Boolean;
  ANoWait: Boolean);
begin
  ExchangeDeclare(AExchangeName, AMQPExchangeTypeStr[AType], AProperties, APassive, ADurable, AAutoDelete, AInternal, ANoWait);
end;

procedure TAMQPChannel.ExchangeDelete(AExchangeName: String;
  AIfUnused: Boolean; ANoWait: Boolean);
begin
  WriteFrame(amqp_method_exchange_delete.create_frame(FID, AExchangeName, AIfUnused, ANoWait));
  if not ANoWait then
    ReadMethod([IAMQPExchangeDeleteOk]);
end;

procedure TAMQPChannel.QueueDeclare(AQueueName: String; APassive: Boolean;
  ADurable: Boolean; AExclusive: Boolean; AAutoDelete: Boolean;
  ANoWait: Boolean);
begin
  QueueDeclare(AQueueName, nil, APassive, ADurable, AExclusive, AAutoDelete, ANoWait);
end;

procedure TAMQPChannel.QueueDeclare(AQueueName: String;
  AProperties: IAMQPProperties; APassive: Boolean; ADurable: Boolean;
  AExclusive: Boolean; AAutoDelete: Boolean; ANoWait: Boolean);
begin
 WriteFrame(amqp_method_queue_declare.create_frame(fid, 0, AQueueName, APassive, ADurable, AExclusive, AAutoDelete, ANoWait, AProperties));
 if not ANoWait then
   ReadMethod([IAMQPMethodQueueDeclareOk]);
end;

procedure TAMQPChannel.QueueBind(AQueueName, AExchangeName,
  ARoutingKey: String; AProperties: IAMQPProperties; ANoWait: Boolean);
begin
  WriteFrame(amqp_method_queue_bind.create_frame(fid, 0, AQueueName, AExchangeName, ARoutingKey, ANoWait, AProperties));
  if not ANoWait then
   ReadMethod([IAMQPQueueBindOk]);
end;

function TAMQPChannel.QueuePurge(AQueueName: String; ANoWait: Boolean): Int64;
var Frame: IAMQPFrame;
    Obj: IAMQPQueuePurgeOk;
begin
  Result := 0;
  WriteFrame(amqp_method_queue_purge.create_frame(FID, 0, AQueueName, ANoWait));
  if not ANoWait then
  begin
    Frame := ReadMethod([IAMQPQueuePurgeOk]);
    if (Frame <> nil) and Supports(Frame.AsMethod, IAMQPQueuePurgeOk, Obj) then
      Result := Obj.message_count;
  end;
end;

function TAMQPChannel.QueueDelete(AQueueName: String; AIfUnused: Boolean;
  AIfEmpty: Boolean; ANoWait: Boolean): Int64;
var Frame: IAMQPFrame;
    Obj: IAMQPQueueDeleteOk;
begin
  WriteFrame(amqp_method_queue_delete.create_frame(FID, 0, AQueueName, AIfUnused, AIfEmpty, ANoWait));
  if not ANoWait then
  begin
    Frame := ReadMethod([IAMQPQueueDeleteOk]);
    if (Frame <> nil) and (Supports(Frame.AsMethod, IAMQPQueueDeleteOk, Obj)) then
     Result := Obj.message_count;
  end;
end;

procedure TAMQPChannel.QueueUnBind(AQueueName, AExchangeName,
  ARoutingKey: String; AProperties: IAMQPProperties);
begin
  WriteFrame(amqp_method_queue_unbind.create_frame(fid, 0, AQueueName, AExchangeName, ARoutingKey, AProperties));
  ReadMethod([IAMQPQueueUnBindOk]);
end;

procedure TAMQPChannel.BasicPublish(AExchange, ARoutingKey: String;
  AMsg: IAMQPMessage);
begin
  with AMsg do
   BasicPublish(AExchange, ARoutingKey, False, False, contentType, contentEncoding, correlationId, replyTo, expiration,
     messageId, &type, userId, appId, clusterId, Body, deliveryMode, priority, timestamp, headers);
end;

procedure TAMQPChannel.BasicPublish(AMsg: IAMQPMessage);
begin
 with AMsg do
  BasicPublish(Exchange, RoutingKey, False, False, contentType, contentEncoding, correlationId, replyTo, expiration,
    messageId, &type, userId, appId, clusterId, Body, deliveryMode, priority, timestamp, headers);
end;

procedure TAMQPChannel.BasicPublish(AExchange, ARoutingKey: AnsiString;
  AMandatory, AImmediate: Boolean; AContentType, AContentEncoding,
  ACorrelationId, AReplyTo, AExpiration, AMessageId, AType, AUserId, AAppId,
  AClusterId: AnsiString; ABody: TAMQPBody; ADeliveryMode: TAMQPDeliveryMode;
  APriority: Byte; ATimeStamp: TDateTime; AHeaders: IAMQPHeaders);
var Buf: Pointer;
begin
  Buf := @ABody[0];
  BasicPublish(AExchange, ARoutingKey, AMandatory, AImmediate,
    AContentType, AContentEncoding, ACorrelationId, AReplyTo, AExpiration,
    AMessageId, AType, AUserId, AAppId, AClusterId, Buf, Length(ABody),
    ADeliveryMode, APriority, ATimeStamp, AHeaders);
end;

procedure TAMQPChannel.BasicPublish(AExchange, ARoutingKey: String;
  AMandatory, AImmediate: Boolean; AContentType, AContentEncoding,
  ACorrelationId, AReplyTo, AExpiration, AMessageId, AType, AUserId, AAppId,
  AClusterId: String; ABody: Pointer; ABodySize: UInt64;
  ADeliveryMode: TAMQPDeliveryMode; APriority: Byte; ATimeStamp: TDateTime;
  AHeaders: IAMQPHeaders);
var PublishFrame: IAMQPFrame;
    ContentHeader: IAMQPFrame;
    BodyFrame: IAMQPFrame;
    Offset, Remaining, Len: UInt64;
    Buf: PByte;
begin
 Buf := ABody;
 PublishFrame := amqp_method_basic_publish.create_frame(fid, 0, AExchange, ARoutingKey, AMandatory, AImmediate);
 ContentHeader := amqp_content_header.create_frame(fid, ABodySize);
 with ContentHeader.AsContentHeader do
   begin
     contentType := AContentType;
     contentEncoding := AContentEncoding;
     deliveryMode := Byte(ADeliveryMode);
     priority := APriority;
     correlationId := ACorrelationId;
     replyTo := AReplyTo;
     expiration := AExpiration;
     messageId := AMessageId;
     appId := AAppId;
     userId := AUserId;
     clusterId := AClusterId;
     _type := AType;
     timestamp := DateTimeToUnix(ATimeStamp);
     headers.Assign(AHeaders);
   end;
  WriteFrame(PublishFrame);
  WriteFrame(ContentHeader);
  Offset :=  0;
  while Offset < ABodySize do
   begin
     Remaining := ABodySize - Offset;
     if Remaining > (FConnection.MaxSize - 8) then
      Len := FConnection.MaxSize - 8
     else
      Len := Remaining;
     BodyFrame := amqp_content_body.create_frame(FID, len, Buf);
     WriteFrame(BodyFrame);
     Inc(Buf, Len);
     Offset := Offset + Len;
   end;
  if FConfirmSelect then
    ReadMethod([IAMQPBasicAck]);
end;

procedure TAMQPChannel.ExchangeBind(ADestination, ASource: String;
  ARoutingKey: String; ANoWait: Boolean);
begin
  ExchangeBind(ADestination, ASource, nil, ARoutingKey, ANoWait);
end;

procedure TAMQPChannel.ExchangeBind(ADestination, ASource: String;
  AProperties: IAMQPProperties; ARoutingKey: String; ANoWait: Boolean);
begin
 WriteFrame(amqp_method_exchange_bind.create_frame(FID, 0, ADestination, ASource, ARoutingKey, ANoWait, AProperties));
 if not ANoWait then
  ReadMethod([IAMQPExchangeBindOk]);
end;

function TAMQPChannel.PopFrame: IAMQPFrame;
begin
  Result := FQueue.Pop;
  {$ifdef AMQP_DEBUG}
  DbgWriteLn(ClassName+'.PopFrame:'+DumpIObj(Result));
  {$EndIf}
end;

procedure TAMQPChannel.BasicAck(AMessage: IAMQPMessage; AMultiple: Boolean);
begin
  BasicAck(AMessage.DeliveryTag, AMultiple);
end;

procedure TAMQPChannel.BasicAck(ADeliveryTag: UInt64; AMultiple: Boolean);
begin
  WriteFrame(amqp_method_basic_ack.create_frame(FID, ADeliveryTag, AMultiple));
end;

procedure TAMQPChannel.ConfirmSelect(ANoWait: Boolean);
begin
  WriteFrame(amqp_method_confirm_select.create_frame(FID, ANoWait));
  if not ANoWait then
   ReadMethod([IAMQPConfirmSelectOk]);
  FConfirmSelect := True;
end;

function TAMQPChannel.BasicQOS(APrefetchSize, APrefetchCount: UInt64;
  AGlobal: Boolean = False): Boolean;
begin
  WriteFrame(amqp_method_basic_qos.create_frame(FID, APrefetchSize, APrefetchCount, AGlobal));
  Result := ReadMethod([IAMQPBasicQOSOk]) <> nil;
end;

function TAMQPChannel.BasicGet(AQueueName: String;
  ANoAck: Boolean): IAMQPMessage;
var
  frame, headerframe, bodyframe: IAMQPFrame;
  hdr: IAMQPContentHeader;
  msg: TAMQPMessage;
  sz: Int64;
  BasicGetOk: IAMQPBasicGetOk;
begin
  Result := nil;
  WriteFrame(amqp_method_basic_get.create_frame(FID, 0, AQueueName, ANoAck));
  Frame := ReadMethod([IAMQPBasicGetOk, IAMQPBasicGetEmpty]);
  if Supports(Frame.AsMethod, IAMQPBasicGetEmpty) then
   Result := nil
  else
   begin
     headerframe := FQueue.Pop;
     if headerframe.frame_type <> AMQP_FRAME_HEADER then
      raise AMQPException.Create('Expected header frame');
     if Supports(frame.AsMethod, IAMQPBasicGetOk, BasicGetOk) then
     begin
       Msg := TAMQPMessage.CreateBasicGet(BasicGetOk);
       Msg.Channel := Self;
       hdr := headerframe.AsContentHeader;
       msg.AssignFromContentHeader(hdr);
       sz := 0;
       repeat
         bodyframe := FQueue.Pop;
         msg.LoadBody(bodyframe.AsContentBody);
         sz := sz + bodyframe.AsContentBody.Size;
       until sz >= hdr.bodySize;
       Result := msg;
     end;
   end;
end;

procedure TAMQPChannel.BasicCancel(AConsumerTag: AnsiString; ANoWait: Boolean);
var Frame: IAMQPFrame;
begin
  RemoveConsumer(AConsumerTag);
  Frame := amqp_method_basic_cancel.create_frame(FID, AConsumerTag, ANoWait);
  {$ifdef AMQP_DEBUG}
  DbgWriteLn(ToString+'.BasicCancel:'+DumpIObj(Frame));
  {$EndIf}
  WriteFrame(Frame);
  if not ANoWait then
   ReadMethod([IAMQPBasicCancelOk]);
end;

procedure TAMQPChannel.BasicConsume(AMessageQueue: TAMQPMessageQueue;
  AQueueName: String; var AConsumerTag: String; ANoLocal, ANoAck, AExclusive,
  ANoWait: Boolean);
begin
  AddConsumer(AQueueName, AConsumerTag, nil, AMessageQueue);
  WriteFrame(amqp_method_basic_consume.create_frame(FID, 0, AQueueName, AConsumerTag, ANoLocal, ANoAck, AExclusive, ANoWait, nil));
  ReadMethod([IAMQPBasicConsumeOk]);
end;

procedure TAMQPChannel.BasicConsume(AMessageHandler: TAMQPConsumerMethod;
  AQueueName: String; var AConsumerTag: String; ANoLocal: Boolean; ANoAck: Boolean;
  AExclusive: Boolean; ANoWait: Boolean);
begin
  AddConsumer(AQueueName, AConsumerTag, AMessageHandler, nil);
  WriteFrame(amqp_method_basic_consume.create_frame(FID, 0, AQueueName, AConsumerTag, ANoLocal, ANoAck, AExclusive, ANoWait, nil));
  ReadMethod([IAMQPBasicConsumeOk]);
end;

procedure TAMQPChannel.BasicNAck(AMessage: IAMQPMessage; ARequeue: Boolean = True;  AMultiple: Boolean = False);
begin
  BasicNAck(AMessage.DeliveryTag, ARequeue, AMultiple);
end;

procedure TAMQPChannel.BasicNAck(ADeliveryTag: UInt64; ARequeue: Boolean = True; AMultiple: Boolean = false);
begin
  WriteFrame(amqp_method_basic_nack.create_frame(FID, ADeliveryTag, AMultiple, ARequeue));
end;

procedure TAMQPChannel.BasicReject(AMessage: IAMQPMessage; ARequeue: Boolean);
begin
  BasicReject(AMessage.DeliveryTag, ARequeue);
end;

procedure TAMQPChannel.BasicReject(ADeliveryTag: UInt64; ARequeue: Boolean);
begin
 WriteFrame(amqp_method_basic_reject.create_frame(fid, ADeliveryTag, ARequeue));
end;

{ TSingletonImplementation }

function TSingletonImplementation.QueryInterface(constref IID: TGUID;
  out Obj): HResult; cdecl;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TSingletonImplementation._AddRef: Integer; cdecl;
begin
 Result := -1;
end;

function TSingletonImplementation._Release: Integer; cdecl;
begin
 Result := -1;
end;

{ TAMQPMessageQueue }

function TAMQPMessageQueue.Push(AItem: IAMQPMessage): IAMQPMessage;
begin
  Result := inherited Push(AItem) as IAMQPMessage;
end;

function TAMQPMessageQueue.Pop: IAMQPMessage;
begin
 Result := inherited Pop as IAMQPMessage
end;

function TAMQPMessageQueue.Peek: IAMQPMessage;
begin
 Result := inherited Peek as IAMQPMessage
end;

{ TAMQPBlockedQueued }

constructor TAMQPBlockedQueued.Create(ATimeOut: Integer);
begin
  inherited Create;
  FTimeout := ATimeOut;
  FEvent :=  TEvent.Create(nil, True, False, TGuid.NewGuid.ToString);
end;

destructor TAMQPBlockedQueued.Destroy;
begin
  FEvent.Free;
  inherited Destroy;
end;

function TAMQPBlockedQueued.Push(AItem: IUnknown): IUnknown;
begin
 Result := inherited Push(AItem);
 FEvent.SetEvent;
 {$ifdef AMQP_DEBUG}
 DbgWriteLn('Push:'+DumpIObj(AItem));
 {$EndIf}
end;

function TAMQPBlockedQueued.Pop: IUnknown;
begin
 if not AtLeast(1) then
  begin
   FEvent.ResetEvent;
   if FEvent.WaitFor(FTimeout) = wrSignaled then
    Result := inherited Pop
   else
    raise EBlockedQueueTimeout.CreateFmt('Event timeout %d', [FTimeout]);
  end else
  Result := inherited Pop;
  {$ifdef AMQP_DEBUG}
  DbgWriteLn('Pop:'+DumpIObj(Result));
  {$EndIf}
end;

{ TAMQPConsumer }

procedure TAMQPConsumer.DoReceive(AChannel: IAMQPChannel; AMessage: IAMQPMessage; out SendAck: Boolean);
//var SendAck: Boolean;
begin
 if FMessageQueue <> nil then
    FMessageQueue.Push(AMessage)
 else
   begin
     SendAck := True;
     if Assigned(FMessageHandler) then
        FMessageHandler(AChannel, AMessage, SendAck);
//    if SendAck then
//       AMessage.Ack;
   end;
end;

procedure TAMQPConsumer.DoIncStat;
begin
  if FChannelStat <> nil then
   FChannelStat.IncConsumerThread;
end;

procedure TAMQPConsumer.DoDecStat;
begin
  if FChannelStat <> nil then
   FChannelStat.DecConsumerThread;
end;

procedure TAMQPConsumer.Lock;
begin
  FLock.Enter;
end;

procedure TAMQPConsumer.Unlock;
begin
 FLock.Leave;
end;

procedure TAMQPConsumer.Receive(AMessage: IAMQPMessage);
begin
 try
  TConsumeThread.Create(Self, AMessage, FSemaphore);
 finally
 end;
end;

constructor TAMQPConsumer.Create(AChannel: IAMQPChannel; AQueueName,
  AConsumerTag: String; AMessageHandler: TAMQPConsumerMethod;
  AMessageQueue: TAMQPMessageQueue; ASemaphore: TAMQPSemaphore);
begin
  FChannel := AChannel;
  FQueueName := AQueueName;
  FConsumerTag := AConsumerTag;
  FMessageHandler := AMessageHandler;
  FMessageQueue := AMessageQueue;
  FSemaphore := ASemaphore;
  FLock := TCriticalSection.Create;
  if not Supports(FChannel,  IAMQPChannelStat, FChannelStat) then
   FChannelStat := nil;
end;

destructor TAMQPConsumer.Destroy;
begin
  Lock;
  try
//   if FThread <> nil then
//    begin
//      FThread.WaitFor;
//      FreeAndNil(FThread);
//    end;
   FChannelStat := nil;
   if FMessageQueue <> nil then
      FMessageQueue.Push(nil);
   {$IfDef AMQP_DEBUG}
    DbgWriteLn(ClassName+'.Destroy');
   {$EndIf}

  finally
   Unlock;
  end;
  FLock.Free;
  inherited Destroy;
end;

{ TAMQPFrameQueue }

function TAMQPFrameQueue.Push(AItem: IAMQPFrame): IAMQPFrame;
begin
  Result := inherited Push(AItem) as IAMQPFrame;
end;

function TAMQPFrameQueue.Pop: IAMQPFrame;
begin
  Result := inherited Pop as IAMQPFrame;
end;

function TAMQPFrameQueue.Peek: IAMQPFrame;
begin
  Result := inherited Peek as IAMQPFrame;
end;

{ TAMQPQueue }

procedure TAMQPQueue.PushItem(AItem: IUnknown);
begin
  With FList do
     Insert(0, AItem);
end;

function TAMQPQueue.PopItem: IUnknown;
begin
  with FList do
    if Count>0 then
      begin
       Result:=Items[Count-1];
       Delete(Count-1);
      end
    else
      Result:=nil;
end;

function TAMQPQueue.PeekItem: IUnknown;
begin
  with Flist do
    Result:=Items[Count-1]
end;

constructor TAMQPQueue.Create;
begin
  FList := TInterfaceList.Create;
end;

destructor TAMQPQueue.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function TAMQPQueue.Count: Integer;
begin
 Result := FList.Count;
end;

function TAMQPQueue.AtLeast(ACount: Integer): Boolean;
begin
  Result:=(FList.Count>=Acount)
end;

function TAMQPQueue.Push(AItem: IUnknown): IUnknown;
begin
  PushItem(AItem);
  Result:=AItem;
end;

function TAMQPQueue.Pop: IUnknown;
begin
  If Atleast(1) then
    Result:=PopItem
  else
    Result:=nil;
end;

function TAMQPQueue.Peek: IUnknown;
begin
  if AtLeast(1) then
    Result:=PeekItem
  else
    Result:=nil;
end;

procedure TAMQPQueue.Clear;
begin
 FList.Clear;
end;

{ TAMQPThread }

function TAMQPThread.FindChannel(AChannels: TAMQPChannelList; AChannelId: Word): IAMQPChannel;
var c: IAMQPChannel;

begin
 for c in AChannels do
   if c.Id = AChannelId then
   Exit(c);
 Result := nil;
end;

procedure TAMQPThread.Execute;
var Frame: IAMQPFrame;
begin
 NameThreadForDebugging('fpcAMQP');
 try
  repeat
    frame := ReadFrame;
    if Frame <> nil then
    begin
     if Frame.channel = 0 then
        SendFrameToMainChannel(Frame)
     else
        SendFrameToChannel(Frame);
    end;
  until Terminated or (not FTCP.Connected);
  {$ifdef AMQP_DEBUG}
  DbgWriteLn(ToString+'.Terminated:'+Terminated.ToString);
  DbgWriteLn(ToString+'.FTCP.Connected:'+FTCP.Connected.ToString);
  {$EndIf}
 except
   on E: EIdSocketError do
     ServerDisconnect(500, E.Message);
   on E: Exception do
     Disconnect(E);
 end;
 if FMainQueue.Count = 0 then
   FMainQueue.Push(nil);
end;

function TAMQPThread.ReadFrame: IAMQPFrame;
const
  FRAME_HEADER_SIZE  = 7;
  METHOD_HEADER_SIZE = 4;
var
  Bytes   : TIdBytes;
  Payload : TIdBytes;
  Frame   : IAMQPFrame;
  Stream  : TMemoryStream;
  FrameSize: Int64;
  FrameEnd: Byte;
begin
  SetLength(Bytes, 0);
  SetLength(Payload, 0);
  Result := nil;
  Frame  := amqp_frame.Create;
    Stream := TMemoryStream.Create;
    Try
      FTCP.IOHandler.ReadBytes( Bytes, FRAME_HEADER_SIZE, False );
      FrameSize :=Bytes[3] shl 24 + Bytes[4] shl 16 + Bytes[5] shl 8 + Bytes[6];
      Stream.Write(Bytes[0], Length( Bytes ) );
      FTCP.IOHandler.ReadBytes( Payload, FrameSize + 1, False );
      FrameEnd := Payload[ FrameSize ];
      Stream.Write(Payload[0], Length( Payload )-1 );
      //FDumpFrame( srReceive, Stream );
      If FrameEnd <> $CE then
        raise AMQPException.Create('FrameEnd incorrect');
      Stream.Position := 0;
      Frame.Read(Stream);
      Result := Frame;
      {$ifdef AMQP_DEBUG}
      DbgWriteLn(ToString+'.ReadFrame'+DumpIObj(Result));
      {$EndIf}
    Finally
      Stream.Free;
    End;
end;

procedure TAMQPThread.SendFrameToMainChannel(AFrame: IAMQPFrame);
var Close: IAMQPMethodClose;
begin
 {$ifdef AMQP_DEBUG}
  DbgWriteLn(ToString+'.SendFrameToMainChannel:'+DumpIObj(AFrame));
 {$EndIf}
  if AFrame.frame_type = AMQP_FRAME_METHOD then
  begin
    if supports(AFrame.AsMethod, IAMQPMethodCloseOk) then
     begin
      FMainQueue.Push(AFrame);
      Terminate;
      Exit;
     end
    else
   if supports(AFrame.AsMethod, IAMQPMethodClose, Close) then
    begin
      Terminate;
      try
        ServerDisconnect(close.replyCode, Close.replyText);
        Exit;
      finally
        AFrame := nil;
      end;
    end;
  end;
  if AFrame.frame_type = AMQP_FRAME_HEARTBEAT then
    SendHeartbeat
  else
   if FMainQueue <> nil then
     FMainQueue.Push(AFrame);
end;

procedure TAMQPThread.SendFrameToChannel(AFrame: IAMQPFrame);
var c: IAMQPChannel;
    List: TAMQPChannelList;
begin
  List := FChannelList.LockList;
  try
   c := FindChannel(List, AFrame.channel);
  finally
    FChannelList.UnlockList;
  end;
  if c <> nil then
    c.ReceiveFrame(AFrame)
  else
    raise AMQPException.CreateFmt('Invalid channel %d', [AFrame.channel]);
end;

procedure TAMQPThread.SendHeartbeat;
begin
  FConnection.WriteFrame(amqp_heartbeat.create_frame(0));
end;

procedure TAMQPThread.ServerDisconnect(ACode: Integer; Msg: String);
begin
 try
  FConnection.ServerDisconnect(ACode, Msg);

 finally
   SignalCloseToChannel;
 end;
end;

procedure TAMQPThread.Disconnect(E: Exception);
begin
  FConnection.InternalDisconnect(True);
end;

procedure TAMQPThread.SignalCloseToChannel;
var
  List: TAMQPChannelList;
  Channel: IAMQPChannel;
  Frame: IAMQPFrame;
begin
  List := FChannelList.LockList;
  try
   for Channel in List do
     begin
       Frame := amqp_method_close_ok.create_frame(Channel.Id);
       {$ifdef AMQP_DEBUG}
       DbgWriteLn('SignalCloseToChannel:'+DumpIObj(Frame));
       {$EndIf}
       Channel.PushFrame(Frame);
       Channel.ChannelClosed;
     end;
  finally
    FChannelList.UnlockList;
  end;
end;

constructor TAMQPThread.Create(AConnection: IAMQPConnection; ATCP: TIdTCPClient; AMainQueue: TAMQPFrameQueue; AChannelList: TAMQPChannelThreadList);
begin
  FTCP := ATCP;
  FMainQueue := AMainQueue;
  FChannelList := AChannelList;
  FConnection := AConnection;
  inherited Create(False);
end;

{ TAMQPConnection }

function TAMQPConnection.GetHost: String;
begin
  Result := FHost;
end;

function TAMQPConnection.GetConsumerThreadCount: Integer;
begin
  Result := FConsumerThreadCount;
end;

function TAMQPConnection.GetMaxSize: Integer;
begin
  Result := FMaxSize;
end;

function TAMQPConnection.GetMaxThread: Word;
begin
  Result := FMaxThread;
end;

function TAMQPConnection.GetPassword: String;
begin
 Result := FPassword;
end;

function TAMQPConnection.GetPort: Word;
begin
 Result := FPort;
end;

function TAMQPConnection.GetTimeOut: Integer;
begin
  Result := FTimeout;
end;

function TAMQPConnection.GetUsername: String;
begin
 Result := FUsername;
end;

function TAMQPConnection.GetVirtualHost: String;
begin
 Result := FVirtualhost;
end;

procedure TAMQPConnection.SetHost(AValue: String);
begin
 FHost := AValue;
end;

procedure TAMQPConnection.SetMaxSize(AValue: Integer);
begin
  FMaxSize := AValue;
  if FMaxSize > 131072 then
   FMaxSize := 131072;
end;

procedure TAMQPConnection.SetMaxThread(AValue: Word);
var semArgs: TSEMun;
begin
  if (FMaxThread <> AValue) and (AValue > 0) then
   begin
    semArgs.val := AValue;
    if semctl(FSemaphore, 0, SEM_SETVAL, semArgs) <> -1 then
     FMaxThread := AValue;
   end;
end;

procedure TAMQPConnection.SetPassword(AValue: String);
begin
 FPassword := AValue;
end;

procedure TAMQPConnection.SetPort(AValue: Word);
begin
 FPort := AValue;
end;

procedure TAMQPConnection.SetTimeout(AValue: Integer);
begin
  Ftimeout := AValue;
end;

procedure TAMQPConnection.SetUsername(AValue: String);
begin
 FUsername := AValue;
end;

procedure TAMQPConnection.SetVirtualHost(AValue: String);
begin
 FVirtualhost := AValue;
end;

procedure TAMQPConnection.IncConsumerCount;
begin
  InterLockedIncrement(FConsumerThreadCount);
end;

procedure TAMQPConnection.DecConsumerCount;
begin
 InterLockedDecrement(FConsumerThreadCount);
end;

function TAMQPConnection.ThreadRunning: Boolean;
begin
  Result := Assigned(FThread) and not FThread.Terminated;
end;

function TAMQPConnection.ReadFrame: IAMQPFrame;
begin
  Result := Nil;
  if ThreadRunning or FMainQueue.AtLeast(1) then
   try
    Result := FMainQueue.Pop;
   except
     on E: EBlockedQueueTimeout do  ;
   end
  else
   Result := nil;
end;

function TAMQPConnection.ReadMethod(AExpected: array of TGUID): IAMQPFrame;
var
  MethodIsExpected: Boolean;
  Method: TGuid;
begin
  repeat
    {$ifdef AMQP_DEBUG}
    DbgWriteLn('ReadMethod->ReadFrame: wait');
    {$EndIf}
    Result := ReadFrame;
    {$ifdef AMQP_DEBUG}
    DbgWriteLn('ReadMethod->ReadFrame:'+DumpIObj(Result));
    {$EndIf}
  until (Result = nil) or ((result <> nil)  and (Result.frame_type <> AMQP_FRAME_HEARTBEAT));

  if (Result = nil) then
    raise AMQPException.Create('Disconnected');

  if (Result.AsContainer.method = nil) then
    raise AMQPException.Create('Frame does not contain a method');

  MethodIsExpected := False;
  for Method in AExpected do
    if Supports(Result.AsContainer.method, Method) then
      MethodIsExpected := True;

  if not MethodIsExpected then
    raise AMQPException.CreateFmt( 'Unexpected class/method: %d.%d',
                                   [ Result.AsContainer.class_id, Result.AsContainer.method_id ] );
end;

procedure TAMQPConnection.DoOnChannelClose(AChannel: IAMQPChannel);
begin
  if Assigned(FOnChannelClose) then
   FOnChannelClose(Self, AChannel);
end;

procedure TAMQPConnection.DoOnChannelCloseServer(AChannel: IAMQPChannel);
begin
  if Assigned(FOnChannelCloseServer) then
   FOnChannelCloseServer(Self, AChannel);
end;

procedure TAMQPConnection.DoOnMessageException(AChannel: IAMQPChannel;
  AMessage: IAMQPMessage; AException: Exception);
begin
  if assigned(FOnMessageException) then
   FOnMessageException(Self, AChannel, AMessage, AException)
  else
   raise AException;
end;

procedure TAMQPConnection.WriteFrame(AFrame: IAMQPFrame);
var Buf: TMemoryStream;
begin
  {$ifdef AMQP_DEBUG}
  DbgWriteLn(ToString+'.WriteFrame:'+DumpIObj(AFrame));
  {$EndIf}
  buf := TMemoryStream.Create;
  try
    AFrame.Write(Buf);
    Buf.Position := 0;
    FTCP.IOHandler.Write(Buf);
  finally
    buf.Free;
  end;
end;

procedure TAMQPConnection.CloseConnection;
var Frame: IAMQPFrame;
begin

  if FTCP.Connected then
    begin
     Frame := amqp_method_close.create_frame(0, 200, 'Goodbye', 0, 0);
     {$ifdef AMQP_DEBUG}
     DbgWriteLn(ToString+'.CloseConnection:'+DumpIObj(Frame));
     {$EndIf}
     try
      FTCP.CheckForGracefulDisconnect(True);
      WriteFrame(Frame);
      ReadMethod([IAMQPMethodCloseOk]);
     finally
        FIsOpen := False;
     end;
     {$ifdef AMQP_DEBUG}
     DbgWriteLn(ToString+'.CloseConnection');
     {$EndIf}
    end;
end;

procedure TAMQPConnection.CloseAllChannels;
  function GetFirstChannel: IAMQPChannel;
   var Channels: TAMQPChannelList;
  begin
   Channels := FChannelList.LockList;
   try
    if Channels.Count = 0 then
     Result := nil
    else
      Result := Channels[0];
   finally
     FChannelList.UnlockList;
   end;
  end;
var
  channel: IAMQPChannel;

begin
 channel := GetFirstChannel;
 while channel <> nil do
 begin
    CloseChannel(channel);
    channel := GetFirstChannel;
 end;
 {$ifdef AMQP_DEBUG}
 DbgWriteLn(ToString+'.CloseAllChannels');
 {$EndIf}
end;

procedure TAMQPConnection.InternalDisconnect(ACloseConnection: Boolean);
begin
 {$ifdef AMQP_DEBUG}
 DbgWriteLn(ToString+'.InternalDisconnect:CloseConnection='+ACloseConnection.ToString);
 {$EndIf}
 try
  CloseAllChannels;
  if ACloseConnection then
     CloseConnection;
 finally
   try
    {$ifdef AMQP_DEBUG}
    DbgWriteLn(ToString+'.InternalDisconnect:TCP.Disconnect');
    {$EndIf}
    FTCP.Disconnect;
    FTCP.IOHandler.InputBuffer.Clear;
    FMainQueue.Clear;
    {$ifdef AMQP_DEBUG}
    DbgWriteLn(ToString+'.InternalDisconnect:TCP.Disconnect:'+FTCP.Connected.ToString);
    {$EndIf}
   except
     //on E: Exception do ;
   end;
   FIsOpen := False;
 end;
end;

procedure TAMQPConnection.ServerDisconnect(ACode: Integer; AMessage: String);
begin
  FServerDisconnected := True;
  InternalDisconnect(False);
  {$IfDef AMQP_DEBUG}
  DbgWriteLn('Server disconnect code:'+ACode.ToString+' reason:'+AMessage);
  {$EndIf}
end;

procedure TAMQPConnection.ProtocolError(AErrorMessage: String;
  AFrame: IAMQPFrame);
begin
  InternalDisconnect(True);
  raise AMQPException.Create(AErrorMessage);
end;

function TAMQPConnection.MakeChannel: IAMQPChannel;
  Function ChannelIdInUse( AChannelList: TAMQPChannelList; AChannelID: Word ): Boolean;
  var
    Channel: IAMQPChannel;
  Begin
    for Channel in AChannelList do
      if Channel.ID = AChannelID then
        Exit( True );
    Result := False;
  End;

  Function GetNewChannelID( AChannelList: TAMQPChannelList ): Word;
  Begin
    if AChannelList.Count = 65535 then
      raise AMQPException.Create('All channels in use');
    Result := 1;
    While ChannelIdInUse( AChannelList, Result ) do
      Inc( Result );
  End;

var
  Channels: TAMQPChannelList;
begin
  Channels := FChannelList.LockList;
  try
   Result := TAMQPChannel.Create(Self, GetNewChannelId(Channels), FSemaphore);
   Channels.Add(Result);
  finally
    FChannelList.UnlockList;
  end;
end;

procedure TAMQPConnection.CloseChannelOnServer(AChannel: IAMQPChannel);
var
  Frame  : IAMQPFrame;
begin
  if (AChannel.IsOpen) and ChannelNeedsToBeClosedOnServer( AChannel ) then
  Begin
    AChannel.CancelConsumers;
    WriteFrame(amqp_method_channel_close.create_frame(AChannel.Id, 0, '', 0, 0));
    Frame := AChannel.PopFrame;
    DoOnChannelCloseServer(AChannel);
    if not Supports(Frame.AsMethod, IAMQPChannelCloseOk) then
       ProtocolError(Format('Unexpected method class_id:%d, method_id:%d', [Frame.AsContainer.class_id, Frame.AsContainer.method_id]), Frame);
   {$ifdef AMQP_DEBUG}
   DbgWriteLn(ToString+'.CloseChannelOnServer');
   {$EndIf}
  End;
end;

procedure TAMQPConnection.CloseChannel(AChannel: IAMQPChannel);
begin
  if not FServerDisconnected then
    CloseChannelOnServer(AChannel);
  AChannel.ChannelClosed;
  DoOnChannelClose(AChannel);
  FChannelList.Remove(AChannel);
  {$ifdef AMQP_DEBUG}
  DbgWriteLn(ToString+'.CloseChannel');
  {$EndIf}
end;

function TAMQPConnection.ChannelNeedsToBeClosedOnServer(
  AChannel: IAMQPChannel): Boolean;
var Channels: TAMQPChannelList;
begin
 Channels := FChannelList.LockList;
 try
  Result := (Channels.IndexOf(AChannel) >= 0) and IsOpen and FTCP.Connected;
 finally
   FChannelList.UnlockList;
 end;
end;

procedure TAMQPConnection.MessageException(AChannel: IAMQPChannel;
  AMessage: IAMQPMessage; AException: Exception);
begin
  DoOnMessageException(AChannel, AMessage, AException);
end;

constructor TAMQPConnection.Create;

begin
  Ftimeout := -1;
  FTCP := TIdTCPClient.Create;
  FMainQueue := TAMQPFrameQueue.Create(Ftimeout);
  FChannelList := TAMQPChannelThreadList.Create;
  FMaxSize := 131072;
  FSemaphore := semget(0, 1, 0666 or IPC_PRIVATE);
  FConsumerThreadCount := 0;
  SetMaxThread(10);
end;

destructor TAMQPConnection.Destroy;
var SemArgs: TSEMun;
begin
 FillChar(SemArgs, sizeof(SemArgs), 0);
 semctl(FSemaphore, 0, IPC_RMID, SemArgs);
 try
  if FTCP.Connected then
   InternalDisconnect(True);
 finally
  FThread.Free;
  FTCP.Free;
  FChannelList.Free;
  FMainQueue.Free;
  inherited Destroy;
 end;
end;

procedure TAMQPConnection.Connect;
var hdr: amqp_protocol_header;
    frame: IAMQPFrame;
    tune: IAMQPMethodTune;
    Buf: TIdBytes;
begin
  FMainQueue.Clear;
  SetLength(Buf, sizeof(hdr));
  hdr := new_amqp_protocol(0, 0, 9, 1);
  move(hdr, Buf[0], sizeof(hdr));
  FTCP.Disconnect;
  FTCP.Host := FHost;
  FTCP.Port := FPort;
  FTCP.Connect;
//  FTCP.ReadTimeout := 500;
  FTCP.IOHandler.Write(Buf);
  FThread := TAMQPThread.Create(Self, FTCP, FMainQueue, FChannelList);
  frame := ReadMethod([IAMQPMethodStart]);
  frame := nil;
  frame := amqp_method_start_ok.create_frame(0, nil, 'PLAIN', #0+FUsername+#0+FPassword, 'ru_RU');
  WriteFrame(frame);
  frame := ReadMethod([IAMQPMethodTune]);
  tune := frame.AsContainer.method as IAMQPMethodTune;
  WriteFrame(amqp_method_tune_ok.create_frame(0, tune.channelMax, tune.frameMax, 10));
  WriteFrame(amqp_method_open.create_frame(0, FVirtualhost));
  frame := ReadMethod([IAMQPMethodOpenOk]);
  FIsOpen := True;
  FServerDisconnected := False;
end;

procedure TAMQPConnection.Disconnect;
begin
 if not IsOpen then
  raise AMQPException.Create('Already closed');
 InternalDisconnect(True);
end;

function TAMQPConnection.IsOpen: boolean;
begin
  Result := FIsOpen;
end;

function TAMQPConnection.IsConnected: Boolean;
begin
  Result := (FTCP <> nil) and (FTCP.Connected);
end;

function TAMQPConnection.OpenChannel: IAMQPChannel;
var
    Frame: IAMQPFrame;
begin
  Result := MakeChannel;
  WriteFrame(amqp_method_channel_open.create_frame(Result.Id, ''));
  Frame := Result.PopFrame;
  if not Supports(Frame.AsMethod, IAMQPChannelOpenOk) then
    ProtocolError(format('Expected channel.open-ok. Received class_id:%d, method_id: %d',
     [Frame.AsContainer.class_id, Frame.AsContainer.method_id]), Frame);
end;

initialization
{$IfDef AMQP_DEBUG}
 InitCriticalSection(DbgLock);
{$EndIf}

finalization
{$IfDef AMQP_DEBUG}
 DoneCriticalSection(DbgLock);
{$EndIf}

end.

