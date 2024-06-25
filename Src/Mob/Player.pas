unit Player;
interface
{$O+}
uses BaseMob, PlayerData, Winsock2, Windows, System.Threading, SysUtils,
  PlayerThread, PartyData, MiscData, AnsiStrings, Generics.Collections,
  GuildData, Vcl.Dialogs, SQL, Data.DB, MOB, Classes, FilesData, EntityFriend,
  Dungeon, Math;
{$OLDTYPELAYOUT ON}
{$REGION 'Duel Thread'}
type
  TDuelThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    Player1, Player2: WORD;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE;
      Player1, Player2: WORD);
  end;
{$ENDREGION}
type
  PPlayer = ^TPlayer;
  TPlayer = record
    { Create Destroy }
    procedure Create(clientId: WORD; Channel: BYTE);
    procedure Destroy;
  public
    Base: TBaseMob;
    FirstRecv: Boolean;
    RecvPackets: Integer;
    LastTimeSaved: TDateTime;
    xdisconnected: Boolean;
    SelectedCharacterIndex: Integer;
    Account: TAccountFile;
    Character: TPlayerCharacter;
    CountTime: TDateTime;
    Status: TPlayerStatus;
    SubStatus: TPlayerStatus;
    Thread: TPlayerThread;
    MobsThread: TPlayerThreadMobsUpdate;
    //PlayerSQL: TQuery;
    SqlInUse: Boolean;
    TimeUpdate: TDateTime;
    SkillUpgraded: WORD;
    PlayerThreadActive: Boolean;
    Unlogging: Boolean;
    FDSet: TFDSet;
    SocketClosed: Boolean;
    ChannelIndex: BYTE;
    Socket: TSocket;
    SockInUse: Boolean;
    Ip: String;
    { Open Npc var }
    OpennedNPC: WORD;
    OpennedOption: WORD;
    OpennedDevir: Word;
    OpennedTemple: WORD;
    IsInstantiated: Boolean;
    Party: PParty;
    PartyIndex: WORD;
    GuildRecruterCharIndex: DWORD;
    GuildInviteTime: TDateTime;
    PartyRequester: WORD;
    RaidRequester: WORD;
    CanSendMailTo: string;
    { Duel }
    DuelRequester: WORD;
    DuelThread: TDuelThread;
    Dueling: Boolean;
    DuelFlagPosition: TPosition;
    DuelInitTime: TDateTime;
    DuelWinner: Boolean;
    DuelOutTimes: WORD;
    DuelFlagID: WORD;
    DuelingWith: WORD;
    FriendList: TFriendList;
    EntityFriend: TEntityFriend;
    FriendOpenWindowns: TDictionary<WORD, UInt64>;
    PlayerQuests: Array [0 .. 49] of QuestDin;
    TeleportList: Array [0 .. 4] of TPosition;
    SavedPos: TPosition;
    CurrentCity: TCity;
    CurrentCityID: Integer;
    Cycles, Laps: Integer;
    HPRCycles, HPRLaps: Integer;
    SKDCycles, SKDLaps: Integer;
    ShoutTime: TDateTime;
    SpawnedPran: BYTE;
    DungeonLobbyIndex: BYTE;
    DungeonLobbyDificult: BYTE;
    InDungeon: Boolean;
    DungeonID: BYTE;
    DungeonIDDificult: BYTE;
    DungeonInstanceID: BYTE;
    DesconectedByOtherChannel: Boolean;
    LoggedByOtherChannel: Boolean;
    LastPositionLongSkill: TPosition;
    AliianceByLegion: Boolean;
    AllianceRequester: WORD;
    AllianceSlot: Byte;
    CollectingReliquare: Boolean;
    CollectInitTime: TDateTime;
    CollectingID: WORD;
    FaericForm: Boolean;
    Authenticated, SendedSendToWorld: Boolean;
    ConnectionedTime: TDateTime;
    PingCommandUsed: TDateTime;
    IsAuxilyUser: Boolean;
    { TPlayer }
    function LoadAccountSql(Username: String): Boolean;
    function LoadAccSQL(Username: String): Boolean;
    function LoadCharacterMisc(CharID: Integer): Boolean;
    function NameExists(CharacterName: String): Boolean;
    function VerifyAmount(CharacterName: String): Boolean;
    function SaveAccountToken(Username: String): Boolean;
    function SaveStatus(Username: String): Boolean;
    function SaveCreatedChar(CharacterName: String; Slot: Integer): Boolean;
    function SaveCharOnCharRoom(CharID: Integer): Boolean;
    function SaveInGame(CharID: Integer; isFromPainel: Boolean = false): Boolean;
    function DeleteCharacter(CharID: Integer): Boolean;
    function LoadCharacterTeleportList(CharName: String): Boolean;
    function SaveCharacterTeleportList(CharName: String): Boolean;
    function LoadSavedLocation(): TPosition;
    function SaveSavedLocation(Pos: TPosition): Boolean;
    function CheckSelfSocket(): Boolean;
    procedure SendPacket(const Packet; size: WORD; Encrypt: Boolean = True);
    procedure SendSignal(headerClientId, packetCode: WORD); overload;
    procedure SendSignal(Client, packetCode, size: WORD); overload;
    procedure SendData(clientId, packetCode: WORD; Data: DWORD);
    function GetCurrentCity: TCity;
    function GetCurrentCityID: Integer;
    procedure SetCurrentNeighbors();
    { Sends }
    procedure SendClientMessage(Msg: AnsiString; MsgType: Integer = 16;
      Null: Integer = 0; Type2: Integer = 0);
    procedure SendCharList(Type1: BYTE = 0);
    function BackToCharList: Boolean;
    procedure SendToWorld(CharID: BYTE; aSendPacket: Boolean = True);
    procedure SendToWorld2(CharID: BYTE);
    procedure SendPranToWorld(PranSlot: BYTE);
    procedure SendPranSpawn(PranSlot: BYTE; SendTo: WORD = 0;
      SpawnType: BYTE = 2);
    procedure SendPranUnspawn(PranSlot: BYTE; SendTo: WORD = 0);
    procedure SetPranPassiveSkill(PranSlot: BYTE; Action: BYTE);
    function GetPranClassStoneItem(PranClass: BYTE): BYTE;
    function PranIsFairy(PranClass: BYTE): Boolean;
    procedure SetPranEquipAtributes(PranSlot: BYTE; SetOn: Boolean);
    procedure RefreshMoney;
    procedure RefreshItemBarSlot(Slot, Type1, Item: Integer);
    procedure SendStorage(StorageType: Integer = 1);
    procedure SendChangeItemResponse(ReinforceResult: WORD;
      ChangeType: BYTE = 0);
    procedure SendAccountStatus();
    procedure SendToWorldSends(IsSendedByOtherChannel: Boolean = False);
    procedure SendTitleUpdate(TitleIDAcquire: DWORD; TitleIDLeveled: DWORD);
    procedure RefreshPlayerInfos(SendToVisible: Boolean = True);
    procedure SpawnMob(mobid: DWORD; MobIdGen: DWORD);
    procedure SpawnMobGuard(mobid: DWORD; MobIdGen: DWORD);
    procedure UnspawnMob(mobid: DWORD; MobIdGen: DWORD);
    procedure SpawnPet(PetID: WORD);
    procedure UnSpawnPet(PetID: WORD);
    procedure SendTeleportPositionsFC();
    procedure SendPlayerToSavedPosition();
    procedure SendPlayerToCityPosition();
    procedure DisparosRapidosBarReset(SkillID: DWORD);
    procedure PredadorInvBarReset(SkillID: DWORD);
    procedure SendUpdateActiveTitle();
    procedure SendNationInformation();
    function GetPranEvolutedCnt(): Integer;
    function SetPranEvolutedCnt(Cnt: Integer): Boolean;
    function GetPranClass(xPran: PPran): Byte;
    procedure SendCloseClient();
    { Unk/Others Sends }
    procedure SendNumbers;
    procedure SendClientIndex;
    procedure SendP12C;
    procedure SendP131;
    procedure SendP16F;
    procedure SendP186;
    procedure SendP227;
    procedure SendP33D;
    procedure SendP357;
    procedure SendP3A2;
    procedure SendP94C;
    { Trade }
    procedure RefreshTrade;
    procedure RefreshTradeTo(clientId: Integer);
    procedure CloseTrade;
    { Party }
    procedure SendToParty(var Packet; size: WORD; SendSelf: Boolean = True);
    procedure RefreshParty;
    function AddMemberParty(PlayerIndex: WORD): Boolean;
    procedure SendPositionParty(SendTo: WORD = 0);
    { Cash }
    procedure SendPlayerCash;
    procedure SendCashInventory;
    procedure SendCancelCollectItem(Index: Integer);
    { Char Info }
    procedure CharInfoResponse(Index: WORD);
    { Player Add Functions }
    function AddExp(Value: Int64; out ExpPreReliq: Integer; ExpType: Integer = 0): Int64;
    procedure AddExpPerc(Value: WORD);
    procedure AddLevel(Value: WORD = 1);
    procedure AddPranExp(PranSlot: BYTE; Value: DWORD);
    procedure SendPranLevelAndExp(Level: DWORD; Exp: Int64);
    procedure SendPranDevotionAndFood(Devotion, Food: WORD);
    procedure AddPranLevel(PranSlot: BYTE; Value: WORD = 1);
    function PranBarExistsIndex(PranID: Byte; Index: DWORD): Byte;
    procedure AddGold(Value: Int64);
    procedure AddCash(Value: Cardinal);
    procedure DecGold(Value: Int64);
    procedure AddTitle(TitleID, TitleLevel: Integer; xMsg: Boolean = True);
    procedure RemoveTitle(TitleID: Integer);
    procedure UpdateTitleLevel(TitleID, TitleLevel: Integer; xMsg: Boolean = True);
    { Skills }
    procedure SetPlayerSkills;
    procedure SendPlayerSkills(NPCIndex: Integer = 0);
    procedure SendPlayerSkillsLevel;
    function CalcSkillPoints(Level: WORD): WORD;
    procedure SearchSkillsPassive(Mode: BYTE = 0);
    procedure SetActiveSkillPassive(SkillIndex: Integer; SkillIDLevel: Integer);
    procedure SetDesativeSkillPassive(SkillIndex: Integer);
    { Friend list }
    procedure sendToFriends(const Packet; size: WORD);
    procedure sendFriendToSocial(const characterId: UInt64);
    function AddFriend(PlayerIndex: WORD): BYTE;
    procedure AtualizeFriendInfos(characterId: UInt64);
    procedure sendDeleteFriend(characterId: UInt64);
    procedure SendFriendLogin;
    procedure SendFriendLogout;
    procedure RefreshSocialFriends;
    procedure RefreshMeToFriends;
    procedure OpenFriendWindow(CharIndex, WindowIndex: DWORD);
    procedure CloseFriendWindow(characterId: UInt64);
    { PersonalShop }
    procedure SendPersonalShop(Shop: TPersonalShopData);
    procedure ClosePersonalShop;
    { Teleport Functions }
    procedure Teleport(Pos: TPosition);
    { Change Channel }
    procedure SendChannelClientIndex;
    procedure SendLoginConfirmation;
    { Chat Functions }
    function SendItemChat(Slot: WORD; ChatType: BYTE; Msg: string): Boolean;
    { Effect and Animation Functions }
    procedure SendEffect(EffectIndex: DWORD);
    procedure SendAnimation(AnimationIndex: DWORD; Loop: DWORD = 0);
    procedure SendDevirChange(DevirNpcID: DWORD; DevirAnimation: DWORD);
    procedure SendAnimationDeadOf(ClientID: DWORD);
    { Guild }
    procedure SearchAndSetGuildSlot;
    procedure SendGuildInfo;
    procedure SendGuildPlayers;
    procedure AddPlayerToGuild(Player: TPlayerFromGuild);
    procedure GuildMemberLogin(MemberId: Integer);
    procedure GuildMemberLogout(MemberId: Integer);
    procedure UpdateGuildMemberRank(CharIndex, Rank: Integer);
    procedure UpdateGuildMemberLevel(CharIndex, Level: Integer);
    procedure UpdateGuildRanksConfig;
    procedure UpdateGuildNotices;
    procedure UpdateGuildSite;
    procedure InviteToGuildRequest(clientId: Integer);
    procedure GetOutGuild(Expulsion: Boolean);
    procedure SendGuildChestPermission;
    procedure SendGuildChest;
    procedure CloseGuildChest;
    procedure RefreshGuildChestGold;
    procedure SendP152;
    { Duel }
    procedure SendDuelTime();
    procedure CreateDuelSession(OtherPlayer: PPlayer);
    procedure SendDuelEnd(MsgType: BYTE);
    procedure RemoveDuelFlag(FlagID: WORD = 0);
    { Quest }
    procedure SendQuests();
    procedure UpdateQuest(QuestID: DWORD);
    procedure RemoveQuest(QuestID: DWORD);
    procedure SendExpGoldMsg(Exp, Gold: DWORD);
    function QuestExists(QuestID: WORD; out QuestIndex: WORD): Boolean;
    function SearchEmptyQuestIndex(): WORD;
    function QuestCount(): WORD;
    { Event Item }
    procedure GetAllEventItems();
    function DiaryItemAvaliable(): Boolean;
    { Dungeon }
    procedure SendDungeonLobby(InParty: Boolean; Dungeon, Dificult: BYTE);
    function GetFreeDungeonInstance(): BYTE;
    procedure CreateDungeonInstance(InParty: Boolean; Dungeon, Dificult: BYTE);
    procedure SendSpawnMobDungeon(MOB: PMobsStructDungeonInstance);
    procedure SendRemoveMobDungeon(MOB: PMobsStructDungeonInstance);
    { Nation }
    function IsMarshal(): Boolean;
    function IsArchon(): Boolean;
    function IsGradeMarshal(): Boolean;
    function IsGradeArchon(): Boolean;
    { Reliquares and Devir }
    procedure SendUpdateReliquareInformation(Channel: BYTE);
    procedure SendReliquesToPlayer();
    procedure UpdateReliquareOpennedDevir(DevirID: Integer);
    { Classes }
    class function GetPlayer(Index: WORD; Server: BYTE; out Player: TPlayer)
      : Boolean; static;
    class procedure ForEach(proc: TProc<PPlayer>; Server: BYTE);
      overload; static;
    class procedure ForEach(proc: TProc<PPlayer, TParallel.TLoopState>;
      Server: BYTE); overload; static;
    function GetTitleLevelValue(Slot, Level: BYTE): WORD;
    function CheckGameMasterLogged(): Boolean;
    function CheckAdminLogged(): Boolean;
    function CheckModeratorLogged(): Boolean;
    procedure SendMessageGritoForGameMaster(Nick: String; ServerFrom: Integer; xMsg: String);
    { New method declaration }
    procedure SendMessageToPainel(const Msg: string; Icon: Integer; Flags: Integer);
  end;
{$OLDTYPELAYOUT OFF}
implementation
uses GlobalDefs, Functions, ItemFunctions, SkillFunctions, EncDec, Packets, Log,
  DateUtils, EntityMail, Util, FireDAC.Phys.Intf;
{ Implementation of the new method }
procedure TPlayer.SendMessageToPainel(const Msg: string; Icon: Integer; Flags: Integer);
begin
  // Implementation of the SendMessageToPainel method
  // Add your code here
end;

{ Additional code can be added here }
{$REGION 'Duel Thread'}
constructor TDuelThread.Create(SleepTime: Integer; ChannelId: BYTE;
  Player1, Player2: WORD);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.Player1 := Player1;
  Self.Player2 := Player2;
  inherited Create(FALSE);
end;
procedure TDuelThread.Execute;
var
  i: Integer;
  P1, P2: PPlayer;
begin
  P1 := @Servers[Self.ChannelId].Players[Self.Player1];
  P2 := @Servers[Self.ChannelId].Players[Self.Player2];
  P1.DuelOutTimes := 0;
  P2.DuelOutTimes := 0;
  Sleep(DUEL_TIME_WAIT);
  while (P1.Dueling) do
  begin
    if not(P1.Base.IsActive) then
    begin
      P1.Dueling := FALSE;
      P2.Dueling := FALSE;
      P1.DuelWinner := FALSE;
      P2.DuelWinner := True;
      Break;
    end;
    if not(P2.Base.IsActive) then
    begin
      P1.Dueling := FALSE;
      P2.Dueling := FALSE;
      P1.DuelWinner := True;
      P2.DuelWinner := FALSE;
      Break;
    end;
    if (P1.Base.PlayerCharacter.LastPos.Distance(P1.DuelFlagPosition) >
      DISTANCE_TO_WATCH) then
    begin
      if (P1.DuelOutTimes = 0) then
      begin
        P1.SendClientMessage('Volte em at?5 segundos para a área de duelo.');
        P2.SendClientMessage
          ('Seu alvo est?fora da área de duelo. 5 Segundos para voltar.');
        Inc(P1.DuelOutTimes);
      end
      else
      begin
        Inc(P1.DuelOutTimes);
        if (P1.DuelOutTimes >= 5) then
        begin
          P1.Dueling := FALSE;
          P2.Dueling := FALSE;
          P1.DuelWinner := FALSE;
          P2.DuelWinner := True;
          Break;
        end;
      end;
    end
    else
      P1.DuelOutTimes := 0;
    if (P2.Base.PlayerCharacter.LastPos.Distance(P2.DuelFlagPosition) >
      DISTANCE_TO_WATCH) then
    begin
      if (P2.DuelOutTimes = 0) then
      begin
        P2.SendClientMessage('Volte em at?5 segundos para a área de duelo.');
        P1.SendClientMessage
          ('Seu alvo est?fora da área de duelo. 5 Segundos para voltar.');
        Inc(P2.DuelOutTimes);
      end
      else
      begin
        Inc(P2.DuelOutTimes);
        if (P2.DuelOutTimes >= 5) then
        begin
          P2.Dueling := FALSE;
          P1.Dueling := FALSE;
          P2.DuelWinner := FALSE;
          P1.DuelWinner := True;
          Break;
        end;
      end;
    end
    else
      P2.DuelOutTimes := 0;
    if (SecondsBetween(Now, P1.DuelInitTime) >= (300 + DUEL_TIME_WAIT)) then
    begin
      P2.Dueling := FALSE;
      P1.Dueling := FALSE;
      P2.DuelWinner := FALSE;
      P1.DuelWinner := FALSE;
      P1.SendClientMessage
        ('Duelo terminou. Limite máximo de tempo ?de 5 minutos.');
      P2.SendClientMessage
        ('Duelo terminou. Limite máximo de tempo ?de 5 minutos.');
      Break;
    end;
    if (P1.Base.Character.CurrentScore.CurHP <= 10) then
    begin
      P2.Dueling := FALSE;
      P1.Dueling := FALSE;
      P2.DuelWinner := True;
      P1.DuelWinner := FALSE;
      Break;
    end;
    if (P2.Base.Character.CurrentScore.CurHP <= 10) then
    begin
      P2.Dueling := FALSE;
      P1.Dueling := FALSE;
      P2.DuelWinner := FALSE;
      P1.DuelWinner := True;
      Break;
    end;
    Sleep(FDelay);
  end;
  if (P1.DuelWinner) then // jogador que enviou o duelo ganhou
  begin
    P1.SendDuelEnd(1); // win
    P2.SendDuelEnd(0); // lose
    P1.SendClientMessage(AnsiString(P1.Character.Base.Name) + ' venceu ' +
      AnsiString(P2.Character.Base.Name) + ' no duelo.');
    P2.RemoveDuelFlag;
    P1.RemoveDuelFlag;
    for i in P1.Base.VisiblePlayers do
    begin
      if not(Servers[Self.ChannelId].Players[i].Base.IsActive) then
        Continue;
      Servers[Self.ChannelId].Players[i].SendClientMessage
        (AnsiString(P1.Character.Base.Name) + ' venceu ' +
        AnsiString(P2.Character.Base.Name) + ' no duelo.');
      Servers[Self.ChannelId].Players[i].RemoveDuelFlag(P1.DuelFlagID);
    end;
  end
  else if (P2.DuelWinner) then // jogador desafiado ganhou
  begin
    P1.SendDuelEnd(0); // lose
    P2.SendDuelEnd(1); // win
    P2.SendClientMessage(AnsiString(P2.Character.Base.Name) + ' venceu ' +
      AnsiString(P1.Character.Base.Name) + ' no duelo.');
    P2.RemoveDuelFlag;
    P1.RemoveDuelFlag;
    for i in P2.Base.VisiblePlayers do
    begin
      if not(Servers[Self.ChannelId].Players[i].Base.IsActive) then
        Continue;
      Servers[Self.ChannelId].Players[i].SendClientMessage
        (AnsiString(P2.Character.Base.Name) + ' venceu ' +
        AnsiString(P1.Character.Base.Name) + ' no duelo.');
      Servers[Self.ChannelId].Players[i].RemoveDuelFlag(P1.DuelFlagID);
    end;
  end
  else // ninguem ganhou e deu empate, mandar lose pros 2
  begin
    P1.SendDuelEnd(0); // lose
    P2.SendDuelEnd(0); // lose
    P1.SendClientMessage('Duelo entre ' + AnsiString(P1.Character.Base.Name) +
      ' e ' + AnsiString(P2.Character.Base.Name) + ' deu empate.');
    P1.RemoveDuelFlag;
    P2.RemoveDuelFlag;
    for i in P1.Base.VisiblePlayers do
    begin
      if not(Servers[Self.ChannelId].Players[i].Base.IsActive) then
        Continue;
      Servers[Self.ChannelId].Players[i].SendClientMessage
        ('Duelo entre ' + AnsiString(P1.Character.Base.Name) + ' e ' +
        AnsiString(P2.Character.Base.Name) + ' deu empate.');
      Servers[Self.ChannelId].Players[i].RemoveDuelFlag(P1.DuelFlagID);
    end;
  end;
  P1.Base.RemoveAllDebuffs;
  P2.Base.RemoveAllDebuffs;
  P1.Base.ResolutoPoints := 0;
  P2.Base.ResolutoPoints := 0;
end;
{$ENDREGION}
{$REGION 'Create & Destroy'}
procedure TPlayer.Create(clientId: WORD; Channel: BYTE);
var
  address: TSockAddrIn;
  addressLength: Integer;
begin
  Self.ChannelIndex := Channel;
  Self.Unlogging := FALSE;
  PlayerThreadActive := True;
  Base.Create(@Self.Character.Base, clientId, Channel);
  getpeername(Self.Socket, TSockAddr(address), addressLength);
  Self.Ip := string(inet_ntoa(address.sin_addr));
  Self.FriendOpenWindowns := TDictionary<WORD, UInt64>.Create(6);
  Self.FriendOpenWindowns.Clear;
  ZeroMemory(@PlayerQuests, sizeof(PlayerQuests));
  ShoutTime := Now;
  SpawnedPran := 255;
  Self.LastTimeSaved := Now;
  Self.Base.LastReceivedAttack := Now;
  FaericForm := False;
  Self.SendedSendToWorld := False;
  // PlayerQuests := TDictionary<WORD, QuestDin>.Create;
  Self.EntityFriend := TEntityFriend.Create(@Self);
  Self.FriendList := TDictionary<UInt64, TFriend>.Create(50);
  {Self.PlayerSQL := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(Self.PlayerSQL.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.', TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.', TlogType.Error);
  end;
  }
end;
procedure TPlayer.Destroy;
var
  Guild: PGuild;
  i, ch, RlkSlot: BYTE;
  cid: WORD;
  ChangeChannelToken: TChangeChannelToken;
  Item: PItem;
  str_aux: String;
begin
  Self.Unlogging := True;
  // if (Self.Account.Header.IsActive = FALSE) then
  // Exit;
  // if (Self.Base.IsActive = FALSE) then
  // Exit;
  // Self.SendFriendLogout;
  { if (Self.Status >= Playing) then
    begin
    Self.Base.SendRemoveMob(0, 0, FALSE);
    if (Self.PartyIndex > 0) then
    begin
    Self.Party.RemoveMember(Self.Base.clientId);
    Self.Party.RefreshParty;
    Self.RefreshParty;
    end;
    if Self.Character.Base.GuildIndex > 0 then
    begin
    Guild := @Guilds[Self.Character.GuildSlot];
    Guild.SendMemberLogout(Self.Character.Index);
    if Guild.MemberInChest = Guild.FindMemberFromCharIndex(Self.Character.
    Index) then
    begin
    Guild.MemberInChest := $FF;
    Guild.LastChestActionDate := 0;
    end;
    end;
    end; }

  if(Self.Base.ClientID = 0) then
    Exit;

  if (Self.Status = TPlayerStatus.CharList) then
  begin
    for i := 0 to 2 do
    begin
      if (Self.Account.Characters[i].Base.Name = '') then
        Continue;
      Self.SaveCharOnCharRoom(i);
    end;
    Self.Account.Header.IsActive := FALSE;
    Self.SaveStatus(String(Self.Account.Header.Username));
    cid := Self.Base.clientId;
    ch := Self.Base.ChannelId;
    Self.Base.Destroy;
    FreeAndNil(Self.FriendOpenWindowns);
    FreeAndNil(Self.EntityFriend);
    FreeAndNil(Self.FriendList);
    //Self.PlayerSQL.Destroy;
    closesocket(Self.Socket);
    xdisconnected := True;
    // ZeroMemory(@Servers[ch].Players[cid], sizeof(TPlayer));
    Exit;
  end;
  if (Self.Status > TPlayerStatus.CharList) then
  begin
    case Self.spawnedPran of
      0:
        begin
          for I in Self.Base.VisiblePlayers do
          begin
            Self.SendPranUnspawn(0, i);
          end;
        end;
      1:
        begin
          for I in Self.Base.VisiblePlayers do
          begin
            Self.SendPranUnspawn(1, i);
          end;
        end;
    end;
    Self.SendFriendLogout;
    Self.Base.SendRemoveMob(0, 0, FALSE);
    if (Self.InDungeon) then
    begin
      if (Self.Base.clientId = Self.Party.Leader) then
      begin
        DungeonInstances[Self.DungeonInstanceID].Index := 0;
        DungeonInstances[Self.DungeonInstanceID].CreateTime := Now;
        DungeonInstances[Self.DungeonInstanceID].Party := nil;
        DungeonInstances[Self.DungeonInstanceID].DungeonID := 0;
        DungeonInstances[Self.DungeonInstanceID].Dificult := 0;
        ZeroMemory(@DungeonInstances[Self.DungeonInstanceID].MOBS,
          sizeof(DungeonInstances[Self.DungeonInstanceID].MOBS));
        DungeonInstances[Self.DungeonInstanceID].InstanceOnline := FALSE;
        for i in Self.Party.Members do
        begin
          if (i = Self.Base.clientId) then
            Continue;
          Servers[Self.ChannelIndex].Players[i].SendClientMessage
            ('O jogador [' + AnsiString(Self.Base.Character.Name) +
            '] era líder do grupo e se desconectou, todos foram expulsos do calabouço.');
          Servers[Self.ChannelIndex].Players[i].DungeonLobbyIndex := 0;
          Servers[Self.ChannelIndex].Players[i].DungeonLobbyDificult := 0;
          Servers[Self.ChannelIndex].Players[i].DungeonID := 0;
          Servers[Self.ChannelIndex].Players[i].DungeonIDDificult := 0;
          Servers[Self.ChannelIndex].Players[i].DungeonInstanceID := 0;
          Servers[Self.ChannelIndex].Players[i].InDungeon := FALSE;
          Servers[Self.ChannelIndex].Players[i]
            .Teleport(TPosition.Create(3399, 564));
        end;
      end
      else
      begin
        Self.DungeonLobbyIndex := 0;
        Self.DungeonLobbyDificult := 0;
        Self.DungeonID := 0;
        Self.DungeonIDDificult := 0;
        Self.DungeonInstanceID := 0;
        Self.InDungeon := FALSE;
        Self.Teleport(TPosition.Create(3399, 564));
        for i in Self.Party.Members do
        begin
          Servers[Self.ChannelIndex].Players[i].SendClientMessage
            ('O jogador [' + AnsiString(Self.Base.Character.Name) +
            '] se desconectou e foi expulso do calabouço.');
        end;
      end;
    end;
    if Self.Character.Base.GuildIndex > 0 then
    begin
      Guild := @Guilds[Self.Character.GuildSlot];
      Guild.SendMemberLogout(Self.Character.Index);
      if Guild.MemberInChest = Guild.FindMemberFromCharIndex(Self.Character.
        Index) then
      begin
        Guild.MemberInChest := $FF;
        Guild.LastChestActionDate := 0;
      end;
    end;
    if not(Self.DesconectedByOtherChannel) then
    begin
      if (Self.PartyIndex > 0) then
      begin
        Self.Party.RemoveMember(Self.Base.clientId);
        //Self.Party.RefreshParty;
        //Self.RefreshParty;
      end;
      while (TItemFunctions.GetItemSlotByItemType(Self, 40, INV_TYPE, 0) <> 255) do
      begin
        RlkSlot := TItemFunctions.GetItemSlotByItemType(Self, 40, INV_TYPE, 0);
        if(RlkSlot <> 255) then
        begin
          Item := @Self.Base.Character.Inventory[RlkSlot];
          Servers[Self.ChannelIndex].CreateMapObject(@Self, 320, Item.Index);
          {Servers[Self.ChannelIndex].SendServerMsg('O jogador ' +
            AnsiString(Self.Base.Character.Name) + ' dropou a relíquia <' +
            AnsiString(ItemList[Item.Index].Name) + '>.');}
          ZeroMemory(Item, sizeof(TItem));
          Self.Base.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, False);
        end;
      end;
      Self.Base.RemoveBuffByIndex(91);
    end
    else
    begin
      if (Self.PartyIndex > 0) then
      begin
        if(Self.Party.Leader = Self.Base.ClientID) then
        begin
          Self.Party.DestroyParty(Self.Base.ClientID);
          //Self.Party.RemoveMember(Self.Base.clientId);
          Self.Party.RefreshParty;
          Self.RefreshParty;
        end;
      end;
    end;

    if(Self.Base.Character.Equip[8].Index <> 0) then
    begin
      Self.Base.DestroyPet(Self.Base.PetClientID);
    end;

    Self.Account.Header.IsActive := FALSE;
    Self.Base.IsActive := FALSE;
    str_aux := String(Self.Account.Header.Username);
    //TFunctions.SaveAccountFile(Self.Account, str_aux);
    Self.SaveStatus(str_aux);
    Self.SaveCharOnCharRoom(Self.SelectedCharacterIndex);
    Self.SaveInGame(Self.SelectedCharacterIndex);
    cid := Self.Base.clientId;
    ch := Self.Base.ChannelId;
    Self.Base.Destroy;
    FreeAndNil(Self.FriendOpenWindowns);
    FreeAndNil(Self.EntityFriend);
    FreeAndNil(Self.FriendList);
    //Self.PlayerSQL.Destroy;
    // shutdown(Self.Socket, SD_BOTH);
    closesocket(Self.Socket);
    xdisconnected := True;
    // ZeroMemory(@Servers[ch].Players[cid], sizeof(TPlayer));
  end
  else if (Self.Status < TPlayerStatus.CharList) then
  begin
    Self.Account.Header.IsActive := FALSE;
    Self.Base.IsActive := FALSE;
    Self.SaveStatus(String(Self.Account.Header.Username));
    cid := Self.Base.clientId;
    ch := Self.Base.ChannelId;
    Self.Base.Destroy;
    FreeAndNil(Self.FriendOpenWindowns);
    FreeAndNil(Self.EntityFriend);
    FreeAndNil(Self.FriendList);
    //Self.PlayerSQL.Destroy;
    // shutdown(Self.Socket, SD_BOTH);
    closesocket(Self.Socket);
    xdisconnected := True;
    // ZeroMemory(@Servers[ch].Players[cid], sizeof(TPlayer));
  end;
end;
{$ENDREGION}
{$REGION 'TPlayer'}
function TPlayer.LoadAccountSql(Username: String): Boolean;
var
  PlayerSQLComp: TQuery;
begin
  Result := FALSE;
  PlayerSQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(PlayerSQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[LoadAccountSql]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[LoadAccountSql]', TlogType.Error);
    PlayerSQLComp.Destroy;
    Exit;
  end;
  try
    // if(Self.PlayerSQL.Query.Command.State =
    // FireDAC.Phys.Intf.TFDPhysCommandState.csExecuting) then
    // Self.PlayerSQL.MySQL.StartTransaction;
    PlayerSQLComp.SetQuery
      ('SELECT id, password_hash, last_token, coalesce(last_token_creation_time, "01/01/2020 00:00:01") as last_token_creation_time,'
      + ' nation, isactive, account_status, account_type, storage_gold, cash, coalesce(premium_time, "01/01/2020 00:00:01") as premium_time, ban_days'
      + ' FROM accounts WHERE username = "'+Username+'"');
    // Servers[Self.ChannelIndex].cSQL.AddParameter2('pusername', Username);
    PlayerSQLComp.Run();
    if (PlayerSQLComp.Query.IsEmpty) then
    begin
      PlayerSQLComp.Destroy;
      Exit;
    end;
    Self.Account.Header.AccountId := PlayerSQLComp.Query.FieldByName('id')
      .AsInteger;
    Self.Account.Header.Username := String(Username);
    Self.Account.Header.Password :=
      ShortString(PlayerSQLComp.Query.FieldByName('password_hash').AsString);
    AnsiStrings.StrPLCopy(Self.Account.Header.Token.Token,
      AnsiString(PlayerSQLComp.Query.FieldByName('last_token').AsString), 32);
    Self.Account.Header.Token.CreationTime :=
      StrToDateTime(PlayerSQLComp.Query.FieldByName('last_token_creation_time')
      .AsString);
    Self.Account.Header.Nation :=
      TCitizenship(PlayerSQLComp.Query.FieldByName('nation').AsInteger);
    Self.Account.Header.IsActive :=
      (PlayerSQLComp.Query.FieldByName('isactive').AsInteger).ToBoolean;
    Self.Account.Header.AccountStatus :=
      PlayerSQLComp.Query.FieldByName('account_status').AsInteger;
    Self.Account.Header.AccountType :=
      TAccountType(PlayerSQLComp.Query.FieldByName('account_type').AsInteger);
    Self.Account.Header.Storage.Gold := PlayerSQLComp.Query.FieldByName
      ('storage_gold').AsInteger;
    Self.Account.Header.CashInventory.Cash := PlayerSQLComp.Query.FieldByName
      ('cash').AsInteger;
    //if(PlayerSQLComp.Query.FieldByName('premium_time').AsString = '') then
      //Self.Account.Header.PremiumTime := StrToDateTime('01/01/2020 00:00:00')
   // else
      Self.Account.Header.PremiumTime :=
        StrToDateTime(PlayerSQLComp.Query.FieldByName('premium_time').AsString);
    Self.Account.Header.BanDays := PlayerSQLComp.Query.FieldByName('ban_days')
      .AsInteger;
    //Self.Account.Header.IsFounder := (PlayerSQLComp.Query.FieldByName('isfounder')
      //.AsInteger > 0);
    //if(Self.Account.Header.IsFounder) then
      //Self.Account.Header.FounderLevel := PlayerSQLComp.Query.FieldByName('isfounder')
      //.AsInteger;
    // Self.PlayerSQL.MySQL.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Load Account error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' + Username + '] ' +
        DateTimeToStr(Now) + '.', TlogType.Error);
      //Self.PlayerSQL.Query.Connection.Rollback;
    end;
  end;
  PlayerSQLComp.Destroy;
  Result := True;
end;
function TPlayer.LoadAccSQL(Username: String): Boolean;
var
  CharCount: Integer;
  Slot: Integer;
  ItemAmount: Integer;
  ItemSlot: Integer;
  i: Integer;
  J: Integer;
  SQLComp: TQuery;
begin
  Result := FALSE;
  if not(Self.LoadAccountSql(Username)) then
  begin
    Exit;
  end;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[LoadAccSQL]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[LoadAccSQL]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    // Self.PlayerSQL.MySQL.StartTransaction;
    SQLComp.SetQuery
      ('SELECT id, slot, numeric_errors, deleted, numeric_token, name, '
      + 'classinfo, strength, agility, intelligence, constitution, luck, status, '
      + 'altura, tronco, perna, corpo, curhp, curmp, honor, killpoint, infamia, '
      + 'skillpoint, experience, level, guildindex, gold, creationtime, ' +
      'numeric_token, logintime, speedmove, rotation, lastlogin, loggedtime, ' +
      'playerkill, posx, posy, deleted, delete_time, active_title ' +
      'FROM characters WHERE owner_accid = '+Self.Account.Header.AccountId.ToString+
      ' LIMIT 3');
    // PlayerSQL.AddParameter2('powner_accid', Self.Account.Header.AccountId);
    SQLComp.Run();
    CharCount := SQLComp.Query.RecordCount;
    if (CharCount = 0) then
    begin
      // Self.PlayerSQL.MySQL.Commit;
      SQLComp.Destroy;
      Result := True;
      Exit;
    end;
    for i := 0 to (CharCount - 1) do
    begin
      Slot := SQLComp.Query.FieldByName('slot').AsInteger;
      Self.Account.Header.NumError[Slot] :=
        (SQLComp.Query.FieldByName('numeric_errors').AsInteger);
      Self.Account.Header.PlayerDelete[Slot] :=
        Boolean(SQLComp.Query.FieldByName('deleted').AsInteger);
      Self.Account.Header.NumericToken[Slot] :=
        ShortString(SQLComp.Query.FieldByName('numeric_token').AsString);
      Self.Account.Characters[Slot].Index := SQLComp.Query.FieldByName('id')
        .AsInteger;
      AnsiStrings.StrPLCopy(Self.Account.Characters[Slot].Base.Name,
        AnsiString(SQLComp.Query.FieldByName('name').AsString), 16);
      Self.Account.Characters[Slot].Base.CharIndex := Self.Account.Characters
        [Slot].Index;
      // PlayerSQL.Query.FieldByName('slot').AsInteger;
      case Self.Account.Header.Nation of
        TCitizenship.None: Self.Account.Characters[Slot].Base.Nation:=0;
        TCitizenship.Server1: Self.Account.Characters[Slot].Base.Nation:=1;
        TCitizenship.Server2: Self.Account.Characters[Slot].Base.Nation:=2;
        TCitizenship.Server3: Self.Account.Characters[Slot].Base.Nation:=3;
      end;
      Self.Account.Characters[Slot].Base.ClassInfo :=
        (SQLComp.Query.FieldByName('classinfo').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.Str :=
        (SQLComp.Query.FieldByName('strength').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.agility :=
        (SQLComp.Query.FieldByName('agility').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.Int :=
        (SQLComp.Query.FieldByName('intelligence').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.Cons :=
        (SQLComp.Query.FieldByName('constitution').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.Luck :=
        (SQLComp.Query.FieldByName('luck').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.Status :=
        (SQLComp.Query.FieldByName('status').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.Sizes.Altura :=
        (SQLComp.Query.FieldByName('altura').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.Sizes.Tronco :=
        (SQLComp.Query.FieldByName('tronco').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.Sizes.Perna :=
        (SQLComp.Query.FieldByName('perna').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.Sizes.Corpo :=
        (SQLComp.Query.FieldByName('corpo').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.CurHP :=
        SQLComp.Query.FieldByName('curhp').AsInteger;
      Self.Account.Characters[Slot].Base.CurrentScore.CurMp :=
        SQLComp.Query.FieldByName('curmp').AsInteger;
      Self.Account.Characters[Slot].Base.CurrentScore.Honor :=
        SQLComp.Query.FieldByName('honor').AsInteger;
      Self.Account.Characters[Slot].Base.CurrentScore.KillPoint :=
        SQLComp.Query.FieldByName('killpoint').AsInteger;
      Self.Account.Characters[Slot].Base.CurrentScore.Infamia :=
        (SQLComp.Query.FieldByName('infamia').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.SkillPoint :=
        (SQLComp.Query.FieldByName('skillpoint').AsInteger);
      Self.Account.Characters[Slot].Base.Exp :=
        SQLComp.Query.FieldByName('experience').AsLargeInt;
      Self.Account.Characters[Slot].Base.Level :=
        (SQLComp.Query.FieldByName('level').AsInteger);
      Self.Account.Characters[Slot].Base.GuildIndex :=
        SQLComp.Query.FieldByName('guildindex').AsInteger;
      Self.Account.Characters[Slot].Base.Gold :=
        SQLComp.Query.FieldByName('gold').AsLargeInt;
      Self.Account.Characters[Slot].Base.CreationTime :=
        TFunctions.DateTimeToUNIXTimeFAST
        (StrToDateTime(SQLComp.Query.FieldByName('creationtime').AsString));
      AnsiStrings.StrPLCopy(Self.Account.Characters[Slot].Base.Numeric,
        AnsiString(SQLComp.Query.FieldByName('numeric_token').AsString), 4);
      Self.Account.Characters[Slot].Base.LoginTime :=
        SQLComp.Query.FieldByName('logintime').AsInteger;
      Self.Account.Characters[Slot].SpeedMove :=
        (SQLComp.Query.FieldByName('speedmove').AsInteger);
      Self.Account.Characters[Slot].Rotation :=
        (SQLComp.Query.FieldByName('rotation').AsInteger);
     // Self.Account.Characters[Slot].LastLogin :=
        //StrToDateTime(PlayerSQL.Query.FieldByName('lastlogin')
        //.AsString);
      Self.Account.Characters[Slot].LoggedTime :=
        SQLComp.Query.FieldByName('loggedtime').AsInteger;
      Self.Account.Characters[Slot].PlayerKill :=
        Boolean(SQLComp.Query.FieldByName('playerkill').AsInteger);
      Self.Account.Characters[Slot].LastPos.X :=
        SQLComp.Query.FieldByName('posx').AsSingle;
      Self.Account.Characters[Slot].LastPos.Y :=
        SQLComp.Query.FieldByName('posy').AsSingle;
      Self.Account.CharactersDelete[Slot] :=
        (SQLComp.Query.FieldByName('deleted').AsInteger).ToBoolean;
      Self.Account.CharactersDeleteTime[Slot] :=
        ShortString(SQLComp.Query.FieldByName('delete_time').AsString);
      Self.Account.Characters[Slot].ActiveTitle.Index :=
        (SQLComp.Query.FieldByName('active_title').AsInteger);

      if not(i = (CharCount - 1)) then
      begin
        SQLComp.Query.Next;
      end;
    end;
    for i := 0 to (CharCount - 1) do
    begin
      SQLComp.SetQuery
        ('SELECT slot, item_id, app, identific, effect1_index, effect2_index, '
        + 'effect3_index, effect1_value, effect2_value, effect3_value, min, max, refine, time '
        + 'FROM items WHERE owner_id = '+Self.Account.Characters[i].Index.ToString+
        ' AND slot_type=0 LIMIT 16');
      // PlayerSQL.AddParameter2('powner_id', Self.Account.Characters[i].Index);
      SQLComp.Run();
      ItemAmount := SQLComp.Query.RecordCount;
      Slot := i;
      if not(ItemAmount = 0) then
      begin
        for J := 0 to (ItemAmount - 1) do
        begin
          ItemSlot := SQLComp.Query.FieldByName('slot').AsInteger;
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].Index :=
            (SQLComp.Query.FieldByName('item_id').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].APP :=
            (SQLComp.Query.FieldByName('app').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].Identific :=
            SQLComp.Query.FieldByName('identific').AsInteger;
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].Effects.Index[0] :=
            (SQLComp.Query.FieldByName('effect1_index').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].Effects.Index[1] :=
            (SQLComp.Query.FieldByName('effect2_index').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].Effects.Index[2] :=
            (SQLComp.Query.FieldByName('effect3_index').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].Effects.Value[0] :=
            (SQLComp.Query.FieldByName('effect1_value').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].Effects.Value[1] :=
            (SQLComp.Query.FieldByName('effect2_value').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].Effects.Value[2] :=
            (SQLComp.Query.FieldByName('effect3_value').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].MIN :=
            (SQLComp.Query.FieldByName('min').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].MAX :=
            (SQLComp.Query.FieldByName('max').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].Refi :=
            (SQLComp.Query.FieldByName('refine').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].Time :=
            (SQLComp.Query.FieldByName('time').AsInteger);
          if not(j = (ItemAmount - 1)) then
          begin
            SQLComp.Query.Next;
          end;
        end;
      end;
    end;
    // Self.PlayerSQL.MySQL.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Load Character to room(loadaccsql) error. msg[' +
        E.Message + ' : ' + E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      //Self.PlayerSQL.Query.Connection.Rollback;
    end;
  end;
  SQLComp.Destroy;
  Result := True;
end;
function TPlayer.LoadCharacterMisc(CharID: Integer): Boolean;
var
  ID: Integer;
  ItemAmount, ItemAmount2: Integer;
  i, J, k, z: Integer;
  ItemSlot: Integer;
  SkillType: Integer;
  CharCount: BYTE;
  QuestIndex: WORD;
  MySQLComp: TQuery;
begin
  TFunctions.ManageAccountsBackupCount(Self, Self.Account.Header.Username);

  MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(MySQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[LoadCharacterMisc]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[LoadCharacterMisc]', TlogType.Error);
    MySQLComp.Destroy;
    Exit;
  end;

  if (Self.Account.Characters[CharID].Base.Exp = 0) then
  begin
    // Self.PlayerSQL.MySQL.StartTransaction;
    MySQLComp.SetQuery
      ('SELECT id, slot FROM characters WHERE owner_accid = '+
      Self.Account.Header.AccountId.ToString+' order by slot LIMIT 3');
    // PlayerSQL.AddParameter2('powner_accid', Self.Account.Header.AccountId);
    MySQLComp.Run();
    CharCount := MySQLComp.Query.RecordCount;
    if (CharCount = 0) then
    begin
      // Self.PlayerSQL.MySQL.Commit;
      MySQLComp.Destroy;
      Result := True;
      Exit;
    end;
    MySQLComp.Query.First;
    for i := 0 to (CharCount - 1) do
    begin
      Self.Account.Characters[MySQLComp.Query.FieldByName('slot')
        .AsInteger].Index := MySQLComp.Query.FieldByName('id')
        .AsInteger;
      MySQLComp.Query.Next;
     { case i of
        0:
          begin
            MySQLComp.Query.Next;
          end;
        1:
          begin
            MySQLComp.Query.Next;
            MySQLComp.Query.Next;
          end;
        2:
          begin
            //
          end;
      end;}
    end;
    // Self.PlayerSQL.MySQL.Commit;
  end;
  for z := 0 to 2 do
  begin
    if(Self.Account.Characters[z].Index = 0) then
      Continue;

    CharID := z;

    ID := Self.Account.Characters[CharID].Index;

    try
      { Inventory }
      // Self.PlayerSQL.MySQL.StartTransaction;
      MySQLComp.SetQuery
        ('SELECT slot, item_id, app, identific, effect1_index, effect2_index, '
        + 'effect3_index, effect1_value, effect2_value, effect3_value, min, max, '
        + 'refine, time FROM items WHERE owner_id = '+ID.ToString+
        ' AND slot_type=1 order by slot limit 64');
      // PlayerSQL.AddParameter2('powner_id', ID);
      MySQLComp.Run();
      ItemAmount := MySQLComp.Query.RecordCount;
      if not(ItemAmount = 0) then
      begin
        MySQLComp.Query.First;
        for i := 0 to ItemAmount-1 do
        begin
          if(MySQLComp.Query.FieldByName('item_id').AsInteger = 0) then
          begin
            MySQLComp.Query.Next;
            Continue;
          end;
          ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger;
          Self.Account.Characters[CharID].Base.Inventory[ItemSlot].Index :=
            (MySQLComp.Query.FieldByName('item_id').AsInteger);
          Self.Account.Characters[CharID].Base.Inventory[ItemSlot].APP :=
            (MySQLComp.Query.FieldByName('app').AsInteger);
          Self.Account.Characters[CharID].Base.Inventory[ItemSlot].Identific :=
            MySQLComp.Query.FieldByName('identific').AsInteger;
          Self.Account.Characters[CharID].Base.Inventory[ItemSlot].Effects.
            Index[0] := (MySQLComp.Query.FieldByName('effect1_index')
            .AsInteger);
          Self.Account.Characters[CharID].Base.Inventory[ItemSlot].Effects.
            Index[1] := (MySQLComp.Query.FieldByName('effect2_index')
            .AsInteger);
          Self.Account.Characters[CharID].Base.Inventory[ItemSlot].Effects.
            Index[2] := (MySQLComp.Query.FieldByName('effect3_index')
            .AsInteger);
          Self.Account.Characters[CharID].Base.Inventory[ItemSlot].Effects.Value
            [0] := (MySQLComp.Query.FieldByName('effect1_value').AsInteger);
          Self.Account.Characters[CharID].Base.Inventory[ItemSlot].Effects.Value
            [1] := (MySQLComp.Query.FieldByName('effect2_value').AsInteger);
          Self.Account.Characters[CharID].Base.Inventory[ItemSlot].Effects.Value
            [2] := (MySQLComp.Query.FieldByName('effect3_value').AsInteger);
          Self.Account.Characters[CharID].Base.Inventory[ItemSlot].MIN :=
            (MySQLComp.Query.FieldByName('min').AsInteger);
          Self.Account.Characters[CharID].Base.Inventory[ItemSlot].MAX :=
            (MySQLComp.Query.FieldByName('max').AsInteger);
          Self.Account.Characters[CharID].Base.Inventory[ItemSlot].Refi :=
            (MySQLComp.Query.FieldByName('refine').AsInteger);
          Self.Account.Characters[CharID].Base.Inventory[ItemSlot].Time :=
            (MySQLComp.Query.FieldByName('time').AsInteger);
          {if(Self.Account.Characters[CharID].Base.Inventory[ItemSlot].APP = 0) then
             Self.Account.Characters[CharID].Base.Inventory[ItemSlot].APP :=
              Self.Account.Characters[CharID].Base.Inventory[ItemSlot].Index;}

          MySQLComp.Query.Next;
        end;
      end;
      if(Self.Account.Characters[CharID].Base.Inventory[60].Index = 0) then
      begin
        Self.Account.Characters[CharID].Base.Inventory[60].Index := 5300;
        Self.Account.Characters[CharID].Base.Inventory[60].APP := 5300;
        Self.Account.Characters[CharID].Base.Inventory[60].Refi := 1;
      end;
      // Self.PlayerSQL.MySQL.Commit;
    except
      on E: Exception do
      begin
        Logger.Write('MYSQL Load misc Inventory error. msg[' + E.Message + ' : ' +
          E.GetBaseException.Message + '] username[' +
          String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
          TlogType.Error);
        //Self.PlayerSQL.Query.Connection.Rollback;
      end;
    end;
    { Skills }
    try
      // Self.PlayerSQL.MySQL.StartTransaction;
      MySQLComp.SetQuery
        ('SELECT slot, type, item, level FROM skills WHERE ' +
        'owner_charid = '+ID.ToString+' order by slot LIMIT 60');
      // PlayerSQL.AddParameter2('powner_charid', ID);
      MySQLComp.Run();
      ItemAmount := MySQLComp.Query.RecordCount;
      if not(ItemAmount = 0) then
      begin
        MySQLComp.Query.First;
        for i := 0 to ItemAmount-1 do
        begin
          if(MySQLComp.Query.FieldByName('item').AsInteger = 0) then
          begin
            MySQLComp.Query.Next;
            Continue;
          end;
          ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger;
          SkillType := MySQLComp.Query.FieldByName('type').AsInteger;
          if (SkillType = 1) then
          begin
            Self.Account.Characters[CharID].Skills.Basics[ItemSlot].Index :=
              (MySQLComp.Query.FieldByName('item').AsInteger);
            Self.Account.Characters[CharID].Skills.Basics[ItemSlot].Level :=
              (MySQLComp.Query.FieldByName('level').AsInteger);
          end
          else if (SkillType = 2) then
          begin
            Self.Account.Characters[CharID].Skills.Others[ItemSlot].Index :=
              (MySQLComp.Query.FieldByName('item').AsInteger);
            Self.Account.Characters[CharID].Skills.Others[ItemSlot].Level :=
              (MySQLComp.Query.FieldByName('level').AsInteger);
          end;

          MySQLComp.Query.Next;
        end;
      end;
      // Self.PlayerSQL.MySQL.Commit;
    except
      on E: Exception do
      begin
        Logger.Write('MYSQL Load misc Skills error. msg[' + E.Message + ' : ' +
          E.GetBaseException.Message + '] username[' +
          String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
          TlogType.Error);
        //Self.PlayerSQL.Query.Connection.Rollback;
      end;
    end;
    { Items on Bar }
    try
      // Self.PlayerSQL.MySQL.StartTransaction;
      MySQLComp.SetQuery
        ('SELECT slot, item FROM itembars WHERE owner_charid = '+ID.ToString+
        ' order by slot LIMIT 32');
      // PlayerSQL.AddParameter2('powner_charid', ID);
      MySQLComp.Run();
      ItemAmount := MySQLComp.Query.RecordCount;
      if not(ItemAmount = 0) then
      begin
        MySQLComp.Query.First;
        for i := 0 to ItemAmount-1 do
        begin
          if(MySQLComp.Query.FieldByName('item').AsInteger = 0) then
          begin
            MySQLComp.Query.Next;
            Continue;
          end;
          ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger;
          Self.Account.Characters[CharID].Base.ItemBar[ItemSlot] :=
            (MySQLComp.Query.FieldByName('item').AsInteger);
          MySQLComp.Query.Next;
        end;
      end;
      // Self.PlayerSQL.MySQL.Commit;
    except
      on E: Exception do
      begin
        Logger.Write('MYSQL Load misc Items on bar error. msg[' + E.Message +
          ' : ' + E.GetBaseException.Message + '] username[' +
          String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
          TlogType.Error);
        //Self.PlayerSQL.Query.Connection.Rollback;
      end;
    end;

    { Buffs }
    try
        // Self.PlayerSQL.MySQL.StartTransaction;
      MySQLComp.SetQuery
        ('SELECT buff_index, buff_time FROM buffs WHERE owner_charid = '+
        ID.ToString+' LIMIT 60');
      // PlayerSQL.AddParameter2('powner_charid', ID);
      MySQLComp.Run();
      ItemAmount := MySQLComp.Query.RecordCount;
      MySQLComp.Query.First;
      for i := 0 to (ItemAmount-1) do
      begin
        if(MySQLComp.Query.FieldByName('buff_index').AsInteger = 0) then
        begin
          MySQLComp.Query.Next;
          Continue;
        end;
        Self.Account.Characters[CharID].Buffs[i].Index :=
          MySQLComp.Query.FieldByName('buff_index').AsInteger;
        Self.Account.Characters[CharID].Buffs[i].CreationTime :=
          StrToDateTime(MySQLComp.Query.FieldByName('buff_time').AsString);
        MySQLComp.Query.Next;
      end;


      // Self.PlayerSQL.MySQL.Commit;
    except
      on E: Exception do
      begin
        Logger.Write('MYSQL Load misc Buffs error. msg[' + E.Message + ' : ' +
          E.GetBaseException.Message + '] username[' +
          String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
          TlogType.Error);
       // Self.PlayerSQL.Query.Connection.Rollback;
      end;
    end;

    if(z = Self.SelectedCharacterIndex) then
    begin
      { Quests }
      try
        // Self.PlayerSQL.MySQL.StartTransaction;

        MySQLComp.SetQuery
          ('SELECT questid, isdone, req1, req2, req3, req4, req5, updated_at FROM quests '
          + 'WHERE charid = '+ ID.ToString);
        // PlayerSQL.AddParameter2('pcharid', ID);
        MySQLComp.Run();
        ItemAmount := MySQLComp.Query.RecordCount;
        if not(ItemAmount = 0) then
        begin
          MySQLComp.Query.First;
          for i := 0 to ItemAmount-1 do
          begin
            QuestIndex := Self.SearchEmptyQuestIndex;
            if(QuestIndex = 255) then
              Continue;
            Self.PlayerQuests[QuestIndex].ID := MySQLComp.Query.FieldByName
              ('questid').AsInteger;
            Self.PlayerQuests[QuestIndex].IsDone :=
              (MySQLComp.Query.FieldByName('isdone').AsInteger).ToBoolean;
            Self.PlayerQuests[QuestIndex].Complete[0] :=
              (MySQLComp.Query.FieldByName('req1').AsInteger);
            Self.PlayerQuests[QuestIndex].Complete[1] :=
              (MySQLComp.Query.FieldByName('req2').AsInteger);
            Self.PlayerQuests[QuestIndex].Complete[2] :=
              (MySQLComp.Query.FieldByName('req3').AsInteger);
            Self.PlayerQuests[QuestIndex].Complete[3] :=
              (MySQLComp.Query.FieldByName('req4').AsInteger);
            Self.PlayerQuests[QuestIndex].Complete[4] :=
              (MySQLComp.Query.FieldByName('req5').AsInteger);
            Self.PlayerQuests[QuestIndex].UpdatedAt :=
             TFunctions.UNIXTimeToDateTimeFAST(MySQLComp.Query.FieldByName('updated_at').AsLargeInt);
            // Self.PlayerQuests[QuestIndex].CreatedAt :=
            // StrToDateTime(PlayerSQL.Query.FieldByName('created_at').AsString);
            for J := Low(_Quests) to High(_Quests) do
            begin
              if (_Quests[J].QuestID = DWORD(Self.PlayerQuests[QuestIndex].ID)) then
              begin
                Move(_Quests[J], Self.PlayerQuests[QuestIndex].Quest,
                  sizeof(TQuestMisc));
                Break;
              end;
            end;

            MySQLComp.Query.Next;
          end;
        end;

        // Self.PlayerSQL.MySQL.Commit;
      except
        on E: Exception do
        begin
          Logger.Write('MYSQL Load misc Quests error. msg[' + E.Message + ' : ' +
            E.GetBaseException.Message + '] username[' +
            String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
            TlogType.Error);
          //Self.PlayerSQL.Query.Connection.Rollback;
        end;
      end;

      { Titles }
      try
        // Self.PlayerSQL.MySQL.StartTransaction;

        MySQLComp.SetQuery
          ('SELECT title_index, title_level, title_progress FROM titles WHERE '
          + 'owner_charid = '+ID.ToString);
        // PlayerSQL.AddParameter2('powner_charid', ID);
        MySQLComp.Run();
        ItemAmount := MySQLComp.Query.RecordCount;
        if not(ItemAmount = 0) then
        begin
          MySQLComp.Query.First;
          for i := 0 to ItemAmount-1 do
          begin
            if(MySQLComp.Query.FieldByName('title_index').AsInteger = 0) then
            begin
              MySQLComp.Query.Next;
              Continue;
            end;
            Self.Character.Titles[i].Index :=
              (MySQLComp.Query.FieldByName('title_index').AsInteger);
            Self.Character.Titles[i].Level :=
              (MySQLComp.Query.FieldByName('title_level').AsInteger);
            Self.Character.Titles[i].Progress :=
              (MySQLComp.Query.FieldByName('title_progress').AsInteger);
            if (Self.Account.Characters[CharID].ActiveTitle.
              Index = Self.Character.Titles[i].Index) then
            begin
              Self.Account.Characters[CharID].ActiveTitle.Level :=
                Self.Character.Titles[i].Level;
            end;
            MySQLComp.Query.Next;
          end;
        end;

        // Self.PlayerSQL.MySQL.Commit;
      except
        on E: Exception do
        begin
          Logger.Write('MYSQL Load misc Titles error. msg[' + E.Message + ' : ' +
            E.GetBaseException.Message + '] username[' +
            String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
            TlogType.Error);
         // Self.PlayerSQL.Query.Connection.Rollback;
        end;
      end;
    end;

  end;



  try
   { Prans }
      // Self.PlayerSQL.MySQL.StartTransaction;
    MySQLComp.SetQuery
      ('SELECT id, item_id, name, level, class, hp, max_hp, mp, ' +
      'max_mp, xp, def_p, def_m, food, devotion, p_cute, p_smart, p_sexy, p_energetic, '
      + 'p_tough, p_corrupt, width, chest, leg, created_at, updated_at FROM ' +
      'prans WHERE acc_id = '+Self.Account.Header.AccountId.ToString+
      ' order by id LIMIT 2');
    // PlayerSQL.AddParameter2('pacc_id', Self.Account.Header.AccountId);
    MySQLComp.Run();
    ItemAmount := MySQLComp.Query.RecordCount;
    if not(ItemAmount = 0) then
    begin
      J := 0;
      MySQLComp.Query.First;
      for i := 0 to ItemAmount-1 do
      begin
        if (J = 0) then
        begin // pran1
          Account.Header.Pran1.Iddb := MySQLComp.Query.FieldByName('id')
            .AsInteger;
          Account.Header.Pran1.ItemID := MySQLComp.Query.FieldByName('item_id')
            .AsInteger;
          Account.Header.Pran1.AccId := Self.Account.Header.AccountId;
          AnsiStrings.StrPLCopy(Account.Header.Pran1.Name,
            AnsiString(MySQLComp.Query.FieldByName('name').AsString), 16);
          Account.Header.Pran1.Level := MySQLComp.Query.FieldByName('level')
            .AsInteger;
          Account.Header.Pran1.ClassPran := MySQLComp.Query.FieldByName('class')
            .AsInteger;
          Account.Header.Pran1.CurHP := MySQLComp.Query.FieldByName('hp')
            .AsInteger;
          Account.Header.Pran1.MaxHp := MySQLComp.Query.FieldByName('max_hp')
            .AsInteger;
          Account.Header.Pran1.CurMp := MySQLComp.Query.FieldByName('mp')
            .AsInteger;
          Account.Header.Pran1.MaxMP := MySQLComp.Query.FieldByName('max_mp')
            .AsInteger;
          Account.Header.Pran1.Exp := MySQLComp.Query.FieldByName('xp')
            .AsInteger;
          Account.Header.Pran1.DefFis := MySQLComp.Query.FieldByName('def_p')
            .AsInteger;
          Account.Header.Pran1.DefMag := MySQLComp.Query.FieldByName('def_m')
            .AsInteger;
          Account.Header.Pran1.Food := MySQLComp.Query.FieldByName('food')
            .AsInteger;
          Account.Header.Pran1.Devotion := MySQLComp.Query.FieldByName
            ('devotion').AsInteger;
          Account.Header.Pran1.Personality.Cute :=
            MySQLComp.Query.FieldByName('p_cute').AsInteger;
          Account.Header.Pran1.Personality.Smart :=
            MySQLComp.Query.FieldByName('p_smart').AsInteger;
          Account.Header.Pran1.Personality.Sexy :=
            MySQLComp.Query.FieldByName('p_sexy').AsInteger;
          Account.Header.Pran1.Personality.Energetic :=
            MySQLComp.Query.FieldByName('p_energetic').AsInteger;
          Account.Header.Pran1.Personality.Tough :=
            MySQLComp.Query.FieldByName('p_tough').AsInteger;
          Account.Header.Pran1.Personality.Corrupt :=
            MySQLComp.Query.FieldByName('p_corrupt').AsInteger;
          Account.Header.Pran1.Width := MySQLComp.Query.FieldByName('width')
            .AsInteger;
          Account.Header.Pran1.Chest := MySQLComp.Query.FieldByName('chest')
            .AsInteger;
          Account.Header.Pran1.Leg := MySQLComp.Query.FieldByName('leg')
            .AsInteger;
          Account.Header.Pran1.CreatedAt := MySQLComp.Query.FieldByName
            ('created_at').AsInteger;
          Account.Header.Pran1.Updated_at := MySQLComp.Query.FieldByName
            ('updated_at').AsInteger;
          MySQLComp.SetQuery
            ('SELECT slot, item_id, app, identific, effect1_index, effect2_index, '
            + 'effect3_index, effect1_value, effect2_value, effect3_value, min, max, '
            + 'refine, time FROM items WHERE slot_type = '+
            PRAN_EQUIP_TYPE.ToString+' AND ' +
            'owner_id = '+Account.Header.Pran1.Iddb.ToString+
            ' order by slot LIMIT 16');
          // PlayerSQL.AddParameter2('pslot_type', PRAN_EQUIP_TYPE);
          // PlayerSQL.AddParameter2('powner_id', Account.Header.Pran1.Iddb);
          MySQLComp.Run();
          ItemAmount2 := MySQLComp.Query.RecordCount;
          if not(ItemAmount2 = 0) then
          begin
            MySQLComp.Query.First;
            for k := 0 to ItemAmount2-1 do
            begin
              ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger;
              Account.Header.Pran1.Equip[ItemSlot].Index :=
                MySQLComp.Query.FieldByName('item_id').AsInteger;
              Account.Header.Pran1.Equip[ItemSlot].APP :=
                MySQLComp.Query.FieldByName('app').AsInteger;
              Account.Header.Pran1.Equip[ItemSlot].Identific :=
                MySQLComp.Query.FieldByName('identific').AsInteger;
              Account.Header.Pran1.Equip[ItemSlot].Effects.Index[0] :=
                MySQLComp.Query.FieldByName('effect1_index').AsInteger;
              Account.Header.Pran1.Equip[ItemSlot].Effects.Index[1] :=
                MySQLComp.Query.FieldByName('effect2_index').AsInteger;
              Account.Header.Pran1.Equip[ItemSlot].Effects.Index[2] :=
                MySQLComp.Query.FieldByName('effect3_index').AsInteger;
              Account.Header.Pran1.Equip[ItemSlot].Effects.Value[0] :=
                MySQLComp.Query.FieldByName('effect1_value').AsInteger;
              Account.Header.Pran1.Equip[ItemSlot].Effects.Value[1] :=
                MySQLComp.Query.FieldByName('effect2_value').AsInteger;
              Account.Header.Pran1.Equip[ItemSlot].Effects.Value[2] :=
                MySQLComp.Query.FieldByName('effect3_value').AsInteger;
              Account.Header.Pran1.Equip[ItemSlot].MIN :=
                MySQLComp.Query.FieldByName('min').AsInteger;
              Account.Header.Pran1.Equip[ItemSlot].MAX :=
                MySQLComp.Query.FieldByName('max').AsInteger;
              Account.Header.Pran1.Equip[ItemSlot].Refi :=
                MySQLComp.Query.FieldByName('refine').AsInteger;
              Account.Header.Pran1.Equip[ItemSlot].Time :=
                MySQLComp.Query.FieldByName('time').AsInteger;
              MySQLComp.Query.Next;
            end;
          end;
          MySQLComp.SetQuery
            ('SELECT slot, item_id, app, identific, effect1_index, effect2_index, '
            + 'effect3_index, effect1_value, effect2_value, effect3_value, min, max, '
            + 'refine, time FROM items WHERE slot_type= '+
            PRAN_INV_TYPE.ToString+' AND ' +
            'owner_id = '+Account.Header.Pran1.Iddb.ToString+
            ' order by slot LIMIT 42');
          // PlayerSQL.AddParameter2('pslot_type', PRAN_INV_TYPE);
          // PlayerSQL.AddParameter2('powner_id', Account.Header.Pran1.Iddb);
          MySQLComp.Run();
          ItemAmount2 := MySQLComp.Query.RecordCount;
          if not(ItemAmount2 = 0) then
          begin
            MySQLComp.Query.First;
            for k := 0 to ItemAmount2-1 do
            begin
              ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger;
              Account.Header.Pran1.Inventory[ItemSlot].Index :=
                MySQLComp.Query.FieldByName('item_id').AsInteger;
              Account.Header.Pran1.Inventory[ItemSlot].APP :=
                MySQLComp.Query.FieldByName('app').AsInteger;
              Account.Header.Pran1.Inventory[ItemSlot].Identific :=
                MySQLComp.Query.FieldByName('identific').AsInteger;
              Account.Header.Pran1.Inventory[ItemSlot].Effects.Index[0] :=
                MySQLComp.Query.FieldByName('effect1_index').AsInteger;
              Account.Header.Pran1.Inventory[ItemSlot].Effects.Index[1] :=
                MySQLComp.Query.FieldByName('effect2_index').AsInteger;
              Account.Header.Pran1.Inventory[ItemSlot].Effects.Index[2] :=
                MySQLComp.Query.FieldByName('effect3_index').AsInteger;
              Account.Header.Pran1.Inventory[ItemSlot].Effects.Value[0] :=
                MySQLComp.Query.FieldByName('effect1_value').AsInteger;
              Account.Header.Pran1.Inventory[ItemSlot].Effects.Value[1] :=
                MySQLComp.Query.FieldByName('effect2_value').AsInteger;
              Account.Header.Pran1.Inventory[ItemSlot].Effects.Value[2] :=
                MySQLComp.Query.FieldByName('effect3_value').AsInteger;
              Account.Header.Pran1.Inventory[ItemSlot].MIN :=
                MySQLComp.Query.FieldByName('min').AsInteger;
              Account.Header.Pran1.Inventory[ItemSlot].MAX :=
                MySQLComp.Query.FieldByName('max').AsInteger;
              Account.Header.Pran1.Inventory[ItemSlot].Refi :=
                MySQLComp.Query.FieldByName('refine').AsInteger;
              Account.Header.Pran1.Inventory[ItemSlot].Time :=
                MySQLComp.Query.FieldByName('time').AsInteger;
              MySQLComp.Query.Next;
            end;
          end;
          { Pran Skills }
          MySQLComp.SetQuery
            ('SELECT slot, item, level FROM skills WHERE ' +
            'owner_charid = '+Account.Header.Pran1.Iddb.ToString+
            ' AND type = 3 order by slot LIMIT 10');
          // PlayerSQL.AddParameter2('powner_charid', Account.Header.Pran1.Iddb);
          // PlayerSQL.AddParameter2('ptype', 3);
          MySQLComp.Run();
          ItemAmount2 := MySQLComp.Query.RecordCount;
          if not(ItemAmount2 = 0) then
          begin
            MySQLComp.Query.First;
            for k := 0 to ItemAmount2-1 do
            begin
              ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger;
              Account.Header.Pran1.Skills[ItemSlot].Index :=
                MySQLComp.Query.FieldByName('item').AsInteger;
              Account.Header.Pran1.Skills[ItemSlot].Level :=
                MySQLComp.Query.FieldByName('level').AsInteger;
              MySQLComp.Query.Next;
            end;
          end;
          { Pran Skill Bar }
          MySQLComp.SetQuery('SELECT slot, item FROM itembars WHERE ' +
            'owner_charid = '+(Account.Header.Pran1.Iddb+1024000).ToString+
            ' order by slot LIMIT 3');
          // PlayerSQL.AddParameter2('powner_charid', Account.Header.Pran1.Iddb);
          MySQLComp.Run();
          ItemAmount2 := MySQLComp.Query.RecordCount;
          if not(ItemAmount2 = 0) then
          begin
            MySQLComp.Query.First;
            for k := 0 to ItemAmount2-1 do
            begin
              ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger;
              ItemSlot := ItemSlot - 100;
              Account.Header.Pran1.ItemBar[ItemSlot] :=
                MySQLComp.Query.FieldByName('item').AsInteger;
              MySQLComp.Query.Next;
            end;
          end;
        end
        else // pran2
        begin
          Account.Header.Pran2.Iddb := MySQLComp.Query.FieldByName('id')
            .AsInteger;
          Account.Header.Pran2.ItemID := MySQLComp.Query.FieldByName('item_id')
            .AsInteger;
          Account.Header.Pran2.AccId := Self.Account.Header.AccountId;
          AnsiStrings.StrPLCopy(Account.Header.Pran2.Name,
            AnsiString(MySQLComp.Query.FieldByName('name').AsString), 16);
          Account.Header.Pran2.Level := MySQLComp.Query.FieldByName('level')
            .AsInteger;
          Account.Header.Pran2.ClassPran := MySQLComp.Query.FieldByName('class')
            .AsInteger;
          Account.Header.Pran2.CurHP := MySQLComp.Query.FieldByName('hp')
            .AsInteger;
          Account.Header.Pran2.MaxHp := MySQLComp.Query.FieldByName('max_hp')
            .AsInteger;
          Account.Header.Pran2.CurMp := MySQLComp.Query.FieldByName('mp')
            .AsInteger;
          Account.Header.Pran2.MaxMP := MySQLComp.Query.FieldByName('max_mp')
            .AsInteger;
          Account.Header.Pran2.Exp := MySQLComp.Query.FieldByName('xp')
            .AsInteger;
          Account.Header.Pran2.DefFis := MySQLComp.Query.FieldByName('def_p')
            .AsInteger;
          Account.Header.Pran2.DefMag := MySQLComp.Query.FieldByName('def_m')
            .AsInteger;
          Account.Header.Pran2.Food := MySQLComp.Query.FieldByName('food')
            .AsInteger;
          Account.Header.Pran2.Devotion := MySQLComp.Query.FieldByName
            ('devotion').AsInteger;
          Account.Header.Pran2.Personality.Cute :=
            MySQLComp.Query.FieldByName('p_cute').AsInteger;
          Account.Header.Pran2.Personality.Smart :=
            MySQLComp.Query.FieldByName('p_smart').AsInteger;
          Account.Header.Pran2.Personality.Sexy :=
            MySQLComp.Query.FieldByName('p_sexy').AsInteger;
          Account.Header.Pran2.Personality.Energetic :=
            MySQLComp.Query.FieldByName('p_energetic').AsInteger;
          Account.Header.Pran2.Personality.Tough :=
            MySQLComp.Query.FieldByName('p_tough').AsInteger;
          Account.Header.Pran2.Personality.Corrupt :=
            MySQLComp.Query.FieldByName('p_corrupt').AsInteger;
          Account.Header.Pran2.Width := MySQLComp.Query.FieldByName('width')
            .AsInteger;
          Account.Header.Pran2.Chest := MySQLComp.Query.FieldByName('chest')
            .AsInteger;
          Account.Header.Pran2.Leg := MySQLComp.Query.FieldByName('leg')
            .AsInteger;
          Account.Header.Pran2.CreatedAt := MySQLComp.Query.FieldByName
            ('created_at').AsInteger;
          Account.Header.Pran2.Updated_at := MySQLComp.Query.FieldByName
            ('updated_at').AsInteger;

          MySQLComp.SetQuery
            ('SELECT slot, item_id, app, identific, effect1_index, effect2_index, '
            + 'effect3_index, effect1_value, effect2_value, effect3_value, min, max, '
            + 'refine, time FROM items WHERE slot_type = '+
            PRAN_EQUIP_TYPE.ToString+' AND ' +
            'owner_id = '+Account.Header.Pran2.Iddb.ToString+
            ' order by slot LIMIT 16');
          // PlayerSQL.AddParameter2('pslot_type', PRAN_EQUIP_TYPE);
          // PlayerSQL.AddParameter2('powner_id', Account.Header.Pran1.Iddb);
          MySQLComp.Run();
          ItemAmount2 := MySQLComp.Query.RecordCount;
          if not(ItemAmount2 = 0) then
          begin
            MySQLComp.Query.First;
            for k := 0 to ItemAmount2-1 do
            begin
              ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger;
              Account.Header.Pran2.Equip[ItemSlot].Index :=
                MySQLComp.Query.FieldByName('item_id').AsInteger;
              Account.Header.Pran2.Equip[ItemSlot].APP :=
                MySQLComp.Query.FieldByName('app').AsInteger;
              Account.Header.Pran2.Equip[ItemSlot].Identific :=
                MySQLComp.Query.FieldByName('identific').AsInteger;
              Account.Header.Pran2.Equip[ItemSlot].Effects.Index[0] :=
                MySQLComp.Query.FieldByName('effect1_index').AsInteger;
              Account.Header.Pran2.Equip[ItemSlot].Effects.Index[1] :=
                MySQLComp.Query.FieldByName('effect2_index').AsInteger;
              Account.Header.Pran2.Equip[ItemSlot].Effects.Index[2] :=
                MySQLComp.Query.FieldByName('effect3_index').AsInteger;
              Account.Header.Pran2.Equip[ItemSlot].Effects.Value[0] :=
                MySQLComp.Query.FieldByName('effect1_value').AsInteger;
              Account.Header.Pran2.Equip[ItemSlot].Effects.Value[1] :=
                MySQLComp.Query.FieldByName('effect2_value').AsInteger;
              Account.Header.Pran2.Equip[ItemSlot].Effects.Value[2] :=
                MySQLComp.Query.FieldByName('effect3_value').AsInteger;
              Account.Header.Pran2.Equip[ItemSlot].MIN :=
                MySQLComp.Query.FieldByName('min').AsInteger;
              Account.Header.Pran2.Equip[ItemSlot].MAX :=
                MySQLComp.Query.FieldByName('max').AsInteger;
              Account.Header.Pran2.Equip[ItemSlot].Refi :=
                MySQLComp.Query.FieldByName('refine').AsInteger;
              Account.Header.Pran2.Equip[ItemSlot].Time :=
                MySQLComp.Query.FieldByName('time').AsInteger;

              MySQLComp.Query.Next;
            end;
          end;
          MySQLComp.SetQuery
            ('SELECT slot, item_id, app, identific, effect1_index, effect2_index, '
            + 'effect3_index, effect1_value, effect2_value, effect3_value, min, max, '
            + 'refine, time FROM items WHERE slot_type = '+
            PRAN_INV_TYPE.ToString+' AND ' +
            'owner_id = '+Account.Header.Pran2.Iddb.ToString+
            ' order by slot LIMIT 42');
          // PlayerSQL.AddParameter2('pslot_type', PRAN_INV_TYPE);
          // PlayerSQL.AddParameter2('powner_id', Account.Header.Pran1.Iddb);
          MySQLComp.Run();
          ItemAmount2 := MySQLComp.Query.RecordCount;
          if not(ItemAmount2 = 0) then
          begin
            MySQLComp.Query.First;
            for k := 0 to ItemAmount2-1 do
            begin
              ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger;
              Account.Header.Pran2.Inventory[ItemSlot].Index :=
                MySQLComp.Query.FieldByName('item_id').AsInteger;
              Account.Header.Pran2.Inventory[ItemSlot].APP :=
                MySQLComp.Query.FieldByName('app').AsInteger;
              Account.Header.Pran2.Inventory[ItemSlot].Identific :=
                MySQLComp.Query.FieldByName('identific').AsInteger;
              Account.Header.Pran2.Inventory[ItemSlot].Effects.Index[0] :=
                MySQLComp.Query.FieldByName('effect1_index').AsInteger;
              Account.Header.Pran2.Inventory[ItemSlot].Effects.Index[1] :=
                MySQLComp.Query.FieldByName('effect2_index').AsInteger;
              Account.Header.Pran2.Inventory[ItemSlot].Effects.Index[2] :=
                MySQLComp.Query.FieldByName('effect3_index').AsInteger;
              Account.Header.Pran2.Inventory[ItemSlot].Effects.Value[0] :=
                MySQLComp.Query.FieldByName('effect1_value').AsInteger;
              Account.Header.Pran2.Inventory[ItemSlot].Effects.Value[1] :=
                MySQLComp.Query.FieldByName('effect2_value').AsInteger;
              Account.Header.Pran2.Inventory[ItemSlot].Effects.Value[2] :=
                MySQLComp.Query.FieldByName('effect3_value').AsInteger;
              Account.Header.Pran2.Inventory[ItemSlot].MIN :=
                MySQLComp.Query.FieldByName('min').AsInteger;
              Account.Header.Pran2.Inventory[ItemSlot].MAX :=
                MySQLComp.Query.FieldByName('max').AsInteger;
              Account.Header.Pran2.Inventory[ItemSlot].Refi :=
                MySQLComp.Query.FieldByName('refine').AsInteger;
              Account.Header.Pran2.Inventory[ItemSlot].Time :=
                MySQLComp.Query.FieldByName('time').AsInteger;
              MySQLComp.Query.Next;
            end;
          end;
          { Pran Skills }
          MySQLComp.SetQuery
            ('SELECT slot, item, level FROM skills WHERE ' +
            'owner_charid = '+
            Account.Header.Pran2.Iddb.ToString+' AND type = 3 order by slot LIMIT 10');
          // PlayerSQL.AddParameter2('powner_charid', Account.Header.Pran2.Iddb);
          // PlayerSQL.AddParameter2('ptype', 3);
          MySQLComp.Run();
          ItemAmount2 := MySQLComp.Query.RecordCount;
          if not(ItemAmount2 = 0) then
          begin
            MySQLComp.Query.First;
            for k := 0 to ItemAmount2-1 do
            begin
              ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger;
              Account.Header.Pran2.Skills[ItemSlot].Index :=
                MySQLComp.Query.FieldByName('item').AsInteger;
              Account.Header.Pran2.Skills[ItemSlot].Level :=
                MySQLComp.Query.FieldByName('level').AsInteger;

              MySQLComp.Query.Next;
            end;
          end;
          { Pran Skill Bar }
          MySQLComp.SetQuery('SELECT slot, item FROM itembars WHERE ' +
            'owner_charid = '+
            (Account.Header.Pran2.Iddb+1024000).ToString+' order by slot LIMIT 3');
          // PlayerSQL.AddParameter2('powner_charid', Account.Header.Pran2.Iddb);
          MySQLComp.Run();
          ItemAmount2 := MySQLComp.Query.RecordCount;
          if not(ItemAmount2 = 0) then
          begin
            MySQLComp.Query.First;
            for k := 0 to ItemAmount2-1 do
            begin
              ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger;
              ItemSlot := ItemSlot - 100;
              Account.Header.Pran2.ItemBar[ItemSlot] :=
                MySQLComp.Query.FieldByName('item').AsInteger;
              MySQLComp.Query.Next;
            end;
          end;
        end;
        if (ItemAmount > 1) then
        begin
          Inc(J);
          MySQLComp.SetQuery
            ('SELECT id, item_id, name, level, class, hp, max_hp, mp, ' +
            'max_mp, xp, def_p, def_m, food, devotion, p_cute, p_smart, p_sexy, p_energetic, '
            + 'p_tough, p_corrupt, width, chest, leg, created_at, updated_at ' +
            'FROM prans WHERE acc_id = '+
            Self.Account.Header.AccountId.ToString+' order by id LIMIT 2');
          // PlayerSQL.AddParameter2('pacc_id', Self.Account.Header.AccountId);
          MySQLComp.Run();
          MySQLComp.Query.First;
          MySQLComp.Query.Next;
        end;
      end;
    end;

      // Self.PlayerSQL.MySQL.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Load misc Prans error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
     // Self.PlayerSQL.Query.Connection.Rollback;
    end;
  end;

  { Storage }
  try
    // Self.PlayerSQL.MySQL.StartTransaction;

    MySQLComp.SetQuery
      ('SELECT slot, item_id, app, identific, effect1_index, effect2_index, '
      + 'effect3_index, effect1_value, effect2_value, effect3_value, min, max, '
      + 'refine, time FROM items WHERE owner_id = '+
      Self.Account.Header.AccountId.ToString+' AND slot_type=2 order by slot LIMIT 86');
    // PlayerSQL.AddParameter2('powner_id', ID);
    MySQLComp.Run();
    ItemAmount := MySQLComp.Query.RecordCount;
    if not(ItemAmount = 0) then
    begin
      MySQLComp.Query.First;
      for i := 0 to ItemAmount-1 do
      begin
        if(MySQLComp.Query.FieldByName('item_id').AsInteger = 0) then
        begin
          MySQLComp.Query.Next;
          Continue;
        end;
        ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger;
        Self.Account.Header.Storage.Itens[ItemSlot].Index :=
          (MySQLComp.Query.FieldByName('item_id').AsInteger);
        Self.Account.Header.Storage.Itens[ItemSlot].APP :=
          (MySQLComp.Query.FieldByName('app').AsInteger);
        Self.Account.Header.Storage.Itens[ItemSlot].Identific :=
          MySQLComp.Query.FieldByName('identific').AsInteger;
        Self.Account.Header.Storage.Itens[ItemSlot].Effects.Index[0] :=
          (MySQLComp.Query.FieldByName('effect1_index').AsInteger);
        Self.Account.Header.Storage.Itens[ItemSlot].Effects.Index[1] :=
          (MySQLComp.Query.FieldByName('effect2_index').AsInteger);
        Self.Account.Header.Storage.Itens[ItemSlot].Effects.Index[2] :=
          (MySQLComp.Query.FieldByName('effect3_index').AsInteger);
        Self.Account.Header.Storage.Itens[ItemSlot].Effects.Value[0] :=
          (MySQLComp.Query.FieldByName('effect1_value').AsInteger);
        Self.Account.Header.Storage.Itens[ItemSlot].Effects.Value[1] :=
          (MySQLComp.Query.FieldByName('effect2_value').AsInteger);
        Self.Account.Header.Storage.Itens[ItemSlot].Effects.Value[2] :=
          (MySQLComp.Query.FieldByName('effect3_value').AsInteger);
        Self.Account.Header.Storage.Itens[ItemSlot].MIN :=
          (MySQLComp.Query.FieldByName('min').AsInteger);
        Self.Account.Header.Storage.Itens[ItemSlot].MAX :=
          (MySQLComp.Query.FieldByName('max').AsInteger);
        Self.Account.Header.Storage.Itens[ItemSlot].Refi :=
          (MySQLComp.Query.FieldByName('refine').AsInteger);
        Self.Account.Header.Storage.Itens[ItemSlot].Time :=
          (MySQLComp.Query.FieldByName('time').AsInteger);

        MySQLComp.Query.Next;
      end;
    end;

    // Self.PlayerSQL.MySQL.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Load misc Storage error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
     // Self.PlayerSQL.Query.Connection.Rollback;
    end;
  end;
  { Premium }
  try
    // Self.PlayerSQL.MySQL.StartTransaction;

    MySQLComp.SetQuery
      ('SELECT slot, item_id, app, identific FROM items WHERE ' +
      'owner_id = '+Self.Account.Header.AccountId.ToString+
      ' AND slot_type=10 order by slot LIMIT 24');
    // PlayerSQL.AddParameter2('powner_id', ID);
    MySQLComp.Run();
    ItemAmount := MySQLComp.Query.RecordCount;
    if not(ItemAmount = 0) then
    begin
      MySQLComp.Query.First;
      for i := 0 to ItemAmount-1 do
      begin
        if(MySQLComp.Query.FieldByName('item_id').AsInteger = 0) then
        begin
          MySQLComp.Query.Next;
          Continue;
        end;
        ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger;
        Self.Account.Header.CashInventory.Items[ItemSlot].Index :=
          (MySQLComp.Query.FieldByName('item_id').AsInteger);
        Self.Account.Header.CashInventory.Items[ItemSlot].APP :=
          (MySQLComp.Query.FieldByName('app').AsInteger);
        Self.Account.Header.CashInventory.Items[ItemSlot].Identific :=
          MySQLComp.Query.FieldByName('identific').AsInteger;

        MySQLComp.Query.Next;
      end;
    end;

    // Self.PlayerSQL.MySQL.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Load misc Premium error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      //Self.PlayerSQL.Query.Connection.Rollback;
    end;
  end;

  MySQLComp.Destroy;
  Result := True;
end;
function TPlayer.NameExists(CharacterName: String): Boolean;
var
  SQLComp: TQuery;
begin
  Result := True;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[NameExists]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[NameExists]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    // Self.PlayerSQL.MySQL.StartTransaction;
    SQLComp.SetQuery('SELECT id FROM characters WHERE name = "'+
      CharacterName+'"');
    SQLComp.Run();
    if (SQLComp.Query.RecordCount = 0) then
      Result := FALSE;
    { if (PlayerSQL.Query.Locate('name', CharacterName, [loCaseInsensitive])) then
      begin
      Result := True;
      end; }
    // Self.PlayerSQL.MySQL.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Verify Name Exists error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      //Self.PlayerSQL.Query.Connection.Rollback;
    end;
  end;
  SQLComp.Destroy;
end;
function TPlayer.VerifyAmount(CharacterName: String): Boolean;
var
  CharCount: Integer;
  SQLComp: TQuery;
begin
  Result := FALSE;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[VerifyAmount]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[VerifyAmount]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    // Self.PlayerSQL.MySQL.StartTransaction;
    SQLComp.SetQuery
      ('SELECT id FROM characters WHERE owner_accid = '+
      Self.Account.Header.AccountId.ToString+' LIMIT 3');
    // PlayerSQL.AddParameter2('powner_accid', Self.Account.Header.AccountId);
    SQLComp.Run();
    CharCount := SQLComp.Query.RecordCount;
    // Self.PlayerSQL.MySQL.Commit;
    if (CharCount = 3) then
    begin
      SQLComp.Destroy;
      Exit;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Verify Amount error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      //Self.PlayerSQL.Query.Connection.Rollback;
    end;
  end;
  SQLComp.Destroy;
  Result := True;
end;
function TPlayer.SaveAccountToken(Username: String): Boolean;
var
  SQLComp: TQuery;
begin
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SaveAccountToken]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveAccountToken]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  SQLComp.Query.Connection.StartTransaction;
  try
    SQLComp.SetQuery('UPDATE accounts SET last_token = "'+
      String(Self.Account.Header.Token.Token)+'",' +
      ' last_token_creation_time = "'+
      DateTimeToStr(Self.Account.Header.Token.CreationTime)+
      '" WHERE username = "'+Username+'"');
    // Servers[Self.ChannelIndex].cSQL.AddParameter2('pusername', Username);
    // Servers[Self.ChannelIndex].cSQL.AddParameter2('plast_token',
    // String(Self.Account.Header.Token.Token));
    // Servers[Self.ChannelIndex].cSQL.AddParameter2('plast_token_creation_time',
    // DateTimeToStr(Self.Account.Header.Token.CreationTime));
    SQLComp.Run(False);
    SQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Save Account Token error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      SQLComp.Query.Connection.Rollback;
    end;
  end;

  SQLComp.Destroy;
  Result := True;
end;
function TPlayer.SaveStatus(Username: String): Boolean;
var
  PlayerSQLComp: TQuery;
  is_active: integer;
begin
  PlayerSQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);
  if not(PlayerSQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SaveStatus]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveStatus]', TlogType.Error);
    PlayerSQLComp.Destroy;
    Exit;
  end;
  if(Self.Account.Header.IsActive) then
    is_active := 1
  else
    is_active := 0;
  try
    PlayerSQLComp.Query.Connection.StartTransaction;
    PlayerSQLComp.SetQuery('UPDATE accounts SET isactive='+is_active.ToString+
    ', ' +
      'premium_time="'+DateTimeToStr(Self.Account.Header.PremiumTime)+
      '", account_status='+Self.Account.Header.AccountStatus.ToString+
      ', ban_days='+Self.Account.Header.BanDays.ToString+
      ', cash='+Self.Account.Header.CashInventory.Cash.ToString+
      ' WHERE username="'+Username+'"');
    { Servers[Self.ChannelIndex].cSQL.AddParameter2('pisactive',
      Self.Account.Header.IsActive.ToInteger);
      Servers[Self.ChannelIndex].cSQL.AddParameter2('ppremium_time',
      DateTimeToStr(Self.Account.Header.PremiumTime));
      Servers[Self.ChannelIndex].cSQL.AddParameter2('pusername', Username); }
    PlayerSQLComp.Run(False);
    PlayerSQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Save Status error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      PlayerSQLComp.Query.Connection.Rollback;
    end;
  end;
  PlayerSQLComp.Destroy;
  Result := True;
end;
function TPlayer.SaveCreatedChar(CharacterName: String; Slot: Integer): Boolean;
var
  i: Integer;
  Item: PItem;
  CharID: Integer;
  SQLComp: TQuery;
begin
  Result := FALSE;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SaveCreatedChar]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveCreatedChar]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  SQLComp.Query.Connection.StartTransaction;
  try
    SQLComp.SetQuery
      (format('INSERT INTO characters (owner_accid, name, slot, classinfo,'
      + ' strength, agility, intelligence, constitution, luck, status, altura, tronco,'
      + ' perna, corpo, experience, level, gold, posx, posy, creationtime, pranevcnt, last_diary_event) VALUES '
      + '(%d, %s, %d, %d, ' + '%d, %d, %d, %d, %d, %d, %d, %d, ' +
      '%d, %d, %d, %d, %d, %s, %s, %s, %d, %s)', [Self.Account.Header.AccountId,
      QuotedStr(String(Self.Account.Characters[Slot].Base.Name)), Slot,
      Self.Account.Characters[Slot].Base.ClassInfo,
      Self.Account.Characters[Slot].Base.CurrentScore.Str,
      Self.Account.Characters[Slot].Base.CurrentScore.agility,
      Self.Account.Characters[Slot].Base.CurrentScore.Int,
      Self.Account.Characters[Slot].Base.CurrentScore.Cons,
      Self.Account.Characters[Slot].Base.CurrentScore.Luck,
      Self.Account.Characters[Slot].Base.CurrentScore.Status,
      Self.Account.Characters[Slot].Base.CurrentScore.Sizes.Altura,
      Self.Account.Characters[Slot].Base.CurrentScore.Sizes.Tronco,
      Self.Account.Characters[Slot].Base.CurrentScore.Sizes.Perna,
      Self.Account.Characters[Slot].Base.CurrentScore.Sizes.Corpo,
      Self.Account.Characters[Slot].Base.Exp, Self.Account.Characters[Slot]
      .Base.Level, Self.Account.Characters[Slot].Base.Gold,
      QuotedStr(Self.Account.Characters[Slot].LastPos.X.ToString),
      QuotedStr(Self.Account.Characters[Slot].LastPos.Y.ToString),
      QuotedStr(DateTimeToStr(Now)), Self.Account.PranEvoCnt,
      QuotedStr(DateTimeToStr(Now))]));
    SQLComp.Run(False);
    SQLComp.Query.SQL.Clear;
    SQLComp.Query.SQL.Add('select id from characters where name ='+
      QuotedStr(String(Self.Account.Characters[Slot].Base.Name)));
    SQLComp.Run(True);
    if(SQLComp.Query.RecordCount > 0) then
    begin
      Self.Account.Characters[Slot].Index := SQLComp.Query.Fields[0].AsInteger;
      Self.Account.Characters[Slot].Base.CharIndex :=
        Self.Account.Characters[Slot].Index;
    end
    else
    begin
      Logger.Write('Não foi possível resgatar o código do cliente.', TLogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
    CharID := Self.Account.Characters[Slot].Index;
    for i := 0 to 7 do
    begin
      Item := @Self.Account.Characters[Slot].Base.Equip[i];
      if (Item^.Index = 0) then
        Continue;
      SQLComp.SetQuery
        (format('INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
        'app, effect1_index, effect1_value, effect2_index, effect2_value,' +
        ' effect3_index, effect3_value, min, max, refine, time) VALUES ' +
        '(0, %d, %d, %d, ' + '%d, %d, %d, %d, %d, ' + '%d, %d, %d, %d, %d, %d)',
        [CharID, i, Item^.Index, Item^.APP, Item^.Effects.Index[0],
        Item^.Effects.Value[0], Item^.Effects.Index[1], Item^.Effects.Value[1],
        Item^.Effects.Index[2], Item^.Effects.Value[2], Item^.MIN, Item^.MAX,
        Item^.Refi, Item^.Time]));
      { PlayerSQL.AddParameter2('pisactive', Item.IsActive);
        PlayerSQL.AddParameter2('pgeneratedin', Item.GeneratedIn);
        PlayerSQL.AddParameter2('pgeneratedtime',
        TFunctions.DateTimeToUNIXTimeFAST(Item.GeneratedTime));
        PlayerSQL.AddParameter2('pgeneratoraccid', Item.GeneratorAccountID); }
      { PlayerSQL.AddParameter2('pslot_type', 0);
        PlayerSQL.AddParameter2('powner_id', CharID);
        PlayerSQL.AddParameter2('pslot', i);
        PlayerSQL.AddParameter2('pitem_id', Item.Index);
        PlayerSQL.AddParameter2('papp', Item.APP);
        PlayerSQL.AddParameter2('peffect1_index', Item.Effects.Index[0]);
        PlayerSQL.AddParameter2('peffect1_value', Item.Effects.Value[0]);
        PlayerSQL.AddParameter2('peffect2_index', Item.Effects.Index[1]);
        PlayerSQL.AddParameter2('peffect2_value', Item.Effects.Value[1]);
        PlayerSQL.AddParameter2('peffect3_index', Item.Effects.Index[2]);
        PlayerSQL.AddParameter2('peffect3_value', Item.Effects.Value[2]);
        PlayerSQL.AddParameter2('pmin', Item.MIN);
        PlayerSQL.AddParameter2('pmax', Item.MAX);
        PlayerSQL.AddParameter2('prefine', Item.Refi);
        PlayerSQL.AddParameter2('ptime', Item.Time); }
      SQLComp.Run(False);
    end;
    for i := 0 to 63 do
    begin
      Item := @Self.Account.Characters[Slot].Base.Inventory[i];
      if (Item^.Index = 0) then
        Continue;
      SQLComp.SetQuery
        (format('INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
        'app, effect1_index, effect1_value, effect2_index, effect2_value,' +
        ' effect3_index, effect3_value, min, max, refine, time) VALUES ' +
        '(1, %d, %d, %d, ' + '%d, %d, %d, %d, %d, ' + '%d, %d, %d, %d, %d, %d)',
        [CharID, i, Item^.Index, Item^.APP, Item^.Effects.Index[0],
        Item^.Effects.Value[0], Item^.Effects.Index[1], Item^.Effects.Value[1],
        Item^.Effects.Index[2], Item^.Effects.Value[2], Item^.MIN, Item^.MAX,
        Item^.Refi, Item^.Time]));
      { PlayerSQL.AddParameter2('pisactive', Item.IsActive);
        PlayerSQL.AddParameter2('pgeneratedin', Item.GeneratedIn);
        PlayerSQL.AddParameter2('pgeneratedtime',
        TFunctions.DateTimeToUNIXTimeFAST(Item.GeneratedTime));
        PlayerSQL.AddParameter2('pgeneratoraccid', Item.GeneratorAccountID); }
      { PlayerSQL.AddParameter2('pslot_type', 1);
        PlayerSQL.AddParameter2('powner_id', CharID);
        PlayerSQL.AddParameter2('pslot', i);
        PlayerSQL.AddParameter2('pitem_id', Item.Index);
        PlayerSQL.AddParameter2('papp', Item.APP);
        PlayerSQL.AddParameter2('peffect1_index', Item.Effects.Index[0]);
        PlayerSQL.AddParameter2('peffect1_value', Item.Effects.Value[0]);
        PlayerSQL.AddParameter2('peffect2_index', Item.Effects.Index[1]);
        PlayerSQL.AddParameter2('peffect2_value', Item.Effects.Value[1]);
        PlayerSQL.AddParameter2('peffect3_index', Item.Effects.Index[2]);
        PlayerSQL.AddParameter2('peffect3_value', Item.Effects.Value[2]);
        PlayerSQL.AddParameter2('pmin', Item.MIN);
        PlayerSQL.AddParameter2('pmax', Item.MAX);
        PlayerSQL.AddParameter2('prefine', Item.Refi);
        PlayerSQL.AddParameter2('ptime', Item.Time); }
      SQLComp.Run(False);
    end;
    for i := 0 to 5 do
    begin
      if (Self.Account.Characters[Slot].Skills.Basics[i].Index = 0) then
      begin
        Continue;
      end;
      SQLComp.SetQuery
        (format('INSERT INTO skills (owner_charid, slot, item, level, type) VALUES '
        + '(%d, %d, %d, %d, 1)', [CharID, i, Self.Account.Characters[Slot]
        .Skills.Basics[i].Index, Self.Account.Characters[Slot].Skills.Basics
        [i].Level]));
      { PlayerSQL.AddParameter2('powner_charid', CharID);
        PlayerSQL.AddParameter2('pslot', i);
        PlayerSQL.AddParameter2('pitem', Self.Account.Characters[Slot]
        .Skills.Basics[i].Index);
        PlayerSQL.AddParameter2('plevel', Self.Account.Characters[Slot]
        .Skills.Basics[i].Level);
        PlayerSQL.AddParameter2('ptype', 1); }
      SQLComp.Run(False);
    end;
    for i := 0 to 39 do
    begin
      if (Self.Account.Characters[Slot].Skills.Others[i].Index = 0) then
      begin
        Continue;
      end;
      SQLComp.SetQuery
        (format('INSERT INTO skills (owner_charid, slot, item, level, type) VALUES '
        + '(%d, %d, %d, %d, 2)', [CharID, i, Self.Account.Characters[Slot]
        .Skills.Others[i].Index, Self.Account.Characters[Slot].Skills.Others
        [i].Level]));
      { PlayerSQL.AddParameter2('powner_charid', CharID);
        PlayerSQL.AddParameter2('pslot', i);
        PlayerSQL.AddParameter2('pitem', Self.Account.Characters[Slot]
        .Skills.Others[i].Index);
        PlayerSQL.AddParameter2('plevel', Self.Account.Characters[Slot]
        .Skills.Others[i].Level);
        PlayerSQL.AddParameter2('ptype', 2); }
      SQLComp.Run(False);
    end;
    for i := 0 to 31 do
    begin
      if (Self.Account.Characters[Slot].Base.ItemBar[i] = 0) then
      begin
        Continue;
      end;
      SQLComp.SetQuery
        (format('INSERT INTO itembars (owner_charid, slot, item) VALUES ' +
        '(%d, %d, %d)', [CharID, i, Self.Account.Characters[Slot]
        .Base.ItemBar[i]]));
      { PlayerSQL.AddParameter2('powner_charid', CharID);
        PlayerSQL.AddParameter2('pslot', i);
        PlayerSQL.AddParameter2('pitem', Self.Account.Characters[Slot]
        .Base.ItemBar[i]); }
      SQLComp.Run(False);
    end;
    SQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Save Created Char error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      SQLComp.Query.Connection.Rollback;
    end;
  end;
  SQLComp.Destroy;
  Result := True;
end;
function TPlayer.SaveCharOnCharRoom(CharID: Integer): Boolean;
var
  ID: Integer;
  PlayerSQLComp: TQuery;
begin
  Result := FALSE;
  if (Self.Base.clientId = 0) then
  begin
    Exit;
  end;
  PlayerSQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);
  if not(PlayerSQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SaveCharOnCharRoom]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveCharOnCharRoom]', TlogType.Error);
    PlayerSQLComp.Destroy;
    Exit;
  end;
  try
    PlayerSQLComp.SetQuery('SELECT id FROM characters WHERE name = "'+
    String(Self.Account.Characters[CharID].Base.Name)+'"');
    PlayerSQLComp.Run();
    ID := PlayerSQLComp.Query.FieldByName('id').AsInteger;
    //PlayerSQLComp.Query.Close();
    PlayerSQLComp.Query.Connection.StartTransaction;

    PlayerSQLComp.SetQuery('UPDATE characters SET numeric_token="'+
    String(Self.Account.Header.NumericToken[CharID])+'", ' +
      'delete_time="'+String(Self.Account.CharactersDeleteTime[CharID])+
      '", deleted='+Self.Account.CharactersDelete[CharID].ToInteger.ToString+
      ', ' + 'numeric_errors='+Self.Account.Header.NumError[CharID].ToString+
      ' WHERE id='+ID.ToString);
    { PlayerSQL.AddParameter2('pid', ID);
      PlayerSQL.AddParameter2('pdeleted', Self.Account.CharactersDelete[CharID]
      .ToInteger);
      PlayerSQL.AddParameter2('pdelete_time',
      String(Self.Account.CharactersDeleteTime[CharID]));
      PlayerSQL.AddParameter2('pnumeric_errors',
      Self.Account.Header.NumError[CharID]);
      PlayerSQL.AddParameter2('pnumeric_token',
      String(Self.Account.Header.NumericToken[CharID])); }
    PlayerSQLComp.Run(False);
    PlayerSQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Save Char on CharRoom error. msg[' + E.Message + ' : '
        + E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      PlayerSQLComp.Query.Connection.Rollback;
    end;
  end;
  PlayerSQLComp.Destroy;
  Result := True;
end;
function TPlayer.DeleteCharacter(CharID: Integer): Boolean;
var
  ID: Integer;
  SQLComp: TQuery;
begin
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SaveNation]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveNation]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  SQLComp.Query.Connection.StartTransaction;
  try
    ID := Self.Account.Characters[CharID].Index;
    SQLComp.SetQuery(format('DELETE FROM characters WHERE id=%d', [ID]));
    SQLComp.Run(False);
    SQLComp.SetQuery
      (format('DELETE FROM itembars WHERE owner_charid=%d', [ID]));
    SQLComp.Run(False);
    SQLComp.SetQuery(format('DELETE FROM items WHERE owner_id=%d', [ID]));
    SQLComp.Run(False);
    SQLComp.SetQuery
      (format('DELETE FROM skills WHERE owner_charid=%d', [ID]));
    SQLComp.Run(False);
    SQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Delete Character error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      SQLComp.Query.Connection.Rollback;
    end;
  end;
  SQLComp.Destroy;
  Result := True;
end;
function TPlayer.SaveInGame(CharID: Integer; isFromPainel: Boolean): Boolean;
var
  ID: Integer;
  i: Integer;
  Item: PItem;
  ItemC: PItemCash;
  VarQuery: String;
  Cnt: Integer;
  MySQLComp: TQuery;
begin
  Result := FALSE;
  ID := 0;
  //if (SqlInUse = True) then
    //Exit;
  if (Self.Base.clientId = 0) then
    Exit;
  if not(isFromPainel) then
  begin
    MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
      AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
      AnsiString(MYSQL_DATABASE), False);
    if not(MySQLComp.Query.Connection.Connected) then
    begin
      Logger.Write('Falha de conexão individual com mysql.[SaveInGame]',
        TlogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveInGame]', TlogType.Error);
      Exit;
    end;
  end
  else
  begin
    MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
      AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
      AnsiString(MYSQL_DATABASE), False);
    if not(MySQLComp.Query.Connection.Connected) then
    begin
      Logger.Write('Falha de conexão individual com mysql.[SaveInGame]',
        TlogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveInGame]', TlogType.Error);
      Exit;
    end;
  end;

  try
    //MySQLComp.SetQuery(format('SELECT id FROM characters WHERE name = %s;',
    //  [QuotedStr(String(Self.Account.Characters[CharID].Base.Name))]));
   // MySQLComp.Run();
    //ID := MySQLComp.Query.FieldByName('id').AsInteger;
    //if(ID = 0) then
    //begin
    ID := Self.Base.Character.CharIndex; //id 4

    if((Self.Base.Character.Equip[0].Index <> 0) and (ID <> 0)) then
    begin
      try
        MySQLComp.SetQuery('SELECT lastlogin from characters where id =' +ID.ToString);
        MySQLComp.Run();
        if(MySQLComp.Query.RecordCount > 0) then
        begin
          if not(MySQLComp.Query.Fields[0].IsNull) then
          begin
            if(HourOf(MySQLComp.Query.Fields[0].AsDateTime) <>
              HourOf(Now)) then
            begin
              TFunctions.SaveAccountFile(Self.Account,
                String(Self.Account.Header.Username) + '_' + FormatDateTime('dd_mm_yyyy_hh_nn_ss', Now), String(Self.Account.Header.Username));
            end;
          end
          else
          begin
            TFunctions.SaveAccountFile(Self.Account,
                String(Self.Account.Header.Username) + '_' + FormatDateTime('dd_mm_yyyy_hh_nn_ss', Now), String(Self.Account.Header.Username));
          end;
        end;
      except
        on E: Exception do
        begin
          TFunctions.SaveAccountFile(Self.Account,
            String(Self.Account.Header.Username) + '_' + FormatDateTime('dd_mm_yyyy_hh_nn_ss', Now), String(Self.Account.Header.Username));
          Logger.Write(E.Message + ' erro ao executar querie para backup.', TLogType.Error);
        end;
      end;
    end;

    {MySQLComp.Destroy;

    MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);
    if not(MySQLComp.Query.Connection.Connected) then
    begin
      Logger.Write('Falha de conexão individual com mysql.[SaveInGame]',
        TlogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveInGame]', TlogType.Error);
      Exit;
    end;  }
    //end;
    //MySQLComp.Query.Close;
    { Account Info }
    MySQLComp.Query.Connection.StartTransaction;
    MySQLComp.SetQuery('UPDATE accounts SET isactive='+
      Self.Account.Header.IsActive.ToString+', nation='+
      Integer(Self.Account.Header.Nation).ToString+', ' +
      'storage_gold='+Self.Account.Header.Storage.Gold.ToString+', cash='+
      Self.Account.Header.CashInventory.Cash.ToString+', ' +
      'account_status='+Self.Account.Header.AccountStatus.ToString+
      ', ban_days='+Self.Account.Header.BanDays.ToString+' WHERE id='+
      Self.Account.Header.AccountId.ToString+';');

    { PlayerSQL.AddParameter2('pid', Self.Account.Header.AccountId);
      PlayerSQL.AddParameter2('pisactive', Self.Account.Header.IsActive);
      PlayerSQL.AddParameter2('pnation', Self.Account.Header.Nation);
      PlayerSQL.AddParameter2('pstorage_gold', Self.Account.Header.Storage.Gold);
      PlayerSQL.AddParameter2('pcash', Self.Account.Header.CashInventory.Cash);
      PlayerSQL.AddParameter2('paccount_status',
      Self.Account.Header.AccountStatus); }
    MySQLComp.Run(False);
    MySQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL SaveInGame: AccountInfo error. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      MySQLComp.Query.Connection.Rollback;
    end;
  end;
  //if(ID = 0) then
  //begin
  //  ID := Self.Base.Character.CharIndex;
  //end;
  { Character Info }
  MySQLComp.Query.Connection.StartTransaction;
  try
    MySQLComp.SetQuery('UPDATE characters SET curhp='+Self.Character.Base.CurrentScore.CurHP.ToString+',' +
      ' curmp='+Self.Character.Base.CurrentScore.CurMp.ToString+
      ', honor='+Self.Character.Base.CurrentScore.Honor.ToString+
      ', killpoint='+Self.Character.Base.CurrentScore.KillPoint.ToString+
      ', infamia='+Self.Character.Base.CurrentScore.Infamia.ToString+',' +
      ' skillpoint='+Self.Character.Base.CurrentScore.SkillPoint.ToString+
      ', experience='+Self.Character.Base.Exp.ToString+
      ', level='+Self.Character.Base.Level.ToString+',' +
      ' guildindex='+Self.Character.Base.GuildIndex.ToString+
      ', gold='+Self.Character.Base.Gold.ToString+
      ', posx='+Round(Self.Base.PlayerCharacter.LastPos.X).ToString+
      ', posy='+Round(Self.Base.PlayerCharacter.LastPos.Y).ToString+
      ', active_title='+Self.Base.PlayerCharacter.ActiveTitle.Index.ToString+
       ' WHERE id='+ID.ToString+';');
    MySQLComp.Run(False);
    MySQLComp.SetQuery('UPDATE characters SET name="'+
      String(Self.Character.Base.Name)+'", rotation='+
      Self.Character.Rotation.ToString+',' +
      ' lastlogin="'+DateTimeToStr(Now)+'", playerkill='+
      Self.Character.PlayerKill.ToInteger.ToString+', classinfo='+
      Self.Character.Base.ClassInfo.ToString+',' +
      ' strength='+Self.Character.Base.CurrentScore.Str.ToString+
      ', agility='+Self.Character.Base.CurrentScore.agility.ToString+
      ', intelligence='+Self.Character.Base.CurrentScore.Int.ToString+',' +
      ' constitution='+Self.Character.Base.CurrentScore.Cons.ToString+
      ', luck='+Self.Character.Base.CurrentScore.Luck.ToString+
      ', status='+Self.Character.Base.CurrentScore.Status.ToString+
      ' WHERE id=' + ID.ToString + ';');

    MySQLComp.Run(False);
    MySQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL SaveInGame: CharacterInfo error. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      MySQLComp.Query.Connection.Rollback;
    end;
  end;
  { Equips }
  try
    MySQLComp.Query.Connection.StartTransaction;
    MySQLComp.SetQuery
      ('DELETE FROM items WHERE owner_id='+ID.ToString+' AND slot_type=0;');
    MySQLComp.Run(False);
    VarQuery := 'INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
      'app, identific, effect1_index, effect1_value, effect2_index, effect2_value,'
      + ' effect3_index, effect3_value, min, max, refine, time) VALUES ';
    Cnt := 0;
    for i := 0 to 15 do
    begin
      Item := @Self.Character.Base.Equip[i];
      if (Item^.Index = 0) then
        Continue;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ', (0, '+ID.ToString+', '+i.ToString+
          ', '+Item^.Index.ToString+', ' + Item^.APP.ToString +
          ', '+Item^.Identific.ToString+', '+Item.Effects.Index[0].ToString+
          ', '+Item^.Effects.Value[0].ToString+
          ', '+Item.Effects.Index[1].ToString+', '+
          Item^.Effects.Value[1].ToString+',' +Item^.Effects.Index[2].ToString +
          ', '+Item^.Effects.Value[2].ToString+', '+Item^.MIN.ToString+
          ', '+Item^.MAX.ToString+', '+Item^.Refi.ToString+', '+
          Item^.Time.ToString+')';
      end
      else
      begin
        VarQuery := VarQuery + '(0, '+ID.ToString+', '+i.ToString+
          ', '+Item^.Index.ToString+', ' + Item^.APP.ToString +
          ', '+Item^.Identific.ToString+', '+Item.Effects.Index[0].ToString+
          ', '+Item^.Effects.Value[0].ToString+
          ', '+Item.Effects.Index[1].ToString+', '+
          Item^.Effects.Value[1].ToString+',' +Item^.Effects.Index[2].ToString +
          ', '+Item^.Effects.Value[2].ToString+', '+Item^.MIN.ToString+
          ', '+Item^.MAX.ToString+', '+Item^.Refi.ToString+', '+
          Item^.Time.ToString+')';
      end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
    end;
    MySQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL SaveInGame: Equips error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      MySQLComp.Query.Connection.Rollback;
    end;
  end;
  { Inventory }
  try
    MySQLComp.Query.Connection.StartTransaction;
    MySQLComp.SetQuery
      ('DELETE FROM items WHERE owner_id='+ID.ToString+' AND slot_type=1;');
    MySQLComp.Run(False);
    Cnt := 0;
    VarQuery := 'INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
      'app, identific, effect1_index, effect1_value, effect2_index, effect2_value,'
      + ' effect3_index, effect3_value, min, max, refine, time) VALUES ';
    for i := 63 downto 0 do
    begin
      Item := @Self.Character.Base.Inventory[i];
      if (Item^.Index = 0) then
        Continue;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ', (1, ' + ID.ToString() + ', ' + i.ToString() +
          ', ' + Item^.Index.ToString + ', ' + Item^.APP.ToString + ', ' + Item^.Identific.ToString +
          ', ' + Item.Effects.Index[0].ToString + ', ' + Item^.Effects.Value[0].ToString +
          ', ' + Item^.Effects.Index[1].ToString + ', ' + Item^.Effects.Value[1].ToString + ', ' +
          Item^.Effects.Index[2].ToString + ', ' + Item^.Effects.Value[2].ToString + ', ' +
          Item^.MIN.ToString + ', ' + Item^.MAX.ToString + ', ' + Item^.Refi.ToString + ', ' + Item^.Time.ToString + ')';

         {format(', (1, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)',
          [ID, i, Item^.Index, Item^.APP, Item^.Identific,
          Item.Effects.Index[0], Item^.Effects.Value[0], Item^.Effects.Index[1],
          Item^.Effects.Value[1], Item^.Effects.Index[2],
          Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
          Item^.Time]);}
      end
      else
      begin
        VarQuery := VarQuery + '(1, ' + ID.ToString() + ', ' + i.ToString() +
          ', ' + Item^.Index.ToString + ', ' + Item^.APP.ToString + ', ' + Item^.Identific.ToString +
          ', ' + Item.Effects.Index[0].ToString + ', ' + Item^.Effects.Value[0].ToString +
          ', ' + Item^.Effects.Index[1].ToString + ', ' + Item^.Effects.Value[1].ToString + ', ' +
          Item^.Effects.Index[2].ToString + ', ' + Item^.Effects.Value[2].ToString + ', ' +
          Item^.MIN.ToString + ', ' + Item^.MAX.ToString + ', ' + Item^.Refi.ToString + ', ' + Item^.Time.ToString + ')';
        {
        VarQuery := VarQuery +
          format('(1, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)', [ID, i, Item^.Index, Item^.APP,
          Item^.Identific, Item.Effects.Index[0], Item^.Effects.Value[0],
          Item^.Effects.Index[1], Item^.Effects.Value[1], Item^.Effects.
          Index[2], Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
          Item^.Time]); }
      end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
    end;
   { Cnt := 0;
    VarQuery := 'INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
      'app, identific, effect1_index, effect1_value, effect2_index, effect2_value,'
      + ' effect3_index, effect3_value, min, max, refine, time) VALUES ';
    for i := 59 downto 45 do
    begin
      Item := @Self.Character.Base.Inventory[i];
      if (Item^.Index = 0) then
        Continue;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ', (1, ' + ID.ToString() + ', ' + i.ToString() +
          ', ' + Item^.Index.ToString + ', ' + Item^.APP.ToString + ', ' + Item^.Identific.ToString +
          ', ' + Item.Effects.Index[0].ToString + ', ' + Item^.Effects.Value[0].ToString +
          ', ' + Item^.Effects.Index[1].ToString + ', ' + Item^.Effects.Value[1].ToString + ', ' +
          Item^.Effects.Index[2].ToString + ', ' + Item^.Effects.Value[2].ToString + ', ' +
          Item^.MIN.ToString + ', ' + Item^.MAX.ToString + ', ' + Item^.Refi.ToString + ', ' + Item^.Time.ToString + ')';

         {format(', (1, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)',
          [ID, i, Item^.Index, Item^.APP, Item^.Identific,
          Item.Effects.Index[0], Item^.Effects.Value[0], Item^.Effects.Index[1],
          Item^.Effects.Value[1], Item^.Effects.Index[2],
          Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
          Item^.Time]);}
     { end
      else
      begin
        VarQuery := VarQuery + '(1, ' + ID.ToString() + ', ' + i.ToString() +
          ', ' + Item^.Index.ToString + ', ' + Item^.APP.ToString + ', ' + Item^.Identific.ToString +
          ', ' + Item.Effects.Index[0].ToString + ', ' + Item^.Effects.Value[0].ToString +
          ', ' + Item^.Effects.Index[1].ToString + ', ' + Item^.Effects.Value[1].ToString + ', ' +
          Item^.Effects.Index[2].ToString + ', ' + Item^.Effects.Value[2].ToString + ', ' +
          Item^.MIN.ToString + ', ' + Item^.MAX.ToString + ', ' + Item^.Refi.ToString + ', ' + Item^.Time.ToString + ')';
        {
        VarQuery := VarQuery +
          format('(1, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)', [ID, i, Item^.Index, Item^.APP,
          Item^.Identific, Item.Effects.Index[0], Item^.Effects.Value[0],
          Item^.Effects.Index[1], Item^.Effects.Value[1], Item^.Effects.
          Index[2], Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
          Item^.Time]); }
      {end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
    end;
    Cnt := 0;
    VarQuery := 'INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
      'app, identific, effect1_index, effect1_value, effect2_index, effect2_value,'
      + ' effect3_index, effect3_value, min, max, refine, time) VALUES ';
    for i := 44 downto 30 do
    begin
      Item := @Self.Character.Base.Inventory[i];
      if (Item^.Index = 0) then
        Continue;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ', (1, ' + ID.ToString() + ', ' + i.ToString() +
          ', ' + Item^.Index.ToString + ', ' + Item^.APP.ToString + ', ' + Item^.Identific.ToString +
          ', ' + Item.Effects.Index[0].ToString + ', ' + Item^.Effects.Value[0].ToString +
          ', ' + Item^.Effects.Index[1].ToString + ', ' + Item^.Effects.Value[1].ToString + ', ' +
          Item^.Effects.Index[2].ToString + ', ' + Item^.Effects.Value[2].ToString + ', ' +
          Item^.MIN.ToString + ', ' + Item^.MAX.ToString + ', ' + Item^.Refi.ToString + ', ' + Item^.Time.ToString + ')';

         {format(', (1, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)',
          [ID, i, Item^.Index, Item^.APP, Item^.Identific,
          Item.Effects.Index[0], Item^.Effects.Value[0], Item^.Effects.Index[1],
          Item^.Effects.Value[1], Item^.Effects.Index[2],
          Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
          Item^.Time]);}
     { end
      else
      begin
        VarQuery := VarQuery + '(1, ' + ID.ToString() + ', ' + i.ToString() +
          ', ' + Item^.Index.ToString + ', ' + Item^.APP.ToString + ', ' + Item^.Identific.ToString +
          ', ' + Item.Effects.Index[0].ToString + ', ' + Item^.Effects.Value[0].ToString +
          ', ' + Item^.Effects.Index[1].ToString + ', ' + Item^.Effects.Value[1].ToString + ', ' +
          Item^.Effects.Index[2].ToString + ', ' + Item^.Effects.Value[2].ToString + ', ' +
          Item^.MIN.ToString + ', ' + Item^.MAX.ToString + ', ' + Item^.Refi.ToString + ', ' + Item^.Time.ToString + ')';
        {
        VarQuery := VarQuery +
          format('(1, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)', [ID, i, Item^.Index, Item^.APP,
          Item^.Identific, Item.Effects.Index[0], Item^.Effects.Value[0],
          Item^.Effects.Index[1], Item^.Effects.Value[1], Item^.Effects.
          Index[2], Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
          Item^.Time]); }
      {end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
    end;
    Cnt := 0;
    VarQuery := 'INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
      'app, identific, effect1_index, effect1_value, effect2_index, effect2_value,'
      + ' effect3_index, effect3_value, min, max, refine, time) VALUES ';
    for i := 29 downto 15 do
    begin
      Item := @Self.Character.Base.Inventory[i];
      if (Item^.Index = 0) then
        Continue;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ', (1, ' + ID.ToString() + ', ' + i.ToString() +
          ', ' + Item^.Index.ToString + ', ' + Item^.APP.ToString + ', ' + Item^.Identific.ToString +
          ', ' + Item.Effects.Index[0].ToString + ', ' + Item^.Effects.Value[0].ToString +
          ', ' + Item^.Effects.Index[1].ToString + ', ' + Item^.Effects.Value[1].ToString + ', ' +
          Item^.Effects.Index[2].ToString + ', ' + Item^.Effects.Value[2].ToString + ', ' +
          Item^.MIN.ToString + ', ' + Item^.MAX.ToString + ', ' + Item^.Refi.ToString + ', ' + Item^.Time.ToString + ')';

         {format(', (1, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)',
          [ID, i, Item^.Index, Item^.APP, Item^.Identific,
          Item.Effects.Index[0], Item^.Effects.Value[0], Item^.Effects.Index[1],
          Item^.Effects.Value[1], Item^.Effects.Index[2],
          Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
          Item^.Time]);}
      {end
      else
      begin
        VarQuery := VarQuery + '(1, ' + ID.ToString() + ', ' + i.ToString() +
          ', ' + Item^.Index.ToString + ', ' + Item^.APP.ToString + ', ' + Item^.Identific.ToString +
          ', ' + Item.Effects.Index[0].ToString + ', ' + Item^.Effects.Value[0].ToString +
          ', ' + Item^.Effects.Index[1].ToString + ', ' + Item^.Effects.Value[1].ToString + ', ' +
          Item^.Effects.Index[2].ToString + ', ' + Item^.Effects.Value[2].ToString + ', ' +
          Item^.MIN.ToString + ', ' + Item^.MAX.ToString + ', ' + Item^.Refi.ToString + ', ' + Item^.Time.ToString + ')';
        {
        VarQuery := VarQuery +
          format('(1, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)', [ID, i, Item^.Index, Item^.APP,
          Item^.Identific, Item.Effects.Index[0], Item^.Effects.Value[0],
          Item^.Effects.Index[1], Item^.Effects.Value[1], Item^.Effects.
          Index[2], Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
          Item^.Time]); }
      {end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
    end;
    Cnt := 0;
    VarQuery := 'INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
      'app, identific, effect1_index, effect1_value, effect2_index, effect2_value,'
      + ' effect3_index, effect3_value, min, max, refine, time) VALUES ';
    for i := 14 downto 0 do
    begin
      Item := @Self.Character.Base.Inventory[i];
      if (Item^.Index = 0) then
        Continue;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ', (1, ' + ID.ToString() + ', ' + i.ToString() +
          ', ' + Item^.Index.ToString + ', ' + Item^.APP.ToString + ', ' + Item^.Identific.ToString +
          ', ' + Item.Effects.Index[0].ToString + ', ' + Item^.Effects.Value[0].ToString +
          ', ' + Item^.Effects.Index[1].ToString + ', ' + Item^.Effects.Value[1].ToString + ', ' +
          Item^.Effects.Index[2].ToString + ', ' + Item^.Effects.Value[2].ToString + ', ' +
          Item^.MIN.ToString + ', ' + Item^.MAX.ToString + ', ' + Item^.Refi.ToString + ', ' + Item^.Time.ToString + ')';

         {format(', (1, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)',
          [ID, i, Item^.Index, Item^.APP, Item^.Identific,
          Item.Effects.Index[0], Item^.Effects.Value[0], Item^.Effects.Index[1],
          Item^.Effects.Value[1], Item^.Effects.Index[2],
          Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
          Item^.Time]);}
     { end
      else
      begin
        VarQuery := VarQuery + '(1, ' + ID.ToString() + ', ' + i.ToString() +
          ', ' + Item^.Index.ToString + ', ' + Item^.APP.ToString + ', ' + Item^.Identific.ToString +
          ', ' + Item.Effects.Index[0].ToString + ', ' + Item^.Effects.Value[0].ToString +
          ', ' + Item^.Effects.Index[1].ToString + ', ' + Item^.Effects.Value[1].ToString + ', ' +
          Item^.Effects.Index[2].ToString + ', ' + Item^.Effects.Value[2].ToString + ', ' +
          Item^.MIN.ToString + ', ' + Item^.MAX.ToString + ', ' + Item^.Refi.ToString + ', ' + Item^.Time.ToString + ')';
        {
        VarQuery := VarQuery +
          format('(1, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)', [ID, i, Item^.Index, Item^.APP,
          Item^.Identific, Item.Effects.Index[0], Item^.Effects.Value[0],
          Item^.Effects.Index[1], Item^.Effects.Value[1], Item^.Effects.
          Index[2], Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
          Item^.Time]); }
      {end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
    end;                }
    MySQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL SaveInGame: Inventory error. msg[' + E.Message + ' : '
        + E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      MySQLComp.Query.Connection.Rollback;
    end;
  end;
  { Premium }
  try
    MySQLComp.Query.Connection.StartTransaction;
    MySQLComp.SetQuery
      ('DELETE FROM items WHERE owner_id='+
      Self.Account.Header.AccountId.ToString+' AND slot_type=10;');
    MySQLComp.Run(False);
    Cnt := 0;
    VarQuery := 'INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
      'app, identific) VALUES ';
    for i := 0 to 23 do
    begin
      ItemC := @Self.Account.Header.CashInventory.Items[i];
      if (ItemC^.Index = 0) then
        Continue;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ', (10, '+
          Self.Account.Header.AccountId.ToString+', '+i.ToString+
          ', '+ItemC^.Index.ToString+', ' + ItemC^.APP.ToString +
          ', '+ItemC^.Identific.ToString+')';
      end
      else
      begin
        VarQuery := VarQuery + '(10, '+
          Self.Account.Header.AccountId.ToString+', '+i.ToString+
          ', '+ItemC^.Index.ToString+', ' + ItemC^.APP.ToString +
          ', '+ItemC^.Identific.ToString+')';
      end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
    end;
    MySQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL SaveInGame: Premium error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      MySQLComp.Query.Connection.Rollback;
    end;
  end;
  { Storage }
  try
    MySQLComp.Query.Connection.StartTransaction;
    MySQLComp.SetQuery
      ('DELETE FROM items WHERE owner_id='+
        Self.Account.Header.AccountId.ToString+' AND slot_type=2;');
    MySQLComp.Run(False);
    Cnt := 0;
    VarQuery := 'INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
      'app, identific, effect1_index, effect1_value, effect2_index, effect2_value,'
      + ' effect3_index, effect3_value, min, max, refine, time) VALUES ';
    for i := 85 downto 0 do
    begin
      Item := @Self.Account.Header.Storage.Itens[i];
      if (Item^.Index = 0) then
        Continue;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ', (2, ' + Self.Account.Header.AccountId.ToString + ', ' + i.ToString() +
          ', ' + Item^.Index.ToString + ', ' + Item^.APP.ToString + ', ' + Item^.Identific.ToString +
          ', ' + Item.Effects.Index[0].ToString + ', ' + Item^.Effects.Value[0].ToString +
          ', ' + Item^.Effects.Index[1].ToString + ', ' + Item^.Effects.Value[1].ToString + ', ' +
          Item^.Effects.Index[2].ToString + ', ' + Item^.Effects.Value[2].ToString + ', ' +
          Item^.MIN.ToString + ', ' + Item^.MAX.ToString + ', ' + Item^.Refi.ToString + ', ' + Item^.Time.ToString + ')';
      end
      else
      begin
        VarQuery := VarQuery + '(2, ' + Self.Account.Header.AccountId.ToString + ', ' + i.ToString() +
          ', ' + Item^.Index.ToString + ', ' + Item^.APP.ToString + ', ' + Item^.Identific.ToString +
          ', ' + Item.Effects.Index[0].ToString + ', ' + Item^.Effects.Value[0].ToString +
          ', ' + Item^.Effects.Index[1].ToString + ', ' + Item^.Effects.Value[1].ToString + ', ' +
          Item^.Effects.Index[2].ToString + ', ' + Item^.Effects.Value[2].ToString + ', ' +
          Item^.MIN.ToString + ', ' + Item^.MAX.ToString + ', ' + Item^.Refi.ToString + ', ' + Item^.Time.ToString + ')';
      end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
    end;
    {Cnt := 0;
    VarQuery := 'INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
      'app, identific, effect1_index, effect1_value, effect2_index, effect2_value,'
      + ' effect3_index, effect3_value, min, max, refine, time) VALUES ';
    for i := 79 downto 60 do
    begin
      Item := @Self.Account.Header.Storage.Itens[i];
      if (Item^.Index = 0) then
        Continue;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + format(', (2, %d, %d, %d, ' +
          '%d, %d, %d, %d, %d, %d,' + ' %d, %d, %d, %d, %d, %d)',
          [Self.Account.Header.AccountId, i, Item^.Index, Item^.APP,
          Item^.Identific, Item.Effects.Index[0], Item^.Effects.Value[0],
          Item^.Effects.Index[1], Item^.Effects.Value[1], Item^.Effects.
          Index[2], Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
          Item^.Time]);
      end
      else
      begin
        VarQuery := VarQuery +
          format('(2, %d, %d, %d, ' + '%d, %d, %d, %d, %d, %d,' +
          ' %d, %d, %d, %d, %d, %d)', [Self.Account.Header.AccountId, i,
          Item^.Index, Item^.APP, Item^.Identific, Item.Effects.Index[0],
          Item^.Effects.Value[0], Item^.Effects.Index[1],
          Item^.Effects.Value[1], Item^.Effects.Index[2],
          Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
          Item^.Time]);
      end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
    end;
    Cnt := 0;
    VarQuery := 'INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
      'app, identific, effect1_index, effect1_value, effect2_index, effect2_value,'
      + ' effect3_index, effect3_value, min, max, refine, time) VALUES ';
    for i := 59 downto 40 do
    begin
      Item := @Self.Account.Header.Storage.Itens[i];
      if (Item^.Index = 0) then
        Continue;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + format(', (2, %d, %d, %d, ' +
          '%d, %d, %d, %d, %d, %d,' + ' %d, %d, %d, %d, %d, %d)',
          [Self.Account.Header.AccountId, i, Item^.Index, Item^.APP,
          Item^.Identific, Item.Effects.Index[0], Item^.Effects.Value[0],
          Item^.Effects.Index[1], Item^.Effects.Value[1], Item^.Effects.
          Index[2], Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
          Item^.Time]);
      end
      else
      begin
        VarQuery := VarQuery +
          format('(2, %d, %d, %d, ' + '%d, %d, %d, %d, %d, %d,' +
          ' %d, %d, %d, %d, %d, %d)', [Self.Account.Header.AccountId, i,
          Item^.Index, Item^.APP, Item^.Identific, Item.Effects.Index[0],
          Item^.Effects.Value[0], Item^.Effects.Index[1],
          Item^.Effects.Value[1], Item^.Effects.Index[2],
          Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
          Item^.Time]);
      end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
    end;
    Cnt := 0;
    VarQuery := 'INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
      'app, identific, effect1_index, effect1_value, effect2_index, effect2_value,'
      + ' effect3_index, effect3_value, min, max, refine, time) VALUES ';
    for i := 39 downto 20 do
    begin
      Item := @Self.Account.Header.Storage.Itens[i];
      if (Item^.Index = 0) then
        Continue;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + format(', (2, %d, %d, %d, ' +
          '%d, %d, %d, %d, %d, %d,' + ' %d, %d, %d, %d, %d, %d)',
          [Self.Account.Header.AccountId, i, Item^.Index, Item^.APP,
          Item^.Identific, Item.Effects.Index[0], Item^.Effects.Value[0],
          Item^.Effects.Index[1], Item^.Effects.Value[1], Item^.Effects.
          Index[2], Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
          Item^.Time]);
      end
      else
      begin
        VarQuery := VarQuery +
          format('(2, %d, %d, %d, ' + '%d, %d, %d, %d, %d, %d,' +
          ' %d, %d, %d, %d, %d, %d)', [Self.Account.Header.AccountId, i,
          Item^.Index, Item^.APP, Item^.Identific, Item.Effects.Index[0],
          Item^.Effects.Value[0], Item^.Effects.Index[1],
          Item^.Effects.Value[1], Item^.Effects.Index[2],
          Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
          Item^.Time]);
      end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
    end;
    Cnt := 0;
    VarQuery := 'INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
      'app, identific, effect1_index, effect1_value, effect2_index, effect2_value,'
      + ' effect3_index, effect3_value, min, max, refine, time) VALUES ';
    for i := 19 downto 0 do
    begin
      Item := @Self.Account.Header.Storage.Itens[i];
      if (Item^.Index = 0) then
        Continue;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + format(', (2, %d, %d, %d, ' +
          '%d, %d, %d, %d, %d, %d,' + ' %d, %d, %d, %d, %d, %d)',
          [Self.Account.Header.AccountId, i, Item^.Index, Item^.APP,
          Item^.Identific, Item.Effects.Index[0], Item^.Effects.Value[0],
          Item^.Effects.Index[1], Item^.Effects.Value[1], Item^.Effects.
          Index[2], Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
          Item^.Time]);
      end
      else
      begin
        VarQuery := VarQuery +
          format('(2, %d, %d, %d, ' + '%d, %d, %d, %d, %d, %d,' +
          ' %d, %d, %d, %d, %d, %d)', [Self.Account.Header.AccountId, i,
          Item^.Index, Item^.APP, Item^.Identific, Item.Effects.Index[0],
          Item^.Effects.Value[0], Item^.Effects.Index[1],
          Item^.Effects.Value[1], Item^.Effects.Index[2],
          Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
          Item^.Time]);
      end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
    end;     }
    MySQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL SaveInGame: Storage error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      MySQLComp.Query.Connection.Rollback;
    end;
  end;
  { Skills }
  try
    MySQLComp.Query.Connection.StartTransaction;
    MySQLComp.SetQuery
      ('DELETE FROM skills WHERE owner_charid='+
        ID.ToString+' and type in (1,2);');
    MySQLComp.Run(False);
    Cnt := 0;
    VarQuery :=
      'INSERT INTO skills (owner_charid, slot, item, level, type) VALUES ';
    for i := 0 to 5 do
    begin
      if (Self.Character.Skills.Basics[i].Index = 0) then
      begin
        Continue;
      end;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ', ('+ID.ToString+', '+
          i.ToString+', '+Self.Character.Skills.Basics[i].Index.ToString+
          ', '+Self.Character.Skills.Basics[i].Level.ToString+', 1)';
      end
      else
      begin
        VarQuery := VarQuery + '('+ID.ToString+', '+
          i.ToString+', '+Self.Character.Skills.Basics[i].Index.ToString+
          ', '+Self.Character.Skills.Basics[i].Level.ToString+', 1)';
      end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
    end;
    Cnt := 0;
    VarQuery :=
      'INSERT INTO skills (owner_charid, slot, item, level, type) VALUES ';
    for i := 0 to 39 do
    begin
      if (Self.Character.Skills.Others[i].Index = 0) then
      begin
        Continue;
      end;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ', ('+ID.ToString+
          ', '+i.ToString+', '+Self.Character.Skills.Others[i].Index.ToString+
          ', '+Self.Character.Skills.Others[i].Level.ToString+', 2)';
      end
      else
      begin
        VarQuery := VarQuery + '('+ID.ToString+
          ', '+i.ToString+', '+Self.Character.Skills.Others[i].Index.ToString+
          ', '+Self.Character.Skills.Others[i].Level.ToString+', 2)';
      end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
    end;
    {Cnt := 0;
    VarQuery :=
      'INSERT INTO skills (owner_charid, slot, item, level, type) VALUES ';
    for i := 20 to 39 do
    begin
      if (Self.Character.Skills.Others[i].Index = 0) then
      begin
        Continue;
      end;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + format(', (%d, %d, %d, %d, 2)',
          [ID, i, Self.Character.Skills.Others[i].Index,
          Self.Character.Skills.Others[i].Level]);
      end
      else
      begin
        VarQuery := VarQuery + format('(%d, %d, %d, %d, 2)',
          [ID, i, Self.Character.Skills.Others[i].Index,
          Self.Character.Skills.Others[i].Level]);
      end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
    end;   }
    MySQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL SaveInGame: Skills error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      MySQLComp.Query.Connection.Rollback;
    end;
  end;
  { Skills On Bar }
  try
    MySQLComp.Query.Connection.StartTransaction;
    MySQLComp.SetQuery
      ('DELETE FROM itembars WHERE owner_charid='+ID.ToString+';');
    MySQLComp.Run(False);
    Cnt := 0;
    VarQuery := 'INSERT INTO itembars (owner_charid, slot, item) VALUES ';
    for i := 0 to 23 do
    begin
      if (Self.Base.Character.ItemBar[i] = 0) then //Self.Character.Base.ItemBar[i]
      begin
        Continue;
      end;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ', ('+ID.ToString+
          ', '+i.ToString+', '+Self.Base.Character.ItemBar[i].ToString+')';
      end
      else
      begin
        VarQuery := VarQuery + '('+ID.ToString+
          ', '+i.ToString+', '+Self.Base.Character.ItemBar[i].ToString+')';
      end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
    end;
   { Cnt := 0;
    VarQuery := 'INSERT INTO itembars (owner_charid, slot, item) VALUES ';
    for i := 12 to 23 do
    begin
      if (Self.Base.Character.ItemBar[i] = 0) then
      begin
        Continue;
      end;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + format(', (%d, %d, %d)',
          [ID, i, Self.Base.Character.ItemBar[i]]);
      end
      else
      begin
        VarQuery := VarQuery + format('(%d, %d, %d)',
          [ID, i, Self.Base.Character.ItemBar[i]]);
      end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
    end;  }
    MySQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL SaveInGame: Skills On Bar error. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      MySQLComp.Query.Connection.Rollback;
    end;
  end;
  { Buffs }
  try
    MySQLComp.Query.Connection.StartTransaction;
    MySQLComp.SetQuery('DELETE FROM buffs WHERE owner_charid='+ID.ToString+
      ';');
    MySQLComp.Run(False);
    Cnt := 0;
    VarQuery :=
      'INSERT INTO buffs (buff_index, buff_time, owner_charid) VALUES ';
    for i := 0 to 59 do
    begin
      if (Self.Base.PlayerCharacter.Buffs[i].Index = 0) then
      begin
        Continue;
      end;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ', ('+
        Self.Base.PlayerCharacter.Buffs[i].Index.ToString+
        ', "'+DateTimeToStr(Self.Base.PlayerCharacter.Buffs[i]
          .CreationTime)+'", '+ID.ToString+')';
      end
      else
      begin
        VarQuery := VarQuery + '('+
        Self.Base.PlayerCharacter.Buffs[i].Index.ToString+
        ', "'+DateTimeToStr(Self.Base.PlayerCharacter.Buffs[i]
          .CreationTime)+'", '+ID.ToString+')';
      end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
    end;
   { Cnt := 0;
    VarQuery :=
      'INSERT INTO buffs (buff_index, buff_time, owner_charid) VALUES ';
    for i := 30 to 59 do
    begin
      if (Self.Base.PlayerCharacter.Buffs[i].Index = 0) then
      begin
        Continue;
      end;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + format(', (%d, %s, %d)',
          [Self.Base.PlayerCharacter.Buffs[i].Index,
          QuotedStr(DateTimeToStr(Self.Base.PlayerCharacter.Buffs[i]
          .CreationTime)), ID]);
      end
      else
      begin
        VarQuery := VarQuery + format('(%d, %s, %d)',
          [Self.Base.PlayerCharacter.Buffs[i].Index,
          QuotedStr(DateTimeToStr(Self.Base.PlayerCharacter.Buffs[i]
          .CreationTime)), ID]);
      end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
    end;  }
    MySQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL SaveInGame: Buffs error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      MySQLComp.Query.Connection.Rollback;
    end;
  end;
  { Quests }
  try
    if not(Self.QuestCount = 0) then
    begin
      MySQLComp.Query.Connection.StartTransaction;
      MySQLComp.SetQuery('DELETE FROM quests WHERE charid='+ID.ToString+';');
      MySQLComp.Run(False);
      Cnt := 0;
      VarQuery :=
        'INSERT INTO quests (charid, questid, req1, req2, req3, req4, ' +
        'req5, isdone, updated_at, created_at) VALUES ';
      for i := 0 to 49 do
      begin
        if (Self.PlayerQuests[i].Quest.QuestID = 0) then
        begin
          Continue;
        end;
        if (Cnt > 0) then
        begin
          VarQuery := VarQuery +
            ', ('+ID.ToString+
            ', '+Self.PlayerQuests[i].ID.ToString+
            ', '+Self.PlayerQuests[i].Complete[0].ToString +
            ', '+Self.PlayerQuests[i].Complete[1].ToString+
            ', '+Self.PlayerQuests[i].Complete[2].ToString+
            ', '+Self.PlayerQuests[i].Complete[3].ToString+
            ', '+Self.PlayerQuests[i].Complete[4].ToString+
            ', '+Self.PlayerQuests[i].IsDone.ToInteger.ToString+
            ', '+TFunctions.DateTimeToUNIXTimeFAST(Self.PlayerQuests[i].UpdatedAt).ToString+
            ', '+TFunctions.DateTimeToUNIXTimeFAST(Self.PlayerQuests[i].CreatedAt).ToString+')';
        end
        else
        begin
          VarQuery := VarQuery +
            '('+ID.ToString+
            ', '+Self.PlayerQuests[i].ID.ToString+
            ', '+Self.PlayerQuests[i].Complete[0].ToString +
            ', '+Self.PlayerQuests[i].Complete[1].ToString+
            ', '+Self.PlayerQuests[i].Complete[2].ToString+
            ', '+Self.PlayerQuests[i].Complete[3].ToString+
            ', '+Self.PlayerQuests[i].Complete[4].ToString+
            ', '+Self.PlayerQuests[i].IsDone.ToInteger.ToString+
            ', '+TFunctions.DateTimeToUNIXTimeFAST(Self.PlayerQuests[i].UpdatedAt).ToString+
            ', '+TFunctions.DateTimeToUNIXTimeFAST(Self.PlayerQuests[i].CreatedAt).ToString+')';
        end;
        Inc(Cnt);
      end;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ';';
        MySQLComp.SetQuery(VarQuery);
        MySQLComp.Run(False);
      end;
      MySQLComp.Query.Connection.Commit;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL SaveInGame: Quests error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      MySQLComp.Query.Connection.Rollback;
    end;
  end;
  { Titles }
  try
    MySQLComp.Query.Connection.StartTransaction;
    MySQLComp.SetQuery('DELETE FROM titles WHERE owner_charid='+ID.ToString+ ';');
    MySQLComp.Run(False);
    Cnt := 0;
    VarQuery :=
      'INSERT INTO titles (title_index, title_level, title_progress, owner_charid) VALUES ';

    for i := 0 to 95 do
    begin
      //Self.Base.PlayerCharacter.Titles
      if (Self.Base.PlayerCharacter.Titles[i].Index = 0) then
      begin
        Continue;
      end;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ', ('+Self.Base.PlayerCharacter.Titles[i].Index.ToString+
        ', '+Self.Base.PlayerCharacter.Titles[i].Level.ToString+
        ', '+Self.Base.PlayerCharacter.Titles[i].Progress.ToString+
        ', '+ID.ToString+')';
      end
      else
      begin
        VarQuery := VarQuery + '('+Self.Base.PlayerCharacter.Titles[i].Index.ToString+
        ', '+Self.Base.PlayerCharacter.Titles[i].Level.ToString+
        ', '+Self.Base.PlayerCharacter.Titles[i].Progress.ToString+
        ', '+ID.ToString+')';
      end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
    end;
    MySQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL SaveInGame: Titles error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      MySQLComp.Query.Connection.Rollback;
    end;
  end;
  { Prans }
  try
    if (Account.Header.Pran1.Iddb > 0) then
    begin

      MySQLComp.SetQuery
        ('UPDATE prans SET name="'+String(Account.Header.Pran1.Name)+
        '", food='+Account.Header.Pran1.Food.ToString+
        ', devotion='+Account.Header.Pran1.Devotion.ToString+
        ', p_cute=' + Account.Header.Pran1.Personality.Cute.ToString +
        ', p_smart='+Account.Header.Pran1.Personality.Smart.ToString+
        ', p_sexy='+Account.Header.Pran1.Personality.Sexy.ToString+
        ', p_energetic='+Account.Header.Pran1.Personality.Energetic.ToString+
        ', p_tough=' + Account.Header.Pran1.Personality.Tough.ToString +
        ', p_corrupt='+Account.Header.Pran1.Personality.Corrupt.ToString+
        ', level='+Account.Header.Pran1.Level.ToString+
        ', class='+Account.Header.Pran1.ClassPran.ToString+
        ', hp='+Account.Header.Pran1.CurHP.ToString+
        ', max_hp=' + Account.Header.Pran1.MaxHp.ToString +
        ', mp='+Account.Header.Pran1.CurMp.ToString+
        ', max_mp='+Account.Header.Pran1.MaxMP.ToString+
        ', xp='+Account.Header.Pran1.Exp.ToString+
        ', def_p='+Account.Header.Pran1.DefFis.ToString+
        ', def_m='+Account.Header.Pran1.DefMag.ToString +
        ' WHERE id='+Account.Header.Pran1.Iddb.ToString+';');

      MySQLComp.Query.Connection.StartTransaction;
      MySQLComp.Run(False);
      MySQLComp.Query.Connection.Commit;
      { PlayerSQL.AddParameter2('pname', String(Account.Header.Pran1.Name));
        PlayerSQL.AddParameter2('pfood', Account.Header.Pran1.Food);
        PlayerSQL.AddParameter2('pdevotion', Account.Header.Pran1.Devotion);
        PlayerSQL.AddParameter2('pp_cute', Account.Header.Pran1.Personality.Cute);
        PlayerSQL.AddParameter2('pp_smart',
        Account.Header.Pran1.Personality.Smart);
        PlayerSQL.AddParameter2('pp_sexy', Account.Header.Pran1.Personality.Sexy);
        PlayerSQL.AddParameter2('pp_energetic',
        Account.Header.Pran1.Personality.Energetic);
        PlayerSQL.AddParameter2('pp_tough',
        Account.Header.Pran1.Personality.Tough);
        PlayerSQL.AddParameter2('pp_corrupt',
        Account.Header.Pran1.Personality.Corrupt);
        PlayerSQL.AddParameter2('plevel', Account.Header.Pran1.Level);
        PlayerSQL.AddParameter2('pclass', Account.Header.Pran1.ClassPran);
        PlayerSQL.AddParameter2('php', Account.Header.Pran1.CurHP);
        PlayerSQL.AddParameter2('pmax_hp', Account.Header.Pran1.MaxHp);
        PlayerSQL.AddParameter2('pmp', Account.Header.Pran1.CurMp);
        PlayerSQL.AddParameter2('pmax_mp', Account.Header.Pran1.MaxMP);
        PlayerSQL.AddParameter2('pxp', Account.Header.Pran1.Exp);
        PlayerSQL.AddParameter2('pdef_p', Account.Header.Pran1.DefFis);
        PlayerSQL.AddParameter2('pdef_m', Account.Header.Pran1.DefMag);
        PlayerSQL.AddParameter2('pid', Account.Header.Pran1.Iddb);
        PlayerSQL.Run(FALSE); }
      { Pran Equip }
      try
        MySQLComp.Query.Connection.StartTransaction;
        MySQLComp.SetQuery
          ('DELETE FROM items WHERE owner_id='+
            Account.Header.Pran1.Iddb.ToString+' AND slot_type='+
            PRAN_EQUIP_TYPE.ToString+';');
        // PlayerSQL.AddParameter2('powner_id', Account.Header.Pran1.Iddb);
        // PlayerSQL.AddParameter2('pslot_type', PRAN_EQUIP_TYPE);
        MySQLComp.Run(False);

        Cnt := 0;
        VarQuery := 'INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
          'app, identific, effect1_index, effect1_value, effect2_index, effect2_value,'
          + ' effect3_index, effect3_value, min, max, refine, time) VALUES ';
        for i := 0 to 15 do
        begin
          Item := @Account.Header.Pran1.Equip[i];
          if (Item^.Index = 0) then
            Continue;
          if (Cnt > 0) then
          begin
            VarQuery := VarQuery +
              ', ('+PRAN_EQUIP_TYPE.ToString+
              ', '+Account.Header.Pran1.Iddb.ToString+
              ', '+i.ToString+', '+Item^.Index.ToString+
              ', '+Item^.APP.ToString+', '+Item^.Identific.ToString+
              ', '+Item^.Effects.Index[0].ToString+
              ', '+Item^.Effects.Value[0].ToString+
              ', '+Item^.Effects.Index[1].ToString+
              ', '+Item^.Effects.Value[1].ToString+
              ', '+Item^.Effects.Index[2].ToString+
              ', '+Item^.Effects.Value[2].ToString+
              ', '+Item^.MIN.ToString+
              ', '+Item^.MAX.ToString+
              ', '+Item^.Refi.ToString+', '+Item^.Time.ToString+')';
          end
          else
          begin
            VarQuery := VarQuery +
              '('+PRAN_EQUIP_TYPE.ToString+
              ', '+Account.Header.Pran1.Iddb.ToString+
              ', '+i.ToString+', '+Item^.Index.ToString+
              ', '+Item^.APP.ToString+', '+Item^.Identific.ToString+
              ', '+Item^.Effects.Index[0].ToString+
              ', '+Item^.Effects.Value[0].ToString+
              ', '+Item^.Effects.Index[1].ToString+
              ', '+Item^.Effects.Value[1].ToString+
              ', '+Item^.Effects.Index[2].ToString+
              ', '+Item^.Effects.Value[2].ToString+
              ', '+Item^.MIN.ToString+
              ', '+Item^.MAX.ToString+
              ', '+Item^.Refi.ToString+', '+Item^.Time.ToString+')';
          end;
          Inc(Cnt);
        end;
        if (Cnt > 0) then
        begin
          VarQuery := VarQuery + ';';
          MySQLComp.SetQuery(VarQuery);
          MySQLComp.Run(False);

        end;
        MySQLComp.Query.Connection.Commit;
      except
        on E: Exception do
        begin
          MySQLComp.Query.Connection.Rollback;
          Logger.Write('Erro ao salvar PRAN1_EQUIP: ' +E.Message,
            TLogType.Error);
        end;
      end;

      try
        MySQLComp.Query.Connection.StartTransaction;
        { Pran Inventory }
        MySQLComp.SetQuery
          ('DELETE FROM items WHERE owner_id='+
            Account.Header.Pran1.Iddb.ToString+' AND slot_type='+
              PRAN_INV_TYPE.ToString+';');
        // PlayerSQL.AddParameter2('powner_id', Account.Header.Pran1.Iddb);
        // PlayerSQL.AddParameter2('pslot_type', PRAN_INV_TYPE);

        MySQLComp.Run(False);
        //MySQLComp.Query.Connection.Commit;
        Cnt := 0;
        VarQuery := 'INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
          'app, identific, effect1_index, effect1_value, effect2_index, effect2_value,'
          + ' effect3_index, effect3_value, min, max, refine, time) VALUES ';
        for i := 0 to 41 do
        begin
          Item := @Account.Header.Pran1.Inventory[i];
          if (Item^.Index = 0) then
            Continue;
          if (Cnt > 0) then
          begin
            VarQuery := VarQuery +
                ', ('+PRAN_INV_TYPE.ToString+
                ', '+Account.Header.Pran1.Iddb.ToString+
                ', '+i.ToString+', '+Item^.Index.ToString+
                ', '+Item^.APP.ToString+', '+Item^.Identific.ToString+
                ', '+Item^.Effects.Index[0].ToString+
                ', '+Item^.Effects.Value[0].ToString+
                ', '+Item^.Effects.Index[1].ToString+
                ', '+Item^.Effects.Value[1].ToString+
                ', '+Item^.Effects.Index[2].ToString+
                ', '+Item^.Effects.Value[2].ToString+
                ', '+Item^.MIN.ToString+
                ', '+Item^.MAX.ToString+
                ', '+Item^.Refi.ToString+', '+Item^.Time.ToString+')';
          end
          else
          begin
            VarQuery := VarQuery +
                '('+PRAN_INV_TYPE.ToString+
                ', '+Account.Header.Pran1.Iddb.ToString+
                ', '+i.ToString+', '+Item^.Index.ToString+
                ', '+Item^.APP.ToString+', '+Item^.Identific.ToString+
                ', '+Item^.Effects.Index[0].ToString+
                ', '+Item^.Effects.Value[0].ToString+
                ', '+Item^.Effects.Index[1].ToString+
                ', '+Item^.Effects.Value[1].ToString+
                ', '+Item^.Effects.Index[2].ToString+
                ', '+Item^.Effects.Value[2].ToString+
                ', '+Item^.MIN.ToString+
                ', '+Item^.MAX.ToString+
                ', '+Item^.Refi.ToString+', '+Item^.Time.ToString+')';
          end;
          Inc(Cnt);
        end;
        if (Cnt > 0) then
        begin
          VarQuery := VarQuery + ';';
          MySQLComp.SetQuery(VarQuery);
          //MySQLComp.Query.Connection.StartTransaction;
          MySQLComp.Run(False);

        end;
        MySQLComp.Query.Connection.Commit;
      except
        on E: Exception do
        begin
          MySQLComp.Query.Connection.Rollback;
          Logger.Write('Erro ao salvar PRAN1_INVENT: ' +E.Message,
            TLogType.Error);
        end;

      end;
      {Cnt := 0;
      VarQuery := 'INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
        'app, identific, effect1_index, effect1_value, effect2_index, effect2_value,'
        + ' effect3_index, effect3_value, min, max, refine, time) VALUES ';
      for i := 21 to 41 do
      begin
        Item := @Account.Header.Pran1.Inventory[i];
        if (Item^.Index = 0) then
          Continue;
        if (Cnt > 0) then
        begin
          VarQuery := VarQuery +
            format(', (%d, %d, %d, %d, ' + '%d, %d, %d, %d, %d, %d,' +
            ' %d, %d, %d, %d, %d, %d)',
            [PRAN_INV_TYPE, Account.Header.Pran1.Iddb, i, Item^.Index,
            Item^.APP, Item^.Identific, Item^.Effects.Index[0],
            Item^.Effects.Value[0], Item^.Effects.Index[1],
            Item^.Effects.Value[1], Item^.Effects.Index[2],
            Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
            Item^.Time]);
        end
        else
        begin
          VarQuery := VarQuery +
            format('(%d, %d, %d, %d, ' + '%d, %d, %d, %d, %d, %d,' +
            ' %d, %d, %d, %d, %d, %d)',
            [PRAN_INV_TYPE, Account.Header.Pran1.Iddb, i, Item^.Index,
            Item^.APP, Item^.Identific, Item^.Effects.Index[0],
            Item^.Effects.Value[0], Item^.Effects.Index[1],
            Item^.Effects.Value[1], Item^.Effects.Index[2],
            Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
            Item^.Time]);
        end;
        Inc(Cnt);
      end;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ';';
        MySQLComp.SetQuery(VarQuery);
        MySQLComp.Run(False);
      end; }
      { Pran Skills }
      try
        MySQLComp.Query.Connection.StartTransaction;
        
        MySQLComp.SetQuery
          ('DELETE FROM skills WHERE owner_charid='+
            Account.Header.Pran1.Iddb.ToString+' AND type=3;');
        // PlayerSQL.AddParameter2('powner_charid', Account.Header.Pran1.Iddb);
        // PlayerSQL.AddParameter2('ptype', 3);
        
        MySQLComp.Run(False);
        //MySQLComp.Query.Connection.Commit;
        Cnt := 0;
        VarQuery :=
          'INSERT INTO skills (owner_charid, slot, item, level, type) VALUES ';
        for i := 0 to 9 do // PRANSKILL_ATENTION elas podem ser (10) ou (12)
        begin
          if (Account.Header.Pran1.Skills[i].Index = 0) then
            Continue;
          if (Cnt > 0) then
          begin
            VarQuery := VarQuery + ', ('+
              Account.Header.Pran1.Iddb.ToString+
              ', '+i.ToString+
              ', '+Account.Header.Pran1.Skills[i].Index.ToString+
              ', '+Account.Header.Pran1.Skills[i].Level.ToString+', 3)';
          end
          else
          begin
            VarQuery := VarQuery + '('+
              Account.Header.Pran1.Iddb.ToString+
              ', '+i.ToString+
              ', '+Account.Header.Pran1.Skills[i].Index.ToString+
              ', '+Account.Header.Pran1.Skills[i].Level.ToString+', 3)';
          end;
          Inc(Cnt);
        end;
        if (Cnt > 0) then
        begin
          VarQuery := VarQuery + ';';
          MySQLComp.SetQuery(VarQuery);
          //MySQLComp.Query.Connection.StartTransaction;
          MySQLComp.Run(False);
          
        end;
        MySQLComp.Query.Connection.Commit;
      except
        on E: Exception do
        begin
          MySQLComp.Query.Connection.Rollback;
          Logger.Write('Erro ao salvar PRAN1_SKILLS: ' + E.Message,
            TLogType.Error);
        end;

      end;
      { Pran Skill Bar }
      try
        MySQLComp.Query.Connection.StartTransaction;
        MySQLComp.SetQuery('DELETE FROM itembars WHERE owner_charid='+
          (Account.Header.Pran1.Iddb+1024000).ToString+';');
          
        // PlayerSQL.AddParameter2('powner_charid', Account.Header.Pran1.Iddb);
        
        MySQLComp.Run(False);
        //MySQLComp.Query.Connection.Commit;
        Cnt := 0;
        VarQuery := 'INSERT INTO itembars (owner_charid, slot, item) VALUES ';
        for i := 0 to 2 do
        begin
          if (Account.Header.Pran1.ItemBar[i] = 0) then
            Continue;
          if (Cnt > 0) then
          begin
            VarQuery := VarQuery + format(', (%d, %d, %d)',
              [Account.Header.Pran1.Iddb+1024000, (i + 100),
              Account.Header.Pran1.ItemBar[i]]);
          end
          else
          begin
            VarQuery := VarQuery + format('(%d, %d, %d)',
              [Account.Header.Pran1.Iddb+1024000, (i + 100),
              Account.Header.Pran1.ItemBar[i]]);
          end;
          Inc(Cnt);
        end;
        if (Cnt > 0) then
        begin
          VarQuery := VarQuery + ';';
          MySQLComp.SetQuery(VarQuery);
          //MySQLComp.Query.Connection.StartTransaction;
          MySQLComp.Run(False);
        end;
        MySQLComp.Query.Connection.Commit;
      except
        on E: Exception do
        begin
          MySQLComp.Query.Connection.Rollback;
          Logger.Write('Erro ao salvar PRAN1_SKILLBAR: ' + E.Message,
            TLogType.Error);
        end;

      end;
      //MySQLComp.Query.Connection.Commit;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL SaveInGame: Pran1 error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      //MySQLComp.Query.Connection.Rollback;
    end;
  end;

  try
    if (Account.Header.Pran2.Iddb > 0) then
    begin

      MySQLComp.SetQuery
        ('UPDATE prans SET name="'+String(Account.Header.Pran2.Name)+
        '", food='+Account.Header.Pran2.Food.ToString+
        ', devotion='+Account.Header.Pran2.Devotion.ToString+
        ', p_cute=' + Account.Header.Pran2.Personality.Cute.ToString +
        ', p_smart='+Account.Header.Pran2.Personality.Smart.ToString+
        ', p_sexy='+Account.Header.Pran2.Personality.Sexy.ToString+
        ', p_energetic='+Account.Header.Pran2.Personality.Energetic.ToString+
        ', p_tough=' + Account.Header.Pran2.Personality.Tough.ToString +
        ', p_corrupt='+Account.Header.Pran2.Personality.Corrupt.ToString+
        ', level='+Account.Header.Pran2.Level.ToString+
        ', class='+Account.Header.Pran2.ClassPran.ToString+
        ', hp='+Account.Header.Pran2.CurHP.ToString+
        ', max_hp=' + Account.Header.Pran2.MaxHp.ToString +
        ', mp='+Account.Header.Pran2.CurMp.ToString+
        ', max_mp='+Account.Header.Pran2.MaxMP.ToString+
        ', xp='+Account.Header.Pran2.Exp.ToString+
        ', def_p='+Account.Header.Pran2.DefFis.ToString+
        ', def_m='+Account.Header.Pran2.DefMag.ToString +
        ' WHERE id='+Account.Header.Pran2.Iddb.ToString+';');

      MySQLComp.Query.Connection.StartTransaction;
      MySQLComp.Run(False);
      MySQLComp.Query.Connection.Commit;
      { PlayerSQL.AddParameter2('pname', String(Account.Header.Pran1.Name));
        PlayerSQL.AddParameter2('pfood', Account.Header.Pran1.Food);
        PlayerSQL.AddParameter2('pdevotion', Account.Header.Pran1.Devotion);
        PlayerSQL.AddParameter2('pp_cute', Account.Header.Pran1.Personality.Cute);
        PlayerSQL.AddParameter2('pp_smart',
        Account.Header.Pran1.Personality.Smart);
        PlayerSQL.AddParameter2('pp_sexy', Account.Header.Pran1.Personality.Sexy);
        PlayerSQL.AddParameter2('pp_energetic',
        Account.Header.Pran1.Personality.Energetic);
        PlayerSQL.AddParameter2('pp_tough',
        Account.Header.Pran1.Personality.Tough);
        PlayerSQL.AddParameter2('pp_corrupt',
        Account.Header.Pran1.Personality.Corrupt);
        PlayerSQL.AddParameter2('plevel', Account.Header.Pran1.Level);
        PlayerSQL.AddParameter2('pclass', Account.Header.Pran1.ClassPran);
        PlayerSQL.AddParameter2('php', Account.Header.Pran1.CurHP);
        PlayerSQL.AddParameter2('pmax_hp', Account.Header.Pran1.MaxHp);
        PlayerSQL.AddParameter2('pmp', Account.Header.Pran1.CurMp);
        PlayerSQL.AddParameter2('pmax_mp', Account.Header.Pran1.MaxMP);
        PlayerSQL.AddParameter2('pxp', Account.Header.Pran1.Exp);
        PlayerSQL.AddParameter2('pdef_p', Account.Header.Pran1.DefFis);
        PlayerSQL.AddParameter2('pdef_m', Account.Header.Pran1.DefMag);
        PlayerSQL.AddParameter2('pid', Account.Header.Pran1.Iddb);
        PlayerSQL.Run(FALSE); }
      { Pran Equip }
      try
        MySQLComp.Query.Connection.StartTransaction;
        MySQLComp.SetQuery
          ('DELETE FROM items WHERE owner_id='+
            Account.Header.Pran2.Iddb.ToString+' AND slot_type='+
            PRAN_EQUIP_TYPE.ToString+';');
        // PlayerSQL.AddParameter2('powner_id', Account.Header.Pran1.Iddb);
        // PlayerSQL.AddParameter2('pslot_type', PRAN_EQUIP_TYPE);
        MySQLComp.Run(False);

        Cnt := 0;
        VarQuery := 'INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
          'app, identific, effect1_index, effect1_value, effect2_index, effect2_value,'
          + ' effect3_index, effect3_value, min, max, refine, time) VALUES ';
        for i := 0 to 15 do
        begin
          Item := @Account.Header.Pran2.Equip[i];
          if (Item^.Index = 0) then
            Continue;
          if (Cnt > 0) then
          begin
            VarQuery := VarQuery +
              ', ('+PRAN_EQUIP_TYPE.ToString+
              ', '+Account.Header.Pran2.Iddb.ToString+
              ', '+i.ToString+', '+Item^.Index.ToString+
              ', '+Item^.APP.ToString+', '+Item^.Identific.ToString+
              ', '+Item^.Effects.Index[0].ToString+
              ', '+Item^.Effects.Value[0].ToString+
              ', '+Item^.Effects.Index[1].ToString+
              ', '+Item^.Effects.Value[1].ToString+
              ', '+Item^.Effects.Index[2].ToString+
              ', '+Item^.Effects.Value[2].ToString+
              ', '+Item^.MIN.ToString+
              ', '+Item^.MAX.ToString+
              ', '+Item^.Refi.ToString+', '+Item^.Time.ToString+')';
          end
          else
          begin
            VarQuery := VarQuery +
              '('+PRAN_EQUIP_TYPE.ToString+
              ', '+Account.Header.Pran2.Iddb.ToString+
              ', '+i.ToString+', '+Item^.Index.ToString+
              ', '+Item^.APP.ToString+', '+Item^.Identific.ToString+
              ', '+Item^.Effects.Index[0].ToString+
              ', '+Item^.Effects.Value[0].ToString+
              ', '+Item^.Effects.Index[1].ToString+
              ', '+Item^.Effects.Value[1].ToString+
              ', '+Item^.Effects.Index[2].ToString+
              ', '+Item^.Effects.Value[2].ToString+
              ', '+Item^.MIN.ToString+
              ', '+Item^.MAX.ToString+
              ', '+Item^.Refi.ToString+', '+Item^.Time.ToString+')';
          end;
          Inc(Cnt);
        end;
        if (Cnt > 0) then
        begin
          VarQuery := VarQuery + ';';
          MySQLComp.SetQuery(VarQuery);
          MySQLComp.Run(False);

        end;
        MySQLComp.Query.Connection.Commit;
      except
        on E: Exception do
        begin
          MySQLComp.Query.Connection.Rollback;
          Logger.Write('Erro ao salvar PRAN1_EQUIP: ' +E.Message,
            TLogType.Error);
        end;
      end;

      try
        MySQLComp.Query.Connection.StartTransaction;
        { Pran Inventory }
        MySQLComp.SetQuery
          ('DELETE FROM items WHERE owner_id='+
            Account.Header.Pran2.Iddb.ToString+' AND slot_type='+
              PRAN_INV_TYPE.ToString+';');
        // PlayerSQL.AddParameter2('powner_id', Account.Header.Pran1.Iddb);
        // PlayerSQL.AddParameter2('pslot_type', PRAN_INV_TYPE);

        MySQLComp.Run(False);
        //MySQLComp.Query.Connection.Commit;
        Cnt := 0;
        VarQuery := 'INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
          'app, identific, effect1_index, effect1_value, effect2_index, effect2_value,'
          + ' effect3_index, effect3_value, min, max, refine, time) VALUES ';
        for i := 0 to 41 do
        begin
          Item := @Account.Header.Pran2.Inventory[i];
          if (Item^.Index = 0) then
            Continue;
          if (Cnt > 0) then
          begin
            VarQuery := VarQuery +
                ', ('+PRAN_INV_TYPE.ToString+
                ', '+Account.Header.Pran2.Iddb.ToString+
                ', '+i.ToString+', '+Item^.Index.ToString+
                ', '+Item^.APP.ToString+', '+Item^.Identific.ToString+
                ', '+Item^.Effects.Index[0].ToString+
                ', '+Item^.Effects.Value[0].ToString+
                ', '+Item^.Effects.Index[1].ToString+
                ', '+Item^.Effects.Value[1].ToString+
                ', '+Item^.Effects.Index[2].ToString+
                ', '+Item^.Effects.Value[2].ToString+
                ', '+Item^.MIN.ToString+
                ', '+Item^.MAX.ToString+
                ', '+Item^.Refi.ToString+', '+Item^.Time.ToString+')';
          end
          else
          begin
            VarQuery := VarQuery +
                '('+PRAN_INV_TYPE.ToString+
                ', '+Account.Header.Pran2.Iddb.ToString+
                ', '+i.ToString+', '+Item^.Index.ToString+
                ', '+Item^.APP.ToString+', '+Item^.Identific.ToString+
                ', '+Item^.Effects.Index[0].ToString+
                ', '+Item^.Effects.Value[0].ToString+
                ', '+Item^.Effects.Index[1].ToString+
                ', '+Item^.Effects.Value[1].ToString+
                ', '+Item^.Effects.Index[2].ToString+
                ', '+Item^.Effects.Value[2].ToString+
                ', '+Item^.MIN.ToString+
                ', '+Item^.MAX.ToString+
                ', '+Item^.Refi.ToString+', '+Item^.Time.ToString+')';
          end;
          Inc(Cnt);
        end;
        if (Cnt > 0) then
        begin
          VarQuery := VarQuery + ';';
          MySQLComp.SetQuery(VarQuery);
          //MySQLComp.Query.Connection.StartTransaction;
          MySQLComp.Run(False);

        end;
        MySQLComp.Query.Connection.Commit;
      except
        on E: Exception do
        begin
          MySQLComp.Query.Connection.Rollback;
          Logger.Write('Erro ao salvar PRAN1_INVENT: ' +E.Message,
            TLogType.Error);
        end;

      end;
      {Cnt := 0;
      VarQuery := 'INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
        'app, identific, effect1_index, effect1_value, effect2_index, effect2_value,'
        + ' effect3_index, effect3_value, min, max, refine, time) VALUES ';
      for i := 21 to 41 do
      begin
        Item := @Account.Header.Pran1.Inventory[i];
        if (Item^.Index = 0) then
          Continue;
        if (Cnt > 0) then
        begin
          VarQuery := VarQuery +
            format(', (%d, %d, %d, %d, ' + '%d, %d, %d, %d, %d, %d,' +
            ' %d, %d, %d, %d, %d, %d)',
            [PRAN_INV_TYPE, Account.Header.Pran1.Iddb, i, Item^.Index,
            Item^.APP, Item^.Identific, Item^.Effects.Index[0],
            Item^.Effects.Value[0], Item^.Effects.Index[1],
            Item^.Effects.Value[1], Item^.Effects.Index[2],
            Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
            Item^.Time]);
        end
        else
        begin
          VarQuery := VarQuery +
            format('(%d, %d, %d, %d, ' + '%d, %d, %d, %d, %d, %d,' +
            ' %d, %d, %d, %d, %d, %d)',
            [PRAN_INV_TYPE, Account.Header.Pran1.Iddb, i, Item^.Index,
            Item^.APP, Item^.Identific, Item^.Effects.Index[0],
            Item^.Effects.Value[0], Item^.Effects.Index[1],
            Item^.Effects.Value[1], Item^.Effects.Index[2],
            Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi,
            Item^.Time]);
        end;
        Inc(Cnt);
      end;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ';';
        MySQLComp.SetQuery(VarQuery);
        MySQLComp.Run(False);
      end; }
      { Pran Skills }
      try
        MySQLComp.Query.Connection.StartTransaction;
        
        MySQLComp.SetQuery
          ('DELETE FROM skills WHERE owner_charid='+
            Account.Header.Pran2.Iddb.ToString+' AND type=3;');
        // PlayerSQL.AddParameter2('powner_charid', Account.Header.Pran1.Iddb);
        // PlayerSQL.AddParameter2('ptype', 3);
        
        MySQLComp.Run(False);
        //MySQLComp.Query.Connection.Commit;
        Cnt := 0;
        VarQuery :=
          'INSERT INTO skills (owner_charid, slot, item, level, type) VALUES ';
        for i := 0 to 9 do // PRANSKILL_ATENTION elas podem ser (10) ou (12)
        begin
          if (Account.Header.Pran2.Skills[i].Index = 0) then
            Continue;
          if (Cnt > 0) then
          begin
            VarQuery := VarQuery + ', ('+
              Account.Header.Pran2.Iddb.ToString+
              ', '+i.ToString+
              ', '+Account.Header.Pran2.Skills[i].Index.ToString+
              ', '+Account.Header.Pran2.Skills[i].Level.ToString+', 3)';
          end
          else
          begin
            VarQuery := VarQuery + '('+
              Account.Header.Pran2.Iddb.ToString+
              ', '+i.ToString+
              ', '+Account.Header.Pran2.Skills[i].Index.ToString+
              ', '+Account.Header.Pran2.Skills[i].Level.ToString+', 3)';
          end;
          Inc(Cnt);
        end;
        if (Cnt > 0) then
        begin
          VarQuery := VarQuery + ';';
          MySQLComp.SetQuery(VarQuery);
          //MySQLComp.Query.Connection.StartTransaction;
          MySQLComp.Run(False);
          
        end;
        MySQLComp.Query.Connection.Commit;
      except
        on E: Exception do
        begin
          MySQLComp.Query.Connection.Rollback;
          Logger.Write('Erro ao salvar PRAN1_SKILLS: ' + E.Message,
            TLogType.Error);
        end;

      end;
      { Pran Skill Bar }
      try
        MySQLComp.Query.Connection.StartTransaction;
        MySQLComp.SetQuery('DELETE FROM itembars WHERE owner_charid='+
          (Account.Header.Pran2.Iddb+1024000).ToString+';');
          
        // PlayerSQL.AddParameter2('powner_charid', Account.Header.Pran1.Iddb);
        
        MySQLComp.Run(False);
        //MySQLComp.Query.Connection.Commit;
        Cnt := 0;
        VarQuery := 'INSERT INTO itembars (owner_charid, slot, item) VALUES ';
        for i := 0 to 2 do
        begin
          if (Account.Header.Pran2.ItemBar[i] = 0) then
            Continue;
          if (Cnt > 0) then
          begin
            VarQuery := VarQuery + format(', (%d, %d, %d)',
              [Account.Header.Pran2.Iddb+1024000, (i + 100),
              Account.Header.Pran2.ItemBar[i]]);
          end
          else
          begin
            VarQuery := VarQuery + format('(%d, %d, %d)',
              [Account.Header.Pran2.Iddb+1024000, (i + 100),
              Account.Header.Pran2.ItemBar[i]]);
          end;
          Inc(Cnt);
        end;
        if (Cnt > 0) then
        begin
          VarQuery := VarQuery + ';';
          MySQLComp.SetQuery(VarQuery);
          //MySQLComp.Query.Connection.StartTransaction;
          MySQLComp.Run(False);
        end;
        MySQLComp.Query.Connection.Commit;
      except
        on E: Exception do
        begin
          MySQLComp.Query.Connection.Rollback;
          Logger.Write('Erro ao salvar PRAN1_SKILLBAR: ' + E.Message,
            TLogType.Error);
        end;

      end;
      //MySQLComp.Query.Connection.Commit;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL SaveInGame: Pran1 error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      //MySQLComp.Query.Connection.Rollback;
    end;
  end;
  MySQLComp.Destroy;
  Result := True;
end;
function TPlayer.LoadCharacterTeleportList(CharName: String): Boolean;
var
  SList1, SList2: TStringList;
  PositionsLine: String;
  i, Cnt: Integer;
  SQLComp: TQuery;
begin
  Result := FALSE;
  if not(Self.Base.GetMobClass = 4) then
    Exit;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[LoadCharacterTeleportList]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[LoadCharacterTeleportList]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    SQLComp.SetQuery
      (format('SELECT tp_positions FROM characters WHERE name=%s',
      [QuotedStr(CharName)]));
    SQLComp.Run();
    PositionsLine := SQLComp.Query.FieldByName('tp_positions').AsString;
    if not(PositionsLine = '') then
    begin
      SList1 := TStringList.Create;
      SList2 := TStringList.Create;
      ExtractStrings([';'], [' '], PChar(PositionsLine), SList1);
      ExtractStrings([','], [' '], PChar(SList1.Text), SList2);
      Cnt := 0;
      for I := 0 to ((SList2.Count div 2)-1) do
      begin
        Self.TeleportList[i] := TPosition.Create(StrToInt(SList2.Strings[cnt]),
          StrToInt(SList2.Strings[cnt+1]));
        cnt := cnt + 2;
      end;
      FreeAndNil(SList1);
      FreeAndNil(SList2);
    end;
  except
    on E: Exception do
      Logger.Write('MYSQL Load TeleportList error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
  end;
  SQLComp.Destroy;
  Result := True;
end;
function TPlayer.SaveCharacterTeleportList(CharName: String): Boolean;
var
  ID, i: Integer;
  LinePositions, LinePos: String;
  SQLComp: TQuery;
begin
  Result := FALSE;
  if not(Self.Base.GetMobClass = 4) then
    Exit;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SaveCharacterTeleportList]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveCharacterTeleportList]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    // PlayerSQL.MySQL.StartTransaction;
    for i := 0 to 4 do
    begin
      if not(Self.TeleportList[i].IsValid) then
        Continue;
      LinePos := Round(Self.TeleportList[i].X).ToString + ',' +
        Round(Self.TeleportList[i].Y).ToString;
      LinePositions := LinePositions + LinePos + ';';
    end;
    SQLComp.SetQuery(format('SELECT id FROM characters WHERE name=%s',
      [QuotedStr(CharName)]));
    // PlayerSQL.AddParameter2('pname', CharName);
    SQLComp.Run();
    ID := SQLComp.Query.FieldByName('id').AsInteger;
    SQLComp.SetQuery
      (format('UPDATE characters SET tp_positions=%s WHERE id=%d',
      [QuotedStr(LinePositions), ID]));
    // PlayerSQL.AddParameter2('pid', ID);
    // PlayerSQL.AddParameter2('ptp_positions', LinePositions);
    SQLComp.Run(False);
    // PlayerSQL.MySQL.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Save TeleportList error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      //PlayerSQL.Query.Connection.Rollback;
    end;
  end;
  SQLComp.Destroy;
  Result := True;
end;
function TPlayer.LoadSavedLocation(): TPosition;
var
  SQLComp: TQuery;
begin
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[LoadSavedLocation]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[LoadSavedLocation]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    SQLComp.SetQuery
      ('SELECT saved_posx, saved_posy FROM characters WHERE id=' +
      Self.Character.Base.CharIndex.ToString);
    SQLComp.Run();
    if (SQLComp.Query.RecordCount = 0) then
    begin
      Result.Create(3450, 690);
    end
    else
    begin
      Result.Create(SQLComp.Query.FieldByName('saved_posx').AsInteger,
        SQLComp.Query.FieldByName('saved_posy').AsInteger);
      if not(Result.IsValid) then
      begin
        Result.Create(3450, 690);
      end;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('TPlayer.LoadSavedLocation ' + E.Message, TlogType.Error);
    end;
  end;
  SQLComp.Destroy;
end;
function TPlayer.SaveSavedLocation(Pos: TPosition): Boolean;
var
  SQLComp: TQuery;
begin
  Result := FALSE;
  if ((Pos.X = 0) or (Pos.Y = 0)) then
    Exit;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SaveSavedLocation]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveSavedLocation]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    SQLComp.SetQuery
      ('UPDATE characters SET saved_posx='+Round(Pos.X).ToString+
      ', saved_posy='+Round(Pos.Y).ToString+' WHERE id='+
      Self.Character.Base.CharIndex.ToString);
    SQLComp.Run(False);
    SQLComp.Destroy;
    Result := True;
  except
    on E: Exception do
    begin
      Logger.Write('TPlayer.SaveSavedLocation ' + E.Message, TlogType.Error);
    end;
  end;
end;
function TPlayer.CheckSelfSocket(): Boolean;
begin
  Result := not(Self.Socket = INVALID_SOCKET);
end;
procedure TPlayer.SendPacket(const Packet; size: WORD; Encrypt: Boolean);
var
  RetVal: Integer;
  Buffer: ARRAY [0..21999] OF BYTE;
begin
  if(Self.SocketClosed) then
    Exit;

  if(size > 21999) then
    Exit;

  ZeroMemory(@Buffer, 22000);
  //if not (CheckSelfSocket) then
  //while(Self.SockInUse) do
  //begin
    //Sleep(10);
  //end;
  //Self.SockInUse := True;
  // SetLength(Buffer, size+1);
  //ZeroMemory(@Buffer, size);
  //SetLength(Buffer, size);
  //Move(Packet, Buffer[0], size);
  //if Encrypt then
  //begin
    //TEncDec.Encrypt(@Buffer, size);
  //end;
  if(Self.Socket <> INVALID_SOCKET) then
  begin
    Move(Packet, Buffer[0], size);
    TEncDec.Encrypt(@Buffer, size);
    try
      RetVal := Send(Socket, Buffer, size, 0);  //Socket
    except
      on E: Exception do
      begin
        Logger.Write('erro no sendpacket '+ E.Message, TlogType.Error);
        shutdown(Self.Socket, 0);
        Servers[Self.ChannelIndex].Disconnect(Self);
        Self.SocketClosed := True;
      end;
    end;
    if (RetVal = SOCKET_ERROR) then
    begin
      if(WSAGetLastError = WSAEWOULDBLOCK) then
        Exit;
      shutdown(Self.Socket, 0);
      //Servers[Self.ChannelIndex].Disconnect(Self);
      Self.SocketClosed := True;
    end;

     { if not(Self.Unlogging) then
      begin
        Logger.Write('Send failed with error: ' + IntToStr(WSAGetLastError),
          TlogType.Warnings);
        Self.Socket := INVALID_SOCKET;
        closesocket(Self.Socket);
        //Servers[Self.ChannelIndex].Disconnect(Self);
        //Servers[Self.ChannelIndex].Players[Self.Base.ClientID].PlayerThreadActive := FALSE;
        //PlayersThreads := PlayersThreads-1;
        //Servers[Self.ChannelIndex].Disconnect(Self);
        //Self.Destroy;
        //Send(Self.Socket, Buffer, size, 0);
        //Self.SockInUse := False;
      end;
    end
    else
      Self.SockInUse := False; }
  end;
end;
procedure TPlayer.SendSignal(headerClientId, packetCode: WORD);
var
  signal: TPacketHeader;
begin
  ZeroMemory(@signal, sizeof(TPacketHeader));
  signal.size := sizeof(TPacketHeader);
  signal.Index := headerClientId;
  signal.Code := packetCode;
  SendPacket(signal, signal.size)
end;
procedure TPlayer.SendSignal(Client, packetCode, size: WORD);
var
  signal: TPacketHeader;
  Buffer: array of BYTE;
begin
  ZeroMemory(@signal, sizeof(TPacketHeader));
  SetLength(Buffer, size);
  ZeroMemory(@Buffer, size);
  signal.size := size;
  signal.Index := Client;
  signal.Code := packetCode;
  Move(signal, Buffer, 12);
  SendPacket(Buffer, size);
end;
procedure TPlayer.SendData(clientId, packetCode: WORD; Data: DWORD);
var
  signal: TSignalData;
begin
  ZeroMemory(@signal, sizeof(TSignalData));
  signal.Header.size := sizeof(TSignalData);
  signal.Header.Index := clientId;
  signal.Header.Code := packetCode;
  signal.Data := Data;
  SendPacket(signal, signal.Header.size)
end;
function TPlayer.GetCurrentCity: TCity;
var
  i: WORD;
  MapID: BYTE;
  X, Y: DWORD;
begin
  MapID := 0;
  X := Round(Self.Base.PlayerCharacter.LastPos.X);
  Y := Round(Self.Base.PlayerCharacter.LastPos.Y);
  for i := 0 to 58 do
  begin
    if (X > MapsData.Limits[i].StartX) and (X < MapsData.Limits[i].FinalX) and
      (Y > MapsData.Limits[i].StartY) and (Y < MapsData.Limits[i].FinalY) then
    begin
      MapID := i + 1;
      Break;
    end;
  end;
  Result := TCity(MapID);
end;
function TPlayer.GetCurrentCityID: Integer;
var
  i: WORD;
  MapID: BYTE;
  X, Y: DWORD;
begin
  MapID := 0;
  X := Round(Self.Base.PlayerCharacter.LastPos.X);
  Y := Round(Self.Base.PlayerCharacter.LastPos.Y);
  for i := 0 to 58 do
  begin
    if (X > MapsData.Limits[i].StartX) and (X < MapsData.Limits[i].FinalX) and
      (Y > MapsData.Limits[i].StartY) and (Y < MapsData.Limits[i].FinalY) then
    begin
      MapID := i + 1;
      Break;
    end;
  end;
  Result := MapID;

end;
procedure TPlayer.SetCurrentNeighbors();
begin
  Self.Base.Neighbors[0].Pos.X := Self.Base.PlayerCharacter.LastPos.X - 0.6;
  Self.Base.Neighbors[0].Pos.Y := Self.Base.PlayerCharacter.LastPos.Y - 0.6;
  Self.Base.Neighbors[1].Pos.X := Self.Base.PlayerCharacter.LastPos.X + 0.6;
  Self.Base.Neighbors[1].Pos.Y := Self.Base.PlayerCharacter.LastPos.Y + 0.6;
  Self.Base.Neighbors[2].Pos.X := Self.Base.PlayerCharacter.LastPos.X - 0.7;
  Self.Base.Neighbors[2].Pos.Y := Self.Base.PlayerCharacter.LastPos.Y - 0.7;
  Self.Base.Neighbors[3].Pos.X := Self.Base.PlayerCharacter.LastPos.X + 0.7;
  Self.Base.Neighbors[3].Pos.Y := Self.Base.PlayerCharacter.LastPos.Y + 0.7;
  Self.Base.Neighbors[4].Pos.X := Self.Base.PlayerCharacter.LastPos.X - 0.5;
  Self.Base.Neighbors[4].Pos.Y := Self.Base.PlayerCharacter.LastPos.Y - 0.5;
  Self.Base.Neighbors[5].Pos.X := Self.Base.PlayerCharacter.LastPos.X + 0.5;
  Self.Base.Neighbors[5].Pos.Y := Self.Base.PlayerCharacter.LastPos.Y + 0.5;
  Self.Base.Neighbors[6].Pos.X := Self.Base.PlayerCharacter.LastPos.X - 0.8;
  Self.Base.Neighbors[6].Pos.Y := Self.Base.PlayerCharacter.LastPos.Y - 0.8;
  Self.Base.Neighbors[7].Pos.X := Self.Base.PlayerCharacter.LastPos.X + 0.8;
  Self.Base.Neighbors[7].Pos.Y := Self.Base.PlayerCharacter.LastPos.Y + 0.8;
  Self.Base.Neighbors[8].Pos.X := Self.Base.PlayerCharacter.LastPos.X - 1;
  Self.Base.Neighbors[8].Pos.Y := Self.Base.PlayerCharacter.LastPos.Y - 1;
end;
{$ENDREGION}
{$REGION 'Sends'}
procedure TPlayer.SendClientMessage(Msg: AnsiString; MsgType: Integer = 16;
  Null: Integer = 0; Type2: Integer = 0);
var
  Packet: TClientMessagePacket;
  i: Integer;
begin
  ZeroMemory(@Packet, sizeof(TClientMessagePacket));
  Packet.Header.size := 144;
  Packet.Header.Code := $984;
  Packet.Null := Null; { 16 = Msg Amarela }
  Packet.Type1 := MsgType; { 16 + = msg aparece em cima na tela }
  { 32 + = msg de GM }
  { 48 + = msg de GM + msg em cima }
  Packet.Type2 := Type2;
  for i := 0 to Length(Msg) do
  begin
    Packet.Msg[i] := Msg[i + 1];
  end;
  SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendCharList(Type1: BYTE);
var
  Packet: TSendToCharListPacket;
  i, z: BYTE;
begin
  ZeroMemory(@Packet, sizeof(TSendToCharListPacket));
  if (Type1 = 0) then
  begin
    ZeroMemory(@Self.Base.MOB_EF, sizeof(Self.Base.MOB_EF));
    ZeroMemory(@Self.Base.PlayerCharacter, sizeof(TPlayerCharacter));
  end;
  Packet.Header.size := sizeof(TSendToCharListPacket);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $901;
  Packet.AcountID := Account.Header.AccountId;
  for i := 0 to 2 do
  begin
    Move(Account.Characters[i].Base.Name, Packet.CharactersData[i].Name, 16);
    Packet.CharactersData[i].Nation := Integer(Account.Header.Nation);
    for z := 0 to 7 do
    begin
      Packet.CharactersData[i].Equip[z] := Account.Characters[i]
        .Base.Equip[z].APP;
    end;
    Packet.CharactersData[i].Refine[7] := Account.Characters[i].Base.Equip[6]
      .Refi div $10;
    Move(Account.Characters[i].Base.CurrentScore,
      Packet.CharactersData[i].Attributes, sizeof(TAttributes));
    if Account.Header.NumericToken[i] <> '' then
      Packet.CharactersData[i].NumRegister := True;
    Packet.CharactersData[i].NumericError := Account.Header.NumError[i];
    Move(Account.Characters[i].Base.CurrentScore.Sizes,
      Packet.CharactersData[i].size, sizeof(TSize));
    Move(Account.Characters[i].Base.Gold, Packet.CharactersData[i].Gold,
      sizeof(DWORD));
    Move(Account.Characters[i].Base.Exp, Packet.CharactersData[i].Exp,
      sizeof(DWORD));
    Packet.CharactersData[i].ClassInfo := Account.Characters[i].Base.ClassInfo;
    Packet.CharactersData[i].Level := Account.Characters[i].Base.Level - 1;
    Packet.CharactersData[i].Equip[0] := Account.Characters[i]
      .Base.Equip[0].Index;
    Packet.CharactersData[i].Equip[1] := Account.Characters[i]
      .Base.Equip[1].Index;
    if (Self.Account.CharactersDelete[i] = True) then
    begin
      Packet.CharactersData[i].DeleteTime := TFunctions.DateTimeToUNIXTimeFAST
        (StrToDateTime(String(Self.Account.CharactersDeleteTime[i])));
      { TFunctions.DateTimeToUNIXTimeFAST
        (TFunctions.ReTime(String(Self.Account.CharactersDeleteTime[i]))); }
    end;
  end;
  if (Status = CharList) then
  begin
    Packet.Header.size := sizeof(TSendToCharListPacket);
    SendPacket(Packet, Packet.Header.size);
    Exit;
  end;
  Status := CharList;
  SubStatus := Senha2;
  SendPacket(Packet, Packet.Header.size);
end;
function TPlayer.BackToCharList: Boolean;
var
  Guild: PGuild;
  i, ch, RlkSlot: BYTE;
  cid: WORD;
  ChangeChannelToken: TChangeChannelToken;
  Item: PItem;
  str_aux: String;
begin
  if (Self.Status > TPlayerStatus.CharList) then
  begin
    case Self.spawnedPran of
      0:
        begin
          for I in Self.Base.VisiblePlayers do
          begin
            Self.SendPranUnspawn(0, i);
          end;
        end;
      1:
        begin
          for I in Self.Base.VisiblePlayers do
          begin
            Self.SendPranUnspawn(1, i);
          end;
        end;
    end;
    Self.SendFriendLogout;
    Self.Base.SendRemoveMob(0, 0, FALSE);
    if (Self.InDungeon) then
    begin
      if (Self.Base.clientId = Self.Party.Leader) then
      begin
        DungeonInstances[Self.DungeonInstanceID].Index := 0;
        DungeonInstances[Self.DungeonInstanceID].CreateTime := Now;
        DungeonInstances[Self.DungeonInstanceID].Party := nil;
        DungeonInstances[Self.DungeonInstanceID].DungeonID := 0;
        DungeonInstances[Self.DungeonInstanceID].Dificult := 0;
        ZeroMemory(@DungeonInstances[Self.DungeonInstanceID].MOBS,
          sizeof(DungeonInstances[Self.DungeonInstanceID].MOBS));
        DungeonInstances[Self.DungeonInstanceID].InstanceOnline := FALSE;
        for i in Self.Party.Members do
        begin
          if (i = Self.Base.clientId) then
            Continue;
          Servers[Self.ChannelIndex].Players[i].SendClientMessage
            ('O jogador [' + AnsiString(Self.Base.Character.Name) +
            '] era líder do grupo e se desconectou, todos foram expulsos do calabouço.');
          Servers[Self.ChannelIndex].Players[i].DungeonLobbyIndex := 0;
          Servers[Self.ChannelIndex].Players[i].DungeonLobbyDificult := 0;
          Servers[Self.ChannelIndex].Players[i].DungeonID := 0;
          Servers[Self.ChannelIndex].Players[i].DungeonIDDificult := 0;
          Servers[Self.ChannelIndex].Players[i].DungeonInstanceID := 0;
          Servers[Self.ChannelIndex].Players[i].InDungeon := FALSE;
          Servers[Self.ChannelIndex].Players[i]
            .Teleport(TPosition.Create(3399, 564));
        end;
      end
      else
      begin
        Self.DungeonLobbyIndex := 0;
        Self.DungeonLobbyDificult := 0;
        Self.DungeonID := 0;
        Self.DungeonIDDificult := 0;
        Self.DungeonInstanceID := 0;
        Self.InDungeon := FALSE;
        Self.Teleport(TPosition.Create(3399, 564));
        for i in Self.Party.Members do
        begin
          Servers[Self.ChannelIndex].Players[i].SendClientMessage
            ('O jogador [' + AnsiString(Self.Base.Character.Name) +
            '] se desconectou e foi expulso do calabouço.');
        end;
      end;
    end;
    if Self.Character.Base.GuildIndex > 0 then
    begin
      Guild := @Guilds[Self.Character.GuildSlot];
      Guild.SendMemberLogout(Self.Character.Index);
      if Guild.MemberInChest = Guild.FindMemberFromCharIndex(Self.Character.
        Index) then
      begin
        Guild.MemberInChest := $FF;
        Guild.LastChestActionDate := 0;
      end;
    end;
    if not(Self.DesconectedByOtherChannel) then
    begin
      if (Self.PartyIndex > 0) then
      begin
        Self.Party.RemoveMember(Self.Base.clientId);
        Self.Party.RefreshParty;
        Self.RefreshParty;
      end;
      while (TItemFunctions.GetItemSlotByItemType(Self, 40, INV_TYPE, 0) <> 255) do
      begin
        RlkSlot := TItemFunctions.GetItemSlotByItemType(Self, 40, INV_TYPE, 0);
        if(RlkSlot <> 255) then
        begin
          Item := @Self.Base.Character.Inventory[RlkSlot];
          Servers[Self.ChannelIndex].CreateMapObject(@Self, 320, Item.Index);
          {Servers[Self.ChannelIndex].SendServerMsg('O jogador ' +
            AnsiString(Self.Base.Character.Name) + ' dropou a relíquia <' +
            AnsiString(ItemList[Item.Index].Name) + '>.');}
          ZeroMemory(Item, sizeof(TItem));
          Self.Base.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, False);
        end;
      end;
      Self.Base.RemoveBuffByIndex(91);
    end
    else
    begin
      if (Self.PartyIndex > 0) then
      begin
        if(Self.Party.Leader = Self.Base.ClientID) then
        begin
          Self.Party.DestroyParty(Self.Base.ClientID);
          //Self.Party.RemoveMember(Self.Base.clientId);
          Self.Party.RefreshParty;
          Self.RefreshParty;
        end;
      end;
    end;

    SendSignal(Self.Base.clientId, $318);

    Self.SaveCharOnCharRoom(Self.SelectedCharacterIndex);
    Self.SaveInGame(Self.SelectedCharacterIndex);
    cid := Self.Base.clientId;
    ch := Self.Base.ChannelId;

    Self.SpawnedPran := 255;
    ZeroMemory(@Self.PlayerQuests, sizeof(Self.PlayerQuests));
    ZeroMemory(@Self.TeleportList, sizeof(Self.TeleportList));
    Self.OpennedNPC := 0;
    Self.OpennedOption := 0;

    ShoutTime := Now;
    Self.Base.LastReceivedAttack := Now;
    FaericForm := False;
    Self.TimeUpdate := Now;

    Self.Base.Destroy(True);
    Self.FriendList.Clear;
    Self.FriendOpenWindowns.Clear;
    FreeAndNil(Self.EntityFriend);
    Self.EntityFriend := TEntityFriend.Create(@Self);

    Status := CharList;
    Self.IsInstantiated := FALSE;
    Self.SendedSendToWorld := False;
    Self.LastTimeSaved := Now;

    ZeroMemory(@Character, sizeof(TPlayerCharacter));

    ZeroMemory(@Self.Account.Header.Pran1, sizeof(TPran));
    ZeroMemory(@Self.Account.Header.Pran2, sizeof(TPran));

    Self.Base.Create(@Self.Character.Base, cid, ch);

    Self.Base.TimeForGoldTime := Now;

    Self.SendCharList(1);

    SelectedCharacterIndex := -1;
  end;
  {if (Self.InDungeon) then
  begin
    if (Self.Base.clientId = Self.Party.Leader) then
    begin
      DungeonInstances[Self.DungeonInstanceID].Index := 0;
      DungeonInstances[Self.DungeonInstanceID].CreateTime := Now;
      DungeonInstances[Self.DungeonInstanceID].Party := nil;
      DungeonInstances[Self.DungeonInstanceID].DungeonID := 0;
      DungeonInstances[Self.DungeonInstanceID].Dificult := 0;
      ZeroMemory(@DungeonInstances[Self.DungeonInstanceID].MOBS,
        sizeof(DungeonInstances[Self.DungeonInstanceID].MOBS));
      DungeonInstances[Self.DungeonInstanceID].InstanceOnline := FALSE;
      for i in Self.Party.Members do
      begin
        if (i = Self.Base.clientId) then
          Continue;
        Servers[Self.ChannelIndex].Players[i].SendClientMessage
          ('O jogador [' + AnsiString(Self.Base.Character.Name) +
          '] era líder do grupo e se desconectou, todos foram expulsos do calabouço.');
        Servers[Self.ChannelIndex].Players[i].DungeonLobbyIndex := 0;
        Servers[Self.ChannelIndex].Players[i].DungeonLobbyDificult := 0;
        Servers[Self.ChannelIndex].Players[i].DungeonID := 0;
        Servers[Self.ChannelIndex].Players[i].DungeonIDDificult := 0;
        Servers[Self.ChannelIndex].Players[i].DungeonInstanceID := 0;
        Servers[Self.ChannelIndex].Players[i].InDungeon := FALSE;
        Servers[Self.ChannelIndex].Players[i].Teleport
          (TPosition.Create(3399, 564));
      end;
    end
    else
    begin
      Self.DungeonLobbyIndex := 0;
      Self.DungeonLobbyDificult := 0;
      Self.DungeonID := 0;
      Self.DungeonIDDificult := 0;
      Self.DungeonInstanceID := 0;
      Self.InDungeon := FALSE;
      Self.Teleport(TPosition.Create(3399, 564));
      for i in Self.Party.Members do
      begin
        Servers[Self.ChannelIndex].Players[i].SendClientMessage
          ('O jogador [' + AnsiString(Self.Base.Character.Name) +
          '] se desconectou e foi expulso do calabouço.');
      end;
    end;
  end;
  Character.LastPos := Self.Base.PlayerCharacter.LastPos;
  Self.Base.SendRemoveMob(DELETE_NORMAL);
  Self.Base.VisibleMobs.Clear;
  Self.Base.VisibleNPCS.Clear;
  Self.Base.VisiblePlayers.Clear;
  SendSignal(Self.Base.clientId, $318);
  Self.SendCharList(1);
  if (Self.PartyIndex > 0) then
  begin
    Servers[Self.ChannelIndex].Parties[Self.PartyIndex].RemoveMember
      (Self.Base.clientId);
    Self.RefreshParty;
  end;
  Self.SendFriendLogout;
  if Self.Character.Base.GuildIndex > 0 then
    Guilds[Self.Character.GuildSlot].SendMemberLogout(Self.Character.Index);
  Status := CharList;
  Self.IsInstantiated := FALSE;
  Move(Self.Character, Account.Characters[Self.SelectedCharacterIndex],
    sizeof(TCharacterDB));
  Self.SaveInGame(Self.SelectedCharacterIndex);
  ZeroMemory(@Character, sizeof(TPlayerCharacter));
  Self.SpawnedPran := 255;
  ZeroMemory(@Self.PlayerQuests, sizeof(Self.PlayerQuests));
  ZeroMemory(@Self.TeleportList, sizeof(Self.TeleportList));
  Self.Base.ClearTargetList();
  Self.FriendList.Clear;
  Self.FriendOpenWindowns.Clear;
  Self.OpennedNPC := 0;
  Self.OpennedOption := 0;
  Self.Base.ZerarBuffs();
  SelectedCharacterIndex := -1;
  ZeroMemory(@Self.Base.MOB_EF, sizeof(Self.Base.MOB_EF));
  ZeroMemory(@Self.Base.Eff_5, 6);
  ZeroMemory(@Self.Base.PlayerCharacter, sizeof(TPlayerCharacter));   }
  Result := True;
end;
procedure TPlayer.SendToWorld(CharID: BYTE; aSendPacket: Boolean);
var
  Packet: TSendToWorldPacket;
  i: Integer;
  CurrentTitle: TTitleData;
  TitleCategory: BYTE;
  TitleSlot: BYTE;
  ItemPran1, ItemPran2, ItemInventory: PItem;
  Pran1ItemID, Pran2ItemID: Integer;
  Pran1OldSlot: BYTE;
  Pran1OldType: BYTE;
  Pran2OldSlot: BYTE;
  Pran2OldType: BYTE;
  ItemBlank: TItem;
  // EmptySlot: BYTE;
begin
  if(Self.SendedSendToWorld) then
    Exit;
  Pran1OldSlot := 0;
  Pran1OldType := 0;
  Pran2OldSlot := 0;
  Pran2OldType := 0;
  Self.OpennedDevir := 255;
  Self.OpennedTemple := 255;
  ZeroMemory(@Packet, sizeof(TSendToWorldPacket));
  SelectedCharacterIndex := CharID;
  Packet.Header.size := sizeof(TSendToWorldPacket);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $925;
  Packet.AcountSerial := Account.Header.AccountId;

  if(aSendPacket) then
  begin
    Self.LoadCharacterMisc(CharID);
    Move(Account.Characters[CharID], Character, sizeof(TCharacterDB));
  end;

  if (Self.Character.Base.GuildIndex > 0) then
  begin
    Self.SearchAndSetGuildSlot;
    { if Guilds[Self.Character.GuildSlot].FindMemberFromCharIndex(Self.Character.
      Index) < 0 then
      begin
      Self.Character.Base.GuildIndex := 0;
      end; }
  end;
  Character.Base.clientId := Base.clientId;
  Self.Character.Base.LoginTime := TFunctions.DateTimeToUNIXTimeFAST(Now);
  Self.Character.Base.EndDayTime := Servers[Self.ChannelIndex].GetEndDayTime;
  Self.Character.Base.Nation := BYTE(Self.Account.Header.Nation);
  { Seta as skills do char [os leveis que vai no packet] }
  Self.SetPlayerSkills;
  // Self.Character.Base.GuildIndex := Self.Character.Base.GuildIndex;
  // Self.Character.Base.BuffsId[0] := 6600;
  // Self.Character.Base.BuffsId[0] := 6600;
{$REGION 'Set Titles List'}
  Self.Character.Base.ActiveTitle := Character.ActiveTitle.Index;
  ZeroMemory(@Self.Character.Base.TitleCategoryLevel, 12 * sizeof(DWORD));
  for i := 0 to 95 do
  begin
    CurrentTitle := Self.Character.Titles[i];
    if (CurrentTitle.Index = 0) then
      Continue;
    if(CurrentTitle.Level = 0) then
      Continue;
    TitleCategory := BYTE(trunc(CurrentTitle.Index / 8));
    TitleSlot := (CurrentTitle.Index mod 8);
    Inc(Self.Character.Base.TitleCategoryLevel[TitleCategory],
      TFunctions.GetTitleLevelValue(TitleSlot, CurrentTitle.Level));
    case Titles[CurrentTitle.Index].TitleLevel[CurrentTitle.Level - 1]
      .TitleType of
      8:
        begin
          Self.Character.Base.TitleProgressType8
            [Titles[CurrentTitle.Index].TitleLevel[CurrentTitle.Level - 1]
            .TitleIndex - 1] := CurrentTitle.Progress;
        end;
      9:
        begin
          Self.Character.Base.TitleProgressType9[1] := CurrentTitle.Progress;
        end;
      4:
        begin
          Self.Character.Base.TitleProgressType4 := CurrentTitle.Progress;
        end;
      10:
        begin
          Self.Character.Base.TitleProgressType10 := CurrentTitle.Progress;
        end;
      7:
        begin
          Self.Character.Base.TitleProgressType7 := CurrentTitle.Progress;
        end;
      11:
        begin
          Self.Character.Base.TitleProgressType11 := CurrentTitle.Progress;
        end;
      12:
        begin
          Self.Character.Base.TitleProgressType12 := CurrentTitle.Progress;
        end;
      13:
        begin
          Self.Character.Base.TitleProgressType13 := CurrentTitle.Progress;
        end;
      15:
        begin
          Self.Character.Base.TitleProgressType15 := CurrentTitle.Progress;
        end;
      16:
        begin
          Self.Character.Base.TitleProgressType16
            [Titles[CurrentTitle.Index].TitleLevel[CurrentTitle.Level - 1]
            .TitleIndex - 1] := CurrentTitle.Progress;
        end;
      23:
        begin
          Self.Character.Base.TitleProgressType23 := CurrentTitle.Progress;
        end
    else
      begin
        // Logger.Write('Nada !!', TlogType.Packets);
      end;
    end;
  end;

  // 0..48 Dungeon and Monsters <8>
  // 49 Elter Notavel <9>
  // 50 Inimigo Publico <4>
  // 51 Saqueador <10>
  // 52 Exterminador <7>
  // 53 Mestre de Batalha <11>
  // 54 Rei das Lutas <12>
  // 55 Perito Em Pesca <13>
  // 56 Aventureiro Mestre <15>
  // 57 ??
  // 58 Gatinho Assustado <16> [1]
  // 59 Pupilo de Alan <16> [2]
  // 60 Mestre da Arena <16> [3]
  // 61 <16> [4]
  // 62 <16> [5]
  // 74 Abre Alas<16> [17]
  // 75 ??
  // 76 ??
  // 77 ??
  // 78 ??
  // 79 ??
  // 80 Sangue Frio <23>
  //
{$ENDREGION}
  Character.Base.CurrentScore.ServerReset := Servers[Self.ChannelIndex]
    .ResetTime;
  for i := 0 to 15 do
    Self.Base.SetEquipEffect(Character.Base.Equip[i], EQUIPING_TYPE);
  Move(Character.Base, Packet.Character, sizeof(TCharacter));
  Move(Self.Character, Self.Base.PlayerCharacter, sizeof(TPlayerCharacter));
  if (aSendPacket) then
  begin
    Self.SendData(Base.clientId, $CCCC, $1);
    Self.SendData(Base.clientId, $186, $1);
    Self.SendData(Base.clientId, $186, $1);
    Self.SendData(Base.clientId, $186, $1);
  end;

  try
    Pran1ItemID := 0;
    Pran2ItemID := 0;
    if (Self.Account.Header.Pran1.Iddb <> 0) then
    begin
      Move(Self.Account.Header.Pran1.Name, Packet.Character.PranName[0], 16);
      Pran1ItemID := Self.Account.Header.Pran1.ItemID;
    end;
    if (Self.Account.Header.Pran2.Iddb <> 0) then
    begin
      Move(Self.Account.Header.Pran2.Name, Packet.Character.PranName[1], 16);
      Pran2ItemID := Self.Account.Header.Pran2.ItemID;
    end;
    // Packet.Character.Unknow := 21568;

    if (aSendPacket) then
    begin
      SendPacket(Packet, Packet.Header.size);
      Self.TimeUpdate := Now;
    end
    else
    begin
      Self.TimeUpdate := IncSecond(Now, 600);
      Self.Base.SendRefreshItemSlot(STORAGE_TYPE, 84,
        Self.Account.Header.Storage.Itens[84], FALSE);
      Self.SendClientIndex;
      // talvez seja isso aq
      Self.Base.SendRefreshItemSlot(STORAGE_TYPE, 85,
        Self.Account.Header.Storage.Itens[85], FALSE);
      Self.SendClientIndex;

      SendPacket(Packet, Packet.Header.size);
    end;
    // talvez seja isso aq
{$REGION 'Setando cada pran com cada nome de pran'}
    ItemPran1 := nil;
    ItemPran2 := nil;
    // procurar o item e mandar o pointer dele
    for i := 0 to 59 do
    begin
      // procurando no inventário
      ItemInventory := @Self.Character.Base.Inventory[i];
      if (ItemInventory.Index = 0) then
        Continue;
      if (ItemInventory.Identific = Pran1ItemID) then // achou a pran1
      begin
        ItemPran1 := @Self.Character.Base.Inventory[i];
        Pran1OldSlot := i;
        Pran1OldType := INV_TYPE;
      end
      else if (ItemInventory.Identific = Pran2ItemID) then // achou a pran2
      begin
        ItemPran2 := @Self.Character.Base.Inventory[i];
        Pran2OldSlot := i;
        Pran2OldType := INV_TYPE;
      end;
    end;
    ItemInventory := @Self.Character.Base.Equip[10];
    if (ItemInventory.Index > 0) then
    begin
      if (ItemInventory.Identific = Pran1ItemID) then // achou a pran1
      begin
        ItemPran1 := @Self.Character.Base.Equip[10];
        Pran1OldSlot := 10;
        Pran1OldType := EQUIP_TYPE;
      end
      else if (ItemInventory.Identific = Pran2ItemID) then // achou a pran2
      begin
        ItemPran2 := @Self.Character.Base.Equip[10];
        Pran2OldSlot := 10;
        Pran2OldType := EQUIP_TYPE;
      end;
    end;
    for i := 84 to 85 do
    begin // procurando nos slots de pran
      ItemInventory := @Self.Account.Header.Storage.Itens[i];
      if (ItemInventory.Index = 0) then
        Continue;
      if (ItemInventory.Identific = Pran1ItemID) then // achou a pran1
      begin
        ItemPran1 := @Self.Account.Header.Storage.Itens[i];
        Pran1OldSlot := i;
        Pran1OldType := STORAGE_TYPE;
      end
      else if (ItemInventory.Identific = Pran2ItemID) then // achou a pran2
      begin
        ItemPran2 := @Self.Account.Header.Storage.Itens[i];
        Pran2OldSlot := i;
        Pran2OldType := STORAGE_TYPE;
      end;
    end;
    ZeroMemory(@ItemBlank, sizeof(ItemBlank));
    if not(ItemPran1 = nil) then
    begin
      if (ItemPran1.Index > 0) then
      begin
        case Pran1OldType of
          INV_TYPE:
            begin
              Self.Base.SendRefreshItemSlot(Pran1OldType, Pran1OldSlot,
                ItemBlank, FALSE);
              Self.Base.SendRefreshItemSlot(STORAGE_TYPE, 84,
                ItemPran1^, FALSE);
              Self.SendClientIndex;
              Self.Base.SendRefreshItemSlot(STORAGE_TYPE, 84, ItemBlank, FALSE);
              Self.Base.SendRefreshItemSlot(Pran1OldType, Pran1OldSlot,
                ItemPran1^, FALSE);
            end;
          EQUIP_TYPE:
            begin
              Self.Base.SendRefreshItemSlot(Pran1OldType, Pran1OldSlot,
                ItemBlank, FALSE);
              Self.Base.SendRefreshItemSlot(STORAGE_TYPE, 84,
                ItemPran1^, FALSE);
              Self.SendClientIndex;
              Self.Base.SendRefreshItemSlot(STORAGE_TYPE, 84, ItemBlank, FALSE);
              Self.Base.SendRefreshItemSlot(Pran1OldType, Pran1OldSlot,
                ItemPran1^, FALSE);
            end;
          STORAGE_TYPE:
            begin
              Self.Base.SendRefreshItemSlot(Pran1OldType, Pran1OldSlot,
                ItemPran1^, FALSE);
              Self.SendClientIndex;
            end;
        end;
      end;
    end;
    if not(ItemPran2 = nil) then
    begin
      if (ItemPran2.Index > 0) then
      begin
        case Pran2OldType of
          INV_TYPE:
            begin
              Self.Base.SendRefreshItemSlot(Pran2OldType, Pran2OldSlot,
                ItemBlank, FALSE);
              Self.Base.SendRefreshItemSlot(STORAGE_TYPE, 84,
                ItemPran2^, FALSE);
              Self.SendClientIndex;
              Self.Base.SendRefreshItemSlot(STORAGE_TYPE, 84, ItemBlank, FALSE);
              Self.Base.SendRefreshItemSlot(Pran2OldType, Pran2OldSlot,
                ItemPran2^, FALSE);
            end;
          EQUIP_TYPE:
            begin
              Self.Base.SendRefreshItemSlot(Pran2OldType, Pran2OldSlot,
                ItemBlank, FALSE);
              Self.Base.SendRefreshItemSlot(STORAGE_TYPE, 84,
                ItemPran2^, FALSE);
              Self.SendClientIndex;
              Self.Base.SendRefreshItemSlot(STORAGE_TYPE, 84, ItemBlank, FALSE);
              Self.Base.SendRefreshItemSlot(Pran2OldType, Pran2OldSlot,
                ItemPran2^, FALSE);
            end;
          STORAGE_TYPE:
            begin
              Self.Base.SendRefreshItemSlot(Pran2OldType, Pran2OldSlot,
                ItemPran2^, FALSE);
              Self.SendClientIndex;
            end;
        end;
      end;
    end;
{$ENDREGION}
  except
    on E: Exception do
      Logger.Write('SendToWorld at pran settings region Error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
  end;
  //Self.SetCurrentNeighbors;
  Self.SendedSendToWorld := True;
end;
procedure TPlayer.SendToWorld2(CharID: BYTE);
var
  Packet: TSendToWorldPacket;
  CurrentTitle: PTitleData;
  i: Integer;
  TitleCategory: BYTE;
  TitleSlot: BYTE;
begin
  SelectedCharacterIndex := CharID;
  Self.LoadCharacterMisc(CharID);
  Move(Account.Characters[CharID], Character, sizeof(TCharacterDB));
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $925;
  Packet.AcountSerial := Self.Account.Header.AccountId;
  Packet.Character.clientId := Self.Base.clientId;
  Packet.Character.CharIndex := Self.Character.Index;
  Packet.Character.Name := Self.Character.Base.Name;
  Packet.Character.Nation := Self.Character.Base.Nation;
  Packet.Character.ClassInfo := Self.Character.Base.ClassInfo;
  Packet.Character.CreationTime := Self.Character.Base.CreationTime;
  Packet.Character.CurrentScore := Self.Character.Base.CurrentScore;
  Packet.Character.EndDayTime := TFunctions.DateTimeToUNIXTimeFAST(Now);
  for i := 0 to 15 do
    Self.Base.SetEquipEffect(Character.Base.Equip[i], EQUIPING_TYPE);
  Move(Self.Character.Base.Equip, Packet.Character.Equip,
    sizeof(Packet.Character.Equip));
  Move(Self.Character.Base.Inventory, Packet.Character.Inventory,
    sizeof(Packet.Character.Inventory));
  Move(Self.Character.Base.ItemBar, Packet.Character.ItemBar,
    sizeof(Packet.Character.ItemBar));
  Self.SetPlayerSkills;
  Move(Self.Character.Base.SkillList, Packet.Character.SkillList,
    sizeof(Packet.Character.SkillList));
  Packet.Character.ActiveTitle := Self.Character.Base.ActiveTitle;
  Packet.Character := Self.Character.Base;
  for i := 0 to 95 do
  begin
    CurrentTitle := @Self.Character.Titles[i];
    if (CurrentTitle.Index = 0) then
      Continue;
    TitleCategory := trunc(CurrentTitle.Index div 8);
    TitleSlot := (CurrentTitle.Index mod 8);
    Packet.Character.TitleCategoryLevel[TitleCategory] :=
      Packet.Character.TitleCategoryLevel[TitleCategory] +
      Self.GetTitleLevelValue(TitleSlot, CurrentTitle.Level);
    case Titles[CurrentTitle.Index].TitleLevel[CurrentTitle.Level - 1]
      .TitleType of
      8:
        Packet.Character.TitleProgressType8
          [Titles[CurrentTitle.Index].TitleLevel[CurrentTitle.Level - 1]
          .TitleIndex - 1] := CurrentTitle.Progress;
      9:
        Packet.Character.TitleProgressType9[1] := CurrentTitle.Progress;
      4:
        Packet.Character.TitleProgressType4 := CurrentTitle.Progress;
      10:
        Packet.Character.TitleProgressType10 := CurrentTitle.Progress;
      7:
        Packet.Character.TitleProgressType7 := CurrentTitle.Progress;
      11:
        Packet.Character.TitleProgressType11 := CurrentTitle.Progress;
      12:
        Packet.Character.TitleProgressType12 := CurrentTitle.Progress;
      13:
        Packet.Character.TitleProgressType13 := CurrentTitle.Progress;
      15:
        Packet.Character.TitleProgressType15 := CurrentTitle.Progress;
      16:
        Packet.Character.TitleProgressType16
          [Titles[CurrentTitle.Index].TitleLevel[CurrentTitle.Level - 1]
          .TitleIndex - 1] := CurrentTitle.Progress;
      23:
        Packet.Character.TitleProgressType23 := CurrentTitle.Progress;
    end;
  end;
  Packet.Character.Exp := Self.Character.Base.Exp;
  Packet.Character.Level := Self.Character.Base.Level;
  Packet.Character.Gold := Self.Character.Base.Gold;
  Packet.Character.GuildIndex := Self.Character.Base.GuildIndex;
  Packet.Character.LoginTime := TFunctions.DateTimeToUNIXTimeFAST(Now);
  Packet.Character.Location := Self.Character.Base.Location;
  Packet.Character.CurrentScore.ServerReset := Servers[Self.ChannelIndex]
    .ResetTime;
  Move(Self.Character.Base.Numeric, Packet.Character.Numeric,
    sizeof(Packet.Character.Numeric));
  Move(Self.Character, Self.Base.PlayerCharacter, sizeof(TPlayerCharacter));
  Self.SendData(Base.clientId, $CCCC, $1);
  SendP3A2;
  SendP186;
  SendP186;
  SendP186;
  Self.SendP131;
  Self.SendPacket(Packet, Packet.Header.size);
  SendP12C;
  Self.Base.SendRefreshItemSlot(2, 54, Self.Account.Header.Storage.Itens
    [54], FALSE);
  Self.SendClientIndex;
  Self.Base.SendRefreshItemSlot(2, 55, Self.Account.Header.Storage.Itens
    [55], FALSE);
  Self.SendClientIndex;
  Self.SendP94C;
end;
procedure TPlayer.SendPranToWorld(PranSlot: BYTE);
var
  Packet: TSendPranToWorld;
  i: Integer;
  Tamanho: Integer;
  Level: Cardinal;
begin
  ZeroMemory(@Packet, sizeof(TSendPranToWorld));
  Packet.Header.size := sizeof(TSendPranToWorld);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $907;
  if (PranSlot = 0) then
  begin
    Move(Self.Account.Header.Pran1.Name, Packet.Name, 16);
    Packet.PranClass := Self.Account.Header.Pran1.ClassPran;
    Packet.Food := Self.Account.Header.Pran1.Food;
    if (Self.Account.Header.Pran1.Personality.Cute >=
      Self.Account.Header.Pran1.Devotion) then
      Packet.Personality := 00;
    if (Self.Account.Header.Pran1.Personality.Smart >=
      Self.Account.Header.Pran1.Devotion) then
      Packet.Personality := 01;
    if (Self.Account.Header.Pran1.Personality.Sexy >=
      Self.Account.Header.Pran1.Devotion) then
      Packet.Personality := 02;
    if (Self.Account.Header.Pran1.Personality.Energetic >=
      Self.Account.Header.Pran1.Devotion) then
      Packet.Personality := 03;
    if (Self.Account.Header.Pran1.Personality.Tough >=
      Self.Account.Header.Pran1.Devotion) then
      Packet.Personality := 04;
    if (Self.Account.Header.Pran1.Personality.Corrupt >=
      Self.Account.Header.Pran1.Devotion) then
      Packet.Personality := 05;
    for i := 0 to 9 do { ATTENTION PRAN SKILL Count can be 10 or 12 }
    begin
      if (Self.Account.Header.Pran1.Skills[i].Level = 0) then
      begin
        Continue;
      end;
      Tamanho := TSkillFunctions.GetSkillPranLevel(i,
        Self.Account.Header.Pran1.Skills[i].Level, Level);
      Move(Level, Packet.Unk[i], Tamanho);
    end;
    for i := 0 to 2 do
    begin
      if (Self.Account.Header.Pran1.ItemBar[i] = 0) then
      begin
        Continue;
      end;
      Packet.PranSkillBar[i] := Self.Account.Header.Pran1.ItemBar[i];
    end;
    Packet.Devotion := Self.Account.Header.Pran1.Devotion;
    Packet.MaxHp := Self.Account.Header.Pran1.MaxHp;
    Packet.CurHP := Self.Account.Header.Pran1.CurHP;
    Packet.MaxMP := Self.Account.Header.Pran1.MaxMP;
    Packet.CurMp := Self.Account.Header.Pran1.CurMp;
    Packet.Exp := Self.Account.Header.Pran1.Exp;
    Packet.DefFis := Self.Account.Header.Pran1.DefFis;
    Packet.DefMag := Self.Account.Header.Pran1.DefMag;
    Move(Self.Account.Header.Pran1.Equip, Packet.Equips, 16 * sizeof(TItem));
    Move(Self.Account.Header.Pran1.Inventory, Packet.Inventory,
      42 * sizeof(TItem));
  end
  else if (PranSlot = 1) then
  begin
    Move(Self.Account.Header.Pran2.Name, Packet.Name, 16);
    Packet.PranClass := Self.Account.Header.Pran2.ClassPran;
    Packet.Food := Self.Account.Header.Pran2.Food;
    if (Self.Account.Header.Pran2.Personality.Cute >=
      Self.Account.Header.Pran1.Devotion) then
      Packet.Personality := 00;
    if (Self.Account.Header.Pran2.Personality.Smart >=
      Self.Account.Header.Pran1.Devotion) then
      Packet.Personality := 01;
    if (Self.Account.Header.Pran2.Personality.Sexy >=
      Self.Account.Header.Pran1.Devotion) then
      Packet.Personality := 02;
    if (Self.Account.Header.Pran2.Personality.Energetic >=
      Self.Account.Header.Pran1.Devotion) then
      Packet.Personality := 03;
    if (Self.Account.Header.Pran2.Personality.Tough >=
      Self.Account.Header.Pran1.Devotion) then
      Packet.Personality := 04;
    if (Self.Account.Header.Pran2.Personality.Corrupt >=
      Self.Account.Header.Pran1.Devotion) then
      Packet.Personality := 05;
    for i := 0 to 9 do { ATTENTION PRAN SKILL Count can be 10 or 12 }
    begin
      if (Self.Account.Header.Pran2.Skills[i].Level = 0) then
      begin
        Continue;
      end;
      Tamanho := TSkillFunctions.GetSkillPranLevel(i,
        Self.Account.Header.Pran2.Skills[i].Level, Level);
      Move(Level, Packet.Unk[i], Tamanho);
    end;
    for i := 0 to 2 do
    begin
      if (Self.Account.Header.Pran2.ItemBar[i] = 0) then
      begin
        Continue;
      end;
      Packet.PranSkillBar[i] := Self.Account.Header.Pran2.ItemBar[i];
    end;
    Packet.Devotion := Self.Account.Header.Pran2.Devotion;
    Packet.MaxHp := Self.Account.Header.Pran2.MaxHp;
    Packet.CurHP := Self.Account.Header.Pran2.CurHP;
    Packet.MaxMP := Self.Account.Header.Pran2.MaxMP;
    Packet.CurMp := Self.Account.Header.Pran2.CurMp;
    Packet.Exp := Self.Account.Header.Pran2.Exp;
    Packet.DefFis := Self.Account.Header.Pran2.DefFis;
    Packet.DefMag := Self.Account.Header.Pran2.DefMag;
    Move(Self.Account.Header.Pran2.Equip, Packet.Equips, 16 * sizeof(TItem));
    Move(Self.Account.Header.Pran2.Inventory, Packet.Inventory,
      42 * sizeof(TItem));
  end;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendPranSpawn(PranSlot: BYTE; SendTo: WORD; SpawnType: BYTE);
var
  Packet: TSendCreatePranPacket;
  // Packet2: Tp10D;
  i: Integer;
  Rand: Integer;
  Title: String;
begin
  ZeroMemory(@Packet, sizeof(TSendCreatePranPacket));
  Packet.Header.size := sizeof(TSendCreatePranPacket);
  Packet.Header.Code := $349;
  if (PranSlot = 0) then
  begin
    { if (Self.Account.Header.Pran1.ID = 0) then
      begin
      Packet.Header.Index := Servers[Self.ChannelIndex].GetFreePranClientID;
      Logger.Write('Pegou novo id de pran char name:' +
      String(Self.Character.Base.Name), TlogType.Warnings);
      if (Packet.Header.Index = 0) then
      begin
      Self.SendClientMessage
      ('O ClientID da pran não pode ser vazio. Nos envie um ticket.');
      Exit;
      end;
      Self.Account.Header.Pran1.ID := Packet.Header.Index;
      Servers[Self.ChannelIndex].Prans[Packet.Header.Index] :=
      Self.Account.Header.Pran1.Iddb;
      end
      else
      begin
      Packet.Header.Index := Self.Account.Header.Pran1.ID;
      end; }
    // fazer teste, dps fazer isso ficar dinamico
    if not(Self.PranIsFairy(Self.Account.Header.Pran1.ClassPran)) then
    begin
      Move(Self.Account.Header.Pran1.Name, Packet.Name[0], 16);
      for i := 0 to 7 do
        Packet.Equip[i] := Self.Account.Header.Pran1.Equip[i].Index;

      Packet.MaxHp := Self.Account.Header.Pran1.MaxHp;
      Packet.CurHP := Self.Account.Header.Pran1.CurHP;
      Packet.MaxMP := Self.Account.Header.Pran1.MaxMP;
      Packet.CurMp := Self.Account.Header.Pran1.CurMp;
      Packet.SpeedMove := Self.Base.PlayerCharacter.SpeedMove;
      Packet.SpawnType := SpawnType;
      Packet.Altura := Self.Account.Header.Pran1.Width;
      Packet.Tronco := Self.Account.Header.Pran1.Chest;
      Packet.Perna := Self.Account.Header.Pran1.Leg;
      ///SetLength(Servers[Self.ChannelIndex].PranClientID,
        //Length(Servers[Self.ChannelIndex].PranClientID)+1);
      Packet.PranClientID := Self.Base.PranClientID;
      Packet.Header.Index := Packet.PranClientID;

      if(Self.Account.Header.Pran1.Equip[5].Index <> 0) then
      begin
        if(ItemList[Self.Account.Header.Pran1.Equip[5].Index].DelayUse <> 0) then
        begin
          ZeroMemory(@Packet.Equip, sizeof(Packet.Equip));
          Packet.Equip[0] := ItemList[Self.Account.Header.Pran1.Equip[5].Index].DelayUse;
          Packet.Equip[6] := ItemList[Self.Account.Header.Pran1.Equip[5].Index].MeshIDWeapon;
        end
        else
        begin
          for i := 0 to 7 do
            Packet.Equip[i] := Self.Character.Base.Equip[i].Index;
        end;

        Packet.Altura := ItemList[Self.Account.Header.Pran1.Equip[5].Index].Duration;

        //Packet.Effects[1] := 74;
      end;
      // Title := 'Pran de ' + QuotedStr(String(Self.Character.Base.Name));
      Title := String(Self.Character.Base.Name) + ' ' + #39 + 's Pran';
      AnsiStrings.StrPLCopy(Packet.Title, AnsiString(Title), 32);
      if (SendTo = 0) then
      begin
        Randomize;
        Rand := RandomRange(0, 8);
        Packet.Position := Self.Base.Neighbors[Rand].Pos;
        Self.Account.Header.Pran1.Position := Packet.Position;
        Self.Base.SendToVisible(Packet, Packet.Header.size, True);
        Self.Account.Header.Pran1.IsSpawned := True;
      end
      else
      begin
        Packet.Position := Self.Account.Header.Pran1.Position;
        Servers[Self.ChannelIndex].SendPacketTo(SendTo, Packet,
          Packet.Header.size);
      end;
    end
    else // pran modo elfa
    begin
      case Self.Account.Header.Pran1.ClassPran of
        61..64:
          Self.SendEffect(2);
        71..74:
          Self.SendEffect(4);
        81..84:
          Self.SendEffect(8);
      end;
    end;
  end
  else if (PranSlot = 1) then
  begin
    { if (Self.Account.Header.Pran2.ID = 0) then
      begin
      Packet.Header.Index := Servers[Self.ChannelIndex].GetFreePranClientID;
      if (Packet.Header.Index = 0) then
      begin
      Self.SendClientMessage
      ('O ClientID da pran não pode ser vazio. Nos envie um ticket.');
      Exit;
      end;
      Self.Account.Header.Pran2.ID := Packet.Header.Index;
      Servers[Self.ChannelIndex].Prans[Packet.Header.Index] :=
      Self.Account.Header.Pran2.Iddb;
      end
      else
      begin
      Packet.Header.Index := Self.Account.Header.Pran2.ID;
      end; }
    // fazer teste, dps fazer isso ficar dinamico fazer no unspawn pran tbm
    if not(Self.PranIsFairy(Self.Account.Header.Pran2.ClassPran)) then
    begin
      Move(Self.Account.Header.Pran2.Name, Packet.Name[0], 16);
      for i := 0 to 7 do
        Packet.Equip[i] := Self.Account.Header.Pran2.Equip[i].Index;
      Packet.MaxHp := Self.Account.Header.Pran2.MaxHp;
      Packet.CurHP := Self.Account.Header.Pran2.CurHP;
      Packet.MaxMP := Self.Account.Header.Pran2.MaxMP;
      Packet.CurMp := Self.Account.Header.Pran2.CurMp;
      Packet.SpeedMove := Self.Base.PlayerCharacter.SpeedMove;
      Packet.SpawnType := SpawnType;
      Packet.Altura := Self.Account.Header.Pran2.Width;
      Packet.Tronco := Self.Account.Header.Pran2.Chest;
      Packet.Perna := Self.Account.Header.Pran2.Leg;
      Packet.PranClientID := Self.Base.PranClientID;//Self.Account.Header.Pran2.Iddb + 10240;
      Packet.Header.Index := Packet.PranClientID;

      if(Self.Account.Header.Pran2.Equip[5].Index <> 0) then
      begin
        if(ItemList[Self.Account.Header.Pran2.Equip[5].Index].DelayUse <> 0) then
        begin
          ZeroMemory(@Packet.Equip, sizeof(Packet.Equip));
          Packet.Equip[0] := ItemList[Self.Account.Header.Pran2.Equip[5].Index].DelayUse;
          Packet.Equip[6] := ItemList[Self.Account.Header.Pran2.Equip[5].Index].MeshIDWeapon;
        end
        else
        begin
          for i := 0 to 7 do
            Packet.Equip[i] := Self.Character.Base.Equip[i].Index;
        end;

        Packet.Altura := ItemList[Self.Account.Header.Pran2.Equip[5].Index].Duration;

        //Packet.Effects[1] := 74;
      end;

      // Title := 'Pran de ' + QuotedStr(String(Self.Character.Base.Name));
      Title := String(Self.Character.Base.Name) + ' ' + #39 + 's Pran';
      AnsiStrings.StrPLCopy(Packet.Title, AnsiString(Title), 32);
      if (SendTo = 0) then
      begin
        Randomize;
        Rand := RandomRange(0, 8);
        Packet.Position := Self.Base.Neighbors[Rand].Pos;
        Self.Account.Header.Pran2.Position := Packet.Position;
        Self.Base.SendToVisible(Packet, Packet.Header.size, True);
        Self.Account.Header.Pran2.IsSpawned := True;
      end
      else
      begin
        Packet.Position := Self.Account.Header.Pran2.Position;
        Servers[Self.ChannelIndex].SendPacketTo(SendTo, Packet,
          Packet.Header.size);
      end;
    end
    else // pran modo elfa
    begin
      case Self.Account.Header.Pran2.ClassPran of
        61..64:
          Self.SendEffect(2);
        71..74:
          Self.SendEffect(4);
        81..84:
          Self.SendEffect(8);
      end;
    end;
  end;
end;
procedure TPlayer.SendPranUnspawn(PranSlot: BYTE; SendTo: WORD);
var
  Packet: TSendRemoveMobPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(TSendRemoveMobPacket);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $101;
  case PranSlot of
    0:
      begin // fazer aqui e no spawnpran
        if (Self.Account.Header.Pran1.Iddb > 0) then
        begin
          Packet.Index := Self.Base.PranClientID;
          Packet.DeleteType := 0;
          // eu vou zerar o client id das prans sempre que for unspanned
          if (Self.Account.Header.Pran1.Level < 4) then
          begin
            Self.SendEffect(0);
          end
          else
          begin
            if (SendTo = 0) then
            begin
              Self.Base.SendToVisible(Packet, Packet.Header.size, True);
              if (Self.SpawnedPran = 255) then
              begin
                // Servers[Self.ChannelIndex].Prans
                // [Self.Account.Header.Pran1.ID] := 0;
                // Self.Account.Header.Pran1.ID := 0;
                Self.Account.Header.Pran1.IsSpawned := FALSE;
              end;
            end
            else
            begin
              Servers[Self.ChannelIndex].SendPacketTo(SendTo, Packet,
                Packet.Header.size);
            end;
          end;
        end;
      end;
    1:
      begin
        if (Self.Account.Header.Pran2.Iddb > 0) then
        begin
          Packet.Index := Self.Base.PranClientID;
          Packet.DeleteType := 0;
          if (Self.Account.Header.Pran2.Level < 4) then
          begin
            Self.SendEffect(0);
          end
          else
          begin
            if (SendTo = 0) then
            begin
              Self.Base.SendToVisible(Packet, Packet.Header.size, True);
              if (Self.SpawnedPran = 255) then
              begin
                // Servers[Self.ChannelIndex].Prans
                // [Self.Account.Header.Pran2.ID] := 0;
                // Self.Account.Header.Pran2.ID := 0;
                Self.Account.Header.Pran2.IsSpawned := FALSE;
              end;
            end
            else
            begin
              Servers[Self.ChannelIndex].SendPacketTo(SendTo, Packet,
                Packet.Header.size);
            end;
          end;
        end;
      end;
  end;
end;
procedure TPlayer.SetPranPassiveSkill(PranSlot: BYTE; Action: BYTE);
var
  i: Integer;
begin
  case PranSlot of
    0:
      begin
        case Action of
          0:
            // desativando as passivas
            begin
              for i := 0 to 9 do
              begin
                if (Self.Account.Header.Pran1.Skills[i].Level = 0) then
                  Continue;
                case SkillData[Self.Account.Header.Pran1.Skills[i].
                  Index + (Self.Account.Header.Pran1.Skills[i].Level - 1)
                  ].Index of
                  193: // bravura [ataque em todos os sentidos] 5 + (2*lv)
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (5 + (2 * Self.Account.Header.Pran1.Skills[i].Level)));
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (5 + (2 * Self.Account.Header.Pran1.Skills[i].Level)));
                    end;
                  194: // defesa elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran1.Skills[i].Level));
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran1.Skills[i].Level));
                    end;
                  197: // coragem [hp+] 23 + ((13+level) * level)
                    begin
                      Base.DecreasseMobAbility(EF_HP,
                        (23 + (13 + Self.Account.Header.Pran1.Skills[i].Level) *
                        Self.Account.Header.Pran1.Skills[i].Level));
                    end;
                  199: // lamina flamejante [crit+] 1*lv
                    begin
                      Base.DecreasseMobAbility(EF_CRITICAL,
                        Self.Account.Header.Pran1.Skills[i].Level);
                    end;
                  217: // coragem [ataque em todos os sentidos] 3 + (2*lv)
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (3 + (2 * Self.Account.Header.Pran1.Skills[i].Level)));
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (3 + (2 * Self.Account.Header.Pran1.Skills[i].Level)));
                    end;
                  218: // proteção elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran1.Skills[i].Level));
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran1.Skills[i].Level));
                    end;
                  221: // sabedoria [mp+] 30 + (20*lv)
                    begin
                      Base.DecreasseMobAbility(EF_MP,
                        (30 + (20 * Self.Account.Header.Pran1.Skills[i]
                        .Level)));
                    end;
                  223: // toque assombrado [res+] lv*1
                    begin
                      Base.DecreasseMobAbility(EF_RESISTANCE6,
                        Self.Account.Header.Pran1.Skills[i].Level);
                    end;
                  241: // coragem [ataque em todos os sentidos] 5 + (2*lv)
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (4 + (2 * Self.Account.Header.Pran1.Skills[i].Level)));
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (4 + (2 * Self.Account.Header.Pran1.Skills[i].Level)));
                    end;
                  242: // proteção elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran1.Skills[i].Level));
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran1.Skills[i].Level));
                    end;
                  245: // serenidade [hp e mp+]
                    begin
                      Base.DecreasseMobAbility(EF_HP,
                        (15 + ((8 + Self.Account.Header.Pran1.Skills[i].Level) *
                        Self.Account.Header.Pran1.Skills[i].Level)));
                      Base.DecreasseMobAbility(EF_MP,
                        (21 + ((11 + Self.Account.Header.Pran1.Skills[i].Level)
                        * Self.Account.Header.Pran1.Skills[i].Level)));
                    end;
                  247: // vento da clemencia [hp_res e mp_res+]
                    begin
                      Base.DecreasseMobAbility(EF_HP,
                        (15 + ((8 + Self.Account.Header.Pran1.Skills[i].Level) *
                        Self.Account.Header.Pran1.Skills[i].Level)));
                      Base.DecreasseMobAbility(EF_MP,
                        (21 + ((11 + Self.Account.Header.Pran1.Skills[i].Level)
                        * Self.Account.Header.Pran1.Skills[i].Level)));
                    end;
                end;
              end;
            end;
          1: // ativando as passivas
            begin
              for i := 0 to 9 do
              begin
                if (Self.Account.Header.Pran1.Skills[i].Level = 0) then
                  Continue;
                case SkillData[Self.Account.Header.Pran1.Skills[i].
                  Index + (Self.Account.Header.Pran1.Skills[i].Level - 1)
                  ].Index of
                  193: // bravura [ataque em todos os sentidos] 5 + (2*lv)
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (5 + (2 * Self.Account.Header.Pran1.Skills[i].Level)));
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (5 + (2 * Self.Account.Header.Pran1.Skills[i].Level)));
                    end;
                  194: // defesa elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran1.Skills[i].Level));
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran1.Skills[i].Level));
                    end;
                  197: // coragem [hp+] 23 + ((13+level) * level)
                    begin
                      Base.IncreasseMobAbility(EF_HP,
                        (23 + (13 + Self.Account.Header.Pran1.Skills[i].Level) *
                        Self.Account.Header.Pran1.Skills[i].Level));
                    end;
                  199: // lamina flamejante [crit+] 1*lv
                    begin
                      Base.IncreasseMobAbility(EF_CRITICAL,
                        Self.Account.Header.Pran1.Skills[i].Level);
                    end;
                  217: // coragem [ataque em todos os sentidos] 3 + (2*lv)
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (3 + (2 * Self.Account.Header.Pran1.Skills[i].Level)));
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (3 + (2 * Self.Account.Header.Pran1.Skills[i].Level)));
                    end;
                  218: // proteção elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran1.Skills[i].Level));
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran1.Skills[i].Level));
                    end;
                  221: // sabedoria [mp+] 30 + (20*lv)
                    begin
                      Base.IncreasseMobAbility(EF_MP,
                        (30 + (20 * Self.Account.Header.Pran1.Skills[i]
                        .Level)));
                    end;
                  223: // toque assombrado [res+] lv*1
                    begin
                      Base.IncreasseMobAbility(EF_RESISTANCE6,
                        Self.Account.Header.Pran1.Skills[i].Level);
                    end;
                  241: // coragem [ataque em todos os sentidos] 5 + (2*lv)
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (4 + (2 * Self.Account.Header.Pran1.Skills[i].Level)));
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (4 + (2 * Self.Account.Header.Pran1.Skills[i].Level)));
                    end;
                  242: // proteção elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran1.Skills[i].Level));
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran1.Skills[i].Level));
                    end;
                  245: // serenidade [hp e mp+]
                    begin
                      Base.IncreasseMobAbility(EF_HP,
                        (15 + ((8 + Self.Account.Header.Pran1.Skills[i].Level) *
                        Self.Account.Header.Pran1.Skills[i].Level)));
                      Base.IncreasseMobAbility(EF_MP,
                        (21 + ((11 + Self.Account.Header.Pran1.Skills[i].Level)
                        * Self.Account.Header.Pran1.Skills[i].Level)));
                    end;
                  247: // vento da clemencia [hp_res e mp_res+]
                    begin
                      Base.IncreasseMobAbility(EF_HP,
                        (15 + ((8 + Self.Account.Header.Pran1.Skills[i].Level) *
                        Self.Account.Header.Pran1.Skills[i].Level)));
                      Base.IncreasseMobAbility(EF_MP,
                        (21 + ((11 + Self.Account.Header.Pran1.Skills[i].Level)
                        * Self.Account.Header.Pran1.Skills[i].Level)));
                    end;
                end;
              end;
            end;
        end;
      end;
    1:
      begin
        case Action of
          0: // desativando as passivas
            begin
              for i := 0 to 9 do
              begin
                if (Self.Account.Header.Pran2.Skills[i].Level = 0) then
                  Continue;
                case SkillData[Self.Account.Header.Pran2.Skills[i].
                  Index + (Self.Account.Header.Pran2.Skills[i].Level - 1)
                  ].Index of
                  193: // bravura [ataque em todos os sentidos] 5 + (2*lv)
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (5 + (2 * Self.Account.Header.Pran2.Skills[i].Level)));
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (5 + (2 * Self.Account.Header.Pran2.Skills[i].Level)));
                    end;
                  194: // defesa elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran2.Skills[i].Level));
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran2.Skills[i].Level));
                    end;
                  197: // coragem [hp+] 23 + ((13+level) * level)
                    begin
                      Base.DecreasseMobAbility(EF_HP,
                        (23 + (13 + Self.Account.Header.Pran2.Skills[i].Level) *
                        Self.Account.Header.Pran1.Skills[i].Level));
                    end;
                  199: // lamina flamejante [crit+] 1*lv
                    begin
                      Base.DecreasseMobAbility(EF_CRITICAL,
                        Self.Account.Header.Pran2.Skills[i].Level);
                    end;
                  217: // coragem [ataque em todos os sentidos] 3 + (2*lv)
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (3 + (2 * Self.Account.Header.Pran2.Skills[i].Level)));
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (3 + (2 * Self.Account.Header.Pran2.Skills[i].Level)));
                    end;
                  218: // proteção elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran2.Skills[i].Level));
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran2.Skills[i].Level));
                    end;
                  221: // sabedoria [mp+] 30 + (20*lv)
                    begin
                      Base.DecreasseMobAbility(EF_MP,
                        (30 + (20 * Self.Account.Header.Pran2.Skills[i]
                        .Level)));
                    end;
                  223: // toque assombrado [res+] lv*1
                    begin
                      Base.DecreasseMobAbility(EF_RESISTANCE6,
                        Self.Account.Header.Pran2.Skills[i].Level);
                    end;
                  241: // coragem [ataque em todos os sentidos] 5 + (2*lv)
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (4 + (2 * Self.Account.Header.Pran2.Skills[i].Level)));
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (4 + (2 * Self.Account.Header.Pran2.Skills[i].Level)));
                    end;
                  242: // proteção elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran2.Skills[i].Level));
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran2.Skills[i].Level));
                    end;
                  245: // serenidade [hp e mp+]
                    begin
                      Base.DecreasseMobAbility(EF_HP,
                        (15 + ((8 + Self.Account.Header.Pran2.Skills[i].Level) *
                        Self.Account.Header.Pran2.Skills[i].Level)));
                      Base.DecreasseMobAbility(EF_MP,
                        (21 + ((11 + Self.Account.Header.Pran2.Skills[i].Level)
                        * Self.Account.Header.Pran2.Skills[i].Level)));
                    end;
                  247: // vento da clemencia [hp_res e mp_res+]
                    begin
                      Base.DecreasseMobAbility(EF_HP,
                        (15 + ((8 + Self.Account.Header.Pran1.Skills[i].Level) *
                        Self.Account.Header.Pran2.Skills[i].Level)));
                      Base.DecreasseMobAbility(EF_MP,
                        (21 + ((11 + Self.Account.Header.Pran1.Skills[i].Level)
                        * Self.Account.Header.Pran2.Skills[i].Level)));
                    end;
                end;
              end;
            end;
          1: // ativando as passivas
            begin
              for i := 0 to 9 do
              begin
                if (Self.Account.Header.Pran2.Skills[i].Level = 0) then
                  Continue;
                case SkillData[Self.Account.Header.Pran2.Skills[i].
                  Index + (Self.Account.Header.Pran2.Skills[i].Level - 1)
                  ].Index of
                  193: // bravura [ataque em todos os sentidos] 5 + (2*lv)
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (5 + (2 * Self.Account.Header.Pran2.Skills[i].Level)));
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (5 + (2 * Self.Account.Header.Pran2.Skills[i].Level)));
                    end;
                  194: // defesa elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran2.Skills[i].Level));
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran2.Skills[i].Level));
                    end;
                  197: // coragem [hp+] 23 + ((13+level) * level)
                    begin
                      Base.IncreasseMobAbility(EF_HP,
                        (23 + (13 + Self.Account.Header.Pran2.Skills[i].Level) *
                        Self.Account.Header.Pran2.Skills[i].Level));
                    end;
                  199: // lamina flamejante [crit+] 1*lv
                    begin
                      Base.IncreasseMobAbility(EF_CRITICAL,
                        Self.Account.Header.Pran2.Skills[i].Level);
                    end;
                  217: // coragem [ataque em todos os sentidos] 3 + (2*lv)
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (3 + (2 * Self.Account.Header.Pran2.Skills[i].Level)));
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (3 + (2 * Self.Account.Header.Pran2.Skills[i].Level)));
                    end;
                  218: // proteção elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran2.Skills[i].Level));
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran2.Skills[i].Level));
                    end;
                  221: // sabedoria [mp+] 30 + (20*lv)
                    begin
                      Base.IncreasseMobAbility(EF_MP,
                        (30 + (20 * Self.Account.Header.Pran2.Skills[i]
                        .Level)));
                    end;
                  223: // toque assombrado [res+] lv*1
                    begin
                      Base.IncreasseMobAbility(EF_RESISTANCE6,
                        Self.Account.Header.Pran2.Skills[i].Level);
                    end;
                  241: // coragem [ataque em todos os sentidos] 5 + (2*lv)
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (4 + (2 * Self.Account.Header.Pran2.Skills[i].Level)));
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (4 + (2 * Self.Account.Header.Pran2.Skills[i].Level)));
                    end;
                  242: // proteção elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran2.Skills[i].Level));
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran2.Skills[i].Level));
                    end;
                  245: // serenidade [hp e mp+]
                    begin
                      Base.IncreasseMobAbility(EF_HP,
                        (15 + ((8 + Self.Account.Header.Pran2.Skills[i].Level) *
                        Self.Account.Header.Pran2.Skills[i].Level)));
                      Base.IncreasseMobAbility(EF_MP,
                        (21 + ((11 + Self.Account.Header.Pran2.Skills[i].Level)
                        * Self.Account.Header.Pran2.Skills[i].Level)));
                    end;
                  247: // vento da clemencia [hp_res e mp_res+]
                    begin
                      Base.IncreasseMobAbility(EF_HP,
                        (15 + ((8 + Self.Account.Header.Pran2.Skills[i].Level) *
                        Self.Account.Header.Pran2.Skills[i].Level)));
                      Base.IncreasseMobAbility(EF_MP,
                        (21 + ((11 + Self.Account.Header.Pran2.Skills[i].Level)
                        * Self.Account.Header.Pran2.Skills[i].Level)));
                    end;
                end;
              end;
            end;
        end;
      end;
  end;
end;
function TPlayer.GetPranClassStoneItem(PranClass: BYTE): BYTE;
begin
  Result := 0;
  case PranClass of
    61, 62, 71, 72, 81, 82:
      Result := 100;
    63, 73, 83:
      Result := 101;
    64, 74, 84:
      Result := 102;
  end;
end;
function TPlayer.PranIsFairy(PranClass: BYTE): Boolean;
begin
  Result := FALSE;
  case PranClass of
    61, 71, 81:
      Result := True;
  end;
  if(Result = False) then
  begin
    Result := Self.FaericForm;
  end;
end;
procedure TPlayer.SetPranEquipAtributes(PranSlot: BYTE; SetOn: Boolean);
var
  i: BYTE;
begin
  if (SetOn = True) then
  begin // aqui setar os atributos como online.
    case PranSlot of
      0:
        begin
          for i := 0 to 15 do
          begin
            if (Self.Account.Header.Pran1.Equip[i].Index = 0) then
              Continue;
            Self.Base.SetEquipEffect(Self.Account.Header.Pran1.Equip[i],
              EQUIPING_TYPE);
          end;
        end;
      1:
        begin
          for i := 0 to 15 do
          begin
            if (Self.Account.Header.Pran2.Equip[i].Index = 0) then
              Continue;
            Self.Base.SetEquipEffect(Self.Account.Header.Pran2.Equip[i],
              EQUIPING_TYPE);
          end;
        end;
    end;
  end
  else // aqui setar os atributos como offline.
  begin
    case PranSlot of
      0:
        begin
          for i := 0 to 15 do
          begin
            if (Self.Account.Header.Pran1.Equip[i].Index = 0) then
              Continue;
            Self.Base.SetEquipEffect(Self.Account.Header.Pran1.Equip[i],
              DESEQUIPING_TYPE);
          end;
        end;
      1:
        begin
          for i := 0 to 15 do
          begin
            if (Self.Account.Header.Pran2.Equip[i].Index = 0) then
              Continue;
            Self.Base.SetEquipEffect(Self.Account.Header.Pran2.Equip[i],
              DESEQUIPING_TYPE);
          end;
        end;
    end;
  end;
end;
procedure TPlayer.RefreshMoney;
var
  Packet: TRefreshMoneyPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $312;
  Packet.InventoryGold := Character.Base.Gold;
  Packet.ChestGold := Account.Header.Storage.Gold;
  SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.RefreshItemBarSlot(Slot: Integer; Type1: Integer;
  Item: Integer);
var
  Packet: TChangeItemBarPacket;
begin
  ZeroMemory(@Packet, sizeof(TChangeItemBarPacket));
  Packet.Header.size := sizeof(TChangeItemBarPacket);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $31E;
  Packet.DestSlot := Slot;
  Packet.SrcType := Type1;
  Packet.SrcIndex := Item;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendStorage(StorageType: Integer = 1);
var
  Packet: TStoragePacket;
begin
  ZeroMemory(@Packet, sizeof(TStoragePacket));
  Packet.Header.size := sizeof(TStoragePacket);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $137;
  Move(Self.Account.Header.Storage, Packet.Storage, sizeof(TStoragePlayer));
  {if not(Self.Character.IsStorageSend) then
  begin

    Self.Character.IsStorageSend := True;
  end;}
  Self.SendPacket(Packet, Packet.Header.size);
  Self.SendData(Self.Base.clientId, $310, StorageType);
  Self.Base.SendRefreshItemSlot(STORAGE_TYPE, 84,
    Self.Account.Header.Storage.Itens[84], FALSE);
  Self.Base.SendRefreshItemSlot(STORAGE_TYPE, 85,
    Self.Account.Header.Storage.Itens[85], FALSE);
end;
procedure TPlayer.SendChangeItemResponse(ReinforceResult: WORD;
  ChangeType: BYTE);
var
  Packet: TReinforceResponse;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $32E;
  Packet.ReinforceResult := ReinforceResult;
  Packet.Unk1 := ChangeType;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendAccountStatus();
var
  Packet: TSendAccountStatus;
  Helper1: Integer;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $14F;
  Packet.Header.Index := Self.Base.clientId;

  if((Self.Account.Header.PremiumTime <> 0) and (DateTimeToStr(Self.Account.Header.PremiumTime)
    <> '01/01/2020')) then
  begin
    Helper1 := DaysBetween(Now, Self.Account.Header.PremiumTime);
    if(Helper1 <= 3) then
    begin
      Packet.Status := AuxilioRed1;
      Self.SendClientMessage('Restam apenas mais ' + Helper1.ToString +
        ' dias de Auxílio Poderoso. Adquira iNiz Coins.');
    end
    else
    begin
      Packet.Status := AuxilioBlue1;
      Self.SendClientMessage('Restam ainda ' + Helper1.ToString +
        ' dias de Auxílio Poderoso. Aproveite.');
    end;
  end;

  Self.SendPacket(Packet, Packet.Header.size);
end;


procedure TPlayer.SendToWorldSends(IsSendedByOtherChannel: Boolean);
var
  i, j: Integer;
  xCharacterId: UInt64;
  PtrMyFriend: PPlayer;
  AlreadyActivatedAux: Boolean;
  ResultOf: Integer;
begin
  if (Self.IsInstantiated = True) then
    Exit;

  IsAuxilyUser := False;

  Self.Base.LastMovedTime := Now;
  Self.Base.LastMovedMessageHack := Now;
  Self.LoadCharacterTeleportList(String(Self.Base.Character.Name));
  Self.SendTeleportPositionsFC();

  Base.SendCreateMob(SPAWN_NORMAL, Self.Base.clientId);

  if (Self.Character.Base.GuildIndex > 0) then
  begin
    Self.Character.GuildSlot :=
      Servers[Self.ChannelIndex].GetGuildSlotByID(Self.Character.Base.GuildIndex);
    Self.SendGuildInfo;
    Self.RefreshPlayerInfos;
    Self.SendP152;
    Self.SendGuildPlayers;
    Guilds[Self.Character.GuildSlot].SendMemberLogin(Self.Character.Base.CharIndex);
  end;

  Self.SendPlayerSkills;

  if (Self.Character.Base.Exp = 0) then
  begin
    i := TItemFunctions.GetItemSlot2(Self, 5284);
    if(i<>255) then
    begin
      TITemFunctions.RemoveItem(Self, INV_TYPE, i);
    end;
    Self.Character.Base.Exp := 1;
    Base.SendRefreshLevel;
  end;
  Self.SendCashInventory;

  try
    Self.CurrentCityID := Self.GetCurrentCityID;
    if (Self.EntityFriend.readFriendList(@Self)) then
    begin
      Self.RefreshSocialFriends;
      Self.SendFriendLogin;
      Self.RefreshMeToFriends;
    end;
  except

  end;

  AlreadyActivatedAux := False;

  Self.SendPlayerCash;
  if (Self.Character.PlayerKill) then
  begin
    Self.SendData(Self.Base.clientId, $357, 1);
  end;

  Self.SearchSkillsPassive(0);

  if not(IsSendedByOtherChannel) then
  begin
    if not(DateTimeToStr(Self.Account.Header.PremiumTime) = '01/01/2020') then
    begin
      ResultOf := CompareDateTime(Now, Self.Account.Header.PremiumTime);

      if (ResultOf < 1) then
      begin
        Self.SendAccountStatus();
        AlreadyActivatedAux := True;
        IsAuxilyUser := True;
      end
      else
      begin
        Self.SendClientMessage('Seu auxílio poderoso expirou.');
      end;
    end;

    for i := 0 to 59 do
    begin
      if (Self.Base.Character.Inventory[i].Index = 0) then
        Continue;
      if (Self.Base.Character.Inventory[i].Index = 8250) then
      begin
        if (DateTimeToStr(Self.Account.Header.PremiumTime) = '01/01/2020') then
        begin
          Self.SendClientMessage
            ('Seu auxílio poderoso foi ativado. Voc?tem 30 dias Premium.');

          Self.Account.Header.PremiumTime := Now;
          Self.Account.Header.PremiumTime :=
            IncDay(Self.Account.Header.PremiumTime, 30);
          Self.SendAccountStatus();
          AlreadyActivatedAux := True;
          IsAuxilyUser := True;
        end
        else
        begin
          ResultOf := CompareDateTime(Now, Self.Account.Header.PremiumTime);

          if (ResultOf = 1) then
          begin
            Self.Account.Header.PremiumTime := StrToDateTime('01/01/2020');
            TItemFunctions.RemoveItem(Self, INV_TYPE, i);
            Self.SendClientMessage('Seu auxílio poderoso expirou.');
          end
          else
          begin
            Self.SendAccountStatus();
            AlreadyActivatedAux := True;
            IsAuxilyUser := True;
          end;
        end;
      end;
      if not(TItemFunctions.GetItemEquipSlot(Self.Base.Character.Inventory[i].
        Index) = 9) then
        Continue;
      Self.Base.SendRefreshItemSlot(i, FALSE);
    end;

    if not(AlreadyActivatedAux) then
    begin
      for j := 0 to 2 do
        begin
          if(Self.Account.Characters[j].Base.CharIndex = 0) then
            Continue;

            if(Self.Account.Characters[j].Base.CharIndex =
              Self.Base.Character.CharIndex) then
            Continue;

          for I := 0 to 59 do
          begin
            if(Self.Account.Characters[j].Base.Inventory[i].Index = 0) then
              Continue;

            if (Self.Account.Characters[j].Base.Inventory[i].Index = 8250) then
            begin
              if (DateTimeToStr(Self.Account.Header.PremiumTime) = '01/01/2020') then
              begin
                Self.SendClientMessage
                  ('Seu auxílio poderoso foi ativado. Voc?tem 30 dias Premium.');
                Self.Account.Header.PremiumTime := Now;
                Self.Account.Header.PremiumTime :=
                  IncDay(Self.Account.Header.PremiumTime, 30);
                Self.SendAccountStatus();
                AlreadyActivatedAux := True;
                IsAuxilyUser := True;
              end
              else
              begin
                ResultOf := CompareDateTime(Now, Self.Account.Header.PremiumTime);

                if (ResultOf = 1) then
                begin
                  Self.SendClientMessage('Seu auxílio poderoso expirou.');
                end
                else
                begin
                  Self.SendAccountStatus();
                  AlreadyActivatedAux := True;
                  IsAuxilyUser := True;
                end;
              end;
            end;
          end;
        end;
    end;

    if not(AlreadyActivatedAux) then
      Self.Account.Header.PremiumTime := StrToDateTime('01/01/2020');
  end;

  Self.SavedPos := Self.LoadSavedLocation();

  for i := 0 to 59 do
  begin
    if (Self.Base.PlayerCharacter.Buffs[i].Index = 0) then
      Continue;
    Self.Base.AddBuffWhenEntering(Self.Base.PlayerCharacter.Buffs[i].Index,
      Self.Base.PlayerCharacter.Buffs[i].CreationTime);
  end;
  Self.Status := Playing;
  Self.Base.SendRefreshBuffs;
  Self.SendQuests;
  TEntityMail.sendUnreadMails(Self);
  Self.SendUpdateActiveTitle();
  Self.Base.SetOnTitleActiveEffect;
  { nation send begin }
  Self.SendNationInformation;
  Self.SendReliquesToPlayer;
  { nation send end }
  Self.Base.GetCurrentScore;
  Self.Base.SendRefreshPoint;
  Self.Base.SendStatus;
  Self.Base.SendRefreshLevel;
  Self.Base.SendCurrentHPMP();
  if(Self.Base.Character.Equip[9].Index <> 0) then
  begin //corrigindo os atributos da montaria
    Self.Base.SendRefreshItemSlot(EQUIP_TYPE, 9,
      Self.Base.Character.Equip[9], FALSE);
  end;
  for I := 0 to 23 do
  begin
    if(Self.Character.Base.ItemBar[i] = 0) then
      Continue;
    if(TItemFunctions.GetItemSlot2(Self, Self.Character.Base.ItemBar[i]) = 255) then
    begin
      Continue;
    end
    else
    begin
      Self.RefreshItemBarSlot(i, 6, Self.Character.Base.ItemBar[i]);
    end;
  end;

  //Self.Base.VisibleNPCS.Clear;
  //Self.Base.UpdateVisibleList();

  Self.Character.LastPos := Self.Base.PlayerCharacter.LastPos;
  if (Self.GetCurrentCity <> Self.CurrentCity) then
  begin
    //Player.CurrentCity := Player.GetCurrentCity;
    Self.CurrentCityID := Self.GetCurrentCityID;
    Self.RefreshMeToFriends;
  end;

  //Self.SetCurrentNeighbors;

  Self.IsInstantiated := True;

  Self.Base.VisibleMobs.Clear;
  Self.Base.VisiblePlayers.Clear;
  Self.Base.VisibleNPCS.Clear;
  //Self.Base.visible
  {for I := 1 to High(Servers[Self.ChannelIndex].Players) do
  begin
    if(Servers[Self.ChannelIndex].Players[i].Status >= Playing) then
    begin
      if(Servers[Self.ChannelIndex].Players[i].Base.PlayerCharacter.LastPos.InRange(
        Self.Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)) then
      begin
        Self.Base.SendCreateMob(SPAWN_TELEPORT, i, False);
        if(i = Self.Base.ClientID) then
          Continue;
        Servers[Self.ChannelIndex].Players[i].Base.SendCreateMob(SPAWN_TELEPORT,
          Self.Base.ClientID, False);
        Sleep(1);
        Servers[Self.ChannelIndex].Players[i].Base.SendCreateMob(SPAWN_TELEPORT,
          Self.Base.ClientID, False);
      end;
    end;
  end; }
  Self.SetCurrentNeighbors;
  Base.SendCreateMob(SPAWN_NORMAL, Self.Base.clientId);
  Self.SetCurrentNeighbors;
  Self.Base.UpdateVisibleList();
  Base.SendCreateMob(SPAWN_TELEPORT, 0, False);

  Self.Base.PranClientID := Servers[Self.ChannelIndex].GetFreePranClientID;
  Servers[Self.ChannelIndex].Prans[Self.Base.PranClientID] := Self.Base.ClientID;

  if (Self.Character.Base.Equip[10].Identific > 0) then
  begin
    //Self.SetCurrentNeighbors;
    // mandar sendtoworld da pran e spawn
    if (Self.Account.Header.Pran1.ItemID = Self.Character.Base.Equip[10]
      .Identific) then
    begin
      Self.SendPranSpawn(0, 0, 0);
      Self.SendPranToWorld(0);
      Self.SetPranPassiveSkill(0, 1);
      Self.SpawnedPran := 0;
      Self.Account.Header.Pran1.IsSpawned := True;
      Self.SetPranEquipAtributes(Self.SpawnedPran, True);
    end;
    if (Self.Account.Header.Pran2.ItemID = Self.Character.Base.Equip[10]
      .Identific) then
    begin
      Self.SendPranSpawn(1, 0, 0);
      Self.SendPranToWorld(1);
      Self.SetPranPassiveSkill(1, 1);
      Self.SpawnedPran := 1;
      Self.Account.Header.Pran2.IsSpawned := True;
      Self.SetPranEquipAtributes(Self.SpawnedPran, True);
    end;
  end;

  if(Self.Base.Character.Equip[8].Index <> 0) then
  begin
    i := Servers[Self.ChannelIndex].GetFreePetClientID;

    if(i = 0) then
    begin
      Self.SendClientMessage('Erro ao spawnar mascote. Contate o suporte.');
    end
    else
    begin
      Randomize;
      Self.Base.CreatePet(NORMAL_PET, Self.Base.Neighbors[RandomRange(0,8)].pos,
        Self.Base.Character.Equip[8].Index);

      Self.SpawnPet(Self.Base.PetClientID);

      for j in Self.Base.VisiblePlayers do
      begin
        Servers[Self.ChannelIndex].Players[j].SpawnPet(Self.Base.PetClientID);
        if not(Servers[Self.ChannelIndex].Players[j].Base.VisibleMobs.Contains(Self.Base.PetClientID)) then
          Servers[Self.ChannelIndex].Players[j].Base.VisibleMobs.Add(Self.Base.PetClientID);
      end;
    end;
  end;


{$REGION ''}

{$ENDREGION}
end;
procedure TPlayer.SendTitleUpdate(TitleIDAcquire: DWORD; TitleIDLeveled: DWORD);
var
  Packet: TUpdateTitleListPacket;
begin
  ZeroMemory(@Packet, sizeof(TUpdateTitleListPacket));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $17D;
  Packet.IDAcquire := TitleIDAcquire;
  Packet.IDLeveled := TitleIDLeveled;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.RefreshPlayerInfos(SendToVisible: Boolean);
var
  Packet: TRefreshPlayerInfosPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $130;
  Packet.Index := Self.Base.clientId;
  Packet.Nation := Self.Character.Base.Nation;
  if Self.Character.Base.GuildIndex > 0 then
  begin
    Packet.GuildIndex := Self.Character.Base.GuildIndex;
    Move(Guilds[Self.Character.GuildSlot].Name, Packet.GuildName, 19);
  end;
  // Packet.MarechalGuildIndex := Self.Character.Base.GuildIndex;
  if SendToVisible then
    Self.Base.SendToVisible(Packet, Packet.Header.size)
  else
    Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SpawnMob(mobid: DWORD; MobIdGen: DWORD);
var
  Packet: TSpawnMobPacket;
begin
  if(Self.SocketClosed) then
    Exit;
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].MobsP
    [MobIdGen].Index;
  Packet.Header.Code := $35E;
  Packet.Equip[0] := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].Equip[0];
  Packet.Equip[1] := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].Equip[1];
  Packet.Equip[6] := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].Equip[6];
  Packet.Position := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].MobsP
    [MobIdGen].CurrentPos;
  Packet.Rotation := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].Rotation;
  Packet.CurHP := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].InitHP;
  Packet.CurMp := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].InitHP;
  Packet.MaxHp := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].MobsP
    [MobIdGen].HP;
  Packet.MaxMP := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].MobsP
    [MobIdGen].MP;
  Packet.Level := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].MobLevel;
  Packet.IsService := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].IsService;
  Packet.SpawnType := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].SpawnType;
  Packet.Altura := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].MobElevation;
  Packet.Tronco := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].Cabeca;
  Packet.Perna := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].Perna;
  Packet.Corpo := 0;
  Packet.MobType := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].MobType;
  Packet.MobName := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].IntName;
  Self.SendPacket(Packet, Packet.Header.size);
  Self.SendPacket(Packet, Packet.Header.size)
end;
procedure TPlayer.SpawnMobGuard(mobid: DWORD; MobIdGen: DWORD);
var
  Packet: TSendCreateMobPacket;
begin
  ZeroMemory(@Packet, sizeof(TSendCreateMobPacket));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].MobsP
    [MobIdGen].Index;
  Packet.Header.Code := $349;
  System.AnsiStrings.StrPLCopy(Packet.Name,
    AnsiString(IntToStr(Servers[Self.ChannelIndex].MOBS.TMobS[mobid].IntName)),
    sizeof(IntToStr(Servers[Self.ChannelIndex].MOBS.TMobS[mobid].IntName)));
  Packet.Equip[0] := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].Equip[0];
  Packet.Equip[1] := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].Equip[1];
  Packet.Equip[6] := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].Equip[6];
  Packet.Position := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].MobsP
    [MobIdGen].CurrentPos;
  Packet.Rotation := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].Rotation;
  Packet.CurHP := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].InitHP;
  Packet.CurMp := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].InitHP;
  Packet.MaxHp := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].MobsP
    [MobIdGen].HP;
  Packet.MaxMP := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].MobsP
    [MobIdGen].MP;
  Packet.IsService := 1;
  Packet.SpawnType := SPAWN_NORMAL;
  Packet.Altura := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].MobElevation;
  Packet.Tronco := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].Cabeca;
  Packet.Perna := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].Perna;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.UnspawnMob(mobid: DWORD; MobIdGen: DWORD);
var
  Packet: TSendRemoveMobPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].MobsP
    [MobIdGen].Index;
  Packet.Header.Code := $101;
  Packet.Index := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].MobsP
    [MobIdGen].Index;
  Packet.DeleteType := 0;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SpawnPet(PetID: WORD);
var
  Packet: TSendCreateMobPacket;
begin
  ZeroMemory(@Packet, sizeof(TSendCreateMobPacket));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Servers[Self.ChannelIndex].PETS[PetID].Base.clientId;
  Packet.Header.Code := $349;
  System.AnsiStrings.StrPLCopy(Packet.Name,
    AnsiString(IntToStr(Servers[Self.ChannelIndex].PETS[PetID].IntName)),
    sizeof(IntToStr(Servers[Self.ChannelIndex].PETS[PetID].IntName)));
  Packet.Equip[0] := Servers[Self.ChannelIndex].PETS[PetID]
    .Base.PlayerCharacter.Base.Equip[0].Index;
  Packet.Equip[1] := Servers[Self.ChannelIndex].PETS[PetID]
    .Base.PlayerCharacter.Base.Equip[1].Index;
  Packet.Position := Servers[Self.ChannelIndex].PETS[PetID]
    .Base.PlayerCharacter.LastPos;
  Packet.Rotation := 0;
  Packet.CurHP := Servers[Self.ChannelIndex].PETS[PetID]
    .Base.PlayerCharacter.Base.CurrentScore.CurHP;
  Packet.CurMp := Servers[Self.ChannelIndex].PETS[PetID]
    .Base.PlayerCharacter.Base.CurrentScore.CurMp;
  Packet.MaxHp := Servers[Self.ChannelIndex].PETS[PetID]
    .Base.PlayerCharacter.Base.CurrentScore.MaxHp;
  Packet.MaxMP := Servers[Self.ChannelIndex].PETS[PetID]
    .Base.PlayerCharacter.Base.CurrentScore.MaxMP;
  Packet.IsService := 0;
  Packet.SpawnType := SPAWN_NORMAL;
  Packet.Altura := Servers[Self.ChannelIndex].PETS[PetID]
    .Base.PlayerCharacter.Base.CurrentScore.Sizes.Altura;
  Packet.Tronco := Servers[Self.ChannelIndex].PETS[PetID]
    .Base.PlayerCharacter.Base.CurrentScore.Sizes.Tronco;
  Packet.Perna := Servers[Self.ChannelIndex].PETS[PetID]
    .Base.PlayerCharacter.Base.CurrentScore.Sizes.Perna;
  Packet.Corpo := Servers[Self.ChannelIndex].PETS[PetID]
    .Base.PlayerCharacter.Base.CurrentScore.Sizes.Corpo;
  System.AnsiStrings.StrPLCopy(Packet.Title,
    Servers[Self.ChannelIndex].Players[Servers[Self.ChannelIndex].PETS[PetID]
    .MasterClientID].Base.Character.Name + #39+'s PET', 32);

  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.UnSpawnPet(PetID: WORD);
var
  Packet: TSendRemoveMobPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Servers[Self.ChannelIndex].PETS[PetID].Base.clientId;
  Packet.Header.Code := $101;
  Packet.Index := Servers[Self.ChannelIndex].PETS[PetID].Base.clientId;
  Packet.DeleteType := 0;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendTeleportPositionsFC();
var
  Packet: TTeleportFcPacket;
  i: Integer;
begin
  if not(Self.Base.GetMobClass = 4) then
    Exit;
  ZeroMemory(@Packet, sizeof(TTeleportFcPacket));
  Packet.Header.size := sizeof(TTeleportFcPacket);
  Packet.Header.Index := Self.Base.ClientId;
  Packet.Header.Code := $34A;
  for i := 0 to 4 do
  begin
    if not(Self.TeleportList[i].IsValid) then
      Continue;
    Packet.Slot := i;
    Packet.PosX := Round(Self.TeleportList[i].X);
    Packet.PosY := Round(Self.TeleportList[i].Y);
    Self.SendPacket(Packet, Packet.Header.size);
  end;
end;
procedure TPlayer.SendPlayerToSavedPosition();
begin
  if ((Self.SavedPos.X = 0) or (Self.SavedPos.Y = 0)) then
  begin
    Self.Teleport(TPosition.Create(3400, 565));
  end
  else
  begin
    Self.Teleport(Self.SavedPos);
  end;
end;
procedure TPlayer.SendPlayerToCityPosition();
begin
  Self.Teleport(TPosition.Create(3400, 565));
end;
procedure TPlayer.DisparosRapidosBarReset(SkillID: DWORD);
var
  Packet: Tp12C;
begin
  ZeroMemory(@Packet, sizeof(Tp12C));
  Packet.Header.size := sizeof(Tp12C);
  Packet.Header.Index := $7535; // era 0
  Packet.Header.Code := $12C;
  Packet.Skills[24] := 300;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.PredadorInvBarReset(SkillID: DWORD);
var
  Packet: Tp12C;
  new_cd: Integer;
begin
  ZeroMemory(@Packet, sizeof(Tp12C));
  Packet.Header.size := sizeof(Tp12C);
  Packet.Header.Index := $7535; // era 0
  Packet.Header.Code := $12C;
  new_cd := 150 - ((150 div 100) * Self.Base.GetMobAbility(EF_COOLTIME));
  Packet.Skills[28] := new_cd;
end;

procedure TPlayer.SendUpdateActiveTitle();
var
  Packet: TUpdateActiveTitlePacket;
begin
  ZeroMemory(@Packet, sizeof(TUpdateActiveTitlePacket));
  Packet.Header.size := sizeof(TUpdateActiveTitlePacket);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $361;
  Packet.TitleIndex := Self.Base.PlayerCharacter.ActiveTitle.Index;
  if (Self.Base.PlayerCharacter.ActiveTitle.Level = 0) then
    Packet.TitleLevel := 0
  else
  begin
    if (Self.Base.PlayerCharacter.ActiveTitle.Level >= 1) then
      Packet.TitleLevel := (Self.Base.PlayerCharacter.ActiveTitle.Level - 1)
    else
      Packet.TitleLevel := 0;
  end;
  Self.Base.SendToVisible(Packet, Packet.Header.size);
end;
procedure TPlayer.SendNationInformation();
var
  Packet: TGuildsGradePacket;
  PacketSiege: TGuildsSiegePacket;
  // PacketAlliance: TAllyanceInfoPacket;
  // PacketNationGold: TUpdateNationTreasure;
  SelfNationID, i: BYTE;
begin
  try
    ZeroMemory(@Packet, sizeof(Packet));
    ZeroMemory(@PacketSiege, sizeof(PacketSiege));
    // ZeroMemory(@PacketAlliance, sizeof(PacketAlliance));
    // ZeroMemory(@PacketNationGold, sizeof(PacketNationGold));
    Packet.Header.size := sizeof(Packet);
    Packet.Header.Index := Self.Base.clientId;
    Packet.Header.Code := $936;
    PacketSiege.Header.size := sizeof(PacketSiege);
    PacketSiege.Header.Index := Self.Base.clientId;
    PacketSiege.Header.Code := $91A;
    // PacketAlliance.Header.size := sizeof(PacketAlliance);
    // PacketAlliance.Header.Index := Self.Base.clientId;
    // PacketAlliance.Header.Code := $967;
    // PacketNationGold.Header.size := sizeof(PacketNationGold);
    // PacketNationGold.Header.Index := Self.Base.clientId;
    // PacketNationGold.Header.Code := $F34;
    if (Self.Character.Base.Nation = 0) then
      SelfNationID := (Servers[Self.ChannelIndex].NationID - 1)
    else
      SelfNationID := Self.Character.Base.Nation - 1;
    Packet.Guilds.LordMarechal := Nations[SelfNationID]
      .Cerco.Defensoras.LordMarechal;
    Packet.Guilds.Estrategista := Nations[SelfNationID]
      .Cerco.Defensoras.Estrategista;
    Packet.Guilds.Juiz := Nations[SelfNationID].Cerco.Defensoras.Juiz;
    Packet.Guilds.Tesoureiro := Nations[SelfNationID]
      .Cerco.Defensoras.Tesoureiro;

    PacketSiege.Defensoras.LordMarechal := Packet.Guilds.LordMarechal;
    PacketSiege.Defensoras.Estrategista := Packet.Guilds.Estrategista;
    PacketSiege.Defensoras.Juiz := Packet.Guilds.Juiz;
    PacketSiege.Defensoras.Tesoureiro := Packet.Guilds.Tesoureiro;

    for I := 0 to 3 do
    begin
      PacketSiege.Atacantes[i].LordMarechal := Nations[SelfNationID].Cerco.Atacantes[i].LordMarechal;
      PacketSiege.Atacantes[i].Estrategista := Nations[SelfNationID].Cerco.Atacantes[i].Estrategista;
      PacketSiege.Atacantes[i].Juiz := Nations[SelfNationID].Cerco.Atacantes[i].Juiz;
      PacketSiege.Atacantes[i].Tesoureiro := Nations[SelfNationID].Cerco.Atacantes[i].Tesoureiro;
    end;
    // PacketAlliance.Nation := Servers[Self.ChannelIndex].NationID;
    // PacketAlliance.NationAlly := Nations[SelfNationID].NationIDAlly;
    // PacketAlliance.AllyDate := Nations[SelfNationID].AllyDate;
    // AnsiStrings.StrPLCopy(PacketAlliance.MarshalAlly,
    // AnsiString(Nations[SelfNationID].MarechalAllyName), 16);
    Packet.GuildsID[0] := Nations[SelfNationID].MarechalGuildID;
    Packet.GuildsID[1] := Nations[SelfNationID].TacticianGuildID;
    Packet.GuildsID[2] := Nations[SelfNationID].JudgeGuildID;
    Packet.GuildsID[3] := Nations[SelfNationID].TreasurerGuildID;
    Packet.Nation := SelfNationID + 1;
    Packet.RegisterBonus := Nations[SelfNationID].Settlement;
    Packet.CitizenTax := Nations[SelfNationID].CitizenTax;
    Packet.NoCitizenTax := Nations[SelfNationID].VisitorTax;
    // a aba de nacao aliada nao funciona, mas isso aq funciona
    Packet.NationAlly := 0; // Nations[SelfNationID].NationIDAlly;
    Packet.AllyanceDate := Nations[SelfNationID].AllyDate;
    AnsiStrings.StrPLCopy(Packet.MarshalAlly,
      String(AnsiString(Nations[SelfNationID].MarechalAllyName)), 16);
    Packet.RankNation := Nations[SelfNationID].NationRank;
    // Packet.Estabilization := 100;
    // PacketNationGold.Gold := Nations[SelfNationID].NationGold;
    Self.SendPacket(Packet, Packet.Header.size);
    Self.SendPacket(PacketSiege, PacketSiege.Header.size);
    // Self.SendPacket(PacketAlliance, PacketAlliance.Header.size);
    // Self.SendPacket(PacketNationGold, PacketNationGold.Header.size);
    if (Self.IsMarshal) then
    begin
      if not(Self.Base.BuffExistsByID(6600)) then
        Self.Base.AddBuff(6600);
    end
    else
    begin
      if(Self.Base.BuffExistsByID(6600)) then
        Self.Base.RemoveBuff(6600);
    end;
    if (Self.IsArchon) then
    begin
      if not(Self.Base.BuffExistsByID(ARCHON_BUFF)) then
        Self.Base.AddBuff(ARCHON_BUFF);
    end
    else
    begin
      if(Self.Base.BuffExistsByID(ARCHON_BUFF)) then
        Self.Base.RemoveBuff(ARCHON_BUFF);
    end;
    if (Self.IsGradeMarshal) then
    begin
      if not(Self.IsMarshal) then
        if not(Self.Base.BuffExistsByID(6601)) then
          Self.Base.AddBuff(6601);
    end
    else
    begin
      if(Self.Base.BuffExistsByID(6601)) then
        Self.Base.RemoveBuff(6601);
    end;
    if (Self.IsGradeArchon) then
    begin
      if not(Self.IsArchon) then
        if not(Self.Base.BuffExistsByID(CAVALEIROS_ARCHON)) then
          Self.Base.AddBuff(CAVALEIROS_ARCHON);
    end
    else
    begin
      if(Self.Base.BuffExistsByID(CAVALEIROS_ARCHON)) then
        Self.Base.RemoveBuff(CAVALEIROS_ARCHON);
    end;
  except
    on E: Exception do
    begin
      Logger.Write('Error LM Buffs ' + E.Message, TlogType.Warnings);
    end;
  end;
end;
function TPlayer.GetPranEvolutedCnt(): Integer;
var
  SQLComp: TQuery;
begin
  Result := -1;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GetPranEvolutedCnt]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetPranEvolutedCnt]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    SQLComp.SetQuery
      (format('SELECT pranevcnt FROM characters WHERE id=%d',
      [Self.Character.Index]));
    SQLComp.Run();
    if (SQLComp.Query.RecordCount > 0) then
    begin
      Result := SQLComp.Query.FieldByName('pranevcnt').AsInteger;
    end
    else
    begin
      Self.SendClientMessage
        ('Erro de personagem, procure o suporte. TPlayer.GetPranEvolutedCnt 0x01');
      SQLComp.Destroy;
      Exit;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('TPlayer.GetPranEvolutedCnt ' + E.Message, TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
  end;
  SQLComp.Destroy;
end;
function TPlayer.SetPranEvolutedCnt(Cnt: Integer): Boolean;
var
  SQLComp: TQuery;
begin
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SetPranEvolutedCnt]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SetPranEvolutedCnt]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  SQLComp.Query.Connection.StartTransaction;
  try
    SQLComp.SetQuery
      (format('UPDATE characters SET pranevcnt=%d WHERE id=%d',
      [Cnt, Self.Character.Index]));
    SQLComp.Run(False);
    SQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('TPlayer.SetPranEvolutedCnt ' + E.Message, TlogType.Error);
      SQLComp.Query.Connection.Rollback;
      SQLComp.Destroy;
      Exit;
    end;
  end;
  SQLComp.Destroy;
end;
function TPlayer.GetPranClass(xPran: PPran): Byte;
begin
  Result := 255;
  case xPran.ClassPran of
    61..64:
      Result := 1;
    71..74:
      Result := 2;
    81..84:
      Result := 3;
  end;
end;
procedure TPlayer.SendCloseClient();
var
  Packet: TSignalData;
begin
  ZeroMemory(@Packet, sizeof(TSignalData));
  Packet.Header.size := sizeof(TSignalData);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $358;
  Packet.Data := 1;
  Self.SendPacket(Packet, Packet.Header.size);
end;
{$REGION 'Unk Sends'}
procedure TPlayer.SendNumbers;
var
  Packet: TSendNumbersPacket;
  i: Integer;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $D41;
  Packet.AccountId := Self.Account.Header.AccountId;
  for i := 0 to Length(Packet.Numbers) - 1 do
  begin
    Packet.Numbers[i].Index := i;
  end;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendClientIndex;
var
  Packet: TSendClientIndexPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $117;
  Packet.Index := Self.Base.clientId;
  // Packet.Effect := Self.Base.clientId;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendP12C;
var
  Packet: Tp12C;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $12C;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendP131;
var
  Packet: Tp131;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $131;
  Packet.Unk_1 := $FFFFFFFF;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendP16F;
var
  Packet: TUpdateBuffPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $16F;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendP186;
var
  Packet: Tp186;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $186;
  Packet.Unk_0 := $1;
  // Packet.Unk_2 := $1;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendP227;
var
  Packet: Tp227;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $227;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendP33D;
var
  Packet: Tp33D;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $33D;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendP357;
var
  Packet: Tp357;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $357;
  Packet.Null1 := $2082;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendP3A2;
var
  Packet: Tp3A2;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $3A2;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendP94C;
var
  Packet: Tp94C;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $94C;
  Self.SendPacket(Packet, Packet.Header.size);
end;
{$ENDREGION}
{$REGION 'Cash'}
procedure TPlayer.SendPlayerCash;
begin
  Self.SendData(0, $139, Self.Account.Header.CashInventory.Cash);
end;
procedure TPlayer.SendCashInventory;
var
  Packet: TUpdateCashInventory;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $138;
  Move(Self.Account.Header.CashInventory.Items, Packet.Items,
    sizeof(Packet.Items));
  Self.SendPacket(Packet, Packet.Header.size);
end;
{$ENDREGION}
procedure TPlayer.SendCancelCollectItem(Index: Integer);
var
  Packet: TCancelCollectItem;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.Size := sizeof(Packet);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $33A;
  Packet.Index := Index;
  Self.SendPacket(Packet, Packet.Header.Size);
end;
{$ENDREGION}
{$REGION 'Trade'}
procedure TPlayer.RefreshTrade;
var
  Packet: TTradePacket;
begin
  ZeroMemory(@Packet, sizeof(TTradePacket));
  Packet.Header.size := sizeof(TTradePacket);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $317;
  Move(Self.Character.Trade, Packet.Trade, sizeof(TTrade));
  Packet.Trade.OtherClientid := Self.Character.TradingWith;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.RefreshTradeTo(clientId: Integer);
var
  Packet: TTradePacket;
begin
  ZeroMemory(@Packet, sizeof(TTradePacket));
  Packet.Header.size := sizeof(TTradePacket);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $317;
  Move(Self.Character.Trade, Packet.Trade, sizeof(TTrade));
  Packet.Trade.OtherClientid := Self.Base.clientId;
  Servers[Self.ChannelIndex].Players[clientId].SendPacket(Packet,
    Packet.Header.size);
end;
procedure TPlayer.CloseTrade;
begin
  Self.Character.TradingWith := 0;
  Self.SendData(Self.Base.clientId, $318, 0);
end;
{$ENDREGION}
{$REGION 'Party'}
procedure TPlayer.SendToParty(var Packet; size: WORD; SendSelf: Boolean);
begin
  if (Self.PartyIndex = 0) then
  begin
    Exit;
  end;
  Self.Party := @Servers[Self.ChannelIndex].Parties[Self.PartyIndex];
  Self.Party.SendToParty(Packet, size);
end;
procedure TPlayer.RefreshParty;
var
  Packet: TUpdatePartyPacket;
  i, J, k, m, n: Integer;
  CurPlayer: PPlayer;
  OtherParty, LeaderParty, stParty: PParty;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  if not(Self.PartyIndex = 0) then
  begin
    Self.Party := @Servers[Self.ChannelIndex].Parties[PartyIndex];
  end;
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $326;
  if (Self.PartyIndex = 0) then
  begin
    Self.SendPacket(Packet, Packet.Header.size);
    for I := 1 to 3 do
    begin
      Packet.PartyInRaidIndex := i;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
    Exit;
  end;
  J := 0;
  for i in Self.Party.Members do
  begin
    CurPlayer := @Servers[Self.ChannelIndex].Players[i];
    AnsiStrings.StrLCopy(Packet.Name[J], CurPlayer.Character.Base.Name, 16);
    Packet.PlayerIndex[J] := CurPlayer.Base.clientId;
    Packet.ClassInfo[J] := CurPlayer.Character.Base.ClassInfo;
    Packet.Level[J] := CurPlayer.Character.Base.Level - 1;
    Packet.CurHP[J] := CurPlayer.Base.Character.CurrentScore.CurHP;
    Packet.MaxHp[J] := CurPlayer.Base.GetCurrentHP;
    Packet.CurMp[J] := CurPlayer.Base.Character.CurrentScore.CurMp;
    Packet.MaxMP[J] := CurPlayer.Base.GetCurrentMP;
    Packet.LeaderIndex := Self.Party.Leader;
    Inc(J);

    //if not(i = Self.Base.ClientID) then
      //CurPlayer.SendPositionParty(Self.Base.ClientID);
  end;
  Packet.itemallocate := Self.Party.itemalocate;
  Packet.expallocate := Self.Party.expalocate;
  if not(Party.InRaid) then
  begin
    Packet.PartyInRaidIndex := 0;
    Packet.IsPartyLeaderOfRaid := 1;//Byte(Self.Party.IsRaidLeader.ToInteger);
    Self.SendPacket(Packet, Packet.Header.size);
    ZeroMemory(@Packet, sizeof(Packet));
    Packet.Header.size := sizeof(Packet);
    Packet.Header.Index := Self.Base.clientId;
    Packet.Header.Code := $326;
    for I := 1 to 3 do
    begin
      Packet.PartyInRaidIndex := i;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end
  else
  begin
    Packet.PartyInRaidIndex := 0;
    Packet.IsPartyLeaderOfRaid := Byte(Self.Party.IsRaidLeader.ToInteger);
    Self.SendPacket(Packet, Packet.Header.size);
    if(Self.Party.PartyRaidCount = 1) then
    begin
      Self.Party.InRaid := False;
      Self.Party.IsRaidLeader := True;
    end;
    for k := 1 to 3 do
    begin
      ZeroMemory(@Packet, sizeof(Packet));
      Packet.Header.size := sizeof(Packet);
      Packet.Header.Index := Self.Base.clientId;
      Packet.Header.Code := $326;
      if(Self.Party.InRaid = False) then
      begin
        Packet.PartyInRaidIndex := k;
        Self.SendPacket(Packet, Packet.Header.size);
        Continue;
      end;
      if(Party.PartyAllied[k] = 0) then
      begin
        Packet.PartyInRaidIndex := k;
        Self.SendPacket(Packet, Packet.Header.size);
        Continue;
      end;
      OtherParty := @Servers[Self.ChannelIndex].Parties[Party.PartyAllied[k]];
      J := 0;
      for i in OtherParty.Members do
      begin
        CurPlayer := @Servers[Self.ChannelIndex].Players[i];
        AnsiStrings.StrLCopy(Packet.Name[J], CurPlayer.Character.Base.Name, 16);
        Packet.PlayerIndex[J] := CurPlayer.Base.clientId;
        Packet.ClassInfo[J] := CurPlayer.Character.Base.ClassInfo;
        Packet.Level[J] := CurPlayer.Character.Base.Level - 1;
        Packet.CurHP[J] := CurPlayer.Base.Character.CurrentScore.CurHP;
        Packet.MaxHp[J] := CurPlayer.Base.GetCurrentHP;
        Packet.CurMp[J] := CurPlayer.Base.Character.CurrentScore.CurMp;
        Packet.MaxMP[J] := CurPlayer.Base.GetCurrentMP;
        Packet.LeaderIndex := OtherParty.Leader;
        Inc(J);

        //if not(i = CurPlayer.Base.ClientID) then
          //CurPlayer.SendPositionParty(i);

        {}
      end;

      Packet.itemallocate := OtherParty.itemalocate;
      Packet.expallocate := OtherParty.expalocate;
      Packet.PartyInRaidIndex := k;
      Packet.IsPartyLeaderOfRaid := Byte(OtherParty.IsRaidLeader.ToInteger);
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;
end;
function TPlayer.AddMemberParty(PlayerIndex: WORD): Boolean;
begin
  Result := FALSE;
  if (Self.PartyIndex = 0) then
    Exit;
  Result := Servers[Self.ChannelIndex].Parties[Self.PartyIndex]
    .AddMember(PlayerIndex);
end;
procedure TPlayer.SendPositionParty(SendTo: WORD = 0);
var
  Packet: TPartyMemberCoordPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $11D;
  Packet.Index := Self.Base.clientId;
  Packet.PosX := Round(Self.Base.PlayerCharacter.LastPos.X);
  Packet.PosY := Round(Self.Base.PlayerCharacter.LastPos.Y);
  if (SendTo = 0) then
  begin
    Self.SendPacket(Packet, Packet.Header.size);
    Exit;
  end;
  Servers[Self.ChannelIndex].SendPacketTo(SendTo, Packet, Packet.Header.size);
end;
{$ENDREGION}
{$REGION 'Char info'}
procedure TPlayer.CharInfoResponse(Index: WORD);
var
  Packet: TCharInfoResponsePacket;
  FPlayer: PPlayer;
  //FCharacter: PCharacter;
begin
  if(Servers[Self.ChannelIndex].Players[Index].SocketClosed) then
    Exit;
  ZeroMemory(@Packet, sizeof(Packet));
  FPlayer := @Servers[Self.ChannelIndex].Players[Index];
  //FCharacter := @Servers[Self.ChannelIndex].Players[Index]
    //.Base.PlayerCharacter.Base;
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $19E;
  System.AnsiStrings.StrPLCopy(Packet.Nick, FPlayer.Base.Character.Name, 16);
  if ((FPlayer.Base.Character.GuildIndex > 0) and (FPlayer.Base.PlayerCharacter.GuildSlot > 0)) then
  begin
    System.AnsiStrings.StrPLCopy(Packet.GuildName,
      Guilds[FPlayer^.Base.PlayerCharacter.GuildSlot].Name, 19);
  end
  else
    Packet.GuildName := 'Nenhuma';
  // FPlayer.Base.GetCurrentScore;
  Packet.Classe := FPlayer.Base.Character.ClassInfo;
  //Packet.Nação := FCharacter^.Nation; apaguei como teste
  Packet.Nacao := FPlayer.Base.Character.Nation; //Character^.Nation * 4096
  Packet.Infamia := FPlayer.Base.PlayerCharacter.Base.CurrentScore.Infamia;
  Packet.Honra := FPlayer.Base.PlayerCharacter.Base.CurrentScore.Honor;
  Packet.Pvp := FPlayer.Base.PlayerCharacter.Base.CurrentScore.KillPoint;
  Packet.Str := FPlayer.Base.PlayerCharacter.Base.CurrentScore.Str;
  Packet.Agi := FPlayer.Base.PlayerCharacter.Base.CurrentScore.agility;
  Packet.Int := FPlayer.Base.PlayerCharacter.Base.CurrentScore.Int;
  Packet.Cons := FPlayer.Base.PlayerCharacter.Base.CurrentScore.Cons;
  Packet.Sorte := FPlayer.Base.PlayerCharacter.Base.CurrentScore.Luck;
  Packet.Status := FPlayer.Base.PlayerCharacter.Base.CurrentScore.Status;
  Packet.Critico := FPlayer.Base.PlayerCharacter.Base.CurrentScore.Critical;
  Packet.Esquiva := FPlayer.Base.PlayerCharacter.Base.CurrentScore.Esquiva;
  Packet.Acerto := FPlayer.Base.PlayerCharacter.Base.CurrentScore.Acerto;
  Packet.AtkFis := FPlayer.Base.PlayerCharacter.Base.CurrentScore.DNFis;
  Packet.DefFis := FPlayer.Base.PlayerCharacter.Base.CurrentScore.DefFis;
  Packet.AtkMag := FPlayer.Base.PlayerCharacter.Base.CurrentScore.DNMag;
  Packet.DefMag := FPlayer.Base.PlayerCharacter.Base.CurrentScore.DefMag;
  Packet.Movimento := FPlayer.Base.PlayerCharacter.SpeedMove;
  Packet.Resistencia := FPlayer.Base.PlayerCharacter.Resistence;
  Packet.AtkDuplo := FPlayer.Base.PlayerCharacter.DuploAtk;
  Packet.Exp := FPlayer.Base.Character.Exp;
  Packet.BonusDMG := FPlayer.Base.PlayerCharacter.Base.CurrentScore.BonusDMG;
  if not(FPlayer.Base.Character.Level = 0) then
    Packet.Level := FPlayer.Base.Character.Level - 1;
  Move(FPlayer.Base.Character.Equip, Packet.Equips, (sizeof(TItem) * 9));
  Packet.Equips2[11] := FPlayer.Base.Character.Equip[11];
  Packet.Equips2[12] := FPlayer.Base.Character.Equip[12];
  Packet.Equips2[13] := FPlayer.Base.Character.Equip[13];
  Packet.Equips2[14] := FPlayer.Base.Character.Equip[14];
  Packet.Equips2[15] := FPlayer.Base.Character.Equip[15];
  if(FPlayer.Base.Character.Equip[9].Index <> 0) then
  begin //se tiver montaria
    Packet.MountEquip.Index := FPlayer.Base.Character.Equip[9].Index;
    Packet.MountEquip.APP := Packet.MountEquip.Index;
    Packet.MountEquip.Identific := FPlayer.Base.Character.Equip[9].Identific;
    Packet.MountEquip.Slot1 := FPlayer.Base.Character.Equip[9].Effects.Index[0];
    Packet.MountEquip.Slot2 := FPlayer.Base.Character.Equip[9].Effects.Index[1];
    Packet.MountEquip.Slot3 := FPlayer.Base.Character.Equip[9].Effects.Index[2];
    Packet.MountEquip.Enc1 := FPlayer.Base.Character.Equip[9].Effects.Value[0];
    Packet.MountEquip.Enc2 := FPlayer.Base.Character.Equip[9].Effects.Value[1];
    Packet.MountEquip.Enc3 := FPlayer.Base.Character.Equip[9].Effects.Value[2];
    Packet.MountEquip.MIN := FPlayer.Base.Character.Equip[9].MIN;
    Packet.MountEquip.Time := FPlayer.Base.Character.Equip[9].Time;
  end;
  case (FPlayer.SpawnedPran) of
    0:
      begin
        System.AnsiStrings.StrPLCopy(Packet.PranName,
          FPlayer.Account.Header.Pran1.Name, 16);
        Packet.PranEquip.Index := FPlayer.Base.Character.Equip[10].Index;
        Packet.PranEquip.APP := FPlayer.Base.Character.Equip[10].APP;
        Packet.PranEquip.Identific := FPlayer.Base.Character.Equip[10].Identific;
        Packet.PranEquip.CreationTime := FPlayer.Account.Header.Pran1.CreatedAt;
        Packet.PranEquip.Devotion := FPlayer.Account.Header.Pran1.Food;
        Packet.PranEquip.State := 00;
        Packet.PranEquip.Level := FPlayer.Account.Header.Pran1.Level;
      end;
    1:
      begin
        System.AnsiStrings.StrPLCopy(Packet.PranName,
          FPlayer.Account.Header.Pran2.Name, 16);
        Packet.PranEquip.Index := FPlayer.Base.Character.Equip[10].Index;
        Packet.PranEquip.APP := FPlayer.Base.Character.Equip[10].APP;
        Packet.PranEquip.Identific := FPlayer.Base.Character.Equip[10].Identific;
        Packet.PranEquip.CreationTime := FPlayer.Account.Header.Pran2.CreatedAt;
        Packet.PranEquip.Devotion := FPlayer.Account.Header.Pran2.Food;
        Packet.PranEquip.State := 00;
        Packet.PranEquip.Level := FPlayer.Account.Header.Pran2.Level;
      end;
  end;
  Self.SendPacket(Packet, Packet.Header.size);
end;
{$ENDREGION}
{$REGION 'Player Add Functions'}
function TPlayer.AddExp(Value: Int64; out ExpPreReliq: Integer; ExpType: Integer = 0): Int64;
var
  NewExp: Int64;
begin
  Result := 0;
  case ExpType of
    EXP_TYPE_NORMAL:
      begin
        Inc(Self.Character.Base.Exp, Value);
        Result := Value;
      end;
    EXP_TYPE_MOB:
      begin // skillindex 251
        NewExp := Value * (EXP_MULTIPLIER);
        if (Self.Base.GetMobAbility(EF_MULTIPLE_EXP4) > 0) then
          NewExp := NewExp * 4
        else
        if (Self.Base.GetMobAbility(EF_PREMIUM_PER_EXP) > 0) then
          NewExp := NewExp * 2;

        ExpPreReliq := NewExp;

        if((Servers[Self.ChannelIndex].ReliqEffect[
          EF_RELIQUE_PER_EXP] > 0) and (NewExp > 0)) then
          Inc(NewExp, Servers[Self.ChannelIndex].ReliqEffect[
            EF_RELIQUE_PER_EXP] * (NewExp div 100));

        Inc(Self.Character.Base.Exp, NewExp);
        Result := NewExp;
      end;
    EXP_TYPE_QUEST:
      begin
        // Verifica se tem o buff do double Quest e multiplica;
      end;
  end;
  while (Self.Character.Base.Exp > ExpList[Self.Character.Base.Level]) and
    (Self.Character.Base.Level < LEVEL_CAP) do
    Self.AddLevel;
  if (Self.Character.Base.Level = LEVEL_CAP) and
    (Self.Character.Base.Exp > ExpList[Self.Character.Base.Level]) then
    Self.Character.Base.Exp := ExpList[Self.Character.Base.Level];
  Self.Base.SendRefreshLevel;
end;
procedure TPlayer.AddExpPerc(Value: WORD);
var
  Perc: Single;
  Exp: Int64;
  DifLevel: Int64;
begin
  Perc := Value / 1000;
  if (Self.Character.Base.Level = 90) then
  begin
    Exit;
  end;
  DifLevel := ExpList[Self.Character.Base.Level] -
    ExpList[Self.Character.Base.Level - 1];
  Exp := Round(DifLevel * Perc);
  Inc(Self.Character.Base.Exp, Exp);
  while (Self.Character.Base.Exp > ExpList[Self.Character.Base.Level]) and
    (Self.Character.Base.Level < LEVEL_CAP) do
    Self.AddLevel;
  if (Self.Character.Base.Level = LEVEL_CAP) and
    (Self.Character.Base.Exp > ExpList[Self.Character.Base.Level]) then
    Self.Character.Base.Exp := ExpList[Self.Character.Base.Level];
  Self.Base.SendRefreshLevel;
end;
procedure TPlayer.AddLevel(Value: WORD = 1);
begin
  if (Self.Character.Base.Level = LEVEL_CAP) then
    Exit;
  if (Self.Character.Base.Level <= 50) and
    (Self.Character.Base.Level + Value >= 51) then
  begin
    Inc(Self.Character.Base.ClassInfo);
  end;
  Inc(Self.Character.Base.Level, Value);
  Inc(Self.Character.Base.CurrentScore.SkillPoint, SKILL_POINT_PER_LEVEL);
  if (Self.Character.Base.Level > 50) then
  begin
    Inc(Self.Character.Base.CurrentScore.Status, STATUS_POINT_PER_LEVEL);
    if (Self.Character.Base.Level = 51) then
    begin
      Inc(Self.Character.Base.CurrentScore.SkillPoint, SKILL_POINT_X);
      Inc(Self.Character.Base.CurrentScore.Status, STATUS_POINT_X);
    end;
    if (Self.Character.Base.Level = 61) then
    begin
      Inc(Self.Character.Base.CurrentScore.SkillPoint, SKILL_POINT_X);
      Inc(Self.Character.Base.CurrentScore.Status, STATUS_POINT_X);
    end;
    if (Self.Character.Base.Level = 71) then
    begin
      Inc(Self.Character.Base.CurrentScore.SkillPoint, SKILL_POINT_X);
      Inc(Self.Character.Base.CurrentScore.Status, STATUS_POINT_X);
    end;
    if (Self.Character.Base.Level = 81) then
    begin
      Inc(Self.Character.Base.CurrentScore.SkillPoint, SKILL_POINT_X);
      Inc(Self.Character.Base.CurrentScore.Status, STATUS_POINT_X);
    end;
  end;
  Self.Base.Character.CurrentScore.CurHP :=
    Self.Base.Character.CurrentScore.MaxHp;
  Self.Base.Character.CurrentScore.CurMP :=
    Self.Base.Character.CurrentScore.MaxMp;

  {if(Self.Character.Base.Level = 45) then
  begin
    //CAIXA PRE TESTE, APAGAR APÓS BETA
    TItemFunctions.PutItemOnEventByCharIndex(Self, Self.Character.Base.CharIndex,
      5250);
    Self.SendClientMessage('Aperte T. Voc?recebeu um item de Evento.');
  end;}

  Self.Base.SendCurrentHPMP(True);
  Self.Base.SendRefreshLevel;
  Self.Base.SendRefreshPoint;
  if (Self.PartyIndex > 0) then
    Servers[Self.ChannelIndex].Parties[PartyIndex].RefreshParty;
  Self.SendEffect(1);
  Self.RefreshMeToFriends;
  if Self.Character.Base.GuildIndex > 0 then
    Guilds[Self.Character.Base.GuildIndex].UpdateLevel(Self.Base.Character.CharIndex,
      Self.Base.Character.Level - 1);
end;
procedure TPlayer.AddPranExp(PranSlot: BYTE; Value: DWORD);
begin
  case PranSlot of
    0:
      begin
        Inc(Self.Account.Header.Pran1.Exp, Value);
        while (Self.Account.Header.Pran1.Exp > PranExpList
          [Self.Account.Header.Pran1.Level + 1]) and
          (Self.Account.Header.Pran1.Level + 1 < MAX_PRAN_LEVEL) do
          Self.AddPranLevel(0);
        if (Self.Account.Header.Pran1.Level + 1 = MAX_PRAN_LEVEL) and
          (Self.Account.Header.Pran1.Exp > PranExpList
          [Self.Account.Header.Pran1.Level + 1]) then
          Self.Account.Header.Pran1.Exp :=
            PranExpList[Self.Account.Header.Pran1.Level + 1];
        Self.SendPranLevelAndExp((Self.Account.Header.Pran1.Level + 1),
          Self.Account.Header.Pran1.Exp);
        // mandar aqui o sendrefreshpranexp
      end;
    1:
      begin
        Inc(Self.Account.Header.Pran2.Exp, Value);
        while (Self.Account.Header.Pran2.Exp > PranExpList
          [Self.Account.Header.Pran2.Level + 1]) and
          (Self.Account.Header.Pran2.Level + 1 < MAX_PRAN_LEVEL) do
          Self.AddPranLevel(1);
        if (Self.Account.Header.Pran2.Level + 1 = MAX_PRAN_LEVEL) and
          (Self.Account.Header.Pran2.Exp > PranExpList
          [Self.Account.Header.Pran2.Level + 1]) then
          Self.Account.Header.Pran2.Exp :=
            PranExpList[Self.Account.Header.Pran2.Level + 1];
        Self.SendPranLevelAndExp((Self.Account.Header.Pran2.Level + 1),
          Self.Account.Header.Pran2.Exp);
        // mandar aqui o sendrefreshpranexp
      end;
  end;
end;
function TPlayer.PranBarExistsIndex(PranID: Byte; Index: DWORD): Byte;
var
  i: Integer;
begin
  Result := 255;
  case PranID of
    0:
      begin
        for I := 0 to 2 do
        begin
          if(Self.Account.Header.Pran1.ItemBar[i] = Index) then
          begin
            Result := i;
            break;
          end;
        end;
      end;
    1:
      begin
        for I := 0 to 2 do
        begin
          if(Self.Account.Header.Pran2.ItemBar[i] = Index) then
          begin
            Result := i;
            break;
          end;
        end;
      end;
  end;
end;
procedure TPlayer.AddPranLevel(PranSlot: BYTE; Value: WORD);
 var
 i: Integer;
 helper: Integer;
 baseSkillPran: WORD;
begin
  case PranSlot of
    0:
      begin
        if (Self.Account.Header.Pran1.Level = MAX_PRAN_LEVEL) then
          Exit;
        Inc(Self.Account.Header.Pran1.Level);
        Self.SendClientMessage('Sua pran subiu de nível.');
        Self.SendPranLevelAndExp((Self.Account.Header.Pran1.Level + 1),
          Self.Account.Header.Pran1.Exp);
        Inc(Self.Account.Header.Pran1.MaxHp, PRAN_HP_INC_PER_LEVEL);
        Inc(Self.Account.Header.Pran1.MaxMP, PRAN_MP_INC_PER_LEVEL);
        Self.Account.Header.Pran1.CurHP := Self.Account.Header.Pran1.MaxHp;
        Self.Account.Header.Pran1.CurMp := Self.Account.Header.Pran1.MaxMP;
        Self.SetPranPassiveSkill(0, 0);
        case (Self.Account.Header.Pran1.Level + 1) of
          5:
            begin
              Inc(Self.Account.Header.Pran1.Skills[0].Level);
              Inc(Self.Account.Header.Pran1.Skills[1].Level);
              Inc(Self.Account.Header.Pran1.Skills[2].Level);
              {for I := 0 to 2 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran1.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran1.Skills[i].Index :=
                    Self.Account.Header.Pran1.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran1.Skills[i].Index);
                end;
              end; }
              // [3] e transformacao
            end;
          10:
            begin
              Inc(Self.Account.Header.Pran1.Skills[0].Level);
              Inc(Self.Account.Header.Pran1.Skills[1].Level);
              Inc(Self.Account.Header.Pran1.Skills[2].Level);
              Inc(Self.Account.Header.Pran1.Skills[4].Level);
              {for I := 0 to 4 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran1.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran1.Skills[i].Index :=
                    Self.Account.Header.Pran1.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran1.Skills[i].Index);
                end;
              end;}
            end;
          15:
            begin
              Inc(Self.Account.Header.Pran1.Skills[0].Level);
              Inc(Self.Account.Header.Pran1.Skills[1].Level);
              Inc(Self.Account.Header.Pran1.Skills[2].Level);
              Inc(Self.Account.Header.Pran1.Skills[4].Level);
              Inc(Self.Account.Header.Pran1.Skills[5].Level);
              {for I := 0 to 5 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran1.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran1.Skills[i].Index :=
                    Self.Account.Header.Pran1.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran1.Skills[i].Index);
                end;
              end;}
            end;
          20:
            begin
              Inc(Self.Account.Header.Pran1.Skills[0].Level);
              Inc(Self.Account.Header.Pran1.Skills[1].Level);
              Inc(Self.Account.Header.Pran1.Skills[2].Level);
              Inc(Self.Account.Header.Pran1.Skills[4].Level);
              Inc(Self.Account.Header.Pran1.Skills[5].Level);
              Inc(Self.Account.Header.Pran1.Skills[6].Level);
              {for I := 0 to 6 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran1.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran1.Skills[i].Index :=
                    Self.Account.Header.Pran1.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran1.Skills[i].Index);
                end;
              end;}
            end;
          25:
            begin
              Inc(Self.Account.Header.Pran1.Skills[0].Level);
              Inc(Self.Account.Header.Pran1.Skills[1].Level);
              Inc(Self.Account.Header.Pran1.Skills[2].Level);
              Inc(Self.Account.Header.Pran1.Skills[4].Level);
              Inc(Self.Account.Header.Pran1.Skills[5].Level);
              Inc(Self.Account.Header.Pran1.Skills[6].Level);
              Inc(Self.Account.Header.Pran1.Skills[7].Level);
              {for I := 0 to 7 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran1.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran1.Skills[i].Index :=
                    Self.Account.Header.Pran1.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran1.Skills[i].Index);
                end;
              end; }
            end;
          30:
            begin
              Inc(Self.Account.Header.Pran1.Skills[0].Level);
              Inc(Self.Account.Header.Pran1.Skills[1].Level);
              Inc(Self.Account.Header.Pran1.Skills[2].Level);
              Inc(Self.Account.Header.Pran1.Skills[4].Level);
              Inc(Self.Account.Header.Pran1.Skills[5].Level);
              Inc(Self.Account.Header.Pran1.Skills[6].Level);
              Inc(Self.Account.Header.Pran1.Skills[7].Level);
              Inc(Self.Account.Header.Pran1.Skills[8].Level);
              {for I := 0 to 8 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran1.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran1.Skills[i].Index :=
                    Self.Account.Header.Pran1.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran1.Skills[i].Index);
                end;
              end;}
            end;
          35:
            begin
              Inc(Self.Account.Header.Pran1.Skills[0].Level);
              Inc(Self.Account.Header.Pran1.Skills[1].Level);
              Inc(Self.Account.Header.Pran1.Skills[2].Level);
              Inc(Self.Account.Header.Pran1.Skills[4].Level);
              Inc(Self.Account.Header.Pran1.Skills[5].Level);
              Inc(Self.Account.Header.Pran1.Skills[6].Level);
              Inc(Self.Account.Header.Pran1.Skills[7].Level);
              Inc(Self.Account.Header.Pran1.Skills[8].Level);
              Inc(Self.Account.Header.Pran1.Skills[9].Level);
              {for I := 0 to 9 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran1.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran1.Skills[i].Index :=
                    Self.Account.Header.Pran1.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran1.Skills[i].Index);
                end;
              end;}
            end;
          40:
            begin
              Inc(Self.Account.Header.Pran1.Skills[0].Level);
              Inc(Self.Account.Header.Pran1.Skills[1].Level);
              Inc(Self.Account.Header.Pran1.Skills[2].Level);
              Inc(Self.Account.Header.Pran1.Skills[4].Level);
              Inc(Self.Account.Header.Pran1.Skills[5].Level);
              Inc(Self.Account.Header.Pran1.Skills[6].Level);
              Inc(Self.Account.Header.Pran1.Skills[7].Level);
              Inc(Self.Account.Header.Pran1.Skills[8].Level);
              Inc(Self.Account.Header.Pran1.Skills[9].Level);
              {for I := 0 to 9 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran1.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran1.Skills[i].Index :=
                    Self.Account.Header.Pran1.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran1.Skills[i].Index);
                end;
              end;}
            end;
          45:
            begin
              Inc(Self.Account.Header.Pran1.Skills[0].Level);
              Inc(Self.Account.Header.Pran1.Skills[1].Level);
              Inc(Self.Account.Header.Pran1.Skills[2].Level);
              Inc(Self.Account.Header.Pran1.Skills[4].Level);
              Inc(Self.Account.Header.Pran1.Skills[5].Level);
              Inc(Self.Account.Header.Pran1.Skills[6].Level);
              Inc(Self.Account.Header.Pran1.Skills[7].Level);
              Inc(Self.Account.Header.Pran1.Skills[8].Level);
              Inc(Self.Account.Header.Pran1.Skills[9].Level);
              {for I := 0 to 9 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran1.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran1.Skills[i].Index :=
                    Self.Account.Header.Pran1.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran1.Skills[i].Index);
                end;
              end;}
            end;
          50:
            begin
              Inc(Self.Account.Header.Pran1.Skills[1].Level);
              Inc(Self.Account.Header.Pran1.Skills[2].Level);
              Inc(Self.Account.Header.Pran1.Skills[4].Level);
              Inc(Self.Account.Header.Pran1.Skills[5].Level);
              Inc(Self.Account.Header.Pran1.Skills[6].Level);
              Inc(Self.Account.Header.Pran1.Skills[7].Level);
              Inc(Self.Account.Header.Pran1.Skills[8].Level);
              Inc(Self.Account.Header.Pran1.Skills[9].Level);
              {for I := 1 to 9 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran1.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran1.Skills[i].Index :=
                    Self.Account.Header.Pran1.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran1.Skills[i].Index);
                end;
              end;}
            end;
          55:
            begin
              Inc(Self.Account.Header.Pran1.Skills[2].Level);
              Inc(Self.Account.Header.Pran1.Skills[4].Level);
              Inc(Self.Account.Header.Pran1.Skills[5].Level);
              Inc(Self.Account.Header.Pran1.Skills[6].Level);
              Inc(Self.Account.Header.Pran1.Skills[7].Level);
              Inc(Self.Account.Header.Pran1.Skills[8].Level);
              Inc(Self.Account.Header.Pran1.Skills[9].Level);
              {for I := 2 to 9 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran1.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran1.Skills[i].Index :=
                    Self.Account.Header.Pran1.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran1.Skills[i].Index);
                end;
              end;}
            end;
          60:
            begin
              Inc(Self.Account.Header.Pran1.Skills[4].Level);
              Inc(Self.Account.Header.Pran1.Skills[5].Level);
              Inc(Self.Account.Header.Pran1.Skills[6].Level);
              Inc(Self.Account.Header.Pran1.Skills[7].Level);
              Inc(Self.Account.Header.Pran1.Skills[8].Level);
              Inc(Self.Account.Header.Pran1.Skills[9].Level);
              {for I := 4 to 9 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran1.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran1.Skills[i].Index :=
                    Self.Account.Header.Pran1.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran1.Skills[i].Index);
                end;
              end;}
            end;
          65:
            begin
              Inc(Self.Account.Header.Pran1.Skills[4].Level);
              Inc(Self.Account.Header.Pran1.Skills[5].Level);
              Inc(Self.Account.Header.Pran1.Skills[6].Level);
              Inc(Self.Account.Header.Pran1.Skills[7].Level);
              Inc(Self.Account.Header.Pran1.Skills[8].Level);
              Inc(Self.Account.Header.Pran1.Skills[9].Level);
              {for I := 4 to 9 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran1.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran1.Skills[i].Index :=
                    Self.Account.Header.Pran1.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran1.Skills[i].Index);
                end;
              end;}
            end;
          70:
            begin
              Inc(Self.Account.Header.Pran1.Skills[5].Level);
              Inc(Self.Account.Header.Pran1.Skills[6].Level);
              Inc(Self.Account.Header.Pran1.Skills[7].Level);
              Inc(Self.Account.Header.Pran1.Skills[8].Level);
              Inc(Self.Account.Header.Pran1.Skills[9].Level);
              {for I := 5 to 9 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran1.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran1.Skills[i].Index :=
                    Self.Account.Header.Pran1.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran1.Skills[i].Index);
                end;
              end;}
            end;
        end;
        Self.SetPranPassiveSkill(0, 1);
        Self.SendPranToWorld(0);
        case Self.GetPranClass(@Self.Account.Header.Pran1) of
          1:
            baseSkillPran := 5760;
          2:
            baseSkillPran := 5860;
          3:
            baseSkillPran := 5960;
        end;
        for I := 0 to 2 do
        begin
          //if(Self.Account.Header.Pran1.ItemBar[i] = 0) or
            //(Self.Account.Header.Pran1.ItemBar[i] = 5760) then
            //continue;
          for helper := 0 to 9 do
          begin
            if(((Self.Account.Header.Pran1.ItemBar[i] + baseSkillPran) >=
            Self.Account.Header.Pran1.Skills[helper].Index) and
            ((Self.Account.Header.Pran1.ItemBar[i] + baseSkillPran) <=
            Self.Account.Header.Pran1.Skills[helper].Index+9)) then
            begin
              Self.Account.Header.Pran1.ItemBar[i] :=
                ((Self.Account.Header.Pran1.Skills[helper].Index +
                Self.Account.Header.Pran1.Skills[helper].Level-1) - baseSkillPran);
            end;
          end;
        end;
        Self.RefreshItemBarSlot(0, 3, Self.Account.Header.Pran1.ItemBar[0]);
        Self.RefreshItemBarSlot(1, 3, Self.Account.Header.Pran1.ItemBar[1]);
        Self.RefreshItemBarSlot(2, 3, Self.Account.Header.Pran1.ItemBar[2]);
      end;
    1:
      begin
        if (Self.Account.Header.Pran2.Level = MAX_PRAN_LEVEL) then
          Exit;
        Inc(Self.Account.Header.Pran2.Level);
        Self.SendClientMessage('Sua pran subiu de nível.');
        Self.SendPranLevelAndExp((Self.Account.Header.Pran2.Level + 1),
          Self.Account.Header.Pran2.Exp);
        Self.SetPranPassiveSkill(1, 0);
        case (Self.Account.Header.Pran2.Level + 1) of
          5:
            begin
              Inc(Self.Account.Header.Pran2.Skills[0].Level);
              Inc(Self.Account.Header.Pran2.Skills[1].Level);
              Inc(Self.Account.Header.Pran2.Skills[2].Level);
              {for I := 0 to 2 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran2.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran2.Skills[i].Index :=
                    Self.Account.Header.Pran2.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran2.Skills[i].Index);
                end;
              end; }
            end;
          10:
            begin
              Inc(Self.Account.Header.Pran2.Skills[0].Level);
              Inc(Self.Account.Header.Pran2.Skills[1].Level);
              Inc(Self.Account.Header.Pran2.Skills[2].Level);
              Inc(Self.Account.Header.Pran2.Skills[4].Level);
              {for I := 0 to 4 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran2.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran2.Skills[i].Index :=
                    Self.Account.Header.Pran2.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran2.Skills[i].Index);
                end;
              end;}
            end;
          15:
            begin
              Inc(Self.Account.Header.Pran2.Skills[0].Level);
              Inc(Self.Account.Header.Pran2.Skills[1].Level);
              Inc(Self.Account.Header.Pran2.Skills[2].Level);
              Inc(Self.Account.Header.Pran2.Skills[4].Level);
              Inc(Self.Account.Header.Pran2.Skills[5].Level);
              {for I := 0 to 5 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran2.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran2.Skills[i].Index :=
                    Self.Account.Header.Pran2.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran2.Skills[i].Index);
                end;
              end;}
            end;
          20:
            begin
              Inc(Self.Account.Header.Pran2.Skills[0].Level);
              Inc(Self.Account.Header.Pran2.Skills[1].Level);
              Inc(Self.Account.Header.Pran2.Skills[2].Level);
              Inc(Self.Account.Header.Pran2.Skills[4].Level);
              Inc(Self.Account.Header.Pran2.Skills[5].Level);
              Inc(Self.Account.Header.Pran2.Skills[6].Level);
              {for I := 0 to 6 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran2.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran2.Skills[i].Index :=
                    Self.Account.Header.Pran2.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran2.Skills[i].Index);
                end;
              end;}
            end;
          25:
            begin
              Inc(Self.Account.Header.Pran2.Skills[0].Level);
              Inc(Self.Account.Header.Pran2.Skills[1].Level);
              Inc(Self.Account.Header.Pran2.Skills[2].Level);
              Inc(Self.Account.Header.Pran2.Skills[4].Level);
              Inc(Self.Account.Header.Pran2.Skills[5].Level);
              Inc(Self.Account.Header.Pran2.Skills[6].Level);
              Inc(Self.Account.Header.Pran2.Skills[7].Level);
              {for I := 0 to 7 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran2.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran2.Skills[i].Index :=
                    Self.Account.Header.Pran2.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran2.Skills[i].Index);
                end;
              end;}
            end;
          30:
            begin
              Inc(Self.Account.Header.Pran2.Skills[0].Level);
              Inc(Self.Account.Header.Pran2.Skills[1].Level);
              Inc(Self.Account.Header.Pran2.Skills[2].Level);
              Inc(Self.Account.Header.Pran2.Skills[4].Level);
              Inc(Self.Account.Header.Pran2.Skills[5].Level);
              Inc(Self.Account.Header.Pran2.Skills[6].Level);
              Inc(Self.Account.Header.Pran2.Skills[7].Level);
              Inc(Self.Account.Header.Pran2.Skills[8].Level);
              {for I := 0 to 8 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran2.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran2.Skills[i].Index :=
                    Self.Account.Header.Pran2.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran2.Skills[i].Index);
                end;
              end;}
            end;
          35:
            begin
              Inc(Self.Account.Header.Pran2.Skills[0].Level);
              Inc(Self.Account.Header.Pran2.Skills[1].Level);
              Inc(Self.Account.Header.Pran2.Skills[2].Level);
              Inc(Self.Account.Header.Pran2.Skills[4].Level);
              Inc(Self.Account.Header.Pran2.Skills[5].Level);
              Inc(Self.Account.Header.Pran2.Skills[6].Level);
              Inc(Self.Account.Header.Pran2.Skills[7].Level);
              Inc(Self.Account.Header.Pran2.Skills[8].Level);
              Inc(Self.Account.Header.Pran2.Skills[9].Level);
              {for I := 0 to 9 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran2.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran2.Skills[i].Index :=
                    Self.Account.Header.Pran2.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran2.Skills[i].Index);
                end;
              end;}
            end;
          40:
            begin
              Inc(Self.Account.Header.Pran2.Skills[0].Level);
              Inc(Self.Account.Header.Pran2.Skills[1].Level);
              Inc(Self.Account.Header.Pran2.Skills[2].Level);
              Inc(Self.Account.Header.Pran2.Skills[4].Level);
              Inc(Self.Account.Header.Pran2.Skills[5].Level);
              Inc(Self.Account.Header.Pran2.Skills[6].Level);
              Inc(Self.Account.Header.Pran2.Skills[7].Level);
              Inc(Self.Account.Header.Pran2.Skills[8].Level);
              Inc(Self.Account.Header.Pran2.Skills[9].Level);
              {for I := 0 to 9 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran2.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran2.Skills[i].Index :=
                    Self.Account.Header.Pran2.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran2.Skills[i].Index);
                end;
              end;}
            end;
          45:
            begin
              Inc(Self.Account.Header.Pran2.Skills[0].Level);
              Inc(Self.Account.Header.Pran2.Skills[1].Level);
              Inc(Self.Account.Header.Pran2.Skills[2].Level);
              Inc(Self.Account.Header.Pran2.Skills[4].Level);
              Inc(Self.Account.Header.Pran2.Skills[5].Level);
              Inc(Self.Account.Header.Pran2.Skills[6].Level);
              Inc(Self.Account.Header.Pran2.Skills[7].Level);
              Inc(Self.Account.Header.Pran2.Skills[8].Level);
              Inc(Self.Account.Header.Pran2.Skills[9].Level);
              {for I := 0 to 9 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran2.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran2.Skills[i].Index :=
                    Self.Account.Header.Pran2.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran2.Skills[i].Index);
                end;
              end;}
            end;
          50:
            begin
              Inc(Self.Account.Header.Pran2.Skills[1].Level);
              Inc(Self.Account.Header.Pran2.Skills[2].Level);
              Inc(Self.Account.Header.Pran2.Skills[4].Level);
              Inc(Self.Account.Header.Pran2.Skills[5].Level);
              Inc(Self.Account.Header.Pran2.Skills[6].Level);
              Inc(Self.Account.Header.Pran2.Skills[7].Level);
              Inc(Self.Account.Header.Pran2.Skills[8].Level);
              Inc(Self.Account.Header.Pran2.Skills[9].Level);
              {for I := 1 to 9 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran2.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran2.Skills[i].Index :=
                    Self.Account.Header.Pran2.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran2.Skills[i].Index);
                end;
              end;}
            end;
          55:
            begin
              Inc(Self.Account.Header.Pran2.Skills[2].Level);
              Inc(Self.Account.Header.Pran2.Skills[4].Level);
              Inc(Self.Account.Header.Pran2.Skills[5].Level);
              Inc(Self.Account.Header.Pran2.Skills[6].Level);
              Inc(Self.Account.Header.Pran2.Skills[7].Level);
              Inc(Self.Account.Header.Pran2.Skills[8].Level);
              Inc(Self.Account.Header.Pran2.Skills[9].Level);
              {for I := 2 to 9 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran2.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran2.Skills[i].Index :=
                    Self.Account.Header.Pran2.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran2.Skills[i].Index);
                end;
              end;}
            end;
          60:
            begin
              Inc(Self.Account.Header.Pran2.Skills[4].Level);
              Inc(Self.Account.Header.Pran2.Skills[5].Level);
              Inc(Self.Account.Header.Pran2.Skills[6].Level);
              Inc(Self.Account.Header.Pran2.Skills[7].Level);
              Inc(Self.Account.Header.Pran2.Skills[8].Level);
              Inc(Self.Account.Header.Pran2.Skills[9].Level);
              {for I := 4 to 9 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran2.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran2.Skills[i].Index :=
                    Self.Account.Header.Pran2.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran2.Skills[i].Index);
                end;
              end;}
            end;
          65:
            begin
              Inc(Self.Account.Header.Pran2.Skills[4].Level);
              Inc(Self.Account.Header.Pran2.Skills[5].Level);
              Inc(Self.Account.Header.Pran2.Skills[6].Level);
              Inc(Self.Account.Header.Pran2.Skills[7].Level);
              Inc(Self.Account.Header.Pran2.Skills[8].Level);
              Inc(Self.Account.Header.Pran2.Skills[9].Level);
              {for I := 4 to 9 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran2.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran2.Skills[i].Index :=
                    Self.Account.Header.Pran2.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran2.Skills[i].Index);
                end;
              end;}
            end;
          70:
            begin
              Inc(Self.Account.Header.Pran2.Skills[5].Level);
              Inc(Self.Account.Header.Pran2.Skills[6].Level);
              Inc(Self.Account.Header.Pran2.Skills[7].Level);
              Inc(Self.Account.Header.Pran2.Skills[8].Level);
              Inc(Self.Account.Header.Pran2.Skills[9].Level);
              {for I := 5 to 9 do
              begin
                Helper := Self.PranBarExistsIndex(PranSlot,
                  Self.Account.Header.Pran2.Skills[i].Index);
                if(Helper <> 255) then
                begin
                  Self.Account.Header.Pran2.Skills[i].Index :=
                    Self.Account.Header.Pran2.Skills[i].Index + 1;
                  Self.RefreshItemBarSlot(Helper, 3, Self.Account.Header.Pran2.Skills[i].Index);
                end;
              end;}
            end;
        end;
        Self.SetPranPassiveSkill(1, 1);
        Self.SendPranToWorld(1);
        case Self.GetPranClass(@Self.Account.Header.Pran2) of
          1:
            baseSkillPran := 5760;
          2:
            baseSkillPran := 5860;
          3:
            baseSkillPran := 5960;
        end;
        for I := 0 to 2 do
        begin
          //if(Self.Account.Header.Pran2.ItemBar[i] = 0) or
            //(Self.Account.Header.Pran2.ItemBar[i] = 5760) then
            //continue;
          for helper := 0 to 9 do
          begin
            if(((Self.Account.Header.Pran2.ItemBar[i] + baseSkillPran) >=
            Self.Account.Header.Pran2.Skills[helper].Index) and
            ((Self.Account.Header.Pran2.ItemBar[i] + baseSkillPran) <=
            Self.Account.Header.Pran2.Skills[helper].Index+9)) then
            begin
              Self.Account.Header.Pran2.ItemBar[i] :=
                ((Self.Account.Header.Pran2.Skills[helper].Index +
                Self.Account.Header.Pran2.Skills[helper].Level-1) - baseSkillPran);  //era 60 testar isso aq
            end;
          end;
        end;
        Self.RefreshItemBarSlot(0, 3, Self.Account.Header.Pran2.ItemBar[0]);
        Self.RefreshItemBarSlot(1, 3, Self.Account.Header.Pran2.ItemBar[1]);
        Self.RefreshItemBarSlot(2, 3, Self.Account.Header.Pran2.ItemBar[2]);
      end;
  end;
end;
procedure TPlayer.SendPranLevelAndExp(Level: DWORD; Exp: Int64);
var
  Packet: TRefreshPranLevelExpPacket;
begin
  ZeroMemory(@Packet, sizeof(TRefreshPranLevelExpPacket));
  Packet.Header.size := sizeof(TRefreshPranLevelExpPacket);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $116;
  Packet.Level := Level;
  Packet.Exp := Exp;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendPranDevotionAndFood(Devotion, Food: WORD);
var
  Packet: TRefreshPranDevotionFoodPacket;
begin
  ZeroMemory(@Packet, sizeof(TRefreshPranDevotionFoodPacket));
  Packet.Header.size := sizeof(TRefreshPranDevotionFoodPacket);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $96B;
  Packet.Devotion := Devotion;
  Packet.Food := Food;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.AddGold(Value: Int64);
begin
  Inc(Self.Character.Base.Gold, Value);
  Self.RefreshMoney;
end;
procedure TPlayer.AddCash(Value: Cardinal);
begin
  Inc(Self.Account.Header.CashInventory.Cash, Value);
  Self.SendPlayerCash;
end;
procedure TPlayer.DecGold(Value: Int64);
begin
  Dec(Self.Character.Base.Gold, Value);
  Self.RefreshMoney;
end;
procedure TPlayer.AddTitle(TitleID, TitleLevel: Integer; xMsg: Boolean);
var
  i: Integer;
  Slot: Integer;
  SQLComp: TQuery;
begin
  Slot := 255;
  for i := 0 to 95 do
  begin
    if (Self.Base.PlayerCharacter.Titles[i].Index = 0) then
    begin
      Slot := i;
      Break;
    end;
  end;
  if (Slot = 255) then
  begin
    Self.SendClientMessage('Sua lista de títulos est?cheia.');
    Exit;
  end;

  if(Self.Account.GetCharCount(Self.Account.Header.AccountId, Self.ChannelIndex,
    @Self) > 1) then
  begin
    if(TitleID in [17,18]) then
    begin
      for I := 0 to 2 do
      begin
        if(Self.Account.Characters[i].Base.CharIndex = 0) then
          Continue;

        if(Self.Account.Characters[i].Base.CharIndex <> Self.Base.Character.CharIndex) then
        begin
          SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
            AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
            AnsiString(MYSQL_DATABASE));
          if not(SQLComp.Query.Connection.Connected) then
          begin
            Logger.Write('Falha de conexão individual com mysql.[AddTitle]',
              TlogType.Warnings);
            Logger.Write('PERSONAL MYSQL FAILED LOAD.[AddTitle]', TlogType.Error);
            SQLComp.Destroy;
            Exit;
          end;
          SQLComp.SetQuery
            (Format('INSERT INTO titles (owner_charid, title_index, title_level, ' +
            'title_progress) VALUES (%d, %d, %d, ' +
            '%d)', [Self.Account.Characters[i].Base.CharIndex, TitleID, TitleLevel, 1]));
          SQLComp.Run(FALSE);

          SQLComp.Destroy;
        end;
      end;
    end;
  end;

  Self.Base.PlayerCharacter.Titles[Slot].Index := TitleID;
  Self.Base.PlayerCharacter.Titles[Slot].Level := TitleLevel;
  if(xMsg) then
    Self.Base.PlayerCharacter.Titles[Slot].Progress := Titles[TitleID].TitleLevel
      [TitleLevel - 1].TitleGoal
  else
    Self.Base.PlayerCharacter.Titles[Slot].Progress := 1;

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[AddTitle]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[AddTitle]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  SQLComp.SetQuery
    (Format('INSERT INTO titles (owner_charid, title_index, title_level, ' +
    'title_progress) VALUES (%d, %d, %d, ' +
    '%d)', [Self.Base.Character.CharIndex, Self.Base.PlayerCharacter.Titles
    [Slot].Index, Self.Base.PlayerCharacter.Titles
    [Slot].Level, Self.Base.PlayerCharacter.Titles[Slot].Progress]));
  SQLComp.Run(FALSE);

  if(xMsg) then
  begin
    Self.SendTitleUpdate(TitleID, TitleLevel - 1);
    Self.SendClientMessage('Voc?obteve um novo título [' +
      AnsiString(Titles[TitleID].TitleLevel[TitleLevel - 1].TitleName) + ']');
  end;

  SQLComp.Destroy;
end;
procedure TPlayer.RemoveTitle(TitleID: Integer);
var
  i, Slot: Integer;
  SQLComp: TQuery;
begin
  Slot := 255;
  for I := 0 to 95 do
  begin
    if(Self.Base.PlayerCharacter.Titles[i].Index = TitleID) then
    begin
      Slot := i;
      Break;
    end;
  end;
  if(Slot = 255) then
    Exit;
  Self.Base.PlayerCharacter.Titles[Slot].Index := 0;
  Self.Base.PlayerCharacter.Titles[Slot].Level := 0;
  Self.Base.PlayerCharacter.Titles[Slot].Progress := 0;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[RemoveTitle]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[RemoveTitle]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  SQLComp.SetQuery(Format('DELETE FROM titles where owner_charid = %d and title_index = %d',
    [Self.Base.Character.CharIndex, TitleID]));
  SQLComp.Run(False);
  Self.SendTitleUpdate(TitleID, 0);
  Self.SendClientMessage('Voc?teve o título [' +
    AnsiString(Titles[TitleID].TitleLevel[0].TitleName) + '] deletado.');
  SQLComp.Destroy;
end;
procedure TPlayer.UpdateTitleLevel(TitleID, TitleLevel: Integer; xMsg: Boolean);
var
  i, Slot: Integer;
  SQLComp: TQuery;
begin
  Slot := 255;
  for I := 0 to 95 do
  begin
    if(Self.Base.PlayerCharacter.Titles[i].Index = TitleID) then
    begin
      Slot := i;
      Break;
    end;
  end;
  if(Slot = 255) then
    Exit;
  Self.Base.PlayerCharacter.Titles[Slot].Level := TitleLevel;
  if(xMsg) then
    Self.Base.PlayerCharacter.Titles[Slot].Progress := Titles[TitleID].TitleLevel
      [TitleLevel - 1].TitleGoal;

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[UpdateTitleLevel]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[UpdateTitleLevel]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  SQLComp.SetQuery(Format
    ('UPDATE titles SET title_level = %d, title_progress = %d where owner_charid = %d and title_index = %d',
    [TitleLevel, Self.Base.PlayerCharacter.Titles[Slot].Progress, Self.Base.Character.CharIndex, TitleID]));
  SQLComp.Run(False);
  if(xMsg) then
  begin
    Self.SendClientMessage('Voc?teve o título [' +
      AnsiString(Titles[TitleID].TitleLevel[0].TitleName) + '] aprimorado para o nível '+ IntToStr(TitleLevel) +'.');
    Self.SendTitleUpdate(TitleID, TitleLevel-1);
  end;
  SQLComp.Destroy;
end;
{$ENDREGION}
{$REGION 'Skills'}
procedure TPlayer.SetPlayerSkills;
var
  i, J, Tamanho: Integer;
  Level: Cardinal;
begin
  ZeroMemory(@Self.Character.Base.SkillList, 120);
  for i := 0 to Length(Self.Character.Skills.Basics) - 1 do
  begin
    if (Self.Character.Skills.Basics[i].Level = 0) then
      Continue;
    Self.Character.Base.SkillList[i] := $2;
  end;
  J := 6;
  for i := 0 to Length(Self.Character.Skills.Others) - 1 do
  begin
    if (Self.Character.Skills.Others[i].Level = 0) then
    begin
      Continue;
    end;
    Tamanho := TSkillFunctions.GetSkillLevel(Self.Character.Skills.Others[i].
      Index + (Self.Character.Skills.Others[i].Level - 1), Level);
    if (i > 0) then
    begin
      if (Self.Character.Skills.Others[i - 1].Level = 16) then
      begin
        Level := Level + 1;
      end;
    end;
    Move(Level, Self.Character.Base.SkillList[i + J], Tamanho);
  end;
end;
procedure TPlayer.SendPlayerSkills(NPCIndex: Integer = 0);
var
  Packet: TSendSkillsPacket;
  i: Integer;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $106;
  Packet.NPCIndex := NPCIndex;
  if (NPCIndex > 0) then
    Packet.SendType := $B;
  for i := 0 to Length(Self.Character.Skills.Others) - 1 do
  begin
    Packet.Skills[i] := Self.Character.Skills.Others[i].Index;
  end;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendPlayerSkillsLevel;
var
  Packet: TSendSkillsLevelPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $107;
  Self.SetPlayerSkills;
  Move(Self.Character.Base.SkillList[0], Packet.Skills[0],
    sizeof(Packet.Skills));
  Packet.SkillPoints := Self.Character.Base.CurrentScore.SkillPoint;
  Packet.Unk := $CCCC;
  Self.SendPacket(Packet, Packet.Header.size);
end;
function TPlayer.CalcSkillPoints(Level: WORD): WORD;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to Level do
  begin
    Inc(Result, SKILL_POINT_PER_LEVEL);
    if (i > 50) then
    begin
      if (i = 51) then
      begin
        Inc(Result, SKILL_POINT_X);
      end;
      if (i = 61) then
      begin
        Inc(Result, SKILL_POINT_X);
      end;
      if (i = 71) then
      begin
        Inc(Result, SKILL_POINT_X);
      end;
      if (i = 81) then
      begin
        Inc(Result, SKILL_POINT_X);
      end;
    end;
  end;
end;
procedure TPlayer.SearchSkillsPassive(Mode: BYTE);
var
  // Mode0 = Ativando  Mode1 = Desativando
  i: Integer;
  Skill, Level: Integer;
  helper: Integer;
begin
  for i := 0 to Length(Self.Character.Skills.Others) - 1 do
  begin
    if ((((SkillData[Self.Character.Skills.Others[i].Index].Agressive = 1) and
      (SkillData[Self.Character.Skills.Others[i].Index].Attribute = 0)) or
      ((SkillData[Self.Character.Skills.Others[i].Index].Agressive = 2) and
      (SkillData[Self.Character.Skills.Others[i].Index].Attribute = 0)))) then
    begin
      Skill := Self.Character.Skills.Others[i].Index;
      Level := Self.Character.Skills.Others[i].Level;
      case SkillData[Skill].Index of
        9: // fortitude WR atk fis 2 e acerto 4
          begin
            if (Mode = 0) then
            begin // para entrar no jogo
              Self.Base.IncreasseMobAbility(EF_DAMAGE1, (Level * 2));
              Self.Base.IncreasseMobAbility(EF_HIT, (Level * 4));
            end
            else if (Mode = 1) then
            begin // para reiniciar todas as habilidades
              Self.Base.DecreasseMobAbility(EF_DAMAGE1, (Level * 2));
              Self.Base.DecreasseMobAbility(EF_HIT, (Level * 4));
            end;
          end;
        10: // corpo draconiano WR hp 145 e 5% de recuperação de hp
          begin
            helper := 2000;
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_HP, (Level * 145));
              Self.Base.IncreasseMobAbility(EF_REGENHP,
                (Level * ((helper div 100) * 5)));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_HP, (Level * 145));
              Self.Base.DecreasseMobAbility(EF_REGENHP,
                (Level * ((helper div 100) * 5)));
            end;
          end;
        146: // Inspirar Coragem WR resfriamento 2%
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_COOLTIME, (Level * 2));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_COOLTIME, (Level * 2));
            end;
          end;
        23: // Instinto de batalha WR Reduz dano recebido em area 30%+(2%*lvl) e critico 1
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_REDUCE_AOE, (30 + (Level * 2)));
              Self.Base.IncreasseMobAbility(EF_CRITICAL, Level);
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_REDUCE_AOE, (30 + (Level * 2)));
              Self.Base.DecreasseMobAbility(EF_CRITICAL, Level);
            end;
          end;
        33: // punição TP recupera HP com o dano 1%*lvl
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_HP_ATK_RES, Level);
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_HP_ATK_RES, Level);
            end;
          end;
        34: // Revelação TP aumento de cura 120, cura recebida 1%, diminuição mp habilidades 10%+(2%*lvl)
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_SKILL_DAMAGE6, (Level * 120));
              Self.Base.IncreasseMobAbility(EF_MPCURE, (10 + (Level * 2)));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_SKILL_DAMAGE6, (Level * 120));
              Self.Base.DecreasseMobAbility(EF_MPCURE, (10 + (Level * 2)));
            end;
          end;
        149: // Defesa Automatica TP 10%+2*lvl de diminuir os danos em 5%+1*lvl
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_GUARD_RATE, (10 + (Level * 2)));
              Self.Base.IncreasseMobAbility(EF_GUARD, (5 + Level));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_GUARD_RATE, (10 + (Level * 2)));
              Self.Base.DecreasseMobAbility(EF_GUARD, (5 + Level));
            end;
          end;
        47: // Julgamento TP atk fis 8 + 4*lvl e crit 1
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_DAMAGE1, (8 + (Level * 4)));
              Self.Base.IncreasseMobAbility(EF_CRITICAL, Level);
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_DAMAGE1, (8 + (Level * 4)));
              Self.Base.DecreasseMobAbility(EF_CRITICAL, Level);
            end;
          end;
        57: // concentração att acerto 2
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_HIT, (Level * 2));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_HIT, (Level * 2));
            end;
          end;
        58: // Poder Critico Att critical power 5% + 5*lvl
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_CRITICAL_POWER,
                (5 + (Level * 5)));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_CRITICAL_POWER,
                (5 + (Level * 5)));
            end;
          end;
        152: // Ultimato att skill damage 50 + 50*lvl e velo 1 + lvl
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_RUNSPEED, (1 + (Level)));
              Self.Base.IncreasseMobAbility(EF_SKILL_DAMAGE,
                (50 + (Level * 50)));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_RUNSPEED, (1 + (Level)));
              Self.Base.DecreasseMobAbility(EF_SKILL_DAMAGE,
                (50 + (Level * 50)));
            end;
          end;
        71: // Guarda Fatal att res crit e duplo 3
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_RESISTANCE6, (Level * 3));
              Self.Base.IncreasseMobAbility(EF_RESISTANCE7, (Level * 3));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_RESISTANCE6, (Level * 3));
              Self.Base.DecreasseMobAbility(EF_RESISTANCE7, (Level * 3));
            end;
          end;
        81: // Olhar Penetrante DG crit 1 e dano crit 3
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_CRITICAL, Level);
              Self.Base.IncreasseMobAbility(EF_CRITICAL_POWER, (Level * 3));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_CRITICAL, Level);
              Self.Base.DecreasseMobAbility(EF_CRITICAL_POWER, (Level * 3));
            end;
          end;
        82: // Movimento Gracioso DG esquiva 2 + lvl
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_PARRY, (2 + Level));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_PARRY, (2 + Level));
            end;
          end;
        155: // Vento Cortante DG res lentidao 5 e res paralisia 3
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_IM_RUNSPEED, (Level * 5));
              Self.Base.IncreasseMobAbility(EF_IM_SKILL_IMMOVABLE, (Level * 3));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_IM_RUNSPEED, (Level * 5));
              Self.Base.DecreasseMobAbility(EF_IM_SKILL_IMMOVABLE, (Level * 3));
            end;
          end;
        95: // Falsa Pontaria DG reduz tax de perigo 8 + lvl*2 e Outro bglh la
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_STATE_RESISTANCE,
                (8 + (Level * 2)));
              Self.Base.IncreasseMobAbility(EF_DECEIVE_ATK, Level);
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_STATE_RESISTANCE,
                (8 + (Level * 2)));
              Self.Base.DecreasseMobAbility(EF_DECEIVE_ATK, Level);
            end;
          end;

        105: // Tempestade de Mana FC
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_DAMAGE2, (Level * 5));
              Self.Base.IncreasseMobAbility(EF_PRAN_REQUIRE_MP, (Level * 3));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_DAMAGE2, (Level * 5));
              Self.Base.DecreasseMobAbility(EF_PRAN_REQUIRE_MP, (Level * 3));
            end;
          end;
        106: // Harmonia de Mana FC
          begin

            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_MP, (80 * Level));
              Self.Base.IncreasseMobAbility(EF_REGENMP, (5 * Level));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_MP, (80 * Level));
              Self.Base.DecreasseMobAbility(EF_REGENMP, (5 * Level));
            end;
          end;
        158: // Afinidade Negra FC res silence 5 e terror 3
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_IM_SILENCE1, (Level * 5));
              Self.Base.IncreasseMobAbility(EF_IM_FEAR, (Level * 3));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_IM_SILENCE1, (Level * 5));
              Self.Base.DecreasseMobAbility(EF_IM_FEAR, (Level * 3));
            end;
          end;
        119: // Focar Mágica FC aumento do consumo de mana=MANABURN
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_CAST_RATE, (Level * 4));
              Self.Base.IncreasseMobAbility(EF_MANABURN, (4 + Level));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_CAST_RATE, (Level * 4));
              Self.Base.DecreasseMobAbility(EF_MANABURN, (4 + Level));
            end;
          end;
        129: // Ativação divina CL cura 120 diminui mp consumido em 10% cura
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_SKILL_DAMAGE6, (Level * 120));
              Self.Base.IncreasseMobAbility(EF_MPCURE, (8 + (2 * Level)));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_SKILL_DAMAGE6, (Level * 120));
              Self.Base.DecreasseMobAbility(EF_MPCURE, (8 + (2 * Level)));
            end;
          end;
        130: // Ativação De Mana CL aumento de duração dos buffs 2
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_SKILL_ATIME6, (Level * 2));
              Self.Base.IncreasseMobAbility(EF_REQUIRE_MP, (8 + (2 + Level)));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_SKILL_ATIME6, (Level * 2));
              Self.Base.DecreasseMobAbility(EF_REQUIRE_MP, (8 + (2 + Level)));
            end;
          end;
        161: // Vontade Inabalável CL res paralisia 5 choque 3
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_IM_SKILL_IMMOVABLE, (Level * 5));
              Self.Base.IncreasseMobAbility(EF_IM_SKILL_SHOCK, (Level * 3));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_IM_SKILL_IMMOVABLE, (Level * 5));
              Self.Base.DecreasseMobAbility(EF_IM_SKILL_SHOCK, (Level * 3));
            end;
          end;
        143: // Penitencia CL aumento de cura em 17 + lvl*3
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_SKILL_DAMAGE6,
                (17 + (Level * 3)));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_SKILL_DAMAGE6,
                (17 + (Level * 3)));
            end;
          end;
      end;
    end;
  end;
end;
procedure TPlayer.SetActiveSkillPassive(SkillIndex: Integer;
  SkillIDLevel: Integer);
begin
  case SkillData[SkillIndex].Index of
    9:
      begin
        Self.Base.IncreasseMobAbility(EF_DAMAGE1, 2);
        Self.Base.IncreasseMobAbility(EF_HIT, 4);
      end;
    10:
      begin
        Self.Base.IncreasseMobAbility(EF_HP, 145);
        Self.Base.IncreasseMobAbility(EF_REGENHP, Round((2000 div 100) * 5));
      end;
    146: // Inspirar Coragem WR resfriamento 2%
      begin
        Self.Base.IncreasseMobAbility(EF_COOLTIME, 2);
      end;
    23: // Instinto de batalha WR Reduz dano recebido em area 30%+(2%*lvl) e critico 1
      begin
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_REDUCE_AOE, (30 + 2))
        else
          Self.Base.IncreasseMobAbility(EF_REDUCE_AOE, 2);
        Self.Base.IncreasseMobAbility(EF_CRITICAL, 1);
      end;
    33: // punição TP Aumento da ameaça a todas as ações em 8.
      begin
      end;
    34: // Revelação TP aumento de cura 120, cura recebida 1%, diminuição mp habilidades 10%+(2%*lvl)
      begin
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_MPCURE, (10 + 2))
        else
          Self.Base.IncreasseMobAbility(EF_MPCURE, 2);
        Self.Base.IncreasseMobAbility(EF_SKILL_DAMAGE6, 120);
        Self.Base.IncreasseMobAbility(EF_UPCURE, 1);
      end;
    149: // Defesa Automatica TP 10%+2*lvl de diminuir os danos em 5%+1*lvl
      begin
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_GUARD_RATE, (10 + 2))
        else
          Self.Base.IncreasseMobAbility(EF_GUARD_RATE, 2);
        Self.Base.IncreasseMobAbility(EF_GUARD, 5);
      end;
    47: // Julgamento TP atk fis 8 + 4*lvl e crit 1
      begin
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_DAMAGE1, (8 + 4))
        else
          Self.Base.IncreasseMobAbility(EF_DAMAGE1, 4);
        Self.Base.IncreasseMobAbility(EF_CRITICAL, 1);
      end;
    57: // concentração att acerto 2
      begin
        Self.Base.IncreasseMobAbility(EF_HIT, 2);
      end;
    58: // Poder Critico Att critical power 5% + 5*lvl
      begin
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_CRITICAL_POWER, (5 + 5))
        else
          Self.Base.IncreasseMobAbility(EF_CRITICAL_POWER, 5);
      end;
    152: // Ultimato att skill damage 50 + 50*lvl e velo 1 + lvl
      begin
        if (SkillData[SkillIDLevel].Level = 1) then
        begin
          Self.Base.IncreasseMobAbility(EF_RUNSPEED, (1 + 1));
          Self.Base.IncreasseMobAbility(EF_SKILL_DAMAGE, (50 + 50));
        end
        else
        begin
          Self.Base.IncreasseMobAbility(EF_RUNSPEED, 1);
          Self.Base.IncreasseMobAbility(EF_SKILL_DAMAGE, 50);
        end;
      end;
    71: // Guarda Fatal att res crit e duplo 3
      begin
        Self.Base.IncreasseMobAbility(EF_RESISTANCE6, 3);
        Self.Base.IncreasseMobAbility(EF_RESISTANCE7, 3);
      end;
    81: // Olhar Penetrante DG crit 1 e dano crit 3
      begin
        Self.Base.IncreasseMobAbility(EF_CRITICAL, 1);
        Self.Base.IncreasseMobAbility(EF_CRITICAL_POWER, 3);
      end;
    82: // Movimento Gracioso DG esquiva 2 + lvl
      begin
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_PARRY, 3)
        else
          Self.Base.IncreasseMobAbility(EF_PARRY, 1);
      end;
    155: // Vento Cortante DG res lentidao 5 e res paralisia 3
      begin
        Self.Base.IncreasseMobAbility(EF_IM_RUNSPEED, 5);
        Self.Base.IncreasseMobAbility(EF_IM_SKILL_IMMOVABLE, 3);
      end;
    95: // Falsa Pontaria DG reduz tax de perigo 8 + lvl*2 e Outro bglh la
      begin
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_STATE_RESISTANCE, (8 + 2))
        else
          Self.Base.IncreasseMobAbility(EF_STATE_RESISTANCE, 2);
        Self.Base.IncreasseMobAbility(EF_DECEIVE_ATK, 1);
      end;
    105: // Tempestade de Mana FC
      begin
        Self.Base.IncreasseMobAbility(EF_DAMAGE2, 5);
        Self.Base.IncreasseMobAbility(EF_PRAN_REQUIRE_MP, 3);
      end;
    106: // Harmonia de Mana FC 5% + lvl
      begin
        Self.Base.IncreasseMobAbility(EF_MP,
          (80));
        Self.Base.IncreasseMobAbility(EF_REGENMP,
          (5));
      end;
    158: // Afinidade Negra FC res silence 5 e terror 3
      begin
        Self.Base.IncreasseMobAbility(EF_IM_SILENCE1, 5);
        Self.Base.IncreasseMobAbility(EF_IM_FEAR, 3);
      end;
    119: // Focar Mágica FC aumento do consumo de mana=MANABURN
      begin
        Self.Base.IncreasseMobAbility(EF_CAST_RATE, 4);
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_MANABURN, 5)
        else
          Self.Base.IncreasseMobAbility(EF_MANABURN, 1);
      end;
    129: // Ativação divina CL cura 120 diminui mp consumido em 10% cura
      begin
        Self.Base.IncreasseMobAbility(EF_SKILL_DAMAGE6, 120);
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_MPCURE, (8 + 2))
        else
          Self.Base.IncreasseMobAbility(EF_MPCURE, 2);
      end;
    130: // Ativação De Mana CL aumento de duração dos buffs 2
      begin
        Self.Base.IncreasseMobAbility(EF_SKILL_ATIME6, 2);
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_REQUIRE_MP, (8 + 2))
        else
          Self.Base.IncreasseMobAbility(EF_REQUIRE_MP, 2);
      end;
    161: // Vontade Inabalável CL res paralisia 5 choque 3
      begin
        Self.Base.IncreasseMobAbility(EF_IM_SKILL_IMMOVABLE, 5);
        Self.Base.IncreasseMobAbility(EF_IM_SKILL_SHOCK, 3);
      end;
    143: // Penitencia CL aumento de cura em 17 + lvl*3
      begin
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_SKILL_DAMAGE6, (17 + 3))
        else
          Self.Base.IncreasseMobAbility(EF_SKILL_DAMAGE6, 3);
      end;
  end;
end;
procedure TPlayer.SetDesativeSkillPassive(SkillIndex: Integer);
begin
end;
{$ENDREGION}
{$REGION 'Friend list'}
procedure TPlayer.sendToFriends(const Packet; size: WORD);
var
  // i: BYTE;
  characterId: UInt64;
  OtherPlayer: WORD;
  OtherServer: Byte;
begin
  for characterId in Self.FriendList.Keys do
  begin
    if not(Self.EntityFriend.getFriend(characterId, OtherPlayer, OtherServer)) then
      Continue;
    Servers[OtherServer].Players[OtherPlayer].SendPacket(Packet, size);
  end;
end;
procedure TPlayer.sendFriendToSocial(const characterId: UInt64);
var
  Packet: TSendFriendToSocialPacket;
  OP: Word;
  OtherServer: Byte;
  OtherPlayer: PPlayer;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $870;
  if (characterId = 0) then
    Exit;
  AnsiStrings.StrPCopy(Packet.Nick, Self.FriendList[characterId]
    .friendCharacterName);
  Packet.CharIndex := characterId;
  if not(Self.EntityFriend.getFriend(characterId, OP, OtherServer)) then
  begin
    Packet.FriendStatus := TFriendStatus.Offline;
    Self.SendPacket(Packet, Packet.Header.size);
    Exit;
  end;
  OtherPlayer := @Servers[OtherServer].Players[OP];
  Packet.FriendStatus := TFriendStatus.Online;
  Packet.Channel := OtherPlayer^.ChannelIndex;
  Packet.PlayerIndex := OtherPlayer^.Base.clientId;
  Packet.Classe := OtherPlayer^.Base.Character.ClassInfo;
  Packet.City := OtherPlayer^.CurrentCity;
  Packet.Level := (OtherPlayer^.Base.Character.Level - 1);
  Self.SendPacket(Packet, Packet.Header.size);
end;
function TPlayer.AddFriend(PlayerIndex: WORD): BYTE;
var
  OtherPlayer: PPlayer;
  friend, friend1: TFriend;
begin
  Result := 0;
  OtherPlayer := @Servers[Self.ChannelIndex].Players[PlayerIndex];
  if (OtherPlayer^.Status < Playing) then
  begin
    Result := 1;
    Exit;
  end;
  if (Self.FriendList.Count >= 50) then
  begin
    Result := 2;
    Exit;
  end;
  if (OtherPlayer^.FriendList.Count >= 50) then
  begin
    Result := 3;
    Exit;
  end;
  if (OtherPlayer^.Base.clientId = Self.Base.clientId) then
  begin
    Self.SendClientMessage('Voc?não pode se adicionar como amigo.');
    Exit;
  end;
  if not(Self.EntityFriend.AddFriend(OtherPlayer^.Character.Index)) then
    Exit;
  if not(OtherPlayer^.EntityFriend.AddFriend(Self.Character.Index)) then
    Exit;
  friend.Create(OtherPlayer^.Character.Index, OtherPlayer.Character.Index,
    AnsiString(OtherPlayer^.Character.Base.Name));
  Self.FriendList.Add(OtherPlayer^.Character.Index, friend);
  Self.sendFriendToSocial(OtherPlayer^.Character.Index);
  friend1.Create(Self.Character.Index, Self.Character.Index,
    AnsiString(Self.Character.Base.Name));
  OtherPlayer^.FriendList.Add(Self.Character.Index, friend1);
  OtherPlayer^.sendFriendToSocial(Self.Character.Index);
  Result := 0;
end;
procedure TPlayer.AtualizeFriendInfos(characterId: UInt64);
var
  Packet: TAtualizeFriendInfosPacket;
  OtherPlayer: PPlayer;
  OP: WORD;
  OtherServer: Byte;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $975;
  if not(Self.EntityFriend.getFriend(characterId, OP, OtherServer)) then
  begin
    Exit;
  end;
  OtherPlayer := @Servers[OtherServer].Players[OP];
  Packet.PlayerIndex := OtherPlayer.Base.clientId;
  Packet.FriendStatus := TFriendStatus.Online;
  Packet.Channel := OtherPlayer.ChannelIndex;
  Packet.City := OtherPlayer.CurrentCityID;
  Packet.Level := (OtherPlayer.Base.Character.Level - 1);
  Packet.Classe := OtherPlayer.Base.Character.ClassInfo;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.sendDeleteFriend(characterId: UInt64);
var
  Packet: TDeleteFriendPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $F74;
  Packet.CharIndex := characterId;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendFriendLogin;
var
  Packet: TFriendLoginPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $96F;
  Packet.CharIndex := Self.Character.Index;
  Packet.PlayerIndex := Self.Base.clientId;
  Packet.FriendStatus := TFriendStatus.Online;
  Packet.Channel := Self.ChannelIndex;
  Packet.City := Self.CurrentCity;
  Packet.Nation := Self.Account.Header.Nation;
  Packet.Level := Self.Base.Character.Level - 1;
  Packet.Classe := Self.Base.Character.ClassInfo;
  Self.sendToFriends(Packet, Packet.Header.size);
end;
procedure TPlayer.SendFriendLogout;
var
  Packet: TFriendLogoutPacket;
begin
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $971;
  Packet.CharIndex := Self.Character.Index;
  Self.sendToFriends(Packet, Packet.Header.size);
end;
procedure TPlayer.RefreshSocialFriends;
var
  // i: BYTE;
  characterId: UInt64;
begin
  for characterId in Self.FriendList.Keys do
  begin
    Self.sendFriendToSocial(characterId);
  end;
end;
procedure TPlayer.RefreshMeToFriends;
var
  Packet: TAtualizeFriendInfosPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $975;
  Packet.CharIndex := Self.Character.Index;
  Packet.PlayerIndex := Self.Base.clientId;
  Packet.FriendStatus := TFriendStatus.Online;
  Packet.Channel := Self.ChannelIndex;
  Packet.City := BYTE(Self.CurrentCityID);
  Packet.Level := Self.Base.Character.Level - 1;
  Packet.Classe := Self.Base.Character.ClassInfo;
  Self.sendToFriends(Packet, Packet.Header.size);
end;
procedure TPlayer.OpenFriendWindow(CharIndex, WindowIndex: DWORD);
var
  Packet: TOpenFriendWindowPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $F27;
  Packet.CharIndex := CharIndex;
  Packet.WindowIndex := WindowIndex;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.CloseFriendWindow(characterId: UInt64);
var
  Packet: TCloseFriendWindowPacket;
  key: WORD;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $F30;
  if not(Self.FriendOpenWindowns.ContainsValue(characterId)) then
    Exit;
  for key in Self.FriendOpenWindowns.Keys do
  begin
    if (Self.FriendOpenWindowns[key] = characterId) then
    begin
      Packet.WindowIndex := key;
    end;
  end;
  Self.FriendOpenWindowns.Remove(Packet.WindowIndex);
  Self.SendPacket(Packet, Packet.Header.size);
end;
{$ENDREGION}
{$REGION 'Teleport Functions'}
procedure TPlayer.Teleport(Pos: TPosition);
var
  Packet: TMovementPacket;
  i: WORD;
  OtherPlayer: PPlayer;
begin
  if not(Pos.IsValid) then
  begin
    Exit;
  end;
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $301;
  Packet.Destination := Pos;
  Packet.MoveType := MOVE_TELEPORT;
  Self.Base.SendToVisible(Packet, Packet.Header.size, True);
  for i in Self.Base.VisiblePlayers do
  begin
    if (i = Self.Base.clientId) then
      Continue;
    OtherPlayer := @Servers[Self.Base.ChannelId].Players[i];
    if (Self.Account.Header.Pran1.IsSpawned) then
    begin
      Self.SendPranUnspawn(0, OtherPlayer^.Base.clientId);
    end;
    if (Self.Account.Header.Pran2.IsSpawned) then
    begin
      Self.SendPranUnspawn(1, OtherPlayer^.Base.clientId);
    end;
    if (OtherPlayer^.Account.Header.Pran1.IsSpawned) then
    begin
      OtherPlayer^.SendPranUnspawn(0, Self.Base.clientId);
    end;
    if (OtherPlayer^.Account.Header.Pran2.IsSpawned) then
    begin
      OtherPlayer^.SendPranUnspawn(1, Self.Base.clientId);
    end;
    Self.Base.removevisible(OtherPlayer^.Base);
  end;
  Self.Base.PlayerCharacter.LastPos := Packet.Destination;
  Self.Character.LastPos := Packet.Destination;
  Self.SetCurrentNeighbors;
  Self.Base.UpdateVisibleList;
  if (Self.Account.Header.Pran1.IsSpawned) then
  begin
    Self.SendPranSpawn(Self.SpawnedPran, 0, MOVE_TELEPORT);
    { Packet.Header.Index := Self.Account.Header.Pran1.ID;
      Randomize;
      Packet.Destination := Self.Base.Neighbors[Random(7)].Pos;
      Packet.MoveType := MOVE_NORMAL;
      Self.Account.Header.Pran1.Position := Packet.Destination;
      Self.SendPacket(Packet, Packet.Header.size); }
  end;
  if (Self.Account.Header.Pran2.IsSpawned) then
  begin
    Self.SendPranSpawn(Self.SpawnedPran, 0, MOVE_TELEPORT);
    { Packet.Header.Index := Self.Account.Header.Pran2.ID;
      Randomize;
      Packet.Destination := Self.Base.Neighbors[Random(7)].Pos;
      Packet.MoveType := MOVE_NORMAL;
      Self.Account.Header.Pran2.Position := Packet.Destination;
      Self.SendPacket(Packet, Packet.Header.size); }
  end;
  //if (Self.GetCurrentCity <> Self.CurrentCity) then
  //begin
    //Self.CurrentCity := Self.GetCurrentCity;
  Self.CurrentCityID := Self.GetCurrentCityID;
  Self.RefreshMeToFriends;
  //end;
  // Self.Base.SendCreateMob(SPAWN_TELEPORT);
end;
{$ENDREGION}
{$REGION 'Classes'}
class procedure TPlayer.ForEach(proc: TProc<PPlayer, TParallel.TLoopState>;
  Server: BYTE);
begin
  TParallel.For(1, Servers[Server].InstantiatedPlayers,
    procedure(i: Integer; state: TParallel.TLoopState)
    var
      Player: PPlayer;
    begin
      Player := @Servers[Server].Players[i];
      if (Player = nil) OR not(Player.Base.IsActive) then
        Exit;
      proc(Player, state);
    end);
end;

class procedure TPlayer.ForEach(proc: TProc<PPlayer>; Server: BYTE);
var
  i: Integer;
  Player: PPlayer;
begin
  for i := 1 to Servers[Server].InstantiatedPlayers do
  begin
    Player := @Servers[Server].Players[i];
    if (Player = nil) OR not(Player.Base.IsActive) then
      Continue;
    proc(Player);
  end;
end;

class function TPlayer.GetPlayer(Index: WORD; Server: BYTE;
out Player: TPlayer): Boolean;
begin
  Result := FALSE;
  if (index = 0) OR (index > MAX_CONNECTIONS) then
    Exit;
  Player := Servers[Server].Players[index];
  Result := Player.Base.IsActive;
end;
{$ENDREGION}

{$REGION 'PersonalShop'}
procedure TPlayer.SendPersonalShop(Shop: TPersonalShopData);
var
  Packet: TPersonalShopPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $319;
  Move(Shop, Packet.Shop, sizeof(Shop));
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.ClosePersonalShop;
begin
  Self.SendData(Self.Base.clientId, $318, 0);
end;
{$ENDREGION}
{$REGION 'Change Channel'}
procedure TPlayer.SendChannelClientIndex;
var
  Packet: TUpdateClientIDPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $150;
  Packet.AccountId := Self.Account.Header.AccountId;
  Packet.clientId := Self.Base.clientId;
  Packet.LoginTime := DateTimeToUnix(Now);
  Packet.Unk1 := (Self.ChannelIndex + 1);
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendLoginConfirmation;
var
  Packet: TResponseLoginPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $82;
  Packet.Index := Self.Account.Header.AccountId;
  Packet.Time := DateTimeToUnix(Now);
  Packet.Nation := Self.Account.Header.Nation;
  Self.SendPacket(Packet, Packet.Header.size);
end;
{$ENDREGION}
{$REGION 'Chat Functions'}
function TPlayer.SendItemChat(Slot: WORD; ChatType: BYTE; Msg: string): Boolean;
var
  Packet: TChatItemLinkPacket;
  Item: PItem;
begin
  Result := FALSE;
  ZeroMemory(@Packet, sizeof(Packet));
  Item := @Self.Character.Base.Inventory[Slot];
  if (Item.Index = 0) then
    Exit;
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $F6F;
  AnsiStrings.StrCopy(Packet.Nick, Self.Character.Base.Name);
  Packet.ChatType := ChatType;
  Packet.Item := Item^;
  AnsiStrings.StrPCopy(Packet.Fala, AnsiString(Msg));
  case ChatType of
    CHAT_TYPE_NORMAL:
      Self.Base.SendToVisible(Packet, Packet.Header.size);
    CHAT_TYPE_GRUPO:
      Self.SendToParty(Packet, Packet.Header.size);
    CHAT_TYPE_GUILD:
      begin
        Guilds[Self.Character.GuildSlot].SendChatMessage(Packet, Packet.Header.Size);
      end;
    CHAT_TYPE_GRITO:
      begin
        if (SecondsBetween(Now, Self.ShoutTime) < 5) then
        begin
          Self.SendClientMessage('Voc?não pode floodar o grito.');
        end
        else
        begin
          Servers[Self.ChannelIndex].SendToAll(Packet, Packet.Header.size);
          Self.ShoutTime := Now;
        end;
      end;
    CHAT_TYPE_MEGAFONE:
      begin
        Servers[Self.ChannelIndex].SendToAll(Packet, Packet.Header.size);
      end;
  end;
  Result := True;
end;
{$ENDREGION}
{$REGION 'Effect Functions'}
procedure TPlayer.SendEffect(EffectIndex: DWORD);
var
  Packet: TSendClientIndexPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $117;
  Packet.Index := Self.Base.clientId;
  Packet.Effect := EffectIndex;
  Self.Base.SendToVisible(Packet, Packet.Header.size);
end;

procedure TPlayer.SendAnimation(AnimationIndex, Loop: DWORD);
var
  Packet: TSendAnimationPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $31F;
  Packet.Anim := AnimationIndex;
  Packet.Loop := Loop;
  Self.Base.SendToVisible(Packet, Packet.Header.size);
end;

procedure TPlayer.SendDevirChange(DevirNpcID: DWORD; DevirAnimation: DWORD);
var
  Packet: TSendAnimationPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := DevirNpcID;
  Packet.Header.Code := $31F;
  Packet.Anim := DevirAnimation;
  Packet.Loop := 0;
  Self.SendPacket(Packet, Packet.Header.Size);
  //Self.Base.SendToVisible(Packet, Packet.Header.size);
end;

procedure TPlayer.SendAnimationDeadOf(ClientID: DWORD);
var
  Packet: TPacketSendDeadAnimation;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $180;
  Packet.CountOfBlueTicks := 0;
  Packet.ClientID := ClientID;

  Self.Base.SendToVisible(Packet, Packet.Header.size, True);
  //Self.SendPacket(Packet, Packet.Header.Size);
end;

{$ENDREGION}
{$REGION 'Guild'}
procedure TPlayer.SearchAndSetGuildSlot;
var
  i: Integer;
begin
  for i := Low(Guilds) to High(Guilds) do
  begin
    if (Guilds[i].Index = 0) then
      Continue;
    if (Guilds[i].Index = Self.Character.Base.GuildIndex) then
    begin
      Self.Character.GuildSlot := Guilds[i].Slot;
      Break;
    end;
  end;
end;
procedure TPlayer.SendGuildInfo;
var
  Packet: TGuildInfoPacket;
  Guild: PGuild;
begin
  // if Self.Character.Base.GuildIndex <= 0 then
  // Exit;
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $965;
  Guild := @Guilds[Self.Character.GuildSlot];
  Packet.GuildIndex := Self.Character.Base.GuildIndex;
  Packet.Nation := Guild.Nation;
  Move(Guild.Name, Packet.GuildName, Length(Guild.Name) - 1);
  Move(Guild.Notices, Packet.Notices, sizeof(Guild.Notices));
  Move(Guild.Site, Packet.Site, Length(Guild.Site));
  Packet.GuildIndex_1 := Self.Character.Base.GuildIndex;
  Move(Guild.Ally.Guilds, Packet.GuildsAlly, sizeof(Guild.Ally.Guilds));
  Packet.Null_4 := 1;
  {Packet.Unk_1[0] := 1;
  Packet.Unk_1[1] := 1;
  Packet.Unk_1[2] := 1;  }
  Move(Guild.RanksConfig, Packet.RanksConfig, 5);
  Packet.Exp := Guild.Exp;
  Packet.Level := Guild.Level;
  Packet.BravePoints := Guild.BravurePoints;
  Packet.Promote := Guild.Promote;
  Packet.SkillPoints := Guild.SkillPoints;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendGuildPlayers;
var
  Packet: TGuildPlayersPacket;
  i, P, S: Integer;
  Guild: PGuild;
  Player: PPlayer;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Character.Base.clientId;
  Packet.Header.Code := $97F;
  P := 0;
  if Self.Character.Base.GuildIndex <= 0 then
    Exit;
  Guild := @Guilds[Self.Character.GuildSlot];
  Packet.GuildIndex := Guild^.Index;
  for i := 0 to Length(Guild^.Members) - 1 do
    if Guild^.Members[i].CharIndex > 0 then
    begin
      if P >= 10 then
      begin
        Self.SendPacket(Packet, Packet.Header.size);
        ZeroMemory(@Packet.Players, sizeof(Packet.Players));
        P := 0;
      end;
      Move(Guild^.Members[i], Packet.Players[P], sizeof(TPlayerFromGuild));
      Packet.Players[P].Logged := FALSE;
      for S := Low(Servers) to High(Servers) do
        if Servers[S].GetPlayerByCharIndex(Packet.Players[P].CharIndex, Player)
        then
        begin
          Packet.Players[P].Logged := True;
          Break;
        end;
      Inc(P, 1);
    end;
  if P = 0 then
    Exit;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.AddPlayerToGuild(Player: TPlayerFromGuild);
var
  Packet: TAddPlayerToGuildPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Character.Base.clientId;
  Packet.Header.Code := $125;
  Packet.Player := Player;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.GuildMemberLogin(MemberId: Integer);
var
  Packet: TGuildMemberLoginPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $969;
  Packet.CharIndex := Guilds[Self.Character.GuildSlot].Members[MemberId]
    .CharIndex;
  Packet.Status := 1;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.GuildMemberLogout(MemberId: Integer);
var
  Packet: TGuildMemberLogoutPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $96A;
  Packet.CharIndex := Guilds[Self.Character.GuildSlot].Members[MemberId]
    .CharIndex;
  Packet.LastLogin := Guilds[Self.Character.GuildSlot].Members[MemberId]
    .LastLogin;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.UpdateGuildMemberRank(CharIndex: Integer; Rank: Integer);
var
  Packet: TChangeGuildMemberRankPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $F1D;
  Packet.CharIndex := CharIndex;
  Packet.Rank := Rank;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.UpdateGuildMemberLevel(CharIndex: Integer; Level: Integer);
var
  Packet: TUpdateGuildMemberLevelPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $D1E;
  Packet.CharIndex := CharIndex;
  Packet.Level := Level;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.UpdateGuildRanksConfig;
var
  Packet: TUpdateGuildRanksConfigPacket;
begin
  if Self.Character.Base.GuildIndex <= 0 then
    Exit;
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $F22;
  Move(Guilds[Self.Character.GuildSlot].RanksConfig, Packet.RanksConfig, 4);
  Packet.GuildIndex := Self.Character.Base.GuildIndex;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.UpdateGuildNotices;
var
  Packet: TUpdateGuildNoticesPacket;
  i: Integer;
begin
  if Self.Character.Base.GuildIndex <= 0 then
    Exit;
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $F20;
  Packet.GuildIndex := Self.Character.Base.GuildIndex;
  for i := 0 to 2 do
    AnsiStrings.StrCopy(Packet.Notices[i], Guilds[Self.Character.GuildSlot]
      .Notices[i].Text);
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.UpdateGuildSite;
var
  Packet: TUpdateGuildSitePacket;
begin
  if Self.Character.Base.GuildIndex <= 0 then
    Exit;
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $F21;
  Packet.GuildIndex := Self.Character.Base.GuildIndex;
  AnsiStrings.StrCopy(Packet.Site, Guilds[Self.Character.GuildSlot].Site);
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.InviteToGuildRequest(clientId: Integer);
var
  Packet: TInviteToGuildPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := clientId;
  Packet.Header.Code := $97C;
  Move(Self.Character.Base.Name, Packet.InviterNick,
    Length(Packet.InviterNick));
  Servers[Self.ChannelIndex].Players[clientId].SendPacket(Packet,
    Packet.Header.size);
end;
procedure TPlayer.GetOutGuild(Expulsion: Boolean);
begin
  Self.Character.Base.GuildIndex := 0;
  case Expulsion of
    True:
      Self.SendData(Self.Base.clientId, $F1C, 1);
    FALSE:
      Self.SendData(Self.Base.clientId, $F1C, 0);
  end;
  Self.RefreshPlayerInfos(True);
  Self.SendP152;
end;
procedure TPlayer.SendGuildChestPermission;
var
  Packet: TGuildChestPermissionPacket;
  Guild: PGuild;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $F10;
  Guild := @Guilds[Self.Character.GuildSlot];
  Packet.CanUseGuildChest := Guild.GetRankConfig
    (Guild.Members[Guild.FindMemberFromCharIndex(Self.Character.Index)
    ].Rank).UseGWH;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendGuildChest;
var
  Packet: TGuildChestPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $D58;
  Packet.Content := Guilds[Self.Character.GuildSlot].Chest;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.CloseGuildChest;
var
  i: Integer;
  Player: PPlayer;
begin
  for i := Low(Servers) to High(Servers) do
    if Servers[i].GetPlayerByCharIndex(Self.Character.Index, Player) then
    begin
      Player.SendSignal(Self.Character.Base.clientId, $F2F);
      Exit;
    end;
end;
procedure TPlayer.RefreshGuildChestGold;
var
  Packet: TRefreshGuildChestGoldPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $D18;
  Packet.GuildIndex := Self.Character.Base.GuildIndex;
  Packet.Unk := 1;
  Packet.Gold := Guilds[Self.Character.GuildSlot].Chest.Gold;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendP152;
var
  Packet: ARRAY [0 .. $2F] OF BYTE;
begin //pacote de buffs da guilda estudar mais depois
  ZeroMemory(@Packet, Length(Packet));
  PWORD(Integer(@Packet) + 00)^ := Length(Packet);
  PWORD(Integer(@Packet) + 06)^ := $152;
  {PWORD(Integer(@Packet) + 12)^ := Guilds[Self.Character.GuildSlot].Index;
  PWORD(Integer(@Packet) + 14)^ := Guilds[Self.Character.GuildSlot].Nation;
  PWORD(Integer(@Packet) + 16)^ := Guilds[Self.Character.GuildSlot].Level;
  PINT64(Integer(@Packet) + 20)^ := Guilds[Self.Character.GuildSlot].Exp; }
  Self.SendPacket(Packet, Length(Packet));
end;
{$ENDREGION}
{$REGION 'Duel'}
procedure TPlayer.SendDuelTime();
var
  Packet: TSendDuelTime;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $1A2;
  Packet.SecondsCount := DUEL_TIME_WAIT;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.CreateDuelSession(OtherPlayer: PPlayer);
var
  Packet: TSendCreateMobPacket;
  FlagID: WORD;
  Title: String;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Inc(Servers[Self.ChannelIndex].DuelCount);
  FlagID := 10148 + Servers[Self.ChannelIndex].DuelCount;
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := FlagID;
  Packet.Header.Code := $349;
  System.AnsiStrings.StrPLCopy(Packet.Name, '365', 3);
  Packet.Equip[0] := 413;
  Packet.Equip[6] := 1481;
  Randomize;
  Packet.Position := Self.Base.Neighbors[Random(7)].Pos;
  Self.DuelFlagPosition := Packet.Position;
  OtherPlayer.DuelFlagPosition := Packet.Position;
  Packet.MaxHp := 20000;
  Packet.CurHP := 20000;
  Packet.Unk0 := $0A;
  Packet.Effects[1] := $1D;
  Packet.EffectType := 1;
  Packet.IsService := 1;
  Packet.SpawnType := SPAWN_BABYGEN;
  Packet.Altura := 4;
  Packet.Tronco := $77;
  Packet.Perna := $77;
  Packet.Corpo := 0;
  Title := String(Self.Base.Character.Name) + ' vs. ' +
    String(OtherPlayer.Base.Character.Name);
  System.AnsiStrings.StrPLCopy(Packet.Title, AnsiString(Title), 32);
  Self.Base.SendToVisible(Packet, Packet.Header.size);
  Self.Dueling := True;
  OtherPlayer.Dueling := True;
  Self.DuelInitTime := Now;
  OtherPlayer.DuelInitTime := Now;
  Self.DuelFlagID := FlagID;
  OtherPlayer.DuelFlagID := FlagID;
  Self.DuelingWith := OtherPlayer.Base.clientId;
  OtherPlayer.DuelingWith := Self.Base.clientId;
  Self.DuelThread := TDuelThread.Create(1000, Self.ChannelIndex,
    Self.Base.clientId, OtherPlayer.Base.clientId);
end;
procedure TPlayer.SendDuelEnd(MsgType: BYTE);
var
  Packet: TMessageEndDuel;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $1A0;
  Packet.WonLose := MsgType;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.RemoveDuelFlag(FlagID: WORD);
var
  Packet: TSendRemoveMobPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $101;
  if (FlagID = 0) then
    Packet.Index := Self.DuelFlagID
  else
    Packet.Index := FlagID;
  Self.SendPacket(Packet, Packet.Header.size);
end;
{$ENDREGION}
{$REGION 'Quest'}
procedure TPlayer.SendQuests();
var
  i: Integer;
begin
  for i := 0 to 49 do
  begin
    if (Self.PlayerQuests[i].ID > 0) then
    begin
      if not(Self.PlayerQuests[i].IsDone) then
      begin
        Self.UpdateQuest(Self.PlayerQuests[i].ID);
      end;
    end;
  end;
end;
procedure TPlayer.UpdateQuest(QuestID: DWORD);
var
  Packet: TSendQuestInfo;
  QuestIndex: WORD;
  auxInt: Integer;
begin
  ZeroMemory(@Packet, sizeof(TSendQuestInfo));
  Packet.Header.size := sizeof(TSendQuestInfo);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $331;
  if (Self.QuestExists(QuestID, QuestIndex)) then
  begin
    Packet.QuestID := QuestID;
    Packet.RequirimentType[0] := Self.PlayerQuests[QuestIndex]
      .Quest.RequirimentsType[0];
    Packet.RequirimentType[1] := Self.PlayerQuests[QuestIndex]
      .Quest.RequirimentsType[1];
    Packet.RequirimentType[2] := Self.PlayerQuests[QuestIndex]
      .Quest.RequirimentsType[2];
    Packet.RequirimentType[3] := Self.PlayerQuests[QuestIndex]
      .Quest.RequirimentsType[3];
    Packet.RequirimentType[4] := Self.PlayerQuests[QuestIndex]
      .Quest.RequirimentsType[4];
    Packet.RequirimentAmount[0] := Self.PlayerQuests[QuestIndex]
      .Quest.RequirimentsAmount[0];
    Packet.RequirimentAmount[1] := Self.PlayerQuests[QuestIndex]
      .Quest.RequirimentsAmount[1];
    Packet.RequirimentAmount[2] := Self.PlayerQuests[QuestIndex]
      .Quest.RequirimentsAmount[2];
    Packet.RequirimentAmount[3] := Self.PlayerQuests[QuestIndex]
      .Quest.RequirimentsAmount[3];
    Packet.RequirimentAmount[4] := Self.PlayerQuests[QuestIndex]
      .Quest.RequirimentsAmount[4];
    Packet.RequirimentComplete[0] := Self.PlayerQuests[QuestIndex].Complete[0];
    Packet.RequirimentComplete[1] := Self.PlayerQuests[QuestIndex].Complete[1];
    Packet.RequirimentComplete[2] := Self.PlayerQuests[QuestIndex].Complete[2];
    Packet.RequirimentComplete[3] := Self.PlayerQuests[QuestIndex].Complete[3];
    Packet.RequirimentComplete[4] := Self.PlayerQuests[QuestIndex].Complete[4];
    // amount ?o total, complete ?quantos j?foi
    Packet.RequirimentItem[0] := Self.PlayerQuests[QuestIndex]
      .Quest.Requiriments[0];
    Packet.RequirimentItem[1] := Self.PlayerQuests[QuestIndex]
      .Quest.Requiriments[1];
    Packet.RequirimentItem[2] := Self.PlayerQuests[QuestIndex]
      .Quest.Requiriments[2];
    Packet.RequirimentItem[3] := Self.PlayerQuests[QuestIndex]
      .Quest.Requiriments[3];
    Packet.RequirimentItem[4] := Self.PlayerQuests[QuestIndex]
      .Quest.Requiriments[4];
    if (Self.PlayerQuests[QuestIndex].Quest.Requiriments[0] = 0) then
      Packet.IsCompleted := BYTE(True);
    Self.SendPacket(Packet, Packet.Header.size);
    if(Self.PlayerQuests[QuestIndex].Quest.NPCID < 2047) then
      auxInt := Self.PlayerQuests[QuestIndex].Quest.NPCID + 2047
    else
      auxInt := Self.PlayerQuests[QuestIndex].Quest.NPCID;

    if(Self.Base.VisibleNPCS.Contains(auxInt)) then
    begin
      Servers[Self.ChannelIndex].NPCS[auxInt].Base.SendRemoveMob(DELETE_NORMAL, self.Base.ClientID, False);
      Servers[Self.ChannelIndex].NPCS[auxInt].Base.SendCreateMob(SPAWN_NORMAL, self.Base.ClientID, False);
    end;
  end;
end;
procedure TPlayer.RemoveQuest(QuestID: DWORD);
var
  Packet: TAbandonQuestPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $32F;
  Packet.QuestID := QuestID;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendExpGoldMsg(Exp, Gold: DWORD);
var
  Packet: TSendExpGoldMsg;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $11B;
  Packet.Exp := Exp;
  Packet.Gold := Gold;
  Self.SendPacket(Packet, Packet.Header.size);
end;
function TPlayer.QuestExists(QuestID: WORD; out QuestIndex: WORD): Boolean;
var
  i: WORD;
begin
  Result := FALSE;
  for i := 0 to 49 do
  begin
    if (Self.PlayerQuests[i].ID = QuestID) then
    begin
      Result := True;
      QuestIndex := i;
      Break;
    end;
  end;
end;
function TPlayer.SearchEmptyQuestIndex(): WORD;
var
  i: WORD;
begin
  Result := 255;
  for i := 0 to 49 do
  begin
    if (Self.PlayerQuests[i].ID = 0) then
    begin
      Result := i;
      Break;
    end;
  end;
end;
function TPlayer.QuestCount(): WORD;
var
  i: WORD;
begin
  Result := 0;
  for i := 0 to 49 do
  begin
    if not(Self.PlayerQuests[i].ID = 0) then
    begin
      Inc(Result);
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Get Event Itens'}
procedure TPlayer.GetAllEventItems();
type
  TEventItem = record
    ItemID: WORD;
    Amount: WORD;
  end;
var
  // Itens: Array [0 .. 19] of TEventItem;
  SlotsAvaliable: WORD;
  ItemID: WORD;
  i: WORD;
  MySQLComp, MySQLCompAux: TQuery;
begin
  MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);
  if not(MySQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GetAllEventItems]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetAllEventItems]', TlogType.Error);
    MySQLComp.Destroy;
    Exit;
  end;
  //if(Assigned())
  //if(Assigned())
  MySQLComp.SetQuery
    (format('SELECT item_id, refine FROM items WHERE owner_id=%d AND slot_type=%d',
    [Self.Character.Base.CharIndex, EVENT_ITEM]));
  MySQLComp.Run();

  if (MySQLComp.Query.RecordCount = 0) then
  begin
    Self.SendClientMessage('Não existem itens de evento para receber.', 16, 16);
    Self.SendSignal(Self.Base.clientId, $359);
    MySQLComp.Destroy;
    Exit;
  end
  else
  begin
    SlotsAvaliable := TItemFunctions.GetInvAvailableSlots(Self);

    if (SlotsAvaliable = 0) then
    begin
      Self.SendClientMessage('Inventário cheio.');
      Self.SendSignal(Self.Base.clientId, $359);
      MySQLComp.Destroy;
      Exit;
    end;

    if (SlotsAvaliable > MySQLComp.Query.RecordCount) then
      SlotsAvaliable := MySQLComp.Query.RecordCount;

    MySQLComp.Query.First;
    for i := 0 to (SlotsAvaliable - 1) do
    begin
      ItemID := WORD(MySQLComp.Query.FieldByName('item_id').AsInteger);

      TItemFunctions.PutItem(Self, ItemID,
        WORD(MySQLComp.Query.FieldByName('refine').AsInteger));

      {MySQLCompAux := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
        AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
        AnsiString(MYSQL_DATABASE), True);

      if not(MySQLCompAux.Query.Connection.Connected) then
      begin
        Logger.Write('Falha de conexão individual com mysql.[GetAllEventItemsAux]',
          TlogType.Warnings);
        Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetAllEventItemsAux]', TlogType.Error);
        MySQLCompAux.Destroy;
        Exit;
      end;}

      MySQLCompAux := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
        AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
        AnsiString(MYSQL_DATABASE), True);
      if not(MySQLCompAux.Query.Connection.Connected) then
      begin
        Logger.Write('Falha de conexão individual com mysql.[GetAllEventItems]',
          TlogType.Warnings);
        Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetAllEventItems]', TlogType.Error);
        MySQLCompAux.Destroy;
        Exit;
      end;

      MySQLCompAux.Query.Connection.StartTransaction;

      MySQLCompAux.SetQuery
        (format('DELETE FROM items WHERE owner_id=%d AND item_id=%d AND slot_type=17',
        [Self.Character.Base.CharIndex, ItemID]));
      MySQLCompAux.Run(False);
      MySQLCompAux.Query.Connection.Commit;
      //MSSQLCompAux.Query.Connection.CommitTrans;

      MySQLCompAux.Destroy;

      MySQLComp.Query.Next;
    end;

    Self.SendClientMessage
      ('Não existem mais itens de evento para receber.', 16, 16);
    Self.SendSignal(Self.Base.clientId, $359);
  end;

  MySQLComp.Destroy;
end;
function TPlayer.DiaryItemAvaliable(): Boolean;
var
  TimeInString: String;
  LastReceived: TDateTime;
  SQLComp: TQuery;
begin
  Result := FALSE;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[DiaryItemAvaliable]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[DiaryItemAvaliable]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    SQLComp.SetQuery
      (format('SELECT last_diary_event FROM characters WHERE id=%d',
      [Self.Character.Base.CharIndex]));
    SQLComp.Run();
    if (SQLComp.Query.RecordCount = 0) then
    begin
      SQLComp.Destroy;
      Exit;
    end;
    TimeInString := SQLComp.Query.FieldByName
      ('last_diary_event').AsString;
    if (TimeInString = '') then
    begin
      Result := True;
      SQLComp.Query.Connection.StartTransaction;
      SQLComp.SetQuery
        (format('UPDATE characters SET last_diary_event=%s WHERE id=%d',
        [QuotedStr(DateTimeToStr(IncHour(Now, -25))), Self.Character.Base.CharIndex]));
      SQLComp.Run(False);
      SQLComp.Query.Connection.Commit;
      SQLComp.Destroy;
      Exit;
    end;

    LastReceived := StrToDateTime(TimeInString);

    if (HoursBetween(Now, LastReceived) >= 24) then
    begin
      SQLComp.Query.Connection.StartTransaction;
      SQLComp.SetQuery
        (format('UPDATE characters SET last_diary_event=%s WHERE id=%d',
        [QuotedStr(DateTimeToStr(Now)), Self.Character.Base.CharIndex]));
      SQLComp.Run(False);
      SQLComp.Query.Connection.Commit;
      SQLComp.Destroy;
      Result := True;
      Exit;
    end;

    SQLComp.Destroy;
  except
    on E: Exception do
    begin
      Logger.Write('TPlayer.DiaryItemAvaliable ' + E.Message, TlogType.Error);
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Titles'}
function TPlayer.GetTitleLevelValue(Slot, Level: BYTE): WORD;
var
  X: BYTE;
begin
  // X := 0;
  X := (Slot * 4) + (Level - 1);
  if (Level > 1) then
  begin
    Result := (1 shl X) + Self.GetTitleLevelValue(Slot, Level - 1);
  end
  else
  begin
    Result := (1 shl X);
  end;
end;
{$ENDREGION}
{$REGION 'Dungeons'}
procedure TPlayer.SendDungeonLobby(InParty: Boolean; Dungeon, Dificult: BYTE);
var
  Packet: TSendPlayersLobbyDungeon;
  i, Cnt: WORD;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $145;
  Packet.Header.Index := Self.Base.clientid;

  Packet.Dungeon := Dungeon;
  Packet.Dificult := Dificult;

  if (InParty) then
  begin
    // verificar o negocio de raids

    Cnt := 0;

    for i in Self.Party.Members do
    begin
      Packet.PlayersParty1[Cnt] := Servers[Self.ChannelIndex].Players[i]
        .Base.clientId;
      Packet.UnkPlayersRecord[Cnt] := Cnt;
      Servers[Self.ChannelIndex].Players[i].DungeonLobbyIndex := Dungeon;
      Servers[Self.ChannelIndex].Players[i].DungeonLobbyDificult := Dificult;
      Inc(Cnt);
    end;

    Self.Party.SendToParty(Packet, Packet.Header.size);
  end
  else
  begin
    Packet.PlayersParty1[0] := Self.Base.clientId;
    Packet.UnkPlayersRecord[0] := 0;
    Self.DungeonLobbyIndex := Dungeon;
    Self.DungeonLobbyDificult := Dificult;

    Self.SendPacket(Packet, Packet.Header.size);
  end;
end;
function TPlayer.GetFreeDungeonInstance(): BYTE;
var
  i: BYTE;
begin
  Result := 255;
  for i := Low(DungeonInstances) to High(DungeonInstances) do
  begin
    if (DungeonInstances[i].Index = 0) then
    begin
      Result := i;
      Break;
    end;
  end;
end;
procedure TPlayer.CreateDungeonInstance(InParty: Boolean;
Dungeon, Dificult: BYTE);
var
  i, J, k, Cnt: WORD;
  FreeId: BYTE;
begin
  /// /example for clear list
  /// //Servers[Self.ChannelIndex].Players[i].Base.ClearTargetList
  if (InParty) then
  begin
    case Dungeon of
      DUNGEON_ZANTORIAN_CITADEL:
        begin
          for i in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[i].Base.WalkTo
              (Servers[Self.ChannelIndex].DGUrsula[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[i].InDungeon := True;
            Servers[Self.ChannelIndex].Players[i].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[i].DungeonIDDificult := Dificult;
            if (i = Servers[Self.ChannelIndex].Players[i].Party.Members.First)
            then
            begin
              FreeId := Servers[Self.ChannelIndex].Players[i]
                .GetFreeDungeonInstance;
              if (FreeId = 255) then
              begin
                Self.SendClientMessage('Dungeon Instances Full.');
                Exit;
              end;
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
                .DungeonInstanceID := FreeId;
              DungeonInstances[FreeId].Index := FreeId;
              DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
                .Players[i].Party;
              DungeonInstances[FreeId].CreateTime := Now;
              DungeonInstances[FreeId].DungeonID := Dungeon;
              DungeonInstances[FreeId].Dificult := Dificult;
              Cnt := 1;
              for J := Low(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGUrsula
                [Dificult].MOBS.TMobS) do
              begin
                for k := 0 to 49 do
                begin
                  if (Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].MobsP[k].Base.clientId = 0) then
                    Continue;
                  DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].IntName;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS[J]
                    .MobsP[k].Base.clientId, Self.ChannelIndex);
                  DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].InitHP;
                  DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                    DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                  DungeonInstances[FreeId].MOBS[Cnt].Position :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS[J]
                    .MobsP[k].InitPos;
                  DungeonInstances[FreeId].MOBS[Cnt]
                    .Base.PlayerCharacter.LastPos := DungeonInstances[FreeId]
                    .MOBS[Cnt].Position;
                  DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].MobLevel;
                  DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].MobExp;
                  DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].MobType;
                  DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS[J]
                    .MobElevation;
                  DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].Cabeca;
                  DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult]
                    .MOBS.TMobS[J].Perna;
                  DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].FisAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].MagAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].FisDef;
                  DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].MagDef;
                  Move(Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                  case Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].DungeonDropIndex of
                    11, 21, 31:
                      begin
                        Move(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                          .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                          [Cnt].Drops,
                          sizeof(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                          .MobsDrop.SemCoroa));
                      end;
                    12, 22, 32:
                      begin
                        Move(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                          .MobsDrop.CoroaPrata,
                          DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                          sizeof(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                          .MobsDrop.CoroaPrata));
                      end;
                    13, 23, 33:
                      begin
                        Move(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                          .MobsDrop.CoroaDourada,
                          DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                          sizeof(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                          .MobsDrop.CoroaDourada));
                      end;
                  end;
                  Inc(Cnt);
                end;
              end;
              DungeonInstances[FreeId].InstanceOnline := True;
              DungeonInstances[FreeId].MainThread :=
                TDungeonMainThread.Create(1000, Self.ChannelIndex, FreeId);
            end;
            Servers[Self.ChannelIndex].Players[i].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
          end;
        end;
      DUNGEON_MARAUDER_HOLD:
        begin
          for i in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[i].Base.WalkTo
              (Servers[Self.ChannelIndex].DGEvgInf[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[i].InDungeon := True;
            Servers[Self.ChannelIndex].Players[i].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[i].DungeonIDDificult := Dificult;
            if (i = Servers[Self.ChannelIndex].Players[i].Party.Members.First)
            then
            begin
              FreeId := Servers[Self.ChannelIndex].Players[i]
                .GetFreeDungeonInstance;
              if (FreeId = 255) then
              begin
                Self.SendClientMessage('Dungeon Instances Full.');
                Exit;
              end;
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
                .DungeonInstanceID := FreeId;
              DungeonInstances[FreeId].Index := FreeId;
              DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
                .Players[i].Party;
              DungeonInstances[FreeId].CreateTime := Now;
              DungeonInstances[FreeId].DungeonID := Dungeon;
              DungeonInstances[FreeId].Dificult := Dificult;
              Cnt := 1;
              for J := Low(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGEvgInf
                [Dificult].MOBS.TMobS) do
              begin
                for k := 0 to 49 do
                begin
                  if (Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].MobsP[k].Base.clientId = 0) then
                    Continue;
                  DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].IntName;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS[J]
                    .MobsP[k].Base.clientId, Self.ChannelIndex);
                  DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].InitHP;
                  DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                    DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                  DungeonInstances[FreeId].MOBS[Cnt].Position :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS[J]
                    .MobsP[k].InitPos;
                  DungeonInstances[FreeId].MOBS[Cnt]
                    .Base.PlayerCharacter.LastPos := DungeonInstances[FreeId]
                    .MOBS[Cnt].Position;
                  DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].MobLevel;
                  DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].MobExp;
                  DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].MobType;
                  DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS[J]
                    .MobElevation;
                  DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].Cabeca;
                  DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                    .MOBS.TMobS[J].Perna;
                  DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].FisAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].MagAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].FisDef;
                  DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].MagDef;
                  Move(Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                  case Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].DungeonDropIndex of
                    41, 51, 61:
                      begin
                        Move(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                          .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                          [Cnt].Drops,
                          sizeof(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                          .MobsDrop.SemCoroa));
                      end;
                    42, 52, 62:
                      begin
                        Move(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                          .MobsDrop.CoroaPrata,
                          DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                          sizeof(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                          .MobsDrop.CoroaPrata));
                      end;
                    43, 53, 63:
                      begin
                        Move(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                          .MobsDrop.CoroaDourada,
                          DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                          sizeof(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                          .MobsDrop.CoroaDourada));
                      end;
                  end;
                  Inc(Cnt);
                end;
              end;
              DungeonInstances[FreeId].InstanceOnline := True;
              DungeonInstances[FreeId].MainThread :=
                TDungeonMainThread.Create(1000, Self.ChannelIndex, FreeId);
            end;
            Servers[Self.ChannelIndex].Players[i].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
          end;
        end;
      DUNGEON_MARAUDER_CABIN:
        begin
          for i in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[i].Base.WalkTo
              (Servers[Self.ChannelIndex].DGEvgSup[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[i].InDungeon := True;
            Servers[Self.ChannelIndex].Players[i].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[i].DungeonIDDificult := Dificult;
            if (i = Servers[Self.ChannelIndex].Players[i].Party.Members.First)
            then
            begin
              FreeId := Servers[Self.ChannelIndex].Players[i]
                .GetFreeDungeonInstance;
              if (FreeId = 255) then
              begin
                Self.SendClientMessage('Dungeon Instances Full.');
                Exit;
              end;
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
                .DungeonInstanceID := FreeId;
              DungeonInstances[FreeId].Index := FreeId;
              DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
                .Players[i].Party;
              DungeonInstances[FreeId].CreateTime := Now;
              DungeonInstances[FreeId].DungeonID := Dungeon;
              DungeonInstances[FreeId].Dificult := Dificult;
              Cnt := 1;
              for J := Low(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGEvgSup
                [Dificult].MOBS.TMobS) do
              begin
                for k := 0 to 49 do
                begin
                  if (Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].MobsP[k].Base.clientId = 0) then
                    Continue;
                  DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].IntName;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS[J]
                    .MobsP[k].Base.clientId, Self.ChannelIndex);
                  DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].InitHP;
                  DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                    DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                  DungeonInstances[FreeId].MOBS[Cnt].Position :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS[J]
                    .MobsP[k].InitPos;
                  DungeonInstances[FreeId].MOBS[Cnt]
                    .Base.PlayerCharacter.LastPos := DungeonInstances[FreeId]
                    .MOBS[Cnt].Position;
                  DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].MobLevel;
                  DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].MobExp;
                  DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].MobType;
                  DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS[J]
                    .MobElevation;
                  DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].Cabeca;
                  DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                    .MOBS.TMobS[J].Perna;
                  DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].FisAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].MagAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].FisDef;
                  DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].MagDef;
                  Move(Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                  case Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].DungeonDropIndex of
                    71, 81, 91:
                      begin
                        Move(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                          .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                          [Cnt].Drops,
                          sizeof(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                          .MobsDrop.SemCoroa));
                      end;
                    72, 82, 92:
                      begin
                        Move(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                          .MobsDrop.CoroaPrata,
                          DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                          sizeof(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                          .MobsDrop.CoroaPrata));
                      end;
                    73, 83, 93:
                      begin
                        Move(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                          .MobsDrop.CoroaDourada,
                          DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                          sizeof(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                          .MobsDrop.CoroaDourada));
                      end;
                  end;
                  Inc(Cnt);
                end;
              end;
              DungeonInstances[FreeId].InstanceOnline := True;
              DungeonInstances[FreeId].MainThread :=
                TDungeonMainThread.Create(1000, Self.ChannelIndex, FreeId);
            end;
            Servers[Self.ChannelIndex].Players[i].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
          end;
        end;
      DUNGEON_LOST_MINES:
        begin
          for i in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[i].Base.WalkTo
              (Servers[Self.ChannelIndex].DGMines1[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[i].InDungeon := True;
            Servers[Self.ChannelIndex].Players[i].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[i].DungeonIDDificult := Dificult;
            if (i = Servers[Self.ChannelIndex].Players[i].Party.Members.First)
            then
            begin
              FreeId := Servers[Self.ChannelIndex].Players[i]
                .GetFreeDungeonInstance;
              if (FreeId = 255) then
              begin
                Self.SendClientMessage('Dungeon Instances Full.');
                Exit;
              end;
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
                .DungeonInstanceID := FreeId;
              DungeonInstances[FreeId].Index := FreeId;
              DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
                .Players[i].Party;
              DungeonInstances[FreeId].CreateTime := Now;
              DungeonInstances[FreeId].DungeonID := Dungeon;
              DungeonInstances[FreeId].Dificult := Dificult;
              Cnt := 1;
              for J := Low(Servers[Self.ChannelIndex].DGMines1[Dificult]
                .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGMines1
                [Dificult].MOBS.TMobS) do
              begin
                for k := 0 to 49 do
                begin
                  if (Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].MobsP[k].Base.clientId = 0) then
                    Continue;
                  DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].IntName;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS[J]
                    .MobsP[k].Base.clientId, Self.ChannelIndex);
                  DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].InitHP;
                  DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                    DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                  DungeonInstances[FreeId].MOBS[Cnt].Position :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS[J]
                    .MobsP[k].InitPos;
                  DungeonInstances[FreeId].MOBS[Cnt]
                    .Base.PlayerCharacter.LastPos := DungeonInstances[FreeId]
                    .MOBS[Cnt].Position;
                  DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].MobLevel;
                  DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].MobExp;
                  DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].MobType;
                  DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS[J]
                    .MobElevation;
                  DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].Cabeca;
                  DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult]
                    .MOBS.TMobS[J].Perna;
                  DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].FisAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].MagAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].FisDef;
                  DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].MagDef;
                  Move(Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                  case Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].DungeonDropIndex of
                    101, 201, 301:
                      begin
                        Move(Servers[Self.ChannelIndex].DGMines1[Dificult]
                          .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                          [Cnt].Drops,
                          sizeof(Servers[Self.ChannelIndex].DGMines1[Dificult]
                          .MobsDrop.SemCoroa));
                      end;
                    102, 202, 302:
                      begin
                        Move(Servers[Self.ChannelIndex].DGMines1[Dificult]
                          .MobsDrop.CoroaPrata,
                          DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                          sizeof(Servers[Self.ChannelIndex].DGMines1[Dificult]
                          .MobsDrop.CoroaPrata));
                      end;
                    103, 203, 303:
                      begin
                        Move(Servers[Self.ChannelIndex].DGMines1[Dificult]
                          .MobsDrop.CoroaDourada,
                          DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                          sizeof(Servers[Self.ChannelIndex].DGMines1[Dificult]
                          .MobsDrop.CoroaDourada));
                      end;
                  end;
                  Inc(Cnt);
                end;
              end;
              DungeonInstances[FreeId].InstanceOnline := True;
              DungeonInstances[FreeId].MainThread :=
                TDungeonMainThread.Create(1000, Self.ChannelIndex, FreeId);
            end;
            Servers[Self.ChannelIndex].Players[i].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
          end;
        end;
      DUNGEON_KINARY_AVIARY:
        begin
          for i in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[i].Base.WalkTo
              (Servers[Self.ChannelIndex].DGKinary[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[i].InDungeon := True;
            Servers[Self.ChannelIndex].Players[i].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[i].DungeonIDDificult := Dificult;
            if (i = Servers[Self.ChannelIndex].Players[i].Party.Members.First)
            then
            begin
              FreeId := Servers[Self.ChannelIndex].Players[i]
                .GetFreeDungeonInstance;
              if (FreeId = 255) then
              begin
                Self.SendClientMessage('Dungeon Instances Full.');
                Exit;
              end;
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
                .DungeonInstanceID := FreeId;
              DungeonInstances[FreeId].Index := FreeId;
              DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
                .Players[i].Party;
              DungeonInstances[FreeId].CreateTime := Now;
              DungeonInstances[FreeId].DungeonID := Dungeon;
              DungeonInstances[FreeId].Dificult := Dificult;
              Cnt := 1;
              for J := Low(Servers[Self.ChannelIndex].DGKinary[Dificult]
                .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGKinary
                [Dificult].MOBS.TMobS) do
              begin
                for k := 0 to 49 do
                begin
                  if (Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].MobsP[k].Base.clientId = 0) then
                    Continue;
                  DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].IntName;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS[J]
                    .MobsP[k].Base.clientId, Self.ChannelIndex);
                  DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].InitHP;
                  DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                    DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                  DungeonInstances[FreeId].MOBS[Cnt].Position :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS[J]
                    .MobsP[k].InitPos;
                  DungeonInstances[FreeId].MOBS[Cnt]
                    .Base.PlayerCharacter.LastPos := DungeonInstances[FreeId]
                    .MOBS[Cnt].Position;
                  DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].MobLevel;
                  DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].MobExp;
                  DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].MobType;
                  DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS[J]
                    .MobElevation;
                  DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].Cabeca;
                  DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult]
                    .MOBS.TMobS[J].Perna;
                  DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].FisAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].MagAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].FisDef;
                  DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].MagDef;
                  Move(Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                  case Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].DungeonDropIndex of
                    101, 201, 301:
                      begin
                        Move(Servers[Self.ChannelIndex].DGKinary[Dificult]
                          .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                          [Cnt].Drops,
                          sizeof(Servers[Self.ChannelIndex].DGKinary[Dificult]
                          .MobsDrop.SemCoroa));
                      end;
                    102, 202, 302:
                      begin
                        Move(Servers[Self.ChannelIndex].DGKinary[Dificult]
                          .MobsDrop.CoroaPrata,
                          DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                          sizeof(Servers[Self.ChannelIndex].DGKinary[Dificult]
                          .MobsDrop.CoroaPrata));
                      end;
                    103, 203, 303:
                      begin
                        Move(Servers[Self.ChannelIndex].DGKinary[Dificult]
                          .MobsDrop.CoroaDourada,
                          DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                          sizeof(Servers[Self.ChannelIndex].DGKinary[Dificult]
                          .MobsDrop.CoroaDourada));
                      end;
                  end;
                  Inc(Cnt);
                end;
              end;
              DungeonInstances[FreeId].InstanceOnline := True;
              DungeonInstances[FreeId].MainThread :=
                TDungeonMainThread.Create(1000, Self.ChannelIndex, FreeId);
            end;
            Servers[Self.ChannelIndex].Players[i].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
          end;
        end;
    end;
  end
  else
  begin
    if (TParty.CreateParty(Self.Base.clientId, Self.ChannelIndex)) then
    begin
      Self.RefreshParty;
    end
    else
    begin
      Self.SendClientMessage('Não foi possível criar o grupo.');
      Exit;
    end;
    case Dungeon of
      DUNGEON_ZANTORIAN_CITADEL:
        begin
          for i in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[i].Base.WalkTo
              (Servers[Self.ChannelIndex].DGUrsula[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[i].InDungeon := True;
            Servers[Self.ChannelIndex].Players[i].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[i].DungeonIDDificult := Dificult;
            FreeId := Servers[Self.ChannelIndex].Players[i]
              .GetFreeDungeonInstance;
            if (FreeId = 255) then
            begin
              Self.SendClientMessage('Dungeon Instances Full.');
              Exit;
            end;
            Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID := FreeId;
            DungeonInstances[FreeId].Index := FreeId;
            DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
              .Players[i].Party;
            DungeonInstances[FreeId].CreateTime := Now;
            DungeonInstances[FreeId].DungeonID := Dungeon;
            DungeonInstances[FreeId].Dificult := Dificult;
            Cnt := 1;
            for J := Low(Servers[Self.ChannelIndex].DGUrsula[Dificult]
              .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGUrsula[Dificult]
              .MOBS.TMobS) do
            begin
              for k := 0 to 49 do
              begin
                if (Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId = 0) then
                  Continue;
                DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                  [J].IntName;
                DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId, Self.ChannelIndex);
                DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                  [J].InitHP;
                DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                DungeonInstances[FreeId].MOBS[Cnt].Position :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS[J]
                  .MobsP[k].InitPos;
                DungeonInstances[FreeId].MOBS[Cnt].Base.PlayerCharacter.LastPos
                  := DungeonInstances[FreeId].MOBS[Cnt].Position;
                DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                  [J].MobLevel;
                DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                  [J].MobExp;
                DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                  [J].MobType;
                DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS[J]
                  .MobElevation;
                DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                  [J].Cabeca;
                DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult]
                  .MOBS.TMobS[J].Perna;
                DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                  [J].FisAtk;
                DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                  [J].MagAtk;
                DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                  [J].FisDef;
                DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                  [J].MagDef;
                Move(Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS[J]
                  .Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                case Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS[J]
                  .DungeonDropIndex of
                  11, 21, 31:
                    begin
                      Move(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                        .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        sizeof(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                        .MobsDrop.SemCoroa));
                    end;
                  12, 22, 32:
                    begin
                      Move(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                        .MobsDrop.CoroaPrata, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        sizeof(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                        .MobsDrop.CoroaPrata));
                    end;
                  13, 23, 33:
                    begin
                      Move(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                        .MobsDrop.CoroaDourada,
                        DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                        sizeof(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                        .MobsDrop.CoroaDourada));
                    end;
                end;
                Inc(Cnt);
              end;
            end;
            Servers[Self.ChannelIndex].Players[i].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
            DungeonInstances[FreeId].InstanceOnline := True;
            DungeonInstances[FreeId].MainThread :=
              TDungeonMainThread.Create(1000, Self.ChannelIndex, FreeId);
          end;
        end;
      DUNGEON_MARAUDER_HOLD:
        begin
          for i in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[i].Base.WalkTo
              (Servers[Self.ChannelIndex].DGEvgInf[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[i].InDungeon := True;
            Servers[Self.ChannelIndex].Players[i].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[i].DungeonIDDificult := Dificult;
            FreeId := Servers[Self.ChannelIndex].Players[i]
              .GetFreeDungeonInstance;
            if (FreeId = 255) then
            begin
              Self.SendClientMessage('Dungeon Instances Full.');
              Exit;
            end;
            Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID := FreeId;
            DungeonInstances[FreeId].Index := FreeId;
            DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
              .Players[i].Party;
            DungeonInstances[FreeId].CreateTime := Now;
            DungeonInstances[FreeId].DungeonID := Dungeon;
            DungeonInstances[FreeId].Dificult := Dificult;
            Cnt := 1;
            for J := Low(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
              .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
              .MOBS.TMobS) do
            begin
              for k := 0 to 49 do
              begin
                if (Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId = 0) then
                  Continue;
                DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                  [J].IntName;
                DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId, Self.ChannelIndex);
                DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                  [J].InitHP;
                DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                DungeonInstances[FreeId].MOBS[Cnt].Position :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS[J]
                  .MobsP[k].InitPos;
                DungeonInstances[FreeId].MOBS[Cnt].Base.PlayerCharacter.LastPos
                  := DungeonInstances[FreeId].MOBS[Cnt].Position;
                DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                  [J].MobLevel;
                DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                  [J].MobExp;
                DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                  [J].MobType;
                DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS[J]
                  .MobElevation;
                DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                  [J].Cabeca;
                DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                  .MOBS.TMobS[J].Perna;
                DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                  [J].FisAtk;
                DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                  [J].MagAtk;
                DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                  [J].FisDef;
                DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                  [J].MagDef;
                Move(Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS[J]
                  .Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                case Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS[J]
                  .DungeonDropIndex of
                  41, 51, 61:
                    begin
                      Move(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                        .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        sizeof(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                        .MobsDrop.SemCoroa));
                    end;
                  42, 52, 62:
                    begin
                      Move(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                        .MobsDrop.CoroaPrata, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        sizeof(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                        .MobsDrop.CoroaPrata));
                    end;
                  43, 53, 63:
                    begin
                      Move(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                        .MobsDrop.CoroaDourada,
                        DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                        sizeof(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                        .MobsDrop.CoroaDourada));
                    end;
                end;
                Inc(Cnt);
              end;
            end;
            Servers[Self.ChannelIndex].Players[i].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
            DungeonInstances[FreeId].InstanceOnline := True;
            DungeonInstances[FreeId].MainThread :=
              TDungeonMainThread.Create(1000, Self.ChannelIndex, FreeId);
          end;
        end;
      DUNGEON_MARAUDER_CABIN:
        begin
          for i in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[i].Base.WalkTo
              (Servers[Self.ChannelIndex].DGEvgSup[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[i].InDungeon := True;
            Servers[Self.ChannelIndex].Players[i].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[i].DungeonIDDificult := Dificult;
            FreeId := Servers[Self.ChannelIndex].Players[i]
              .GetFreeDungeonInstance;
            if (FreeId = 255) then
            begin
              Self.SendClientMessage('Dungeon Instances Full.');
              Exit;
            end;
            Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID := FreeId;
            DungeonInstances[FreeId].Index := FreeId;
            DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
              .Players[i].Party;
            DungeonInstances[FreeId].CreateTime := Now;
            DungeonInstances[FreeId].DungeonID := Dungeon;
            DungeonInstances[FreeId].Dificult := Dificult;
            Cnt := 1;
            for J := Low(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
              .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
              .MOBS.TMobS) do
            begin
              for k := 0 to 49 do
              begin
                if (Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId = 0) then
                  Continue;
                DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                  [J].IntName;
                DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId, Self.ChannelIndex);
                DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                  [J].InitHP;
                DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                DungeonInstances[FreeId].MOBS[Cnt].Position :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS[J]
                  .MobsP[k].InitPos;
                DungeonInstances[FreeId].MOBS[Cnt].Base.PlayerCharacter.LastPos
                  := DungeonInstances[FreeId].MOBS[Cnt].Position;
                DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                  [J].MobLevel;
                DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                  [J].MobExp;
                DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                  [J].MobType;
                DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS[J]
                  .MobElevation;
                DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                  [J].Cabeca;
                DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                  .MOBS.TMobS[J].Perna;
                DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                  [J].FisAtk;
                DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                  [J].MagAtk;
                DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                  [J].FisDef;
                DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                  [J].MagDef;
                Move(Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS[J]
                  .Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                case Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS[J]
                  .DungeonDropIndex of
                  71, 81, 91:
                    begin
                      Move(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                        .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        sizeof(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                        .MobsDrop.SemCoroa));
                    end;
                  72, 82, 92:
                    begin
                      Move(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                        .MobsDrop.CoroaPrata, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        sizeof(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                        .MobsDrop.CoroaPrata));
                    end;
                  73, 83, 93:
                    begin
                      Move(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                        .MobsDrop.CoroaDourada,
                        DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                        sizeof(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                        .MobsDrop.CoroaDourada));
                    end;
                end;
                Inc(Cnt);
              end;
            end;
            Servers[Self.ChannelIndex].Players[i].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
            DungeonInstances[FreeId].InstanceOnline := True;
            DungeonInstances[FreeId].MainThread :=
              TDungeonMainThread.Create(1000, Self.ChannelIndex, FreeId);
          end;
        end;
      DUNGEON_LOST_MINES:
        begin
          for i in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[i].Base.WalkTo
              (Servers[Self.ChannelIndex].DGMines1[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[i].InDungeon := True;
            Servers[Self.ChannelIndex].Players[i].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[i].DungeonIDDificult := Dificult;
            FreeId := Servers[Self.ChannelIndex].Players[i]
              .GetFreeDungeonInstance;
            if (FreeId = 255) then
            begin
              Self.SendClientMessage('Dungeon Instances Full.');
              Exit;
            end;
            Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID := FreeId;
            DungeonInstances[FreeId].Index := FreeId;
            DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
              .Players[i].Party;
            DungeonInstances[FreeId].CreateTime := Now;
            DungeonInstances[FreeId].DungeonID := Dungeon;
            DungeonInstances[FreeId].Dificult := Dificult;
            Cnt := 1;
            for J := Low(Servers[Self.ChannelIndex].DGMines1[Dificult]
              .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGMines1[Dificult]
              .MOBS.TMobS) do
            begin
              for k := 0 to 49 do
              begin
                if (Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId = 0) then
                  Continue;
                DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                  [J].IntName;
                DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId, Self.ChannelIndex);
                DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                  [J].InitHP;
                DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                DungeonInstances[FreeId].MOBS[Cnt].Position :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS[J]
                  .MobsP[k].InitPos;
                DungeonInstances[FreeId].MOBS[Cnt].Base.PlayerCharacter.LastPos
                  := DungeonInstances[FreeId].MOBS[Cnt].Position;
                DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                  [J].MobLevel;
                DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                  [J].MobExp;
                DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                  [J].MobType;
                DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS[J]
                  .MobElevation;
                DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                  [J].Cabeca;
                DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult]
                  .MOBS.TMobS[J].Perna;
                DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                  [J].FisAtk;
                DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                  [J].MagAtk;
                DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                  [J].FisDef;
                DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                  [J].MagDef;
                Move(Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS[J]
                  .Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                case Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS[J]
                  .DungeonDropIndex of
                  101, 201, 301:
                    begin
                      Move(Servers[Self.ChannelIndex].DGMines1[Dificult]
                        .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        sizeof(Servers[Self.ChannelIndex].DGMines1[Dificult]
                        .MobsDrop.SemCoroa));
                    end;
                  102, 202, 302:
                    begin
                      Move(Servers[Self.ChannelIndex].DGMines1[Dificult]
                        .MobsDrop.CoroaPrata, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        sizeof(Servers[Self.ChannelIndex].DGMines1[Dificult]
                        .MobsDrop.CoroaPrata));
                    end;
                  103, 203, 303:
                    begin
                      Move(Servers[Self.ChannelIndex].DGMines1[Dificult]
                        .MobsDrop.CoroaDourada,
                        DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                        sizeof(Servers[Self.ChannelIndex].DGMines1[Dificult]
                        .MobsDrop.CoroaDourada));
                    end;
                end;
                Inc(Cnt);
              end;
            end;
            Servers[Self.ChannelIndex].Players[i].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
            DungeonInstances[FreeId].InstanceOnline := True;
            DungeonInstances[FreeId].MainThread :=
              TDungeonMainThread.Create(1000, Self.ChannelIndex, FreeId);
          end;
        end;
      DUNGEON_KINARY_AVIARY:
        begin
          for i in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[i].Base.WalkTo
              (Servers[Self.ChannelIndex].DGKinary[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[i].InDungeon := True;
            Servers[Self.ChannelIndex].Players[i].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[i].DungeonIDDificult := Dificult;
            FreeId := Servers[Self.ChannelIndex].Players[i]
              .GetFreeDungeonInstance;
            if (FreeId = 255) then
            begin
              Self.SendClientMessage('Dungeon Instances Full.');
              Exit;
            end;
            Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID := FreeId;
            DungeonInstances[FreeId].Index := FreeId;
            DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
              .Players[i].Party;
            DungeonInstances[FreeId].CreateTime := Now;
            DungeonInstances[FreeId].DungeonID := Dungeon;
            DungeonInstances[FreeId].Dificult := Dificult;
            Cnt := 1;
            for J := Low(Servers[Self.ChannelIndex].DGKinary[Dificult]
              .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGKinary[Dificult]
              .MOBS.TMobS) do
            begin
              for k := 0 to 49 do
              begin
                if (Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId = 0) then
                  Continue;
                DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                  [J].IntName;
                DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId, Self.ChannelIndex);
                DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                  [J].InitHP;
                DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                DungeonInstances[FreeId].MOBS[Cnt].Position :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS[J]
                  .MobsP[k].InitPos;
                DungeonInstances[FreeId].MOBS[Cnt].Base.PlayerCharacter.LastPos
                  := DungeonInstances[FreeId].MOBS[Cnt].Position;
                DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                  [J].MobLevel;
                DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                  [J].MobExp;
                DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                  [J].MobType;
                DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS[J]
                  .MobElevation;
                DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                  [J].Cabeca;
                DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult]
                  .MOBS.TMobS[J].Perna;
                DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                  [J].FisAtk;
                DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                  [J].MagAtk;
                DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                  [J].FisDef;
                DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                  [J].MagDef;
                Move(Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS[J]
                  .Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                case Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS[J]
                  .DungeonDropIndex of
                  401, 501, 601:
                    begin
                      Move(Servers[Self.ChannelIndex].DGKinary[Dificult]
                        .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        sizeof(Servers[Self.ChannelIndex].DGKinary[Dificult]
                        .MobsDrop.SemCoroa));
                    end;
                  402, 502, 602:
                    begin
                      Move(Servers[Self.ChannelIndex].DGKinary[Dificult]
                        .MobsDrop.CoroaPrata, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        sizeof(Servers[Self.ChannelIndex].DGKinary[Dificult]
                        .MobsDrop.CoroaPrata));
                    end;
                  403, 503, 603:
                    begin
                      Move(Servers[Self.ChannelIndex].DGKinary[Dificult]
                        .MobsDrop.CoroaDourada,
                        DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                        sizeof(Servers[Self.ChannelIndex].DGKinary[Dificult]
                        .MobsDrop.CoroaDourada));
                    end;
                end;
                Inc(Cnt);
              end;
            end;
            Servers[Self.ChannelIndex].Players[i].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
            DungeonInstances[FreeId].InstanceOnline := True;
            DungeonInstances[FreeId].MainThread :=
              TDungeonMainThread.Create(1000, Self.ChannelIndex, FreeId);
          end;
        end;
    end;
  end;
end;
procedure TPlayer.SendSpawnMobDungeon(MOB: PMobsStructDungeonInstance);
var
  Packet: TSpawnMobPacket;
begin
  ZeroMemory(@Packet, sizeof(TSpawnMobPacket));
  Packet.Header.size := sizeof(TSpawnMobPacket);
  Packet.Header.Index := MOB^.Base.clientId;
  Packet.Header.Code := $35E;
  Move(MOB^.Equip, Packet.Equip, 16);
  Packet.Position := MOB^.Position;
  Packet.MaxHp := MOB^.MaxHp;
  Packet.CurHP := Packet.MaxHp;
  Packet.MaxMP := Packet.MaxHp;
  Packet.CurMp := Packet.MaxMP;
  Packet.Level := MOB^.MobLevel;
  Packet.SpawnType := SPAWN_NORMAL;
  Packet.Altura := MOB^.MobElevation;
  Packet.Tronco := MOB^.Cabeca;
  Packet.Perna := MOB^.Perna;
  Packet.MobType := MOB^.MobType;
  Packet.MobName := MOB^.IntName;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendRemoveMobDungeon(MOB: PMobsStructDungeonInstance);
var
  Packet: TSendRemoveMobPacket;
begin
  ZeroMemory(@Packet, sizeof(TSendRemoveMobPacket));
  Packet.Header.size := sizeof(TSendRemoveMobPacket);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $101;
  Packet.Index := MOB.Base.clientId;
  Packet.DeleteType := DELETE_NORMAL;
  Self.SendPacket(Packet, Packet.Header.size);
end;
{$ENDREGION}
{$REGION 'Nation'}
function TPlayer.IsMarshal(): Boolean;
var
  SelfNationID: Integer;
begin
  Result := FALSE;
  if (Self.Character.Base.Nation = 0) then
    SelfNationID := (Servers[Self.ChannelIndex].NationID - 1)
  else
    SelfNationID := Self.Character.Base.Nation - 1;
  if (Self.Base.Character.GuildIndex > 0) then
  begin
    if (Nations[SelfNationID].MarechalGuildID = Self.Base.Character.GuildIndex)
    then
      if ((Guilds[Self.Character.GuildSlot].GuildLeaderCharIndex)
        = Self.Base.Character.CharIndex) then
      begin
        Result := True;
      end;
  end;
end;
function TPlayer.IsArchon(): Boolean;
var
  SelfNationID: Integer;
begin
  Result := FALSE;
  if (Self.Character.Base.Nation = 0) then
    SelfNationID := (Servers[Self.ChannelIndex].NationID - 1)
  else
    SelfNationID := Self.Character.Base.Nation - 1;
  if (Self.Base.Character.GuildIndex > 0) then
  begin
    if ((Nations[SelfNationID].TacticianGuildID = Self.Base.Character.
      GuildIndex) or (Nations[SelfNationID].JudgeGuildID = Self.Base.Character.
      GuildIndex) or (Nations[SelfNationID].TreasurerGuildID = Self.Base.
      Character.GuildIndex)) then
      if ((Guilds[Self.Character.GuildSlot].GuildLeaderCharIndex)
        = Self.Base.Character.CharIndex) then
      begin
        Result := True;
      end;
  end;
end;
function TPlayer.IsGradeMarshal(): Boolean;
var
  GuildSlot, MemberSlot: Integer;
  SelfNationID: Integer;
begin
  Result := FALSE;
  if (Self.Character.Base.Nation = 0) then
    SelfNationID := (Servers[Self.ChannelIndex].NationID - 1)
  else
    SelfNationID := Self.Character.Base.Nation - 1;
  if (Self.Base.Character.GuildIndex > 0) and
    (Nations[SelfNationID].MarechalGuildID > 0) then
  begin
    GuildSlot := Servers[Self.ChannelIndex].GetGuildSlotByID
      (Nations[SelfNationID].MarechalGuildID);
    if(GuildSlot = 0) then
      Exit;
    MemberSlot := Guilds[GuildSlot].FindMemberFromCharIndex
      (Self.Base.Character.CharIndex);
    if not(MemberSlot = -1) then
      Result := True;
  end;
end;
function TPlayer.IsGradeArchon(): Boolean;
var
  GuildSlot, MemberSlot: Integer;
  Tac, Jud, Tre: Boolean;
  SelfNationID: Integer;
begin
  Result := FALSE;
  Tac := FALSE;
  Jud := FALSE;
  Tre := FALSE;
  if (Self.Character.Base.Nation = 0) then
    SelfNationID := (Servers[Self.ChannelIndex].NationID - 1)
  else
    SelfNationID := Self.Character.Base.Nation - 1;
  GuildSlot := 0;
  MemberSlot := -1;
  if (Self.Base.Character.GuildIndex > 0) then
  begin
    if (Nations[SelfNationID].TacticianGuildID > 0) then
      GuildSlot := Servers[Self.ChannelIndex].GetGuildSlotByID
        (Nations[SelfNationID].TacticianGuildID);
    if (GuildSlot > 0) then
    begin
      MemberSlot := Guilds[GuildSlot].FindMemberFromCharIndex
        (Self.Base.Character.CharIndex);
      if (MemberSlot >= 0) then
        Tac := True;
    end;
    GuildSlot := 0;
    MemberSlot := -1;
    if (Nations[SelfNationID].JudgeGuildID > 0) then
      GuildSlot := Servers[Self.ChannelIndex].GetGuildSlotByID
        (Nations[SelfNationID].JudgeGuildID);
    if (GuildSlot > 0) then
    begin
      MemberSlot := Guilds[GuildSlot].FindMemberFromCharIndex
        (Self.Base.Character.CharIndex);
      if (MemberSlot >= 0) then
        Jud := True;
    end;
    GuildSlot := 0;
    MemberSlot := -1;
    if (Nations[SelfNationID].TreasurerGuildID > 0) then
      GuildSlot := Servers[Self.ChannelIndex].GetGuildSlotByID
        (Nations[SelfNationID].TreasurerGuildID);
    if (GuildSlot > 0) then
    begin
      MemberSlot := Guilds[GuildSlot].FindMemberFromCharIndex
        (Self.Base.Character.CharIndex);
      if (MemberSlot >= 0) then
        Tre := True;
    end;
    if ((Tac) or (Jud) or (Tre)) then
    begin
      Result := True;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Reliquares and Devir'}
procedure TPlayer.SendUpdateReliquareInformation(Channel: BYTE);
var
  Packet: TDevirTimeRelikInfoPacket;
  i: Integer;
begin
  ZeroMemory(@Packet, sizeof(TDevirTimeRelikInfoPacket));
  Packet.Header.size := sizeof(TDevirTimeRelikInfoPacket);
  Packet.Header.Code := $953;
  Packet.Header.Index := $7535;
  Packet.Nation := Servers[Channel].NationID;
  for i := 0 to 4 do
  begin
    if (Servers[Channel].Devires[0].Slots[i].ItemID <> 0) then
    begin
      Packet.DevirAmk.Slots[i].ItemID := Servers[Channel].Devires[0].Slots
        [i].ItemID;
      Packet.DevirAmk.Slots[i].APP := Servers[Channel].Devires[0].Slots[i].APP;
      Packet.DevirAmk.Slots[i].TimeToEstabilish := TFunctions.DateTimeToUNIXTimeFAST(
        Servers[Channel].Devires[0].Slots[i].TimeToEstabilish);
      Packet.DevirAmk.Slots[i].UnkByte1 := 2;
      Packet.DevirAmk.Slots[i].UnkByte2 := 1;
      Packet.DevirAmkInfo.Slots[i].ItemID := Packet.DevirAmk.Slots[i].ItemID;
      Move(Servers[Channel].Devires[0].Slots[i].NameCapped,
        Packet.DevirAmkInfo.Slots[i].NameCapped[0], 16);
      Packet.DevirAmkInfo.Slots[i].TimeCapped := TFunctions.DateTimeToUNIXTimeFAST(Servers[Channel].Devires[0]
        .Slots[i].TimeCapped);
    end;
    Packet.DevirAmkInfo.Slots[i].IsActive :=
      BYTE(Servers[Channel].Devires[0].Slots[i].IsAble);
    if (Servers[Channel].Devires[1].Slots[i].ItemID <> 0) then
    begin
      Packet.DevirSig.Slots[i].ItemID := Servers[Channel].Devires[1].Slots
        [i].ItemID;
      Packet.DevirSig.Slots[i].APP := Servers[Channel].Devires[1].Slots[i].APP;
      Packet.DevirSig.Slots[i].TimeToEstabilish := TFunctions.DateTimeToUNIXTimeFAST(
        Servers[Channel].Devires[1].Slots[i].TimeToEstabilish);
      Packet.DevirSig.Slots[i].UnkByte1 := 2;
      Packet.DevirSig.Slots[i].UnkByte2 := 1;
      Packet.DevirSigInfo.Slots[i].ItemID := Packet.DevirAmk.Slots[i].ItemID;
      Move(Servers[Channel].Devires[1].Slots[i].NameCapped,
        Packet.DevirSigInfo.Slots[i].NameCapped[0], 16);
      Packet.DevirSigInfo.Slots[i].TimeCapped := TFunctions.DateTimeToUNIXTimeFAST
        (Servers[Channel].Devires[1].Slots[i].TimeCapped);
    end;
    Packet.DevirSigInfo.Slots[i].IsActive :=
      BYTE(Servers[Channel].Devires[1].Slots[i].IsAble);
    if (Servers[Channel].Devires[2].Slots[i].ItemID <> 0) then
    begin
      Packet.DevirCah.Slots[i].ItemID := Servers[Channel].Devires[2].Slots
        [i].ItemID;
      Packet.DevirCah.Slots[i].APP := Servers[Channel].Devires[2].Slots[i].APP;
      Packet.DevirCah.Slots[i].TimeToEstabilish := TFunctions.DateTimeToUNIXTimeFAST(
        Servers[Channel].Devires[2].Slots[i].TimeToEstabilish);
      Packet.DevirCah.Slots[i].UnkByte1 := 2;
      Packet.DevirCah.Slots[i].UnkByte2 := 1;
      Packet.DevirCahInfo.Slots[i].ItemID := Packet.DevirAmk.Slots[i].ItemID;
      Move(Servers[Channel].Devires[2].Slots[i].NameCapped,
        Packet.DevirCahInfo.Slots[i].NameCapped[0], 16);
      Packet.DevirCahInfo.Slots[i].TimeCapped := TFunctions.DateTimeToUNIXTimeFAST
        (Servers[Channel].Devires[2].Slots[i].TimeCapped);
    end;
    Packet.DevirCahInfo.Slots[i].IsActive :=
      BYTE(Servers[Channel].Devires[2].Slots[i].IsAble);
    if (Servers[Channel].Devires[3].Slots[i].ItemID <> 0) then
    begin
      Packet.DevirMir.Slots[i].ItemID := Servers[Channel].Devires[3].Slots
        [i].ItemID;
      Packet.DevirMir.Slots[i].APP := Servers[Channel].Devires[3].Slots[i].APP;
      Packet.DevirMir.Slots[i].TimeToEstabilish := TFunctions.DateTimeToUNIXTimeFAST(
        Servers[Channel].Devires[3].Slots[i].TimeToEstabilish);
      Packet.DevirMir.Slots[i].UnkByte1 := 2;
      Packet.DevirMir.Slots[i].UnkByte2 := 1;
      Packet.DevirMirInfo.Slots[i].ItemID := Packet.DevirAmk.Slots[i].ItemID;
      Move(Servers[Channel].Devires[3].Slots[i].NameCapped,
        Packet.DevirMirInfo.Slots[i].NameCapped[0], 16);
      Packet.DevirMirInfo.Slots[i].TimeCapped := TFunctions.DateTimeToUNIXTimeFAST
        (Servers[Channel].Devires[3].Slots[i].TimeCapped);
    end;
    Packet.DevirMirInfo.Slots[i].IsActive :=
      BYTE(Servers[Channel].Devires[3].Slots[i].IsAble);
    if (Servers[Channel].Devires[4].Slots[i].ItemID <> 0) then
    begin
      Packet.DevirZel.Slots[i].ItemID := Servers[Channel].Devires[4].Slots
        [i].ItemID;
      Packet.DevirZel.Slots[i].APP := Servers[Channel].Devires[4].Slots[i].APP;
      Packet.DevirZel.Slots[i].TimeToEstabilish := TFunctions.DateTimeToUNIXTimeFAST(
        Servers[Channel].Devires[4].Slots[i].TimeToEstabilish);
      Packet.DevirZel.Slots[i].UnkByte1 := 2;
      Packet.DevirZel.Slots[i].UnkByte2 := 1;
      Packet.DevirZelInfo.Slots[i].ItemID := Packet.DevirAmk.Slots[i].ItemID;
      Move(Servers[Channel].Devires[4].Slots[i].NameCapped,
        Packet.DevirZelInfo.Slots[i].NameCapped[0], 16);
      Packet.DevirZelInfo.Slots[i].TimeCapped := TFunctions.DateTimeToUNIXTimeFAST
        (Servers[Channel].Devires[4].Slots[i].TimeCapped);
    end;
    Packet.DevirZelInfo.Slots[i].IsActive :=
      BYTE(Servers[Channel].Devires[4].Slots[i].IsAble);
  end;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TPlayer.SendReliquesToPlayer();
var
  Packet: TSendReliques;
  i, j, k: Integer;
  Chid: Byte;
begin
  ZeroMemory(@Packet, sizeof(TSendReliques));
  Packet.Header.size := sizeof(TSendReliques);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $136;
  if (Self.Base.Character.Nation = 0) then
  begin
    k := 0;
    
    for i := 0 to 4 do
    begin
      for j := 0 to 4 do
      begin
        Packet.ReliquesItemID[k] := Servers[Self.ChannelIndex].Devires[i].Slots[j].ItemID;
        Inc(k);
      end;
    end;
  end
  else
  begin
    Chid := Nations[Integer(Self.Account.header.Nation)-1].ChannelId;
    if(Chid <> Self.ChannelIndex) then
    begin
      ZeroMemory(@Packet.ReliquesItemID, 50);
    end
    else
    begin
      k := 0;
      for i := 0 to 4 do
      begin
        for j := 0 to 4 do
        begin
          Packet.ReliquesItemID[k] := Servers[Chid].Devires[i].Slots[j].ItemID;
          Inc(k);
        end;
      end;
    end;
  end;
  Self.SendPacket(Packet, Packet.Header.Size);
end;

procedure TPlayer.UpdateReliquareOpennedDevir(DevirID: Integer);
var
  Packet: TSendDevirInfoPacket;
  i: Integer;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.Size := sizeof(Packet);
  Packet.Header.Index := 0;
  Packet.Header.Code := $B52;
  Packet.DevirID := DevirID;
  Packet.TypeOpen := 5;

  for I := 0 to 4 do
  begin
    if(Servers[Self.ChannelIndex].Devires[DevirID].Slots[i].ItemId <> 0) then
    begin
      Packet.DevirReliq.Slots[i].ItemID :=
        Servers[Self.ChannelIndex].Devires[DevirID].Slots[i].ItemId;
      Packet.DevirReliq.Slots[i].APP :=
        Packet.DevirReliq.Slots[i].ItemID;
      Packet.DevirReliq.Slots[i].Unknown := i;
      Packet.DevirReliq.Slots[i].TimeToEstabilish :=
         TFunctions.DateTimeToUNIXTimeFAST(
          Servers[Self.ChannelIndex].Devires[DevirID].Slots[i].TimeToEstabilish);
      Packet.DevirReliq.Slots[i].UnkByte1 := 2;
      Packet.DevirReliq.Slots[i].UnkByte2 := 1;
      Packet.DevirReliInfo.Slots[i].ItemID :=
        Servers[Self.ChannelIndex].Devires[DevirID].Slots[i].ItemId;
      Packet.DevirReliInfo.Slots[i].IsActive := 1;
      Packet.DevirReliInfo.Slots[i].TimeCapped :=
      TFunctions.DateTimeToUNIXTimeFAST(
          Servers[Self.ChannelIndex].Devires[DevirID].Slots[i].TimeCapped);
      System.AnsiStrings.StrPLCopy(Packet.DevirReliInfo.Slots[i].NameCapped,
      String(Servers[Self.ChannelIndex].Devires[DevirID].Slots[i].NameCapped), 16);
    end
    else
    begin
      Packet.DevirReliInfo.Slots[i].IsActive :=
        Servers[Self.ChannelIndex].Devires[DevirID].Slots[i].IsAble.ToInteger;
    end;
  end;
  Self.SendPacket(Packet, Packet.Header.Size);
end;
{$ENDREGION}
function TPlayer.CheckGameMasterLogged(): Boolean;
begin
  Result := FALSE;
  if (Self.Base.SessionMasterPriv >= TMasterPrives.GameMasterPriv) then
    Result := True;
end;
function TPlayer.CheckAdminLogged(): Boolean;
begin
  Result := FALSE;
  if (Self.Base.SessionMasterPriv >= TMasterPrives.AdministratorPriv) then
    Result := True;
end;
function TPlayer.CheckModeratorLogged(): Boolean;
begin
  Result := FALSE;
  if (Self.Base.SessionMasterPriv >= TMasterPrives.ModeradorPriv) then
    Result := True;
end;
procedure TPlayer.SendMessageGritoForGameMaster(Nick: String; ServerFrom: Integer; xMsg: String);
var
  Packet: TSendMessageShout;
begin
  ZeroMemory(@Packet, sizeof(TSendMessageShout));
  Packet.Header.Size := sizeof(TSendMessageShout);
  Packet.Header.Code := $3217;
  Packet.Header.Index := Self.Base.ClientID;
  AnsiStrings.StrPCopy(Packet.Nick, Nick);
  AnsiStrings.StrPCopy(Packet.xMsg, xMsg);
  //System.AnsiStrings.StrPLCopy(Packet.Nick, Nick, sizeof(Nick));
  //System.AnsiStrings.StrPLCopy(Packet.xMsg, xMsg, sizeof(xMsg));
  Packet.ServerFrom := ServerFrom;
  Self.SendPacket(Packet, Packet.Header.Size);
end;
end.
