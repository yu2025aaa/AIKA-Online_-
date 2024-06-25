unit FilesData;
interface
uses
  Windows;
{$OLDTYPELAYOUT ON}
{$REGION 'ItemList Data'}
type
  TItemFromList = packed record
    Name: Array [0 .. 63] of AnsiChar; // Nome Portugues
    NameEnglish: Array [0 .. 63] of AnsiChar; // Nome original
    Descrition: Array [0 .. 127] of AnsiChar; // Descrição

    CanAgroup: Boolean;
    Unknow: BYTE;
    ItemType: WORD;
    UnkValues: ARRAY [0 .. 7] OF BYTE;
    UseEffect: WORD;
    Unk_other: ARRAY [0 .. 5] OF BYTE;

    DelayUse, // delay ao usar item consumivel
    PriceHonor, // valor
    PriceMedal, // valor
    PriceGold, // valor
    SellPrince, Null_0: DWORD;

    Classe: WORD; // dword
    Null_00: WORD;
    MeshIDEquip: WORD;
    Null_1: Array [0 .. 2] of BYTE;
    Null_Mashid: WORD; //era meshid

    Null_0001: Boolean;
    TextureID: WORD;
    Null_3: ARRAY [0 .. 3] OF BYTE;
    MeshIDWeapon: WORD;

    IconID, Unk_1, Conjunto: WORD;
    Null_4: WORD;
    Expires: Boolean; // se  expira ou não aqui não é a data
    Unk_Bool: BYTE;

    Level: WORD;
    Null_001: DWORD;
    Duration: DWORD;
    Nothing_2: ARRAY [0 .. 17] OF BYTE;

    ATKFis, DefFis, MagATK, DefMag: WORD;

    Null0: Array [0 .. 5] OF BYTE;
    HP, MP: WORD; //
    Null001: Array [0 .. 13] OF BYTE;
    TypeItem: BYTE; // Se é raro...normal....  [0~~7]
    Null01: WORD;
    TypeTrade: BYTE; // [0~~2] 1 N Trocavel, 2 Negociação revertida
    Null02: Array [0 .. 11] OF BYTE;
    Durabilidade: BYTE;
    Null_5: ARRAY [0 .. 4] OF BYTE;

    EF, EFV: Array [0 .. 2] of WORD;
    Change, // Mudança de aparencia
    Reduction, // se ja foi reduzido
    Fortification: Boolean; //
    Rank: BYTE;
    Null, MaxLvl, Null3: DWORD;
    TypePriceItem: WORD; // se for cash por exemplo
    TypePriceItemValue: WORD;
    Null4: Array [0 .. 15] of BYTE;
    CanSealed: WordBool;
    Null5: WORD;
  end;

type
  TItemList = ARRAY [0 .. 20477] OF TItemFromList;

{$ENDREGION}
{$REGION 'PremiumItem Data'}

type
  TPremiumItem = packed record
    Index  : DWORD;
    unk0        : byte;
    status      : byte;
    show        : byte;
    trade       : byte;
    name        : array [0..63] of AnsiChar;
    Description        : array [0..255] of AnsiChar;
    price       : DWORD;
    price_off   : WORD;
    amount      : WORD;
    ItemIndex  : WORD;
    unk1        : array [0..13] of byte;
    Amount_2     : WORD;
    unk2        : array [0..21] of byte;

    {Index: DWORD;
    Null_0: Boolean;
    Unk_0: BYTE;
    Null_1: WORD;
    Name: ARRAY [0 .. 63] OF AnsiChar;
    Description: ARRAY [0 .. 255] OF AnsiChar;
    Price: DWORD;
    Null_2: WORD;
    Amount: WORD;
    ItemIndex: WORD;
    Unk_1: ARRAY [0 .. 13] OF BYTE;
    Amount_2: WORD;
    Unk_2: ARRAY [0 .. 21] OF BYTE; }
  end;

type
  TPremiumList = ARRAY OF TPremiumItem;

{$ENDREGION}
{$REGION 'SetItem Data'}

type
  T_SetItem = packed record
    Name: ARRAY [0 .. 63] OF AnsiChar;
    NameEnglish: ARRAY [0 .. 63] OF AnsiChar;

    Unk_1, // 0x5
    Unk_2: WORD; // 0x3B
    Equips: ARRAY [0 .. 11] OF WORD;
    EffSlot: ARRAY [0 .. 9] OF WORD;
    Unk_3: ARRAY [0 .. 15] OF BYTE;
    EF, EFV: ARRAY [0 .. 5] OF WORD;
  end;

type
  TSetItem = Array [0 .. 800] OF T_SetItem;

type
  TConjunts = ARRAY [0 .. 20477] OF WORD;

{$ENDREGION}
{$REGION 'Skill Data'}

type
  P_SkillData = ^T_SkillData;

  T_SkillData = packed record
    Index, MinLevel, Null_3, Level, Classification: DWORD;

    NameEnglish: Array [0 .. 63] of AnsiChar;
    Name: Array [0 .. 63] of AnsiChar;

    SkillPoints: DWORD;
    LearnCosts: DWORD;
    Classe: DWORD;

    Unk_0: ARRAY [0 .. 11] OF BYTE;

    MP: DWORD;

    // Unk_1: ARRAY [0 .. 7] OF BYTE;
    Unk_1: DWORD;
    PreCooldown: DWORD;
    Cooldown: DWORD; { Em milisegundos }
    CooldownType: DWORD;
    TargetType: DWORD;
    UniqueType: DWORD;
    MaxTargets: DWORD;
    Unknown1: DWORD;
    Range: DWORD;
    DamageRange: DWORD;
    SuccessRate: DWORD;
    Agressive: DWORD;
    BuffDebuff: DWORD;
    Attribute: LongInt;
    Unk_2: ARRAY [0 .. 15] OF BYTE;
    Damage: DWORD;
    Adicional: DWORD;
    Unk_4: DWORD;

    EF, EFV: Array [0 .. 3] of Integer;

    Duration: DWORD; { Em segundos }

    Unk_5: ARRAY [0 .. 23] OF BYTE;
    CastTime: DWORD; { Em milisegundos }
    Unk_6: ARRAY [0 .. 19] OF BYTE;
    SelfAnimation: DWORD;
    TargetAnimation: DWORD;
    Unk_7: DWORD;
    Anim: DWORD;
    Unk_8: ARRAY [0 .. 67] OF BYTE;
    Description: ARRAY [0 .. 287] OF AnsiChar;
  end;
type
  TSkillData = ARRAY [0 .. 11998] OF T_SkillData;
type
  TSkillListItem = packed record
  end;
{$ENDREGION}
{$REGION 'QuestList'}
type
  TQuestData = record
    TypeID: Int32;
    Quantity1: Int32;
    Quantity2: Int32;
    Unk1: Int32;
    ItemID1: UInt16;
    ItemID2: UInt16;
    Unk2: Int32;
    Unk3: Int16;
    Unk8: Int16;
    Unk4: Int32;
    Quantity3: Int32;
    Unk5: Int32;
    Unk6: Int32;
    Unk7: Int32;
  end;
type
  TQuestFromList = Record // size 2332
    ID: WORD;
    Unk: WORD;
    StartNPC: DWORD;
    EndNPC: DWORD;
    Unk2: DWORD;
    Titulo: Array [0 .. 63] of AnsiChar;
    StartDialog: WORD;
    UnfinishedDialog: WORD;
    EndDialog: WORD;
    Summary: WORD;
    UnkBytes1: Array [0..1154] of BYTE;
    Level: Byte;
    Unk3: WORD;
    Unk4: WORD;
    Unk5: WORD;
    Unk6: WORD;  //1252
    Unknown: Array [0..1079] of Byte;
    {PreConditions: Array [0..2] of TQuestData;
    Requires: Array [0..2] of TQuestData;
    Rewards: Array [0..7] of TQuestData;
    Removes: Array [0..2] of TQuestData;
    Choices: Array [0..2] of TQuestData;
    Misc: Array [0..2] of TQuestData;}
  End;
Type
  TQuestList = ARRAY OF TQuestFromList;
type
  TQuestMisc = record
    NPCID: DWORD;
    QuestID: DWORD;
    QuestType: Byte;
    QuestMark: Byte;
    Rewards: Array [0..5] of DWORD;
    Requiriments: Array [0..4] of DWORD;
    RequirimentsType: Array [0..4] of Byte;
    RequirimentsAmount: Array [0..4] of WORD;
    DeletesItem: Array [0..2] of DWORD;
    DeletesAmount: Array [0..2] of WORD;
    Gold: Int64;
    Exp: Int64;
    LevelMin: Byte;
  end;
type
  QuestDin = record
    ID: Integer;
    Quest: TQuestMisc;
    IsDone: Boolean;
    Complete: Array [0..4] of byte;
    UpdatedAt: TDateTime;
    CreatedAt: TDateTime;
  end;
type
  TQuestMiscArray = Array [0..99] of TQuestMisc;
{$ENDREGION}
{$REGION 'Reinforce Data'}

{$REGION 'ReinforceA01 & ReinforceW01'}
type
  TItemChanceReinforce = packed record
    Unk: DWORD;
    ReinforceCust: DWORD;
    Chance: ARRAY [0 .. 15] OF WORD; // 1000 : 100%
  end;
type
  TReinforceChanceFile = ARRAY [0 .. 103] OF TItemChanceReinforce;
{$ENDREGION}
{$REGION 'ReinforceArmor'}
{type
  TArmorReinforce = packed record
    DamageReduction, HPMP: ARRAY [0 .. 15] OF DWORD;
  end; }
{type
  TArmorType = ARRAY [0 .. 29] OF TArmorReinforce;  }
type
  PArmorReinforceItem = ^TArmorReinforceItem;
  TArmorReinforceItem = packed record
    DamageReduction, HPMP: ARRAY [0 .. 15] OF WORD;
    DefMag,DefFis : ARRAY [0 .. 15] OF WORD;
    RefineChance: ARRAY [0 .. 15] OF WORD;
    ReinforceCost : DWORD;
  end;
type
  TArmorReinforceFile = ARRAY [0 .. 109, 0 .. 7] OF TArmorReinforceItem;
{$ENDREGION}
{$REGION 'ReinforceWeapon'}
type
  PWeaponReinforceItem = ^TWeaponReinforceItem;
  TWeaponReinforceItem = packed record
    AtkMag,AtkFis : ARRAY [0 .. 15] OF WORD;
    RefineChance: ARRAY [0 .. 15] OF WORD;
    ReinforceCost : DWORD;
  end;
type
  TWeaponReinforceFile = ARRAY [0 .. 109] OF TWeaponReinforceItem;

{$ENDREGION}
{$REGION 'Reinforce2'}
type
  TItemAttributeReinforce = packed record
    AttributeFis, AttributeMag: ARRAY [0 .. 15] OF DWORD;
  end;
type
  Reinforce2_Area = (
  Reinforce2_Area_Blade = 0,
	Reinforce2_Area_Sword = 35,
	Reinforce2_Area_Pistol = 70,
	Reinforce2_Area_Rifle = 105,
	Reinforce2_Area_Wand = 140,
	Reinforce2_Area_Staff = 175,
	Reinforce2_Area_Helmet = 210,
	Reinforce2_Area_Armor = 390,
	Reinforce2_Area_Gloves = 570,
	Reinforce2_Area_Shoes = 750,
	Reinforce2_Area_Shield = 930
  );
const reinforce2sectionSize : WORD = 960;
{$ENDREGION}
{$REGION 'Reinforce3'}
type
  ArmorAttributeReinforce = packed record
    DamageReduction,
    HealthIncrementPoints : ARRAY [0..15] OF DWORD;
end;
type
  Reinforce3_Area_ = (
    Reinforce3_Area_Helmet = 0,
    Reinforce3_Area_Shield = Reinforce3_Area_Helmet,
    Reinforce3_Area_Armor = 30,
    Reinforce3_Area_Gloves = 60,
    Reinforce3_Area_Shoes = 90
  );
const reinforce3sectionSize : WORD = 150;

{$ENDREGION}
{$ENDREGION}
{$REGION 'ExpList Data'}
type
  TExpList = ARRAY OF UInt64;
type
  TPranExpList = Array of DWORD;
{$ENDREGION}
{$REGION 'NPC Options Data'}
type
  TNPCOptionText = record
    Text: ARRAY [0 .. 63] OF AnsiChar;
  end;
type
  TNPCFileOptions = record
    Options: ARRAY [1 .. 65] OF TNPCOptionText;
  end;
{$ENDREGION}
{$REGION 'MobPos Data'}
type
  TMobPosition = packed record
    X, Y: DWORD;
  end;
type
  TMobPos = packed record
    Index: DWORD;
    Name: ARRAY [0 .. 11] OF AnsiChar;
    Positions: ARRAY [0 .. 49] OF TMobPosition;
  end;
type
  TMobPosFile = ARRAY OF TMobPos;
{$ENDREGION}
{$REGION 'ServerList'}
type
  TChannelFromList = packed record
    IP: ARRAY [0 .. 31] OF AnsiChar;
    Unk_0: DWORD;
    Name: ARRAY [0 .. 23] OF AnsiChar;
    Check, // $FFFFFFFF
    NationIndex, ChannelNationIndex: DWORD;
  end;
type
  TServerList = ARRAY OF TChannelFromList;
{$ENDREGION}
{$REGION 'Maps File Data'}
type
  TMapLimit = packed record
    StartX: DWORD;
    StartY: DWORD;
    FinalX: DWORD;
    FinalY: DWORD;
  end;
type
  TFileMapsData = packed record
    Limits: ARRAY [0 .. 63] OF TMapLimit;
  end;
type
  TScrollTeleportPos = packed record
    Index: DWORD;
    PosX: WORD;
    PosY: WORD;
    MapIndex: WORD;
    LocationIndex: WORD;
    Null: DWORD;
    MapName: ARRAY [0 .. 63] OF AnsiChar;
    LocationName: ARRAY [0 .. 63] OF AnsiChar;
  end;
type
  TScrollTeleportFile = ARRAY OF TScrollTeleportPos;
{$ENDREGION}
{$REGION 'Title Data'}
type
  TitleLevel = packed record
    HideTitle: Boolean;
    TitleType: BYTE;
    TitleGoal: WORD;
    EF, EFV: Array [0 .. 2] of WORD;
    TitleName: Array [0 .. 31] of AnsiChar;
    TitleCategory: BYTE;
    TitleIndex: BYTE;
    Null_1: WORD;
    TitleCollor: DWORD;
  end;
type
  TitleFromList = packed record
    TitleLevel: Array [0 .. 3] of TitleLevel;
  end;
type
  TitleList = Array [0..254] of TitleFromList;
{$ENDREGION}
{$REGION 'DropList Data'}
type
  TItemNormalDrops = Array of WORD; //const 1
  TItemSuperiorDrops = Array of WORD; //const 2
  TItemRareDrops = Array of WORD; //const 3
  TItemLegendaryDrops = Array of WORD; //const 4
type
  TMobDropList = packed record
    NormalItems: Array of WORD;
    SuperiorItems: Array of WORD;
    RareItems: Array of WORD;
    LegendaryItems: Array of WORD;
  end;
type
  TMobDrops = Array [0..12] of TMobDropList; //são 13 arquivos de drop list

{$ENDREGION}
{$REGION 'Recipes Data'}
type
  TRecipeData = packed record
    ItemRecipeID: WORD;
    Null: WORD;
    Reward: WORD;
    RewardAgain: WORD; //i dont know why?!?!
    Null2: DWORD;
    RewardAmount: Byte;
    LevelMin: Byte; //1 in file = 2 in client
    SuccessTax: WORD; //100% = 1000 logo successtax / 10 = porcentagem real
    Null3: DWORD;
    ItemIDRequired: Array [0..11] of WORD;
    ItemRequiredAmount: Array [0..11] of Byte; //max amount required = 255 ??
  end;
type
  TRecipes = Array of TRecipeData;
{$ENDREGION}
{$REGION 'Make Items Data'}
type
  TMakeItemsData = packed record
    ResultItemID: WORD;
    ID: WORD;
    LevelMin: Byte;
    Price: DWORD;
    ResultAmount: Byte;
    TaxSuccess: WORD;
  end;
type
  TMakeItemsIngredientsData = packed record
    ID: WORD;
    ItemID: WORD;
    Amount: WORD;
  end;
type
  TMakeItems = Array of TMakeItemsData;
type
  TMakeItemsIngredients = Array of TMakeItemsIngredientsData;
{$ENDREGION}
{$OLDTYPELAYOUT OFF}
implementation
uses
  SysUtils;
end.
