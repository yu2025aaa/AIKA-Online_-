unit UpdateThreads;

interface

uses
  Windows, Classes, ItemFunctions, SQL, System.AnsiStrings, System.SyncObjs,
  CastleSiege, Math;

{$REGION 'TUpdateHpMpThread'}

type
  TUpdateHpMpThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSec: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;

{$ENDREGION}
{$REGION 'TUpdateBuffsThread'}

type
  TUpdateBuffsThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSec: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;

{$ENDREGION}
{$REGION 'TUpdateMailsThread'}

type
  TUpdateMailsThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;
{$ENDREGION}
{$REGION 'TUpdateVisibleThread'}

type
  TUpdateVisibleThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;
{$ENDREGION}
{$REGION 'UpdateWorldAroundThread'}

type
  TUpdateWorldAroundThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;
{$ENDREGION}
{$REGION 'UpdateTimeThread'}

type
  TUpdateTimeThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSec: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;
{$ENDREGION}
{$REGION 'UpdateEventListenerThread'}

type
  TUpdateEventListenerThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;
{$ENDREGION}
{$REGION 'SkillRegenerateThread'}

type
  TSkillRegenerateThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSec: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;
{$ENDREGION}
{$REGION 'SkillDamageThread'}

type
  TSkillDamageThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSec: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;
{$ENDREGION}
{$REGION 'SaveInGame Thread'}

type
  TSaveInGame = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSec: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;

{$ENDREGION}
{$REGION 'Verify Item Expired Thread'}

type
  TTimeItensThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    procedure CheckItens();
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;
{$ENDREGION}
{$REGION 'Verify Item Quest Thread'}

type
  TQuestItemThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    procedure CheckInventory();
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;
{$ENDREGION}
{$REGION 'Pran Food System'}

type
  TPranFoodThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    procedure CheckFood();
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;
{$ENDREGION}
{$REGION 'Temples Thread'}

type
  TTemplesManagmentThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSec: TCriticalSection;
    procedure CheckGuards();
    procedure CheckStones();
    procedure CheckReliques();
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;
{$ENDREGION}
{$REGION 'Auction Offers System'}

type
  TAuctionOffersThread = class(TThread)
  private
    FDelay: Integer;
    FQuery: TQuery;

    procedure CheckOffers();

    function ReturnOffer(CharacterId: UInt64; AuctionId: UInt64): Boolean;
    function RegisterReturnMail(CharacterId: UInt64; AuctionId: UInt64;
      OUT MailIndex: UInt64): Boolean;

    function CloseOffer(AuctionId: UInt64): Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer);
  end;
{$ENDREGION}
{$REGION 'Castle Siege'}
type
    TSiegeStatus = (None = 0, PreStart, Running, OrbsHolded, Sealing, Finished);

 type
  TCastleSiegeThread = class(TThread)
  private
    FDelay: Integer;
    FChannelID: BYTE;

    SiegeStatus: TSiegeStatus;

    procedure CheckCastleOrbs(CastleSiege: PCastleSiege);
    procedure RemoveOrbHolder(CastleSiege: PCastleSiege; OrbIndex: BYTE);
    procedure CountOrbsHolding(CastleSiege: PCastleSiege);
    procedure CheckMarshallSeal(CastleSiege: PCastleSiege);

    procedure RemoveSealHolder(CastleSiege: PCastleSiege);

    procedure UpdateSiegeStatus(CastleSiege: PCastleSiege);
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;

{$ENDREGION}

implementation

uses
  GlobalDefs, Log, Player, MiscData, PlayerData, Util, BaseMob,
  EntityMail, DateUtils, SysUtils, ServerSocket, Packets, TokenSocket,
    IdHTTPServer, IdCustomHTTPServer, IdServerIOHandler, IdSSL, IdSSLOpenSSL,
    GuildData, Functions;

{$REGION 'TUpdateHpMpThread'}

constructor TUpdateHpMpThread.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;

  fCritSec := TCriticalSection.Create;

  inherited Create(FALSE);
end;

procedure TUpdateHpMpThread.Execute;
var
  hpMp: DWORD;
  dirtyHpMp: Boolean;
  i: WORD;
  Player: PPlayer;
begin
  while (Servers[ChannelId].IsActive) do
  begin
    fCritSec.Enter;
    for i := Low(Servers[ChannelId].Players)
      to High(Servers[ChannelId].Players) do
    begin
      try
        dirtyHpMp := FALSE;

        Player := @Servers[ChannelId].Players[i];

        if ((Player.Status < TPlayerStatus.PLAYING) OR (Player.Base.IsDead) or (Servers[ChannelId].Players[i].Unlogging))
        then
          Continue;

        if(Player.SocketClosed) then
          Continue;

        if (Player.Character.Base.CurrentScore.CurMP < Player.Base.GetCurrentMP)
        then
        begin
          dirtyHpMp := True;
          hpMp := Player.Character.Base.CurrentScore.CurMP +
            Player.Base.GetRegenerationMP;
          hpMp := IFThen(hpMp > Player.Base.GetCurrentMP,
            Player.Base.GetCurrentMP, hpMp);
          Player.Character.Base.CurrentScore.CurMP := hpMp;
        end;

        if (Player.Character.Base.CurrentScore.CurHP < Player.Base.GetCurrentHP)
        then
        begin
          if (SecondsBetween(Now, Player.Base.LastReceivedAttack) <= 4) then
            Continue;
          dirtyHpMp := True;
          hpMp := Player.Character.Base.CurrentScore.CurHP +
            Player.Base.GetRegenerationHP;
          hpMp := IFThen(hpMp > Player.Base.GetCurrentHP,
            Player.Base.GetCurrentHP, hpMp);
          Player.Character.Base.CurrentScore.CurHP := hpMp;
        end;

        if (dirtyHpMp) then
        begin
          Player.Base.SendCurrentHPMP();
        end;
      except
        Continue;
      end;
    end;

    fCritSec.Release;
    Sleep(FDelay);
  end;
end;

{$ENDREGION}
{$REGION 'TUpdateBuffsThread'}

constructor TUpdateBuffsThread.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;

  fCritSec := TCriticalSection.Create;

  inherited Create(FALSE);
end;

procedure TUpdateBuffsThread.Execute;
var
  i: Integer;
  UpdatedBuffs: Integer;
begin
  while (Servers[ChannelId].IsActive) do
  begin
    fCritSec.Enter;
    for i := Low(Servers[ChannelId].Players)
      to High(Servers[ChannelId].Players) do
    begin
      try
        if ((Servers[ChannelId].Players[i].Status < TPlayerStatus.PLAYING) or (Servers[ChannelId].Players[i].Unlogging)) then
          Continue;

        if(Servers[ChannelId].Players[i].SocketClosed) then
          Continue;

        {if(Servers[ChannelId].Players[i].Base.BuffExistsByIndex(91)) then
        begin
          Servers[ChannelId].Players[i].Base.RemoveBuffByIndex(91);
        end;

        if(Servers[ChannelId].Players[i].Base.BuffExistsByIndex(335)) then
        begin
          Servers[ChannelId].Players[i].Base.RemoveBuffByIndex(335);
        end; }

        UpdatedBuffs := Servers[ChannelId].Players[i].Base.RefreshBuffs;

        if (UpdatedBuffs = 0) then
          Continue;

        // Servers[ChannelId].Players[i].Base.SendRefreshBuffs;

        //Sleep(100);
      except
        Continue;
      end;
    end;

    fCritSec.Release;
    Sleep(FDelay);
  end;
end;

{$ENDREGION}
{$REGION 'TUpdateMailsThread'}

constructor TUpdateMailsThread.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;

  inherited Create(FALSE);
end;

procedure TUpdateMailsThread.Execute;
var
  i: Integer;
  CurrentServer: PServerSocket;
begin
  CurrentServer := @Servers[Self.ChannelId];

  while (CurrentServer^.IsActive) do
  begin
    for i := Low(CurrentServer^.Players) to High(CurrentServer^.Players) do
    begin
      try
        if (CurrentServer^.Players[i].Status < TPlayerStatus.PLAYING) then
          Continue;

        if(CurrentServer^.Players[i].SocketClosed) then
            Continue;

        TEntityMail.SendUnreadMails(CurrentServer^.Players[i]);

        { TMailFunctions.RemoveExpiredMails
          (string(Servers[ChannelId].Players[i].Character.Base.Name)); }

        Sleep(10);
      except
        Continue;
      end;
    end;
    Sleep(FDelay);
  end;
end;

{$ENDREGION}
{$REGION 'TUpdateVisibleThread'}

constructor TUpdateVisibleThread.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;

  inherited Create(FALSE);
end;

procedure TUpdateVisibleThread.Execute;
var
  i: Integer;
begin
  while (Servers[ChannelId].IsActive) do
  begin
    for i := Low(Servers[ChannelId].Players)
      to High(Servers[ChannelId].Players) do
    begin
      try
        if (Servers[ChannelId].Players[i].Status < TPlayerStatus.PLAYING) then
          Continue;

        Servers[ChannelId].Players[i].Base.UpdateVisibleList;
      except
        Continue;
      end;
    end;
    Sleep(FDelay);
  end;
end;

{$ENDREGION}
{$REGION 'UpdateWorldAroundThread'}

constructor TUpdateWorldAroundThread.Create(SleepTime: Integer;
  ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;

  inherited Create(FALSE);
end;

procedure TUpdateWorldAroundThread.Execute;
var
  i, j: Integer;
begin
  while (Servers[ChannelId].IsActive) do
  begin
    for i := Low(Servers[ChannelId].Players)
      to High(Servers[ChannelId].Players) do
    begin
      if (Servers[ChannelId].Players[i].Status < TPlayerStatus.PLAYING) then
        Continue;

      for j in Servers[ChannelId].Players[i].Base.VisibleMobs do
      begin
        Servers[ChannelId].Players[i].Base.removevisible
          (Servers[ChannelId].Players[j].Base);
      end;

      { Servers[ChannelId].Players[i].Base.ForEachInRange
        (Servers[ChannelId].Players[i].Character.LastPos, DISTANCE_TO_WATCH,
        procedure(p: TPosition; m: TBaseMob)
        begin
        if not(Servers[ChannelId].Players[i].Base.VisibleMobs.Contains
        (m.ClientId)) then
        begin
        if not(Servers[ChannelId].Players[i].Base.ClientId = m.ClientId)
        then
        Servers[ChannelId].Players[i].Base.addvisible(m);
        end;
        end, Self.ChannelId); }

    end;
    Sleep(FDelay);
  end;
end;
{$ENDREGION}
{ TUpdateTimeThread }
{$REGION 'UpdateTimeThread'}

constructor TUpdateTimeThread.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  fCritSec := TCriticalSection.Create;


  inherited Create(FALSE);
end;

procedure TUpdateTimeThread.Execute;
var
  i: Integer;
  xPlayer: PPlayer;
  ItemSLot: Byte;

begin
  while (Servers[ChannelId].IsActive) do
  begin
    fCritSec.Enter;
    for i := Low(Servers[ChannelId].Players)
      to High(Servers[ChannelId].Players) do
    begin
      try
        if(ServerHasClosed) then
          Continue;

        if ((Servers[ChannelId].Players[i].Status < TPlayerStatus.PLAYING) or (Servers[ChannelId].Players[i].Unlogging)) then
          Continue;

        xPlayer := @Servers[ChannelId].Players[i];

        if(xPlayer.SocketClosed) then
          Continue;

        xPlayer.Character.LoggedTime := MinutesBetween(Now, xPlayer.Base.TimeForGoldTime);

        if (xPlayer.Character.LoggedTime >= 10) then
        begin
          TItemFunctions.PutItem(xPlayer^, 11286, 1);

          xPlayer.Base.TimeForGoldTime := Now;
        end;

        ItemSLot := TItemFunctions.GetItemSlotByItemType(xPlayer^, 715, INV_TYPE);
        if(ItemSlot <> 255) then
        begin
          if not(xPLayer.Base.Character.Inventory[ItemSLot].Time = 0) then
          begin
            if not(xPlayer.Base.BuffExistsByID(ItemList[xPLayer.Base.Character.Inventory[ItemSLot].Index].UseEffect)) then
            begin
              if not(SkillData[ItemList[xPLayer.Base.Character.Inventory[ItemSLot].Index].UseEffect].Index = 163) then
                xPlayer.Base.AddBuff(ItemList[xPLayer.Base.Character.Inventory[ItemSLot].Index].UseEffect);
            end;
          end;
        end
        else
        begin
          if (xPlayer.Base.BuffExistsByID(ItemList[xPLayer.Base.Character.Inventory[ItemSLot].Index].UseEffect)) then
          begin
            xPlayer.Base.RemoveBuff(ItemList[xPLayer.Base.Character.Inventory[ItemSLot].Index].UseEffect);
          end;
        end;

        ItemSLot := TItemFunctions.GetItemSlotByItemType(xPlayer^, 716, INV_TYPE);
        if(ItemSlot <> 255) then
        begin
          if not(xPLayer.Base.Character.Inventory[ItemSLot].Time = 0) then
          begin
            if not(xPlayer.Base.BuffExistsByID(ItemList[xPLayer.Base.Character.Inventory[ItemSLot].Index].UseEffect)) then
            begin
              if not(SkillData[ItemList[xPLayer.Base.Character.Inventory[ItemSLot].Index].UseEffect].Index = 163) then
                xPlayer.Base.AddBuff(ItemList[xPLayer.Base.Character.Inventory[ItemSLot].Index].UseEffect);
            end;
          end;
        end
        else
        begin
          if (xPlayer.Base.BuffExistsByID(ItemList[xPLayer.Base.Character.Inventory[ItemSLot].Index].UseEffect)) then
          begin
            xPlayer.Base.RemoveBuff(ItemList[xPLayer.Base.Character.Inventory[ItemSLot].Index].UseEffect);
          end;
        end;

        if (xPlayer.Base.IsDead) and (xPlayer.Base.Character.CurrentScore.CurHP > 0) then
        begin
          xPlayer.Base.Character.CurrentScore.CurHP := 0;
          xPlayer.Base.SendEffect($0);
        end;

        if (SecondsBetween(Now, xPlayer.LastTimeSaved) >= 10) then
        begin
          if (xPlayer.Status >= Playing) then
          begin
            try
              if (not(xPlayer.SocketClosed) and (xPlayer.Base.ClientID > 0)) then
              begin
                if not(xServerClosed) then
                begin
                  xPlayer.SaveInGame(xPlayer.SelectedCharacterIndex);
                  xPlayer.LastTimeSaved := Now;
                end;
              end;
            except
              begin
                Continue;
              end;
            end;
            try
              if (not(xPlayer.SocketClosed) and (xPlayer.Base.ClientID > 0)) then
              begin
                if not(xServerClosed) then
                begin
                  TEntityMail.SendUnreadMails(xPlayer^);
                end;
              end;
            except
              begin
                Continue;
              end;
            end;
          end;
        end;
      except
        Continue;
      end;
    end;


    fCritSec.Release;
    Sleep(FDelay);
  end;
end;
{$ENDREGION}
{$REGION 'UpdateTimeThread'}

constructor TUpdateEventListenerThread.Create(SleepTime: Integer;
  ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;

  inherited Create(FALSE);
end;

procedure TUpdateEventListenerThread.Execute;
var
  i: Integer;
  Player: PPlayer;

  j, k: Integer;
begin
  while (Servers[ChannelId].IsActive) do
  begin

    for i := Low(Servers[ChannelId].Players)
      to High(Servers[ChannelId].Players) do
    begin
      try
        if ((Servers[ChannelId].Players[i].Status < TPlayerStatus.PLAYING) or (Servers[ChannelId].Players[i].Unlogging)) then
          Continue;

        if(Servers[ChannelId].Players[i].SocketClosed) then
          Continue;

        Player := @Servers[ChannelId].Players[i];

        if not(Player.Base.EventListener) then
          Continue;

        case Player.Base.EventAction of
          1: // lamina da tp
            begin
              Player.Laps := SkillData[Player.Base.LaminaID].Duration;

              if (Player.Cycles > Player.Laps) then
              begin
                Player.Base.EventListener := FALSE;
                Player.Base.EventAction := 0;
                Player.Base.LaminaPoints := 0;
                Player.Base.LaminaID := 0;
                Player.Laps := 0;
                Player.Cycles := 0;
              end
              else
              begin
                try
                  Player.Base.AreaSkill(Player.Base.LaminaPoints, 0, @Player.Base,
                    Player.Base.PlayerCharacter.LastPos,
                    @SkillData[Player.Base.LaminaID]);
                finally

                end;

                Inc(Player.Cycles);
              end;
            end;
        end;
      except
        Continue;
      end;
    end;

    Sleep(FDelay);
  end;
end;
{$ENDREGION}
{$REGION 'TSkillRegenerateThread'}
{ TSkillRegenerateThread }

constructor TSkillRegenerateThread.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;

  fCritSec := TCriticalSection.Create;

  inherited Create(FALSE);
end;

procedure TSkillRegenerateThread.Execute;
var
  i: Integer;
  Player: PPlayer;
begin
  while (Servers[ChannelId].IsActive) do
  begin
    fCritSec.Enter;
    for i := Low(Servers[ChannelId].Players)
      to High(Servers[ChannelId].Players) do
    begin
      try
        if(Servers[ChannelId].Players[i].Base.HPRAction = 0) then
          Continue;

        if (Servers[ChannelId].Players[i].Status < TPlayerStatus.PLAYING) then
          Continue;

        if (Servers[ChannelId].Players[i].Unlogging) then
          Continue;

        if(Servers[ChannelId].Players[i].SocketClosed) then
          Continue;

        Player := @Servers[ChannelId].Players[i];

        if not(Player.Base.HPRListener) then
          Continue;

        case Player.Base.HPRAction of
          1: // revitalizar wr
            begin
              Player.HPRLaps := SkillData[Player.Base.HPRSkillID].Duration;

              if (Player.HPRCycles > Player.HPRLaps) then
              begin
                Player.Base.HPRListener := FALSE;
                Player.Base.HPRAction := 0;
                Player.Base.HPRSkillID := 0;
                Player.Base.HPRSkillEtc1 := 0;
                Player.HPRLaps := 0;
                Player.HPRCycles := 0;
              end
              else
              begin
                if not(Player.Base.IsDead) then
                begin
                  Player.Base.AddHP
                    (((Player.Base.Character.CurrentScore.MaxHp div 100) *
                    1), True);
                end;

                Inc(Player.HPRCycles);
              end;
            end;

          2: // aegis tp
            begin
              Player.HPRLaps := SkillData[Player.Base.HPRSkillID].Duration;

              if (Player.HPRCycles > Player.HPRLaps) then
              begin
                Player.Base.HPRListener := FALSE;
                Player.Base.HPRAction := 0;
                Player.Base.HPRSkillID := 0;
                Player.Base.HPRSkillEtc1 := 0;
                Player.HPRLaps := 0;
                Player.HPRCycles := 0;
              end
              else
              begin
                if not(Player.Base.IsDead) then
                begin
                  if(SkillData[Player.Base.HPRSkillID].Index = 125) then
                  begin
                    if((Player.Base.GetMobAbility(EF_ANTICURE) > 0) and
                      (Player.Base.NegarCuraCount = 0)) then
                    begin
                      Player.Base.NegarCuraCount := 3;

                      Player.Base.RemoveHP(((Player.Base.HPRSkillEtc1 div 100) * Player.Base.GetMobAbility(EF_ANTICURE)), True, True);
                      Player.Base.LastReceivedAttack := Now;
                      Player.Base.NegarCuraCount := Player.Base.NegarCuraCount -1;
                    end
                    else if((Player.Base.GetMobAbility(EF_ANTICURE) > 0) and
                      (Player.Base.NegarCuraCount > 0)) then
                    begin
                      Player.Base.RemoveHP(((Player.Base.HPRSkillEtc1 div 100) * Player.Base.GetMobAbility(EF_ANTICURE)), True, True);
                      Player.Base.LastReceivedAttack := Now;
                      Player.Base.NegarCuraCount := Player.Base.NegarCuraCount -1;

                      if(Player.Base.NegarCuraCount = 0) then
                      begin
                        Player.Base.RemoveBuffByIndex(88);
                      end;
                    end
                    else
                      Player.Base.AddHP(Player.Base.HPRSkillEtc1, True);
                  end
                  else
                  begin
                    Player.Base.AddHP(Player.Base.HPRSkillEtc1, True);
                  end;

                  {if(SkillData[Player.Base.HPRSkillID].Index = 125) then
                  begin
                    Player.SendClientMessage('Seu HP foi recuperado em ' +
                      Player.Base.HPRSkillEtc1.ToString + ' pontos.');
                  end;}
                end;

                Inc(Player.HPRCycles);
              end;
            end;

          3: // Libertação de mana CL
            begin
              Player.HPRLaps := SkillData[Player.Base.HPRSkillID].Duration;

              if (Player.HPRCycles > Player.HPRLaps) then
              begin
                Player.Base.HPRListener := FALSE;
                Player.Base.HPRAction := 0;
                Player.Base.HPRSkillID := 0;
                Player.Base.HPRSkillEtc1 := 0;
                Player.HPRLaps := 0;
                Player.HPRCycles := 0;
              end
              else
              begin
                if not(Player.Base.IsDead) then
                begin
                  Player.Base.AddMP(Player.Base.HPRSkillEtc1, True);
                end;

                Inc(Player.HPRCycles);
              end;
            end;

          4: // glora de execelsis cl
            begin
              Player.HPRLaps := 10;

              if (Player.HPRCycles > Player.HPRLaps) then
              begin
                Player.Base.HPRListener := FALSE;
                Player.Base.HPRAction := 0;
                Player.Base.HPRSkillID := 0;
                Player.Base.HPRSkillEtc1 := 0;
                Player.HPRLaps := 0;
                Player.HPRCycles := 0;
              end
              else
              begin
                if not(Player.Base.IsDead) then
                begin
                  Player.Base.AddHP(Player.Base.HPRSkillEtc1, True);
                end;

                Inc(Player.HPRCycles);
              end;
            end;
        end;
      except
        begin
          Continue;
        end;
      end;
    end;

    fCritSec.Leave;
    Sleep(1000);
  end;

end;

{$ENDREGION}
{$REGION 'TSkillDamageThread'}
{ TSkillDamageThread }

constructor TSkillDamageThread.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;

  fCritSec := TCriticalSection.Create;

  inherited Create(FALSE);
end;

procedure TSkillDamageThread.Execute;
var
  i: Integer;
  Player, Target: PPlayer;
begin
  while (Servers[ChannelId].IsActive) do
  begin
    fCritSec.Enter;
    try
      for i := Low(Servers[ChannelId].Players)
        to High(Servers[ChannelId].Players) do
      begin
        if(Servers[ChannelId].Players[i].Base.SKDAction = 0) then
          Continue;

        if ((Servers[ChannelId].Players[i].Status < TPlayerStatus.PLAYING) or (Servers[ChannelId].Players[i].Unlogging)) then
          Continue;

        if (Servers[ChannelId].Players[i].Base.IsDead) then
          Continue;

        Player := @Servers[ChannelId].Players[i];

        if(Player.SocketClosed) then
          Continue;

        if not(Player.Base.SKDListener) then
          Continue;

        if(Player.Base.SKDAction = 0) then
          Continue;

        if((Player.Base.ClientID = 0) or (Player.Base.ClientID > MAX_CONNECTIONS)) then
          Continue;
        if((Player.Base.SKDSkillID = 0) or (Player.Base.SKDSkillID > 11998)) then
          Continue;

        case Player.Base.SKDAction of
          1: // estocada wr
            begin
              Player.SKDLaps := SkillData[Player.Base.SKDSkillID].Duration;

              if (Player.SKDCycles > Player.SKDLaps) then
              begin
                Player.Base.SKDListener := FALSE;
                Player.Base.SKDAction := 0;
                Player.Base.SKDSkillID := 0;
                Player.Base.SKDSkillEtc1 := 0;
                Player.SKDLaps := 0;
                Player.SKDCycles := 0;
                Player.Base.SKDIsMob := False;
                Player.Base.SDKMobID := 0;
                Player.Base.SDKSecondIndex := 0;
                continue;
              end
              else
              begin
                if(Player.Base.SKDIsMob) then
                begin
                  if(Player.Base.SDKSecondIndex = 0) then
                    Continue;

                  if not(Servers[Player.ChannelIndex].MOBS.TMobS[Player.Base.SDKMobID].MobsP[Player.Base.SDKSecondIndex].Base.IsDead) then
                    Servers[Player.ChannelIndex].MOBS.TMobS[Player.Base.SDKMobID].MobsP[Player.Base.SDKSecondIndex]
                    .Base.RemoveHP(Player.Base.SKDSkillEtc1, True, True);

                  Inc(Player.SKDCycles);
                  continue;
                end
                else
                begin
                  if(Player.Base.SKDTarget = 0) then
                    Continue;

                  Target := @Servers[ChannelId].Players[Player.Base.SKDTarget];

                  if(Target.SocketClosed) then
                    Continue;

                  if(Target.Status >= Playing) then
                  begin
                    if not(Target.Base.IsDead) then
                    begin
                      Target.Base.RemoveHP(Player.Base.SKDSkillEtc1, True, True);
                      Target.Base.LastReceivedAttack := Now;
                    end;
                  end;

                  Inc(Player.SKDCycles);
                  continue;
                end;
              end;
            end;

          2:
            begin
              Player.SKDLaps := SkillData[Player.Base.SKDSkillID].Duration;

              if (Player.SKDCycles > Player.SKDLaps) then
              begin
                Player.Base.SKDListener := FALSE;
                Player.Base.SKDAction := 0;
                Player.Base.SKDSkillID := 0;
                Player.Base.SKDSkillEtc1 := 0;
                Player.SKDLaps := 0;
                Player.SKDCycles := 0;
                continue;
              end
              else
              begin
                if(Player.Base.SKDIsMob) then
                begin
                  if(Player.Base.SDKSecondIndex = 0) then
                    Continue;

                  if not(Servers[Player.ChannelIndex].MOBS.TMobS[Player.Base.SDKMobID].MobsP[Player.Base.SDKSecondIndex].Base.IsDead) then
                    Servers[Player.ChannelIndex].MOBS.TMobS[Player.Base.SDKMobID].MobsP[Player.Base.SDKSecondIndex]
                    .Base.RemoveHP(Player.Base.SKDSkillEtc1, True, True);

                  Inc(Player.SKDCycles);
                  continue;
                end
                else
                begin
                  if(Player.Base.SKDTarget = 0) then
                    Continue;

                  Target := @Servers[ChannelId].Players[Player.Base.SKDTarget];

                  if(Target.SocketClosed) then
                    Continue;

                  if(Target.Status >= Playing) then
                  begin
                    if not(Target.Base.IsDead) then
                    begin
                      Target.Base.RemoveHP(Player.Base.SKDSkillEtc1, True, True);
                      Target.Base.LastReceivedAttack := Now;
                    end;
                  end;

                  Inc(Player.SKDCycles);
                  continue;
                end;
              end;
            end;
        end;
      end;
    except
      on E: Exception do
      begin
          Logger.Write('UpdateThreads: TSkillDamageThread.Execute error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
          fCritSec.Leave;
          Continue;
      end;
    end;
    fCritSec.Leave;
    Sleep(FDelay);
  end;

end;

{$ENDREGION}
{$REGION 'SaveInGame Thread'}

constructor TSaveInGame.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;

  fCritSec := TCriticalSection.Create;

  inherited Create(FALSE);
end;

procedure TSaveInGame.Execute;
var
  i: Integer;
begin
  {while (Servers[Self.ChannelId].IsActive) do
  begin
    fCritSec.Enter;

    for i := 1 to MAX_CONNECTIONS do
    begin
      try
        if not(Servers[Self.ChannelId].Players[i].Base.IsActive) then
        begin
          Continue;
        end;

        if (Servers[Self.ChannelId].Players[i].Status = TPlayerStatus.CharList)
        then
        begin
          Servers[Self.ChannelId].Players[i].SaveCharOnCharRoom
            (Servers[Self.ChannelId].Players[i].SelectedCharacterIndex);
        end
        else if (Servers[Self.ChannelId].Players[i].Status >= PLAYING) then
        begin
          Servers[Self.ChannelId].Players[i].SaveInGame
            (Servers[Self.ChannelId].Players[i].SelectedCharacterIndex);
          // Servers[Self.ChannelId].Players[i].SaveCharOnCharRoom
          // (Servers[Self.ChannelId].Players[i].SelectedCharacterIndex);
        end;

        //Sleep(10);
      except
        Continue;
      end;
    end;
    fCritSec.Leave;

    Sleep(FDelay);
  end; }
end;

{$ENDREGION}
{$REGION 'Verify Item Expired Thread'}

procedure TTimeItensThread.CheckItens;
var
  i, j: WORD;
  ResultOf: Integer;
  ItemName: String;
begin
  for i := Low(Servers[Self.ChannelId].Players)
    to High(Servers[Self.ChannelId].Players) do
  begin
    try
      if (Servers[Self.ChannelId].Players[i].Status < PLAYING) then
        Continue;

      if(Servers[ChannelId].Players[i].SocketClosed) then
        Continue;

      for j := 0 to 63 do
      begin
        if(Servers[Self.ChannelId].Players[i]
          .Base.Character.Inventory[j].Index = 0) {or (Servers[Self.ChannelId].Players[i]
          .Base.Character.Inventory[j].Time = 0)} then
          Continue;

        if ((ItemList[Servers[Self.ChannelId].Players[i]
          .Base.Character.Inventory[j].Index].Expires) and
          not(Servers[Self.ChannelId].Players[i].Base.Character.Inventory[j]
          .IsSealed)) then
        begin
          ResultOf := CompareDateTime(Now, Servers[Self.ChannelId].Players[i]
            .Base.Character.Inventory[j].ExpireDate);

          if (ResultOf = 1) then
          begin
            ItemName :=
              String(ItemList[Servers[Self.ChannelId].Players[i]
              .Base.Character.Inventory[j].Index].Name);

            if(ItemList[Servers[Self.ChannelId].Players[i]
              .Base.Character.Inventory[j].Index].ItemType = 716) then
            begin //remover buff de experiencia / quest double
              Servers[Self.ChannelId].Players[i]
              .Base.RemoveBuff(ItemList[Servers[Self.ChannelId].Players[i]
              .Base.Character.Inventory[j].Index].UseEffect);
            end;

            if(TItemFunctions.GetItemEquipSlot(Servers[Self.ChannelId].Players[i]
                .Base.Character.Inventory[j].Index) = 9) then
             begin  //montaria não deleta, só expira mesmo
               Servers[Self.ChannelId].Players[i]
                .Base.Character.Inventory[j].Time := $FFFF;
               //Servers[Self.ChannelId].Players[i]
                //.Base.Character.Inventory[j].Max := $FF;
               Servers[Self.ChannelId].Players[i]
                .Base.SendRefreshItemSlot(INV_TYPE, j,Servers[Self.ChannelId].Players[i]
                .Base.Character.Inventory[j], False);
               Servers[Self.ChannelId].Players[i].SendClientMessage
                ('O item [' + AnsiString(ItemName) + '] expirou.');
              { Servers[Self.ChannelId].Players[i].Base.SetEquipEffect(
                Servers[Self.ChannelId].Players[i]
                .Base.Character.Inventory[j], DESEQUIPING_TYPE, True, False);
               Servers[Self.ChannelId].Players[i].Base.GetCurrentScore;
               Servers[Self.ChannelId].Players[i].Base.SendRefreshPoint;
               Servers[Self.ChannelId].Players[i].Base.SendStatus;
               Servers[Self.ChannelId].Players[i].Base.SendCurrentHPMP(); }
             end
             else
             if(ItemList[Servers[Self.ChannelId].Players[i]
              .Base.Character.Inventory[j].Index].Classe >= 100) and
              (ItemList[Servers[Self.ChannelId].Players[i]
              .Base.Character.Inventory[j].Index].Classe <= 104) then
             begin //roupa de pran não deleta, só expira mesmo
               Servers[Self.ChannelId].Players[i]
                .Base.Character.Inventory[j].Min := $FF;
               Servers[Self.ChannelId].Players[i]
                .Base.Character.Inventory[j].Max := $FF;
               Servers[Self.ChannelId].Players[i]
                .Base.SendRefreshItemSlot(INV_TYPE, j,Servers[Self.ChannelId].Players[i]
                .Base.Character.Inventory[j], False);
               Servers[Self.ChannelId].Players[i].SendClientMessage
                ('O item [' + AnsiString(ItemName) + '] expirou.');
               {Servers[Self.ChannelId].Players[i].Base.SetEquipEffect(
                Servers[Self.ChannelId].Players[i]
                .Base.Character.Inventory[j], DESEQUIPING_TYPE, True, False);
               Servers[Self.ChannelId].Players[i].Base.GetCurrentScore;
               Servers[Self.ChannelId].Players[i].Base.SendRefreshPoint;
               Servers[Self.ChannelId].Players[i].Base.SendStatus;
               Servers[Self.ChannelId].Players[i].Base.SendCurrentHPMP(); }
             end
             else
             begin
              TItemFunctions.RemoveItem(Servers[Self.ChannelId].Players[i],
                INV_TYPE, j);
              Servers[Self.ChannelId].Players[i].SendClientMessage
                ('O item [' + AnsiString(ItemName) + '] expirou.');
             end;
          end;
        end;
      end;

      for j := 0 to 15 do
      begin
        if(Servers[Self.ChannelId].Players[i]
          .Base.Character.Equip[j].Index = 0) or (Servers[Self.ChannelId].Players[i]
          .Base.Character.Equip[j].Time = 0) then
          Continue;

        //if(j = 9) then
          //Continue;

        if ((ItemList[Servers[Self.ChannelId].Players[i].Base.Character.Equip[j]
          .Index].Expires) and not(Servers[Self.ChannelId].Players[i]
          .Base.Character.Equip[j].IsSealed)) then
        begin
          ResultOf := CompareDateTime(Now, Servers[Self.ChannelId].Players[i]
            .Base.Character.Equip[j].ExpireDate);

          if (ResultOf = 1) then
          begin
            ItemName :=
              String(ItemList[Servers[Self.ChannelId].Players[i]
              .Base.Character.Equip[j].Index].Name);

            if(TItemFunctions.GetItemEquipSlot(Servers[Self.ChannelId].Players[i]
                .Base.Character.Equip[j].Index) = 9) then
             begin  //montaria não deleta, só expira mesmo
               Servers[Self.ChannelId].Players[i]
                .Base.Character.Equip[j].Time := $FFFF;
               //Servers[Self.ChannelId].Players[i]
                //.Base.Character.Equip[j].Max := $FF;
               Servers[Self.ChannelId].Players[i]
                .Base.SendRefreshItemSlot(Equip_TYPE, j, Servers[Self.ChannelId].Players[i]
                .Base.Character.Equip[j], False);
               Servers[Self.ChannelId].Players[i].SendClientMessage
                ('O item [' + AnsiString(ItemName) + '] expirou.');
                Servers[Self.ChannelId].Players[i].Base.SetEquipEffect(
                Servers[Self.ChannelId].Players[i]
                .Base.Character.Equip[j], DESEQUIPING_TYPE, True, False);
               Servers[Self.ChannelId].Players[i].Base.GetCurrentScore;
               Servers[Self.ChannelId].Players[i].Base.SendRefreshPoint;
               Servers[Self.ChannelId].Players[i].Base.SendStatus;
               Servers[Self.ChannelId].Players[i].Base.SendCurrentHPMP();
             end
             else
             if(ItemList[Servers[Self.ChannelId].Players[i]
              .Base.Character.Equip[j].Index].Classe >= 100) and
              (ItemList[Servers[Self.ChannelId].Players[i]
              .Base.Character.Equip[j].Index].Classe <= 104) then
             begin //roupa de pran não deleta, só expira mesmo
               Servers[Self.ChannelId].Players[i]
                .Base.Character.Equip[j].Min := $FF;
               Servers[Self.ChannelId].Players[i]
                .Base.Character.Equip[j].Max := $FF;
               Servers[Self.ChannelId].Players[i]
                .Base.SendRefreshItemSlot(Equip_TYPE, j,Servers[Self.ChannelId].Players[i]
                .Base.Character.Equip[j], False);
               Servers[Self.ChannelId].Players[i].SendClientMessage
                ('O item [' + AnsiString(ItemName) + '] expirou.');
                Servers[Self.ChannelId].Players[i].Base.SetEquipEffect(
                Servers[Self.ChannelId].Players[i]
                .Base.Character.Equip[j], DESEQUIPING_TYPE, True, False);
               Servers[Self.ChannelId].Players[i].Base.GetCurrentScore;
               Servers[Self.ChannelId].Players[i].Base.SendRefreshPoint;
               Servers[Self.ChannelId].Players[i].Base.SendStatus;
               Servers[Self.ChannelId].Players[i].Base.SendCurrentHPMP();
             end
             else
             begin
              TItemFunctions.RemoveItem(Servers[Self.ChannelId].Players[i],
                EQUIP_TYPE, j);
              Servers[Self.ChannelId].Players[i].SendClientMessage
                ('O item [' + AnsiString(ItemName) + '] expirou.');
             end;
          end;
        end;
      end;

      for j := 0 to 83 do
      begin
        if(Servers[Self.ChannelId].Players[i].Account.
          Header.Storage.Itens[j].Index = 0) {or (Servers[Self.ChannelId].Players[i].Account.
          Header.Storage.Itens[j].Time = 0)} then
          Continue;

        //if(ItemList[Servers[Self.ChannelId].Players[i].Account.Header.Storage.Itens[j].Index].Classe >= 100) and
         // (ItemList[Servers[Self.ChannelId].Players[i].Account.Header.Storage.Itens[j].Index].Classe <= 104) then
         // Continue;

         if ((ItemList[Servers[Self.ChannelId].Players[i].Account.Header.Storage.Itens[j]
          .Index].Expires) and not(Servers[Self.ChannelId].Players[i].Account.Header.Storage.Itens[j].IsSealed)) then
        begin
          ResultOf := CompareDateTime(Now, Servers[Self.ChannelId].Players[i].Account.Header.Storage.Itens[j].ExpireDate);

          if (ResultOf = 1) then
          begin
            ItemName :=
              String(ItemList[Servers[Self.ChannelId].Players[i].Account.Header.Storage.Itens[j].Index].Name);

            if(TItemFunctions.GetItemEquipSlot(Servers[Self.ChannelId].Players[i].Account.
          Header.Storage.Itens[j].Index) = 9) then
             begin  //montaria não deleta, só expira mesmo
               Servers[Self.ChannelId].Players[i].Account.
                Header.Storage.Itens[j].Time := $FFFF;
               //Servers[Self.ChannelId].Players[i].Account.
                //Header.Storage.Itens[j].Max := $FF;
               Servers[Self.ChannelId].Players[i]
                .Base.SendRefreshItemSlot(STORAGE_TYPE, j,Servers[Self.ChannelId].Players[i].Account.
          Header.Storage.Itens[j], False);
               Servers[Self.ChannelId].Players[i].SendClientMessage
                ('O item [' + AnsiString(ItemName) + '] expirou.');

             end
             else
             if(ItemList[Servers[Self.ChannelId].Players[i].Account.
          Header.Storage.Itens[j].Index].Classe >= 100) and
              (ItemList[Servers[Self.ChannelId].Players[i].Account.
          Header.Storage.Itens[j].Index].Classe <= 104) then
             begin //roupa de pran não deleta, só expira mesmo
               Servers[Self.ChannelId].Players[i].Account.
                Header.Storage.Itens[j].Min := $FF;
               Servers[Self.ChannelId].Players[i].Account.
                Header.Storage.Itens[j].Max := $FF;
               Servers[Self.ChannelId].Players[i]
                .Base.SendRefreshItemSlot(STORAGE_TYPE, j,Servers[Self.ChannelId].Players[i].Account.
          Header.Storage.Itens[j], False);
               Servers[Self.ChannelId].Players[i].SendClientMessage
                ('O item [' + AnsiString(ItemName) + '] expirou.');
             end
             else
             begin
            TItemFunctions.RemoveItem(Servers[Self.ChannelId].Players[i],
              STORAGE_TYPE, j);
            Servers[Self.ChannelId].Players[i].SendClientMessage
              ('O item [' + AnsiString(ItemName) + '] expirou.');
             end;
          end;
        end;
      end;

      case Servers[Self.ChannelId].Players[i].SpawnedPran of
        0:
          begin
            for j := 1 to 5 do
            begin
              if(Servers[Self.ChannelId].Players[i].Account.
                Header.Pran1.Equip[j].Index = 0) {or (Servers[Self.ChannelId].Players[i].Account.
                Header.Pran1.Equip[j].Time = 0)} then
                Continue;

              if ((ItemList[Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Equip[j]
                .Index].Expires) and not(Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Equip[j].IsSealed)) then
              begin
                ResultOf := CompareDateTime(Now, Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Equip[j].ExpireDate);

                if (ResultOf = 1) then
                begin
                  ItemName :=
                    String(ItemList[Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Equip[j].Index].Name);

                   if(ItemList[Servers[Self.ChannelId].Players[i].Account.
                Header.Pran1.Equip[j].Index].Classe >= 100) and
                    (ItemList[Servers[Self.ChannelId].Players[i].Account.
                Header.Pran1.Equip[j].Index].Classe <= 104) then
                   begin //roupa de pran não deleta, só expira mesmo
                     Servers[Self.ChannelId].Players[i].Account.
                      Header.Pran1.Inventory[j].MAX := $FF;
                    Servers[Self.ChannelId].Players[i].Account.
                      Header.Pran1.Inventory[j].MIN := $FF;
                     Servers[Self.ChannelId].Players[i]
                      .Base.SendRefreshItemSlot(PRAN_Equip_TYPE, j,Servers[Self.ChannelId].Players[i].Account.
                    Header.Pran1.Equip[j], False);
                     Servers[Self.ChannelId].Players[i].SendClientMessage
                      ('O item [' + AnsiString(ItemName) + '] expirou.');
                     Servers[Self.ChannelId].Players[i].Base.SetEquipEffect(
                      Servers[Self.ChannelId].Players[i].Account.
                    Header.Pran1.Equip[j], DESEQUIPING_TYPE, True, False);
                     Servers[Self.ChannelId].Players[i].Base.GetCurrentScore;
                     Servers[Self.ChannelId].Players[i].Base.SendRefreshPoint;
                     Servers[Self.ChannelId].Players[i].Base.SendStatus;
                     Servers[Self.ChannelId].Players[i].Base.SendCurrentHPMP();
                   end
                   else
                   begin
                    TItemFunctions.RemoveItem(Servers[Self.ChannelId].Players[i],
                      PRAN_Equip_TYPE, j);
                    Servers[Self.ChannelId].Players[i].SendClientMessage
                      ('O item [' + AnsiString(ItemName) + '] expirou.');
                   end;
                end;
              end;
            end;


            for j := 0 to 41 do
            begin
              if(Servers[Self.ChannelId].Players[i].Account.
                Header.Pran1.Inventory[j].Index = 0) {or (Servers[Self.ChannelId].Players[i].Account.
                Header.Pran1.Inventory[j].Time = 0)} then
                Continue;

              //if(ItemList[Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Inventory[j].Index].Classe >= 100) and
                //(ItemList[Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Inventory[j].Index].Classe <= 104) then
                //Continue;

              if ((ItemList[Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Inventory[j]
                .Index].Expires) and not(Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Inventory[j].IsSealed)) then
              begin
                ResultOf := CompareDateTime(Now, Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Inventory[j].ExpireDate);

                if (ResultOf = 1) then
                begin
                  ItemName :=
                    String(ItemList[Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Inventory[j].Index].Name);

                  if(TItemFunctions.GetItemEquipSlot(Servers[Self.ChannelId].Players[i].Account.
                Header.Pran1.Inventory[j].Index) = 9) then
                   begin  //montaria não deleta, só expira mesmo
                     Servers[Self.ChannelId].Players[i].Account.
                      Header.Pran1.Inventory[j].Time := $FFFF;
                    //Servers[Self.ChannelId].Players[i].Account.
                      //Header.Pran1.Inventory[j].MIN := $FF;
                     Servers[Self.ChannelId].Players[i]
                      .Base.SendRefreshItemSlot(PRAN_INV_TYPE, j,Servers[Self.ChannelId].Players[i].Account.
                Header.Pran1.Inventory[j], False);
                     Servers[Self.ChannelId].Players[i].SendClientMessage
                      ('O item [' + AnsiString(ItemName) + '] expirou.');
                   end
                   else
                   if(ItemList[Servers[Self.ChannelId].Players[i].Account.
                Header.Pran1.Inventory[j].Index].Classe >= 100) and
                    (ItemList[Servers[Self.ChannelId].Players[i].Account.
                Header.Pran1.Inventory[j].Index].Classe <= 104) then
                   begin //roupa de pran não deleta, só expira mesmo
                     Servers[Self.ChannelId].Players[i].Account.
                      Header.Pran1.Inventory[j].MAX := $FF;
                    Servers[Self.ChannelId].Players[i].Account.
                      Header.Pran1.Inventory[j].MIN := $FF;
                     Servers[Self.ChannelId].Players[i]
                      .Base.SendRefreshItemSlot(PRAN_INV_TYPE, j,Servers[Self.ChannelId].Players[i].Account.
                Header.Pran1.Inventory[j], False);
                     Servers[Self.ChannelId].Players[i].SendClientMessage
                      ('O item [' + AnsiString(ItemName) + '] expirou.');
                   end
                   else
                   begin
                    TItemFunctions.RemoveItem(Servers[Self.ChannelId].Players[i],
                      PRAN_INV_TYPE, j);
                    Servers[Self.ChannelId].Players[i].SendClientMessage
                      ('O item [' + AnsiString(ItemName) + '] expirou.');
                   end;
                end;
              end;
            end;
          end;

        1:
          begin
            for j := 1 to 5 do
            begin
              if(Servers[Self.ChannelId].Players[i].Account.
                Header.Pran2.Equip[j].Index = 0) {or (Servers[Self.ChannelId].Players[i].Account.
                Header.Pran2.Equip[j].Time = $FFFF)} then
                Continue;

              if ((ItemList[Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Equip[j]
                .Index].Expires) and not(Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Equip[j].IsSealed)) then
              begin
                ResultOf := CompareDateTime(Now, Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Equip[j].ExpireDate);

                if (ResultOf = 1) then
                begin
                  ItemName :=
                    String(ItemList[Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Equip[j].Index].Name);

                   if(ItemList[Servers[Self.ChannelId].Players[i].Account.
                Header.Pran2.Equip[j].Index].Classe >= 100) and
                    (ItemList[Servers[Self.ChannelId].Players[i].Account.
                Header.Pran2.Equip[j].Index].Classe <= 104) then
                   begin //roupa de pran não deleta, só expira mesmo
                     Servers[Self.ChannelId].Players[i].Account.
                      Header.Pran2.Inventory[j].MAX := $FF;
                    Servers[Self.ChannelId].Players[i].Account.
                      Header.Pran2.Inventory[j].MIN := $FF;
                     Servers[Self.ChannelId].Players[i]
                      .Base.SendRefreshItemSlot(PRAN_Equip_TYPE, j,Servers[Self.ChannelId].Players[i].Account.
                Header.Pran2.Equip[j], False);
                     Servers[Self.ChannelId].Players[i].SendClientMessage
                      ('O item [' + AnsiString(ItemName) + '] expirou.');
                     Servers[Self.ChannelId].Players[i].Base.SetEquipEffect(
                      Servers[Self.ChannelId].Players[i].Account.
                    Header.Pran2.Equip[j], DESEQUIPING_TYPE, True, False);
                     Servers[Self.ChannelId].Players[i].Base.GetCurrentScore;
                     Servers[Self.ChannelId].Players[i].Base.SendRefreshPoint;
                     Servers[Self.ChannelId].Players[i].Base.SendStatus;
                     Servers[Self.ChannelId].Players[i].Base.SendCurrentHPMP();
                   end
                   else
                   begin
                    TItemFunctions.RemoveItem(Servers[Self.ChannelId].Players[i],
                      PRAN_Equip_TYPE, j);
                    Servers[Self.ChannelId].Players[i].SendClientMessage
                      ('O item [' + AnsiString(ItemName) + '] expirou.');
                   end;
                end;
              end;
            end;

            for j := 0 to 41 do
            begin
              if(Servers[Self.ChannelId].Players[i].Account.
                Header.Pran2.Inventory[j].Index = 0) {or (Servers[Self.ChannelId].Players[i].Account.
                Header.Pran2.Inventory[j].Time = )} then
                Continue;

              //if(ItemList[Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Inventory[j].Index].Classe >= 100) and
                //(ItemList[Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Inventory[j].Index].Classe <= 104) then
               // Continue;

              if ((ItemList[Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Inventory[j]
                .Index].Expires) and not(Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Inventory[j].IsSealed)) then
              begin
                ResultOf := CompareDateTime(Now, Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Inventory[j].ExpireDate);

                if (ResultOf = 1) then
                begin
                  ItemName :=
                    String(ItemList[Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Inventory[j].Index].Name);

                  if(TItemFunctions.GetItemEquipSlot(Servers[Self.ChannelId].Players[i].Account.
                Header.Pran2.Inventory[j].Index) = 9) then
                   begin  //montaria não deleta, só expira mesmo
                     Servers[Self.ChannelId].Players[i].Account.
                      Header.Pran2.Inventory[j].Time := $FFFF;
                    //Servers[Self.ChannelId].Players[i].Account.
                      //Header.Pran2.Inventory[j].MIN := $FF;
                     Servers[Self.ChannelId].Players[i]
                      .Base.SendRefreshItemSlot(PRAN_INV_TYPE, j,Servers[Self.ChannelId].Players[i].Account.
                Header.Pran2.Inventory[j], False);
                     Servers[Self.ChannelId].Players[i].SendClientMessage
                      ('O item [' + AnsiString(ItemName) + '] expirou.');
                   end
                   else
                   if(ItemList[Servers[Self.ChannelId].Players[i].Account.
                Header.Pran2.Inventory[j].Index].Classe >= 100) and
                    (ItemList[Servers[Self.ChannelId].Players[i].Account.
                Header.Pran2.Inventory[j].Index].Classe <= 104) then
                   begin //roupa de pran não deleta, só expira mesmo
                     Servers[Self.ChannelId].Players[i].Account.
                      Header.Pran2.Inventory[j].MAX := $FF;
                    Servers[Self.ChannelId].Players[i].Account.
                      Header.Pran2.Inventory[j].MIN := $FF;
                     Servers[Self.ChannelId].Players[i]
                      .Base.SendRefreshItemSlot(PRAN_INV_TYPE, j,Servers[Self.ChannelId].Players[i].Account.
                Header.Pran2.Inventory[j], False);
                     Servers[Self.ChannelId].Players[i].SendClientMessage
                      ('O item [' + AnsiString(ItemName) + '] expirou.');
                   end
                   else
                   begin
                    TItemFunctions.RemoveItem(Servers[Self.ChannelId].Players[i],
                      PRAN_INV_TYPE, j);
                    Servers[Self.ChannelId].Players[i].SendClientMessage
                      ('O item [' + AnsiString(ItemName) + '] expirou.');
                   end;
                end;
              end;
            end;
          end;
      end;

    except
      Continue;
    end;
  end;

end;

constructor TTimeItensThread.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;

  inherited Create(FALSE);
end;

procedure TTimeItensThread.Execute;
begin
  while (Servers[ChannelId].IsActive) do
  begin
    Self.CheckItens;

    Sleep(FDelay);
  end;
end;

{$ENDREGION}
{$REGION 'Verify Item Quest Thread'}

procedure TQuestItemThread.CheckInventory();
var
  i, j, k, l: WORD;
  ItemID: WORD;
  Item: PItem;
  RichTitle: Boolean;
  // SendUpdates: Boolean;
  OldValue: WORD;
  Helper: WORD;
begin
  for i := Low(Servers[Self.ChannelId].Players)
    to High(Servers[Self.ChannelId].Players) do
  begin
    if (Servers[Self.ChannelId].Players[i].Status < PLAYING) then
      Continue;

    if(Servers[ChannelId].Players[i].SocketClosed) then
      Continue;

   { if(Servers[Self.ChannelId].Players[i].Base.Character.Gold >=
      1000000000) then
    begin
      RichTitle := False;
      for j := 0 to 95 do
      begin
        if(Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.Titles[j].Index=45) then
        begin
          RichTitle := True;
          break;
        end;
      end;

      if not(RichTitle) then
        Servers[Self.ChannelId].Players[i].AddTitle(45, 1);
    end; }

    for j := 0 to 49 do
    begin
      if (Servers[Self.ChannelId].Players[i].PlayerQuests[j].ID > 0) then
      begin // player tem quest
        if not(Servers[Self.ChannelId].Players[i].PlayerQuests[j].IsDone) then
        begin // quest ainda não entregue
          for k := 0 to 4 do
          begin
            if (Servers[Self.ChannelId].Players[i].PlayerQuests[j]
              .Quest.RequirimentsType[k] = 2) then
            begin // se a quest tiver algum requiriment de pegar item
              ItemID := Servers[Self.ChannelId].Players[i].PlayerQuests[j]
                .Quest.Requiriments[k];

              case Servers[Self.ChannelId].Players[i].PlayerQuests[j]
                .Quest.QuestID of
                1297: // quest da relíquia
                  begin
                    Helper := TItemFunctions.GetItemSlotByItemType
                      (Servers[Self.ChannelId].Players[i], 713, INV_TYPE);

                    if not(Helper = 255) then
                    begin
                      Item := nil;

                      Item := @Servers[Self.ChannelId].Players[i]
                        .Base.Character.Inventory[Helper];

                      OldValue := Servers[Self.ChannelId].Players[i]
                        .PlayerQuests[j].Complete[k];

                      Servers[Self.ChannelId].Players[i].PlayerQuests[j]
                        .Complete[k] := Item.Refi;

                      if (OldValue <> Servers[Self.ChannelId].Players[i]
                        .PlayerQuests[j].Complete[k]) then
                      begin
                        Servers[Self.ChannelId].Players[i].UpdateQuest
                          (Servers[Self.ChannelId].Players[i]
                          .PlayerQuests[j].ID);
                      end;
                    end
                    else
                    begin
                      Servers[Self.ChannelId].Players[i].PlayerQuests[j]
                        .Complete[k] := 0;

                      Servers[Self.ChannelId].Players[i].UpdateQuest
                        (Servers[Self.ChannelId].Players[i].PlayerQuests[j].ID);
                    end;
                  end;

              else
                begin
                  Item := nil;

                  for l := 0 to 63 do
                  begin
                    if (Servers[Self.ChannelId].Players[i]
                      .Base.Character.Inventory[l].Index = ItemID) then
                    begin
                      Item := @Servers[Self.ChannelId].Players[i]
                        .Base.Character.Inventory[l];
                    end;
                  end;

                  // SendUpdates := False;
                  OldValue := Servers[Self.ChannelId].Players[i].PlayerQuests[j]
                    .Complete[k];

                  if (Item = nil) then
                  begin // a pessoa não tem o item no inventário
                    Servers[Self.ChannelId].Players[i].PlayerQuests[j]
                      .Complete[k] := 0;
                  end
                  else // a pessoa tem o item no inventário
                  begin
                    Servers[Self.ChannelId].Players[i].PlayerQuests[j].Complete
                      [k] := Item.Refi;
                  end;

                  if (OldValue <> Servers[Self.ChannelId].Players[i]
                    .PlayerQuests[j].Complete[k]) then
                  begin
                    Servers[Self.ChannelId].Players[i].UpdateQuest
                      (Servers[Self.ChannelId].Players[i].PlayerQuests[j].ID);
                    // SendUpdates := True;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

constructor TQuestItemThread.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;

  inherited Create(FALSE);
end;

procedure TQuestItemThread.Execute;
var
  ActivePlayers, ActivePlayersIsolated: Integer;
  i, j, k: Integer;
begin
  while ((Servers[ChannelId].IsActive) or (ActivePlayersNow > 0)) do
  begin
    try
      Self.CheckInventory;
    except

    end;

    {if(WebServerClosed) then
    begin
      while WebServerClosed do
      begin
        TokenServer.Requests.StopListening;
        TokenServer.IsActive := False;
        TokenServer.Requests.Destroy;
        TokenServer.SSLServer.Destroy;

        TokenServer.Requests := TIdHTTPServer.Create(Nil);
        TokenServer.Requests.DefaultPort := 8090;
        TokenServer.Requests.OnCommandGet := TokenServer.OnGetCommand;
        TokenServer.SSLServer := TIdServerIOHandlerSSLOpenSSL.Create(Nil);
        TokenServer.SSLServer.SSLOptions.CertFile := 'mycert.pem';
        TokenServer.SSLServer.SSLOptions.KeyFile := 'mycert.pem';
        TokenServer.SSLServer.SSLOptions.Mode := sslmServer;
        TokenServer.SSLServer.SSLOptions.VerifyDepth := 1;
        TokenServer.Requests.IOHandler := TokenServer.SSLServer;
        TokenServer.SSLHelper := TSSLHelper.Create;
        TokenServer.Requests.OnQuerySSLPort := TokenServer.SSLHelper.QuerySSLPort;
        TokenServer.StartServer;
        Logger.Write('TokenServer passou por erro e foi reiniciado.', TLogType.ConnectionsTraffic);
        WebServerClosed := not(TokenServer.Requests.Active);
      end;
    end; }

    ActivePlayers:= 0;
    for I := Low(Servers) to High(Servers) do
    begin
      ActivePlayersIsolated := 0;
      for j := Low(Servers[i].Players) to High(Servers[i].Players) do
      begin
        if(Servers[i].Players[j].Status >= CharList) then
        begin
          inc(ActivePlayers);
          inc(ActivePlayersIsolated);
        end;
      end;
      Servers[i].ActiveReliquaresOnTemples := 0;
      for j := Low(Servers[i].Devires) to High(Servers[i].Devires) do
      begin
        if(Servers[i].Devires[j].DevirId = 0) then
          Continue;

        for k := 0 to 4 do
        begin
          if(Servers[i].Devires[j].Slots[k].ItemID > 0) then
            Inc(Servers[i].ActiveReliquaresOnTemples, 1);
        end;
      end;

      Servers[i].ActivePlayersNowHere := ActivePlayersIsolated;
    end;
    ActivePlayersNow := ActivePlayers;

    SetConsoleTitle(PChar('Aika Server - ' + Length(Servers).ToString +
      ' channels :: ' + ActivePlayersNow.ToString + ' players connected.'));

    Sleep(FDelay);
  end;
end;
{$ENDREGION}
{$REGION 'Pran Food System'}

constructor TPranFoodThread.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;

  inherited Create(FALSE);
end;

procedure TPranFoodThread.Execute;
begin
  while (Servers[ChannelId].IsActive) do
  begin
    Self.CheckFood;

    Sleep(FDelay);
  end;
end;

procedure TPranFoodThread.CheckFood;
var
  i: WORD;
  destItem, srcItem: PItem;
  Aux: TItem;
begin
  for i := 1 to MAX_CONNECTIONS do
  begin
    if (Servers[Self.ChannelId].Players[i].Status < PLAYING) then
      Continue;

    if(Servers[ChannelId].Players[i].SocketClosed) then
      Continue;

    if (Servers[Self.ChannelId].Players[i].Account.Header.Pran1.IsSpawned) then
    begin
      if not(Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Food = 0)
      then
      begin
        if (Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Food <= 3)
        then
          Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Food := 0
        else
          Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Food :=
            Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Food - 3;

        if (Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Food < 25)
        then
        begin
          Servers[Self.ChannelId].Players[i].SendClientMessage
            ('Pran está com fome.', 16, 32);
        end;
      end
      else
      begin
        { if not(Servers[Self.ChannelId].Players[i]
          .Account.Header.Pran1.Devotion = 0) then
          Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Devotion :=
          Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Devotion - 1
          else
          begin }
       { if not(Servers[Self.ChannelId].Players[i]
          .Account.Header.Pran1.MovedToCentral) then
        begin
          Servers[Self.ChannelId].Players[i].SendClientMessage
            ('Sua pran foi enviada para a estação pran');

          Servers[Self.ChannelId].Players[i].Account.Header.Pran1.
            MovedToCentral := True;
          Servers[Self.ChannelId].Players[i].Account.Header.Pran1.
            IsSpawned := FALSE;
          Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Food := 10;
          Servers[Self.ChannelId].Players[i].SpawnedPran := 255;
          Servers[Self.ChannelId].Players[i].Account.Header.Pran1.
            Devotion := 68;
          // familiaridade pran cai pra 30% apos ela ser mandada pra estação pran

          Servers[Self.ChannelId].Players[i].SetPranEquipAtributes(0, FALSE);

          if (Servers[Self.ChannelId].Players[i].Account.Header.Storage.Itens
            [84].Index = 0) then
          begin
            srcItem := @Servers[Self.ChannelId].Players[i]
              .Base.Character.Equip[10];
            destItem := @Servers[Self.ChannelId].Players[i]
              .Account.Header.Storage.Itens[84];

            //Move(destItem^, Aux, sizeof(TItem));
            Move(srcItem^, destItem^, sizeof(TItem));
            //Move(Aux, srcItem^, sizeof(TItem));

            // Move(Servers[Self.ChannelId].Players[i].Base.Character.Equip[10],
            // Servers[Self.ChannelId].Players[i].Account.Header.Storage.Itens
            // [84], sizeof(TItem));

            Servers[Self.ChannelId].Players[i].Base.SendRefreshItemSlot
              (EQUIP_TYPE, 10, Servers[Self.ChannelId].Players[i]
              .Base.Character.Equip[10], FALSE);
            Servers[Self.ChannelId].Players[i].Base.SendRefreshItemSlot
              (STORAGE_TYPE, 84, Servers[Self.ChannelId].Players[i]
              .Account.Header.Storage.Itens[84], FALSE);
          end
          else if (Servers[Self.ChannelId].Players[i]
            .Account.Header.Storage.Itens[85].Index = 0) then
          begin
            srcItem := @Servers[Self.ChannelId].Players[i]
              .Base.Character.Equip[10];
            destItem := @Servers[Self.ChannelId].Players[i]
              .Account.Header.Storage.Itens[85];

            //Move(destItem^, Aux, sizeof(TItem));
            Move(srcItem^, destItem^, sizeof(TItem));
            //Move(Aux, srcItem^, sizeof(TItem));

            // Move(Servers[Self.ChannelId].Players[i].Base.Character.Equip[10],
            // Servers[Self.ChannelId].Players[i].Account.Header.Storage.Itens
            // [85], sizeof(TItem));

            Servers[Self.ChannelId].Players[i].Base.SendRefreshItemSlot
              (EQUIP_TYPE, 10, Servers[Self.ChannelId].Players[i]
              .Base.Character.Equip[10], FALSE);
            Servers[Self.ChannelId].Players[i].Base.SendRefreshItemSlot
              (STORAGE_TYPE, 85, Servers[Self.ChannelId].Players[i]
              .Account.Header.Storage.Itens[85], FALSE);
          end;

          Servers[Self.ChannelId].Players[i].spawnedPran := 255;
          Servers[Self.ChannelId].Players[i].SendPranToWorld(255);
          Servers[Self.ChannelId].Players[i].SendPranUnspawn(0);
          Servers[Self.ChannelId].Players[i].SetPranPassiveSkill(0, 0);
          Servers[Self.ChannelId].Players[i].SetPranEquipAtributes(0, False);
          Servers[Self.ChannelId].Players[i].Base.GetCurrentScore;
          Servers[Self.ChannelId].Players[i].Base.SendStatus;
          Servers[Self.ChannelId].Players[i].Base.SendRefreshPoint;
          Servers[Self.ChannelId].Players[i].Base.SendCurrentHPMP;

          Servers[Self.ChannelId].Players[i].SendEffect(0);

          Continue;
        end; }
        // end;
      end;

      if (Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Food >= 72)
      then
      begin
        if not(Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Devotion
          >= 226) then
          Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Devotion :=
            Servers[Self.ChannelId].Players[i]
            .Account.Header.Pran1.Devotion + 1;
      end
      else
      begin
        Servers[Self.ChannelId].Players[i].Account.Header.Pran1.Devotion :=
          Servers[Self.ChannelId].Players[i]
          .Account.Header.Pran1.Devotion - 1;
      end;

      Servers[Self.ChannelId].Players[i].SendPranToWorld(0);
    end;

    if (Servers[Self.ChannelId].Players[i].Account.Header.Pran2.IsSpawned) then
    begin
      if not(Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Food = 0)
      then
      begin
        if (Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Food <= 3)
        then
          Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Food := 0
        else
          Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Food :=
            Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Food - 3;

        if (Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Food < 25)
        then
        begin
          Servers[Self.ChannelId].Players[i].SendClientMessage
            ('Pran está com fome.', 16, 32);
        end;
      end
      else
      begin
        { if not(Servers[Self.ChannelId].Players[i]
          .Account.Header.Pran2.Devotion = 0) then
          Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Devotion :=
          Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Devotion - 1
          else
          begin }
        {if not(Servers[Self.ChannelId].Players[i]
          .Account.Header.Pran2.MovedToCentral) then
        begin
          Servers[Self.ChannelId].Players[i].SendClientMessage
            ('Sua pran foi enviada para a estação pran');

          Servers[Self.ChannelId].Players[i].Account.Header.Pran2.
            MovedToCentral := True;
          Servers[Self.ChannelId].Players[i].Account.Header.Pran2.
            IsSpawned := FALSE;
          Servers[Self.ChannelId].Players[i].SpawnedPran := 255;
          Servers[Self.ChannelId].Players[i].Account.Header.Pran2.
            Devotion := 68;
          Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Food := 10;
          // familiaridade pran cai pra 30% apos ela ser mandada pra estação pran

          Servers[Self.ChannelId].Players[i].SetPranEquipAtributes(1, FALSE);

          if (Servers[Self.ChannelId].Players[i].Account.Header.Storage.Itens
            [84].Index = 0) then
          begin
            srcItem := @Servers[Self.ChannelId].Players[i]
              .Base.Character.Equip[10];
            destItem := @Servers[Self.ChannelId].Players[i]
              .Account.Header.Storage.Itens[84];

            //Move(destItem^, Aux, sizeof(TItem));
            Move(srcItem^, destItem^, sizeof(TItem));
            //Move(Aux, srcItem^, sizeof(TItem));

            // Move(Servers[Self.ChannelId].Players[i].Base.Character.Equip[10],
            // Servers[Self.ChannelId].Players[i].Account.Header.Storage.Itens
            // [84], sizeof(TItem));

            Servers[Self.ChannelId].Players[i].Base.SendRefreshItemSlot
              (EQUIP_TYPE, 10, Servers[Self.ChannelId].Players[i]
              .Base.Character.Equip[10], FALSE);
            Servers[Self.ChannelId].Players[i].Base.SendRefreshItemSlot
              (STORAGE_TYPE, 84, Servers[Self.ChannelId].Players[i]
              .Account.Header.Storage.Itens[84], FALSE);
          end
          else if (Servers[Self.ChannelId].Players[i]
            .Account.Header.Storage.Itens[85].Index = 0) then
          begin
            srcItem := @Servers[Self.ChannelId].Players[i]
              .Base.Character.Equip[10];
            destItem := @Servers[Self.ChannelId].Players[i]
              .Account.Header.Storage.Itens[85];

            //Move(destItem^, Aux, sizeof(TItem));
            Move(srcItem^, destItem^, sizeof(TItem));
           // Move(Aux, srcItem^, sizeof(TItem));

            // Move(Servers[Self.ChannelId].Players[i].Base.Character.Equip[10],
            // Servers[Self.ChannelId].Players[i].Account.Header.Storage.Itens
            // [85], sizeof(TItem));
            Servers[Self.ChannelId].Players[i].Base.SendRefreshItemSlot
              (EQUIP_TYPE, 10, Servers[Self.ChannelId].Players[i]
              .Base.Character.Equip[10], FALSE);
            Servers[Self.ChannelId].Players[i].Base.SendRefreshItemSlot
              (STORAGE_TYPE, 85, Servers[Self.ChannelId].Players[i]
              .Account.Header.Storage.Itens[85], FALSE);
          end;

          Servers[Self.ChannelId].Players[i].spawnedPran := 255;
          Servers[Self.ChannelId].Players[i].SendPranToWorld(255);
          Servers[Self.ChannelId].Players[i].SendPranUnspawn(1);
          Servers[Self.ChannelId].Players[i].SetPranPassiveSkill(1, 0);
          Servers[Self.ChannelId].Players[i].Base.GetCurrentScore;
          Servers[Self.ChannelId].Players[i].Base.SendStatus;
          Servers[Self.ChannelId].Players[i].Base.SendRefreshPoint;
          Servers[Self.ChannelId].Players[i].Base.SendCurrentHPMP;
          Servers[Self.ChannelId].Players[i].SendEffect(0);

          Continue;
        end;  }
        // end;
      end;

      if (Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Food >= 72)
      then
      begin
        if not(Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Devotion
          >= 226) then
          Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Devotion :=
            Servers[Self.ChannelId].Players[i]
            .Account.Header.Pran2.Devotion + 1;
      end
      else
      begin
        Servers[Self.ChannelId].Players[i].Account.Header.Pran2.Devotion :=
          Servers[Self.ChannelId].Players[i]
          .Account.Header.Pran2.Devotion - 1;
      end;

      Servers[Self.ChannelId].Players[i].SendPranToWorld(1);
    end;
  end;
end;

{$ENDREGION}
{$REGION 'Temples Thread'}

constructor TTemplesManagmentThread.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;

  fCritSec := TCriticalSection.Create;

  inherited Create(FALSE);
end;

procedure TTemplesManagmentThread.Execute;
begin
  while (Servers[ChannelId].IsActive) do
  begin
    fCritSec.Enter;

    try
      Self.CheckGuards;
      Self.CheckStones;
      Self.CheckReliques;
    finally
      fCritSec.Release;
    end;
    Sleep(FDelay);
  end;
end;

procedure TTemplesManagmentThread.CheckGuards;
var
  i, j: WORD;
  OtherPlayer: PPlayer;
  Rand, did: Integer;
  DevirName: String;
begin
  for j := Low(Servers[Self.ChannelId].DevirGuards)
    to High(Servers[Self.ChannelId].DevirGuards) do
  begin
    if (Servers[Self.ChannelId].DevirGuards[j].Base.IsDead) then
    begin
      // verifica o tempo de reespawn
      if ((Now >= IncSecond(Servers[Self.ChannelId].DevirGuards[j].DeadTime,
        180))) then
      begin
        Servers[Self.ChannelId].DevirGuards[j].Base.IsDead := FALSE;
        Servers[Self.ChannelId].DevirGuards[j].PlayerChar.Base.CurrentScore.
          CurHP := Servers[Self.ChannelId].DevirGuards[j]
          .PlayerChar.Base.CurrentScore.MaxHp;
        Servers[Self.ChannelId].DevirGuards[j].IsAttacked := FALSE;
        Servers[Self.ChannelId].DevirGuards[j].AttackerID := 0;
        Servers[Self.ChannelId].DevirGuards[j].FirstPlayerAttacker := 0;

        did := Servers[Self.ChannelId].DevirGuards[j]
          .GetDevirIdByStoneOrGuardId(j);

        if not(did = 255) then
        begin
          Dec(Servers[Self.ChannelId].Devires[did].GuardsDied, 1);
        end;

        Servers[Self.ChannelId].DevirGuards[j].PlayerChar.LastPos :=
          Servers[Self.ChannelId].DevirGuards[j].FirstPosition;

        for i := 1 to MAX_CONNECTIONS do
        begin
          if (Servers[Self.ChannelId].Players[i].Status >= PLAYING) then
          begin
            if(Servers[ChannelId].Players[i].SocketClosed) then
              Continue;

            if (Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.LastPos.
              InRange(Servers[Self.ChannelId].DevirGuards[j]
              .PlayerChar.LastPos, 20)) then
            begin
              Servers[Self.ChannelId].Players[i].Base.UpdateVisibleList;
            end;
          end;
        end;
      end;

      Continue;
    end;

    { Nao Foi atacado }
    if not(Servers[Self.ChannelId].DevirGuards[j].IsAttacked) then
    begin
      { Verificar se tem alguém ao redor para atacar }
      for i := 1 to MAX_CONNECTIONS do
      begin
        if (Servers[Self.ChannelId].Players[i].Status >= PLAYING) then
        begin
          if(Servers[ChannelId].Players[i].SocketClosed) then
            Continue;

          if (Integer(Servers[Self.ChannelId].Players[i].Account.Header.Nation)
            = Servers[Self.ChannelId].DevirGuards[j].PlayerChar.Base.Nation)
          then
            Continue;

          if (Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.LastPos.
            InRange(Servers[Self.ChannelId].DevirGuards[j]
            .PlayerChar.LastPos, 20)) then
          begin
            Servers[Self.ChannelId].DevirGuards[j].IsAttacked := True;
            Servers[Self.ChannelId].DevirGuards[j].AttackerID := i;
            Servers[Self.ChannelId].DevirGuards[j].FirstPlayerAttacker := i;
            Servers[Self.ChannelId].DevirGuards[j].PlayerChar.CurrentPos :=
              Servers[Self.ChannelId].DevirGuards[j].PlayerChar.LastPos;

            if not(Servers[Self.ChannelId].DevirGuards[j]
              .Base.VisibleMobs.Contains(i)) then
              Servers[Self.ChannelId].DevirGuards[j].Base.VisibleMobs.Add(i);

            did := Servers[Self.ChannelId].DevirGuards[j]
              .GetDevirIdByStoneOrGuardId(j);

            if not(did = 255) then
            begin
              //System.AnsiStrings.StrPLCopy(DevirName, String(Servers[Self.ChannelId].DevirNpc[did]
                //.PlayerChar.Base.PranName[0]), sizeof(String(Servers[Self.ChannelId].DevirNpc[did]
                //.PlayerChar.Base.PranName[0])));

              DevirName := Servers[Self.ChannelId].DevirNpc[did+3335].DevirName; //talvez esteja dando erro pois ele não consegue acessar um array dentro de outro array

              Servers[Self.ChannelId].SendServerMsgForNation
                ('O Totem de ' + AnsiString(DevirName) + ' está sob ameaça.',
                Servers[Self.ChannelId].NationID);
            end;
          end
          else
          begin
            if (Servers[Self.ChannelId].DevirGuards[j]
              .Base.VisibleMobs.Contains(i)) then
              Servers[Self.ChannelId].DevirGuards[j].Base.VisibleMobs.Remove(i);

          end;
        end;
      end;

      if (Servers[Self.ChannelId].DevirGuards[j].PlayerChar.LastPos.Distance
        (Servers[Self.ChannelId].DevirGuards[j].FirstPosition) >= 60) then
      begin
        if not(Servers[Self.ChannelId].DevirGuards[j].IsAttacked) then
        begin // guarda matou player, mas não achou ninguem para atacar mais
          Servers[Self.ChannelId].DevirGuards[j].PlayerChar.LastPos :=
            Servers[Self.ChannelId].DevirGuards[j].FirstPosition;

          Servers[Self.ChannelId].DevirGuards[j]
            .MobMove(Servers[Self.ChannelId].DevirGuards[j]
            .PlayerChar.LastPos, 70);
        end;
      end;

      if (Servers[Self.ChannelId].DevirGuards[j].PlayerChar.Base.CurrentScore.
        CurHP < Servers[Self.ChannelId].DevirGuards[j]
        .PlayerChar.Base.CurrentScore.MaxHp) then
      begin
        Servers[Self.ChannelId].DevirGuards[j].PlayerChar.Base.CurrentScore.
          CurHP := Servers[Self.ChannelId].DevirGuards[j]
          .PlayerChar.Base.CurrentScore.CurHP + 100;
      end;

      if (Servers[Self.ChannelId].DevirGuards[j].PlayerChar.Base.CurrentScore.
        CurHP > Servers[Self.ChannelId].DevirGuards[j]
        .PlayerChar.Base.CurrentScore.MaxHp) then
      begin
        Servers[Self.ChannelId].DevirGuards[j].PlayerChar.Base.CurrentScore.
          CurHP := Servers[Self.ChannelId].DevirGuards[j]
          .PlayerChar.Base.CurrentScore.MaxHp;
      end;

      try
        //Servers[Self.ChannelId].DevirGuards[j].UpdateHPForVisibles();
      except

      end;
    end
    else
    begin
      OtherPlayer := @Servers[Self.ChannelId].Players
        [Servers[Self.ChannelId].DevirGuards[j].AttackerID];

      if (Servers[Self.ChannelId].DevirGuards[j].Base.RefreshBuffs > 0) then
      begin
        Servers[Self.ChannelId].DevirGuards[j].Base.SendRefreshBuffs;
      end;

      if (Servers[Self.ChannelId].DevirGuards[j].PlayerChar.LastPos.Distance
        (OtherPlayer^.Base.PlayerCharacter.LastPos) >= 3) then
      begin // mover guarda para perto
        Randomize;

        Rand := Random(7);

        Servers[Self.ChannelId].DevirGuards[j].PlayerChar.LastPos :=
          OtherPlayer^.Base.Neighbors[Rand].pos;

        Servers[Self.ChannelId].DevirGuards[j]
          .MobMove(Servers[Self.ChannelId].DevirGuards[j]
          .PlayerChar.LastPos, 45);
      end
      else // atacar
      begin
        if (Now >= IncSecond(Servers[Self.ChannelId].DevirGuards[j]
          .LastMyAttack, 3)) then
        begin
          if not(Servers[Self.ChannelId].DevirGuards[j].Base.GetMobAbility(EF_SKILL_STUN) = 0) then
            Continue;
          if not(Servers[Self.ChannelId].DevirGuards[j].Base.GetMobAbility(EF_SKILL_IMMOVABLE) = 0) then
            Continue;
          if not(Servers[Self.ChannelId].DevirGuards[j].Base.GetMobAbility(EF_SILENCE1) = 0) then
            Continue;
          if not(Servers[Self.ChannelId].DevirGuards[j].Base.GetMobAbility(EF_SILENCE2) = 0) then
            Continue;
          if not(Servers[Self.ChannelId].DevirGuards[j].Base.GetMobAbility(EF_SKILL_SHOCK) = 0) then
            Continue;
          if not(Servers[Self.ChannelId].DevirGuards[j].Base.GetMobAbility(EF_SKILL_SLEEP) = 0) then
            Continue;

          Servers[Self.ChannelId].DevirGuards[j].LastMyAttack := Now;
          Servers[Self.ChannelId].DevirGuards[j].AttackPlayer(OtherPlayer,
            MOB_GUARD_DEVIR_ATK, 0);
        end;
      end;

      if ((Servers[Self.ChannelId].DevirGuards[j].PlayerChar.LastPos.Distance
        (Servers[Self.ChannelId].DevirGuards[j].FirstPosition) >= 60) or (
        OtherPlayer^.Base.IsDead)) then
      begin // mover-se para a posição original zerar perseguicao
        Servers[Self.ChannelId].DevirGuards[j].PlayerChar.LastPos :=
          Servers[Self.ChannelId].DevirGuards[j].FirstPosition;

        Servers[Self.ChannelId].DevirGuards[j].IsAttacked := FALSE;
        Servers[Self.ChannelId].DevirGuards[j].AttackerID := 0;
        Servers[Self.ChannelId].DevirGuards[j].FirstPlayerAttacker := 0;

        Servers[Self.ChannelId].DevirGuards[j]
          .MobMove(Servers[Self.ChannelId].DevirGuards[j]
          .PlayerChar.LastPos, 70);
      end;

      // abandonar target se ele morrer
      if (OtherPlayer.Base.IsDead) then
      begin
        Servers[Self.ChannelId].DevirGuards[j].IsAttacked := FALSE;
        Servers[Self.ChannelId].DevirGuards[j].AttackerID := 0;
        Servers[Self.ChannelId].DevirGuards[j].FirstPlayerAttacker := 0;
      end;
    end;
  end;
end;

procedure TTemplesManagmentThread.CheckStones;
var
  j, i, k, Rand: Integer;
  OtherPlayer: PPlayer;
  did: Integer;
  StonesIds: TIdsArray;
begin
  for j := Low(Servers[Self.ChannelId].DevirStones)
    to High(Servers[Self.ChannelId].DevirStones) do
  begin
    if (Servers[Self.ChannelId].DevirStones[j].Base.IsDead) then
    begin
      did := Servers[Self.ChannelId].DevirStones[j]
          .GetDevirIdByStoneOrGuardId(j);

      if (did = 255) then
      begin
        Continue;
      end;

      if not(Servers[Self.ChannelId].Devires[did].IsOpen) then
      begin
        if(Servers[Self.ChannelId].Devires[did].StonesDied >= 3) and
          (Servers[Self.ChannelId].Devires[did].CollectedReliquare) then
        begin //fechar o templo que estava aberto
          Servers[Self.ChannelId].Devires[did].StonesDied := 0;
          Servers[Self.ChannelId].Devires[did].GuardsDied := 0;

          Servers[Self.ChannelId].Devires[did].IsOpen := FALSE;

          StonesIds := Servers[Self.ChannelId].GetTheStonesFromDevir(did);

          for k := 0 to 2 do
          begin
            Servers[Self.ChannelId].DevirStones[StonesIds[k]].Base.IsDead := FALSE;
            Servers[Self.ChannelId].DevirStones[StonesIds[k]].PlayerChar.Base.CurrentScore.
              CurHP := Servers[Self.ChannelId].DevirStones[StonesIds[k]]
              .PlayerChar.Base.CurrentScore.MaxHp;
            Servers[Self.ChannelId].DevirStones[StonesIds[k]].IsAttacked := FALSE;
            Servers[Self.ChannelId].DevirStones[StonesIds[k]].AttackerID := 0;
            Servers[Self.ChannelId].DevirStones[StonesIds[k]].FirstPlayerAttacker := 0;

            for i := 1 to MAX_CONNECTIONS do
            begin
              if (Servers[Self.ChannelId].Players[i].Status >= PLAYING) then
              begin
                if(Servers[ChannelId].Players[i].SocketClosed) then
                  Continue;

                if (Servers[Self.ChannelId].Players[i]
                  .Base.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId]
                  .DevirStones[StonesIds[k]].PlayerChar.LastPos, 20)) then
                begin
                  Servers[Self.ChannelId].Players[i].Base.UpdateVisibleList;
                end;
              end;
            end;
          end;
        end
        else
        begin //renascer a pedra
          if(Servers[Self.ChannelId].Devires[did].StonesDied >= 1) then
          begin
            if (Now >= IncSecond(Servers[Self.ChannelId].DevirStones[j].DeadTime,
              600)) then
            begin
              Servers[Self.ChannelId].DevirStones[j].Base.IsDead := FALSE;
              Servers[Self.ChannelId].DevirStones[j].PlayerChar.Base.CurrentScore.
                CurHP := Servers[Self.ChannelId].DevirStones[j]
                .PlayerChar.Base.CurrentScore.MaxHp;
              Servers[Self.ChannelId].DevirStones[j].IsAttacked := FALSE;
              Servers[Self.ChannelId].DevirStones[j].AttackerID := 0;
              Servers[Self.ChannelId].DevirStones[j].FirstPlayerAttacker := 0;

              Servers[Self.ChannelId].Devires[did].StonesDied :=
                Servers[Self.ChannelId].Devires[did].StonesDied - 1;

              for i := 1 to MAX_CONNECTIONS do
              begin
                if (Servers[Self.ChannelId].Players[i].Status >= PLAYING) then
                begin
                  if(Servers[ChannelId].Players[i].SocketClosed) then
                    Continue;

                  if (Servers[Self.ChannelId].Players[i]
                    .Base.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId]
                    .DevirStones[j].PlayerChar.LastPos, 20)) then
                  begin
                    Servers[Self.ChannelId].Players[i].Base.UpdateVisibleList;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;

      {
      // verifica o tempo de reespawn
      if ((Now >= IncSecond(Servers[Self.ChannelId].DevirStones[j].DeadTime,
        1200))) then
      begin
        did := Servers[Self.ChannelId].DevirStones[j]
          .GetDevirIdByStoneOrGuardId(j);

        if not(did = 255) then
        begin
          Dec(Servers[Self.ChannelId].Devires[did].StonesDied, 1);
        end
        else
          Continue;

        if not(Servers[Self.ChannelId].Devires[did].IsOpen) then
        begin
          Servers[Self.ChannelId].DevirStones[j].Base.IsDead := FALSE;
          Servers[Self.ChannelId].DevirStones[j].PlayerChar.Base.CurrentScore.
            CurHP := Servers[Self.ChannelId].DevirStones[j]
            .PlayerChar.Base.CurrentScore.MaxHp;
          Servers[Self.ChannelId].DevirStones[j].IsAttacked := FALSE;
          Servers[Self.ChannelId].DevirStones[j].AttackerID := 0;
          Servers[Self.ChannelId].DevirStones[j].FirstPlayerAttacker := 0;

          //Servers[Self.ChannelId].DevirStones[j].PlayerChar.LastPos :=
            //Servers[Self.ChannelId].DevirStones[j].FirstPosition;

          for i := 1 to MAX_CONNECTIONS do
          begin
            if (Servers[Self.ChannelId].Players[i].Status >= PLAYING) then
            begin
              if (Servers[Self.ChannelId].Players[i]
                .Base.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId]
                .DevirStones[j].PlayerChar.LastPos, 20)) then
              begin
                Servers[Self.ChannelId].Players[i].Base.UpdateVisibleList;
              end;
            end;
          end;
        end
        else
        begin
          if (Now >= IncSecond(Servers[Self.ChannelId].Devires[did].OpenTime,
            1500)) then
          begin
            Servers[Self.ChannelId].DevirStones[j].Base.IsDead := FALSE;
            Servers[Self.ChannelId].DevirStones[j].PlayerChar.Base.CurrentScore.
              CurHP := Servers[Self.ChannelId].DevirStones[j]
              .PlayerChar.Base.CurrentScore.MaxHp;
            Servers[Self.ChannelId].DevirStones[j].IsAttacked := FALSE;
            Servers[Self.ChannelId].DevirStones[j].AttackerID := 0;
            Servers[Self.ChannelId].DevirStones[j].FirstPlayerAttacker := 0;

            //Servers[Self.ChannelId].DevirStones[j].PlayerChar.LastPos :=
              //Servers[Self.ChannelId].DevirStones[j].FirstPosition;

            Servers[Self.ChannelId].Devires[did].StonesDied := 0;
            Servers[Self.ChannelId].Devires[did].GuardsDied := 0;

            Servers[Self.ChannelId].Devires[did].IsOpen := FALSE;

            for i := 1 to MAX_CONNECTIONS do
            begin
              if (Servers[Self.ChannelId].Players[i].Status >= PLAYING) then
              begin
                if (Servers[Self.ChannelId].Players[i]
                  .Base.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId]
                  .DevirStones[j].PlayerChar.LastPos, 20)) then
                begin
                  Servers[Self.ChannelId].Players[i].Base.UpdateVisibleList;
                end;
              end;
            end;
          end;
        end;
      end; }

      Continue;
    end;

    { Nao Foi atacado }
    if not(Servers[Self.ChannelId].DevirStones[j].IsAttacked) then
    begin
      { Verificar se tem alguém ao redor para atacar }
      for i := 1 to MAX_CONNECTIONS do
      begin
        if (Servers[Self.ChannelId].Players[i].Status >= PLAYING) then
        begin
          if(Servers[ChannelId].Players[i].SocketClosed) then
            Continue;

          if (Integer(Servers[Self.ChannelId].Players[i].Account.Header.Nation)
            = Servers[Self.ChannelId].DevirStones[j].PlayerChar.Base.Nation)
          then
            Continue;

          if (Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.LastPos.
            InRange(Servers[Self.ChannelId].DevirStones[j]
            .PlayerChar.LastPos, 20)) then
          begin
            if(Servers[Self.ChannelId].Players[i].Base.IsDead) then
              Continue;

            if(Servers[Self.ChannelId].DevirStones[j].IsAttacked = False) then
            begin
              Servers[Self.ChannelId].DevirStones[j].IsAttacked := True;
              Servers[Self.ChannelId].DevirStones[j].AttackerID := i;
              Servers[Self.ChannelId].DevirStones[j].FirstPlayerAttacker := i;
              Servers[Self.ChannelId].DevirStones[j].PlayerChar.CurrentPos :=
                Servers[Self.ChannelId].DevirStones[j].PlayerChar.LastPos;
            end;

            if not(Servers[Self.ChannelId].DevirStones[j]
              .Base.VisibleMobs.Contains(i)) then
              Servers[Self.ChannelId].DevirStones[j].Base.VisibleMobs.Add(i);
          end
          else
          begin
            if (Servers[Self.ChannelId].DevirStones[j]
              .Base.VisibleMobs.Contains(i)) then
              Servers[Self.ChannelId].DevirStones[j].Base.VisibleMobs.Remove(i);

          end;
        end;
      end;

      if (Servers[Self.ChannelId].DevirStones[j].PlayerChar.Base.CurrentScore.
        CurHP < Servers[Self.ChannelId].DevirStones[j]
        .PlayerChar.Base.CurrentScore.MaxHp) then
      begin
        Servers[Self.ChannelId].DevirStones[j].PlayerChar.Base.CurrentScore.
          CurHP := Servers[Self.ChannelId].DevirStones[j]
          .PlayerChar.Base.CurrentScore.CurHP + 100;
      end;

      if (Servers[Self.ChannelId].DevirStones[j].PlayerChar.Base.CurrentScore.
        CurHP > Servers[Self.ChannelId].DevirStones[j]
        .PlayerChar.Base.CurrentScore.MaxHp) then
      begin
        Servers[Self.ChannelId].DevirStones[j].PlayerChar.Base.CurrentScore.
          CurHP := Servers[Self.ChannelId].DevirStones[j]
          .PlayerChar.Base.CurrentScore.MaxHp;
      end;

      try
        Servers[Self.ChannelId].DevirStones[j].UpdateHPForVisibles();
      except

      end;

    end
    else
    begin
      OtherPlayer := @Servers[Self.ChannelId].Players
        [Servers[Self.ChannelId].DevirStones[j].AttackerID];

      if (Servers[Self.ChannelId].DevirStones[j].Base.RefreshBuffs > 0) then
      begin
        Servers[Self.ChannelId].DevirStones[j].Base.SendRefreshBuffs;
      end;

      if ((Servers[Self.ChannelId].DevirStones[j].PlayerChar.LastPos.Distance
        (OtherPlayer^.Base.PlayerCharacter.LastPos) >= 15) or (OtherPlayer^.Base.IsDead)) then
      begin // resetar para atacar outro
        Servers[Self.ChannelId].DevirStones[j].IsAttacked := FALSE;
        Servers[Self.ChannelId].DevirStones[j].AttackerID := 0;
        Servers[Self.ChannelId].DevirStones[j].FirstPlayerAttacker := 0;
      end
      else // atacar
      begin
        if (Now >= IncSecond(Servers[Self.ChannelId].DevirStones[j]
          .LastMyAttack, 3)) then
        begin
          if not(Servers[Self.ChannelId].DevirStones[j].Base.GetMobAbility(EF_SKILL_STUN) = 0) then
            Continue;
          if not(Servers[Self.ChannelId].DevirStones[j].Base.GetMobAbility(EF_SKILL_IMMOVABLE) = 0) then
            Continue;
          if not(Servers[Self.ChannelId].DevirStones[j].Base.GetMobAbility(EF_SILENCE1) = 0) then
            Continue;
          if not(Servers[Self.ChannelId].DevirStones[j].Base.GetMobAbility(EF_SILENCE2) = 0) then
            Continue;
          if not(Servers[Self.ChannelId].DevirStones[j].Base.GetMobAbility(EF_SKILL_SHOCK) = 0) then
            Continue;
          if not(Servers[Self.ChannelId].DevirStones[j].Base.GetMobAbility(EF_SKILL_SLEEP) = 0) then
            Continue;
          Servers[Self.ChannelId].DevirStones[j].LastMyAttack := Now;
          Servers[Self.ChannelId].DevirStones[j].AttackPlayer(OtherPlayer,
            MOB_STONE_DEVIR_ATK, 6465);
        end;
      end;

      if (OtherPlayer.Base.IsDead) then
      begin
        Servers[Self.ChannelId].DevirStones[j].IsAttacked := FALSE;
        Servers[Self.ChannelId].DevirStones[j].AttackerID := 0;
        Servers[Self.ChannelId].DevirStones[j].FirstPlayerAttacker := 0;
      end;
    end;
  end;
end;

procedure TTemplesManagmentThread.CheckReliques();
var
  i, j, k, l, m, reliqSlot: Integer;
  checked: Boolean;
  xPacket: TSendRemoveMobPacket;
  MPlayer: PPlayer;
begin
  for I := 0 to 4 do
  begin
    for j := 0 to 4 do
    begin
      if(Servers[Self.ChannelId].Devires[i].Slots[j].Furthed) then
      begin
        if(SecondsBetween(Now, IncHour(Servers[Self.ChannelId].Devires[i].Slots[j].TimeFurthed, -3)) >= 1200) then
        begin
          Checked := False;

          Servers[Self.ChannelId].Devires[i].Slots[j].ItemID := Servers[Self.ChannelId].Devires[i].Slots[j].ItemFurthed;
          Servers[Self.ChannelId].Devires[i].Slots[j].App := Servers[Self.ChannelId].Devires[i].Slots[j].ItemID;
          Servers[Self.ChannelId].Devires[i].Slots[j].TimeToEstabilish := Servers[Self.ChannelId].Devires[i].Slots[j].TimeFurthed;
          Servers[Self.ChannelId].Devires[i].Slots[j].Furthed := False;

          for k := Low(Servers) to High(Servers) do
          begin
            for l := Low(Servers[k].Players) to High(Servers[k].Players) do
            begin
              if(Servers[k].Players[l].Status >= Playing) then
              begin
                reliqSlot := TItemFunctions.GetItemSlot2(Servers[k].Players[l],
                  Servers[Self.ChannelId].Devires[i].Slots[j].ItemID);

                if(reliqSlot <> 255) then
                begin
                  ZeroMemory(@Servers[k].Players[l].Base.Character.Inventory[reliqSlot], sizeof(TItem));
                  Servers[k].Players[l].Base.SendRefreshItemSlot(INV_TYPE, reliqSlot,
                    Servers[k].Players[l].Base.Character.Inventory[reliqSlot], False);

                  Servers[k].Players[l].Base.SendEffect(0);

                  Servers[Self.ChannelId].SendServerMsg('O tesouro sagrado [' +
                    AnsiString(ItemList[Servers[Self.ChannelId].Devires[i].Slots[j].ItemID].Name) +
                    '] foi retornado ao templo.');

                  Servers[Self.ChannelId].SaveTemplesDB(@Servers[k].Players[l]);

                  Servers[Self.ChannelId].ReliqEffect[ItemList[Servers[Self.ChannelId].Devires[i].Slots[j].ItemID].EF[0]
                    ] := Servers[Self.ChannelId].ReliqEffect
                    [ItemList[Servers[Self.ChannelId].Devires[i].Slots[j].ItemID].EF[0]] + ItemList[Servers[Self.ChannelId].Devires[i].Slots[j].ItemID].EFV[0];

                  Servers[Self.ChannelId].UpdateReliquaresForAll;

                  Checked := True;
                  break;
                end;
              end;
            end;

            if(Checked) then
              break;
          end;

          if(Checked = False) then
          begin
            for k := Low(Servers) to High(Servers) do
            begin
              for l := Low(Servers[k].OBJ) to High(Servers[k].OBJ) do
              begin
                if(Servers[k].OBJ[l].ContentItemID <> 0) then
                begin
                  if(Servers[k].OBJ[l].ContentItemID =
                    Servers[Self.ChannelId].Devires[i].Slots[j].ItemID) then
                  begin
                    ZeroMemory(@xPacket, sizeof(xPacket));

                    xPacket.Header.Size := sizeof(xPacket);
                    xPacket.Header.Index := $7535;
                    xPacket.Header.Code := $101;

                    xPacket.Index := Servers[k].OBJ[l].Index;

                    ZeroMemory(@Servers[k].OBJ[l], sizeof(
                      Servers[k].OBJ[l]));

                    for m := Low(Servers[k].Players) to High(Servers[k].Players) do
                    begin
                      MPlayer := nil;

                      if(Servers[k].Players[m].Status < Playing) then
                        Continue;

                      if(MPlayer = nil) then
                        MPlayer := @Servers[k].Players[m];

                      MPlayer.SendPacket(xPacket, xPacket.Header.Size);


                      if(MPlayer.Base.VisibleMobs.Contains(xPacket.Index)) then
                        MPlayer.Base.VisibleMobs.Remove(xPacket.Index);
                    end;

                    Servers[Self.ChannelId].SendServerMsg('O tesouro sagrado [' +
                    AnsiString(ItemList[Servers[Self.ChannelId].Devires[i].Slots[j].ItemID].Name) +
                    '] foi retornado ao templo.');

                    Servers[Self.ChannelId].SaveTemplesDB(MPlayer);

                    Servers[Self.ChannelId].ReliqEffect[ItemList[Servers[Self.ChannelId].Devires[i].Slots[j].ItemID].EF[0]
                      ] := Servers[Self.ChannelId].ReliqEffect
                      [ItemList[Servers[Self.ChannelId].Devires[i].Slots[j].ItemID].EF[0]] + ItemList[Servers[Self.ChannelId].Devires[i].Slots[j].ItemID].EFV[0];

                    Servers[Self.ChannelId].UpdateReliquaresForAll;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

{$ENDREGION}
{$REGION 'Auction Offers System'}

constructor TAuctionOffersThread.Create(SleepTime: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;

  inherited Create(FALSE);
end;

procedure TAuctionOffersThread.Execute;
begin
  while not(xServerClosed) do
  begin
    Self.CheckOffers();

    Sleep(Self.FDelay);
  end;
end;

procedure TAuctionOffersThread.CheckOffers();
var
  QueryString: string;
  i: Integer;
  MySQLQuery: TQuery;
begin
  MySQLQuery := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  QueryString :=
    'SELECT AuctionId, CharacterId FROM vwauction_getactiveoffers WHERE NOW() > ExpireDate;';

  MySQLQuery.SetQuery(QueryString);
  MySQLQuery.Run();

  if (MySQLQuery.Query.RecordCount = 0) then
  begin
    MySQLQuery.Destroy;
    Exit;
  end;

  MySQLQuery.Query.First;
  for i := 0 to MySQLQuery.Query.RecordCount - 1 do
  begin

    Self.ReturnOffer(MySQLQuery.Query.FieldByName('CharacterId').AsLargeInt,
      MySQLQuery.Query.FieldByName('AuctionId').AsLargeInt);

    MySQLQuery.Query.Next;
  end;
  MySQLQuery.Destroy;
end;

function TAuctionOffersThread.ReturnOffer(CharacterId: UInt64;
  AuctionId: UInt64): Boolean;
var
  QueryString: string;
  ReturnMailId: UInt64;
  ReturnMailItemId: UInt64;
begin
  Result := True;

  ReturnMailId := 0;
  ReturnMailItemId := 0;

  try
    if not(Self.RegisterReturnMail(CharacterId, AuctionId, ReturnMailId)) then
    begin
      Self.FQuery.Destroy;
      Result := FALSE;
      Exit;
    end;

    Self.FQuery := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
      AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
      AnsiString(MYSQL_DATABASE), True);

    QueryString :=
      Format('INSERT INTO mails_items (mail_id, slot, item_id, app, identific, effect1_index, effect1_value, '
      + 'effect2_index, effect2_value, effect3_index, effect3_value, min, max, refine, `time`) '
      + 'SELECT %d AS MailIndex, 0, ItemId, ItemLookId, IdentificableAddOns, EffectId_1, EffectValue_1, EffectId_2, EffectValue_2, '
      + 'EffectId_3, EffectValue_3, DurabilityMin, DurabilityMax, Amount_Reinforce, ItemTime '
      + 'FROM vwauction_getactiveoffers WHERE AuctionId=%d; UPDATE auction SET Active=0 WHERE AuctionId=%d;',
      [ReturnMailId, AuctionId, AuctionId]);

    Self.FQuery.SetQuery(QueryString);
    Self.FQuery.Query.Connection.StartTransaction;
    Self.FQuery.Run(False);
    Self.FQuery.Query.Connection.Commit;

    if (Self.FQuery.Query.RowsAffected = 0) then
    begin
      Self.FQuery.Destroy;
      Result := FALSE;
      Exit;
    end;
    QueryString := 'SELECT max(id) as idx from mails_items;';
    Self.FQuery.SetQuery(QueryString);
    Self.FQuery.Run();

    if (Self.FQuery.Query.RecordCount = 0) then
    begin
      Self.FQuery.Destroy;
      Result := FALSE;
      Exit;
    end;

    ReturnMailItemId := Self.FQuery.Query.FieldByName('idx').AsLargeInt;

    if ReturnMailItemId = 0 then
    begin
      Self.FQuery.Destroy;
      Result := FALSE;
      Exit;
    end;
    Self.FQuery.Destroy;
    if not(Self.CloseOffer(AuctionId)) then
    begin
      Self.FQuery.Destroy;
      Result := FALSE;
      Exit;
    end;
  except
    begin
      Self.FQuery.Destroy;
      Result := FALSE;
    end;
  end;

  //Self.FQuery.Destroy;
end;

function TAuctionOffersThread.RegisterReturnMail(CharacterId: UInt64;
  AuctionId: UInt64; OUT MailIndex: UInt64): Boolean;
var
  QueryString: string;
begin
  Result := True;

  Self.FQuery := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);

  try
    QueryString :=
      Format('INSERT INTO mails (characterId, sentCharacterId, sentCharacterName, title, '
      + 'textBody, slot, sentGold, gold, returnDate, ' +
      'sentDate, isFromAuction, canReturn, hasItems) VALUES (%d, 1, "Casa de Leilões", '
      + '"Item retornou", "Entrega de item expirado da casa de leilões", 0, ' +
      '0, 0, "%s", "%s", 1, 0, 1);',
      [CharacterId, FormatDateTime('yyyy-mm-dd hh:nn:ss', IncDay(Now, 90)),
      FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)]);

    Self.FQuery.SetQuery(QueryString);
    Self.FQuery.Query.Connection.StartTransaction;
    Self.FQuery.Run(False);
    Self.FQuery.Query.Connection.Commit;

    if (Self.FQuery.Query.RowsAffected = 0) then
    begin
      Self.FQuery.Destroy;
      Result := FALSE;
      Exit;
    end;

    QueryString := 'SELECT max(id) as idx from mails;';
    Self.FQuery.SetQuery(QueryString);
    Self.FQuery.Run();

    MailIndex := UInt64(Self.FQuery.Query.FieldByName('idx').AsLargeInt);

    if MailIndex = 0 then
    begin
      Self.FQuery.Destroy;
      Result := FALSE;
      Exit;
    end;
  except
    begin
      Self.FQuery.Destroy;
      Result := FALSE;
      Exit;
    end;
  end;

  Self.FQuery.Destroy;
end;

function TAuctionOffersThread.CloseOffer(AuctionId: UInt64): Boolean;
var
  QueryString: string;
begin
  Result := True;

  Self.FQuery := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);

  try
    QueryString :=
      Format('UPDATE auction SET Active = 0 WHERE AuctionId=%d LIMIT 1',
      [AuctionId]);

    Self.FQuery.SetQuery(QueryString);
    Self.FQuery.Query.Connection.StartTransaction;
    Self.FQuery.Run(False);
    Self.FQuery.Query.Connection.Commit;

    if not(Self.FQuery.Query.RowsAffected > 0) then
    begin
      Self.FQuery.Destroy;
      Result := FALSE;
      Exit;
    end;
  except
    begin
      Self.FQuery.Destroy;
      Result := FALSE;
      Exit;
    end;
  end;

  Self.FQuery.Destroy;
end;
{$ENDREGION}

{$REGION 'Castle Siege System'}

constructor TCastleSiegeThread.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.FChannelID := ChannelId;

  inherited Create(FALSE);
end;

procedure TCastleSiegeThread.Execute;
var
  Server: PServerSocket;
  CastleSiege: PCastleSiege;
begin
  Server:= @Servers[FChannelID];
  CastleSiege := @Server.CastleSiegeHandler;

  CastleSiege.WarTimeInit := Now;

  while (CastleSiege.WarInProgress) do
  begin
    CheckCastleOrbs(CastleSiege);
    CountOrbsHolding(CastleSiege);
    CheckMarshallSeal(CastleSiege);

    UpdateSiegeStatus(CastleSiege);

    Sleep(FDelay);
  end;
end;

procedure TCastleSiegeThread.CheckCastleOrbs(CastleSiege: PCastleSiege);
var
  I: Integer;
  Player: PPlayer;
begin
  for I:= 0 to 2 do
  begin
    Player:= CastleSiege.OrbHolder[I];

    if (CastleSiege.OrbHolder[I] = nil) then
      Continue;

    if not(Player.Base.IsActive) then
    begin
      RemoveOrbHolder(CastleSiege, I);
    end;

    if (Player.Base.IsDead) then
    begin
      RemoveOrbHolder(CastleSiege, I);
    end;

    if(SecondsBetween(Player.Base.LastReceivedSkillFromCastle, Now) <= 3) then
    begin
      RemoveOrbHolder(CastleSiege, I);
    end;

    case i of
      0:
        begin
          if not(Player.Base.PlayerCharacter.LastPos.InRange
          (TPosition.Create(3551, 2759), 1)) then
          begin
            RemoveOrbHolder(CastleSiege, I);
          end;
        end;
      1:
        begin
          if not(Player.Base.PlayerCharacter.LastPos.InRange
          (TPosition.Create(3616, 2759), 1)) then
          begin
            RemoveOrbHolder(CastleSiege, I);
          end;
        end;
      2:
        begin
          if not(Player.Base.PlayerCharacter.LastPos.InRange
          (TPosition.Create(3584, 2860), 1)) then
          begin
            RemoveOrbHolder(CastleSiege, I);
          end;
        end;
    end;
  end;
end;

procedure TCastleSiegeThread.RemoveOrbHolder(CastleSiege: PCastleSiege;
  OrbIndex: BYTE);
begin
  if (SiegeStatus = TSiegeStatus.OrbsHolded) then
  begin
    SiegeStatus :=  TSiegeStatus.Running;
  end;

  if (SiegeStatus = TSiegeStatus.Sealing) then
  begin
    if (CastleSiege.OrbsHolded = 3) then
    begin
      SiegeStatus :=  TSiegeStatus.OrbsHolded;
    end else begin
      SiegeStatus :=  TSiegeStatus.Running;
    end;
  end;

  CastleSiege.OrbHolder[OrbIndex].SendSignal($7535, $33A);
  CastleSiege.OrbHolder[OrbIndex] := nil;
end;

procedure TCastleSiegeThread.CountOrbsHolding(CastleSiege: PCastleSiege);
var
  I: Integer;
  orbsHolded: Integer;
  Player: PPlayer;
begin
  orbsHolded := 0;

  for I:= 0 to 2 do
  begin
    if not(CastleSiege.OrbHolder[i] = nil) then
    begin
      inc(orbsHolded);
    end;
  end;

  if(SiegeStatus >= TSiegeStatus.Sealing) then
  begin
    if(CastleSiege.SealHolder <> nil) then
      SiegeStatus := TSiegeStatus.Sealing;
  end;

  CastleSiege.OrbsHolded := orbsHolded;
end;

procedure TCastleSiegeThread.CheckMarshallSeal(CastleSiege: PCastleSiege);
var
  Player: PPlayer;
begin
  if (SiegeStatus < TSiegeStatus.Sealing) then
    Exit;

  Player:= CastleSiege.SealHolder;

  if not(Player.Base.IsActive) then
  begin
    RemoveSealHolder(CastleSiege);
  end;

  if (Player.Base.IsDead) then
  begin
    RemoveSealHolder(CastleSiege);
  end;

  if(SecondsBetween(Player.Base.LastReceivedSkillFromCastle, Now) <= 3) then
  begin
    RemoveSealHolder(CastleSiege);
  end;

  if not(Player.Base.PlayerCharacter.LastPos.InRange
    (TPosition.Create(3584, 2804.75), 3)) then
  begin
    RemoveSealHolder(CastleSiege);
  end;
end;

procedure TCastleSiegeThread.RemoveSealHolder(CastleSiege: PCastleSiege);
begin
  if (SiegeStatus = TSiegeStatus.OrbsHolded) then
  begin
    SiegeStatus :=  TSiegeStatus.Running;
  end;

  if (SiegeStatus = TSiegeStatus.Sealing) then
  begin
    if (CastleSiege.OrbsHolded = 3) then
    begin
      SiegeStatus :=  TSiegeStatus.OrbsHolded;
    end else begin
      SiegeStatus :=  TSiegeStatus.Running;
    end;
  end;

  CastleSiege.SealHolder.SendSignal($7535, $33A);
  CastleSiege.SealHolder := nil;
  CastleSiege.SealBeingHold := False;
end;


procedure TCastleSiegeThread.UpdateSiegeStatus(CastleSiege: PCastleSiege);
var
  TempGuild, xGuild, OtherGuild1, OtherGuild2, OtherGuild3: PGuild;
  i, j, k: Integer;
  AnotherPlayer: PPlayer;
  OldAlliance: TGuildAlly;
begin
  xGuild := nil;
  OtherGuild1 := nil;
  OtherGuild2 := nil;
  OtherGuild3 := nil;
  TempGuild := nil;
  ZeroMemory(@OldAlliance, sizeof(TGuildAlly));

  if(MinutesBetween(CastleSiege.WarTimeInit, Now) >= 60) then
  begin
    Move(Nations[Servers[FChannelID].NationID-1].Cerco.Defensoras,
      OldAlliance, sizeof(TGuildAlly));

    for I := 0 to 3 do
    begin
      if(String(Nations[Servers[FChannelID].NationID-1].Cerco.Atacantes[i].LordMarechal) <> '') then
      begin
        for J := 0 to 127 do
        begin
          TempGuild := @Guilds[Servers[FChannelID].GetGuildSlotByID(
            Servers[FChannelID].GetGuildByName(String(Nations[Servers[FChannelID].NationID-1].Cerco.Atacantes[i].LordMarechal)))];

          if(TempGuild.Members[j].Logged) then
           begin
             if(Servers[FChannelID].GetPlayerByCharIndex(TempGuild.Members[j].CharIndex, AnotherPlayer)) then
             begin
               AnotherPlayer.SendGuildInfo;
               AnotherPlayer.SendClientMessage('A guerra acabou e não há vencedores.');

               AnotherPlayer.SendNationInformation;
               AnotherPlayer.Base.GetCurrentScore;
               AnotherPlayer.Base.SendRefreshPoint;
               AnotherPlayer.Base.SendStatus;
               AnotherPlayer.Base.SendRefreshLevel;
               AnotherPlayer.Base.SendCurrentHPMP();

               if(AnotherPlayer.SavedPos.IsValid) then
                AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
               else
                AnotherPlayer.Teleport(TPosition.Create(3450, 690));

               AnotherPlayer.Base.InClastleVerus := False;
             end;
           end;
        end;
      end;
      if(String(Nations[Servers[FChannelID].NationID-1].Cerco.Atacantes[i].Estrategista) <> '') then
      begin
        for J := 0 to 127 do
        begin
          TempGuild := @Guilds[Servers[FChannelID].GetGuildSlotByID(
            Servers[FChannelID].GetGuildByName(String(Nations[Servers[FChannelID].NationID-1].Cerco.Atacantes[i].Estrategista)))];

          if(TempGuild.Members[j].Logged) then
           begin
             if(Servers[FChannelID].GetPlayerByCharIndex(TempGuild.Members[j].CharIndex, AnotherPlayer)) then
             begin
               AnotherPlayer.SendGuildInfo;
               AnotherPlayer.SendClientMessage('A guerra acabou e não há vencedores.');

               AnotherPlayer.SendNationInformation;
               AnotherPlayer.Base.GetCurrentScore;
               AnotherPlayer.Base.SendRefreshPoint;
               AnotherPlayer.Base.SendStatus;
               AnotherPlayer.Base.SendRefreshLevel;
               AnotherPlayer.Base.SendCurrentHPMP();

               if(AnotherPlayer.SavedPos.IsValid) then
                AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
               else
                AnotherPlayer.Teleport(TPosition.Create(3450, 690));

               AnotherPlayer.Base.InClastleVerus := False;
             end;
           end;
        end;
      end;
      if(String(Nations[Servers[FChannelID].NationID-1].Cerco.Atacantes[i].Juiz) <> '') then
      begin
        for J := 0 to 127 do
        begin
          TempGuild := @Guilds[Servers[FChannelID].GetGuildSlotByID(
            Servers[FChannelID].GetGuildByName(String(Nations[Servers[FChannelID].NationID-1].Cerco.Atacantes[i].Juiz)))];

          if(TempGuild.Members[j].Logged) then
           begin
             if(Servers[FChannelID].GetPlayerByCharIndex(TempGuild.Members[j].CharIndex, AnotherPlayer)) then
             begin
               AnotherPlayer.SendGuildInfo;
               AnotherPlayer.SendClientMessage('A guerra acabou e não há vencedores.');

               AnotherPlayer.SendNationInformation;
               AnotherPlayer.Base.GetCurrentScore;
               AnotherPlayer.Base.SendRefreshPoint;
               AnotherPlayer.Base.SendStatus;
               AnotherPlayer.Base.SendRefreshLevel;
               AnotherPlayer.Base.SendCurrentHPMP();

               if(AnotherPlayer.SavedPos.IsValid) then
                AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
               else
                AnotherPlayer.Teleport(TPosition.Create(3450, 690));

               AnotherPlayer.Base.InClastleVerus := False;
             end;
           end;
        end;
      end;
      if(String(Nations[Servers[FChannelID].NationID-1].Cerco.Atacantes[i].Tesoureiro) <> '') then
      begin
        for J := 0 to 127 do
        begin
          TempGuild := @Guilds[Servers[FChannelID].GetGuildSlotByID(
            Servers[FChannelID].GetGuildByName(String(Nations[Servers[FChannelID].NationID-1].Cerco.Atacantes[i].Tesoureiro)))];

          if(TempGuild.Members[j].Logged) then
           begin
             if(Servers[FChannelID].GetPlayerByCharIndex(TempGuild.Members[j].CharIndex, AnotherPlayer)) then
             begin
               AnotherPlayer.SendGuildInfo;
               AnotherPlayer.SendClientMessage('A guerra acabou e não há vencedores.');

               AnotherPlayer.SendNationInformation;
               AnotherPlayer.Base.GetCurrentScore;
               AnotherPlayer.Base.SendRefreshPoint;
               AnotherPlayer.Base.SendStatus;
               AnotherPlayer.Base.SendRefreshLevel;
               AnotherPlayer.Base.SendCurrentHPMP();

               if(AnotherPlayer.SavedPos.IsValid) then
                AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
               else
                AnotherPlayer.Teleport(TPosition.Create(3450, 690));

               AnotherPlayer.Base.InClastleVerus := False;
             end;
           end;
        end;
      end;
    end;

    ZeroMemory(@Nations[Servers[FChannelID].NationID-1].Cerco.Atacantes,
      sizeof(Nations[Servers[FChannelID].NationID-1].Cerco.Atacantes));

    if(OldAlliance.Guilds[0].Index <> 0) then
    begin
      for i := 0 to 127 do
      begin
        TempGuild := @Guilds[Servers[FChannelID].GetGuildSlotByID(
          OldAlliance.Guilds[0].Index)];

        if(TempGuild.Members[i].Logged) then
         begin
           if(Servers[FChannelID].GetPlayerByCharIndex(TempGuild.Members[i].CharIndex, AnotherPlayer)) then
           begin
             AnotherPlayer.SendGuildInfo;
             AnotherPlayer.SendClientMessage('A guerra acabou e não há vencedores.');

             AnotherPlayer.SendNationInformation;
             AnotherPlayer.Base.GetCurrentScore;
             AnotherPlayer.Base.SendRefreshPoint;
             AnotherPlayer.Base.SendStatus;
             AnotherPlayer.Base.SendRefreshLevel;
             AnotherPlayer.Base.SendCurrentHPMP();

             if(AnotherPlayer.SavedPos.IsValid) then
              AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
             else
              AnotherPlayer.Teleport(TPosition.Create(3450, 690));

             AnotherPlayer.Base.InClastleVerus := False;
           end;
         end;
      end;
    end;
    if(OldAlliance.Guilds[1].Index <> 0) then
    begin
      for i := 0 to 127 do
      begin
        TempGuild := @Guilds[Servers[FChannelID].GetGuildSlotByID(
          OldAlliance.Guilds[1].Index)];

        if(TempGuild.Members[i].Logged) then
         begin
           if(Servers[FChannelID].GetPlayerByCharIndex(TempGuild.Members[i].CharIndex, AnotherPlayer)) then
           begin
             AnotherPlayer.SendGuildInfo;
             AnotherPlayer.SendClientMessage('A guerra acabou e não há vencedores.');

             AnotherPlayer.SendNationInformation;
             AnotherPlayer.Base.GetCurrentScore;
             AnotherPlayer.Base.SendRefreshPoint;
             AnotherPlayer.Base.SendStatus;
             AnotherPlayer.Base.SendRefreshLevel;
             AnotherPlayer.Base.SendCurrentHPMP();

             if(AnotherPlayer.SavedPos.IsValid) then
              AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
             else
              AnotherPlayer.Teleport(TPosition.Create(3450, 690));

             AnotherPlayer.Base.InClastleVerus := False;
           end;
         end;
      end;
    end;
    if(OldAlliance.Guilds[2].Index <> 0) then
    begin
      for i := 0 to 127 do
      begin
        TempGuild := @Guilds[Servers[FChannelID].GetGuildSlotByID(
          OldAlliance.Guilds[2].Index)];

        if(TempGuild.Members[i].Logged) then
         begin
           if(Servers[FChannelID].GetPlayerByCharIndex(TempGuild.Members[i].CharIndex, AnotherPlayer)) then
           begin
             AnotherPlayer.SendGuildInfo;
             AnotherPlayer.SendClientMessage('A guerra acabou e não há vencedores.');

             AnotherPlayer.SendNationInformation;
             AnotherPlayer.Base.GetCurrentScore;
             AnotherPlayer.Base.SendRefreshPoint;
             AnotherPlayer.Base.SendStatus;
             AnotherPlayer.Base.SendRefreshLevel;
             AnotherPlayer.Base.SendCurrentHPMP();

             if(AnotherPlayer.SavedPos.IsValid) then
              AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
             else
              AnotherPlayer.Teleport(TPosition.Create(3450, 690));

             AnotherPlayer.Base.InClastleVerus := False;
           end;
         end;
      end;
    end;
    if(OldAlliance.Guilds[3].Index <> 0) then
    begin
      for i := 0 to 127 do
      begin
        TempGuild := @Guilds[Servers[FChannelID].GetGuildSlotByID(
          OldAlliance.Guilds[3].Index)];

        if(TempGuild.Members[i].Logged) then
         begin
           if(Servers[FChannelID].GetPlayerByCharIndex(TempGuild.Members[i].CharIndex, AnotherPlayer)) then
           begin
             AnotherPlayer.SendGuildInfo;
             AnotherPlayer.SendClientMessage('A guerra acabou e não há vencedores.');

             AnotherPlayer.SendNationInformation;
             AnotherPlayer.Base.GetCurrentScore;
             AnotherPlayer.Base.SendRefreshPoint;
             AnotherPlayer.Base.SendStatus;
             AnotherPlayer.Base.SendRefreshLevel;
             AnotherPlayer.Base.SendCurrentHPMP();

             if(AnotherPlayer.SavedPos.IsValid) then
              AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
             else
              AnotherPlayer.Teleport(TPosition.Create(3450, 690));

             AnotherPlayer.Base.InClastleVerus := False;
           end;
         end;
      end;
    end;

    Nations[Servers[FChannelID].NationID-1].SaveNation;

    for I := 1 to High(Servers[FChannelID].Players) do
    begin
      AnotherPlayer := @Servers[FChannelID].Players[i];

      if(AnotherPlayer.Status < Playing) then
        Continue;

      AnotherPlayer.SendNationInformation;

      AnotherPlayer.SendClientMessage('A guerra de castelo foi finalizada. A liderança atual conseguiu sustentar seu poder.');
    end;

    for I := 0 to 2 do
    begin
      Self.RemoveOrbHolder(CastleSiege,i);
    end;
    CastleSiege.WarInProgress := False;
    CastleSiege.OrbHolder[0] := nil;
    CastleSiege.OrbHolder[1] := nil;
    CastleSiege.OrbHolder[2] := nil;
    CastleSiege.SealHolder := nil;
    Exit;
  end;

  if (CastleSiege.OrbsHolded < 3) then
  begin
    SiegeStatus := TSiegeStatus.Running;
    Exit;
  end;

  if not(CastleSiege.SealBeingHold) then
  begin
    SiegeStatus := TSiegeStatus.OrbsHolded;
    Exit;
  end;

  SiegeStatus := TSiegeStatus.Sealing;
  CastleSiege.SealHoldingSeconds := SecondsBetween(CastleSiege.SealHoldingStart,
    Now);

  Servers[FChannelID].SendServerMsg('Selo do Marechal: ' +
    (120-CastleSiege.SealHoldingSeconds).ToString + ' seg. restantes.', 32, 16, 32);

  if(CastleSiege.SealHoldingSeconds >= 120) then
  begin
    Move(Nations[CastleSiege.SealHolder.Base.Character.Nation-1].Cerco.Defensoras,
      OldAlliance, sizeof(TGuildAlly));

    xGuild := @Guilds[CastleSiege.SealHolder.Character.GuildSlot];

    if(xGuild.Index > 0) then
    begin
      if(xGuild.Ally.Guilds[1].Index > 0) then
      begin
        OtherGuild1 := @Guilds[Servers[FChannelID].GetGuildSlotByID(xGuild.Ally.Guilds[1].Index)];
      end;

      if(xGuild.Ally.Guilds[2].Index > 0) then
      begin
        OtherGuild2 := @Guilds[Servers[FChannelID].GetGuildSlotByID(xGuild.Ally.Guilds[2].Index)];
      end;

      if(xGuild.Ally.Guilds[3].Index > 0) then
      begin
        OtherGuild3 := @Guilds[Servers[FChannelID].GetGuildSlotByID(xGuild.Ally.Guilds[3].Index)];
      end;

      Nations[CastleSiege.SealHolder.Base.Character.Nation-1].MarechalGuildID :=
        xGuild.Index;
      System.AnsiStrings.StrPLCopy(
        Nations[CastleSiege.SealHolder.Base.Character.Nation-1].Cerco.Defensoras.LordMarechal,
        String(xGuild.Name), 18);

      if(OtherGuild1 <> nil) then
      begin
        Nations[CastleSiege.SealHolder.Base.Character.Nation-1].TacticianGuildID :=
          OtherGuild1.Index;
        System.AnsiStrings.StrPLCopy(
          Nations[CastleSiege.SealHolder.Base.Character.Nation-1].Cerco.Defensoras.Estrategista,
          String(OtherGuild1.Name), 18);
      end;
      if(OtherGuild2 <> nil) then
      begin
        Nations[CastleSiege.SealHolder.Base.Character.Nation-1].JudgeGuildID :=
          OtherGuild2.Index;
        System.AnsiStrings.StrPLCopy(
          Nations[CastleSiege.SealHolder.Base.Character.Nation-1].Cerco.Defensoras.Juiz,
          String(OtherGuild2.Name), 18);
      end;
      if(OtherGuild3 <> nil) then
      begin
        Nations[CastleSiege.SealHolder.Base.Character.Nation-1].TreasurerGuildID :=
          OtherGuild3.Index;
        System.AnsiStrings.StrPLCopy(
          Nations[CastleSiege.SealHolder.Base.Character.Nation-1].Cerco.Defensoras.Tesoureiro,
          String(OtherGuild3.Name), 18);
      end;

      for I := 0 to 3 do
      begin
        if(String(Nations[CastleSiege.SealHolder.Character.Base.Nation-1].Cerco.Atacantes[i].LordMarechal) <> '') then
        begin
          for J := 0 to 127 do
          begin
            TempGuild := @Guilds[Servers[CastleSiege.SealHolder.ChannelIndex].GetGuildSlotByID(
              Servers[CastleSiege.SealHolder.ChannelIndex].GetGuildByName(String(Nations[CastleSiege.SealHolder.Character.Base.Nation-1].Cerco.Atacantes[i].LordMarechal)))];

            if(TempGuild.Members[j].Logged) then
             begin
               if(Servers[CastleSiege.SealHolder.ChannelIndex].GetPlayerByCharIndex(TempGuild.Members[j].CharIndex, AnotherPlayer)) then
               begin
                 AnotherPlayer.SendGuildInfo;
                 AnotherPlayer.SendClientMessage('A guerra acabou. Os vencedores foram definidos.');

                 AnotherPlayer.SendNationInformation;
                 AnotherPlayer.Base.GetCurrentScore;
                 AnotherPlayer.Base.SendRefreshPoint;
                 AnotherPlayer.Base.SendStatus;
                 AnotherPlayer.Base.SendRefreshLevel;
                 AnotherPlayer.Base.SendCurrentHPMP();

                 if(AnotherPlayer.SavedPos.IsValid) then
                  AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
                 else
                  AnotherPlayer.Teleport(TPosition.Create(3450, 690));

                 AnotherPlayer.Base.InClastleVerus := False;
               end;
             end;
          end;
        end;
        if(String(Nations[CastleSiege.SealHolder.Character.Base.Nation-1].Cerco.Atacantes[i].Estrategista) <> '') then
        begin
          for J := 0 to 127 do
          begin
            TempGuild := @Guilds[Servers[CastleSiege.SealHolder.ChannelIndex].GetGuildSlotByID(
              Servers[CastleSiege.SealHolder.ChannelIndex].GetGuildByName(String(Nations[CastleSiege.SealHolder.Character.Base.Nation-1].Cerco.Atacantes[i].Estrategista)))];

            if(TempGuild.Members[j].Logged) then
             begin
               if(Servers[CastleSiege.SealHolder.ChannelIndex].GetPlayerByCharIndex(TempGuild.Members[j].CharIndex, AnotherPlayer)) then
               begin
                 AnotherPlayer.SendGuildInfo;
                 AnotherPlayer.SendClientMessage('A guerra acabou. Os vencedores foram definidos.');

                 AnotherPlayer.SendNationInformation;
                 AnotherPlayer.Base.GetCurrentScore;
                 AnotherPlayer.Base.SendRefreshPoint;
                 AnotherPlayer.Base.SendStatus;
                 AnotherPlayer.Base.SendRefreshLevel;
                 AnotherPlayer.Base.SendCurrentHPMP();

                 if(AnotherPlayer.SavedPos.IsValid) then
                  AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
                 else
                  AnotherPlayer.Teleport(TPosition.Create(3450, 690));

                 AnotherPlayer.Base.InClastleVerus := False;
               end;
             end;
          end;
        end;
        if(String(Nations[CastleSiege.SealHolder.Character.Base.Nation-1].Cerco.Atacantes[i].Juiz) <> '') then
        begin
          for J := 0 to 127 do
          begin
            TempGuild := @Guilds[Servers[CastleSiege.SealHolder.ChannelIndex].GetGuildSlotByID(
              Servers[CastleSiege.SealHolder.ChannelIndex].GetGuildByName(String(Nations[CastleSiege.SealHolder.Character.Base.Nation-1].Cerco.Atacantes[i].Juiz)))];

            if(TempGuild.Members[j].Logged) then
             begin
               if(Servers[CastleSiege.SealHolder.ChannelIndex].GetPlayerByCharIndex(TempGuild.Members[j].CharIndex, AnotherPlayer)) then
               begin
                 AnotherPlayer.SendGuildInfo;
                 AnotherPlayer.SendClientMessage('A guerra acabou. Os vencedores foram definidos.');

                 AnotherPlayer.SendNationInformation;
                 AnotherPlayer.Base.GetCurrentScore;
                 AnotherPlayer.Base.SendRefreshPoint;
                 AnotherPlayer.Base.SendStatus;
                 AnotherPlayer.Base.SendRefreshLevel;
                 AnotherPlayer.Base.SendCurrentHPMP();

                 if(AnotherPlayer.SavedPos.IsValid) then
                  AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
                 else
                  AnotherPlayer.Teleport(TPosition.Create(3450, 690));

                 AnotherPlayer.Base.InClastleVerus := False;
               end;
             end;
          end;
        end;
        if(String(Nations[CastleSiege.SealHolder.Character.Base.Nation-1].Cerco.Atacantes[i].Tesoureiro) <> '') then
        begin
          for J := 0 to 127 do
          begin
            TempGuild := @Guilds[Servers[CastleSiege.SealHolder.ChannelIndex].GetGuildSlotByID(
              Servers[CastleSiege.SealHolder.ChannelIndex].GetGuildByName(String(Nations[CastleSiege.SealHolder.Character.Base.Nation-1].Cerco.Atacantes[i].Tesoureiro)))];

            if(TempGuild.Members[j].Logged) then
             begin
               if(Servers[CastleSiege.SealHolder.ChannelIndex].GetPlayerByCharIndex(TempGuild.Members[j].CharIndex, AnotherPlayer)) then
               begin
                 AnotherPlayer.SendGuildInfo;
                 AnotherPlayer.SendClientMessage('A guerra acabou. Os vencedores foram definidos.');

                 AnotherPlayer.SendNationInformation;
                 AnotherPlayer.Base.GetCurrentScore;
                 AnotherPlayer.Base.SendRefreshPoint;
                 AnotherPlayer.Base.SendStatus;
                 AnotherPlayer.Base.SendRefreshLevel;
                 AnotherPlayer.Base.SendCurrentHPMP();

                 if(AnotherPlayer.SavedPos.IsValid) then
                  AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
                 else
                  AnotherPlayer.Teleport(TPosition.Create(3450, 690));

                 AnotherPlayer.Base.InClastleVerus := False;
               end;
             end;
          end;
        end;
      end;

      ZeroMemory(@Nations[CastleSiege.SealHolder.Base.Character.Nation-1].Cerco.Atacantes,
        sizeof(Nations[CastleSiege.SealHolder.Base.Character.Nation-1].Cerco.Atacantes));

      if(OldAlliance.Guilds[0].Index <> 0) then
      begin
        for i := 0 to 127 do
        begin
          TempGuild := @Guilds[Servers[CastleSiege.SealHolder.ChannelIndex].GetGuildSlotByID(
            OldAlliance.Guilds[0].Index)];

          if(TempGuild.Members[i].Logged) then
           begin
             if(Servers[CastleSiege.SealHolder.ChannelIndex].GetPlayerByCharIndex(TempGuild.Members[i].CharIndex, AnotherPlayer)) then
             begin
               AnotherPlayer.SendGuildInfo;
               AnotherPlayer.SendClientMessage('A guerra acabou. Os vencedores foram definidos.');

               AnotherPlayer.SendNationInformation;
               AnotherPlayer.Base.GetCurrentScore;
               AnotherPlayer.Base.SendRefreshPoint;
               AnotherPlayer.Base.SendStatus;
               AnotherPlayer.Base.SendRefreshLevel;
               AnotherPlayer.Base.SendCurrentHPMP();

               if(AnotherPlayer.SavedPos.IsValid) then
                AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
               else
                AnotherPlayer.Teleport(TPosition.Create(3450, 690));

               AnotherPlayer.Base.InClastleVerus := False;
             end;
           end;
        end;
      end;
      if(OldAlliance.Guilds[1].Index <> 0) then
      begin
        for i := 0 to 127 do
        begin
          TempGuild := @Guilds[Servers[CastleSiege.SealHolder.ChannelIndex].GetGuildSlotByID(
            OldAlliance.Guilds[1].Index)];

          if(TempGuild.Members[i].Logged) then
           begin
             if(Servers[CastleSiege.SealHolder.ChannelIndex].GetPlayerByCharIndex(TempGuild.Members[i].CharIndex, AnotherPlayer)) then
             begin
               AnotherPlayer.SendGuildInfo;
               AnotherPlayer.SendClientMessage('A guerra acabou. Os vencedores foram definidos.');

               AnotherPlayer.SendNationInformation;
               AnotherPlayer.Base.GetCurrentScore;
               AnotherPlayer.Base.SendRefreshPoint;
               AnotherPlayer.Base.SendStatus;
               AnotherPlayer.Base.SendRefreshLevel;
               AnotherPlayer.Base.SendCurrentHPMP();

               if(AnotherPlayer.SavedPos.IsValid) then
                AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
               else
                AnotherPlayer.Teleport(TPosition.Create(3450, 690));

               AnotherPlayer.Base.InClastleVerus := False;
             end;
           end;
        end;
      end;
      if(OldAlliance.Guilds[2].Index <> 0) then
      begin
        for i := 0 to 127 do
        begin
          TempGuild := @Guilds[Servers[CastleSiege.SealHolder.ChannelIndex].GetGuildSlotByID(
            OldAlliance.Guilds[2].Index)];

          if(TempGuild.Members[i].Logged) then
           begin
             if(Servers[CastleSiege.SealHolder.ChannelIndex].GetPlayerByCharIndex(TempGuild.Members[i].CharIndex, AnotherPlayer)) then
             begin
               AnotherPlayer.SendGuildInfo;
               AnotherPlayer.SendClientMessage('A guerra acabou. Os vencedores foram definidos.');

               AnotherPlayer.SendNationInformation;
               AnotherPlayer.Base.GetCurrentScore;
               AnotherPlayer.Base.SendRefreshPoint;
               AnotherPlayer.Base.SendStatus;
               AnotherPlayer.Base.SendRefreshLevel;
               AnotherPlayer.Base.SendCurrentHPMP();

               if(AnotherPlayer.SavedPos.IsValid) then
                AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
               else
                AnotherPlayer.Teleport(TPosition.Create(3450, 690));

               AnotherPlayer.Base.InClastleVerus := False;
             end;
           end;
        end;
      end;
      if(OldAlliance.Guilds[3].Index <> 0) then
      begin
        for i := 0 to 127 do
        begin
          TempGuild := @Guilds[Servers[CastleSiege.SealHolder.ChannelIndex].GetGuildSlotByID(
            OldAlliance.Guilds[3].Index)];

          if(TempGuild.Members[i].Logged) then
           begin
             if(Servers[CastleSiege.SealHolder.ChannelIndex].GetPlayerByCharIndex(TempGuild.Members[i].CharIndex, AnotherPlayer)) then
             begin
               AnotherPlayer.SendGuildInfo;
               AnotherPlayer.SendClientMessage('A guerra acabou. Os vencedores foram definidos.');

               AnotherPlayer.SendNationInformation;
               AnotherPlayer.Base.GetCurrentScore;
               AnotherPlayer.Base.SendRefreshPoint;
               AnotherPlayer.Base.SendStatus;
               AnotherPlayer.Base.SendRefreshLevel;
               AnotherPlayer.Base.SendCurrentHPMP();

               if(AnotherPlayer.SavedPos.IsValid) then
                AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
               else
                AnotherPlayer.Teleport(TPosition.Create(3450, 690));

               AnotherPlayer.Base.InClastleVerus := False;
             end;
           end;
        end;
      end;

      Nations[CastleSiege.SealHolder.Base.Character.Nation-1].SaveNation;

      for I := 1 to High(Servers[CastleSiege.SealHolder.ChannelIndex].Players) do
      begin
        AnotherPlayer := @Servers[CastleSiege.SealHolder.ChannelIndex].Players[i];

        if(AnotherPlayer.Status < Playing) then
          Continue;

        AnotherPlayer.SendNationInformation;

        AnotherPlayer.SendClientMessage('A guerra de castelo foi finalizada. Confira os novos líderes de sua nação.');
      end;

      for I := 0 to 2 do
      begin
        Self.RemoveOrbHolder(CastleSiege,i);
      end;

      CastleSiege.WarInProgress := False;
      CastleSiege.OrbHolder[0] := nil;
      CastleSiege.OrbHolder[1] := nil;
      CastleSiege.OrbHolder[2] := nil;
      CastleSiege.SealHolder := nil;
    end;
  end;
  //verificar tempo>=120 setar marechal, salvar, teleportar todos para local salvo
  //limpar cadastro de guerra, limpar titulos e adicionar novos aos vencedores


end;

{$ENDREGION}

end.

