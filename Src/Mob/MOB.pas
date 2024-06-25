unit MOB;
interface
{$O+}
uses
  Windows, SysUtils, MiscData, BaseMob, Packets, Classes, Math, System.SyncObjs;
{$OLDTYPELAYOUT OFF}
{$REGION 'Mob Threads'}
type
  TMobSpawnThread1 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
    fCritSect: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
    destructor Destroy; override;
  end;
type
  TMobSpawnThread2 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
    fCritSect: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
    destructor Destroy; override;
  end;
type
  TMobSpawnThread3 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
    fCritSect: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
    destructor Destroy; override;
  end;
type
  TMobSpawnThread4 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
  end;
type
  TMobHandlerThread1 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
    fCritSect: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
    destructor Destroy; override;
  end;
type
  TMobHandlerThread2 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
    fCritSect: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
    destructor Destroy; override;
  end;
type
  TMobHandlerThread3 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
    fCritSect: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
    destructor Destroy; override;
  end;
type
  TMobHandlerThread4 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
  end;
type
  TMobHandlerThread5 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
  end;
type
  TMobHandlerThread6 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
  end;
type
  TMobHandlerThread7 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
  end;
type
  TMobHandlerThread8 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
  end;
type
  TMobMovimentThread1 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
    fCritSect: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
    destructor Destroy; override;
  end;
type
  TMobMovimentThread2 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
    fCritSect: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
    destructor Destroy; override;
  end;
type
  TMobMovimentThread3 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
    fCritSect: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
    destructor Destroy; override;
  end;
type
  TMobMovimentThread4 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
  end;
type
  TMobMovimentThread5 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
  end;
type
  TMobMovimentThread6 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
  end;
type
  TMobMovimentThread7 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
  end;
type
  TMobMovimentThread8 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
  end;
{$ENDREGION}
{$REGION 'Mob Data'}
type
  PMobSPoisition = ^TMobSPosition;
  TMobSPosition = record // dinamic informations
    Index: DWORD; // static index for a packet render generation on client
    HP, MP: DWORD; // health, mana
    InitPos: TPosition; // initial position [X,Y]
    DestPos: TPosition; // destine position [X,Y]
    CurrentPos: TPosition; // current position [X,Y] change by moviment thread
    FirstDestPos: TPosition;
    InitAttackRange: WORD;
    // range for follow the player to attack him [on init]
    DestAttackRange: WORD;
    // range for follow the player to attack him [on dest]
    InitMoveWait: WORD; // wait to move to destine position [Thread use]
    DestMoveWait: WORD; // wait to move to initial position [Thread use]
    Base: TBaseMob;
    DeadTime: TDateTime;
    LastMoviment: TDateTime;
    MovedTo: TypeMobLocation;
    MovimentsTime: BYTE;
    XPositionDif: Integer;
    YPositionDif: Integer;
    XPositionsToMove: Integer;
    YPositionsToMove: Integer;
    IsAttacked: Boolean;
    AttackerID: WORD;
    LastAttackerID: WORD;
    FirstPlayerAttacker: Integer;
    LastMyAttack: TDateTime;
    LastSkillAttack: TDateTime;
    NeighborIndex: Integer;
    isGuard: Boolean;
    isMutant: Boolean;
    isTemp: Boolean;
    GeneratedAt: TDateTime;
    LastSkillUsedByMob: TDateTime;
    ActualUsingSkill: Integer;
    AttackSamePlayerTimes: Integer;

    UpdatedMobSpawn, UpdatedMobHandler, UpdatedMobMoviment: TDateTime;
  public
    procedure SendMobDamage(PlayerID: WORD; MobID: DWORD; SkillID: DWORD;
      Anim: DWORD; out DnTypeA: BYTE);
    function GetMobDamage(PlayerID: WORD; Skill: DWORD;
      out DamageType: TDamageType): UInt64;
    function GetMobDamageType(PlayerID: WORD; Skill: DWORD; IsPhys: Boolean)
      : TDamageType;
    procedure MobHandler(ClientHandlerID: Integer = 0);
    procedure MobMoviment(ClientHandlerID: Integer = 0);
    procedure MobMove(Position: TPosition; Speed: BYTE = 25;
      MoveType: BYTE = 0);
    procedure AttackPlayer(SkillID: WORD = 0);
    function GetDamageByPlayer(Skill: DWORD;
      out DamageType: TDamageType): UInt64;
    function GetDamageTypePlayer(Skill: DWORD; IsPhys: Boolean): TDamageType;
    procedure UpdateSpawnToPlayers(mid, smid: Integer; ClientHandlerID: Integer = 0);
  end;
type // mob inventory class
  TMobInvent = packed record
    ItemID: WORD; // id
    Amount: WORD; // amount
  end;
type
  PMobSa = ^TMobSa;
  TMobSa = record // static informations
    IndexGeneric: DWORD; // index file generated
    Name: Array [0 .. 63] of AnsiChar; // name of mob on main array
    IntName: WORD; // name for client read and show it
    Equip: Array [0 .. 12] of WORD; // mob equips [face, weapon]
    MobsP: Array [0 .. 49] of TMobSPosition; // all 50 mobs positions
    MobElevation, Cabeca, Perna: BYTE; // mob "altura"
    FisAtk, MagAtk, FisDef, MagDef: DWORD; // mob attributes
    MoveSpeed: WORD; // mob speed move
    MobExp: DWORD; // mob exp give for player
    MobLevel: WORD; // for a name collor on client
    InitHP: DWORD;
    Rotation: DWORD;
    MobType: WORD;
    IsService: WordBool;
    SpawnType: BYTE;
    cntControl: WORD;
    ReespawnTime: WORD;
    Skill01, Skill02, Skill03, Skill04, Skill05: WORD;
    DropIndex: WORD;
    IsActiveToSpawn: Boolean;
    DungeonDropIndex: WORD;
    // ThreadHanler: TMobHandlerThread; // Thread for control all 50 mobs [attack]
    // ThreadMoviment: TMobMovimentThread; // Thread for control all 50 mobs [movimentation]
  end;
type
  TMobStruct = packed record
    TMobS: Array [0 .. 449] of TMobSa;
    // até 389 tipos de mobs diferentes em lakia
  end;
type
  TMobDungeonStruct = packed record
    TMobS: Array [0 .. 44] of TMobSa;
    // até 45 tipos de mobs diferentes por dungeon
  end;
type
  TMobFuncs = class(TObject)
    class function GetMobGeralID(Channel: BYTE; ID: DWORD;
      out MobPosID: Integer): Integer;
    class function GetMobDgGeralID(Channel: BYTE; ID: DWORD;
      DungeonInstanceID: BYTE): Integer;
  end;
{$ENDREGION}

implementation
uses
  GlobalDefs, DateUtils, Player, PlayerData, Log, ItemFunctions, Util;
{$REGION 'Mob Threads'}
{ TMobSpawnThread1 }
constructor TMobSpawnThread1.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  fCritSect := TCriticalSection.Create;
  inherited Create(FALSE);
end;
destructor TMobSpawnThread1.Destroy;
begin
  fCritSect.Free;
  inherited;
end;
procedure TMobSpawnThread1.Execute;
var
  i, j,k: Integer;
begin
  while ((Servers[Self.ChannelId].IsActive) and not(xServerClosed)) do
  begin
    try
      fCritSect.Acquire;
      for k := 1 to MAX_CONNECTIONS do
      begin
        if(Servers[Self.ChannelId].Players[k].Status < Playing) then
          Continue;
        if(Servers[Self.ChannelId].Players[k].SocketClosed) then
          Continue;

        for i := 0 to 129 do // 0..193
        begin
          if(Servers[Self.ChannelId].MOBS.TMobS[i].IntName = 0) then
            Continue;
          for j := 1 to 49 do
          begin
            try
              if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Index = 0) then
                continue;
              if(Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Base.ClientID =0) then
                Continue;
             // fCritSect.Enter;
              Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].UpdateSpawnToPlayers(i, j, k);
              //fCritSect.Release;
            except
             // fCritSect.Release;
              Continue;
            end;
          end;
        end;
      end;
      fCritSect.Release;
      Sleep(FDelay);
    except
      on E: Exception do
      begin
        fCritSect.Release;
        Logger.Write(E.Message + '|' + 'TMobSpawnThread1.Execute', TlogType.Error);
      end;
    end;
  end;
end;
{ TMobSpawnThread2 }
constructor TMobSpawnThread2.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  fCritSect := TCriticalSection.Create;
  inherited Create(FALSE);
end;
destructor TMobSpawnThread2.Destroy;
begin
  fCritSect.Free;
  inherited;
end;
procedure TMobSpawnThread2.Execute;
var
  i, j, k: Integer;
begin
  while ((Servers[Self.ChannelId].IsActive) and not(xServerClosed)) do
  begin
    try
      fCritSect.Acquire;
      for k := 1 to MAX_CONNECTIONS do
      begin
        if(Servers[Self.ChannelId].Players[k].Status < Playing) then
          Continue;
        if(Servers[Self.ChannelId].Players[k].SocketClosed) then
          Continue;
       //fCritSect.Acquire;
        for i := 130 to 259 do
        begin
          if(Servers[Self.ChannelId].MOBS.TMobS[i].IntName = 0) then
            Continue;
          for j := 1 to 49 do
          begin
            try
              if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Index = 0) then
                continue;
              if(Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Base.ClientID =0) then
                Continue;
             // fCritSect.Enter;
              Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].UpdateSpawnToPlayers(i, j, k);
             // fCritSect.Release;
            except
             // fCritSect.Release;
              Continue;
            end;
          end;
        end;
      end;
      fCritSect.Release;
      Sleep(FDelay);
    except
      on E: Exception do
      begin
        fCritSect.Release;
        Logger.Write(E.Message + '|' + 'TMobSpawnThread2.Execute', TlogType.Error);
      end;
    end;
  end;
end;
{ TMobSpawnThread3 }
constructor TMobSpawnThread3.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  fCritSect := TCriticalSection.Create;
  inherited Create(FALSE);
end;
destructor TMobSpawnThread3.Destroy;
begin
  fCritSect.Free;
  inherited;
end;
procedure TMobSpawnThread3.Execute;
var
  i, j, k: Integer;
begin
  while ((Servers[Self.ChannelId].IsActive) and not(xServerClosed)) do
  begin
    try
      fCritSect.Acquire;
      for k := 1 to MAX_CONNECTIONS do
      begin
        if(Servers[Self.ChannelId].Players[k].Status < Playing) then
          Continue;
        if(Servers[Self.ChannelId].Players[k].SocketClosed) then
          Continue;

        for i := 260 to 449 do
        begin
          if(Servers[Self.ChannelId].MOBS.TMobS[i].IntName = 0) then
            Continue;
          for j := 1 to 49 do
          begin
            try
              if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Index = 0) then
                continue;
              if(Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Base.ClientID =0) then
                Continue;
              //fCritSect.Enter;
              Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].UpdateSpawnToPlayers(i, j, k);
              //fCritSect.Release;
            except
              //fCritSect.Release;
              Continue;
            end;
          end;
        end;
      end;
      fCritSect.Release;
      Sleep(FDelay);
    except
      on E: Exception do
      begin
        fCritSect.Release;
        Logger.Write(E.Message + '|' + 'TMobSpawnThread3.Execute', TlogType.Error);
      end;
    end;
  end;
end;
{ TMobSpawnThread4 }
constructor TMobSpawnThread4.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  inherited Create(FALSE);
end;
procedure TMobSpawnThread4.Execute;
var
  i, j: Integer;
begin
  while ((Servers[Self.ChannelId].IsActive) and not(xServerClosed)) do
  begin

    for i := 292 to 449 do
    begin
      if(Servers[Self.ChannelId].MOBS.TMobS[i].IntName = 0) then
        Continue;
      for j := 1 to 49 do
      begin
        if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Index = 0) then
          continue;
        Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].UpdateSpawnToPlayers(i ,j);
      end;
    end;
    Sleep(FDelay);
  end;
end;
{ TMobHandlerThread1 }
constructor TMobHandlerThread1.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  fCritSect := TCriticalSection.Create;
  inherited Create(FALSE);
end;
destructor TMobHandlerThread1.Destroy;
begin
   fCritSect.Free;
  inherited;
end;
procedure TMobHandlerThread1.Execute;
var
  i, j, k: Integer;
begin
  while ((Servers[Self.ChannelId].IsActive) and not(xServerClosed)) do
  begin
    try
      for k := 1 to MAX_CONNECTIONS do
      begin
        if(Servers[Self.ChannelId].Players[k].Status < Playing) then
          Continue;
        fCritSect.Acquire;
        for i := 0 to 129 do // 0..49
        begin
          if(Servers[Self.ChannelId].MOBS.TMobS[i].IntName = 0) then
            Continue;
          for j := 1 to 49 do
          begin

            if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Index = 0) then
              continue;
            try
              Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].MobHandler(k);
            Except
              continue;
            end;

          end;
        end;
      end;
      fCritSect.Release;
      Sleep(FDelay);
    except
      on E: Exception do
      begin
        Logger.Write(E.Message + '|' + 'TMobHandlerThread1.Execute', TlogType.Error);
      end;
    end;
  end;
end;
constructor TMobHandlerThread2.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  fCritSect := TCriticalSection.Create;
  inherited Create(FALSE);
end;
destructor TMobHandlerThread2.Destroy;
begin
  fCritSect.Free;
  inherited;
end;
procedure TMobHandlerThread2.Execute;
var
  i, j, k: Integer;
begin
  while ((Servers[Self.ChannelId].IsActive) and not(xServerClosed)) do
  begin
    try
      for k := 1 to MAX_CONNECTIONS do
      begin
        if(Servers[Self.ChannelId].Players[k].Status < Playing) then
          Continue;
      fCritSect.Acquire;
        for i := 130 to 259 do
        begin
          if(Servers[Self.ChannelId].MOBS.TMobS[i].IntName = 0) then
            Continue;
          for j := 1 to 49 do
          begin
            if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Index = 0) then
                continue;
            try

              Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].MobHandler(k);
            except
              //Sleep(10);
              continue;
            end;
          end;
        end;
      end;
      fCritSect.Release;
      Sleep(FDelay);
    except
      on E: Exception do
      begin
        Logger.Write(E.Message + '|' + 'TMobHandlerThread2.Execute', TlogType.Error);
      end;
    end;
  end;
end;
constructor TMobHandlerThread3.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  fCritSect := TCriticalSection.Create;
  inherited Create(FALSE);
end;
destructor TMobHandlerThread3.Destroy;
begin
   fCritSect.Free;
  inherited;
end;
procedure TMobHandlerThread3.Execute;
var
  i, j, k: Integer;
begin
  while ((Servers[Self.ChannelId].IsActive) and not(xServerClosed)) do
  begin
    try
      fCritSect.Acquire;
      for k := 1 to MAX_CONNECTIONS do
      begin
        if(Servers[Self.ChannelId].Players[k].Status < Playing) then
          Continue;
        for i := 260 to 449 do
        begin
          if(Servers[Self.ChannelId].MOBS.TMobS[i].IntName = 0) then
            Continue;
          for j := 1 to 49 do
          begin
            if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Index = 0) then
                continue;
            try
              Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].MobHandler(k);
            except
              continue;
            end;
          end;
        end;
      end;
      fCritSect.Release;
      Sleep(FDelay);
    except
      on E: Exception do
      begin
        Logger.Write(E.Message + '|' + 'TMobHandlerThread3.Execute', TlogType.Error);
      end;
    end;
  end;
end;
constructor TMobHandlerThread4.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  inherited Create(FALSE);
end;
procedure TMobHandlerThread4.Execute;
var
  i, j: Integer;
begin
  while ((Servers[Self.ChannelId].IsActive) and not(xServerClosed)) do
  begin
    for i := 148 to 198 do
    begin
      for j := 1 to 49 do
      begin
        if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Index = 0) then
          continue;
        Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].MobHandler();
      end;
    end;
    Sleep(FDelay);
  end;
end;
constructor TMobHandlerThread5.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  inherited Create(FALSE);
end;
procedure TMobHandlerThread5.Execute;
var
  i, j: Integer;
begin
  while ((Servers[Self.ChannelId].IsActive) and not(xServerClosed)) do
  begin
    for i := 199 to 247 do
    begin
      for j := 1 to 49 do
      begin
        if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Index = 0) then
          continue;
        Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].MobHandler();
      end;
    end;
    Sleep(FDelay);
  end;
end;
constructor TMobHandlerThread6.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  inherited Create(FALSE);
end;
procedure TMobHandlerThread6.Execute;
var
  i, j: Integer;
begin
  while ((Servers[Self.ChannelId].IsActive) and not(xServerClosed)) do
  begin
    for i := 248 to 297 do
    begin
      for j := 1 to 49 do
      begin
        if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Index = 0) then
          continue;
        Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].MobHandler();
      end;
    end;
    Sleep(FDelay);
  end;
end;
constructor TMobHandlerThread7.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  inherited Create(FALSE);
end;
procedure TMobHandlerThread7.Execute;
var
  i, j: Integer;
begin
  while ((Servers[Self.ChannelId].IsActive) and not(xServerClosed)) do
  begin
    for i := 298 to 347 do
    begin
      for j := 1 to 49 do
      begin
        if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Index = 0) then
          continue;
        Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].MobHandler();
      end;
    end;
    Sleep(FDelay);
  end;
end;
constructor TMobHandlerThread8.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  inherited Create(FALSE);
end;
procedure TMobHandlerThread8.Execute;
var
  i, j: Integer;
begin
  while ((Servers[Self.ChannelId].IsActive) and not(xServerClosed)) do
  begin
    for i := 348 to 449 do
    begin
      for j := 1 to 49 do
      begin
        if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Index = 0) then
          continue;
        Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].MobHandler();
      end;
    end;
    Sleep(FDelay);
  end;
end;
{ TMobMovimentThread }
constructor TMobMovimentThread1.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  fCritSect := TCriticalSection.Create;
  inherited Create(FALSE);
end;
destructor TMobMovimentThread1.Destroy;
begin
  fCritSect.Free;
  inherited;
end;
procedure TMobMovimentThread1.Execute;
var
  i, j, k: Integer;
begin
  while ((Servers[Self.ChannelId].IsActive) and not(xServerClosed)) do
  begin
    try
      fCritSect.Acquire;
      for k := 1 to MAX_CONNECTIONS do
      begin
        if(Servers[Self.ChannelId].Players[k].Status < Playing) then
          Continue;
        for i := 0 to 129 do // 0..49
        begin
          if(Servers[Self.ChannelId].MOBS.TMobS[i].IntName = 0) then
            Continue;
          for j := 1 to 49 do
          begin
            if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Index = 0) then
                continue;

            if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].isTemp) then
              Continue;
            try
              Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].MobMoviment(k);
            except
              Continue;
            end;
          end;
        end;
      end;
      fCritSect.Release;
      Sleep(FDelay);
    except
      on E: Exception do
      begin
        Logger.Write(E.Message + '|' + 'TMobMovimentThread1.Execute', TlogType.Error);
      end;
    end;
  end;
end;
constructor TMobMovimentThread2.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  fCritSect := TCriticalSection.Create;
  inherited Create(FALSE);
end;
destructor TMobMovimentThread2.Destroy;
begin
  fCritSect.Free;
  inherited;
end;
procedure TMobMovimentThread2.Execute;
var
  i, j, k: Integer;
begin
  while ((Servers[Self.ChannelId].IsActive) and not(xServerClosed)) do
  begin
    try
      fCritSect.Acquire;
      for k := 1 to MAX_CONNECTIONS do
      begin
        if(Servers[Self.ChannelId].Players[k].Status < Playing) then
          Continue;
        for i := 130 to 259 do
        begin
          if(Servers[Self.ChannelId].MOBS.TMobS[i].IntName = 0) then
            Continue;
          for j := 1 to 49 do
          begin
            if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Index = 0)  then
                continue;

            if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].isTemp) then
              Continue;
            try
              Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].MobMoviment();
            except
              Continue;
            end;
          end;
        end;
      end;
      fCritSect.Release;
      Sleep(FDelay);
    except
      on E: Exception do
      begin
        Logger.Write(E.Message + '|' + 'TMobMovimentThread2.Execute', TlogType.Error);
      end;
    end;
  end;
end;
constructor TMobMovimentThread3.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  fCritSect := TCriticalSection.Create;
  inherited Create(FALSE);
end;
destructor TMobMovimentThread3.Destroy;
begin
  fCritSect.Free;
  inherited;
end;
procedure TMobMovimentThread3.Execute;
var
  i, j, k: Integer;
begin
  while ((Servers[Self.ChannelId].IsActive) and not(xServerClosed)) do
  begin
    fCritSect.Acquire;
    try
      for k := 1 to MAX_CONNECTIONS do
      begin
        if(Servers[Self.ChannelId].Players[k].Status < Playing) then
          Continue;
        for i := 260 to 449 do
        begin
          if(Servers[Self.ChannelId].MOBS.TMobS[i].IntName = 0) then
            Continue;
          for j := 1 to 49 do
          begin
            if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Index = 0)  then
                continue;

            if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].isTemp) then
              Continue;
            try
              Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].MobMoviment(k);
            except
              Continue;
            end;
          end;
        end;
      end;
      fCritSect.Release;
      Sleep(FDelay);
    except
      on E: Exception do
      begin
        Logger.Write(E.Message + '|' + 'TMobMovimentThread3.Execute', TlogType.Error);
      end;
    end;
  end;
end;
constructor TMobMovimentThread4.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  inherited Create(FALSE);
end;
procedure TMobMovimentThread4.Execute;
var
  i, j: Integer;
begin
  while ((Servers[Self.ChannelId].IsActive) and not(xServerClosed)) do
  begin
    for i := 148 to 197 do
    begin
      for j := 0 to 49 do
      begin
        if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Index = 0) then
          continue;
        Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].MobMoviment();
      end;
    end;
    Sleep(FDelay);
  end;
end;
constructor TMobMovimentThread5.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  inherited Create(FALSE);
end;
procedure TMobMovimentThread5.Execute;
var
  i, j: Integer;
begin
  while ((Servers[Self.ChannelId].IsActive) and not(xServerClosed)) do
  begin
    for i := 198 to 247 do
    begin
      for j := 0 to 49 do
      begin
        if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Index = 0) then
          continue;
        Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].MobMoviment();
      end;
    end;
    Sleep(FDelay);
  end;
end;
constructor TMobMovimentThread6.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  inherited Create(FALSE);
end;
procedure TMobMovimentThread6.Execute;
var
  i, j: Integer;
begin
  while ((Servers[Self.ChannelId].IsActive) and not(xServerClosed)) do
  begin
    for i := 248 to 297 do
    begin
      for j := 0 to 49 do
      begin
        if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Index = 0) then
          continue;
        Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].MobMoviment();
      end;
    end;
    Sleep(FDelay);
  end;
end;
constructor TMobMovimentThread7.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  inherited Create(FALSE);
end;
procedure TMobMovimentThread7.Execute;
var
  i, j: Integer;
begin
  while ((Servers[Self.ChannelId].IsActive) and not(xServerClosed)) do
  begin
    for i := 298 to 347 do
    begin
      for j := 0 to 49 do
      begin
        if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Index = 0) then
          continue;
        Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].MobMoviment();
      end;
    end;
    Sleep(FDelay);
  end;
end;
constructor TMobMovimentThread8.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  inherited Create(FALSE);
end;
procedure TMobMovimentThread8.Execute;
var
  i, j: Integer;
begin
  while ((Servers[Self.ChannelId].IsActive) and not(xServerClosed)) do
  begin
    for i := 348 to 449 do
    begin
      for j := 0 to 49 do
      begin
        if (Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].Index = 0) then
          continue;
        Servers[Self.ChannelId].MOBS.TMobS[i].MobsP[j].MobMoviment();
      end;
    end;
    Sleep(FDelay);
  end;
end;
{$ENDREGION}
{$OLDTYPELAYOUT OFF}
class function TMobFuncs.GetMobGeralID(Channel: BYTE; ID: DWORD;
  out MobPosID: Integer): Integer;
var
  i, j: Integer;
begin
  Result := -1;
  for i := Low(Servers[Channel].MOBS.TMobS)
    to High(Servers[Channel].MOBS.TMobS) do
  begin
    for j := 1 to 49 do
    begin
      if (Servers[Channel].MOBS.TMobS[i].MobsP[j].Index = ID) then
      begin
        Result := i;
        MobPosID := j;
        break;
      end;
    end;

    if(result <> -1) then
      break;
  end;
end;
class function TMobFuncs.GetMobDgGeralID(Channel: BYTE; ID: DWORD;
  DungeonInstanceID: BYTE): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := Low(DungeonInstances[DungeonInstanceID].MOBS)
    to High(DungeonInstances[DungeonInstanceID].MOBS) do
  begin
    if (DungeonInstances[DungeonInstanceID].MOBS[i].Base.ClientId = ID) then
    begin
      Result := i;
      break;
    end
    else
      continue;
  end;
end;
procedure TMobSPosition.SendMobDamage(PlayerID: WORD; MobID: DWORD;
  SkillID: DWORD; Anim: DWORD; out DnTypeA: BYTE);
var
  Packet: TRecvDamagePacket;
  dnType: TDamageType;
  i, mbid, j: DWORD;
  AuxID: Integer;
  RandonPosition: Integer;
  RandonLocal: Integer;
  DnAux: BYTE;
begin
  if (Self.Base.IsDead) then
    Exit;
  if (Self.isGuard) and
    (BYTE(Servers[Self.Base.ChannelId].Players[PlayerID].Account.Header.Nation)
    = Servers[Self.Base.ChannelId].NationID) then
    Exit;
  ZeroMemory(@Packet, sizeof(Packet));
  Self.IsAttacked := True;
  Self.AttackerID := PlayerID;
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := PlayerID;
  Packet.Header.Code := $102;
  Packet.SkillID := SkillID;
  Packet.AttackerPos := Servers[Self.Base.ChannelId].Players[PlayerID]
    .Base.PlayerCharacter.LastPos;
  Packet.AttackerID := PlayerID;
  Packet.Animation := Anim;
  Packet.AttackerHP := Servers[Self.Base.ChannelId].Players[PlayerID]
    .Base.Character.CurrentScore.CurHP;
  Packet.TargetID := Self.Index;
  Packet.MobAnimation := SkillData[SkillID].TargetAnimation;
  Packet.DANO := Self.GetMobDamage(PlayerID, SkillID, dnType);
  Packet.dnType := dnType;
  if (Packet.DANO >= Self.HP) then
  begin
    Self.HP := 0;
    Self.Base.IsDead := True;
    Self.IsAttacked := FALSE;
    Self.AttackerID := 0;
    Self.DeadTime := Now;
    Packet.MobAnimation := 30;
    if (Servers[Self.Base.ChannelId].Players[PlayerID].Base.VisibleMobs.Contains
      (Self.Index)) then
      Servers[Self.Base.ChannelId].Players[PlayerID].Base.VisibleMobs.Remove
        (Self.Index);
    Self.Base.VisibleMobs.Clear;
    //Servers[Self.Base.ChannelId].Players[PlayerID]
   //   .AddExp(Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.MobID].MobExp,
    //  EXP_TYPE_MOB);
    Servers[Self.Base.ChannelId].Players[PlayerID].SendClientMessage
      ('Você recebeu ' + AnsiString(Servers[Self.Base.ChannelId].MOBS.TMobS
      [Self.Base.MobID].MobExp.ToString) + ' pontos de experiência.', 0);
  end
  else
  begin
    Self.HP := (Self.HP - Packet.DANO);
  end;
  if (Servers[Self.Base.ChannelId].Players[PlayerID].Base.GetMobAbility
    (EF_DRAIN_HP) > 0) then
  begin
    Servers[Self.Base.ChannelId].Players[PlayerID].Base.Character.CurrentScore.
      CurHP := Servers[Self.Base.ChannelId].Players[PlayerID]
      .Base.Character.CurrentScore.CurHP +
      ((Packet.DANO div 100) * Servers[Self.Base.ChannelId].Players[PlayerID]
      .Base.GetMobAbility(EF_DRAIN_HP));
  end;
  if (Servers[Self.Base.ChannelId].Players[PlayerID].Base.GetMobAbility
    (EF_DRAIN_MP) > 0) then
  begin
    Servers[Self.Base.ChannelId].Players[PlayerID].Base.Character.CurrentScore.
      CurMP := Servers[Self.Base.ChannelId].Players[PlayerID]
      .Base.Character.CurrentScore.CurMP +
      ((Packet.DANO div 100) * Servers[Self.Base.ChannelId].Players[PlayerID]
      .Base.GetMobAbility(EF_DRAIN_MP));
  end;
  if (Servers[Self.Base.ChannelId].Players[PlayerID].Base.GetMobAbility
    (EF_SPLASH) > 0) then
  begin
    if (SkillData[SkillID].Index = 0) or (SkillData[SkillID].Index = 48) or
      (SkillData[SkillID].Index = 96) then
    begin
      for i in Servers[Self.Base.ChannelId].Players[PlayerID]
        .Base.VisibleMobs do
      begin
        if (i = Servers[Self.Base.ChannelId].Players[PlayerID].Base.ClientId)
        then
          continue;
        if (i = Self.Index) then
          continue;
        if (Servers[Self.Base.ChannelId].Players[i].Base.IsDead) then
          continue;
        if (Self.CurrentPos.Distance(Servers[Self.Base.ChannelId].Players[i]
          .Base.PlayerCharacter.LastPos) > 5) then
          continue;
        if (Packet.DANO >= Servers[Self.Base.ChannelId].Players[i]
          .Base.Character.CurrentScore.CurHP) then
        begin
          Servers[Self.Base.ChannelId].Players[i].Base.Character.CurrentScore.
            CurHP := 0;
          Servers[Self.Base.ChannelId].Players[i].Base.IsDead := True;
          Servers[Self.Base.ChannelId].Players[i].Base.SendEffect($0);
          Packet.MobAnimation := 30;
        end
        else
        begin
          Servers[Self.Base.ChannelId].Players[i].Base.Character.CurrentScore.
            CurHP := (Servers[Self.Base.ChannelId].Players[i]
            .Base.Character.CurrentScore.CurHP - Packet.DANO);
        end;
        Servers[Self.Base.ChannelId].Players[i].Base.LastReceivedAttack := Now;
        Packet.MobCurrHP := Servers[Self.Base.ChannelId].Players[i]
          .Base.Character.CurrentScore.CurHP;
        Servers[Self.Base.ChannelId].Players[PlayerID].Base.SendToVisible
          (Packet, Packet.Header.size);
      end;
      for i in Servers[Self.Base.ChannelId].Players[PlayerID]
        .Base.VisibleMobs do
      begin
        mbid := TMobFuncs.GetMobGeralID(Self.Base.ChannelId, i, AuxID);
        if (Servers[Self.Base.ChannelId].MOBS.TMobS[mbid].MobsP[i].Base.IsDead)
        then
          continue;
        if (Self.CurrentPos.Distance(Servers[Self.Base.ChannelId].MOBS.TMobS
          [mbid].MobsP[AuxID].CurrentPos) > 7) then
          continue;
        if (Packet.DANO >= Servers[Self.Base.ChannelId].MOBS.TMobS[mbid].MobsP
          [AuxID].HP) then
        begin
          Servers[Self.Base.ChannelId].MOBS.TMobS[mbid].MobsP[AuxID].HP := 0;
          Servers[Self.Base.ChannelId].MOBS.TMobS[mbid].MobsP[AuxID]
            .Base.IsDead := True;
          Servers[Self.Base.ChannelId].MOBS.TMobS[mbid].MobsP[AuxID]
            .IsAttacked := FALSE;
          Servers[Self.Base.ChannelId].MOBS.TMobS[mbid].MobsP[AuxID]
            .AttackerID := 0;
          Self.Base.SendEffect($0);
          Servers[Self.Base.ChannelId].MOBS.TMobS[mbid].MobsP[AuxID]
            .DeadTime := Now;
          Packet.MobAnimation := 30;
          for j in Servers[Self.Base.ChannelId].MOBS.TMobS[mbid].MobsP[AuxID]
            .Base.VisibleMobs do
          begin
            Servers[Self.Base.ChannelId].MOBS.TMobS[mbid].MobsP[AuxID]
              .Base.SendRemoveMob(1, j);
          end;
          if (Servers[Self.Base.ChannelId].Players[PlayerID]
            .Base.VisibleMobs.Contains(Servers[Self.Base.ChannelId].MOBS.TMobS
            [mbid].MobsP[AuxID].Index)) then
            Servers[Self.Base.ChannelId].Players[PlayerID]
              .Base.VisibleMobs.Remove(Servers[Self.Base.ChannelId].MOBS.TMobS
              [mbid].MobsP[AuxID].Index);
          Servers[Self.Base.ChannelId].MOBS.TMobS[mbid].MobsP[AuxID]
            .Base.VisibleMobs.Clear;
        end
        else
        begin
          Servers[Self.Base.ChannelId].MOBS.TMobS[mbid].MobsP[i].HP :=
            (Servers[Self.Base.ChannelId].MOBS.TMobS[mbid].MobsP[i].HP -
            Packet.DANO);
        end;
        Servers[Self.Base.ChannelId].MOBS.TMobS[mbid].MobsP[i]
          .Base.LastReceivedAttack := Now;
        Packet.MobCurrHP := Servers[Self.Base.ChannelId].MOBS.TMobS[mbid]
          .MobsP[i].HP;
        Servers[Self.Base.ChannelId].Players[PlayerID].Base.SendToVisible
          (Packet, Packet.Header.size);
      end;
    end;
  end;
  if (Servers[Self.Base.ChannelId].Players[PlayerID].Base.GetMobAbility
    (EF_SKILL_INVISIBILITY) > 0) then
  begin
    if (Servers[Self.Base.ChannelId].Players[PlayerID].Base.GetMobClass
      (Servers[Self.Base.ChannelId].Players[PlayerID]
      .Base.Character.ClassInfo) = 2) then
    begin
      for i := 0 to 15 do
      begin
        Servers[Self.Base.ChannelId].Players[PlayerID].Base.RemoveBuff
          (2081 + i);
      end;
    end
    else
    begin
      for i := 0 to 15 do
      begin
        Servers[Self.Base.ChannelId].Players[PlayerID].Base.RemoveBuff
          (3041 + i);
      end;
    end;
  end;
  if (Self.CurrentPos.Distance(Servers[Self.Base.ChannelId].Players[PlayerID]
    .Base.PlayerCharacter.LastPos) > 5) then
  begin
    Randomize;
    RandonPosition := RandomRange(1, 3);
    RandonLocal := RandomRange(0,2);
    case RandonLocal of
      0:
        RandonPosition := RandonPosition;
      1:
        RandonPosition := -RandonPosition;
    end;
    Self.CurrentPos := TPosition.Create
      ((Servers[Self.Base.ChannelId].Players[PlayerID]
      .Base.PlayerCharacter.LastPos.X + RandonPosition),
      (Servers[Self.Base.ChannelId].Players[PlayerID]
      .Base.PlayerCharacter.LastPos.Y + RandonPosition));
    Self.MobMove(Self.CurrentPos, 50);
  end;
  Self.Base.LastReceivedAttack := Now;
  Packet.MobCurrHP := Self.HP;
  Servers[Self.Base.ChannelId].Players[PlayerID].Base.SendCurrentHPMP();
  Servers[Self.Base.ChannelId].Players[PlayerID].Base.SendToVisible(Packet,
    Packet.Header.size);
end;
function TMobSPosition.GetMobDamage(PlayerID: WORD; Skill: DWORD;
  out DamageType: TDamageType): UInt64;
var
  IsPhysical: Boolean;
  ResultDamage: UInt64;
  MobDef: DWORD;
  MoreDamage: UInt64;
begin
  Result := 0;
  case Servers[Self.Base.ChannelId].Players[PlayerID].Base.GetMobClass of
    0 .. 3:
      begin
        IsPhysical := True;
      end;
  else
    if (SkillData[Skill].Index = 96) then
      IsPhysical := True
    else
      IsPhysical := FALSE;
  end;
  if (IsPhysical) then
  begin
    ResultDamage := Servers[Self.Base.ChannelId].Players[PlayerID]
      .Base.PlayerCharacter.Base.CurrentScore.DNFis;
    MobDef := Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.MobID].FisDef;
    MobDef := MobDef - // penetração Fisica
      ((MobDef div 100) * Servers[Self.Base.ChannelId].Players[PlayerID]
      .Base.GetMobAbility(EF_PIERCING_RESISTANCE1));
  end
  else
  begin
    ResultDamage := Servers[Self.Base.ChannelId].Players[PlayerID]
      .Base.PlayerCharacter.Base.CurrentScore.DNMAG;
    MobDef := Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.MobID].MagDef;
    MobDef := MobDef - // penetração Magica
      ((MobDef div 100) * Servers[Self.Base.ChannelId].Players[PlayerID]
      .Base.GetMobAbility(EF_PIERCING_RESISTANCE2));
  end;
  DamageType := Self.GetMobDamageType(PlayerID, Skill, IsPhysical);
  if (DamageType = Miss) then
    Exit;
  inc(ResultDamage, SkillData[Skill].Damage);
  ResultDamage := ResultDamage - (MobDef shr 3);
  Randomize;
  inc(ResultDamage, (Random(99) + 5));
  if (Skill > 0) then
  begin
    inc(ResultDamage, Servers[Self.Base.ChannelId].Players[PlayerID]
      .Base.GetMobAbility(EF_SKILL_DAMAGE));
    if (SkillData[Skill].Index = 336) then // pancada de sangue
    begin
      MoreDamage :=
        ((Servers[Self.Base.ChannelId].Players[PlayerID]
        .Base.Character.CurrentScore.CurHP div 100) *
        (SkillData[Skill].Adicional));
      inc(ResultDamage, MoreDamage);
    end;
  end;
  case DamageType of
    Critical:
      ResultDamage := Round(ResultDamage * 1.5); // 1.5
    Double:
      ResultDamage := Round(ResultDamage * 2.0); // 2.0
    DoubleCritical:
      ResultDamage := Round(ResultDamage * 3.0); // 2.5
  end;
  // dec(ResultDamage, Round(ResultDamage * (mob.GetEquipedItensDamageReduce
  // 1000)));
  if (ResultDamage < 0) or (ResultDamage > 1000000) then
    ResultDamage := 1;
  Result := ResultDamage;
end;
function TMobSPosition.GetMobDamageType(PlayerID: WORD; Skill: DWORD;
  IsPhys: Boolean): TDamageType;
var
  RamdomArray: ARRAY [0 .. 999] OF BYTE;
  RamdomSlot: WORD;
  Chance: BYTE;
  function GetEmpty: WORD;
  var
    i: WORD;
  begin
    Result := 0;
    for i := 0 to 999 do
    begin
      if (RamdomArray[i] = 0) then
        inc(Result);
    end;
  end;
  procedure SetChance(Chance: WORD; const Type1: BYTE);
  var
    i: Integer;
    Empty: WORD;
  begin
    if (Chance = 0) then
      Exit;
    Empty := GetEmpty;
    if (Chance > Empty) then
      Chance := Empty;
    for i := 0 to Chance - 1 do
    begin
      RamdomSlot := Random(1000);
      while (RamdomArray[RamdomSlot] <> 0) do
      begin
        RamdomSlot := Random(1000);
      end;
      RamdomArray[RamdomSlot] := Type1;
    end;
  end;
begin
  ZeroMemory(@RamdomArray, Length(RamdomArray));
  Randomize;
{$REGION 'Seta a chance basica dos tipos de dano'}
  if (IsPhys) then
    Chance := 55
  else
    Chance := 60;
  SetChance(Chance, BYTE(TDamageType.Critical));
  SetChance(20, BYTE(TDamageType.Miss));
  if (IsPhys) then
  begin
    SetChance(40, BYTE(TDamageType.Double));
    SetChance(20, BYTE(TDamageType.DoubleCritical));
  end;
  SetChance(Servers[Self.Base.ChannelId].Players[PlayerID]
    .Base.PlayerCharacter.Base.CurrentScore.Critical,
    BYTE(TDamageType.Critical));
  SetChance(Servers[Self.Base.ChannelId].Players[PlayerID]
    .Base.PlayerCharacter.DuploAtk, BYTE(TDamageType.Double));
  SetChance(Round(Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.MobID]
    .MobLevel / 2), BYTE(TDamageType.Miss));
  SetChance(((Servers[Self.Base.ChannelId].Players[PlayerID]
    .Base.PlayerCharacter.DuploAtk + Servers[Self.Base.ChannelId].Players
    [PlayerID].Base.PlayerCharacter.Base.CurrentScore.Critical) div 2),
    BYTE(TDamageType.DoubleCritical));
  // SetChance((mob.MOB_EF[EF_RESISTANCE6]), Byte(TDamageType.Normal));
  // SetChance((mob.MOB_EF[EF_RESISTANCE7]), Byte(TDamageType.Normal));
{$ENDREGION}
  Result := TDamageType(RamdomArray[Random(1000)]);
end;
procedure TMobSPosition.MobHandler(ClientHandlerID: Integer);
var
  i: Integer;
  UpdatedBuffs, Rand: Integer;
  OtherPlayer, OPP: PPlayer;
begin
  //if(MilliSecondsBetween(Now, Self.UpdatedMobHandler) < 1000) then
   // Exit;

  Self.UpdatedMobHandler := Now;

  if(Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].IntName = 0) then
    Exit;
  // try
  if (Self.Base.IsDead = FALSE) then // attack and IA verifications
  begin
    if(Self.isTemp) then //aqui e aquela verificacao de mob temporario PAINEL
    begin
      if(MinutesBetween(Now, Self.GeneratedAt) >= 120) then
      begin
        for i in Self.Base.VisibleMobs do
        begin
          OtherPlayer := @Servers[Self.Base.ChannelId].Players[i];
          if not(Assigned(OtherPlayer.FriendList)) then
          begin
            Self.Base.VisibleMobs.Remove(i);
            Continue;
          end;
          if(OtherPlayer.InDungeon) then
            continue;
          if(OtherPlayer.Status < Playing) then
            Continue;
          if (OtherPlayer.Base.VisibleMobs.Contains(Self.Index)) then
          begin
            OtherPlayer.Base.VisibleMobs.Remove(Self.Index);
            OtherPlayer.UnspawnMob(Self.Base.MobID, Self.Base.SecondIndex);
            OtherPlayer.Base.RemoveTargetFromList(@Self.Base);
          end;
        end;
        ZeroMemory(@Self, sizeof(Self));
        Exit;
      end;
    end;
{$REGION 'Buffs'}
    UpdatedBuffs := Self.Base.RefreshBuffs;
    if (UpdatedBuffs > 0) then
    begin
      Self.Base.SendRefreshBuffs;
    end;
{$ENDREGION}
{$REGION 'Attack'}
    if not(Self.Base.GetMobAbility(EF_SKILL_STUN) = 0) then
    begin
      Self.AttackSamePlayerTimes := 0;
      Exit;
    end;
    if not(Self.Base.GetMobAbility(EF_SKILL_IMMOVABLE) = 0) then
      Exit;
    if not(Self.Base.GetMobAbility(EF_SILENCE1) = 0) then
    begin
      Self.AttackSamePlayerTimes := 0;
      Exit;
    end;
    if not(Self.Base.GetMobAbility(EF_SILENCE2) = 0) then
    begin
      Self.AttackSamePlayerTimes := 0;
      Exit;
    end;
    if not(Self.Base.GetMobAbility(EF_SKILL_SHOCK) = 0) then
    begin
      Self.AttackSamePlayerTimes := 0;
      Exit;
    end;
    if not(Self.Base.GetMobAbility(EF_SKILL_SLEEP) = 0) then
    begin
      Self.AttackSamePlayerTimes := 0;
      Exit;
    end;

    if (Self.IsAttacked) then // se o mob foi atacado, entao...
    begin
      if(Self.FirstPlayerAttacker <> Self.AttackerID) then
      begin
        Self.LastAttackerID := Self.AttackerID;
        Self.AttackSamePlayerTimes := 0;
      end;

      if(Self.LastAttackerID <> Self.AttackerID) then
      begin
        Self.LastAttackerID := Self.AttackerID;
        Self.AttackSamePlayerTimes := 0;
      end;

      if(Servers[Self.Base.ChannelId].Players
        [Self.AttackerID].Status < Playing) then
      Exit;
      if (Self.CurrentPos.Distance(Servers[Self.Base.ChannelId].Players
        [Self.AttackerID].Base.PlayerCharacter.LastPos) <= 3) then
      // atacar se tiver no range
      begin
        if not(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.IsDead) then
        begin
          if (SecondsBetween(Now, Self.LastMyAttack) >= 3) then
          // se tiver 2 segundos entre
          // um ataque e outro, ele ataca...
          begin

            if ((Self.Base.GetMobAbility(EF_SKILL_STUN) = 0) and (
              Self.Base.GetMobAbility(EF_SILENCE1) = 0)) then
            begin
              if (Self.isGuard) then
              begin
                if(SecondsBetween(Now, Self.LastSkillAttack) >= 20) then
                begin
                  if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
                      .Base.BuffExistsByIndex(36)) then
                  begin
                    dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
                      .Base.BolhaPoints, 1);
                    if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
                      .Base.BolhaPoints = 0) then
                    begin
                      Servers[Self.Base.ChannelId].Players[Self.AttackerID]
                      .Base.RemoveBuffByIndex(36);
                      Servers[Self.Base.ChannelId].Players[Servers[Self.Base.ChannelId].Players[Self.AttackerID]
                      .Base.ClientID].SendClientMessage
                        ('Você resistiu à habilidade de slow. Proteção caiu.', 16, 1, 1);
                    end
                    else
                    begin
                      Servers[Self.Base.ChannelId].Players[Servers[Self.Base.ChannelId].Players[Self.AttackerID]
                      .Base.ClientID].SendClientMessage
                        ('Você resistiu à habilidade de de slow. Proteção restam ' +
                        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
                      .Base.BolhaPoints.ToString + ' ticks.', 16, 1, 1);
                    end;
                    Self.LastMyAttack := Now;
                    Self.LastSkillAttack := now;
                    //Self.AttackSamePlayerTimes := Self.AttackSamePlayerTimes + 1;

                  end
                  else
                  begin;
                    Self.LastMyAttack := Now;
                    Self.LastSkillAttack := now;
                    Self.AttackPlayer(6470); // lentidão em massa
                    //Self.AttackSamePlayerTimes := Self.AttackSamePlayerTimes + 1;
                  end;
                end
                else
                begin
                  Self.LastMyAttack := Now;
                  Self.AttackPlayer(0);
                  //Self.AttackSamePlayerTimes := Self.AttackSamePlayerTimes + 1;
                end;
              end
              else
              begin
                Self.LastMyAttack := Now;
                Self.AttackPlayer(0);
                //Self.AttackSamePlayerTimes := Self.AttackSamePlayerTimes + 1;
              end;
            end;
          end;
        end
        else
        begin
          OPP := nil;

          for I := 1 to High(Servers[Self.Base.ChannelId].Players) do
          begin
            if((Servers[Self.Base.ChannelId].Players[i].Status < Playing) or
              (Servers[Self.Base.ChannelId].Players[i].SocketClosed)) then
                Continue;
            if(Servers[Self.Base.ChannelId].Players[i].Base.PlayerCharacter.LastPos
              .InRange(Self.InitPos, 25)) then
            begin
              OPP := @Servers[Self.Base.ChannelId].Players[i];
              break;
            end;
          end;

          if(OPP <> nil) then
          begin
            Self.FirstPlayerAttacker := OPP.Base.ClientID;
            Self.AttackerID := OPP.Base.ClientID;
          end
          else
          begin
            Self.MovedTo := Init;
            Self.MovimentsTime := 0;
            Self.LastMoviment := Now;
            Self.AttackerID := 0;
            Self.IsAttacked := FALSE;
            LastSkillUsedByMob := Now;
            ActualUsingSkill := 0;
            Self.FirstPlayerAttacker := 0;
            Self.CurrentPos := Self.InitPos;
            Self.Base.PlayerCharacter.LastPos := Self.CurrentPos;
            Self.HP := Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].InitHP;
            Self.MobMove(Self.InitPos, 40, MOVE_NORMAL); // era move normal
            Self.AttackSamePlayerTimes := 0;
          end;
        end;
      end
      else if (Self.InitPos.Distance(Servers[Self.Base.ChannelId].Players
        [Self.AttackerID].Base.PlayerCharacter.LastPos) >= 51) then
      begin
        OPP := nil;

        for I := 1 to High(Servers[Self.Base.ChannelId].Players) do
        begin
          if((Servers[Self.Base.ChannelId].Players[i].Status < Playing) or
            (Servers[Self.Base.ChannelId].Players[i].SocketClosed)) then
              Continue;
          if(Servers[Self.Base.ChannelId].Players[i].Base.PlayerCharacter.LastPos
            .InRange(Self.InitPos, 25)) then
          begin
            if (Self.isGuard) then
            begin
              //for i := 1 to MAX_CONNECTIONS do
              //begin
                if (Servers[Self.Base.ChannelId].Players[i].status < Playing) then
                  Exit;
                if (Servers[Self.Base.ChannelId].Players[i].Base.BuffExistsByIndex(77)) then
                begin // inv dual
                  Exit;
                end;
                if (Servers[Self.Base.ChannelId].Players[i].Base.BuffExistsByIndex(53)) then
                begin // inv att
                  Exit;
                end;
                if (Servers[Self.Base.ChannelId].Players[i].Base.BuffExistsByIndex(153)) then
                begin // predador
                  Exit;
                end;
                if not(
                  Servers[Self.Base.ChannelId].Players[i]
                  .Base.IsDead) then
                begin
                  if (Servers[Self.Base.ChannelId].Players[i]
                    .Base.Character.Nation > 0) then
                  begin
                    if (Servers[Self.Base.ChannelId].Players[i].Base.Character.Nation
                      <> Self.Base.PlayerCharacter.Base.Nation) then
                    begin // ir atras e dar slow
                      OPP := @Servers[Self.Base.ChannelId].Players[i];
                      break;
                    end;
                  end;
                end;
            end
            else
            begin
              OPP := @Servers[Self.Base.ChannelId].Players[i];
              break;
            end;
          end;
        end;

        if(OPP <> nil) then
        begin
          Self.FirstPlayerAttacker := OPP.Base.ClientID;
          Self.AttackerID := OPP.Base.ClientID;
        end
        else
        begin
          Self.MovedTo := Init;
          Self.MovimentsTime := 0;
          Self.LastMoviment := Now;
          Self.AttackerID := 0;
          Self.IsAttacked := FALSE;
          Self.FirstPlayerAttacker := 0;
          LastSkillUsedByMob := Now;
          ActualUsingSkill := 0;
          Self.CurrentPos := Self.InitPos;
          Self.Base.PlayerCharacter.LastPos := Self.CurrentPos;
          Self.HP := Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].InitHP;
          Self.MobMove(Self.InitPos, 40, MOVE_NORMAL); // era move normal
          Self.AttackSamePlayerTimes := 0;
        end;
      end
      else
      begin
        OPP := nil;

        for I := 1 to High(Servers[Self.Base.ChannelId].Players) do
        begin
          if((Servers[Self.Base.ChannelId].Players[i].Status < Playing) or
            (Servers[Self.Base.ChannelId].Players[i].SocketClosed)) then
              Continue;
          if(Servers[Self.Base.ChannelId].Players[i].Base.PlayerCharacter.LastPos
            .InRange(Self.InitPos, 25)) then
          begin
            if (Self.isGuard) then
            begin
              //for i := 1 to MAX_CONNECTIONS do
              //begin
                if (Servers[Self.Base.ChannelId].Players[i].status < Playing) then
                  Exit;
                if (Servers[Self.Base.ChannelId].Players[i].Base.BuffExistsByIndex(77)) then
                begin // inv dual
                  Exit;
                end;
                if (Servers[Self.Base.ChannelId].Players[i].Base.BuffExistsByIndex(53)) then
                begin // inv att
                  Exit;
                end;
                if (Servers[Self.Base.ChannelId].Players[i].Base.BuffExistsByIndex(153)) then
                begin // predador
                  Exit;
                end;
                if not(
                  Servers[Self.Base.ChannelId].Players[i]
                  .Base.IsDead) then
                begin
                  if (Servers[Self.Base.ChannelId].Players[i]
                    .Base.Character.Nation > 0) then
                  begin
                    if (Servers[Self.Base.ChannelId].Players[i].Base.Character.Nation
                      <> Self.Base.PlayerCharacter.Base.Nation) then
                    begin // ir atras e dar slow
                      OPP := @Servers[Self.Base.ChannelId].Players[i];
                      break;
                    end;
                  end;
                end;
            end
            else
            begin
              OPP := @Servers[Self.Base.ChannelId].Players[i];
              break;
            end;
          end;
        end;

        if(OPP <> nil) then
        begin
          Self.FirstPlayerAttacker := OPP.Base.ClientID;
          Self.AttackerID := OPP.Base.ClientID;

          Randomize;
          Rand := RandomRange(1, 8);

          {Self.XPositionDif := Round(Self.CurrentPos.X - Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            .Base.Neighbors[Rand].pos.X);
          if (Self.XPositionDif < 0) then
            Self.XPositionDif := abs(Self.XPositionDif);
          if (Self.XPositionDif >= 1) then
          begin
            if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            .Base.Neighbors[Rand].pos.X < Self.CurrentPos.X) then
              Self.CurrentPos.X := Self.CurrentPos.X - (1)
            else
              Self.CurrentPos.X := Self.CurrentPos.X + (1);
          end;
          Self.YPositionDif := Round(Self.CurrentPos.Y - Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            .Base.Neighbors[Rand].pos.Y);
          if (Self.YPositionDif < 0) then
            Self.YPositionDif := abs(Self.YPositionDif);
          if (Self.YPositionDif >= 1) then
          begin
            if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            .Base.Neighbors[Rand].pos.Y < Self.CurrentPos.Y) then
              Self.CurrentPos.Y := Self.CurrentPos.Y - (1)
            else
              Self.CurrentPos.Y := Self.CurrentPos.Y + (1);
          end; }

          //Self.CurrentPos := Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            //.Base.Neighbors[Rand].pos;
          Self.CurrentPos := Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            .Base.Neighbors[Rand].pos;
          Self.Base.PlayerCharacter.LastPos := Self.CurrentPos;
          Self.MobMove(Self.CurrentPos, 40);
        end
        else
        begin
          Self.MovedTo := Init;
          Self.MovimentsTime := 0;
          Self.LastMoviment := Now;
          Self.AttackerID := 0;
          Self.IsAttacked := FALSE;
          Self.FirstPlayerAttacker := 0;
          LastSkillUsedByMob := Now;
          ActualUsingSkill := 0;
          Self.CurrentPos := Self.InitPos;
          Self.Base.PlayerCharacter.LastPos := Self.CurrentPos;
          Self.HP := Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].InitHP;
          Self.MobMove(Self.InitPos, 40, MOVE_NORMAL); // era move normal
          Self.AttackSamePlayerTimes := 0;
        end;
      end;
{$ENDREGION}
    end
    else
    begin
      Self.AttackSamePlayerTimes := 0;
      {if (Self.isGuard) then
      begin
        if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            .Base.BuffExistsByIndex(36)) then
        begin
          dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            .Base.BolhaPoints, 1);
          if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            .Base.BolhaPoints = 0) then
          begin
            Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            .Base.RemoveBuffByIndex(36);
            Servers[Self.Base.ChannelId].Players[Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            .Base.ClientID].SendClientMessage
              ('Você resistiu à habilidade de ataque de [' +
              AnsiString(Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].Name) + ']', 16, 1, 1);
          end
          else
          begin
            Servers[Self.Base.ChannelId].Players[Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            .Base.ClientID].SendClientMessage
              ('Você resistiu à habilidade de ataque de [' +
              AnsiString(Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].Name) + ']', 16, 1, 1);
          end;
          Self.LastMyAttack := Now;
          Self.LastSkillAttack := now;
        end
        else
        begin
          Self.LastMyAttack := Now;
          Self.LastSkillAttack := now;
          Self.AttackPlayer(6470); // lentidão em massa
        end;
      end;     }
      if (Self.isGuard) then
      begin
        //for i := 1 to MAX_CONNECTIONS do
        //begin
          if (Servers[Self.Base.ChannelId].Players[ClientHandlerID].status < Playing) then
            Exit;
          if (Servers[Self.Base.ChannelId].Players[ClientHandlerID].Base.BuffExistsByIndex(77)) then
          begin // inv dual
            Exit;
          end;
          if (Servers[Self.Base.ChannelId].Players[ClientHandlerID].Base.BuffExistsByIndex(53)) then
          begin // inv att
            Exit;
          end;
          if (Servers[Self.Base.ChannelId].Players[ClientHandlerID].Base.BuffExistsByIndex(153)) then
          begin // predador
            Exit;
          end;
          if ((Servers[Self.Base.ChannelId].Players[ClientHandlerID]
            .Base.PlayerCharacter.LastPos.InRange(Self.CurrentPos, 30)) and not(
            Servers[Self.Base.ChannelId].Players[ClientHandlerID]
            .Base.IsDead)) then
          begin
            if (Servers[Self.Base.ChannelId].Players[ClientHandlerID]
              .Base.Character.Nation > 0) then
            begin
              if (Servers[Self.Base.ChannelId].Players[ClientHandlerID].Base.Character.Nation
                <> Self.Base.PlayerCharacter.Base.Nation) then
              begin // ir atras e dar slow
                Self.IsAttacked := True;
                Self.AttackerID := ClientHandlerID;
                Exit;
              end;
            end;
          end;
        //end;
      end;

      if(Self.Base.VisibleMobs.Count > 0) then
      begin
        for i in Self.Base.VisibleMobs do
        begin
          OtherPlayer := @Servers[Self.Base.ChannelId].Players[i];
          if(OtherPlayer.InDungeon) then
            continue;
          if(OtherPlayer.Status < Playing) then
            Continue;
          if(OtherPlayer.SocketClosed) then
            Continue;
          if (OtherPlayer.Base.BuffExistsByIndex(77)) then
          begin // inv dual
            Continue;
          end;
          if (OtherPlayer.Base.BuffExistsByIndex(53)) then
          begin // inv att
            Continue;
          end;
          if (OtherPlayer.Base.BuffExistsByIndex(153)) then
          begin // predador
            Continue;
          end;
          if not(OtherPlayer.Base.IsDead) then
            OtherPlayer.Base.LureMobsInRange;
        end;
      end;
    end;
  end;
end;

procedure TMobSPosition.MobMoviment(ClientHandlerID: Integer);
var
  Rand, i, j: Integer;
  OPP: PPlayer;
begin
  //if(MilliSecondsBetween(Now, Self.UpdatedMobMoviment) < 600) then
    //Exit;

  Self.UpdatedMobMoviment := Now;

  if(Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].IntName = 0) then
    Exit;

  try
    if ((Self.Base.IsDead = FALSE) and (Self.IsAttacked = FALSE)) then
    begin
      if (Self.MovedTo = Init) then
      begin
        if (SecondsBetween(Now, Self.LastMoviment) > Self.InitMoveWait) then
        begin
          Self.XPositionDif := Round(Self.DestPos.X - Self.CurrentPos.X);
          if (Self.XPositionDif < 0) then
            Self.XPositionDif := abs(Self.XPositionDif);
          if (Self.XPositionDif >= 2) then
          begin
            if (Self.DestPos.X > Self.CurrentPos.X) then
              Self.CurrentPos.X := Self.CurrentPos.X + (1.5)
            else
              Self.CurrentPos.X := Self.CurrentPos.X - (1.5);
          end;
          Self.YPositionDif := Round(Self.DestPos.Y - Self.CurrentPos.Y);
          if (Self.YPositionDif < 0) then
            Self.YPositionDif := abs(Self.YPositionDif);
          if (Self.YPositionDif >= 2) then
          begin
            if (Self.DestPos.Y > Self.CurrentPos.Y) then
              Self.CurrentPos.Y := Self.CurrentPos.Y + (1.5)
            else
              Self.CurrentPos.Y := Self.CurrentPos.Y - (1.5);
          end;
          inc(Self.MovimentsTime);
          Self.Base.PlayerCharacter.LastPos := Self.CurrentPos;
          if (Self.MovimentsTime >= 2) then
          begin
            Self.MovimentsTime := 0;
            Self.MobMove(Self.CurrentPos, 25);
          end;
          if (Self.CurrentPos.Distance(Self.DestPos) <= 0) then
          begin
            Self.MovedTo := Dest;
            Self.MovimentsTime := 0;
            Self.LastMoviment := Now;
            Self.CurrentPos := Self.DestPos;
          end;
        end;
      end
      else if (Self.MovedTo = Dest) then
      begin
        if (SecondsBetween(Now, Self.LastMoviment) > Self.InitMoveWait) then
        begin
          Self.XPositionDif := Round(Self.CurrentPos.X - Self.InitPos.X);
          if (Self.XPositionDif < 0) then
            Self.XPositionDif := abs(Self.XPositionDif);
          if (Self.XPositionDif >= 2) then
          begin
            if (Self.InitPos.X < Self.CurrentPos.X) then
              Self.CurrentPos.X := Self.CurrentPos.X - (1.5)
            else
              Self.CurrentPos.X := Self.CurrentPos.X + (1.5);
          end;
          Self.YPositionDif := Round(Self.CurrentPos.Y - Self.InitPos.Y);
          if (Self.YPositionDif < 0) then
            Self.YPositionDif := abs(Self.YPositionDif);
          if (Self.YPositionDif >= 2) then
          begin
            if (Self.InitPos.Y < Self.CurrentPos.Y) then
              Self.CurrentPos.Y := Self.CurrentPos.Y - (1.5)
            else
              Self.CurrentPos.Y := Self.CurrentPos.Y + (1.5);
          end;
          inc(Self.MovimentsTime);
          Self.Base.PlayerCharacter.LastPos := Self.CurrentPos;
          if (Self.MovimentsTime >= 2) then
          begin
            Self.MovimentsTime := 0;
            Self.MobMove(Self.CurrentPos, 25);
          end;
          if (Self.CurrentPos.Distance(Self.InitPos) <= 0) then
          begin
            Self.MovedTo := Init;
            Self.MovimentsTime := 0;
            Self.LastMoviment := Now;
            Self.CurrentPos := Self.InitPos;
          end;
        end;
      end;
    end;

    if(Self.AttackerID = 0) then
      Exit;

    if ((Self.Base.IsDead = FALSE) and (Self.IsAttacked = True)) then
    begin
      if not(Self.AttackerID > 0) then
        Exit;
      if not(Self.CurrentPos.Distance(Servers[Self.Base.ChannelId].Players
        [Self.AttackerID].Base.PlayerCharacter.LastPos) >= 3) then
          Exit;
      if not(Self.Base.GetMobAbility(EF_SKILL_STUN) = 0) then
        Exit;
      if not(Self.Base.GetMobAbility(EF_SKILL_IMMOVABLE) = 0) then
        Exit;
      if not(Self.Base.GetMobAbility(EF_SKILL_SHOCK) = 0) then
        Exit;
      if not(Self.Base.GetMobAbility(EF_SKILL_SLEEP) = 0) then
        Exit;

      Randomize;
      Rand := RandomRange(1, 8);

      if(Self.isGuard) then
      begin
        //Self.CurrentPos := Self.InitPos;
        {Self.CurrentPos :=
          Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.Neighbors[Rand].pos;}
        Self.XPositionDif := Round(Self.CurrentPos.X - Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.Neighbors[Rand].pos.X);
        if (Self.XPositionDif < 0) then
          Self.XPositionDif := abs(Self.XPositionDif);
        if (Self.XPositionDif >= 3) then
        begin
          if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.Neighbors[Rand].pos.X < Self.CurrentPos.X) then
            Self.CurrentPos.X := Self.CurrentPos.X - 2
          else
            Self.CurrentPos.X := Self.CurrentPos.X + 2;
        end;
        Self.YPositionDif := Round(Self.CurrentPos.Y - Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.Neighbors[Rand].pos.Y);
        if (Self.YPositionDif < 0) then
          Self.YPositionDif := abs(Self.YPositionDif);
        if (Self.YPositionDif >= 3) then
        begin
          if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.Neighbors[Rand].pos.Y < Self.CurrentPos.Y) then
            Self.CurrentPos.Y := Self.CurrentPos.Y - 2
          else
            Self.CurrentPos.Y := Self.CurrentPos.Y + 2;
        end;

        Self.Base.PlayerCharacter.LastPos := Self.CurrentPos;
        Self.MobMove(Self.CurrentPos, 40);
      end
      else
      begin

        Self.XPositionDif := Round(Self.CurrentPos.X - Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.Neighbors[Rand].pos.X);
        if (Self.XPositionDif < 0) then
          Self.XPositionDif := abs(Self.XPositionDif);
        if (Self.XPositionDif >= 3) then
        begin
          if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.Neighbors[Rand].pos.X < Self.CurrentPos.X) then
            Self.CurrentPos.X := Self.CurrentPos.X - (2)
          else
            Self.CurrentPos.X := Self.CurrentPos.X + (2);
        end;
        Self.YPositionDif := Round(Self.CurrentPos.Y - Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.Neighbors[Rand].pos.Y);
        if (Self.YPositionDif < 0) then
          Self.YPositionDif := abs(Self.YPositionDif);
        if (Self.YPositionDif >= 3) then
        begin
          if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.Neighbors[Rand].pos.Y < Self.CurrentPos.Y) then
            Self.CurrentPos.Y := Self.CurrentPos.Y - (2)
          else
            Self.CurrentPos.Y := Self.CurrentPos.Y + (2);
        end;
        Self.Base.PlayerCharacter.LastPos := Self.CurrentPos;
        Self.MobMove(Self.CurrentPos, 40);
      end;

      //Self.CurrentPos := Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        //.Base.Neighbors[Rand].pos;

    end;
    if ((Self.Base.IsDead = FALSE) and (Self.IsAttacked = True) and
      (Self.CurrentPos.Distance(Self.InitPos) >= 40)) then
    begin
      if not(Self.Base.GetMobAbility(EF_SKILL_STUN) = 0) then
        Exit;
      if not(Self.Base.GetMobAbility(EF_SKILL_IMMOVABLE) = 0) then
        Exit;
      if not(Self.Base.GetMobAbility(EF_SKILL_SHOCK) = 0) then
        Exit;
      if not(Self.Base.GetMobAbility(EF_SKILL_SLEEP) = 0) then
        Exit;

      OPP := nil;

      for I := 1 to High(Servers[Self.Base.ChannelId].Players) do
      begin
        if((Servers[Self.Base.ChannelId].Players[i].Status < Playing) or
          (Servers[Self.Base.ChannelId].Players[i].SocketClosed)) then
            Continue;
        if(Servers[Self.Base.ChannelId].Players[i].Base.PlayerCharacter.LastPos
          .InRange(Self.InitPos, 40)) then
        begin
          OPP := @Servers[Self.Base.ChannelId].Players[i];
          break;
        end;
      end;

      if(OPP <> nil) then
      begin
        Self.FirstPlayerAttacker := OPP.Base.ClientID;
        Self.AttackerID := OPP.Base.ClientID;
      end
      else
      begin
        Self.MovedTo := Init;
        Self.MovimentsTime := 0;
        Self.LastMoviment := Now;
        Self.AttackerID := 0;
        Self.IsAttacked := FALSE;
        Self.FirstPlayerAttacker := 0;
        Self.CurrentPos := Self.InitPos;
        Self.Base.PlayerCharacter.LastPos := Self.CurrentPos;
        Self.HP := Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].InitHP;
        Self.MobMove(Self.InitPos, 40, MOVE_NORMAL); // era move normal
      end;
    end;
    // Logger.Write('Mob Moviment Error: mobID[' + Self.Base.MobID.ToString +
    // '] mobPID[' + Self.Base.SecondIndex.ToString + ']', TlogType.Error);
  except
    on E: Exception do
      Logger.Write('Error at mob Moviment [' + E.Message + '] b.e: ' +
        E.BaseException.Message + ' mobid: ' + Self.Base.MobID.ToString + ' t:'
        + DateTimeToStr(Now), TlogType.Error);
  end;
end;
procedure TMobSPosition.MobMove(Position: TPosition; Speed: BYTE;
  MoveType: BYTE);
var
  Packet: TMobMovimentPacket;
  i: Integer;
begin
  ZeroMemory(@Packet, sizeof(TMobMovimentPacket));
  Packet.Header.size := sizeof(TMobMovimentPacket);
  Packet.Header.Index := Self.Index;
  Packet.Header.Code := $301;
  Packet.Destination := Position;
  Packet.MoveType := MoveType;
  if (Speed = 25) then
    Packet.Speed := Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.MobID]
      .MoveSpeed
  else
    Packet.Speed := Speed;
  for i in Self.Base.VisibleMobs do
  begin
    if (i <= MAX_CONNECTIONS) then
    begin
      //if (Assigned(Servers[Self.Base.ChannelId].Players[i]) = False) then
        //Continue;
      if not(Assigned(Servers[Self.Base.ChannelId].Players[i].FriendList)) then
      begin
        Self.Base.VisibleMobs.Remove(i);
        Continue;
      end;
      if(Servers[Self.Base.ChannelId].Players[i].SocketClosed) then
        Continue;
      if (Servers[Self.Base.ChannelId].Players[i].status < TPlayerStatus.Playing)
      then
        continue;
      Servers[Self.Base.ChannelId].Players[i].SendPacket(Packet,
        Packet.Header.size);
    end;
  end;
end;
procedure TMobSPosition.AttackPlayer(SkillID: WORD);
var
  Packet: TRecvDamagePacket;
  dnType: TDamageType;
  DANO: Integer;
  SkillIDa: DWORD;
  AttackResultType, RlkSlot: BYTE;
  DefTarget: WORD;
  i, j: Integer;
  OtherPlayer, OPP: PPlayer;
  Item: PItem;
  cnt: Byte;
  AddBuff: Boolean;
begin
  try
    SkillIDa := SkillID;

    if ((SkillID = 0) and (Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].Skill01 > 0)) then
    begin
      if(SecondsBetween(Self.LastSkillUsedByMob, Now) > 4) then
      begin
        Self.LastSkillUsedByMob := Now;


        case Self.ActualUsingSkill of
          0:
            begin
              SkillIDa := Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].Skill01;
              Inc(Self.ActualUsingSkill);
            end;
          1:
            begin
              if(Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].Skill02 = 0) then
              begin
                Self.ActualUsingSkill := 0;
              end
              else
              begin
                SkillIDa := Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].Skill02;
                Inc(Self.ActualUsingSkill);
              end;
            end;

          2:
            begin
              if(Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].Skill03 = 0) then
              begin
                Self.ActualUsingSkill := 0;
              end
              else
              begin
                SkillIDa := Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].Skill03;
                Inc(Self.ActualUsingSkill);
              end;
            end;

          3:
            begin
              if(Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].Skill04 = 0) then
              begin
                Self.ActualUsingSkill := 0;
              end
              else
              begin
                SkillIDa := Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].Skill04;
                Inc(Self.ActualUsingSkill);
              end;
            end;

          4:
            begin
              if(Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].Skill05 = 0) then
              begin
                Self.ActualUsingSkill := 0;
              end
              else
              begin
                SkillIDa := Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].Skill05;
                Inc(Self.ActualUsingSkill);
              end;

              Self.ActualUsingSkill := 0;
            end;
        end;
      end;
    end;

    // fazeer umas checagens aqui, para certos tipos de mobs terem skills
    // tipo, guardas, pedras, e mobs mutantes devem ter skills
    { if (Self.PosGot.Distance(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.PlayerCharacter.LastPos) > 5) then
      begin
      Self.PosGot := Self.CurrentPos;
      Exit;
      end; }
    if(Servers[Self.Base.ChannelId].Players[Self.AttackerID].SocketClosed) then
      Exit;
    if(Self.Base.IsDead) then
    begin
      Self.IsAttacked := False;
      Self.AttackerID := 0;
      Exit;
    end;
    if(Self.isGuard) then
    begin
      if(Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.Character.Nation > 0) then
      begin
        if(Servers[Self.Base.ChannelId].NationID =
          Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.Character.Nation) then
        begin
          Self.IsAttacked := False;
          Self.AttackerID := 0;
          Exit;
        end;
      end;
    end;
    ZeroMemory(@Packet, sizeof(Packet));
    Packet.Header.size := sizeof(Packet);
    Packet.Header.Index := Self.Index;
    Packet.Header.Code := $102;
    Packet.SkillID := SkillIDa;
    Packet.AttackerPos := Self.CurrentPos;
    Packet.AttackerID := Self.Index;
    Packet.Animation := 06;
    Packet.AttackerHP := Self.HP;
    Packet.TargetID := Self.AttackerID;
    Packet.MobAnimation := 26;
    DANO := 0;
    if (SkillIDa > 0) then
      DANO := (Self.Base.PlayerCharacter.Base.CurrentScore.DNFis div 2) +
        SkillData[SkillIDa].Damage
    else
      DANO := Self.Base.PlayerCharacter.Base.CurrentScore.DNFis div 2;
    { case Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Level of
      0 .. 20:
      begin
      Packet.DANO := 10;
      end;
      21 .. 40:
      begin
      Packet.DANO := 50;
      end;
      41 .. 60:
      begin
      Packet.DANO := 200;
      end;
      end; }
    case Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.GetMobClass of
      0 .. 3:
        begin
          DefTarget := Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            .Base.PlayerCharacter.Base.CurrentScore.DefFis;
        end;
    else
      DefTarget := Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.PlayerCharacter.Base.CurrentScore.DefMag;
    end;
    Randomize;
    AttackResultType := RandomRange(1, 101);
    case AttackResultType of
      2 .. 15:
        begin
          dnType := TDamageType.Miss;
        end;
      16 .. 30:
        begin
          dnType := TDamageType.Critical;
        end;
      31 .. 100:
        begin
          dnType := TDamageType.Normal;
        end;
    else
      dnType := TDamageType.Normal;
    end;
    DANO := DANO - (DefTarget shr 3);
    inc(DANO, (RandomRange(10, 39) + 7));
    if (dnType = TDamageType.Miss) then
    begin
      DANO := 0;
    end
    else
    begin
      if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.BuffExistsByIndex(19)) then
      begin
        DANO := 0;
        dnType := TDamageType.Block;
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.RemoveBuffByIndex(19);
      end;
      if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.BuffExistsByIndex(91)) then
      begin
        DANO := 0;
        dnType := TDamageType.Miss2;
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.RemoveBuffByIndex(91);
      end;
    end;

    if(Servers[Self.Base.ChannelId].ReliqEffect[
    EF_RELIQUE_DEF_MONSTER] > 0) then
    begin
      DecInt(DANO, (Servers[Self.Base.ChannelId].ReliqEffect[
        EF_RELIQUE_DEF_MONSTER] * (DANO div 100)));
    end;
      //DANO := DANO -

    if(dnType = Critical) then
    begin
      DANO := Round(DANO * 1.5);
    end;
    //if(AttackSamePlayerTimes = 0) then
      //AttackSamePlayerTimes := 1;

    //DANO := Dano * AttackSamePlayerTimes;

    if (DANO < 0) then
      DANO := 1;

    AddBuff := True;

    if(SkillIDa > 0) then
      Self.Base.AttackParseForMobs(SkillIDa, 0,
      @Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base, Dano, DnType,
      AddBuff, Packet.MobAnimation)
    else
      Self.Base.AttackParseForMobs(0, 0,
      @Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base, Dano, DnType,
      AddBuff, Packet.MobAnimation);

    if (Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.GetMobAbility(EF_IMMUNITY) > 0) then
    begin
      DnType := TDamageType.Immune;
      Packet.DANO := 0;
      AddBuff := False;
    end;

    if (Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.BuffExistsByIndex(19)) then
    begin
      Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.RemoveBuffByIndex(19);
      DnType := TDamageType.Block;
      Packet.DANO := 0;
      AddBuff := False;
    end;

    if (Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.BuffExistsByIndex(91)) then
    begin

      Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.RemoveBuffByIndex(91);
      DnType := TDamageType.Miss2;
      Packet.DANO := 0;
      AddBuff := False;
    end;

    if(SkillIDa > 0) then
    begin
      if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.BuffExistsByIndex(36)) then
      begin
        dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.BolhaPoints, 1);
        if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.BolhaPoints = 0) then
        begin
          Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.RemoveBuffByIndex(36);
          Servers[Self.Base.ChannelId].Players[Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.ClientID].SendClientMessage
            ('Você resistiu à habilidade de slow. Proteção caiu.', 16, 1, 1);
        end
        else
        begin
          Servers[Self.Base.ChannelId].Players[Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.ClientID].SendClientMessage
            ('Você resistiu à habilidade de de slow. Proteção restam ' +
            Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.BolhaPoints.ToString + ' ticks.', 16, 1, 1);
        end;

        AddBuff := False;
      end;
    end;

    Packet.dnType := dnType;

    Packet.DANO := DANO;

    if((Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(53)) or (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(77)) or (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(24))) then
    begin
      Self.IsAttacked := False;
      Self.AttackerID := 0;
      Exit;
    end;

    if (Packet.DANO >= Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.CurrentScore.CurHP) then
    begin
      if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(134)) then
      begin
        //Helper := mob.GetBuffIDByIndex(134);
        //mob.AddHP(mob.CalcCure2(SkillData[Helper].EFV[0], mob, Helper), True);
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.Character.CurrentScore.CurHP := 1;
        Servers[Self.Base.ChannelId].Players[Self.AttackerID].SendClientMessage
            ('Cura preventiva entrou em ação e feitiço foi desfeito.', 0);
        Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.RemoveBuffByIndex(134);
      end
      else
      begin
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.Character.CurrentScore.CurHP := 0;
        Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.IsDead := True;
        Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.SendEffect($0);
        Packet.MobAnimation := 30;
        cnt := 0;
        while (TItemFunctions.GetItemSlotByItemType(Servers[Self.Base.ChannelId].Players[Self.AttackerID],
          40, INV_TYPE, 0) <> 255) do
        begin
          RlkSlot := TItemFunctions.GetItemSlotByItemType(Servers[Self.Base.ChannelId].Players[Self.AttackerID],
            40, INV_TYPE, 0);
          if(RlkSlot <> 255) then
          begin
            Item := @Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.Character.Inventory[RlkSlot];
            Servers[Self.Base.ChannelId].CreateMapObject(@Servers[Self.Base.ChannelId].Players[Self.AttackerID],
              320, Item.Index);
            Servers[Self.Base.ChannelId].SendServerMsg('O jogador ' +
              AnsiString(Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.Character.Name) + ' dropou a relíquia <' +
              AnsiString(ItemList[Item.Index].Name) + '>.');
            ZeroMemory(Item, sizeof(TItem));
            Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, False);
            cnt := cnt + 1;
          end;
        end;
        if(cnt > 0) then
        begin
          Servers[Self.Base.ChannelId].Players[Self.AttackerID].SendEffect(0);
        end;

        OPP := nil;

        for I := 1 to High(Servers[Self.Base.ChannelId].Players) do
        begin
          if((Servers[Self.Base.ChannelId].Players[i].Status < Playing) or
              (Servers[Self.Base.ChannelId].Players[i].SocketClosed)) then
            Continue;

          if((Servers[Self.Base.ChannelId].Players[i].Base.PlayerCharacter
            .LastPos.InRange(Self.InitPos, 40)) and not(Servers[Self.Base.ChannelId].Players[i].Base.IsDead)) then
          begin
            OPP := @Servers[Self.Base.ChannelId].Players[i];
            break;
          end;
        end;

        if(OPP = nil) then
        begin
          Self.IsAttacked := FALSE;
          Self.LastMoviment := Now;
          Self.CurrentPos := InitPos;
          Self.MovimentsTime := 0;
          Self.MovedTo := Init;
          Self.FirstPlayerAttacker := 0;
          Self.Base.PlayerCharacter.LastPos := Self.CurrentPos;
          Self.HP := Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].InitHP;
          Self.MobMove(Self.InitPos, 50, MOVE_NORMAL); // era move normal
        end
        else
        begin
          Self.AttackerID := OPP.Base.ClientID;
          Self.FirstPlayerAttacker := OPP.Base.ClientID;
        end;
      end;

      {for I := Low(Servers[Self.Base.ChannelId].MOBS.TMobS) to
        High(Servers[Self.Base.ChannelId].MOBS.TMobS) do
      begin
        if(Servers[Self.Base.ChannelId].MOBS.TMobS[i].IndexGeneric = 0) then
          Continue;
        for j := Low(Servers[Self.Base.ChannelId].MOBS.TMobS[i].MobsP) to
          High(Servers[Self.Base.ChannelId].MOBS.TMobS[i].MobsP) do
        begin
          if(Servers[Self.Base.ChannelId].MOBS.TMobS[i].MobsP[j].Index = 0) then
            Continue;
          if not(Servers[Self.Base.ChannelId].MOBS.TMobS[i].MobsP[j].IsAttacked) then
            Continue;
          if(Servers[Self.Base.ChannelId].MOBS.TMobS[i].MobsP[j].Base.IsDead) then
            Continue;
          if(Servers[Self.Base.ChannelId].MOBS.TMobS[i].MobsP[j].AttackerID =
            Self.AttackerID) then //achei os outros que estavam me atacando, agora vou limpar eles tbm
          begin
            Servers[Self.Base.ChannelId].MOBS.TMobS[i].MobsP[j].IsAttacked := FALSE;
            Servers[Self.Base.ChannelId].MOBS.TMobS[i].MobsP[j].LastMoviment := Now;
            Servers[Self.Base.ChannelId].MOBS.TMobS[i].MobsP[j].CurrentPos := InitPos;
            Servers[Self.Base.ChannelId].MOBS.TMobS[i].MobsP[j].MovimentsTime := 0;
            Servers[Self.Base.ChannelId].MOBS.TMobS[i].MobsP[j].MovedTo := Init;
          end;
        end;
      end; }
    end
    else
    begin
      if(DANO > 0) then
      begin
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.RemoveHP(Dano, False, False);
         //DecCardinal(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          //.Base.Character.CurrentScore.CurHP, DANO);
      end;
    end;

    Inc(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.AttacksReceivedAccumulated);
    if(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.AttacksReceivedAccumulated >= 48) then
    begin
      if(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[2].Index > 0) then
      begin
        case Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[2].Refi of
          1..80:
            begin
              if not(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(303)) then
              Dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[2].MIN, 1);
            end;
          81..160:
            begin
              if not(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(303)) then
              Dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[2].MIN, 2);
            end;
          161..240:
            begin
              if not(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(303)) then
              Dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[2].MIN, 3);
            end;
        end;
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.AttacksReceivedAccumulated := 0;
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.SendRefreshItemSlot(EQUIP_TYPE, 2,
          Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[2], False);
      end;
      if(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[3].Index > 0) then
      begin
        case Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[3].Refi of
          1..80:
            begin
              if not(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(303)) then
              Dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[3].MIN, 1);
            end;
          81..160:
            begin
              if not(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(303)) then
              Dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[3].MIN, 2);
            end;
          161..240:
            begin
              if not(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(303)) then
              Dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[3].MIN, 3);
            end;
        end;
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.AttacksReceivedAccumulated := 0;
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.SendRefreshItemSlot(EQUIP_TYPE, 3,
          Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[3], False);
      end;
      if(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[4].Index > 0) then
      begin
        case Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[4].Refi of
          1..80:
            begin
              if not(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(303)) then
              Dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[4].MIN, 1);
            end;
          81..160:
            begin
              if not(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(303)) then
              Dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[4].MIN, 2);
            end;
          161..240:
            begin
              if not(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(303)) then
              Dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[4].MIN, 3);
            end;
        end;
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.AttacksReceivedAccumulated := 0;
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.SendRefreshItemSlot(EQUIP_TYPE, 4,
          Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[4], False);
      end;
      if(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[5].Index > 0) then
      begin
        case Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[5].Refi of
          1..80:
            begin
              if not(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(303)) then
              Dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[5].MIN, 1);
            end;
          81..160:
            begin
              if not(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(303)) then
              Dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[5].MIN, 2);
            end;
          161..240:
            begin
              if not(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(303)) then
              Dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[5].MIN, 3);
            end;
        end;
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.AttacksReceivedAccumulated := 0;
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.SendRefreshItemSlot(EQUIP_TYPE, 5,
          Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[5], False);
      end;
      if(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[7].Index > 0) then
      begin
        case Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[7].Refi of
          1..80:
            begin
            if not(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(303)) then
              Dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[7].MIN, 1);
            end;
          81..160:
            begin
              if not(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(303)) then
              Dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[7].MIN, 2);
            end;
          161..240:
            begin
              if not(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(303)) then
              Dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[7].MIN, 3);
            end;
        end;
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.AttacksReceivedAccumulated := 0;
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.SendRefreshItemSlot(EQUIP_TYPE, 7,
          Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Equip[7], False);
      end;
    end;

    //if(Self.AttackerID > 0) then
      //Self.UpdateSpawnToPlayers(Self.Base.Mobid, Self.Base.SecondIndex,
       // Self.AttackerID);
    Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.LastReceivedAttack := Now;
    Packet.MobCurrHP := Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.CurrentScore.CurHP;
    Packet.DeathPos := Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.PlayerCharacter.LastPos;
    Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.SendToVisible
      (Packet, Packet.Header.size, True);
    if (Packet.DANO > 0) then
    begin
      if(SkillIda > 0) then
      begin
        if (SkillData[SkillIDa].SuccessRate = 1) and
          (SkillData[SkillIDa].Range > 0) then
        begin // skill em area
          if(AddBuff) then
            Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.AddBuff(SkilliDa);
         { for i := Low(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            .Base.VisibleTargets) to High(Servers[Self.Base.ChannelId].Players
            [Self.AttackerID].Base.VisibleTargets) do
          begin
            if(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            .Base.VisibleTargets[i].TargetType = 0) then
            begin //guardas atacam somente players
              OtherPlayer := Servers[Self.Base.ChannelId].Players
                [Self.AttackerID].Base.VisibleTargets[i].Player;
              if (OtherPlayer.Status >= Playing) then
              begin
                if(OtherPlayer.Base.Character.Nation > 0) and (
                  OtherPlayer.Base.Character.Nation <> Self.Base.PlayerCharacter.Base.Nation) then
                  begin //atacar somente pessoas que não são da nação do guarda
                    if(Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.
                    PlayerCharacter.LastPos.InRange(OtherPlayer.Base.PlayerCharacter.LastPos,
                    4)) then //se esse outro tal player estiver perto
                    begin
                      if (OtherPlayer.Base.BuffExistsByIndex(36) = True) then
                      begin
                        dec(OtherPlayer.Base.BolhaPoints, 1);
                        if (OtherPlayer.Base.BolhaPoints = 0) then
                        begin
                          OtherPlayer.Base.RemoveBuffByIndex(36);
                          OtherPlayer.SendClientMessage
                            ('Você resistiu à habilidade de lentidão de um Guarda.', 16, 1, 1);
                        end
                        else
                        begin
                          OtherPlayer.SendClientMessage
                            ('Você resistiu à habilidade de lentidão de um Guarda.', 16, 1, 1);
                        end;
                      end
                      else
                        OtherPlayer.Base.AddBuff(SkillIDa);
                    end;
                  end;
              end;
            end;
          end;}
        end
        else // skill unica
        begin
          if(AddBuff) then
            Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.AddBuff
              (SkillIDa);
        end;
      end;
    end;

    if not(Self.IsAttacked) then
      Self.AttackerID := 0;

  except
    on E: Exception do
      Logger.Write('Error at mob Attack Player [' + E.Message + '] b.e: ' +
        E.BaseException.Message + ' user: ' +
        String(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.Character.Name) + ' t:' + DateTimeToStr(Now), TlogType.Error);
  end;
end;
function TMobSPosition.GetDamageByPlayer(Skill: DWORD;
  out DamageType: TDamageType): UInt64;
var
  IsPhysical: Boolean;
  ResultDamage: UInt64;
  MobDef: DWORD;
begin
  Result := 0;
  case Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.GetMobClass of
    0 .. 3:
      begin
        IsPhysical := True;
      end;
  else
    if (SkillData[Skill].Index = 96) then
      IsPhysical := True
    else
      IsPhysical := FALSE;
  end;
  if (IsPhysical) then
  begin
    ResultDamage := Servers[Self.Base.ChannelId].MOBS.TMobS
      [Self.Base.MobID].FisAtk;
    MobDef := Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.PlayerCharacter.Base.CurrentScore.DefFis;
  end
  else
  begin
    ResultDamage := Servers[Self.Base.ChannelId].MOBS.TMobS
      [Self.Base.MobID].MagAtk;
    MobDef := Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.PlayerCharacter.Base.CurrentScore.DefMag;
  end;
  DamageType := Self.GetDamageTypePlayer(Skill, IsPhysical);
  if (DamageType = Miss) then
    Exit;
  inc(ResultDamage, SkillData[Skill].Damage);
  ResultDamage := ResultDamage - (MobDef shr 3);
  Randomize;
  inc(ResultDamage, (Random(20) + 5));
  case DamageType of
    Critical:
      ResultDamage := Round(ResultDamage * 1.5); // 1.5
  end;
  if (ResultDamage < 0) or (ResultDamage > 1000000) then
    ResultDamage := 1;
  Result := ResultDamage;
end;
function TMobSPosition.GetDamageTypePlayer(Skill: DWORD; IsPhys: Boolean)
  : TDamageType;
var
  RamdomArray: ARRAY [0 .. 999] OF BYTE;
  InitialSlot: WORD;
  procedure SetChance(Chance: WORD; const Type1: BYTE);
  var
    i: Integer;
  begin
    if (Chance = 0) then
      Exit;
    for i := 1 to Chance do
    begin
      if (InitialSlot >= 999) then
        continue;
      RamdomArray[InitialSlot] := Type1;
      inc(InitialSlot);
    end;
  end;
begin
  ZeroMemory(@RamdomArray, 1000);
  InitialSlot := 0;
  SetChance(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
    .Base.PlayerCharacter.Base.CurrentScore.Esquiva, BYTE(TDamageType.Miss));
  SetChance((Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.MobID]
    .MobLevel div 2), BYTE(TDamageType.Critical));
  SetChance(Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.MobID].MobLevel,
    BYTE(TDamageType.Normal));
  Randomize;
  Result := TDamageType(RamdomArray[Random(InitialSlot - 1)]);
end;
procedure TMobSPosition.UpdateSpawnToPlayers(mid, smid: Integer; ClientHandlerID: Integer);
var
  i: Integer;
  OtherPlayer: PPlayer;
begin
  try
    if (not(ClientHandlerID > 0) or
      (ClientHandlerID > MAX_CONNECTIONS)) then
      Exit;

    if(Self.Base.Mobid > 449) then
      Exit;

    if (Self.Base.IsDead) then
    begin
      if( Self.DeadTime.Year >= Now.Year) then
      begin
        try
          if (SecondsBetween(Now, Self.DeadTime) >=
            Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].ReespawnTime) then
          begin
            Self.Base.IsDead := FALSE;
            Self.IsAttacked := FALSE;
            Self.CurrentPos := Self.InitPos;
            Self.MovedTo := Init;
            Self.MovimentsTime := 0;
            Self.FirstPlayerAttacker := 0;
            LastSkillUsedByMob := Now;
            ActualUsingSkill := 0;
            Self.LastMoviment := Now;
            Self.HP := Servers[Self.Base.ChannelId].MOBS.TMobS
              [Self.Base.Mobid].InitHP;
            Self.MP := Self.HP;
          end;
        except
          on E: Exception do
          begin
            Logger.Write('Erro no reespawn do mob ' + E.Message, TLogType.Error);
          end;

        end;
      end;
    end;

   // for i := Low(Servers[Self.Base.ChannelId].Players)
     // to High(Servers[Self.Base.ChannelId].Players) do
   // begin
      //OtherPlayer := @Servers[Self.Base.ChannelId].Players[ClientHandlerID];
      if(ClientHandlerID = 0) then
        Exit;

      OtherPlayer := Servers[Self.Base.ChannelId].GetPlayer(ClientHandlerID);

      if(OtherPlayer = nil) then
        Exit;
      if (OtherPlayer.SocketClosed) then
        Exit;
      if(OtherPlayer.Status < Playing) then
        Exit;
      if((Self.CurrentPos.X < 50) or (Self.CurrentPos.Y < 50)) then
        Exit;
      if ((OtherPlayer.status < TPlayerStatus.Playing) or
        (OtherPlayer.Unlogging)) then
        Exit;
      if(OtherPlayer.Base.IsDead) then
        Exit;
      if (Self.Base.IsDead) then
        Exit;
      if not(Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].IsActiveToSpawn) then
        Exit;
      if not(OtherPlayer.IsInstantiated) then
        Exit;

      //if(MilliSecondsBetween(Now, Self.UpdatedMobSpawn) < 1000) then
        //Exit;

      //Self.UpdatedMobSpawn := Now;

      if not(OtherPlayer.Base.PlayerCharacter.LastPos.IsValid) then
        Exit;

      if not(Self.CurrentPos.IsValid) then
        Exit;

      if (OtherPlayer.Base.PlayerCharacter.LastPos.InRange(Self.CurrentPos, DISTANCE_TO_WATCH)) then
      begin
        if not(OtherPlayer.Base.VisibleMobs.Contains(Self.Base.ClientID)) then
        begin
          OtherPlayer.Base.VisibleMobs.Add(Self.Base.ClientID);
          OtherPlayer.Base.AddTargetToList(@Self.Base);

          if (Self.isGuard) then
          begin
            if ((BYTE(OtherPlayer.Account.Header.Nation) = Servers
              [Self.Base.ChannelId].NationID) or
              (OtherPlayer.Base.Character.Level < 16)) then
              OtherPlayer.SpawnMobGuard(Self.Base.Mobid, Self.Base.SecondIndex)
            else
              OtherPlayer.SpawnMob(Self.Base.Mobid, Self.Base.SecondIndex);
          end
          else
          begin
            OtherPlayer.SpawnMob(Self.Base.Mobid, Self.Base.SecondIndex);
          end;

        end;

        {if((OtherPlayer.Base.PetClientID >= 9148) and
        (OtherPlayer.Base.PetClientID <= 10147))then
        begin
          if(Servers[OtherPlayer.ChannelIndex].PETS[OtherPlayer.Base.PetClientID].IntName > 0) then
          begin
            if(Servers[OtherPlayer.ChannelIndex].PETS[OtherPlayer.Base.PetClientID].Base.IsActive) then
            begin
            if not(Servers[OtherPlayer.ChannelIndex].PETS[OtherPlayer.Base.PetClientID].Base.ClientID = 0) then
              if(Servers[OtherPlayer.ChannelIndex].PETS[OtherPlayer.Base.PetClientID].PetType = X14) then
              begin
                if not(Servers[OtherPlayer.ChannelIndex].PETS[OtherPlayer.Base.PetClientID].Base.VisibleMobs.Contains(
                  Self.Base.ClientID)) then
                begin
                  Servers[OtherPlayer.ChannelIndex].PETS[OtherPlayer.Base.PetClientID].Base.VisibleMobs.Add(Self.Base.ClientID);
                end;
              end;
            end;
          end;
        end;}

        if not(Self.Base.VisibleMobs.Contains(OtherPlayer.Base.ClientId)) then
        begin
          Self.Base.VisibleMobs.Add(OtherPlayer.Base.ClientId);
        end;
      end
      else
      begin
        if (OtherPlayer.Base.VisibleMobs.Contains(Self.Base.ClientID)) then
        begin
          if not(Self.isTemp) then
          begin
            OtherPlayer.UnspawnMob(Self.Base.Mobid, Self.Base.SecondIndex);
            OtherPlayer.Base.VisibleMobs.Remove(Self.Base.ClientID);
            OtherPlayer.Base.RemoveTargetFromList(@Self.Base);
          end;
        end;

       { if((OtherPlayer.Base.PetClientID >= 9148) and
        (OtherPlayer.Base.PetClientID <= 10147))then
        begin
        if(Servers[OtherPlayer.ChannelIndex].PETS[OtherPlayer.Base.PetClientID].IntName > 0) then
          begin
            if(Servers[OtherPlayer.ChannelIndex].PETS[OtherPlayer.Base.PetClientID].Base.IsActive) then
            begin
            if not(Servers[OtherPlayer.ChannelIndex].PETS[OtherPlayer.Base.PetClientID].Base.ClientID = 0) then
              if(Servers[OtherPlayer.ChannelIndex].PETS[OtherPlayer.Base.PetClientID].PetType = X14) then
              begin
                if (Servers[OtherPlayer.ChannelIndex].PETS[OtherPlayer.Base.PetClientID].Base.VisibleMobs.Contains(
                  Self.Base.ClientID)) then
                begin
                  Servers[OtherPlayer.ChannelIndex].PETS[OtherPlayer.Base.PetClientID].Base.VisibleMobs.Remove(Self.Base.ClientID);
                end;
              end;
            end;
          end;
        end; }

        if (Self.Base.VisibleMobs.Contains(OtherPlayer.Base.ClientId)) then
        begin
          Self.Base.VisibleMobs.Remove(OtherPlayer.Base.ClientId);
        end;
      end;
    //end;
  except
    on E: Exception do
    begin
      //OtherPlayer.SocketClosed := True;
      Logger.Write('Error at mob UpdateSpawnToPlayers [' + E.Message + '] b.e: '
        + E.BaseException.Message + ' t:' + DateTimeToStr(Now), TlogType.Error);
      //Raise;
    end;
  end;
  // comentado aqui em PETS dia 16/03/2021
  {
    for i := Low(Servers[Self.Base.ChannelId].PETS)
    to High(Servers[Self.Base.ChannelId].PETS) do
    begin
    if not(Servers[Self.Base.ChannelId].PETS[i].Base.IsActive) then
    continue;
    if (Servers[Self.Base.ChannelId].PETS[i].Base.PlayerCharacter.LastPos.
    Distance(Self.CurrentPos) < DISTANCE_TO_WATCH) then
    begin
    if (Servers[Self.Base.ChannelId].PETS[i].Base.VisibleMobs.Contains
    (Self.Base.ClientId)) then
    continue;
    Servers[Self.Base.ChannelId].PETS[i].Base.VisibleMobs.Add
    (Self.Base.ClientId);
    end
    else
    begin
    if not(Servers[Self.Base.ChannelId].PETS[i].Base.VisibleMobs.Contains
    (Self.Base.ClientId)) then
    continue;
    Servers[Self.Base.ChannelId].PETS[i].Base.VisibleMobs.Remove
    (Self.Base.ClientId);
    end;
    end; }
end;
end.
