{$i ampq2.inc}
{$IfDef DEBUG}
 {$Define AMQP_DEBUG}
 {$IfDef AMQP_DEBUG}
   {$Define AMQP_DEBUG_FRAME}
 {$EndIf}
{$EndIf}

unit amqp_connection;

{$IfDef FPC}
  {$mode objfpc}{$H+}
{$EndIf}

interface

uses
  Classes
  , SysUtils
  , IdTCPClient
  , IdIOHandler
  , amqp_types
  , contnrs
  , syncobjs
  , amqp_message
 {$IfDef USE_CONSUMER_THREAD}
  {$IfDef FPC}
   , ipc
  {$EndIf}
 {$EndIf}
{$IfNDef FPC}
  , System.Generics.Defaults
  , System.Generics.Collections
  , Windows
{$EndIf}
  , ampq_intf
  , amqp_classes;

type

{$IfDef FPC}
  { TSingletonImplementation }
  TSingletonImplementation = class(TObject, IInterface)
  protected
    function QueryInterface(constref IID: TGUID; out Obj): HResult; cdecl;
    function _AddRef: Integer; cdecl;
    function _Release: Integer; cdecl;
  end;
{$EndIf}

  TAMQPFrameList = {$IfDef FPC}specialize GAMQPFrameList<IAMQPFrame>{$Else}GAMQPFrameList{$EndIf};
  TAMQPMessageList = {$IfDef FPC}specialize GAMQPFrameList<IAMQPMessage>{$Else}GAMQPFrameList{$EndIf};
  TAMQPChannelList = class;
  TAMQPChannelThreadList = class;


  { TAMQPFrameQueue }

  TAMQPFrameQueue = class(TAMQPBlockedQueued)
  private
  public
    Function Push(AItem: IAMQPFrame): IAMQPFrame;
    Function Pop: IAMQPFrame;
    Function Peek: IAMQPFrame;
  end;

  { TAMQPMessageQueue }

  TAMQPMessageQueue = class(TAMQPBlockedQueued, IAMQPMessageQueue)
  public
    Function Push(AItem: IAMQPMessage): IAMQPMessage;
    Function Pop: IAMQPMessage;
    Function Peek: IAMQPMessage;
  end;


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


  { TAMQPConsumer }

  TAMQPConsumer = class
  strict private
    type
      {$IfDef USE_CONSUMER_THREAD}
        { TConsumeThread }

        TConsumeThread = class(TThread)
        private
          FConsumer: TAMQPConsumer;
          FMessage: IAMQPMessage;
          FSendAck: Boolean;
          FSemaphore: TAMQPSemaphore;
          FConsumerSemaphore: TAMQPSemaphore;
          FUserData: Pointer;
        protected
          procedure Execute; override;
        public
         constructor Create(AConsumer: TAMQPConsumer; AMessage: IAMQPMessage; AUserData: Pointer;
            AConsumerSemaphore: TAMQPSemaphore = {$IfDef FPC}-1{$Else}Nil{$EndIf};
            ASemaphore: TAMQPSemaphore = {$IfDef FPC}-1{$Else}Nil{$EndIf});
         destructor Destroy; override;
        end;
      {$EndIf}

  private
   {$IfDef USE_CONSUMER_THREAD}
    FConsumerSemaphore: TAMQPSemaphore;
    FConsumerThreadCount: Integer;
    FChannelStat: IAMQPChannelStat;
    FMaxThread: Word;
    FSemaphore: TAMQPSemaphore;
   {$EndIf}
    FConsumerTag: String;
    FMessageHandler: TAMQPConsumerMethod;
    FMessageQueue: IAMQPMessageQueue;
    FQueueName: String;
    FUserData: Pointer;
    FLock: TCriticalSection;
    FChannel: IAMQPChannel;
   {$IfDef USE_CONSUMER_THREAD}
    procedure WaitAllThreadEnd;
   {$EndIf}
  protected
    procedure DoReceive(AChannel: IAMQPChannel; AMessage: IAMQPMessage; AUserData: Pointer; out SendAck: Boolean);
   {$IfDef USE_CONSUMER_THREAD}
    procedure DoIncStat;
    procedure DoDecStat;
   {$EndIf}
    procedure Lock;
    procedure Unlock;

  public
    Property QueueName      : String            read FQueueName;
    Property ConsumerTag    : String            read FConsumerTag;
    Property MessageHandler : TAMQPConsumerMethod   read FMessageHandler write FMessageHandler;
    Property MessageQueue   : IAMQPMessageQueue read FMessageQueue;
    Procedure Receive( AMessage: IAMQPMessage );
    Constructor Create( AChannel: IAMQPChannel; AQueueName, AConsumerTag: String; AMessageHandler: TAMQPConsumerMethod;
      AMessageQueue: IAMQPMessageQueue{$IfDef USE_CONSUMER_THREAD}; ASemaphore: TAMQPSemaphore; AMaxThread: Word{$EndIf}; AUserData: Pointer);
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
   {$IfDef FPC}
    FLock: TRTLCriticalSection;
   {$Else}
    FLock: TCriticalSection;
   {$EndIf}
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

  TAMQPChannel = class(TInterfacedObject, IAMQPChannel, IAMQPChannelPublish, IAMQPChannelAck{$IfDef USE_CONSUMER_THREAD}, IAMQPChannelStat{$EndIf})
  strict private
    FConnection: IAMQPConnection;
    FID: Word;
    FConfirmSelect: Boolean;
    FQueue: TAMQPFrameQueue;
    FConsumers: TAMQPConsumerList;
    FDeliverConsumer: TAMQPConsumer;
    FDeliverQueue: TAMQPFrameList;
    FTimeout: Integer;
   {$IfDef USE_CONSUMER_THREAD}
    FConnectionStat: IAMQPConnectionStat;
    FSemaphore: TAMQPSemaphore;
    FChannelMaxThread: Word;
    FChannelThreadCount: Integer;
    function GetConsumerThreadCount: Integer;
    function GetChannelThreadCount: Integer;
   {$EndIf}

    function GetIsOpen: boolean;
    function GetQueue: TAMQPFrameQueue;
    function GetTimeout: Integer;
    procedure SetTimeout(AValue: Integer);
  protected
    procedure AddConsumer(AQueueName: String; var AConsumerTag: String;
              AMessageHandler: TAMQPConsumerMethod; AMessageQueue: IAMQPMessageQueue; AUserData: Pointer);
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
   {$IfDef USE_CONSUMER_THREAD}
    procedure IncConsumerThread;
    procedure DecConsumerThread;
    property ConsumerThreadCount: Integer read GetConsumerThreadCount;
   {$EndIf}
  public
    constructor Create(AConnection: IAMQPConnection; AChannelId: Word{$IfDef USE_CONSUMER_THREAD}; ASemaphore: TAMQPSemaphore; AChannelMaxThread: Word{$EndIf});
    destructor Destroy; override;
    function NewMessage: IAMQPMessage;

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

    procedure ConfirmSelect(ANoWait: Boolean);
    function BasicQOS(APrefetchSize, APrefetchCount: UInt64; AGlobal: Boolean = false): Boolean;

    function BasicGet(AQueueName: String; ANoAck: Boolean): IAMQPMessage;
    procedure BasicCancel(AConsumerTag: AnsiString; ANoWait: Boolean);
    procedure BasicConsume(AMessageQueue: IAMQPMessageQueue; AQueueName: String;
              var AConsumerTag: String; ANoLocal, ANoAck, AExclusive, ANoWait: Boolean; AUserData: Pointer = nil); overload;
    Procedure BasicConsume( AMessageHandler: TAMQPConsumerMethod; AQueueName: String; var AConsumerTag: String; ANoLocal: Boolean = False;
              ANoAck: Boolean = False; AExclusive: Boolean = False; ANoWait: Boolean = False; AUserData: Pointer = nil ); Overload;


    Procedure BasicReject( AMessage: IAMQPMessage; ARequeue: Boolean = True ); overload;
    Procedure BasicReject( ADeliveryTag: UInt64; ARequeue: Boolean = True ); overload;
    procedure BasicNAck( AMessage: IAMQPMessage; ARequeue: Boolean = True;  AMultiple: Boolean = False ); Overload;
    Procedure BasicNAck( ADeliveryTag: UInt64; ARequeue: Boolean = True; AMultiple: Boolean = False ); Overload;
    Procedure BasicAck( AMessage: IAMQPMessage; AMultiple: Boolean = False ); Overload;
    Procedure BasicAck( ADeliveryTag: UInt64; AMultiple: Boolean = False ); Overload;

  end;

  TAMQPOnProtocolError = procedure(AObject: TObject; AMessage: String; AFrame: IAMQPFrame; var AHandled: Boolean) of object;
  TAMQPOnServerDisconnect = procedure(AObject: TObject; ACode: Word; AMessage: String) of object;
  TAMQPOnDisconnect = procedure(AObject: TObject) of object;
  TAMQPOnChannelClose = procedure(AObject: TObject; AChannel: IAMQPChannel) of object;
  TAMQPOnChannelOpen = procedure(AObject: TObject; AChannel: IAMQPChannel) of object;
  TAMQPOnMessageException = procedure(AObject: TObject; AChannel: IAMQPChannel; AMessage: IAMQPMessage; AException: Exception) of object;

  { TAMQPConnection }

  TAMQPConnection = class(TSingletonImplementation, IAMQPConnection{$IfDef USE_CONSUMER_THREAD}, IAMQPConnectionStat{$EndIf})
  private
    FOnChannelClose: TAMQPOnChannelClose;
    FOnChannelCloseServer: TAMQPOnChannelClose;
    FOnChannelOpen: TAMQPOnChannelOpen;
    FOnConnect: TNotifyEvent;
    FOnDisconnect: TAMQPOnDisconnect;
    FOnMessageException: TAMQPOnMessageException;
    FOnProtocolError: TAMQPOnProtocolError;
    FOnServerDisconnect: TAMQPOnServerDisconnect;
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
   {$IfDef USE_CONSUMER_THREAD}
    FSemaphore: TAMQPSemaphore;
    FMaxThread: Word;
    FConsumerThreadCount: {$IfDef FPC}Cardinal{$Else}Integer{$EndIf};
    FChannelMaxThread: Word;
   {$EndIf}
   {$IfDef USE_CONSUMER_THREAD}
    function GetChannelMaxThread: Word;
    function GetConsumerThreadCount: Integer;
    function GetMaxThread: Word;
    procedure SetChannelMaxThread(AValue: Word);
    procedure SetMaxThread(AValue: Word);
   {$endif}
    function GetIOHandler: TIdIOHandler;
    procedure SetIOHandler(AValue: TIdIOHandler);

    function GetHost: String;
    function GetMaxSize: Integer;

    function GetPassword: String;
    function GetPort: Word;
    function GetTimeOut: Integer;
    function GetUsername: String;
    function GetVirtualHost: String;
    procedure SetHost(AValue: String);
    procedure SetMaxSize(AValue: Integer);

    procedure SetPassword(AValue: String);
    procedure SetPort(AValue: Word);
    procedure SetTimeout(AValue: Integer);
    procedure SetUsername(AValue: String);
    procedure SetVirtualHost(AValue: String);
  protected
   {$IfDef USE_CONSUMER_THREAD}
    procedure IncConsumerCount;
    procedure DecConsumerCount;
   {$EndIf}
    function ThreadRunning: Boolean;
    function ReadFrame: IAMQPFrame;
    function ReadMethod(AExpected: array of TGUID): IAMQPFrame;
    procedure DoOnChannelClose(AChannel: IAMQPChannel);
    procedure DoOnChannelOpen(AChannel: IAMQPChannel);
    procedure DoOnChannelCloseServer(AChannel: IAMQPChannel);
    procedure DoOnMessageException(AChannel: IAMQPChannel; AMessage: IAMQPMessage; AException: Exception);
    procedure DoOnConnect;
    procedure DoOnDisconnect;
    procedure DoOnServerDisconnect(ACode: Word; AMessage: String);
    procedure DoOnProtocolError(AMessage: String; AFrame: IAMQPFrame; var AHandled: Boolean);
    procedure WriteFrame(AFrame: IAMQPFrame);

    procedure CloseConnection;
    procedure CloseAllChannels;
    procedure InternalDisconnect(ACloseConnection: Boolean);
    procedure ServerDisconnect(ACode: Integer; AMessage: String);
    procedure ProtocolError(AErrorMessage: String; AFrame: IAMQPFrame);
    {$IfDef USE_CONSUMER_THREAD}
    property ConsumerThreadCount: Integer read GetConsumerThreadCount;
    {$EndIf}
    function MakeChannel: IAMQPChannel;
    procedure CloseChannelOnServer(AChannel: IAMQPChannel);
    Function ChannelNeedsToBeClosedOnServer(AChannel: IAMQPChannel): Boolean;
    procedure MessageException(AChannel: IAMQPChannel; AMessage: IAMQPMessage; AException: Exception);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Connect;
    procedure Disconnect;
    property IOHandler: TIdIOHandler read GetIOHandler write SetIOHandler;
   {$IfDef USE_CONSUMER_THREAD}
    property MaxThread: Word read GetMaxThread write SetMaxThread;
    property ChannelMaxThread: Word read GetChannelMaxThread write SetChannelMaxThread;
   {$EndIf}
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
    property OnConnect: TNotifyEvent read FOnConnect write FOnConnect;
    property OnDisconnect: TAMQPOnDisconnect read FOnDisconnect write FOnDisconnect;
    property OnServerDisconnect: TAMQPOnServerDisconnect read FOnServerDisconnect write FOnServerDisconnect;
    property OnChannelOpen: TAMQPOnChannelOpen read FOnChannelOpen write FOnChannelOpen;
    property OnChannelClose: TAMQPOnChannelClose read FOnChannelClose write FOnChannelClose;
    property OnChannelCloseServer: TAMQPOnChannelClose read FOnChannelCloseServer write FOnChannelCloseServer;
    property OnMessageException: TAMQPOnMessageException read FOnMessageException write FOnMessageException;
    property OnProtocolError: TAMQPOnProtocolError read FOnProtocolError write FOnProtocolError;
  end;

implementation

uses IdGlobal, IdStack, dateutils;

{$IfDef USE_CONSUMER_THREAD}
 {$IfDef FPC}
 const
      cConsumerLock : TSEMbuf = (sem_num:0;sem_op:-1;sem_flg:0);
      cConsumerInlock: TSEMbuf = (sem_num:0;sem_op:1;sem_flg:0);
 {$EndIf}
{$EndIf}

{$IfDef AMQP_DEBUG}
var
  DbgLock: {$IfDef FPC}TRTLCriticalSection{$Else}TCriticalSection{$EndIf};

procedure DbgWriteln(AMsg: String);
begin
 {$IfDef FPC}
 EnterCriticalsection(DbgLock);
 {$Else}
 DbgLock.Enter;
 {$EndIf}
 try
 {$IfDef FPC}
  Write(AMsg, #13#10);
 {$Else}
  DebugOutput(AMsg);
 {$EndIf}
 finally
  {$IfDef FPC}
   LeaveCriticalsection(DbgLock);
  {$Else}
   DbgLock.Leave
  {$EndIf}
 end;
end;

{$EndIf}


function DumpIObj(AObj: IUnknown): String;
var S: IAMQPObject;
begin
 Result := IntToStr(PtrInt(Pointer(AObj)));
 if Supports(AObj, IAMQPObject, S) then
  Result := Result + ':' + s.AsDebugString;
end;


{$IfDef USE_CONSUMER_THREAD}
{ TAMQPConsumer.TConsumeThread }

procedure TAMQPConsumer.TConsumeThread.Execute;
begin
 {$IfDef AMQP_DEBUG}
  {$IfDef FPC}
   DbgWriteln(ToString+'.Execute:'+FConsumer.FConsumerThreadCount.ToString+':'+FConsumer.ConsumerTag);
  {$Else}
   DbgWriteln(ToString+'.Execute:'+IntToStr(FConsumer.FConsumerThreadCount)+':'+FConsumer.ConsumerTag);
  {$EndIf}
 {$EndIf}
 try
  FConsumer.DoReceive(FConsumer.FChannel,  FMessage, FUserData, FSendAck);
 finally
  Terminate;
 end;
end;

constructor TAMQPConsumer.TConsumeThread.Create(AConsumer: TAMQPConsumer;
  AMessage: IAMQPMessage; AUserData: Pointer; AConsumerSemaphore: TAMQPSemaphore;
  ASemaphore: TAMQPSemaphore);
begin
  FSemaphore := ASemaphore;
  FConsumerSemaphore := AConsumerSemaphore;
  FConsumer := AConsumer;
  FUserData := AUserData;
  FMessage := AMessage;
  FreeOnTerminate := True;
  {$IfDef FPC}
   if FConsumerSemaphore > -1 then
     if semop(FConsumerSemaphore, @cConsumerLock, 1) = -1 then
      RaiseLastOSError(GetLastOSError);

   if FSemaphore > -1 then
    if semop(FSemaphore, @cConsumerLock, 1) = -1 then
      RaiseLastOSError(GetLastOSError);
  {$Else}
    if FConsumerSemaphore <> nil then
     FConsumerSemaphore.Acquire;
    if FSemaphore <> nil then
     FSemaphore.Acquire;
  {$EndIf}
  FConsumer.DoIncStat;
  {$IfDef AMQP_DEBUG}
   {$IfDef FPC}
    DbgWriteln(ToString+'.Create:'+FConsumer.FConsumerThreadCount.ToString()+':'+FConsumer.ConsumerTag);
   {$Else}
    DbgWriteln(ToString+'.Create:'+IntToStr(FConsumer.FConsumerThreadCount)+':'+FConsumer.ConsumerTag);
   {$EndIf}
  {$EndIf}
  inherited Create(False);
end;

destructor TAMQPConsumer.TConsumeThread.Destroy;
begin
 if FSendAck then
  FMessage.Ack;
 {$IfDef AMQP_DEBUG}
  {$IfDef FPC}
    DbgWriteln(ToString+'.Destroy:'+FConsumer.FConsumerThreadCount.ToString()+':'+FConsumer.ConsumerTag);
  {$Else}
    DbgWriteln(ToString+'.Destroy:'+IntToStr(FConsumer.FConsumerThreadCount)+':'+FConsumer.ConsumerTag);
  {$EndIf}
 {$EndIf}
 try
  if Assigned(FConsumer) then
    FConsumer.DoDecStat;
 except
   on E: Exception do ;
 end;
 {$IfDef FPC}
 if FConsumerSemaphore > -1 then
  if semop(FConsumerSemaphore, @cConsumerInlock, 1) = -1 then
    RaiseLastOSError(GetLastOSError);
  if FSemaphore > -1 then
   if semop(FSemaphore, @cConsumerInlock, 1) = -1 then
     RaiseLastOSError(GetLastOSError);
 {$Else}
  if FSemaphore <> nil then
   FSemaphore.Release;
  if FConsumerSemaphore <> nil then
   FConsumerSemaphore.Release;
 {$EndIf}
 inherited Destroy;
end;
{$EndIf}

{ TAMQPChannelThreadList }

constructor TAMQPChannelThreadList.Create;
begin
  FList := TAMQPChannelList.Create;
{$IfDef FPC}
  InitCriticalSection(FLock);
{$Else}
  FLock := TCriticalSection.Create;
{$EndIf}
end;

destructor TAMQPChannelThreadList.Destroy;
begin
  FList.Free;
{$IfDef FPC}
  DoneCriticalsection(FLock);
{$Else}
  FLock.Free;
{$EndIf}
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
{$IfDef FPC}
  system.EnterCriticalsection(FLock);
{$Else}
  FLock.Enter;
{$EndIf}
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
{$IfDef FPC}
  system.LeaveCriticalsection(FLock);
{$Else}
  FLock.Leave;
{$EndIf}
end;

{ TAMQPFrameList }


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
  AMessageQueue: IAMQPMessageQueue; AUserData: Pointer);
var
  Consumer: TAMQPConsumer;
begin
 if AConsumerTag = '' then
 {$IfDef FPC}
  AConsumerTag := TGuid.NewGuid.ToString(True);
 {$Else}
  AConsumerTag := GUIDToString(TGUID.NewGuid);
 {$EndIf}
  for Consumer in FConsumers do
    if (Consumer.ConsumerTag = AConsumerTag) then
      raise AMQPException.Create('Duplicate consumer');
  FConsumers.Add(TAMQPConsumer.Create(Self, AQueueName, AConsumerTag, AMessageHandler,
    AMessageQueue{$IfDef USE_CONSUMER_THREAD}, FSemaphore, FChannelMaxThread{$EndIf}, AUserData));
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
    HeaderFrame  := AQueue[1] as IAMQPFrame;
    {$ifdef AMQP_DEBUG}
     {$IfDef AMQP_DEBUG_FRAME}
      DbgWriteLn(ToString+'.HasCompleteMessageInQueue:'+DumpIObj(HeaderFrame));
     {$EndIf}
    {$endif}
    if HeaderFrame.frame_type = AMQP_FRAME_HEADER then
    begin
      ContentHdr := HeaderFrame.AsContentHeader;
      Size         := ContentHdr.bodySize;
      Received     := 0;
      Index := 2;
      While (Index < AQueue.Count) and
            ((AQueue[Index] as IAMQPFrame).frame_type = AMQP_FRAME_BODY) and
            (Received < Size) do
      Begin
        Received := Received + (AQueue[Index] as IAMQPFrame).AsContentBody.len;
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
  Msg          : TAMQPMessage;
  sz: Int64;
  bodySz: Int64;
begin
  DeliverFrame := FDeliverQueue.Extract( FDeliverQueue[0] ) as IAMQPFrame;
  HeaderFrame  := FDeliverQueue.Extract( FDeliverQueue[0] ) as IAMQPFrame;
  Msg := TAMQPMessage.CreateBasicDeliver(DeliverFrame.AsMethod as IAMQPBasicDeliver);
  Result := Msg;
  Result.Channel := Self;
  ContentHdr := HeaderFrame.AsContentHeader;
  Result.AssignFromContentHeader(ContentHdr);
  BodySz := ContentHdr.bodySize;
  sz := 0;
  Try
    Repeat
      BodyFrame := FDeliverQueue.Extract( FDeliverQueue[0] )  as IAMQPFrame;
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

{$IfDef USE_CONSUMER_THREAD}
function TAMQPChannel.GetConsumerThreadCount: Integer;
begin
  if FConnectionStat <> nil then
   Result := FConnectionStat.ConsumerThreadCount;
end;

function TAMQPChannel.GetChannelThreadCount: Integer;
begin
  Result := FChannelThreadCount;
end;

{$EndIf}

procedure TAMQPChannel.ReceiveFrame(AFrame: IAMQPFrame);
begin
  DoReceiveFrame(AFrame);
end;

procedure TAMQPChannel.PushFrame(AFrame: IAMQPFrame);
begin
  {$ifdef AMQP_DEBUG}
   {$IfDef AMQP_DEBUG_FRAME}
    DbgWriteLn(ClassName+'.PushFrame:'+DumpIObj(AFrame));
   {$EndIf}
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
 {$IfDef USE_CONSUMER_THREAD}
  FConnectionStat := nil;
 {$EndIf}
  FConnection := nil;

  {$ifdef AMQP_DEBUG}
  {$IfDef FPC}
   DbgWriteLn(ToString+'.ChannelClosed:'+FID.ToString);
  {$Else}
   DbgWriteLn(ToString+'.ChannelClosed:'+IntToStr(FID));
  {$EndIf}
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
   {$IfDef USE_CONSUMER_THREAD}
    FConnectionStat := nil;
   {$EndIf}
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

{$IfDef USE_CONSUMER_THREAD}
procedure TAMQPChannel.IncConsumerThread;
begin
  if FConnectionStat <> nil then
   FConnectionStat.IncConsumerCount;
  InterlockedIncrement(FChannelThreadCount);
end;

procedure TAMQPChannel.DecConsumerThread;
begin
  if FConnectionStat <> nil then
   FConnectionStat.DecConsumerCount;
  InterlockedDecrement(FChannelThreadCount);
end;
{$EndIf}

constructor TAMQPChannel.Create(AConnection: IAMQPConnection; AChannelId: Word{$IfDef USE_CONSUMER_THREAD}; ASemaphore: TAMQPSemaphore; AChannelMaxThread: Word{$EndIf});
begin
 {$IfDef USE_CONSUMER_THREAD}
  FSemaphore := ASemaphore;
  FChannelMaxThread := AChannelMaxThread;
  FChannelThreadCount := 0;
 {$EndIf}
  FConnection := AConnection;
  FConfirmSelect := False;
  FID := AChannelId;
  FTimeout := AConnection.Timeout;
  FQueue := TAMQPFrameQueue.Create(FTimeout);
  FConsumers := TAMQPConsumerList.Create;
  FDeliverQueue := TAMQPFrameList.Create;
  FConfirmSelect := False;
 {$IfDef USE_CONSUMER_THREAD}
  FConnection.QueryInterface(IAMQPConnectionStat, FConnectionStat);
 {$EndIf}
end;

destructor TAMQPChannel.Destroy;
begin
  FQueue.Free;
  FConsumers.Free;
  FDeliverQueue.Free;
  {$ifdef AMQP_DEBUG}
  DbgWriteLn(Format('%s.Destroy:%d', [ClassName, FID]));
  {$EndIf}
  inherited Destroy;
end;

function TAMQPChannel.NewMessage: IAMQPMessage;
begin
  Result := TAMQPMessage.Create;
  Result.Channel := Self;
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
   {$IfDef AMQP_DEBUG_FRAME}
    DbgWriteLn(ClassName+'.PopFrame:'+DumpIObj(Result));
   {$EndIf}
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

procedure TAMQPChannel.BasicConsume(AMessageQueue: IAMQPMessageQueue;
  AQueueName: String; var AConsumerTag: String; ANoLocal, ANoAck, AExclusive,
  ANoWait: Boolean; AUserData: Pointer = nil);
begin
  AddConsumer(AQueueName, AConsumerTag, nil, AMessageQueue, AUserData);
  WriteFrame(amqp_method_basic_consume.create_frame(FID, 0, AQueueName, AConsumerTag, ANoLocal, ANoAck, AExclusive, ANoWait, nil));
  ReadMethod([IAMQPBasicConsumeOk]);
end;

procedure TAMQPChannel.BasicConsume( AMessageHandler: TAMQPConsumerMethod; AQueueName: String; var AConsumerTag: String; ANoLocal: Boolean = False;
              ANoAck: Boolean = False; AExclusive: Boolean = False; ANoWait: Boolean = False; AUserData: Pointer = nil );
begin
  AddConsumer(AQueueName, AConsumerTag, AMessageHandler, nil, AUserData);
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

{$IfDef FPC}
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
{$EndIf}

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


{ TAMQPConsumer }

{$IfDef USE_CONSUMER_THREAD}
procedure TAMQPConsumer.WaitAllThreadEnd;
begin
  repeat
   Sleep(10);
   {$IfDef AMQP_DEBUG}
 //   DbgWriteLn(Format('%s.%s:%d',[ClassName, 'WaitAllThreadEnd', FConsumerThreadCount]));
   {$EndIf}
  until FConsumerThreadCount = 0;
end;
{$EndIf}

procedure TAMQPConsumer.DoReceive(AChannel: IAMQPChannel; AMessage: IAMQPMessage; AUserData: Pointer; out SendAck: Boolean);
//var SendAck: Boolean;
begin
 if FMessageQueue <> nil then
    FMessageQueue.Push(AMessage)
 else
   begin
     SendAck := True;
     if Assigned(FMessageHandler) then
        FMessageHandler(AChannel, AMessage, FUserData, SendAck);
//    if SendAck then
//       AMessage.Ack;
   end;
end;

{$IfDef USE_CONSUMER_THREAD}
procedure TAMQPConsumer.DoIncStat;
begin
  if FChannelStat <> nil then
   FChannelStat.IncConsumerThread;
  InterLockedIncrement(FConsumerThreadCount);
end;

procedure TAMQPConsumer.DoDecStat;
begin
  if FChannelStat <> nil then
   FChannelStat.DecConsumerThread;
  InterLockedDecrement(FConsumerThreadCount);
end;
{$EndIf}

procedure TAMQPConsumer.Lock;
begin
  FLock.Enter;
end;

procedure TAMQPConsumer.Unlock;
begin
 FLock.Leave;
end;

procedure TAMQPConsumer.Receive(AMessage: IAMQPMessage);
{$IfNDef USE_CONSUMER_THREAD}
var
  SendAck: Boolean;
{$EndIf}
begin
 {$IfDef USE_CONSUMER_THREAD}
 try
  TConsumeThread.Create(Self, AMessage, FUserData, FConsumerSemaphore, FSemaphore);
 finally
 end;
 {$Else}
  DoReceive(FChannel,  AMessage, SendAck);
  if SendAck then
    AMessage.Ack;
 {$EndIf}

end;

constructor TAMQPConsumer.Create(AChannel: IAMQPChannel; AQueueName,
  AConsumerTag: String; AMessageHandler: TAMQPConsumerMethod;
  AMessageQueue: IAMQPMessageQueue{$IfDef USE_CONSUMER_THREAD}; ASemaphore: TAMQPSemaphore;
  AMaxThread: Word{$EndIf}; AUserData: Pointer);
{$IfDef USE_CONSUMER_THREAD}
 {$IfDef FPC}
  var semArgs: TSEMun;
 {$EndIf}
{$EndIf}
begin
  FChannel := AChannel;
  FQueueName := AQueueName;
  FConsumerTag := AConsumerTag;
  FMessageHandler := AMessageHandler;
  FMessageQueue := AMessageQueue;
  FUserData := AUserData;
  FLock := TCriticalSection.Create;
 {$IfDef USE_CONSUMER_THREAD}
  FSemaphore := ASemaphore;
  FMaxThread := AMaxThread;
  if FMaxThread > 0 then
  begin
  {$IfDef FPC}
   FConsumerSemaphore := semget(0, 1, 0666 or IPC_PRIVATE);
   semArgs.val := FMaxThread;
   if semctl(FConsumerSemaphore, 0, SEM_SETVAL, semArgs) = -1 then
    RaiseLastOSError(GetLastOSError);
  {$Else}
   FConsumerSemaphore := TAMQPSemaphore.Create(nil, FMaxThread, FMaxThread, FConsumerTag);
  {$EndIf}
  end else
   FConsumerSemaphore := NullSemaphore;
  if not Supports(FChannel,  IAMQPChannelStat, FChannelStat) then
   FChannelStat := nil;
 {$EndIf}

end;

destructor TAMQPConsumer.Destroy;
{$IfDef USE_CONSUMER_THREAD}
 {$IfDef FPC}
  var SemArgs: TSEMun;
 {$EndIf}
{$EndIf}
begin
//  Lock;
  try
  {$IfDef USE_CONSUMER_THREAD}
   WaitAllThreadEnd;
   FChannelStat := nil;
  {$EndIf}
   if FMessageQueue <> nil then
      FMessageQueue.Push(nil);
  {$IfDef USE_CONSUMER_THREAD}
   if FConsumerSemaphore <> NullSemaphore then
    begin
    {$IfDef FPC}
      FillChar(SemArgs, sizeof(SemArgs), 0);
      semctl(FConsumerSemaphore, 0, IPC_RMID, SemArgs);
    {$Else}
      FConsumerSemaphore.Free;
    {$EndIf}
      FConsumerSemaphore := NullSemaphore;
    end;
  {$EndIf}
   {$IfDef AMQP_DEBUG}
    DbgWriteLn(ClassName+'.Destroy');
   {$EndIf}
  finally
//   Unlock;
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
   {$IfDef FPC}
    DbgWriteLn(ToString+'.Terminated:'+Terminated.ToString);
    DbgWriteLn(ToString+'.FTCP.Connected:'+FTCP.Connected.ToString);
   {$Else}
    DbgWriteLn(ToString+'.Terminated:'+ BoolToStr(Terminated));
    DbgWriteLn(ToString+'.FTCP.Connected:'+BoolToStr(FTCP.Connected));
   {$EndIf}
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
       {$IfDef AMQP_DEBUG_FRAME}
        DbgWriteLn(ToString+'.ReadFrame'+DumpIObj(Result));
       {$EndIf}
      {$EndIf}
    Finally
      Stream.Free;
    End;
end;

procedure TAMQPThread.SendFrameToMainChannel(AFrame: IAMQPFrame);
var Close: IAMQPMethodClose;
begin
 {$ifdef AMQP_DEBUG}
  {$IfDef AMQP_DEBUG_FRAME}
    DbgWriteLn(ToString+'.SendFrameToMainChannel:'+DumpIObj(AFrame));
  {$EndIf}
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

function TAMQPConnection.GetIOHandler: TIdIOHandler;
begin
 Result := nil;
 if FTCP <> nil then
  Result := FTCP.IOHandler;
end;


{$IfDef USE_CONSUMER_THREAD}
function TAMQPConnection.GetConsumerThreadCount: Integer;
begin
  Result := FConsumerThreadCount;
end;

function TAMQPConnection.GetChannelMaxThread: Word;
begin
  Result := FChannelMaxThread;
end;

function TAMQPConnection.GetMaxThread: Word;
begin
  Result := FMaxThread;
end;

{$EndIf}

function TAMQPConnection.GetMaxSize: Integer;
begin
  Result := FMaxSize;
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

{$IfDef USE_CONSUMER_THREAD}
procedure TAMQPConnection.SetChannelMaxThread(AValue: Word);
begin
 if AValue <> FChannelMaxThread then
 begin
  if AValue < FMaxThread then
    FChannelMaxThread := AValue;
 end;
end;
{$EndIf}

procedure TAMQPConnection.SetIOHandler(AValue: TIdIOHandler);
begin
  FTCP.IOHandler := AValue;
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


{$IfDef USE_CONSUMER_THREAD}
procedure TAMQPConnection.SetMaxThread(AValue: Word);
{$IfDef FPC}
var semArgs: TSEMun;
{$EndIf}
begin
  if (FMaxThread <> AValue) and (AValue > 0) then
   begin
    {$IfDef FPC}
    semArgs.val := AValue;
    if semctl(FSemaphore, 0, SEM_SETVAL, semArgs) <> -1 then
    {$Else}
    if not FTCP.Connected then
     begin
      if FSemaphore <> NullSemaphore then
       FSemaphore.Free;
      FSemaphore := TAMQPSemaphore.Create(nil, AValue, AValue, GUIDToString(TGuid.NewGuid));
      if FChannelMaxThread > FMaxThread then
        FChannelMaxThread := (FMaxThread div 2) + 1;
     end;
    {$EndIf}
     FMaxThread := AValue;
   end;
end;
{$EndIf}

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


{$IfDef USE_CONSUMER_THREAD}
procedure TAMQPConnection.IncConsumerCount;
begin
  InterLockedIncrement(FConsumerThreadCount);
end;

procedure TAMQPConnection.DecConsumerCount;
begin
 InterLockedDecrement(FConsumerThreadCount);
end;
{$EndIf}

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
     {$IfDef AMQP_DEBUG_FRAME}
       DbgWriteLn('ReadMethod->ReadFrame: wait');
     {$EndIf}
    {$EndIf}
    Result := ReadFrame;
    {$ifdef AMQP_DEBUG}
     {$IfDef AMQP_DEBUG_FRAME}
      DbgWriteLn('ReadMethod->ReadFrame:'+DumpIObj(Result));
     {$EndIf}
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

procedure TAMQPConnection.DoOnChannelOpen(AChannel: IAMQPChannel);
begin
  if Assigned(FOnChannelOpen) then
   FOnChannelOpen(Self, AChannel);
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

procedure TAMQPConnection.DoOnConnect;
begin
  if Assigned(FOnConnect) then
   FOnConnect(Self);
end;

procedure TAMQPConnection.DoOnDisconnect;
begin
  if Assigned(FOnDisconnect) then
   FOnDisconnect(Self);
end;

procedure TAMQPConnection.DoOnServerDisconnect(ACode: Word; AMessage: String);
begin
  if assigned(FOnServerDisconnect) then
   FOnServerDisconnect(Self, ACode, AMessage);
end;

procedure TAMQPConnection.DoOnProtocolError(AMessage: String;
  AFrame: IAMQPFrame; var AHandled: Boolean);
begin
  if Assigned(FOnProtocolError) then
   FOnProtocolError(Self, AMessage, AFrame, AHandled);
end;

procedure TAMQPConnection.WriteFrame(AFrame: IAMQPFrame);
var Buf: TMemoryStream;
begin
  {$ifdef AMQP_DEBUG}
   {$IfDef AMQP_DEBUG_FRAME}
    DbgWriteLn(ToString+'.WriteFrame:'+DumpIObj(AFrame));
   {$EndIf}
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
  {$IfDef FPC}
   DbgWriteLn(ToString+'.InternalDisconnect:CloseConnection='+ACloseConnection.ToString);
  {$Else}
   DbgWriteLn(ToString+'.InternalDisconnect:CloseConnection='+ BoolToStr(ACloseConnection));
  {$EndIf}
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
    DoOnDisconnect;
    {$ifdef AMQP_DEBUG}
     {$IfDef FPC}
       DbgWriteLn(ToString+'.InternalDisconnect:TCP.Disconnect:'+FTCP.Connected.ToString);
     {$Else}
       DbgWriteLn(ToString+'.InternalDisconnect:TCP.Disconnect:'+ BoolToStr(FTCP.Connected));
     {$EndIf}
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
  DoOnServerDisconnect(ACode, AMessage);
  InternalDisconnect(False);
  {$IfDef AMQP_DEBUG}
   {$IfDef FPC}
     DbgWriteLn('Server disconnect code:'+ACode.ToString+' reason:'+AMessage);
   {$Else}
     DbgWriteLn('Server disconnect code:'+IntToStr(ACode)+' reason:'+AMessage);
   {$EndIf}
  {$EndIf}
end;

procedure TAMQPConnection.ProtocolError(AErrorMessage: String;
  AFrame: IAMQPFrame);
var Handled: Boolean;
begin
  Handled := False;
  DoOnProtocolError(AErrorMessage, AFrame, Handled);
  InternalDisconnect(True);
  if not Handled then
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
   Result := TAMQPChannel.Create(Self, GetNewChannelId(Channels){$IfDef USE_CONSUMER_THREAD}, FSemaphore, FChannelMaxThread{$EndIf});
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
 {$IfDef USE_CONSUMER_THREAD}
  {$IfDef FPC}
   FSemaphore := semget(0, 1, 0666 or IPC_PRIVATE);
   FConsumerThreadCount := 0;
   FChannelMaxThread := 2;
  {$Else}
   FSemaphore := NullSemaphore;
  {$EndIf}
  SetMaxThread(10);
 {$EndIf}
end;

destructor TAMQPConnection.Destroy;
{$IfDef USE_CONSUMER_THREAD}
 {$IfDef FPC}
   var SemArgs: TSEMun;
 {$EndIf}
{$EndIf}
begin
 {$IfDef USE_CONSUMER_THREAD}
 {$IfDef FPC}
  FillChar(SemArgs, sizeof(SemArgs), 0);
  semctl(FSemaphore, 0, IPC_RMID, SemArgs);
 {$Else}
  if FSemaphore <> NullSemaphore then
   FSemaphore.Free;
 {$EndIf}
 {$EndIf}
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
  DoOnConnect;
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
     [Frame.AsContainer.class_id, Frame.AsContainer.method_id]), Frame)
  else
    DoOnChannelOpen(Result);
end;

initialization
{$IfDef AMQP_DEBUG}
 {$IfDef FPC}
   InitCriticalSection(DbgLock);
 {$Else}
   DbgLock := TCriticalSection.Create;
 {$EndIf}
{$EndIf}

finalization
{$IfDef AMQP_DEBUG}
 {$IfDef FPC}
   DoneCriticalSection(DbgLock);
 {$Else}
   DbgLock.Free;
 {$EndIf}
{$EndIf}

end.

