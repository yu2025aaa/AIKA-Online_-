unit BaseMob;
interface
{$O+}
uses
  Windows, PlayerData, Diagnostics, Generics.Collections, Packets, SysUtils,
  MiscData, AnsiStrings, FilesData, Math;
{$OLDTYPELAYOUT ON}
type
  TPrediction = record
    ETA: Single;
    Timer: { TDateTime; } TStopwatch;
    Source: TPosition;
    Destination: TPosition;
    function CanPredict: Boolean;
    function Elapsed: Integer;
    function Delta: Single;
    function Interpolate(out d: Single): TPosition;
    procedure Create; overload;
    procedure CalcETA(speed: Byte);
  end;
type
  PBaseMob = ^TBaseMob;
  TBaseMob = record
  private
    _prediction: TPrediction;
    _cooldown: TDictionary<WORD, TTime>;
    _buffs: TDictionary<WORD, TDateTime>;
    // _currentPosition: TPosition;
    procedure AddToVisible(var mob: TBaseMob; SpawnType: Byte = 0);
    procedure RemoveFromVisible(mob: TBaseMob; SpawnType: Byte = 0);
  public
    IsDead: Boolean;
    ClientID: WORD;
    PranClientID: WORD;
    PetClientID: WORD;
    Character: PCharacter;
    PlayerCharacter: TPlayerCharacter;
    AttackSpeed: WORD;
    IsActive: Boolean;
    IsDirty: Boolean;
    Mobbaby: WORD;
    PartyId: WORD;
    PartyRequestId: WORD;
    VisibleMobs: TList<WORD>;
    VisibleNPCS: TList<WORD>;
    VisiblePlayers: TList<WORD>;
    TimeForGoldTime: TDateTime;
    VisibleTargets: Array of TMobTarget;
    VisibleTargetsCnt: WORD; // aqui vai ser o controle da lista propia
    LastTimeGarbaged: TDateTime;
    target: PBaseMob;
    IsDungeonMob: Boolean;
    InClastleVerus: Boolean;
    LastReceivedSkillFromCastle: TDateTime;
    PositionSpawnedInCastle: TPosition;
    NationForCastle: Byte;
    NpcIdGen: WORD;
    NpcQuests: Array [0 .. 7] of TQuestMisc;
    PersonalShopIndex: DWORD;
    PersonalShop: TPersonalShopData;
    MOB_EF: ARRAY [0 .. 395] OF Integer;
    EQUIP_CONJUNT: ARRAY [0 .. 15] OF WORD;
    EFF_5: Array [0 .. 2] of WORD; // podemos ter até 3 efeitos 5
    IsPlayerService: Boolean;
    ChannelId: Byte;
    Neighbors: Array [0 .. 8] of TNeighbor;
    EventListener: Boolean;
    EventAction: Byte;
    EventSkillID: WORD;
    EventSkillEtc1: WORD;
    HPRListener: Boolean; // HPR = HP Recovery
    HPRAction: Byte;
    HPRSkillID: WORD;
    HPRSkillEtc1: WORD;
    SKDListener: Boolean; // SKD = Skill Damage
    SKDAction: Byte;
    SKDSkillID: WORD;
    SKDTarget: WORD;
    SKDSkillEtc1: WORD;
    SKDIsMob: Boolean;
    SDKMobID, SDKSecondIndex: WORD;
    Mobid: WORD;
    SecondIndex: WORD;
    IsBoss: Boolean;
    { Skill }
    LastBasicAttack: TDateTime;
    LastAttackMsg: TDateTime;
    AttackMsgCount: Integer;
    UsingSkill: WORD;
    ResolutoPoints: Byte;
    ResolutoTime: TDateTime;
    DefesaPoints: Byte;
    DefesaPoints2: Byte;
    BolhaPoints: Byte;
    LaminaID: WORD;
    LaminaPoints: WORD;
    Polimorfed: Boolean;
    UsingLongSkill: Boolean;
    LongSkillTimes: WORD;
    UniaoDivina: String;
    SessionOnline: Boolean;
    SessionUsername: String;
    SessionMasterPriv: TMasterPrives;
    MissCount: WORD;
    NegarCuraCount: Integer;
    RevivedTime: TDateTime;
    CurrentAction: Integer;
    LastSplashTime: TDateTime;

    ActiveTitle: Integer;
    LastReceivedAttack: TDateTime;
    LastMovedTime: TDateTime;
    LastMovedMessageHack: TDateTime;
    AttacksAccumulated, AttacksReceivedAccumulated: Integer;
    DroppedCount: Integer;
    { TBaseMob }
    procedure Create(characterPointer: PCharacter; Index: WORD;
      ChannelId: Byte); overload;
    procedure Destroy(Aux: Boolean = False);
    function IsPlayer: Boolean;
    procedure UpdateVisibleList(SpawnType: Byte = 0);
    // function CurrentPosition: TPosition;
    procedure SetDestination(const Destination: TPosition);
    procedure addvisible(m: TBaseMob);
    procedure removevisible(m: TBaseMob);
    procedure AddHP(Value: Integer; ShowUpdate: Boolean);
    procedure AddMP(Value: Integer; ShowUpdate: Boolean);
    procedure RemoveHP(Value: Integer; ShowUpdate: Boolean; StayOneHP: Boolean = False);
    procedure RemoveMP(Value: Integer; ShowUpdate: Boolean);
    procedure WalkinTo(Pos: TPosition);
    procedure SetEquipEffect(const Equip: TItem; SetType: Integer;
      ChangeConjunt: Boolean = True; VerifyExpired: Boolean = True);
    procedure SetConjuntEffect(Index: Integer; SetType: Integer);
    procedure ConfigEffect(Count, ConjuntId: Integer; SetType: Integer);
    procedure SetOnTitleActiveEffect();
    procedure SetOffTitleActiveEffect();
    function MatchClassInfo(ClassInfo: Byte): Boolean;
    function IsCompleteEffect5(out CountEffects: Byte): Boolean;
    function SearchEmptyEffect5Slot(): Byte;
    function GetSlotOfEffect5(CallID: WORD): Byte;
    procedure LureMobsInRange();
    { Send's }
    procedure SendCreateMob(SpawnType: WORD = 0; sendTo: WORD = 0;
      SendSelf: Boolean = True; Polimorf: WORD = 0);
    procedure SendRemoveMob(delType: Integer = 0; sendTo: WORD = 0;
      SendSelf: Boolean = True);
    procedure SendToVisible(var Packet; size: WORD; sendToSelf: Boolean = True);
    procedure SendPacket(var Packet; size: WORD);
    procedure SendRefreshLevel;
    procedure SendCurrentHPMP(Update: Boolean = False);
    procedure SendCurrentHPMPMob();
    procedure SendStatus;
    procedure SendRefreshPoint;
    procedure SendRefreshKills;
    procedure SendEquipItems(SendSelf: Boolean = True);
    procedure SendRefreshItemSlot(SlotType, SlotItem: WORD; Item: TItem;
      Notice: Boolean); overload;
    procedure SendRefreshItemSlot(SlotItem: WORD; Notice: Boolean); overload;
    procedure SendSpawnMobs;
    procedure GenerateBabyMob;
    procedure UngenerateBabyMob(ungenEffect: WORD);
    function AddTargetToList(target: PBaseMob): Boolean;
    function RemoveTargetFromList(target: PBaseMob): Boolean;
    function ContainsTargetInList(target: PBaseMob; out id: WORD)
      : Boolean; overload;
    function ContainsTargetInList(ClientID: WORD): Boolean; overload;
    function ContainsTargetInList(ClientID: WORD; out id: WORD): Boolean; overload;
    function GetEmptyTargetInList(out Index: WORD): Boolean;
    function GetTargetInList(ClientID: WORD): PBaseMob;
    function ClearTargetList(): Boolean;
    function TargetGarbageService(): Boolean;
    { Get's }
    procedure GetCreateMob(out Packet: TSendCreateMobPacket;
      P1: WORD = 0); overload;
    class function GetMob(Index: WORD; Channel: Byte; out mob: TBaseMob)
      : Boolean; overload; static;
    class function GetMob(Index: WORD; Channel: Byte; out mob: PBaseMob)
      : Boolean; overload; static;
    { class function GetMob(Pos: TPosition; Channel: Byte; out mob: TBaseMob)
      : Boolean; overload; static; }
    function GetMobAbility(eff: Integer): Integer;
    procedure IncreasseMobAbility(eff: Integer; Value: Integer);
    procedure DecreasseMobAbility(eff: Integer; Value: Integer);
    function GetCurrentHP(): DWORD;
    function GetCurrentMP(): DWORD;
    function GetRegenerationHP(): DWORD;
    function GetRegenerationMP(): DWORD;
    function GetEquipedItensHPMPInc: DWORD;
    function GetEquipedItensDamageReduce: DWORD;
    function GetMobClass(ClassInfo: Integer = 0): Integer;
    procedure GetCurrentScore;
    procedure GetEquipDamage(const Equip: TItem);
    procedure GetEquipDefense(const Equip: TItem);
    procedure GetEquipsDefense;
    { Buffs }
    function RefreshBuffs: Integer;
    procedure SendRefreshBuffs;
    procedure SendAddBuff(BuffIndex: WORD);
    procedure AddBuffEffect(Index: WORD);
    procedure RemoveBuffEffect(Index: WORD);
    function GetBuffToRemove(): DWORD;
    function GetDeBuffToRemove(): DWORD;
    function GetDebuffCount(): WORD;
    function GetBuffCount(): WORD;
    procedure RemoveBuffByIndex(Index: WORD);
    function GetBuffSameIndex(BuffIndex: DWORD): Boolean;
    function BuffExistsByIndex(BuffIndex: DWORD): Boolean;
    function BuffExistsByID(BuffID: DWORD): Boolean;
    function BuffExistsInArray(const BuffList: Array of DWORD): Boolean;
    function BuffExistsSopa(): Boolean;
    function GetBuffIDByIndex(Index: DWORD): WORD;
    procedure RemoveBuffs(Quant: Byte);
    procedure RemoveDebuffs(Quant: Byte);
    procedure ZerarBuffs();
    { Attack & Skills }
    procedure CheckCooldown(var Packet: TSendSkillUse);
    function CheckCooldown2(SkillID: DWORD): Boolean;
    procedure SendCurrentAllSkillCooldown();
    function AddBuff(BuffIndex: WORD; Refresh: Boolean = True;
      AddTime: Boolean = False; TimeAditional: Integer = 0): Boolean;
    function AddBuffWhenEntering(BuffIndex: Integer;
      BuffTime: TDateTime): Boolean;
    function GetBuffSlot(BuffIndex: WORD): Integer;
    function GetEmptyBuffSlot(): Integer;
    function RemoveBuff(BuffIndex: WORD): Boolean;
    procedure RemoveAllDebuffs();

    procedure SendDamage(Skill, Anim: DWORD; mob: PBaseMob;
      DataSkill: P_SkillData);
    function GetDamage(Skill: DWORD; mob: PBaseMob;
      out DnType: TDamageType): UInt64;
    function GetDamageType(Skill: DWORD; IsPhysical: Boolean; mob: PBaseMob)
      : TDamageType;
    function GetDamageType2(Skill: DWORD; IsPhysical: Boolean; mob: PBaseMob)
      : TDamageType;
    function GetDamageType3(Skill: DWORD; IsPhysical: Boolean; mob: PBaseMob)
      : TDamageType;
    procedure CalcAndCure(Skill: DWORD; mob: PBaseMob);
    function CalcCure(Skill: DWORD; mob: PBaseMob): Integer;
    function CalcCure2(BaseCure: DWORD; mob: PBaseMob; xSkill: Integer = 0): Integer;
    procedure HandleSkill(Skill, Anim: DWORD; mob: PBaseMob;
      SelectedPos: TPosition; DataSkill: P_SkillData);
    function ValidAttack(DmgType: TDamageType; DebuffType: Byte = 0;
      mob: PBaseMob = nil; AuxDano: Integer = 0; xisBoss: Boolean = False): Boolean;
    procedure MobKilledInDungeon(mob: PBaseMob);
    procedure MobKilled(mob: PBaseMob; out DroppedExp: Boolean;
      out DroppedItem: Boolean; InParty: Boolean = False);
    procedure DropItemFor(PlayerBase: PBaseMob; mob: PBaseMob);
    procedure PlayerKilled(mob: PBaseMob; xRlkSlot: Byte = 0);
    { Parses }
    procedure SelfBuffSkill(Skill, Anim: DWORD; mob: PBaseMob; Pos: TPosition);
    procedure TargetBuffSkill(Skill, Anim: DWORD; mob: PBaseMob;
      DataSkill: P_SkillData; Posx: DWORD = 0; Posy: DWORD = 0);
    procedure TargetSkill(Skill, Anim: DWORD; mob: PBaseMob; out Dano: Integer;
      out DmgType: TDamageType; var CanDebuff: Boolean; var Resisted: Boolean);
    procedure AreaBuff(Skill, Anim: DWORD; mob: PBaseMob;
      Packet: TRecvDamagePacket);
    procedure AreaSkill(Skill, Anim: DWORD; mob: PBaseMob; SkillPos: TPosition;
      DataSkill: P_SkillData; DamagePerc: Single = 0; ElThymos: Integer = 0);
    procedure AttackParse(Skill, Anim: DWORD; mob: PBaseMob; var Dano: Integer;
      var DmgType: TDamageType; out AddBuff: Boolean; out MobAnimation: Byte;
      DataSkill: P_SkillData);
    procedure AttackParseForMobs(Skill, Anim: DWORD; mob: PBaseMob; var Dano: Integer;
      var DmgType: TDamageType; out AddBuff: Boolean; out MobAnimation: Byte);
    procedure Effect5Skill(mob: PBaseMob; EffCount: Byte; xPassive: Boolean = False);
    function IsSecureArea(): Boolean;
    { Skill classes handle }
    procedure WarriorSkill(Skill, Anim: DWORD; mob: PBaseMob; out Dano: Integer;
      out DmgType: TDamageType; var CanDebuff: Boolean; var Resisted: Boolean);
    procedure TemplarSkill(Skill, Anim: DWORD; mob: PBaseMob; out Dano: Integer;
      out DmgType: TDamageType; var CanDebuff: Boolean; var Resisted: Boolean);
    procedure RiflemanSkill(Skill, Anim: DWORD; mob: PBaseMob; out Dano: Integer;
      out DmgType: TDamageType; var CanDebuff: Boolean; var Resisted: Boolean);
    procedure DualGunnerSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean);
    procedure MagicianSkill(Skill, Anim: DWORD; mob: PBaseMob; out Dano: Integer;
      out DmgType: TDamageType; var CanDebuff: Boolean; var Resisted: Boolean);
    procedure ClericSkill(Skill, Anim: DWORD; mob: PBaseMob; out Dano: Integer;
      out DmgType: TDamageType; var CanDebuff: Boolean; var Resisted: Boolean);
    procedure WarriorAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean; out MoveToTarget: Boolean);
    procedure TemplarAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean);
    procedure RiflemanAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean);
    procedure DualGunnerAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean);
    procedure MagicianAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean);
    procedure ClericAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean);
    { Effect Functions }
    procedure SendEffect(EffectIndex: DWORD);
    { Move/Teleport }
    procedure Teleport(Pos: TPosition); overload;
    procedure Teleport(Posx, Posy: WORD); overload;
    procedure Teleport(Posx, Posy: string); overload;
    procedure WalkTo(Pos: TPosition; speed: WORD = 70; MoveType: Byte = 0);
    procedure WalkAvanced(Pos: TPosition; SkillID: Integer);
    procedure WalkBacked(Pos: TPosition; SkillID: Integer; Mob: PBaseMob);
    { Pets }
    procedure CreatePet(PetType: TPetType; Pos: TPosition; SkillID: DWORD = 0);
    procedure DestroyPet(PetID: WORD);
    { Class }
    // class procedure ForEachInRange(Pos: TPosition; range: Byte;
    // proc: TProc<TPosition, TBaseMob>; ChannelId: Byte); overload; static;
    // procedure ForEachInRange(range: Byte;
    // proc: TProc<TPosition, TBaseMob, TBaseMob>); overload;
  end;
{$REGION 'HP / MP Increment por level'}
const
  HPIncrementPerLevel: array [0 .. 5] of Integer = (150, // War
    140, // Tp
    115, // Att
    120, // Dual
    110, // Fc
    130 // Santa
    );
const
  MPIncrementPerLevel: array [0 .. 5] of Integer = (110, // War
    130, // Tp
    145, // Att
    150, // Dual
    330, // Fc
    135 // Santa
    );
{$ENDREGION}
{$OLDTYPELAYOUT OFF}
implementation
uses
  Player, GlobalDefs, Util, Log, ItemFunctions, Functions, DateUtils, mob, PET,
  PartyData, Objects, PacketHandlers;
{$REGION 'TBaseMob'}
procedure TBaseMob.Destroy(Aux: Boolean);
begin
  Self.IsActive := Aux;
  FreeAndNil(VisibleMobs);
  FreeAndNil(VisibleNPCS);
  FreeAndNil(VisiblePlayers);
  FreeAndNil(_cooldown);
  FreeAndNil(_buffs);
  Servers[Self.ChannelId].Prans[Self.PranClientID] := 0;
  Self.ClearTargetList();
  Self.Character := nil; //talvez essa seja a solução do back char list
  Self.target := nil;
  Self.IsBoss := False;
  ZeroMemory(@Self, sizeof(TBaseMob));
end;
procedure TBaseMob.Create(characterPointer: PCharacter; Index: WORD;
  ChannelId: Byte);
begin
  ZeroMemory(@Self, sizeof(TBaseMob));
  VisibleMobs := TList<WORD>.Create;
  VisibleNPCS := TList<WORD>.Create;
  VisiblePlayers := TList<WORD>.Create;
  SetLength(VisibleTargets, 1);
  LastTimeGarbaged := Now;
  LastAttackMsg := Now;
  LastBasicAttack := Now;
  AttackMsgCount := 0;
  AttacksAccumulated := 0;
  DroppedCount := 0;
  AttacksReceivedAccumulated := 0;
  IsActive := True;
  IsDirty := False;
  LastReceivedSkillFromCastle := Now;
  InClastleVerus := False;
  Character := characterPointer;
  ClientID := index;
  Self.ChannelId := ChannelId;
  RevivedTime := Now;
  LastSplashTime := Now;
  if ((index >= 2048) and (index <= 3047)) then
  begin
    Self.NpcIdGen := index - 2047;
  end;
  // _prediction.Create;
  _cooldown := TDictionary<WORD, TTime>.Create;
  _buffs := TDictionary<WORD, TDateTime>.Create(40);
end;
function TBaseMob.IsPlayer: Boolean;
begin
  Result := IfThen(ClientID <= MAX_CONNECTIONS);
end;
procedure TBaseMob.UpdateVisibleList(SpawnType: Byte = 0);
var
  i: WORD;
  npcMob: PBaseMob;
  Packet: TSendRemoveMobPacket;
  // cid: Integer;
  // Dificult: Byte;
  // InstanceiD: Byte;
  OtherPlayer: PPlayer;
  PacketDevirSpawn: TSendCreateMobPacket;
  PacketDevirMobsSpawn: TSpawnMobPacket;
  xObj: POBJ;
begin
  IsDirty := False;
  if (Servers[Self.ChannelId].Players[Self.ClientID].InDungeon) then
    Exit;
  for i := Low(Servers[Self.ChannelId].Players)
    to High(Servers[Self.ChannelId].Players) do
  begin
    OtherPlayer := @Servers[Self.ChannelId].Players[i];
    if (OtherPlayer^.Status < Playing) then
    begin
      Continue;
    end;
    if (OtherPlayer^.Base.ClientID = Self.ClientID) then
      Continue;
    if (Self.PlayerCharacter.LastPos.InRange
      (OtherPlayer^.Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)) then
    begin
      if (Self.VisiblePlayers.Contains(OtherPlayer^.Base.ClientID)) then
        Continue;
      Self.AddToVisible(OtherPlayer^.Base);
      if (OtherPlayer^.Account.Header.Pran1.IsSpawned) then
      begin
        OtherPlayer^.SendPranSpawn(0, Self.ClientID, 0);
      end;
      if (OtherPlayer^.Account.Header.Pran2.IsSpawned) then
      begin
        OtherPlayer^.SendPranSpawn(1, Self.ClientID, 0);
      end;
      if (Servers[Self.ChannelId].Players[Self.ClientID]
        .Account.Header.Pran1.IsSpawned) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendPranSpawn(0,
          OtherPlayer^.Base.ClientID, 0);
      end;
      if (Servers[Self.ChannelId].Players[Self.ClientID]
        .Account.Header.Pran2.IsSpawned) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendPranSpawn(1,
          OtherPlayer^.Base.ClientID, 0);
      end;
    end
    else
    begin
      if not(Self.VisiblePlayers.Contains(OtherPlayer^.Base.ClientID)) then
        Continue;
      if (Servers[Self.ChannelId].Players[Self.ClientID]
        .Account.Header.Pran1.IsSpawned) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendPranUnspawn(0,
          OtherPlayer^.Base.ClientID);
      end;
      if (Servers[Self.ChannelId].Players[Self.ClientID]
        .Account.Header.Pran2.IsSpawned) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendPranUnspawn(1,
          OtherPlayer^.Base.ClientID);
      end;
      if (OtherPlayer^.Account.Header.Pran1.IsSpawned) then
      begin
        OtherPlayer^.SendPranUnspawn(0, Self.ClientID);
      end;
      if (OtherPlayer^.Account.Header.Pran2.IsSpawned) then
      begin
        OtherPlayer^.SendPranUnspawn(1, Self.ClientID);
      end;
      Self.RemoveFromVisible(OtherPlayer^.Base);
      if (OtherPlayer^.Base.IsActive = False) then
      begin
        ZeroMemory(@Packet, sizeof(Packet));
        Packet.Header.size := sizeof(Packet);
        Packet.Header.Index := $7535;
        Packet.Header.Code := $101;
        Packet.Index := OtherPlayer^.Base.ClientID;
        Self.SendPacket(Packet, Packet.Header.size);
      end;
    end;
  end;
  if(Servers[Self.ChannelId].Players[Self.ClientID].IsInstantiated) then
    for i := Low(Servers[Self.ChannelId].NPCs)
      to High(Servers[Self.ChannelId].NPCs) do
    begin
      if (Servers[Self.ChannelId].NPCs[i].Base.ClientID = 0) then
        Continue;
      // cid := Servers[Self.ChannelId].NPCs[i].Base.ClientId;
      npcMob := @Servers[Self.ChannelId].NPCs[i].Base;
      if (Self.PlayerCharacter.LastPos.InRange(npcMob^.PlayerCharacter.LastPos,
        DISTANCE_TO_WATCH)) then
      begin
        if (Self.VisibleNPCS.Contains(npcMob^.ClientID)) then
          Continue;
        Self.VisibleNPCS.Add(npcMob^.ClientID);
        npcMob^.SendCreateMob(SPAWN_NORMAL, Self.ClientID, False);
      end
      else
      begin
        if not(Self.VisibleNPCS.Contains(npcMob^.ClientID)) then
          Continue;
        Self.VisibleNPCS.Remove(npcMob^.ClientID);
        ZeroMemory(@Packet, sizeof(Packet));
        Packet.Header.size := sizeof(Packet);
        Packet.Header.Index := $7535;
        Packet.Header.Code := $101;
        Packet.Index := npcMob^.ClientID;
        Self.SendPacket(Packet, Packet.Header.size);
      end;
    end;
  for i := Low(Servers[Self.ChannelId].DevirNPC)
    to High(Servers[Self.ChannelId].DevirNPC) do
  begin
    if (Self.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId].DevirNPC[i]
      .PlayerChar.LastPos, (DISTANCE_TO_WATCH))) then
    begin
      if (Self.VisibleNPCS.Contains(i)) then
        Continue;
      Self.VisibleNPCS.Add(i);
      ZeroMemory(@PacketDevirSpawn, sizeof(TSendCreateMobPacket));
      PacketDevirSpawn.Header.size := sizeof(TSendCreateMobPacket);
      PacketDevirSpawn.Header.Index := i;
      PacketDevirSpawn.Header.Code := $349;
      Move(Servers[Self.ChannelId].DevirNPC[i].PlayerChar.Base.Name,
        PacketDevirSpawn.Name[0], 16);
      PacketDevirSpawn.Equip[0] := Servers[Self.ChannelId].DevirNPC[i]
        .PlayerChar.Base.Equip[0].Index;
      PacketDevirSpawn.Position := Servers[Self.ChannelId].DevirNPC[i]
        .PlayerChar.LastPos;
      PacketDevirSpawn.MaxHP := Servers[Self.ChannelId].DevirNPC[i]
        .PlayerChar.Base.CurrentScore.MaxHP;
      PacketDevirSpawn.CurHP := PacketDevirSpawn.MaxHP;
      PacketDevirSpawn.MaxMP := PacketDevirSpawn.MaxHP;
      PacketDevirSpawn.CurMP := PacketDevirSpawn.MaxHP;
      if(Servers[Self.ChannelId].Devires[i-3335].IsOpen) then
      begin
        PacketDevirSpawn.ItemEff[0] := $35;
      end;
      PacketDevirSpawn.Altura := Servers[Self.ChannelId].DevirNPC[i]
        .PlayerChar.Base.CurrentScore.Sizes.Altura;
      PacketDevirSpawn.Tronco := Servers[Self.ChannelId].DevirNPC[i]
        .PlayerChar.Base.CurrentScore.Sizes.Tronco;
      PacketDevirSpawn.Perna := Servers[Self.ChannelId].DevirNPC[i]
        .PlayerChar.Base.CurrentScore.Sizes.Perna;
      PacketDevirSpawn.Corpo := Servers[Self.ChannelId].DevirNPC[i]
        .PlayerChar.Base.CurrentScore.Sizes.Corpo;
      PacketDevirSpawn.IsService := 1;
      PacketDevirSpawn.EffectType := $1;
      PacketDevirSpawn.IsService := 1;
      PacketDevirSpawn.Unk0 := $28;
      Self.SendPacket(PacketDevirSpawn, PacketDevirSpawn.Header.size);

      if(PacketDevirSpawn.ItemEff[0] = $35) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendDevirChange(i, $1D);
      end;
    end
    else
    begin
      if not(Self.VisibleNPCS.Contains(i)) then
        Continue;
      Self.VisibleNPCS.Remove(i);
      ZeroMemory(@Packet, sizeof(Packet));
      Packet.Header.size := sizeof(Packet);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $101;
      Packet.Index := i;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;
  for i := Low(Servers[Self.ChannelId].DevirGuards)
    to High(Servers[Self.ChannelId].DevirGuards) do
  begin
    if (Servers[Self.ChannelId].DevirGuards[i].Base.IsDead) then
      Continue;
    if (Self.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId].DevirGuards
      [i].PlayerChar.LastPos, DISTANCE_TO_WATCH)) then
    begin
      if (Self.VisibleNPCs.Contains(i)) then
        Continue;
      Self.VisibleNPCs.Add(i);
      Self.AddTargetToList(@Servers[Self.ChannelId].DevirGuards[i]
        .Base);
      ZeroMemory(@PacketDevirMobsSpawn, sizeof(TSpawnMobPacket));
      PacketDevirMobsSpawn.Header.size := sizeof(TSpawnMobPacket);
      PacketDevirMobsSpawn.Header.Index := i;
      PacketDevirMobsSpawn.Header.Code := $35E;
      PacketDevirMobsSpawn.Equip[0] := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.Equip[0].Index;
      PacketDevirMobsSpawn.Equip[6] := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.Equip[6].Index;
      PacketDevirMobsSpawn.Position := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.LastPos;
      PacketDevirMobsSpawn.MaxHP := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.CurrentScore.MaxHP;
      PacketDevirMobsSpawn.CurHP := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.CurrentScore.CurHP;
      PacketDevirMobsSpawn.MaxMP := PacketDevirMobsSpawn.MaxHP;
      PacketDevirMobsSpawn.CurMP := PacketDevirMobsSpawn.MaxHP;
      PacketDevirMobsSpawn.Level :=
        (Servers[Self.ChannelId].DevirGuards[i].PlayerChar.Base.Level + 1) * 13;
      if(Self.Character <> nil) then
        if (Self.Character.Nation = Servers[Self.ChannelId].DevirGuards[i]
          .PlayerChar.Base.Nation) then
        begin // aqui o player é da nação do guarda, não disponível para atacar.
          PacketDevirMobsSpawn.IsService := True;
        end
        else
        begin // aqui é disponível atacar
          PacketDevirMobsSpawn.IsService := False;
        end;
      PacketDevirMobsSpawn.Effects[0] := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.DuploAtk;
      PacketDevirMobsSpawn.Altura := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.CurrentScore.Sizes.Altura;
      PacketDevirMobsSpawn.Tronco := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.CurrentScore.Sizes.Tronco;
      PacketDevirMobsSpawn.Perna := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.CurrentScore.Sizes.Perna;
      PacketDevirMobsSpawn.Corpo := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.CurrentScore.Sizes.Corpo;
      PacketDevirMobsSpawn.MobType := 0;
      PacketDevirMobsSpawn.MobName :=
        StrToInt(String(Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.Name));
      Self.SendPacket(PacketDevirMobsSpawn, PacketDevirMobsSpawn.Header.size);
      // Servers[Self.ChannelId].DevirGuards[i].Base.SendCreateMob(SPAWN_NORMAL,
      // Self.ClientID, False);
    end
    else
    begin
      if not(Self.VisibleNPCs.Contains(i)) then
        Continue;
      Self.VisibleNPCs.Remove(i);
      Self.RemoveTargetFromList(@Servers[Self.ChannelId].DevirGuards[i]
        .Base);
      ZeroMemory(@Packet, sizeof(Packet));
      Packet.Header.size := sizeof(Packet);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $101;
      Packet.Index := i;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;
  for i := Low(Servers[Self.ChannelId].DevirStones)
    to High(Servers[Self.ChannelId].DevirStones) do
  begin
    if (Servers[Self.ChannelId].DevirStones[i].Base.IsDead) then
      Continue;
    if (Self.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId].DevirStones
      [i].PlayerChar.LastPos, DISTANCE_TO_WATCH)) then
    begin
      if (Self.VisibleNPCs.Contains(i)) then
        Continue;
      Self.VisibleNPCs.Add(i);
      Self.AddTargetToList(@Servers[Self.ChannelId].DevirStones[i]
        .Base);
      ZeroMemory(@PacketDevirMobsSpawn, sizeof(TSpawnMobPacket));
      PacketDevirMobsSpawn.Header.size := sizeof(TSpawnMobPacket);
      PacketDevirMobsSpawn.Header.Index := i;
      PacketDevirMobsSpawn.Header.Code := $35E;
      PacketDevirMobsSpawn.Position := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.LastPos;
      PacketDevirMobsSpawn.Equip[0] := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.Equip[0].Index;
      PacketDevirMobsSpawn.MaxHP := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.CurrentScore.MaxHP;
      PacketDevirMobsSpawn.CurHP := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.CurrentScore.CurHP;
      PacketDevirMobsSpawn.MaxMP := PacketDevirMobsSpawn.MaxHP;
      PacketDevirMobsSpawn.CurMP := PacketDevirMobsSpawn.MaxHP;
      PacketDevirMobsSpawn.Level :=
        (Servers[Self.ChannelId].DevirStones[i].PlayerChar.Base.Level + 1) * 13;
      if(Self.Character <> nil) then
        if (Self.Character.Nation = Servers[Self.ChannelId].DevirStones[i]
          .PlayerChar.Base.Nation) then
        begin // aqui o player é da nação do guarda, não disponível para atacar.
          PacketDevirMobsSpawn.IsService := True;
        end
        else
        begin // aqui é disponível atacar
          PacketDevirMobsSpawn.IsService := False;
        end;
      PacketDevirMobsSpawn.Effects[0] := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.DuploAtk;
      PacketDevirMobsSpawn.Altura := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.CurrentScore.Sizes.Altura;
      PacketDevirMobsSpawn.Tronco := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.CurrentScore.Sizes.Tronco;
      PacketDevirMobsSpawn.Perna := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.CurrentScore.Sizes.Perna;
      PacketDevirMobsSpawn.Corpo := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.CurrentScore.Sizes.Corpo;
      PacketDevirMobsSpawn.MobType := 1;
      PacketDevirMobsSpawn.MobName :=
        StrToInt(String(Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.Name));
      Self.SendPacket(PacketDevirMobsSpawn, PacketDevirMobsSpawn.Header.size);
      // Servers[Self.ChannelId].DevirStones[i].Base.SendCreateMob(SPAWN_NORMAL,
      // Self.ClientID, False);
    end
    else
    begin
      if not(Self.VisibleNPCs.Contains(i)) then
        Continue;
      Self.VisibleNPCs.Remove(i);
      Self.RemoveTargetFromList(@Servers[Self.ChannelId].DevirStones[i]
        .Base);
      ZeroMemory(@Packet, sizeof(Packet));
      Packet.Header.size := sizeof(Packet);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $101;
      Packet.Index := i;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;
  {for I := Low(Servers[Self.Channelid].SecureAreas) to
    High(Servers[Self.Channelid].SecureAreas) do
  begin
    if(Servers[Self.Channelid].SecureAreas[i].IsActive) then
    begin
      if(Servers[Self.Channelid].SecureAreas[i].
      SecureClientiD = 0) then
        Continue;
      if (Self.PlayerCharacter.LastPos.InRange(Servers[Self.Channelid].SecureAreas[i].Position, DISTANCE_TO_WATCH)) then
      begin
        if not(Self.VisibleNPCs.Contains(Servers[Self.Channelid].SecureAreas[i].
          SecureClientiD)) then
        begin
          Self.VisibleNPCs.Add(Servers[Self.Channelid].SecureAreas[i].
            SecureClientiD);
          ZeroMemory(@PacketDevirMobsSpawn, sizeof(TSpawnMobPacket));
          PacketDevirMobsSpawn.Header.Size := sizeof(TSpawnMobPacket);
          PacketDevirMobsSpawn.Header.index := Servers[Self.Channelid].SecureAreas[i].
            SecureClientiD;
          PacketDevirMobsSpawn.Header.Code := $35E;
          PacketDevirMobsSpawn.Equip[0] := Servers[Self.Channelid].SecureAreas[i].TotemFace;
          PacketDevirMobsSpawn.Position := Servers[Self.Channelid].SecureAreas[i].Position;
           PacketDevirMobsSpawn.MaxHP := 100000;
          PacketDevirMobsSpawn.CurHP := PacketDevirMobsSpawn.MaxHP;
          PacketDevirMobsSpawn.MaxMP := PacketDevirMobsSpawn.MaxHP;
          PacketDevirMobsSpawn.CurMP := PacketDevirMobsSpawn.MaxHP;
          PacketDevirMobsSpawn.Level := 95;
          PacketDevirMobsSpawn.IsService := true;
          PacketDevirMobsSpawn.Effects[0] := $35;
          PacketDevirMobsSpawn.Altura := 10;
          PacketDevirMobsSpawn.Tronco := 119;
          PacketDevirMobsSpawn.Perna := 119;
          PacketDevirMobsSpawn.Corpo := 20;
          PacketDevirMobsSpawn.MobType := 4;
          PacketDevirMobsSpawn.MobName := StrToInt('942');
          Self.SendPacket(PacketDevirMobsSpawn, PacketDevirMobsSpawn.Header.Size);
        end;
      end
      else
      begin
        if (Self.VisibleNPCs.Contains(Servers[Self.Channelid].SecureAreas[i].
          SecureClientiD)) then
        begin
          Self.VisibleNPCs.Remove(Servers[Self.Channelid].SecureAreas[i].
          SecureClientiD);
          ZeroMemory(@Packet, sizeof(Packet));
          Packet.Header.size := sizeof(Packet);
          Packet.Header.Index := $7535;
          Packet.Header.Code := $101;
          Packet.Index := Servers[Self.Channelid].SecureAreas[i].
            SecureClientiD;
          Self.SendPacket(Packet, Packet.Header.size);
        end;
      end;
    end
    else
    begin
      if(Servers[Self.Channelid].SecureAreas[i].
      SecureClientiD = 0) then
        Continue;
      if (Self.VisibleNPCs.Contains(Servers[Self.Channelid].SecureAreas[i].
      SecureClientiD)) then
      begin
        Self.VisibleNPCs.Remove(Servers[Self.Channelid].SecureAreas[i].
          SecureClientiD);
        ZeroMemory(@Packet, sizeof(Packet));
        Packet.Header.size := sizeof(Packet);
        Packet.Header.Index := $7535;
        Packet.Header.Code := $101;
        Packet.Index := Servers[Self.Channelid].SecureAreas[i].
          SecureClientiD;
        Self.SendPacket(Packet, Packet.Header.size);
      end;
    end;
  end;
  }
  for I := Low(Servers[Self.ChannelId].OBJ) to High(Servers[Self.ChannelId].OBJ) do
  begin
    if not(Servers[Self.ChannelId].OBJ[i].Index = 0) then
    begin
      xObj := @Servers[Self.ChannelId].OBJ[i];
      if(xObj.Position.InRange(Self.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)) then
      begin
        if not(Self.VisibleMobs.Contains(xObj.Index)) then
        begin
          Self.VisibleMobs.Add(xObj.Index);
          ZeroMemory(@PacketDevirSpawn, sizeof(TSendCreateMobPacket));
          PacketDevirSpawn.Header.size := sizeof(TSendCreateMobPacket);
          PacketDevirSpawn.Header.Index := i;
          PacketDevirSpawn.Header.Code := $349;
          System.AnsiStrings.StrPLCopy(PacketDevirSpawn.Name, IntToStr(xObj.NameID), sizeof(IntToStr(xObj.NameID)));
          PacketDevirSpawn.Equip[0] := xObj.Face;
          PacketDevirSpawn.Equip[6] := xObj.Weapon;
          PacketDevirSpawn.Position := xObj.Position;
          PacketDevirSpawn.MaxHP := 100000;
          PacketDevirSpawn.MaxMP := 100000;
          PacketDevirSpawn.CurHP := 100000;
          PacketDevirSpawn.CurMP := 100000;
          PacketDevirSpawn.Altura := 7;
          PacketDevirSpawn.Tronco := 119;
          PacketDevirSpawn.Perna := 119;
          PacketDevirSpawn.Corpo := 1;
          PacketDevirSpawn.IsService := 1;
          if(xObj.Face = 320) then
            System.AnsiStrings.StrPLCopy(PacketDevirSpawn.Title,
              ItemList[xObj.ContentItemID].Name, sizeof(PacketDevirSpawn.Title));
          Self.SendPacket(PacketDevirSpawn, PacketDevirSpawn.Header.Size);
        end;
      end
      else
      begin
        if (Self.VisibleMobs.Contains(Servers[Self.ChannelId].OBJ[i].Index)) then
        begin
          Self.VisibleMobs.Remove(Servers[Self.ChannelId].OBJ[i].Index);
          ZeroMemory(@Packet, sizeof(Packet));
          Packet.Header.size := sizeof(Packet);
          Packet.Header.Index := $7535;
          Packet.Header.Code := $101;
          Packet.Index := i;
          Self.SendPacket(Packet, Packet.Header.Size);
        end;
      end;
    end;
  end;

  for i := Low(Servers[Self.ChannelId].CastleObjects)
    to High(Servers[Self.ChannelId].CastleObjects) do
  begin
    if (Self.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId].CastleObjects[i]
      .PlayerChar.LastPos, DISTANCE_TO_WATCH)) then
    begin
      if (Self.VisibleNPCS.Contains(i)) then
        Continue;

      Self.VisibleNPCS.Add(i);

      ZeroMemory(@PacketDevirSpawn, sizeof(TSendCreateMobPacket));

      PacketDevirSpawn.Header.size := sizeof(TSendCreateMobPacket);
      PacketDevirSpawn.Header.Index := i;
      PacketDevirSpawn.Header.Code := $349;

      Move(Servers[Self.ChannelId].CastleObjects[i].PlayerChar.Base.Name,
        PacketDevirSpawn.Name[0], 16);

      PacketDevirSpawn.Equip[0] := Servers[Self.ChannelId].CastleObjects[i]
        .PlayerChar.Base.Equip[0].Index;

      PacketDevirSpawn.Position := Servers[Self.ChannelId].CastleObjects[i]
        .PlayerChar.LastPos;

      PacketDevirSpawn.MaxHP := Servers[Self.ChannelId].CastleObjects[i]
        .PlayerChar.Base.CurrentScore.MaxHP;
      PacketDevirSpawn.CurHP := PacketDevirSpawn.MaxHP;
      PacketDevirSpawn.MaxMP := PacketDevirSpawn.MaxHP;
      PacketDevirSpawn.CurMP := PacketDevirSpawn.MaxHP;

      PacketDevirSpawn.Altura := Servers[Self.ChannelId].CastleObjects[i]
        .PlayerChar.Base.CurrentScore.Sizes.Altura;
      PacketDevirSpawn.Tronco := Servers[Self.ChannelId].CastleObjects[i]
        .PlayerChar.Base.CurrentScore.Sizes.Tronco;
      PacketDevirSpawn.Perna := Servers[Self.ChannelId].CastleObjects[i]
        .PlayerChar.Base.CurrentScore.Sizes.Perna;
      PacketDevirSpawn.Corpo := Servers[Self.ChannelId].CastleObjects[i]
        .PlayerChar.Base.CurrentScore.Sizes.Corpo;

      PacketDevirSpawn.EffectType := $1;
      PacketDevirSpawn.IsService := 1;
      PacketDevirSpawn.Unk0 := $28;

      Self.SendPacket(PacketDevirSpawn, PacketDevirSpawn.Header.size);
    end
    else
    begin
      if not(Self.VisibleNPCS.Contains(i)) then
        Continue;

      Self.VisibleNPCS.Remove(i);

      ZeroMemory(@Packet, sizeof(Packet));

      Packet.Header.size := sizeof(Packet);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $101;

      Packet.Index := i;

      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;

  // end
  // else
  // begin
  { if (Servers[Self.ChannelId].Players[Self.ClientId].Party.Members.Count > 1)
    then
    begin
    for i in Servers[Self.ChannelId].Players[Self.ClientId].Party.Members do
    begin
    if (i = Self.ClientId) then
    Continue;
    if (Self.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId].Players
    [i].Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)) then
    begin
    if (Self.VisiblePlayers.Contains(i)) then
    Continue;
    Self.AddToVisible(Servers[Self.ChannelId].Players[i].Base);
    if (Servers[Self.ChannelId].Players[i].Account.Header.Pran1.IsSpawned)
    then
    begin
    Servers[Self.ChannelId].Players[i].SendPranSpawn(0,
    Self.ClientId, 0);
    end;
    if (Servers[Self.ChannelId].Players[i].Account.Header.Pran2.IsSpawned)
    then
    begin
    Servers[Self.ChannelId].Players[i].SendPranSpawn(1,
    Self.ClientId, 0);
    end;
    if (Servers[Self.ChannelId].Players[Self.ClientId]
    .Account.Header.Pran1.IsSpawned) then
    begin
    Servers[Self.ChannelId].Players[Self.ClientId].SendPranSpawn
    (0, i, 0);
    end;
    if (Servers[Self.ChannelId].Players[Self.ClientId]
    .Account.Header.Pran2.IsSpawned) then
    begin
    Servers[Self.ChannelId].Players[Self.ClientId].SendPranSpawn
    (1, i, 0);
    end;
    end
    else
    begin
    if not(Self.VisiblePlayers.Contains(i)) then
    Continue;
    if (Servers[Self.ChannelId].Players[Self.ClientId]
    .Account.Header.Pran1.IsSpawned) then
    begin
    Servers[Self.ChannelId].Players[Self.ClientId]
    .SendPranUnspawn(0, i);
    end;
    if (Servers[Self.ChannelId].Players[Self.ClientId]
    .Account.Header.Pran2.IsSpawned) then
    begin
    Servers[Self.ChannelId].Players[Self.ClientId]
    .SendPranUnspawn(1, i);
    end;
    if (Servers[Self.ChannelId].Players[i].Account.Header.Pran1.IsSpawned)
    then
    begin
    Servers[Self.ChannelId].Players[i].SendPranUnspawn(0,
    Self.ClientId);
    end;
    if (Servers[Self.ChannelId].Players[i].Account.Header.Pran2.IsSpawned)
    then
    begin
    Servers[Self.ChannelId].Players[i].SendPranUnspawn(1,
    Self.ClientId);
    end;
    Self.RemoveFromVisible(Servers[Self.ChannelId].Players[i].Base);
    if (Servers[Self.ChannelId].Players[i].Base.IsActive = False) then
    begin
    ZeroMemory(@Packet, sizeof(Packet));
    Packet.Header.size := sizeof(Packet);
    Packet.Header.Index := $7535;
    Packet.Header.Code := $101;
    Packet.Index := i;
    Self.SendPacket(Packet, Packet.Header.size);
    end;
    end;
    end;
    end;
    Dificult := Servers[Self.ChannelId].Players[Self.ClientId]
    .DungeonIDDificult;
    InstanceiD := Servers[Self.ChannelId].Players[Self.ClientId]
    .DungeonInstanceID;
    for i := Low(Servers[Self.ChannelId].DungeonInstances[InstanceiD].Mobs)
    to High(Servers[Self.ChannelId].DungeonInstances[InstanceiD].Mobs) do
    begin
    if(Servers[Self.ChannelId].DungeonInstances[InstanceiD].Mobs[i].IntName = 0) then
    Continue;
    Logger.Write('Self X: ' +
    Self.PlayerCharacter.LastPos.X.ToString, TLogType.Packets);
    Logger.Write('Self y: ' +
    Self.PlayerCharacter.LastPos.y.ToString, TLogType.Packets);
    Logger.Write('mob X: ' +
    Servers[Self.ChannelId]
    .DungeonInstances[InstanceiD].Mobs[i].Position.X.ToString, TLogType.Packets);
    Logger.Write('mob y: ' +
    Servers[Self.ChannelId]
    .DungeonInstances[InstanceiD].Mobs[i].Position.y.ToString, TLogType.Packets);
    Logger.Write(' ', TLogType.Packets);
    if (Self.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId]
    .DungeonInstances[InstanceiD].Mobs[i].Position, DISTANCE_TO_WATCH))
    then
    begin // spawnando o bicho de acordo com a posição
    if (Self.VisibleMobs.Contains(Servers[Self.ChannelId].DungeonInstances
    [InstanceiD].Mobs[i].Base.ClientId)) then
    Continue;
    Self.VisibleMobs.Add(Servers[Self.ChannelId].DungeonInstances
    [InstanceiD].Mobs[i].Base.ClientId);
    Servers[Self.ChannelId].Players[Self.ClientId].SendSpawnMobDungeon
    (@Servers[Self.ChannelId].DungeonInstances[InstanceiD].Mobs[i]);
    end
    else // se ele não ta perto, ta longe, verificar se tem na visiblemobs
    begin
    if not(Self.VisibleMobs.Contains(Servers[Self.ChannelId]
    .DungeonInstances[InstanceiD].Mobs[i].Base.ClientId)) then
    Continue;
    Self.VisibleMobs.Remove(Servers[Self.ChannelId].DungeonInstances
    [InstanceiD].Mobs[i].Base.ClientId);
    Servers[Self.ChannelId].Players[Self.ClientId].SendRemoveMobDungeon
    (@Servers[Self.ChannelId].DungeonInstances[InstanceiD].Mobs[i]);
    end;
    end;
    end;
  }
  {
    for i in VisibleMobs do
    begin
    if (i > MAX_CONNECTIONS) and (i < 3048) then
    begin
    npcMob := @Servers[Self.ChannelId].NPCs[i].Base;
    if (Self.PlayerCharacter.LastPos.InRange(npcMob.PlayerCharacter.LastPos,
    DISTANCE_TO_FORGET)) then
    begin
    Continue;
    end
    else
    begin
    Self.RemoveFromVisible(npcMob^);
    end;
    end
    else if (i <= MAX_CONNECTIONS) then
    begin
    OtherPlayer := @Servers[Self.ChannelId].Players[i];
    if (OtherPlayer.Status >= TPlayerStatus.Playing) then
    begin
    if (Self.PlayerCharacter.LastPos.InRange
    (OtherPlayer.Base.PlayerCharacter.LastPos, DISTANCE_TO_FORGET)) then
    begin
    Continue;
    end
    else
    begin
    Self.RemoveFromVisible(OtherPlayer.Base);
    end;
    end
    else
    begin
    //OtherPlayer.Base.SendRemoveMob(0, Self.ClientId, False);
    end;
    end;
    end; }
end;
procedure TBaseMob.AddToVisible(var mob: TBaseMob; SpawnType: Byte = 0);
begin
  if (Self.IsPlayer) then
  begin
    if not(VisiblePlayers.Contains(mob.ClientID)) then
    begin
      //if (Servers[Self.ChannelId].Players[Self.ClientID].IsInstantiated) then
      //begin
        VisiblePlayers.Add(mob.ClientID);
        mob.AddToVisible(Self);
        mob.SendCreateMob(SPAWN_NORMAL, Self.ClientID, False);
      //end;
      if not(Self.AddTargetToList(@mob)) then
      begin
        Logger.Write('Não foi possível adicionar alvo na lista de targets.',
          TLogType.Error);
      end;
    end;
  end
  else
  begin
    if (mob.IsPlayer) then
    begin
      VisiblePlayers.Add(mob.ClientID);
      if not(mob.VisiblePlayers.Contains(Self.ClientID)) then
      begin
        mob.VisiblePlayers.Add(Self.ClientID);
      end;
    end;
  end;
end;
procedure TBaseMob.RemoveFromVisible(mob: TBaseMob; SpawnType: Byte = 0);
begin
  try
    if ((mob.IsActive = False) or (mob.ClientID = 0)) then
      Exit;
    // if(mob.ClientID = 0) then
    // Exit;
    if (Self.IsActive = False) then
      Exit;
    VisiblePlayers.Remove(mob.ClientID);
    if (Self.IsPlayer) then
      mob.SendRemoveMob(0, Self.ClientID);
    if (mob.VisiblePlayers.Contains(Self.ClientID)) then
    begin
      mob.RemoveFromVisible(Self);
      mob.RemoveTargetFromList(@Self);
    end;
    Self.RemoveTargetFromList(@mob);
    if (target <> NIL) AND (target.ClientID = mob.ClientID) then
      target := NIL;
  except
    on E: Exception do
    begin
      Logger.Write('Error at removefromvisible: ' + E.Message, TLogType.Error);
    end;
  end;
end;
function TBaseMob.AddTargetToList(target: PBaseMob): Boolean;
var
  id, id2: WORD;
begin
  Result := False;
  try
    if not(ContainsTargetInList(target.ClientID, id2)) then
    begin
      VisibleTargetsCnt := Length(VisibleTargets) + 1;
      SetLength(VisibleTargets, VisibleTargetsCnt);
      //id := VisibleTargetsCnt;
      if (GetEmptyTargetInList(id)) then
      begin
        VisibleTargets[id].ClientID := target.ClientID;

         case target.ClientID of
            1..1000:
              begin
                VisibleTargets[id].Position := target.PlayerCharacter.LastPos;
                VisibleTargets[id].Player := target;
                VisibleTargets[id].TargetType := 0;
              end;
            1001..3339, 3370..9147:
              begin
                VisibleTargets[id].Position :=
                  Servers[Self.ChannelId].MOBS.TMobS[target.Mobid].MobsP[target.SecondIndex].Base.PlayerCharacter.LastPos;
                VisibleTargets[id].mob := target;
                VisibleTargets[id].TargetType := 1;
              end;
            3340 .. 3354:
              begin
                VisibleTargets[id].Position := Servers[Self.ChannelId]
                  .DevirStones[target.ClientID].PlayerChar.LastPos;
                VisibleTargets[id].mob := target;
                VisibleTargets[id].TargetType := 1;
              end;
            3355 .. 3369:
              begin
                VisibleTargets[id].Position := Servers[Self.ChannelId]
                  .DevirGuards[target.ClientID].PlayerChar.LastPos;
                VisibleTargets[id].mob := target;
                VisibleTargets[id].TargetType := 1;
              end;
         end;
        Result := True;
      end
      else
      begin
        VisibleTargetsCnt := Length(VisibleTargets) + 1;
        SetLength(VisibleTargets, VisibleTargetsCnt);
        id := VisibleTargetsCnt-1;
        VisibleTargets[id].ClientID := target.ClientID;

         case target.ClientID of
            1..1000:
              begin
                VisibleTargets[id].Position := target.PlayerCharacter.LastPos;
                VisibleTargets[id].Player := target;
                VisibleTargets[id].TargetType := 0;
              end;
            1001..3339, 3370..9147:
              begin
                VisibleTargets[id].Position :=
                  Servers[Self.ChannelId].MOBS.TMobS[target.Mobid].MobsP[target.SecondIndex].Base.PlayerCharacter.LastPos;
                VisibleTargets[id].mob := target;
                VisibleTargets[id].TargetType := 1;
              end;
            3340 .. 3354:
              begin
                VisibleTargets[id].Position := Servers[Self.ChannelId]
                  .DevirStones[target.ClientID].PlayerChar.LastPos;
                VisibleTargets[id].mob := target;
                VisibleTargets[id].TargetType := 1;
              end;
            3355 .. 3369:
              begin
                VisibleTargets[id].Position := Servers[Self.ChannelId]
                  .DevirGuards[target.ClientID].PlayerChar.LastPos;
                VisibleTargets[id].mob := target;
                VisibleTargets[id].TargetType := 1;
              end;
         end;
        Result := True;
      end;
    end
    else
    begin
      Result := True;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('AddTargetToList: ' + E.Message, TLogType.Error);
    end;
  end;
end;
function TBaseMob.RemoveTargetFromList(target: PBaseMob): Boolean;
var
  id: WORD;
begin
  Result := False;
  if (ContainsTargetInList(target, id)) then
  begin
    VisibleTargets[id].ClientID := 0;
    VisibleTargets[id].TargetType := 0;
    VisibleTargets[id].Position.x := 0;
    VisibleTargets[id].Position.y := 0;
    VisibleTargets[id].Player := nil;
    VisibleTargets[id].mob := nil;
    dec(VisibleTargetsCnt, 1);
    Result := True;
  end;
end;
function TBaseMob.ContainsTargetInList(target: PBaseMob; out id: WORD): Boolean;
var
  i: WORD;
begin
  Result := False;

  if(Length(VisibleTargets) = 0) then
  begin
    Exit;
  end;

  for i := 0 to Length(VisibleTargets)-1 do
  begin
    if (VisibleTargets[i].ClientID = target.ClientID) then
    begin
      id := i;
      Result := True;
      break;
    end;
  end;
end;
function TBaseMob.ContainsTargetInList(ClientID: WORD): Boolean;
var
  i: WORD;
begin
  Result := False;

  if(Length(VisibleTargets) = 0) then
  begin
    Exit;
  end;

  for i := 0 to Length(VisibleTargets)-1 do
  begin
    if (VisibleTargets[i].ClientID = ClientID) then
    begin
      Result := True;
      break;
    end;
  end;
end;
function TBaseMob.ContainsTargetInList(ClientID: WORD; out id: WORD): Boolean;
var
  i: WORD;
begin
  Result := False;

  if(Length(VisibleTargets) = 0) then
  begin
    Exit;
  end;

  for i := 0 to Length(VisibleTargets)-1 do
  begin
    if (VisibleTargets[i].ClientID = ClientID) then
    begin
      Result := True;
      id := i;
      break;
    end;
  end;
end;
function TBaseMob.GetEmptyTargetInList(out Index: WORD): Boolean;
var
  i: WORD;
begin
  Result := False;
  if (Length(Self.VisibleTargets) > 0) then
  begin
    for i := Low(VisibleTargets) to High(VisibleTargets) do
    begin
      if (VisibleTargets[i].ClientID > 0) then
        Continue;

      Index := i;
      Result := True;
      break;
    end;
  end;

  {if(Result = False) then
  begin
    SetLength(VisibleTargets, Length(VisibleTargets) + 1);
    Index := High(VisibleTargets);
    Result := True;
  end;}
end;
function TBaseMob.GetTargetInList(ClientID: WORD): PBaseMob;
var
  i: WORD;
begin
  Result := nil;

  if(Length(VisibleTargets) = 0) then
  begin
    Exit;
  end;

  for i := 0 to Length(VisibleTargets)-1 do
  begin
    if (VisibleTargets[i].ClientID = ClientID) then
    begin
      case VisibleTargets[i].TargetType of
        0:
          Result := PBaseMob(VisibleTargets[i].Player);
        1:
          Result := PBaseMob(VisibleTargets[i].mob);
      end;
      break;
    end;
  end;
end;
function TBaseMob.ClearTargetList(): Boolean;
var
  i: WORD;
begin
  Result := False;

  if(Length(VisibleTargets) = 0) then
  begin
    VisibleTargetsCnt := 0;

    Result := True;
    Exit;
  end;

  for i := 0 to Length(VisibleTargets)-1 do
  begin
    VisibleTargets[i].ClientID := 0;
    VisibleTargets[i].TargetType := 0;
    VisibleTargets[i].Position.x := 0;
    VisibleTargets[i].Position.y := 0;
    VisibleTargets[i].Player := nil;
    VisibleTargets[i].mob := nil;
  end;
  SetLength(VisibleTargets, 0); //////
  VisibleTargetsCnt := 0;

  Result := True;
end;
function TBaseMob.TargetGarbageService(): Boolean;
var
  OtherList: Array of TMobTarget;
  i, cnt, cnt2, id, id2: WORD;
begin
  cnt := 0;
  Result := False;

  if(Length(VisibleTargets) = 0) then
  begin
    Result := True;
    Exit;
  end;

  for i := 0 to Length(VisibleTargets)-1 do
  begin
    if(VisibleTargets[i].TargetType = 0) then
    begin
      if(VisibleTargets[i].Player = nil) then
        Continue;
      if ((VisibleTargets[i].ClientID > 0) and not(PBaseMob(VisibleTargets[i].Player).IsDead)) then
      begin
        Inc(cnt, 1);
        SetLength(OtherList, cnt);
        id := (cnt - 1);
        OtherList[id].ClientID := VisibleTargets[i].ClientID;
        OtherList[id].TargetType := VisibleTargets[i].TargetType;
        OtherList[id].Position := VisibleTargets[i].Position;
        OtherList[id].Player := VisibleTargets[i].Player;
        OtherList[id].mob := VisibleTargets[i].mob;
      end;
      VisibleTargets[i].ClientID := 0;
      VisibleTargets[i].TargetType := 0;
      VisibleTargets[i].Position.x := 0;
      VisibleTargets[i].Position.y := 0;
      VisibleTargets[i].Player := nil;
      VisibleTargets[i].mob := nil;
    end
    else if(VisibleTargets[i].TargetType = 1) then
    begin
      if(VisibleTargets[i].Mob = nil) then
        Continue;

      if ((VisibleTargets[i].ClientID > 0) and not(PBaseMob(VisibleTargets[i].Mob).IsDead)) then
      begin
        Inc(cnt, 1);
        SetLength(OtherList, cnt);
        id := (cnt - 1);
        OtherList[id].ClientID := VisibleTargets[i].ClientID;
        OtherList[id].TargetType := VisibleTargets[i].TargetType;

        case VisibleTargets[i].ClientID of
          2001..3339, 3370..9147:
            begin
              OtherList[id].Position :=
                Servers[Self.ChannelId].MOBS.TMobS[PBaseMob(VisibleTargets[i].Mob).Mobid].MobsP[PBaseMob(VisibleTargets[i].Mob).SecondIndex].Base.PlayerCharacter.LastPos;
            end;
          3340 .. 3354:
            begin
              OtherList[id].Position := Servers[Self.ChannelId]
                .DevirStones[PBaseMob(VisibleTargets[i].Mob).ClientID].PlayerChar.LastPos;
            end;
          3355 .. 3369:
            begin
              OtherList[id].Position := Servers[Self.ChannelId]
                .DevirGuards[PBaseMob(VisibleTargets[i].Mob).ClientID].PlayerChar.LastPos;
            end;
        end;

        OtherList[id].Position := VisibleTargets[i].Position;
        OtherList[id].Player := VisibleTargets[i].Player;
        OtherList[id].mob := VisibleTargets[i].mob;
      end;
      VisibleTargets[i].ClientID := 0;
      VisibleTargets[i].TargetType := 0;
      VisibleTargets[i].Position.x := 0;
      VisibleTargets[i].Position.y := 0;
      VisibleTargets[i].Player := nil;
      VisibleTargets[i].mob := nil;
    end;
  end;
  SetLength(VisibleTargets, 0); ////////////////
  VisibleTargetsCnt := 0;
  cnt2 := 0;
  if (cnt > 0) then
  begin
    for i := 0 to Length(OtherList)-1 do
    begin
      Inc(cnt2, 1);
      SetLength(VisibleTargets, cnt2);
      //id2 := Length(VisibleTargets);
      id2 := (cnt2 - 1);
      VisibleTargets[id2].ClientID := OtherList[i].ClientID;
      VisibleTargets[id2].TargetType := OtherList[i].TargetType;
      VisibleTargets[id2].Position := OtherList[i].Position;
      VisibleTargets[id2].Player := OtherList[i].Player;
      VisibleTargets[id2].mob := OtherList[i].mob;
    end;
    Result := True;
  end;
end;
{
  function TBaseMob.CurrentPosition: TPosition;
  var
  Delta: Single;
  begin
  if not _currentPosition.IsValid then
  _currentPosition := PlayerCharacter.LastPos;
  if not(_prediction.CanPredict) then
  begin
  Result := _currentPosition;
  Exit;
  end;
  Result := _prediction.Interpolate(Delta);
  { // if not TFunctions.UpdateWorld(ClientId, Result, WORLD_MOB) then
  // begin
  // Result := _currentPosition;
  // exit;
  // end;
  // if Character.Last.Distance(_currentPosition) > 4 then
  // IsDirty := true; }
{ Result := PlayerCharacter.LastPos;
  _currentPosition := Result;
  end; }
procedure TBaseMob.SetDestination(const Destination: TPosition);
begin
  _prediction.Source := PlayerCharacter.LastPos;
  if (_prediction.Source = Destination) then
    Exit;
  _prediction.Timer.Stop;
  _prediction.Timer.Reset;
  _prediction.Timer.Start;
  _prediction.Destination := Destination;
  _prediction.CalcETA(PlayerCharacter.SpeedMove);
end;
procedure TBaseMob.addvisible(m: TBaseMob);
begin
  Self.AddToVisible(m);
end;
procedure TBaseMob.removevisible(m: TBaseMob);
begin
  Self.RemoveFromVisible(m);
end;
procedure TBaseMob.AddHP(Value: Integer; ShowUpdate: Boolean);
begin
  if (Self.ClientID >= 3048) then
  begin
    Inc(Servers[Self.ChannelId].Mobs.TMobS[Self.Mobid].MobsP[Self.SecondIndex]
      .HP, Value);
    Self.SendCurrentHPMP(ShowUpdate);
    Exit;
  end;
  Inc(Self.Character.CurrentScore.CurHP, Value);
  Self.SendCurrentHPMP(ShowUpdate);
end;
procedure TBaseMob.AddMP(Value: Integer; ShowUpdate: Boolean);
begin
  if (Self.ClientID >= 3048) then
    Exit;
  Inc(Self.Character.CurrentScore.CurMP, Value);
  Self.SendCurrentHPMP(ShowUpdate);
end;
procedure TBaseMob.RemoveHP(Value: Integer; ShowUpdate: Boolean; StayOneHP: Boolean);
var
  Packet: TSendCurrentHPMPPacket;
begin
  if (Self.ClientID >= 3048) then
  begin
    //if not(Self.Mobid > 0) then
      //Exit;

    deccardinal(Servers[Self.ChannelId].Mobs.TMobS[Self.Mobid].MobsP
      [Self.SecondIndex].HP, Value);
    if(StayOneHP) then
    begin
      if(Servers[Self.ChannelId].Mobs.TMobS[Self.Mobid].MobsP
      [Self.SecondIndex].HP = 0) then
        Servers[Self.ChannelId].Mobs.TMobS[Self.Mobid].MobsP
      [Self.SecondIndex].HP := 1;
    end;
    ZeroMemory(@Packet, sizeof(TSendCurrentHPMPPacket));
    Packet.Header.size := sizeof(TSendCurrentHPMPPacket);
    Packet.Header.Code := $103; // AIKA
    Packet.Header.Index := Servers[Self.ChannelId].Mobs.TMobS[Self.Mobid].MobsP
      [Self.SecondIndex].Index;
    if(ShowUpdate) then
      Packet.Null := 1;
    Packet.MaxHP := Servers[Self.ChannelId].Mobs.TMobS[Self.Mobid].InitHP;
    Packet.MaxMP := Servers[Self.ChannelId].Mobs.TMobS[Self.Mobid].InitHP;
    Packet.CurHP := Servers[Self.ChannelId].Mobs.TMobS[Self.Mobid].MobsP
      [Self.SecondIndex].HP;
    Packet.CurMP := Packet.MaxMP;

    Self.SendToVisible(Packet, Packet.Header.Size, False);
    {if(Servers[Self.ChannelId].Mobs.TMobS[Self.Mobid].MobsP
      [Self.SecondIndex].AttackerID > 0) then
    begin
      Servers[Self.ChannelId].Players[Servers[Self.ChannelId].Mobs.TMobS[Self.Mobid].MobsP
        [Self.SecondIndex].AttackerID].Base.SendToVisible(Packet, Packet.Header.Size);
    end
    else
      Self.SendToVisible(Packet, Packet.Header.Size, False);}
    Exit;
  end;
  deccardinal(Self.Character.CurrentScore.CurHP, Value);

  if(Self.Character.CurrentScore.CurHP <=
    Trunc((Self.Character.CurrentScore.MaxHp / 100 ) * 50)) then
  begin
    Self.RemoveBuffByIndex(108);
  end;

  if(StayOneHP) then
  begin
    if(Self.Character.CurrentScore.CurHP = 0) then
      Self.Character.CurrentScore.CurHP := 1;
  end;
  // mod dia 30/04/2021
  Self.SendCurrentHPMP(ShowUpdate);

  if (Self.BuffExistsByIndex(134)) then
    if (Self.Character.CurrentScore.CurHP <
      (Self.Character.CurrentScore.MaxHP div 2)) then
    begin
      //Helper := mob.GetBuffIDByIndex(134);
      //mob.AddHP(mob.CalcCure2(SkillData[Helper].EFV[0], mob, Helper), True);
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
          ('Cura preventiva entrou em ação e feitiço foi desfeito.', 0);
      Self.RemoveBuffByIndex(134);
    end;

  if(Self.Character.CurrentScore.CurHP = 0) then
  begin
    //Self.Character.CurrentScore.CurHP := 0;
    Self.SendCurrentHPMP();
    Self.SendEffect($0);
    Exit;
  end;
end;
procedure TBaseMob.RemoveMP(Value: Integer; ShowUpdate: Boolean);
begin
  if (Self.ClientID >= 3048) then
    Exit;
  deccardinal(Self.Character.CurrentScore.CurMP, Value);
  Self.SendCurrentHPMP(ShowUpdate);
end;
procedure TBaseMob.WalkinTo(Pos: TPosition);
{ var
  Dist, h: Integer;
  i: Integer;
  nx, ny: Single; }
begin
  Self.WalkTo(Pos, 70);
  // Dist := Self.PlayerCharacter.LastPos.Distance(Pos);
  // h := Round(Dist div 4);
  // if (h < 1) then
  // h := 1;
  { if (Self.PlayerCharacter.LastPos.X > Pos.X) and
    (Self.PlayerCharacter.LastPos.Y > Pos.Y) then
    begin
    for i := 1 to h do
    begin
    if (Self.PlayerCharacter.LastPos.X - 4) <= Pos.X then
    nx := Pos.X
    else
    nx := Self.PlayerCharacter.LastPos.X - 4;
    if (Self.PlayerCharacter.LastPos.Y - 4) <= Pos.Y then
    ny := Pos.Y
    else
    ny := Self.PlayerCharacter.LastPos.Y - 4;
    Self.WalkTo(TPosition.Create(nx, ny), 100);
    end;
    end;
    if (Self.PlayerCharacter.LastPos.X < Pos.X) and
    (Self.PlayerCharacter.LastPos.Y < Pos.Y) then
    begin
    for i := 1 to h do
    begin
    if (Self.PlayerCharacter.LastPos.X + 4) >= Pos.X then
    nx := Pos.X
    else
    nx := Self.PlayerCharacter.LastPos.X + 4;
    if (Self.PlayerCharacter.LastPos.Y + 4) >= Pos.Y then
    ny := Pos.Y
    else
    ny := Self.PlayerCharacter.LastPos.Y + 4;
    Self.WalkTo(TPosition.Create(nx, ny), 100);
    end;
    end;
    if (Self.PlayerCharacter.LastPos.X > Pos.X) and
    (Self.PlayerCharacter.LastPos.Y < Pos.Y) then
    begin
    for i := 1 to h do
    begin
    if (Self.PlayerCharacter.LastPos.X - 4) <= Pos.X then
    nx := Pos.X
    else
    nx := Self.PlayerCharacter.LastPos.X - 4;
    if (Self.PlayerCharacter.LastPos.Y + 4) >= Pos.Y then
    ny := Pos.Y
    else
    ny := Self.PlayerCharacter.LastPos.Y + 4;
    Self.WalkTo(TPosition.Create(nx, ny), 100);
    end;
    end;
    if (Self.PlayerCharacter.LastPos.X < Pos.X) and
    (Self.PlayerCharacter.LastPos.Y > Pos.Y) then
    begin
    for i := 1 to h do
    begin
    if (Self.PlayerCharacter.LastPos.X + 4) >= Pos.X then
    nx := Pos.X
    else
    nx := Self.PlayerCharacter.LastPos.X + 4;
    if (Self.PlayerCharacter.LastPos.Y - 4) <= Pos.Y then
    ny := Pos.Y
    else
    ny := Self.PlayerCharacter.LastPos.Y - 4;
    Self.WalkTo(TPosition.Create(nx, ny), 100);
    end;
    end; }
end;
procedure TBaseMob.SetEquipEffect(const Equip: TItem; SetType: Integer;
  ChangeConjunt: Boolean = True; VerifyExpired: Boolean = True);
var
  i, ResultOf, EmptySlot: Integer;
begin
  if(ItemList[Equip.Index].ItemType = 10) then
    Exit;

  if(VerifyExpired) then
  begin
    if ((ItemList[Equip.Index].Expires) and not(Equip.IsSealed)) then
    begin
      ResultOf := CompareDateTime(Now, Equip.ExpireDate);
      //se o item está expirado (roupa pran ou montaria)
      if (ResultOf = 1) then
      begin
        Exit;
      end
      else if((Equip.Time = $FFFF) and (TItemFunctions.GetItemEquipSlot(Equip.Index) = 9)) then
        Exit;
    end;
  end;

  if (Conjuntos[Equip.Index] > 0) and (ChangeConjunt) then
    SetConjuntEffect(Equip.Index, SetType);
  case SetType of
    EQUIPING_TYPE:
      begin
        for i := 0 to 2 do
        begin
          if Equip.Effects.Index[i] > 0 then
            Inc(Self.MOB_EF[Equip.Effects.Index[i]],
              Equip.Effects.Value[i] * 2);
          if ItemList[Equip.Index].EF[i] > 0 then
            Inc(Self.MOB_EF[ItemList[Equip.Index].EF[i]],
              ItemList[Equip.Index].EFV[i]);


          {if (ItemList[Equip.Index].HP > 0) then
          begin
            Inc(Self.MOB_EF[EF_HP],ItemList[Equip.Index].HP);
          end;
          if (ItemList[Equip.Index].MP > 0) then
          begin
            Inc(Self.MOB_EF[EF_MP],ItemList[Equip.Index].MP);
          end;}
        end;

        if(ItemList[Equip.Index].ItemType = 8) then
        begin
          EmptySlot := SearchEmptyEffect5Slot();
          if not(EmptySlot = 255) then
            Self.EFF_5[EmptySlot] := ItemList[Equip.Index].MeshIDEquip;
        end;
      end;
    DESEQUIPING_TYPE:
      begin
        for i := 0 to 2 do
        begin
          if Equip.Effects.Index[i] > 0 then
            dec(Self.MOB_EF[Equip.Effects.Index[i]],
              Equip.Effects.Value[i] * 2);
          if ItemList[Equip.Index].EF[i] > 0 then
            dec(Self.MOB_EF[ItemList[Equip.Index].EF[i]],
              ItemList[Equip.Index].EFV[i]);


          {if (ItemList[Equip.Index].HP > 0) then
          begin
            Dec(Self.MOB_EF[EF_HP],ItemList[Equip.Index].HP);
          end;
          if (ItemList[Equip.Index].MP > 0) then
          begin
            Dec(Self.MOB_EF[EF_MP],ItemList[Equip.Index].MP);
          end;}
        end;

        if(ItemList[Equip.Index].ItemType = 8) then
        begin
          EmptySlot := GetSlotOfEffect5(ItemList[Equip.Index].MeshIDEquip);
          if not(EmptySlot = 255) then
            Self.EFF_5[EmptySlot] := 0;
        end;
      end;
    SAME_ITEM_TYPE:
      begin
        // Alterar apenas os atributos de acordo com o refine;
      end;
  end;
end;
procedure TBaseMob.SetConjuntEffect(Index: Integer; SetType: Integer);
var
  CfgEffect: Integer;
begin
  if Index = 0 then
    Exit;
  Self.EQUIP_CONJUNT[TItemFunctions.GetItemEquipSlot(Index)] :=
    Conjuntos[Index];
  CfgEffect := TItemFunctions.GetConjuntCount(Self, Index);
  case CfgEffect of
    3:
      ConfigEffect(3, Conjuntos[Index], SetType);
    4:
      ConfigEffect(4, Conjuntos[Index], SetType);
    5:
      ConfigEffect(5, Conjuntos[Index], SetType);
    6:
      ConfigEffect(6, Conjuntos[Index], SetType);
  end;
  if SetType = DESEQUIPING_TYPE then
    Self.EQUIP_CONJUNT[TItemFunctions.GetItemEquipSlot(Index)] := 0;
end;
procedure TBaseMob.ConfigEffect(Count: Integer; ConjuntId: Integer;
  SetType: Integer);
var
  i: Integer;
  EmptySlot: Byte;
begin
  EmptySlot := 255;
  case SetType of
    EQUIPING_TYPE:
      begin
        for i := 0 to 5 do
        begin
          if SetItem[ConjuntId].EffSlot[i] <> Count then
            Continue;
          Inc(Self.MOB_EF[SetItem[ConjuntId].EF[i]], SetItem[ConjuntId].EFV[i]);
          if (SetItem[ConjuntId].EF[i] = EF_CALLSKILL) then
          begin // se for eff_5
            EmptySlot := SearchEmptyEffect5Slot();
            if (EmptySlot = 255) then
              Continue;
            Self.EFF_5[EmptySlot] := SetItem[ConjuntId].EFV[i];
          end;
        end;
      end;
    DESEQUIPING_TYPE:
      begin
        for i := 0 to 5 do
        begin
          if SetItem[ConjuntId].EffSlot[i] <> Count then
            Continue;
          dec(Self.MOB_EF[SetItem[ConjuntId].EF[i]], SetItem[ConjuntId].EFV[i]);
          if (SetItem[ConjuntId].EF[i] = EF_CALLSKILL) then
          begin // se for eff_5
            EmptySlot := GetSlotOfEffect5(SetItem[ConjuntId].EFV[i]);
            if (EmptySlot = 255) then
              Continue;
            Self.EFF_5[EmptySlot] := 0;
          end;
        end;
      end;
  end;
end;

procedure TBaseMob.SetOnTitleActiveEffect();
var
  i: Integer;
begin
  if(Self.PlayerCharacter.ActiveTitle.Index > 0) then
  begin
    for I := 0 to 2 do
    begin
      if(Titles[Self.PlayerCharacter.ActiveTitle.Index].TitleLevel
        [Self.PlayerCharacter.ActiveTitle.Level-1].EF[i] = 0) then
          Continue;

      Self.IncreasseMobAbility(Titles[Self.PlayerCharacter.ActiveTitle.Index].TitleLevel
        [Self.PlayerCharacter.ActiveTitle.Level-1].EF[i],
        Titles[Self.PlayerCharacter.ActiveTitle.Index].TitleLevel
        [Self.PlayerCharacter.ActiveTitle.Level-1].EFV[i]);
    end;
  end;
end;

procedure TBaseMob.SetOffTitleActiveEffect();
var
  i: Integer;
begin
  if(Self.PlayerCharacter.ActiveTitle.Index > 0) then
  begin
    for I := 0 to 2 do
    begin
      if(Titles[Self.PlayerCharacter.ActiveTitle.Index].TitleLevel
        [Self.PlayerCharacter.ActiveTitle.Level-1].EF[i] = 0) then
          Continue;

      Self.DecreasseMobAbility(Titles[Self.PlayerCharacter.ActiveTitle.Index].TitleLevel
        [Self.PlayerCharacter.ActiveTitle.Level-1].EF[i],
        Titles[Self.PlayerCharacter.ActiveTitle.Index].TitleLevel
        [Self.PlayerCharacter.ActiveTitle.Level-1].EFV[i]);
    end;
  end;
end;
function TBaseMob.MatchClassInfo(ClassInfo: Byte): Boolean;
begin
  Result := (Self.GetMobClass = Self.GetMobClass(ClassInfo));
end;
function TBaseMob.IsCompleteEffect5(out CountEffects: Byte): Boolean;
var
  i: Byte;
begin
  Result := False;
  for i := 0 to 2 do
  begin
    if (EFF_5[i] > 0) then
    begin
      Inc(CountEffects);
      Result := True;
    end;
  end;
  // if (Self.GetMobAbility(EF_CALLSKILL) > 0) then
  // begin
  // Result := True;
  // end;
end;
function TBaseMob.SearchEmptyEffect5Slot(): Byte;
var
  i: Byte;
begin
  Result := 255;
  for i := 0 to 2 do
  begin
    if (Self.EFF_5[i] = 0) then
    begin
      Result := i;
      break;
    end;
  end;
end;
function TBaseMob.GetSlotOfEffect5(CallID: WORD): Byte;
var
  i: Byte;
begin
  Result := 255;
  for i := 0 to 2 do
  begin
    if (Self.EFF_5[i] = CallID) then
    begin
      Result := i;
      break;
    end;
  end;
end;

procedure TBaseMob.LureMobsInRange;
var
  i: integer;
begin
  for I := Low(Self.VisibleTargets) to High(Self.VisibleTargets) do
  begin
    if(Self.VisibleTargets[i].TargetType = 1) then
    begin
      if(Servers[Self.ChannelId].MOBS.TMobS[PBaseMob(Self.VisibleTargets[i].Mob).Mobid].MobsP[
        PBaseMob(Self.VisibleTargets[i].Mob).SecondIndex].CurrentPos.Distance(
          Self.PlayerCharacter.LastPos) <= 8) then
      begin
        if (not(Servers[Self.ChannelId].MOBS.TMobS[PBaseMob(Self.VisibleTargets[i].Mob).Mobid].MobsP[
        PBaseMob(Self.VisibleTargets[i].Mob).SecondIndex].isGuard) and not(
        Servers[Self.ChannelId].MOBS.TMobS[PBaseMob(Self.VisibleTargets[i].Mob).Mobid].MobsP[
        PBaseMob(Self.VisibleTargets[i].Mob).SecondIndex].isMutant)) then
        begin
          if not(AnsiPos('Max', String(Servers[Self.ChannelId].MOBS.TMobS[PBaseMob(Self.VisibleTargets[i].Mob).Mobid].Name)) > 0) then
          begin
            if not(Servers[Self.ChannelId].MOBS.TMobS[PBaseMob(Self.VisibleTargets[i].Mob).Mobid].MobsP[
            PBaseMob(Self.VisibleTargets[i].Mob).SecondIndex].IsAttacked) then
            begin
              Servers[Self.ChannelId].MOBS.TMobS[PBaseMob(Self.VisibleTargets[i].Mob).Mobid].MobsP[
              PBaseMob(Self.VisibleTargets[i].Mob).SecondIndex].IsAttacked := True;
              Servers[Self.ChannelId].MOBS.TMobS[PBaseMob(Self.VisibleTargets[i].Mob).Mobid].MobsP[
              PBaseMob(Self.VisibleTargets[i].Mob).SecondIndex].AttackerID := Self.ClientID;
              Servers[Self.ChannelId].MOBS.TMobS[PBaseMob(Self.VisibleTargets[i].Mob).Mobid].MobsP[
              PBaseMob(Self.VisibleTargets[i].Mob).SecondIndex].FirstPlayerAttacker := Self.ClientID;
            end;
          end;
        end;
      end;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Sends'}
procedure TBaseMob.SendToVisible(var Packet; size: WORD; sendToSelf: Boolean);
var
  i: WORD;
  xPlayer: PPlayer;
begin
  sendToSelf := IfThen(sendToSelf, IsPlayer, False);
  if (sendToSelf) then
    Self.SendPacket(Packet, size);
  if (Self.ClientID <= 3048) then
  begin
    for i in VisiblePlayers do
    begin
      try
        xPlayer := @Servers[Self.ChannelId].Players[i];
        if (xPlayer.Status >= Playing) then
          xPlayer.SendPacket(Packet, size);
      except
        Continue;
      end;
    end;
  end
  else
  begin
    for i in VisibleMobs do
    begin
      try
        if (i > MAX_CONNECTIONS) then
          Continue; // new
        xPlayer := @Servers[Self.ChannelId].Players[i];
        if (xPlayer.Status >= Playing) then
          xPlayer.SendPacket(Packet, size);
      except
        continue;
      end;
    end;
  end;
end;
procedure TBaseMob.SendPacket(var Packet; size: WORD);
begin
  Servers[ChannelId].SendPacketTo(ClientID, Packet, size);
end;
procedure TBaseMob.SendCreateMob(SpawnType: WORD = 0; sendTo: WORD = 0;
  SendSelf: Boolean = True; Polimorf: WORD = 0);
var
  Packet: TSendCreateMobPacket;
  Packet2: TSpawnMobPacket;
  PacketAct: TSendActionPacket;
  RlkSlot: Byte;
  i: Integer;
begin
  ZeroMemory(@Packet, sizeof(Packet));

  if (Polimorf > 0) then
  begin
    //Self.SendRemoveMob(0, 0, False);

    ZeroMemory(@Packet2, sizeof(Packet2));

    Packet2.Header.Size := sizeof(Packet2);
    Packet2.Header.Code := $35E;
    Packet2.Header.Index := Self.ClientID;

    Packet2.Position := Self.PlayerCharacter.LastPos;
    Packet2.Rotation := Self.PlayerCharacter.Rotation;
    Packet2.CurHP := Self.Character.CurrentScore.CurHP;
    Packet2.CurMP := Self.Character.CurrentScore.CurMP;
    Packet2.MaxHP := Self.Character.CurrentScore.MaxHp;
    Packet2.MaxMP := Self.Character.CurrentScore.MaxMp;

    Packet2.Level := Self.Character.Level;
    Packet2.SpawnType := 0;

    //Packet2.Unk_0 := $0A;

    Packet2.Equip[0] := Polimorf;
    Packet2.Equip[1] := Polimorf;
    Packet2.Equip[6] := 0;
    Packet2.Equip[7] := 0;
    Packet2.Altura := 7;
    Packet2.Tronco := 119;
    Packet2.Perna := 119;
    Packet2.Corpo := 0;
    Packet2.IsService := False;
    Packet2.MobType := 1;
    Packet2.Nation := Self.Character.Nation;
    Packet2.MobName := $7535;

    if (sendTo > 0) then
      Servers[Self.ChannelId].SendPacketTo(sendTo, Packet2, Packet2.Header.size)
    else
    begin
      Self.SendPacket(Packet2, Packet2.Header.Size);

      for i in Self.VisiblePlayers do
      begin
        if(Servers[Self.ChannelId].Players[i].Base.Character.Nation =
          Self.Character.Nation) then
        begin
          Packet2.Nation := 0;
        end
        else
        begin
          Packet2.Nation := Self.Character.Nation;
        end;

        Servers[Self.ChannelId].Players[i].SendPacket(Packet2, Packet2.Header.Size);
      end;

      //Self.SendToVisible(Packet2, Packet2.Header.size, SendSelf);
    end;
  end
  else
  begin
    if (Self.PlayerCharacter.PlayerKill) then
      Inc(SpawnType, $80);

    Self.GetCreateMob(Packet, sendTo);
    Packet.SpawnType := SpawnType;

    if(Self.InClastleVerus) then
    begin
      Packet.GuildIndexAndNation := Self.NationForCastle * 4096;
    end;

    if (sendTo > 0) then
      Servers[Self.ChannelId].SendPacketTo(sendTo, Packet, Packet.Header.size)
    else
      Self.SendToVisible(Packet, Packet.Header.size, SendSelf);

    if(Self.ClientID <= MAX_CONNECTIONS) then
    begin
      RlkSlot := TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players[Self.ClientID],
        40, INV_TYPE, 0);
      if(RlkSlot <> 255) then
      begin
        Self.SendEffect(32);
      end;
    end;

    if((Self.CurrentAction <> 0) and (sendTo > 0)) then
    begin
      ZeroMemory(@PacketAct, sizeof(PacketAct));

      PacketAct.Header.size := sizeof(PacketAct);
      PacketAct.Header.Index := Self.ClientID;
      PacketAct.Header.Code := $304;

      PacketAct.Index := Self.CurrentAction;
      PacketAct.InLoop := 1;

      Servers[Self.ChannelId].SendPacketTo(SendTo, PacketAct, PacketAct.Header.size);
    end
    else if(Servers[Self.ChannelId].Players[sendTo].Base.CurrentAction <> 0) then
    begin
      ZeroMemory(@PacketAct, sizeof(PacketAct));

      PacketAct.Header.size := sizeof(PacketAct);
      PacketAct.Header.Index := SendTo;
      PacketAct.Header.Code := $304;

      PacketAct.Index := Servers[Self.ChannelId].Players[sendTo].Base.CurrentAction;
      if(Servers[Self.ChannelId].Players[sendTo].Base.CurrentAction = 65) then
        PacketAct.InLoop := 1;

      Self.SendPacket(PacketAct, PacketAct.Header.size);
    end;
  end;

  {if (Polimorf > 0) then
  begin
    Self.SendCurrentHPMP(True);
  end;}

end;
procedure TBaseMob.SendRemoveMob(delType: Integer = DELETE_NORMAL;
  sendTo: WORD = 0; SendSelf: Boolean = True);
var
  Packet: TSendRemoveMobPacket;
  mob: TBaseMob;
  i: WORD;
begin
  Packet.Header.size := sizeof(TSendRemoveMobPacket);
  Packet.Header.Code := $101; // aika
  Packet.Header.Index := $7535;
  Packet.Index := Self.ClientID;
  Packet.DeleteType := delType;
  if (SendSelf) and (Self.IsPlayer) then
  begin
    Self.SendPacket(Packet, Packet.Header.size);
  end;
  if (sendTo = 0) then
  begin
    SendToVisible(Packet, Packet.Header.size, SendSelf);
  end
  else
  begin
    Servers[ChannelId].SendPacketTo(sendTo, Packet, Packet.Header.size);
    Exit;
  end;
  for i in VisiblePlayers do
  begin
    if (GetMob(i, ChannelId, mob)) then
      RemoveFromVisible(mob);
  end;
  VisiblePlayers.Clear;
end;
procedure TBaseMob.SendRefreshLevel;
var
  Packet: TSendCurrentLevel;
begin
  if (Self.ClientID >= 3048) then
    Exit;
  ZeroMemory(@Packet, sizeof(TSendCurrentLevel));
  Packet.Header.size := sizeof(TSendCurrentLevel);
  Packet.Header.Code := $108; // AIKA
  Packet.Header.Index := ClientID;
  Packet.Level := Character.Level - 1;
  Packet.Unk := $CC;
  Packet.Exp := Character.Exp;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TBaseMob.SendCurrentHPMP(Update: Boolean);
var
  Packet: TSendCurrentHPMPPacket;
begin
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;
  ZeroMemory(@Packet, sizeof(TSendCurrentHPMPPacket));
  Packet.Header.size := sizeof(TSendCurrentHPMPPacket);
  Packet.Header.Code := $103; // AIKA
  Packet.Header.Index := ClientID;
  Character.CurrentScore.MaxHP := Self.GetCurrentHP;
  Character.CurrentScore.MaxMP := Self.GetCurrentMP;
  if Character.CurrentScore.CurHP > Character.CurrentScore.MaxHP then
    Character.CurrentScore.CurHP := Character.CurrentScore.MaxHP;
  if Character.CurrentScore.CurMP > Character.CurrentScore.MaxMP then
    Character.CurrentScore.CurMP := Character.CurrentScore.MaxMP;
  Packet.CurHP := Character.CurrentScore.CurHP;
  Packet.MaxHP := Character.CurrentScore.MaxHP;
  Packet.CurMP := Character.CurrentScore.CurMP;
  Packet.MaxMP := Character.CurrentScore.MaxMP;
  if (Update) then
    Packet.Null := 1;
  SendToVisible(Packet, Packet.Header.size);
  Sleep(1);
end;
procedure TBaseMob.SendCurrentHPMPMob();
var
  Packet: TSendCurrentHPMPPacket;
begin
  if(Self.IsDungeonMob) then
    Exit;

  if(Self.Mobid = 0) then
    Exit;

  ZeroMemory(@Packet, sizeof(TSendCurrentHPMPPacket));

  Packet.Header.size := sizeof(TSendCurrentHPMPPacket);
  Packet.Header.Code := $103; // AIKA
  Packet.Header.Index := ClientID;

  Packet.CurHP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP[Self.SecondIndex].HP;
  Packet.MaxHP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].InitHP;
  Packet.CurMP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP[Self.SecondIndex].HP;
  Packet.MaxMP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].InitHP;

  SendToVisible(Packet, Packet.Header.size);
end;
procedure TBaseMob.SendStatus;
var
  Packet: TSendRefreshStatus;
  temp_buff: Array [0..12] of Byte;
begin
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;
  // Self.GetCurrentScore;
  ZeroMemory(@Packet, $2C);
  Packet.Header.size := $2C;
  Packet.Header.Code := $10A; // AIKA
  Packet.Header.Index := $7535;
  Packet.DNFis := PlayerCharacter.Base.CurrentScore.DNFis;
  Packet.DEFFis := PlayerCharacter.Base.CurrentScore.DEFFis;
  Packet.DNMAG := PlayerCharacter.Base.CurrentScore.DNMAG;
  Packet.DEFMAG := PlayerCharacter.Base.CurrentScore.DEFMAG;
  Packet.SpeedMove := PlayerCharacter.SpeedMove;
  Packet.Critico := PlayerCharacter.Base.CurrentScore.Critical;
  Packet.Esquiva := PlayerCharacter.Base.CurrentScore.Esquiva;
  Packet.Acerto := PlayerCharacter.Base.CurrentScore.Acerto;
  Packet.Duplo := PlayerCharacter.DuploAtk;
  Packet.Resist := PlayerCharacter.Resistence;
  SendPacket(Packet, Packet.Header.size);
  ZeroMemory(@temp_buff, 12);
  TPacketHandlers.RequestAllAttributes(Servers[Self.ChannelId].Players[Self.ClientID], temp_buff);
end;
procedure TBaseMob.SendRefreshPoint;
var
  Packet: TSendRefreshPoint;
begin
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;
  ZeroMemory(@Packet, sizeof(TSendRefreshPoint));
  Packet.Header.size := sizeof(TSendRefreshPoint);
  Packet.Header.Code := $109; // AIKA
  Packet.Header.Index := $7535;
  Move(PlayerCharacter.Base.CurrentScore, Packet.Pontos, sizeof(Packet.Pontos));
  Packet.SkillsPoint := Self.Character.CurrentScore.SkillPoint;
  Packet.StatusPoint := Self.Character.CurrentScore.Status;
  SendPacket(Packet, Packet.Header.size);
end;
procedure TBaseMob.SendRefreshKills;
var
  Packet: TUpdateHonorAndKills;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $12A;
  Packet.Honor := Self.Character.CurrentScore.Honor;
  Packet.Kills := Self.Character.CurrentScore.KillPoint;
  Self.SendPacket(Packet, Packet.Header.size);
end;
procedure TBaseMob.SendEquipItems(SendSelf: Boolean = True);
// var
// packet: TRefreshEquips;
// x: Byte;
// sItem: TItem;
// effValue: Byte;
begin
end;
procedure TBaseMob.SendRefreshItemSlot(SlotType, SlotItem: WORD; Item: TItem;
  Notice: Boolean);
var
  Packet: TRefreshItemPacket;
  Packet2: TRefreshMountPacket;
  Packet3: TRefreshItemPranPacket;
begin
  case SlotType of
    INV_TYPE:
      begin
        case TItemFunctions.GetItemEquipSlot
          (Self.Character.Inventory[SlotItem].Index) of
          9: // mount item
            begin
              ZeroMemory(@Packet2, sizeof(Packet2));
              Packet2.Header.size := sizeof(Packet2);
              Packet2.Header.Index := $7535;
              Packet2.Header.Code := $F0E;
              Packet2.Notice := Notice;
              Packet2.TypeSlot := SlotType;
              Packet2.Slot := SlotItem;
              Packet2.Item.Index := Item.Index;
              Packet2.Item.APP := Item.APP;
              Packet2.Item.Slot1 := Item.Effects.Index[0];
              Packet2.Item.Slot2 := Item.Effects.Index[1];
              Packet2.Item.Slot3 := Item.Effects.Index[2];
              Packet2.Item.Enc1 := Item.Effects.Value[0];
              Packet2.Item.Enc2 := Item.Effects.Value[1];
              Packet2.Item.Enc3 := Item.Effects.Value[2];
              Packet2.Item.Time := Item.Time;
              Packet2.Item.MIN := Item.MIN;
              Self.SendPacket(Packet2, Packet2.Header.size);
            end;
          10: // pran item
            begin
              ZeroMemory(@Packet3, sizeof(Packet3));
              Packet3.Header.size := sizeof(TRefreshItemPranPacket);
              Packet3.Header.Index := $7535;
              Packet3.Header.Code := $F0E;
              Packet3.Notice := Notice;
              Packet3.TypeSlot := SlotType;
              Packet3.Slot := SlotItem;
              Packet3.Item.Index := Item.Index;
              Packet3.Item.APP := Item.APP;
              Packet3.Item.Identific := Item.Identific;
              if (Item.Identific = Servers[Self.ChannelId].Players
                [Self.ClientID].Account.Header.Pran1.ItemID) then
              begin
                Packet3.Item.CreationTime := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.CreatedAt;
                Packet3.Item.Devotion := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.Devotion;
                Packet3.Item.State := 00;
                Packet3.Item.Level := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.Level;
              end
              else if (Item.Identific = Servers[Self.ChannelId].Players
                [Self.ClientID].Account.Header.Pran2.ItemID) then
              begin
                Packet3.Item.CreationTime := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.CreatedAt;
                Packet3.Item.Devotion := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.Devotion;
                Packet3.Item.State := 00;
                Packet3.Item.Level := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.Level;
                Packet3.Item.NotUse[0] := 1;
              end;
              Self.SendPacket(Packet3, Packet3.Header.size);
            end;
        else
          begin
            ZeroMemory(@Packet, sizeof(Packet));
            Packet.Header.size := sizeof(TRefreshItemPacket);
            Packet.Header.Index := $7535;
            Packet.Header.Code := $F0E;
            Packet.Notice := Notice;
            Packet.TypeSlot := SlotType;
            Packet.Slot := SlotItem;
            Packet.Item := Item;
            Self.SendPacket(Packet, Packet.Header.size);
          end;
        end;
      end;
    EQUIP_TYPE:
      begin
        case TItemFunctions.GetItemEquipSlot
          (Self.Character.Equip[SlotItem].Index) of
          9: // mount item
            begin
              ZeroMemory(@Packet2, sizeof(Packet2));
              Packet2.Header.size := sizeof(Packet2);
              Packet2.Header.Index := $7535;
              Packet2.Header.Code := $F0E;
              Packet2.Notice := Notice;
              Packet2.TypeSlot := SlotType;
              Packet2.Slot := SlotItem;
              Packet2.Item.Index := Item.Index;
              Packet2.Item.APP := Item.APP;
              Packet2.Item.Slot1 := Item.Effects.Index[0];
              Packet2.Item.Slot2 := Item.Effects.Index[1];
              Packet2.Item.Slot3 := Item.Effects.Index[2];
              Packet2.Item.Enc1 := Item.Effects.Value[0];
              Packet2.Item.Enc2 := Item.Effects.Value[1];
              Packet2.Item.Enc3 := Item.Effects.Value[2];
              Packet2.Item.MIN := Item.MIN;
              Packet2.Item.Time := Item.Time;
              Self.SendPacket(Packet2, Packet2.Header.size);
            end;
          10: // pran item
            begin
              ZeroMemory(@Packet3, sizeof(Packet3));
              Packet3.Header.size := sizeof(TRefreshItemPranPacket);
              Packet3.Header.Index := $7535;
              Packet3.Header.Code := $F0E;
              Packet3.Notice := Notice;
              Packet3.TypeSlot := SlotType;
              Packet3.Slot := SlotItem;
              Packet3.Item.Index := Item.Index;
              Packet3.Item.APP := Item.APP;
              Packet3.Item.Identific := Item.Identific;
              if (Item.Identific = Servers[Self.ChannelId].Players
                [Self.ClientID].Account.Header.Pran1.ItemID) then
              begin
                Packet3.Item.CreationTime := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.CreatedAt;
                Packet3.Item.Devotion := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.Devotion;
                Packet3.Item.State := 00;
                Packet3.Item.Level := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.Level;
              end
              else if (Item.Identific = Servers[Self.ChannelId].Players
                [Self.ClientID].Account.Header.Pran2.ItemID) then
              begin
                Packet3.Item.CreationTime := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.CreatedAt;
                Packet3.Item.Devotion := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.Devotion;
                Packet3.Item.State := 00;
                Packet3.Item.Level := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.Level;
                Packet3.Item.NotUse[0] := 1;
              end;
              Self.SendPacket(Packet3, Packet3.Header.size);
            end;
        else
          begin
            ZeroMemory(@Packet, sizeof(Packet));
            Packet.Header.size := sizeof(TRefreshItemPacket);
            Packet.Header.Index := $7535;
            Packet.Header.Code := $F0E;
            Packet.Notice := Notice;
            Packet.TypeSlot := SlotType;
            Packet.Slot := SlotItem;
            Packet.Item := Item;
            Self.SendPacket(Packet, Packet.Header.size);
          end;
        end;
      end;
    STORAGE_TYPE:
      begin
        case TItemFunctions.GetItemEquipSlot(Servers[Self.ChannelId].Players
          [Self.ClientID].Account.Header.Storage.Itens[SlotItem].Index) of
          9: // mount item
            begin
              ZeroMemory(@Packet2, sizeof(Packet2));
              Packet2.Header.size := sizeof(Packet2);
              Packet2.Header.Index := $7535;
              Packet2.Header.Code := $F0E;
              Packet2.Notice := Notice;
              Packet2.TypeSlot := SlotType;
              Packet2.Slot := SlotItem;
              Packet2.Item.Index := Item.Index;
              Packet2.Item.APP := Item.APP;
              Packet2.Item.Slot1 := Item.Effects.Index[0];
              Packet2.Item.Slot2 := Item.Effects.Index[1];
              Packet2.Item.Slot3 := Item.Effects.Index[2];
              Packet2.Item.Enc1 := Item.Effects.Value[0];
              Packet2.Item.Enc2 := Item.Effects.Value[1];
              Packet2.Item.Enc3 := Item.Effects.Value[2];
              Packet2.Item.MIN := Item.MIN;
              Packet2.Item.Time := Item.Time;
              Self.SendPacket(Packet2, Packet2.Header.size);
            end;
          10: // pran item
            begin
              ZeroMemory(@Packet3, sizeof(Packet3));
              Packet3.Header.size := sizeof(TRefreshItemPranPacket);
              Packet3.Header.Index := $7535;
              Packet3.Header.Code := $F0E;
              Packet3.Notice := Notice;
              Packet3.TypeSlot := SlotType;
              Packet3.Slot := SlotItem;
              Packet3.Item.Index := Item.Index;
              Packet3.Item.APP := Item.APP;
              Packet3.Item.Identific := Item.Identific;
              if (Item.Identific = Servers[Self.ChannelId].Players
                [Self.ClientID].Account.Header.Pran1.ItemID) then
              begin
                Packet3.Item.CreationTime := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.CreatedAt;
                Packet3.Item.Devotion := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.Devotion;
                Packet3.Item.State := 00;
                Packet3.Item.Level := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.Level;
              end
              else if (Item.Identific = Servers[Self.ChannelId].Players
                [Self.ClientID].Account.Header.Pran2.ItemID) then
              begin
                Packet3.Item.CreationTime := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.CreatedAt;
                Packet3.Item.Devotion := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.Devotion;
                Packet3.Item.State := 00;
                Packet3.Item.Level := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.Level;
                Packet3.Item.NotUse[0] := 1;
              end;
              Self.SendPacket(Packet3, Packet3.Header.size);
            end;
        else
          begin
            ZeroMemory(@Packet, sizeof(Packet));
            Packet.Header.size := sizeof(TRefreshItemPacket);
            Packet.Header.Index := $7535;
            Packet.Header.Code := $F0E;
            Packet.Notice := Notice;
            Packet.TypeSlot := SlotType;
            Packet.Slot := SlotItem;
            Packet.Item := Item;
            Self.SendPacket(Packet, Packet.Header.size);
          end;
        end;
      end;
  else
    begin
      ZeroMemory(@Packet, sizeof(Packet));
      Packet.Header.size := sizeof(TRefreshItemPacket);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $F0E;
      Packet.Notice := Notice;
      Packet.TypeSlot := SlotType;
      Packet.Slot := SlotItem;
      Packet.Item := Item;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;
end;
procedure TBaseMob.SendRefreshItemSlot(SlotItem: WORD; Notice: Boolean);
var
  Packet: TRefreshItemPacket;
  Packet2: TRefreshMountPacket;
begin
  if not(TItemFunctions.GetItemEquipSlot(Self.Character.Inventory[SlotItem].
    Index) = 9) then
  begin
    ZeroMemory(@Packet, sizeof(Packet));
    Packet.Header.size := sizeof(TRefreshItemPacket);
    Packet.Header.Index := $7535;
    Packet.Header.Code := $F0E;
    Packet.Notice := Notice;
    Packet.TypeSlot := $1;
    Packet.Slot := SlotItem;
    Packet.Item := Self.Character.Inventory[SlotItem];
    Self.SendPacket(Packet, Packet.Header.size);
  end
  else
  begin
    ZeroMemory(@Packet2, sizeof(Packet2));
    Packet2.Header.size := sizeof(Packet2);
    Packet2.Header.Index := $7535;
    Packet2.Header.Code := $F0E;
    Packet2.Notice := Notice;
    Packet2.TypeSlot := $1;
    Packet2.Slot := SlotItem;
    Packet2.Item.Index := Self.Character.Inventory[SlotItem].Index;
    Packet2.Item.APP := Self.Character.Inventory[SlotItem].APP;
    Packet2.Item.Slot1 := Self.Character.Inventory[SlotItem].Effects.Index[0];
    Packet2.Item.Slot2 := Self.Character.Inventory[SlotItem].Effects.Index[1];
    Packet2.Item.Slot3 := Self.Character.Inventory[SlotItem].Effects.Index[2];
    Packet2.Item.Enc1 := Self.Character.Inventory[SlotItem].Effects.Value[0];
    Packet2.Item.Enc2 := Self.Character.Inventory[SlotItem].Effects.Value[1];
    Packet2.Item.Enc3 := Self.Character.Inventory[SlotItem].Effects.Value[2];
    Packet2.Item.Time := Self.Character.Inventory[SlotItem].Time;
    Self.SendPacket(Packet2, Packet2.Header.size);
  end;
end;
procedure TBaseMob.SendSpawnMobs;
var
  i: Integer;
begin
  for i in Self.VisibleMobs do
  begin
    if (i = 0) OR (i = Self.ClientID) then
    begin
      Exit;
    end;
    if (i <= MAX_CONNECTIONS) then
    begin
      // Servers[ChannelId].Players[i].Base.SendCreateMob(SPAWN_NORMAL, Self.ClientId);
    end
    else
    begin
      // NPCs[i].Base.SendCreateMob(SPAWN_NORMAL, Self.ClientId);
    end;
  end;
end;
procedure TBaseMob.GenerateBabyMob;
// var pos: TPosition; i, j: BYTE; mIndex, id: WORD;
// party : PParty;
// var
// babyId, babyClientId: WORD;
// party : PParty;
// i, j: Byte;
// pos: TPosition;
begin
end;
procedure TBaseMob.UngenerateBabyMob(ungenEffect: WORD);
// evok pode ser usado pra skill de att
// var pos: TPosition; i,j: BYTE; party : PParty; find: boolean;
begin
end;
{$ENDREGION}
{$REGION 'Gets'}
procedure TBaseMob.GetCreateMob(out Packet: TSendCreateMobPacket; P1: WORD);
type
  A = record
    hi, lo: Byte;
  end;
var
  i, j, k: Integer;
  Index: WORD;
  Count, Count2: Integer;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := ClientID;
  Packet.Header.Code := $349;
  Packet.Rotation := PlayerCharacter.Rotation;
  Move(Character^.Name, Packet.Name[0], 16);
  Packet.Equip[0] := Character^.Equip[0].Index;
  Packet.Equip[1] := Character^.Equip[1].Index;
  for i := 2 to 7 do
  begin
    if (Character^.Equip[i].APP = 0) or not(Self.IsPlayer) then
    begin
      Packet.Equip[i] := Character^.Equip[i].Index;
      Continue;
    end;
    Packet.Equip[i] := Character^.Equip[i].APP;
  end;
  Packet.SpeedMove := Self.PlayerCharacter.SpeedMove;
  Packet.MaxHP := Character^.CurrentScore.MaxHP;
  Packet.MaxMP := Character^.CurrentScore.MaxHP;
  if Self.IsPlayer then
  begin
    Packet.MaxHP := Self.GetCurrentHP;
    Packet.MaxMP := Self.GetCurrentMP;
    Packet.TitleId := Self.ActiveTitle;
    Packet.Unk0 := $0A;
    Packet.Effects[1] := $1D;
    Packet.GuildIndexAndNation := Character^.Nation * 4096;
    if (Servers[Self.ChannelId].Players[Self.ClientID]
      .Character.Base.GuildIndex) > 0 then
    begin
      AnsiStrings.StrPCopy(Packet.Title,
        AnsiString(Guilds[Servers[Self.ChannelId].Players[Self.ClientID]
        .Character.GuildSlot].Name));
      Packet.GuildIndexAndNation :=
        StrToInt('$' + IntToStr(Character.Nation) +
        IntToHex(Servers[Self.ChannelId].Players[Self.ClientID]
        .Character.Base.GuildIndex, 3));
    end;
  end
  else
  begin
    Packet.EffectType := $1;
    Packet.IsService := 1;
    Packet.Unk0 := $28;
    if (Self.ClientID <= 3047) then
      AnsiStrings.StrPCopy(Packet.Title,
        AnsiString(Servers[ChannelId].NPCs[Self.ClientID]
        .NPCFile.Header.Title));
  end;
  Packet.ItemEff[7] := Character^.Equip[6].Refi div 16;
  Packet.Position := PlayerCharacter.LastPos;
  Packet.CurHP := Character^.CurrentScore.CurHP;
  Packet.CurMP := Character^.CurrentScore.CurMP;
  if Packet.CurHP > Packet.MaxHP then
    Packet.CurHP := Packet.MaxHP;
  if Packet.CurMP > Packet.MaxMP then
    Packet.CurMP := Packet.MaxMP;
  Packet.Altura := Character^.CurrentScore.Sizes.Altura;
  Packet.Tronco := Character^.CurrentScore.Sizes.Tronco;
  Packet.Perna := Character^.CurrentScore.Sizes.Perna;
  Packet.Corpo := Character^.CurrentScore.Sizes.Corpo;
  Packet.TitleId := Self.PlayerCharacter.ActiveTitle.Index;
  Packet.Titlelevel := Self.PlayerCharacter.ActiveTitle.Level - 1;
  if (PersonalShop.Index > 0) and (PersonalShop.Name <> '') then
  begin
    AnsiStrings.StrCopy(Packet.Title, Self.PersonalShop.Name);
    Packet.Corpo := 3;
    Packet.EffectType := 2;
  end;
  i := 0;
  for Index in Self._buffs.Keys do
  begin
    Packet.Buffs[i] := Index;
    Packet.Time[i] := DateTimeToUnix(IncSecond(Self._buffs[Index],
      SkillData[Index].Duration));
    Inc(i);
  end;
  if ((Self.ClientID >= 2048) and (Self.ClientID <= 3047)) then
  begin // isso aqui é só por conta do símbolo quest
    Packet.EffectType := 0;

    for i := Low(Self.NpcQuests) to High(Self.NpcQuests) do
    begin
      if (Self.NpcQuests[i].QuestID = 0) then
        Continue;
      if (Self.NpcQuests[i].LevelMin > Servers[Self.ChannelId].Players[P1]
        .Base.Character.Level) then
      begin
        if (Packet.EffectType = 0) then
          Packet.EffectType := 07;
        Continue;
      end;
      { Verificar se a quest ja foi completa }
      Count := 0;
      Count2 := 0;
      for k := Low(Servers[Self.ChannelId].Players[P1].PlayerQuests)
        to High(Servers[Self.ChannelId].Players[P1].PlayerQuests) do
      begin
        if(Servers[Self.ChannelId].Players[P1].PlayerQuests[k].Quest.QuestID =
          Self.NpcQuests[i].QuestID) then
        begin
          for j := 0 to 4 do
          begin
            if(Servers[Self.ChannelId].Players[P1].PlayerQuests[k].Quest.RequirimentsAmount[j] = 0) then
              Continue
            else
              Inc(Count2);

            if (Servers[Self.ChannelId].Players[P1].PlayerQuests[k].Complete[j] >=
              Servers[Self.ChannelId].Players[P1].PlayerQuests[k].Quest.RequirimentsAmount[j]) then
            begin
              if not(Servers[Self.ChannelId].Players[P1].PlayerQuests[k].Complete[j] = 0) then
                Inc(Count);
            end;
          end;
          if (not(Servers[Self.ChannelId].Players[P1].PlayerQuests[k].IsDone)) then
          begin
            if(Count = Count2) then
            begin
              Packet.EffectType := 4;
            end
            else
            begin
              Packet.EffectType := 3;
            end;
          end
          else
          begin
            {if(Count = Count2) then
            begin
              Packet.EffectType := 4;
            end
            else
            begin
              Packet.EffectType := 3;
            end; }
            if(Packet.EffectType <> 4) or (Packet.EffectType <> 3) then
              Packet.EffectType := Self.NpcQuests[i].QuestMark
            else
            begin
              if(Count = Count2) then
              begin
                Packet.EffectType := 4;
              end
              else
              begin
                Packet.EffectType := 3;
              end;
            end;
          end;
        end;
      end;

      if((Packet.EffectType = 4) or (Packet.EffectType = 3)) then
        break;

      Packet.EffectType := Self.NpcQuests[i].QuestMark;
    end;
  end;
end;
class function TBaseMob.GetMob(Index: WORD; Channel: Byte;
  out mob: TBaseMob): Boolean;
begin
  Result := False;
  if (index = 0) OR (index > MAX_SPAWN_ID) then
  begin
    Exit;
  end;
  if (index > MAX_CONNECTIONS) then
    // mob := Servers[Channel].Players[index].Base
    // else
    mob := Servers[Channel].NPCs[index].Base
  else
    Exit;
  if mob.Character = nil then
    Exit;
  Result := mob.IsActive;
end;
{
  class function TBaseMob.GetMob(Pos: TPosition; Channel: Byte;
  out mob: TBaseMob): Boolean;
  begin
  Result := GetMob(Servers[Channel].MobGrid[Round(Pos.Y)][Round(Pos.X)],
  Channel, mob);
  end; }
class function TBaseMob.GetMob(Index: WORD; Channel: Byte;
  out mob: PBaseMob): Boolean;
begin
  if (index = 0) then
  begin
    Result := False;
    Exit;
  end;
  if (index <= MAX_CONNECTIONS) then
    mob := @Servers[Channel].Players[index].Base
  else
    mob := @Servers[Channel].NPCs[index].Base;
  Result := mob.IsActive;
end;
function TBaseMob.GetMobAbility(eff: Integer): Integer;
begin
  Result := Self.MOB_EF[eff];
end;
procedure TBaseMob.IncreasseMobAbility(eff: Integer; Value: Integer);
begin
  Inc(Self.MOB_EF[eff], Value);
end;
procedure TBaseMob.DecreasseMobAbility(eff: Integer; Value: Integer);
begin
  if (Value < 0) then
  begin
    Value := Value * (-1);
    Inc(Self.MOB_EF[eff], Value);
  end
  else
    decInt(Self.MOB_EF[eff], Value); //mexi aqui nesse decint
end;
function TBaseMob.GetCurrentHP(): DWORD;
var
  hp_inc, hp_perc: DWORD; // ainda no esquema do WYD
begin
  hp_inc := GetMobAbility(EF_HP);
  Inc(hp_inc, (Round(HPIncrementPerLevel[GetMobClass(Character.ClassInfo)]*0.3) *
    Character.Level));
  Inc(hp_inc, (PlayerCharacter.Base.CurrentScore.CONS * 27));
  Inc(hp_inc, Self.GetEquipedItensHPMPInc);
  hp_perc := GetMobAbility(EF_MARSHAL_PER_HP);
  Inc(hp_inc, (hp_perc * Round(hp_inc div 100)));
  if(Self.Character <> nil) then
    if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    begin
      hp_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_HP];
      Inc(hp_inc, (hp_perc * Round(hp_inc div 100)));
    end;
  hp_perc := GetMobAbility(EF_PER_HP);
  Inc(hp_inc, (hp_perc * Round(hp_inc div 100)));
  if (hp_inc <= 0) then
    hp_inc := 1;
  Result := hp_inc;
end;
function TBaseMob.GetCurrentMP(): DWORD;
var
  mp_inc, mp_perc: DWORD;
begin
  mp_inc := GetMobAbility(EF_MP);
  Inc(mp_inc, (Round(MPIncrementPerLevel[GetMobClass(Character.ClassInfo)]*0.3) *
    Character.Level));
  Inc(mp_inc, (PlayerCharacter.Base.CurrentScore.luck * 27));
  Inc(mp_inc, Self.GetEquipedItensHPMPInc);

  mp_perc := GetMobAbility(EF_MARSHAL_PER_MP);
  Inc(mp_inc, (mp_perc * Round(mp_inc div 100)));
  if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
  begin
    mp_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_HP];
    Inc(mp_inc, (mp_perc * Round(mp_inc div 100)));
  end;

  mp_perc := GetMobAbility(EF_PER_MP);
  Inc(mp_inc, (mp_perc * Round(mp_inc div 100)));
  if (mp_inc <= 0) then
    mp_inc := 1;
  Result := mp_inc;
end;
function TBaseMob.GetRegenerationHP(): DWORD;
var
  hp_inc: Integer;
  hp_perc: Single;
  curHp: DWORD;
const
  REC_BASE: Single = 0.05; // antes de 30/04/2021 era 0.05
begin
  hp_inc := 0;
  Inc(hp_inc, Self.GetMobAbility(EF_PRAN_REGENHP));
  Inc(hp_inc, PlayerCharacter.Base.CurrentScore.CONS * 3);
  if (hp_inc < 0) then
    hp_inc := 0;
  hp_perc := REC_BASE + ((hp_inc div 100) div 10);
  curHp := Self.GetCurrentHP;
  Inc(hp_inc, Self.GetMobAbility(EF_REGENHP));
  Result := Trunc(curHp * hp_perc);
  if(Result > Trunc(curHp * 0.15)) then
    Result := Trunc(curHp * 0.15);
end;
function TBaseMob.GetRegenerationMP(): DWORD;
var
  mp_inc: Integer;
  mp_perc: Single;
  curMp: DWORD;
const
  REC_BASE: Single = 0.03;
begin
  mp_inc := 0;
  Inc(mp_inc, Self.GetMobAbility(EF_PRAN_REGENMP));
  Inc(mp_inc, PlayerCharacter.Base.CurrentScore.Luck * 3);
  if (mp_inc < 0) then
    mp_inc := 0;
  mp_perc := REC_BASE + ((mp_inc div 100) div 10);
  curMp := Self.GetCurrentMP;
  Inc(mp_inc, Self.GetMobAbility(EF_REGENMP));
  Result := Trunc(curMp * mp_perc);
  if(Result > Trunc(curMp * 0.15)) then
    Result := Trunc(curMp * 0.15);
end;
function TBaseMob.GetEquipedItensHPMPInc: DWORD;
var
  i: Byte;
  Refine: Byte;
begin
  Result := 0;
  for i := 2 to 7 do
  begin
    if (i = 6) then
      Continue;
    if(Self.Character.Equip[i].Time > 0) then
      continue;
    Refine := TItemFunctions.GetReinforceFromItem(Self.Character.Equip[i]);
    if (Refine = 0) then
      Continue;
    Inc(Result, TItemFunctions.GetItemReinforceHPMPInc(Self.Character.Equip[i].
      Index, Refine - 1));
  end;
end;
function TBaseMob.GetEquipedItensDamageReduce: DWORD;
var
  i, Refine: Byte;
begin
  Result := 0;
  for i := 2 to 7 do
  begin
    if (i = 6) then
      Continue;
    if(Self.Character.Equip[i].Time > 0) then
      continue;
    Refine := TItemFunctions.GetReinforceFromItem(Self.Character.Equip[i]);
    if (Refine = 0) then
      Continue;
    Inc(Result, TItemFunctions.GetItemReinforceDamageReduction
      (Self.Character.Equip[i].Index, Refine - 1));
  end;
end;
function TBaseMob.GetMobClass(ClassInfo: Integer = 0): Integer;
begin
  Result := 0;
  if (Self.ClientID > MAX_CONNECTIONS) then
  begin
    Exit;
  end;
  if (ClassInfo = 0) then
    ClassInfo := Self.Character.ClassInfo;
  // war
  if (ClassInfo >= 1) and (ClassInfo <= 9) then
    Result := 0;
  // templar
  if (ClassInfo >= 11) and (ClassInfo <= 19) then
    Result := 1;
  // att
  if (ClassInfo >= 21) and (ClassInfo <= 29) then
    Result := 2;
  // dual
  if (ClassInfo >= 31) and (ClassInfo <= 39) then
    Result := 3;
  // mago
  if (ClassInfo >= 41) and (ClassInfo <= 49) then
    Result := 4;
  // cleriga
  if (ClassInfo >= 51) and (ClassInfo <= 59) then
    Result := 5;
end;
procedure TBaseMob.GetEquipDamage(const Equip: TItem);
var
  FisAtk: WORD;
  MagAtk: WORD;
  RefineIndex: WORD;
  Reinforce: Byte;
begin
  FisAtk := 0;
  MagAtk := 0;

  if Equip.Index = 0 then
  begin
    Exit
  end;

  if(Equip.MIN = 0) then
  begin
    Exit;
  end;

  if not(Equip.Refi >= 16) then
  begin
    FisAtk := ItemList[Equip.Index].ATKFis;
    MagAtk := ItemList[Equip.Index].MagAtk;
  end
  else
  begin
    if not(Equip.Time > 0) then
    begin
      Reinforce := Round(Equip.Refi div 16) - 1;

      RefineIndex := TItemFunctions.GetItemReinforce2Index(Equip.Index);

      Inc(FisAtk, Reinforce2[RefineIndex].AttributeFis[Reinforce]);
      Inc(MagAtk, Reinforce2[RefineIndex].AttributeMag[Reinforce]);
    end
    else
    begin
      FisAtk := ItemList[Equip.Index].ATKFis;
      MagAtk := ItemList[Equip.Index].MagAtk;
    end;
  end;

  PlayerCharacter.Base.CurrentScore.DNMAG := MagAtk;
  PlayerCharacter.Base.CurrentScore.DNFis := FisAtk;
end;

procedure TBaseMob.GetEquipDefense(const Equip: TItem);
var
  FisDef: DWORD;
  MagDef: DWORD;
  RefineIndex: WORD;
  Reinforce: Byte;
begin
  FisDef := 0;
  MagDef := 0;

  if Equip.Index = 0 then
  begin
    Exit
  end;

  if not(Equip.Refi >= 16) then
  begin
    FisDef := ItemList[Equip.Index].DEFFis;
    MagDef := ItemList[Equip.Index].DEFMAG;
  end
  else
  begin
    if not(Equip.Time > 0) then
    begin
      Reinforce := Round(Equip.Refi div 16) - 1;

      RefineIndex := TItemFunctions.GetItemReinforce2Index(Equip.Index);

      Inc(FisDef, Reinforce2[RefineIndex].AttributeFis[Reinforce]);
      Inc(MagDef, Reinforce2[RefineIndex].AttributeMag[Reinforce]);
    end
    else
    begin
      FisDef := ItemList[Equip.Index].DEFFis;
      MagDef := ItemList[Equip.Index].DEFMAG;
    end;
  end;

  Inc(PlayerCharacter.Base.CurrentScore.DEFMAG, MagDef);
  Inc(PlayerCharacter.Base.CurrentScore.DEFFis, FisDef);
end;

procedure TBaseMob.GetEquipsDefense;
var
  i: Integer;
begin
  Self.PlayerCharacter.Base.CurrentScore.DEFMAG := 0;
  Self.PlayerCharacter.Base.CurrentScore.DEFFis := 0;

  for i := 2 to 7 do
  begin
    if (i = 6) then
      Continue;

    if(Self.Character.Equip[i].MIN = 0) then
      continue;

    Self.GetEquipDefense(Self.Character.Equip[i]);
  end;

end;
procedure TBaseMob.GetCurrentScore;
var
  Damage_perc: WORD;
  Def_perc: WORD;
begin
  if (Self.ClientID > MAX_CONNECTIONS) then
    Exit;
  ZeroMemory(@PlayerCharacter.Base.CurrentScore, 10);
  PlayerCharacter.Base.CurrentScore.DNFis := 0;
  PlayerCharacter.Base.CurrentScore.DNMAG := 0;
  PlayerCharacter.Base.CurrentScore.DEFFis := 0;
  PlayerCharacter.Base.CurrentScore.DEFMAG := 0;
  PlayerCharacter.Base.CurrentScore.BonusDMG := 0;
  PlayerCharacter.Base.CurrentScore.Critical := 0;
  PlayerCharacter.Base.CurrentScore.Esquiva := 0;
  PlayerCharacter.Base.CurrentScore.Acerto := 0;
  PlayerCharacter.DuploAtk := 0;
  PlayerCharacter.SpeedMove := 0;
  PlayerCharacter.Resistence := 0;
  PlayerCharacter.HabAtk := 0;
  PlayerCharacter.DamageCritical := 0;
  PlayerCharacter.ResDamageCritical := 0;
  PlayerCharacter.MagPenetration := 0;
  PlayerCharacter.FisPenetration := 0;
  PlayerCharacter.CureTax := 0;
  PlayerCharacter.CritRes := 0;
  PlayerCharacter.DuploRes := 0;
  PlayerCharacter.ReduceCooldown := 0;
  PlayerCharacter.PvPDamage := 0;
  PlayerCharacter.PvPDefense := 0;
{$REGION 'Get Status Points'}
  IncCritical(PlayerCharacter.Base.CurrentScore.Str, Character.CurrentScore.Str +
    Self.GetMobAbility(EF_STR));
  IncCritical(PlayerCharacter.Base.CurrentScore.agility,
    Character.CurrentScore.agility + Self.GetMobAbility(EF_DEX));
  IncCritical(PlayerCharacter.Base.CurrentScore.Int, Character.CurrentScore.Int +
    Self.GetMobAbility(EF_INT));
  IncCritical(PlayerCharacter.Base.CurrentScore.CONS, Character.CurrentScore.CONS +
    Self.GetMobAbility(EF_CON));
  IncCritical(PlayerCharacter.Base.CurrentScore.luck, Character.CurrentScore.luck +
    Self.GetMobAbility(EF_SPI));
{$ENDREGION}
{$REGION 'Get Others Status'}
{$REGION 'SpeedMove'}
  IncSpeedMove(PlayerCharacter.SpeedMove, (40 + Self.GetMobAbility(EF_RUNSPEED)));
  if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncSpeedMove(PlayerCharacter.SpeedMove, Servers[Self.ChannelId].ReliqEffect
      [EF_RELIQUE_RUNSPEED]);
{$ENDREGION}
{$REGION 'Duplo Atk'}

  IncCritical(PlayerCharacter.DuploAtk,
    Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.21));
  //IncCritical(PlayerCharacter.DuploAtk,
    //Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.25));
  IncCritical(PlayerCharacter.DuploAtk, Servers[Self.ChannelId].ReliqEffect
    [EF_RELIQUE_DOUBLE]);
  IncCritical(PlayerCharacter.DuploAtk, Self.GetMobAbility(EF_DOUBLE));
{$ENDREGION}
{$REGION 'Critical'}
  IncCritical(PlayerCharacter.Base.CurrentScore.Critical,
    Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.13));
  //IncCritical(PlayerCharacter.Base.CurrentScore.Critical,
    //Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.2));
  if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncCritical(PlayerCharacter.Base.CurrentScore.Critical,
    Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_CRITICAL]);
  IncCritical(PlayerCharacter.Base.CurrentScore.Critical,
    Self.GetMobAbility(EF_CRITICAL));
{$ENDREGION}
{$REGION 'Damage Critical'}
  IncCritical(PlayerCharacter.DamageCritical,
    Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.2));
  //IncCritical(PlayerCharacter.DamageCritical,
   // Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.2));
  IncCritical(PlayerCharacter.DamageCritical,
    Self.GetMobAbility(EF_CRITICAL_POWER));
{$ENDREGION}
{$REGION 'Penetration Fis and Mag'}
  IncCooldown(PlayerCharacter.FisPenetration,
    Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.04));
  IncCooldown(PlayerCharacter.MagPenetration,
    Trunc(PlayerCharacter.Base.CurrentScore.Int * 0.34));
  IncCooldown(PlayerCharacter.FisPenetration,
    Self.GetMobAbility(EF_PIERCING_RESISTANCE1));
  IncCooldown(PlayerCharacter.MagPenetration,
    Self.GetMobAbility(EF_PIERCING_RESISTANCE2));
{$ENDREGION}
{$REGION 'PvP Damage'}
  IncWORD(PlayerCharacter.PvPDamage, Self.GetMobAbility(EF_ATK_NATION2));
{$ENDREGION}
{$REGION 'PvP Defense'}
  IncWORD(PlayerCharacter.PvPDefense, Self.GetMobAbility(EF_DEF_NATION2));
{$ENDREGION}
{$REGION 'Hab Skill Atk'}
  IncWORD(PlayerCharacter.HabAtk, (PlayerCharacter.Base.CurrentScore.luck * 6));
  //IncWORD(PlayerCharacter.HabAtk, (PlayerCharacter.Base.CurrentScore.Cons * 2));
  IncWORD(PlayerCharacter.HabAtk, Self.GetMobAbility(EF_SKILL_DAMAGE));
{$ENDREGION}
{$REGION 'Cure Tax'}
  IncCritical(PlayerCharacter.CureTax,
    Trunc(PlayerCharacter.Base.CurrentScore.Int * 0.7));
  IncCritical(PlayerCharacter.CureTax,
    Trunc(PlayerCharacter.Base.CurrentScore.Cons * 0.3));
  IncCritical(PlayerCharacter.CureTax,
    Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.2));
  IncCritical(PlayerCharacter.CureTax,
    Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.1));
  //IncCritical(PlayerCharacter.CureTax,
    //Self.GetMobAbility(EF_SKILL_DAMAGE6));
{$ENDREGION}
{$REGION 'Res Crit'}
  IncCritical(PlayerCharacter.CritRes, Trunc(PlayerCharacter.Base.CurrentScore.CONS
    * 0.15)); // 10 cons = 3 rescrit
  IncCritical(PlayerCharacter.CritRes, Trunc(PlayerCharacter.Base.CurrentScore.luck
    * 0.2)); // 10 luck = 2 rescrit
  IncCritical(PlayerCharacter.CritRes, Self.GetMobAbility(EF_RESISTANCE6));
{$ENDREGION}
{$REGION 'Res Damage Crit'}
  IncCritical(PlayerCharacter.ResDamageCritical,
    Trunc(PlayerCharacter.Base.CurrentScore.CONS * 0.2));
  // 10 cons = 2 res damaag crit
  IncCritical(PlayerCharacter.ResDamageCritical, Self.GetMobAbility(EF_CRITICAL_DEFENCE));
{$ENDREGION}
{$REGION 'Res Duplo'}
  IncCritical(PlayerCharacter.DuploRes, Trunc(PlayerCharacter.Base.CurrentScore.CONS
    * 0.34)); // 10 cons = 2 res duplo
  IncCritical(PlayerCharacter.DuploRes, Self.GetMobAbility(EF_RESISTANCE7));
{$ENDREGION}
{$REGION 'Acerto'}

  IncByte(PlayerCharacter.Base.CurrentScore.Acerto,
    Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.1));
  //IncByte(PlayerCharacter.Base.CurrentScore.Acerto,
    //Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.4));
  if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncByte(PlayerCharacter.Base.CurrentScore.Acerto,
      Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_HIT]);
  IncByte(PlayerCharacter.Base.CurrentScore.Acerto, Self.GetMobAbility(EF_HIT));
{$ENDREGION}
{$REGION 'Esquiva'}

  IncByte(PlayerCharacter.Base.CurrentScore.Esquiva,
    Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.021));
  //IncByte(PlayerCharacter.Base.CurrentScore.Esquiva,
    //Trunc(PlayerCharacter.Base.CurrentScore.luck * 0.3));
  IncByte(PlayerCharacter.Base.CurrentScore.Esquiva,
    Self.GetMobAbility(EF_PRAN_PARRY));
  if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncByte(PlayerCharacter.Base.CurrentScore.Esquiva,
      Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PARRY]);
  IncByte(PlayerCharacter.Base.CurrentScore.Esquiva,
    Self.GetMobAbility(EF_PARRY));
{$ENDREGION}
{$REGION 'Resistence'}
  IncCritical(PlayerCharacter.Resistence, //resistencia a status anormais, colocar no valid atk
    Round(PlayerCharacter.Base.CurrentScore.Luck * 0.1));
  if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncCritical(PlayerCharacter.Resistence,
      Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_STATE_RESISTANCE]);
  IncCritical(PlayerCharacter.Resistence, Self.GetMobAbility(EF_STATE_RESISTANCE));
{$ENDREGION}
{$REGION 'Cooldown Time'}
  IncCooldown(PlayerCharacter.ReduceCooldown,
    Trunc(PlayerCharacter.Base.CurrentScore.Int * 0.25));
  if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncCooldown(PlayerCharacter.ReduceCooldown, Servers[Self.ChannelId].ReliqEffect
      [EF_RELIQUE_COOLTIME]);
  IncCooldown(PlayerCharacter.ReduceCooldown, Self.GetMobAbility(EF_COOLTIME));
{$ENDREGION}
{$ENDREGION}
{$REGION 'Get Def'}
  Self.GetEquipsDefense;

  //IncWord(PlayerCharacter.Base.CurrentScore.DEFFis,
   //Trunc(PlayerCharacter.Base.CurrentScore.Str * 1.3));
  //IncWord(PlayerCharacter.Base.CurrentScore.DEFMAG,
  //  Trunc(PlayerCharacter.Base.CurrentScore.Luck * 1.6));
  Def_perc := Self.GetMobAbility(EF_PER_RESISTANCE1);
  IncWord(PlayerCharacter.Base.CurrentScore.DEFFis,
    Trunc(Def_perc * (PlayerCharacter.Base.CurrentScore.DEFFis div 100)));
  if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    Def_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_RESISTANCE1];
  //IncWord(PlayerCharacter.Base.CurrentScore.DEFFis,
    //Trunc(Def_perc * (PlayerCharacter.Base.CurrentScore.DEFFis div 100)));

  Def_perc := Self.GetMobAbility(EF_PER_RESISTANCE2);
  IncWord(PlayerCharacter.Base.CurrentScore.DEFMAG,
    Trunc(Def_perc * (PlayerCharacter.Base.CurrentScore.DEFMAG div 100)));
  if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    Def_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_RESISTANCE2];
  //IncWord(PlayerCharacter.Base.CurrentScore.DEFMAG,
    //Trunc(Def_perc * (PlayerCharacter.Base.CurrentScore.DEFMAG div 100)));

  IncWord(PlayerCharacter.Base.CurrentScore.DEFFis,
    Self.GetMobAbility(EF_RESISTANCE1));
  IncWord(PlayerCharacter.Base.CurrentScore.DEFMAG,
    Self.GetMobAbility(EF_RESISTANCE2));
  IncWord(PlayerCharacter.Base.CurrentScore.DEFFis,
    Self.GetMobAbility(EF_PRAN_RESISTANCE1));
  IncWord(PlayerCharacter.Base.CurrentScore.DEFMAG,
    Self.GetMobAbility(EF_PRAN_RESISTANCE2));
  if (Self.GetMobAbility(EF_UNARMOR) > 0) then
  begin
    PlayerCharacter.Base.CurrentScore.DEFFis := 0;
    PlayerCharacter.Base.CurrentScore.DEFMAG := 0;
  end;
{$ENDREGION}
{$REGION 'Get Atk'}
  Self.GetEquipDamage(Self.Character.Equip[6]);
{$REGION 'Atk Fis'}

  IncWord(PlayerCharacter.Base.CurrentScore.DNFis,
    Trunc(PlayerCharacter.Base.CurrentScore.Str * 2.6));
  IncWord(PlayerCharacter.Base.CurrentScore.DNFis,
    Trunc(PlayerCharacter.Base.CurrentScore.agility * 2.6));

  IncWord(PlayerCharacter.Base.CurrentScore.DNFis,
    Self.GetMobAbility(EF_PRAN_DAMAGE1));

  Damage_perc := Self.GetMobAbility(EF_PER_DAMAGE1);
  IncWord(PlayerCharacter.Base.CurrentScore.DNFis,
    Trunc((PlayerCharacter.Base.CurrentScore.DNFis div 100) * Damage_perc));
  { Reliquia }
  if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
  begin
    Damage_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_DAMAGE1];
    IncWord(PlayerCharacter.Base.CurrentScore.DNFis,
      Trunc((PlayerCharacter.Base.CurrentScore.DNFis div 100) * Damage_perc));
  end;

  decword(PlayerCharacter.Base.CurrentScore.DNFis,
    Trunc((PlayerCharacter.Base.CurrentScore.DNFis div 100) *
    Self.GetMobAbility(EF_DECREASE_PER_DAMAGE1)));

  IncWord(PlayerCharacter.Base.CurrentScore.DNFis,
    Self.GetMobAbility(EF_DAMAGE1));
{$ENDREGION}
{$REGION 'Atk Mag'}

  IncWord(PlayerCharacter.Base.CurrentScore.DNMAG,
    Trunc(PlayerCharacter.Base.CurrentScore.Int * 3.2));

  IncWord(PlayerCharacter.Base.CurrentScore.DNMAG,
    Self.GetMobAbility(EF_PRAN_DAMAGE2));

    Damage_perc := Self.GetMobAbility(EF_PER_DAMAGE2);
  IncWord(PlayerCharacter.Base.CurrentScore.DNMAG,
    Trunc((PlayerCharacter.Base.CurrentScore.DNMAG div 100) * Damage_perc));
  { Reliquia }
  if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
  begin
    Damage_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_DAMAGE2];
    IncWord(PlayerCharacter.Base.CurrentScore.DNMAG,
      Trunc((PlayerCharacter.Base.CurrentScore.DNMAG div 100) * Damage_perc));
  end;

  decword(PlayerCharacter.Base.CurrentScore.DNMAG,
    Trunc((PlayerCharacter.Base.CurrentScore.DNMAG div 100) *
    Self.GetMobAbility(EF_DECREASE_PER_DAMAGE2)));

  IncWord(PlayerCharacter.Base.CurrentScore.DNMAG,
    Self.GetMobAbility(EF_DAMAGE2));

{$ENDREGION}
{$ENDREGION}
end;
{
  procedure TBaseMob.ForEachInRange(range: Byte;
  proc: TProc<TPosition, TBaseMob, TBaseMob>);
  var
  MobId, Index: WORD;
  mob, Current: TBaseMob;
  Channel: Byte;
  begin
  if not(PlayerCharacter.LastPos.IsValid) then
  Exit;
  index := Self.ClientId;
  Channel := Self.ChannelId;
  Current := Self;
  PlayerCharacter.LastPos.ForEach(range,
  procedure(Pos: TPosition)
  begin
  MobId := Servers[Channel].MobGrid[Round(Pos.Y)][Round(Pos.X)];
  // pode gerar erro
  if (MobId = 0) OR (MobId = index) then
  begin
  Exit;
  end;
  if (MobId <= MAX_CONNECTIONS) then
  begin
  mob := Servers[Channel].Players[MobId].Base;
  end
  else
  begin
  mob := Servers[Channel].NPCs[MobId].Base;
  end;
  if not(mob.IsActive) then
  begin
  Exit;
  end;
  proc(Pos, Current, mob);
  end);
  end;
  class procedure TBaseMob.ForEachInRange(Pos: TPosition; range: Byte;
  proc: TProc<TPosition, TBaseMob>; ChannelId: Byte);
  var
  MobId: WORD;
  mob: TBaseMob;
  begin
  if not(Pos.IsValid) then
  Exit;
  Pos.ForEach(range,
  procedure(p: TPosition)
  begin
  MobId := Servers[ChannelId].MobGrid[Round(p.Y)][Round(p.X)];
  // pode gerar erro
  if (MobId = 0) then
  Exit;
  if (MobId <= MAX_CONNECTIONS) then
  mob := Servers[ChannelId].Players[MobId].Base
  else
  mob := Servers[ChannelId].NPCs[MobId].Base;
  if not(mob.IsActive) then
  Exit;
  proc(p, mob);
  end);
  end; }
{$ENDREGION}
{$REGION 'Buffs'}
procedure TBaseMob.SendRefreshBuffs();
var
  Packet: TSendBuffsPacket;
  i: Integer;
  Index: WORD;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $16E;
  Packet.Header.Index := Self.ClientID;
  Self.RefreshBuffs;
  i := 0;
  for Index in Self._buffs.Keys do
  begin
    Packet.Buffs[i] := Index;
    Packet.Time[i] := DateTimeToUnix(IncSecond(Self._buffs[Index],
      (SkillData[Index].Duration)));
    Inc(i);
  end;
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Self.SendToVisible(Packet, Packet.Header.size, False)
  else
    Self.SendToVisible(Packet, Packet.Header.size);
end;
procedure TBaseMob.SendAddBuff(BuffIndex: WORD);
var
  Packet: TUpdateBuffPacket;
  EndTime: TDateTime;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $16F;
  Packet.Buff := BuffIndex;
  EndTime := IncSecond(Self._buffs[BuffIndex], (SkillData[BuffIndex].Duration));
  Packet.EndTime := DateTimeToUnix(EndTime);
  if (Self.ClientID >= 3048) then
    Self.SendToVisible(Packet, Packet.Header.size, False)
  else
    Self.SendPacket(Packet, Packet.Header.size);
  Self.SendRefreshBuffs;
  Self.SendRefreshPoint;
  Self.SendStatus;
end;
function TBaseMob.RefreshBuffs: Integer;
var
  Index: WORD;
  EndTime: TDateTime;
  // TimeNow: TDateTime;
  i: Integer;
begin
  Result := 0;
  for Index in Self._buffs.Keys do
  begin
    EndTime := IncSecond(Self._buffs[Index], SkillData[Index].Duration);
    // TimeNow := Now;
    if (EndTime < Now) then
    begin
      if (Self.RemoveBuff(Index)) then
      begin
        Inc(Result);
      end;
    end;
  end;
  if(Result > 0) then
  begin
    Self.SendCurrentHPMP(True);
    Self.SendStatus;
    Self.SendRefreshPoint;
  end;

  // mod se der merda foi aqui por conta verificar if clientid <= max_connections
  if (Self.ClientID <= MAX_CONNECTIONS) then
  begin
    for i := Low(Self.PlayerCharacter.Buffs)
      to High(Self.PlayerCharacter.Buffs) do
    begin
      EndTime := IncSecond(Self.PlayerCharacter.Buffs[i].CreationTime,
        SkillData[Self.PlayerCharacter.Buffs[i].Index].Duration);
      if (EndTime <= Now) then
      begin
        ZeroMemory(@Self.PlayerCharacter.Buffs[i],
          sizeof(Self.PlayerCharacter.Buffs[i]));
      end;
    end;
  end;
end;
function TBaseMob.AddBuff(BuffIndex: WORD; Refresh: Boolean = True;
  AddTime: Boolean = False; TimeAditional: Integer = 0): Boolean;
var
  BuffSlot: Integer;
begin
  Result := False;
  if (Self._buffs.Count >= 60) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Não foi possível adicionar novos buffs. Limite: 60 Buffs.');
    Exit;
  end;
  if(BuffIndex = 7257) or (BuffIndex = 9133) then
    Exit;
  if(Self.BuffExistsByIndex(SkillData[BuffIndex].Index)) then
  begin
    Self.RemoveBuffByIndex(SkillData[BuffIndex].Index);
  end;
  if (Self._buffs.ContainsKey(BuffIndex)) then
  begin
    Result := True;
    if(Self.Character <> nil) then
    begin //arrumar pro debuff não aumentar em nation mas sim no inimigo
      if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
      begin
        TimeAditional := TimeAditional +
          ((Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_SKILL_ATIME0] *
          SkillData[BuffIndex].Duration) div 100);
      end;

      {if((SkillData[BuffIndex].Duration >= 600) and
        (SkillData[BuffIndex].MP > 0)) then
      begin
        if(Self.GetMobAbility(EF_SKILL_ATIME6) > 0) then
        begin
          TimeAditional := TimeAditional +
            (Self.GetMobAbility(EF_SKILL_ATIME6) * 60);
        end;
      end;}
    end;
    if (TimeAditional > 0) then
      Self._buffs[BuffIndex] := IncSecond(Now, TimeAditional)
    else
      Self._buffs[BuffIndex] := Now;
    Self.SendRefreshBuffs;
    BuffSlot := Self.GetBuffSlot(BuffIndex);
    if (BuffSlot >= 0) then
    begin
      Self.PlayerCharacter.Buffs[BuffSlot].CreationTime :=
        Self._buffs[BuffIndex];
    end;
  end
  else
  begin
    Result := True;
    if(Self.Character <> nil) then
    begin //arrumar pro debuff não aumentar em nation mas sim no inimigo
      if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
      begin
        TimeAditional := TimeAditional +
          ((Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_SKILL_ATIME0] *
          SkillData[BuffIndex].Duration) div 100);
      end;

     { if((SkillData[BuffIndex].Duration >= 600) and
        (SkillData[BuffIndex].MP > 0)) then
      begin
        if(Self.GetMobAbility(EF_SKILL_ATIME6) > 0) then
        begin
          TimeAditional := TimeAditional +
            (Self.GetMobAbility(EF_SKILL_ATIME6) * 60);
        end;
      end;}
    end;
    Self._buffs.Add(BuffIndex, IncSecond(Now, TimeAditional));
    Self.AddBuffEffect(BuffIndex);
    Self.GetCurrentScore;
    BuffSlot := Self.GetEmptyBuffSlot;
    if (BuffSlot >= 0) then
    begin
      Self.PlayerCharacter.Buffs[BuffSlot].Index := BuffIndex;
      Self.PlayerCharacter.Buffs[BuffSlot].CreationTime :=
        Self._buffs[BuffIndex];
    end;
  end;
  if (Refresh) then
  begin
    Self.SendAddBuff(BuffIndex);
  end;
end;
function TBaseMob.AddBuffWhenEntering(BuffIndex: Integer;
  BuffTime: TDateTime): Boolean;
begin
  Result := True;
  if (Self._buffs.ContainsKey(BuffIndex)) then
    Exit;
  Self._buffs.Add(BuffIndex, BuffTime);
  Self.AddBuffEffect(BuffIndex);
  // Self.GetCurrentScore;
  // Self.SendAddBuff(BuffIndex);
end;
function TBaseMob.GetBuffSlot(BuffIndex: WORD): Integer;
var
  i: Integer;
begin
  Result := -1;
  if (Self.ClientID > MAX_CONNECTIONS) then
    Exit;
  for i := 0 to 59 do
  begin
    if (Self.PlayerCharacter.Buffs[i].Index = BuffIndex) then
    begin
      Result := i;
      break;
    end
    else
      Continue;
  end;
end;
function TBaseMob.GetEmptyBuffSlot(): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to 59 do
  begin
    if (Self.PlayerCharacter.Buffs[i].Index = 0) then
    begin
      Result := i;
      break;
    end
    else
      Continue;
  end;
end;
function TBaseMob.RemoveBuff(BuffIndex: WORD): Boolean;
var
  BuffSlot: Integer;
begin
  Result := False;
  if (Self._buffs.ContainsKey(BuffIndex)) then
  begin
    Self.RemoveBuffEffect(BuffIndex);
    Self._buffs.Remove(BuffIndex);
    BuffSlot := Self.GetBuffSlot(BuffIndex);
    if (BuffSlot >= 0) then
    begin
      Self.PlayerCharacter.Buffs[BuffSlot].Index := 0;
      Self.PlayerCharacter.Buffs[BuffSlot].CreationTime := 0;
    end;
  end;
  if not(Self._buffs.ContainsKey(BuffIndex)) then
    Result := True;
  Self.GetCurrentScore;
  Self.SendStatus;
  Self.SendRefreshPoint;
  Self.SendRefreshBuffs;
  case SkillData[BuffIndex].Index of
    35: //uniao divina
      begin
        Self.UniaoDivina := '';
      end;
    42:
      begin
        Self.HPRListener := False;
      end;
    49: //contagem regressiva
      begin
        Randomize;
        Self.RemoveHP((RandomRange(15, 90) +
          SkillData[BuffIndex].EFV[0]), True, True);
      end;
    65: //x14
      begin
        Self.DestroyPet(Self.PetClientID);
        Self.PetClientID := 0;
      end;

    73: //mjolnir
      begin
        Self.RemoveHP((RandomRange(15, 90) +
          SkillData[BuffIndex].EFV[0]), True, True);
      end;
    //91: //pocao logo aika
      //begin
       // Self.SendCreateMob(SPAWN_NORMAL);
      //  Self.SendEffect(0);
      //end;
    99: // polimorfo
      begin
        Self.SendCreateMob(SPAWN_NORMAL);
      end;
    108: // eclater
      begin
        Randomize;
        if(Self.GetMobAbility(EF_ACCELERATION1) > 0) then
        begin
          Self.RemoveHP((RandomRange(15, 90) +
            SkillData[BuffIndex].EFV[0] + SkillData[BuffIndex].Damage), True, True);
        end
        else
          Self.RemoveHP((RandomRange(15, 90) +
            SkillData[BuffIndex].EFV[0]), True, True);

      end;
    120:
      begin
        Self.HPRListener := False;
      end;
    125:
      begin
        Self.HPRListener := False;
      end;
    134: // cura preventiva
      begin
        Self.CalcAndCure(BuffIndex, @Self);
      end;
  end;
end;
procedure TBaseMob.RemoveAllDebuffs();
var
  i, cnt: WORD;
begin
  cnt := 0;
  if (Self._buffs.Count = 0) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if ((SkillData[i].BuffDebuff = 3) or (SkillData[i].BuffDebuff = 4)) then
    begin
      Self.RemoveBuff(i);
      Inc(cnt);
    end
    else
      Continue;
  end;
  if not(cnt = 0) then
  begin
    Self.SendRefreshBuffs;
    Self.SendCurrentHPMP;
    Self.SendStatus;
    Self.SendRefreshPoint;
  end;
end;
procedure TBaseMob.AddBuffEffect(Index: WORD);
var
  i: Integer;
begin
  if (Self.IsDungeonMob) then
    Exit;
  for i := 0 to 3 do
  begin
    if(i = EF_RUNSPEED) then
    begin
      if((Self.MOB_EF[EF_RUNSPEED] + SkillData[Index].EFV[i]) >= 13) then
      begin
        Self.MOB_EF[EF_RUNSPEED] := 13;
      end
      else
      begin
        Self.IncreasseMobAbility(SkillData[Index].EF[i], SkillData[Index].EFV[i]);
      end;
    end
    else
      Self.IncreasseMobAbility(SkillData[Index].EF[i], SkillData[Index].EFV[i]);
  end;
end;
procedure TBaseMob.RemoveBuffEffect(Index: WORD);
var
  i: Integer;
begin
  if (Self.IsDungeonMob) then
    Exit;
  for i := 0 to 3 do
  begin
    Self.DecreasseMobAbility(SkillData[Index].EF[i], SkillData[Index].EFV[i]);
  end;

end;
function TBaseMob.GetBuffToRemove(): DWORD;
var
  i: WORD;
begin
  Result := 0;
  for i in Self._buffs.Keys do
  begin
    if (SkillData[i].BuffDebuff <> 1) then
      Continue;
    Result := i;
    break;
  end;
end;
function TBaseMob.GetDeBuffToRemove(): DWORD;
var
  i: WORD;
begin
  Result := 0;
  for i in Self._buffs.Keys do
  begin
    if (SkillData[i].BuffDebuff <> 3) or (SkillData[i].BuffDebuff <> 4) then
      Continue;
    Result := i;
    break;
  end;
end;
function TBaseMob.GetDebuffCount(): WORD;
var
  i: WORD;
begin
  Result := 0;
  for i in Self._buffs.Keys do
  begin
    if (SkillData[i].BuffDebuff = 3) or (SkillData[i].BuffDebuff = 4) then
    begin
      Inc(Result);
    end
    else
      Continue;
  end;
end;
function TBaseMob.GetBuffCount(): WORD;
var
  i: WORD;
begin
  Result := 0;
  for i in Self._buffs.Keys do
  begin
    if (SkillData[i].BuffDebuff = 1) then
    begin
      Inc(Result);
    end
    else
      Continue;
  end;
end;
procedure TBaseMob.RemoveBuffByIndex(Index: WORD);
var
  i: WORD;
begin
  if (Self._buffs.Count = 0) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if (SkillData[i].Index = Index) then
    begin
      if (Self.RemoveBuff(i)) then
      begin
        Self.SendRefreshBuffs;
        Self.SendCurrentHPMP;
        Self.SendStatus;
        Self.SendRefreshPoint;
      end;
      break;
    end
    else
      Continue;
  end;
end;
function TBaseMob.GetBuffSameIndex(BuffIndex: DWORD): Boolean;
var
  j: DWORD;
  Index: DWORD;
begin
  Result := False;
  if (Self._buffs.Count = 0) then
    Exit;
  for j in Self._buffs.Keys do
  begin
    if (SkillData[BuffIndex].Index = SkillData[j].Index) then
    begin
      Self.RemoveBuff(j);
      Result := True;
      //break;
    end
    else
    begin
      Continue;
    end;
  end;
end;
function TBaseMob.BuffExistsByIndex(BuffIndex: DWORD): Boolean;
var
  i: Integer;
  Index: DWORD;
begin
  Result := False;
  if {(Self.ClientID >= 3048) or }(Self.IsDungeonMob) then
    Exit;
  if (BuffIndex = 0) then
    Exit;
  if (Self._buffs.Count = 0) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if (BuffIndex = SkillData[i].Index) then
    begin
      Result := True;
      break;
    end;
  end;
end;
function TBaseMob.BuffExistsByID(BuffID: DWORD): Boolean;
var
  i: Integer;
  Index: DWORD;
begin
  Result := False;
  if {(Self.ClientID >= 3048) or} (Self.IsDungeonMob) then
    Exit;
  if (BuffID = 0) then
    Exit;
  if (Self._buffs.Count = 0) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if (BuffID = i) then
    begin
      Result := True;
      break;
    end;
  end;
end;

function TBaseMob.BuffExistsInArray(const BuffList: Array of DWORD): Boolean;
var
  i, j: Integer;
begin
  Result := False;

  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;

  if (Self._buffs.Count = 0) then
    Exit;

  for i in Self._buffs.Keys do
  begin
    for j in BuffList do
    begin
       if(SkillData[i].Index = j) then
       begin
         Result := True;
         break;
       end;
    end;

    if(Result) then
      break;
  end;
end;

function TBaseMob.BuffExistsSopa(): Boolean;
var
  i: Integer;
begin
  Result := False;

  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;

  if (Self._buffs.Count = 0) then
    Exit;

  for i in Self._buffs.Keys do
  begin
    if(Copy(String(SkillData[i].Name), 0, 4) = 'Sopa') then
    begin
      Result := True;
      break;
    end;
  end;
end;
function TBaseMob.GetBuffIDByIndex(Index: DWORD): WORD;
var
  i, id: WORD;
begin
  Result := 0;
  if {(Self.ClientID >= 3048) or} (Self.IsDungeonMob) then
    Exit;
  if (Index = 0) then
    Exit;
  if (Self._buffs.Count = 0) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if (Index = SkillData[i].Index) then
    begin
      Result := id;
      break;
    end;
  end;
end;
procedure TBaseMob.RemoveBuffs(Quant: Byte);
var
  i, cnt: WORD;
begin
  if (Self._buffs.Count = 0) then
    Exit;
  cnt := 0;
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if (cnt >= Quant) then
      break;
    if (SkillData[i].BuffDebuff = 1) then
    begin
      if (Self.RemoveBuff(i)) then
      begin
        Inc(cnt);
        Continue;
      end;
    end
    else
      Continue;
  end;
  if not(cnt = 0) then
  begin
    Self.SendRefreshBuffs;
    Self.SendCurrentHPMP;
    Self.SendStatus;
    Self.SendRefreshPoint;
  end;
end;
procedure TBaseMob.RemoveDebuffs(Quant: Byte);
var
  i, cnt: WORD;
begin
  if (Self._buffs.Count = 0) then
    Exit;
  cnt := 0;
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if (cnt >= Quant) then
      break;
    if ((SkillData[i].BuffDebuff = 3) or (SkillData[i].BuffDebuff = 4)) then
    begin
      if (Self.RemoveBuff(i)) then
      begin
        Inc(cnt);
        Continue;
      end;
    end
    else
      Continue;
  end;
  if not(cnt = 0) then
  begin
    Self.SendRefreshBuffs;
    Self.SendCurrentHPMP;
    Self.SendStatus;
    Self.SendRefreshPoint;
  end;
end;
procedure TBaseMob.ZerarBuffs();
var
  i: Integer;
begin
  for I in Self._buffs.Keys do
  begin
    Self.RemoveBuff(i);
  end;
end;
{$ENDREGION}
{$REGION 'Attack & Skills'}
procedure TBaseMob.CheckCooldown(var Packet: TSendSkillUse);
var
  EndTime: TTime;
begin
  { if (SkillData[Packet.Skill].Level = 0) then
    begin // ataque basico
    if (MilliSecondsBetween(Now, Self.LastBasicAttack) <= MIN_DELAY_ATTACK) then
    Exit;
    Self.LastBasicAttack := Now;
    Self.SendToVisible(Packet, Packet.Header.size, True);
    end; }
  if (Self._cooldown.ContainsKey(Packet.Skill)) then
  begin
    EndTime := IncMillisecond(Self._cooldown[Packet.Skill],
      SkillData[Packet.Skill].Cooldown);
    if not(EndTime < Now) then
    begin
      Exit;
    end;
  end;
  Self.UsingSkill := Packet.Skill;
  Self.SendToVisible(Packet, Packet.Header.size, True);
  { if (SkillData[Packet.Skill].SuccessRate = 1) and
    (SkillData[Packet.Skill].range > 0) then
    begin
    if (Self._cooldown.ContainsKey(Packet.Skill)) then
    begin
    EndTime := IncMillisecond(Self._cooldown[Packet.Skill],
    SkillData[Packet.Skill].Cooldown);
    if not(EndTime <= Now) then
    begin
    Exit;
    end;
    end;
    Self.UsingSkill := Packet.Skill;
    Self.SendToVisible(Packet, Packet.Header.size, True);
    end
    else
    begin
    if (Self._cooldown.ContainsKey(Packet.Skill)) then
    begin
    EndTime := IncMillisecond(Self._cooldown[Packet.Skill],
    SkillData[Packet.Skill].Cooldown);
    if not(EndTime <= Now) then
    begin
    Exit;
    end;
    end;
    Self.UsingSkill := Packet.Skill;
    Self.SendToVisible(Packet, Packet.Header.size, True);
    end; }
end;

procedure TBaseMob.SendCurrentAllSkillCooldown();
var
  Packet: Tp12C;
  i: Integer;
  CurrTime: TTime;
  OPlayer: PPlayer;
begin
  ZeroMemory(@Packet, sizeof(Tp12C));
  Packet.Header.size := sizeof(Tp12C);
  Packet.Header.Index := $7535; // era 0
  Packet.Header.Code := $12C;

  OPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];

  for I := 0 to 5 do
  begin
    if(Self._cooldown.ContainsKey(OPlayer.Character.Skills.Basics[i].Index +
       OPlayer.Character.Skills.Basics[i].Level-1)) then
    begin
      Self._cooldown.TryGetValue(OPlayer.Character.Skills.Basics[i].Index +
       OPlayer.Character.Skills.Basics[i].Level-1, CurrTime);
      Packet.Skills[i] := SkillData[OPlayer.Character.Skills.Basics[i].Index +
       OPlayer.Character.Skills.Basics[i].Level-1].Duration -
       ((SkillData[OPlayer.Character.Skills.Basics[i].Index +
       OPlayer.Character.Skills.Basics[i].Level-1].Duration div 100) *
       Self.PlayerCharacter.ReduceCooldown) -
        (SecondsBetween(CurrTime, Now));
    end;
  end;

  for I := 0 to 39 do
  begin
    if(Self._cooldown.ContainsKey(OPlayer.Character.Skills.Others[i].Index +
       OPlayer.Character.Skills.Others[i].Level-1)) then
    begin
      Self._cooldown.TryGetValue(OPlayer.Character.Skills.Others[i].Index +
       OPlayer.Character.Skills.Others[i].Level-1, CurrTime);
      Packet.Skills[i] := SkillData[OPlayer.Character.Skills.Others[i].Index +
       OPlayer.Character.Skills.Others[i].Level-1].Duration -
       ((SkillData[OPlayer.Character.Skills.Others[i].Index +
       OPlayer.Character.Skills.Others[i].Level-1].Duration div 100) *
       Self.PlayerCharacter.ReduceCooldown) -
        (SecondsBetween(CurrTime, Now));
    end;
  end;

  Self.SendPacket(Packet, Packet.Header.Size);
end;

function TBaseMob.CheckCooldown2(SkillID: DWORD): Boolean;
var
  EndTime: TTime;
  CD: DWORD;
begin
  Result := True;
  if (Self._cooldown.ContainsKey(SkillID)) then
  begin
<<<<<<< HEAD
    if(Self.GetMobClass() = 3) then
      CD := ((SkillData[SkillID].Cooldown *
        PlayerCharacter.ReduceCooldown+50) div 100)
    else
      CD := ((SkillData[SkillID].Cooldown *
        PlayerCharacter.ReduceCooldown) div 100);
   
=======
    CD := ((SkillData[SkillID].Cooldown *
      PlayerCharacter.ReduceCooldown) div 100);
    {EndTime := IncMillisecond(Self._cooldown[SkillID],
      ((SkillData[SkillID].Cooldown - ((SkillData[SkillID].Cooldown div 100) * 10)) - CD));}
>>>>>>> parent of a46c38b (30)
    EndTime := IncMillisecond(Self._cooldown[SkillID],
      ((SkillData[SkillID].Cooldown) - CD));
    if not(EndTime < Now) then
    begin
      Result := False;
    end
    else
    begin
      Self._cooldown[SkillID] := Now;
      Result := True;
    end;
  end
  else
  begin
    Self._cooldown.Add(SkillID, Now);
    Result := True;
  end;
end;
procedure TBaseMob.SendDamage(Skill, Anim: DWORD; mob: PBaseMob;
  DataSkill: P_SkillData);
var
  Packet: TRecvDamagePacket;
  Add_Buff: Boolean;
  j: Integer;
  DropExp: Boolean;
  DropItem: Boolean;
  MobsP: PMobSPoisition;
  xDano, helper: Integer;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $102;
  Packet.SkillID := Skill;
  Packet.AttackerPos := Self.PlayerCharacter.LastPos;
  Packet.AttackerID := Self.ClientID;
  Packet.Animation := Anim;
  Packet.AttackerHP := Self.Character.CurrentScore.CurHP;
  Packet.TargetID := mob^.ClientID;
  Packet.MobAnimation := DataSkill^.TargetAnimation;
  // try
  xDano := Self.GetDamage(Skill, mob, Packet.DnType);
  // except
  // Packet.Dano := ((Self.PlayerCharacter.Base.CurrentScore.DNFis +
  // Self.PlayerCharacter.Base.CurrentScore.DNMAG) div 2);
  // Packet.DnType := TDamageType.Normal;
  // end;
  if (xDano > 0) then
  begin
    Self.AttackParse(Skill, Anim, mob, xDano, Packet.DnType, Add_Buff,
      Packet.MobAnimation, DataSkill);

    if(xDano > 0) then
    begin
      Inc(xDano, (RandomRange((xDano div 20), (xDano div 10)) + 13));
    end;
  end
  else if(xDano < 0) then
  begin
    xDano := 0;
  end;

  Packet.DANO := xDano;

  if(Skill = 0) then
  begin
    case Self.GetMobClass() of
      {0:
        begin
          if(mob.ClientID <= MAX_CONNECTIONS) then
            Packet.Dano := Trunc(Packet.Dano / 1.2);
        end;}


      1:
        begin
          if(mob.ClientID <= MAX_CONNECTIONS) then
            Packet.Dano := Packet.Dano + Trunc(Packet.Dano * 1.4);
        end;

      2:
        begin
          if(mob.ClientID <= MAX_CONNECTIONS) then
            Packet.Dano := Trunc(Packet.Dano / 1.69);

          if not(ItemList[Self.Character.Equip[15].Index].ItemType = 52) then
          begin
            TItemFunctions.DecreaseAmount(@Self.Character.Equip[15], 1);
            Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
              Self.Character.Equip[15], False);

            if(Self.Character.Equip[15].Index = 0) then
            begin
              Helper := TItemFunctions.GetItemSlotByItemType(
                Servers[Self.ChannelId].Players[Self.ClientID], 50, INV_TYPE);

              if(Helper <> 255) and (ItemList[Self.Character.Inventory[Helper].Index]
                .Classe = Self.Character.ClassInfo) then
              begin
                Move(Self.Character.Inventory[Helper],
                  Self.Character.Equip[15], sizeof(TItem));
                Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
                  Self.Character.Equip[15], False);
                ZeroMemory(@Self.Character.Inventory[Helper], sizeof(TITem));
                Self.SendRefreshItemSlot(INV_TYPE, Helper,
                  Self.Character.Inventory[Helper], False);

                Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
                'Suas balas acabaram e foram equipadas novas balas a partir do inventário.');
              end;
            end;
          end;
        end;

      3:
        begin
          if(mob.ClientID <= MAX_CONNECTIONS) then
            Packet.Dano := Trunc(Packet.Dano / 1.79);

          if not(ItemList[Self.Character.Equip[15].Index].ItemType = 52) then
          begin
            TItemFunctions.DecreaseAmount(@Self.Character.Equip[15], 2);
            Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
              Self.Character.Equip[15], False);

            if(Self.Character.Equip[15].Index = 0) then
            begin
              Helper := TItemFunctions.GetItemSlotByItemType(
                Servers[Self.ChannelId].Players[Self.ClientID], 50, INV_TYPE);

              if(Helper <> 255) and (ItemList[Self.Character.Inventory[Helper].Index]
                .Classe = Self.Character.ClassInfo) then
              begin
                Move(Self.Character.Inventory[Helper],
                  Self.Character.Equip[15], sizeof(TItem));
                Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
                  Self.Character.Equip[15], False);
                ZeroMemory(@Self.Character.Inventory[Helper], sizeof(TITem));
                Self.SendRefreshItemSlot(INV_TYPE, Helper,
                  Self.Character.Inventory[Helper], False);

                Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage(
                'Suas balas acabaram e foram equipadas novas balas a partir do inventário.');
              end;
            end;
          end;
        end;
    end;
  end;
 { if (Self.BuffExistsByIndex(77)) then
  begin // inv dual
    Self.RemoveBuffByIndex(77);
  end;
  if (Self.BuffExistsByIndex(53)) then
  begin // inv att
    Self.RemoveBuffByIndex(53);
  end;
  if (mob^.BuffExistsByIndex(153)) then
  begin // predador
    mob^.RemoveBuffByIndex(153);
  end;}
  {if (Servers[Self.ChannelId].Players[Self.ClientID].InDungeon) then
  begin
    if (Packet.Dano >= DungeonInstances[Servers[Self.ChannelId].Players
      [Self.ClientID].DungeonInstanceID].Mobs[mob.Mobid].CurrentHP) then
    begin
      mob.IsDead := True;
      DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].Mobs[mob.Mobid].CurrentHP := 0;
      DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].Mobs[mob.Mobid].IsAttacked := False;
      DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].Mobs[mob.Mobid].AttackerID := 0;
      { DungeonInstances
        [Servers[Self.ChannelId].Players[Self.ClientId].DungeonInstanceID].Mobs
        [mob.Mobid].deadTime := Now; }
    {  if (Self.VisibleMobs.Contains(mob.ClientID)) then
        Self.VisibleMobs.Remove(mob.ClientID);
      Self.MobKilledInDungeon(mob);
      Packet.MobAnimation := 30;
    end
    else
    begin
      DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].Mobs[mob.Mobid].CurrentHP :=
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].Mobs[mob.Mobid].CurrentHP - Packet.Dano;
    end;
    mob.LastReceivedAttack := Now;
    Packet.MobCurrHP := DungeonInstances
      [Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID].Mobs
      [mob.Mobid].CurrentHP;
    Self.SendToVisible(Packet, Packet.Header.size);
    Exit;
  end;  }
  MobsP := @Servers[mob^.ChannelId].Mobs.TMobS[0].MobsP
      [1];
  if(mob^.SecondIndex > 0) then
    MobsP := @Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobsP
      [mob^.SecondIndex];

  if ((mob^.ClientID >= 3048) and (mob^.ClientID <= 9147)) then
  begin
    case mob^.ClientID of
      3340 .. 3354:
        begin // stones
          if ((Packet.Dano >= Servers[Self.ChannelId].DevirStones[mob^.ClientID]
            .PlayerChar.Base.CurrentScore.CurHP) and not(mob^.IsDead)) then
          begin
            mob^.IsDead := True;
            Servers[Self.ChannelId].DevirStones[mob^.ClientID]
              .PlayerChar.Base.CurrentScore.CurHP := 0;
            Servers[Self.ChannelId].DevirStones[mob^.ClientID]
              .IsAttacked := False;
            Servers[Self.ChannelId].DevirStones[mob^.ClientID].AttackerID := 0;
            Servers[Self.ChannelId].DevirStones[mob^.ClientID].deadTime := Now;
            Servers[Self.ChannelId].DevirStones[mob^.ClientID].KillStone(mob^.ClientID,
            Self.ClientId);
            if (Self.VisibleNPCs.Contains(mob^.ClientID)) then
            begin
              Self.VisibleNPCs.Remove(mob^.ClientID);
              Self.RemoveTargetFromList(mob);
              // essa skill tem retorno no caso de erro
            end;
            for j in Self.VisiblePlayers do
            begin
              if(Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Contains(mob^.ClientID)) then
              begin
                Servers[Self.ChannelId].Players[j].Base.VisibleNPCs.Remove(mob^.ClientID);
                Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(mob);
              end;
            end;
            mob^.VisibleMobs.Clear;
            // Self.MobKilled(mob, DropExp, DropItem, False);
            Packet.MobAnimation := 30;
          end
          else
          begin
            Servers[Self.ChannelId].DevirStones[mob^.ClientID]
              .PlayerChar.Base.CurrentScore.CurHP := Servers[Self.ChannelId]
              .DevirStones[mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP -
              Packet.Dano;
          end;
          mob^.LastReceivedAttack := Now;
          Packet.MobCurrHP := Servers[Self.ChannelId].DevirStones[mob^.ClientID]
            .PlayerChar.Base.CurrentScore.CurHP;
          Self.SendToVisible(Packet, Packet.Header.size);
          //Sleep(1);
          Exit;
        end;
      3355 .. 3369:
        begin // guards
          if ((Packet.Dano >= Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
            .PlayerChar.Base.CurrentScore.CurHP)and not(mob^.IsDead)) then
          begin
            mob^.IsDead := True;
            Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
              .PlayerChar.Base.CurrentScore.CurHP := 0;
            Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
              .IsAttacked := False;
            Servers[Self.ChannelId].DevirGuards[mob^.ClientID].AttackerID := 0;
            Servers[Self.ChannelId].DevirGuards[mob^.ClientID].deadTime := Now;
            Servers[Self.ChannelId].DevirGuards[mob^.ClientID].KillGuard(mob^.ClientID,
            Self.ClientId);
            if (Self.VisibleNPCs.Contains(mob^.ClientID)) then
            begin
              Self.VisibleNPCs.Remove(mob^.ClientID);
              Self.RemoveTargetFromList(mob);
              // essa skill tem retorno no caso de erro
            end;
            for j in Self.VisiblePlayers do
            begin
              if(Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Contains(mob^.ClientID)) then
              begin
                Servers[Self.ChannelId].Players[j].Base.VisibleNPCs.Remove(mob^.ClientID);
                Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(mob);
              end;
            end;
            mob^.VisibleMobs.Clear;
            // Self.MobKilled(mob, DropExp, DropItem, False);
            Packet.MobAnimation := 30;
          end
          else
          begin
            Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
              .PlayerChar.Base.CurrentScore.CurHP := Servers[Self.ChannelId]
              .DevirGuards[mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP -
              Packet.Dano;
          end;
          mob^.LastReceivedAttack := Now;
          Packet.MobCurrHP := Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
            .PlayerChar.Base.CurrentScore.CurHP;
          Self.SendToVisible(Packet, Packet.Header.size);
          //Sleep(1);
          Exit;
        end;
    else
      begin


        if not(MobsP.IsAttacked) then
        begin
          MobsP.FirstPlayerAttacker := Self.ClientID;
        end;

        if (Packet.Dano >= MobsP^.HP) then
        begin
          mob^.IsDead := True;
          MobsP^.HP := 0;
          MobsP^.IsAttacked := False;
          MobsP^.AttackerID := 0;
          MobsP^.deadTime := Now;

          MobsP.Base.SendEffect($0);

          mob.SendCurrentHPMPMob;
          if (Self.VisibleMobs.Contains(mob^.ClientID)) then
          begin
            Self.VisibleMobs.Remove(mob^.ClientID);
            Self.RemoveTargetFromList(mob);
            // essa skill tem retorno no caso de erro
          end;
          for j := Low(Servers[Self.ChannelId].Players) to
            High(Servers[Self.ChannelId].Players) do
          begin
            if((Servers[Self.ChannelId].Players[j].Status < Playing) or
              (Servers[Self.ChannelId].Players[j].SocketClosed)) then
              COntinue;

            if(Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Contains(mob^.ClientID)) then
            begin
              Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Remove(mob^.ClientID);
              Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(mob);
            end;
          end;
          try
            if not(Servers[Self.ChannelId].Players[Self.ClientID].SocketClosed) then
            begin
              if(mob.SecondIndex > 0) then
              begin
                if(mob.ClientID >= 3049) and (mob.ClientID <= 9147) then
                begin
                  if(Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].IsActiveToSpawn) then
                    Self.MobKilled(mob, DropExp, DropItem, False);
                end;
              end;
            end;
          except
            on E: Exception do
            begin
              Logger.Write('Erro no MobKiller: ' + E.Message + 't ' +
                DateTimeToStr(Now), TLogType.Error);
            end;
          end;

          mob^.VisibleMobs.Clear;
          Packet.MobAnimation := 30;
        end
        else
        begin
          MobsP^.HP := MobsP^.HP - Packet.Dano;
        end;
        mob^.LastReceivedAttack := Now;
        Packet.MobCurrHP := MobsP^.HP;
        Self.SendToVisible(Packet, Packet.Header.size);
        //Sleep(1);
        Exit;
      end;
    end;
  end
  else if (mob.ClientID >= 9148)  then
  begin
    if(Servers[Self.ChannelId].PETS[mob.ClientID].PetType = X14) then
    begin
      Servers[Self.ChannelId].PETS[mob.ClientID].IsAttacked := True;
      Servers[Self.ChannelId].PETS[mob.ClientID].AttackerID := Self.ClientID;
      if (Packet.Dano >= mob.PlayerCharacter.Base.CurrentScore.CurHP) then
      begin
        Packet.MobAnimation := 30;
        mob.IsDead := True;
         if(Servers[Self.ChannelId].PETS[mob.ClientID].IntName > 0) then
        begin
          if(Servers[Self.ChannelId].PETS[mob.ClientID].Base.IsActive) then
            Servers[Self.ChannelId].Players[Self.ClientID].Base.DestroyPet(
              mob.ClientID);
        end;
        //Servers[Self.ChannelId].PETS[mob.ClientID].Base.Destroy;
        //ZeroMemory(@Servers[Self.ChannelId].PETS[mob.ClientID], sizeof(TPet));
      end
      else
      begin
        DecCardinal(mob.PlayerCharacter.Base.CurrentScore.CurHP,
          Packet.DANO);
      end;
      mob.LastReceivedAttack := Now;
      Packet.MobCurrHP := mob.PlayerCharacter.Base.CurrentScore.CurHP;
      // Self.SendCurrentHPMP;
      Self.SendToVisible(Packet, Packet.Header.size);
      //Sleep(1);
      Exit;
    end;
  end;

  if(SecondsBetween(Now, mob.RevivedTime) <= 7) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Alvo acabou de nascer.');
    Exit;
  end;

  if (Packet.Dano >= mob^.Character.CurrentScore.CurHP) then
  begin
    if (Servers[Self.ChannelId].Players[mob^.ClientID].Dueling) then
    begin
      mob^.Character.CurrentScore.CurHP := 10;
    end
    else
    begin
      mob^.Character.CurrentScore.CurHP := 0;
      mob^.SendEffect($0);
      Packet.MobAnimation := 30;
      mob^.IsDead := True;
      if(Servers[Self.ChannelId].Players[mob^.ClientID].CollectingReliquare) then
      Servers[Self.ChannelId].Players[mob^.ClientID].SendCancelCollectItem(
      Servers[Self.ChannelId].Players[mob^.ClientID].CollectingID);
      mob^.LastReceivedAttack := Now;
      Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;
      // Self.SendCurrentHPMP;
      Self.SendToVisible(Packet, Packet.Header.size);
      if (mob^.Character.Nation > 0) and (Self.Character.Nation > 0) then
      begin
        if ((mob^.Character.Nation <> Self.Character.Nation) or
          (Self.InClastleVerus)) then
        begin
          Self.PlayerKilled(mob);
        end;
      end;
      // Inc(Self.PlayerCharacter.Base.CurrentScore.KillPoint);
      // Self.SendRefreshKills;
      // Servers[Self.ChannelId].Players[Self.ClientId].SendClientMessage
      // ('Seus pontos de PvP foram incrementados em 1.');
      // Self.SendRefreshPoint;
    end;
  end
  else
  begin
    if (Packet.Dano > 0) then
      mob^.RemoveHP(Packet.Dano, False);

    if(Servers[Self.ChannelId].Players[mob^.ClientID].CollectingReliquare) then
    Servers[Self.ChannelId].Players[mob^.ClientID].SendCancelCollectItem(
    Servers[Self.ChannelId].Players[mob^.ClientID].CollectingID);
    mob^.LastReceivedAttack := Now;
    Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;
    // Self.SendCurrentHPMP;
    Self.SendToVisible(Packet, Packet.Header.size);
  end;

  //Sleep(1);
end;
function TBaseMob.GetDamage(Skill: DWORD; mob: PBaseMob;
  out DnType: TDamageType): UInt64;
var
  ResultDamage: Integer;
  MobDef, defHelp: Integer;
  IsPhysical: Boolean;
begin
  try
    Result := 0;
    // Self.GetCurrentScore;
    if (mob^.ClientID >= 9148) then
    begin // ataque dos pets é diferenciado
      Randomize;
      Result := (((Self.PlayerCharacter.Base.CurrentScore.DNFis +
        Self.PlayerCharacter.Base.CurrentScore.DNMAG) div 2) +
        (Random(99) + 15));
      DnType := TDamageType.Normal;
      Exit;
    end;
{$REGION 'Verifica se esta imune'}
    if (mob^.GetMobAbility(EF_IMMUNITY) > 0) then
    begin
      DnType := TDamageType.Immune;
      Exit;
    end;
    if (mob^.BuffExistsByIndex(19)) then
    begin
      if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
      begin
        mob^.RemoveBuffByIndex(19);
        Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
      end
      else
      begin
        mob^.RemoveBuffByIndex(19);
        DnType := TDamageType.Block;
        Exit;
      end;
    end;
    if (mob^.BuffExistsByIndex(91)) then
    begin
      if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
      begin
        mob^.RemoveBuffByIndex(91);
        Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
      end
      else
      begin
        mob^.RemoveBuffByIndex(91);
        DnType := TDamageType.Miss2;
        Exit;
      end;
    end;
{$ENDREGION}
{$REGION 'Verifica se o ataque é fisico ou magico'}
    case Self.GetMobClass of
      0 .. 3:
        begin
          IsPhysical := True;
        end;
    else
      if (Skill = 0) then
        IsPhysical := True
      else
        IsPhysical := False;
    end;
{$ENDREGION}
    if (IsPhysical) then
    begin
      ResultDamage := Self.PlayerCharacter.Base.CurrentScore.DNFis;
      MobDef := mob.PlayerCharacter.Base.CurrentScore.DEFFis;
      defHelp := (Self.PlayerCharacter.FisPenetration);
      if (defHelp > 0) then
      begin
        dec(MobDef, ((mob.PlayerCharacter.Base.CurrentScore.DEFFis div 100) *
          defHelp));
      end;
    end
    else
    begin
      ResultDamage := Self.PlayerCharacter.Base.CurrentScore.DNMAG;
      MobDef := mob.PlayerCharacter.Base.CurrentScore.DEFMAG;
      defHelp := (Self.PlayerCharacter.MagPenetration);
      if (defHelp > 0) then
      begin
        dec(MobDef, ((mob.PlayerCharacter.Base.CurrentScore.DEFMAG div 100) *
          defHelp));
      end;
    end;
    DnType := Self.GetDamageType3(Skill, IsPhysical, mob);
    if (DnType = Miss) then
    begin
      Result := 0;
      Exit;
    end;
    Randomize;
    ResultDamage := ResultDamage - (MobDef shr 3);
    if (mob^.ClientID <= MAX_CONNECTIONS) then
      Dec(ResultDamage,
        ((ResultDamage div 100) * (mob.GetEquipedItensDamageReduce div 10)));


    if (ResultDamage <= 0) then
      ResultDamage := 1;
    Result := ResultDamage;
  except
    on E: Exception do
    begin
      Logger.Write('TBaseMob.GetDamage Error: ' + E.Message, TLogType.Error);
      Result := (((Self.PlayerCharacter.Base.CurrentScore.DNFis +
        Self.PlayerCharacter.Base.CurrentScore.DNMAG) div 2) -
        (((mob^.PlayerCharacter.Base.CurrentScore.DEFMAG +
        mob^.PlayerCharacter.Base.CurrentScore.DEFFis) div 2) shr 3));
      DnType := TDamageType.Normal;
      Randomize;
      Inc(Result, (RandomRange(10, 120) + 15));
    end;
  end;
end;
function TBaseMob.GetDamageType(Skill: DWORD; IsPhysical: Boolean;
  mob: PBaseMob): TDamageType;
var
  RamdomArray: ARRAY [0 .. 999] OF Byte;
  RamdomSlot: WORD;
  Chance: Integer;
  DuploChance: WORD;
  CritChance, CritHelp: WORD;
  DuploHelp: WORD;
  MissHelp: WORD;
  AllChance: Word;
  xRes: TDamageType;
  function GetEmpty: WORD;
  var
    i: WORD;
  begin
    Result := 0;
    for i := 0 to 999 do
    begin
      if (RamdomArray[i] = 0) then
        Inc(Result);
    end;
  end;
  procedure SetChance(Chance: WORD; const Type1: Byte);
  var
    i: Integer;
    Empty: WORD;
    cnt: WORD;
  begin
    if (Chance = 0) then
      Exit;
    cnt := 0;
    for i := 0 to 999 do
    begin
      if(cnt >= Chance) then
        break;
      if (RamdomArray[i] = 0) then
      begin
        RamdomArray[i] := Type1;
        inc(cnt);
      end
      else
        Continue;
    end;
    AllChance := AllChance + Chance;
      {
    Empty := GetEmpty;
    if (Chance > Empty) then
      Chance := Empty;
    for i := 1 to Chance do
    begin
      RamdomSlot := RandomRange(0, 767);
      while (RamdomArray[RamdomSlot] <> 0) do
      begin
        RamdomSlot := RandomRange(0, 767);
      end;
      RamdomArray[RamdomSlot] := Type1;
    end; }
  end;
begin
  ZeroMemory(@RamdomArray, 1000);
  Randomize;
{$REGION 'Seta a chance basica dos tipos de dano'}
  if (IsPhysical) then
    Chance := 20
  else
    Chance := 30;
  SetChance(Chance, Byte(TDamageType.Critical));
  SetChance((Chance div 2), Byte(TDamageType.Miss));
{$ENDREGION}
{$REGION 'Seta de acordo com os status'}
  CritHelp := mob^.GetMobAbility(EF_RESISTANCE6) + mob^.PlayerCharacter.CritRes;
  if (CritHelp > Self.PlayerCharacter.Base.CurrentScore.Critical) then
  begin
    CritChance := 0;
  end
  else
  begin
    CritChance := Self.PlayerCharacter.Base.CurrentScore.Critical;
    decword(CritChance, CritHelp);
  end;
  SetChance(CritChance, Byte(TDamageType.Critical));
  if (IsPhysical) then
  begin
    SetChance(10, Byte(TDamageType.Double));
    SetChance(20, Byte(TDamageType.DoubleCritical));
    DuploHelp := mob^.GetMobAbility(EF_RESISTANCE7) +
      mob^.PlayerCharacter.DuploRes;
    if (DuploHelp > Self.PlayerCharacter.DuploAtk) then
    begin
      DuploChance := 0;
    end
    else
    begin
      DuploChance := Self.PlayerCharacter.DuploAtk;
      decword(DuploChance, DuploHelp); // redução de duplo
    end;
    DuploHelp :=
      ((Self.PlayerCharacter.DuploAtk + Self.PlayerCharacter.Base.CurrentScore.
      Critical) div 3);
    if (CritHelp >= DuploHelp) then
    begin
      DuploHelp := 10;
    end;
    SetChance(DuploHelp, Byte(TDamageType.DoubleCritical));
    SetChance(DuploChance, Byte(TDamageType.Double));
  end
  else
  begin
    SetChance(20, Byte(TDamageType.DoubleCritical));
    DuploHelp :=
      ((Self.PlayerCharacter.DuploAtk + Self.PlayerCharacter.Base.CurrentScore.
      Critical) div 2);
    if (DuploHelp <= CritHelp) then
    begin
      DuploHelp := 20;
    end;
    SetChance(DuploHelp, Byte(TDamageType.DoubleCritical));
  end;
  MissHelp := mob^.PlayerCharacter.Base.CurrentScore.Esquiva;
  decword(MissHelp, Self.PlayerCharacter.Base.CurrentScore.Acerto);
  SetChance(MissHelp, Byte(TDamageType.Miss));
{$ENDREGION}
  if(AllChance > 998) then
    AllChance := 998;
  xRes := TDamageType(RamdomArray[RandomRange(1, AllChance+1)]);
  if(xRes = TDamageType.Double) then
  begin
    if((Skill > 0) and (IsPhysical)) then
    begin
      xRes := TDamageType.Normal;
    end;
  end;
  Result := xRes;
end;
function TBaseMob.GetDamageType2(Skill: DWORD; IsPhysical: Boolean;
  mob: PBaseMob): TDamageType;
var
  // RamdomArray: ARRAY [0 .. 999] OF Byte;
  // InitialSlot: WORD;
  MissRate, HitRate, CritRate, ResCritRate, DuploCritRate, DuploRate,
    DuploResRate: Integer;
  Helper1 { , Helper2, Helper3, Helper4, Helper5, Helper6, Helper7 } : Integer;
  { procedure SetChance(Chance: WORD; const Type1: Byte);
    var
    i: Integer;
    begin
    if (Chance = 0) then
    Exit;
    for i := 1 to Chance do
    begin
    if (InitialSlot >= 999) then
    Continue;
    RamdomArray[InitialSlot] := Type1;
    Inc(InitialSlot);
    end;
    end; }
begin
  Result := TDamageType.Normal;
  Randomize;
  Helper1 := RandomRange(1, 101);
  MissRate := ((mob^.PlayerCharacter.Base.CurrentScore.Esquiva div 127) * 100);
  if (MissRate > 80) then
    MissRate := 80; // 20% de margem de erro 1/5
  if (Helper1 <= MissRate) then
  begin // o alvo se esquivou
    HitRate := ((Self.PlayerCharacter.Base.CurrentScore.Acerto div 127) * 100);
    if (HitRate > 60) then
      HitRate := 60;
    Helper1 := RandomRange(1, 101);
    if (Helper1 <= HitRate) then
    begin // mas meu acerto furou o miss do alvo
      Result := TDamageType.Normal;
    end
    else
    begin // meu acerto não conseguiu furar a esquiva do alvo, e deu miss msm
      Result := TDamageType.Miss;
      Exit;
    end;
  end;
  CritRate := ((Self.PlayerCharacter.Base.CurrentScore.Critical div 127) * 100);
  if (CritRate > 80) then
    CritRate := 80; // 20% de critico imperfeito
  // Helper3 := Random(100);
  Helper1 := RandomRange(1, 101);
  if (Helper1 <= CritRate) then
  begin // critei no alvo, sera que o alvo resiste ao meu critico?
    ResCritRate :=
      (((mob^.GetMobAbility(EF_RESISTANCE6) + mob^.PlayerCharacter.CritRes)
      div 127) * 100);
    if (ResCritRate > 60) then
      ResCritRate := 60; // 30% de resistencia a critico imperfeita
    // Helper4 := Random(100);
    Helper1 := RandomRange(1, 101);
    if (Helper1 <= ResCritRate) then
    begin // critei, mas o alvo resistiu ao meu critico
      Result := TDamageType.Normal;
    end
    else
    begin // opa critei mesmo, nem a resistencia dele foi capaz de me parar
      DuploCritRate :=
        ((((Self.PlayerCharacter.Base.CurrentScore.Critical +
        Self.PlayerCharacter.DuploAtk) div 2) div 127) * 100);
      if (DuploCritRate > 60) then
        DuploCritRate := 60; // 40% de duplo critico imperfeito
      // Helper5 := Random(100);
      Helper1 := RandomRange(1, 101);
      if (Helper1 <= DuploCritRate) then
      begin // carai, consegui duplo critico, M.A. de crit_rate + duplo_rate
        Result := TDamageType.Critical;
      end
      else
        Result := TDamageType.DoubleCritical;
      Exit;
    end;
  end;
  DuploRate := ((Self.PlayerCharacter.DuploAtk div 127) * 100);
  if (DuploRate > 80) then
    DuploRate := 80;
  // Helper6 := Random(100);
  Helper1 := RandomRange(1, 101);
  if (Helper1 <= DuploRate) then
  begin // boa boa consegui dar duplo no cara
    DuploResRate :=
      (((mob^.GetMobAbility(EF_RESISTANCE7) + mob^.PlayerCharacter.DuploRes)
      div 127) * 100);
    if (DuploResRate > 60) then
      DuploResRate := 60;
    // Helper7 := Random(100);
    Helper1 := RandomRange(1, 101);
    if (Helper1 <= DuploResRate) then
    begin // o alvo conseguiu resistir ao meu duplo, opora
      Result := TDamageType.Normal;
    end
    else
    begin
      Result := TDamageType.Double;
    end;
  end;
end;
function TBaseMob.GetDamageType3(Skill: DWORD; IsPhysical: Boolean; mob: PBaseMob)
  : TDamageType;
var
  Esquiva, Acerto: WORD;
  Critico, ResistenciaCrit: WORD;
  Duplo, ResistenciaDuplo: WORD;
  DuploCritico, ResistenciaDuploCritico: WORD;
  TaxaCritica, TaxaAcerto, TaxaDuplo, TaxaDuploCritico: Integer;
  TaxaRand: Integer;
  Helper: Extended;
  HelperX: Integer;
  AlwaysCrit: Boolean;
begin
  AlwaysCrit := False;

  Result := TDamageType.Normal;

{$REGION 'Calculando Acerto x Esquiva'}
  Esquiva := mob.PlayerCharacter.Base.CurrentScore.Esquiva; //esquiva do alvo
  Acerto := Self.PlayerCharacter.base.CurrentScore.Acerto;

  if not(mob.IsPlayer) then
  begin
    Randomize;
    Acerto := Acerto + RandomRange(20, 40);
  end;

  TaxaAcerto := Acerto - Esquiva; //tava esquiva - acerto

  if(TaxaAcerto >= 0) then
  begin
    Randomize;
    TaxaRand := RandomRange(1, 101);

    if(TaxaAcerto > 10) then
      TaxaAcerto := 10;

    if((TaxaRand+TaxaAcerto) <= 20) and (Esquiva >= 7) then
    begin
      Result := TDamageType.Miss;
      INCWORD(Self.MissCount, 1);

      if(Self.MissCount >= 3) then
      begin
        Result := TDamageType.Normal;
        Self.MissCount := 0;
      end
      else
        Exit;
    end;
  end
  else
  begin
    TaxaAcerto := (TaxaAcerto * (-1));

    //Helper := (TaxaAcerto div 255);
    //HelperX := Trunc(Helper * 100);

    Randomize;
    TaxaRand := RandomRange(1, (101));

    //HelperX := HelperX + 25;

    if(TaxaAcerto > 10) then
      TaxaAcerto := 10;

    if((TaxaRand <= (30+TaxaAcerto)) and (Esquiva >= 3)) then
    begin
      Result := TDamageType.Miss;
      INCWORD(Self.MissCount, 1);

      if(Self.MissCount >= 3) then
      begin
        Result := TDamageType.Normal;
        Self.MissCount := 0;
      end
      else
        Exit;
    end;
  end;
{$ENDREGION}
{$REGION 'Calculando Critico x Resistencia Critico'}
  Critico := Self.PlayerCharacter.Base.CurrentScore.Critical;
  ResistenciaCrit := Trunc((mob.PlayerCharacter.CritRes+10)*1.4);

  if not(mob.IsPlayer) then
  begin
    if(Critico >= 100) then
      AlwaysCrit := True;
  end;

  TaxaCritica := Critico - ResistenciaCrit; //tava ao contrario tbm

  if(TaxaCritica >= 0) then
  begin
    Randomize;
    TaxaRand := RandomRange(1, 101);

    if(TaxaCritica > 25) then
      TaxaCritica := 25;

    if(((TaxaRand+TaxaCritica) >= 40) and (Critico >= 5)) then
    begin //deu critico ainda calcular o double critical
      Result := TDamageType.Critical;
    end;

    if(AlwaysCrit) then
    begin
      Randomize;
      if(RandomRange(1, 4) = 2) then
        Result := TDamageType.Critical;
    end;
  end
  else
  begin
    TaxaCritica := (TaxaCritica * (-1));

    //Helper := (TaxaCritica div 255);
    //HelperX := Trunc(Helper * 100);

    Randomize;
    TaxaRand := RandomRange(1, (101));

   // HelperX := HelperX;

    if(TaxaCritica > 5) then
      TaxaCritica := 5;

    if((TaxaRand <= (15-TaxaCritica)) and (Critico >= 9)) then
    begin //deu critico ainda calcular o double critical
      Result := TDamageType.Critical;
    end;
  end;

  if(Self.BuffExistsByID(6347)) then
    Result := TDamageType.Critical;

{$ENDREGION}

  case Result of
    Normal: //calcular o double
      begin
{$REGION 'Calculando duplo x resistencia a duplo'}
        if(Skill = 0) then
        begin
          Duplo := Self.PlayerCharacter.DuploAtk;
          ResistenciaDuplo := Trunc((mob.PlayerCharacter.DuploRes+5)*1.5);

          TaxaDuplo := Duplo - ResistenciaDuplo; //tava ao contrario tbm

          if(TaxaDuplo >= 0) then
          begin
            Randomize;
            TaxaRand := RandomRange(1, 101);

            if(TaxaDuplo > 10) then
              TaxaDuplo := 10;

            if((TaxaRand >= (80-TaxaDuplo)) and (Duplo >= 3)) then
            begin
              Result := TDamageType.Double;
            end;
          end
          else
          begin
            TaxaDuplo := (TaxaDuplo * (-1));

            //Helper := (TaxaDuplo div 255);
            //HelperX := Trunc(Helper * 100);

            Randomize;
            TaxaRand := RandomRange(1, (101));

            //;//HelperX := HelperX + 7;

            if(TaxaDuplo > 10) then
              TaxaDuplo := 10;

            if((TaxaRand <= (15+TaxaDuplo)) and (Duplo >= 5))  then
            begin
              Result := TDamageType.Double;
            end;
          end;
        end;

{$ENDREGION}
      end;
    //Critical: //calcular o double critical
    //  begin
{$REGION 'Calculando duplo critico'}
     {   IncWORD(DuploCritico, (Self.PlayerCharacter.DuploAtk +
          Self.PlayerCharacter.Base.CurrentScore.Critical));

        DuploCritico := (DuploCritico div 2);

        IncWORD(ResistenciaDuploCritico, ((mob.PlayerCharacter.DuploRes +
          mob.PlayerCharacter.CritRes)*1.4));

        ResistenciaDuploCritico := (ResistenciaDuploCritico div 2);

        TaxaDuploCritico := DuploCritico - ResistenciaDuploCritico;

        if(TaxaDuploCritico >= 0) then
        begin
          Randomize;
          TaxaRand := RandomRange(1, 101);

          if(TaxaRand >= 72) then
          begin
            Result := TDamageType.DoubleCritical;
          end;
        end
        else
        begin
          TaxaDuploCritico := (TaxaDuploCritico * (-1));

          Helper := (TaxaDuplo div 127);
          HelperX := (Helper * 100);

          Randomize;
          TaxaRand := RandomRange(1, (101+HelperX));

          HelperX := HelperX + 15;

          if(TaxaRand <= HelperX) then
          begin
            Result := TDamageType.DoubleCritical;
          end;

        end; }
{$ENDREGION}
    //  end;
  end;
end;

procedure TBaseMob.CalcAndCure(Skill: DWORD; mob: PBaseMob);
var
  Cure: Cardinal;
  curePerc: Integer;
begin
  Cure := (Self.PlayerCharacter.Base.CurrentScore.DNMAG div 2);

  Inc(Cure, SkillData[Skill].Damage);

  Inc(Cure, ((Cure div 40) * Self.GetMobAbility(EF_DAMAGE6)));
  Inc(Cure, (Self.GetMobAbility(EF_SKILL_DAMAGE6)));
  if(Self.ClientID <> mob.ClientID) then
  begin
    Inc(Cure, ((Cure div 40) * mob.GetMobAbility(EF_DAMAGE6)));
    Inc(Cure, (mob.GetMobAbility(EF_SKILL_DAMAGE6)));
  end;

  Inc(Cure, ((Cure div 100) * mob.PlayerCharacter.CureTax));

  Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_UPCURE)));

  Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_PER_CURE_PREPARE)));

  Randomize;
  curePerc := ((RandomRange(20, 299) div 2) + 35);
  Inc(Cure, curePerc);

  DecCardinal(Cure, ((Cure div 100) * mob.GetMobAbility(EF_DECURE)));

  if((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount = 0)) then
  begin
    mob.NegarCuraCount := 3;

    mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)), True, True);
    mob.LastReceivedAttack := Now;
    mob.NegarCuraCount := mob.NegarCuraCount -1;

    Exit;
  end
  else if((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount > 0)) then
  begin
    mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)), True, True);

    mob.NegarCuraCount := mob.NegarCuraCount -1;
    mob.LastReceivedAttack := Now;
    if(mob.NegarCuraCount = 0) then
    begin
      mob.RemoveBuffByIndex(88);
    end;

    Exit;
  end;

  mob.AddHP(Cure, True);

  //mob.GetCurrentScore;
  //mob.SendCurrentHPMP();

  if(mob.ClientID = Self.ClientID) then
  begin
    Servers[Self.ChannelId].Players[mob.ClientId].SendClientMessage
      ('Seu HP foi restaurado em ' + AnsiString(Cure.ToString), 16);
  end
  else
  begin
    Servers[Self.ChannelId].Players[mob.ClientId].SendClientMessage
      ('Seu HP foi restaurado em ' + AnsiString(Cure.ToString) + ' por [' +
      AnsiString(Self.Character.Name) + '].', 16);
  end;
end;

function TBaseMob.CalcCure(Skill: DWORD; mob: PBaseMob): Integer;
var
  Cure: Cardinal;
  curePerc: Integer;
begin
  Result := 0;

  Cure := (Self.PlayerCharacter.Base.CurrentScore.DNMAG div 2);

  Inc(Cure, SkillData[Skill].Damage);

  Inc(Cure, ((Cure div 40) * Self.GetMobAbility(EF_DAMAGE6)));
  Inc(Cure, (Self.GetMobAbility(EF_SKILL_DAMAGE6)));
  if(Self.ClientID <> mob.ClientID) then
  begin
    Inc(Cure, ((Cure div 40) * mob.GetMobAbility(EF_DAMAGE6)));
    Inc(Cure, (mob.GetMobAbility(EF_SKILL_DAMAGE6)));
  end;

  Inc(Cure, ((Cure div 100) * mob.PlayerCharacter.CureTax));

  Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_UPCURE)));

  Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_PER_CURE_PREPARE)));

  Randomize;
  curePerc := ((RandomRange(20, 299) div 2) + 35);
  Inc(Cure, curePerc);

  DecCardinal(Cure, ((Cure div 100) * mob.GetMobAbility(EF_DECURE)));

  if((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount = 0)) then
  begin
    mob.NegarCuraCount := 3;

    mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)), True, True);
    mob.LastReceivedAttack := Now;
    mob.NegarCuraCount := mob.NegarCuraCount -1;

    Exit;
  end
  else if((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount > 0)) then
  begin
    mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)), True, True);
    mob.LastReceivedAttack := Now;
    mob.NegarCuraCount := mob.NegarCuraCount -1;

    if(mob.NegarCuraCount = 0) then
    begin
      mob.RemoveBuffByIndex(88);
    end;

    Exit;
  end;

  Result := Cure;
end;

function TBaseMob.CalcCure2(BaseCure: DWORD; mob: PBaseMob; xSkill: Integer): Integer;
var
  Cure: Cardinal;
  curePerc: Integer;
begin
  Result := 0;

  Cure := (Self.PlayerCharacter.Base.CurrentScore.DNMAG div 2);
  Cure := Cure + BaseCure;

  if(xSkill > 0) then
  begin
    Inc(Cure, SkillData[xSkill].Damage);
  end;

  Inc(Cure, ((Cure div 40) * Self.GetMobAbility(EF_DAMAGE6)));
  Inc(Cure, (Self.GetMobAbility(EF_SKILL_DAMAGE6)));
  if(Self.ClientID <> mob.ClientID) then
  begin
    Inc(Cure, ((Cure div 40) * mob.GetMobAbility(EF_DAMAGE6)));
    Inc(Cure, (mob.GetMobAbility(EF_SKILL_DAMAGE6)));
  end;

  Inc(Cure, ((Cure div 100) * mob.PlayerCharacter.CureTax));

  Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_UPCURE)));

  //Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_PER_CURE_PREPARE)));

  Randomize;
  curePerc := ((RandomRange(20, 299) div 2) + 35);
  Inc(Cure, curePerc);

  DecCardinal(Cure, ((Cure div 100) * mob.GetMobAbility(EF_DECURE)));

  if(SkillData[xSkill].Index <> 125) then
  begin
    if((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount = 0)) then
    begin
      mob.NegarCuraCount := 3;

      mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)), True, True);
      mob.LastReceivedAttack := Now;
      mob.NegarCuraCount := mob.NegarCuraCount -1;

      Exit;
    end
    else if((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount > 0)) then
    begin
      mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)), True, True);
      mob.LastReceivedAttack := Now;
      mob.NegarCuraCount := mob.NegarCuraCount -1;

      if(mob.NegarCuraCount = 0) then
      begin
        mob.RemoveBuffByIndex(88);
      end;

      Exit;
    end;
  end;

  Result := Cure;
end;
procedure TBaseMob.HandleSkill(Skill, Anim: DWORD; mob: PBaseMob;
  SelectedPos: TPosition; DataSkill: P_SkillData);
var
  Packet: TRecvDamagePacket;
  gotDano: Integer;
  gotDMGType: TDamageType;
  Add_Buff: Boolean;
  Resisted: Boolean;
  DropExp, DropItem: Boolean;
  j: Integer;
  s: Integer;
  Helper2: Byte;
  SelfPlayer, OtherPlayer: PPlayer;
  // Mobs: PMobSa;
  MobsP: PMobSPoisition;
  Rand: Integer;
begin
  s := sizeof(Packet);
  ZeroMemory(@Packet, s);
  Packet.Header.size := s;
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $102;
  Packet.SkillID := Skill;
  Packet.AttackerPos := Self.PlayerCharacter.LastPos;
  Packet.AttackerID := Self.ClientID;
  Packet.Animation := Anim;
  Packet.AttackerHP := Self.Character.CurrentScore.CurHP;
  if (mob^.ClientID = Self.ClientID) then
    Packet.TargetID := Self.ClientID
  else
    Packet.TargetID := mob^.ClientID;
  Packet.MobAnimation := DataSkill^.TargetAnimation;

  { if (SkillData[Skill].SuccessRate = 1) and (SkillData[Skill].range > 0) then
    begin // skills de ataque em area[targets]
    { if ((SkillData[Skill].Index = 102) or (SkillData[Skill].Index = 118)) then
    // fix skill de fc que não acerta
    begin
    SelectedPos := mob.PlayerCharacter.LastPos;
    end; }
  { Self.AreaSkill(Skill, Anim, mob, SelectedPos);
    Exit;
    end; }
  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];
  if (DataSkill^.SuccessRate = 1) and (DataSkill^.range = 0) then
  begin // skills de ataque single[Target]
    Resisted := False;
    case Self.GetMobClass() of
      2:
      begin
        if not(ItemList[Self.Character.Equip[15].Index].ItemType = 52) then
          begin
            TItemFunctions.DecreaseAmount(@Self.Character.Equip[15], 1);
            Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
              Self.Character.Equip[15], False);
          end;
      end;

      3:
        begin
          if not(ItemList[Self.Character.Equip[15].Index].ItemType = 52) then
          begin
            TItemFunctions.DecreaseAmount(@Self.Character.Equip[15], 2);
            Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
              Self.Character.Equip[15], False);
          end;
        end;
    end;
    Self.TargetSkill(Skill, Anim, mob, gotDano, gotDMGType, Add_Buff, Resisted);

    if (gotDano > 0) then
    begin
      Self.AttackParse(Skill, Anim, mob, gotDano, gotDMGType, Add_Buff,
        Packet.MobAnimation, DataSkill);

      if(gotDano > 0) then
      begin
        Inc(gotDano, ((RandomRange((gotDano div 20), (gotDano div 10))) + 13));
      end;
    end
    else
    begin
      if not(gotDMGType in [Critical, Normal, Double]) then
        Add_Buff := False;
    end;

    if (Add_Buff = True) then
    begin
      if not(Resisted) then
        Self.TargetBuffSkill(Skill, Anim, mob, DataSkill);
    end;
    Packet.Dano := gotDano;
    Packet.DnType := gotDMGType;
    if (Servers[Self.ChannelId].Players[Self.ClientID].InDungeon) then
    begin
      if (Packet.Dano >= DungeonInstances[Servers[Self.ChannelId].Players
        [Self.ClientID].DungeonInstanceID].Mobs[mob.Mobid].CurrentHP) then
      begin
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].Mobs[mob.Mobid].CurrentHP := 0;
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].Mobs[mob.Mobid].IsAttacked := False;
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].Mobs[mob.Mobid].AttackerID := 0;
        { DungeonInstances
          [Servers[Self.ChannelId].Players[Self.ClientId].DungeonInstanceID]
          .Mobs[mob.Mobid].deadTime := Now; }
        if (Self.VisibleMobs.Contains(mob.ClientID)) then
          Self.VisibleMobs.Remove(mob.ClientID);
        mob.VisibleMobs.Clear;
        Self.MobKilledInDungeon(mob);
        Packet.MobAnimation := 30;
        mob.IsDead := True;
      end
      else
      begin
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].Mobs[mob.Mobid].CurrentHP :=
          DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].Mobs[mob.Mobid].CurrentHP - Packet.Dano;
      end;
      mob.LastReceivedAttack := Now;
      Packet.MobCurrHP := DungeonInstances
        [Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID].Mobs
        [mob.Mobid].CurrentHP;
      Self.SendToVisible(Packet, Packet.Header.size);
      Exit;
    end;

    MobsP := @Servers[mob^.ChannelId].Mobs.TMobS[0].MobsP[1];
    if(mob^.SecondIndex > 0) then
      MobsP := @Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobsP
        [mob^.SecondIndex];

    if (mob^.ClientID <= MAX_CONNECTIONS) then
    begin
      if(SecondsBetween(Now, mob.RevivedTime) <= 7) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Alvo acabou de nascer.');
        Exit;
      end;

      OtherPlayer := @Servers[mob^.ChannelId].Players[mob^.ClientID];
      if (Packet.Dano >= mob^.Character.CurrentScore.CurHP) then
      begin
        if (OtherPlayer^.Dueling) then
        begin
          mob^.Character.CurrentScore.CurHP := 10;
        end
        else
        begin
          mob^.Character.CurrentScore.CurHP := 0;
          mob^.SendEffect($0);
          Packet.MobAnimation := 30;
          mob^.IsDead := True;
          if(Servers[Self.ChannelId].Players[mob^.ClientID].CollectingReliquare) then
            Servers[Self.ChannelId].Players[mob^.ClientID].SendCancelCollectItem(
            Servers[Self.ChannelId].Players[mob^.ClientID].CollectingID);
          mob^.LastReceivedAttack := Now;
          Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;
          Self.SendToVisible(Packet, Packet.Header.size);
          if (mob^.Character.Nation > 0) and (Self.Character.Nation > 0) then
          begin
            if ((mob^.Character.Nation <> Self.Character.Nation) or
              (Self.InClastleVerus))  then
            begin
              Self.PlayerKilled(mob);
            end;
          end;
        end;
      end
      else
      begin
        if (Packet.Dano > 0) then
          mob^.RemoveHP(Packet.Dano, False);
        if(Servers[Self.ChannelId].Players[mob^.ClientID].CollectingReliquare) then
          Servers[Self.ChannelId].Players[mob^.ClientID].SendCancelCollectItem(
          Servers[Self.ChannelId].Players[mob^.ClientID].CollectingID);
        mob^.LastReceivedAttack := Now;
        Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;
        Self.SendToVisible(Packet, Packet.Header.size);
      end;

      Exit;
    end
    else if (((mob^.ClientID >= 3048) and (mob^.ClientID < 9148)) or (MobsP.isTemp)) then
    begin
      // Mobs := @Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid];
      case mob^.ClientID of
        3340 .. 3354:
          begin // stones
            if ((Packet.Dano >= Servers[Self.ChannelId].DevirStones
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP)and not(mob^.IsDead)) then
            begin
              mob^.IsDead := True;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := 0;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .IsAttacked := False;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .AttackerID := 0;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .deadTime := Now;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID].
                KillStone(mob^.ClientID, Self.ClientId);
              if (Self.VisibleNPCs.Contains(mob^.ClientID)) then
              begin
                Self.VisibleNPCs.Remove(mob^.ClientID);
                Self.RemoveTargetFromList(mob);
                // essa skill tem retorno no caso de erro
              end;
              for j in Self.VisiblePlayers do
              begin
                if(Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Contains(mob^.ClientID)) then
                begin
                  Servers[Self.ChannelId].Players[j].Base.VisibleNPCs.Remove(mob^.ClientID);
                  Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(mob);
                end;
              end;
              mob^.VisibleMobs.Clear;
              // Self.MobKilled(mob, DropExp, DropItem, False);
              Packet.MobAnimation := 30;
            end
            else
            begin
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := Servers[Self.ChannelId]
                .DevirStones[mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP -
                Packet.Dano;
            end;
            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := Servers[Self.ChannelId].DevirStones
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP;
            Self.SendToVisible(Packet, Packet.Header.size);
            Exit;
          end;
        3355 .. 3369:
          begin // guards
            if ((Packet.Dano >= Servers[Self.ChannelId].DevirGuards
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP)and not(mob^.IsDead)) then
            begin
              mob^.IsDead := True;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := 0;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .IsAttacked := False;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .AttackerID := 0;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .deadTime := Now;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID].
                KillGuard(mob^.ClientID, Self.ClientId);
              if (Self.VisibleNPCs.Contains(mob^.ClientID)) then
              begin
                Self.VisibleNPCs.Remove(mob^.ClientID);
                Self.RemoveTargetFromList(mob);
                // essa skill tem retorno no caso de erro
              end;
              for j in Self.VisiblePlayers do
              begin
                if(Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Contains(mob^.ClientID)) then
                begin
                  Servers[Self.ChannelId].Players[j].Base.VisibleNPCs.Remove(mob^.ClientID);
                  Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(mob);
                end;
              end;
              mob^.VisibleMobs.Clear;
              // Self.MobKilled(mob, DropExp, DropItem, False);
              Packet.MobAnimation := 30;
            end
            else
            begin
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := Servers[Self.ChannelId]
                .DevirGuards[mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP -
                Packet.Dano;
            end;
            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := Servers[Self.ChannelId].DevirGuards
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP;
            Self.SendToVisible(Packet, Packet.Header.size);
            //Sleep(1);
            Exit;
          end;
      else
        begin
          MobsP := @Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobsP
            [mob.SecondIndex];

          if not(MobsP.IsAttacked) then
          begin
            MobsP.FirstPlayerAttacker := Self.ClientID;
          end;

          if (Packet.Dano >= MobsP^.HP) then
          begin
            MobsP^.HP := 0;
            MobsP^.IsAttacked := False;
            MobsP^.AttackerID := 0;
            MobsP^.deadTime := Now;

            MobsP.Base.SendEffect($0);
            if (Self.VisibleMobs.Contains(mob^.ClientID)) then
            begin
              Self.VisibleMobs.Remove(mob^.ClientID);
              Self.RemoveTargetFromList(mob);
            end;
            for j in Self.VisiblePlayers do
            begin
              if(Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Contains(mob^.ClientID)) then
              begin
                Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Remove(mob^.ClientID);
                Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(mob);
              end;
            end;
            // ver aquele bang de tirar na lista propia
            mob^.VisibleMobs.Clear;
            mob^.IsDead := True;
            { Servers[Self.ChannelId].Players[Self.ClientId].SendClientMessage
              ('Adquiriu ' + AnsiString(Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid]
              .MobExp.ToString) + ' + ' +
              AnsiString((Servers[Self.ChannelId].Players[Self.ClientId]
              .AddExp(Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobExp,
              EXP_TYPE_MOB) - Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobExp)
              .ToString) + ' exp.', 0); }
            Self.MobKilled(mob, DropExp, DropItem, False);
            Packet.MobAnimation := 30;
            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := MobsP^.HP;
            Self.SendToVisible(Packet, Packet.Header.size);
          end
          else
          begin
            deccardinal(MobsP^.HP, Packet.Dano);
            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := MobsP^.HP;
            Self.SendToVisible(Packet, Packet.Header.size);
          end;

          //Sleep(1);
          Exit;
        end;
      end;
    end
    else if (mob^.ClientID >= 9148) then
    begin
      Servers[Self.ChannelId].PETS[mob.ClientID].IsAttacked := True;
      Servers[Self.ChannelId].PETS[mob.ClientID].AttackerID := Self.ClientID;
      if (Packet.Dano >= mob.PlayerCharacter.Base.CurrentScore.CurHP) then
      begin
        mob.PlayerCharacter.Base.CurrentScore.CurHP := 0;
        Packet.MobAnimation := 30;
        mob.IsDead := True;
        {for j in mob.VisibleMobs do
        begin
          if not(j >= 3048) then
          begin
            Servers[Self.ChannelId].Players[j].UnSpawnPet(mob.ClientID);
          end;
        end; }

        if(Servers[Self.ChannelId].PETS[mob.ClientID].IntName > 0) then
        begin
          if(Servers[Self.ChannelId].PETS[mob.ClientID].Base.IsActive) then
            Servers[Self.ChannelId].Players[Self.ClientID].Base.DestroyPet(
              mob.ClientID);
        end;
        //Servers[Self.ChannelId].PETS[mob.ClientID].Base.Destroy;
        //ZeroMemory(@Servers[Self.ChannelId].PETS[mob.ClientID], sizeof(TPet));
      end
      else
      begin
        DecCardinal(mob.PlayerCharacter.Base.CurrentScore.CurHP,
          Packet.DANO);
         //:=
          //mob.PlayerCharacter.Base.CurrentScore.CurHP - Packet.Dano;
      end;
      mob.LastReceivedAttack := Now;
      Packet.MobCurrHP := mob.PlayerCharacter.Base.CurrentScore.CurHP;
      // Self.SendCurrentHPMP;
      Self.SendToVisible(Packet, Packet.Header.size);
      //Sleep(1);
      Exit;
    end;
  end;
  if (DataSkill^.SuccessRate = 0) and (DataSkill^.range = 0) then
  begin // skills de buff single[Self div Target]
    Packet.DnType := TDamageType.None;
    Packet.Dano := 0;
    Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;

    if (Self.IsCompleteEffect5(Helper2)) then
    begin
      Randomize;
      Rand := RandomRange(1, 101);
      if (Rand <= (RATE_EFFECT5*Length(Self.EFF_5))) then
      begin
        Self.Effect5Skill(@Self, Helper2, True);
      end;
    end;

    if (DataSkill^.TargetType = 1) then
    begin // [Self]
      // Self.SendCurrentHPMP;
      Self.SendToVisible(Packet, Packet.Header.size);
      Self.SelfBuffSkill(Skill, Anim, mob, SelectedPos);
    end
    else
    begin // [Target]
      // Self.SendCurrentHPMP;
      if (DataSkill^.Classe >= 61) and (DataSkill^.Classe <= 84) then
      begin // skills de pran
        case SelfPlayer^.SpawnedPran of
          0:
            begin
              Packet.AttackerPos := SelfPlayer^.Account.Header.Pran1.Position;
              Packet.AttackerID := SelfPlayer^.Account.Header.Pran1.id;
              Packet.TargetID := Self.ClientID;
              Randomize;
              Rand := RandomRange(1, 225);
              if (Rand > SelfPlayer^.Account.Header.Pran1.Devotion) then
              begin
                SelfPlayer^.SendClientMessage
                  ('Pran se recusou por conta da familiaridade.');
                Self.SendToVisible(Packet, Packet.Header.size);
                Exit;
              end;
            end;
          1:
            begin
              Packet.AttackerPos := SelfPlayer^.Account.Header.Pran2.Position;
              Packet.AttackerID := SelfPlayer^.Account.Header.Pran2.id;
              Packet.TargetID := Self.ClientID;
              Randomize;
              Rand := RandomRange(1, 225);
              if (Rand > SelfPlayer^.Account.Header.Pran2.Devotion) then
              begin
                SelfPlayer^.SendClientMessage
                  ('Pran se recusou por conta da familiaridade.');
                Self.SendToVisible(Packet, Packet.Header.size);
                Exit;
              end;
            end;
        end;
      end;
      Self.SendToVisible(Packet, Packet.Header.size);
      //Sleep(1);
      Self.TargetBuffSkill(Skill, Anim, mob, DataSkill);
    end;
    Exit;
  end;
  if (DataSkill^.SuccessRate = 0) and (DataSkill^.range > 0) then
  begin // skills de buff em area [ou em party]
    if (Self.IsCompleteEffect5(Helper2)) then
    begin
      Randomize;
      Rand := RandomRange(1, 101);
      if (Rand <= (RATE_EFFECT5*Length(Self.EFF_5))) then
      begin
        Self.Effect5Skill(@Self, Helper2, True);
      end;
    end;

    Packet.DnType := TDamageType.None;
    Packet.Dano := 0;
    Packet.MobCurrHP := mob.Character.CurrentScore.CurHP;
    Packet.DeathPos := SelectedPos;
    Packet.TargetID := Self.ClientID;
    // Self.SendCurrentHPMP;
    Self.SendToVisible(Packet, Packet.Header.size);
    //Sleep(1);
    Self.AreaBuff(Skill, Anim, mob, Packet);
    Exit;
  end;
end;
function TBaseMob.ValidAttack(DmgType: TDamageType; DebuffType: Byte;
  mob: PBaseMob; AuxDano: Integer; xisBoss: Boolean): Boolean;
var
  Rate: Integer;
  Rand: Integer;
  VerifyToCastle: Boolean;
begin
  Result := False;
  VerifyToCastle := False;
  case DmgType of
    Normal, Critical, Double, DoubleCritical:
      begin
        Result := True;
      end;
    Miss:
      Result := False;
  end;
  if (mob = nil) then
    Exit;
  if (mob^.ClientID >= 3048) or (mob^.IsDungeonMob) then
  begin
    if((mob.IsBoss) and not(xisBoss)) then
    begin
      Result := False;
    end;
    Exit;
  end;

  if not(Result) then
    Exit;

  if(AuxDano > 0) then
  begin //aviso da bolha
    if (mob^.BuffExistsByIndex(36) = True) then
    begin
      Result := False;
      Exit;
    end;
  end
  else //apenas sair
  begin
    if (mob^.BuffExistsByIndex(36) = True) then
    begin
      dec(mob^.BolhaPoints, 1);
      if (mob^.BolhaPoints = 0) then
      begin
        mob^.RemoveBuffByIndex(36);
        Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
          ('[' + AnsiString(mob.Character.Name) +
          '] resistiu à sua habilidade de ataque.', 16, 1, 1);
        Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
        ('Você resistiu ao de ataque de [' +
        AnsiString(Self.Character.Name) + '] Proteção desativada.', 16, 1, 1);
      end
      else
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
          ('[' + AnsiString(mob.Character.Name) +
          '] resistiu à sua habilidade de ataque.', 16, 1, 1);
        Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
        ('Você resistiu ao ataque de [' +
        AnsiString(Self.Character.Name) + '] restam ' +
        mob.BolhaPoints.ToString + ' ticks.', 16, 1, 1);
      end;

      Result := False;
      Exit;
    end;
  end;

  if (Result = True) then
  begin
    if (DebuffType = 0) then
      Exit;
    Randomize;
    Rand := RandomRange(1, 255);
    Rate := 0;
    Rate := Trunc(Self.PlayerCharacter.Resistence / 5);
    Rate := Rate + Self.GetMobAbility(EF_STATE_RESISTANCE);
    case DebuffType of
      STUN_TYPE:
        begin
          Rate := Rate + mob^.GetMobAbility(EF_IM_SKILL_STUN);
          if (Rand <= Rate) then
          begin
            Result := False;
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
              ('[' + AnsiString(mob^.Character.Name) +
              '] resistiu à sua habilidade de stun.');
            Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
              ('Você resistiu à habilidade de stun de [' +
              AnsiString(Self.Character.Name) + '].');
          end
          else
          begin
            VerifyToCastle := True;
          end;
        end;
      SILENCE_TYPE:
        begin
          Rate := Rate + mob^.GetMobAbility(EF_IM_SILENCE1);
          if (Rand <= Rate) then
          begin
            Result := False;
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
              ('[' + AnsiString(mob^.Character.Name) +
              '] resistiu à sua habilidade de silêncio.');
            Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
              ('Você resistiu à habilidade de silêncio de [' +
              AnsiString(Self.Character.Name) + '].');
          end
          else
          begin
            VerifyToCastle := True;
          end;
        end;
      FEAR_TYPE:
        begin
          Rate := Rate + mob^.GetMobAbility(EF_IM_FEAR);
          if (Rand <= Rate) then
          begin
            Result := False;
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
              ('[' + AnsiString(mob^.Character.Name) +
              '] resistiu à sua habilidade de medo.');
            Servers[mob.ChannelId].Players[mob^.ClientID].SendClientMessage
              ('Você resistiu à habilidade de medo de [' +
              AnsiString(Self.Character.Name) + '].');
          end
          else
          begin
            VerifyToCastle := True;
          end;
        end;
      LENT_TYPE:
        begin
          Rate := Rate + mob^.GetMobAbility(EF_IM_RUNSPEED);
          if (Rand <= Rate) then
          begin
            Result := False;
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
              ('[' + AnsiString(mob^.Character.Name) +
              '] resistiu à sua habilidade de lentidão.');
            Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
              ('Você resistiu à habilidade de lentidão de [' +
              AnsiString(Self.Character.Name) + '].');
          end
          else
          begin
            VerifyToCastle := True;
          end;
        end;
      CHOCK_TYPE:
        begin
          Rate := Rate + mob^.GetMobAbility(EF_IM_SKILL_SHOCK);
          if (Rand <= Rate) then
          begin
            Result := False;
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
              ('[' + AnsiString(mob^.Character.Name) +
              '] resistiu à sua habilidade de choque.');
            Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
              ('Você resistiu à habilidade de choque de [' +
              AnsiString(Self.Character.Name) + '].');
          end
          else
          begin
            VerifyToCastle := True;
          end;
        end;
      PARALISYS_TYPE:
        begin
          Rate := Rate + mob^.GetMobAbility(EF_IM_SKILL_IMMOVABLE);
          if (Rand <= Rate) then
          begin
            Result := False;
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
              ('[' + AnsiString(mob^.Character.Name) +
              '] resistiu à sua habilidade de paralisia.');
            Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
              ('Você resistiu à habilidade de paralisia de [' +
              AnsiString(Self.Character.Name) + '].');
          end
          else
          begin
            VerifyToCastle := True;
          end;
        end;
    end;

    if(VerifyToCastle) then
    begin
      if(mob^.InClastleVerus) then
      begin
        mob^.LastReceivedSkillFromCastle := Now;
      end;
    end;
  end;
end;
procedure TBaseMob.MobKilledInDungeon(mob: PBaseMob);
var
  MobExp, ExpAcquired, NIndex, Helper: Integer;
  i, RandomClientID, j, k: WORD;
begin
  ExpAcquired := 0;
  MobExp := DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
    .DungeonInstanceID].Mobs[mob.Mobid].MobExp;
  for i in Servers[Self.ChannelId].Players[Self.ClientID].Party.Members do
  begin
    case Servers[Self.ChannelId].Players[Self.ClientID].Party.ExpAlocate of
      1: // igualmente
        begin
          MobExp := (MobExp div Servers[Self.ChannelId].Players[Self.ClientID]
            .Party.Members.Count);
          ExpAcquired := Servers[Self.ChannelId].Players[i].AddExp(MobExp, Helper,
            EXP_TYPE_MOB);
        end;
      2: // individualmente
        begin
          if (i = DungeonInstances[Servers[Self.ChannelId].Players
            [Self.ClientID].DungeonInstanceID].Mobs[mob.Mobid]
            .FirstPlayerAttacker) then
          begin
            ExpAcquired := Servers[Self.ChannelId].Players[i].AddExp(MobExp, Helper,
              EXP_TYPE_MOB);
          end;
        end;
    end;
    case Servers[Self.ChannelId].Players[Self.ClientID].Party.ItemAlocate of
      1: // em ordem
        begin
          NIndex := Servers[Self.ChannelId].Players[Self.ClientID]
            .Party^.LastSlotItemReceived;
          if (i = Servers[Self.ChannelId].Players[Self.ClientID].Party.Leader)
          then
          begin
            Self.DropItemFor(@Servers[Self.ChannelId].Players
              [Servers[Self.ChannelId].Players[Self.ClientID]
              .Party^.Members.ToArray[NIndex]].Base, mob);
            Inc(Servers[Self.ChannelId].Players[Self.ClientID]
              .Party^.LastSlotItemReceived);
            NIndex := Servers[Self.ChannelId].Players[Self.ClientID]
              .Party^.LastSlotItemReceived;
          end;
          { if (Servers[Self.ChannelId].Players[Self.ClientID]
            .Party^.Members.ToArray[NIndex] = i) then
            begin
            Inc(Servers[Self.ChannelId].Players[Self.ClientID]
            .Party.LastSlotItemReceived);
            Self.DropItemFor(@Servers[Self.ChannelId].Players[i].Base, mob);
            end; }
          if (NIndex >= (Servers[Self.ChannelId].Players[Self.ClientID]
            .Party.Members.Count)) then // reiniciar a ordem
            Servers[Self.ChannelId].Players[Self.ClientID]
              .Party.LastSlotItemReceived := 0;
        end;
      2: // aleatorio
        begin
          if (i = Servers[Self.ChannelId].Players[Self.ClientID].Party.Leader)
          then
          begin
            Randomize;
            RandomClientID := Servers[Self.ChannelId].Players[Self.ClientID]
              .Party.Members.ToArray
              [RandomRange(0, Servers[Self.ChannelId].Players[Self.ClientID]
              .Party.Members.Count+1)];
            Self.DropItemFor(@Servers[Self.ChannelId].Players[RandomClientID]
              .Base, mob);
          end;
        end;
      3: // individualmente
        begin
          if (i = DungeonInstances[Servers[Self.ChannelId].Players
            [Self.ClientID].DungeonInstanceID].Mobs[mob.Mobid]
            .FirstPlayerAttacker) then
          begin
            Self.DropItemFor(@Servers[Self.ChannelId].Players[i].Base, mob);
          end;
        end;
      4: // lider
        begin
          if (i = Servers[Self.ChannelId].Players[Self.ClientID].Party.Leader)
          then
          begin
            Self.DropItemFor(@Servers[Self.ChannelId].Players[i].Base, mob);
          end;
        end;
    end;
    if (ExpAcquired > 0) then
    begin
      // Servers[Self.ChannelId].Players[i].SendClientMessage
      // ('Adquiriu ' + AnsiString(IntToStr(ExpAcquired)) + ' exp.', 0);
      if not(Servers[Self.ChannelId].Players[i].SpawnedPran = 255) then
      begin
        Servers[Self.ChannelId].Players[i].SendClientMessage
          ('Você e sua pran não podem adquirir experiência em calabouços. ', 0);
      end;
    end;
    for j := 0 to 49 do
    begin
      if (Servers[Self.ChannelId].Players[i].PlayerQuests[j].id > 0) then
      begin // se existir quest no jogador
        if not(Servers[Self.ChannelId].Players[i].PlayerQuests[j].IsDone) then
        begin // se a quest ainda não foi entregue
          for k := 0 to 4 do
          begin // checa cada requiriment de mob
            if (Servers[Self.ChannelId].Players[i].PlayerQuests[j]
              .Quest.RequirimentsType[k] = 1) then
            // se o requiriment checado for de mob kill
            begin
              if (Servers[Self.ChannelId].Players[i].PlayerQuests[j]
                .Quest.Requiriments[k] = DungeonInstances
                [Servers[Self.ChannelId].Players[i].DungeonInstanceID].Mobs
                [mob.Mobid].IntName) then // se o mob morto for o mesmo da quest
              begin
                Inc(Servers[Self.ChannelId].Players[i].PlayerQuests[j]
                  .Complete[k]);
                if (Servers[Self.ChannelId].Players[i].PlayerQuests[j].Complete
                  [k] >= Servers[Self.ChannelId].Players[i].PlayerQuests[j]
                  .Quest.RequirimentsAmount[k]) then
                begin
                  Servers[Self.ChannelId].Players[i].PlayerQuests[j].Complete[k]
                    := Servers[Self.ChannelId].Players[i].PlayerQuests[j]
                    .Quest.RequirimentsAmount[k];
                  Servers[Self.ChannelId].Players[i].SendClientMessage
                    ('Você completou a quest [' +
                    AnsiString(Quests[Servers[Self.ChannelId].Players[i]
                    .PlayerQuests[j].Quest.QuestID].Titulo) + ']');
                  // aqui vai o aviso de quest completa
                end;
                Servers[Self.ChannelId].Players[i].UpdateQuest
                  (Servers[Self.ChannelId].Players[i].PlayerQuests[j].id);
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;
procedure TBaseMob.MobKilled(mob: PBaseMob; out DroppedExp: Boolean;
  out DroppedItem: Boolean; InParty: Boolean);
var
  i, j: Integer;
  ExpAcquired, PranExpAcquired: Int64;
  MobExp, CalcAux, CalcAuxRlq: Integer;
  DropExp, DropItem: Boolean;
  A, HelperX { B } : Integer;
  NIndex: WORD;
  // ClientIDReceiveItem: WORD;
  RandomClientID: Integer;
  // ItemReceived: Boolean;
  SelfPlayer, OtherPlayer: PPlayer;
  MobsP: PMobSPoisition;
begin // aqui será a função que verificará quest e dará drop/exp
  ExpAcquired := 0;
  PranExpAcquired := 0;
  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];

  if (mob^.ClientID <= MAX_CONNECTIONS) then
  begin
    Exit;
    //OtherPlayer := @Servers[mob^.ChannelId].Players[mob^.ClientID];
  end
  else if((mob^.ClientID >= 3048) and (mob^.ClientID <= 9147)) then
  begin
    MobsP := @Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobsP
      [mob^.SecondIndex];
  end
  else
    Exit;

  if (SelfPlayer^.PartyIndex <> 0) and (InParty = False) then
  begin
    A := 0;
    for i in SelfPlayer^.Party.Members do
    begin
      DropExp := False;
      DropItem := False;
      Servers[Self.ChannelId].Players[i].Base.MobKilled(mob, DropExp,
        DropItem, True);
      if (DropExp = True) then
        Inc(A);
    end;
    if (A = 0) then
    begin // cara de outra pt ou fora da pt quem atacou (Exp)
      if(MobsP^.FirstPlayerAttacker <> 0) then
      begin
        if not(MobsP^.FirstPlayerAttacker = Self.ClientID) then
        begin
          DropExp := False;
          DropItem := False;
          Servers[Self.ChannelId].Players[MobsP^.FirstPlayerAttacker]
            .Base.MobKilled(mob, DropExp, DropItem, False);
        end;
      end;
    end;
    Exit;
  end;

  if(TItemFunctions.GetEmptySlot(SelfPlayer^) = 255) then
  begin
    SelfPlayer.SendClientMessage('Seu inventário está cheio. Recompensas não serão recebidas.');
    Exit;
  end;

  if (SelfPlayer^.InDungeon) then
  begin
    MobExp := DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
      .DungeonInstanceID].Mobs[mob.Mobid].MobExp;
  end
  else
  begin
    HelperX := (Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid]
      .MobLevel-Self.Character.Level);
    case HelperX of
      -255..-8:
        begin //cinza
          MobExp := 1;
        end;
      -7..-3:
        begin //azul
          MobExp := Round(Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobExp * 0.5);
        end;

      -2..2: //amarelo
        begin
          MobExp := (Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobExp * 1);
        end;

      3..5: //laranja
        begin
          MobExp := Round(Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobExp *1.5);
        end;

      6..255: //roxo
      begin
        MobExp := Round(Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobExp * 0.2);
      end;

    else
      MobExp := (Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobExp * 1);
    end;

    if not(MobExp = 1) then
    begin
      MobExp := MobExp * 4;
    end;

   { if((Self.Character.Level+2 >= (Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid]
      .MobLevel)) and
    (Self.Character.Level+2 >= (Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid]
      .MobLevel))) then


    if (Self.Character.Level+2 >= (Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid]
      .MobLevel)) then
      MobExp := Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobExp
    else if ((Self.Character.Level+4 >= Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid]
      .MobLevel) ) then// essa aqui é a verificação dos mobs que tem nome cinza pra n dar xp
    begin
      if (((Self.Character.Level+3 >= Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid]
      .MobLevel)) or (Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobsP[mob.SecondIndex].isMutant)) then
        MobExp := Round(Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobExp *1.5)
      else
        MobExp := (Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobExp div 8);
    end
    else
    if ((Self.Character.Level >= Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid]
      .MobLevel-4) or  Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobsP[mob.SecondIndex].isMutant) then
    begin
      MobExp := (Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobExp div 3);
    end
    else
      MobExp := 1;}
  end;

  if(Self.Character <> nil) then
    if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    begin
      MobExp := MobExp + ((MobExp div 100) * Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_EXP]);
    end;

  try
    if (InParty) then
    begin // está em grupo
      if not(MobsP^.CurrentPos.InRange(Self.PlayerCharacter.LastPos, 25)) then
        Exit;
      case SelfPlayer^.Party.ExpAlocate of
        1: // igualmente
          begin
            j := 0;
            for I in SelfPlayer^.Party.Members do
            begin
              if(Self.PlayerCharacter.LastPos.Distance(
                Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.LastPos) <= DISTANCE_TO_WATCH) then
              begin
                j := j +1;
              end;
            end;

            if(j = 0) then j := 1;

            MobExp := (MobExp div j);
            if(MobExp = 0) then
              MobExp := 1;
            ExpAcquired := SelfPlayer^.AddExp(MobExp, CalcAuxRlq, EXP_TYPE_MOB);
            DroppedExp := True;
          end;
        2: // individualmente
          begin
            if (SelfPlayer^.InDungeon) then
            begin
              if (Self.ClientID = DungeonInstances[Servers[Self.ChannelId].Players
                [Self.ClientID].DungeonInstanceID].Mobs[mob.Mobid]
                .FirstPlayerAttacker) then
              begin
                ExpAcquired := Servers[Self.ChannelId].Players[Self.ClientID]
                  .AddExp(MobExp, CalcAuxRlq, EXP_TYPE_MOB);
                DroppedExp := True;
              end;
            end
            else
            begin
              if(MobsP^.FirstPlayerAttacker <> 0) then
              begin
                if (Self.ClientID = MobsP^.FirstPlayerAttacker) then
                begin
                  ExpAcquired := SelfPlayer^.AddExp(MobExp, CalcAuxRlq, EXP_TYPE_MOB);
                  DroppedExp := True;
                end;
              end
              else
              begin
                ExpAcquired := SelfPlayer^.AddExp(MobExp, CalcAuxRlq, EXP_TYPE_MOB);
                DroppedExp := True;
              end;
            end;
          end;
      end;
      if(Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].InitHP > 999999) then
      begin //MobsP
        if(Servers[mob^.ChannelId].Players[Self.ClientID].Party.InRaid) then
        begin
          for I in Servers[mob^.ChannelId].Players[Self.ClientID].Party.Members do
          begin
            Randomize;
            if(RandomRange(0, 2) = 1) then
            begin
              DroppedItem := True;
              Self.DropItemFor(@Servers[mob^.ChannelId].Players[i].Base, mob);
            end;
          end;

          for I := 1 to 3 do
          begin
            if(Servers[mob^.ChannelId].Players[Self.ClientID].Party.PartyAllied[i]=0) then
              Continue;
            for j in Servers[mob^.ChannelId].Parties[
              Servers[mob^.ChannelId].Players[Self.ClientID].Party.PartyAllied[i]].Members do
            begin
              Randomize;
              if(RandomRange(0, 2) = 1) then
              begin
                DroppedItem := True;
                Self.DropItemFor(@Servers[mob^.ChannelId].Players[j].Base, mob);
              end;
            end;
          end;
        end
        else
        begin
          for I in Servers[mob^.ChannelId].Players[Self.ClientID].Party.Members do
          begin
            Randomize;
            if(RandomRange(0, 2) = 1) then
            begin
              DroppedItem := True;
              Self.DropItemFor(@Servers[mob^.ChannelId].Players[i].Base, mob);
            end;
          end;
        end;
      end
      else
      begin
        case SelfPlayer^.Party.ItemAlocate of
          1: // em ordem
            begin
              NIndex := SelfPlayer^.Party.LastSlotItemReceived;
              if (SelfPlayer^.Party.Members.ToArray[NIndex] = Self.ClientID) then
              begin
                Inc(SelfPlayer^.Party.LastSlotItemReceived);

                DroppedItem := True;
                Self.DropItemFor(@Self, mob);
                if (NIndex >= (SelfPlayer^.Party.Members.Count - 1)) then
                  // reiniciar a ordem
                  SelfPlayer^.Party.LastSlotItemReceived := 0;
              end;

            end;
          2: // aleatorio
            begin
              if (Self.ClientID = SelfPlayer^.Party.Leader) then
              begin
                Randomize;
                RandomClientID := SelfPlayer^.Party.Members.ToArray
                  [RandomRange(0, SelfPlayer^.Party.Members.Count)];
                DroppedItem := True;
                // criar func pra entregar o item pelo client id
                Self.DropItemFor(@Servers[Self.ChannelId].Players[RandomClientID]
                  .Base, mob);
              end;
            end;
          3: // individual
            begin
              if (SelfPlayer^.InDungeon) then
              begin
                if (Self.ClientID = DungeonInstances[Servers[Self.ChannelId].Players
                  [Self.ClientID].DungeonInstanceID].Mobs[mob.Mobid]
                  .FirstPlayerAttacker) then
                begin
                  // criar func pra entregar o item pelo client id
                  Self.DropItemFor(@Self, mob);
                  DroppedItem := True;
                end;
              end
              else
              begin
                //if(MobsP^.FirstPlayerAttacker <> 0) then
               // begin
               //   if (Self.ClientID = MobsP^.FirstPlayerAttacker) then
              //    begin
                //    // criar func pra entregar o item pelo client id
               //     Self.DropItemFor(@Self, mob);
               //     DroppedItem := True;
               //   end;
              //  end
               // else
              //  begin
                if(Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobsP[
                  mob.SecondIndex].FirstPlayerAttacker > 0) then
                begin
                  if(Servers[Self.ChannelId].Players[Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobsP[
                  mob.SecondIndex].FirstPlayerAttacker].Status >= Playing) then
                  begin
                    if not(Servers[Self.ChannelId].Players[Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobsP[
                      mob.SecondIndex].FirstPlayerAttacker].SocketClosed) then
                    begin
                      Self.DropItemFor(@Self, mob);
                      DroppedItem := True;
                    end;
                  end;
                end;
              //  end;
              end;
            end;
          4: // lider
            begin
              if (Self.ClientID = SelfPlayer^.Party.Leader) then
              begin
                // criar func pra entregar o item pelo client id
                Self.DropItemFor(@Self, mob);
                DroppedItem := True;
              end;
            end;
        end;
      end;
    end
    else // não está em grupo
    begin
      ExpAcquired := SelfPlayer^.AddExp(MobExp, CalcAuxRlq, EXP_TYPE_MOB);
      Self.DropItemFor(@Self, mob);
      // criar func pra entregar o item pelo client id
    end;
  except
    Logger.Write('erro na entrega em grupo de xp / solo', TLogTYpe.Error);
  end;
  try
    if not(ExpAcquired = 0) then
    begin
      try
        case SelfPlayer^.SpawnedPran of
          0:
            begin
              case SelfPlayer^.Account.Header.Pran1.Level of
                0 .. 3: // pran fada
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran1.Exp) >
                      PranExpList[5]) then
                    begin
                      SelfPlayer^.Account.Header.Pran1.Exp := PranExpList[4];
                      for i := SelfPlayer^.Account.Header.Pran1.Level to 3 do
                      begin
                        SelfPlayer^.AddPranLevel(0);
                      end;
                    end
                    else
                      SelfPlayer^.AddPranExp(0, PranExpAcquired);
                    //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                      //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
                4: // pran fada ~ pran criança
                  begin
                    case SelfPlayer^.Account.Header.Pran1.ClassPran of
                      61, 71, 81:
                        begin
                          SelfPlayer^.SendClientMessage
                            ('A sua pran precisa evoluir para ganhar exp.', 0, 1);
                          PranExpAcquired := 0;
                        end;
                    else
                      begin
                        PranExpAcquired := (ExpAcquired div 3);
                        SelfPlayer^.AddPranExp(0, PranExpAcquired);
                        //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                          //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                      end;
                    end;
                  end;
                5 .. 18: // pran criança
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran1.Exp) >
                      PranExpList[20]) then
                    begin
                      SelfPlayer^.Account.Header.Pran1.Exp := PranExpList[19];
                      for i := SelfPlayer^.Account.Header.Pran1.Level to 18 do
                      begin
                        SelfPlayer^.AddPranLevel(0);
                      end;
                    end
                    else
                      SelfPlayer^.AddPranExp(0, PranExpAcquired);
                    //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                      //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
                19: // pran criança ~ pran adolescente
                  begin
                    case SelfPlayer^.Account.Header.Pran1.ClassPran of
                      62, 72, 82:
                        begin
                          SelfPlayer^.SendClientMessage
                            ('A sua pran precisa evoluir para ganhar exp.', 0, 1);
                          PranExpAcquired := 0;
                        end;
                    else
                      begin
                        PranExpAcquired := (ExpAcquired div 3);
                        SelfPlayer^.AddPranExp(0, PranExpAcquired);
                        //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                          //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                      end;
                    end;
                  end;
                20 .. 48: // pran adolescente
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran1.Exp) >
                      PranExpList[50]) then
                    begin
                      SelfPlayer^.Account.Header.Pran1.Exp := PranExpList[49];
                      for i := SelfPlayer^.Account.Header.Pran1.Level to 48 do
                      begin
                        SelfPlayer^.AddPranLevel(0);
                      end;
                    end
                    else
                      SelfPlayer^.AddPranExp(0, PranExpAcquired);
                    //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                      //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
                49:
                  begin // pran adolescente ~ pran adulta
                    case SelfPlayer^.Account.Header.Pran1.ClassPran of
                      63, 73, 83:
                        begin
                          SelfPlayer^.SendClientMessage
                            ('A sua pran precisa evoluir para ganhar exp.', 0, 1);
                          PranExpAcquired := 0;
                        end;
                    else
                      begin
                        PranExpAcquired := (ExpAcquired div 3);
                        SelfPlayer^.AddPranExp(0, PranExpAcquired);
                        //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                          //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                      end;
                    end;
                  end;
                50 .. 69: // pran adulta
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    SelfPlayer^.AddPranExp(0, PranExpAcquired);
                    //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                      //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
              end;
            end;
          1:
            begin
              case SelfPlayer^.Account.Header.Pran2.Level of
                0 .. 3: // pran fada
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran2.Exp) >
                      PranExpList[5]) then
                    begin
                      SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[4];
                      for i := SelfPlayer^.Account.Header.Pran2.Level to 3 do
                      begin
                        SelfPlayer^.AddPranLevel(1);
                      end;
                    end
                    else
                      SelfPlayer^.AddPranExp(1, PranExpAcquired);
                    //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                      //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
                4: // pran fada ~ pran criança
                  begin
                    case SelfPlayer^.Account.Header.Pran2.ClassPran of
                      61, 71, 81:
                        begin
                          SelfPlayer^.SendClientMessage
                            ('A sua pran precisa evoluir para ganhar exp.', 0, 1);
                          PranExpAcquired := 0;
                        end;
                    else
                      begin
                        PranExpAcquired := (ExpAcquired div 3);
                        SelfPlayer^.AddPranExp(1, PranExpAcquired);
                        //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                          //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                      end;
                    end;
                  end;
                5 .. 18: // pran criança
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran2.Exp) >
                      PranExpList[20]) then
                    begin
                      SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[19];
                      for i := SelfPlayer^.Account.Header.Pran2.Level to 18 do
                      begin
                        SelfPlayer^.AddPranLevel(1);
                      end;
                    end
                    else
                      SelfPlayer^.AddPranExp(1, PranExpAcquired);
                    //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                      //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
                19: // pran criança ~ pran adolescente
                  begin
                    case SelfPlayer^.Account.Header.Pran2.ClassPran of
                      62, 72, 82:
                        begin
                          SelfPlayer^.SendClientMessage
                            ('A sua pran precisa evoluir para ganhar exp.', 0, 1);
                        end;
                    else
                      begin
                        PranExpAcquired := (ExpAcquired div 3);
                        SelfPlayer^.AddPranExp(1, PranExpAcquired);
                        //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                          //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                      end;
                    end;
                  end;
                20 .. 48: // pran adolescente
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran2.Exp) >
                      PranExpList[50]) then
                    begin
                      SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[49];
                      for i := SelfPlayer^.Account.Header.Pran2.Level to 48 do
                      begin
                        SelfPlayer^.AddPranLevel(1);
                      end;
                    end
                    else
                      SelfPlayer^.AddPranExp(1, PranExpAcquired);
                    //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                      //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
                49:
                  begin // pran adolescente ~ pran adulta
                    case SelfPlayer^.Account.Header.Pran2.ClassPran of
                      63, 73, 83:
                        begin
                          SelfPlayer^.SendClientMessage
                            ('A sua pran precisa evoluir para ganhar exp.', 0, 1);
                          PranExpAcquired := 0;
                        end;
                    else
                      begin
                        PranExpAcquired := (ExpAcquired div 3);
                        SelfPlayer^.AddPranExp(1, PranExpAcquired);
                        //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                          //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                      end;
                    end;
                  end;
                50 .. 69: // pran adulta
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    SelfPlayer^.AddPranExp(1, PranExpAcquired);
                    //SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                      //AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
              end;
            end;
        end;
      except
        Logger.Write('erro no bghls das prans quando mata', TLogTYpe.Error);
      end;

      if(Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_EXP] > 0) then
      begin
        CalcAux := (Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_EXP] * (CalcAuxRlq div 100));
        if(SelfPlayer^.SpawnedPran <> 255) then
          SelfPlayer^.SendClientMessage('Adquiriu ' + AnsiString(IntToStr(ExpAcquired-CalcAux)
            ) + ' exp + ' + AnsiString(IntToStr(CalcAux)) + ', Pran ' + AnsiString(IntToStr(PranExpAcquired)) + '.', 0)
        else
          SelfPlayer^.SendClientMessage('Adquiriu ' + AnsiString(IntToStr(ExpAcquired-CalcAux)
            ) + ' exp + ' + AnsiString(IntToStr(CalcAux)) + '.', 0);
      end
      else
      begin
        if(SelfPlayer^.SpawnedPran <> 255) then
          SelfPlayer^.SendClientMessage('Adquiriu ' + AnsiString(IntToStr(ExpAcquired)
            ) + ' exp, Pran ' + AnsiString(IntToStr(PranExpAcquired)) + '.', 0)
        else
          SelfPlayer^.SendClientMessage('Adquiriu ' + AnsiString(IntToStr(ExpAcquired)
            ) + ' exp.', 0);
      end;
    end;
  except
    Logger.Write('erro na msg de xp', TLogTYpe.Error);
  end;

  try
    for i := 0 to 49 do
    begin
      if (SelfPlayer^.PlayerQuests[i].id > 0) then
      begin // se existir quest no jogador
        if not(SelfPlayer^.PlayerQuests[i].IsDone) then
        begin // se a quest ainda não foi entregue
          for j := 0 to 4 do
          begin // checa cada requiriment de mob
            if (SelfPlayer^.PlayerQuests[i].Quest.RequirimentsType[j] = 1) then
            // se o requiriment checado for de mob kill
            begin
              if (SelfPlayer^.PlayerQuests[i].Quest.Requiriments[j] = Servers
                [mob^.ChannelId].Mobs.TMobS[mob^.Mobid].IntName) then
              // se o mob morto for o mesmo da quest
              begin
                Inc(SelfPlayer^.PlayerQuests[i].Complete[j]);
                if (SelfPlayer^.PlayerQuests[i].Complete[j] >=
                  SelfPlayer^.PlayerQuests[i].Quest.RequirimentsAmount[j]) then
                begin
                  SelfPlayer^.PlayerQuests[i].Complete[j] :=
                    SelfPlayer^.PlayerQuests[i].Quest.RequirimentsAmount[j];
                  SelfPlayer^.SendClientMessage('Você completou a quest [' +
                    AnsiString(Quests[SelfPlayer^.PlayerQuests[i].Quest.QuestID]
                    .Titulo) + ']');
                  // aqui vai o aviso de quest completa
                end;
                SelfPlayer^.UpdateQuest(SelfPlayer^.PlayerQuests[i].id);
              end;
            end;
          end;
        end;
      end;
    end;
  except
    Logger.Write('erro na contagem da quest pra atualizar', TLogTYpe.Error);
  end;
end;
procedure TBaseMob.DropItemFor(PlayerBase: PBaseMob; mob: PBaseMob);
var
  DropTax: Integer;
  ReceiveFrom: Integer;
  ItemTypeFrom: Integer;
  ItemTax: Integer;
  MaxLen: Integer;
  RandomItem, Helper: Integer;
  ItemID, cnt, i, j, k: Integer;
  OtherPlayer: PPlayer;
  MobT: PMobSa;
label
  ReCase,
  ReCase1;
begin
  if(Servers[mob.ChannelId].Mobs.TMobS[mob.Mobid].MobsP[mob.SecondIndex].isGuard) then
    Exit;   //patch dropando item em guarda
  Randomize;
  ItemTypeFrom := DROP_NORMAL_ITEM; // pre select
  ItemID := 0;
  MaxLen := 0;
  ReceiveFrom := 0;
  DropTax := RandomRange(1, 101);
  OtherPlayer := @Servers[PlayerBase.ChannelId].Players[PlayerBase.ClientID];
  MobT := @Servers[mob.ChannelId].Mobs.TMobS[mob.Mobid];
  {if (OtherPlayer^.InDungeon) then
  begin
    if (DropTax > 50) then
    begin
      cnt := 0;
      for i := 0 to 41 do
      begin
        if (DungeonInstances[Servers[PlayerBase.ChannelId].Players
          [PlayerBase.ClientID].DungeonInstanceID].MobsDrop[mob.Mobid].Drops
          [i] > 0) then
        begin
          Inc(cnt);
        end
        else
          break;
      end;
      if (cnt = 0) then
        cnt := 1
      else
      begin
        Randomize;
        ItemTax := RandomRange(1, cnt); // if gives nah item then puts it -1
      end;
      RandomItem := DungeonInstances[Servers[PlayerBase.ChannelId].Players
        [PlayerBase.ClientID].DungeonInstanceID].MobsDrop[mob.Mobid]
        .Drops[ItemTax];
      if (TItemFunctions.GetItemEquipSlot(RandomItem) = 0) then
        TItemFunctions.PutItem(Servers[PlayerBase.ChannelId].Players
          [PlayerBase.ClientID], RandomItem, 1)
      else
        TItemFunctions.PutEquipament(Servers[PlayerBase.ChannelId].Players
          [PlayerBase.ClientID], RandomItem);
    end;
    Exit;
  end;   }

  if(Self.Character <> nil) then
  begin
    if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    begin
      Inc(DropTax, Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_DROP_RATE] *
        (DropTax div 100));
    end;

    if(Self.GetMobAbility(EF_PARTY_PER_DROP_RATE) > 0) then
      Inc(DropTax, (Self.GetMobAbility(EF_PARTY_PER_DROP_RATE) div 2));

    Inc(Self.DroppedCount);

    if(DroppedCount >= 4) then
    begin
      Inc(DropTax, 50);
      DroppedCount := 0;
    end;
  end;

  if (DropTax > 70) then
  begin // a taxa de drop padrao é 50, Rlk_eff + olho de gato_eff + DropTax
    {case MobT^.MobLevel of
      0 .. 20:
        begin
          ReceiveFrom := MONSTERS_0_20;
        end;
      21 .. 40:
        begin
          ReceiveFrom := MONSTERS_21_40;
        end;
      41 .. 60:
        begin
          ReceiveFrom := MONSTERS_41_60;
          case MobT^.IntName of
            1373: // plantas
              begin
                ReceiveFrom := MONSTERS_PLANTA;
              end;
            1374: // croshu azul
              begin
                ReceiveFrom := MONSTERS_CROSHU_AZUL;
              end;
            1375: // butos
              begin
                ReceiveFrom := MONSTERS_BUTO;
              end;
            1376: // croshu verm
              begin
                ReceiveFrom := MONSTERS_CROSHU_VERM;
              end;
          end;
        end;
      61 .. 80:
        begin
          ReceiveFrom := MONSTERS_61_80;
          case MobT^.IntName of
            1377: // penzas
              begin
                ReceiveFrom := MONSTERS_PENZA;
              end;
            1378: // verits
              begin
                ReceiveFrom := MONSTERS_VERIT;
              end;
          end;
        end;
      81 .. 255:
        begin
          ReceiveFrom := MONSTERS_81_99;
        end;

      256..65535:
        begin
          case MobT^.IntName of
            1373: // plantas
              begin
                MobT^.DropIndex := MONSTERS_PLANTA;
              end;
            1374: // croshu azul
              begin
                MobT^.DropIndex := MONSTERS_CROSHU_AZUL;
              end;
            1375: // butos
              begin
                MobT^.DropIndex := MONSTERS_BUTO;
              end;
            1376: // croshu verm
              begin
                MobT^.DropIndex := MONSTERS_CROSHU_VERM;
              end;
            1377: // penzas
              begin
                MobT^.DropIndex := MONSTERS_PENZA;
              end;
            1378: // verits
              begin
                MobT^.DropIndex := MONSTERS_VERIT;
              end;
          end;
        end;
    end;}

    Randomize;
    ItemTax := RandomRange(1, 101);

    if(Self.Character <> nil) then
      if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
      begin
        decint(ItemTax, Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_DROP_RATE]);
      end;
    if(ItemTax = 0) then ItemTax := 2;
    case ItemTax of
      1:
        begin
          ItemTypeFrom := DROP_LEGENDARY_ITEM;
          //MaxLen := High(Drops[MobT^.DropIndex].LegendaryItems);
        end;
      2 .. 13:
        begin
          ItemTypeFrom := DROP_RARE_ITEM;
          //MaxLen := High(Drops[MobT^.DropIndex].RareItems);
        end;
      14 .. 33:
        begin
          ItemTypeFrom := DROP_SUPERIOR_ITEM;
          //MaxLen := High(Drops[MobT^.DropIndex].SuperiorItems);
        end;
      34 .. 255:
        begin
          ItemTypeFrom := DROP_NORMAL_ITEM;
          //MaxLen := High(Drops[MobT^.DropIndex].NormalItems);
        end;
    end;
    {if (MaxLen = 0) then
    begin
      ItemTypeFrom := DROP_NORMAL_ITEM;
      MaxLen := High(Drops[MobT^.DropIndex].NormalItems);
    end; }

    if(Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].InitHP > 999999) then
    begin
      ReCase:
        case ItemTypeFrom of
          DROP_NORMAL_ITEM:
          begin
            if(Length(Drops[MobT^.DropIndex].NormalItems) = 0) then
            begin
              ItemTypeFrom := ItemTypeFrom +1;
              goto ReCase;
            end;
            Randomize;
            MaxLen := High(Drops[MobT^.DropIndex].NormalItems);
            RandomItem := RandomRange(0, MaxLen+1);
            ItemID := Drops[MobT^.DropIndex].NormalItems[RandomItem];
          end;
          DROP_SUPERIOR_ITEM:
          begin
            if(Length(Drops[MobT^.DropIndex].SuperiorItems) = 0) then
            begin
              ItemTypeFrom := ItemTypeFrom +1;
              goto ReCase;
            end;
            Randomize;
            MaxLen := High(Drops[MobT^.DropIndex].SuperiorItems);
            RandomItem := RandomRange(0, MaxLen+1);
            ItemID := Drops[MobT^.DropIndex].SuperiorItems[RandomItem];
          end;
          DROP_RARE_ITEM:
          begin
            if(Length(Drops[MobT^.DropIndex].RareItems) = 0) then
            begin
              ItemTypeFrom := ItemTypeFrom +1;
              goto ReCase;
            end;
            Randomize;
            MaxLen := High(Drops[MobT^.DropIndex].RareItems);
            RandomItem := RandomRange(0, MaxLen+1);
            ItemID := Drops[MobT^.DropIndex].RareItems[RandomItem];
          end;
          DROP_LEGENDARY_ITEM:
          begin
            if(Length(Drops[MobT^.DropIndex].LegendaryItems) = 0) then
            begin
              ItemTypeFrom := 1;
              goto ReCase;
            end;
            Randomize;
            MaxLen := High(Drops[MobT^.DropIndex].LegendaryItems);
            RandomItem := RandomRange(0, MaxLen+1);
            ItemID := Drops[MobT^.DropIndex].LegendaryItems[RandomItem];
          end;
        end;
    end
    else
    begin
      ReCase1:
        case ItemTypeFrom of
          DROP_NORMAL_ITEM:
          begin
            if(Length(Drops[MobT^.DropIndex].NormalItems) = 0) then
            begin
              ItemTypeFrom := ItemTypeFrom +1;
              goto ReCase1;
            end;
            Randomize;
            MaxLen := High(Drops[MobT^.DropIndex].NormalItems);
            RandomItem := RandomRange(0, MaxLen+1);
            ItemID := Drops[MobT^.DropIndex].NormalItems[RandomItem];
          end;
          DROP_SUPERIOR_ITEM:
          begin
            if(Length(Drops[MobT^.DropIndex].SuperiorItems) = 0) then
            begin
              ItemTypeFrom := ItemTypeFrom +1;
              goto ReCase1;
            end;
            Randomize;
            MaxLen := High(Drops[MobT^.DropIndex].SuperiorItems);
            RandomItem := RandomRange(0, MaxLen+1);
            ItemID := Drops[MobT^.DropIndex].SuperiorItems[RandomItem];
          end;
          DROP_RARE_ITEM:
          begin
            if(Length(Drops[MobT^.DropIndex].RareItems) = 0) then
            begin
              ItemTypeFrom := ItemTypeFrom +1;
              goto ReCase1;
            end;
            Randomize;
            MaxLen := High(Drops[MobT^.DropIndex].RareItems);
            RandomItem := RandomRange(0, MaxLen+1);
            ItemID := Drops[MobT^.DropIndex].RareItems[RandomItem];
          end;
          DROP_LEGENDARY_ITEM:
          begin
            if(Length(Drops[MobT^.DropIndex].LegendaryItems) = 0) then
            begin
              ItemTypeFrom := 1;
              Exit;
            end;
            Randomize;
            MaxLen := High(Drops[MobT^.DropIndex].LegendaryItems);
            RandomItem := RandomRange(0, MaxLen+1);
            ItemID := Drops[MobT^.DropIndex].LegendaryItems[RandomItem];
          end;
        end;
    end;

    if(ItemList[ItemID].ItemType = 713) then
    begin
      for k := Low(Servers) to High(Servers) do
      begin
        for i := 0 to 4 do
        begin
          for j := 0 to 4 do
          begin
            if (Servers[k].Devires[i].Slots[j].ItemID <> 0) then
            begin
              if(ItemList[Servers[k].Devires[i].Slots[j].ItemID].UseEffect =
                ItemList[ItemID].UseEffect) then
                Exit;
            end;
          end;
        end;

        for I := Low(Servers[k].OBJ) to High(Servers[k].OBJ) do
        begin
          if(Servers[k].OBJ[i].ContentItemID = 0) then
            Continue;

          if(ItemList[Servers[k].OBJ[i].ContentItemID].UseEffect =
            ItemList[ItemID].UseEffect) then
            Exit;
        end;

        for I := Low(Servers[k].Players) to High(Servers[k].Players) do
        begin
          if not(Servers[k].Players[i].Status >= Playing) then
            Continue;

          for j := 0 to 59 do
          begin
            if(Servers[k].Players[i].Base.Character.Inventory[j].Index = 0) then
              Continue;

            if(Servers[k].Players[i].Base.Character.Inventory[j].Index = ItemID) then
            begin
              Exit;
            end;

            if(ItemList[Servers[k].Players[i].Base.Character.Inventory[j].Index].ItemType
              = 40) then
            begin
              if(ItemList[Servers[k].Players[i].Base.character.Inventory[j].Index].UseEffect =
                ItemList[ItemID].UseEffect) then
              Exit;
            end;
          end;


          {Helper := TItemFunctions.GetItemSlotByItemType(Servers[k].Players[i],
            40, INV_TYPE, 0);
          if(Helper <> 255) then
          begin
            if(ItemList[Servers[k].Players[i].Base.character.Inventory[Helper].Index].UseEffect =
            ItemList[ItemID].UseEffect) then
              Exit;
          end;}
        end;
      end;

      Servers[Self.ChannelId].SendServerMsg('Jogador <' +
        Self.Character.Name + '> encontrou o [' +
        ItemList[ItemID].Name+'].', 32, 0, 16);
    end;

    if (TItemFunctions.GetItemEquipSlot(ItemID) = 0) then
      TItemFunctions.PutItem(OtherPlayer^, ItemID, 1)
    else
      TItemFunctions.PutEquipament(OtherPlayer^, ItemID);
  end;
end;
procedure TBaseMob.PlayerKilled(mob: PBaseMob; xRlkSlot: Byte = 0);
var
  i, j, k: Integer;
  Party: PParty;
  Honor: Integer;
  GuildPlayer: PPlayer;
  RandomTax: Integer;
  RlkSlot: Byte;
  Item: PItem;
  TitleGoaled: Boolean;
begin
  if(xRlkSlot = 0) then
    RlkSlot := TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players[mob^.ClientID],
      40, INV_TYPE, 0)
  else
    RlkSlot := xRlkSlot;

  if(RlkSlot <> 255) then
  begin
    Item := @mob^.Character.Inventory[RlkSlot];
    Servers[Self.ChannelId].CreateMapObject(@Servers[Self.ChannelId].Players[Self.ClientID],
      320, Item.Index);
    {Servers[Self.ChannelId].SendServerMsg('O jogador ' +
      AnsiString(mob^.Character.Name) + ' dropou a relíquia <' +
      AnsiString(ItemList[Item.Index].Name) + '>.');}
    ZeroMemory(Item, sizeof(TItem));
    mob.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, False);
    RlkSlot := TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players[mob^.ClientID],
      40, INV_TYPE, 0);
    if(RlkSlot <> 255) then
    begin
      Self.PlayerKilled(mob, RlkSlot); //loopzin pra dropar todas as relíquias que tiver
      Exit;
    end;
    Servers[Self.ChannelId].Players[mob^.ClientID].SendEffect(0);
  end;

  if (mob^.BuffExistsByIndex(126)) then
  begin // efeito duradouro
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Alvo está sob Efeito Duradouro. Impossível receber PvP/Honra.');
    Exit;
  end
  else
  begin
    if not(mob.InClastleVerus) then
      mob^.AddBuff(6471);
  end;

  if(Self.BuffExistsByIndex(126)) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Você está sob Efeito Duradouro. Impossível receber PvP/Honra.');
    Exit;
  end;

  if(mob.Character.Level < 25) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Você só pode receber PvP de alvos acima do Nv 25.');
    Exit;
  end;

  if(Self.Character.Level < 25) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Você só pode receber PvP de alvos acima do Nv 25.');
    Exit;
  end;

  if (Servers[Self.ChannelId].Players[Self.ClientID].PartyIndex <> 0) then
  begin
    Party := Servers[Self.ChannelId].Players[Self.ClientID].Party;
    for i in Party.Members do
    begin
      if not(i = Self.ClientID) then
      begin
        if not(Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.LastPos.InRange(
          Self.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)) then
          Continue;
      end;

      Inc(Servers[Self.ChannelId].Players[i].Base.Character.CurrentScore.
        KillPoint, 1);
      Servers[Self.ChannelId].Players[i].SendClientMessage
        ('Seus pontos de PvP foram incrementados.');
      Honor := HONOR_PER_KILL;
      Inc(Servers[Self.ChannelId].Players[i].Base.Character.CurrentScore.
        Honor, Honor);
      Servers[Self.ChannelId].Players[i].SendClientMessage
        ('Adquiriu ' + AnsiString(Honor.ToString) + ' pontos de honra.');
      Servers[Self.ChannelId].Players[i].Base.SendRefreshKills();
      //RandomTax := Random(100);
      //if (RandomTax <= PVP_ITEM_DROP_TAX) then
      //begin
        /// pra dropar caveira e tals
      TItemFunctions.PutItem(Servers[Self.ChannelId].Players[i], 11285,
        SKULL_MULTIPLIER);
        //TItemFunctions.PutItem(Servers[Self.ChannelId].Players[i], 5768, 1);
        //TItemFunctions.PutItem(Servers[Self.ChannelId].Players[i], 15958, 1);
     // end;

      TitleGoaled := False;

      for j := 0 to 95 do
      begin
        if(Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.Titles[j].Index = 0) then
          Continue;

        if(Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.Titles[j].Index = 27) then
        begin
          Inc(Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.Titles[j].Progress, 1);

          if(Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.Titles[j].Progress >=
          Titles[27].TitleLevel[Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.Titles[j].Level].TitleGoal) then
          begin
            Servers[Self.ChannelId].Players[i].UpdateTitleLevel(27, Servers[Self.ChannelId].Players[Self.ClientID].Base.PlayerCharacter.Titles[j].Level+1,
              True);
            Servers[Self.ChannelId].Players[i].SendClientMessage('Seu título ['+
              Titles[27].TitleLevel[Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.Titles[j].Level].TitleName +
              '] foi atualizado.');
          end
          else
            Servers[Self.ChannelId].Players[i].UpdateTitleLevel(27, Servers[Self.ChannelId].Players[Self.ClientID].Base.PlayerCharacter.Titles[j].Level,
              False);

          TitleGoaled := True;
          break;
        end;
      end;

      if not(TitleGoaled) then
      begin
        Servers[Self.ChannelId].Players[i].AddTitle(27, 0, False);
      end;

      {if (Servers[Self.ChannelId].Players[i].Character.Base.GuildIndex > 0) then
      begin
        //Inc(Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot]
          //.Exp, Honor);
        for j := 0 to 127 do
        begin
          if (Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot]
            .Members[j].Logged) then
          begin
<<<<<<< HEAD
            Inc(Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot].Level);
            GuildLeveled := true;
          end;
          Inc(Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot].Exp, Honor);
          //Servers[Self.ChannelId].Players[i].SendClientMessage('Pontos de experiência da legião foram incrementados em '+
            //Honor.ToString + ' pontos.');
          for j := 0 to 127 do
          begin
            if (Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot]
              .Members[j].Logged) then
=======
            for k := Low(Servers) to High(Servers) do
>>>>>>> parent of a46c38b (30)
            begin
              if (Servers[k].GetPlayerByCharIndex
                (Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot]
                .Members[j].CharIndex, GuildPlayer)) then
              begin
                if (GuildPlayer.Status >= Playing) then
                begin
                  Servers[k].Players[GuildPlayer.Base.ClientID].SendGuildInfo;
                end;
                break;
              end;
            end;
          end;
        end;
      end;  }
    end;
  end
  else
  begin
    Inc(Servers[Self.ChannelId].Players[Self.ClientID]
      .Base.Character.CurrentScore.KillPoint, 1);
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Seus pontos de PvP foram incrementados.');
    Inc(Servers[Self.ChannelId].Players[Self.ClientID]
      .Base.Character.CurrentScore.Honor, HONOR_PER_KILL);
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Adquiriu ' + AnsiString(IntToStr(HONOR_PER_KILL)) + ' pontos de honra.');
    Servers[Self.ChannelId].Players[Self.ClientID].Base.SendRefreshKills();
    //RandomTax := Random(100);
    //if (RandomTax <= PVP_ITEM_DROP_TAX) then
    //begin
      /// pra dropar caveira e tals
    TItemFunctions.PutItem(Servers[Self.ChannelId].Players[Self.ClientID],
      11285, SKULL_MULTIPLIER);
      //TItemFunctions.PutItem(Servers[Self.ChannelId].Players
        //[Self.ClientID], 5768, 1);
      //TItemFunctions.PutItem(Servers[Self.ChannelId].Players[Self.ClientID],
        //15958, 1);
   // end;

    TitleGoaled := False;

    for j := 0 to 95 do
    begin
      if(Servers[Self.ChannelId].Players[Self.ClientID].Base.PlayerCharacter.Titles[j].Index = 0) then
        Continue;

      if(Servers[Self.ChannelId].Players[Self.ClientID].Base.PlayerCharacter.Titles[j].Index = 27) then
      begin
        Inc(Servers[Self.ChannelId].Players[Self.ClientID].Base.PlayerCharacter.Titles[j].Progress, 1);

        if(Servers[Self.ChannelId].Players[Self.ClientID].Base.PlayerCharacter.Titles[j].Progress >=
        Titles[27].TitleLevel[Servers[Self.ChannelId].Players[Self.ClientID].Base.PlayerCharacter.Titles[j].Level].TitleGoal) then
        begin
            Servers[Self.ChannelId].Players[Self.ClientID].UpdateTitleLevel(27, Servers[Self.ChannelId].Players[Self.ClientID].Base.PlayerCharacter.Titles[j].Level+1,
              True);
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Seu título ['+
              Titles[27].TitleLevel[Servers[Self.ChannelId].Players[Self.ClientID].Base.PlayerCharacter.Titles[j].Level].TitleName +
              '] foi atualizado.');
        end
        else
          Servers[Self.ChannelId].Players[Self.ClientID].UpdateTitleLevel(27, Servers[Self.ChannelId].Players[Self.ClientID].Base.PlayerCharacter.Titles[j].Level,
            False);

        TitleGoaled := True;
        break;
      end;
    end;

    if not(TitleGoaled) then
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].AddTitle(27, 0, False);
    end;
    {if (Servers[Self.ChannelId].Players[Self.ClientID]
      .Character.Base.GuildIndex > 0) then
    begin
      Inc(Guilds[Servers[Self.ChannelId].Players[Self.ClientID]
        .Character.GuildSlot].Exp, HONOR_PER_KILL);
      for j := 0 to 127 do
      begin
        if (Guilds[Servers[Self.ChannelId].Players[Self.ClientID]
          .Character.GuildSlot].Members[j].Logged) then
        begin
<<<<<<< HEAD
          Inc(Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot].Level);
          GuildLeveled := true;
        end;
        Inc(Guilds[Servers[Self.ChannelId].Players[Self.ClientID]
          .Character.GuildSlot].Exp, HONOR_PER_KILL);
        //Servers[Self.ChannelId].Players[i].SendClientMessage('Pontos de experiência da legião foram incrementados em '+
          //Honor.ToString + ' pontos.');
        for j := 0 to 127 do
        begin
          if (Guilds[Servers[Self.ChannelId].Players[Self.ClientID]
            .Character.GuildSlot].Members[j].Logged) then
=======
          for k := Low(Servers) to High(Servers) do
>>>>>>> parent of a46c38b (30)
          begin
            if (Servers[k].GetPlayerByCharIndex
              (Guilds[Servers[Self.ChannelId].Players[Self.ClientID]
              .Character.GuildSlot].Members[j].CharIndex, GuildPlayer)) then
            begin
              if (GuildPlayer.Status >= Playing) then
              begin
                Servers[k].Players[GuildPlayer.Base.ClientID].SendGuildInfo;
              end;
              break;
            end;
          end;
        end;
      end;
    end;}
  end;
end;
procedure TBaseMob.SelfBuffSkill(Skill, Anim: DWORD; mob: PBaseMob;
  Pos: TPosition);
var
  h1, h2: Integer;
  Item: PItem;
  RlkSlot: Byte;
begin
  if not((SkillData[Skill].Classe >= 61) and
    (SkillData[Skill].Classe <= 84)) then
  begin
    if ((Self.BuffExistsByIndex(53)) or (Self.BuffExistsByIndex(77))) then
    begin
      Self.RemoveBuffByIndex(53);
      Self.RemoveBuffByIndex(77);
    end;
  end;
  case SkillData[Skill].Index of
    124, 127, 137, 160:
      begin
        Self.AddBuff(Skill, True, True,
          (Self.GetMobAbility(EF_SKILL_ATIME6) * 60));
      end;
    32:
      begin
        Self.DefesaPoints := 3;
        Self.AddBuff(Skill);
      end;
    36:
      begin
        Self.BolhaPoints := SkillData[Skill].EFV[0];
        Self.AddBuff(Skill);
      end;
    42:
      begin
        Self.HPRListener := True;
        Self.HPRAction := 2;
        Self.HPRSkillID := Skill;
        Self.HPRSkillEtc1 := (SkillData[Skill].EFV[2] div 2);
        Self.AddBuff(Skill);
      end;
    53: //inv atirador
      begin
        while (TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players[Self.ClientID], 40, INV_TYPE, 0) <> 255) do
        begin
          RlkSlot := TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players[Self.ClientID], 40, INV_TYPE, 0);
          if(RlkSlot <> 255) then
          begin
            Item := @Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory[RlkSlot];
            Servers[Self.ChannelId].CreateMapObject(@Self, 320, Item.Index);
            {Servers[Self.ChannelId].SendServerMsg('O jogador ' +
              AnsiString(Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Name) + ' dropou a relíquia <' +
              AnsiString(ItemList[Item.Index].Name) + '>.');}
            ZeroMemory(Item, sizeof(TItem));
            Servers[Self.ChannelId].Players[Self.ClientID].Base.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, False);
          end;
        end;
        Self.AddBuff(Skill);
      end;
    72: // teleport
      begin
        if(TItemFunctions.GetItemReliquareSlot(Servers[Self.ChannelId].Players[Self.ClientID]) <> 255) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Impossível usar com relíquia.');
          Exit;
        end;

        if(Self.InClastleVerus) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Impossível usar em guerra. Use o teleporte.');
          Exit;
        end;
        if(Self.Character.Nation > 0) then
        begin
          if(Self.Character.Nation <> Servers[Self.ChannelId].NationID) then
          begin
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Impossível usar em outros países.');
            Exit;
          end;
        end;

        Servers[Self.ChannelId].Players[Self.ClientID]
          .Teleport(TPosition.Create(3450, 690));
      end;
    77: //inv dual
      begin
        while (TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players[Self.ClientID], 40, INV_TYPE, 0) <> 255) do
        begin
          RlkSlot := TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players[Self.ClientID], 40, INV_TYPE, 0);
          if(RlkSlot <> 255) then
          begin
            Item := @Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Inventory[RlkSlot];
            Servers[Self.ChannelId].CreateMapObject(@Self, 320, Item.Index);
            {Servers[Self.ChannelId].SendServerMsg('O jogador ' +
              AnsiString(Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Name) + ' dropou a relíquia <' +
              AnsiString(ItemList[Item.Index].Name) + '>.'); }
            ZeroMemory(Item, sizeof(TItem));
            Servers[Self.ChannelId].Players[Self.ClientID].Base.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, False);
          end;
        end;
        Self.AddBuff(Skill);
      end;
    120:
      begin
        Self.HPRListener := True;
        Self.HPRAction := 1;
        Self.HPRSkillID := Skill;
        Self.AddBuff(Skill);
      end;
    150:
      begin
        Self.LaminaPoints := SkillData[Skill].EFV[0];
        Self.LaminaID := Skill;
        Self.EventListener := True;
        Self.EventAction := 1;
        Self.AddBuff(Skill);
      end;
    201: // fluxo de mana
      begin
        h1 := (Self.Character.CurrentScore.MaxMP div 2);
        Randomize;
        case Self.PlayerCharacter.Base.CurrentScore.Int of
          0 .. 20:
            begin
              h2 := Random(10);
            end;
          21 .. 40:
            begin
              h2 := Random(20);
            end;
          41 .. 60:
            begin
              h2 := Random(30);
            end;
          61 .. 80:
            begin
              h2 := Random(40);
            end;
          81 .. 65535:
            begin
              h2 := Random(50);
            end;
        end;
        Self.AddMP(h1 + ((Self.Character.CurrentScore.MaxMP div 100) *
          h2), True);
      end;
    208: // faz parte dos efeitos 5, essa aq pode ser recupercao de hp ou mp
      begin
        if (SkillData[Skill].Damage = 200) then
        begin // recupera mp
          Self.AddMP(((Self.Character.CurrentScore.MaxMP div 100) * 15), True);
        end;
        if (SkillData[Skill].Damage = 300) then
        begin // recupera hp
          Self.AddHP(((Self.Character.CurrentScore.MaxHP div 100) * 15), True);
        end
        else
        begin
          Self.AddBuff(Skill);
        end;
      end;
    337:
      begin
        Self.RemoveAllDebuffs;
      end;
    131: // cura massa defensiva cl
      begin
        Self.CalcAndCure(Skill, mob);
        Self.AddBuff(Skill);
      end;
    128: // libertação de mana cl
      begin
        mob.HPRListener := True;
        mob.HPRAction := 3;
        mob.HPRSkillID := Skill;
        mob.HPRSkillEtc1 := ((Self.Character.CurrentScore.DNMag shr 3) +
          SkillData[Skill].EFV[0]);
        mob.AddBuff(Skill);
      end;
    457: // agua benta cl
      begin
        if TItemFunctions.GetInvAvailableSlots(Servers[Self.ChannelId].Players
          [Self.ClientID]) = 0 then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Servers[Self.ChannelId].Players[Self.ClientID],
          SkillData[Skill].Damage);
      end;
    DEMOLICAO_X14:
      begin
        if(Self.PetClientID > 0) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Você não pode possuir dois PETs ao mesmo tempo.');
          Exit;
        end;

        Self.CreatePet(X14, Pos, Skill);
        Servers[Self.ChannelId].Players[Self.ClientID].SpawnPet(Self.PetClientID);
        Self.AddBuff(Skill);
      end;
    113: // teleporte em massa fc
      begin
        if(Self.InClastleVerus) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Impossível usar em guerra. Use o teleporte.');
          Exit;
        end;
        if(TItemFunctions.GetItemReliquareSlot(Servers[Self.ChannelId].Players[Self.ClientID]) <> 255) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Impossível usar com relíquia.');
          Exit;
        end;
        if(Self.Character.Nation > 0) then
        begin
          if(Self.Character.Nation <> Servers[Self.ChannelId].NationID) then
          begin
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Impossível usar em outros países.');
            Exit;
          end;
        end;
        Self.WalkTo(Pos, 70, MOVE_TELEPORT);
      end;
    89: // disparos rapidos dual
      begin
        Servers[Self.ChannelId].Players[Self.ClientID]
          .DisparosRapidosBarReset(Skill);
        Self._cooldown.Clear;
        Self.AddBuff(Skill);
      end;
    196, 220, 244: //forma faérica da pran
      begin
        if(Servers[Self.ChannelId].Players[Self.ClientID].FaericForm = False) then
        begin
          h1 := Servers[Self.ChannelId].Players[Self.ClientID].SpawnedPran;
          Servers[Self.ChannelId].Players[Self.ClientID].SendPranUnspawn(h1, 0);
          Servers[Self.ChannelId].Players[Self.ClientID].FaericForm := True;
          Servers[Self.ChannelId].Players[Self.ClientID].SendPranSpawn(h1, 0, 0);
        end
        else
        begin
          h1 := Servers[Self.ChannelId].Players[Self.ClientID].SpawnedPran;
          Self.SendEffect(0);
          Servers[Self.ChannelId].Players[Self.ClientID].FaericForm := False;
          Servers[Self.ChannelId].Players[Self.ClientID].SendPranSpawn(h1, 0, 0);
        end;
      end
  else
    begin
      Self.AddBuff(Skill);
    end;
  end;
end;
procedure TBaseMob.TargetBuffSkill(Skill, Anim: DWORD; mob: PBaseMob;
  DataSkill: P_SkillData; Posx, Posy: DWORD);
var
  Helper, Helper2: Integer;
  i: Integer;
  BoolHelper: Boolean;
begin
  {case Skill of
    6879:
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendAnimationDeadOf(mob.ClientID);
      end;
  end;}

  case DataSkill^.Index of
    124, 127, 137, 160:
      begin
        mob^.AddBuff(Skill, True, True,
          (Self.GetMobAbility(EF_SKILL_ATIME6) * 60));
      end;
    15:
      begin
        if(mob^.Character <> nil) then
        begin
          Randomize;
          Helper := ((mob^.Character.CurrentScore.MaxHP div 100) * 80);
          if (mob^.Character.CurrentScore.CurHP >= Helper) then
          begin // dano maior
            Helper2 := RandomRange(30, 60); // 30 -> 60  //30,31,32
          end
          else
          begin // dano menor
            Helper2 := RandomRange(15, 30); // 15 -> 30
          end;
        end
        else
        begin
          Helper2 := RandomRange((Self.Character.CurrentScore.DNFis div 2),
            Self.Character.CurrentScore.DNFis+1);
          if(Helper2 > 1000) then
          begin
            Randomize;
            Helper2 := 1000 + RandomRange(1, 200);
          end;
          Self.SDKMobID := mob.Mobid;
          Self.SDKSecondIndex := mob.SecondIndex;
          Self.SKDIsMob := True;
        end;
        Self.SKDSkillEtc1 := (DataSkill^.EFV[0] + Helper2);
        Self.SKDTarget := mob^.ClientID;
        Self.SKDListener := True;
        Self.SKDAction := 1;
        Self.SKDSkillID := Skill;
        mob^.AddBuff(Skill);
      end;
    26: // remediar tp
      begin
        Self.CalcAndCure(Skill, mob);
      end;
    35: //uniao divina
      begin
        mob.UniaoDivina := String(Self.Character.Name);
        mob^.AddBuff(Skill);
      end;
    39: // el tycia tp
      begin
        Self.RemoveMP(Self.Character.CurrentScore.CurMP, True);
        mob^.Character.CurrentScore.CurHP := mob^.Character.CurrentScore.MaxHP;
        mob^.SendCurrentHPMP(True);
      end;
    55:
      begin
        if(mob^.Character <> nil) then
        begin
          Randomize;
          Helper := ((mob^.Character.CurrentScore.MaxHP div 100) * 80);
          if (mob^.Character.CurrentScore.CurHP >= Helper) then
          begin // dano maior
            Helper2 := RandomRange(60, 120);
          end
          else
          begin // dano menor
            Helper2 := RandomRange(30, 59);
          end;
        end
        else
        begin
          Helper2 := RandomRange((Self.Character.CurrentScore.DNFis div 2),
            Self.Character.CurrentScore.DNFis+1);
          Self.SDKMobID := mob.Mobid;
          Self.SDKSecondIndex := mob.SecondIndex;
          Self.SKDIsMob := True;
        end;
        Self.SKDSkillEtc1 := ((DataSkill^.EFV[0] + Helper2) div DataSkill^.Duration);
        Self.SKDTarget := mob^.ClientID;
        Self.SKDListener := True;
        Self.SKDAction := 1;
        Self.SKDSkillID := Skill;
        mob^.AddBuff(Skill);
      end;
    79, 74: //veneno da lentidão e espinho venenoso
      begin
        if(mob^.Character <> nil) then
        begin
          Randomize;
          Helper := ((mob^.Character.CurrentScore.MaxHP div 100) * 80);
          if (mob^.Character.CurrentScore.CurHP >= Helper) then
          begin // dano maior
            Helper2 := RandomRange(60, 120);
          end
          else
          begin // dano menor
            Helper2 := RandomRange(30, 59);
          end;
        end
        else
        begin
          Helper2 := RandomRange((Self.Character.CurrentScore.DNFis div 2),
            Self.Character.CurrentScore.DNFis+1);
          Self.SDKMobID := mob.Mobid;
          Self.SDKSecondIndex := mob.SecondIndex;
          Self.SKDIsMob := True;
        end;
        Self.SKDSkillEtc1 := ((DataSkill^.EFV[0] + Helper2) div DataSkill^.Duration);
        Self.SKDTarget := mob^.ClientID;
        Self.SKDListener := True;
        Self.SKDAction := 1;
        Self.SKDSkillID := Skill;
        mob^.AddBuff(Skill);
      end;
    250:
      begin
        if(mob^.Character <> nil) then
        begin
          Randomize;
          Helper := ((mob^.Character.CurrentScore.MaxHP div 100) * 80);
          if (mob^.Character.CurrentScore.CurHP >= Helper) then
          begin // dano maior
            Helper2 := RandomRange(60, 120);
          end
          else
          begin // dano menor
            Helper2 := RandomRange(30, 59);
          end;
        end
        else
        begin
          Helper2 := RandomRange((Self.Character.CurrentScore.DNMag div 2),
            Self.Character.CurrentScore.DNMag+1);
          Self.SDKMobID := mob.Mobid;
          Self.SDKSecondIndex := mob.SecondIndex;
          Self.SKDIsMob := True;
        end;
        Self.SKDSkillEtc1 := (DataSkill^.EFV[0] + Helper2);
        Self.SKDTarget := mob^.ClientID;
        Self.SKDListener := True;
        Self.SKDAction := 1;
        Self.SKDSkillID := Skill;
        mob^.AddBuff(Skill);
      end;
    99: // polimorfo
      begin
        mob^.Polimorfed := True;
        if (mob^.ClientID <= MAX_CONNECTIONS) then
        begin
          mob^.SendCreateMob(SPAWN_NORMAL, 0, True, 283);
          mob^.AddBuff(Skill);
        end;
      end;
    140: // limpar cl
      begin
        mob^.RemoveDebuffs(1);
      end;
    122: // cura cl
      begin
        Self.CalcAndCure(Skill, mob);
      end;
    125: // mao de cura cl
      begin
        mob^.HPRListener := True;
        mob^.HPRAction := 2;
        mob^.HPRSkillID := Skill;
        mob^.HPRSkillEtc1 := Round(Self.CalcCure2(DataSkill^.EFV[0], mob, Skill)
          / DataSkill^.Duration);
        mob^.AddBuff(Skill);
      end;
    RESSUREICAO:
      begin
        if(mob.IsDead) then
        begin
          if(Self.PartyId = 0) then
            Exit;

          if(mob.PartyId = 0) then
            Exit;

          if(Servers[Self.ChannelId].Players[Self.ClientID].Party.InRaid) then
          begin
            if(mob.PartyId <> Self.PartyId) then
            begin
              BoolHelper := False;

              for I := 1 to 3 do
              begin
                if(Servers[Self.ChannelId].Players[Self.ClientID].Party.PartyAllied[i] = 0) then
                  Continue;

                if(Servers[Self.ChannelId].Players[Self.ClientID].Party.PartyAllied[i] =
                  mob.PartyId) then
                begin
                  BoolHelper := True;
                  break;
                end;
              end;

              if not(BoolHelper) then
                Exit;
            end;
          end
          else
          begin
            if(mob.PartyId <> Self.PartyId) then
              Exit;
          end;

          mob.IsDead := False;

          mob.Character.CurrentScore.CurHP :=
            ((mob.Character.CurrentScore.MaxHp div 100) * SkillData[Skill].Damage);
          mob.SendEffect(1);
          mob.SendCurrentHPMP(True);

          Servers[mob.ChannelId].Players[mob.ClientID].SendClientMessage(
            'Você foi ressuscitado pelo jogador ' +
              AnsiString(Self.Character.Name) + '.');
        end;
      end;
    131: // cura massa defensiva cl
      begin
        Self.CalcAndCure(Skill, mob);
        mob^.AddBuff(Skill);
      end;
    337: // 75 wr
      begin
        Self.RemoveAllDebuffs;
      end;
    128: // libertação de mana cl
      begin
        mob^.HPRListener := True;
        mob^.HPRAction := 3;
        mob^.HPRSkillID := Skill;
        mob^.HPRSkillEtc1 := (Self.CalcCure2(DataSkill^.EFV[0], mob, Skill) + DataSkill^.EFV[0]);
        mob^.AddBuff(Skill);
      end;
    133: //raio solar
      begin
        if(mob^.Character <> nil) then
        begin
          Randomize;
          Helper := ((mob^.Character.CurrentScore.MaxHP div 100) * 80);
          if (mob^.Character.CurrentScore.CurHP >= Helper) then
          begin // dano maior
            Helper2 := RandomRange(30, 59);
          end
          else
          begin // dano menor
            Helper2 := RandomRange(10, 29);
          end;
        end
        else
        begin
          Helper2 := RandomRange((Self.Character.CurrentScore.DNMag div 2),
            Self.Character.CurrentScore.DNMag+1);
          Self.SDKMobID := mob.Mobid;
          Self.SDKSecondIndex := mob.SecondIndex;
          Self.SKDIsMob := True;
        end;
        Self.SKDSkillEtc1 := ((DataSkill^.EFV[0] div 2) + Helper2);
        Self.SKDTarget := mob^.ClientID;
        Self.SKDListener := True;
        Self.SKDAction := 1;
        Self.SKDSkillID := Skill;
        mob^.AddBuff(Skill);
      end;
    138: // recuperação cl
      begin
        Self.CalcAndCure(Skill, mob);
        mob^.RemoveAllDebuffs;
      end;
    162: // aurea do explendor cl
      begin
        Self.CalcAndCure(Skill, mob);
        mob^.AddBuff(Skill);
      end;
    459: // cura concentrada cl
      begin
        mob^.AddHP(Self.CalcCure2(DataSkill^.Damage, mob), True);
      end;
    167: // gloria de excelis
      begin
        mob^.RemoveDebuffs(1);
        Self.CalcAndCure(Skill, mob);
        mob^.AddBuff(Skill);
      end;
    458: // flores da gloria
      begin
        Self.CalcAndCure(Skill, mob);
      end;
    113: // teleporte em massa fc
      begin
        Helper := TItemFunctions.GetItemReliquareSlot(Servers[mob^.ChannelId].Players[mob.ClientID]);

        if(Helper <> 255) then
        begin
          Servers[mob^.ChannelId].Players[mob.ClientID].SendClientMessage('Impossível telar com relíquia.');
          Exit;
        end;

        if(mob.InClastleVerus) then
        begin
          Servers[mob.ChannelId].Players[mob.ClientID].SendClientMessage('Impossível usar em guerra. Use o teleporte.');
          Exit;
        end;

        if(Self.Character.Nation > 0) then
        begin
          if(Self.Character.Nation <> Servers[Self.ChannelId].NationID) then
          begin
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Impossível usar em outros países.');
            Exit;
          end;
        end;

        {if(mob^.Character.Nation > 0) then
        begin
          if(mob^.Character.Nation = Servers[mob^.ChannelId].NationID) then
            mob^.WalkTo(TPosition.Create(Posx, Posy), 70, MOVE_TELEPORT);
        end
        else }
        mob^.WalkTo(TPosition.Create(Posx, Posy), 70, MOVE_TELEPORT);
      end;
    248: // ceu sereno (pran skill)
      begin
        mob^.HPRListener := True;
        mob^.HPRAction := 2;
        mob^.HPRSkillID := Skill;
        mob^.HPRSkillEtc1 := DataSkill^.EFV[0];
        mob^.AddBuff(Skill);
      end
  else
    begin
      try
        mob^.AddBuff(Skill);
      except
        on E: Exception do
        begin
          Logger.Write('Error at mob.AddBuff ' + E.Message, TLogType.Error);
        end;
      end;
    end;
  end;
  { mob.SendCurrentHPMP;
    mob.SendStatus;
    mob.SendRefreshPoint; }
end;
procedure TBaseMob.TargetSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Classe of
    1, 2:
      begin
        Self.WarriorSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff, Resisted);
      end;
    11, 12: // templar skill
      begin
        Self.TemplarSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff, Resisted);
      end;
    21, 22: // rifleman skill
      begin
        Self.RiflemanSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff,
          Resisted);
      end;
    31, 32: // dualgunner skill
      begin
        Self.DualGunnerSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff,
          Resisted);
      end;
    41, 42: // magician skill
      begin
        Self.MagicianSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff,
          Resisted);
      end;
    51, 52: // cleric skill
      begin
        Self.ClericSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff, Resisted);
      end;
  end;
end;
procedure TBaseMob.AreaBuff(Skill, Anim: DWORD; mob: PBaseMob;
  Packet: TRecvDamagePacket);
var
  i, cnt: Integer;
  PrePosition: TPosition;
begin
  if (Servers[Self.ChannelId].Players[Self.ClientID].PartyIndex = 0) then
  begin // Se não estiver em party, buffa só em si mesmo
    Self.SelfBuffSkill(Skill, Anim, mob, Packet.DeathPos);
    // Logger.Write(Packet.DeathPos.X.ToString, TLogType.Packets);
  end
  else
  begin
    cnt := 0;
    // Se estiver em party, vai buffar em si mesmo + Party
    if (Self.VisiblePlayers.Count = 0) then
    begin
      Self.TargetBuffSkill(Skill, Anim, @Servers[Self.ChannelId].Players
        [Self.ClientID].Base, @SkillData[Skill], Trunc(Packet.DeathPos.x),
        Trunc(Packet.DeathPos.y));
    end
    else
    begin
      for i in Self.VisiblePlayers do
      begin
        if (Servers[Self.ChannelId].Players[i].Status < Playing) or
          (Servers[Self.ChannelId].Players[i].Base.IsDead) then
          Continue;
        if (Servers[Self.ChannelId].Players[i].PartyIndex = 0) then
          Continue;
        if (cnt = 0) then
        begin
          PrePosition := Self.PlayerCharacter.LastPos;
          Self.TargetBuffSkill(Skill, Anim, @Servers[Self.ChannelId].Players
            [Self.ClientID].Base, @SkillData[Skill], Trunc(Packet.DeathPos.x),
            Trunc(Packet.DeathPos.y));
          cnt := 1;
        end;
        if (Servers[Self.ChannelId].Players[Self.ClientID].Party.
          Index <> Servers[Self.ChannelId].Players[i].Party.Index) then
          Continue;

        if not(PrePosition.InRange(
          Servers[Self.ChannelId].Players[i]
          .Base.PlayerCharacter.LastPos, Trunc(SkillData[Skill].Range * 1.5))) then
          Continue;

        Self.TargetBuffSkill(Skill, Anim, @Servers[Self.ChannelId].Players[i]
          .Base, @SkillData[Skill], Trunc(Packet.DeathPos.x),
          Trunc(Packet.DeathPos.y));
        Packet.Animation := 0;
        Packet.TargetID := i;
        Packet.AttackerHP := Servers[Self.ChannelId].Players[i].Base.Character.CurrentScore.CurHP;
        // Packet.DeathPos := Servers[Self.ChannelId].Players[i]
        // .Base.PlayerCharacter.LastPos;
        Self.SendToVisible(Packet, Packet.Header.size);
      end;
    end;
  end;
  if (SkillData[Skill].Index = 167) then
    Self.UsingLongSkill := True;
end;
procedure TBaseMob.AreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  SkillPos: TPosition; DataSkill: P_SkillData; DamagePerc: Single; ElThymos: Integer);
var
  Dano: Integer;
  DmgType: TDamageType;
  SelfPlayer: PPlayer;
  OtherPlayer: PPlayer;
  NewMob, mob_teleport: PBaseMob;
  NewMobSP: PMobSPoisition;
  Packet: TRecvDamagePacket;
  i, j, cnt: Integer;
  Add_Buff: Boolean;
  Resisted: Boolean;
  Mobid, mobpid: Integer;
  MoveTarget: Boolean;
  DropExp, DropItem: Boolean;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $102;
  Packet.SkillID := Skill;
  Packet.DeathPos := SkillPos;
  if((SkillData[Skill].Range > 0) {and (SkillData[Skill].CastTime > 0)}) then
  begin     //SkillData[Skill]
    Packet.AttackerPos := SkillPos;
  end
  else
  begin
    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
  end;
  Packet.AttackerID := Self.ClientID;
  Packet.Animation := Anim;
  Packet.AttackerHP := Self.Character.CurrentScore.CurHP;
  Packet.MobAnimation := DataSkill^.TargetAnimation;
  Self.UsingLongSkill := False;

  if(ElThymos > 0) then
  begin
    Packet.SkillID := 0;
    Packet.Animation := 0;
    Packet.MobAnimation := 26;
  end;

  if(SkillData[Skill].Index = DEMOLICAO_X14) then
  begin
    Self.SelfBuffSkill(Skill, Anim, mob, SkillPos);
    Packet.TargetID := 0;
    Packet.Dano := 0;
    Packet.DnType := TDamageType.None;
    Packet.AttackerPos := SkillPos;
    Packet.DeathPos := SkillPos;
    Self.SendToVisible(Packet, Packet.Header.size);
    Exit;
  end;
  case Self.GetMobClass() of
    2,3:
      begin
        if not(ItemList[Self.Character.Equip[15].Index].ItemType = 52) then
        begin
          TItemFunctions.DecreaseAmount(@Self.Character.Equip[15], 1);
          Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
            Self.Character.Equip[15], False);
        end;
      end;
  end;
  if (Servers[Self.ChannelId].Players[Self.ClientID].InDungeon) then
  begin
    cnt := 0;
    for i := Low(VisibleTargets) to High(VisibleTargets) do
    begin
      if (VisibleTargets[i].ClientID = 0) then
        Continue;
      { Mobid := TMobFuncs.GetMobDgGeralID(Self.ChannelId, i,
        Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID);
        if (Mobid = -1) then
        Continue; }
      NewMob := Self.GetTargetInList(VisibleTargets[i].ClientID);
      if (NewMob = nil) then
        Continue;
      if (NewMob^.IsDead) then
        Continue;
      Mobid := NewMob^.Mobid;
      if (DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].Mobs[Mobid].IsAttacked = False) then
      begin
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].Mobs[Mobid].IsAttacked := True;
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].Mobs[Mobid].FirstPlayerAttacker := Self.ClientID;
      end;
      DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].Mobs[Mobid].AttackerID := Self.ClientID;
      if (DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].Mobs[Mobid].Position.Distance(SkillPos) <=
        (DataSkill^.range * 1.5)) then
      begin
        Packet.TargetID := NewMob^.ClientID;
        Resisted := False;
        case DataSkill^.Classe of
          1, 2: // warrior skill
            begin
              Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                Add_Buff, Resisted, MoveTarget);
            end;
          11, 12: // templar skill
            begin
              Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                Add_Buff, Resisted);
            end;
          21, 22: // rifleman skill
            begin
              Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                Add_Buff, Resisted);
            end;
          31, 32: // dualgunner skill
            begin
              Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                Add_Buff, Resisted);
            end;
          41, 42: // magician skill
            begin
              Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                Add_Buff, Resisted);
            end;
          51, 52: // cleric skill
            begin
              Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
                Resisted);
            end;
        end;
        Inc(cnt);
        if(Dano > 0) then
        begin
          Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
            Packet.MobAnimation, DataSkill);
          if(Dano > 0) then
          begin
            Inc(Dano, ((RandomRange((Dano div 20), (Dano div 10))) + 13));
          end;
        end;

        if (Add_Buff = True) then
        begin
          if not(Resisted) then
            Self.TargetBuffSkill(Skill, Anim, NewMob, DataSkill);
        end;
        Packet.Dano := Dano;
        Packet.DnType := DmgType;
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].Mobs[Mobid].IsAttacked := True;
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].Mobs[Mobid].AttackerID := Self.ClientID;
        if (Packet.Dano >= DungeonInstances[Servers[Self.ChannelId].Players
          [Self.ClientID].DungeonInstanceID].Mobs[Mobid].CurrentHP) then
        begin
          DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
            .DungeonInstanceID].Mobs[Mobid].CurrentHP := 0;
          DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
            .DungeonInstanceID].Mobs[Mobid].IsAttacked := False;
          DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
            .DungeonInstanceID].Mobs[Mobid].AttackerID := 0;
          DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
            .DungeonInstanceID].Mobs[Mobid].deadTime := Now;
          if (Self.VisibleMobs.Contains(NewMob^.ClientID)) then
            Self.VisibleMobs.Remove(NewMob^.ClientID);
          NewMob^.VisibleMobs.Clear;
          Self.MobKilledInDungeon(NewMob);
          Packet.MobAnimation := 30;
          NewMob^.IsDead := True;
          Self.RemoveTargetFromList(NewMob);
        end
        else
        begin
          DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
            .DungeonInstanceID].Mobs[Mobid].CurrentHP :=
            DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
            .DungeonInstanceID].Mobs[Mobid].CurrentHP - Packet.Dano;
        end;
        NewMob.LastReceivedAttack := Now;
        Packet.MobCurrHP := DungeonInstances
          [Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID]
          .Mobs[Mobid].CurrentHP;
        Self.SendToVisible(Packet, Packet.Header.size);
        //Sleep(1);
      end;
    end;
    if (cnt = 0) then
    begin
      Packet.TargetID := 0;
      /// ////era $7535
      Packet.Dano := 0;
      Packet.DnType := TDamageType.Normal;
      Packet.AttackerPos := SkillPos;
      Packet.DeathPos := SkillPos;
      Self.SendToVisible(Packet, Packet.Header.size);
      //Sleep(1);
    end;
    // aquele inc(cnt) comentado tem que fazer ele funfar aqui
    Exit;
  end;

  cnt := 0;
  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];
  for i := Low(VisibleTargets) to High(VisibleTargets) do
  begin
    if (VisibleTargets[i].ClientID = 0) then
      Continue;

    if(ElThymos > 0) then
    begin
      if(VisibleTargets[i].ClientID = mob.ClientID) then
        Continue;
    end;

    case VisibleTargets[i].TargetType of
      0:
        begin
          if(VisibleTargets[i].Player = nil) then
            Continue;

          NewMob := VisibleTargets[i].Player;
          OtherPlayer := @Servers[Self.ChannelId].Players
            [VisibleTargets[i].ClientID];
          if (NewMob^.IsDead) then
            Continue;
          if(OtherPlayer.SocketClosed) then
            Continue;
          if(OtherPlayer.Status < Playing) then
            Continue;
          if (SkillPos.InRange(NewMob^.PlayerCharacter.LastPos,
            Trunc(DataSkill^.range * 1.5))) then
          begin
            if (TPosition.Create(2947, 1664)
              .InRange(NewMob^.PlayerCharacter.LastPos, 10)) then
              Continue;
            if ((SelfPlayer^.Character.Base.GuildIndex > 0) and
              (SelfPlayer.Character.Base.GuildIndex = OtherPlayer^.Character.
              Base.GuildIndex) and not(SelfPlayer^.Dueling)) then
              Continue;
            if (SelfPlayer^.PartyIndex > 0) and
              (SelfPlayer.PartyIndex = OtherPlayer^.PartyIndex) then
              Continue;
            if ((Self.Character.Nation = NewMob^.Character.Nation) and
              (SelfPlayer^.Character.PlayerKill = False) and
              not(SelfPlayer^.Dueling)) then
              Continue;
            if (SelfPlayer^.Dueling) then
            begin
              if (NewMob^.ClientID <> SelfPlayer^.DuelingWith) then
                Continue;
              if (SecondsBetween(Now, SelfPlayer^.DuelInitTime) <= 15) then
                Continue;
            end;

            if((SelfPlayer^.Character.GuildSlot > 0) and (Servers[SelfPlayer^.ChannelIndex].Players[
            NewMob^.ClientID].Character.GuildSlot > 0)) then
            begin
              if(Guilds[SelfPlayer^.Character.GuildSlot].Ally.Leader =
                Guilds[Servers[SelfPlayer^.ChannelIndex].Players[
                NewMob^.ClientID].Character.GuildSlot].Ally.Leader) then
              Exit;
            end;

            if(SecondsBetween(Now, NewMob.RevivedTime) <= 7) then
            begin
              Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Alvo acabou de nascer.');
              Continue;
            end;
            Inc(cnt);
            Packet.TargetID := NewMob^.ClientID;
            Resisted := False;
            case DataSkill^.Classe of
              1, 2: // warrior skill
                begin
                  Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted, MoveTarget);
                end;
              11, 12: // templar skill
                begin
                  Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted);
                end;
              21, 22: // rifleman skill
                begin
                  Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted);
                end;
              31, 32: // dualgunner skill
                begin
                  Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted);
                end;
              41, 42: // magician skill
                begin
                  Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted);
                end;
              51, 52: // cleric skill
                begin
                  Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted);
                end;
            end;
            if (Dano > 0) then
            begin
              if (ElThymos > 0) then
              begin
                Self.AttackParse(0, Anim, NewMob, Dano, DmgType, Add_Buff,
                  Packet.MobAnimation, DataSkill);
              end
              else
              begin
                Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
                  Packet.MobAnimation, DataSkill);
              end;

              if(Dano > 0) then
              begin
                Inc(Dano, ((RandomRange((Dano div 20), (Dano div 10))) + 13));

                if(DamagePerc > 0) then
                begin
                  Dano := Trunc((Dano div 100) * DamagePerc);
                end;
              end;
            end
            else
            begin
              if not(DmgType in [Critical, Normal, Double]) then
                Add_Buff := False;
            end;
            if (Add_Buff = True) then
            begin
              if not(Resisted) then
                Self.TargetBuffSkill(Skill, Anim, NewMob, DataSkill);
            end;
            if((ElThymos > 0) and (Dano > 0)) then
            begin
              Dano := Round((Dano / 100) * DamagePerc);
            end;
            if (DmgType = Miss) then
              Dano := 0;


            Packet.Dano := Dano;
            Packet.DnType := DmgType;
            if (Packet.Dano >= NewMob^.Character.CurrentScore.CurHP) then
            begin
              if (OtherPlayer^.Dueling) then
              begin
                NewMob^.Character.CurrentScore.CurHP := 10;
              end
              else
              begin
                NewMob^.Character.CurrentScore.CurHP := 0;
                NewMob^.SendEffect($0);
                Packet.MobAnimation := 30;
                NewMob^.IsDead := True;
                if(Servers[Self.ChannelId].Players[NewMob^.ClientID].CollectingReliquare) then
                  Servers[Self.ChannelId].Players[NewMob^.ClientID].SendCancelCollectItem(
                  Servers[Self.ChannelId].Players[NewMob^.ClientID].CollectingID);
                NewMob^.LastReceivedAttack := Now;
                Packet.MobCurrHP := NewMob^.Character.CurrentScore.CurHP;
                if(cnt>1) then
                begin
                  Packet.AttackerID := Self.ClientID;
                  Packet.Animation := 0;
                end
                else
                begin
                  Packet.AttackerID := Self.ClientID;
                end;
                if((SkillData[Skill].Range > 0) {and (SkillData[Skill].CastTime > 0)}) then
                begin     //SkillData[Skill]
                  Packet.AttackerPos := SKillPos;
                  Packet.DeathPos := Servers[Self.ChannelId].Players[Self.ClientID].LastPositionLongSkill;
                end
                else
                begin
                  Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                  Packet.DeathPos := SkillPos;
                end;

                Self.SendToVisible(Packet, Packet.Header.size);
                if (NewMob^.Character.Nation > 0) and (Self.Character.Nation > 0)
                then
                begin
                  if ((NewMob^.Character.Nation <> Self.Character.Nation) or
                    (Self.InClastleVerus)) then
                  begin
                    Self.PlayerKilled(NewMob);
                  end;
                end;
              end;
            end
            else
            begin
              if (Packet.Dano > 0) then
                NewMob^.RemoveHP(Packet.Dano, False);
              if(Servers[Self.ChannelId].Players[NewMob^.ClientID].CollectingReliquare) then
                Servers[Self.ChannelId].Players[NewMob^.ClientID].SendCancelCollectItem(
                Servers[Self.ChannelId].Players[NewMob^.ClientID].CollectingID);
              NewMob^.LastReceivedAttack := Now;
              Packet.MobCurrHP := NewMob^.Character.CurrentScore.CurHP;
              if(cnt>1) then
              begin
                Packet.AttackerID := Self.ClientID;
                Packet.Animation := 0;
              end
              else
              begin
                Packet.AttackerID := Self.ClientID;
              end;
              if((SkillData[Skill].Range > 0) {and (SkillData[Skill].CastTime > 0)}) then
              begin     //SkillData[Skill]
                Packet.AttackerPos := SKillPos;
                Packet.DeathPos := Servers[Self.ChannelId].Players[Self.ClientID].LastPositionLongSkill;
              end
              else
              begin
                Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                Packet.DeathPos := SkillPos;
              end;

              Self.SendToVisible(Packet, Packet.Header.size);
            end;

            //Sleep(1);
          end;
        end;
      1:
        begin
          if(VisibleTargets[i].mob = nil) then
            Continue;
          NewMob := VisibleTargets[i].mob;
          if(NewMob.ClientID> 9147) then
            Continue;
          if not(Servers[Self.ChannelId].MOBS.TMobS[NewMob.Mobid].IsActiveToSpawn) then
            Continue;
          if (NewMob^.IsDead) then
            Continue;
          case NewMob^.ClientID of
            3340 .. 3354:
              begin // stones
                if (SkillPos.InRange(Servers[Self.ChannelId].DevirStones
                  [NewMob^.ClientID].PlayerChar.LastPos,
                  Trunc(DataSkill^.range * 1.5))) then
                begin
                  if (Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                    .PlayerChar.Base.Nation = Integer(Servers[Self.Channelid].Players[Self.ClientID].
                    Account.Header.Nation)) then
                    Continue;
                  Inc(cnt);
                  Packet.TargetID := NewMob^.ClientID;
                  Resisted := False;
                  case DataSkill^.Classe of
                    1, 2: // warrior skill
                      begin
                        Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted, MoveTarget);
                      end;
                    11, 12: // templar skill
                      begin
                        Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    21, 22: // rifleman skill
                      begin
                        Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    31, 32: // dualgunner skill
                      begin
                        Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    41, 42: // magician skill
                      begin
                        Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    51, 52: // cleric skill
                      begin
                        Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                          Add_Buff, Resisted);
                      end;
                  end;
                  if(Dano > 0) then
                  begin
                    Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
                      Packet.MobAnimation, DataSkill);

                    if(Dano > 0) then
                    begin
                      Inc(Dano, ((RandomRange((Dano div 20), (Dano div 10))) + 13));

                      if(DamagePerc > 0) then
                      begin
                        Dano := Trunc((Dano div 100) * DamagePerc);
                      end;
                    end;
                  end;
                  if (Add_Buff = True) then
                  begin
                    if not(Resisted) then
                      Self.TargetBuffSkill(Skill, Anim, NewMob, DataSkill);
                  end;
                  if (DmgType = Miss) then
                    Dano := 0;
                  if((ElThymos > 0) and (Dano > 0)) then
                  begin
                    Dano := Round((Dano / 100) * DamagePerc);
                  end;

                  Packet.Dano := Dano;
                  Packet.DnType := DmgType;
                  Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                    .IsAttacked := True;
                  Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                    .AttackerID := Self.ClientID;
                  if ((Packet.Dano >= Servers[Self.ChannelId].DevirStones
                    [NewMob^.ClientID].PlayerChar.Base.CurrentScore.CurHP)and not(NewMob^.IsDead)) then
                  begin
                    NewMob^.IsDead := True;
                    Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                      .PlayerChar.Base.CurrentScore.CurHP := 0;
                    Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                      .IsAttacked := False;
                    Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                      .AttackerID := 0;
                    Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                      .deadTime := Now;
                    Servers[Self.ChannelId].DevirStones[NewMob^.ClientID].
                      KillStone(Newmob^.ClientID, Self.ClientId);
                    if (Self.VisibleNPCs.Contains(NewMob^.ClientID)) then
                    begin
                      Self.VisibleNPCs.Remove(NewMob^.ClientID);
                      Self.RemoveTargetFromList(NewMob);
                      // essa skill tem retorno no caso de erro
                    end;
                    for j in Self.VisiblePlayers do
                    begin
                      if(Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Contains(NewMob^.ClientID)) then
                      begin
                        Servers[Self.ChannelId].Players[j].Base.VisibleNPCs.Remove(NewMob^.ClientID);
                        Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(NewMob);
                      end;
                    end;
                    NewMob^.VisibleMobs.Clear;
                    // Self.MobKilled(mob, DropExp, DropItem, False);
                    Packet.MobAnimation := 30;
                  end
                  else
                  begin
                    deccardinal(Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                      .PlayerChar.Base.CurrentScore.CurHP,Packet.Dano);
                  end;
                  NewMob^.LastReceivedAttack := Now;
                  if(cnt>1) then
                  begin
                    Packet.AttackerID := Self.ClientID;
                    Packet.Animation := 0;
                  end
                  else
                  begin
                    Packet.AttackerID := Self.ClientID;
                  end;
                  Packet.MobCurrHP := Servers[Self.ChannelId].DevirStones
                    [NewMob^.ClientID].PlayerChar.Base.CurrentScore.CurHP;
                  if((SkillData[Skill].Range > 0) {and (SkillData[Skill].CastTime > 0)}) then
                  begin     //SkillData[Skill]
                    Packet.AttackerPos := SKillPos;
                    Packet.DeathPos := Servers[Self.ChannelId].Players[Self.ClientID].LastPositionLongSkill;
                  end
                  else
                  begin
                    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                    Packet.DeathPos := SkillPos;
                  end;
                  Self.SendToVisible(Packet, Packet.Header.size);
                  //Sleep(1);
                end;
              end;
            3355 .. 3369:
              begin // guards
                if (SkillPos.InRange(Servers[Self.ChannelId].DevirGuards
                  [NewMob^.ClientID].PlayerChar.LastPos,
                  Trunc(DataSkill^.range * 1.5))) then
                begin
                  if (Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                    .PlayerChar.Base.Nation = Integer(Servers[Self.Channelid].Players[Self.ClientID].
                    Account.Header.Nation)) then
                    Continue;
                  Inc(cnt);
                  Packet.TargetID := NewMob^.ClientID;
                  Resisted := False;
                  case DataSkill^.Classe of
                    1, 2: // warrior skill
                      begin
                        Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted, MoveTarget);
                      end;
                    11, 12: // templar skill
                      begin
                        Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    21, 22: // rifleman skill
                      begin
                        Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    31, 32: // dualgunner skill
                      begin
                        Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    41, 42: // magician skill
                      begin
                        Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    51, 52: // cleric skill
                      begin
                        Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                          Add_Buff, Resisted);
                      end;
                  end;
                  if(Dano > 0) then
                  begin
                    Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
                      Packet.MobAnimation, DataSkill);

                    if(Dano > 0) then
                    begin
                      Inc(Dano, ((RandomRange((Dano div 20), (Dano div 10))) + 13));

                      if(DamagePerc > 0) then
                      begin
                        Dano := Trunc((Dano div 100) * DamagePerc);
                      end;
                    end;
                  end;
                  if (Add_Buff = True) then
                  begin
                    if not(Resisted) then
                      Self.TargetBuffSkill(Skill, Anim, NewMob, DataSkill);
                  end;
                  if (DmgType = Miss) then
                    Dano := 0;
                  if((ElThymos > 0) and (Dano > 0)) then
                  begin
                    Dano := Round((Dano / 100) * DamagePerc);
                  end;

                  Packet.Dano := Dano;
                  Packet.DnType := DmgType;
                  Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                    .IsAttacked := True;
                  Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                    .AttackerID := Self.ClientID;
                  if ((Packet.Dano >= Servers[Self.ChannelId].DevirGuards
                    [NewMob^.ClientID].PlayerChar.Base.CurrentScore.CurHP)and not(NewMob^.IsDead)) then
                  begin
                    NewMob^.IsDead := True;
                    Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                      .PlayerChar.Base.CurrentScore.CurHP := 0;
                    Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                      .IsAttacked := False;
                    Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                      .AttackerID := 0;
                    Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                      .deadTime := Now;
                    Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID].
                      KillGuard(Newmob^.ClientID, Self.ClientId);
                    if (Self.VisibleNPCs.Contains(NewMob^.ClientID)) then
                    begin
                      Self.VisibleNPCs.Remove(NewMob^.ClientID);
                      Self.RemoveTargetFromList(NewMob);
                      // essa skill tem retorno no caso de erro
                    end;
                    for j in Self.VisiblePlayers do
                    begin
                      if(Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Contains(NewMob^.ClientID)) then
                      begin
                        Servers[Self.ChannelId].Players[j].Base.VisibleNPCs.Remove(NewMob^.ClientID);
                        Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(NewMob);
                      end;
                    end;
                    NewMob^.VisibleMobs.Clear;
                    // Self.MobKilled(mob, DropExp, DropItem, False);
                    Packet.MobAnimation := 30;
                  end
                  else
                  begin
                    deccardinal(Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                      .PlayerChar.Base.CurrentScore.CurHP, Packet.Dano);
                  end;
                  NewMob^.LastReceivedAttack := Now;
                  if(cnt>1) then
                  begin
                    Packet.AttackerID := Self.ClientID;
                    Packet.Animation := 0;
                  end
                  else
                  begin
                    Packet.AttackerID := Self.ClientID;
                  end;
                  Packet.MobCurrHP := Servers[Self.ChannelId].DevirGuards
                    [NewMob^.ClientID].PlayerChar.Base.CurrentScore.CurHP;
                  if((SkillData[Skill].Range > 0) {and (SkillData[Skill].CastTime > 0)}) then
                  begin     //SkillData[Skill]
                    Packet.AttackerPos := SKillPos;
                    Packet.DeathPos := Servers[Self.ChannelId].Players[Self.ClientID].LastPositionLongSkill;
                  end
                  else
                  begin
                    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                    Packet.DeathPos := SkillPos;
                  end;
                  Self.SendToVisible(Packet, Packet.Header.size);
                  //Sleep(1);
                end;
              end
          else
            begin
              NewMobSP := @Servers[Self.ChannelId].Mobs.TMobS[NewMob^.Mobid]
                .MobsP[NewMob^.SecondIndex];
              if (SkillPos.InRange(NewMobSP^.CurrentPos,
                Trunc(DataSkill^.range * 1.5))) then
              begin
                if ((NewMobSP^.isGuard) and
                  ((NewMob^.PlayerCharacter.Base.Nation = Self.Character.Nation) or
                  (Self.Character.Nation = 0)))
                then
                  Continue;

                if not(NewMobSP.IsAttacked) then
                begin
                  NewMobSP.FirstPlayerAttacker := Self.ClientID;
                end;

                Inc(cnt);
                Packet.TargetID := NewMob^.ClientID;
                Resisted := False;
                case DataSkill^.Classe of
                  1, 2: // warrior skill
                    begin
                      Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted, MoveTarget);
                    end;
                  11, 12: // templar skill
                    begin
                      Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted);
                    end;
                  21, 22: // rifleman skill
                    begin
                      Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted);
                    end;
                  31, 32: // dualgunner skill
                    begin
                      Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano,
                        DmgType, Add_Buff, Resisted);
                    end;
                  41, 42: // magician skill
                    begin
                      Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted);
                    end;
                  51, 52: // cleric skill
                    begin
                      Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted);
                    end;
                end;
                if(Dano > 0) then
                begin
                  Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
                    Packet.MobAnimation, DataSkill);

                  if(Dano > 0) then
                  begin
                    Inc(Dano, ((RandomRange((Dano div 20), (Dano div 10))) + 13));

                    if(DamagePerc > 0) then
                    begin
                      Dano := Trunc((Dano div 100) * DamagePerc);
                    end;
                  end;
                end;
                if (Add_Buff = True) then
                begin
                  if not(Resisted) then
                    Self.TargetBuffSkill(Skill, Anim, NewMob, DataSkill);
                end;
                if (DmgType = Miss) then
                  Dano := 0;
                if((ElThymos > 0) and (Dano > 0)) then
                begin
                  Dano := Round((Dano / 100) * DamagePerc);
                end;
                Packet.Dano := Dano;
                Packet.DnType := DmgType;
                NewMobSP^.IsAttacked := True;
                NewMobSP^.AttackerID := Self.ClientID;
                if (Packet.Dano >= NewMobSP^.HP) then
                begin
                  NewMobSP^.HP := 0;
                  NewMobSP^.IsAttacked := False;
                  NewMobSP^.AttackerID := 0;
                  NewMobSP^.deadTime := Now;
                  NewMob.SendEffect($0);
                  NewMob^.IsDead := True;
                  NewMob.SendCurrentHPMPMob;
                  if (Self.VisibleMobs.Contains(NewMob^.ClientID)) then
                  begin
                    Self.VisibleMobs.Remove(NewMob^.ClientID);
                    Self.RemoveTargetFromList(NewMob);
                  end;
                  for j in Self.VisiblePlayers do
                  begin
                    if(Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Contains(NewMob^.ClientID)) then
                    begin
                      Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Remove(NewMob^.ClientID);
                      Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(NewMob);
                    end;
                  end;
                  NewMob^.VisibleMobs.Clear;
                  Self.MobKilled(NewMob, DropExp, DropItem, False);
                  Packet.MobAnimation := 30;
                  if(cnt>1) then
                  begin
                    Packet.AttackerID := Self.ClientID;
                    Packet.Animation := 0;
                  end
                  else
                  begin
                    Packet.AttackerID := Self.ClientID;
                  end;
                  if((SkillData[Skill].Range > 0) {and (SkillData[Skill].CastTime > 0)}) then
                  begin     //SkillData[Skill]
                    Packet.AttackerPos := SKillPos;
                    Packet.DeathPos := Servers[Self.ChannelId].Players[Self.ClientID].LastPositionLongSkill;
                  end
                  else
                  begin
                    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                    Packet.DeathPos := SkillPos;
                  end;
                  NewMob^.LastReceivedAttack := Now;
                  Packet.MobCurrHP := 0;
                  Self.SendToVisible(Packet, Packet.Header.size);
                  //Sleep(1);
                end
                else
                begin

                  deccardinal(NewMobSP^.HP, Packet.Dano);
                  Packet.MobCurrHP := NewMobSP^.HP;
                  NewMob^.LastReceivedAttack := Now;
                  if(cnt>1) then
                  begin
                    Packet.AttackerID := Self.ClientID;
                    Packet.Animation := 0;
                  end
                  else
                  begin
                    Packet.AttackerID := Self.ClientID;
                  end;
                  if((SkillData[Skill].Range > 0) {and (SkillData[Skill].CastTime > 0)}) then
                  begin     //SkillData[Skill]
                    Packet.AttackerPos := SKillPos;
                    Packet.DeathPos := Servers[Self.ChannelId].Players[Self.ClientID].LastPositionLongSkill;
                  end
                  else
                  begin
                    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                    Packet.DeathPos := SkillPos;
                  end;
                  Self.SendToVisible(Packet, Packet.Header.size);
                  NewMob.SendCurrentHPMPMob;
                  //Sleep(1);
                end;
              end;
            end;
          end;
        end;
    end;
  end;
  if ((cnt = 0) and (ElThymos = 0)) then
  begin
    Packet.TargetID := 0;
    Packet.Dano := 0;
    Packet.DnType := TDamageType.Normal;
    Packet.AttackerPos := SkillPos;
    Packet.DeathPos := SkillPos;
    Self.SendToVisible(Packet, Packet.Header.size);
  end;
  // tem que continuar transformando tudo em pointer pra isso ficar dinamico
  // tem que terminar de completar a funcao acima de player
  // fazer a de mobs
  // ver se o dungeons la em cima pode encaixar junto
  // dps excluir aqui embaixo
  // 16/03/2021
  {
    if (Self.VisiblePlayers.Count > 0) then
    begin
    for i in Self.VisiblePlayers do
    begin
    if (Servers[Self.ChannelId].Players[i].Base.ClientID = Self.ClientID) then
    Continue;
    if (Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.LastPos.
    InRange(SkillPos, (SkillData[Skill].range * 2.5))) then
    begin
    NewMob := @Servers[Self.ChannelId].Players[i].Base;
    if (NewMob.IsDead) then
    Continue;
    if ((Servers[Self.ChannelId].Players[Self.ClientID]
    .Character.Base.GuildIndex > 0) and
    (Servers[Self.ChannelId].Players[Self.ClientID]
    .Character.Base.GuildIndex = Servers[Self.ChannelId].Players[i]
    .Character.Base.GuildIndex) and
    not(Servers[Self.ChannelId].Players[Self.ClientID].Dueling)) then
    Continue; // mesma guild, se nao tiver duelando
    if (Servers[Self.ChannelId].Players[Self.ClientID].PartyIndex > 0) and
    (Servers[Self.ChannelId].Players[Self.ClientID].PartyIndex = Servers
    [Self.ChannelId].Players[i].PartyIndex) then
    Continue; // mesma party
    if ((Self.Character.Nation = NewMob.Character.Nation) and
    (Servers[Self.ChannelId].Players[Self.ClientID]
    .Character.PlayerKill = False) and
    not(Servers[Self.ChannelId].Players[Self.ClientID].Dueling)) then
    Continue; // mesma nação e pk desligado, se nao tiver duelando
    if (Servers[Self.ChannelId].Players[Self.ClientID].Dueling) then
    begin
    if (i <> Servers[Self.ChannelId].Players[Self.ClientID].DuelingWith)
    then
    Continue;
    if (SecondsBetween(Now, Servers[Self.ChannelId].Players[Self.ClientID]
    .DuelInitTime) <= 15) then
    // fix de atk em area antes do tempo acabar
    Continue;
    end;
    Packet.TargetID := NewMob.ClientID;
    Resisted := False;
    case SkillData[Skill].Classe of
    1, 2: // warrior skill
    begin
    Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted, MoveTarget);
    end;
    11, 12: // templar skill
    begin
    Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    21, 22: // rifleman skill
    begin
    Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    31, 32: // dualgunner skill
    begin
    Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    41, 42: // magician skill
    begin
    Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    51, 52: // cleric skill
    begin
    Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
    Resisted);
    end;
    end;
    Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
    Packet.MobAnimation);
    if (Add_Buff = True) then
    begin
    if not(Resisted) then
    Self.TargetBuffSkill(Skill, Anim, NewMob);
    end;
    Packet.Dano := Dano;
    Packet.DnType := DmgType;
    if (Packet.Dano >= NewMob.Character.CurrentScore.CurHP) then
    begin
    if (Servers[Self.ChannelId].Players[NewMob.ClientID].Dueling) then
    begin
    NewMob.Character.CurrentScore.CurHP := 10;
    end
    else
    begin
    NewMob.Character.CurrentScore.CurHP := 0;
    NewMob.SendEffect($0);
    Packet.MobAnimation := 30;
    NewMob.IsDead := True;
    if (NewMob.Character.Nation > 0) and (Self.Character.Nation > 0)
    then
    begin
    if (NewMob.Character.Nation <> Self.Character.Nation) then
    begin
    Self.PlayerKilled(NewMob);
    end;
    end;
    // Inc(Self.PlayerCharacter.Base.CurrentScore.KillPoint);
    // Servers[Self.ChannelId].Players[Self.ClientId].SendClientMessage
    // ('Seus pontos de PvP foram incrementados em 1.');
    // Self.SendRefreshKills;
    // Self.SendRefreshPoint;
    end;
    end
    else
    begin
    NewMob.RemoveHP(Packet.Dano, False);
    end;
    NewMob.LastReceivedAttack := Now;
    Packet.MobCurrHP := NewMob.Character.CurrentScore.CurHP;
    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
    Packet.DeathPos := SkillPos;
    // Self.SendCurrentHPMP;
    { if (cnt = 0) then
    Self.SendToVisible(Packet, Packet.Header.size)
    else
    Self.SendToVisible(Packet, Packet.Header.size, False);
    Inc(cnt); }
  { end;
    end;
    end;
    if (Self.VisibleMobs.Count > 0) then
    begin
    for i in Self.VisibleMobs do
    begin
    if ((i >= 3048) and (i <= 9147)) then
    begin
    Mobid := TMobFuncs.GetMobGeralID(Self.ChannelId, i, mobpid);
    if (Mobid = -1) then
    Continue;
    /// /////////
    NewMob := @Servers[Self.ChannelId].Mobs.TMobS[Mobid].MobsP[mobpid].Base;
    if (NewMob.IsDead) then
    Continue;
    if ((Servers[Self.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].CurrentPos.Distance(SkillPos) <=
    (SkillData[Skill].range * 2.5))) { or
    ((Servers[Self.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].CurrentPos.Distance(Self.PlayerCharacter.LastPos)
    <= (SkillData[Skill].range)) and (Self.GetMobClass = 2)))
  } { then
    begin
    if ((Servers[Self.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].isGuard) and
    (Servers[Self.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].Base.PlayerCharacter.Base.Nation = Self.
    Character.Nation)) then
    Continue;
    Packet.TargetID := i;
    Resisted := False;
    case SkillData[Skill].Classe of
    1, 2: // warrior skill
    begin
    Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted, MoveTarget);
    end;
    11, 12: // templar skill
    begin
    Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    21, 22: // rifleman skill
    begin
    Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    31, 32: // dualgunner skill
    begin
    Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    41, 42: // magician skill
    begin
    Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    51, 52: // cleric skill
    begin
    Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    end;
    Inc(cnt);
    try
    Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
    Packet.MobAnimation);
    except
    on E: Exception do
    begin // apagar dps isso e mais 2 exceptions
    Logger.Write('Error at AttackParse mob area attack: ' + E.Message,
    TLogType.Warnings);
    end;
    end;
    if (Add_Buff = True) then
    begin
    if not(Resisted) then
    Self.TargetBuffSkill(Skill, Anim, NewMob);
    end;
    Packet.Dano := Dano;
    Packet.DnType := DmgType;
    Servers[Self.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].IsAttacked := True;
    Servers[Self.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].AttackerID := Self.ClientID;
    if (Packet.Dano >= Servers[mob.ChannelId].Mobs.TMobS[NewMob.Mobid]
    .MobsP[NewMob.SecondIndex].HP) then
    begin
    Servers[NewMob.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [mob.SecondIndex].HP := 0;
    Servers[NewMob.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].IsAttacked := False;
    Servers[NewMob.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].AttackerID := 0;
    Servers[NewMob.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].deadTime := Now;
    if (Self.VisibleMobs.Contains(Servers[NewMob.ChannelId].Mobs.TMobS
    [NewMob.Mobid].MobsP[NewMob.SecondIndex].Index)) then
    begin
    Self.VisibleMobs.Remove(Servers[NewMob.ChannelId].Mobs.TMobS
    [NewMob.Mobid].MobsP[NewMob.SecondIndex].Index);
    end;
    NewMob.VisibleMobs.Clear;
    Self.MobKilled(NewMob, DropExp, DropItem, False);
    Packet.MobAnimation := 30;
    Packet.AttackerPos := SkillPos;
    Packet.DeathPos := SkillPos;
    NewMob.LastReceivedAttack := Now;
    Packet.MobCurrHP := 0;
    Self.SendToVisible(Packet, Packet.Header.size);
    NewMob.IsDead := True;
    end
    else
    begin
    Servers[Self.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].HP := Servers[Self.ChannelId].Mobs.TMobS
    [NewMob.Mobid].MobsP[NewMob.SecondIndex].HP - Packet.Dano;
    NewMob.LastReceivedAttack := Now;
    Packet.MobCurrHP := Servers[NewMob.ChannelId].Mobs.TMobS
    [NewMob.Mobid].MobsP[NewMob.SecondIndex].HP;
    Packet.AttackerPos := SkillPos;
    Packet.DeathPos := SkillPos;
    Self.SendToVisible(Packet, Packet.Header.size);
    end;
    end;
    end
    else if (mob.ClientID >= 9148) then
    begin
    NewMob := @Servers[Self.ChannelId].PETS[mob.ClientID].Base;
    if (NewMob.IsDead) then
    Continue;
    if (Servers[Self.ChannelId].PETS[NewMob.ClientID]
    .Base.PlayerCharacter.LastPos.Distance(SkillPos) <=
    (SkillData[Skill].range)) then
    begin
    Packet.TargetID := NewMob.ClientID;
    Resisted := False;
    case SkillData[Skill].Classe of
    1, 2: // warrior skill
    begin
    Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted, MoveTarget);
    end;
    11, 12: // templar skill
    begin
    Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    21, 22: // rifleman skill
    begin
    Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    31, 32: // dualgunner skill
    begin
    Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    41, 42: // magician skill
    begin
    Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    51, 52: // cleric skill
    begin
    Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    end;
    Inc(cnt);
    Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
    Packet.MobAnimation);
    if (Add_Buff = True) then
    begin
    if not(Resisted) then
    Self.TargetBuffSkill(Skill, Anim, NewMob);
    end;
    Packet.Dano := Dano;
    Packet.DnType := DmgType;
    Servers[Self.ChannelId].PETS[NewMob.ClientID].IsAttacked := True;
    Servers[Self.ChannelId].PETS[NewMob.ClientID].AttackerID :=
    Self.ClientID;
    if (Packet.Dano >= NewMob.Character.CurrentScore.CurHP) then
    begin
    NewMob.PlayerCharacter.Base.CurrentScore.CurHP := 0;
    Packet.MobAnimation := 30;
    NewMob.IsDead := True;
    for j in NewMob.VisibleMobs do
    begin
    if not(j >= 3048) then
    begin
    Servers[Self.ChannelId].Players[j].UnSpawnPet(NewMob.ClientID);
    end;
    end;
    Inc(Self.PlayerCharacter.Base.CurrentScore.KillPoint);
    Self.SendRefreshKills;
    Servers[Self.ChannelId].PETS[NewMob.ClientID].Base.Destroy;
    ZeroMemory(@Servers[Self.ChannelId].PETS[NewMob.ClientID],
    sizeof(TPet));
    end
    else
    begin
    NewMob.PlayerCharacter.Base.CurrentScore.CurHP :=
    NewMob.PlayerCharacter.Base.CurrentScore.CurHP - Packet.Dano;
    end;
    NewMob.LastReceivedAttack := Now;
    Packet.MobCurrHP := NewMob.PlayerCharacter.Base.CurrentScore.CurHP;
    // Self.SendCurrentHPMP;
    Self.SendToVisible(Packet, Packet.Header.size);
    end;
    Continue;
    end;
    end;
    end;
    if (cnt = 0) then
    begin
    Logger.Write('Sem alvo disponivel.', TLogType.Packets);
    Packet.TargetID := Self.ClientID;
    /// ////era $7535
    Packet.Dano := 0;
    Packet.DnType := TDamageType.Normal;
    Packet.AttackerPos := SkillPos;
    Packet.DeathPos := SkillPos;
    Self.SendToVisible(Packet, Packet.Header.size);
    end; }
end;
procedure TBaseMob.AttackParse(Skill, Anim: DWORD; mob: PBaseMob;
  var Dano: Integer; var DmgType: TDamageType; out AddBuff: Boolean;
  out MobAnimation: Byte; DataSkill: P_SkillData);
var
  HpPerc, MpPerc: Integer;
  // CriticalResTax: Integer;
  Helper: Integer;
  HelperInByte: Byte;
  Help1: Integer;
  OtherPlayer: PPlayer;
  BoolHelp: Boolean;
begin
  // AddBuff := True;
  if (Skill > 0) then
  begin
    Inc(Dano, (DataSkill^.Damage+Self.PlayerCharacter.HabAtk) div 2);
    /// ///
    //Inc(Dano, Self.PlayerCharacter.HabAtk);
    //Inc(Dano, Self.GetMobAbility(EF_SKILL_DAMAGE));
    Inc(Dano, Self.GetMobAbility(EF_PRAN_SKILL_DAMAGE));
    if(Self.Character <> nil) then
      if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
        Inc(Dano, Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_SKILL_PER_DAMAGE] *
          (Dano div 100));


  end
  else
  begin
    if(Self.GetMobAbility(EF_SPLASH) > 0) then
    begin //efeito de bater em área no ataque básico
      if(SecondsBetween(Now, LastSplashTime) >= 1) then
      begin
        LastSplashTime := Now;

        Self.AreaSkill(177, SkillData[177].Anim, mob, Self.PlayerCharacter.LastPos, @SkillData[177],
          Self.GetMobAbility(EF_SPLASH), 1);
      end;
    end;
  end;

  if(Skill > 0) then
  begin
    if((Self.GetMobClass() = 2) or (Self.GetMobClass() = 4) and
      (SkillData[Skill].Adicional > 0)) then
    begin
      Randomize;

      if(SkillData[Skill].Adicional <= RandomRange(1, 101)) then
        DmgType := Critical;
    end;
  end;

  case DmgType of
    Critical:
      begin
        Dano := Trunc(Dano * 1.5);
        Helper := Self.PlayerCharacter.DamageCritical;
        Helper := Helper - (mob^.PlayerCharacter.ResDamageCritical);
        if (Helper <= 0) then
          Helper := 0;
        if (Helper >= 30) then
          Helper := 30;
        Inc(Dano, ((Dano div 100) * Helper));
      end;
    Double:
      Dano := (Dano * 2);
    {DoubleCritical:
      begin
        Dano := Dano * 3;
        Helper := Self.PlayerCharacter.DamageCritical;
        Helper := Helper - (mob^.PlayerCharacter.ResDamageCritical);
        if (Helper < 10) then
          Helper := 10;
        if (Helper > 100) then
          Helper := 100;
        Inc(Dano, ((Dano div 100) * Helper));
      end;}
  end;
  if (mob^.GetMobAbility(EF_AMP_PHYSICAL) > 0) then
  begin
    Inc(Dano, ((Dano div 100) * mob^.GetMobAbility(EF_AMP_PHYSICAL)));
  end;
  if (mob^.GetMobAbility(EF_TYPE45) > 0) then
  begin // raio solar da santa da 10% a mais de dano em cima da vitima
    Inc(Dano, ((Dano div 100) * 10));
  end;
  if (mob^.BuffExistsByIndex(432)) then
  begin
    Help1 := mob^.GetMobAbility(EF_SKILL_ABSORB1);
    if (Help1 > Dano) then
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque.');
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Você absorveu ' + Dano.ToString + ' pontos de ataque.');
      mob^.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
      Dano := 0;
      DmgType := TDamageType.None;
    end
    else
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque em partes.', 0);
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Você absorveu ' + Help1.ToString + ' pontos de ataque.');
      DecInt(Dano, Help1);
      mob^.RemoveBuffByIndex(432);
    end;
  end;
  if (mob^.BuffExistsByIndex(123)) then
  begin
    Help1 := mob^.GetMobAbility(EF_SKILL_ABSORB1);
    if (Help1 > Dano) then
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque.');
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Você absorveu ' + Dano.ToString + ' pontos de ataque.');
      mob^.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
      Dano := 0;
      DmgType := TDamageType.None;
    end
    else
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque em partes.', 0);
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Você absorveu ' + Help1.ToString + ' pontos de ataque.');
      DecInt(Dano, Help1);
      mob^.RemoveBuffByIndex(123);
    end;
  end;
  if (mob^.BuffExistsByIndex(131)) then
  begin
    Help1 := mob^.GetMobAbility(EF_SKILL_ABSORB1);
    if (Help1 > Dano) then
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque.');
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Você absorveu ' + Dano.ToString + ' pontos de ataque.');
      mob^.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
      Dano := 0;
      DmgType := TDamageType.None;
    end
    else
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque em partes.', 0);
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Você absorveu ' + Help1.ToString + ' pontos de ataque.');
      DecInt(Dano, Help1);
      mob^.RemoveBuffByIndex(131);
    end;
  end;
  if (mob^.BuffExistsByIndex(142)) then
  begin
    Help1 := mob^.GetMobAbility(EF_SKILL_ABSORB2);
    if (Help1 > Dano) then
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque.');
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Você absorveu ' + Dano.ToString + ' pontos de ataque.');
      mob^.DecreasseMobAbility(EF_SKILL_ABSORB2, Dano);
      Dano := 0;
      DmgType := TDamageType.None;
    end
    else
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque em partes.', 0);
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Você absorveu ' + Help1.ToString + ' pontos de ataque.');
      DecInt(Dano, Help1);
      mob^.RemoveBuffByIndex(142);
    end;
  end;
  if (mob^.Polimorfed) then
  begin
    DmgType := TDamageType.DoubleCritical;
    mob^.Polimorfed := False;
    if (mob^.ClientID <= MAX_CONNECTIONS) then
    begin
      mob^.RemoveBuffByIndex(99);
      mob^.SendCreateMob(SPAWN_NORMAL);
    end;
  end;
  if(Self.GetMobAbility(EF_DRAIN_HP) > 0) then
  begin
    HpPerc := Self.GetMobAbility(EF_DRAIN_HP);
    Self.AddHP(((Dano div 100) * HpPerc), True);
  end;
  if(Self.GetMobAbility(EF_DRAIN_MP) > 0) then
  begin
    MpPerc := Self.GetMobAbility(EF_DRAIN_MP);
    Self.AddMP(((Dano div 100) * MpPerc), True);
  end;
  if (Self.GetMobAbility(EF_HP_ATK_RES) > 0) then
  begin
    HpPerc := Self.GetMobAbility(EF_HP_ATK_RES);
    Self.AddHP(((Dano div 100) * HpPerc), True);
  end;
  {if (Self.BuffExistsByIndex(5)) then
  begin
    Help1 := SkillData[Skill].EFV[2];
    Self.AddHP(((Dano div 100) * Help1), True);
  end; }
  //if (mob^.GetMobAbility(EF_MP_EFFICIENCY) > 0) then
  //begin
    //Help1 := ((Dano div 200) * mob^.GetMobAbility(EF_MP_EFFICIENCY));
    // 50% do dano reduzido pelo escudo negro

  if (mob.BuffExistsByIndex(101)) then
  begin
    Help1 := mob.GetMobAbility(EF_HP_CONVERSION);

    Help1 := ((Dano div 100) * Help1);
    if (Help1 >= mob.Character.CurrentScore.CurMP) then
    begin
      mob.RemoveMP((Help1 * (mob.GetMobAbility(EF_MP_EFFICIENCY) div 100)), True);
      mob.RemoveBuffByIndex(101);
    end
    else
      mob.RemoveMP((Help1 * (mob.GetMobAbility(EF_MP_EFFICIENCY) div 100)), True);

    DecInt(Dano, Help1);
    //Dano := Dano - Help1;
  end;
  //end;
  if (mob.BuffExistsByIndex(111)) then
  begin // nevoa fc
    mob.RemoveBuffByIndex(111);
  end;
  if (mob.BuffExistsByIndex(86)) then
  begin // choque dual
    mob.RemoveBuffByIndex(86);
  end;
  if (mob.BuffExistsByIndex(63)) then
  begin // choque att
    mob.RemoveBuffByIndex(63);
  end;
  if (mob.BuffExistsByIndex(153)) then
  begin // predador
    mob.RemoveBuffByIndex(153);
  end;

  if (mob^.ClientID <= MAX_CONNECTIONS) then
  begin
    if ((mob^.Character.Nation <> Self.Character.Nation) and
      (mob^.Character.Nation > 0) and (Self.Character.Nation > 0)) then
    begin
      Inc(Dano, Self.PlayerCharacter.PvPDamage);
      if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
        Inc(Dano, Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_ATK_NATION] *
          (Dano div 100));
      Helper := Dano;
      Inc(Dano, ((Helper div 100) * Self.GetMobAbility(EF_MARSHAL_ATK_NATION)));
      Helper := Dano;
      DecInt(Dano,
        ((Helper div 100) * mob.GetMobAbility(EF_MARSHAL_DEF_NATION)));
      if(Servers[Self.ChannelId].NationID <> Self.Character.Nation) then
        DecInt(Dano, Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_DEF_NATION]
          * (Dano div 100));
      DecInt(Dano, mob.PlayerCharacter.PvPDefense);
    end;
    if(Self.IsSecureArea) then
    begin
      DmgType := None;
      Dano := 0;
      MobAnimation := 0;
      Servers[Self.ChannelId].Players[Self.ClientId].SendClientMessage
        ('Você está em uma área segura, não pode lançar skills.');
      Exit;
    end;
    if(mob^.IsSecureArea) then
    begin
      DmgType := None;
      Dano := 0;
      MobAnimation := 0;
      Servers[Self.ChannelId].Players[Self.ClientId].SendClientMessage
        ('O alvo está dentro de uma área segura e não foi afetado pela sua habilidade.');
      Exit;
    end;
  end
  else
  begin
    if(Servers[Self.ChannelId].NationID = Self.Character.Nation) then
      Inc(Dano, Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_ATK_MONSTER] *
        (Dano div 100));
  end;
  HelperInByte := 0;
  if (Self.IsCompleteEffect5(HelperInByte)) then
  begin
    Randomize;
    Help1 := RandomRange(1, 101);
    if (Help1 <= (RATE_EFFECT5*Length(Self.EFF_5))) then
    begin
      Self.Effect5Skill(mob, HelperInByte);
    end;
  end;
  if (Self.GetMobAbility(EF_DECREASE_PER_DAMAGE1) > 0) then
  begin
    DecInt(Dano,
      ((Dano div 100) * Self.GetMobAbility(EF_DECREASE_PER_DAMAGE1)));
  end;
  if (mob^.GetMobAbility(EF_HP_CONVERSION) > 0) then
  begin
    DecInt(Dano, ((Dano div 100) * mob^.GetMobAbility(EF_HP_CONVERSION)));
  end;
  if (mob^.BuffExistsByIndex(337)) then
  begin // 75
    AddBuff := False;
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('[' + AnsiString(mob.Character.Name) +
      '] resistiu à sua habilidade de ataque.', 16, 1, 1);
    Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
      ('Você resistiu à habilidade de ataque de [' +
      AnsiString(Self.Character.Name) + ']', 16, 1, 1);
  end;
  if (mob^.BuffExistsByIndex(38)) then
  begin
    Help1 := mob^.GetMobAbility(EF_REFLECTION2);
    Self.RemoveHP(((Dano div 100) * Help1), True, True);
    //DecInt(Dano, (Dano div 100) * Help1);
    mob^.RemoveBuffByIndex(38);
    Dano := 0;
    DmgType := TDamageType.None;
  end;
  if (Dano > 0) then
  begin
    Helper := mob^.GetMobAbility(EF_REFLECTION1);
    if (Helper > 0) then
    begin
      Self.RemoveHP(Helper, False, True);
      Self.SendCurrentHPMP(True);
    end;
    if (mob^.BuffExistsByIndex(222)) then
    begin
      Helper := mob^.GetMobAbility(EF_SKILL_ABSORB1);
      if (Helper > 0) then
      begin
        if (Dano >= Helper) then
        begin
          mob^.DecreasseMobAbility(EF_SKILL_ABSORB1, Helper);
          mob^.RemoveBuffByIndex(222);
        end
        else
          mob^.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
        DecInt(Dano, Helper);
      end;
    end;
  end;
  if (mob^.BuffExistsByIndex(32)) then
  begin
    Dec(Dano, ((Dano div 100) * mob.GetMobAbility(EF_POINT_DEFENCE)));
    dec(mob^.DefesaPoints, 1);
    if (mob^.DefesaPoints = 0) then
      mob^.RemoveBuffByIndex(32);
  end;
  if(mob^.BuffExistsByIndex(35) and (Trim(mob.UniaoDivina) <> '')) then
  begin
    Helper := Dano;
    DecInt(Dano, ((Dano div 100) * mob.GetMobAbility(EF_TRANSFER)));
    DecInt(Helper, Dano);
    OtherPlayer := Servers[Self.ChannelId].GetPlayer(mob.UniaoDivina);
    BoolHelp := False;
    if(OtherPlayer <> nil) then
    begin
      if (not(OtherPlayer.Base.IsDead) and (OtherPlayer.Status >= Playing) and
      not(OtherPlayer.SocketClosed)) then
      begin
        OtherPlayer.Base.RemoveHP(Helper, True, True);
        OtherPlayer.Base.LastReceivedAttack := Now;
        OtherPlayer.SendClientMessage('Seu HP foi consumido em ' + Helper.ToString +
        ' pontos pelo buff [União Divina] no membro <' +
        AnsiString(mob.Character.Name) + '>.', 16);
      end
      else
      begin
        mob.RemoveBuffByIndex(35);
        mob.UniaoDivina := '';
        BoolHelp := True;
      end;
    end;
    if not(BoolHelp) then
    begin
      DecInt(mob.MOB_EF[EF_TRANSFER_LIMIT], Helper);
      if(mob.MOB_EF[EF_TRANSFER_LIMIT] = 0) then
      begin
        mob.RemoveBuffByIndex(35);
        mob.UniaoDivina := '';
      end;
    end;
  end;
  if ((mob^.BuffExistsByIndex(36) = True) and not(DataSkill^.Index = 0)
    and (Skill > 0)) then
  begin
    if(DataSkill^.Index = 136) then
    begin
      dec(mob^.BolhaPoints, DataSkill^.Damage);
    end
    else
      dec(mob^.BolhaPoints, 1);

    if (mob^.BolhaPoints = 0) then
    begin
      mob^.RemoveBuffByIndex(36);
      Dano := 0;
      DmgType := TDamageType.None;
      AddBuff := False;
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('[' + AnsiString(mob.Character.Name) +
        '] resistiu à sua habilidade de ataque.', 16, 1, 1);
      Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
        ('Você resistiu ao de ataque de [' +
        AnsiString(Self.Character.Name) + '] Proteção desativada.', 16, 1, 1);
    end
    else
    begin
      Dano := 0;
      DmgType := TDamageType.None;
      AddBuff := False;
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('[' + AnsiString(mob.Character.Name) +
        '] resistiu à sua habilidade de ataque.', 16, 1, 1);
      Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
        ('Você resistiu ao ataque de [' +
        AnsiString(Self.Character.Name) + '] restam ' +
        mob.BolhaPoints.ToString + ' ticks.', 16, 1, 1);
    end;
  end;
  if not(Dano = 0) and not(mob^.ClientID >= 3048) then
  begin
    if (mob^.BuffExistsByIndex(460)) then
    begin
      if (Dano > mob^.Character.CurrentScore.CurHP) then
      begin
        mob^.RemoveBuffByIndex(460);
        mob^.RemoveAllDebuffs;
        mob^.ResolutoPoints := 0;
        mob^.Character.CurrentScore.CurHP :=
          ((mob^.Character.CurrentScore.MaxHP div 100) * 30);
        mob^.Character.CurrentScore.CurMP :=
          ((mob^.Character.CurrentScore.MaxMP div 100) * 25);
        mob^.SendCurrentHPMP(True);
        Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
          ('Você foi revivido graças ao buff [Pedra da Alma].');
        Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
          ('O seu alvo foi revivido graças ao buff [Pedra da Alma].');
      end;
    end;
  end;
  if(mob^.GetMobAbility(EF_ADD_DAMAGE1) > 0) then
  begin //requiem
    Inc(Dano, (mob^.GetMobAbility(EF_ADD_DAMAGE1)*2));
  end;
  if (mob^.BuffExistsByIndex(90)) then
  begin // estripador de dual
    if ((DmgType = Critical) or (DmgType = DoubleCritical)) then
      Self.TargetBuffSkill(6279, 0, mob, @SkillData[6279]);
  end;
  if (mob^.ResolutoPoints > 0) then
  begin
    if (SecondsBetween(Now, mob^.ResolutoTime) >= 8) then
    begin
      mob^.ResolutoPoints := 0;
    end
    else if (AddBuff) then
    begin
      dec(mob^.ResolutoPoints, 1);
      MobAnimation := 26;
      Self.TargetBuffSkill(6879, 0, mob, @SkillData[6879]);
      if(mob.Mobid = 0) then
      begin
        Randomize;
        Helper := RandomRange(1, -2);
        if(Helper = 0) then
          Self.WalkBacked(TPosition.create(mob.PlayerCharacter.LastPos.X-1,
            mob.PlayerCharacter.LastPos.Y+1) , 209, mob)
        else
          Self.WalkBacked(TPosition.create(mob.PlayerCharacter.LastPos.X+Helper,
            mob.PlayerCharacter.LastPos.Y+Helper) , 209, mob);
      end;
    end;
  end;
  {if (mob^.BuffExistsByIndex(134)) then
    if (mob^.Character.CurrentScore.CurHP <
      (mob^.Character.CurrentScore.MaxHP div 2)) then
    begin
      //Helper := mob.GetBuffIDByIndex(134);
      //mob.AddHP(mob.CalcCure2(SkillData[Helper].EFV[0], mob, Helper), True);
      Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
        ('Cura preventiva entrou em ação e feitiço foi desfeito.', 0);
      mob^.RemoveBuffByIndex(134);
    end;}

  if(Self.GetMobClass() = 4) then
  begin
    if(DataSkill.Adicional > 0) then
    begin
      if((mob.GetMobAbility(EF_ACCELERATION1) > 0) or
        (mob.GetMobAbility(EF_ACCELERATION2) > 0) or
        (mob.GetMobAbility(EF_ACCELERATION3) > 0)) then
      begin
        Dano := Dano + DataSkill.Adicional;
      end;
    end;
  end;

  if((mob.ClientID >= 3048) and (mob.ClientID <= 9147)) then
  begin
    if(Self.GetMobAbility(EF_ATK_MONSTER) > 0) then
    begin
      Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_MONSTER)));
    end;
    if(mob.GetMobAbility(197) > 0) then
    begin
      if(Self.GetMobAbility(EF_ATK_UNDEAD) > 0) then
      begin
        Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_UNDEAD)));
      end;

      if(Self.GetMobAbility(EF_ATK_DEMON) > 0) then
      begin
        Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_DEMON)));
      end;
    end;
    if(Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobType >= 1024) then
    begin
      case (Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobType-1024) of
        0: //humanoide
          begin
            if(Self.GetMobAbility(EF_ATK_ALIEN) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_ALIEN)));
            end;
          end;

        1: //animal
          begin
            if(Self.GetMobAbility(EF_ATK_BEAST) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_BEAST)));
            end;
          end;

        2: //plantas
          begin
            if(Self.GetMobAbility(EF_ATK_PLANT) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_PLANT)));
            end;
          end;

        3: //inseto
          begin
            if(Self.GetMobAbility(EF_ATK_INSECT) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_INSECT)));
            end;
          end;

        4: //demonio
          begin
            if(Self.GetMobAbility(EF_ATK_DEMON) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_DEMON)));
            end;
          end;

        5: //morto vivo
          begin
            if(Self.GetMobAbility(EF_ATK_UNDEAD) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_UNDEAD)));
            end;
          end;

        6: //misto
          begin
            if(Self.GetMobAbility(EF_ATK_COMPLEX) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_COMPLEX)));
            end;
          end;

        7: //estrutura
          begin
            if(Self.GetMobAbility(EF_ATK_STRUCTURE) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_STRUCTURE)));
            end;
          end;

        else
          begin
            if(Self.GetMobAbility(EF_ATK_UNDEAD) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_UNDEAD)));
            end;

            if(Self.GetMobAbility(EF_ATK_DEMON) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_DEMON)));
            end;
          end;
      end;
    end;
    {else
    begin
      case (Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobType) of
        0: //humanoide
          begin
            if(Self.GetMobAbility(EF_ATK_ALIEN) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_ALIEN)));
            end;
          end;

        1: //animal
          begin
            if(Self.GetMobAbility(EF_ATK_BEAST) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_BEAST)));
            end;
          end;

        2: //plantas
          begin
            if(Self.GetMobAbility(EF_ATK_PLANT) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_PLANT)));
            end;
          end;

        3: //inseto
          begin
            if(Self.GetMobAbility(EF_ATK_INSECT) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_INSECT)));
            end;
          end;

        4: //demonio
          begin
            if(Self.GetMobAbility(EF_ATK_DEMON) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_DEMON)));
            end;
          end;

        5: //morto vivo
          begin
            if(Self.GetMobAbility(EF_ATK_UNDEAD) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_UNDEAD)));
            end;
          end;

        6: //misto
          begin
            if(Self.GetMobAbility(EF_ATK_COMPLEX) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_COMPLEX)));
            end;
          end;

        7: //estrutura
          begin
            if(Self.GetMobAbility(EF_ATK_STRUCTURE) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_STRUCTURE)));
            end;
          end;

        else
          begin
            if(Self.GetMobAbility(EF_ATK_UNDEAD) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_UNDEAD)));
            end
            else if(Self.GetMobAbility(EF_ATK_DEMON) > 0) then
            begin
              Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_DEMON)));
            end;
          end;
      end;
    end; }
  end;

  if(Dano > 999999) then
    Dano := 1;

  if(Dano < 0) then
    Dano := 1;
end;
procedure TBaseMob.AttackParseForMobs(Skill, Anim: DWORD; mob: PBaseMob; var Dano: Integer;
  var DmgType: TDamageType; out AddBuff: Boolean; out MobAnimation: Byte);
var
  HpPerc, MpPerc: Integer;
  // CriticalResTax: Integer;
  Helper: Integer;
  HelperInByte: Byte;
  Help1: Integer;
  OtherPlayer: PPlayer;
begin
  if (mob.GetMobAbility(EF_AMP_PHYSICAL) > 0) then
  begin
    Inc(Dano, ((Dano div 100) * mob.GetMobAbility(EF_AMP_PHYSICAL)));
  end;

  if (mob.GetMobAbility(EF_TYPE45) > 0) then
  begin // raio solar da santa da 10% a mais de dano em cima da vitima
    Inc(Dano, ((Dano div 100) * 10));
  end;

  if ((mob.BuffExistsByIndex(432)) and (Dano > 0)) then
  begin
    Help1 := mob.GetMobAbility(EF_SKILL_ABSORB1);
    if (Help1 > Dano) then
    begin
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Você absorveu o ataque em ' + Dano.ToString + ' pontos.');
      mob.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
      Dano := 0;
      DmgType := TDamageType.None;
    end
    else
    begin
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Você absorveu o ataque em ' + Help1.ToString + ' pontos.');
      DecInt(Dano, Help1);
      mob.RemoveBuffByIndex(432);
    end;
  end;

  if ((mob.BuffExistsByIndex(123)) and (Dano > 0)) then
  begin
    Help1 := mob.GetMobAbility(EF_SKILL_ABSORB1);
    if (Help1 > Dano) then
    begin
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Você absorveu o ataque em ' + Dano.ToString + ' pontos.');
      mob.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
      Dano := 0;
      DmgType := TDamageType.None;
    end
    else
    begin
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Você absorveu o ataque em ' + Help1.ToString + ' pontos.');
      DecInt(Dano, Help1);
      mob.RemoveBuffByIndex(123);
    end;
  end;

  if ((mob.BuffExistsByIndex(131)) and (Dano > 0)) then
  begin
    Help1 := mob.GetMobAbility(EF_SKILL_ABSORB1);
    if (Help1 > Dano) then
    begin
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Você absorveu o ataque em ' + Dano.ToString + ' pontos.');
      mob.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
      Dano := 0;
      DmgType := TDamageType.None;
    end
    else
    begin
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Você absorveu o ataque em ' + Help1.ToString + ' pontos.');
      DecInt(Dano, Help1);
      mob.RemoveBuffByIndex(131);
    end;
  end;

  if ((mob.BuffExistsByIndex(142)) and (Dano > 0)) then
  begin
    Help1 := mob.GetMobAbility(EF_SKILL_ABSORB2);
    if (Help1 > Dano) then
    begin
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Você absorveu o ataque em ' + Dano.ToString + ' pontos.');
      mob.DecreasseMobAbility(EF_SKILL_ABSORB2, Dano);
      Dano := 0;
      DmgType := TDamageType.None;
    end
    else
    begin
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Você absorveu o ataque em ' + Help1.ToString + ' pontos.');
      DecInt(Dano, Help1);
      mob.RemoveBuffByIndex(142);
    end;
  end;

  if (mob.Polimorfed) then
  begin
    DmgType := TDamageType.DoubleCritical;
    mob.Polimorfed := False;

    if (mob.ClientID <= MAX_CONNECTIONS) then
    begin
      mob.RemoveBuffByIndex(99);
      mob.SendCreateMob(SPAWN_NORMAL);
    end;
  end;

  if (mob.BuffExistsByIndex(101)) then
  begin
    Help1 := mob.GetMobAbility(EF_HP_CONVERSION);

    Help1 := ((Dano div 100) * Help1);
    if (DWORD(Help1) >= mob.Character.CurrentScore.CurMP) then
    begin
      mob.RemoveMP((Help1 * (mob.GetMobAbility(EF_MP_EFFICIENCY) div 100)), True);
      mob.RemoveBuffByIndex(101);
    end
    else
      mob.RemoveMP((Help1 * (mob.GetMobAbility(EF_MP_EFFICIENCY) div 100)), True);

    decint(Dano, Help1);
  end;

  if (mob.BuffExistsByIndex(111)) then
  begin // nevoa fc
    mob.RemoveBuffByIndex(111);
  end;

  if (mob.BuffExistsByIndex(86)) then
  begin // choque dual
    mob.RemoveBuffByIndex(86);
  end;

  if (mob.BuffExistsByIndex(63)) then
  begin // choque att
    mob.RemoveBuffByIndex(63);
  end;

  if (mob.BuffExistsByIndex(153)) then
  begin // predador
    mob.RemoveBuffByIndex(153);
  end;

  HelperInByte := 0;

  if (mob.GetMobAbility(EF_HP_CONVERSION) > 0) then
  begin
    DecInt(Dano, ((Dano div 100) * mob.GetMobAbility(EF_HP_CONVERSION)));
  end;

  if (mob.BuffExistsByIndex(38)) then
  begin
    Help1 := mob.GetMobAbility(EF_REFLECTION2);

    if(not(mob.IsPlayer) and not(Self.IsDungeonMob)) then
    begin
      Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP[Self.SecondIndex].HP :=
       Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP[Self.SecondIndex].HP -
       ((Dano div 100) * Help1);
      Self.SendCurrentHPMPMob();
    end;

    Dano := 0;
    DmgType := TDamageType.None;

    mob.RemoveBuffByIndex(38);
  end;

  if (Dano > 0) then
  begin
    Helper := mob.GetMobAbility(EF_REFLECTION1);
    if (Helper > 0) then
    begin
      if(not(mob.IsPlayer) and not(Self.IsDungeonMob)) then
      begin
        Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP[Self.SecondIndex].HP :=
         Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP[Self.SecondIndex].HP -
         ((Dano div 100) * Help1);
        Self.SendCurrentHPMPMob();
      end;
    end;

    if (mob.BuffExistsByIndex(222)) then
    begin
      Helper := mob.GetMobAbility(EF_SKILL_ABSORB1);

      if (Helper > 0) then
      begin
        if (Dano >= Helper) then
        begin
          mob.DecreasseMobAbility(EF_SKILL_ABSORB1, Helper);
          mob.RemoveBuffByIndex(222);
        end
        else
          mob.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);

        Dec(Dano, Helper);
      end;
    end;
  end;

  if (mob.BuffExistsByIndex(32)) then
  begin
    DecInt(Dano, ((Dano div 100) * mob.GetMobAbility(EF_POINT_DEFENCE)));

    Dec(mob.DefesaPoints, 1);

    if (mob.DefesaPoints = 0) then
      mob.RemoveBuffByIndex(32);
  end;

  if(mob.BuffExistsByIndex(35) and (Trim(mob.UniaoDivina) <> '')) then
  begin
    Helper := Dano;

    DecInt(Dano, ((Dano div 100) * mob.GetMobAbility(EF_TRANSFER)));

    decInt(Helper, Dano);

    OtherPlayer := Servers[Self.ChannelId].GetPlayer(mob.UniaoDivina);

    if(Assigned(OtherPlayer)) then
    begin
      if (not(OtherPlayer.Base.IsDead) and (OtherPlayer.Status >= Playing)) then
      begin
        OtherPlayer.Base.RemoveHP(Helper, True, True);
        OtherPlayer.SendClientMessage('Seu HP foi consumido em ' + Helper.ToString +
        ' pontos pelo buff [União Divina] no membro <' +
        AnsiString(OtherPlayer.Base.Character.Name) + '>.', 16);
      end;
    end;

    DecInt(mob.MOB_EF[EF_TRANSFER_LIMIT], Helper);

    if(mob.MOB_EF[EF_TRANSFER_LIMIT] = 0) then
    begin
      mob.RemoveBuffByIndex(35);
      mob.UniaoDivina := '';
    end;
  end;

  if not(Dano = 0) and not(mob.ClientID >= 3048) then
  begin
    if (mob.BuffExistsByIndex(460)) then
    begin
      if (Dano > mob.Character.CurrentScore.CurHP) then
      begin
        mob.RemoveBuffByIndex(460);
        mob.RemoveAllDebuffs;
        mob.ResolutoPoints := 0;
        mob.Character.CurrentScore.CurHP :=
          ((mob.Character.CurrentScore.MaxHP div 100) * 30);
        mob.Character.CurrentScore.CurMP :=
          ((mob.Character.CurrentScore.MaxMP div 100) * 25);
        mob.SendCurrentHPMP(True);
        Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
          ('Você foi revivido graças ao buff [Pedra da Alma].');
      end;
    end;
  end;

  if(mob.BuffExistsByIndex(80)) then
  begin //requiem
    Inc(Dano, mob.GetMobAbility(EF_ADD_DAMAGE1));
  end;

  if (mob.BuffExistsByIndex(90)) then
  begin // estripador de dual
    if ((DmgType = Critical) or (DmgType = DoubleCritical)) then
      mob.TargetBuffSkill(6279, 0, mob, @SkillData[6279]);
  end;

  if (mob.ResolutoPoints > 0) then
  begin
    if (SecondsBetween(Now, mob.ResolutoTime) >= 8) then
    begin
      mob.ResolutoPoints := 0;
    end
    else if (AddBuff) then
    begin
      dec(mob.ResolutoPoints, 1);
      MobAnimation := 26;
      mob.TargetBuffSkill(6879, 0, mob, @SkillData[6879]);
    end;
  end;

  {if (mob.BuffExistsByIndex(134)) then
    if (mob.Character.CurrentScore.CurHP <
      (mob.Character.CurrentScore.MaxHP div 2)) then
    begin
      //Helper := mob.GetBuffIDByIndex(134);
      //mob.AddHP(mob.CalcCure2(SkillData[Helper].EFV[0], mob, Helper), True);
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
          ('Cura preventiva entrou em ação e feitiço foi desfeito.', 0);
      mob.RemoveBuffByIndex(134);
    end; }

  case (Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobType-1024) of
    0: //humanoide
      begin
        if(mob.GetMobAbility(EF_DEF_ALIEN) > 0) then
        begin
          DecInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_ALIEN)));
        end;
      end;

    1: //animal
      begin
        if(mob.GetMobAbility(EF_DEF_BEAST) > 0) then
        begin
          DecInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_BEAST)));
        end;
      end;

    2: //plantas
      begin
        if(mob.GetMobAbility(EF_DEF_PLANT) > 0) then
        begin
          DecInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_PLANT)));
        end;
      end;

    3: //inseto
      begin
        if(mob.GetMobAbility(EF_DEF_INSECT) > 0) then
        begin
          DecInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_INSECT)));
        end;
      end;

    4: //demonio
      begin
        if(mob.GetMobAbility(EF_DEF_DEMON) > 0) then
        begin
          DecInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_DEMON)));
        end;
      end;

    5: //morto vivo
      begin
        if(mob.GetMobAbility(EF_DEF_UNDEAD) > 0) then
        begin
          DecInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_UNDEAD)));
        end;
      end;

    6: //misto
      begin
        if(mob.GetMobAbility(EF_DEF_COMPLEX) > 0) then
        begin
          DecInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_COMPLEX)));
        end;
      end;

    7: //estrutura
      begin
        if(mob.GetMobAbility(EF_DEF_STRUCTURE) > 0) then
        begin
          DecInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_STRUCTURE)));
        end;
      end;
  end;

  if(Dano < 0) then
    Dano := 1;

end;
procedure TBaseMob.Effect5Skill(mob: PBaseMob; EffCount: Byte; xPassive: Boolean);
var
  Packet: TRecvDamagePacket;
  Skill: Integer;
  i, cnt: Integer;
  FRand: Integer;
  PList: Array [0 .. 2] of WORD;
  MobsP: PMobSPoisition;
begin
  // if (mob^.ClientID >= 3048) then
  // Exit; // mais pra frente setar aqui pra atacar eff5 em mobs tbm
  if (EffCount > 1) then
  begin // se tiver mais de 1 efeito 5 equipado, escolher entre eles
    ZeroMemory(@PList, 6);
    cnt := 0;
    for i := 0 to 2 do
    begin
      if (EFF_5[i] > 0) then
      begin
        PList[cnt] := EFF_5[i];
        Inc(cnt);
      end;
    end;
    Randomize;
    FRand := RandomRange(1, (cnt + 1));
    Skill := PList[FRand - 1];
  end
  else
  begin
    for i := 0 to 2 do
    begin
      if (EFF_5[i] > 0) then
      begin
        Skill := EFF_5[i];
        break;
      end;
    end;
  end;
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $102;
  Packet.SkillID := Skill;
  Packet.AttackerPos := Self.PlayerCharacter.LastPos;
  Packet.AttackerID := Self.ClientID;
  Packet.Animation := SkillData[Skill].Anim;
  Packet.AttackerHP := Self.Character.CurrentScore.CurHP;
  Packet.MobAnimation := SkillData[Skill].TargetAnimation;
  if ((SkillData[Skill].TargetType = 21) and not(xPassive)) then
  begin
    Packet.TargetID := mob^.ClientID;
    Self.TargetBuffSkill(Skill, SkillData[Skill].Anim, mob, @SkillData[Skill]);
    Packet.Dano :=
      ((PlayerCharacter.Base.CurrentScore.DNFis +
      PlayerCharacter.Base.CurrentScore.DNMAG) div 3);

    if(SkillData[Skill].Damage > 0) then
    begin
      Packet.Dano := Packet.Dano + SkillData[Skill].Damage;
    end;
    { Self.GetDamage(Skill, mob, Packet.DnType); }
    Packet.DnType := TDamageType.Critical;
    if (SkillData[Skill].Adicional > 0) then
    begin
      Packet.Dano := (Packet.Dano * 2);
    end;
    if(Packet.DANO >= 20000) then
    begin
      Packet.DANO := 20000;
    end;
    Randomize;
    Packet.Dano := Packet.Dano + RandomRange(20, 200);

    if(SkillData[Skill].Index = 180) then
    begin
      mob.RemoveBuff(mob.GetBuffToRemove);
    end;

    {
      if (mob.ClientId >= 3048) then
      begin
      if (Packet.Dano >= Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobsP
      [mob.SecondIndex].HP) then
      begin
      Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobsP
      [mob.SecondIndex].HP := 0;
      Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobsP[mob.SecondIndex]
      .IsAttacked := False;
      Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobsP[mob.SecondIndex]
      .AttackerID := 0;
      Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobsP[mob.SecondIndex]
      .DeadTime := Now;
      if (Self.VisibleMobs.Contains(Servers[mob.ChannelId].MOBS.TMobS
      [mob.Mobid].MobsP[mob.SecondIndex].Index)) then
      Self.VisibleMobs.Remove(Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid]
      .MobsP[mob.SecondIndex].Index);
      mob.VisibleMobs.Clear;
      Servers[Self.ChannelId].Players[Self.ClientId]
      .AddExp(Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobExp,
      EXP_TYPE_MOB);
      Servers[Self.ChannelId].Players[Self.ClientId].SendClientMessage
      ('Você recebeu ' + AnsiString(Servers[mob.ChannelId].MOBS.TMobS
      [mob.Mobid].MobExp.ToString) + ' pontos de experiência.', 0);
      mob.SendEffect($0);
      Packet.MobAnimation := 30;
      mob.IsDead := True;
      end
      else
      begin
      mob.RemoveHP(Packet.Dano, False);
      end;
      mob.LastReceivedAttack := Now;
      Packet.MobCurrHP := mob.Character.CurrentScore.CurHP;
      Self.SendCurrentHPMP;
      Self.SendToVisible(Packet, Packet.Header.size);
      Exit;
      end;
    }
    if (mob^.ClientID >= 3048) then
    begin
      case mob^.ClientID of
        3340 .. 3354:
          begin // stones
            if (Packet.Dano >= Servers[Self.ChannelId].DevirStones[mob^.ClientID]
              .PlayerChar.Base.CurrentScore.CurHP) then
            begin
              //mob^.IsDead := True;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := 100;
              //Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                //.IsAttacked := False;
              //Servers[Self.ChannelId].DevirStones[mob^.ClientID].AttackerID := 0;
              //Servers[Self.ChannelId].DevirStones[mob^.ClientID].deadTime := Now;
              //Servers[Self.ChannelId].DevirStones[mob^.ClientID].KillStone(mob^.ClientID,
              //Self.ClientId);
              //if (Self.VisibleNPCs.Contains(mob^.ClientID)) then
             // begin
             //   Self.VisibleNPCs.Remove(mob^.ClientID);
              //  Self.RemoveTargetFromList(mob);
             //   // essa skill tem retorno no caso de erro
             // end;
             // mob^.VisibleMobs.Clear;
             // // Self.MobKilled(mob, DropExp, DropItem, False);
             // Packet.MobAnimation := 30;
            end
            else
            begin
              deccardinal(Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP, Packet.Dano);
            end;
            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := Servers[Self.ChannelId].DevirStones[mob^.ClientID]
              .PlayerChar.Base.CurrentScore.CurHP;
            Packet.TargetID :=
              Servers[Self.ChannelId].DevirStones[mob^.ClientID].Base.ClientID;
            Self.SendToVisible(Packet, Packet.Header.size);
            //Sleep(1);
            Exit;
          end;
        3355 .. 3369:
          begin // guards
            if (Packet.Dano >= Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
              .PlayerChar.Base.CurrentScore.CurHP) then
            begin
              //mob^.IsDead := True;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := 100;
             // Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
              //  .IsAttacked := False;
              //Servers[Self.ChannelId].DevirGuards[mob^.ClientID].AttackerID := 0;
              //Servers[Self.ChannelId].DevirGuards[mob^.ClientID].deadTime := Now;
             // Servers[Self.ChannelId].DevirGuards[mob^.ClientID].KillGuard(mob^.ClientID,
              //Self.ClientId);
              //if (Self.VisibleNPCs.Contains(mob^.ClientID)) then
              //begin
              //  Self.VisibleNPCs.Remove(mob^.ClientID);
              //  Self.RemoveTargetFromList(mob);
              //  // essa skill tem retorno no caso de erro
             // end;
             // mob^.VisibleMobs.Clear;
              // Self.MobKilled(mob, DropExp, DropItem, False);
             // Packet.MobAnimation := 30;
            end
            else
            begin
              deccardinal(Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP, Packet.DANO);
            end;
          mob^.LastReceivedAttack := Now;
          Packet.MobCurrHP := Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
            .PlayerChar.Base.CurrentScore.CurHP;
          Packet.TargetID := Servers[Self.ChannelId].DevirGuards[mob^.ClientID].Base.ClientID;
          Self.SendToVisible(Packet, Packet.Header.size);
          //Sleep(1);
          Exit;
        end;
      else
        begin
          MobsP := @Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid].MobsP
            [mob.SecondIndex];
          if (Packet.Dano >= MobsP^.HP) then
          begin
            MobsP^.HP := 10;
          end
          else
          begin
            deccardinal(MobsP^.HP, Packet.Dano);
          end;
          mob^.LastReceivedAttack := Now;
          Packet.MobCurrHP := MobsP^.HP;
          Packet.TargetID := MobsP.Base.ClientID;
          Self.SendToVisible(Packet, Packet.Header.size, True);
          //Sleep(1);
        end;
      end;
    end
    else
    begin
      if (Packet.Dano >= mob^.Character.CurrentScore.CurHP) then
      begin
        mob^.Character.CurrentScore.CurHP := 100;
      end
      else
      begin
        mob^.RemoveHP(Packet.Dano, False);
      end;
      mob^.LastReceivedAttack := Now;
      Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;
      Packet.TargetID := mob.ClientID;
      Self.SendToVisible(Packet, Packet.Header.size, True);
      //Sleep(1);
    end;
  end
  else
  begin
    if not(SkillData[Skill].TargetType = 21) then
    begin
      Packet.TargetID := Self.ClientID;
      Packet.AttackerID := 0;
      Packet.Dano := 0;
      Packet.DnType := TDamageType.None;
      Packet.MobAnimation := SkillData[Skill].TargetAnimation;
      Self.SelfBuffSkill(Skill, SkillData[Skill].Anim, mob,
        TPosition.Create(0, 0));
      Packet.MobCurrHP := Self.Character.CurrentScore.CurHP;
      Self.SendToVisible(Packet, Packet.Header.size);
      //Sleep(1);
    end;
  end;
end;
function TBaseMob.IsSecureArea(): Boolean;
var
  i: Integer;
begin
  Result := False;
  for I := 0 to 9 do
  begin
    {if(Servers[Self.ChannelId].SecureAreas[i].IsActive) then
    begin
      if(Servers[Self.ChannelId].SecureAreas[i].Position.InRange(
        Self.PlayerCharacter.LastPos, 8)) then
      begin
        Result := True;
      end;
    end;}
  end;
end;
procedure TBaseMob.WarriorSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    ATAQUE_PODEROSO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
    AVANCO_PODEROSO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
        case mob.ClientId of
          1..1000: //MAX_CONNECTIONS players
            begin
              Self.WalkAvanced(mob.PlayerCharacter.LastPos, Skill);
            end;
          3048..9147: //mobs
            begin
              case mob.ClientId of
                3340..3354: //stones
                  begin
                    Self.WalkAvanced(Servers[Self.ChannelId].DevirStones[mob.ClientID].PlayerChar.LastPos,
                      Skill);
                  end;
                3355..3369: //guards
                  begin
                    Self.WalkAvanced(Servers[Self.ChannelId].DevirGuards[mob.ClientID].PlayerChar.LastPos,
                      Skill);
                  end;
              else //mobs normais
                begin
                  Self.WalkAvanced(Servers[Self.ChannelId].MOBS.TMobS[mob.MobID].MobsP[mob.SecondIndex].CurrentPos,
                    Skill);
                end;
              end;
            end;
        end;
        // Self.WalkinTo(Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobsP
        // [mob.SecondIndex].CurrentPos)
        // else
        // Self.WalkinTo(mob.PlayerCharacter.LastPos);
      end;
    QUEBRAR_ARMADURA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    INCITAR:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    RESOLUTO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, 0, mob, Dano)) then
        begin
          mob.ResolutoPoints := SkillData[Skill].Damage;
          mob.ResolutoTime := Now;
          mob.TargetBuffSkill(6879, 0, mob, @SkillData[6879]);
        end;
      end;
    ESTOCADA:
      begin
        DmgType := Self.GetDamageType2(Skill, True, mob);

        Dano := 0;

        if (Self.ValidAttack(DmgType, 0, mob, Dano, True)) then
        begin
          CanDebuff := True;
        end;

      end;
    FERIDA_MORTAL:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, SILENCE_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    PANCADA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, 0)) then
        begin
          Inc(Dano, ((Self.Character.CurrentScore.CurHP div 100) *
            SkillData[Skill].Adicional));
        end;
      end;
  end;
end;
procedure TBaseMob.TemplarSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    STIGMA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    PROFICIENCIA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    NEMESIS:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    TRAVAR_ALVO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    ATRACAO_DIVINA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
        // if (mob.ClientId >= 3048) then
        // Self.WalkinTo(Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobsP
        // [mob.SecondIndex].CurrentPos)
        // else
        // Self.WalkinTo(mob.PlayerCharacter.LastPos);
      end;
    CARGA_DIVINA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
        if (mob.ClientID >= 3048) then
          Self.WalkinTo(Servers[Self.ChannelId].Mobs.TMobS[mob.Mobid].MobsP
            [mob.SecondIndex].CurrentPos)
        else
          Self.WalkinTo(mob.PlayerCharacter.LastPos);
      end;
  end;
end;
procedure TBaseMob.RiflemanSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
var
  Helper: Int64;
begin
  case SkillData[Skill].Index of
    ELIMINACAO:
      begin
        Dano := 0; // Self.GetDamage(Skill, mob, DmgType);

        if (mob.GetMobAbility(EF_IMMUNITY) > 0) then
        begin
          DmgType := TDamageType.Immune;
          Exit;
        end;
        if (mob.BuffExistsByIndex(19)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(19);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(19);
            DmgType := TDamageType.Block;
            Exit;
          end;
        end;
        if (mob.BuffExistsByIndex(91)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(91);
            DmgType := TDamageType.Miss2;
            Exit;
          end;
        end;

        DmgType := Self.GetDamageType3(Skill, True, mob);

        if(ValidAttack(DmgType, 0, mob, 0)) then
        begin
          mob.RemoveBuffs(1);
        end;
      end;
    TIRO_FATAL:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    TIRO_ANGULAR:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
    TIRO_NA_PERNA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, LENT_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    PERSEGUIDOR:
      begin
        Dano := 0;//Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, True, mob);
        if (Self.ValidAttack(DmgType, 0, mob, Dano, True)) then
        begin
          CanDebuff := True;
        end;
      end;
    PRIMEIRO_ENCONTRO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    ELIMINAR_ALVO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
    PONTO_VITAL:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    MARCA_PERSEGUIDOR:
      begin
        DmgType := Self.GetDamageType3(Skill, True, mob);

        Dano := 0;

        if(DmgType = Miss) then
          Exit;

        if (mob.GetMobAbility(EF_IMMUNITY) > 0) then
        begin
          DmgType := TDamageType.Immune;
          Exit;
        end;
        if (mob.BuffExistsByIndex(19)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(19);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(19);
            DmgType := TDamageType.Block;
            Exit;
          end;
        end;
        if (mob.BuffExistsByIndex(91)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(91);
            DmgType := TDamageType.Miss2;
            Exit;
          end;
        end;

        if (Self.ValidAttack(DmgType, 0, mob, Dano, True)) then
        begin
          CanDebuff := True;
        end;
      end;
    CONTRA_GOLPE:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
          Helper := ((Dano div 100) * SkillData[Skill].Adicional);
          Inc(Dano, Helper);
          DmgType := TDamageType.Critical;
        end;
      end;
    ATAQUE_ATORDOANTE:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    INSPIRAR_MATANCA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Helper := ((Dano div 100) * SkillData[Skill].Adicional);
          Inc(Self.Character.CurrentScore.CurHP, Helper);
          if (mob.ClientID <= MAX_CONNECTIONS) then
          begin
            if (Dano >= mob.Character.CurrentScore.CurHP) then
            begin
              Inc(Self.Character.CurrentScore.CurHP,
                ((Self.Character.CurrentScore.MaxHP div 100) * 25));
            end;
          end;
          Self.SendCurrentHPMP(True);
        end;
      end;
    SENTENCA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Randomize;
          Helper := Random(100);
          if (Helper <= UInt64(SkillData[Skill].DamageRange - 20)) then
          begin
            Dano := Dano + Dano;
          end;
        end;
      end;
    POSTURA_FANTASMA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Self.SelfBuffSkill(SkillData[Skill].Adicional, Anim, mob,
            TPosition.Create(0, 0));
        end;
      end;
    DESTINO:
      begin
        // verificar se está oculto Dano + Adicional
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Helper := (mob.Character.CurrentScore.DEFFis shr 3);
          Inc(Dano, Helper);
          Self.SelfBuffSkill(SkillData[Skill].Adicional, Anim, mob,
            TPosition.Create(0, 0));
        end;
      end;
  end;
end;
procedure TBaseMob.DualGunnerSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
var
  Helper: Int64;
begin
  case SkillData[Skill].Index of
    MJOLNIR:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    ESPINHO_VENENOSO:
      begin
        Dano := 0; //Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, True, mob);
        if (Self.ValidAttack(DmgType, PARALISYS_TYPE, mob, 0, True)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    TIRO_DESCONTROLADO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
    VENENO_LENTIDAO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, LENT_TYPE, mob, 0, True)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    REQUIEM:
      begin
        // configurar o getDamage para reconhecer o dano de cada ataque
        Dano := 0;//Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, True, mob);
        if (Self.ValidAttack(DmgType, 0, mob, 0, True)) then
        begin
          CanDebuff := True;
        end;
      end;
    VENENO_MANA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Helper := SkillData[Skill].Adicional;
          Inc(Dano, Helper);
          mob.RemoveMP(Helper, True);
          Self.AddMP(Helper, True);
          CanDebuff := True;
        end;
      end;
    CHOQUE_SUBITO:
      begin
        Dano := 0; // Self.GetDamage(Skill, mob, DmgType);
        DmgType := Normal;

        if (mob.GetMobAbility(EF_IMMUNITY) > 0) then
        begin
          DmgType := TDamageType.Immune;
        end;
        if (mob.BuffExistsByIndex(19)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(19);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(19);
            DmgType := TDamageType.Block;
          end;
        end;
        if (mob.BuffExistsByIndex(91)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(91);
            DmgType := TDamageType.Miss2;
          end;
        end;

        if (Self.ValidAttack(DmgType, CHOCK_TYPE, mob, Dano)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    NEGAR_CURA:
      begin // configurar cura para transformar em dano
        Dano := 0; //Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, True, mob);
        if (Self.ValidAttack(DmgType, 0, mob, Dano)) then
        begin
          CanDebuff := True;
        end;
      end;
    ESTRIPADOR:
      begin // configurar o getDamage para a cada critico = stun
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    VENENO_HIDRA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    CHOQUE_HIDRA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, CHOCK_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    DOR_PREDADOR:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          // no getDamage, a cada ataque = ++HP
          CanDebuff := True;
        end;
      end;
    MORTE_DECIDIDA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Randomize;
          Helper := Random(100);
          if (Helper < 30) then
            Helper := 30;
          Helper := (((SkillData[Skill].Damage + 1000) div 100) * Helper);
          Inc(Dano, Helper);
        end;
      end;
    REACAO_CADEIA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          // a cada debuff = Dano + (Adicional * qnt de debuff)
        end;
      end;
    BOMBA_MALDITA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          // a cada buff = Dano + (Adicional * qnt de buff)
          CanDebuff := True;
        end;
      end;
  end;
end;
procedure TBaseMob.MagicianSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
var
  Helper: Int64;
begin
  case SkillData[Skill].Index of
    CHAMA_CAOTICA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    SOFRIMENTO:
      begin
        Dano := 0; //Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, False, mob);
        if (Self.ValidAttack(DmgType, 0, mob, 0, True)) then
        begin
          CanDebuff := True;
        end;
      end;
    POLIMORFO:
      begin
        Dano := 0; //Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, False, mob);

        if (Self.ValidAttack(DmgType, 0, mob, 0)) then
        begin
          CanDebuff := True;
        end;
      end;
    ONDA_CHOQUE:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    INFERNO_CAOTICO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    IMPEDIMENTO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, SILENCE_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    CORROER:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Helper := ((Dano div 100) * SkillData[Skill].Adicional);
          Inc(Self.Character.CurrentScore.CurHP, Helper);
          Self.SendCurrentHPMP(True);
        end;
      end;
    LANCA_RAIO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    MAO_ESCURIDAO:
      begin
        Dano := 0;//Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, False, mob);
        if (Self.ValidAttack(DmgType, 0, mob, 0, True)) then
        begin
          CanDebuff := True;
        end;
      end;
    VINCULO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Helper := ((Dano div 100) * SkillData[Skill].Adicional);
          Self.RemoveHP(Helper, True);
        end;
      end;
    CRISTALIZAR_MANA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Helper := 0;
          if (mob.ClientID <= MAX_CONNECTIONS) then
            Helper := ((mob.Character.CurrentScore.CurMP div 100) *
              SkillData[Skill].Adicional);
          Inc(Dano, Helper);
        end;
      end;
  end;
end;
procedure TBaseMob.ClericSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
var
  Helper: Int64;

begin
  case SkillData[Skill].Index of
    FLECHA_SAGRADA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Helper := ((Dano div 100) * SkillData[Skill].Adicional);
          Inc(Dano, Helper);
        end;
      end;

    RETORNO_MAGICA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Inc(Dano, SkillData[Skill].Adicional);
          mob.RemoveBuffs(SkillData[Skill].Damage);
        end;
      end;
  end;
end;
procedure TBaseMob.WarriorAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean; out MoveToTarget: Boolean);
begin
  case SkillData[Skill].Index of
    TEMPESTADE_LAMINA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
    AREA_IMPACTO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, LENT_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    CANCAO_GUERRA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    SALTO_IMPACTO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
    GRITO_MEDO:
      begin
        Dano := 0; // Self.GetDamage(Skill, mob, DmgType);

        if (mob.GetMobAbility(EF_IMMUNITY) > 0) then
        begin
          DmgType := TDamageType.Immune;
        end;
        if (mob.BuffExistsByIndex(19)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(19);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(19);
            DmgType := TDamageType.Block;
          end;
        end;
        if (mob.BuffExistsByIndex(91)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(91);
            DmgType := TDamageType.Miss2;
          end;
        end;

        if (Self.ValidAttack(DmgType, FEAR_TYPE, mob, Dano)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    LAMINA_CARREGADA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
    INVESTIDA_MORTAL:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, LENT_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
        // Self.WalkinTo(mob.PlayerCharacter.LastPos);
        // MoveToTarget := True;
      end;
    PODER_ABSOLUTO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
    LIMITE_BRUTAL:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    POSTURA_FINAL:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
  end;
end;
procedure TBaseMob.TemplarAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    INCITAR_MULTIDAO:
      begin
        Dano := 0; // Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, True, mob);

        if (mob.GetMobAbility(EF_IMMUNITY) > 0) then
        begin
          DmgType := TDamageType.Immune;
        end;
        if (mob.BuffExistsByIndex(19)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(19);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(19);
            DmgType := TDamageType.Block;
          end;
        end;
        if (mob.BuffExistsByIndex(91)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(91);
            DmgType := TDamageType.Miss2;
          end;
        end;

        if(Self.ValidAttack(DmgType, 0, mob, Dano, True)) then
        begin
          if (mob.BuffExistsByIndex(53)) then
          begin
            mob.RemoveBuffByIndex(53);
          end;
          if (mob.BuffExistsByIndex(77)) then
          begin
            mob.RemoveBuffByIndex(77);
          end;
        end;
      end;
    EMISSAO_DIVINA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, SILENCE_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    LAMINA_PROMESSA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
    SANTUARIO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    CRUZ_JULGAMENTO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
    ESCUDO_VINGADOR:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
  end;
end;
procedure TBaseMob.RiflemanAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    CONTAGEM_REGRESSIVA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    TIRO_ANGULAR_AREA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    DETONACAO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, SILENCE_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    RAJADA_SONICA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, SILENCE_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    GOLPE_FANTASMA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    NAPALM:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    ARMADILHA_MULTIPLA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
  end;
end;
procedure TBaseMob.DualGunnerAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    FUMACA_SANGRENTA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
    EXPLOSAO_RADIANTE:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    DISPARO_DEMOLIDOR:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
    PONTO_CEGO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    FESTIVAL_BALAS:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
  end;
end;
procedure TBaseMob.MagicianAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    INFERNO_CAOTICO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    ENXAME_ESCURIDAO:
      begin
        // Self.UsingLongSkill := True;
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    ECLATER:
      begin
        Dano := 0; //Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, False, mob);
        if (Self.ValidAttack(DmgType, 0, mob, 0, True)) then
        begin
          CanDebuff := True;
        end;
      end;
    ESPLENDOR_CAOTICO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, LENT_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    BRUMA:
      begin
        Dano := 0; // Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, False, mob);

        if (mob.GetMobAbility(EF_IMMUNITY) > 0) then
        begin
          DmgType := TDamageType.Immune;
        end;
        if (mob.BuffExistsByIndex(19)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(19);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(19);
            DmgType := TDamageType.Block;
          end;
        end;
        if (mob.BuffExistsByIndex(91)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(91);
            DmgType := TDamageType.Miss2;
          end;
        end;

        if (Self.ValidAttack(DmgType, STUN_TYPE, mob, Dano, True)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    QUEDA_NEGRA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    PECADOS_MORTAIS:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, LENT_TYPE, mob)) then
        begin
          CanDebuff := True;
          Self.SKDListener := True;
          Self.SKDAction := 2;
          Self.SKDSkillID := Skill;
          Self.SKDTarget := mob.ClientID;
          Self.SKDSkillEtc1 := SkillData[Skill].EFV[0];
        end
        else
          Resisted := True;
      end;
    PROEMINECIA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    TEMPESTADE_RAIOS:
      begin
        Self.UsingLongSkill := True;
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, LENT_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    EXPLOSAO_TREVAS:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    TROVAO_RUINOSO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    TEMPESTADE:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    FURACAO_NEGRO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    PORTAO_ABISSAL:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
  end;
end;
procedure TBaseMob.ClericAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    SENSOR_MAGICO:
      begin
        Dano := 0; // Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, False, mob);

        if (mob.GetMobAbility(EF_IMMUNITY) > 0) then
        begin
          DmgType := TDamageType.Immune;
        end;
        if (mob.BuffExistsByIndex(19)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(19);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(19);
            DmgType := TDamageType.Block;
          end;
        end;
        if (mob.BuffExistsByIndex(91)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(91);
            DmgType := TDamageType.Miss2;
          end;
        end;

        if(Self.ValidAttack(DmgType, 0, mob, Dano)) then
        begin
          if (mob.BuffExistsByIndex(53)) then
          begin
            mob.RemoveBuffByIndex(53);
          end;
          if (mob.BuffExistsByIndex(77)) then
          begin
            mob.RemoveBuffByIndex(77);
          end;
        end;
      end;
    RAIO_SOLAR:
      begin
        if (mob.GetMobAbility(EF_IMMUNITY) > 0) then
        begin
          DmgType := TDamageType.Immune;
          Exit;
        end;
        if (mob.BuffExistsByIndex(19)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(19);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(19);
            DmgType := TDamageType.Block;
            Exit;
          end;
        end;
        if (mob.BuffExistsByIndex(91)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(91);
            DmgType := TDamageType.Miss2;
            Exit;
          end;
        end;

        Dano := 0;//Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, False, mob);
        if (Self.ValidAttack(DmgType, 0, mob, 0, True)) then
        begin
          CanDebuff := True;
        end;
      end;
    UEGENES_LUX:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
    CRUZ_PENITENCIAL:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    EDEN_PIEDOSO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    DIXIT:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
  end;
end;
{$ENDREGION}
{$REGION 'Effect Functions'}
procedure TBaseMob.SendEffect(EffectIndex: DWORD);
var
  Packet: TSendClientIndexPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $117;
  Packet.Index := Self.ClientID;
  Packet.Effect := EffectIndex;
  Self.SendToVisible(Packet, Packet.Header.size);
end;
{$ENDREGION}
{$REGION 'Move/Teleport'}
procedure TBaseMob.Teleport(Pos: TPosition);
begin
  if not(Pos.IsValid) then
    Exit;
  Self.PlayerCharacter.LastPos := Pos;
  Self.SendCreateMob;
  // Self.UpdateVisibleList;
end;
procedure TBaseMob.Teleport(Posx, Posy: WORD);
begin
  Self.Teleport(TPosition.Create(Posx.ToSingle, Posy.ToSingle));
end;
procedure TBaseMob.Teleport(Posx, Posy: string);
begin
  Self.Teleport(TPosition.Create(Posx.ToSingle, Posy.ToSingle));
end;
procedure TBaseMob.WalkTo(Pos: TPosition; speed: WORD; MoveType: Byte);
var
  Packet: TMovementPacket;
begin
  if not(Pos.IsValid) then
    Exit;
  Self.PlayerCharacter.LastPos := Pos;
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $301;
  Packet.Destination := Pos;
  Packet.MoveType := MoveType;
  Packet.speed := speed;
  Self.SendToVisible(Packet, Packet.Header.size, True);
  Self.UpdateVisibleList;
end;
procedure TBaseMob.WalkAvanced(Pos: TPosition; SkillID: Integer);
var
  Packet: TMovementPacket;
begin
   if not(Pos.IsValid) then
    Exit;

  if(Self.PlayerCharacter.LastPos.Distance(Pos) > 18) then
    Exit;
  Self.PlayerCharacter.LastPos := Pos;
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $301;
  Packet.Destination := Pos;
  Packet.MoveType := 0;
  Packet.Unk := SkillID;
  Packet.Speed := 125; //era 125
  Self.SendToVisible(Packet, Packet.Header.size, True);
  Self.UpdateVisibleList;
end;
procedure TBaseMob.WalkBacked(Pos: TPosition; SkillID: Integer; Mob: PBaseMob);
var
  PacketAtk: TRecvDamagePacket;
  PacketMove: TMovementPacket;
begin
  ZeroMemory(@PacketMove, sizeof(PacketMove));
  PacketMove.Header.size := sizeof(PacketMove);
  PacketMove.Header.Index := mob.ClientID;
  PacketMove.Header.Code := $301;
  PacketMove.Destination := Pos;
  mob.PlayerCharacter.LastPos := Pos;
  PacketMove.MoveType := 0;
  PacketMove.Unk := SkillID;
  PacketMove.Speed := 15;
  ZeroMemory(@PacketAtk, sizeof(PacketAtk));
  PacketAtk.Header.size := sizeof(PacketAtk);
  PacketAtk.Header.Index := Self.ClientID;
  PacketAtk.Header.Code := $102;
  PacketAtk.SkillID := SkillID;
  PacketAtk.AttackerPos := Self.PlayerCharacter.LastPos;
  PacketAtk.AttackerID := Self.ClientID;
  PacketAtk.Animation := SkillData[SkillID].Anim;
  PacketAtk.AttackerHP := Self.Character.CurrentScore.CurHP;
  PacketAtk.TargetID := mob.ClientID;
  PacketAtk.MobAnimation := SkillData[SkillID].TargetAnimation;
  PacketAtk.DNType := TDamageType.none;
  PacketAtk.DANO := 0;
  PacketAtk.MobCurrHP := mob.Character.CurrentScore.CurHP;
  PacketAtk.DeathPos := mob.PlayerCharacter.LastPos;
  Self.SendToVisible(PacketAtk, PacketAtk.Header.size, True);
  mob.SendToVisible(PacketMove, PacketMove.Header.size, True);
  mob.UpdateVisibleList;
end;
{$ENDREGION}
{$REGION 'Pets'}
procedure TBaseMob.CreatePet(PetType: TPetType; Pos: TPosition; SkillID: DWORD);
var
  pId: Integer;
begin
  pId := TFunctions.FreePetId(Self.ChannelId);
  ZeroMemory(@Servers[Self.ChannelId].PETS[pId], sizeof(TPet));
  Self.PetClientID := pId;
  Servers[Self.ChannelId].PETS[pId].Base.Create(nil, pId, Self.ChannelId);
  Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.ClientID :=
    Servers[Self.ChannelId].PETS[pId].Base.ClientID;
  case PetType of
    X14:
      begin
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.MaxHP := (SkillData[SkillID].Attribute div 5);
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.CurHP := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.MaxHP;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.MaxMP := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.MaxHP;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.CurMP := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.MaxMP;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DNFis := ((SkillData[SkillID].Attribute div 10) div 4);;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DNMAG := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.DNFis;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DEFFis := ((SkillData[SkillID].Attribute div 10) div 2);
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DEFMAG := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.DEFFis;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Equip[0].
          Index := 328; // x14 face
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Equip[1].
          Index := 328;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Altura := 7;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Tronco := $77;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Perna := $77;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Corpo := 0;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Exp := 1;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Level :=
          Self.PlayerCharacter.Base.Level;
        Servers[Self.ChannelId].PETS[pId].PetType := X14;
        Servers[Self.ChannelId].PETS[pId].Duration :=
          (SkillData[SkillID].Duration);
        Servers[Self.ChannelId].PETS[pId].IntName := SkillData[SkillID].EFV[0];
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.LastPos := Pos;
        Servers[Self.ChannelId].PETS[pId].MasterClientID := Self.ClientID;
      end;
    NORMAL_PET:
      begin // soon
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.MaxHP := ItemList[SkillID].HP;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.CurHP := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.MaxHP;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.MaxMP := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.MaxHP;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.CurMP := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.MaxMP;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DNFis := ItemList[SkillID].ATKFis * 2;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DNMAG := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.DNFis;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DEFFis := ItemList[SkillID].MagATK * 2;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DEFMAG := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.DEFFis;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Equip[0].
          Index := ItemList[SkillID].Duration; // duration will be the mob face
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Equip[1].
          Index := ItemList[SkillID].Duration;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Altura := ItemList[SkillID].TextureID;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Tronco := ItemList[SkillID].TextureID*ItemList[SkillID].MeshIDWeapon;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Perna := ItemList[SkillID].TextureID*ItemList[SkillID].MeshIDWeapon;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Corpo := ItemList[SkillID].TextureID*ItemList[SkillID].MeshIDWeapon;;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Exp := 1;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Level := 50;
        Servers[Self.ChannelId].PETS[pId].PetType := NORMAL_PET;
        Servers[Self.ChannelId].PETS[pId].Duration := 0;
        Servers[Self.ChannelId].PETS[pId].IntName := ItemList[SkillID].DelayUse;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.LastPos := Pos;
        Servers[Self.ChannelId].PETS[pId].MasterClientID := Self.ClientID;
      end;
  end;
end;

procedure TBaseMob.DestroyPet(PetID: WORD);
var
  i: Integer;
begin
  Servers[Self.ChannelId].Players[Self.ClientID].UnSpawnPet(PetID);
  for I in Self.VisiblePlayers do
  begin
    Servers[Self.ChannelId].Players[i].UnSpawnPet(PetID);
  end;

  ZeroMemory(@Servers[Self.ChannelId].PETS[PetID], sizeof(TPet));
end;
{$ENDREGION}
{$REGION 'TPrediction'}
procedure TPrediction.Create;
begin
  Timer := TStopwatch.Create;
end;
function TPrediction.Delta: Single;
begin
  if ETA > 0 then
    Result := Elapsed / ETA
  else
    Result := 1;
end;
function TPrediction.Elapsed: Integer;
begin
  Result := Timer.ElapsedTicks;
end;
function TPrediction.CanPredict: Boolean;
begin
  Result := ((ETA > 0) AND (Source.IsValid) AND (Destination.IsValid));
end;
function TPrediction.Interpolate(out d: Single): TPosition;
begin
  d := Delta;
  if (d >= 1) then
  begin
    ETA := 0;
    Result := Destination;
  end
  else
    Result := TPosition.Lerp(Source, Destination, d);
end;
procedure TPrediction.CalcETA(speed: Byte);
var
  Dist: WORD;
begin
  Dist := Source.Distance(Destination);
  speed := speed * 190;
  ETA := (AI_DELAY_MOVIMENTO + (Dist * (1000 - speed)));
end;
{$ENDREGION}
end.
