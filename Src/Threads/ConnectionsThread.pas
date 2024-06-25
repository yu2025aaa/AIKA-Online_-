unit ConnectionsThread;

interface

uses
  System.Classes, Windows, SysUtils, Winsock2, EncDec, System.SyncObjs;

type
  TConnectionsThread = class(TThread)
  private
    { Private declarations }
    FDelay: Integer;
    Channel: BYTE;
    fCritSect: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(Delay: Integer; ChannelIndex: BYTE);
    destructor Destroy;
  end;

type
  TPlayerThreadGarbage = class(TThread)
  private
    { Private declarations }
    FDelay: Integer;
    Channel: BYTE;
  protected
    //procedure Execute; override;
  public
    constructor Create(Delay: Integer; ChannelIndex: BYTE);
  end;

implementation

uses GlobalDefs, Log, Packets;

constructor TConnectionsThread.Create(Delay: Integer; ChannelIndex: BYTE);
begin
  FDelay := Delay;
  Self.Channel := ChannelIndex;
  fCritSect := TCriticalSection.Create;

  inherited Create(FALSE);
end;

constructor TPlayerThreadGarbage.Create(Delay: Integer; ChannelIndex: BYTE);
begin
  inherited Create(FALSE);
  FDelay := Delay;
  Self.Channel := ChannelIndex;
end;

destructor TConnectionsThread.Destroy;
begin
  fCritSect.Free;
  inherited;
end;

procedure TConnectionsThread.Execute;
begin
  while (Servers[Channel].IsActive) do
  begin
    fCritSect.Enter;

    try
      if not(ServerHasClosed) then
        Servers[Channel].AcceptConnection;
    except
      on E: Exception do
      begin
        Logger.Write('Error Accept Connection ' + E.Message, TlogTYpe.Error);
        Continue;
      end;
    end;

    fCritSect.Leave;
    Sleep(Self.FDelay);
  end;
end;
  {
procedure TPlayerThreadGarbage.Execute;
var
  i: Integer;
begin
  while (Servers[Channel].IsActive) do
  begin
    try
      for i := Low(Servers[Channel].PlayerThreads)
        to High(Servers[Channel].PlayerThreads) do
      begin
        if (Servers[Channel].FPlayerThreads[i] = nil) then
          Continue;

        if (Servers[Channel].PlayerThreads[i].Term = True) then
        begin
          Servers[Channel].PlayerThreads[i].Terminate;
          Servers[Channel].PlayerThreads[i].WaitFor;
          FreeAndNil(Servers[Channel].PlayerThreads[i]);
          Servers[Channel].FPlayerThreads[i] := nil;
        end
        else
          Continue;
      end;
    except
      on E: Exception do
      begin
        Logger.Write('ConnectionsThread.pas:TPlayerThreadGarbage.Execute ' +
          E.Message, TlogTYpe.Error);
      end;
    end;

    Sleep(Self.FDelay);
  end;
end;     }

end.
