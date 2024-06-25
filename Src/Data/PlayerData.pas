unit PlayerData;

interface

uses MiscData, Windows, Generics.Collections, PartyData;
{$OLDTYPELAYOUT ON}

{$REGION 'Account Type'}

type
  TAccountType = (Player, Founder, Sponser, Moderator, GameMaster, Admin);

{$ENDREGION}
{$REGION 'Nation Data'}
{$ENDREGION}
{$REGION 'Skill List'}

type
  PSkillFromList = ^TSkillFromList;

  TSkillFromList = packed record
    Index: Word;
    Level: Word;
  end;

type
  TSkillsList = packed record
    Basics: ARRAY [0 .. 5] OF TSkillFromList;
    Others: ARRAY [0 .. 39] OF TSkillFromList;

  public
    // function GetSkill(SkillIndex : Integer) : PSkillFromList; overload;
    function GetSkill(SkillIndex: Integer): Integer; overload;
  end;

{$ENDREGION}
{$REGION 'Pran Data'}

type
  TPranPersonality = packed record
    Cute, Smart, Sexy, Energetic, Tough, Corrupt: WORD;
  end;

type
  PPran = ^TPran;

  TPran = packed record
    Id: WORD; //id for spawn
    Iddb: Integer;
    ItemID: WORD; //not id, yes identific
    AccId: Integer;
    Name: Array [0 .. 15] of AnsiChar;
    Level: Byte;
    ClassPran: Byte;
    CurHP, MaxHp: DWORD;
    CurMp, MaxMP: DWORD;
    Exp: DWORD;
    DefFis, DefMag: Word;
    Food: Byte;
    Devotion: Byte;
    Personality: TPranPersonality;
    Width: Byte;
    Chest: Byte;
    Leg: Byte;
    CreatedAt: DWORD;
    Updated_at: DWORD;
    Equip: Array [0 .. 15] of TITEM; // 16 itens
    Inventory: Array [0 .. 41] of TITEM; // 2 bolsas
    Skills: Array [0..9] of TSkillFromList; //sao 10 skills mas podem ser 12 (2 novas no futuro)
    ItemBar: Array [0..2] of Byte;
    IsSpawned: Boolean;
    Position: TPosition;
    MovedToCentral: Boolean;
  End;

const
  PRAN_HP_INC_PER_LEVEL = 209;
  PRAN_MP_INC_PER_LEVEL = 356;

{$ENDREGION}
{$REGION 'Character Data'}
{$REGION 'Complemento'}

type
  TSizes = packed record
    Altura, Tronco, Perna, Corpo: byte; // 07 77 77 Padrao
  end;

type
  TAttributes = packed record
    Str, Agi, Int, Cons, Luck, Status: Word;
  end;

type
  TLife = packed record
    CurHP, MaxHp: DWORD;
    CurMp, MaxMP: DWORD;
  end;

type
  TDamage = packed record
    DNFis, DefFis: Word;
    DNMag, DefMag: Word;
    BonusDMG: Word;
  end;
{$ENDREGION}

type
  TTrade = packed record
    Itens: Array [0 .. 9] of TITEM;
    Slots: Array [0 .. 9] of byte;
    Null: Word;
    Gold: Int64;
    Ready, Confirm: boolean;
    OtherClientid: Word;
  end;

type
  TPlayerStatus = (WaitingLogin, CharList, Senha2, Waiting, Playing);

type
  TCitizenship = (None = 0, Server1, Server2, Server3, Server4, Server5);

type
  PTitleData = ^TTitleData;
  TTitleData = record
    Index: byte;
    Level: byte; //
    Progress: Word;
  end;

type
  TTitleList = Array [0 .. 95] of TTitleData;


{$REGION 'Buff List'}

type
  TBuffFromList = packed record
    Index: Word;
    CreationTime: TDateTime;
  end;

type
  TBuffsList = ARRAY [0 .. 59] OF TBuffFromList;

{$ENDREGION}

type
  TQuestsList = Array [0 .. 15] OF Word;

type
  TStatus = packed record
    Str, agility, Int, Cons, Luck, Status: Word;

    Sizes: TSizes;

    MaxHp, CurHP: DWORD;
    MaxMP, CurMp: DWORD;
    ServerReset: DWORD; { Hora em que reseta o Servidor do proximo dia }
    Honor: DWORD;
    KillPoint: DWORD;
    Infamia: DWORD; // chaos time
    EvilPoints: Word;
    SkillPoint: Word;
    Unk0: Word; // Valor1
    Null_3: Array [0 .. 59] of byte;
    UNK1: Word; // Valor 52
    DNFis, DefFis: Word;
    DNMag, DefMag: Word;
    BonusDMG: Word;
    null_4: Array [0 .. 9] of byte;
    Critical: Word;
    Esquiva: byte;
    Acerto: byte;
  end;

type
  PCharacter = ^TCharacter;

  TCharacter = packed record
    ClientId: DWORD; // Ou word[sobraria 2bytes]
    FirstLogin: DWORD;
    CharIndex: DWORD; // talvez ID unico do char
    Name: Array [0 .. 15] of AnsiChar;
    Nation: byte; // valor 5 talvez nação
    ClassInfo: byte; // é a classe mesmo
    Null_1: Word;
    CurrentScore: TStatus;

    Null_6: DWORD;
    Exp: Int64; // 8Bytes
    Level: Word; // Level-1
    GuildIndex: Word;
    Null_007: Array [0 .. 31] of byte;
    BuffsId: ARRAY [0..19] OF WORD;
    BuffsDuration: Array [0 .. 19] of DWORD; //UnixTime
    Equip: Array [0 .. 15] of TITEM; // 16 Itens
    Null: DWORD;
    Inventory: Array [0 .. 63] of TITEM; // 60 Itens
    Gold: Int64; // 8 Bytes
    UnkBytes0: Array [0 .. 191] of byte; // Tem valores desconhecidos
    Quests: Array [0 .. 15] of TQuest; // Max 16 Quests
    UnkBytes1: Array [0 .. 211] of byte;

    UNK_BYTE: DWORD;
    Location: DWORD;

    Unk_Bytes1: Array [0 .. 127] of byte;

    CreationTime: DWORD; { Data de Criação do char }
    UnkBytes2: Array [0 .. 435] of byte;
    Numeric: Array [0 .. 3] of AnsiChar;
    UnkBytes3: ARRAY [0 .. 211] OF byte;
    SkillList: ARRAY [0 .. 59] OF Word;
    ItemBar: ARRAY [0 .. 23] OF DWORD;
    // Estranho valor e qtd [4bytes] era 24 no c++
    NULL_5: DWORD;
    TitleCategoryLevel: Array [0 .. 11] of DWORD;
    UNK_8: Array [0 .. 79] of byte;
    ActiveTitle: Word;
    NULL_9: DWORD;
    TitleProgressType8: Array [0 .. 47] of Word;
    TitleProgressType9: Array [0 .. 1] of Word;
    TitleProgressType4: Word;
    TitleProgressType10: Word;
    TitleProgressType7: Word;
    TitleProgressType11: Word;
    TitleProgressType12: Word;
    TitleProgressType13: Word;
    TitleProgressType15: Word;
    TitleProgress_UNK: Word;
    TitleProgressType16: Array [0 .. 21] of Word;
    TitleProgressType23: Word;

    TitleProgress: Array [0 .. 119] of Word;
    EndDayTime: DWORD;
    Null_8: DWORD;
    Unk_0: DWORD;
    Null_10: ARRAY [0 .. 51] OF byte;
    UTC: DWORD;
    LoginTime: DWORD;
    UnkBytes6: ARRAY [0 .. 11] OF byte;
    PranName: ARRAY [0 .. 1] OF ARRAY [0 .. 15] of AnsiChar;
    Unknow: DWORD;

    { ItemBar: ARRAY [0 .. 031] OF DWORD; // Estranho valor e qtd [4bytes]
      UnkBytes4: ARRAY [0 .. 49] OF Word;

      Titles: ARRAY [0 .. 59] OF TTitle;
      UnkBytes5: ARRAY [0 .. 287] OF byte;
      EndDayTime: DWORD;
      Null_8: DWORD;
      Unk_0: DWORD;
      Null_9: ARRAY [0 .. 51] OF byte;
      UTC: DWORD;
      LoginTime: DWORD;
      UnkBytes6: ARRAY [0 .. 011] OF byte;
      PranName: ARRAY [0 .. 001] OF ARRAY [0 .. 15] of AnsiChar;
      Unknow: DWORD; }
  End;

{$REGION 'Struct HN'}
  { type PCharacter = ^TCharacter;
    TCharacter = packed record
    ClientId       : DWORD;
    FirstLogin     : LongBool;
    UnkNK          : DWORD;
    Name           : ARRAY [0..15]of AnsiChar;
    Nation         : Byte;
    ClassInfo      : WORD;
    CurrentScore   : TStatus;

    Exp            : DWORD;
    Level          : WORD;
    GuildId        : WORD;
    Null_6         : ARRAY [0..106] OF BYTE;

    Equip          : ARRAY [0..15] OF TItem;
    Null           : DWORD;
    Inventory      : ARRAY [0..63] OF TItem; //60 Itens  4 bolsas

    Gold,
    Gold2          : DWORD;
    UnkBytes0      : ARRAY [0..383] OF Byte;  //Tem valores desconhecidos
    Quests         : ARRAY [0..016] OF TQuest; //Max 16 Quests
    UnkBytes1      : ARRAY [0..487] OF Byte;  //Tem valores desconhecidos
    Numeric        : ARRAY [0..003] OF AnsiChar;
    UnkBytes2      : ARRAY [0..211] OF Byte;
    SkillList      : ARRAY [0..059] OF WORD;
    ItemBar        : ARRAY [0..031] OF DWORD;//Estranho valor e qtd [4bytes]
    UnkBytes3      : ARRAY [0..099] OF Byte;
    Titles         : ARRAY [0..059] OF WORD;
    UnkBytes4      : ARRAY [0..347] OF Byte;
    PranName       : ARRAY [0..001] OF ARRAY [0..15] of AnsiChar;
    Unknow         : LongInt;
    End; }

{$ENDREGION}

type
  PPlayerCharacter = ^TPlayerCharacter;

  TPlayerCharacter = packed record

    Index: DWORD;
    Base: TCharacter;
    SpeedMove: Word;
    DuploAtk: Word;
    Rotation: Word;
    Resistence: Word;

    LastAction: TTime;
    LastLogin: TDateTime;
    LoggedTime: Cardinal;

    PlayerKill: boolean; // PK
    LastPos: TPosition; // Ultima coordenada
    CurrentPos: TPosition; // Atual

    Skills: TSkillsList;
    Buffs: TBuffsList;
    Quests: TQuestsList;

    ActiveTitle: TTitleData;
    Titles: TTitleList;


    // BasePran: TPran;

    { Não Salva }
    GuildSlot: Integer;
    DamageCritical: Word;
    ResDamageCritical: WORD;
    HabAtk: Word;
    ReduceCooldown: Word;
    MagPenetration, FisPenetration: Word;
    CureTax: Word;
    CritRes, DuploRes: Word;
    PvPDamage, PvPDefense: WORD;

    IngameBuffs: TList<TBuffFromList>;

    IsStorageSend, IsStoreOpened: boolean;
    Trade: TTrade;
    TradingWith: Integer;
  end;

{$ENDREGION}
{$REGION 'Account Data'}

type
  TStoragePlayer = packed record
    Gold: Int64;
    Itens: Array [0 .. 85] of TITEM; //85 83 + 2 pran
    //Prans: Array [0 .. 1] of TITEM;
  end;

type
  PCashInventory = ^TCashInventory;

  TCashInventory = packed record
    Cash: Cardinal;
    Items: ARRAY [0 .. 23] OF TItemCash;

    function AddItem(Index: Integer): Integer;
    function IsEmpyt(Slot: byte): boolean;
  end;

type
  TAccountHeader = packed record // toda conta tem
    AccountId: Integer;
    Username: String[15];
    Password: String[32];
    Token: TPlayerToken;
    Nation: TCitizenship;
    IsActive: boolean;
    AccountStatus: byte;
    AccountType: TAccountType;
    PremiumTime: TDateTime;
    BanDays: Integer;
    IsFounder: Boolean;
    FounderLevel: Integer;

    Pran1: TPran;
    Pran2: TPran;

    Storage: TStoragePlayer;
    NumError: Array [0 .. 2] of byte;
    NumericToken: Array [0 .. 2] of String[4];
    PlayerDelete: Array [0 .. 2] of boolean;

    CashInventory: TCashInventory;
  end;

type
  TBasicCharacter = packed record
    Index: DWORD;
    Base: TCharacter;
    SpeedMove: Word;
    DuploAtk: Word;
    Rotation: Word;
    Resistence: Word;

    LastAction: TTime;
    LastLogin: TDateTime;
    LoggedTime: Cardinal;

    PlayerKill: boolean; // PK
    LastPos: TPosition; // Ultima coordenada
    CurrentPos: TPosition; // Atual

    Skills: TSkillsList;
    Buffs: TBuffsList;
    Quests: TQuestsList;

    // BasePran: TPran;
  end;

type
  TCharacterDB = packed record
    Index: DWORD;
    Base: TCharacter;
    SpeedMove: Word;
    DuploAtk: Word;
    Rotation: Word;
    Resistence: Word;

    LastAction: TTime;
    LastLogin: TDateTime;
    LoggedTime: Cardinal;

    PlayerKill: boolean; // PK
    LastPos: TPosition; // Ultima coordenada
    CurrentPos: TPosition; // Atual

    Skills: TSkillsList;
    Buffs: TBuffsList;
    Quests: TQuestsList;

    ActiveTitle: TTitleData;
  end;

type
  TAccountFile = packed record
    Header: TAccountHeader;
    Characters: ARRAY [0 .. 2] OF TCharacterDB;
    CharactersDelete: Array [0 .. 2] of boolean;
    CharactersDeleteTime: Array [0 .. 2] of String[32];
    PranEvoCnt: Integer;

  public
    function GetCharCount(AccID: Integer; ch: Word; Player: Pointer): Integer;
  end;

{$REGION 'Change Channel'}

type
  TChangeChannelToken = packed record
    CharSlot: BYTE;
    ChangeTime: TTime;
    OldClientID: WORD;
    OldChannelID: Byte;
    PartyTeleport: TParty;
    PartiesTeleport: Array [0..3] of TParty;
    PartiesLeader: Array [0..3] of Integer;
    AccountStatus: Byte;
    accFromOther: TAccountFile;
    charFromOther: TPlayerCharacter;
    buffFromOther: TBuffsList;
  end;

{$ENDREGION}

{$ENDREGION}
{$REGION 'NPC Data'}

type
  TNPCHeader = packed record
    Title: string[35];
    Options: ARRAY [0 .. 9] OF byte;
    Reserved: ARRAY [0 .. 511] OF byte;
  end;

type
  TNPCFile = packed record
    Header: TNPCHeader;
    Base: TBasicCharacter;
  end;

{$ENDREGION}
{$REGION 'Friend List Data'}

type
  TFriend = packed record
    Index: DWORD;
    Nick: ARRAY [0 .. 15] OF AnsiChar;
  end;

  TFriendListFile = ARRAY [0 .. 49] OF TFriend;

type
  TFriendStatus = (BlockedOff, BlockedOn, Offline, Online);

{$ENDREGION}
{$REGION 'City e Location Data'}

type
  TCity = (NoneLocation, Regenshein, Verband, Crac_des_Chevelier, Amarkand,
    Ursula, HeklaCave, Halperin, Sigmund, Mina_Lenfer, Basilan, Mt_Hessen,
    Cahil, Agross);

{$ENDREGION}

type
  TMobTarget = record
    ClientID: WORD;
    TargetType: Byte; //0 para player, 1 para mobs
    Position: TPosition;

    Player: Pointer;
    Mob: Pointer;
  end;

{$OLDTYPELAYOUT OFF}

implementation

uses
  GlobalDefs, SysUtils, Player, Log, SQL;

{$REGION 'Account Data'}

function TAccountFile.GetCharCount(AccID: Integer; ch: Word;
  Player: Pointer): Integer;
var
  OtherPlayer: PPlayer;
  SQLComp: TQuery;
begin
  OtherPlayer := Player;

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

  try
    //OtherPlayer.PlayerSQL.MYSQL.StartTransaction;

    SQLComp.SetQuery
      ('SELECT * FROM characters WHERE owner_accid = :powner_accid');
    SQLComp.AddParameter('powner_accid', AnsiString(IntToStr(AccID)));
    SQLComp.Run();

    //OtherPlayer.PlayerSQL.MYSQL.Commit;
  finally
    Result := SQLComp.Query.RecordCount;
  end;

  SQLComp.Destroy;
end;

{$REGION 'Cash Inventory'}

function TCashInventory.AddItem(Index: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := 0 to 23 do
  begin
    if (Self.Items[i].Index = 0) then
    begin
      Self.Items[i].Index := Index;
      Result := i;
      Break;
    end;
  end;
end;

function TCashInventory.IsEmpyt(Slot: byte): boolean;
begin
  Result := Self.Items[Slot].Index = 0;
end;

{$ENDREGION}
{$ENDREGION}
{$REGION 'Skills'}

function TSkillsList.GetSkill(SkillIndex: Integer): Integer;
var
  BaseSkill: Integer;
  i: Integer;
begin
  Result := -1;
  BaseSkill := SkillIndex;
  dec(BaseSkill, SkillData[SkillIndex].Level + 1);

  for i := 0 to Length(Self.Others) - 1 do
  begin
    if (Self.Others[i].Index = BaseSkill) then
    begin
      Result := i;
      Break;
    end;
  end;
end;

{$ENDREGION}

end.
