unit GuildData;
interface
uses
  Windows, SysUtils, MiscData, System.Classes, DateUtils, AnsiStrings,
  PartyData;
{$OLDTYPELAYOUT ON}
const
  MaxGuildPlayersOfLevel: ARRAY [0 .. 9] OF BYTE = (32, 48, 64, 80, 96, 112,
    128, 128, 128, 128);
type
  PPlayerFromGuild = ^TPlayerFromGuild;
  TPlayerFromGuild = packed record
    CharIndex: DWORD;
    Name: ARRAY [0 .. 19] OF AnsiChar;
    Rank: BYTE;
    ClassInfo: BYTE;
    Level: BYTE;
    Logged: Boolean;
    LastLogin: DWORD;
    Unk: ARRAY [0 .. 31] OF BYTE;
  end;
type
  TGuildNotice = packed record
    Null: WORD;
    Text: ARRAY [0 .. 33] OF AnsiChar;
  end;
type
  TGuildAllyItem = packed record
    Index: WORD;
    Name: ARRAY [0 .. 17] OF AnsiChar;
  end;
type
  TGuildAlly = packed record
    Leader: WORD;
    Guilds: ARRAY [0 .. 3] OF TGuildAllyItem;
  end;
type
  TGuildChest = packed record
    Items: ARRAY [0 .. 49] OF TITEM;
    Gold: UInt64;
  end;
type
  TGuildRankConfig = packed record
    Invite, Kick, UseGuildSkill, EditNotices, OpenGWH, UseGWH: Boolean;
  end;
type
  PGuild = ^TGuild;
  TGuild = record
  private type
    TCloseChestThread = class(TThread)
    public
      Guild: PGuild;
    protected
      procedure Execute; override;
    end;
  public
    Index, Slot, Nation, Exp, Level, TotalMembers: DWORD;
    BravurePoints, SkillPoints: DWORD;
    Promote: Boolean;
    GuildLeaderCharIndex: Integer;
    Name: ARRAY [0 .. 18] OF AnsiChar;
    Notices: ARRAY [0 .. 2] OF TGuildNotice;
    RanksConfig: ARRAY [0 .. 4] OF BYTE;
    Site: ARRAY [0 .. 37] OF AnsiChar;
    Ally: TGuildAlly;
    Members: ARRAY [0 .. 127] OF TPlayerFromGuild;
    Chest: TGuildChest;
    MemberInChest: Integer;
    LastChestActionDate: TDateTime;
    CloseChestThread: TCloseChestThread;
    function CreateGuild(GuildName: ARRAY OF AnsiChar;
      GuildNation, ChannelId: Integer; Party: PParty; SelfPlayer: pointer): Boolean;
    function AddMember(CharIndex, ChannelId: DWORD; Rank: BYTE;
      RecruterCharIndex: DWORD): Boolean;
    function RemoveMember(CharIndex: DWORD; Expulsion: Boolean): Boolean;
    function ChangeRank(CharIndex, Rank: DWORD): Boolean;
    function UpdateLevel(CharIndex, Level: DWORD): Boolean;
    function GetFreeMemberId: Integer;
    function GetAllyGuildCount: Integer;
    function FindMemberFromCharIndex(CharIndex: DWORD): Integer;
    function UpdateRanksConfig(RanksConfig: ARRAY OF BYTE): Boolean;
    function UpdateNotices(Notice1, Notice2,
      Notice3: ARRAY OF AnsiChar): Boolean;
    function UpdateSite(FSite: ARRAY OF AnsiChar): Boolean;
    function OpenChest(CharIndex: DWORD; ChannelId: DWORD): Boolean;
    function CloseChest: Boolean;
    function SendChatMessage(const Packet; Size: Integer): Boolean;
    function SendChatAllyMessage(const Packet; Size: Integer): Boolean;
    function SendMemberLogin(CharIndex: DWORD): Boolean;
    function SendMemberLogout(CharIndex: DWORD): Boolean;
    function GetRankConfig(Rank: Integer): TGuildRankConfig;
  end;
{$OLDTYPELAYOUT OFF}
implementation
uses
  Functions, GlobalDefs, Player, Log, SQL;
procedure TGuild.TCloseChestThread.Execute;
var
  I: Integer;
  Player: PPlayer;
begin
  while not(Self.Guild.MemberInChest < 0) and
    not(Self.Guild.MemberInChest > High(Self.Guild.Members)) do
  begin
    if MinutesBetween(Now, Self.Guild.LastChestActionDate) >= 2 then
    begin
      for I := Low(Servers) to High(Servers) do
        if Servers[I].GetPlayerByCharIndex
          (Self.Guild.Members[Self.Guild.MemberInChest].CharIndex, Player) then
        begin
          Player.SendSignal(Player.Character.Base.ClientId, $F2F);
          Break;
        end;
      Break;
    end;
    Sleep(50);
  end;
  Self.Terminate;
end;
function TGuild.CreateGuild(GuildName: ARRAY OF AnsiChar;
  GuildNation, ChannelId: Integer; Party: PParty; SelfPlayer: pointer): Boolean;
var
  PartyMemberClientId: WORD;
  MemberId, GuildCnt: Integer;
  xPlayer, SPlayer: PPlayer;
  I, M: Integer;
  Member: PPlayerFromGuild;
  SQLComp: TQuery;
begin
  Result := False;
  SPlayer := SelfPlayer;
 { SPlayer.PlayerSQL.SetQuery
    ('SELECT guild_count FROM server_info WHERE server_id = 1');
  //Servers[ChannelId].cSQL.AddParameter2('pserver_id', 1);
  SPlayer.PlayerSQL.Run();
  GuildCnt := SPlayer.PlayerSQL.Query.FieldByName('guild_count')
    .AsInteger;
  Inc(GuildCnt);
  SPlayer.PlayerSQL.SetQuery
    (format('UPDATE server_info SET guild_count=%d WHERE server_id=1',
    [GuildCnt]));
 // Servers[ChannelId].cSQL.AddParameter2('pguild_count', GuildCnt);
  //Servers[ChannelId].cSQL.AddParameter2('pserver_id', 1);
  SPlayer.PlayerSQL.Run(False); }
  //Self.Index := GuildCnt;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[CreateGuild]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[CreateGuild]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  SQLComp.Query.SQL.Clear;
  SQLComp.Query.SQL.Add(Format('SELECT coalesce(max(id), 0) FROM guilds',
    [Self.GuildLeaderCharIndex]));
  SQLComp.Run(True);
  if(SQLComp.Query.RecordCount > 0) then
    Self.Index := SQLComp.Query.Fields[0].AsInteger+1 //pegando id temporário
  else
    Self.Index := 1;
  Move(GuildName, Self.Name[0], Length(GuildName));
  Self.Ally.Leader := Self.Index;
  Self.Ally.Guilds[0].Index := Self.Index;
  Move(GuildName, Self.Ally.Guilds[0].Name, SizeOf(Self.Ally.Guilds[0].Name));
  Self.RanksConfig[4] := $FF;
  Self.Nation := GuildNation;
  Self.MemberInChest := $FF;
  Self.Exp := 1;
  for PartyMemberClientId in Party.Members do
  begin
    xPlayer := @Servers[ChannelId].Players[PartyMemberClientId];
    MemberId := Self.GetFreeMemberId;
    if MemberId < 0 then
      break;
    xPlayer.Character.Base.GuildIndex := Self.Index;
    xPlayer.Character.GuildSlot := Self.Slot;
    // ZeroMemory(@Members[MemberId], SizeOf(Members[MemberId]));
    Self.Members[MemberId].CharIndex := xPlayer.Character.Base.CharIndex;
    Self.Members[MemberId].ClassInfo := xPlayer.Character.Base.ClassInfo;
    Self.Members[MemberId].Level := xPlayer.Character.Base.Level - 1;
    Self.Members[MemberId].Logged := True;
    Self.Members[MemberId].LastLogin := DateTimeToUnix(Now);
    AnsiStrings.StrCopy(Self.Members[MemberId].Name,
      xPlayer.Character.Base.Name);
    if PartyMemberClientId = Party.Leader then
    begin
      Self.Members[MemberId].Rank := 4;
      Self.GuildLeaderCharIndex := xPlayer.Character.Index;
    end
    else
      Self.Members[MemberId].Rank := 0;
  end;
  //for tava aq
  { Save Guild at MySQL }
  try
    // Servers[ChannelId].cSQL.MySQL.StartTransaction;
    SQLComp.SetQuery
      (format('INSERT INTO guilds (slot, name, nation, experience,' +
      ' level, totalmembers, bravurepoints, skillpoints, promote, notice1, notice2,'
      + ' notice3, site, rank1, rank2, rank3, rank4, rank5, ally_leader,' +
      ' guild_ally1_index, guild_ally1_name, guild_ally2_index, guild_ally2_name,'
      + ' guild_ally3_index, guild_ally3_name, guild_ally4_index, guild_ally4_name,'
      + ' storage_gold, leader_char_index) VALUES (%d, %s, %d, %d,'
      + ' %d, %d, %d, %d, %d, %s, %s,'
      + ' %s, %s, %d, %d, %d, %d, %d, %d,'
      + ' %d, %s, %d, %s,'
      + ' %d, %s, %d, %s,'
      + ' %d, %d)',
      [Self.Slot, QuotedStr(String(Self.Name)),
      Self.Nation, Self.Exp, Self.Level, Self.TotalMembers, Self.BravurePoints,
      Self.SkillPoints, Self.Promote.ToInteger, QuotedStr(String(Self.Notices[0].Text)),
      QuotedStr(String(Self.Notices[1].Text)), QuotedStr(String(Self.Notices[2].Text)),
      QuotedStr(String(Self.Site)), Self.RanksConfig[0], Self.RanksConfig[1],
      Self.RanksConfig[2], Self.RanksConfig[3], Self.RanksConfig[4],
      Self.Ally.Leader, Self.Ally.Guilds[0].Index, QuotedStr(String(Self.Ally.Guilds[0].Name)),
      Self.Ally.Guilds[1].Index, QuotedStr(String(Self.Ally.Guilds[1].Name)),
      Self.Ally.Guilds[2].Index, QuotedStr(String(Self.Ally.Guilds[2].Name)),
      Self.Ally.Guilds[3].Index, QuotedStr(String(Self.Ally.Guilds[3].Name)),
      Self.Chest.Gold, Self.GuildLeaderCharIndex]));
    {Servers[ChannelId].cSQL.AddParameter2('pid', Self.Index);
    Servers[ChannelId].cSQL.AddParameter2('pslot', Self.Slot);
    Servers[ChannelId].cSQL.AddParameter2('pname', String(Self.Name));
    Servers[ChannelId].cSQL.AddParameter2('pnation', Self.Nation);
    Servers[ChannelId].cSQL.AddParameter2('pexperience', Self.Exp);
    Servers[ChannelId].cSQL.AddParameter2('plevel', Self.Level);
    Servers[ChannelId].cSQL.AddParameter2('ptotalmembers', Self.TotalMembers);
    Servers[ChannelId].cSQL.AddParameter2('pbravurepoints', Self.BravurePoints);
    Servers[ChannelId].cSQL.AddParameter2('pskillpoints', Self.SkillPoints);
    Servers[ChannelId].cSQL.AddParameter2('ppromote', Self.Promote.ToInteger);
    Servers[ChannelId].cSQL.AddParameter2('pnotice1',
      String(Self.Notices[0].Text));
    Servers[ChannelId].cSQL.AddParameter2('pnotice2',
      String(Self.Notices[1].Text));
    Servers[ChannelId].cSQL.AddParameter2('pnotice3',
      String(Self.Notices[2].Text));
    Servers[ChannelId].cSQL.AddParameter2('psite', String(Self.Site));
    Servers[ChannelId].cSQL.AddParameter2('prank1', Self.RanksConfig[0]);
    Servers[ChannelId].cSQL.AddParameter2('prank2', Self.RanksConfig[1]);
    Servers[ChannelId].cSQL.AddParameter2('prank3', Self.RanksConfig[2]);
    Servers[ChannelId].cSQL.AddParameter2('prank4', Self.RanksConfig[3]);
    Servers[ChannelId].cSQL.AddParameter2('prank5', Self.RanksConfig[4]);
    Servers[ChannelId].cSQL.AddParameter2('pally_leader', Self.Ally.Leader);
    Servers[ChannelId].cSQL.AddParameter2('pguild_ally1_index',
      Self.Ally.Guilds[0].Index);
    Servers[ChannelId].cSQL.AddParameter2('pguild_ally1_name',
      String(Self.Ally.Guilds[0].Name));
    Servers[ChannelId].cSQL.AddParameter2('pguild_ally2_index',
      Self.Ally.Guilds[1].Index);
    Servers[ChannelId].cSQL.AddParameter2('pguild_ally2_name',
      String(Self.Ally.Guilds[1].Name));
    Servers[ChannelId].cSQL.AddParameter2('pguild_ally3_index',
      Self.Ally.Guilds[2].Index);
    Servers[ChannelId].cSQL.AddParameter2('pguild_ally3_name',
      String(Self.Ally.Guilds[2].Name));
    Servers[ChannelId].cSQL.AddParameter2('pguild_ally4_index',
      Self.Ally.Guilds[3].Index);
    Servers[ChannelId].cSQL.AddParameter2('pguild_ally4_name',
      String(Self.Ally.Guilds[3].Name));
    Servers[ChannelId].cSQL.AddParameter2('pstorage_gold', Self.Chest.Gold);
    Servers[ChannelId].cSQL.AddParameter2('pleader_char_index',
      Self.GuildLeaderCharIndex); }
    SQLComp.Run(False);
    SQLComp.Query.SQL.Clear;
    SQLComp.Query.SQL.Add(Format('SELECT id FROM guilds WHERE leader_char_index=%d',
      [Self.GuildLeaderCharIndex]));
    SQLComp.Run(True);
    if not(SQLComp.Query.IsEmpty) then
      Self.Index := SQLComp.Query.Fields[0].AsInteger; //pegando id real
    for I := Low(Self.Members) to High(Self.Members) do
    if Self.Members[I].CharIndex > 0 then
      if Servers[ChannelId].GetPlayerByCharIndex(Self.Members[I].CharIndex,
        xPlayer) then
      begin
        xPlayer.SendGuildInfo;
        xPlayer.RefreshPlayerInfos;
        xPlayer.SendP152;
        xPlayer.SendGuildPlayers;
        Inc(TotalMembers, 1);
      end;
    for M := 0 to 127 do
    begin
      if (Self.Members[M].CharIndex = 0) then
        Continue;
      Member := @Self.Members[M];
      SQLComp.SetQuery
        (format('INSERT INTO guilds_players (guild_index, char_index, name, player_rank,'
        + ' classinfo, level, logged, last_login) VALUES (%d, %d, %s, %d,'
        + ' %d, %d, %d, %d)', [Self.Index, Member.CharIndex,
        QuotedStr(String(Member.Name)), Member.Rank, Member.ClassInfo, Member.Level,
        Member.Logged.ToInteger, Member.LastLogin]));
     { Servers[ChannelId].cSQL.AddParameter2('pid', Member.CharIndex);
      Servers[ChannelId].cSQL.AddParameter2('pguild_index', Self.Index);
      Servers[ChannelId].cSQL.AddParameter2('pchar_index', Member.CharIndex);
      Servers[ChannelId].cSQL.AddParameter2('pname', String(Member.Name));
      Servers[ChannelId].cSQL.AddParameter2('pplayer_rank', Member.Rank);
      Servers[ChannelId].cSQL.AddParameter2('pclassinfo', Member.ClassInfo);
      Servers[ChannelId].cSQL.AddParameter2('plevel', Member.Level);
      Servers[ChannelId].cSQL.AddParameter2('plogged', Member.Logged.ToInteger);
      Servers[ChannelId].cSQL.AddParameter2('plast_login', Member.LastLogin);}
      SQLComp.Run(False);
    end;
    // Servers[ChannelId].cSQL.MySQL.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('guild_save_create_error: ' + E.Message, TLogType.Error);
    end;
  end;
  SQLComp.Destroy;
  Result := True;
end;
function TGuild.AddMember(CharIndex: DWORD; ChannelId: DWORD; Rank: BYTE;
  RecruterCharIndex: DWORD): Boolean;
var
  I, P: Integer;
  MemberId: Integer;
  Player: PPlayer;
  AddBuff: BYTE;
begin
  AddBuff := 0;
  Result := False;
  if Servers[ChannelId].GetPlayerByCharIndex(RecruterCharIndex, Player) = False
  then
    Exit;
  MemberId := Self.GetFreeMemberId;
  if MemberId < 0 then
  begin
    Player.SendClientMessage('A guild não tem mais espaço.');
    if Servers[ChannelId].GetPlayerByCharIndex(CharIndex, Player) then
      Player.SendClientMessage('A guild não tem mais espaço.');
    Exit;
  end;
  if Servers[ChannelId].GetPlayerByCharIndex(CharIndex, Player) = False then
    Exit;
  if (Player.IsGradeMarshal) then
    AddBuff := 1
  else if (Player.IsGradeArchon) then
    AddBuff := 2;
  ZeroMemory(@Members[MemberId], SizeOf(Members[MemberId]));
  Self.Members[MemberId].CharIndex := Player.Character.Index;
  Move(Player.Character.Base.Name, Self.Members[MemberId].Name, 16);
  Self.Members[MemberId].Rank := Rank;
  Self.Members[MemberId].ClassInfo := Player.Character.Base.ClassInfo;
  Self.Members[MemberId].Level := Player.Character.Base.Level - 1;
  Self.Members[MemberId].Logged := True;
  Self.Members[MemberId].LastLogin := DateTimeToUnix(Now);
  Player.Character.Base.GuildIndex := Self.Index;
  Player.Character.GuildSlot := Self.Slot;
  Player.Base.SendCreateMob(SPAWN_NORMAL);
  Player.SendGuildInfo;
  Player.RefreshPlayerInfos;
  Player.SendP152;
  Player.SendGuildPlayers;
  case AddBuff of
    1:
      begin
        Player.Base.AddBuffWhenEntering(CAVALEIROS_MARECHAL, Now);
      end;
    2:
      begin
        Player.Base.AddBuffWhenEntering(CAVALEIROS_ARCHON, Now);
      end;
  end;
  for I := Low(Members) to High(Members) do
    if (Members[I].CharIndex > 0) and
      not(Members[I].CharIndex = Self.Members[MemberId].CharIndex) then
      for P := Low(Servers) to High(Servers) do
        if Servers[P].GetPlayerByCharIndex(Members[I].CharIndex, Player) then
        begin
          Player.AddPlayerToGuild(Self.Members[MemberId]);
          Break;
        end;
  Inc(Self.TotalMembers, 1);
  Result := True;
end;
function TGuild.RemoveMember(CharIndex: DWORD; Expulsion: Boolean): Boolean;
var
  MemberId: Integer;
  I, P: Integer;
  Player: PPlayer;
  RemoveBuff: BYTE;
begin
  Result := False;
  RemoveBuff := 0;
  MemberId := Self.FindMemberFromCharIndex(CharIndex);
  if MemberId >= 0 then
  begin
    for I := Low(Servers) to High(Servers) do
      if Servers[I].GetPlayerByCharIndex(CharIndex, Player) then
      begin
        Player.GetOutGuild(Expulsion);
        if (Player.IsGradeMarshal) then
          RemoveBuff := 1
        else if (Player.IsGradeArchon) then
          RemoveBuff := 2;
        Break;
      end;
    for I := Low(Members) to High(Members) do
      if (Members[I].CharIndex > 0) and not(Members[I].CharIndex = CharIndex)
      then
        for P := Low(Servers) to High(Servers) do
          if Servers[P].GetPlayerByCharIndex(Members[I].CharIndex, Player) then
          begin
            Player.SendData(Player.Base.ClientId, $F1B, CharIndex);
            Break;
          end;
    if Members[MemberId].Rank = 4 then
    begin
      for I := Low(Members) to High(Members) do
        if (Members[I].CharIndex > 0) and not(Members[I].CharIndex = CharIndex)
        then
          Self.RemoveMember(Members[I].CharIndex, True);
      ZeroMemory(@Self, SizeOf(Self));
    end
    else
    begin
      ZeroMemory(@Self.Members[MemberId], SizeOf(Self.Members[MemberId]));
      Dec(Self.TotalMembers, 1);
    end;
    case RemoveBuff of
      1:
        begin
          Player.Base.RemoveBuff(CAVALEIROS_MARECHAL);
        end;
      2:
        begin
          Player.Base.RemoveBuff(CAVALEIROS_ARCHON);
        end;
    end;
    Result := True;
  end;
end;
function TGuild.ChangeRank(CharIndex, Rank: DWORD): Boolean;
var
  I, P: Integer;
  Player: PPlayer;
begin
  Result := False;
  Self.Members[Self.FindMemberFromCharIndex(CharIndex)].Rank := Rank;
  try
    for I := Low(Self.Members) to High(Self.Members) do
      if (Self.Members[I].CharIndex > 0) then
        for P := Low(Servers) to High(Servers) do
          if Servers[P].GetPlayerByCharIndex(Self.Members[I].CharIndex, Player)
          then
          begin
            Player.UpdateGuildMemberRank(CharIndex, Rank);
            Break;
          end;
  except
    Exit;
  end;
  Result := True;
end;
function TGuild.UpdateLevel(CharIndex, Level: DWORD): Boolean;
var
  I, P: Integer;
  Player: PPlayer;
begin
  Result := False;
  Self.Members[Self.FindMemberFromCharIndex(CharIndex)].Level := Level;
  try
    for I := Low(Self.Members) to High(Self.Members) do
      if (Self.Members[I].CharIndex > 0) then
        for P := Low(Servers) to High(Servers) do
          if Servers[P].GetPlayerByCharIndex(Self.Members[I].CharIndex, Player)
          then
          begin
            Player.UpdateGuildMemberLevel(CharIndex, Level);
            Break;
          end;
  except
    Exit;
  end;
  Result := True;
end;
function TGuild.GetFreeMemberId: Integer;
var
  I: Integer;
begin
  Result := -1;
  if TotalMembers >= MaxGuildPlayersOfLevel[Self.Level] then
    Exit;
  for I := Low(Members) to High(Members) do
    if Members[I].CharIndex = 0 then
    begin
      Result := I;
      Break;
    end;
end;
function TGuild.GetAllyGuildCount: Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 0 to 3 do
  begin
    if(Self.Ally.Guilds[i].Index <> 0) then
      inc(Result);
  end;
end;
function TGuild.FindMemberFromCharIndex(CharIndex: DWORD): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := Low(Self.Members) to High(Self.Members) do
    if Self.Members[I].CharIndex = CharIndex then
    begin
      Result := I;
      Break;
    end;
end;
function TGuild.UpdateRanksConfig(RanksConfig: ARRAY OF BYTE): Boolean;
var
  I, P: Integer;
  Player: PPlayer;
begin
  Result := False;
  Move(RanksConfig, Self.RanksConfig, 4);
  try
    for I := Low(Self.Members) to High(Self.Members) do
      if (Self.Members[I].CharIndex > 0) then
        for P := Low(Servers) to High(Servers) do
          if Servers[P].GetPlayerByCharIndex(Self.Members[I].CharIndex, Player)
          then
          begin
            Player.UpdateGuildRanksConfig;
            Break;
          end;
  except
    Exit;
  end;
  Result := True;
end;
function TGuild.UpdateNotices(Notice1, Notice2,
  Notice3: ARRAY OF AnsiChar): Boolean;
var
  I, P: Integer;
  Player: PPlayer;
begin
  Result := False;
  AnsiStrings.StrCopy(Self.Notices[0].Text, Notice1);
  AnsiStrings.StrCopy(Self.Notices[1].Text, Notice2);
  AnsiStrings.StrCopy(Self.Notices[2].Text, Notice3);
  try
    for I := Low(Self.Members) to High(Self.Members) do
      if (Self.Members[I].CharIndex > 0) then
        for P := Low(Servers) to High(Servers) do
          if Servers[P].GetPlayerByCharIndex(Self.Members[I].CharIndex, Player)
          then
          begin
            Player.UpdateGuildNotices;
            Break;
          end;
  except
    Exit;
  end;
  Result := True;
end;
function TGuild.UpdateSite(FSite: ARRAY OF AnsiChar): Boolean;
var
  I, P: Integer;
  Player: PPlayer;
begin
  AnsiStrings.StrCopy(Self.Site, FSite);
  Result := False;
  try
    for I := Low(Self.Members) to High(Self.Members) do
      if (Self.Members[I].CharIndex > 0) then
        for P := Low(Servers) to High(Servers) do
          if Servers[P].GetPlayerByCharIndex(Self.Members[I].CharIndex, Player)
          then
          begin
            Player.UpdateGuildSite;
            Break;
          end;
  except
    Exit;
  end;
  Result := True;
end;
function TGuild.OpenChest(CharIndex: DWORD; ChannelId: DWORD): Boolean;
var
  Player: PPlayer;
begin
  Result := False;
  if Servers[ChannelId].GetPlayerByCharIndex(CharIndex, Player) = False then
    Exit;
  if Self.GetRankConfig(Self.Members[Self.FindMemberFromCharIndex(CharIndex)
    ].Rank).OpenGWH = False then
  begin
    Player.SendClientMessage('Você não tem permissão para isso.');
    Exit;
  end;
  if (Self.MemberInChest >= 0) and (Self.MemberInChest <= High(Self.Members))
  then
  begin
    Player.SendClientMessage(AnsiString(Format('''%s'' está usando o armazém.',
      [Self.Members[Self.MemberInChest].Name])));
    Exit;
  end;
  Self.MemberInChest := Self.FindMemberFromCharIndex(CharIndex);
  Self.LastChestActionDate := Now;
  Self.CloseChestThread := TCloseChestThread.Create(True);
  Self.CloseChestThread.Guild := @Self;
  Self.CloseChestThread.Start;
  Player.SendGuildChestPermission;
  Player.SendGuildChest;
  Player.RefreshGuildChestGold;
  Result := True;
end;
function TGuild.CloseChest: Boolean;
begin
  Result := False;
  try
    Self.MemberInChest := $FF;
    Self.LastChestActionDate := 0;
  except
    Exit;
  end;
  Result := True;
end;
function TGuild.SendChatMessage(const Packet; Size: Integer): Boolean;
var
  I, P: Integer;
  Player: PPlayer;
begin
  Result := False;
  try
    for I := Low(Self.Members) to High(Self.Members) do
      if (Self.Members[I].CharIndex > 0) then
        for P := Low(Servers) to High(Servers) do
          if Servers[P].GetPlayerByCharIndex(Self.Members[I].CharIndex, Player)
          then
          begin
            Player.SendPacket(Packet, Size);
            Break;
          end;
  except
    Exit;
  end;
  Result := True;
end;
function TGuild.SendChatAllyMessage(const Packet; Size: Integer): Boolean;
var
  I, P, K: Integer;
  Player: PPlayer;
  xGuild: PGuild;
begin
  Result := False;
  for k := 0 to 3 do
  begin
    if(Self.Ally.Guilds[k].Index <> 0) then
    begin
      xGuild := @Guilds[Servers[0].GetGuildSlotByID(Self.Ally.Guilds[k].Index)];

      if(xGuild.Index > 0) then
      begin
        for I := Low(xGuild.Members) to High(xGuild.Members) do
          if (xGuild.Members[I].CharIndex > 0) then
            for P := Low(Servers) to High(Servers) do
              if Servers[P].GetPlayerByCharIndex(xGuild.Members[I].CharIndex, Player)
              then
              begin
                Player.SendPacket(Packet, Size);
                Break;
              end;
      end;
    end;
  end;
end;
function TGuild.SendMemberLogin(CharIndex: DWORD): Boolean;
var
  I, P: Integer;
  Player: PPlayer;
begin
  Result := False;
  Self.Members[Self.FindMemberFromCharIndex(CharIndex)].Logged := True;
  try
    for I := Low(Self.Members) to High(Self.Members) do
      if (Self.Members[I].CharIndex > 0) and
        not(Self.Members[I].CharIndex = CharIndex) then
        for P := Low(Servers) to High(Servers) do
          if Servers[P].GetPlayerByCharIndex(Self.Members[I].CharIndex, Player)
          then
          begin
            Player.GuildMemberLogin(Self.FindMemberFromCharIndex(CharIndex));
            Break;
          end;
  except
    Exit;
  end;
  Result := True;
end;
function TGuild.SendMemberLogout(CharIndex: DWORD): Boolean;
var
  I, P: Integer;
  Player: PPlayer;
begin
  Result := False;
  Self.Members[Self.FindMemberFromCharIndex(CharIndex)].Logged := False;
  Self.Members[Self.FindMemberFromCharIndex(CharIndex)].LastLogin :=
    DateTimeToUnix(Now);
  try
    for I := Low(Self.Members) to High(Self.Members) do
      if (Self.Members[I].CharIndex > 0) and
        not(Self.Members[I].CharIndex = CharIndex) then
        for P := Low(Servers) to High(Servers) do
          if Servers[P].GetPlayerByCharIndex(Self.Members[I].CharIndex, Player)
          then
          begin
            Player.GuildMemberLogout(Self.FindMemberFromCharIndex(CharIndex));
            Break;
          end;
  except
    Exit;
  end;
  Result := True;
end;
function TGuild.GetRankConfig(Rank: Integer): TGuildRankConfig;
var
  Value: Integer;
begin
  Value := Self.RanksConfig[Rank];
  case Value of
    $00:
      begin
        Result.Invite := False;
        Result.Kick := False;
        Result.UseGuildSkill := False;
        Result.EditNotices := False;
        Result.OpenGWH := False;
        Result.UseGWH := False;
      end;
    $01:
      begin
        Result.Invite := True;
        Result.Kick := False;
        Result.UseGuildSkill := False;
        Result.EditNotices := False;
        Result.OpenGWH := False;
        Result.UseGWH := False;
      end;
    $02:
      begin
        Result.Invite := False;
        Result.Kick := True;
        Result.UseGuildSkill := False;
        Result.EditNotices := False;
        Result.OpenGWH := False;
        Result.UseGWH := False;
      end;
    $04:
      begin
        Result.Invite := False;
        Result.Kick := False;
        Result.UseGuildSkill := True;
        Result.EditNotices := False;
        Result.OpenGWH := False;
        Result.UseGWH := False;
      end;
    $10:
      begin
        Result.Invite := False;
        Result.Kick := False;
        Result.UseGuildSkill := False;
        Result.EditNotices := True;
        Result.OpenGWH := False;
        Result.UseGWH := False;
      end;
    $40:
      begin
        Result.Invite := False;
        Result.Kick := False;
        Result.UseGuildSkill := False;
        Result.EditNotices := False;
        Result.OpenGWH := True;
        Result.UseGWH := False;
      end;
    $80:
      begin
        Result.Invite := False;
        Result.Kick := False;
        Result.UseGuildSkill := False;
        Result.EditNotices := False;
        Result.OpenGWH := False;
        Result.UseGWH := True;
      end;
    $03:
      begin
        Result.Invite := True;
        Result.Kick := True;
        Result.UseGuildSkill := False;
        Result.EditNotices := False;
        Result.OpenGWH := False;
        Result.UseGWH := False;
      end;
    $05:
      begin
        Result.Invite := True;
        Result.Kick := False;
        Result.UseGuildSkill := True;
        Result.EditNotices := False;
        Result.OpenGWH := False;
        Result.UseGWH := False;
      end;
    $11:
      begin
        Result.Invite := True;
        Result.Kick := False;
        Result.UseGuildSkill := False;
        Result.EditNotices := True;
        Result.OpenGWH := False;
        Result.UseGWH := False;
      end;
    $41:
      begin
        Result.Invite := True;
        Result.Kick := False;
        Result.UseGuildSkill := False;
        Result.EditNotices := False;
        Result.OpenGWH := True;
        Result.UseGWH := False;
      end;
    $81:
      begin
        Result.Invite := True;
        Result.Kick := False;
        Result.UseGuildSkill := False;
        Result.EditNotices := False;
        Result.OpenGWH := False;
        Result.UseGWH := True;
      end;
    $07:
      begin
        Result.Invite := True;
        Result.Kick := True;
        Result.UseGuildSkill := True;
        Result.EditNotices := False;
        Result.OpenGWH := False;
        Result.UseGWH := False;
      end;
    $13:
      begin
        Result.Invite := True;
        Result.Kick := True;
        Result.UseGuildSkill := False;
        Result.EditNotices := True;
        Result.OpenGWH := False;
        Result.UseGWH := False;
      end;
    $43:
      begin
        Result.Invite := True;
        Result.Kick := True;
        Result.UseGuildSkill := False;
        Result.EditNotices := False;
        Result.OpenGWH := True;
        Result.UseGWH := False;
      end;
    $83:
      begin
        Result.Invite := True;
        Result.Kick := True;
        Result.UseGuildSkill := False;
        Result.EditNotices := False;
        Result.OpenGWH := False;
        Result.UseGWH := True;
      end;
    $17:
      begin
        Result.Invite := True;
        Result.Kick := True;
        Result.UseGuildSkill := True;
        Result.EditNotices := True;
        Result.OpenGWH := False;
        Result.UseGWH := False;
      end;
    $47:
      begin
        Result.Invite := True;
        Result.Kick := True;
        Result.UseGuildSkill := True;
        Result.EditNotices := False;
        Result.OpenGWH := True;
        Result.UseGWH := False;
      end;
    $87:
      begin
        Result.Invite := True;
        Result.Kick := True;
        Result.UseGuildSkill := True;
        Result.EditNotices := False;
        Result.OpenGWH := False;
        Result.UseGWH := True;
      end;
    $57:
      begin
        Result.Invite := True;
        Result.Kick := True;
        Result.UseGuildSkill := True;
        Result.EditNotices := True;
        Result.OpenGWH := True;
        Result.UseGWH := False;
      end;
    $97:
      begin
        Result.Invite := True;
        Result.Kick := True;
        Result.UseGuildSkill := True;
        Result.EditNotices := True;
        Result.OpenGWH := True;
        Result.UseGWH := True;
      end;
    $D7:
      begin
        Result.Invite := True;
        Result.Kick := True;
        Result.UseGuildSkill := True;
        Result.EditNotices := True;
        Result.OpenGWH := True;
        Result.UseGWH := True;
      end;
    $06:
      begin
        Result.Invite := False;
        Result.Kick := True;
        Result.UseGuildSkill := True;
        Result.EditNotices := False;
        Result.OpenGWH := False;
        Result.UseGWH := False;
      end;
    $16:
      begin
        Result.Invite := False;
        Result.Kick := True;
        Result.UseGuildSkill := True;
        Result.EditNotices := True;
        Result.OpenGWH := False;
        Result.UseGWH := False;
      end;
    $46:
      begin
        Result.Invite := False;
        Result.Kick := True;
        Result.UseGuildSkill := True;
        Result.EditNotices := False;
        Result.OpenGWH := True;
        Result.UseGWH := False;
      end;
    $86:
      begin
        Result.Invite := False;
        Result.Kick := True;
        Result.UseGuildSkill := True;
        Result.EditNotices := False;
        Result.OpenGWH := False;
        Result.UseGWH := True;
      end;
    $56:
      begin
        Result.Invite := False;
        Result.Kick := True;
        Result.UseGuildSkill := True;
        Result.EditNotices := True;
        Result.OpenGWH := True;
        Result.UseGWH := False;
      end;
    $96:
      begin
        Result.Invite := False;
        Result.Kick := True;
        Result.UseGuildSkill := True;
        Result.EditNotices := True;
        Result.OpenGWH := False;
        Result.UseGWH := True;
      end;
    $D6:
      begin
        Result.Invite := False;
        Result.Kick := True;
        Result.UseGuildSkill := True;
        Result.EditNotices := True;
        Result.OpenGWH := False;
        Result.UseGWH := True;
      end;
    $14:
      begin
        Result.Invite := False;
        Result.Kick := False;
        Result.UseGuildSkill := True;
        Result.EditNotices := True;
        Result.OpenGWH := False;
        Result.UseGWH := False;
      end;
    $44:
      begin
        Result.Invite := False;
        Result.Kick := False;
        Result.UseGuildSkill := True;
        Result.EditNotices := False;
        Result.OpenGWH := True;
        Result.UseGWH := False;
      end;
    $84:
      begin
        Result.Invite := False;
        Result.Kick := False;
        Result.UseGuildSkill := True;
        Result.EditNotices := False;
        Result.OpenGWH := False;
        Result.UseGWH := True;
      end;
    $54:
      begin
        Result.Invite := False;
        Result.Kick := False;
        Result.UseGuildSkill := True;
        Result.EditNotices := True;
        Result.OpenGWH := True;
        Result.UseGWH := False;
      end;
    $94:
      begin
        Result.Invite := False;
        Result.Kick := False;
        Result.UseGuildSkill := True;
        Result.EditNotices := True;
        Result.OpenGWH := False;
        Result.UseGWH := True;
      end;
    $D4:
      begin
        Result.Invite := False;
        Result.Kick := False;
        Result.UseGuildSkill := True;
        Result.EditNotices := True;
        Result.OpenGWH := False;
        Result.UseGWH := True;
      end;
    $50:
      begin
        Result.Invite := False;
        Result.Kick := False;
        Result.UseGuildSkill := False;
        Result.EditNotices := True;
        Result.OpenGWH := True;
        Result.UseGWH := False;
      end;
    $90:
      begin
        Result.Invite := False;
        Result.Kick := False;
        Result.UseGuildSkill := False;
        Result.EditNotices := True;
        Result.OpenGWH := False;
        Result.UseGWH := True;
      end;
    $D0:
      begin
        Result.Invite := False;
        Result.Kick := False;
        Result.UseGuildSkill := False;
        Result.EditNotices := True;
        Result.OpenGWH := True;
        Result.UseGWH := True;
      end;
    $C0:
      begin
        Result.Invite := False;
        Result.Kick := False;
        Result.UseGuildSkill := False;
        Result.EditNotices := False;
        Result.OpenGWH := True;
        Result.UseGWH := True;
      end;
    $FF:
      begin
        Result.Invite := True;
        Result.Kick := True;
        Result.UseGuildSkill := True;
        Result.EditNotices := True;
        Result.OpenGWH := True;
        Result.UseGWH := True;
      end;
  end;
end;
end.
