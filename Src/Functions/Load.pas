unit Load;
interface
uses
  PlayerData, StrUtils, GuildData;
type
  TLoad = class
  public
    class procedure InitCharacters(); static;
    class procedure InitGuilds(); static;
    class function LoadGuild(const FName: string; out Guild: TGuild)
      : Boolean; static;
    class procedure InitItemList(); static;
    class procedure InitSkillData(); static;
    class procedure InitSetItem(); static;
    class procedure InitConjunts(); static;
    class procedure InitReinforce;
    class procedure InitPremiumItems; static;
    class procedure InitMobPos; static;
    class procedure InitExpList; static;
    class procedure InitPranExpList; static;
    class procedure InitQuestList; static;
    class procedure InitQuests; static;
    class procedure InitTitles; static;
    class procedure InitDropList; static;
    class procedure InitRecipes; static;
    class procedure InitMakeItems; static;
    { NPCS }
    class procedure InitNPCS; static;
    class function LoadNPCOptions: Boolean; static;
    class function LoadNPC(const FName: string; out NPC: TNPCFile)
      : Boolean; static;
    { Server }
    class procedure InitServerList; static;
    class procedure InitServerConf(); static;
    class procedure InitServers; static;
    { Auth Servers }
    class procedure InitAuthServer; static;
    { Maps }
    class procedure InitMapsData; static;
    class procedure InitScrollPositions; static;
  private
    class procedure InitReinforceW01; static;
    class procedure InitReinforceA01; static;
    class procedure InitReinforce3; static;
    class procedure InitReinforce2; static;
  end;
implementation
uses
  GlobalDefs, Windows, FilesData, Log, MiscData, SysUtils, IniFiles, Functions,
  Classes,
  ServerSocket, LoginSocket, TokenSocket, System.Ansistrings, SQL;
class procedure TLoad.InitCharacters;
begin
  ZeroMemory(@InitialAccounts[0], 6 * sizeof(TCharacterDB));
  TFunctions.LoadBasicCharacter('Guerreiro', InitialAccounts[0]);
  TFunctions.LoadBasicCharacter('Templaria', InitialAccounts[1]);
  TFunctions.LoadBasicCharacter('Atirador', InitialAccounts[2]);
  TFunctions.LoadBasicCharacter('Pistoleira', InitialAccounts[3]);
  TFunctions.LoadBasicCharacter('Feiticeiro', InitialAccounts[4]);
  TFunctions.LoadBasicCharacter('Cleriga', InitialAccounts[5]);
end;
class procedure TLoad.InitGuilds();
var
  I, M, GuildCnt, MemberCnt, ItemCnt, ID, Slot: Integer;
  GuildQuery: TQuery;
  ItemSlot: Byte;
begin
  ZeroMemory(@Guilds, sizeof(Guilds));
  InstantiatedGuilds := 0;
  GuildQuery := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(GuildQuery.Query.Connection.Connected) then
  begin
    Logger.Write('GuildQuery connection MySQL has failed.', TLogType.Error);
    GuildQuery.Destroy;
    Exit;
  end;
  GuildQuery.SetQuery('SELECT * FROM guilds');
  GuildQuery.Run();
  GuildCnt := GuildQuery.Query.RecordCount;
  if not(GuildCnt = 0) then
  begin
    GuildQuery.Query.First;
    for I := 0 to (GuildCnt - 1) do
    begin
      ID := Integer(GuildQuery.Query.FieldByName('id').AsInteger);
      Slot := Integer(GuildQuery.Query.FieldByName('slot').AsInteger);
      Guilds[Slot].Index := ID;
      Guilds[Slot].Slot := Slot;
      Guilds[Slot].Nation := DWORD(GuildQuery.Query.FieldByName('nation')
        .AsInteger);
      Guilds[Slot].Exp := DWORD(GuildQuery.Query.FieldByName('experience')
        .AsInteger);
      Guilds[Slot].Level := DWORD(GuildQuery.Query.FieldByName('level')
        .AsInteger);
      Guilds[Slot].TotalMembers :=
        GuildQuery.Query.FieldByName('totalmembers').AsInteger;
      Guilds[Slot].BravurePoints :=
        GuildQuery.Query.FieldByName('bravurepoints').AsInteger;
      Guilds[Slot].SkillPoints :=
        GuildQuery.Query.FieldByName('skillpoints').AsInteger;
      Guilds[Slot].Promote := Boolean(GuildQuery.Query.FieldByName('promote')
        .AsInteger);
      System.Ansistrings.StrPlCopy(Guilds[Slot].Name,
        AnsiString(GuildQuery.Query.FieldByName('name').AsString), 19);
      System.Ansistrings.StrPlCopy(Guilds[Slot].Notices[0].Text,
        AnsiString(GuildQuery.Query.FieldByName('notice1').AsString), 34);
      System.Ansistrings.StrPlCopy(Guilds[Slot].Notices[1].Text,
        AnsiString(GuildQuery.Query.FieldByName('notice2').AsString), 34);
      System.Ansistrings.StrPlCopy(Guilds[Slot].Notices[2].Text,
        AnsiString(GuildQuery.Query.FieldByName('notice3').AsString), 34);
      Guilds[Slot].RanksConfig[0] :=
        (GuildQuery.Query.FieldByName('rank1').AsInteger);
      Guilds[Slot].RanksConfig[1] :=
        (GuildQuery.Query.FieldByName('rank2').AsInteger);
      Guilds[Slot].RanksConfig[2] :=
        (GuildQuery.Query.FieldByName('rank3').AsInteger);
      Guilds[Slot].RanksConfig[3] :=
        (GuildQuery.Query.FieldByName('rank4').AsInteger);
      Guilds[Slot].RanksConfig[4] :=
        (GuildQuery.Query.FieldByName('rank5').AsInteger);
      System.Ansistrings.StrPlCopy(Guilds[Slot].Site,
        AnsiString(GuildQuery.Query.FieldByName('site').AsString), 38);
      Guilds[Slot].Ally.Leader :=
        (GuildQuery.Query.FieldByName('ally_leader').AsInteger);
      Guilds[Slot].Ally.Guilds[0].Index :=
        (GuildQuery.Query.FieldByName('guild_ally1_index').AsInteger);
      Guilds[Slot].Ally.Guilds[1].Index :=
        (GuildQuery.Query.FieldByName('guild_ally2_index').AsInteger);
      Guilds[Slot].Ally.Guilds[2].Index :=
        (GuildQuery.Query.FieldByName('guild_ally3_index').AsInteger);
      Guilds[Slot].Ally.Guilds[3].Index :=
        (GuildQuery.Query.FieldByName('guild_ally4_index').AsInteger);
      System.Ansistrings.StrPlCopy(Guilds[Slot].Ally.Guilds[0].Name,
        AnsiString(GuildQuery.Query.FieldByName('guild_ally1_name')
        .AsString), 18);
      System.Ansistrings.StrPlCopy(Guilds[Slot].Ally.Guilds[1].Name,
        AnsiString(GuildQuery.Query.FieldByName('guild_ally2_name')
        .AsString), 18);
      System.Ansistrings.StrPlCopy(Guilds[Slot].Ally.Guilds[2].Name,
        AnsiString(GuildQuery.Query.FieldByName('guild_ally3_name')
        .AsString), 18);
      System.Ansistrings.StrPlCopy(Guilds[Slot].Ally.Guilds[3].Name,
        AnsiString(GuildQuery.Query.FieldByName('guild_ally4_name')
        .AsString), 18);
      Guilds[Slot].Chest.Gold := GuildQuery.Query.FieldByName('storage_gold')
        .AsLargeInt;
      Guilds[Slot].GuildLeaderCharIndex := GuildQuery.Query.FieldByName
        ('leader_char_index').AsLargeInt;
      Guilds[Slot].MemberInChest := $FF;
      GuildQuery.Query.Next;
    end;
    for I := 1 to (GuildCnt) do
    begin
      { Guild Members }
      Slot := I;
      if (Guilds[I].Index = 0) then
        continue;
      ID := Guilds[Slot].Index;
      GuildQuery.SetQuery
        ('SELECT * FROM guilds_players WHERE guild_index=:pguild_index');
      GuildQuery.AddParameter2('pguild_index', ID);
      GuildQuery.Run();
      MemberCnt := GuildQuery.Query.RecordCount;
      if not(MemberCnt = 0) then
      begin
        GuildQuery.Query.First;
        for M := 0 to (MemberCnt - 1) do
        begin
          Guilds[Slot].Members[M].CharIndex := GuildQuery.Query.FieldByName
            ('char_index').AsLargeInt;
          System.Ansistrings.StrPlCopy(Guilds[Slot].Members[M].Name,
            AnsiString(GuildQuery.Query.FieldByName('name').AsString), 20);
          Guilds[Slot].Members[M].Rank :=
            Byte(GuildQuery.Query.FieldByName('player_rank').AsInteger);
          Guilds[Slot].Members[M].ClassInfo :=
            Byte(GuildQuery.Query.FieldByName('classinfo').AsInteger);
          Guilds[Slot].Members[M].Level :=
            Byte(GuildQuery.Query.FieldByName('level').AsInteger);
          Guilds[Slot].Members[M].Logged :=
            Boolean(GuildQuery.Query.FieldByName('logged').AsInteger);
          Guilds[Slot].Members[M].LastLogin :=
            (GuildQuery.Query.FieldByName('last_login').AsInteger);

          GuildQuery.Query.Next;
        end;
      end;
      { Guild Items }
      GuildQuery.SetQuery
        ('SELECT * FROM items WHERE slot_type=:pslot_type AND owner_id=:powner_id LIMIT 50');
      GuildQuery.AddParameter2('pslot_type', 3);
      GuildQuery.AddParameter2('powner_id', ID);
      GuildQuery.Run();
      ItemCnt := GuildQuery.Query.RecordCount;
      if not(ItemCnt = 0) then
      begin
        GuildQuery.Query.First;
        for M := 0 to (ItemCnt - 1) do
        begin
          ItemSlot := Byte(GuildQuery.Query.FieldByName('slot').AsInteger);
          Guilds[Slot].Chest.Items[ItemSlot].Index :=
            WORD(GuildQuery.Query.FieldByName('item_id').AsInteger);
          Guilds[Slot].Chest.Items[ItemSlot].APP :=
            WORD(GuildQuery.Query.FieldByName('app').AsInteger);
          Guilds[Slot].Chest.Items[ItemSlot].Identific :=
            (GuildQuery.Query.FieldByName('identific').AsInteger);
          Guilds[Slot].Chest.Items[ItemSlot].Effects.Index[0] :=
            Byte(GuildQuery.Query.FieldByName('effect1_index').AsInteger);
          Guilds[Slot].Chest.Items[ItemSlot].Effects.Index[1] :=
            Byte(GuildQuery.Query.FieldByName('effect2_index').AsInteger);
          Guilds[Slot].Chest.Items[ItemSlot].Effects.Index[2] :=
            Byte(GuildQuery.Query.FieldByName('effect3_index').AsInteger);
          Guilds[Slot].Chest.Items[ItemSlot].Effects.Value[0] :=
            Byte(GuildQuery.Query.FieldByName('effect1_value').AsInteger);
          Guilds[Slot].Chest.Items[ItemSlot].Effects.Value[1] :=
            Byte(GuildQuery.Query.FieldByName('effect2_value').AsInteger);
          Guilds[Slot].Chest.Items[ItemSlot].Effects.Value[2] :=
            Byte(GuildQuery.Query.FieldByName('effect3_value').AsInteger);
          Guilds[Slot].Chest.Items[ItemSlot].MIN :=
            Byte(GuildQuery.Query.FieldByName('min').AsInteger);
          Guilds[Slot].Chest.Items[ItemSlot].MAX :=
            Byte(GuildQuery.Query.FieldByName('max').AsInteger);
          Guilds[Slot].Chest.Items[ItemSlot].Refi :=
            WORD(GuildQuery.Query.FieldByName('refine').AsInteger);
          Guilds[Slot].Chest.Items[ItemSlot].Time :=
            WORD(GuildQuery.Query.FieldByName('time').AsInteger);

          GuildQuery.Query.Next;
        end;
      end;
    end;
  end;
  InstantiatedGuilds := GuildCnt;
  GuildQuery.Destroy;
  Logger.Write('O servidor carregou ' + IntToStr(InstantiatedGuilds) +
    ' guilds com sucesso.', TLogType.ServerStatus);
end;
class function TLoad.LoadGuild(const FName: string; out Guild: TGuild): Boolean;
var
  f: File of TGuild;
begin
  Result := False;
  try
    if not(FileExists(DATABASE_PATH + 'Guilds\' + FName)) then
      Exit;
    AssignFile(f, DATABASE_PATH + 'Guilds\' + FName);
    Reset(f);
    Read(f, Guild);
    CloseFile(f);
  except
    Exit;
  end;
  Result := true;
end;
class procedure TLoad.InitItemList;
var
  f: File of TItemList;
  local: string;
begin
  local := GetCurrentDir + '\Data\ItemList.bin';
  if (FileExists(local)) then
  begin
    try
      AssignFile(f, local);
      Reset(f);
      Read(f, ItemList);
      CloseFile(f);
      Logger.Write('ItemList.bin carregado com sucesso.',
        TLogType.ServerStatus);
    except
      on E: Exception do
      begin
        Logger.Write(E.ClassName + ': ' + E.Message, TLogType.Warnings);
        CloseFile(f);
      end;
    end;
  end;
end;
class procedure TLoad.InitSkillData;
var
  f: File of TSkillData;
  local: string;
begin
  local := GetCurrentDir + '\Data\SkillData.bin';
  if (FileExists(local)) then
  begin
    try
      AssignFile(f, local);
      Reset(f);
      Read(f, SkillData);
      CloseFile(f);
      Logger.Write('SkillData.bin carregado com sucesso.',
        TLogType.ServerStatus);
    except
      on E: Exception do
      begin
        Logger.Write(E.ClassName + ': ' + E.Message, TLogType.Warnings);
        CloseFile(f);
      end;
    end;
  end;
end;
class procedure TLoad.InitSetItem;
var
  f: File of TSetItem;
  local: string;
begin
  local := GetCurrentDir + '\Data\SetItem.bin';
  if (FileExists(local)) then
  begin
    try
      AssignFile(f, local);
      Reset(f);
      Read(f, SetItem);
      CloseFile(f);
      Logger.Write('SetItem.bin carregado com sucesso.', TLogType.ServerStatus);
    except
      on E: Exception do
      begin
        Logger.Write(E.ClassName + ': ' + E.Message, TLogType.Warnings);
        CloseFile(f);
      end;
    end;
  end;
end;
class procedure TLoad.InitConjunts;
var
  f: File of TConjunts;
  local: string;
begin
  local := GetCurrentDir + '\Data\Conjunts.bin';
  if (FileExists(local)) then
  begin
    try
      AssignFile(f, local);
      Reset(f);
      Read(f, Conjuntos);
      CloseFile(f);
      Logger.Write('Conjunts.bin carregado com sucesso.',
        TLogType.ServerStatus);
    except
      on E: Exception do
      begin
        Logger.Write(E.ClassName + ': ' + E.Message, TLogType.Warnings);
        CloseFile(f);
      end;
    end;
  end;
end;
{$REGION 'Reinforce'}
class procedure TLoad.InitReinforceW01;
var
  Len: Integer;
  f: TFileStream;
  FName: string;
begin
  FName := GetCurrentDir + '\Data\ReinforceW01.bin';
  if not(FileExists(FName)) then
  begin
    Logger.Write('ReinforceW01.bin não encontrado.', TLogType.Warnings);
    Exit;
  end;
  f := TFileStream.Create(FName, FmOpenRead);
  Len := Trunc(f.Size / sizeof(TItemChanceReinforce));
  try
    SetLength(ReinforceW01, Len);
    f.ReadBuffer(ReinforceW01[0], f.Size);
    Logger.Write('ReinforceW01.bin carregado com sucesso.',
      TLogType.ServerStatus);
  finally
    f.Free;
  end;
end;
class procedure TLoad.InitReinforceA01;
var
  Len: Integer;
  f: TFileStream;
  FName: string;
begin
  FName := GetCurrentDir + '\Data\ReinforceA01.bin';
  if not(FileExists(FName)) then
  begin
    Logger.Write('ReinforceA01.bin não encontrado.', TLogType.Warnings);
    Exit;
  end;
  f := TFileStream.Create(FName, FmOpenRead);
  Len := Trunc(f.Size / sizeof(TItemChanceReinforce));
  try
    SetLength(ReinforceA01, Len);
    f.ReadBuffer(ReinforceA01[0], f.Size);
    Logger.Write('ReinforceA01.bin carregado com sucesso.',
      TLogType.ServerStatus);
  finally
    f.Free;
  end;
end;
class procedure TLoad.InitReinforce3;
var
  FName: string;
  f: TFileStream;
  FLength: UInt32;
begin
  FName := GetCurrentDir + '\Data\Reinforce3.bin';
  if not(FileExists(FName)) then
  begin
    Logger.Write('Reinforce3.bin não encontrado.', TLogType.Warnings);
    Exit;
  end;
  f := TFileStream.Create(FName, FmOpenRead);
  FLength := f.Size div sizeof(ArmorAttributeReinforce);
  SetLength(Reinforce3, FLength);
  try
    f.ReadBuffer(Reinforce3[0], f.Size);
  finally
    f.Free;
    Logger.Write('Reinforce3.bin carregado com sucesso.',
      TLogType.ServerStatus);
  end;
end;
class procedure TLoad.InitReinforce2;
var
  FName: string;
  f: TFileStream;
  FLength: UInt32;
begin
  FName := GetCurrentDir + '\Data\Reinforce2.bin';
  if not(FileExists(FName)) then
  begin
    Logger.Write('Reinforce2.bin não encontrado.', TLogType.Warnings);
    Exit;
  end;
  f := TFileStream.Create(FName, FmOpenRead);
  FLength := f.Size div sizeof(TItemAttributeReinforce);
  SetLength(Reinforce2, FLength);
  try
    f.ReadBuffer(Reinforce2[0], f.Size);
  finally
    f.Free;
    Logger.Write('Reinforce2.bin carregado com sucesso.',
      TLogType.ServerStatus);
  end;
end;
class procedure TLoad.InitReinforce;
begin
  Self.InitReinforceW01;
  Self.InitReinforceA01;
  Self.InitReinforce2;
  Self.InitReinforce3;
end;
{$ENDREGION}
class procedure TLoad.InitPremiumItems;
var
  FSize, Len: Integer;
  f: TFileStream;
  FName: string;
begin
  FName := GetCurrentDir + '\Data\PI.bin';
  if not(FileExists(FName)) then
  begin
    Logger.Write('PI.bin não encontrado.', TLogType.Warnings);
    Exit;
  end;
  f := TFileStream.Create(FName, FmOpenRead);
  FSize := f.Size;
  Len := Round(FSize div $178);
  SetLength(PremiumItems, Len);
  try
    f.Position := 0;
    f.ReadBuffer(PremiumItems[0], f.Size);
    f.Free;
  except
    f.Free;
    Exit;
  end;
  Logger.Write('PI.bin carregado com sucesso.', TLogType.ServerStatus);
end;
class procedure TLoad.InitMobPos;
var
  FSize, Len: Integer;
  f: TFileStream;
  FName: string;
begin
  FName := GetCurrentDir + '\Data\MobPos.bin';
  if not(FileExists(FName)) then
  begin
    Logger.Write('MobPos.bin não encontrado.', TLogType.Warnings);
    Exit;
  end;
  f := TFileStream.Create(FName, FmOpenRead);
  FSize := f.Size;
  Len := Round(FSize div $1A0);
  SetLength(MobPos, Len);
  try
    f.Position := 0;
    f.ReadBuffer(MobPos[0], f.Size);
    f.Free;
  except
    f.Free;
    Exit;
  end;
  Logger.Write('MobPos.bin carregado com sucesso.', TLogType.ServerStatus);
end;
class procedure TLoad.InitExpList;
var
  FSize, Len: Integer;
  f: TFileStream;
  FName: string;
begin
  FName := GetCurrentDir + '\Data\ExpList.bin';
  if not(FileExists(FName)) then
  begin
    Logger.Write('ExpList.bin não encontrado.', TLogType.Warnings);
    Exit;
  end;
  f := TFileStream.Create(FName, FmOpenRead);
  FSize := f.Size;
  Len := Round(FSize div sizeof(UInt64));
  SetLength(ExpList, Len);
  try
    f.Position := 0;
    f.ReadBuffer(ExpList[0], f.Size);
    f.Free;
  except
    f.Free;
    Exit;
  end;
  Logger.Write('ExpList.bin carregado com sucesso.', TLogType.ServerStatus);
end;
class procedure TLoad.InitPranExpList;
var
  FSize, Len: Integer;
  f: TFileStream;
  FName: string;
begin
  FName := GetCurrentDir + '\Data\PranExpList.bin';
  if not(FileExists(FName)) then
  begin
    Logger.Write('PranExpList.bin não encontrado.', TLogType.Warnings);
    Exit;
  end;
  f := TFileStream.Create(FName, FmOpenRead);
  FSize := f.Size;
  Len := Round(FSize div sizeof(DWORD));
  SetLength(PranExpList, Len);
  try
    f.Position := 0;
    f.ReadBuffer(PranExpList[0], f.Size);
    f.Free;
  except
    f.Free;
    Exit;
  end;
  Logger.Write('PranExpList.bin carregado com sucesso.', TLogType.ServerStatus);
end;
class procedure TLoad.InitQuestList;
var
  FSize, Len: Integer;
  f: TFileStream;
  FName: string;
begin
  FName := GetCurrentDir + '\Data\Quest.bin';
  if not(FileExists(FName)) then
  begin
    Logger.Write('Quest.bin não encontrado.', TLogType.Warnings);
    Exit;
  end;
  f := TFileStream.Create(FName, FmOpenRead);
  FSize := f.Size;
  Len := Round(FSize div $91C);
  SetLength(Quests, Len);
  try
    f.Position := 0;
    f.ReadBuffer(Quests[0], f.Size);
    f.Free;
  except
    f.Free;
    Exit;
  end;
  Logger.Write('Quest.bin carregado com sucesso.', TLogType.ServerStatus);
end;
class procedure TLoad.InitQuests;
var
  Path: String;
  DataFile, f: TextFile;
  FileStrings: TStringList;
  Count: DWORD;
  LineFile: String;
begin
  Path := GetCurrentDir + '\Data\Quest\Quests.csv';
  if not(FileExists(Path)) then
  begin
    Logger.Write('O arquivo Quests.csv não foi encontrado.', TLogType.Warnings);
    Exit;
  end;
  AssignFile(DataFile, Path);
  Reset(DataFile);
  FileStrings := TStringList.Create;
  Count := 0;
  while not EOF(DataFile) do
  begin
    ReadLn(DataFile, LineFile);
    ExtractStrings([','], [' '], PChar(LineFile), FileStrings);
    _Quests[Count].NPCID := FileStrings[0].ToInteger();
    _Quests[Count].QuestID := FileStrings[1].ToInteger();
    _Quests[Count].QuestType := FileStrings[2].ToInteger();
    _Quests[Count].QuestMark := FileStrings[3].ToInteger();
    _Quests[Count].Rewards[0] := FileStrings[4].ToInteger();
    _Quests[Count].Rewards[1] := FileStrings[5].ToInteger();
    _Quests[Count].Rewards[2] := FileStrings[6].ToInteger();
    _Quests[Count].Rewards[3] := FileStrings[7].ToInteger();
    _Quests[Count].Rewards[4] := FileStrings[8].ToInteger();
    _Quests[Count].Rewards[5] := FileStrings[9].ToInteger();
    _Quests[Count].Requiriments[0] := FileStrings[10].ToInteger();
    _Quests[Count].Requiriments[1] := FileStrings[11].ToInteger();
    _Quests[Count].Requiriments[2] := FileStrings[12].ToInteger();
    _Quests[Count].Requiriments[3] := FileStrings[13].ToInteger();
    _Quests[Count].Requiriments[4] := FileStrings[14].ToInteger();
    _Quests[Count].RequirimentsType[0] := FileStrings[15].ToInteger();
    _Quests[Count].RequirimentsType[1] := FileStrings[16].ToInteger();
    _Quests[Count].RequirimentsType[2] := FileStrings[17].ToInteger();
    _Quests[Count].RequirimentsType[3] := FileStrings[18].ToInteger();
    _Quests[Count].RequirimentsType[4] := FileStrings[19].ToInteger();
    _Quests[Count].RequirimentsAmount[0] := FileStrings[20].ToInteger();
    _Quests[Count].RequirimentsAmount[1] := FileStrings[21].ToInteger();
    _Quests[Count].RequirimentsAmount[2] := FileStrings[22].ToInteger();
    _Quests[Count].RequirimentsAmount[3] := FileStrings[23].ToInteger();
    _Quests[Count].RequirimentsAmount[4] := FileStrings[24].ToInteger();
    _Quests[Count].DeletesItem[0] := FileStrings[25].ToInteger();
    _Quests[Count].DeletesItem[1] := FileStrings[26].ToInteger();
    _Quests[Count].DeletesItem[2] := FileStrings[27].ToInteger();
    _Quests[Count].DeletesAmount[0] := FileStrings[28].ToInteger();
    _Quests[Count].DeletesAmount[1] := FileStrings[29].ToInteger();
    _Quests[Count].DeletesAmount[2] := FileStrings[30].ToInteger();
    _Quests[Count].Gold := FileStrings[31].ToInteger();
    _Quests[Count].Exp := FileStrings[32].ToInteger();
    _Quests[Count].LevelMin := FileStrings[33].ToInteger();
    FileStrings.Clear;
    inc(Count);
  end;
  CloseFile(DataFile);
  Logger.Write(Count.toString + ' quests foram carregadas com sucesso.',
    TLogType.ServerStatus);
end;
class procedure TLoad.InitTitles;
var
  f: File of TitleList;
  local: string;
begin
  local := GetCurrentDir + '\Data\Title.bin';
  if (FileExists(local)) then
  begin
    try
      AssignFile(f, local);
      Reset(f);
      Read(f, Titles);
      CloseFile(f);
      Logger.Write('Title.bin carregado com sucesso.', TLogType.ServerStatus);
    except
      on E: Exception do
      begin
        Logger.Write(E.ClassName + ': ' + E.Message, TLogType.Warnings);
        CloseFile(f);
      end;
    end;
  end;
  {
    var
    FSize, Len: Integer;
    f: TFileStream;
    FName: string;
    begin

    FName := GetCurrentDir + '\Data\Title.bin';
    if not(FileExists(FName)) then
    begin
    Logger.Write('Title.bin não encontrado.', TLogType.Warnings);
    Exit;
    end;
    f := TFileStream.Create(FName, FmOpenRead);
    FSize := //f.Size;
    Len := 255;//Trunc(FSize / sizeof(TitleFromList));
    SetLength(Titles, Len);
    try
    f.Position := 0;
    f.ReadBuffer(Titles[0], f.Size);
    f.Free;
    except
    f.Free;
    Exit;
    end;
    Logger.Write('Title.bin carregado com sucesso.', TLogType.ServerStatus); }
end;
class procedure TLoad.InitDropList;
var
  Path: String;
  DataFile, f: TextFile;
  FileStrings: TStringList;
  NormalCount, SuperiorCount, RareCount, LegendaryCount: DWORD;
  LineFile: String;
  ItemType: Byte;
begin
  Path := GetCurrentDir + '\Data\Drops\Monsters_0_20_DropList.csv';
  if not(FileExists(Path)) then
  begin
    Logger.Write('O arquivo Monsters_0_20_DropList.csv não foi encontrado.',
      TLogType.Warnings);
    Exit;
  end;
  AssignFile(DataFile, Path);
  Reset(DataFile);
  FileStrings := TStringList.Create;
  NormalCount := 0;
  SuperiorCount := 0;
  RareCount := 0;
  LegendaryCount := 0;
  while not EOF(DataFile) do
  begin
    ReadLn(DataFile, LineFile);
    ExtractStrings([','], [' '], PChar(LineFile), FileStrings);
    ItemType := FileStrings[2].ToInteger();
    case ItemType of
      DROP_NORMAL_ITEM:
        begin
          SetLength(Drops[MONSTERS_0_20].NormalItems, (NormalCount + 1));
          Drops[MONSTERS_0_20].NormalItems[NormalCount] :=
            FileStrings[1].ToInteger();
          inc(NormalCount);
        end;
      DROP_SUPERIOR_ITEM:
        begin
          SetLength(Drops[MONSTERS_0_20].SuperiorItems, (SuperiorCount + 1));
          Drops[MONSTERS_0_20].SuperiorItems[SuperiorCount] :=
            FileStrings[1].ToInteger();
          inc(SuperiorCount);
        end;
      DROP_RARE_ITEM:
        begin
          SetLength(Drops[MONSTERS_0_20].RareItems, (RareCount + 1));
          Drops[MONSTERS_0_20].RareItems[RareCount] :=
            FileStrings[1].ToInteger();
          inc(RareCount);
        end;
      DROP_LEGENDARY_ITEM:
        begin
          SetLength(Drops[MONSTERS_0_20].LegendaryItems, (LegendaryCount + 1));
          Drops[MONSTERS_0_20].LegendaryItems[LegendaryCount] :=
            FileStrings[1].ToInteger();
          inc(LegendaryCount);
        end;
    end;
    FileStrings.Clear;
  end;
  Logger.Write('Monsters_0_20_DropList.csv carregado com sucesso.',
    TLogType.ServerStatus);
  CloseFile(DataFile);
  Path := GetCurrentDir + '\Data\Drops\Monsters_21_40_DropList.csv';
  if not(FileExists(Path)) then
  begin
    Logger.Write('O arquivo Monsters_21_40_DropList.csv não foi encontrado.',
      TLogType.Warnings);
    Exit;
  end;
  AssignFile(DataFile, Path);
  Reset(DataFile);
  FileStrings := TStringList.Create;
  NormalCount := 0;
  SuperiorCount := 0;
  RareCount := 0;
  LegendaryCount := 0;
  while not EOF(DataFile) do
  begin
    ReadLn(DataFile, LineFile);
    ExtractStrings([','], [' '], PChar(LineFile), FileStrings);
    ItemType := FileStrings[2].ToInteger();
    case ItemType of
      DROP_NORMAL_ITEM:
        begin
          SetLength(Drops[MONSTERS_21_40].NormalItems, (NormalCount + 1));
          Drops[MONSTERS_21_40].NormalItems[NormalCount] :=
            FileStrings[1].ToInteger();
          inc(NormalCount);
        end;
      DROP_SUPERIOR_ITEM:
        begin
          SetLength(Drops[MONSTERS_21_40].SuperiorItems, (SuperiorCount + 1));
          Drops[MONSTERS_21_40].SuperiorItems[SuperiorCount] :=
            FileStrings[1].ToInteger();
          inc(SuperiorCount);
        end;
      DROP_RARE_ITEM:
        begin
          SetLength(Drops[MONSTERS_21_40].RareItems, (RareCount + 1));
          Drops[MONSTERS_21_40].RareItems[RareCount] :=
            FileStrings[1].ToInteger();
          inc(RareCount);
        end;
      DROP_LEGENDARY_ITEM:
        begin
          SetLength(Drops[MONSTERS_21_40].LegendaryItems, (LegendaryCount + 1));
          Drops[MONSTERS_21_40].LegendaryItems[LegendaryCount] :=
            FileStrings[1].ToInteger();
          inc(LegendaryCount);
        end;
    end;
    FileStrings.Clear;
  end;
  Logger.Write('Monsters_21_40_DropList.csv carregado com sucesso.',
    TLogType.ServerStatus);
  CloseFile(DataFile);
  Path := GetCurrentDir + '\Data\Drops\Monsters_41_60_DropList.csv';
  if not(FileExists(Path)) then
  begin
    Logger.Write('O arquivo Monsters_41_60_DropList.csv não foi encontrado.',
      TLogType.Warnings);
    Exit;
  end;
  AssignFile(DataFile, Path);
  Reset(DataFile);
  FileStrings := TStringList.Create;
  NormalCount := 0;
  SuperiorCount := 0;
  RareCount := 0;
  LegendaryCount := 0;
  while not EOF(DataFile) do
  begin
    ReadLn(DataFile, LineFile);
    ExtractStrings([','], [' '], PChar(LineFile), FileStrings);
    ItemType := FileStrings[2].ToInteger();
    case ItemType of
      DROP_NORMAL_ITEM:
        begin
          SetLength(Drops[MONSTERS_41_60].NormalItems, (NormalCount + 1));
          Drops[MONSTERS_41_60].NormalItems[NormalCount] :=
            FileStrings[1].ToInteger();
          inc(NormalCount);
        end;
      DROP_SUPERIOR_ITEM:
        begin
          SetLength(Drops[MONSTERS_41_60].SuperiorItems, (SuperiorCount + 1));
          Drops[MONSTERS_41_60].SuperiorItems[SuperiorCount] :=
            FileStrings[1].ToInteger();
          inc(SuperiorCount);
        end;
      DROP_RARE_ITEM:
        begin
          SetLength(Drops[MONSTERS_41_60].RareItems, (RareCount + 1));
          Drops[MONSTERS_41_60].RareItems[RareCount] :=
            FileStrings[1].ToInteger();
          inc(RareCount);
        end;
      DROP_LEGENDARY_ITEM:
        begin
          SetLength(Drops[MONSTERS_41_60].LegendaryItems, (LegendaryCount + 1));
          Drops[MONSTERS_41_60].LegendaryItems[LegendaryCount] :=
            FileStrings[1].ToInteger();
          inc(LegendaryCount);
        end;
    end;
    FileStrings.Clear;
  end;
  Logger.Write('Monsters_41_60_DropList.csv carregado com sucesso.',
    TLogType.ServerStatus);
  CloseFile(DataFile);
  Path := GetCurrentDir + '\Data\Drops\Monsters_61_80_DropList.csv';
  if not(FileExists(Path)) then
  begin
    Logger.Write('O arquivo Monsters_61_80_DropList.csv não foi encontrado.',
      TLogType.Warnings);
    Exit;
  end;
  AssignFile(DataFile, Path);
  Reset(DataFile);
  FileStrings := TStringList.Create;
  NormalCount := 0;
  SuperiorCount := 0;
  RareCount := 0;
  LegendaryCount := 0;
  while not EOF(DataFile) do
  begin
    ReadLn(DataFile, LineFile);
    ExtractStrings([','], [' '], PChar(LineFile), FileStrings);
    ItemType := FileStrings[2].ToInteger();
    case ItemType of
      DROP_NORMAL_ITEM:
        begin
          SetLength(Drops[MONSTERS_61_80].NormalItems, (NormalCount + 1));
          Drops[MONSTERS_61_80].NormalItems[NormalCount] :=
            FileStrings[1].ToInteger();
          inc(NormalCount);
        end;
      DROP_SUPERIOR_ITEM:
        begin
          SetLength(Drops[MONSTERS_61_80].SuperiorItems, (SuperiorCount + 1));
          Drops[MONSTERS_61_80].SuperiorItems[SuperiorCount] :=
            FileStrings[1].ToInteger();
          inc(SuperiorCount);
        end;
      DROP_RARE_ITEM:
        begin
          SetLength(Drops[MONSTERS_61_80].RareItems, (RareCount + 1));
          Drops[MONSTERS_61_80].RareItems[RareCount] :=
            FileStrings[1].ToInteger();
          inc(RareCount);
        end;
      DROP_LEGENDARY_ITEM:
        begin
          SetLength(Drops[MONSTERS_61_80].LegendaryItems, (LegendaryCount + 1));
          Drops[MONSTERS_61_80].LegendaryItems[LegendaryCount] :=
            FileStrings[1].ToInteger();
          inc(LegendaryCount);
        end;
    end;
    FileStrings.Clear;
  end;
  Logger.Write('Monsters_61_80_DropList.csv carregado com sucesso.',
    TLogType.ServerStatus);
  CloseFile(DataFile);
  Path := GetCurrentDir + '\Data\Drops\Monsters_81_99_DropList.csv';
  if not(FileExists(Path)) then
  begin
    Logger.Write('O arquivo Monsters_81_99_DropList.csv não foi encontrado.',
      TLogType.Warnings);
    Exit;
  end;
  AssignFile(DataFile, Path);
  Reset(DataFile);
  FileStrings := TStringList.Create;
  NormalCount := 0;
  SuperiorCount := 0;
  RareCount := 0;
  LegendaryCount := 0;
  while not EOF(DataFile) do
  begin
    ReadLn(DataFile, LineFile);
    ExtractStrings([','], [' '], PChar(LineFile), FileStrings);
    ItemType := FileStrings[2].ToInteger();
    case ItemType of
      DROP_NORMAL_ITEM:
        begin
          SetLength(Drops[MONSTERS_81_99].NormalItems, (NormalCount + 1));
          Drops[MONSTERS_81_99].NormalItems[NormalCount] :=
            FileStrings[1].ToInteger();
          inc(NormalCount);
        end;
      DROP_SUPERIOR_ITEM:
        begin
          SetLength(Drops[MONSTERS_81_99].SuperiorItems, (SuperiorCount + 1));
          Drops[MONSTERS_81_99].SuperiorItems[SuperiorCount] :=
            FileStrings[1].ToInteger();
          inc(SuperiorCount);
        end;
      DROP_RARE_ITEM:
        begin
          SetLength(Drops[MONSTERS_81_99].RareItems, (RareCount + 1));
          Drops[MONSTERS_81_99].RareItems[RareCount] :=
            FileStrings[1].ToInteger();
          inc(RareCount);
        end;
      DROP_LEGENDARY_ITEM:
        begin
          SetLength(Drops[MONSTERS_81_99].LegendaryItems, (LegendaryCount + 1));
          Drops[MONSTERS_81_99].LegendaryItems[LegendaryCount] :=
            FileStrings[1].ToInteger();
          inc(LegendaryCount);
        end;
    end;
    FileStrings.Clear;
  end;
  Logger.Write('Monsters_81_99_DropList.csv carregado com sucesso.',
    TLogType.ServerStatus);
  CloseFile(DataFile);
  Path := GetCurrentDir + '\Data\Drops\Buto_DropList.csv';
  if not(FileExists(Path)) then
  begin
    Logger.Write('O arquivo Buto_DropList.csv não foi encontrado.',
      TLogType.Warnings);
    Exit;
  end;
  AssignFile(DataFile, Path);
  Reset(DataFile);
  FileStrings := TStringList.Create;
  NormalCount := 0;
  SuperiorCount := 0;
  RareCount := 0;
  LegendaryCount := 0;
  while not EOF(DataFile) do
  begin
    ReadLn(DataFile, LineFile);
    ExtractStrings([','], [' '], PChar(LineFile), FileStrings);
    ItemType := FileStrings[2].ToInteger();
    case ItemType of
      DROP_NORMAL_ITEM:
        begin
          SetLength(Drops[MONSTERS_BUTO].NormalItems, (NormalCount + 1));
          Drops[MONSTERS_BUTO].NormalItems[NormalCount] :=
            FileStrings[1].ToInteger();
          inc(NormalCount);
        end;
      DROP_SUPERIOR_ITEM:
        begin
          SetLength(Drops[MONSTERS_BUTO].SuperiorItems, (SuperiorCount + 1));
          Drops[MONSTERS_BUTO].SuperiorItems[SuperiorCount] :=
            FileStrings[1].ToInteger();
          inc(SuperiorCount);
        end;
      DROP_RARE_ITEM:
        begin
          SetLength(Drops[MONSTERS_BUTO].RareItems, (RareCount + 1));
          Drops[MONSTERS_BUTO].RareItems[RareCount] :=
            FileStrings[1].ToInteger();
          inc(RareCount);
        end;
      DROP_LEGENDARY_ITEM:
        begin
          SetLength(Drops[MONSTERS_BUTO].LegendaryItems, (LegendaryCount + 1));
          Drops[MONSTERS_BUTO].LegendaryItems[LegendaryCount] :=
            FileStrings[1].ToInteger();
          inc(LegendaryCount);
        end;
    end;
    FileStrings.Clear;
  end;
  Logger.Write('Buto_DropList.csv carregado com sucesso.',
    TLogType.ServerStatus);
  CloseFile(DataFile);
  Path := GetCurrentDir + '\Data\Drops\CroshuAzul_DropList.csv';
  if not(FileExists(Path)) then
  begin
    Logger.Write('O arquivo CroshuAzul_DropList.csv não foi encontrado.',
      TLogType.Warnings);
    Exit;
  end;
  AssignFile(DataFile, Path);
  Reset(DataFile);
  FileStrings := TStringList.Create;
  NormalCount := 0;
  SuperiorCount := 0;
  RareCount := 0;
  LegendaryCount := 0;
  while not EOF(DataFile) do
  begin
    ReadLn(DataFile, LineFile);
    ExtractStrings([','], [' '], PChar(LineFile), FileStrings);
    ItemType := FileStrings[2].ToInteger();
    case ItemType of
      DROP_NORMAL_ITEM:
        begin
          SetLength(Drops[MONSTERS_CROSHU_AZUL].NormalItems, (NormalCount + 1));
          Drops[MONSTERS_CROSHU_AZUL].NormalItems[NormalCount] :=
            FileStrings[1].ToInteger();
          inc(NormalCount);
        end;
      DROP_SUPERIOR_ITEM:
        begin
          SetLength(Drops[MONSTERS_CROSHU_AZUL].SuperiorItems,
            (SuperiorCount + 1));
          Drops[MONSTERS_CROSHU_AZUL].SuperiorItems[SuperiorCount] :=
            FileStrings[1].ToInteger();
          inc(SuperiorCount);
        end;
      DROP_RARE_ITEM:
        begin
          SetLength(Drops[MONSTERS_CROSHU_AZUL].RareItems, (RareCount + 1));
          Drops[MONSTERS_CROSHU_AZUL].RareItems[RareCount] :=
            FileStrings[1].ToInteger();
          inc(RareCount);
        end;
      DROP_LEGENDARY_ITEM:
        begin
          SetLength(Drops[MONSTERS_CROSHU_AZUL].LegendaryItems,
            (LegendaryCount + 1));
          Drops[MONSTERS_CROSHU_AZUL].LegendaryItems[LegendaryCount] :=
            FileStrings[1].ToInteger();
          inc(LegendaryCount);
        end;
    end;
    FileStrings.Clear;
  end;
  Logger.Write('CroshuAzul_DropList.csv carregado com sucesso.',
    TLogType.ServerStatus);
  CloseFile(DataFile);
  Path := GetCurrentDir + '\Data\Drops\Penza_DropList.csv';
  if not(FileExists(Path)) then
  begin
    Logger.Write('O arquivo Penza_DropList.csv não foi encontrado.',
      TLogType.Warnings);
    Exit;
  end;
  AssignFile(DataFile, Path);
  Reset(DataFile);
  FileStrings := TStringList.Create;
  NormalCount := 0;
  SuperiorCount := 0;
  RareCount := 0;
  LegendaryCount := 0;
  while not EOF(DataFile) do
  begin
    ReadLn(DataFile, LineFile);
    ExtractStrings([','], [' '], PChar(LineFile), FileStrings);
    ItemType := FileStrings[2].ToInteger();
    case ItemType of
      DROP_NORMAL_ITEM:
        begin
          SetLength(Drops[MONSTERS_PENZA].NormalItems, (NormalCount + 1));
          Drops[MONSTERS_PENZA].NormalItems[NormalCount] :=
            FileStrings[1].ToInteger();
          inc(NormalCount);
        end;
      DROP_SUPERIOR_ITEM:
        begin
          SetLength(Drops[MONSTERS_PENZA].SuperiorItems, (SuperiorCount + 1));
          Drops[MONSTERS_PENZA].SuperiorItems[SuperiorCount] :=
            FileStrings[1].ToInteger();
          inc(SuperiorCount);
        end;
      DROP_RARE_ITEM:
        begin
          SetLength(Drops[MONSTERS_PENZA].RareItems, (RareCount + 1));
          Drops[MONSTERS_PENZA].RareItems[RareCount] :=
            FileStrings[1].ToInteger();
          inc(RareCount);
        end;
      DROP_LEGENDARY_ITEM:
        begin
          SetLength(Drops[MONSTERS_PENZA].LegendaryItems, (LegendaryCount + 1));
          Drops[MONSTERS_PENZA].LegendaryItems[LegendaryCount] :=
            FileStrings[1].ToInteger();
          inc(LegendaryCount);
        end;
    end;
    FileStrings.Clear;
  end;
  Logger.Write('Penza_DropList.csv carregado com sucesso.',
    TLogType.ServerStatus);
  CloseFile(DataFile);
  Path := GetCurrentDir + '\Data\Drops\Planta_DropList.csv';
  if not(FileExists(Path)) then
  begin
    Logger.Write('O arquivo Planta_DropList.csv não foi encontrado.',
      TLogType.Warnings);
    Exit;
  end;
  AssignFile(DataFile, Path);
  Reset(DataFile);
  FileStrings := TStringList.Create;
  NormalCount := 0;
  SuperiorCount := 0;
  RareCount := 0;
  LegendaryCount := 0;
  while not EOF(DataFile) do
  begin
    ReadLn(DataFile, LineFile);
    ExtractStrings([','], [' '], PChar(LineFile), FileStrings);
    ItemType := FileStrings[2].ToInteger();
    case ItemType of
      DROP_NORMAL_ITEM:
        begin
          SetLength(Drops[MONSTERS_PLANTA].NormalItems, (NormalCount + 1));
          Drops[MONSTERS_PLANTA].NormalItems[NormalCount] :=
            FileStrings[1].ToInteger();
          inc(NormalCount);
        end;
      DROP_SUPERIOR_ITEM:
        begin
          SetLength(Drops[MONSTERS_PLANTA].SuperiorItems, (SuperiorCount + 1));
          Drops[MONSTERS_PLANTA].SuperiorItems[SuperiorCount] :=
            FileStrings[1].ToInteger();
          inc(SuperiorCount);
        end;
      DROP_RARE_ITEM:
        begin
          SetLength(Drops[MONSTERS_PLANTA].RareItems, (RareCount + 1));
          Drops[MONSTERS_PLANTA].RareItems[RareCount] :=
            FileStrings[1].ToInteger();
          inc(RareCount);
        end;
      DROP_LEGENDARY_ITEM:
        begin
          SetLength(Drops[MONSTERS_PLANTA].LegendaryItems,
            (LegendaryCount + 1));
          Drops[MONSTERS_PLANTA].LegendaryItems[LegendaryCount] :=
            FileStrings[1].ToInteger();
          inc(LegendaryCount);
        end;
    end;
    FileStrings.Clear;
  end;
  Logger.Write('Planta_DropList.csv carregado com sucesso.',
    TLogType.ServerStatus);
  CloseFile(DataFile);
  Path := GetCurrentDir + '\Data\Drops\Verit_DropList.csv';
  if not(FileExists(Path)) then
  begin
    Logger.Write('O arquivo Verit_DropList.csv não foi encontrado.',
      TLogType.Warnings);
    Exit;
  end;
  AssignFile(DataFile, Path);
  Reset(DataFile);
  FileStrings := TStringList.Create;
  NormalCount := 0;
  SuperiorCount := 0;
  RareCount := 0;
  LegendaryCount := 0;
  while not EOF(DataFile) do
  begin
    ReadLn(DataFile, LineFile);
    ExtractStrings([','], [' '], PChar(LineFile), FileStrings);
    ItemType := FileStrings[2].ToInteger();
    case ItemType of
      DROP_NORMAL_ITEM:
        begin
          SetLength(Drops[MONSTERS_VERIT].NormalItems, (NormalCount + 1));
          Drops[MONSTERS_VERIT].NormalItems[NormalCount] :=
            FileStrings[1].ToInteger();
          inc(NormalCount);
        end;
      DROP_SUPERIOR_ITEM:
        begin
          SetLength(Drops[MONSTERS_VERIT].SuperiorItems, (SuperiorCount + 1));
          Drops[MONSTERS_VERIT].SuperiorItems[SuperiorCount] :=
            FileStrings[1].ToInteger();
          inc(SuperiorCount);
        end;
      DROP_RARE_ITEM:
        begin
          SetLength(Drops[MONSTERS_VERIT].RareItems, (RareCount + 1));
          Drops[MONSTERS_VERIT].RareItems[RareCount] :=
            FileStrings[1].ToInteger();
          inc(RareCount);
        end;
      DROP_LEGENDARY_ITEM:
        begin
          SetLength(Drops[MONSTERS_VERIT].LegendaryItems, (LegendaryCount + 1));
          Drops[MONSTERS_VERIT].LegendaryItems[LegendaryCount] :=
            FileStrings[1].ToInteger();
          inc(LegendaryCount);
        end;
    end;
    FileStrings.Clear;
  end;
  Logger.Write('Verit_DropList.csv carregado com sucesso.',
    TLogType.ServerStatus);
  CloseFile(DataFile);
  Path := GetCurrentDir + '\Data\Drops\DropAdicional01_DropList.csv';
  if not(FileExists(Path)) then
  begin
    Logger.Write('O arquivo DropAdicional01_DropList.csv não foi encontrado.',
      TLogType.Warnings);
    Exit;
  end;
  AssignFile(DataFile, Path);
  Reset(DataFile);
  FileStrings := TStringList.Create;
  NormalCount := 0;
  SuperiorCount := 0;
  RareCount := 0;
  LegendaryCount := 0;
  while not EOF(DataFile) do
  begin
    ReadLn(DataFile, LineFile);
    ExtractStrings([','], [' '], PChar(LineFile), FileStrings);
    ItemType := FileStrings[2].ToInteger();
    case ItemType of
      DROP_NORMAL_ITEM:
        begin
          SetLength(Drops[MONSTERS_ADICIONAL1].NormalItems, (NormalCount + 1));
          Drops[MONSTERS_ADICIONAL1].NormalItems[NormalCount] :=
            FileStrings[1].ToInteger();
          inc(NormalCount);
        end;
      DROP_SUPERIOR_ITEM:
        begin
          SetLength(Drops[MONSTERS_ADICIONAL1].SuperiorItems, (SuperiorCount + 1));
          Drops[MONSTERS_ADICIONAL1].SuperiorItems[SuperiorCount] :=
            FileStrings[1].ToInteger();
          inc(SuperiorCount);
        end;
      DROP_RARE_ITEM:
        begin
          SetLength(Drops[MONSTERS_ADICIONAL1].RareItems, (RareCount + 1));
          Drops[MONSTERS_ADICIONAL1].RareItems[RareCount] :=
            FileStrings[1].ToInteger();
          inc(RareCount);
        end;
      DROP_LEGENDARY_ITEM:
        begin
          SetLength(Drops[MONSTERS_ADICIONAL1].LegendaryItems, (LegendaryCount + 1));
          Drops[MONSTERS_ADICIONAL1].LegendaryItems[LegendaryCount] :=
            FileStrings[1].ToInteger();
          inc(LegendaryCount);
        end;
    end;
    FileStrings.Clear;
  end;
  Logger.Write('DropAdicional01_DropList.csv carregado com sucesso.',
    TLogType.ServerStatus);
  CloseFile(DataFile);
  Path := GetCurrentDir + '\Data\Drops\DropAdicional02_DropList.csv';
  if not(FileExists(Path)) then
  begin
    Logger.Write('O arquivo DropAdicional02_DropList.csv não foi encontrado.',
      TLogType.Warnings);
    Exit;
  end;
  AssignFile(DataFile, Path);
  Reset(DataFile);
  FileStrings := TStringList.Create;
  NormalCount := 0;
  SuperiorCount := 0;
  RareCount := 0;
  LegendaryCount := 0;
  while not EOF(DataFile) do
  begin
    ReadLn(DataFile, LineFile);
    ExtractStrings([','], [' '], PChar(LineFile), FileStrings);
    ItemType := FileStrings[2].ToInteger();
    case ItemType of
      DROP_NORMAL_ITEM:
        begin
          SetLength(Drops[MONSTERS_ADICIONAL2].NormalItems, (NormalCount + 1));
          Drops[MONSTERS_ADICIONAL2].NormalItems[NormalCount] :=
            FileStrings[1].ToInteger();
          inc(NormalCount);
        end;
      DROP_SUPERIOR_ITEM:
        begin
          SetLength(Drops[MONSTERS_ADICIONAL2].SuperiorItems, (SuperiorCount + 1));
          Drops[MONSTERS_ADICIONAL2].SuperiorItems[SuperiorCount] :=
            FileStrings[1].ToInteger();
          inc(SuperiorCount);
        end;
      DROP_RARE_ITEM:
        begin
          SetLength(Drops[MONSTERS_ADICIONAL2].RareItems, (RareCount + 1));
          Drops[MONSTERS_ADICIONAL2].RareItems[RareCount] :=
            FileStrings[1].ToInteger();
          inc(RareCount);
        end;
      DROP_LEGENDARY_ITEM:
        begin
          SetLength(Drops[MONSTERS_ADICIONAL2].LegendaryItems, (LegendaryCount + 1));
          Drops[MONSTERS_ADICIONAL2].LegendaryItems[LegendaryCount] :=
            FileStrings[1].ToInteger();
          inc(LegendaryCount);
        end;
    end;
    FileStrings.Clear;
  end;
  Logger.Write('DropAdicional02_DropList.csv carregado com sucesso.',
    TLogType.ServerStatus);
  CloseFile(DataFile);
end;
class procedure TLoad.InitRecipes;
var
  FSize, Len: Integer;
  f: TFileStream;
  FName: string;
begin
  FName := GetCurrentDir + '\Data\Recipes.bin';
  if not(FileExists(FName)) then
  begin
    Logger.Write('Recipes.bin não encontrado.', TLogType.Warnings);
    Exit;
  end;
  f := TFileStream.Create(FName, FmOpenRead);
  FSize := f.Size;
  Len := Round(FSize div sizeof(TRecipeData));
  SetLength(Recipes, Len);
  try
    f.Position := 0;
    f.ReadBuffer(Recipes[0], f.Size);
    f.Free;
  except
    f.Free;
    Exit;
  end;
  Logger.Write('Recipes.bin carregado com sucesso.', TLogType.ServerStatus);
end;
class procedure TLoad.InitMakeItems;
var
  Path, LineFile: String;
  f: TextFile;
  FileStrings: TStringList;
  cnt: WORD;
begin
  Path := GetCurrentDir + '\Data\MakeItems.csv';
  if not(FileExists(Path)) then
  begin
    Logger.Write('MakeItems.csv não foi encontrado.', TLogType.Warnings);
    Exit;
  end;
  AssignFile(f, Path);
  Reset(f);
  FileStrings := TStringList.Create;
  cnt := 1;
  while not(EOF(f)) do
  begin
    SetLength(MakeItems, cnt);
    FileStrings.Clear;
    ReadLn(f, LineFile);
    ExtractStrings([','], [' '], PChar(LineFile), FileStrings);
    MakeItems[cnt - 1].ID := FileStrings[1].ToInteger();
    MakeItems[cnt - 1].ResultItemID := FileStrings[0].ToInteger();
    MakeItems[cnt - 1].LevelMin := FileStrings[2].ToInteger();
    MakeItems[cnt - 1].Price := FileStrings[3].ToInteger();
    MakeItems[cnt - 1].ResultAmount := FileStrings[4].ToInteger();
    MakeItems[cnt - 1].TaxSuccess := FileStrings[5].ToInteger();
    inc(cnt);
  end;
  CloseFile(f);
  Logger.Write('MakeItems.csv carregado com sucesso.', TLogType.ServerStatus);
  Path := GetCurrentDir + '\Data\MakeItemsIngredients.csv';
  if not(FileExists(Path)) then
  begin
    Logger.Write('MakeItemsIngredients.csv não foi encontrado.',
      TLogType.Warnings);
    Exit;
  end;
  AssignFile(f, Path);
  Reset(f);
  cnt := 1;
  while not(EOF(f)) do
  begin
    SetLength(MakeItemsIngredients, cnt);
    FileStrings.Clear;
    ReadLn(f, LineFile);
    ExtractStrings([','], [' '], PChar(LineFile), FileStrings);
    MakeItemsIngredients[cnt - 1].ID := FileStrings[0].ToInteger();
    MakeItemsIngredients[cnt - 1].ItemID := FileStrings[1].ToInteger();
    MakeItemsIngredients[cnt - 1].Amount := FileStrings[2].ToInteger();
    inc(cnt);
  end;
  CloseFile(f);
  Logger.Write('MakeItemsIngredients.csv carregado com sucesso.',
    TLogType.ServerStatus);
end;
{$REGION 'NPCs'}
class function TLoad.LoadNPC(const FName: string; out NPC: TNPCFile): Boolean;
var
  f: File of TNPCFile;
begin
  Result := False;
  try
    AssignFile(f, DATABASE_PATH + 'NPCs\' + FName);
    Reset(f);
    Read(f, NPC);
    CloseFile(f);
  except
    Exit;
  end;
  Result := true;
end;
class procedure TLoad.InitNPCS;
var
  f: TSearchRec;
  Ret, j, quest_cnt: Integer;
  TempNome: String;
  NPC: TNPCFile;
  I: Byte;
begin
  InstantiatedNPCs := 0;
  Ret := FindFirst(DATABASE_PATH + 'NPCs\' + '*.npc', faAnyFile, f);
  while Ret = 0 do
  begin
    TempNome := ReplaceStr(f.Name, '.npc', '');
    ZeroMemory(@NPC, sizeof(TNPCFile));
    if (LoadNPC(f.Name, NPC)) then
    begin
      for I := Low(Servers) to High(Servers) do
      begin
        Servers[I].NPCs[NPC.Base.Index].Create(NPC.Base.Index, TempNome, I);
        Servers[I].NPCs[NPC.Base.Index].InstanciateNPC;
        quest_cnt := 0;
        for j := Low(_Quests) to High(_Quests) do
        begin
          if (NPC.Base.Index = _Quests[j].NPCID) then
          begin
            Move(_Quests[j], Servers[I].NPCs[NPC.Base.Index].Base.NpcQuests
              [quest_cnt], sizeof(TQuestMisc));
            inc(quest_cnt);
          end;
        end;
      end;
      inc(InstantiatedNPCs, 1);
    end;
    Ret := FindNext(f);
  end;
  for I := Low(Servers) to High(Servers) do
  begin
    for j := 3335 to 3339 do
    begin
      Servers[I].DevirNpc[j].PlayerChar.Base.ClientId := j;
      case j of
        3335: //devir amk
          begin
            System.Ansistrings.StrPlCopy
              (Servers[I].DevirNpc[j].PlayerChar.Base.Name, '900', 3);
            Servers[I].DevirNpc[j].DevirName := 'Amarkand';
            Servers[I].DevirNpc[j].PlayerChar.LastPos.X := 3662;
            Servers[I].DevirNpc[j].PlayerChar.LastPos.Y := 1978;
            //pedra red
            Servers[I].DevirStones[3340].PlayerChar.Base.ClientId := 3340;
            System.Ansistrings.StrPlCopy(Servers[I].DevirStones[3340]
              .PlayerChar.Base.Name, '905', 3);
            Servers[I].DevirStones[3340].PlayerChar.LastPos.X := 3659;
            Servers[I].DevirStones[3340].PlayerChar.LastPos.Y := 1972;
            Servers[I].DevirStones[3340].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirStones[3340].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirStones[3340].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirStones[3340].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirStones[3340].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirStones[3340].PlayerChar.DuploAtk := $43;
            Servers[I].DevirStones[3340].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3340].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3340].PlayerChar.Base.Equip[0].Index := 221;
            Servers[I].DevirStones[3340].PlayerChar.Base.Equip[0].APP := 221;
            Servers[I].DevirStones[3340].Base.Create(
            @Servers[I].DevirStones[3340].PlayerChar.Base, 3340, I);
            //pedra azul
            Servers[I].DevirStones[3345].PlayerChar.Base.ClientId := 3345;
            System.Ansistrings.StrPlCopy(Servers[I].DevirStones[3345]
              .PlayerChar.Base.Name, '905', 3);
            Servers[I].DevirStones[3345].PlayerChar.LastPos.X := 3658;
            Servers[I].DevirStones[3345].PlayerChar.LastPos.Y := 1984;
            Servers[I].DevirStones[3345].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirStones[3345].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirStones[3345].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirStones[3345].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirStones[3345].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirStones[3345].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3345].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3345].PlayerChar.DuploAtk := $3D;
            Servers[I].DevirStones[3345].PlayerChar.Base.Equip[0].Index := 221;
            Servers[I].DevirStones[3345].PlayerChar.Base.Equip[0].APP := 221;
            Servers[I].DevirStones[3345].Base.Create(
            @Servers[I].DevirStones[3345].PlayerChar.Base, 3345, I);
            //pedra verde
            Servers[I].DevirStones[3350].PlayerChar.Base.ClientId := 3350;
            System.Ansistrings.StrPlCopy(Servers[I].DevirStones[3350]
              .PlayerChar.Base.Name, '905', 3);
            Servers[I].DevirStones[3350].PlayerChar.LastPos.X := 3670;
            Servers[I].DevirStones[3350].PlayerChar.LastPos.Y := 1978;
            Servers[I].DevirStones[3350].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirStones[3350].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirStones[3350].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirStones[3350].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirStones[3350].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirStones[3350].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3350].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3350].PlayerChar.DuploAtk := $3C;
            Servers[I].DevirStones[3350].PlayerChar.Base.Equip[0].Index := 221;
            Servers[I].DevirStones[3350].PlayerChar.Base.Equip[0].APP := 221;
            Servers[I].DevirStones[3350].Base.Create(
            @Servers[I].DevirStones[3350].PlayerChar.Base, 3350, I);
            // guarda red
            Servers[I].DevirGuards[3355].PlayerChar.Base.ClientId := 3355;
            System.Ansistrings.StrPlCopy(Servers[I].DevirGuards[3355]
              .PlayerChar.Base.Name, '938', 3);
            Servers[I].DevirGuards[3355].PlayerChar.LastPos.X := 3666;
            Servers[I].DevirGuards[3355].PlayerChar.LastPos.Y := 1983;
            Servers[I].DevirGuards[3355].FirstPosition :=
              Servers[I].DevirGuards[3355].PlayerChar.LastPos;
            Servers[I].DevirGuards[3355].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirGuards[3355].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirGuards[3355].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirGuards[3355].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirGuards[3355].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirGuards[3355].PlayerChar.Base.Equip[0].Index := 233;
            Servers[I].DevirGuards[3355].PlayerChar.Base.Equip[0].APP := 233;
            Servers[I].DevirGuards[3355].PlayerChar.Base.Equip[6].Index := 1442;
            Servers[I].DevirGuards[3355].PlayerChar.Base.Equip[6].APP := 1442;
            Servers[I].DevirGuards[3355].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3355].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3355].PlayerChar.DuploAtk := $48;
            Servers[I].DevirGuards[3355].Base.Create(
            @Servers[I].DevirGuards[3355].PlayerChar.Base, 3355, I);
            // guarda azul
            Servers[I].DevirGuards[3360].PlayerChar.Base.ClientId := 3360;
            System.Ansistrings.StrPlCopy(Servers[I].DevirGuards[3360]
              .PlayerChar.Base.Name, '942', 3);
            Servers[I].DevirGuards[3360].PlayerChar.LastPos.X := 3654;
            Servers[I].DevirGuards[3360].PlayerChar.LastPos.Y := 1978;
            Servers[I].DevirGuards[3360].FirstPosition :=
              Servers[I].DevirGuards[3360].PlayerChar.LastPos;
            Servers[I].DevirGuards[3360].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirGuards[3360].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirGuards[3360].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirGuards[3360].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirGuards[3360].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirGuards[3360].PlayerChar.Base.Equip[0].Index := 233;
            Servers[I].DevirGuards[3360].PlayerChar.Base.Equip[0].APP := 233;
            Servers[I].DevirGuards[3360].PlayerChar.Base.Equip[6].Index := 1442;
            Servers[I].DevirGuards[3360].PlayerChar.Base.Equip[6].APP := 1442;
            Servers[I].DevirGuards[3360].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_STONE_HP;
            Servers[I].DevirGuards[3360].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3360].PlayerChar.DuploAtk := $4B;
            Servers[I].DevirGuards[3360].Base.Create(
            @Servers[I].DevirGuards[3360].PlayerChar.Base, 3360, I);
            // guarda verde
            Servers[I].DevirGuards[3365].PlayerChar.Base.ClientId := 3365;
            System.Ansistrings.StrPlCopy(Servers[I].DevirGuards[3365]
              .PlayerChar.Base.Name, '941', 3);
            Servers[I].DevirGuards[3365].PlayerChar.LastPos.X := 3665;
            Servers[I].DevirGuards[3365].PlayerChar.LastPos.Y := 1972;
            Servers[I].DevirGuards[3365].FirstPosition :=
              Servers[I].DevirGuards[3365].PlayerChar.LastPos;
            Servers[I].DevirGuards[3365].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirGuards[3365].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirGuards[3365].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirGuards[3365].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirGuards[3365].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirGuards[3365].PlayerChar.Base.Equip[0].Index := 233;
            Servers[I].DevirGuards[3365].PlayerChar.Base.Equip[0].APP := 233;
            Servers[I].DevirGuards[3365].PlayerChar.Base.Equip[6].Index := 1442;
            Servers[I].DevirGuards[3365].PlayerChar.Base.Equip[6].APP := 1442;
            Servers[I].DevirGuards[3365].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_STONE_HP;
            Servers[I].DevirGuards[3365].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3365].PlayerChar.DuploAtk := $4A;
            Servers[I].DevirGuards[3365].Base.Create(
            @Servers[I].DevirGuards[3365].PlayerChar.Base, 3365, I);
          end;
        3336: //devir sigmund
          begin
            System.Ansistrings.StrPlCopy
              (Servers[I].DevirNpc[j].PlayerChar.Base.Name, '904', 3);
            Servers[I].DevirNpc[j].DevirName := 'Sigmund';
            Servers[I].DevirNpc[j].PlayerChar.LastPos.X := 2748;
            Servers[I].DevirNpc[j].PlayerChar.LastPos.Y := 2024;
            //pedra red
            Servers[I].DevirStones[3341].PlayerChar.Base.ClientId := 3341;
            System.Ansistrings.StrPlCopy(Servers[I].DevirStones[3341]
              .PlayerChar.Base.Name, '905', 3);
            Servers[I].DevirStones[3341].PlayerChar.LastPos.X := 2748;
            Servers[I].DevirStones[3341].PlayerChar.LastPos.Y := 2032;
            Servers[I].DevirStones[3341].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirStones[3341].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirStones[3341].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirStones[3341].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirStones[3341].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirStones[3341].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3341].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3341].PlayerChar.DuploAtk := $43;
            Servers[I].DevirStones[3341].PlayerChar.Base.Equip[0].Index := 221;
            Servers[I].DevirStones[3341].PlayerChar.Base.Equip[0].APP := 221;
            Servers[I].DevirStones[3341].Base.Create(
            @Servers[I].DevirStones[3341].PlayerChar.Base, 3341, I);
            //pedra azul
            Servers[I].DevirStones[3346].PlayerChar.Base.ClientId := 3346;
            System.Ansistrings.StrPlCopy(Servers[I].DevirStones[3346]
              .PlayerChar.Base.Name, '905', 3);
            Servers[I].DevirStones[3346].PlayerChar.LastPos.X := 2756;
            Servers[I].DevirStones[3346].PlayerChar.LastPos.Y := 2021;
            Servers[I].DevirStones[3346].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirStones[3346].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirStones[3346].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirStones[3346].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirStones[3346].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirStones[3346].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3346].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3346].PlayerChar.DuploAtk := $3D;
            Servers[I].DevirStones[3346].PlayerChar.Base.Equip[0].Index := 221;
            Servers[I].DevirStones[3346].PlayerChar.Base.Equip[0].APP := 221;
            Servers[I].DevirStones[3346].Base.Create(
            @Servers[I].DevirStones[3346].PlayerChar.Base, 3346, I);
            //pedra verde
            Servers[I].DevirStones[3351].PlayerChar.Base.ClientId := 3351;
            System.Ansistrings.StrPlCopy(Servers[I].DevirStones[3351]
              .PlayerChar.Base.Name, '905', 3);
            Servers[I].DevirStones[3351].PlayerChar.LastPos.X := 2742;
            Servers[I].DevirStones[3351].PlayerChar.LastPos.Y := 2018;
            Servers[I].DevirStones[3351].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirStones[3351].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirStones[3351].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirStones[3351].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirStones[3351].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirStones[3351].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3351].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3351].PlayerChar.DuploAtk := $3C;
            Servers[I].DevirStones[3351].PlayerChar.Base.Equip[0].Index := 221;
            Servers[I].DevirStones[3351].PlayerChar.Base.Equip[0].APP := 221;
            Servers[I].DevirStones[3351].Base.Create(
            @Servers[I].DevirStones[3351].PlayerChar.Base, 3351, I);
            // guarda red
            Servers[I].DevirGuards[3356].PlayerChar.Base.ClientId := 3356;
            System.Ansistrings.StrPlCopy(Servers[I].DevirGuards[3356]
              .PlayerChar.Base.Name, '938', 3);
            Servers[I].DevirGuards[3356].PlayerChar.LastPos.X := 2750;
            Servers[I].DevirGuards[3356].PlayerChar.LastPos.Y := 2016;
            Servers[I].DevirGuards[3356].FirstPosition :=
              Servers[I].DevirGuards[3356].PlayerChar.LastPos;
            Servers[I].DevirGuards[3356].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirGuards[3356].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirGuards[3356].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirGuards[3356].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirGuards[3356].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirGuards[3356].PlayerChar.Base.Equip[0].Index := 233;
            Servers[I].DevirGuards[3356].PlayerChar.Base.Equip[0].APP := 233;
            Servers[I].DevirGuards[3356].PlayerChar.Base.Equip[6].Index := 1442;
            Servers[I].DevirGuards[3356].PlayerChar.Base.Equip[6].APP := 1442;
            Servers[I].DevirGuards[3356].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_STONE_HP;
            Servers[I].DevirGuards[3356].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3356].PlayerChar.DuploAtk := $48;
            Servers[I].DevirGuards[3356].Base.Create(
            @Servers[I].DevirGuards[3356].PlayerChar.Base, 3356, I);
            // guarda azul
            Servers[I].DevirGuards[3361].PlayerChar.Base.ClientId := 3361;
            System.Ansistrings.StrPlCopy(Servers[I].DevirGuards[3361]
              .PlayerChar.Base.Name, '942', 3);
            Servers[I].DevirGuards[3361].PlayerChar.LastPos.X := 2739;
            Servers[I].DevirGuards[3361].PlayerChar.LastPos.Y := 2028;
            Servers[I].DevirGuards[3361].FirstPosition :=
              Servers[I].DevirGuards[3361].PlayerChar.LastPos;
            Servers[I].DevirGuards[3361].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirGuards[3361].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirGuards[3361].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirGuards[3361].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirGuards[3361].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirGuards[3361].PlayerChar.Base.Equip[0].Index := 233;
            Servers[I].DevirGuards[3361].PlayerChar.Base.Equip[0].APP := 233;
            Servers[I].DevirGuards[3361].PlayerChar.Base.Equip[6].Index := 1442;
            Servers[I].DevirGuards[3361].PlayerChar.Base.Equip[6].APP := 1442;
            Servers[I].DevirGuards[3361].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_STONE_HP;
            Servers[I].DevirGuards[3361].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3361].PlayerChar.DuploAtk := $4B;
            Servers[I].DevirGuards[3361].Base.Create(
            @Servers[I].DevirGuards[3361].PlayerChar.Base, 3361, I);
            // guarda verde
            Servers[I].DevirGuards[3366].PlayerChar.Base.ClientId := 3366;
            System.Ansistrings.StrPlCopy(Servers[I].DevirGuards[3366]
              .PlayerChar.Base.Name, '941', 3);
            Servers[I].DevirGuards[3366].PlayerChar.LastPos.X := 2756;
            Servers[I].DevirGuards[3366].PlayerChar.LastPos.Y := 2028;
            Servers[I].DevirGuards[3366].FirstPosition :=
              Servers[I].DevirGuards[3366].PlayerChar.LastPos;
            Servers[I].DevirGuards[3366].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirGuards[3366].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirGuards[3366].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirGuards[3366].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirGuards[3366].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirGuards[3366].PlayerChar.Base.Equip[0].Index := 233;
            Servers[I].DevirGuards[3366].PlayerChar.Base.Equip[0].APP := 233;
            Servers[I].DevirGuards[3366].PlayerChar.Base.Equip[6].Index := 1442;
            Servers[I].DevirGuards[3366].PlayerChar.Base.Equip[6].APP := 1442;
            Servers[I].DevirGuards[3366].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_STONE_HP;
            Servers[I].DevirGuards[3366].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3366].PlayerChar.DuploAtk := $4A;
            Servers[I].DevirGuards[3366].Base.Create(
            @Servers[I].DevirGuards[3366].PlayerChar.Base, 3366, I);
          end;
        3337: //devir cahil
          begin
            System.Ansistrings.StrPlCopy
              (Servers[I].DevirNpc[j].PlayerChar.Base.Name, '935', 3);
            Servers[I].DevirNpc[j].DevirName := 'Cahil';
            Servers[I].DevirNpc[j].PlayerChar.LastPos.X := 1851;
            Servers[I].DevirNpc[j].PlayerChar.LastPos.Y := 1844;
            //pedra red
            Servers[I].DevirStones[3342].PlayerChar.Base.ClientId := 3342;
            System.Ansistrings.StrPlCopy(Servers[I].DevirStones[3342]
              .PlayerChar.Base.Name, '905', 3);
            Servers[I].DevirStones[3342].PlayerChar.LastPos.X := 1847;
            Servers[I].DevirStones[3342].PlayerChar.LastPos.Y := 1837;
            Servers[I].DevirStones[3342].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirStones[3342].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirStones[3342].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirStones[3342].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirStones[3342].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirStones[3342].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3342].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3342].PlayerChar.DuploAtk := $43;
            Servers[I].DevirStones[3342].PlayerChar.Base.Equip[0].Index := 221;
            Servers[I].DevirStones[3342].PlayerChar.Base.Equip[0].APP := 221;
            Servers[I].DevirStones[3342].Base.Create(
            @Servers[I].DevirStones[3342].PlayerChar.Base, 3342, I);
            //pedra azul
            Servers[I].DevirStones[3347].PlayerChar.Base.ClientId := 3347;
            System.Ansistrings.StrPlCopy(Servers[I].DevirStones[3347]
              .PlayerChar.Base.Name, '905', 3);
            Servers[I].DevirStones[3347].PlayerChar.LastPos.X := 1847;
            Servers[I].DevirStones[3347].PlayerChar.LastPos.Y := 1851;
            Servers[I].DevirStones[3347].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirStones[3347].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirStones[3347].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirStones[3347].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirStones[3347].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirStones[3347].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3347].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3347].PlayerChar.DuploAtk := $3D;
            Servers[I].DevirStones[3347].PlayerChar.Base.Equip[0].Index := 221;
            Servers[I].DevirStones[3347].PlayerChar.Base.Equip[0].APP := 221;
            Servers[I].DevirStones[3347].Base.Create(
            @Servers[I].DevirStones[3347].PlayerChar.Base, 3347, I);
            //pedra verde
            Servers[I].DevirStones[3352].PlayerChar.Base.ClientId := 3352;
            System.Ansistrings.StrPlCopy(Servers[I].DevirStones[3352]
              .PlayerChar.Base.Name, '905', 3);
            Servers[I].DevirStones[3352].PlayerChar.LastPos.X := 1859;
            Servers[I].DevirStones[3352].PlayerChar.LastPos.Y := 1844;
            Servers[I].DevirStones[3352].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirStones[3352].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirStones[3352].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirStones[3352].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirStones[3352].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirStones[3352].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3352].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3352].PlayerChar.DuploAtk := $3C;
            Servers[I].DevirStones[3352].PlayerChar.Base.Equip[0].Index := 221;
            Servers[I].DevirStones[3352].PlayerChar.Base.Equip[0].APP := 221;
            Servers[I].DevirStones[3352].Base.Create(
            @Servers[I].DevirStones[3352].PlayerChar.Base, 3352, I);
            // guarda red
            Servers[I].DevirGuards[3357].PlayerChar.Base.ClientId := 3357;
            System.Ansistrings.StrPlCopy(Servers[I].DevirGuards[3357]
              .PlayerChar.Base.Name, '938', 3);
            Servers[I].DevirGuards[3357].PlayerChar.LastPos.X := 1856;
            Servers[I].DevirGuards[3357].PlayerChar.LastPos.Y := 1851;
            Servers[I].DevirGuards[3357].FirstPosition :=
              Servers[I].DevirGuards[3357].PlayerChar.LastPos;
            Servers[I].DevirGuards[3357].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirGuards[3357].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirGuards[3357].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirGuards[3357].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirGuards[3357].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirGuards[3357].PlayerChar.Base.Equip[0].Index := 233;
            Servers[I].DevirGuards[3357].PlayerChar.Base.Equip[0].APP := 233;
            Servers[I].DevirGuards[3357].PlayerChar.Base.Equip[6].Index := 1442;
            Servers[I].DevirGuards[3357].PlayerChar.Base.Equip[6].APP := 1442;
            Servers[I].DevirGuards[3357].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3357].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3357].PlayerChar.DuploAtk := $48;
            Servers[I].DevirGuards[3357].Base.Create(
            @Servers[I].DevirGuards[3357].PlayerChar.Base, 3357, I);
            // guarda azul
            Servers[I].DevirGuards[3362].PlayerChar.Base.ClientId := 3362;
            System.Ansistrings.StrPlCopy(Servers[I].DevirGuards[3362]
              .PlayerChar.Base.Name, '942', 3);
            Servers[I].DevirGuards[3362].PlayerChar.LastPos.X := 1855;
            Servers[I].DevirGuards[3362].PlayerChar.LastPos.Y := 1837;
            Servers[I].DevirGuards[3362].FirstPosition :=
              Servers[I].DevirGuards[3362].PlayerChar.LastPos;
            Servers[I].DevirGuards[3362].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirGuards[3362].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirGuards[3362].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirGuards[3362].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirGuards[3362].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirGuards[3362].PlayerChar.Base.Equip[0].Index := 233;
            Servers[I].DevirGuards[3362].PlayerChar.Base.Equip[0].APP := 233;
            Servers[I].DevirGuards[3362].PlayerChar.Base.Equip[6].Index := 1442;
            Servers[I].DevirGuards[3362].PlayerChar.Base.Equip[6].APP := 1442;
            Servers[I].DevirGuards[3362].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3362].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_GUARD_HP;
              Servers[I].DevirGuards[3362].PlayerChar.DuploAtk := $4B;
            Servers[I].DevirGuards[3362].Base.Create(
            @Servers[I].DevirGuards[3362].PlayerChar.Base, 3362, I);
            // guarda verde
            Servers[I].DevirGuards[3367].PlayerChar.Base.ClientId := 3367;
            System.Ansistrings.StrPlCopy(Servers[I].DevirGuards[3367]
              .PlayerChar.Base.Name, '941', 3);
            Servers[I].DevirGuards[3367].PlayerChar.LastPos.X := 1843;
            Servers[I].DevirGuards[3367].PlayerChar.LastPos.Y := 1845;
            Servers[I].DevirGuards[3367].FirstPosition :=
              Servers[I].DevirGuards[3367].PlayerChar.LastPos;
            Servers[I].DevirGuards[3367].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirGuards[3367].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirGuards[3367].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirGuards[3367].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirGuards[3367].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirGuards[3367].PlayerChar.Base.Equip[0].Index := 233;
            Servers[I].DevirGuards[3367].PlayerChar.Base.Equip[0].APP := 233;
            Servers[I].DevirGuards[3367].PlayerChar.Base.Equip[6].Index := 1442;
            Servers[I].DevirGuards[3367].PlayerChar.Base.Equip[6].APP := 1442;
            Servers[I].DevirGuards[3367].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3367].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3367].PlayerChar.DuploAtk := $4A;
            Servers[I].DevirGuards[3367].Base.Create(
            @Servers[I].DevirGuards[3367].PlayerChar.Base, 3367, I);
          end;
        3338: //devir mirza
          begin
            System.Ansistrings.StrPlCopy
              (Servers[I].DevirNpc[j].PlayerChar.Base.Name, '936', 3);
            Servers[I].DevirNpc[j].DevirName := 'Mirza';
            Servers[I].DevirNpc[j].PlayerChar.LastPos.X := 3014;
            Servers[I].DevirNpc[j].PlayerChar.LastPos.Y := 1158;
            //pedra red
            Servers[I].DevirStones[3343].PlayerChar.Base.ClientId := 3343;
            System.Ansistrings.StrPlCopy(Servers[I].DevirStones[3343]
              .PlayerChar.Base.Name, '905', 3);
            Servers[I].DevirStones[3343].PlayerChar.LastPos.X := 3007;
            Servers[I].DevirStones[3343].PlayerChar.LastPos.Y := 1156;
            Servers[I].DevirStones[3343].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirStones[3343].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirStones[3343].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirStones[3343].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirStones[3343].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirStones[3343].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3343].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3343].PlayerChar.DuploAtk := $43;
            Servers[I].DevirStones[3343].PlayerChar.Base.Equip[0].Index := 221;
            Servers[I].DevirStones[3343].PlayerChar.Base.Equip[0].APP := 221;
            Servers[I].DevirStones[3343].Base.Create(
            @Servers[I].DevirStones[3343].PlayerChar.Base, 3343, I);
            //pedra azul
            Servers[I].DevirStones[3348].PlayerChar.Base.ClientId := 3348;
            System.Ansistrings.StrPlCopy(Servers[I].DevirStones[3348]
              .PlayerChar.Base.Name, '905', 3);
            Servers[I].DevirStones[3348].PlayerChar.LastPos.X := 3016;
            Servers[I].DevirStones[3348].PlayerChar.LastPos.Y := 1165;
            Servers[I].DevirStones[3348].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirStones[3348].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirStones[3348].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirStones[3348].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirStones[3348].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirStones[3348].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3348].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3348].PlayerChar.DuploAtk := $3D;
            Servers[I].DevirStones[3348].PlayerChar.Base.Equip[0].Index := 221;
            Servers[I].DevirStones[3348].PlayerChar.Base.Equip[0].APP := 221;
            Servers[I].DevirStones[3348].Base.Create(
            @Servers[I].DevirStones[3348].PlayerChar.Base, 3348, I);
            //pedra verde
            Servers[I].DevirStones[3353].PlayerChar.Base.ClientId := 3353;
            System.Ansistrings.StrPlCopy(Servers[I].DevirStones[3353]
              .PlayerChar.Base.Name, '905', 3);
            Servers[I].DevirStones[3353].PlayerChar.LastPos.X := 3019;
            Servers[I].DevirStones[3353].PlayerChar.LastPos.Y := 1153;
            Servers[I].DevirStones[3353].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirStones[3353].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirStones[3353].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirStones[3353].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirStones[3353].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirStones[3353].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3353].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3353].PlayerChar.DuploAtk := $3C;
            Servers[I].DevirStones[3353].PlayerChar.Base.Equip[0].Index := 221;
            Servers[I].DevirStones[3353].PlayerChar.Base.Equip[0].APP := 221;
            Servers[I].DevirStones[3353].Base.Create(
            @Servers[I].DevirStones[3353].PlayerChar.Base, 3353, I);
            // guarda red
            Servers[I].DevirGuards[3358].PlayerChar.Base.ClientId := 3358;
            System.Ansistrings.StrPlCopy(Servers[I].DevirGuards[3358]
              .PlayerChar.Base.Name, '938', 3);
            Servers[I].DevirGuards[3358].PlayerChar.LastPos.X := 3024;
            Servers[I].DevirGuards[3358].PlayerChar.LastPos.Y := 1159;
             Servers[I].DevirGuards[3358].FirstPosition :=
              Servers[I].DevirGuards[3358].PlayerChar.LastPos;
            Servers[I].DevirGuards[3358].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirGuards[3358].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirGuards[3358].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirGuards[3358].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirGuards[3358].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirGuards[3358].PlayerChar.Base.Equip[0].Index := 233;
            Servers[I].DevirGuards[3358].PlayerChar.Base.Equip[0].APP := 233;
            Servers[I].DevirGuards[3358].PlayerChar.Base.Equip[6].Index := 1442;
            Servers[I].DevirGuards[3358].PlayerChar.Base.Equip[6].APP := 1442;
            Servers[I].DevirGuards[3358].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3358].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3358].PlayerChar.DuploAtk := $48;
            Servers[I].DevirGuards[3358].Base.Create(
            @Servers[I].DevirGuards[3358].PlayerChar.Base, 3358, I);
            // guarda azul
            Servers[I].DevirGuards[3363].PlayerChar.Base.ClientId := 3363;
            System.Ansistrings.StrPlCopy(Servers[I].DevirGuards[3363]
              .PlayerChar.Base.Name, '942', 3);
            Servers[I].DevirGuards[3363].PlayerChar.LastPos.X := 3007;
            Servers[I].DevirGuards[3363].PlayerChar.LastPos.Y := 1164;
            Servers[I].DevirGuards[3363].FirstPosition :=
              Servers[I].DevirGuards[3363].PlayerChar.LastPos;
            Servers[I].DevirGuards[3363].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirGuards[3363].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirGuards[3363].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirGuards[3363].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirGuards[3363].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirGuards[3363].PlayerChar.Base.Equip[0].Index := 233;
            Servers[I].DevirGuards[3363].PlayerChar.Base.Equip[0].APP := 233;
            Servers[I].DevirGuards[3363].PlayerChar.Base.Equip[6].Index := 1442;
            Servers[I].DevirGuards[3363].PlayerChar.Base.Equip[6].APP := 1442;
            Servers[I].DevirGuards[3363].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3363].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3363].PlayerChar.DuploAtk := $4B;
            Servers[I].DevirGuards[3363].Base.Create(
            @Servers[I].DevirGuards[3363].PlayerChar.Base, 3363, I);
            // guarda verde
            Servers[I].DevirGuards[3368].PlayerChar.Base.ClientId := 3368;
            System.Ansistrings.StrPlCopy(Servers[I].DevirGuards[3368]
              .PlayerChar.Base.Name, '941', 3);
            Servers[I].DevirGuards[3368].PlayerChar.LastPos.X := 3012;
            Servers[I].DevirGuards[3368].PlayerChar.LastPos.Y := 1148;
            Servers[I].DevirGuards[3368].FirstPosition :=
              Servers[I].DevirGuards[3368].PlayerChar.LastPos;
            Servers[I].DevirGuards[3368].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirGuards[3368].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirGuards[3368].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirGuards[3368].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirGuards[3368].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirGuards[3368].PlayerChar.Base.Equip[0].Index := 233;
            Servers[I].DevirGuards[3368].PlayerChar.Base.Equip[0].APP := 233;
            Servers[I].DevirGuards[3368].PlayerChar.Base.Equip[6].Index := 1442;
            Servers[I].DevirGuards[3368].PlayerChar.Base.Equip[6].APP := 1442;
            Servers[I].DevirGuards[3368].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3368].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3368].PlayerChar.DuploAtk := $4A;
            Servers[I].DevirGuards[3368].Base.Create(
            @Servers[I].DevirGuards[3368].PlayerChar.Base, 3368, I);
          end;
        3339: //devir zelant
          begin
            System.Ansistrings.StrPlCopy
              (Servers[I].DevirNpc[j].PlayerChar.Base.Name, '968', 3);
            Servers[I].DevirNpc[j].DevirName := 'Zeelant';
            Servers[I].DevirNpc[j].PlayerChar.LastPos.X := 2236;
            Servers[I].DevirNpc[j].PlayerChar.LastPos.Y := 944;
            //pedra red
            Servers[I].DevirStones[3344].PlayerChar.Base.ClientId := 3344;
            System.Ansistrings.StrPlCopy(Servers[I].DevirStones[3344]
              .PlayerChar.Base.Name, '905', 3);
            Servers[I].DevirStones[3344].PlayerChar.LastPos.X := 2234;
            Servers[I].DevirStones[3344].PlayerChar.LastPos.Y := 952;
            Servers[I].DevirStones[3344].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirStones[3344].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirStones[3344].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirStones[3344].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirStones[3344].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirStones[3344].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3344].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3344].PlayerChar.DuploAtk := $43;
            Servers[I].DevirStones[3344].PlayerChar.Base.Equip[0].Index := 221;
            Servers[I].DevirStones[3344].PlayerChar.Base.Equip[0].APP := 221;
            Servers[I].DevirStones[3344].Base.Create(
            @Servers[I].DevirStones[3344].PlayerChar.Base, 3344, I);
            //pedra azul
            Servers[I].DevirStones[3349].PlayerChar.Base.ClientId := 3349;
            System.Ansistrings.StrPlCopy(Servers[I].DevirStones[3349]
              .PlayerChar.Base.Name, '905', 3);
            Servers[I].DevirStones[3349].PlayerChar.LastPos.X := 2244;
            Servers[I].DevirStones[3349].PlayerChar.LastPos.Y := 942;
            Servers[I].DevirStones[3349].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirStones[3349].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirStones[3349].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirStones[3349].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirStones[3349].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirStones[3349].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3349].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3349].PlayerChar.DuploAtk := $3D;
            Servers[I].DevirStones[3349].PlayerChar.Base.Equip[0].Index := 221;
            Servers[I].DevirStones[3349].PlayerChar.Base.Equip[0].APP := 221;
            Servers[I].DevirStones[3349].Base.Create(
            @Servers[I].DevirStones[3349].PlayerChar.Base, 3349, I);
            //pedra verde
            Servers[I].DevirStones[3354].PlayerChar.Base.ClientId := 3354;
            System.Ansistrings.StrPlCopy(Servers[I].DevirStones[3354]
              .PlayerChar.Base.Name, '905', 3);
            Servers[I].DevirStones[3354].PlayerChar.LastPos.X := 2230;
            Servers[I].DevirStones[3354].PlayerChar.LastPos.Y := 938;
            Servers[I].DevirStones[3354].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirStones[3354].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirStones[3354].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirStones[3354].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirStones[3354].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirStones[3354].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3354].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_STONE_HP;
            Servers[I].DevirStones[3354].PlayerChar.DuploAtk := $3C;
            Servers[I].DevirStones[3354].PlayerChar.Base.Equip[0].Index := 221;
            Servers[I].DevirStones[3354].PlayerChar.Base.Equip[0].APP := 221;
            Servers[I].DevirStones[3354].Base.Create(
            @Servers[I].DevirStones[3354].PlayerChar.Base, 3354, I);
             // guarda red
            Servers[I].DevirGuards[3359].PlayerChar.Base.ClientId := 3359;
            System.Ansistrings.StrPlCopy(Servers[I].DevirGuards[3359]
              .PlayerChar.Base.Name, '938', 3);
            Servers[I].DevirGuards[3359].PlayerChar.LastPos.X := 2237;
            Servers[I].DevirGuards[3359].PlayerChar.LastPos.Y := 935;
            Servers[I].DevirGuards[3359].FirstPosition :=
              Servers[I].DevirGuards[3359].PlayerChar.LastPos;
            Servers[I].DevirGuards[3359].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirGuards[3359].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirGuards[3359].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirGuards[3359].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirGuards[3359].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirGuards[3359].PlayerChar.Base.Equip[0].Index := 233;
            Servers[I].DevirGuards[3359].PlayerChar.Base.Equip[0].APP := 233;
            Servers[I].DevirGuards[3359].PlayerChar.Base.Equip[6].Index := 1442;
            Servers[I].DevirGuards[3359].PlayerChar.Base.Equip[6].APP := 1442;
            Servers[I].DevirGuards[3359].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3359].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3359].PlayerChar.DuploAtk := $48;
            Servers[I].DevirGuards[3359].Base.Create(
            @Servers[I].DevirGuards[3359].PlayerChar.Base, 3359, I);
            // guarda azul
            Servers[I].DevirGuards[3364].PlayerChar.Base.ClientId := 3364;
            System.Ansistrings.StrPlCopy(Servers[I].DevirGuards[3364]
              .PlayerChar.Base.Name, '942', 3);
            Servers[I].DevirGuards[3364].PlayerChar.LastPos.X := 2227;
            Servers[I].DevirGuards[3364].PlayerChar.LastPos.Y := 946;
            Servers[I].DevirGuards[3364].FirstPosition :=
              Servers[I].DevirGuards[3364].PlayerChar.LastPos;
            Servers[I].DevirGuards[3364].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirGuards[3364].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirGuards[3364].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirGuards[3364].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirGuards[3364].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirGuards[3364].PlayerChar.Base.Equip[0].Index := 233;
            Servers[I].DevirGuards[3364].PlayerChar.Base.Equip[0].APP := 233;
            Servers[I].DevirGuards[3364].PlayerChar.Base.Equip[6].Index := 1442;
            Servers[I].DevirGuards[3364].PlayerChar.Base.Equip[6].APP := 1442;
            Servers[I].DevirGuards[3364].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3364].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3364].PlayerChar.DuploAtk := $4B;
            Servers[I].DevirGuards[3364].Base.Create(
            @Servers[I].DevirGuards[3364].PlayerChar.Base, 3364, I);
            // guarda verde
            Servers[I].DevirGuards[3369].PlayerChar.Base.ClientId := 3369;
            System.Ansistrings.StrPlCopy(Servers[I].DevirGuards[3369]
              .PlayerChar.Base.Name, '941', 3);
            Servers[I].DevirGuards[3369].PlayerChar.LastPos.X := 2242;
            Servers[I].DevirGuards[3369].PlayerChar.LastPos.Y := 950;
            Servers[I].DevirGuards[3369].FirstPosition :=
              Servers[I].DevirGuards[3369].PlayerChar.LastPos;
            Servers[I].DevirGuards[3369].PlayerChar.Base.Nation :=
              Servers[I].NationID;
            Servers[I].DevirGuards[3369].PlayerChar.Base.CurrentScore.Sizes.
              Altura := 7;
            Servers[I].DevirGuards[3369].PlayerChar.Base.CurrentScore.Sizes.
              Tronco := 119;
            Servers[I].DevirGuards[3369].PlayerChar.Base.CurrentScore.Sizes.
              Perna := 119;
            Servers[I].DevirGuards[3369].PlayerChar.Base.CurrentScore.Sizes.
              Corpo := 0;
            Servers[I].DevirGuards[3369].PlayerChar.Base.Equip[0].Index := 233;
            Servers[I].DevirGuards[3369].PlayerChar.Base.Equip[0].APP := 233;
            Servers[I].DevirGuards[3369].PlayerChar.Base.Equip[6].Index := 1442;
            Servers[I].DevirGuards[3369].PlayerChar.Base.Equip[6].APP := 1442;
            Servers[I].DevirGuards[3369].PlayerChar.Base.CurrentScore.MaxHp :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3369].PlayerChar.Base.CurrentScore.CurHP :=
              MOB_GUARD_HP;
            Servers[I].DevirGuards[3369].PlayerChar.DuploAtk := $4A;
            Servers[I].DevirGuards[3369].Base.Create(
            @Servers[I].DevirGuards[3369].PlayerChar.Base, 3369, I);
          end;
      end;
      Servers[I].DevirNpc[j].PlayerChar.Base.Nation := Servers[I].NationID;
      Servers[I].DevirNpc[j].PlayerChar.Base.CurrentScore.Sizes.Altura := 20;
      Servers[I].DevirNpc[j].PlayerChar.Base.CurrentScore.Sizes.Tronco := 119;
      Servers[I].DevirNpc[j].PlayerChar.Base.CurrentScore.Sizes.Perna := 119;
      Servers[I].DevirNpc[j].PlayerChar.Base.CurrentScore.Sizes.Corpo := 30;
      Servers[I].Devires[j-3335].IsOpen := False;
      Servers[I].Devires[j-3335].StonesDied := 0;
      Servers[I].Devires[j-3335].GuardsDied := 0;
      Servers[I].DevirNpc[j].PlayerChar.Base.Equip[0].Index := 280;
      Servers[I].DevirNpc[j].PlayerChar.Base.Equip[0].APP := 280;
      Servers[I].DevirNpc[j].PlayerChar.Base.CurrentScore.MaxHP := 20000;
      inc(InstantiatedNPCs);
    end;
  end;
  for I := Low(Servers) to High(Servers) do
  begin
    Servers[I].CastleObjects[3370].PlayerChar.Base.ClientId := 3370;
    System.Ansistrings.StrPlCopy(Servers[I].CastleObjects[3370]
      .PlayerChar.Base.Name, '1014', 4);
    Servers[I].CastleObjects[3370].PlayerChar.LastPos.X := 3551.4;
    Servers[I].CastleObjects[3370].PlayerChar.LastPos.Y := 2759.8;

    Servers[I].CastleObjects[3370].PlayerChar.Base.Nation :=
      Servers[I].NationID;
    Servers[I].CastleObjects[3370].PlayerChar.Base.CurrentScore.Sizes.
      Altura := 7;
    Servers[I].CastleObjects[3370].PlayerChar.Base.CurrentScore.Sizes.
      Tronco := 119;
    Servers[I].CastleObjects[3370].PlayerChar.Base.CurrentScore.Sizes.
      Perna := 119;
    Servers[I].CastleObjects[3370].PlayerChar.Base.CurrentScore.Sizes.
      Corpo := 0;

    Servers[I].CastleObjects[3370].PlayerChar.Base.CurrentScore.MaxHp :=
      30000;

    Servers[I].CastleObjects[3370].PlayerChar.Base.Equip[0].Index := 261;
      Servers[I].CastleObjects[3370].PlayerChar.Base.Equip[0].APP := 261;

    Servers[I].CastleObjects[3370].Base.Create(
      @Servers[I].CastleObjects[3370].PlayerChar.Base, 3370, I);

    Inc(InstantiatedNPCs);


    Servers[I].CastleObjects[3371].PlayerChar.Base.ClientId := 3371;
    System.Ansistrings.StrPlCopy(Servers[I].CastleObjects[3371]
      .PlayerChar.Base.Name, '1016', 4);
    Servers[I].CastleObjects[3371].PlayerChar.LastPos.X := 3616.8;
    Servers[I].CastleObjects[3371].PlayerChar.LastPos.Y := 2759.8;

    Servers[I].CastleObjects[3371].PlayerChar.Base.Nation :=
      Servers[I].NationID;
    Servers[I].CastleObjects[3371].PlayerChar.Base.CurrentScore.Sizes.
      Altura := 7;
    Servers[I].CastleObjects[3371].PlayerChar.Base.CurrentScore.Sizes.
      Tronco := 119;
    Servers[I].CastleObjects[3371].PlayerChar.Base.CurrentScore.Sizes.
      Perna := 119;
    Servers[I].CastleObjects[3371].PlayerChar.Base.CurrentScore.Sizes.
      Corpo := 0;

    Servers[I].CastleObjects[3371].PlayerChar.Base.CurrentScore.MaxHp :=
      30000;

    Servers[I].CastleObjects[3371].PlayerChar.Base.Equip[0].Index := 261;
      Servers[I].CastleObjects[3371].PlayerChar.Base.Equip[0].APP := 261;

    Servers[I].CastleObjects[3371].Base.Create(
      @Servers[I].CastleObjects[3371].PlayerChar.Base, 3371, I);

    Inc(InstantiatedNPCs);


    Servers[I].CastleObjects[3372].PlayerChar.Base.ClientId := 3372;
    System.Ansistrings.StrPlCopy(Servers[I].CastleObjects[3372]
      .PlayerChar.Base.Name, '1015', 4);
    Servers[I].CastleObjects[3372].PlayerChar.LastPos.X := 3583.95;
    Servers[I].CastleObjects[3372].PlayerChar.LastPos.Y := 2860.4;

    Servers[I].CastleObjects[3372].PlayerChar.Base.Nation :=
      Servers[I].NationID;
    Servers[I].CastleObjects[3372].PlayerChar.Base.CurrentScore.Sizes.
      Altura := 7;
    Servers[I].CastleObjects[3372].PlayerChar.Base.CurrentScore.Sizes.
      Tronco := 119;
    Servers[I].CastleObjects[3372].PlayerChar.Base.CurrentScore.Sizes.
      Perna := 119;
    Servers[I].CastleObjects[3372].PlayerChar.Base.CurrentScore.Sizes.
      Corpo := 0;

    Servers[I].CastleObjects[3372].PlayerChar.Base.CurrentScore.MaxHp :=
      30000;

    Servers[I].CastleObjects[3372].PlayerChar.Base.Equip[0].Index := 261;
      Servers[I].CastleObjects[3372].PlayerChar.Base.Equip[0].APP := 261;

    Servers[I].CastleObjects[3372].Base.Create(
      @Servers[I].CastleObjects[3372].PlayerChar.Base, 3372, I);

    Inc(InstantiatedNPCs);


    Servers[I].CastleObjects[3373].PlayerChar.Base.ClientId := 3373;
    System.Ansistrings.StrPlCopy(Servers[I].CastleObjects[3373]
      .PlayerChar.Base.Name, '1017', 4);
    Servers[I].CastleObjects[3373].PlayerChar.LastPos.X := 3584;
    Servers[I].CastleObjects[3373].PlayerChar.LastPos.Y := 2804.75;

    Servers[I].CastleObjects[3373].PlayerChar.Base.Nation :=
      Servers[I].NationID;
    Servers[I].CastleObjects[3373].PlayerChar.Base.CurrentScore.Sizes.
      Altura := 0;
    Servers[I].CastleObjects[3373].PlayerChar.Base.CurrentScore.Sizes.
      Tronco := 135;
    Servers[I].CastleObjects[3373].PlayerChar.Base.CurrentScore.Sizes.
      Perna := 119;
    Servers[I].CastleObjects[3373].PlayerChar.Base.CurrentScore.Sizes.
      Corpo := 0;

    Servers[I].CastleObjects[3373].PlayerChar.Base.CurrentScore.MaxHp :=
      30000;

    Servers[I].CastleObjects[3373].PlayerChar.Base.Equip[0].Index := 5722;
      Servers[I].CastleObjects[3373].PlayerChar.Base.Equip[0].APP := 5722;

    Servers[I].CastleObjects[3373].Base.Create(
      @Servers[I].CastleObjects[3373].PlayerChar.Base, 3373, I);

    Inc(InstantiatedNPCs);
  end;
  Logger.Write('O servidor carregou ' + IntToStr(InstantiatedNPCs) +
    ' NPCs com sucesso.', TLogType.ServerStatus);
  //Logger.Write(quest_cnt.toString, TLogType.Packets);
end;
class function TLoad.LoadNPCOptions: Boolean;
var
  f: File of TNPCFileOptions;
  local: string;
begin
  Result := False;
  local := GetCurrentDir + '\Data\NPCOptionsText.bin';
  if not(FileExists(local)) then
  begin
    Exit;
  end;
  try
    AssignFile(f, local);
    Reset(f);
    Read(f, NPCOptionsText);
    CloseFile(f);
    Result := true;
  except
    CloseFile(f);
    Result := False;
  end;
end;
{$ENDREGION}
{$REGION 'Server'}
class procedure TLoad.InitServerList;
var
  FName: string;
begin
  FName := GetCurrentDir + '\SL.bin';
  if not(TFunctions.LoadSL(FName)) then
  begin
    Logger.Write('SL.bin não encontrado ou arquivo corrompido.',
      TLogType.Warnings);
    Exit;
  end;
  Logger.Write('SL.bin carregado com sucesso.', TLogType.ServerStatus);
end;
class procedure TLoad.InitServerConf;
var
  FileConf: TIniFile;
  Users, Version, ServerCount: String;
  SqlDatabase, SqlUsername, SqlPassword, SqlServer: String;
  SqlPort: Integer;
begin
  if not(FileExists(GetCurrentDir + '\AikaServer.ini')) then
  begin
    Logger.Write('AikaServer.ini não encontrado.', TLogType.Warnings);
    Exit;
  end;
  FileConf := TIniFile.Create(GetCurrentDir + '\AikaServer.ini');
  SqlPort := 0;
  try
    Users := FileConf.ReadString('Server', 'MAX_USERS', Users);
    Version := FileConf.ReadString('Server', 'Version', Version);
    ServerCount := FileConf.ReadString('Server', 'Channels', '1');
    SqlDatabase := FileConf.ReadString('MySQL', 'Database', SqlDatabase);
    SqlServer := FileConf.ReadString('MySQL', 'Server', SqlServer);
    SqlPort := FileConf.ReadInteger('MySQL', 'Port', SqlPort);
    SqlUsername := FileConf.ReadString('MySQL', 'Username', SqlUsername);
    SqlPassword := FileConf.ReadString('MySQL', 'Password', SqlPassword);
    MYSQL_USERNAMEGM := FileConf.ReadString('MySQL', 'UsernameGM', SqlUsername);
    MYSQL_PASSWORDGM := FileConf.ReadString('MySQL', 'PasswordGM', SqlPassword);
    MYSQL_SERVERGM := FileConf.ReadString('MySQL', 'ServerGM', MYSQL_SERVERGM);
    ASAAS_TOKEN_PINGBACK := FileConf.ReadString('ASAAS_TOKEN', 'TOKEN', ASAAS_TOKEN_PINGBACK);
    ASAAS_LINK_GATEWAY := FileConf.ReadString('ASAAS_TOKEN', 'LINK', ASAAS_LINK_GATEWAY);

    LEVEL_CAP := FileConf.ReadInteger('GAMESERVERCONF', 'LEVEL_CAP', LEVEL_CAP);
    MAX_PRAN_LEVEL := FileConf.ReadInteger('GAMESERVERCONF', 'MAX_PRAN_LEVEL', MAX_PRAN_LEVEL);
    DELETE_DAYS_INC := FileConf.ReadInteger('GAMESERVERCONF', 'DELETE_DAYS_INC', DELETE_DAYS_INC);
    DAYS_BACKUP_ACCOUNT_DELETE := FileConf.ReadInteger('GAMESERVERCONF', 'DAYS_BACKUP_ACCOUNT_DELETE', DAYS_BACKUP_ACCOUNT_DELETE);
    MOB_ESQUIVA := FileConf.ReadInteger('GAMESERVERCONF', 'MOB_ESQUIVA', MOB_ESQUIVA);
    MOB_CRIT_RES := FileConf.ReadInteger('GAMESERVERCONF', 'MOB_CRIT_RES', MOB_CRIT_RES);
    MOB_DUPLO_RES := FileConf.ReadInteger('GAMESERVERCONF', 'MOB_DUPLO_RES', MOB_DUPLO_RES);
    MOB_GUARD_PATK := FileConf.ReadInteger('GAMESERVERCONF', 'MOB_GUARD_PATK', MOB_GUARD_PATK);
    MOB_GUARD_MATK := FileConf.ReadInteger('GAMESERVERCONF', 'MOB_GUARD_MATK', MOB_GUARD_MATK);
    MOB_GUARD_PDEF := FileConf.ReadInteger('GAMESERVERCONF', 'MOB_GUARD_PDEF', MOB_GUARD_PDEF);
    MOB_GUARD_MDEF := FileConf.ReadInteger('GAMESERVERCONF', 'MOB_GUARD_MDEF', MOB_GUARD_MDEF);
    MOB_GUARD_DEVIR_ATK := FileConf.ReadInteger('GAMESERVERCONF', 'MOB_GUARD_DEVIR_ATK', MOB_GUARD_DEVIR_ATK);
    MOB_GUARD_DEVIR_DEF := FileConf.ReadInteger('GAMESERVERCONF', 'MOB_GUARD_DEVIR_DEF', MOB_GUARD_DEVIR_DEF);
    MOB_STONE_DEVIR_ATK := FileConf.ReadInteger('GAMESERVERCONF', 'MOB_STONE_DEVIR_ATK', MOB_STONE_DEVIR_ATK);
    MOB_STONE_DEVIR_DEF := FileConf.ReadInteger('GAMESERVERCONF', 'MOB_STONE_DEVIR_DEF', MOB_STONE_DEVIR_DEF);
    MOB_STONE_HP := FileConf.ReadInteger('GAMESERVERCONF', 'MOB_STONE_HP', MOB_STONE_HP);
    MOB_GUARD_HP := FileConf.ReadInteger('GAMESERVERCONF', 'MOB_GUARD_HP', MOB_GUARD_HP);
    EXP_MULTIPLIER := FileConf.ReadInteger('GAMESERVERCONF', 'EXP_MULTIPLIER', EXP_MULTIPLIER);
    HONOR_PER_KILL := FileConf.ReadInteger('GAMESERVERCONF', 'HONOR_PER_KILL', HONOR_PER_KILL);
    PVP_ITEM_DROP_TAX := FileConf.ReadInteger('GAMESERVERCONF', 'PVP_ITEM_DROP_TAX', PVP_ITEM_DROP_TAX);
    SKULL_MULTIPLIER := FileConf.ReadInteger('GAMESERVERCONF', 'SKULL_MULTIPLIER', SKULL_MULTIPLIER);
    DUEL_TIME_WAIT := FileConf.ReadInteger('GAMESERVERCONF', 'DUEL_TIME_WAIT', DUEL_TIME_WAIT);
    RELIQ_EST_TIME := FileConf.ReadInteger('GAMESERVERCONF', 'RELIQ_EST_TIME', RELIQ_EST_TIME);
    INC_HONOR_RELIQ_LEVEL := FileConf.ReadInteger('GAMESERVERCONF', 'INC_HONOR_RELIQ_LEVEL', INC_HONOR_RELIQ_LEVEL);
    RATE_EFFECT5 := FileConf.ReadInteger('GAMESERVERCONF', 'RATE_EFFECT5', RATE_EFFECT5);
    DISTANCE_TO_WATCH := FileConf.ReadInteger('GAMESERVERCONF', 'DISTANCE_TO_WATCH', DISTANCE_TO_WATCH);
    DISTANCE_TO_FORGET := FileConf.ReadInteger('GAMESERVERCONF', 'DISTANCE_TO_FORGET', DISTANCE_TO_FORGET);
  finally
    SERVER_VERSION := StrToInt(Version);
    MAX_CONNECTIONS := StrToInt(Users);
    SERVER_COUNT := StrToInt(ServerCount);
    MYSQL_SERVER := SqlServer;
    MYSQL_PORT := SqlPort;
    MYSQL_DATABASE := SqlDatabase;
    MYSQL_USERNAME := SqlUsername;
    MYSQL_PASSWORD := SqlPassword;
    FileConf.Free;
  end;
  SetLength(Servers, SERVER_COUNT);

  Logger.Write('Configuração do servidor foi carregada com sucesso.', TLogType.Packets);
end;
class procedure TLoad.InitServers;
var
  I: Byte;
begin
  InstantiatedChannels := 0;
  for I := Low(Servers) to High(Servers) do
  begin
    Servers[I] := TServerSocket.Create;
    if (ServerList[I].IP <> '') and (ServerList[I].IP <> '0.0.0.0') then
    begin
      Servers[I].IP := ServerList[I].IP;
      Servers[I].Name := ServerList[I].Name;
      Servers[I].ChannelId := I;
      Servers[I].NationID := ServerList[I].NationIndex;
      Servers[I].NationType := ServerList[I].ChannelNationIndex;
      if (Servers[I].StartServer) then
        inc(InstantiatedChannels);
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Auth Server'}
class procedure TLoad.InitAuthServer;
begin
  LoginServer := TLoginSocket.Create;
  LoginServer.IP := ServerList[31].IP;
  if not(LoginServer.StartServer) then
    Exit;
  TokenServer := TTokenServer.Create;
  if not(TokenServer.StartServer) then
    Exit;
  //TokenServerAdmin := TTokenServerAdmin.Create;
  //if not(TokenServerAdmin.StartServer) then
   // Exit;
end;
{$ENDREGION}
{$REGION 'Maps'}
class procedure TLoad.InitMapsData;
var
  f: File of TFileMapsData;
  FName: string;
begin
  FName := GetCurrentDir + '\Data\Map.bin';
  if not(FileExists(FName)) then
  begin
    Logger.Write('Map.bin não encontrado.', TLogType.Warnings);
    Exit;
  end;
  AssignFile(f, FName);
  try
    Reset(f);
    Read(f, MapsData);
    CloseFile(f);
  except
    Logger.Write('Map.bin não carregou corretamente.', TLogType.Warnings);
    Exit;
  end;
  Logger.Write('Map.bin carregado com sucesso.', TLogType.ServerStatus);
end;
class procedure TLoad.InitScrollPositions;
var
  FSize, Len: Integer;
  f: TFileStream;
  FName: string;
begin
  FName := GetCurrentDir + '\Data\ScrollPos.bin';
  if not(FileExists(FName)) then
  begin
    Logger.Write('ScrollPos.bin não encontrado.', TLogType.Warnings);
    Exit;
  end;
  f := TFileStream.Create(FName, FmOpenRead);
  FSize := f.Size;
  Len := Round(FSize div sizeof(TScrollTeleportPos));
  SetLength(ScrollTeleportPosition, Len);
  try
    f.Position := 0;
    f.ReadBuffer(ScrollTeleportPosition[0], f.Size);
    f.Free;
  except
    f.Free;
    Exit;
  end;
  Logger.Write('ScrollPos.bin carregado com sucesso.', TLogType.ServerStatus);
end;
{$ENDREGION}
end.
