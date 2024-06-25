unit Functions;
interface
uses
  Player, BaseMob, MiscData, Packets, IdHashMessageDigest, CpuUsage, PlayerData,
  SysUtils, GuildData, StrUtils, Data.DB, System.AnsiStrings, Windows;
type
  TByteArr = ARRAY OF BYTE;
type
  TFunctions = class(TObject)
  public
    { String Functions }
    class function IsLetter(Text: String): Boolean;
    class function CharArrayToString(Chars: ARRAY OF AnsiChar): string;
    class function StringToMd5(TextStr: string): string;
    class function ByteArrToString(const Buffer: ARRAY OF BYTE)
      : string; overload;
    class function ByteArrToString(const Buffer: ARRAY OF BYTE; Len: word)
      : string; overload;
    class function StrToFile(Texto: string; FileName: String): Boolean;
    class function StrToArray(const BufferStr: string;
      var Buffer: array of BYTE): Integer;
    class function GetPacketStrLen(const BufferStr: string): Integer;
    { Client ID Functions }
    class function FreeClientId(Server: BYTE): Integer;
    class function ClientId(Server: BYTE; IP: string): Integer;
    class function FreePetId(Server: BYTE): Integer;
    { Title Functions }
    class function GetTitleLevelValue(Slot, Level: BYTE): UInt32;
    { Pran Functions }
    class function GetPranCreationID(var Player: TPlayer;
       AccID: Integer; CreatedAt: DWORD): Integer;
    class function SavePranCreated(var Player: TPlayer;
      var Pran: TPran): Boolean;
    class function VerifyNameAlreadyExists(var Player: TPlayer;
      Name: String): Boolean;
    { Character File Functions }
    // class procedure SaveCharacterFile(const Player: TPlayer; characterName: string);
    // class function FindCharacter(characterName: string): Boolean;
    class function GetCharacterAccount(characterName: string;
      out Account: string): Boolean;
    class function GetCharacterNation(characterName: string;
      out Nation: TCitizenship): Boolean;
    { Guild File Functions }
    class procedure SaveGuilds(GuildX: Cardinal = 0);
    class function SearchGuildByName(Name: String): PGuild;
    { Account File Functions }
    class procedure SaveAccountFile(const Account: TAccountFile;
      AccountName: string; AccountNamePure: String);
    class function GetAccountsBackup(var Player: TPlayer; TypeOf: Integer; AccountName: string): Boolean;
    class procedure ManageAccountsBackupCount(var Player: TPlayer; AccountName: string);
    class function FindAccount(AccountName: string): Boolean;
    { Trade Functions }
    class function ExecuteTrade(var Player: TPlayer; var OtherPlayer: TPlayer)
      : Boolean; overload;
    class function ExecuteTrade(var Player: TPlayer; OtherPlayer: PPlayer)
      : Boolean; overload;
    { Desempein Functions }
    class function GetCPUUsage: Single;
    class function GetMemoryUsed: Integer;
    { File Functions }
    class function GetFileSize(const FileName: string): UInt64;
    class function LoadPacket(PacketName: string;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function LoadBasicCharacter(FName: string;
      var Character: TCharacterDB): Boolean;
    class function SaveBasicCharacter(FName: string;
      const Character: TCharacterDB): Boolean;
    class function CreateBasicCharacter(FName: string; Classe: Integer)
      : Boolean;
    class function GetFilesCount(Diretorio, Pesquisa: string): Integer;
    // class function IncAccountsCount: Cardinal;
    class function IncCharactersCount(SelfPlayer: PPlayer): Cardinal;
    class function DecCharactersCount(SelfPlayer: PPlayer): Cardinal;
    { EncDec Files }
    class function EncDecSL(var Buffer: ARRAY OF BYTE; Encrypt: Boolean)
      : Boolean; overload;
    class function EncDecSL(Buffer: Pointer; Size: UInt64; Encrypt: Boolean)
      : Boolean; overload;
    { Load Functions }
    class function LoadSL(FileName: string): Boolean;
    { Save Functions }
    class function SaveSL(FileName: string): Boolean;
    { Time Functions }
    class function Time(): String; static;
    class function UNIXTimeToDateTimeFAST(UnixTime: Int64)
      : TDateTime; static;
    class function DateTimeToUNIXTimeFAST(DelphiTime: TDateTime)
      : Int64; static;
    class function ReTime(Time: String): TDateTime;
    { MakeItems }
    class function SearchMakeItemIDByRewardID(RewardID: word): word;
    { test functions apagar dps }
    // class procedure GetMakeItems();
    // class procedure GetMakeItemsIngredients();
  end;
implementation
uses
  GlobalDefs, Log, Classes, ItemFunctions, PsApi,
  SkillFunctions, FilesData, DateUtils, SQL;
{$REGION 'String Functions'}
class function TFunctions.IsLetter(Text: String): Boolean;
const
  ALPHA_CHARS = ['a' .. 'z', 'A' .. 'Z', '0' .. '9'];
var
  i: Integer;
begin
  if (Length(Text) > 0) then
  begin
    for I := 1 to Length(Text) do
    begin
      if not(CharInSet(Text[i], ALPHA_CHARS)) then
      begin
        Result := false;
        Exit;
      end;
    end;
  end;
  Result := true;
end;
class function TFunctions.CharArrayToString(Chars: ARRAY OF AnsiChar): string;
begin
  if (Length(Chars) > 0) then
    SetString(Result, PAnsiChar(@Chars[0]), Length(Chars))
  else
    Result := '';
  Result := Trim(Result);
end;
class function TFunctions.StringToMd5(TextStr: string): string;
var
  idmd5: TIdHashMessageDigest5;
begin
  idmd5 := TIdHashMessageDigest5.Create;
  try
    Result := LowerCase(idmd5.HashStringAsHex(TextStr));
  finally
    idmd5.Free;
  end;
end;
class function TFunctions.ByteArrToString(const Buffer: array of BYTE): string;
var
  i: Integer;
begin
  for i := 0 to Length(Buffer) - 1 do
    Result := Result + IntToHex(Buffer[i], 2) + ' ';
end;
class function TFunctions.ByteArrToString(const Buffer: array of BYTE;
  Len: word): string;
var
  i: Integer;
begin
  for i := 0 to Len - 1 do
  begin
    Result := Result + IntToHex(Buffer[i], 2) + ' ';
  end;
end;
class function TFunctions.StrToFile(Texto: string; FileName: string): Boolean;
var
  F: TextFile;
begin
  Result := True;
  try
    AssignFile(F, FileName);
    ReWrite(F);
    WriteLn(F, Texto);
    CloseFile(F);
  except
    Result := False;
  end;
end;
class function TFunctions.StrToArray(const BufferStr: string;
  var Buffer: array of BYTE): Integer;
var
  i: Integer;
  Data: TStringList;
begin
  Result := 0;
  Data := TStringList.Create;
  if (Length(BufferStr) > 1) then
  begin
    try
      Data.Delimiter := ' ';
      Data.DelimitedText := BufferStr;
      Result := Data.Count;
      if (Data.Count > 0) then
        for i := 0 to (Data.Count - 1) do
          Buffer[i] := StrToInt('$' + Data[i]);
    except
      on E: Exception do
      begin
        Result := 0;
        E.Free;
      end;
    end;
  end;
end;
class function TFunctions.GetPacketStrLen(const BufferStr: string): Integer;
var
  Data: TStringList;
begin
  Data := TStringList.Create;
  try
    Data.Delimiter := ' ';
    Data.DelimitedText := BufferStr;
    Result := Data.Count;
  except
    on E: Exception do
    begin
      Result := 0;
      E.Free;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Client Id Functions'}
class function TFunctions.ClientId(Server: BYTE; IP: string): Integer;
var
  i: word;
begin
  Result := 0;
  for i := 1 to MAX_CONNECTIONS do
  begin
    if (Servers[Server].Players[i].IP = IP) then
    begin
      Result := i;
      break;
    end;
  end;
end;
class function TFunctions.FreeClientId(Server: BYTE): Integer;
var
  i: word;
begin
  Result := 0;
  for i := 1 to MAX_CONNECTIONS do
  begin
    if (Servers[Server].Players[i].Base.ClientId = 0) then // era o player.ip
    begin
      Result := i;
      break;
    end;
  end;
end;
class function TFunctions.FreePetId(Server: BYTE): Integer;
var
  i: word;
begin
  Result := 0;
  for i := Low(Servers[Server].PETS) to High(Servers[Server].PETS) do
  begin
    if (Servers[Server].PETS[i].Base.IsActive = False) then
    begin
      Result := i;
      break;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Title Functions'}
class function TFunctions.GetTitleLevelValue(Slot, Level: BYTE): UInt32;
var
  x: BYTE;
begin
  // x := 0;
  x := (Slot * 4) + (Level - 1);
  if (Level > 1) then
  begin
    Result := (1 shl x) + Self.GetTitleLevelValue(Slot, Level - 1);
  end
  else
  begin
    Result := (1 shl x);
  end;
end;
{$ENDREGION}
{$REGION 'Pran Functions'}
class function TFunctions.GetPranCreationID(var Player: TPlayer;
  AccId: Integer; CreatedAt: DWORD): Integer;
var
  PranCount: Integer;
  SQLComp: TQuery;
begin
  PranCount := -1;
  if (CreatedAt = 0) then
  begin
    Result := PranCount;
    Exit;
  end;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GetPranCreationID]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetPranCreationID]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    SQLComp.SetQuery(format('SELECT id FROM prans WHERE acc_id=%d AND created_at=%d',
      [AccID, CreatedAt]));
    SQLComp.Run();
    if (SQLComp.Query.RecordCount = 0) then
    begin
      Result := PranCount;
      SQLComp.Destroy;
      Exit;
    end;
    PranCount := SQLComp.Query.Fields[0].AsInteger;
    // Player.PlayerSQL.MySQL.StartTransaction;
    {
      Player.PlayerSQL.SetQuery
      ('SELECT pran_count FROM server_info WHERE server_id =1');
      //Player.PlayerSQL.AddParameter2('pserver_id', 1);
      Player.PlayerSQL.Run();
      PranCount := Player.PlayerSQL.Query.FieldByName('pran_count').AsInteger;
      Inc(PranCount);
      Player.PlayerSQL.SetQuery
      (format('UPDATE server_info SET pran_count=%d WHERE '+
      'server_id=1', [PranCount]));
      //Player.PlayerSQL.AddParameter2('ppran_count', PranCount);
      // Player.PlayerSQL.AddParameter2('pserver_id', 1);
      Player.PlayerSQL.Run(False); }
    // Player.PlayerSQL.MySQL.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('TFunctions.GetPranCreationID error MYSQL ' + E.Message +
        ' at ' + DateTimeToStr(Now), TlogType.Error);
    end;
  end;
  SQLComp.Destroy;
  Result := PranCount;
end;
class function TFunctions.SavePranCreated(var Player: TPlayer;
  var Pran: TPran): Boolean;
var
  i: Integer;
  SuccessSaved: Boolean;
  PranID: Integer;
  SQLComp: TQuery;
begin
  SuccessSaved := False;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SavePranCreated]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SavePranCreated]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    SQLComp.SetQuery
      (format('INSERT INTO prans (acc_id, char_id, name, food, devotion, p_cute, p_smart, '
      + 'p_sexy, p_energetic, p_tough, p_corrupt, level, class, hp, max_hp, mp, max_mp, '
      + 'xp, def_p, def_m, width, chest, leg, updated_at, created_at) VALUES (%d, %d, %s, %d, %d, %d, %d, '
      + '%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, ' +
      '%d, %d, %d, %d, %d, %d, %d, %d)', [Pran.AccId,
      Player.Character.Base.CharIndex, QuotedStr(String(Pran.Name)), Pran.Food,
      Pran.Devotion, Pran.Personality.Cute, Pran.Personality.Smart,
      Pran.Personality.Sexy, Pran.Personality.Energetic, Pran.Personality.Tough,
      Pran.Personality.Corrupt, Pran.Level, Pran.ClassPran, Pran.CurHP,
      Pran.MaxHp, Pran.CurMp, Pran.MaxMP, Pran.Exp, Pran.DefFis, Pran.DefMag,
      Pran.Width, Pran.Chest, Pran.Leg, Pran.Updated_at, Pran.CreatedAt]));
    SQLComp.Run(False);
  finally
    PranID := Self.GetPranCreationID(Player,Pran.AccId, Pran.CreatedAt);
    if(PranID > 0) then
    begin
      Pran.Iddb := PranID;
      Pran.ItemID := PranID;
      try
        SQLComp.SetQuery(format('UPDATE prans SET item_id=%d WHERE id=%d',
          [Pran.Iddb, PranID]));
        SQLComp.Run(False);
      finally
        SuccessSaved := True;
      end;
    end;
  end;
  if(SuccessSaved = False) then
  begin
    Player.SendClientMessage('Erro de criação de pran, contate o suporte.');
    ZeroMemory(@Pran, sizeof(TPran));
    SQLComp.Destroy;
    Exit;
  end;
  // Player.PlayerSQL.AddParameter2('pid', Pran.Iddb);
  { Player.PlayerSQL.AddParameter2('pacc_id', Pran.AccId);
    Player.PlayerSQL.AddParameter2('pchar_id',
    Player.Account.Characters[Player.SelectedCharacterIndex].Index);
    // Player.PlayerSQL.AddParameter2('pitem_id', Pran.ItemID);
    Player.PlayerSQL.AddParameter2('pname', AnsiString(Pran.Name));
    Player.PlayerSQL.AddParameter2('pfood', Pran.Food);
    Player.PlayerSQL.AddParameter2('pdevotion', Pran.Devotion);
    Player.PlayerSQL.AddParameter2('pp_cute', Pran.Personality.Cute);
    Player.PlayerSQL.AddParameter2('pp_smart', Pran.Personality.Smart);
    Player.PlayerSQL.AddParameter2('pp_sexy', Pran.Personality.Sexy);
    Player.PlayerSQL.AddParameter2('pp_energetic', Pran.Personality.Energetic);
    Player.PlayerSQL.AddParameter2('pp_tough', Pran.Personality.Tough);
    Player.PlayerSQL.AddParameter2('pp_corrupt', Pran.Personality.Corrupt);
    Player.PlayerSQL.AddParameter2('plevel', Pran.Level);
    Player.PlayerSQL.AddParameter2('pclass', Pran.ClassPran);
    Player.PlayerSQL.AddParameter2('php', Pran.CurHP);
    Player.PlayerSQL.AddParameter2('pmax_hp', Pran.MaxHp);
    Player.PlayerSQL.AddParameter2('pmp', Pran.CurMp);
    Player.PlayerSQL.AddParameter2('pmax_mp', Pran.MaxMP);
    Player.PlayerSQL.AddParameter2('pxp', Pran.Exp);
    Player.PlayerSQL.AddParameter2('pdef_p', Pran.DefFis);
    Player.PlayerSQL.AddParameter2('pdef_m', Pran.DefMag);
    Player.PlayerSQL.AddParameter2('pwidth', Pran.Width);
    Player.PlayerSQL.AddParameter2('pchest', Pran.Chest);
    Player.PlayerSQL.AddParameter2('pleg', Pran.Leg);
    Player.PlayerSQL.AddParameter2('pupdated_at', Pran.Updated_at);
    Player.PlayerSQL.AddParameter2('pcreated_at', Pran.CreatedAt);
    Player.PlayerSQL.Run(False); }
  for i := 0 to 15 do
  begin
    if (Pran.Equip[i].Index = 0) then
      Continue;
    SQLComp.SetQuery
      (format('INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
      'app, effect1_index, effect1_value, effect2_index, effect2_value,' +
      ' effect3_index, effect3_value, min, max, refine, time) VALUES ' +
      '(%d, %d, %d, %d, ' +
      '%d, %d, %d, %d, %d,'
      + ' %d, %d, %d, %d, %d, %d)',
      [PRAN_EQUIP_TYPE, Pran.Iddb, i, Pran.Equip[i].Index, Pran.Equip[i].APP,
        Pran.Equip[i].Effects.Index[0], Pran.Equip[i].Effects.Value[0],
        Pran.Equip[i].Effects.Index[1], Pran.Equip[i].Effects.Value[1],
        Pran.Equip[i].Effects.Index[2], Pran.Equip[i].Effects.Value[2],
        Pran.Equip[i].MIN, Pran.Equip[i].MAX, Pran.Equip[i].Refi, Pran.Equip[i].Time]));
    SQLComp.Run(False);
   {Player.PlayerSQL.AddParameter2('pslot_type', PRAN_EQUIP_TYPE);
    Player.PlayerSQL.AddParameter2('powner_id', Pran.Iddb);
    Player.PlayerSQL.AddParameter2('pslot', i);
    Player.PlayerSQL.AddParameter2('pitem_id', Pran.Equip[i].Index);
    Player.PlayerSQL.AddParameter2('papp', Pran.Equip[i].APP);
    Player.PlayerSQL.AddParameter2('peffect1_index',
      Pran.Equip[i].Effects.Index[0]);
    Player.PlayerSQL.AddParameter2('peffect1_value',
      Pran.Equip[i].Effects.Value[0]);
    Player.PlayerSQL.AddParameter2('peffect2_index',
      Pran.Equip[i].Effects.Index[1]);
    Player.PlayerSQL.AddParameter2('peffect2_value',
      Pran.Equip[i].Effects.Value[1]);
    Player.PlayerSQL.AddParameter2('peffect3_index',
      Pran.Equip[i].Effects.Index[2]);
    Player.PlayerSQL.AddParameter2('peffect3_value',
      Pran.Equip[i].Effects.Value[2]);
    Player.PlayerSQL.AddParameter2('pmin', Pran.Equip[i].MIN);
    Player.PlayerSQL.AddParameter2('pmax', Pran.Equip[i].MAX);
    Player.PlayerSQL.AddParameter2('prefine', Pran.Equip[i].Refi);
    Player.PlayerSQL.AddParameter2('ptime', Pran.Equip[i].Time);
    Player.PlayerSQL.Run(False); }
  end;
  for i := 0 to 41 do
  begin
    if (Pran.Inventory[i].Index = 0) then
      Continue;
    SQLComp.SetQuery
      (format('INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
      'app, effect1_index, effect1_value, effect2_index, effect2_value,' +
      ' effect3_index, effect3_value, min, max, refine, time) VALUES ' +
      '(%d, %d, %d, %d, ' +
      '%d, %d, %d, %d, %d,'
      + ' %d, %d, %d, %d, %d, %d)',
      [PRAN_INV_TYPE, Pran.Iddb, i, Pran.Inventory[i].Index, Pran.Inventory[i].APP,
      Pran.Inventory[i].Effects.Index[0], Pran.Inventory[i].Effects.Value[0],
      Pran.Inventory[i].Effects.Index[1], Pran.Inventory[i].Effects.Value[1],
      Pran.Inventory[i].Effects.Index[2], Pran.Inventory[i].Effects.Value[2],
      Pran.Inventory[i].MIN, Pran.Inventory[i].MAX, Pran.Inventory[i].Refi,
      Pran.Inventory[i].Time]));
    SQLComp.Run(False);
   { Player.PlayerSQL.AddParameter2('pslot_type', PRAN_INV_TYPE);
    Player.PlayerSQL.AddParameter2('powner_id', Pran.Iddb);
    Player.PlayerSQL.AddParameter2('pslot', i);
    Player.PlayerSQL.AddParameter2('pitem_id', Pran.Inventory[i].Index);
    Player.PlayerSQL.AddParameter2('papp', Pran.Inventory[i].APP);
    Player.PlayerSQL.AddParameter2('peffect1_index',
      Pran.Inventory[i].Effects.Index[0]);
    Player.PlayerSQL.AddParameter2('peffect1_value',
      Pran.Inventory[i].Effects.Value[0]);
    Player.PlayerSQL.AddParameter2('peffect2_index',
      Pran.Inventory[i].Effects.Index[1]);
    Player.PlayerSQL.AddParameter2('peffect2_value',
      Pran.Inventory[i].Effects.Value[1]);
    Player.PlayerSQL.AddParameter2('peffect3_index',
      Pran.Inventory[i].Effects.Index[2]);
    Player.PlayerSQL.AddParameter2('peffect3_value',
      Pran.Inventory[i].Effects.Value[2]);
    Player.PlayerSQL.AddParameter2('pmin', Pran.Inventory[i].MIN);
    Player.PlayerSQL.AddParameter2('pmax', Pran.Inventory[i].MAX);
    Player.PlayerSQL.AddParameter2('prefine', Pran.Inventory[i].Refi);
    Player.PlayerSQL.AddParameter2('ptime', Pran.Inventory[i].Time);
    Player.PlayerSQL.Run(False);  }
  end;
  for i := 0 to 9 do // PRANSKILL_ATENTION elas podem ser (10) ou (12)
  begin
    if (Pran.Skills[i].Index = 0) then
      Continue;
    SQLComp.SetQuery
      (format('INSERT INTO skills (owner_charid, slot, item, level, type) ' +
      'VALUES (%d, %d, %d, %d, %d)',
      [Pran.Iddb, i, Pran.Skills[i].Index, Pran.Skills[i].Level, 3]));
    SQLComp.Run(False);
   { Player.PlayerSQL.AddParameter2('powner_charid', Pran.Iddb);
    Player.PlayerSQL.AddParameter2('pslot', i);
    Player.PlayerSQL.AddParameter2('pitem', Pran.Skills[i].Index);
    Player.PlayerSQL.AddParameter2('plevel', Pran.Skills[i].Level);
    Player.PlayerSQL.AddParameter2('ptype', 3);
    Player.PlayerSQL.Run(False);                 }
  end;
  // é preciso salvar a pran no ato da criação
  // salvar > colocar nome > mover pra inventário > mandar o sendtoworld
  // 02/10/2020 11h51 - pausa
  //modificado com otimizações aqui 09/04/2021
  SQLComp.Destroy;
  Result := True;
end;
class function TFunctions.VerifyNameAlreadyExists(var Player: TPlayer;
  Name: String): Boolean;
var
  SQLComp: TQuery;
begin
  Result := False;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[VerifyNameAlreadyExists]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[VerifyNameAlreadyExists]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    SQLComp.SetQuery
      (format('SELECT id FROM prans WHERE name=%s', [QuotedStr(Name)]));
    SQLComp.Run();
    if (SQLComp.Query.RecordCount > 0) then
    begin
      Result := True;
    end;
  except
    Logger.Write('MySQL Error player PRAN name exists. ' +
      String(Player.Base.Character.Name), TlogType.Error);
  end;
  SQLComp.Destroy;
end;
{$ENDREGION}
{$REGION 'Character File Functions'}
{
  class function TFunctions.FindCharacter(characterName: string): Boolean;
  var
  local: string;
  begin
  if (IsLetter(characterName)) then
  local := DATABASE_PATH + 'Chars\' + LowerCase(characterName[1]) + '\' +
  Trim(characterName) + '.char'
  else
  local := DATABASE_PATH + 'Chars\etc\' + Trim(characterName) + '.char';
  if (FileExists(local)) then
  Result := True
  else
  Result := False;
  end;
}
class function TFunctions.GetCharacterAccount(characterName: string;
  out Account: string): Boolean;
var
  AccountID: Integer;
  SQLComp: TQuery;
begin
  Result := False;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GetCharacterAccount]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetCharacterAccount]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  SQLComp.SetQuery('SELECT id, owner_accid FROM characters WHERE name=:pname');
  SQLComp.AddParameter('pname', AnsiString(characterName));
  SQLComp.Run();
  if (SQLComp.Query.IsEmpty) then
  begin
    SQLComp.Destroy;
    Exit;
  end;
  AccountID := SQLComp.Query.FieldByName('owner_accid').AsInteger;
  SQLComp.SetQuery('SELECT username FROM accounts WHERE id=:pid');
  SQLComp.AddParameter('pid', AnsiString(IntToStr(AccountID)));
  SQLComp.Run();
  if (SQLComp.Query.IsEmpty) then
  begin
    SQLComp.Destroy;
    Exit;
  end;
  Account := SQLComp.Query.FieldByName('username').AsString;
  Result := True;
end;
class function TFunctions.GetCharacterNation(characterName: string;
  out Nation: TCitizenship): Boolean;
var
  Player: TPlayer;
  // Account: string;
  SQLComp: TQuery;
begin
  Result := False;
  ZeroMemory(@Player, sizeof(TPlayer));
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GetCharacterNation]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetCharacterNation]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    SQLComp.SetQuery
      ('SELECT characters.id as `characterId`, accounts.nation as `nation`' +
      ' FROM characters inner join accounts on accounts.id = characters.owner_accid WHERE characters.name= :pcharacter_name LIMIT 1 ');
    SQLComp.AddParameter2('pcharacter_name', characterName);
    SQLComp.Run();
    if not(SQLComp.Query.RecordCount > 0) then
    begin
      SQLComp.Destroy;
      Exit;
    end;
    Nation := TCitizenship(SQLComp.Query.FieldByName('nation')
      .AsInteger);
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on getting character account nation. msg[' +
        E.Message + ' : ' + E.GetBaseException.Message + '] characterName [' +
        String(characterName) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
  end;
  SQLComp.Destroy;
  Result := True;
end;
{
  class procedure TFunctions.SaveCharacterFile(const Player: TPlayer;
  characterName: string);
  var
  F: TextFile;
  local: string;
  begin
  if (IsLetter(characterName)) then
  begin
  if not DirectoryExists(DATABASE_PATH + 'Chars\' +
  LowerCase(characterName[1])) then
  forceDirectories(DATABASE_PATH + 'Chars\' + LowerCase(characterName[1]));
  local := DATABASE_PATH + 'Chars\' + LowerCase(characterName[1]) + '\' +
  Trim(characterName) + '.char';
  end
  else
  begin
  if not DirectoryExists(DATABASE_PATH + 'Chars\etc') then
  forceDirectories(DATABASE_PATH + 'Chars\etc');
  local := DATABASE_PATH + 'Chars\etc\' + Trim(characterName) + '.char';
  end;
  AssignFile(F, local);
  ReWrite(F);
  WriteLn(F, Player.Account.Header.Username);
  CloseFile(F);
  end;
}
{$ENDREGION}
{$REGION 'Guild File Functions'}
class procedure TFunctions.SaveGuilds(GuildX: Cardinal);
var
  i, m: Integer;
  Member: PPlayerFromGuild;
  Item: PItem;
  MySQLComp: TQuery;
begin
  MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);
  if not(MySQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SAVE_GUILDS]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SAVE_GUILDS]', TlogType.Error);
    Exit;
  end;
  for i := Low(Guilds) to High(Guilds) do
  begin
    if(GuildX > 0) then
    begin
      if not(GuildX = i) then
        continue;
    end;

    if (Guilds[i].Index > 0) then
    begin
      if(Guilds[i].TotalMembers > 128) then
        Guilds[i].TotalMembers := 128;
      MySQLComp.Query.Connection.StartTransaction;
      try
        MySQLComp.SetQuery('UPDATE guilds SET experience='+
        Guilds[i].Exp.ToString+
        ', level='+Guilds[i].Level.ToString+
        ', totalmembers='+Guilds[i].TotalMembers.ToString+
        ', bravurepoints='+Guilds[i].BravurePoints.ToString+',' +
          ' skillpoints='+Guilds[i].SkillPoints.ToString+
          ', promote='+Guilds[i].Promote.ToInteger.ToString+
          ', notice1="'+String(Guilds[i].Notices[0].Text)+'",' +
          ' notice2="'+String(Guilds[i].Notices[1].Text)+
          '", notice3="'+String(Guilds[i].Notices[2].Text)+
          '", site="'+String(Guilds[i].Site)+'", rank1='+
          Guilds[i].RanksConfig[0].ToString+',' +
          ' rank2='+
          Guilds[i].RanksConfig[1].ToString+', rank3='+
          Guilds[i].RanksConfig[2].ToString+', rank4='+
          Guilds[i].RanksConfig[3].ToString+', rank5='+
          Guilds[i].RanksConfig[4].ToString+',' +
          ' ally_leader='+Guilds[i].Ally.Leader.ToString+
          ', guild_ally1_index='+Guilds[i].Ally.Guilds[0].Index.ToString+',' +
          ' guild_ally1_name="'+String(Guilds[i].Ally.Guilds[0].Name)+'", guild_ally2_index='+Guilds[i].Ally.Guilds[1].Index.ToString+',' +
          ' guild_ally2_name="'+String(Guilds[i].Ally.Guilds[1].Name)+'", guild_ally3_index='+Guilds[i].Ally.Guilds[2].Index.ToString+',' +
          ' guild_ally3_name="'+String(Guilds[i].Ally.Guilds[2].Name)+'", guild_ally4_index='+Guilds[i].Ally.Guilds[3].Index.ToString+',' +
          ' guild_ally4_name="'+String(Guilds[i].Ally.Guilds[3].Name)+
          '", storage_gold='+
          Guilds[i].Chest.Gold.ToString+
          ', leader_char_index='+Guilds[i].GuildLeaderCharIndex.ToString+
          '' + ' WHERE id='+Guilds[i].Index.ToString+';');

        MySQLComp.Run(False);

        MySQLComp.Query.Connection.Commit;
      except
        on E: Exception do
        begin
          MySQLComp.Query.Connection.Rollback;
          Logger.Write('Não foi possivel salvar dados da guild: ' +
            String(Guilds[i].Name) + ' [Erro MySQL] ' + E.Message,
            TlogType.Error);
        end;
      end;
        { Servers[0].cSQL.AddParameter2('pexperience', Guilds[i].Exp);
          Servers[0].cSQL.AddParameter2('plevel', Guilds[i].Level);
          Servers[0].cSQL.AddParameter2('ptotalmembers', Guilds[i].TotalMembers);
          Servers[0].cSQL.AddParameter2('pbravurepointes',
          Guilds[i].BravurePoints);
          Servers[0].cSQL.AddParameter2('pskillpoints', Guilds[i].SkillPoints);
          Servers[0].cSQL.AddParameter2('ppromote', Guilds[i].Promote.ToInteger);
          Servers[0].cSQL.AddParameter2('pnotice1',
          String(Guilds[i].Notices[0].Text));
          Servers[0].cSQL.AddParameter2('pnotice2',
          String(Guilds[i].Notices[1].Text));
          Servers[0].cSQL.AddParameter2('pnotice3',
          String(Guilds[i].Notices[2].Text));
          Servers[0].cSQL.AddParameter2('psite', String(Guilds[i].Site));
          Servers[0].cSQL.AddParameter2('prank1', Guilds[i].RanksConfig[0]);
          Servers[0].cSQL.AddParameter2('prank2', Guilds[i].RanksConfig[1]);
          Servers[0].cSQL.AddParameter2('prank3', Guilds[i].RanksConfig[2]);
          Servers[0].cSQL.AddParameter2('prank4', Guilds[i].RanksConfig[3]);
          Servers[0].cSQL.AddParameter2('prank5', Guilds[i].RanksConfig[4]);
          Servers[0].cSQL.AddParameter2('pally_leader', Guilds[i].Ally.Leader);
          Servers[0].cSQL.AddParameter2('pguild_ally1_index',
          Guilds[i].Ally.Guilds[0].Index);
          Servers[0].cSQL.AddParameter2('pguild_ally1_name',
          String(Guilds[i].Ally.Guilds[0].Name));
          Servers[0].cSQL.AddParameter2('pguild_ally2_index',
          Guilds[i].Ally.Guilds[1].Index);
          Servers[0].cSQL.AddParameter2('pguild_ally2_name',
          String(Guilds[i].Ally.Guilds[1].Name));
          Servers[0].cSQL.AddParameter2('pguild_ally3_index',
          Guilds[i].Ally.Guilds[2].Index);
          Servers[0].cSQL.AddParameter2('pguild_ally3_name',
          String(Guilds[i].Ally.Guilds[2].Name));
          Servers[0].cSQL.AddParameter2('pguild_ally4_index',
          Guilds[i].Ally.Guilds[3].Index);
          Servers[0].cSQL.AddParameter2('pguild_ally4_name',
          String(Guilds[i].Ally.Guilds[3].Name));
          Servers[0].cSQL.AddParameter2('pstorage_gold', Guilds[i].Chest.Gold);
          Servers[0].cSQL.AddParameter2('pid', Guilds[i].Index); }


        MySQLComp.Query.Connection.StartTransaction;
        try
          { Guild Members }
          MySQLComp.SetQuery
            ('DELETE FROM guilds_players WHERE guild_index='+Guilds[i].Index.ToString+';');

          // MySQLComp.AddParameter2('pguild_index', Guilds[i].Index);
          //MySQLComp.Query.Connection.StartTransaction;
          MySQLComp.Run(False);
          //MySQLComp.Query.Connection.Commit;
          for m := 0 to 127 do
          begin
            if (Guilds[i].Members[m].CharIndex = 0) then
              Continue;
            Member := @Guilds[i].Members[m];
            MySQLComp.SetQuery
              ('INSERT INTO guilds_players (guild_index, char_index, name, player_rank,'
              + ' classinfo, level, logged, last_login) VALUES ('+
              Guilds[i].Index.ToString+', '+Member.CharIndex.ToString+
              ', "'+String(Member.Name)+'", '+Member.Rank.ToString+','
              + ' '+Member.ClassInfo.ToString+', '+
              Member.Level.ToString+', '+Member.Logged.ToInteger.ToString+
              ', '+Member.LastLogin.ToString+')');
            { Servers[0].cSQL.AddParameter2('pguild_index', Guilds[i].Index);
              Servers[0].cSQL.AddParameter2('pchar_index', Member.CharIndex);
              Servers[0].cSQL.AddParameter2('pname', String(Member.Name));
              Servers[0].cSQL.AddParameter2('pplayer_rank', Member.Rank);
              Servers[0].cSQL.AddParameter2('pclassinfo', Member.ClassInfo);
              Servers[0].cSQL.AddParameter2('plevel', Member.Level);
              Servers[0].cSQL.AddParameter2('plogged', Member.Logged.ToInteger);
              Servers[0].cSQL.AddParameter2('plast_login', Member.LastLogin); }
            MySQLComp.Run(False);
          end;

          MySQLComp.Query.Connection.Commit;
        except
          on E: Exception do
          begin
            MySQLComp.Query.Connection.Rollback;
            Logger.Write('Não foi possivel salvar dados da guild: ' +
              String(Guilds[i].Name) + ' [Erro MySQL] ' + E.Message,
              TlogType.Error);
          end;
        end;

        MySQLComp.Query.Connection.StartTransaction;
        try
          { Guild Items }
          MySQLComp.SetQuery
            ('DELETE FROM items WHERE slot_type=3 AND owner_id='+
            Guilds[i].Index.ToString+';');
          // MySQLComp.AddParameter2('pslot_type', 3);
          // MySQLComp.AddParameter2('powner_id', Guilds[i].Index);
          //MySQLComp.Query.Connection.StartTransaction;
          MySQLComp.Run(False);
          //MySQLComp.Query.Connection.Commit;
          for m := 0 to 49 do
          begin
            if (Guilds[i].Chest.Items[m].Index = 0) then
              Continue;
            Item := @Guilds[i].Chest.Items[m];
            MySQLComp.SetQuery
              ('INSERT INTO items (slot_type, owner_id, slot, item_id, '
              + 'app, effect1_index, effect1_value, effect2_index, effect2_value,'
              + ' effect3_index, effect3_value, min, max, refine, time) VALUES '
              + '(3, '+Guilds[i].Index.ToString+', '+
              m.ToString+', '+Item.Index.ToString+', ' + Item.APP.ToString+
              ', '+Item.Effects.Index[0].ToString+', '+
              Item.Effects.Value[0].ToString+', '+
              Item.Effects.Index[1].ToString+', '+
              Item.Effects.Value[1].ToString+',' +
              ' '+Item.Effects.Index[2].ToString
              +', '+Item.Effects.Value[2].ToString+
              ', '+Item.MIN.ToString+', '+Item.MAX.ToString+', '+Item.Refi.ToString+
              ', '+Item.Time.ToString+')');
            { Servers[0].cSQL.AddParameter2('pslot_type', 3);
              Servers[0].cSQL.AddParameter2('powner_id', Guilds[i].Index);
              Servers[0].cSQL.AddParameter2('pslot', m);
              Servers[0].cSQL.AddParameter2('pitem_id', Item.Index);
              Servers[0].cSQL.AddParameter2('papp', Item.APP);
              Servers[0].cSQL.AddParameter2('peffect1_index',
              Item.Effects.Index[0]);
              Servers[0].cSQL.AddParameter2('peffect1_value',
              Item.Effects.Value[0]);
              Servers[0].cSQL.AddParameter2('peffect2_index',
              Item.Effects.Index[1]);
              Servers[0].cSQL.AddParameter2('peffect2_value',
              Item.Effects.Value[1]);
              Servers[0].cSQL.AddParameter2('peffect3_index',
              Item.Effects.Index[2]);
              Servers[0].cSQL.AddParameter2('peffect3_value',
              Item.Effects.Value[2]);
              Servers[0].cSQL.AddParameter2('pmin', Item.MIN);
              Servers[0].cSQL.AddParameter2('pmax', Item.MAX);
              Servers[0].cSQL.AddParameter2('prefine', Item.Refi);
              Servers[0].cSQL.AddParameter2('ptime', Item.Time); }

            MySQLComp.Run(False);

          end;

          MySQLComp.Query.Connection.Commit;
        except
          on E: Exception do
          begin
            MySQLComp.Query.Connection.Rollback;
            Logger.Write('Não foi possivel salvar dados da guild: ' +
              String(Guilds[i].Name) + ' [Erro MySQL] ' + E.Message,
              TlogType.Error);
          end;
        end;

    end;
  end;
  MySQLComp.Destroy;
  { if not(DirectoryExists(DATABASE_PATH + 'Guilds')) then
    forceDirectories(DATABASE_PATH + 'Guilds');
    for i := Low(Guilds) to High(Guilds) do
    if Guilds[i].Index > 0 then
    begin
    AssignFile(F, DATABASE_PATH + 'Guilds\' + i.ToString + '.guild');
    ReWrite(F);
    Write(F, Guilds[i]);
    CloseFile(F);
    end
    else if FileExists(DATABASE_PATH + 'Guilds\' + i.ToString + '.guild') then
    DeleteFile(PWIDECHAR(DATABASE_PATH + 'Guilds\' + i.ToString + '.guild')); }
end;
class function TFunctions.SearchGuildByName(Name: String): PGuild;
var
  i: Integer;
begin
  Result := nil;
  for I := Low(Guilds) to High(Guilds) do
  begin
    if(Guilds[i].Index = 0) then
      Continue;
    if(String(Guilds[i].Name).ToUpper = Name.ToUpper) then
      Result := @Guilds[i];
  end;
end;
{$ENDREGION}
{$REGION 'Account File Functions'}
class procedure TFunctions.SaveAccountFile(const Account: TAccountFile;
  AccountName: string; AccountNamePure: String);
var
  F: File of TAccountFile;
  FileName: string;
begin
  try
    if not(DirectoryExists(DATABASE_PATH + 'ACCS\' + AccountNamePure))
    then
      forceDirectories(DATABASE_PATH + 'ACCS\' + AccountNamePure);
    FileName := DATABASE_PATH + 'ACCS\' + AccountNamePure + '\' +
      AccountName + '.acc';
    AssignFile(F, FileName);
    try
      ReWrite(F);
      Write(F, Account);
    finally
      CloseFile(F);
    end;
  except
    on E: Exception do
    begin
      Logger.Write('Error at TFunctions.SaveAccountFile ' +
        E.Message + ' t: ' + DateTimeToStr(Now), TlogType.Error)
    end;
  end;
end;
class function TFunctions.GetAccountsBackup(var Player: TPlayer; TypeOf: Integer; AccountName: string): Boolean;
type
  TAccountsBackup = packed record
  xfileName: String;
  xAcc: TAccountFile;
end;
var
  f: TSearchRec;
  Ret, j, quest_cnt, xCnt: Integer;
  TempNome: String;
  xAccount: TAccountFile;
  xF: File of TAccountFile;
  xAccs: Array of TAccountsBackup;
  I: Byte;
  Packet: TReceivePlayerAccountFiles;
  MySQLComp: TQuery;
begin
  if(TypeOf = 1) then
  begin
    MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
      AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
      AnsiString(MYSQL_DATABASE), False);
    if not(MySQLComp.Query.Connection.Connected) then
    begin
      Logger.Write('Falha de conexão individual com mysql.[Functions::GetAccountsBackup]',
        TlogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[Functions::GetAccountsBackup]', TlogType.Error);
      Exit;
    end;

    MySQLComp.SetQuery('SELECT a.username from characters c inner join accounts a on a.id = c.owner_accid'+
      ' WHERE c.name = '+ QuotedStr(AccountName));
    MySQLComp.Run();

    if(MySQLComp.Query.RecordCount > 0) then
    begin
      AccountName := MySQLComp.Query.fieldByName('username').AsString;
    end;
  end;

  if not(DirectoryExists(DATABASE_PATH + 'ACCS\' +
      AccountName)) then
  begin
    Player.SendMessageToPainel('Não existem arquivos de backup para esse login.',
      MB_ICONWARNING, 0);
    Exit;
  end;

  try
    Ret := FindFirst(DATABASE_PATH + 'ACCS\' +
      AccountName + '\*.acc', faAnyFile, f);

    if(Ret <> 0) then
    begin
      Player.SendMessageToPainel('Não existem arquivos de backup para esse login.',
        MB_ICONWARNING, 0);
      Exit;
    end;

    xCnt := 1;
    while Ret = 0 do
    begin
      TempNome := ReplaceStr(f.Name, '.acc', '');

      ZeroMemory(@xAccount, sizeof(xAccount));

      AssignFile(xF, DATABASE_PATH + 'ACCS\' + AccountName + '\' + f.Name);
      Reset(xF);
      Read(xF, xAccount);
      CloseFile(xF);

      SetLength(xAccs, xCnt);

      xAccs[high(xAccs)].xAcc := xAccount;
      xAccs[high(xAccs)].xfileName := TempNome;
      Inc(xCnt);
      Ret := FindNext(f);
    end;

    for I := Low(xAccs) to High(xAccs) do
    begin
      ZeroMemory(@Packet, sizeof(Packet));

      Packet.Header.Size := sizeof(Packet);
      Packet.Header.code := $3223;
      Packet.Header.index := $7535;
      System.AnsiStrings.StrPLCopy(Packet.FileName,
        xAccs[i].xFileName, 255);
      Packet.AccountBackup := xAccs[i].xAcc;

      Player.SendPacket(Packet, Packet.Header.Size);
      Sleep(20);
    end;
  except
    on E: Exception do
    begin
      Logger.Write('Error at TFunctions.GetAccountsBackup ' +
        E.Message + ' t: ' + DateTimeToStr(Now), TlogType.Error)
    end;
  end;

end;

class procedure TFunctions.ManageAccountsBackupCount(var Player: TPlayer; AccountName: string);
var
  fileDate: Integer;
  fileDateTime: TDateTIme;
  f: TSearchRec;
  Ret, xCnt: Integer;
begin
  try
    Ret := FindFirst(DATABASE_PATH + 'ACCS\' +
      AccountName + '\*.acc', faAnyFile, f);

    if(Ret <> 0) then
    begin
      Exit;
    end;

    xCnt := 0;
    while Ret = 0 do
    begin
      fileDate := f.Time;
      fileDateTime := FileDateToDateTime(fileDate);
      if(DaysBetween(fileDateTime, Now) >= DAYS_BACKUP_ACCOUNT_DELETE) then
      begin //deletar arquivo de backup antigo para não lotar memoria
        DeleteFile(PChar(DATABASE_PATH + 'ACCS\' +
          AccountName + '\' + f.Name));
        Inc(xCnt);
      end;

      Ret := FindNext(f);
    end;
  except
    on E: Exception do
    begin
      Logger.Write('Error at TFunctions.ManageAccountsBackupCount ' +
        E.Message + ' t: ' + DateTimeToStr(Now), TlogType.Error)
    end;
  end;
end;

class function TFunctions.FindAccount(AccountName: string): Boolean;
begin
  try
  Result := FileExists(DATABASE_PATH + 'ACCS\' + AccountName + '\'
    + AccountName + '.acc');
  except
    on E: Exception do
    begin
      Logger.Write('Error at TFunctions.FindAccount ' +
        E.Message + ' t: ' + DateTimeToStr(Now), TlogType.Error)
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Trade Functions'}
class function TFunctions.ExecuteTrade(var Player: TPlayer;
  var OtherPlayer: TPlayer): Boolean;
var
  i: Integer;
  Packet: TSignalData;
begin
  Result := False;
  ZeroMemory(@Packet, sizeof(TSignalData));
  Packet.Header.Size := sizeof(TSignalData);
  Packet.Header.Code := $318;
  Packet.Header.Index := Player.Base.ClientId;
  Player.SendPacket(Packet, Packet.Header.Size);
  Packet.Header.Index := OtherPlayer.Base.ClientId;
  OtherPlayer.SendPacket(Packet, Packet.Header.Size);
  for i := 0 to 9 do
  begin
    if (Player.Character.Trade.Itens[i].Index > 0) then
    begin
      TItemFunctions.PutItem(OtherPlayer, Player.Character.Base.Inventory
        [Player.Character.Trade.Slots[i]]);
      TItemFunctions.RemoveItem(Player, INV_TYPE,
        Player.Character.Trade.Slots[i]);
    end;
    if (Player.Character.Trade.Itens[i].Index > 0) then
    begin
      TItemFunctions.PutItem(Player, OtherPlayer.Character.Base.Inventory
        [OtherPlayer.Character.Trade.Slots[i]]);
      TItemFunctions.RemoveItem(OtherPlayer, INV_TYPE,
        OtherPlayer.Character.Trade.Slots[i]);
    end;
  end;
  if (Player.Character.Trade.Gold > 0) then
  begin
    if (Player.Character.Base.Gold >= Player.Character.Trade.Gold) then
    begin
      OtherPlayer.AddGold(Player.Character.Trade.Gold);
      Player.DecGold(Player.Character.Trade.Gold);
    end
    else
      Exit;
  end;
  if (OtherPlayer.Character.Trade.Gold > 0) then
  begin
    if (OtherPlayer.Character.Base.Gold >= OtherPlayer.Character.Trade.Gold)
    then
    begin
      Player.AddGold(OtherPlayer.Character.Trade.Gold);
      OtherPlayer.DecGold(OtherPlayer.Character.Trade.Gold);
    end
    else
      Exit;
  end;
  ZeroMemory(@OtherPlayer.Character.Trade, sizeof(TTrade));
  ZeroMemory(@Player.Character.Trade, sizeof(TTrade));
  Result := True;
end;
class function TFunctions.ExecuteTrade(var Player: TPlayer;
  OtherPlayer: PPlayer): Boolean;
var
  i: BYTE;
begin
  Result := False;
  for i := 0 to 9 do
  begin
    if (Player.Character.Trade.Itens[i].Index > 0) then
    begin
      TItemFunctions.PutItem(OtherPlayer^, Player.Character.Base.Inventory
        [Player.Character.Trade.Slots[i]]);
      TItemFunctions.RemoveItem(Player, INV_TYPE,
        Player.Character.Trade.Slots[i]);
    end;
    if (OtherPlayer.Character.Trade.Itens[i].Index > 0) then
    begin
      TItemFunctions.PutItem(Player, OtherPlayer.Character.Base.Inventory
        [OtherPlayer.Character.Trade.Slots[i]]);
      TItemFunctions.RemoveItem(OtherPlayer^, INV_TYPE,
        OtherPlayer.Character.Trade.Slots[i]);
    end;
  end;
  if (Player.Character.Trade.Gold > 0) then
  begin
    if (Player.Character.Base.Gold >= Player.Character.Trade.Gold) then
    begin
      OtherPlayer.AddGold(Player.Character.Trade.Gold);
      Player.DecGold(Player.Character.Trade.Gold);
    end
    else
      Exit;
  end;
  if (OtherPlayer.Character.Trade.Gold > 0) then
  begin
    if (OtherPlayer.Character.Base.Gold >= OtherPlayer.Character.Trade.Gold)
    then
    begin
      Player.AddGold(OtherPlayer.Character.Trade.Gold);
      OtherPlayer.DecGold(OtherPlayer.Character.Trade.Gold);
    end
    else
      Exit;
  end;
  ZeroMemory(@OtherPlayer.Character.Trade, sizeof(TTrade));
  ZeroMemory(@Player.Character.Trade, sizeof(TTrade));
  Result := True;
end;
{$ENDREGION}
{$REGION 'CPU Usage Functions'}
class function TFunctions.GetCPUUsage: Single;
begin
  Result := GetProcessCpuUsagePct(GetCurrentProcessID);
end;
class function TFunctions.GetMemoryUsed;
var
  st: TMemoryManagerState;
  sb: TSmallBlockTypeState;
begin
  GetMemoryManagerState(st);
  result :=  st.TotalAllocatedMediumBlockSize
           + st.TotalAllocatedLargeBlockSize;
  for sb in st.SmallBlockTypeStates do begin
    result := result + sb.UseableBlockSize * sb.AllocatedBlockCount;
  end;
end;
{$ENDREGION}
{$REGION 'File Functions'}
class function TFunctions.GetFileSize(const FileName: string): UInt64;
var
  SearchRec: TSearchRec;
begin
  try
    if FindFirst(ExpandFileName(FileName), faAnyFile, SearchRec) = 0 then
      Result := SearchRec.Size
    else
      Result := 0;
  finally
    SysUtils.FindClose(SearchRec);
  end;
end;
class function TFunctions.LoadPacket(PacketName: string;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  FSize: Integer;
  F: TFileStream;
  FName: string;
begin
  Result := False;
  FName := GetCurrentDir + '\Packets\' + PacketName + '.packet';
  if not(FileExists(FName)) then
  begin
    Exit;
  end;
  F := TFileStream.Create(FName, fmOpenRead);
  FSize := F.Size;
  try
    F.Position := 0;
    F.ReadBuffer(Buffer[0], FSize);
    F.Free;
  except
    F.Free;
    Exit;
  end;
  Result := True;
end;
class function TFunctions.LoadBasicCharacter(FName: string;
  var Character: TCharacterDB): Boolean;
var
  F: File of TBasicCharacter;
  BasicCharacter: TBasicCharacter;
begin
  Result := False;
  ZeroMemory(@BasicCharacter, sizeof(TBasicCharacter));
  if not(FileExists(DATABASE_PATH + 'BaseAccs\' + FName + '.acc')) then
    Self.CreateBasicCharacter(FName, AnsiIndexStr(FName,
      ['Guerreiro', 'Templaria', 'Atirador', 'Pistoleira', 'Feiticeiro',
      'Cleriga']) + 1);
  try
    AssignFile(F, DATABASE_PATH + 'BaseAccs\' + FName + '.acc');
    Reset(F);
    Read(F, BasicCharacter);
    CloseFile(F);
    Move(BasicCharacter, Character, sizeof(TBasicCharacter));
  except
    CloseFile(F);
  end;
end;
class function TFunctions.SaveBasicCharacter(FName: string;
  const Character: TCharacterDB): Boolean;
var
  F: File of TBasicCharacter;
  BasicCharacter: TBasicCharacter;
begin
  Result := False;
  if not(DirectoryExists(DATABASE_PATH + 'BaseAccs\')) then
    forceDirectories(DATABASE_PATH + 'BaseAccs\');
  try
    Move(Character, BasicCharacter, sizeof(TBasicCharacter));
    AssignFile(F, DATABASE_PATH + 'BaseAccs\' + FName + '.acc');
    ReWrite(F);
    Write(F, BasicCharacter);
    CloseFile(F);
  except
    CloseFile(F);
  end;
end;
class function TFunctions.CreateBasicCharacter(FName: string;
  Classe: Integer): Boolean;
var
  F: TCharacterDB;
  i: Integer;
begin
  Result := False;
  if (Classe < 1) or (Classe > 6) then
    Exit;
  ZeroMemory(@F, sizeof(TCharacterDB));
  F.SpeedMove := 40;
  F.Base.CurrentScore.Sizes.Altura := $07;
  F.Base.CurrentScore.Sizes.Tronco := $77;
  F.Base.CurrentScore.Sizes.Perna := $77;
  F.Base.CurrentScore.Sizes.Corpo := $00;
  F.Skills.Basics[0].Level := 1;
  F.Skills.Basics[1].Level := 1;
  F.Skills.Basics[2].Level := 1;
  F.Skills.Basics[3].Level := 1;
  F.Skills.Others[0].Level := 1;
  F.Base.Level := 1;
  for i := 0 to 5 do
    F.Skills.Basics[i].Index := TSkillFunctions.GetSkillIndex(Classe, i + 1, 1);
  for i := 0 to (Length(F.Skills.Others) - 1) do
    F.Skills.Others[i].Index := TSkillFunctions.GetSkillIndex(Classe, i + 7, 1);
  case Classe of
{$REGION 'Warrior'}
    1:
      begin
        F.Base.CurrentScore.str := 15;
        F.Base.CurrentScore.Int := 05;
        F.Base.CurrentScore.agility := 09;
        F.Base.CurrentScore.Cons := 16;
        F.Base.Equip[3].Index := 1719;
        F.Base.Equip[3].MIN := 100;
        F.Base.Equip[3].MAX := 100;
        F.Base.Equip[3].APP := 1719;
        F.Base.Equip[5].Index := 1779;
        F.Base.Equip[5].MIN := 100;
        F.Base.Equip[5].MAX := 100;
        F.Base.Equip[5].APP := 1779;
        F.Base.Equip[6].Index := 1069;
        F.Base.Equip[6].MIN := 160;
        F.Base.Equip[6].MAX := 160;
        F.Base.Equip[6].APP := 1069;
        F.Base.ItemBar[3] := TSkillFunctions.GetSkillIndexOnBar
          (F.Skills.Basics[3].Index);
        F.Base.ClassInfo := 1;
      end;
{$ENDREGION}
{$REGION 'Templaria'}
    2:
      begin
        F.Base.CurrentScore.str := 14;
        F.Base.CurrentScore.Int := 06;
        F.Base.CurrentScore.agility := 10;
        F.Base.CurrentScore.Cons := 14;
        F.Base.Equip[3].Index := 1839;
        F.Base.Equip[3].MIN := 120;
        F.Base.Equip[3].MAX := 120;
        F.Base.Equip[3].APP := 1839;
        F.Base.Equip[5].Index := 1899;
        F.Base.Equip[5].MIN := 120;
        F.Base.Equip[5].MAX := 120;
        F.Base.Equip[5].APP := 1899;
        F.Base.Equip[6].Index := 1034;
        F.Base.Equip[6].MIN := 140;
        F.Base.Equip[6].MAX := 140;
        F.Base.Equip[6].APP := 1034;
        F.Base.Equip[7].Index := 1309;
        F.Base.Equip[7].MIN := 120;
        F.Base.Equip[7].MAX := 120;
        F.Base.Equip[7].APP := 1309;
        F.Base.ClassInfo := 11;
      end;
{$ENDREGION}
{$REGION 'Atirador'}
    3:
      begin
        F.Base.CurrentScore.str := 08;
        F.Base.CurrentScore.Int := 09;
        F.Base.CurrentScore.agility := 16;
        F.Base.CurrentScore.Cons := 12;
        F.Base.CurrentScore.Luck := 05;
        F.Base.Equip[3].Index := 1959;
        F.Base.Equip[3].MIN := 80;
        F.Base.Equip[3].MAX := 80;
        F.Base.Equip[3].APP := 1959;
        F.Base.Equip[5].Index := 2019;
        F.Base.Equip[5].MIN := 80;
        F.Base.Equip[5].MAX := 80;
        F.Base.Equip[5].APP := 2019;
        F.Base.Equip[6].Index := 1209;
        F.Base.Equip[6].MIN := 160;
        F.Base.Equip[6].MAX := 160;
        F.Base.Equip[6].APP := 1209;
        F.Base.ClassInfo := 21;
      end;
{$ENDREGION}
{$REGION 'Pistoleira'}
    4:
      begin
        F.Base.CurrentScore.str := 08;
        F.Base.CurrentScore.Int := 10;
        F.Base.CurrentScore.agility := 14;
        F.Base.CurrentScore.Cons := 12;
        F.Base.CurrentScore.Luck := 06;
        F.Base.Equip[3].Index := 2079;
        F.Base.Equip[3].MIN := 80;
        F.Base.Equip[3].MAX := 80;
        F.Base.Equip[3].APP := 2079;
        F.Base.Equip[5].Index := 2139;
        F.Base.Equip[5].MIN := 80;
        F.Base.Equip[5].MAX := 80;
        F.Base.Equip[5].APP := 2139;
        F.Base.Equip[6].Index := 1174;
        F.Base.Equip[6].MIN := 140;
        F.Base.Equip[6].MAX := 140;
        F.Base.Equip[6].APP := 1174;
        F.Base.ClassInfo := 31;
      end;
{$ENDREGION}
{$REGION 'Feiticeiro'}
    5:
      begin
        F.Base.CurrentScore.str := 07;
        F.Base.CurrentScore.Int := 16;
        F.Base.CurrentScore.agility := 09;
        F.Base.CurrentScore.Cons := 08;
        F.Base.CurrentScore.Luck := 10;
        F.Base.Equip[3].Index := 2199;
        F.Base.Equip[3].MIN := 60;
        F.Base.Equip[3].MAX := 60;
        F.Base.Equip[3].APP := 2199;
        F.Base.Equip[5].Index := 2259;
        F.Base.Equip[5].MIN := 60;
        F.Base.Equip[5].MAX := 60;
        F.Base.Equip[5].APP := 2259;
        F.Base.Equip[6].Index := 1279;
        F.Base.Equip[6].MIN := 160;
        F.Base.Equip[6].MAX := 160;
        F.Base.Equip[6].APP := 1279;
        F.Base.ClassInfo := 41;
      end;
{$ENDREGION}
{$REGION 'Clériga'}
    6:
      begin
        F.Base.CurrentScore.str := 07;
        F.Base.CurrentScore.Int := 15;
        F.Base.CurrentScore.agility := 10;
        F.Base.CurrentScore.Cons := 09;
        F.Base.CurrentScore.Luck := 09;
        F.Base.Equip[3].Index := 2319;
        F.Base.Equip[3].MIN := 60;
        F.Base.Equip[3].MAX := 60;
        F.Base.Equip[3].APP := 2319;
        F.Base.Equip[5].Index := 2379;
        F.Base.Equip[5].MIN := 60;
        F.Base.Equip[5].MAX := 60;
        F.Base.Equip[5].APP := 2379;
        F.Base.Equip[6].Index := 1244;
        F.Base.Equip[6].MIN := 140;
        F.Base.Equip[6].MAX := 140;
        F.Base.Equip[6].APP := 1244;
        F.Base.ItemBar[3] := TSkillFunctions.GetSkillIndexOnBar
          (F.Skills.Basics[3].Index);
        F.Base.ClassInfo := 51;
      end;
{$ENDREGION}
  end;
  F.Base.ItemBar[0] := TSkillFunctions.GetSkillIndexOnBar
    (F.Skills.Basics[0].Index);
  F.Base.ItemBar[1] := TSkillFunctions.GetSkillIndexOnBar
    (F.Skills.Others[0].Index);
  F.Base.ItemBar[2] := TSkillFunctions.GetSkillIndexOnBar
    (F.Skills.Basics[2].Index);
  F.Base.ItemBar[7] := TSkillFunctions.GetSkillIndexOnBar
    (F.Skills.Basics[1].Index);
  F.Base.Inventory[0].Index := 4350;
  F.Base.Inventory[0].Refi := 10;
  F.Base.Inventory[1].Index := 4390;
  F.Base.Inventory[1].Refi := 10;
  F.Base.Inventory[2].Index := 10044;
  F.Base.Inventory[2].Refi := 1;
  F.Base.Inventory[3].Index := 5284;
  F.Base.Inventory[3].Refi := 1;
  Result := Self.SaveBasicCharacter(FName, F);
end;
class function TFunctions.GetFilesCount(Diretorio, Pesquisa: string): Integer;
var
  F: TSearchRec;
  r: Integer;
begin
  Diretorio := Trim(Diretorio);
  Result := 0;
  if Diretorio[Length(Diretorio)] <> '\' then
    Diretorio := Diretorio + '\';
  if not DirectoryExists(Diretorio) then
    Exit;
  r := FindFirst(Diretorio + Pesquisa, faAnyFile, F);
  while (r = 0) do
  begin
    if (F.Name = '.') or (F.Name = '..') then
      Continue;
    Inc(Result);
    r := FindNext(F);
  end;
end;
{
  class function TFunctions.IncAccountsCount: Cardinal;
  var
  F: File of DWORD;
  FName: string;
  begin
  if not(DirectoryExists(DATABASE_PATH + 'ACCS')) then
  forceDirectories(DATABASE_PATH + 'ACCS');
  Result := 0;
  FName := DATABASE_PATH + 'ACCS\LastIndex.t3c';
  AssignFile(F, FName);
  if (FileExists(FName)) then
  begin
  Reset(F);
  Read(F, Result);
  CloseFile(F);
  end;
  Inc(Result);
  ReWrite(F);
  Write(F, Result);
  CloseFile(F);
  end; }
class function TFunctions.IncCharactersCount(SelfPlayer: PPlayer): Cardinal;
var
  CurrentCnt: Int64;
  SQLComp: TQuery;
begin
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[IncCharactersCount]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[IncCharactersCount]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    //SelfPlayer^.PlayerSQL.Query.Connection.StartTransaction;
    SQLComp.SetQuery
      ('SELECT character_count FROM server_info WHERE server_id = 1');
    // Servers[0].cSQL.AddParameter('pserver_id', AnsiString(IntToStr(1)));
    SQLComp.Run;
    CurrentCnt := SQLComp.Query.FieldByName('character_count')
      .AsLargeInt;
    Inc(CurrentCnt);
    SQLComp.SetQuery
      (format('UPDATE server_info SET character_count=%d WHERE ' +
      'server_id=1', [CurrentCnt]));
    { Servers[0].cSQL.AddParameter('pcharacter_count',
      AnsiString(IntToStr(CurrentCnt)));
      Servers[0].cSQL.AddParameter('pserver_id', AnsiString(IntToStr(1))); }
    SQLComp.Run(False);
   // SelfPlayer^.PlayerSQL.MySQL.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('Error at TFunctions.DecCharacterCount MySQL ' + E.Message,
        TlogType.Error);
    end;
  end;
  SQLComp.Destroy;
  Result := CurrentCnt;
end;
class function TFunctions.DecCharactersCount(SelfPlayer: PPlayer): Cardinal;
var
  CurrentCnt: Int64;
  SQLComp: TQuery;
begin
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[DecCharactersCount]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[DecCharactersCount]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    //SelfPlayer^.Query.Connection.StartTransaction;
    SQLComp.SetQuery
      ('SELECT character_count FROM server_info WHERE server_id = 1');
    // Servers[0].cSQL.AddParameter('pserver_id', AnsiString(IntToStr(1)));
    SQLComp.Run;
    CurrentCnt := SQLComp.Query.FieldByName('character_count')
      .AsLargeInt;
    Dec(CurrentCnt);
    SQLComp.SetQuery
      (format('UPDATE server_info SET character_count=%d WHERE ' +
      'server_id=1', [CurrentCnt]));
    { Servers[0].cSQL.AddParameter('pcharacter_count',
      AnsiString(IntToStr(CurrentCnt)));
      Servers[0].cSQL.AddParameter('pserver_id', AnsiString(IntToStr(1))); }
    SQLComp.Run(False);
    //SelfPlayer^.PlayerSQL.MySQL.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('Error at TFunctions.DecCharacterCount MySQL ' + E.Message,
        TlogType.Error);
    end;
  end;
  SQLComp.Destroy;
  Result := CurrentCnt;
end;
{$ENDREGION}
{$REGION 'EncDec Files'}
class function TFunctions.EncDecSL(var Buffer: ARRAY OF BYTE;
  Encrypt: Boolean): Boolean;
var
  sign, j: Integer;
  par: Boolean;
begin
  Result := False;
  if (Length(Buffer) mod 2) = 0 then
    par := True
  else
    par := False;
  j := 0;
  if (Encrypt) then
    sign := -1
  else
    sign := 1;
  while j < Length(Buffer) - 1 do
  begin
    Buffer[j] := Buffer[j] - sign * (j mod 5);
    Inc(j);
    Buffer[j] := Buffer[j] - sign * (j mod 5);
    Inc(j);
    if not par then
    begin
      Buffer[j] := Buffer[j] - sign * (j mod 5);
      Inc(j);
    end;
    Result := True;
  end;
end;
class function TFunctions.EncDecSL(Buffer: Pointer; Size: UInt64;
  Encrypt: Boolean): Boolean;
var
  sign, j: Integer;
  par: Boolean;
begin
  Result := False;
  if (Size mod 2) = 0 then
    par := True
  else
    par := False;
  j := 0;
  if (Encrypt) then
    sign := -1
  else
    sign := 1;
  while (j < (Size - 1)) do
  begin
    PBYTE(Integer(Buffer) + j)^ := PBYTE(Integer(Buffer) + j)^ - sign *
      (j mod 5);
    Inc(j);
    PBYTE(Integer(Buffer) + j)^ := PBYTE(Integer(Buffer) + j)^ - sign *
      (j mod 5);
    Inc(j);
    if not par then
    begin
      PBYTE(Integer(Buffer) + j)^ := PBYTE(Integer(Buffer) + j)^ - sign *
        (j mod 5);
      Inc(j);
    end;
    Result := True;
  end;
end;
{$ENDREGION}
{$REGION 'Load Functions'}
class function TFunctions.LoadSL(FileName: string): Boolean;
  function ReadFile(FName: string; var SL: TServerList): Boolean;
  var
    Buffer: ARRAY OF BYTE;
    F: TFileStream;
    // F2: TFileStream;
  begin
    Result := False;
    if (FileExists(FName)) then
    begin
      F := TFileStream.Create(FName, fmOpenRead);
      SetLength(Buffer, F.Size);
      F.ReadBuffer(Buffer[0], F.Size);
      if (Self.EncDecSL(Buffer, False)) then
      begin
        { F2 := TFileStream.Create(GetCurrentDir + '\SL_dcr.bin', fmCreate);
          F2.Write(Buffer[0], F.Size);
          F2.Free; }
        Move(Buffer[0], SL[0], F.Size);
        Result := True;
      end;
      F.Free;
    end;
  end;
var
  FSize: UInt64;
  Len: DWORD;
begin
  Result := False;
  if not(FileExists(FileName)) then
    Exit;
  FSize := Self.GetFileSize(FileName);
  Len := Trunc(FSize / 72);
  SetLength(ServerList, Len);
  Result := ReadFile(FileName, ServerList);
end;
{$ENDREGION}
{$REGION 'Save Functions'}
class function TFunctions.SaveSL(FileName: string): Boolean;
var
  Buffer: ARRAY OF BYTE;
  F: TFileStream;
begin
  Result := False;
  if not(FileExists(FileName)) then
  begin
    Exit;
  end;
  F := TFileStream.Create(FileName, fmOpenWrite);
  SetLength(Buffer, F.Size);
  Move(ServerList[0], Buffer[0], F.Size);
  if (Self.EncDecSL(Buffer, True)) then
  begin
    F.WriteBuffer(Buffer[0], F.Size);
    Result := True;
  end;
  F.Free;
end;
{$ENDREGION}
{$REGION 'Time Functions'}
class function TFunctions.Time: String;
var
  Hour, Minute, Second: String;
  Day, Month, Year: String;
begin
  Hour := HourOf(Now).ToString;
  Minute := MinuteOf(Now).ToString;
  Second := SecondOf(Now).ToString;
  Day := DayOf(Now).ToString;
  Month := MonthOf(Now).ToString;
  Year := YearOf(Now).ToString;
  if (StrToInt(Hour) < 10) then
    Hour := IntToStr(0) + Hour;
  if (StrToInt(Minute) < 10) then
    Minute := IntToStr(0) + Minute;
  if (StrToInt(Second) < 10) then
    Second := IntToStr(0) + Second;
  if (StrToInt(Day) < 10) then
    Day := IntToStr(0) + Day;
  if (StrToInt(Month) < 10) then
    Month := IntToStr(0) + Month;
  Result := (Hour + Minute + Second + Day + Month + Year);
end;
class function TFunctions.UNIXTimeToDateTimeFAST(UnixTime: Int64): TDateTime;
begin
  //Result.SetUnix(UnixTime);

  Result := (UnixTime div 86400) + 25569;
end;
class function TFunctions.DateTimeToUNIXTimeFAST(DelphiTime: TDateTime)
  : Int64;
begin
  //DelphiTime.ToUnix();

  Result := Trunc((DelphiTime - 25569) * 86400);
end;
class function TFunctions.ReTime(Time: String): TDateTime;
begin
  Result := StrToDateTime(Time[7] + Time[8] + '/' + Time[9] + Time[10] + '/' +
    Time[11] + Time[12] + Time[13] + Time[14] + ' ' + Time[1] + Time[2] + ':' +
    Time[3] + Time[4] + ':' + Time[5] + Time[6]);
end;
{$ENDREGION}
{$REGION 'MakeItems funcs'}
class function TFunctions.SearchMakeItemIDByRewardID(RewardID: word): word;
var
  i: word;
begin
  Result := 3000;
  for i := Low(MakeItems) to High(MakeItems) do
  begin
    if (RewardID = MakeItems[i].ResultItemID) then
    begin
      Result := i;
      break;
    end
    else
      Continue;
  end;
end;
{$ENDREGION}
{
  class procedure TFunctions.GetMakeItems();
  var
  SelfSql: TQuery;
  ItemLine, LineWrite: String;
  MakeItems: TStringList;
  i, ItemAmount: Integer;
  F: TextFile;
  Path: String;
  begin
  try
  SelfSql := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
  AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
  AnsiString('aikaemu_game'));
  if not(SelfSql.MySQL.Connected) then
  Logger.Write('Erro: not mysql connection', TlogType.Packets);
  MakeItems := TStringList.Create;
  SelfSql.SetQuery('SELECT * FROM data_exp WHERE 1');
  SelfSql.Run();                  //data_make_items
  ItemAmount := SelfSql.Query.RecordCount;
  Logger.Write(ItemAmount.ToString, TlogType.Packets);
  {
  for i := 0 to (ItemAmount - 1) do
  begin
  ItemLine := IntToStr(SelfSql.Query.FieldByName('id').AsInteger) + ',' +
  IntToStr(SelfSql.Query.FieldByName('result_sup_item_id').AsInteger) +
  ',' + IntToStr(SelfSql.Query.FieldByName('level').AsInteger) + ',' +
  IntToStr(SelfSql.Query.FieldByName('price').AsInteger) + ',' +
  IntToStr(SelfSql.Query.FieldByName('quantity').AsInteger) + ',' +
  IntToStr(SelfSql.Query.FieldByName('rate').AsInteger) + ',' +
  IntToStr(SelfSql.Query.FieldByName('rate_sup').AsInteger) + ',' +
  IntToStr(SelfSql.Query.FieldByName('rate_double').AsInteger);
  MakeItems.Add(ItemLine);
  if (ItemAmount > 1) then
  SelfSql.Query.Next;
  end;
  Path := GetCurrentDir + '\Data\MakeItems.csv';
  AssignFile(F, Path);
  Rewrite(F);
  for i := 0 to (MakeItems.Count - 1) do
  begin
  WriteLn(F, MakeItems.Strings[i]);
  end;
  CloseFile(F); }   {
  except
  on E: Exception do
  begin
  Logger.Write('Erro: ' + E.Message, TlogType.Packets);
  end;
  end;
  end;
  class procedure TFunctions.GetMakeItemsIngredients();
  var
  SelfSql: TQuery;
  ItemLine, LineWrite: String;
  MakeItems: TStringList;
  i, ItemAmount: Integer;
  F: TextFile;
  Path: String;
  begin
  try
  SelfSql := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
  AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
  AnsiString('aikaemu_game'));
  MakeItems := TStringList.Create;
  SelfSql.SetQuery('SELECT * FROM data_make_item_ingredients');
  SelfSql.Run();
  ItemAmount := SelfSql.Query.RecordCount;
  for i := 0 to (ItemAmount - 1) do
  begin
  ItemLine := IntToStr(SelfSql.Query.FieldByName('id').AsInteger) + ',' +
  IntToStr(SelfSql.Query.FieldByName('item_id').AsInteger) + ',' +
  IntToStr(SelfSql.Query.FieldByName('quantity').AsInteger);
  MakeItems.Add(ItemLine);
  if (ItemAmount > 1) then
  SelfSql.Query.Next;
  end;
  Path := GetCurrentDir + '\Data\MakeItemsIngredients.csv';
  AssignFile(F, Path);
  Rewrite(F);
  for i := 0 to (MakeItems.Count - 1) do
  begin
  WriteLn(F, MakeItems.Strings[i]);
  end;
  CloseFile(F);
  except
  on E: Exception do
  begin
  Logger.Write('Erro: ' + E.Message, TlogType.Packets);
  end;
  end;
  end; }
end.
