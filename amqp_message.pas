unit amqp_message;
{$ifdef fpc}
  {$mode objfpc}{$H+}
{$endif}

interface

uses
    Classes, SysUtils, amqp_types, IdGlobal;

type
{$ifdef fpc}
  TAMQPBody = array of Byte;
{$else}
  TIdAMQPBody = TBytes;
{$endif}

  TAMQPDeliveryMode = (dmNone, dmNonPersistent, dmPersistent);

  { IAMQPMessage }

  IAMQPMessage = interface;

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
  end;

  IAMQPMessage = interface
  ['{23A8D576-7FE7-4393-87C3-B078CB987DF7}']
    function GetAppId: AnsiString;
    function GetBody: TIdBytes;
    function GetBodyAsString: AnsiString;
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
    property Body: TIdBytes read GetBody;
    property BodyAsString: AnsiString read GetBodyAsString write SetBodyAsString;
    property HdrAsString[AName: AnsiString]: AnsiString read GetHdrAsString write SetHdrAsString;
    property HdrAsBoolean[AName: AnsiString]: Boolean read GetHdrAsBoolean write SetHdrAsBoolean;
    property HdrAsNumber[AName: AnsiString]: Double read GetHdrAsNumber write SetHdrAsNumber;
    property Channel: IAMQPChannelAck read GetChannel write SetChannel;
  end;
  { TAMQPMessage }

  TAMQPMessage = class(TInterfacedObject, IAMQPMessage)
  private
    FChannel: IAMQPChannelAck;
    FRedelivered: Boolean;
    FDeliveryTag: UInt64;
    FExchange: AnsiString;
    FRoutingKey: AnsiString;
    FMessageCount: Integer;
    FExpiration: AnsiString;
    FBodySize: UInt64;
    Fheaders: IAMQPHeaders;
    FUserId: AnsiString;
    FType: AnsiString;
    FAppId: AnsiString;
    FpropFlags: Word;
    FCorrelationId: AnsiString;
    FContentType: AnsiString;
    FTimestamp: TDateTime;
    FClusterId: AnsiString;
    FContentEncoding: AnsiString;
    FReplyTo: AnsiString;
    FWeight: Word;
    FMessageId: AnsiString;
    FDeliveryMode: TAMQPDeliveryMode;
    FPriority: Byte;
    FBody: TIdBytes;
    FPosition: UInt64;
    function GetAppId: AnsiString;
    function GetBody: TIdBytes;
    function GetBodyAsString: AnsiString;
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
  protected

  public
    constructor Create;
    destructor Destroy; override;
    constructor CreateBasicGet(ABasicGet: IAMQPBasicGetOk);
    constructor CreateBasicDeliver(ADeliver: IAMQPBasicDeliver);
    property Channel: IAMQPChannelAck read GetChannel write SetChannel;
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
    property Body: TIdBytes read GetBody;
    property BodyAsString: AnsiString read GetBodyAsString write SetBodyAsString;
    property HdrAsString[AName: AnsiString]: AnsiString read GetHdrAsString write SetHdrAsString;
    property HdrAsBoolean[AName: AnsiString]: Boolean read GetHdrAsBoolean write SetHdrAsBoolean;
    property HdrAsNumber[AName: AnsiString]: Double read GetHdrAsNumber write SetHdrAsNumber;
  end;


implementation

uses dateutils;

procedure TAMQPMessage.AssignFromContentHeader(AContentHeader
  : IAMQPContentHeader);
begin

  weight := AContentHeader.weight;
  BodySize := AContentHeader.BodySize;
  propFlags := AContentHeader.propFlags;
  contentType := AContentHeader.contentType;
  contentEncoding := AContentHeader.contentEncoding;
  headers.Assign(AContentHeader.headers);
  deliveryMode := TAMQPDeliveryMode(AContentHeader.deliveryMode);
  priority := AContentHeader.priority;
  correlationId := AContentHeader.correlationId;
  replyTo := AContentHeader.replyTo;
  expiration := AContentHeader.expiration;
  messageId := AContentHeader.messageId;
  timestamp := UnixToDateTime(AContentHeader.timestamp);
  &type := AContentHeader._type;
  userId := AContentHeader.userId;
  appId := AContentHeader.appId;
  clusterId := AContentHeader.clusterId;
end;

procedure TAMQPMessage.Assign(ASource: IAMQPMessage);
begin
// DeliveryTag := ASource.DeliveryTag;
// Redelivered := ASource.Redelivered;
   Exchange := ASource.Exchange;
   RoutingKey := ASource.RoutingKey;
//   MessageCount := ASource.MessageCount;
//   weight := ASource.weight;
//   BodySize := ASource.BodySize;
//   propFlags := ASource.propFlags;
   contentType := ASource.contentType;
   contentEncoding := ASource.contentEncoding;
   headers.Assign(ASource.headers);
   deliveryMode := ASource.deliveryMode;
   priority := ASource.priority;
   correlationId := ASource.correlationId;
   replyTo := ASource.replyTo;
   expiration := ASource.expiration;
   messageId := ASource.messageId;
   timestamp := ASource.timestamp;
   &type := ASource.&type;
   userId := ASource.userId;
   appId := ASource.appId;
   clusterId := ASource.clusterId;
   BodyAsString := ASource.BodyAsString;
end;

constructor TAMQPMessage.Create;
begin
  Fheaders := amqp_table.Create;
  FChannel := nil;
  FPosition := 0;
  SetLength(FBody, 0);
end;

constructor TAMQPMessage.CreateBasicDeliver
  (ADeliver: IAMQPBasicDeliver);
begin
  Create;
  FDeliveryTag := ADeliver.DeliveryTag;
  FExchange := ADeliver.Exchange;
  FRedelivered := ADeliver.Redelivered;
  FRoutingKey := ADeliver.RoutingKey;
  FMessageCount := 0;
end;

constructor TAMQPMessage.CreateBasicGet(ABasicGet: IAMQPBasicGetOk);
begin
  Create;
  FDeliveryTag := ABasicGet.DeliveryTag;
  FExchange := ABasicGet.Exchange;
  FRedelivered := ABasicGet.Redelivered;
  FRoutingKey := ABasicGet.RoutingKey;
  FMessageCount := ABasicGet.MessageCount;
end;

destructor TAMQPMessage.Destroy;
begin
  Fheaders := nil;
  SetLength(FBody, 0);
  inherited;
end;

procedure TAMQPMessage.LoadBody(ABody: IAMQPContentBody);
begin
  Move(ABody.Data^, FBody[FPosition], ABody.len);
  inc(FPosition, ABody.len);
end;

procedure TAMQPMessage.LoadBodyFromStream(AStream: TStream; ASize: Int64);
begin
  SetBodySize(ASize);
  AStream.Read(FBody[0], ASize);
end;

procedure TAMQPMessage.LoadBodyFromString(AValue: AnsiString);
begin
  SetBodySize(Length(AValue));
  if AValue <> '' then
   Move(AValue[1], FBody[0], Length(AValue));
end;

procedure TAMQPMessage.SaveBodyToStream(AStream: TStream);
begin
  AStream.Write(FBody[0], Length(FBody));
end;

procedure TAMQPMessage.SaveBodyToFile(AFileName: AnsiString);
var fl: TFileStream;
begin
  Fl := TFileStream.Create(AFileName, fmCreate);
  try
    SaveBodyToStream(fl);
  finally
    fl.Free;
  end;
end;

procedure TAMQPMessage.AddHeaderString(AName, AValue: AnsiString);
begin
  Fheaders.add(AName, AValue);
end;

procedure TAMQPMessage.AddHeaderBoolean(AName: AnsiString; AValue: Boolean);
begin
 Fheaders.add(AName, AValue);
end;

procedure TAMQPMessage.AddHeaderNumber(AName: AnsiString; AValue: Double);
begin
  Fheaders.add(AName, AValue);
end;

procedure TAMQPMessage.DeleteHeader(AName: AnsiString);
var i: Integer;
begin
  i := headers.IndexOfField(AName);
  if i > -1 then
   headers.Delete(i);
end;

procedure TAMQPMessage.BodyFromBytes(ABytes: TBytes);
begin
  BodySize := Length(ABytes);
  Move(ABytes[0], FBody[0], Length(ABytes));
end;

procedure TAMQPMessage.Ack;
begin
  if FChannel <> nil then
     FChannel.BasicAck(DeliveryTag, False);
end;

procedure TAMQPMessage.NoAck(ARequeue: Boolean);
begin
  if FChannel <> nil then
    FChannel.BasicNAck(FDeliveryTag);
end;

procedure TAMQPMessage.SetBodySize(const Value: UInt64);
begin
  FBodySize := Value;
  SetLength(FBody, FBodySize);
end;

procedure TAMQPMessage.SetChannel(AValue: IAMQPChannelAck);
begin
  FChannel := AValue;
end;

procedure TAMQPMessage.SetClusterId(AValue: AnsiString);
begin
  FClusterId := AValue;
end;

procedure TAMQPMessage.SetContentEncoding(AValue: AnsiString);
begin
  FContentEncoding := AValue;
end;

procedure TAMQPMessage.SetContentType(AValue: AnsiString);
begin
 FContentType := AValue;
end;

procedure TAMQPMessage.SetCorrelationId(AValue: AnsiString);
begin
 FCorrelationId := AValue;
end;

procedure TAMQPMessage.SetDeliveryMode(AValue: TAMQPDeliveryMode);
begin
 FDeliveryMode := AValue;
end;

procedure TAMQPMessage.SetExchange(AValue: AnsiString);
begin
 FExchange := AValue;
end;

procedure TAMQPMessage.SetExpiration(AValue: AnsiString);
begin
  FExpiration := AValue;
end;

procedure TAMQPMessage.SetHdrAsBoolean(AName: AnsiString; AValue: Boolean);
var i: Integer;
begin
 i := headers.IndexOfField(AName);
 if i = -1 then
   AddHeaderBoolean(AName, AValue)
 else
  headers.Items[i].field_value.AsBoolean := AValue;
end;

procedure TAMQPMessage.SetHdrAsNumber(AName: AnsiString; AValue: Double);
var i: Integer;
begin
 i := headers.IndexOfField(AName);
 if i = -1 then
   AddHeaderNumber(AName, AValue)
 else
  headers.Items[i].field_value.AsDouble := AValue;
end;

procedure TAMQPMessage.SetHdrAsString(AName: AnsiString; AValue: AnsiString);
var i: Integer;
begin
 i := headers.IndexOfField(AName);
 if i = -1 then
   AddHeaderString(AName, AValue)
 else
  headers.Items[i].field_value.AsLongString := AValue;
end;

procedure TAMQPMessage.SetHeaders(AValue: IAMQPHeaders);
begin
  if AValue = nil then
     Fheaders.Clear
  else
     Fheaders.Assign(AValue);
end;

procedure TAMQPMessage.SetMessageId(AValue: AnsiString);
begin
 FMessageId := AValue;
end;

procedure TAMQPMessage.SetPriority(AValue: Byte);
begin
 FPriority := AValue;
end;

procedure TAMQPMessage.SetpropFlags(AValue: Word);
begin
 FpropFlags := AValue;
end;

procedure TAMQPMessage.SetReplyTo(AValue: AnsiString);
begin
 FReplyTo := AValue;
end;

procedure TAMQPMessage.SetRoutingKey(AValue: AnsiString);
begin
  FRoutingKey := AValue;
end;

procedure TAMQPMessage.SetTimestamp(AValue: TDateTime);
begin
 FTimestamp := AValue;
end;

procedure TAMQPMessage.SetType(AValue: AnsiString);
begin
 FType := AValue;
end;

procedure TAMQPMessage.SetUserId(AValue: AnsiString);
begin
 FUserId := AValue;
end;

procedure TAMQPMessage.SetWeight(AValue: Word);
begin
  FWeight := AValue;
end;

function TAMQPMessage.GetBodyAsString: AnsiString;
begin
  SetLength(Result, Length(FBody));
  Move(FBody[0], Result[1], Length(FBody));
end;

function TAMQPMessage.GetAppId: AnsiString;
begin
  Result := FAppId;
end;

function TAMQPMessage.GetBody: TIdBytes;
begin
 Result := FBody;
end;

function TAMQPMessage.GetBodySize: UInt64;
begin
 Result := FBodySize;
end;

function TAMQPMessage.GetChannel: IAMQPChannelAck;
begin
  Result := FChannel;
end;

function TAMQPMessage.GetClusterId: AnsiString;
begin
 Result := FClusterId;
end;

function TAMQPMessage.GetContentEncoding: AnsiString;
begin
 Result := FContentEncoding;
end;

function TAMQPMessage.GetContentType: AnsiString;
begin
 Result := FContentType;
end;

function TAMQPMessage.GetCorrelationId: AnsiString;
begin
 Result := FcorrelationId;
end;

function TAMQPMessage.GetDeliveryMode: TAMQPDeliveryMode;
begin
 Result := FDeliveryMode;
end;

function TAMQPMessage.GetDeliveryTag: UInt64;
begin
 Result := FDeliveryTag;
end;

function TAMQPMessage.GetExchange: AnsiString;
begin
 Result := FExchange;
end;

function TAMQPMessage.GetExpiration: AnsiString;
begin
  Result := FExpiration;
end;

function TAMQPMessage.GetHdrAsBoolean(AName: AnsiString): Boolean;
var i: Integer;
begin
 i := headers.IndexOfField(AName);
 if i <> -1 then
   Result := headers.Items[i].field_value.AsBoolean
 else
   Result := false;
end;

function TAMQPMessage.GetHdrAsNumber(AName: AnsiString): Double;
var i: Integer;
begin
 i := headers.IndexOfField(AName);
 if i <> -1 then
   Result := headers.Items[i].field_value.AsDouble
 else
   Result := 0;
end;

function TAMQPMessage.GetHdrAsString(AName: AnsiString): AnsiString;
var i: Integer;
begin
 i := headers.IndexOfField(AName);
 if i <> -1 then
   Result := headers.Items[i].field_value.AsLongString
 else
   Result := '';
end;

function TAMQPMessage.Getheaders: IAMQPHeaders;
begin
 Result := Fheaders;
end;

function TAMQPMessage.GetMessageCount: Integer;
begin
 Result := FMessageCount;
end;

function TAMQPMessage.GetMessageId: AnsiString;
begin
 Result := FMessageId;
end;

function TAMQPMessage.GetPriority: Byte;
begin
 Result := FPriority;
end;

function TAMQPMessage.GetpropFlags: Word;
begin
 Result := FpropFlags;
end;

function TAMQPMessage.GetRedelivered: Boolean;
begin
 Result := FRedelivered;
end;

function TAMQPMessage.GetReplyTo: AnsiString;
begin
 Result := FReplyTo;
end;

function TAMQPMessage.GetRoutingKey: AnsiString;
begin
 Result := FRoutingKey;
end;

function TAMQPMessage.GetTimestamp: TDateTime;
begin
 Result := FTimestamp;
end;

function TAMQPMessage.GetType: AnsiString;
begin
 Result := FType;
end;

function TAMQPMessage.GetUserId: AnsiString;
begin
 Result := FUserId;
end;

function TAMQPMessage.GetWeight: Word;
begin
 Result := FWeight;
end;

procedure TAMQPMessage.SetAppId(AValue: AnsiString);
begin
 FAppId := AValue;
end;

procedure TAMQPMessage.SetBodyAsString(AValue: AnsiString);
begin
 SetLength(FBody, Length(AValue));
 FBodySize := Length(AValue);
 Move(AValue[1], FBody[0], FBodySize);
end;


end.

