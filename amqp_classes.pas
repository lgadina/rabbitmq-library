unit amqp_classes;

{$IfDef FPC}
  {$mode objfpc}{$H+}
{$EndIf}

interface

uses
  Classes
  , SysUtils
  , syncobjs
{$IfNDef FPC}
  , System.Generics.Collections
{$EndIf}
  ;

type
    { TAMQPQueue }
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


{$IfDef FPC}
  generic GAMQPFrameList<T> = class(TInterfaceList)
  private
    function GetItems(Index: Integer): T;
  public
    property Items[Index: Integer]: T read GetItems; default;
    function Extract(AItem: T): T;
  end;
{$Else}
  GAMQPFrameList = class(TInterfaceList)
  public
    function Extract(AItem: IUnknown): IUnknown;
  end;
{$EndIf}

implementation

uses amqp_types;

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
   if FEvent.WaitFor(INFINITE) = wrSignaled then
    Result := inherited Pop
   else
    raise EBlockedQueueTimeout.CreateFmt('Event timeout %d', [FTimeout]);
  end else
  Result := inherited Pop;
  {$ifdef AMQP_DEBUG}
  DbgWriteLn('Pop:'+DumpIObj(Result));
  {$EndIf}
end;

{$IfDef FPC}
function GAMQPFrameList.GetItems(Index: Integer): T;
begin
  Result := inherited Items[Index] as T;
end;

function GAMQPFrameList.Extract(AItem: T): T;
begin
  Result := AItem;
  Remove(AItem);
end;
{$Else}

{ TAMQPFrameList }

function GAMQPFrameList.Extract(AItem: IInterface): IUnknown;
begin
  Result := AItem;
  Remove(AItem);
end;
{$EndIf}

end.

