
unit amqp_proto;

interface

uses classes, blcksock, amqp_types;


type
  TAMQPSessionOnConnect = procedure(Sender: TObject;
    Mechanisms, Locales: AnsiString; var Mechanism, Locale: AnsiString)
    of object;
  TAMQPSessionOnTune = procedure(Sender: TObject;
    var ChannelMax: amqp_short_uint; var FrameMax: amqp_long_uint;
    var Heartbeat: amqp_short_uint) of object;
  TAMQPExchangeType = (etTopic, etFanout, etDirect, etHeaders);
  TAMQPDeliveryMode = (dmNonPersistent = 1, dmPersistent = 2);
  TAMQPRead = procedure(Sender: TObject; AExchangeName, ARoutingKey, AConsumerTag: AnsiString; ADeliveryTag: UInt64; ARedelivered: Boolean; ABodySize: Cardinal; ABody, AContentType,
       AContentEncoding, ACorrelationId, AReplyTo, AExpiration, AMessageId, AType, AUserId, AAppId, AClusterId: AnsiString;
       ADeliveryMode: TAMQPDeliveryMode; APriority: Byte; ATimeStamp: TDateTime; var Ack: Boolean) of object;

  TAMQPSession = class;

  TAMQPListenThread = class(TThread)
  private
    FSession: TAMQPSession;
    FExchangeName, FRoutingKey, FConsumerTag: AnsiString;
    FDeliveryTag: UInt64;
    FRedelivered: Boolean;
    FBodySize: Cardinal;
    FBody: AnsiString;
    FContentType, FContentEncoding, FCorrelationId, FReplyTo, FExpiration, FMessageId, FType, FUserId, FAppId, FClusterId: AnsiString;
    FDeliveryMode: TAMQPDeliveryMode;
    FPriority: Byte;
    FTimeStamp: TDateTime;
    FAck: Boolean;
  protected
    procedure Execute; override;
    procedure DoEvent;
  public
    constructor Create(ASession: TAMQPSession);
  end;

  TAMQPSession = class
  private
    FListen: TAMQPListenThread;
    FPort: AnsiString;
    FPass: AnsiString;
    FHost: AnsiString;
    FUser: AnsiString;
    FSocket: TTCPBlockSocket;
    FFrameMax: amqp_long_uint;
    FHeartbeat: amqp_short_uint;
    FChannelMax: amqp_short_uint;
    FServerProduct: AnsiString;
    FServerPlatform: AnsiString;
    FServerInfo: AnsiString;
    FServerCopyright: AnsiString;
    FServerVersion: AnsiString;
    FOnConnect: TAMQPSessionOnConnect;
    FVHost: AnsiString;
    FOnTune: TAMQPSessionOnTune;
    FExchange: AnsiString;
    FQueue: AnsiString;
    FRoutingKey: AnsiString;
    FActive: Boolean;
    FChannel: Word;
    FChannelId: AnsiString;
    FReplyMethodId: Word;
    FReplyClassId: Word;
    FReplyText: AnsiString;
    FReplyCode: Word;
    FTimeout: Integer;
    FOnRead: TAMQPRead;
    FNoAck: Boolean;
  protected
    procedure DoOnConnect(Mechanisms, Locales: AnsiString;
      var Mechanism, Locale: AnsiString);
    procedure DoTune(var ChannelMax: amqp_short_uint;
      var FrameMax: amqp_long_uint; var Heartbeat: amqp_short_uint);
    procedure DoRead(AExchangeName, ARoutingKey, AConsumerTag: AnsiString; ADeliveryTag: UInt64; ARedelivered: Boolean; ABodySize: Cardinal; ABody, AContentType,
       AContentEncoding, ACorrelationId, AReplyTo, AExpiration, AMessageId, AType, AUserId, AAppId, AClusterId: AnsiString;
       ADeliveryMode: TAMQPDeliveryMode; APriority: Byte; ATimeStamp: TDateTime; var Ack: Boolean);
    function ReadFrame: amqp_frame;
    procedure SendFrame(frame: amqp_frame);
    function HasData: Boolean;
    function CheckFrameMethod(aframe: amqp_frame; amethodclass: amqp_method_class): Boolean;
    procedure SendHearbeat;
    procedure FreeFrame(var frame: amqp_frame);
  public
    constructor Create;
    destructor Destroy; override;
    property Active: Boolean read FActive;
    property Host: AnsiString read FHost write FHost;
    property Port: AnsiString read FPort write FPort;
    property User: AnsiString read FUser write FUser;
    property Pass: AnsiString read FPass write FPass;
    property VHost: AnsiString read FVHost write FVHost;
    property ChannelMax: amqp_short_uint read FChannelMax;
    property FrameMax: amqp_long_uint read FFrameMax;
    property Heartbeat: amqp_short_uint read FHeartbeat;
    property NoAck: Boolean read FNoAck;

    property Socket: TTCPBlockSocket read FSocket;

    property ServerCopyright: AnsiString read FServerCopyright;
    property ServerInfo: AnsiString read FServerInfo;
    property ServerPlatform: AnsiString read FServerPlatform;
    property ServerProduct: AnsiString read FServerProduct;
    property ServerVersion: AnsiString read FServerVersion;
    property OnConnect: TAMQPSessionOnConnect read FOnConnect write FOnConnect;
    property OnTune: TAMQPSessionOnTune read FOnTune write FOnTune;
    property OnRead: TAMQPRead read FOnRead write FOnRead;
    property Exchange: AnsiString read FExchange;
    property Queue: AnsiString read FQueue;
    property RoutingKey: AnsiString read FRoutingKey;
    property Channel: Word read FChannel;
    property ChannelId: AnsiString read FChannelId;
    property ReplyCode: Word read FReplyCode;
    property ReplyText: AnsiString read FReplyText;
    property ReplyClassId: Word read FReplyClassId;
    property ReplyMethodId: Word read FReplyMethodId;

    procedure ResetError;

    function Connect: Boolean;
    function OpenChannel(AChannel: Word): AnsiString;

    function DeclareExchange(AExchangeName: AnsiString;
      AExchangeType: TAMQPExchangeType; APassive, ADurable, AAutoDelete,
      AInternal, ANoWait: Boolean): Boolean;
    function DeleteExchange(AExchangeName: AnsiString; aIfUnused, aNoWait: Boolean): Boolean;
    function DeclareQueue(AQueueName: AnsiString;
      APassive, ADurable, AExclusive, AAutodelete, ANoWait: Boolean): Boolean;
    function BindQueue(AQueueName, AExchangeName, ARoutingKey: AnsiString; ANoWait: Boolean): Boolean;
    function UnbindQueue(AQueueName, AExchangeName, ARoutingKey: AnsiString): Boolean;
    function PurgeQueue(AQueueName: AnsiString; ANoWait: Boolean; var AMsgCount: Cardinal): Boolean;
    function DeleteQueue(AQueueName: AnsiString; AIfUnused, AIfEmpty, ANoWait: Boolean; var AMsgCount: Cardinal): Boolean;
    function BasicQOS(APrefetchSize: LongWord; APrefetchCount: Word; AGlobal: Boolean): Boolean;
    function BasicConsume(AQueueName : AnsiString; var AConsumerTag: AnsiString; ANoLocal, ANoAck, AExclusive, ANoWait: Boolean): Boolean;
    function BasicCancel(AConsumerTag: AnsiString; ANoWait: Boolean): Boolean;
    function BasicPublish(AExchangeName, ARoutingKey: AnsiString; AMandatory, AImmediate: Boolean; ABody, AContentType,
       AContentEncoding, ACorrelationId, AReplyTo, AExpiration, AMessageId, AType, AUserId, AAppId, AClusterId: AnsiString; ADeliveryMode: TAMQPDeliveryMode; APriority: Byte;
       ATimeStamp: TDateTime; AHeaders: amqp_peer_properties): Boolean;
    function BasicRead(var AExchangeName, ARoutingKey, AConsumerTag: AnsiString; var ADeliveryTag: UInt64; var ARedelivered: Boolean; var ABodySize: Cardinal; var ABody, AContentType,
       AContentEncoding, ACorrelationId, AReplyTo, AExpiration, AMessageId, AType, AUserId, AAppId, AClusterId: AnsiString;
       var ADeliveryMode: TAMQPDeliveryMode; var APriority: Byte; var ATimeStamp: TDateTime): Boolean;

    function BasicAck(ADeliveryTag: UInt64; AMultiply: Boolean): Boolean;
    function BasicNAck(ADeliveryTag: UInt64; AMultiply, ARequeue: Boolean): Boolean;
    function StartListen: Boolean;
    function StopListen: Boolean;
  end;

implementation

uses windows, dateutils;

const
  cAMQP = $50514D41;

const
  cExchangeType : array[TAMQPExchangeType] of AnsiString = ('topic', 'fanout', 'direct', 'headers');

type
  _amqp_header = record
    sign: LongWord;
    protocolmajor: amqp_octet;
    protocolminor: amqp_octet;
    versionmajor: amqp_octet;
    versionminor: amqp_octet;
  end;

function amqp_header(AProtocolIdMajor, AProtocolIdMinor, AVersionMajor,
  AVersionMinor: amqp_octet): _amqp_header;
begin
  with result do
  begin
    sign := cAMQP;
    protocolmajor := AProtocolIdMajor;
    protocolminor := AProtocolIdMinor;
    versionmajor := AVersionMajor;
    versionminor := AVersionMinor;
  end;
end;


{ TAMQPSession }

function TAMQPSession.BasicAck(ADeliveryTag: UInt64; AMultiply: Boolean): Boolean;
var frame: amqp_frame;
begin
 result := False;
 if FNoAck then
 begin
  Result := true;
  exit;
 end;
 if FActive and (FChannel > 0) and (FChannelId <> '')  and (FReplyCode = 0) then
  begin
    frame := amqp_method_basic_ack.create_frame(FChannel, ADeliveryTag, AMultiply);
    try
      SendFrame(frame);
    finally
     FreeFrame(frame);
    end;

    frame := ReadFrame;
    if frame <> nil then
     try
       if not CheckFrameMethod(frame, amqp_empty_method) then
          Exit;
     finally
       FreeFrame(frame);
     end;
   Result := True;
  end;
end;

function TAMQPSession.BasicCancel(AConsumerTag: AnsiString; ANoWait: Boolean): Boolean;
var frame: amqp_frame;
begin
 result := False;
 if FActive and (FChannel > 0) and (FChannelId <> '')  and (FReplyCode = 0) then
  begin
    frame := amqp_method_basic_cancel.create_frame(FChannel, AConsumerTag, ANoWait);
    try
      SendFrame(frame);
    finally
     FreeFrame(frame);
    end;

    frame := ReadFrame;
    try
     if not CheckFrameMethod(frame, amqp_method_basic_cancel_ok) then
      Exit;
    finally
      FreeFrame(frame);
    end;
   Result := True;
  end;
end;

function TAMQPSession.BasicConsume(AQueueName: AnsiString; var AConsumerTag: AnsiString; ANoLocal, ANoAck, AExclusive,
  ANoWait: Boolean): Boolean;
var frame: amqp_frame;
begin
 result := False;
 if FActive and (FChannel > 0) and (FChannelId <> '')  and (FReplyCode = 0) then
  begin
    frame := amqp_method_basic_consume.create_frame(FChannel, 0, AQueueName, AConsumerTag, ANoLocal, ANoAck, AExclusive, ANoWait, nil);
    try
      SendFrame(frame);
    finally
     FreeFrame(frame);
    end;

    frame := ReadFrame;
    try
     if not CheckFrameMethod(frame, amqp_method_basic_consume_ok) then
      Exit
     else
     with amqp_method_basic_consume_ok(frame.AsMethod.method) do
      AConsumerTag := consumerTag;
      FNoAck := ANoAck;
    finally
      FreeFrame(frame);
    end;
   Result := True;
  end;
end;

function TAMQPSession.BasicNAck(ADeliveryTag: UInt64; AMultiply, ARequeue: Boolean): Boolean;
var frame: amqp_frame;
begin
 result := False;
 if FNoAck then
 begin
  Result := true;
  exit;
 end;
 if FActive and (FChannel > 0) and (FChannelId <> '')  and (FReplyCode = 0) then
  begin
    frame := amqp_method_basic_nack.create_frame(FChannel, ADeliveryTag, AMultiply, ARequeue);
    try
      SendFrame(frame);
    finally
     FreeFrame(frame);
    end;

    frame := ReadFrame;
    if frame <> nil then
     try
       if not CheckFrameMethod(frame, amqp_empty_method) then
        Exit;
     finally
       FreeFrame(frame);
     end;
   Result := True;
  end;
end;

function TAMQPSession.BasicPublish(AExchangeName, ARoutingKey: AnsiString; AMandatory, AImmediate: Boolean;
  ABody, AContentType, AContentEncoding, ACorrelationId, AReplyTo, AExpiration, AMessageId, AType, AUserId, AAppId, AClusterId: AnsiString;
  ADeliveryMode: TAMQPDeliveryMode; APriority: Byte; ATimeStamp: TDateTime; AHeaders: amqp_peer_properties): Boolean;
var Offset: Cardinal;
    MaxSize: Cardinal;
    BodySize, Len: Cardinal;
    frame: amqp_frame;
    remaining: Cardinal;
begin
  MaxSize := FFrameMax - 8;
  Result := False;

 if FActive and (FChannel > 0) and (FChannelId <> '')  and (FReplyCode = 0) then
  begin
    frame := amqp_method_basic_publish.create_frame(FChannel, 0, AExchangeName, ARoutingKey, AMandatory, AImmediate);
    try
      SendFrame(frame);
    finally
      FreeFrame(frame);
    end;
    BodySize := Length(ABody);
    if HasData then
     begin
      frame := ReadFrame;
      Result := CheckFrameMethod(frame, amqp_method_basic_publish);
     end else
      Result := True;

   if Result then
   begin
    frame := amqp_content_header.create_frame(FChannel, amqp_method_basic_class.class_id, 0, BodySize);
    with frame.AsContentHeader do
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
    try
      SendFrame(frame);
    finally
      FreeFrame(frame);
    end;
   end;
   if HasData then
   begin
    frame := ReadFrame;
    Result := CheckFrameMethod(frame, amqp_method_basic_publish);
   end else
    Result := True;
   if Result then
   begin
     Offset := 0;
     while Offset < BodySize do
     begin
      remaining := BodySize - Offset;
      if remaining > MaxSize then
       Len := MaxSize
      else
       Len := remaining;

      frame := amqp_content_body.create_frame(FChannel,  Len, @ABody[Offset+1]);
      try
        SendFrame(frame);
      finally
        FreeFrame(frame);
      end;
       Offset := Offset + Len;
     end;
   end;
   if HasData then
   begin
    frame := ReadFrame;
    Result := CheckFrameMethod(frame, amqp_method_basic_publish);
   end else
    Result := True;
  end;
end;

function TAMQPSession.BasicQOS(APrefetchSize: LongWord; APrefetchCount: Word; AGlobal: Boolean): Boolean;
var frame: amqp_frame;
begin
 result := False;
 if FActive and (FChannel > 0) and (FChannelId <> '')  and (FReplyCode = 0) then
  begin
    frame := amqp_method_basic_qos.create_frame(FChannel, APrefetchSize, APrefetchcount, AGlobal);
    try
      SendFrame(frame);
    finally
     FreeFrame(frame);
    end;

    frame := ReadFrame;
    try
     if not CheckFrameMethod(frame, amqp_method_basic_qos_ok) then
      Exit;
    finally
      FreeFrame(frame);
    end;
   Result := True;
  end;
end;

function TAMQPSession.BasicRead(var AExchangeName, ARoutingKey, AConsumerTag: AnsiString; var ADeliveryTag: UInt64; var ARedelivered: Boolean; var ABodySize: Cardinal; var ABody, AContentType,
       AContentEncoding, ACorrelationId, AReplyTo, AExpiration, AMessageId, AType, AUserId, AAppId, AClusterId: AnsiString;
       var ADeliveryMode: TAMQPDeliveryMode; var APriority: Byte; var ATimeStamp: TDateTime): Boolean;
var frame: amqp_frame;
    len: Integer;
    Buf: AnsiString;
begin
 Result := False;
 ABody := '';
 frame := ReadFrame;

 try
  Result := CheckFrameMethod(frame, amqp_method_basic_deliver);
  if Result then
   with amqp_method_basic_deliver(frame.AsMethod.method) do
   begin
    ADeliveryTag := deliveryTag;
    ARedelivered := redelivered;
    AExchangeName := exchange;
    ARoutingKey := routingKey;
    AconsumerTag := AConsumerTag;
   end;
 finally
   FreeFrame(frame);
 end;

 if Result then
  begin
    frame := ReadFrame;
    Result := (frame <> nil) and (frame.frame_type = AMQP_FRAME_HEADER);
    if Result then
     with frame.AsContentHeader do
     begin
      ABodySize := frame.AsContentHeader.bodySize;
      AContentType := contentType;
      AContentEncoding := contentEncoding;
      AReplyTo := replyTo;
      AExpiration := expiration;
      AMessageId := messageId;
      AType := _type;
      AUserId := userId;
      AAppId := appId;
      AClusterId := clusterId;
      ADeliveryMode := TAMQPDeliveryMode(deliveryMode);
      APriority := priority;
      ATimeStamp := UnixToDateTime(timestamp);
     end
    else
     Result := False;
     FreeFrame(frame);
  end;

  if Result then
  begin
   len := 0;
   repeat
    frame := ReadFrame;
    try
      Result := (frame <> nil) and (frame.frame_type = AMQP_FRAME_BODY);
      if Result then
      begin
       SetLength(Buf, frame.AsContentBody.len);
       move(frame.AsContentBody.Data^, Buf[1], frame.AsContentBody.len);
       ABody := ABody + Buf;
      end else
       Result := False;
       len := len + frame.AsContentBody.len;
    finally
      FreeFrame(frame);
    end;
   until (len >= ABodySize) or (not Result);
  end;
end;

function TAMQPSession.BindQueue(AQueueName, AExchangeName, ARoutingKey: AnsiString; ANoWait: Boolean): Boolean;
var frame: amqp_frame;
begin
 result := False;
 if FActive and (FChannel > 0) and (FChannelId <> '')  and (FReplyCode = 0) then
  begin
    frame := amqp_method_queue_bind.create_frame(FChannel, 0, AQueueName, AExchangeName, ARoutingKey, ANoWait, nil);
    try
      SendFrame(frame);
    finally
     FreeFrame(frame);
    end;

    frame := ReadFrame;
    try
     if not CheckFrameMethod(frame, amqp_method_queue_bind_ok) then
      Exit;
    finally
      FreeFrame(frame);
    end;
   Result := True;
  end;
end;

function TAMQPSession.CheckFrameMethod(aframe: amqp_frame; amethodclass: amqp_method_class): Boolean;
begin
 Result := not ((aframe = nil) or (aframe.frame_type <> AMQP_FRAME_METHOD) or (aframe.AsMethod = nil) or (aframe.AsMethod.method = nil)
  or (aframe.AsMethod.class_id <> amethodclass.class_id) or (aframe.AsMethod.method_id <> amethodclass.method_id));
 FReplyClassId := amethodclass.class_id;
 FReplyMethodId := amethodclass.method_id;
 if Result then
  begin
    FReplyCode := 0;
    FReplyText := 'OK';
  end
  else
  begin
    if aframe = nil then
    begin
     FReplyCode := 2;
     FReplyText := 'frame failure';
    end else
    if aframe.frame_type = AMQP_FRAME_HEARTBEAT then
    begin
      FReplyCode := 1;
      FReplyText := 'heartbeat';
      SendHearbeat;
    end else
    if aframe.frame_type <> AMQP_FRAME_METHOD then
    begin
      FReplyCode := 3;
      FReplyText := 'frame is not have method';
    end else
    if (aframe.AsMethod = nil) or (aframe.AsMethod.method = nil) then
    begin
      FReplyCode := 10;
      FReplyText := 'unknown error';
    end else
    if (aframe.AsMethod.class_id = amqp_method_close.class_id) and (aframe.AsMethod.method_id = amqp_method_close.method_id) then
    begin
      with amqp_method_close(aframe.AsMethod.method) do
       begin
         FReplyCode := replyCode;
         FReplyText := replyText;
         FReplyClassId := rclassid;
         FReplyMethodId := rmethodid;
       end;
    end else
    if (aframe.AsMethod.class_id = amqp_method_channel_close.class_id) and (aframe.AsMethod.method_id = amqp_method_channel_close.method_id) then
    begin
      with amqp_method_channel_close(aframe.AsMethod.method) do
       begin
         FReplyCode := replyCode;
         FReplyText := replyText;
         FReplyClassId := rclassid;
         FReplyMethodId := rmethodid;
       end;
    end;

  end;
end;

function TAMQPSession.Connect: Boolean;
var
  hdr: _amqp_header;
  frame: amqp_frame;
  mh, lc, mho, lco: AnsiString;
  i: Integer;
begin
  result := false;
  FSocket.CloseSocket;
  FActive := false;
  FSocket.Connect(FHost, FPort);
  if FSocket.LastError = 0 then
  begin
    hdr := amqp_header(0, 0, 9, 1);
    FSocket.SendBuffer(@hdr, sizeOf(hdr));
    if FSocket.CanRead(FTimeout) then
    begin
      frame := ReadFrame;
      try
        if not CheckFrameMethod(frame, amqp_method_start) then
          exit
        else
        begin
          with amqp_method_start(frame.AsMethod.method) do
          begin
            mh := Mechanisms;
            lc := Locales;
            mho := 'PLAIN';
            lco := 'en_US';
            DoOnConnect(mh, lc, mho, lco);
            for i := 0 to properties.Count - 1 do
              if properties[i].field_name.val = 'copyright' then
                FServerCopyright := properties[i].field_value.AsLongString
              else if properties[i].field_name.val = 'information' then
                FServerInfo := properties[i].field_value.AsLongString
              else if properties[i].field_name.val = 'platform' then
                FServerPlatform := properties[i].field_value.AsLongString
              else if properties[i].field_name.val = 'product' then
                FServerProduct := properties[i].field_value.AsLongString
              else if properties[i].field_name.val = 'version' then
                FServerVersion := properties[i].field_value.AsLongString;
          end;
        end;
      finally
        FreeFrame(frame);
      end;

      frame := amqp_method_start_ok.create_frame(0, nil, mho,
        #0 + FUser + #0 + FPass, lco);
      try
        SendFrame(frame);
      finally
        FreeFrame(frame);
      end;

      frame := ReadFrame;
      try
        if not CheckFrameMethod(frame, amqp_method_tune) then
          exit
        else
        begin
          with amqp_method_tune(frame.AsMethod.method) do
          begin
            FFrameMax := FrameMax;
            FChannelMax := ChannelMax;
            FHeartbeat := Heartbeat;
          end;
        end;
      finally
        FreeFrame(frame);
      end;

      DoTune(FChannelMax, FFrameMax, FHeartbeat);

      frame := amqp_method_tune_ok.create_frame(0, FChannelMax, FFrameMax,
        FHeartbeat);
      try
        SendFrame(frame);
      finally
        FreeFrame(frame);
      end;

      frame := amqp_method_open.create_frame(0, FVHost);
      try
        SendFrame(frame);
      finally
        FreeFrame(frame);
      end;

      frame := ReadFrame;
      try
        if not CheckFrameMethod(frame, amqp_method_open_ok) then
          exit;
      finally
        FreeFrame(frame);
      end;

    end;
    result := true;
  end;
  FActive := result;
end;

constructor TAMQPSession.Create;
begin
  FSocket := TTCPBlockSocket.Create;
  FTimeout := 1000;
  FVHost := '/';
  FActive := false;
  ResetError;
  FListen := TAMQPListenThread.Create(Self);
end;

function TAMQPSession.DeclareExchange(AExchangeName: AnsiString; AExchangeType: TAMQPExchangeType; APassive, ADurable,
  AAutoDelete, AInternal, ANoWait: Boolean): Boolean;
var frame: amqp_frame;
begin
 result := False;
 if FActive and (FChannel > 0) and (FChannelId <> '') and (FReplyCode = 0) then
  begin
    frame := amqp_method_exchange_declare.create_frame(FChannel, AExchangeName, cExchangeType[AExchangeType], APassive, ADurable, AAutoDelete, AInternal, ANoWait, nil);
    try
      SendFrame(frame);
    finally
     FreeFrame(frame);
    end;

    frame := ReadFrame;
    try
     if not CheckFrameMethod(frame, amqp_method_exchange_declare_ok) then
      Exit;
    finally
      FreeFrame(frame);
    end;
   Result := True;
  end;
end;

function TAMQPSession.DeclareQueue(AQueueName: AnsiString; APassive, ADurable, AExclusive, AAutodelete,
  ANoWait: Boolean): Boolean;
var frame: amqp_frame;
begin
 result := False;
 if FActive and (FChannel > 0) and (FChannelId <> '')  and (FReplyCode = 0) then
  begin
    frame := amqp_method_queue_declare.create_frame(FChannel, 0, AQueueName, APassive, ADurable, AExclusive, AAutoDelete, ANoWait, nil);
    try
      SendFrame(frame);
    finally
     FreeFrame(frame);
    end;

    frame := ReadFrame;
    try
     if not CheckFrameMethod(frame, amqp_method_queue_declare_ok) then
      Exit;
    finally
      FreeFrame(frame);
    end;
   Result := True;
  end;
end;

function TAMQPSession.DeleteExchange(AExchangeName: AnsiString; aIfUnused, aNoWait: Boolean): Boolean;
var frame: amqp_frame;
begin
 result := False;
 if FActive and (FChannel > 0) and (FChannelId <> '')  and (FReplyCode = 0) then
  begin
    frame := amqp_method_exchange_delete.create_frame(FChannel, AExchangeName, aIfUnused, aNoWait);
    try
      SendFrame(frame);
    finally
     FreeFrame(frame);
    end;

    frame := ReadFrame;
    try
     if not CheckFrameMethod(frame, amqp_method_exchange_delete_ok) then
      Exit;
    finally
      FreeFrame(frame);
    end;
   Result := True;
  end;
end;

function TAMQPSession.DeleteQueue(AQueueName: AnsiString; AIfUnused, AIfEmpty, ANoWait: Boolean; var AMsgCount: Cardinal): Boolean;
var frame: amqp_frame;
begin
 result := False;
 AMsgCount := 0;
 if FActive and (FChannel > 0) and (FChannelId <> '')  and (FReplyCode = 0) then
  begin
    frame := amqp_method_queue_delete.create_frame(FChannel, 0, AQueueName, AIfUnused, AIfEmpty, ANoWait);
    try
      SendFrame(frame);
    finally
     FreeFrame(frame);
    end;

    frame := ReadFrame;
    try
     if not CheckFrameMethod(frame, amqp_method_queue_delete_ok) then
      Exit
     else
     with amqp_method_queue_delete_ok(frame.AsMethod.method) do
      AMsgCount := message_count
    finally
      FreeFrame(frame);
    end;
   Result := True;
  end;
end;

destructor TAMQPSession.Destroy;
begin
  FListen.Terminate;
  FListen.WaitFor;
  FListen.Free;
  FSocket.Free;
  inherited;
end;

procedure TAMQPSession.DoOnConnect(Mechanisms, Locales: AnsiString;
  var Mechanism, Locale: AnsiString);
begin
  if Assigned(FOnConnect) then
    FOnConnect(Self, Mechanisms, Locales, Mechanism, Locale);
end;

procedure TAMQPSession.DoRead(AExchangeName, ARoutingKey, AConsumerTag: AnsiString; ADeliveryTag: UInt64;
  ARedelivered: Boolean; ABodySize: Cardinal; ABody, AContentType, AContentEncoding, ACorrelationId, AReplyTo,
  AExpiration, AMessageId, AType, AUserId, AAppId, AClusterId: AnsiString; ADeliveryMode: TAMQPDeliveryMode;
  APriority: Byte; ATimeStamp: TDateTime; var Ack: Boolean);
begin
 if Assigned(FOnRead) then
  FOnRead(Self, AExchangeName, ARoutingKey, AConsumerTag, ADeliveryTag, ARedelivered, ABodySize, ABody, AContentType, AContentEncoding, ACorrelationId, AReplyTo,
   AExpiration, AMessageId, AType, AUserId, AAppId, AClusterId, ADeliveryMode, APriority, ATimeStamp, Ack);
end;

procedure TAMQPSession.DoTune(var ChannelMax: amqp_short_uint;
  var FrameMax: amqp_long_uint; var Heartbeat: amqp_short_uint);
begin
  if Assigned(FOnTune) then
    FOnTune(Self, ChannelMax, FrameMax, Heartbeat);
end;

procedure TAMQPSession.FreeFrame(var frame: amqp_frame);
begin
 if frame <> nil then
  begin
    frame.Free;
    frame := nil;
  end;
end;

function TAMQPSession.HasData: Boolean;
begin
 Result := FSocket.CanRead(0);
end;

function TAMQPSession.OpenChannel(AChannel: Word): AnsiString;
var frame: amqp_frame;
begin
 result := '';
 if FActive then
  begin

    frame := amqp_method_channel_open.create_frame(AChannel, '');
    try
      SendFrame(frame);
    finally
      FreeFrame(frame);
    end;

    frame := ReadFrame;
    try
     if not CheckFrameMethod(frame, amqp_method_channel_open_ok) then
      Exit
     else
      with amqp_method_channel_open_ok(frame.AsMethod.method) do
       FChannelId := ChannelId;

     if FChannelId = '' then
      FChannelId := '<MISSING>';

     Result := FChannelId;
     FChannel := AChannel;

    finally
      FreeFrame(frame);
    end;
  end;
end;

function TAMQPSession.PurgeQueue(AQueueName: AnsiString; ANoWait: Boolean; var AMsgCount: Cardinal): Boolean;
var frame: amqp_frame;
begin
 result := False;
 AMsgCount := 0;
 if FActive and (FChannel > 0) and (FChannelId <> '')  and (FReplyCode = 0) then
  begin
    frame := amqp_method_queue_purge.create_frame(FChannel, 0, AQueueName, ANoWait);
    try
      SendFrame(frame);
    finally
     FreeFrame(frame);
    end;

    frame := ReadFrame;
    try
     if not CheckFrameMethod(frame, amqp_method_queue_purge_ok) then
      Exit
      else
      with amqp_method_queue_purge_ok(frame.AsMethod.method) do
       AMsgCount := message_count;

    finally
      FreeFrame(frame);
    end;
   Result := True;
  end;
end;

function TAMQPSession.ReadFrame: amqp_frame;
var
  Buf: TMemoryStream;
  b: byte;
begin
  result := amqp_frame.Create;
    Buf := TMemoryStream.Create;
    try
      repeat
        b := FSocket.RecvByte(FTimeout);
        if FSocket.LastError = 0 then
          Buf.Write(b, sizeOf(b));
      until (b = $CE) or (FSocket.LastError <> 0);

      if FSocket.LastError <> 0 then
        Buf.Clear;

      Buf.Position := 0;
      if Buf.Size > 0 then
        result.Read(Buf)
       else
       begin
          result.Free;
          result := nil;
       end;
    finally
      Buf.Free;
    end;
end;

procedure TAMQPSession.ResetError;
begin
 FReplyMethodId := 0;
 FReplyClassId := 0;
 FReplyText := '';
 FReplyCode := 0;
end;

procedure TAMQPSession.SendFrame(frame: amqp_frame);
var
  Buf: TMemoryStream;
begin
  Buf := TMemoryStream.Create;
  try
    frame.Write(Buf);
    Buf.Position := 0;
    FSocket.SendStreamRaw(Buf);
  finally
    Buf.Free;
  end;
end;

procedure TAMQPSession.SendHearbeat;
var frame: amqp_frame;
begin
  frame := amqp_heartbeat.create_frame(0);
  try
    SendFrame(frame);
  finally
    FreeFrame(frame);
  end;
end;

function TAMQPSession.StartListen: Boolean;
begin
 FListen.Suspended := False;
end;

function TAMQPSession.StopListen: Boolean;
begin
 FListen.Suspended := True;
end;

function TAMQPSession.UnbindQueue(AQueueName, AExchangeName, ARoutingKey: AnsiString): Boolean;
var frame: amqp_frame;
begin
 result := False;
 if FActive and (FChannel > 0) and (FChannelId <> '')  and (FReplyCode = 0) then
  begin
    frame := amqp_method_queue_unbind.create_frame(FChannel, 0, AQueueName, AExchangeName, ARoutingKey, nil);
    try
      SendFrame(frame);
    finally
     FreeFrame(frame);
    end;

    frame := ReadFrame;
    try
     if not CheckFrameMethod(frame, amqp_method_queue_unbind_ok) then
      Exit;
    finally
      FreeFrame(frame);
    end;
   Result := True;
  end;
end;

{ TAMQPListenThread }

constructor TAMQPListenThread.Create(ASession: TAMQPSession);
begin
 inherited Create(True);
 FSession := ASession;
end;

procedure TAMQPListenThread.DoEvent;
begin
 FSession.DoRead(FExchangeName, FRoutingKey, FConsumerTag, FDeliveryTag, FRedelivered, FBodySize, FBody,
               FContentType, FContentEncoding, FCorrelationId, FReplyTo, FExpiration, FMessageId, FType, FUserId, FAppId, FClusterId,
               FDeliveryMode, FPriority, FTimeStamp, FAck);
end;

procedure TAMQPListenThread.Execute;
begin
 repeat
  if (FSession <> nil) and (FSession.Active) then
   begin
    FAck := True;
    if FSession.BasicRead(FExchangeName, FRoutingKey, FConsumerTag, FDeliveryTag, FRedelivered, FBodySize, FBody,
               FContentType, FContentEncoding, FCorrelationId, FReplyTo, FExpiration, FMessageId, FType, FUserId, FAppId, FClusterId,
               FDeliveryMode, FPriority, FTimeStamp) then
     begin
       Synchronize(DoEvent);
       if FAck then
        FSession.BasicAck(FDeliveryTag, False);
     end;
   end;
  Sleep(10);
 until Terminated;
end;

end.

