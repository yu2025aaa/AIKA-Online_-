unit NPCHandlers;
interface
uses
  Player, NPC, Packets, SysUtils, AnsiStrings, Log, DateUtils;
type
  TNPCHandlers = class(TObject)
  public
    class function ShowOptions(var Player: TPlayer; var NPC: TNPC): Boolean;
    class function ShowShop(var Player: TPlayer; var NPC: TNPC): Boolean;
    class function ShowSkills(var Player: TPlayer; var NPC: TNPC): Boolean;
    class function ShowReinforce(var Player: TPlayer): Boolean;
    class function ShowActionHouse(var Player: TPlayer): Boolean;
    class function ShowEnchant(var Player: TPlayer): Boolean;
    class function SendTalk(var Player: TPlayer; NpcId: WORD): Boolean;
    class function SendQuests(var Player: TPlayer; NpcId: WORD;
      Type2: WORD): Boolean;
    class function LilolaBuff(var Player: TPlayer; NpcId: WORD): Boolean;
    class function ShowMountEnchant(var Player: TPlayer): Boolean;
    class function ShowBigorna(var Player: TPlayer): Boolean;
    class function ShowRepareItens(var Player: TPlayer): Boolean;
    class function ShowRepareAllItens(var Player: TPlayer): Boolean;
    class function ShowPranEnchant(var Player: TPlayer): Boolean;
    class function ShowDesmontItem(var Player: TPlayer): Boolean;
    class function ShowChangeApp(var Player: TPlayer): Boolean;
    class function ShowChangeNation(var Player: TPlayer): Boolean;
    class function ShowAgros(var Player: TPlayer): Boolean;
    class function ShowNivelament(var Player: TPlayer): Boolean;
    class function ShowDungeonDialog(var Player: TPlayer): Boolean;
    class procedure CloseOptions(var Player: TPlayer);
    class function SaveLocation(var Player: TPlayer; NpcId: WORD): Boolean;
    class function SignInCastle(var Player: TPlayer; NpcId: WORD): Boolean;
    class function EnterInCastle(var Player: TPlayer; NpcId: WORD): Boolean;
    class function GetQuest(var Player: TPlayer; QuestId: Cardinal;
      NpcId: Cardinal): Boolean;
    class function FinishQuest(var Player: TPlayer; QuestId: Cardinal): Boolean;

    class function DestroyAlliance(var Player: TPlayer): Boolean;
    class function RemoveMemberAlliance(var Player: TPlayer; SlotTo: Integer): Boolean;
    class function ExitAlliance(var Player: TPlayer): Boolean;
  private
    class procedure ShowNPCOption(var Player: TPlayer; Option: Integer);
  end;
implementation
uses Windows, GlobalDefs, PlayerData, FilesData, Functions, ItemFunctions,
  MiscData, SkillFunctions, GuildData, UpdateThreads;
class function TNPCHandlers.ShowOptions(var Player: TPlayer;
  var NPC: TNPC): Boolean;
var
  i: Integer;
begin
  Result := False;
  if (Player.Base.IsDead) then
    Exit;

  Player.SendSignal(Player.Base.ClientId, $110);
  if(Player.OpennedNPC = 0) then
  begin
    Player.SendData(Player.Base.ClientId, $10E, NPC.Base.ClientId);
  end;

  case NPC.Base.ClientId of
    2073: //Roberto Delfino NPC Alliance/Castle
      begin
        NPC.NPCFile.Header.Options[5] := 70; //desfazer alian鏰 (lider)
        NPC.NPCFile.Header.Options[6] := 71; //tirar guild 01
        NPC.NPCFile.Header.Options[7] := 72; //tirar guild 02
        NPC.NPCFile.Header.Options[8] := 73; //tirar guild 03
        NPC.NPCFile.Header.Options[9] := 74; //tirar guild 04
      end;

    2093: //teleport de regenchain
      begin
        NPC.NPCFile.Header.Options[0] := 67; //Ursula
        NPC.NPCFile.Header.Options[1] := 68; //Basilan [2500 gold]
        NPC.NPCFile.Header.Options[2] := 8; //Fechar
      end;

    2111: //teleport de ursula
      begin
        NPC.NPCFile.Header.Options[0] := 69; //Regenchain
        NPC.NPCFile.Header.Options[1] := 8; //Fechar
      end;

    2172: //teleport do castelo
      begin
        NPC.NPCFile.Header.Options[0] := 75; //voltar para regenchain
        NPC.NPCFile.Header.Options[1] := 76; //[Defesa] Torre 01
        NPC.NPCFile.Header.Options[2] := 77; //[Defesa] Torre 02
        NPC.NPCFile.Header.Options[3] := 78; //[Defesa] Torre 03
        NPC.NPCFile.Header.Options[4] := 8; //Fechar
      end;

    2196: //teleport de basilan
      begin
        NPC.NPCFile.Header.Options[0] := 69; //Regenchain
        NPC.NPCFile.Header.Options[1] := 8; //Fechar
      end;

  end;

  for i := 0 to 9 do
  begin
    if (NPC.NPCFile.Header.Options[i] > 0) and
      (NPC.NPCFile.Header.Options[i] < 80) then
    begin

      Self.ShowNPCOption(Player, NPC.NPCFile.Header.Options[i]);
    end;
  end;
  Result := True;
end;
class procedure TNPCHandlers.ShowNPCOption(var Player: TPlayer;
  Option: Integer);
var
  Packet: TShowOptionsPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.Size := sizeof(Packet);
  Packet.Header.Index := $3575;
  Packet.Header.Code := $112;
  Packet.Option := Option;

  case Option of
    8: //cor de fechar
    begin
      AnsiStrings.StrLCopy(Packet.Name, NPCOptionsText.Options[Option].Text,
        Length(NPCOptionsText.Options[Option].Text));
      Packet.Show := $FFEB5A5A;
    end;
    21: //cor de menu
    begin
      AnsiStrings.StrLCopy(Packet.Name, NPCOptionsText.Options[Option].Text,
        Length(NPCOptionsText.Options[Option].Text));
      Packet.Show := $FF7FC1F4;
    end;

    67:
      begin
        System.AnsiStrings.StrPLCopy(Packet.Name, 'Ir para Ursula', 64);
        Packet.Show := $FFffdb4d;
      end;
    68:
      begin
        System.AnsiStrings.StrPLCopy(Packet.Name, 'Ir para Basilan [2500 gold]', 64);
        Packet.Show := $FFe6b800;
      end;
    69:
      begin
        System.AnsiStrings.StrPLCopy(Packet.Name, 'Ir para Regenchain', 64);
        Packet.Show := $FFffdb4d;
      end;
    70:
      begin
        System.AnsiStrings.StrPLCopy(Packet.Name, 'Desfazer alian鏰', 64);
        Packet.Show := $FFEB5A5A;
      end;
    71:
      begin
        System.AnsiStrings.StrPLCopy(Packet.Name, 'Remover aliado 01', 64);
        Packet.Show := $FFEB5A5A;
      end;
    72:
      begin
        System.AnsiStrings.StrPLCopy(Packet.Name, 'Remover aliado 02', 64);
        Packet.Show := $FFEB5A5A;
      end;
    73:
      begin
        System.AnsiStrings.StrPLCopy(Packet.Name, 'Remover aliado 03', 64);
        Packet.Show := $FFEB5A5A;
      end;
    74:
      begin
        System.AnsiStrings.StrPLCopy(Packet.Name, 'Sair da alian鏰', 64);
        Packet.Show := $FFEB5A5A;
      end;
    75:
      begin
        System.AnsiStrings.StrPLCopy(Packet.Name, 'Voltar para Regenchain', 64);
        Packet.Show := $FF2eb82e;
      end;
    76:
      begin
        System.AnsiStrings.StrPLCopy(Packet.Name, '[Defesa] Torre 01', 64);
        Packet.Show := $FF33adff;
      end;
    77:
      begin
        System.AnsiStrings.StrPLCopy(Packet.Name, '[Defesa] Torre 02', 64);
        Packet.Show := $FF33adff;
      end;
    78:
      begin
        System.AnsiStrings.StrPLCopy(Packet.Name, '[Defesa] Torre 03', 64);
        Packet.Show := $FF33adff;
      end;
  else
    begin
      AnsiStrings.StrLCopy(Packet.Name, NPCOptionsText.Options[Option].Text,
        Length(NPCOptionsText.Options[Option].Text));
      Packet.Show := $FFFFFFFF;
    end;
  end;
  Player.SendPacket(Packet, Packet.Header.Size);
end;
class function TNPCHandlers.ShowShop(var Player: TPlayer;
  var NPC: TNPC): Boolean;
var
  Packet: TShowShopPacket;
  i: Integer;
begin
  Result := False;
  if (Player.Base.IsDead) then
    Exit;
  ZeroMemory(@Packet, sizeof(TShowShopPacket));
  Packet.Header.Size := $60;
  Packet.Header.Index := Player.Base.ClientId;
  Packet.Header.Code := $106;
  Packet.Index := NPC.Base.ClientId;
  Packet.DefByte := $C;
  for i := 0 to 39 do
    Packet.Items[i] := NPC.Character.Inventory[i].Index;
  Player.SendPacket(Packet, Packet.Header.Size);
  Result := True;
end;
class function TNPCHandlers.ShowSkills(var Player: TPlayer;
  var NPC: TNPC): Boolean;
begin
  Result := False;
  if (Player.Base.IsDead) then
    Exit;
  Player.SendPlayerSkills(NPC.Base.ClientId);
  Result := True;
end;
class function TNPCHandlers.ShowReinforce(var Player: TPlayer): Boolean;
begin
  Player.SendData(Player.Base.ClientId, $310, $5);
  Result := True;
end;
class function TNPCHandlers.ShowActionHouse(var Player: TPlayer): Boolean;
begin
  Player.SendData(Player.Base.ClientId, $310, $1A);
  Result := True;
end;
class function TNPCHandlers.SendTalk(var Player: TPlayer; NpcId: WORD): Boolean;
var
  Packet: TShowOptionsPacket;
  i: Integer;
begin
  Player.SendSignal(Player.Base.ClientId, $110);
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.Size := sizeof(Packet);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $112;
  Packet.Option := 21; // a op玢o do menu ?21
  Packet.Name := 'Menu';
  Packet.Show := $FF7FC1F4;
  Player.SendPacket(Packet, sizeof(Packet));
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.Size := sizeof(Packet);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $112;
  Packet.Option := 08;
  Packet.Name := 'Fechar';
  Packet.Show := $FFEB5A5A;
  Player.SendPacket(Packet, sizeof(Packet));
  Result := True;
end;
class function TNPCHandlers.SendQuests(var Player: TPlayer; NpcId: WORD;
  Type2: WORD): Boolean;
var
  Packet: TShowOptionsPacket;
  // MyQuest: QuestDin;
  Shower: Cardinal;
  i: Integer;
  QuestIndex: WORD;
begin
  Result := True;
  Player.SendSignal(Player.Base.ClientId, $110);
  if (Type2 <> 0) then // clicou no nome da miss鉶
  begin
    if (Player.QuestExists(Type2, QuestIndex)) then
    begin
      if(Player.PlayerQuests[QuestIndex].Quest.QuestMark = 11) then
      begin
        if(Player.PlayerQuests[QuestIndex].Complete[0] = 0) then
        begin
          ZeroMemory(@Packet, sizeof(Packet));
          Packet.Header.Size := sizeof(Packet);
          Packet.Header.Index := $7535;
          Packet.Header.Code := $112;
          Packet.Option := 22;
          Packet.Null := Type2;
          Packet.Name := 'Aceitar';
          Packet.Show := $FFD2EC7D;
          Player.SendPacket(Packet, sizeof(Packet));
        end
        else
        begin
          ZeroMemory(@Packet, sizeof(Packet));
          Packet.Header.Size := sizeof(Packet);
          Packet.Header.Index := $7535;
          Packet.Header.Code := $112;
          Packet.Option := 24;
          Packet.Null := Type2;
          Packet.Name := 'Entregar';
          Packet.Show := $FF9BEC7D;
          Player.SendPacket(Packet, sizeof(Packet));
        end;
        ZeroMemory(@Packet, sizeof(Packet));
        Packet.Header.Size := sizeof(Packet);
        Packet.Header.Index := $7535;
        Packet.Header.Code := $112;
        Packet.Option := 21; // a op玢o do menu ?21
        Packet.Name := 'Menu';
        Packet.Show := $FF7FC1F4;
        Player.SendPacket(Packet, sizeof(Packet));
        ZeroMemory(@Packet, sizeof(Packet));
        Packet.Header.Size := sizeof(Packet);
        Packet.Header.Index := $7535;
        Packet.Header.Code := $112;
        Packet.Option := 08;
        Packet.Name := 'Fechar';
        Packet.Show := $FFEB5A5A;
        Player.SendPacket(Packet, sizeof(Packet));
        Result := True;
        Exit;
      end
      else
      begin
        if(Player.PlayerQuests[QuestIndex].IsDone) then
        begin // ja fez a quest
          Player.SendData(Player.Base.ClientId, $10E, NpcId);
          Player.SendSignal(Player.Base.ClientId, $110);
          Exit;
        end;
      end;

     { if ((Player.PlayerQuests[QuestIndex].IsDone) and not(
        Player.PlayerQuests[QuestIndex].Quest.QuestMark = 11)) then
      begin
        Player.SendData(Player.Base.ClientId, $10E, NpcId);
        Player.SendSignal(Player.Base.ClientId, $110);
        Exit;
      end
      else if ((Player.PlayerQuests[QuestIndex].IsDone) and(
        Player.PlayerQuests[QuestIndex].Quest.QuestMark = 11)) then
      begin

      end; }
      if (Player.PlayerQuests[QuestIndex].Quest.LevelMin >
        Player.Base.Character.Level) then
      begin // n鉶 tem o level minimo
        Player.SendData(Player.Base.ClientId, $10E, NpcId);
        Player.SendSignal(Player.Base.ClientId, $110);
        Exit;
      end;
      if ((Player.PlayerQuests[QuestIndex].Quest.QuestId = 406) or
        (Player.PlayerQuests[QuestIndex].Quest.QuestId = 407)) then
      begin // pran evolution lv5 e lv20
        case Player.SpawnedPran of
          0:
            begin
              if (Player.PlayerQuests[QuestIndex].Quest.LevelMin >
                (Player.Account.Header.Pran1.Level + 1)) then
              begin
                Player.SendData(Player.Base.ClientId, $10E, NpcId);
                Player.SendSignal(Player.Base.ClientId, $110);
                Player.SendClientMessage('Sua pran deve estar lvl ' +
                  AnsiString(Player.PlayerQuests[QuestIndex]
                  .Quest.LevelMin.ToString) + ' pra essa miss鉶.');
                Exit;
              end;
            end;
          1:
            begin
              if (Player.PlayerQuests[QuestIndex].Quest.LevelMin >
                (Player.Account.Header.Pran2.Level + 1)) then
              begin
                Player.SendData(Player.Base.ClientId, $10E, NpcId);
                Player.SendSignal(Player.Base.ClientId, $110);
                Player.SendClientMessage('Sua pran deve estar lvl ' +
                  AnsiString(Player.PlayerQuests[QuestIndex]
                  .Quest.LevelMin.ToString) + ' pra essa miss鉶.');
                Exit;
              end;
            end;
        end;
      end;
      ZeroMemory(@Packet, sizeof(Packet));
      Packet.Header.Size := sizeof(Packet);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $112;
      Packet.Option := 24;
      Packet.Null := Type2;
      Packet.Name := 'Entregar';
      Packet.Show := $FF9BEC7D;
      Player.SendPacket(Packet, sizeof(Packet));
    end
    else
    begin
      ZeroMemory(@Packet, sizeof(Packet));
      Packet.Header.Size := sizeof(Packet);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $112;
      Packet.Option := 22;
      Packet.Null := Type2;
      Packet.Name := 'Aceitar';
      Packet.Show := $FFD2EC7D;
      Player.SendPacket(Packet, sizeof(Packet));
    end;
    ZeroMemory(@Packet, sizeof(Packet));
    Packet.Header.Size := sizeof(Packet);
    Packet.Header.Index := $7535;
    Packet.Header.Code := $112;
    Packet.Option := 21; // a op玢o do menu ?21
    Packet.Name := 'Menu';
    Packet.Show := $FF7FC1F4;
    Player.SendPacket(Packet, sizeof(Packet));
    ZeroMemory(@Packet, sizeof(Packet));
    Packet.Header.Size := sizeof(Packet);
    Packet.Header.Index := $7535;
    Packet.Header.Code := $112;
    Packet.Option := 08;
    Packet.Name := 'Fechar';
    Packet.Show := $FFEB5A5A;
    Player.SendPacket(Packet, sizeof(Packet));
    Result := True;
    Exit;
  end;
  for i := Low(Servers[Player.ChannelIndex].NPCS[NpcId].Base.NpcQuests)
    to High(Servers[Player.ChannelIndex].NPCS[NpcId].Base.NpcQuests) do
  begin // clicou pra exibir as missoes do npc
    if (Servers[Player.ChannelIndex].NPCS[NpcId].Base.NpcQuests[i].NpcId <>
      NpcId) then
      Continue;
    if (Servers[Player.ChannelIndex].NPCS[NpcId].Base.NpcQuests[i].LevelMin >
      Player.Base.Character.Level) then
      Continue;
    Shower := $FFFFFFFF;
    if (Player.QuestExists(Servers[Player.ChannelIndex].NPCS[NpcId]
      .Base.NpcQuests[i].QuestId, QuestIndex)) then
    begin
      if (Player.PlayerQuests[QuestIndex].IsDone) then
      begin
        if not(Player.PlayerQuests[QuestIndex].Quest.QuestMark = 11) then
          Continue;
      end;
      Shower := $FFEC7FF4;
    end;
    ZeroMemory(@Packet, sizeof(Packet));
    Packet.Header.Size := sizeof(Packet);
    Packet.Header.Index := $7535;
    Packet.Header.Code := $112;
    Packet.Option := 02;
    Packet.Null := Servers[Player.ChannelIndex].NPCS[NpcId].Base.NpcQuests
      [i].QuestId;
    Move(Quests[Servers[Player.ChannelIndex].NPCS[NpcId].Base.NpcQuests[i]
      .QuestId].Titulo, Packet.Name, 64);
    Packet.Show := Shower;
    Player.SendPacket(Packet, sizeof(Packet));
  end;
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.Size := sizeof(Packet);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $112;
  Packet.Option := 21; // a op玢o do menu ?21
  Packet.Name := 'Menu';
  Packet.Show := $FF7FC1F4;
  Player.SendPacket(Packet, sizeof(Packet));
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.Size := sizeof(Packet);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $112;
  Packet.Option := 08;
  Packet.Name := 'Fechar';
  Packet.Show := $FFEB5A5A;
  Player.SendPacket(Packet, sizeof(Packet));
  Result := True;
end;
class function TNPCHandlers.ShowDesmontItem(var Player: TPlayer): Boolean;
begin
  Player.SendData(Player.Base.ClientId, $310, $11);
  Result := True;
end;
class function TNPCHandlers.ShowRepareAllItens(var Player: TPlayer): Boolean;
begin
  Player.SendData(Player.Base.ClientId, $310, $F);
  Result := True;
end;
class function TNPCHandlers.ShowRepareItens(var Player: TPlayer): Boolean;
begin
  Player.SendData(Player.Base.ClientId, $310, $E);
  Result := True;
end;
class function TNPCHandlers.ShowPranEnchant(var Player: TPlayer): Boolean;
begin
  Player.SendData(Player.Base.ClientId, $310, $23);
  Result := True;
end;
class function TNPCHandlers.LilolaBuff(var Player: TPlayer;
  NpcId: WORD): Boolean;
begin
  Player.Base.AddBuff(6498, True);
  Player.Base.AddBuff(6499, True);
  Result := True;
end;
class procedure TNPCHandlers.CloseOptions(var Player: TPlayer);
begin
  Player.SendSignal(Player.Base.ClientId, $10F);
end;
class function TNPCHandlers.SaveLocation(var Player: TPlayer;
  NpcId: WORD): Boolean;
var
  Pos: TPosition;
begin
  Pos.X := Servers[Player.ChannelIndex].NPCS[NpcId]
    .Base.PlayerCharacter.LastPos.X + 1;
  Pos.Y := Servers[Player.ChannelIndex].NPCS[NpcId]
    .Base.PlayerCharacter.LastPos.Y + 1;
  if (Pos.IsValid) then
  begin
    if (Player.SaveSavedLocation(Pos)) then
      Player.SavedPos := Pos;
    Player.SendClientMessage('Localiza玢o salva.');
  end;
end;

class function TNPCHandlers.ShowAgros(var Player: TPlayer): Boolean;
begin
  Player.SendData(Player.Base.ClientId, $310, $15);
  Result := True;
end;
class function TNPCHandlers.ShowNivelament(var Player: TPlayer): Boolean;
begin
  Player.SendData(Player.Base.ClientId, $310, $8);
  Result := True;
end;
class function TNPCHandlers.ShowDungeonDialog(var Player: TPlayer): Boolean;
var
  Packet: TSendDungeonDialog;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.Size := sizeof(Packet);
  Packet.Header.Code := $119;
  Packet.Header.Index := $7535;
  case Player.OpennedNPC of
    DUNGEON_NPC_KINARY:
      begin
        Packet.Dungeon := DUNGEON_KINARY_AVIARY;
        Packet.LevelMin := Servers[Player.ChannelIndex].DGKinary[0].LevelMin;
      end;
    DUNGEON_NPC_MINA_1:
      begin
        Packet.Dungeon := DUNGEON_LOST_MINES;
        Packet.LevelMin := Servers[Player.ChannelIndex].DGMines1[0].LevelMin;
      end;
    DUNGEON_NPC_URSULA:
      begin
        Packet.Dungeon := DUNGEON_ZANTORIAN_CITADEL;
        Packet.LevelMin := Servers[Player.ChannelIndex].DGUrsula[0].LevelMin;
      end;
    DUNGEON_NPC_EVG_INF:
      begin
        Packet.Dungeon := DUNGEON_MARAUDER_HOLD;
        Packet.LevelMin := Servers[Player.ChannelIndex].DGEvgInf[0].LevelMin;
      end;
    DUNGEON_NPC_EVG_SUP:
      begin
        Packet.Dungeon := DUNGEON_MARAUDER_CABIN;
        Packet.LevelMin := Servers[Player.ChannelIndex].DGEvgSup[0].LevelMin;
      end;
  end;
  Packet.Entering := 1;
  Player.SendPacket(Packet, Packet.Header.Size);
  // Player.OpennedNPC := 0;
  // Player.OpennedOption := 0;
  Result := True;
end;
class function TNPCHandlers.ShowBigorna(var Player: TPlayer): Boolean;
begin
  Player.SendData(Player.Base.ClientId, $310, $4);
  Result := True;
end;
class function TNPCHandlers.ShowChangeApp(var Player: TPlayer): Boolean;
begin
  Player.SendData(Player.Base.ClientId, $310, $7);
  Result := True;
end;
class function TNPCHandlers.ShowChangeNation(var Player: TPlayer): Boolean;
begin
  Player.SendData(Player.Base.ClientId, $310, $9);
  Result := True;
end;
class function TNPCHandlers.ShowEnchant(var Player: TPlayer): Boolean;
begin
  Player.SendData(Player.Base.ClientId, $310, $6);
  Result := True;
end;
class function TNPCHandlers.ShowMountEnchant(var Player: TPlayer): Boolean;
begin
  Player.SendData(Player.Base.ClientId, $310, $17);
  Result := True;
end;
{ Quest Functions }
class function TNPCHandlers.GetQuest(var Player: TPlayer; QuestId: Cardinal;
  NpcId: Cardinal): Boolean;
var
  i: Integer;
  QuestIndex: WORD;
begin
  if not(Player.QuestExists(QuestId, QuestIndex)) then
  begin
    QuestIndex := Player.SearchEmptyQuestIndex;
    if (QuestIndex = 255) then
    begin
      Result := True;
      Player.SendClientMessage
        ('Sua lista de quests n鉶 pode receber mais quests.');
      Exit;
    end;
    Player.PlayerQuests[QuestIndex].ID := QuestId;
    for i := Low(_Quests) to High(_Quests) do
    begin
      if not(_Quests[i].QuestId = QuestId) then
        Continue;
      Move(_Quests[i], Player.PlayerQuests[QuestIndex].Quest,
        sizeof(TQuestMisc));
      break;
    end;
    Player.PlayerQuests[QuestIndex].IsDone := False;
    Player.PlayerQuests[QuestIndex].CreatedAt := Now;
    Player.PlayerQuests[QuestIndex].UpdatedAt := IncDay(Now, -1);
    Player.UpdateQuest(Player.PlayerQuests[QuestIndex].ID);
    Player.SendClientMessage('Voc?aceitou a quest [' +
      AnsiString(Quests[Player.PlayerQuests[QuestIndex].ID].Titulo) + ']');
  end
  else
  begin
    if(Player.PlayerQuests[QuestIndex].Quest.QuestMark = 11) then
    begin
      for I := 0 to 4 do
      begin
        Player.PlayerQuests[QuestIndex].Complete[i] := 0;
      end;
      Player.UpdateQuest(Player.PlayerQuests[QuestIndex].ID);
      Player.SendClientMessage('Voc?aceitou a quest [' +
        AnsiString(Quests[Player.PlayerQuests[QuestIndex].ID].Titulo) + ']');
      Player.PlayerQuests[QuestIndex].IsDone := False;
    end
    else
      Player.SendClientMessage('Quest j?existente.');
  end;

  Servers[Player.ChannelIndex].NPCS[Player.PlayerQuests[QuestIndex].Quest.NPCID]
    .Base.SendCreateMob(SPAWN_NORMAL, Player.Base.ClientID, False);

  Result := True;
end;
class function TNPCHandlers.FinishQuest(var Player: TPlayer;
  QuestId: Cardinal): Boolean;
var
  i,j,k: WORD;
  QuestIndex: WORD;
  Count, cnt_helper, Count2, Helper3: Integer;
  QuestAbort, ClearQuest, GuildLeveled: Boolean;
  PranID: Integer;
  Helper, Helper2, Helper4: Integer;
  TempleSpace: TSpaceTemple;
  OtherPlayer: PPlayer;
begin
  Result := True;
  QuestAbort := False;
  ClearQuest := False;
  if not(Player.QuestExists(QuestId, QuestIndex)) then
  begin
    Player.SendClientMessage('Quest n鉶 existente.');
    Exit;
  end;
  if (TItemFunctions.GetInvAvailableSlots(Player) = 0) then
  begin
    Player.SendClientMessage
      ('Voc?n鉶 pode finalizar uma quest com a bolsa cheia.');
    Exit;
  end;

  if(Player.PlayerQuests[QuestIndex].Quest.QuestMark = 11) then
  begin
    if(Player.PlayerQuests[QuestIndex].UpdatedAt > 0) then
    begin
      if(Player.PlayerQuests[QuestIndex].UpdatedAt.Day = Now.Day) then
      begin
        Player.SendClientMessage
          ('Voc?s?poder?finalizar essa miss鉶 amanh? ' + DateTimeToStr(
            IncDay(Player.PlayerQuests[QuestIndex].UpdatedAt, 1)));
        Exit;
      end;
    end;
  end;

  if (Player.PlayerQuests[QuestIndex].Quest.Requiriments[0] = 0) then
  begin // quest que n鉶 precisa de nada pra se completar
    for i := 0 to 5 do
    begin
      if (Player.PlayerQuests[QuestIndex].Quest.Rewards[i] = 0) then
        Continue;
      if not(Player.PlayerQuests[QuestIndex].Quest.QuestType = QuestPran) then
      begin
        TItemFunctions.PutItem(Player, Player.PlayerQuests[QuestIndex]
          .Quest.Rewards[i], 1);
      end // arrumar quantidade  //se for outro QuestType tem que fazer case aq
      else
      begin
        if (Player.Account.Header.Storage.Itens[84].Index = 0) then
        begin
          { if (Player.Account.Header.Storage.Itens[85].Index <> 0) then
            begin
            Player.SendClientMessage
            ('Voc?n鉶 pode criar uma pran no momento.');
            Player.SendClientMessage
            ('A sala de espera da Pran deve estar vazia.');
            QuestAbort := True;
            Continue;
            end; }
          // PranID := TFunctions.GetPranCreationID(Player);
          // possible exploit (esse numero s?vai subir se der erro)
          // if (PranID = -1) then
          // begin
          // Player.SendClientMessage('Tente novamente mais tarde.');
          // break;
          // end;
          if (Player.Account.Header.Pran1.AcciD = 0) then // isso aq era iddb
          begin
            // Player.Account.Header.Pran1.Iddb := PranID; ///
            // Player.Account.Header.Pran1.ItemID := PranID;  ////
            Player.Account.Header.Pran1.AcciD :=
              Player.Account.Header.AccountId;
            case Player.PlayerQuests[QuestIndex].Quest.QuestId of
              39: // pran do fogo
                begin
                  Player.Account.Header.Pran1.ClassPran := 61;
                  Player.Account.Header.Pran1.MaxHp := 383;
                  Player.Account.Header.Pran1.MaxMP := 235;
                  Player.Account.Header.Pran1.DefFis := 239;
                  Player.Account.Header.Pran1.DefMag := 104;
                  Player.Account.Header.Pran1.Skills[0].Index := 5761;
                  Player.Account.Header.Pran1.Skills[1].Index := 5771;
                  Player.Account.Header.Pran1.Skills[2].Index := 5781;
                  Player.Account.Header.Pran1.Skills[3].Index := 5791;
                  Player.Account.Header.Pran1.Skills[4].Index := 5801;
                  Player.Account.Header.Pran1.Skills[5].Index := 5811;
                  Player.Account.Header.Pran1.Skills[6].Index := 5821;
                  Player.Account.Header.Pran1.Skills[7].Index := 5831;
                  Player.Account.Header.Pran1.Skills[8].Index := 5841;
                  Player.Account.Header.Pran1.Skills[9].Index := 5851;
                  // as 3 primeiras skills t阭 lv1
                  Player.Account.Header.Pran1.Skills[0].Level := 1;
                  Player.Account.Header.Pran1.Skills[1].Level := 1;
                  Player.Account.Header.Pran1.Skills[2].Level := 1;
                  // Bravura lv1
                end;
              40: // pran da agua
                begin
                  Player.Account.Header.Pran1.ClassPran := 71;
                  Player.Account.Header.Pran1.MaxHp := 209;
                  Player.Account.Header.Pran1.MaxMP := 356;
                  Player.Account.Header.Pran1.DefFis := 153;
                  Player.Account.Header.Pran1.DefMag := 308;
                  Player.Account.Header.Pran1.Skills[0].Index := 5861;
                  // Coragem lv1
                  Player.Account.Header.Pran1.Skills[1].Index := 5871;
                  Player.Account.Header.Pran1.Skills[2].Index := 5881;
                  Player.Account.Header.Pran1.Skills[3].Index := 5891;
                  Player.Account.Header.Pran1.Skills[4].Index := 5901;
                  Player.Account.Header.Pran1.Skills[5].Index := 5911;
                  Player.Account.Header.Pran1.Skills[6].Index := 5921;
                  Player.Account.Header.Pran1.Skills[7].Index := 5931;
                  Player.Account.Header.Pran1.Skills[8].Index := 5941;
                  Player.Account.Header.Pran1.Skills[9].Index := 5951;
                  Player.Account.Header.Pran1.Skills[0].Level := 1;
                  Player.Account.Header.Pran1.Skills[1].Level := 1;
                  Player.Account.Header.Pran1.Skills[2].Level := 1;
                end;
              41: // pran do ar
                begin
                  Player.Account.Header.Pran1.ClassPran := 81;
                  Player.Account.Header.Pran1.MaxHp := 255;
                  Player.Account.Header.Pran1.MaxMP := 267;
                  Player.Account.Header.Pran1.DefFis := 201;
                  Player.Account.Header.Pran1.DefMag := 205;
                  Player.Account.Header.Pran1.Skills[0].Index := 5961;
                  // Coragem lv1
                  Player.Account.Header.Pran1.Skills[1].Index := 5971;
                  Player.Account.Header.Pran1.Skills[2].Index := 5981;
                  Player.Account.Header.Pran1.Skills[3].Index := 5991;
                  Player.Account.Header.Pran1.Skills[4].Index := 6001;
                  Player.Account.Header.Pran1.Skills[5].Index := 6011;
                  Player.Account.Header.Pran1.Skills[6].Index := 6021;
                  Player.Account.Header.Pran1.Skills[7].Index := 6031;
                  Player.Account.Header.Pran1.Skills[8].Index := 6041;
                  Player.Account.Header.Pran1.Skills[9].Index := 6051;
                  Player.Account.Header.Pran1.Skills[0].Level := 1;
                  Player.Account.Header.Pran1.Skills[1].Level := 1;
                  Player.Account.Header.Pran1.Skills[2].Level := 1;
                end;
            end;
            Player.Account.Header.Pran1.CurHP :=
              Player.Account.Header.Pran1.MaxHp;
            Player.Account.Header.Pran1.CurMp :=
              Player.Account.Header.Pran1.MaxMP;
            Player.Account.Header.Pran1.Exp := 1;
            Player.Account.Header.Pran1.Food := 121;
            Player.Account.Header.Pran1.Devotion := 113;
            Player.Account.Header.Pran1.Personality.Cute := 226;
            Player.Account.Header.Pran1.Personality.Smart := 50;
            Player.Account.Header.Pran1.Personality.Sexy := 50;
            Player.Account.Header.Pran1.Personality.Energetic := 50;
            Player.Account.Header.Pran1.Personality.Tough := 50;
            Player.Account.Header.Pran1.Personality.Corrupt := 50;
            Player.Account.Header.Pran1.Width := 7;
            Player.Account.Header.Pran1.Chest := 100;
            Player.Account.Header.Pran1.Leg := 100;
            Player.Account.Header.Pran1.CreatedAt :=
              TFunctions.DateTimeToUNIXTimeFAST(Now);
            Player.Account.Header.Pran1.Updated_at :=
              TFunctions.DateTimeToUNIXTimeFAST(Now);
            Player.Account.Header.Pran1.Equip[0].Index := Player.PlayerQuests
              [QuestIndex].Quest.Rewards[i];
            Player.Account.Header.Pran1.Equip[0].APP := Player.PlayerQuests
              [QuestIndex].Quest.Rewards[i];
            Player.Account.Header.Pran1.Equip[6].Index := 7780;
            Player.Account.Header.Pran1.Equip[6].APP := 7780;
            Player.Account.Header.Pran1.Inventory[40].Index := 5301;
            Player.Account.Header.Pran1.Inventory[40].APP := 5301;
            Player.Account.Header.Pran1.Inventory[40].Refi := 1;
            if (TFunctions.SavePranCreated(Player, Player.Account.Header.Pran1)
              = True) then
            begin
              PranID := Player.Account.Header.Pran1.Iddb;
            end
            else
              Exit;
          end
          else if (Player.Account.Header.Pran2.AcciD = 0) then
          begin
            // Player.Account.Header.Pran2.Iddb := PranID;
            // Player.Account.Header.Pran2.ItemID := PranID;
            Player.Account.Header.Pran2.AcciD :=
              Player.Account.Header.AccountId;
            case Player.PlayerQuests[QuestIndex].Quest.QuestId of
              39: // pran do fogo
                begin
                  Player.Account.Header.Pran2.ClassPran := 61;
                  Player.Account.Header.Pran2.MaxHp := 383;
                  Player.Account.Header.Pran2.MaxMP := 235;
                  Player.Account.Header.Pran2.DefFis := 239;
                  Player.Account.Header.Pran2.DefMag := 104;
                  Player.Account.Header.Pran2.Skills[0].Index := 5761;
                  // Bravura lv1
                  Player.Account.Header.Pran2.Skills[1].Index := 5771;
                  Player.Account.Header.Pran2.Skills[2].Index := 5781;
                  Player.Account.Header.Pran2.Skills[3].Index := 5791;
                  Player.Account.Header.Pran2.Skills[4].Index := 5801;
                  Player.Account.Header.Pran2.Skills[5].Index := 5811;
                  Player.Account.Header.Pran2.Skills[6].Index := 5821;
                  Player.Account.Header.Pran2.Skills[7].Index := 5831;
                  Player.Account.Header.Pran2.Skills[8].Index := 5841;
                  Player.Account.Header.Pran2.Skills[9].Index := 5851;
                  Player.Account.Header.Pran2.Skills[0].Level := 1;
                  Player.Account.Header.Pran2.Skills[1].Level := 1;
                  Player.Account.Header.Pran2.Skills[2].Level := 1;
                end;
              40: // pran da agua
                begin
                  Player.Account.Header.Pran2.ClassPran := 71;
                  Player.Account.Header.Pran2.MaxHp := 209;
                  Player.Account.Header.Pran2.MaxMP := 356;
                  Player.Account.Header.Pran2.DefFis := 153;
                  Player.Account.Header.Pran2.DefMag := 308;
                  Player.Account.Header.Pran2.Skills[0].Index := 5861;
                  // Coragem lv1
                  Player.Account.Header.Pran2.Skills[1].Index := 5871;
                  Player.Account.Header.Pran2.Skills[2].Index := 5881;
                  Player.Account.Header.Pran2.Skills[3].Index := 5891;
                  Player.Account.Header.Pran2.Skills[4].Index := 5901;
                  Player.Account.Header.Pran2.Skills[5].Index := 5911;
                  Player.Account.Header.Pran2.Skills[6].Index := 5921;
                  Player.Account.Header.Pran2.Skills[7].Index := 5931;
                  Player.Account.Header.Pran2.Skills[8].Index := 5941;
                  Player.Account.Header.Pran2.Skills[9].Index := 5951;
                  Player.Account.Header.Pran2.Skills[0].Level := 1;
                  Player.Account.Header.Pran2.Skills[1].Level := 1;
                  Player.Account.Header.Pran2.Skills[2].Level := 1;
                end;
              41: // pran do ar
                begin
                  Player.Account.Header.Pran2.ClassPran := 81;
                  Player.Account.Header.Pran2.MaxHp := 255;
                  Player.Account.Header.Pran2.MaxMP := 267;
                  Player.Account.Header.Pran2.DefFis := 201;
                  Player.Account.Header.Pran2.DefMag := 205;
                  Player.Account.Header.Pran2.Skills[0].Index := 5961;
                  // Coragem lv1
                  Player.Account.Header.Pran2.Skills[1].Index := 5971;
                  Player.Account.Header.Pran2.Skills[2].Index := 5981;
                  Player.Account.Header.Pran2.Skills[3].Index := 5991;
                  Player.Account.Header.Pran2.Skills[4].Index := 6001;
                  Player.Account.Header.Pran2.Skills[5].Index := 6011;
                  Player.Account.Header.Pran2.Skills[6].Index := 6021;
                  Player.Account.Header.Pran2.Skills[7].Index := 6031;
                  Player.Account.Header.Pran2.Skills[8].Index := 6041;
                  Player.Account.Header.Pran2.Skills[9].Index := 6051;
                  Player.Account.Header.Pran2.Skills[0].Level := 1;
                  Player.Account.Header.Pran2.Skills[1].Level := 1;
                  Player.Account.Header.Pran2.Skills[2].Level := 1;
                end;
            end;
            Player.Account.Header.Pran2.CurHP :=
              Player.Account.Header.Pran2.MaxHp;
            Player.Account.Header.Pran2.CurMp :=
              Player.Account.Header.Pran2.MaxMP;
            Player.Account.Header.Pran2.Exp := 1;
            Player.Account.Header.Pran2.Food := 121;
            Player.Account.Header.Pran2.Devotion := 113;
            Player.Account.Header.Pran2.Personality.Cute := 226;
            Player.Account.Header.Pran2.Personality.Smart := 50;
            Player.Account.Header.Pran2.Personality.Sexy := 50;
            Player.Account.Header.Pran2.Personality.Energetic := 50;
            Player.Account.Header.Pran2.Personality.Tough := 50;
            Player.Account.Header.Pran2.Personality.Corrupt := 50;
            Player.Account.Header.Pran2.Width := 7;
            Player.Account.Header.Pran2.Chest := 100;
            Player.Account.Header.Pran2.Leg := 100;
            Player.Account.Header.Pran2.CreatedAt :=
              TFunctions.DateTimeToUNIXTimeFAST(Now);
            Player.Account.Header.Pran2.Updated_at :=
              TFunctions.DateTimeToUNIXTimeFAST(Now);
            Player.Account.Header.Pran2.Equip[0].Index := Player.PlayerQuests
              [QuestIndex].Quest.Rewards[i];
            Player.Account.Header.Pran2.Equip[0].APP := Player.PlayerQuests
              [QuestIndex].Quest.Rewards[i];
            Player.Account.Header.Pran2.Equip[6].Index := 7780;
            Player.Account.Header.Pran2.Equip[6].APP := 7780;
            Player.Account.Header.Pran2.Inventory[40].Index := 5301;
            Player.Account.Header.Pran2.Inventory[40].APP := 5301;
            Player.Account.Header.Pran2.Inventory[40].Refi := 1;
            if (TFunctions.SavePranCreated(Player, Player.Account.Header.Pran2)
              = True) then
            begin
              PranID := Player.Account.Header.Pran2.Iddb;
            end
            else
              Exit;
          end
          else
          begin
            Player.SendClientMessage('Voc?j?possui 2 prans');
            QuestAbort := True;
            Continue;
          end;
          Player.Account.Header.Storage.Itens[84].Index := Player.PlayerQuests
            [QuestIndex].Quest.Rewards[i];
          Player.Account.Header.Storage.Itens[84].APP :=
            Player.Account.Header.Storage.Itens[84].Index;
          Player.Base.SendRefreshItemSlot(STORAGE_TYPE, 84,
            Player.Account.Header.Storage.Itens[84], False);
          Player.Account.Header.Storage.Itens[84].Identific := PranID;
          if ((Player.Account.Header.Pran1.ItemID = PranID) and
            (Player.Account.Header.Pran2.Iddb = 0)) then
          begin
            Player.AddTitle(17, 1);
            // Player.SendClientMessage
            // ('?recomendado criar as duas prans seguidas, para evitar bugs ' +
            // 'e erros na sua conta.');
          end;
        end
        else if (Player.Account.Header.Storage.Itens[85].Index = 0) then
        begin
          { if (Player.Account.Header.Storage.Itens[84].Index <> 0) then
            begin
            Player.SendClientMessage
            ('Voc?n鉶 pode criar uma pran no momento.');
            Player.SendClientMessage
            ('A sala de espera da Pran deve estar vazia.');
            QuestAbort := True;
            Continue;
            end; }
          // PranID := TFunctions.GetPranCreationID(Player);
          // if (PranID = -1) then
          // begin
          // Player.SendClientMessage('Tente novamente mais tarde.');
          // break;
          // end;
          // possible exploit (esse numero s?vai subir se der erro)
          if (Player.Account.Header.Pran1.AcciD = 0) then
          begin
            // Player.Account.Header.Pran1.Iddb := PranID;
            // Player.Account.Header.Pran1.ItemID := PranID;
            Player.Account.Header.Pran1.AcciD :=
              Player.Account.Header.AccountId;
            case Player.PlayerQuests[QuestIndex].Quest.QuestId of
              39: // pran do fogo
                begin
                  Player.Account.Header.Pran1.ClassPran := 61;
                  Player.Account.Header.Pran1.MaxHp := 383;
                  Player.Account.Header.Pran1.MaxMP := 235;
                  Player.Account.Header.Pran1.DefFis := 239;
                  Player.Account.Header.Pran1.DefMag := 104;
                  Player.Account.Header.Pran1.Skills[0].Index := 5761;
                  // Bravura lv1
                  Player.Account.Header.Pran1.Skills[1].Index := 5771;
                  Player.Account.Header.Pran1.Skills[2].Index := 5781;
                  Player.Account.Header.Pran1.Skills[3].Index := 5791;
                  Player.Account.Header.Pran1.Skills[4].Index := 5801;
                  Player.Account.Header.Pran1.Skills[5].Index := 5811;
                  Player.Account.Header.Pran1.Skills[6].Index := 5821;
                  Player.Account.Header.Pran1.Skills[7].Index := 5831;
                  Player.Account.Header.Pran1.Skills[8].Index := 5841;
                  Player.Account.Header.Pran1.Skills[9].Index := 5851;
                  Player.Account.Header.Pran1.Skills[0].Level := 1;
                  Player.Account.Header.Pran1.Skills[1].Level := 1;
                  Player.Account.Header.Pran1.Skills[2].Level := 1;
                end;
              40: // pran da agua
                begin
                  Player.Account.Header.Pran1.ClassPran := 71;
                  Player.Account.Header.Pran1.MaxHp := 209;
                  Player.Account.Header.Pran1.MaxMP := 356;
                  Player.Account.Header.Pran1.DefFis := 153;
                  Player.Account.Header.Pran1.DefMag := 308;
                  Player.Account.Header.Pran1.Skills[0].Index := 5861;
                  // Coragem lv1
                  Player.Account.Header.Pran1.Skills[1].Index := 5871;
                  Player.Account.Header.Pran1.Skills[2].Index := 5881;
                  Player.Account.Header.Pran1.Skills[3].Index := 5891;
                  Player.Account.Header.Pran1.Skills[4].Index := 5901;
                  Player.Account.Header.Pran1.Skills[5].Index := 5911;
                  Player.Account.Header.Pran1.Skills[6].Index := 5921;
                  Player.Account.Header.Pran1.Skills[7].Index := 5931;
                  Player.Account.Header.Pran1.Skills[8].Index := 5941;
                  Player.Account.Header.Pran1.Skills[9].Index := 5951;
                  Player.Account.Header.Pran1.Skills[0].Level := 1;
                  Player.Account.Header.Pran1.Skills[1].Level := 1;
                  Player.Account.Header.Pran1.Skills[2].Level := 1;
                end;
              41: // pran do ar
                begin
                  Player.Account.Header.Pran1.ClassPran := 81;
                  Player.Account.Header.Pran1.MaxHp := 255;
                  Player.Account.Header.Pran1.MaxMP := 267;
                  Player.Account.Header.Pran1.DefFis := 201;
                  Player.Account.Header.Pran1.DefMag := 205;
                  Player.Account.Header.Pran1.Skills[0].Index := 5961;
                  // Coragem lv1
                  Player.Account.Header.Pran1.Skills[1].Index := 5971;
                  Player.Account.Header.Pran1.Skills[2].Index := 5981;
                  Player.Account.Header.Pran1.Skills[3].Index := 5991;
                  Player.Account.Header.Pran1.Skills[4].Index := 6001;
                  Player.Account.Header.Pran1.Skills[5].Index := 6011;
                  Player.Account.Header.Pran1.Skills[6].Index := 6021;
                  Player.Account.Header.Pran1.Skills[7].Index := 6031;
                  Player.Account.Header.Pran1.Skills[8].Index := 6041;
                  Player.Account.Header.Pran1.Skills[9].Index := 6051;
                  Player.Account.Header.Pran1.Skills[0].Level := 1;
                  Player.Account.Header.Pran1.Skills[1].Level := 1;
                  Player.Account.Header.Pran1.Skills[2].Level := 1;
                end;
            end;
            Player.Account.Header.Pran1.CurHP :=
              Player.Account.Header.Pran1.MaxHp;
            Player.Account.Header.Pran1.CurMp :=
              Player.Account.Header.Pran1.MaxMP;
            Player.Account.Header.Pran1.Exp := 1;
            Player.Account.Header.Pran1.Food := 121;
            Player.Account.Header.Pran1.Devotion := 113;
            Player.Account.Header.Pran1.Personality.Cute := 226;
            Player.Account.Header.Pran1.Personality.Smart := 50;
            Player.Account.Header.Pran1.Personality.Sexy := 50;
            Player.Account.Header.Pran1.Personality.Energetic := 50;
            Player.Account.Header.Pran1.Personality.Tough := 50;
            Player.Account.Header.Pran1.Personality.Corrupt := 50;
            Player.Account.Header.Pran1.Width := 7;
            Player.Account.Header.Pran1.Chest := 100;
            Player.Account.Header.Pran1.Leg := 100;
            Player.Account.Header.Pran1.CreatedAt :=
              TFunctions.DateTimeToUNIXTimeFAST(Now);
            Player.Account.Header.Pran1.Updated_at :=
              TFunctions.DateTimeToUNIXTimeFAST(Now);
            Player.Account.Header.Pran1.Equip[0].Index := Player.PlayerQuests
              [QuestIndex].Quest.Rewards[i];
            Player.Account.Header.Pran1.Equip[0].APP := Player.PlayerQuests
              [QuestIndex].Quest.Rewards[i];
            Player.Account.Header.Pran1.Equip[6].Index := 7780;
            Player.Account.Header.Pran1.Equip[6].APP := 7780;
            Player.Account.Header.Pran1.Inventory[40].Index := 5301;
            Player.Account.Header.Pran1.Inventory[40].APP := 5301;
            Player.Account.Header.Pran1.Inventory[40].Refi := 1;
            if (TFunctions.SavePranCreated(Player, Player.Account.Header.Pran1)
              = True) then
            begin
              PranID := Player.Account.Header.Pran1.Iddb;
            end
            else
              Exit;
          end
          else if (Player.Account.Header.Pran2.AcciD = 0) then
          begin
            // Player.Account.Header.Pran2.Iddb := PranID;
            // Player.Account.Header.Pran2.ItemID := PranID;
            Player.Account.Header.Pran2.AcciD :=
              Player.Account.Header.AccountId;
            case Player.PlayerQuests[QuestIndex].Quest.QuestId of
              39: // pran do fogo
                begin
                  Player.Account.Header.Pran2.ClassPran := 61;
                  Player.Account.Header.Pran2.MaxHp := 383;
                  Player.Account.Header.Pran2.MaxMP := 235;
                  Player.Account.Header.Pran2.DefFis := 239;
                  Player.Account.Header.Pran2.DefMag := 104;
                  Player.Account.Header.Pran2.Skills[0].Index := 5761;
                  // Bravura lv1
                  Player.Account.Header.Pran2.Skills[1].Index := 5771;
                  Player.Account.Header.Pran2.Skills[2].Index := 5781;
                  Player.Account.Header.Pran2.Skills[3].Index := 5791;
                  Player.Account.Header.Pran2.Skills[4].Index := 5801;
                  Player.Account.Header.Pran2.Skills[5].Index := 5811;
                  Player.Account.Header.Pran2.Skills[6].Index := 5821;
                  Player.Account.Header.Pran2.Skills[7].Index := 5831;
                  Player.Account.Header.Pran2.Skills[8].Index := 5841;
                  Player.Account.Header.Pran2.Skills[9].Index := 5851;
                  Player.Account.Header.Pran2.Skills[0].Level := 1;
                  Player.Account.Header.Pran2.Skills[1].Level := 1;
                  Player.Account.Header.Pran2.Skills[2].Level := 1;
                end;
              40: // pran da agua
                begin
                  Player.Account.Header.Pran2.ClassPran := 71;
                  Player.Account.Header.Pran2.MaxHp := 209;
                  Player.Account.Header.Pran2.MaxMP := 356;
                  Player.Account.Header.Pran2.DefFis := 153;
                  Player.Account.Header.Pran2.DefMag := 308;
                  Player.Account.Header.Pran2.Skills[0].Index := 5861;
                  // Coragem lv1
                  Player.Account.Header.Pran2.Skills[1].Index := 5871;
                  Player.Account.Header.Pran2.Skills[2].Index := 5881;
                  Player.Account.Header.Pran2.Skills[3].Index := 5891;
                  Player.Account.Header.Pran2.Skills[4].Index := 5901;
                  Player.Account.Header.Pran2.Skills[5].Index := 5911;
                  Player.Account.Header.Pran2.Skills[6].Index := 5921;
                  Player.Account.Header.Pran2.Skills[7].Index := 5931;
                  Player.Account.Header.Pran2.Skills[8].Index := 5941;
                  Player.Account.Header.Pran2.Skills[9].Index := 5951;
                  Player.Account.Header.Pran2.Skills[0].Level := 1;
                  Player.Account.Header.Pran2.Skills[1].Level := 1;
                  Player.Account.Header.Pran2.Skills[2].Level := 1;
                end;
              41: // pran do ar
                begin
                  Player.Account.Header.Pran2.ClassPran := 81;
                  Player.Account.Header.Pran2.MaxHp := 255;
                  Player.Account.Header.Pran2.MaxMP := 267;
                  Player.Account.Header.Pran2.DefFis := 201;
                  Player.Account.Header.Pran2.DefMag := 205;
                  Player.Account.Header.Pran2.Skills[0].Index := 5961;
                  // Coragem lv1
                  Player.Account.Header.Pran2.Skills[1].Index := 5971;
                  Player.Account.Header.Pran2.Skills[2].Index := 5981;
                  Player.Account.Header.Pran2.Skills[3].Index := 5991;
                  Player.Account.Header.Pran2.Skills[4].Index := 6001;
                  Player.Account.Header.Pran2.Skills[5].Index := 6011;
                  Player.Account.Header.Pran2.Skills[6].Index := 6021;
                  Player.Account.Header.Pran2.Skills[7].Index := 6031;
                  Player.Account.Header.Pran2.Skills[8].Index := 6041;
                  Player.Account.Header.Pran2.Skills[9].Index := 6051;
                  Player.Account.Header.Pran2.Skills[0].Level := 1;
                  Player.Account.Header.Pran2.Skills[1].Level := 1;
                  Player.Account.Header.Pran2.Skills[2].Level := 1;
                end;
            end;
            Player.Account.Header.Pran2.CurHP :=
              Player.Account.Header.Pran2.MaxHp;
            Player.Account.Header.Pran2.CurMp :=
              Player.Account.Header.Pran2.MaxMP;
            Player.Account.Header.Pran2.Exp := 1;
            Player.Account.Header.Pran2.Food := 121;
            Player.Account.Header.Pran2.Devotion := 113;
            Player.Account.Header.Pran2.Personality.Cute := 226;
            Player.Account.Header.Pran2.Personality.Smart := 50;
            Player.Account.Header.Pran2.Personality.Sexy := 50;
            Player.Account.Header.Pran2.Personality.Energetic := 50;
            Player.Account.Header.Pran2.Personality.Tough := 50;
            Player.Account.Header.Pran2.Personality.Corrupt := 50;
            Player.Account.Header.Pran2.Width := 7;
            Player.Account.Header.Pran2.Chest := 100;
            Player.Account.Header.Pran2.Leg := 100;
            Player.Account.Header.Pran2.CreatedAt :=
              TFunctions.DateTimeToUNIXTimeFAST(Now);
            Player.Account.Header.Pran2.Updated_at :=
              TFunctions.DateTimeToUNIXTimeFAST(Now);
            Player.Account.Header.Pran2.Equip[0].Index := Player.PlayerQuests
              [QuestIndex].Quest.Rewards[i];
            Player.Account.Header.Pran2.Equip[0].APP := Player.PlayerQuests
              [QuestIndex].Quest.Rewards[i];
            Player.Account.Header.Pran2.Equip[6].Index := 7780;
            Player.Account.Header.Pran2.Equip[6].APP := 7780;
            Player.Account.Header.Pran2.Inventory[40].Index := 5301;
            Player.Account.Header.Pran2.Inventory[40].APP := 5301;
            Player.Account.Header.Pran2.Inventory[40].Refi := 1;
            if (TFunctions.SavePranCreated(Player, Player.Account.Header.Pran2)
              = True) then
            begin
              PranID := Player.Account.Header.Pran2.Iddb;
            end
            else
              Exit;
          end
          else
          begin
            Player.SendClientMessage('Voc?j?possui 2 prans');
            QuestAbort := True;
            Continue;
          end;
          Player.Account.Header.Storage.Itens[85].Index := Player.PlayerQuests
            [QuestIndex].Quest.Rewards[i];
          Player.Account.Header.Storage.Itens[85].APP :=
            Player.Account.Header.Storage.Itens[85].Index;
          Player.Base.SendRefreshItemSlot(STORAGE_TYPE, 85,
            Player.Account.Header.Storage.Itens[85], False);
          Player.Account.Header.Storage.Itens[85].Identific := PranID
        end
        else
        begin // sem espa鏾 disponivel
          Player.SendClientMessage('N鉶 h?espa鏾 dispon韛el.');
        end;
      end;
    end;
    if not(QuestAbort) then
    begin
      if not(Player.PlayerQuests[QuestIndex].IsDone) then
      begin
        Player.SendExpGoldMsg(Player.PlayerQuests[QuestIndex].Quest.Exp,
          Player.PlayerQuests[QuestIndex].Quest.Gold);
        Player.AddGold(Player.PlayerQuests[QuestIndex].Quest.Gold);
        Player.AddExp(Player.PlayerQuests[QuestIndex].Quest.Exp, Helper);
      end;
      Player.RemoveQuest(QuestId);
      Player.PlayerQuests[QuestIndex].IsDone := True;

      Servers[Player.ChannelIndex].NPCS[Player.PlayerQuests[QuestIndex].Quest.NPCID]
        .Base.SendCreateMob(SPAWN_NORMAL, Player.Base.ClientID, False);
    end;
  end
  else // quest que precisa de alguma coisa pra completar
  begin
    case Player.PlayerQuests[QuestIndex].Quest.QuestType of
      QuestKillMob: // quest que completou ao matar mob
        begin
          Count := 0;
          Count2 := 0;
          for i := 0 to 4 do
          begin
            if(Player.PlayerQuests[QuestIndex].Quest.RequirimentsAmount[i] = 0) then
              Continue
            else
              Inc(Count2);

            if (Player.PlayerQuests[QuestIndex].Complete[i] >=
              Player.PlayerQuests[QuestIndex].Quest.RequirimentsAmount[i]) then
            begin
              if not(Player.PlayerQuests[QuestIndex].Complete[i] = 0) then
              begin  //Helper4
                if(Player.PlayerQuests[QuestIndex].Quest.RequirimentsType[i] = QuestItem) then
                begin
                  Helper4 := TItemFunctions.GetItemSlot2(Player,
                    Player.PlayerQuests[QuestIndex].Quest.Requiriments[i]);

                  if(Helper4 < 60) then
                  begin
                    if(Player.Base.Character.Inventory[Helper4].Refi >=
                      Player.PlayerQuests[QuestIndex].Quest.RequirimentsAmount[i]) then
                        Inc(Count);
                  end;
                end
                else
                  Inc(Count);
              end;
            end;
          end;
if ((Count >= Count2) and (Count2 > 0) and (Count > 0)) then
begin
  for i := 0 to 5 do
  begin
    if not(i = 5) then
    begin
      if (Player.PlayerQuests[QuestIndex].Quest.RequirimentsType[i] = QuestItem) then
      begin
        Helper3 := TItemFunctions.GetItemSlot2(Player,
          Player.PlayerQuests[QuestIndex].Quest.Requiriments[i]);

        if (Helper3 = 255) then
          Continue;

        TItemFunctions.DecreaseAmount(Player, Helper3,
          Player.PlayerQuests[QuestIndex].Quest.RequirimentsAmount[i]);
        Player.Base.SendRefreshItemSlot(INV_TYPE, Helper3,
          Player.Base.Character.Inventory[Helper3], False);
      end;
    end;

    if (Player.PlayerQuests[QuestIndex].Quest.Rewards[i] = 0) then
      Continue;      // 调整数量
    TItemFunctions.PutItem(Player, Player.PlayerQuests[QuestIndex]
      .Quest.Rewards[i], 1);
  end;
end;


            case Player.PlayerQuests[QuestIndex].Quest.QuestId of
              406: // isso aqui ?a quest Evolucao pran Lv5
                begin
                  if(Player.Base.Character.Equip[10].Index = 0) then
                  begin
                    Player.SendClientMessage
                      ('Voc?deve equipar uma pran para este procedimento.');
                    Exit;
                  end;

                  case Player.SpawnedPran of
                    0:
                      begin
                        if (Player.Account.Header.Pran1.Level = 4) then
                        begin
                          case Player.Account.Header.Pran1.ClassPran of
                            61, 71, 81:
                              begin
                                if (Player.Account.Header.Pran2.ID > 0) then
                                begin
                                  case Player.Account.Header.Pran2.ClassPran of
                                    61, 71, 81:
                                      begin
                                        ClearQuest := True;
                                      end;
                                  end;
                                end
                                else
                                  ClearQuest := True;
                              end;
                          else
                            begin
                              Player.SendClientMessage
                                ('Essa pran n鉶 pode ser upada de classe.');
                              Exit;
                            end;
                          end;
                          Inc(Player.Account.Header.Pran1.ClassPran);
                          Player.Account.Header.Pran1.Equip[0].Index := 104;
                          Player.Account.Header.Pran1.Equip[0].APP := 104;
                          //Player.Account.Header.Pran1.Equip[1].Index := 150;
                          //Player.Account.Header.Pran1.Equip[1].APP := 150;
                          Player.Account.Header.Pran1.Equip[6].Index := 150;
                          Player.Account.Header.Pran1.Equip[6].APP := 150;
                          Player.Base.Character.Equip[10].Index := 104;
                          Player.Base.Character.Equip[10].APP := 104;
                          // Player.Base.SendRefreshItemSlot(PRAN_EQUIP_TYPE, 0,
                          // Player.Account.Header.Pran1.Equip[0], False);
                          // Player.Base.SendRefreshItemSlot(PRAN_EQUIP_TYPE, 0,
                          // Player.Account.Header.Pran1.Equip[6], False);
                          // Player.Base.SendRefreshItemSlot(EQUIP_TYPE, 0,
                          // Player.Base.Character.Equip[10], False);
                          Inc(Player.Account.Header.Pran1.Skills[3].Level);
                          // fazer atualizar o item do personagem
                          // fazer criar a skill pranskill[3] "transformar"
                          // essa skill nao pode evoluir no mobkilled exp pran
                          Player.SendEffect(0);
                          Player.SendPranToWorld(0);
                          Player.SendPranSpawn(0);
                          Player.Base.SendRefreshItemSlot(EQUIP_TYPE, 10,
                           Player.Base.Character.Equip[10], False);
                          { case Player.GetPranEvolutedCnt of
                            0: //evoluindo
                            begin
                            ClearQuest := True;
                            Inc(Player.GetPranEvolutedCnt);
                            Player.SetPranEvolutedCnt(Player.GetPranEvolutedCnt);
                            break;
                            end;
                            1:
                            begin
                            cnt_helper := 0;
                            if(Player.Account.Header.Pran1.Id <> 0) then
                            inc(cnt_helper);
                            if(Player.Account.Header.Pran2.Id <> 0) then
                            inc(cnt_helper);
                            case cnt_helper of
                            0:
                            begin
                            Player.SendClientMessage('ERRO');
                            end;
                            1:
                            begin
                            Player.SendClientMessage('ERRO');
                            end;
                            2:
                            begin
                            Inc(Player.GetPranEvolutedCnt);
                            Player.SetPranEvolutedCnt(Player.GetPranEvolutedCnt);
                            break;
                            end;
                            end;
                            end;
                            2:
                            begin
                            cnt_helper := 0;
                            if(Player.Account.Header.Pran1.Id <> 0) then
                            inc(cnt_helper);
                            if(Player.Account.Header.Pran2.Id <> 0) then
                            inc(cnt_helper);
                            end;
                            3:
                            begin
                            end;
                            end;
                            ClearQuest := True; }
                        end
                        else
                          QuestAbort := True;
                      end;
                    1:
                      begin

                        if (Player.Account.Header.Pran2.Level = 4) then
                        begin
                          case Player.Account.Header.Pran2.ClassPran of
                            61, 71, 81:
                              begin
                                if (Player.Account.Header.Pran1.ID > 0) then
                                begin
                                  case Player.Account.Header.Pran1.ClassPran of
                                    61, 71, 81:
                                      begin
                                        ClearQuest := True;
                                      end;
                                  end;
                                end
                                else
                                  ClearQuest := True;
                              end;
                          else
                            begin
                              Player.SendClientMessage
                                ('Essa pran n鉶 pode ser upada de classe.');
                              Exit;
                            end;
                          end;
                          Inc(Player.Account.Header.Pran2.ClassPran);
                          Player.Account.Header.Pran2.Equip[0].Index := 104;
                          Player.Account.Header.Pran2.Equip[0].APP := 104;
                          //Player.Account.Header.Pran2.Equip[1].Index := 150;
                          //Player.Account.Header.Pran2.Equip[1].APP := 150;
                          Player.Account.Header.Pran2.Equip[6].Index := 150;
                          Player.Account.Header.Pran2.Equip[6].APP := 150;
                          Player.Base.Character.Equip[10].Index := 104;
                          Player.Base.Character.Equip[10].APP := 104;
                          // Player.Base.SendRefreshItemSlot(PRAN_EQUIP_TYPE, 0,
                          // Player.Account.Header.Pran2.Equip[0], False);
                          // Player.Base.SendRefreshItemSlot(PRAN_EQUIP_TYPE, 0,
                          // Player.Account.Header.Pran2.Equip[6], False);
                          // Player.Base.SendRefreshItemSlot(EQUIP_TYPE, 0,
                          // Player.Base.Character.Equip[10], False);
                          Inc(Player.Account.Header.Pran2.Skills[3].Level);
                          Player.SendEffect(0);
                          Player.SendPranToWorld(1);
                          Player.SendPranSpawn(1);
                          Player.Base.SendRefreshItemSlot(EQUIP_TYPE, 10,
                           Player.Base.Character.Equip[10], False);
                        end
                        else
                          QuestAbort := True;
                      end;
                  else
                    begin
                      Player.SendClientMessage
                        ('Voc?deve equipar uma pran para este procedimento.');
                      Exit;
                    end;
                  end;
                end;
              407: // isso aqui ?a quest Evolucao pran Lv20
                begin
                  if(Player.Base.Character.Equip[10].Index = 0) then
                  begin
                    Player.SendClientMessage
                      ('Voc?deve equipar uma pran para este procedimento.');
                    Exit;
                  end;

                  case Player.SpawnedPran of
                    0:
                      begin
                        if (Player.Account.Header.Pran1.Level = 19) then
                        begin
                          case Player.Account.Header.Pran1.ClassPran of
                            62, 72, 82:
                              begin
                                if (Player.Account.Header.Pran2.ID > 0) then
                                begin
                                  case Player.Account.Header.Pran2.ClassPran of
                                    61, 71, 81:
                                      begin
                                        ClearQuest := True;
                                      end;
                                    62, 72, 82:
                                      begin
                                        ClearQuest := True;
                                      end;
                                  end;
                                end
                                else
                                  ClearQuest := True;
                              end;
                          else
                            begin
                              Player.SendClientMessage
                                ('Essa pran n鉶 pode ser upada de classe.');
                              Exit;
                            end;
                          end;
                          Inc(Player.Account.Header.Pran1.ClassPran);
                          Player.Account.Header.Pran1.Equip[0].Index := 105;
                          Player.Account.Header.Pran1.Equip[0].APP := 105;
                          Player.Base.Character.Equip[10].Index := 105;
                          Player.Base.Character.Equip[10].APP := 105;
                          // Player.Base.SendRefreshItemSlot(PRAN_EQUIP_TYPE, 0,
                          // Player.Account.Header.Pran1.Equip[0], False);
                          // Player.Base.SendRefreshItemSlot(EQUIP_TYPE, 0,
                          // Player.Base.Character.Equip[10], False);
                          Player.SendPranToWorld(0);
                          Player.SendPranSpawn(0);
                          Player.Base.SendRefreshItemSlot(EQUIP_TYPE, 10,
                            Player.Base.Character.Equip[10], False);
                          // ClearQuest := True;
                        end
                        else
                          QuestAbort := True;
                      end;
                    1:
                      begin
                        if (Player.Account.Header.Pran2.Level = 19) then
                        begin
                          case Player.Account.Header.Pran2.ClassPran of
                            62, 72, 82:
                              begin
                                if (Player.Account.Header.Pran1.ID > 0) then
                                begin
                                  case Player.Account.Header.Pran1.ClassPran of
                                    61, 71, 81:
                                      begin
                                        ClearQuest := True;
                                      end;
                                    62, 72, 82:
                                      begin
                                        ClearQuest := True;
                                      end;
                                  end;
                                end
                                else
                                  ClearQuest := True;
                              end;
                          else
                            begin
                              Player.SendClientMessage
                                ('Essa pran n鉶 pode ser upada de classe.');
                              Exit;
                            end;
                          end;
                          Inc(Player.Account.Header.Pran2.ClassPran);
                          Player.Account.Header.Pran2.Equip[0].Index := 105;
                          Player.Account.Header.Pran2.Equip[0].APP := 105;
                          Player.Base.Character.Equip[10].Index := 105;
                          Player.Base.Character.Equip[10].APP := 105;
                          // Player.Base.SendRefreshItemSlot(PRAN_EQUIP_TYPE, 0,
                          // Player.Account.Header.Pran2.Equip[0], False);
                          // Player.Base.SendRefreshItemSlot(EQUIP_TYPE, 0,
                          // Player.Base.Character.Equip[10], False);
                          Player.SendPranToWorld(1);
                          Player.SendPranSpawn(1);
                          Player.Base.SendRefreshItemSlot(EQUIP_TYPE, 10,
                            Player.Base.Character.Equip[10], False);
                        end
                        else
                          QuestAbort := True;
                      end;
                  else
                    begin
                      Player.SendClientMessage
                        ('Voc?deve equipar uma pran para este procedimento.');
                      Exit;
                    end;
                  end;
                end;
              408: // quest Evolucao pran lv50 (fazer nos proximos caps)
                begin
                end;
            end;
            if not(QuestAbort) then
            begin
              if not(Player.PlayerQuests[QuestIndex].IsDone) then
              begin
                Player.SendExpGoldMsg(Player.PlayerQuests[QuestIndex].Quest.Exp,
                  Player.PlayerQuests[QuestIndex].Quest.Gold);
                Player.AddGold(Player.PlayerQuests[QuestIndex].Quest.Gold);
                Player.AddExp(Player.PlayerQuests[QuestIndex].Quest.Exp, Helper);
              end
              else if(Player.PlayerQuests[QuestIndex].Quest.QuestMark = 11) then
              begin
                Player.SendExpGoldMsg(Player.PlayerQuests[QuestIndex].Quest.Exp,
                  Player.PlayerQuests[QuestIndex].Quest.Gold);
                Player.AddGold(Player.PlayerQuests[QuestIndex].Quest.Gold);
                Player.AddExp(Player.PlayerQuests[QuestIndex].Quest.Exp, Helper);
              end;

              Player.RemoveQuest(QuestId);

              case (Player.PlayerQuests[QuestIndex].Quest.QuestMark) of
                8://red
                  begin
                    Player.PlayerQuests[QuestIndex].IsDone := True;
                    Player.PlayerQuests[QuestIndex].UpdatedAt := Now;
                    Player.PlayerQuests[QuestIndex].Complete[0] := 0;
                    Player.PlayerQuests[QuestIndex].Complete[1] := 0;
                    Player.PlayerQuests[QuestIndex].Complete[2] := 0;
                    Player.PlayerQuests[QuestIndex].Complete[3] := 0;
                    Player.PlayerQuests[QuestIndex].Complete[4] := 0;
                    Servers[Player.ChannelIndex].NPCS[Player.PlayerQuests[QuestIndex].Quest.NPCID]
                      .Base.SendCreateMob(SPAWN_NORMAL, Player.Base.ClientID, False);
                  end;

                2, 9: //blue and green (repetable)
                  begin
                    if not(ClearQuest) then
                    begin
                      Player.PlayerQuests[QuestIndex].IsDone := True;
                      Player.PlayerQuests[QuestIndex].UpdatedAt := Now;
                      Player.PlayerQuests[QuestIndex].Complete[0] := 0;
                      Player.PlayerQuests[QuestIndex].Complete[1] := 0;
                      Player.PlayerQuests[QuestIndex].Complete[2] := 0;
                      Player.PlayerQuests[QuestIndex].Complete[3] := 0;
                      Player.PlayerQuests[QuestIndex].Complete[4] := 0;
                      Servers[Player.ChannelIndex].NPCS[Player.PlayerQuests[QuestIndex].Quest.NPCID]
                        .Base.SendCreateMob(SPAWN_NORMAL, Player.Base.ClientID, False);
                    end
                    else
                    begin
                      Helper := Player.PlayerQuests[QuestIndex].Quest.NPCID;
                      ZeroMemory(@Player.PlayerQuests[QuestIndex], sizeof(QuestDin));
                      Servers[Player.ChannelIndex].NPCS[Helper]
                        .Base.SendCreateMob(SPAWN_NORMAL, Player.Base.ClientID, False);
                    end;
                  end;

                11: //yellow (repetable diary)
                  begin
                    Player.PlayerQuests[QuestIndex].IsDone := True;
                    Player.PlayerQuests[QuestIndex].UpdatedAt := Now;
                    Player.PlayerQuests[QuestIndex].Complete[0] := 0;
                    Player.PlayerQuests[QuestIndex].Complete[1] := 0;
                    Player.PlayerQuests[QuestIndex].Complete[2] := 0;
                    Player.PlayerQuests[QuestIndex].Complete[3] := 0;
                    Player.PlayerQuests[QuestIndex].Complete[4] := 0;
                    Servers[Player.ChannelIndex].NPCS[Player.PlayerQuests[QuestIndex].Quest.NPCID]
                      .Base.SendCreateMob(SPAWN_NORMAL, Player.Base.ClientID, False);
                  end;
              end;


            end;
          end;
        end;
      //QuestItem: // quest que precisou de item no invent醨io pra se completar
        begin
          case Player.PlayerQuests[QuestIndex].Quest.QuestId of
  1297: // quest de reliquia adormecida
    begin
      Helper := TItemFunctions.GetItemSlotByItemType(Player, 713, INV_TYPE);
      Count := 0;
      for i := 6370 to 6444 do
      begin
        if (ItemList[i].ItemType = 40) then
        begin
          if (ItemList[i].UseEffect = ItemList[Player.Base.Character.Inventory[Helper].Index].UseEffect) then
          begin
            if (ItemList[i].Level = 0) then
            begin
              Count := i;
            end
            else
              Continue;
          end;
        end;
      end;
      if (Count = 0) then
      begin
        for i := 12000 to 12032 do
        begin
          if (ItemList[i].ItemType = 40) then
          begin
            if (ItemList[i].UseEffect = ItemList[Player.Base.Character.Inventory[Helper].Index].UseEffect) then
            begin
              if (ItemList[i].Level = 0) then
              begin
                Count := i;
              end
              else
                Continue;
            end;
          end;
        end;
      end;
      if not(Count = 0) then
      begin
        for k := Low(Servers) to High(Servers) do
        begin
          for i := 0 to 4 do
          begin
            for j := 0 to 4 do
            begin
              if (Servers[k].Devires[i].Slots[j].ItemID <> 0) then
              begin
                if (ItemList[Servers[k].Devires[i].Slots[j].ItemID].UseEffect = ItemList[Player.Base.Character.Inventory[Helper].Index].UseEffect) then
                begin
                  Player.SendClientMessage('Esse tesouro sagrado já existe em algum templo.');
                  Exit;
                end;
              end;
            end;
          end;
        end;

        TempleSpace := Servers[Player.ChannelIndex].GetFreeTempleSpace;
        if (TempleSpace.DevirID = 255) then
        begin
          Player.SendClientMessage('Todos os templos estão cheios. Tente novamente mais tarde.');
          Exit;
        end;
        Servers[Player.ChannelIndex].Devires[TempleSpace.DevirID].Slots[TempleSpace.SlotID].ItemID := Count;
        Servers[Player.ChannelIndex].Devires[TempleSpace.DevirID].Slots[TempleSpace.SlotID].APP := Count;
        Servers[Player.ChannelIndex].Devires[TempleSpace.DevirID].Slots[TempleSpace.SlotID].TimeCapped := IncHour(Now, 3);
        Servers[Player.ChannelIndex].Devires[TempleSpace.DevirID].Slots[TempleSpace.SlotID].TimeToEstabilish := IncHour(Now, RELIQ_EST_TIME + 5);
        Move(Player.Base.Character.Name, Servers[Player.ChannelIndex].Devires[TempleSpace.DevirID].Slots[TempleSpace.SlotID].NameCapped[0], 16);
        Servers[Player.ChannelIndex].ReliqEffect[ItemList[Count].EF[0]] := Servers[Player.ChannelIndex].ReliqEffect[ItemList[Count].EF[0]] + ItemList[Count].EFV[0];
        Servers[Player.ChannelIndex].SaveTemplesDB(@Player);
        Servers[Player.ChannelIndex].UpdateReliquaresForAll;
        TItemFunctions.RemoveItem(Player, INV_TYPE, Helper);
        Servers[Player.ChannelIndex].SendServerMsg('O tesouro sagrado [' + AnsiString(ItemList[Count].Name) + '] foi encontrado e ativado pelo jogador <' + AnsiString(Player.Base.Character.Name) + '>.', 16, 16, 16);
        Player.RemoveQuest(QuestId);
        ZeroMemory(@Player.PlayerQuests[QuestIndex], sizeof(QuestDin));
      end;
    end;
else
  begin
    Count := 0;
    Count2 := 0;
    for i := 0 to 4 do
    begin
      if (Player.PlayerQuests[QuestIndex].Complete[i] >= Player.PlayerQuests[QuestIndex].Quest.RequirimentsAmount[i]) then
      begin
        if (Player.PlayerQuests[QuestIndex].Quest.RequirimentsAmount[i] = 0) then
          Continue
        else
          Inc(Count2);

        if not(Player.PlayerQuests[QuestIndex].Complete[i] = 0) then
        begin
          Helper4 := TItemFunctions.GetItemSlot2(Player, Player.PlayerQuests[QuestIndex].Quest.Requiriments[i]);

          if (Helper4 < 60) then
          begin
            if (Player.Base.Character.Inventory[Helper4].Refi >= Player.PlayerQuests[QuestIndex].Quest.RequirimentsAmount[i]) then
              Inc(Count);
          end
          else
          begin
            Dec(Count);
          end;
        end;
      end;
    end;
    if ((Count >= Count2) and (Count2 > 0)) then
    begin
      if not(Player.PlayerQuests[QuestIndex].IsDone) then
      begin
        for i := 0 to 5 do
        begin
          if (Player.PlayerQuests[QuestIndex].Quest.Rewards[i] = 0) then
            Continue;
          TItemFunctions.PutItem(Player, Player.PlayerQuests[QuestIndex].Quest.Rewards[i], 1); // arrumar quantidade
        end;
        Player.SendExpGoldMsg(Player.PlayerQuests[QuestIndex].Quest.Exp, Player.PlayerQuests[QuestIndex].Quest.Gold);
        Player.AddGold(Player.PlayerQuests[QuestIndex].Quest.Gold);
        Player.AddExp(Player.PlayerQuests[QuestIndex].Quest.Exp, Helper);
        for i := 0 to 4 do
        begin
          if not(Player.PlayerQuests[QuestIndex].Quest.Requiriments[i] = 0) then
          begin
            cnt_helper := TItemFunctions.GetItemSlot2(Player, Player.PlayerQuests[QuestIndex].Quest.Requiriments[i]);
            if (cnt_helper <> 255) then
            begin
              TItemFunctions.DecreaseAmount(Player, cnt_helper, Player.PlayerQuests[QuestIndex].Quest.RequirimentsAmount[i]);
              Player.Base.SendRefreshItemSlot(cnt_helper, False);
            end;
          end;
        end;
      end;
    end;
  end;
end;




                  Player.PlayerQuests[QuestIndex].IsDone := True;
                  Player.PlayerQuests[QuestIndex].UpdatedAt := Now;
                  Player.PlayerQuests[QuestIndex].Complete[0] := 0;
                  Player.PlayerQuests[QuestIndex].Complete[1] := 0;
                  Player.PlayerQuests[QuestIndex].Complete[2] := 0;
                  Player.PlayerQuests[QuestIndex].Complete[3] := 0;
                  Player.PlayerQuests[QuestIndex].Complete[4] := 0;
                  Servers[Player.ChannelIndex].NPCS[Player.PlayerQuests[QuestIndex].Quest.NPCID]
                    .Base.SendCreateMob(SPAWN_NORMAL, Player.Base.ClientID, False);

                end;

                Player.RemoveQuest(QuestId);
              end;
            end;
          end;
         end;

              end;
            end;
          end;
         end;
      QuestExperienceGuild:
        begin
          if(Player.Character.GuildSlot = 0) then
            Exit;

          Count := 0;
          Count2 := 0;
          for i := 0 to 4 do
          begin
            if (Player.PlayerQuests[QuestIndex].Complete[i] >=
              Player.PlayerQuests[QuestIndex].Quest.RequirimentsAmount[i])
            then
            begin
              if(Player.PlayerQuests[QuestIndex].Quest.RequirimentsAmount[i] = 0) then
                Continue
              else
                Inc(Count2);

              if not(Player.PlayerQuests[QuestIndex].Complete[i] = 0) then
              begin  //Helper4
                if(Player.PlayerQuests[QuestIndex].Quest.RequirimentsType[i] = QuestItem) then
                begin
                  Helper4 := TItemFunctions.GetItemSlot2(Player,
                    Player.PlayerQuests[QuestIndex].Quest.Requiriments[i]);

                  if(Helper4 <> 255) then
                  begin
                    if(Player.Base.Character.Inventory[Helper4].Refi >=
                      Player.PlayerQuests[QuestIndex].Quest.RequirimentsAmount[i]) then
                        Inc(Count);
                  end;
                end
                else
                  Inc(Count);
              end;
            end;
          end;
          if ((Count >= Count2) and (Count2 > 0)) then
          begin
            for i := 0 to 4 do
            begin
              if not(Player.PlayerQuests[QuestIndex].Quest.Requiriments
                [i] = 0) then
              begin // fun玢o pra deletar o item do inventario
                cnt_helper := TItemFunctions.GetItemSlot2(Player,
                  Player.PlayerQuests[QuestIndex].Quest.Requiriments[i]);
                if(cnt_helper <> 255) then
                begin
                  TItemFunctions.DecreaseAmount(Player, cnt_helper,
                    Player.PlayerQuests[QuestIndex].Quest.RequirimentsAmount[i]);
                  Player.Base.SendRefreshItemSlot(cnt_helper, False);
                end;
              end;
            end;

            Inc(Guilds[Player.Character.GuildSlot].Exp,
              (Player.PlayerQuests[QuestIndex].Quest.Rewards[0]*3));

            if (Guilds[Player.Character.GuildSlot].Exp > GuildExpList
              [Guilds[Player.Character.GuildSlot].Level + 1]) then
            begin
              Inc(Guilds[Player.Character.GuildSlot].Level);
              GuildLeveled := true;
            end;
            for i := 0 to 127 do
            begin
              if (Guilds[Player.Character.GuildSlot].Members[i].CharIndex = 0) then
                Continue;
              OtherPlayer := Servers[Player.ChannelIndex].GetPlayer
                (String(Guilds[Player.Character.GuildSlot].Members[i].Name));
              if (OtherPlayer.IsInstantiated) then
              begin
                OtherPlayer.SendGuildInfo;
                OtherPlayer.SendClientMessage('Jogador <' +
                  Player.Base.Character.Name+'> adquiriu ' +
                   Player.PlayerQuests[QuestIndex].Quest.Rewards[0].ToString + ' experi阯cia da legi鉶.' );
                if (GuildLeveled) then
                begin
                  OtherPlayer.SendClientMessage('A sua guild subiu de level!');
                end;
              end;
            end;

            Helper := Player.PlayerQuests[QuestIndex].Quest.NPCID;
            ZeroMemory(@Player.PlayerQuests[QuestIndex], sizeof(QuestDin));
            Servers[Player.ChannelIndex].NPCS[Helper]
              .Base.SendCreateMob(SPAWN_NORMAL, Player.Base.ClientID, False);

            Player.RemoveQuest(QuestId);
          end;
        end;

      QuestSkillAcquire:
        begin
          Count := 0;
          Count2 := 0;
          for i := 0 to 4 do
          begin
            if(Player.PlayerQuests[QuestIndex].Quest.RequirimentsAmount[i] = 0) then
              Continue
            else
              Inc(Count2);

            if (Player.PlayerQuests[QuestIndex].Complete[i] >=
              Player.PlayerQuests[QuestIndex].Quest.RequirimentsAmount[i]) then
            begin
              if not(Player.PlayerQuests[QuestIndex].Complete[i] = 0) then
                Inc(Count);
            end;
          end;
          if ((Count = Count2) and (Count2 > 0)) then
          begin
            case Player.PlayerQuests[QuestIndex].Quest.QuestId of
              901:
                begin
                  Helper := Player.Character.Skills.Basics[5].Index;
                  if(Helper = 0) then Helper := Player.Character.Skills.Basics[4].Index;
                  if (TSkillFunctions.IncremmentSkillLevel(Player, Helper, Helper2))
                  then
                  begin

                    Player.SendPlayerSkills($7535);
                    //Player.RefreshMoney;
                    Player.SendPlayerSkillsLevel;

                    Player.Base.SendCurrentHPMP;
                    Player.Base.SendStatus;
                    Player.Base.SendRefreshPoint;
                  end;
                end;
            end;

            Player.SendClientMessage('Voc?adquiriu uma nova habilidade!');

            Player.RemoveQuest(QuestId);
            Player.PlayerQuests[QuestIndex].IsDone := True;
            Player.PlayerQuests[QuestIndex].Complete[0] := 0;
            Player.PlayerQuests[QuestIndex].Complete[1] := 0;
            Player.PlayerQuests[QuestIndex].Complete[2] := 0;
            Player.PlayerQuests[QuestIndex].Complete[3] := 0;
            Player.PlayerQuests[QuestIndex].Complete[4] := 0;
          end;
        end;

      QuestCash:
        begin
          case Player.PlayerQuests[QuestIndex].Quest.QuestId of
            408: // exilar para astur
              begin
                if (Player.Base.Character.Nation = 0) then
                begin
                  Player.SendClientMessage('Voc?n鉶 possui na玢o.');
                  Exit;
                end;
                if (Player.Base.Character.Nation = 1) then
                begin
                  Player.SendClientMessage('Voc?j?est?em astur.');
                  Exit;
                end;
                if(player.Character.GuildSlot > 0) then
                begin
                  Player.SendClientMessage('Voc?n鉶 pode exilar estando em uma guilda.');
                  Exit;
                end;

                if (Player.Account.Header.CashInventory.Cash < 100000) then
                begin
                  Player.SendClientMessage
                    ('?necess醨io possuir [100.000] na loja cash para essa a玢o.');
                  Exit;
                end;
                Dec(Player.Account.Header.CashInventory.Cash, 100000);
                Player.SendPlayerCash;
                Player.Account.Header.Nation := TCitizenship(1);
                Servers[Player.ChannelIndex].SendServerMsg
                  ('O jogador <' + AnsiString(Player.Base.Character.Name) +
                  '> exilou para Astur.', 32, 16);
                Player.RemoveQuest(QuestId);
                ZeroMemory(@Player.PlayerQuests[QuestIndex], sizeof(QuestDin));

                for I in Player.FriendList.Keys do
                begin
                  Player.EntityFriend.removeFriend(i);
                end;

                Guilds[Player.Character.GuildSlot].RemoveMember(Player.Character.Base.CharIndex, True);

                Player.SocketClosed := True;
              end;
            409: // exilar para exodia
              begin
                if (Player.Base.Character.Nation = 0) then
                begin
                  Player.SendClientMessage('Voc?n鉶 possui na玢o.');
                  Exit;
                end;
                if (Player.Base.Character.Nation = 2) then
                begin
                  Player.SendClientMessage('Voc?j?est?em exodia.');
                  Exit;
                end;
                if(player.Character.GuildSlot > 0) then
                begin
                  Player.SendClientMessage('Voc?n鉶 pode exilar estando em uma guilda.');
                  Exit;
                end;
                if (Player.Account.Header.CashInventory.Cash < 100000) then
                begin
                  Player.SendClientMessage
                    ('?necess醨io possuir [100.000] na loja cash para essa a玢o.');
                  Exit;
                end;
                Dec(Player.Account.Header.CashInventory.Cash, 100000);
                Player.SendPlayerCash;
                Player.Account.Header.Nation := TCitizenship(2);
                Servers[Player.ChannelIndex].SendServerMsg
                  ('O jogador <' + AnsiString(Player.Base.Character.Name) +
                  '> exilou para Exodia.', 32, 16);
                Player.RemoveQuest(QuestId);
                ZeroMemory(@Player.PlayerQuests[QuestIndex], sizeof(QuestDin));

                for I in Player.FriendList.Keys do
                begin
                  Player.EntityFriend.removeFriend(i);
                end;

                Guilds[Player.Character.GuildSlot].RemoveMember(Player.Character.Base.CharIndex, True);

                Player.SocketClosed := True;
              end;
              410:
              begin
                if (Player.Base.Character.Nation = 0) then
                begin
                  Player.SendClientMessage('Voc?n鉶 possui na玢o.');
                  Exit;
                end;
                if (Player.Base.Character.Nation = 3) then
                begin
                  Player.SendClientMessage('Voc?j?est?em Leonides.');
                  Exit;
                end;
                if(player.Character.GuildSlot > 0) then
                begin
                  Player.SendClientMessage('Voc?n鉶 pode exilar estando em uma guilda.');
                  Exit;
                end;
                if (Player.Account.Header.CashInventory.Cash < 100000) then
                begin
                  Player.SendClientMessage
                    ('?necess醨io possuir [100.000] na loja cash para essa a玢o.');
                  Exit;
                end;
                Dec(Player.Account.Header.CashInventory.Cash, 100000);
                Player.SendPlayerCash;

                Player.Account.Header.Nation := TCitizenship(3);
                Servers[Player.ChannelIndex].SendServerMsg
                  ('O jogador <' + AnsiString(Player.Base.Character.Name) +
                  '> exilou para Leonides.', 32, 16);
                Player.RemoveQuest(QuestId);
                ZeroMemory(@Player.PlayerQuests[QuestIndex], sizeof(QuestDin));

                for I in Player.FriendList.Keys do
                begin
                  Player.EntityFriend.removeFriend(i);
                end;

                Guilds[Player.Character.GuildSlot].RemoveMember(Player.Character.Base.CharIndex, True);

                Player.SocketClosed := True;
              end;
          end;
        end;
    end;
  end;
end;

class function TNPCHandlers.DestroyAlliance(var Player: TPlayer): Boolean;
var
  xGuild, OtherGuild1, OtherGuild2, OtherGuild3: PGuild;
  AnotherPlayer: PPlayer;
  i: Integer;
begin
  Result := False;
  xGuild := nil;
  OtherGuild1 := nil;
  OtherGuild2 := nil;
  OtherGuild3 := nil;

  xGuild := @Guilds[Player.Character.GuildSlot];

  for I := 0 to 3 do
  begin
    if(String(Nations[Player.Character.Base.Nation-1].Cerco.Atacantes[i].LordMarechal) =
      String(xGuild.Name)) then
    begin
      Player.SendClientMessage('Voc?n鉶 pode desfazer a alian鏰 estando cadastrado na guerra.');
      Exit;
    end;
  end;

  if(String(Nations[Player.Character.Base.Nation-1].Cerco.Defensoras.LordMarechal) =
    String(xGuild.Name)) then
  begin
    Player.SendClientMessage('Voc?n鉶 pode desfazer a alian鏰 estando cadastrado na guerra.');
    Exit;
  end;

  if(xGuild.Ally.Guilds[1].Index <> 0) then
  begin
    OtherGuild1 := @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID
      (xGuild.Ally.Guilds[1].Index)];

    if(OtherGuild1.Index > 0) then
    begin
      ZeroMemory(@OtherGuild1.Ally, sizeof(OtherGuild1.Ally));
      OtherGuild1.Ally.Leader := OtherGuild1.Index;
      OtherGuild1.Ally.Guilds[0].Index := OtherGuild1.Index;
      System.AnsiStrings.StrPLCopy(OtherGuild1.Ally.Guilds[0].Name,
        String(OtherGuild1.Name), 18);
    end;
  end;

  if(xGuild.Ally.Guilds[2].Index <> 0) then
  begin
    OtherGuild2 := @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID
      (xGuild.Ally.Guilds[2].Index)];

    if(OtherGuild2.Index > 0) then
    begin
      ZeroMemory(@OtherGuild2.Ally, sizeof(OtherGuild2.Ally));
      OtherGuild1.Ally.Leader := OtherGuild2.Index;
      OtherGuild1.Ally.Guilds[0].Index := OtherGuild2.Index;
      System.AnsiStrings.StrPLCopy(OtherGuild2.Ally.Guilds[0].Name,
        String(OtherGuild2.Name), 18);
    end;
  end;

  if(xGuild.Ally.Guilds[3].Index <> 0) then
  begin
    OtherGuild3 := @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID
      (xGuild.Ally.Guilds[3].Index)];

    if(OtherGuild3.Index > 0) then
    begin
      ZeroMemory(@OtherGuild3.Ally, sizeof(OtherGuild3.Ally));
      OtherGuild3.Ally.Leader := OtherGuild3.Index;
      OtherGuild3.Ally.Guilds[0].Index := OtherGuild3.Index;
      System.AnsiStrings.StrPLCopy(OtherGuild3.Ally.Guilds[0].Name,
        String(OtherGuild3.Name), 18);
    end;
  end;

  if(xGuild.Index > 0) then
  begin
    ZeroMemory(@xGuild.Ally, sizeof(xGuild.Ally));
    xGuild.Ally.Leader := xGuild.Index;
    xGuild.Ally.Guilds[0].Index := xGuild.Index;
    System.AnsiStrings.StrPLCopy(xGuild.Ally.Guilds[0].Name,
      String(xGuild.Name), 18);
  end;

  for I := 0 to 127 do
   begin
     //talvez tenha que fazer para todos os servidores
     if(xGuild <> nil) then
     begin
       if(xGuild.Members[i].Logged) then
       begin
         if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(xGuild.Members[i].CharIndex, AnotherPlayer)) then
         begin
           AnotherPlayer.SendGuildInfo;
           AnotherPlayer.SendClientMessage('Sua alian鏰 teve mudan鏰s.');

           AnotherPlayer.SendNationInformation;
           AnotherPlayer.Base.GetCurrentScore;
           AnotherPlayer.Base.SendRefreshPoint;
           AnotherPlayer.Base.SendStatus;
           AnotherPlayer.Base.SendRefreshLevel;
           AnotherPlayer.Base.SendCurrentHPMP();

         end;
       end;

       //TFunctions.SaveGuilds(xGuild.Slot);
     end;

     if(OtherGuild1 <> nil) then
     begin
       if(OtherGuild1.Members[i].Logged) then
       begin
         if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(OtherGuild1.Members[i].CharIndex, AnotherPlayer)) then
         begin
           AnotherPlayer.SendGuildInfo;
           AnotherPlayer.SendClientMessage('Sua alian鏰 teve mudan鏰s.');

           AnotherPlayer.SendNationInformation;
           AnotherPlayer.Base.GetCurrentScore;
           AnotherPlayer.Base.SendRefreshPoint;
           AnotherPlayer.Base.SendStatus;
           AnotherPlayer.Base.SendRefreshLevel;
           AnotherPlayer.Base.SendCurrentHPMP();

         end;
       end;

       //TFunctions.SaveGuilds(OtherGuild1.Slot);
     end;

     if(OtherGuild2 <> nil) then
     begin
       if(OtherGuild2.Members[i].Logged) then
       begin
         if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(OtherGuild2.Members[i].CharIndex, AnotherPlayer)) then
         begin
           AnotherPlayer.SendGuildInfo;
           AnotherPlayer.SendClientMessage('Sua alian鏰 teve mudan鏰s.');

           AnotherPlayer.SendNationInformation;
           AnotherPlayer.Base.GetCurrentScore;
           AnotherPlayer.Base.SendRefreshPoint;
           AnotherPlayer.Base.SendStatus;
           AnotherPlayer.Base.SendRefreshLevel;
           AnotherPlayer.Base.SendCurrentHPMP();

         end;
       end;

       //TFunctions.SaveGuilds(OtherGuild2.Slot);
     end;

     if(OtherGuild3 <> nil) then
     begin
       if(OtherGuild3.Members[i].Logged) then
       begin
         if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(OtherGuild3.Members[i].CharIndex, AnotherPlayer)) then
         begin
           AnotherPlayer.SendGuildInfo;
           AnotherPlayer.SendClientMessage('Sua alian鏰 teve mudan鏰s.');

           AnotherPlayer.SendNationInformation;
           AnotherPlayer.Base.GetCurrentScore;
           AnotherPlayer.Base.SendRefreshPoint;
           AnotherPlayer.Base.SendStatus;
           AnotherPlayer.Base.SendRefreshLevel;
           AnotherPlayer.Base.SendCurrentHPMP();

         end;
       end;

       //TFunctions.SaveGuilds(OtherGuild3.Slot);
     end;
   end;

  if(xGuild <> nil) then
  begin
    TFunctions.SaveGuilds(xGuild.Slot);
  end;
  if(OtherGuild1 <> nil) then
  begin
    TFunctions.SaveGuilds(OtherGuild1.Slot);
  end;
  if(OtherGuild2 <> nil) then
  begin
    TFunctions.SaveGuilds(OtherGuild2.Slot);
  end;
  if(OtherGuild3 <> nil) then
  begin
    TFunctions.SaveGuilds(OtherGuild3.Slot);
  end;
end;

class function TNPCHandlers.RemoveMemberAlliance(var Player: TPlayer; SlotTo: Integer): Boolean;
var
  xGuild, OtherGuild1, OtherGuild2, OtherGuild3: PGuild;
  AnotherPlayer: PPlayer;
  UpdateNation: Boolean;
  i: Integer;
begin
  Result := False;
  xGuild := nil;
  OtherGuild1 := nil;
  OtherGuild2 := nil;
  OtherGuild3 := nil;
  UpdateNation := False;

  if((SlotTo >= 1) and (SlotTo <= 3)) then
  begin
    xGuild := @Guilds[Player.Character.GuildSlot];
    OtherGuild1 := @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID(xGuild.Ally.Guilds[SlotTo].Index)];

    for I := 0 to 3 do
    begin
      if(String(Nations[Player.Character.Base.Nation-1].Cerco.Atacantes[i].LordMarechal) =
        String(xGuild.Name)) then
      begin
        Player.SendClientMessage('Voc?n鉶 pode retirar aliado estando cadastrado na guerra.');
        Exit;
      end;
    end;

    case SlotTo of
      1:
        begin
          if(xGuild.Ally.Guilds[2].Index <> 0) then
          begin
            OtherGuild2 := @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID(xGuild.Ally.Guilds[2].Index)];
          end;

          if(xGuild.Ally.Guilds[3].Index <> 0) then
          begin
            OtherGuild3 := @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID(xGuild.Ally.Guilds[3].Index)];
          end;
        end;
      2:
        begin
          if(xGuild.Ally.Guilds[1].Index <> 0) then
          begin
            OtherGuild2 := @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID(xGuild.Ally.Guilds[1].Index)];
          end;

          if(xGuild.Ally.Guilds[3].Index <> 0) then
          begin
            OtherGuild3 := @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID(xGuild.Ally.Guilds[3].Index)];
          end;
        end;
      3:
        begin
          if(xGuild.Ally.Guilds[1].Index <> 0) then
          begin
            OtherGuild2 := @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID(xGuild.Ally.Guilds[1].Index)];
          end;

          if(xGuild.Ally.Guilds[2].Index <> 0) then
          begin
            OtherGuild3 := @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID(xGuild.Ally.Guilds[2].Index)];
          end;
        end;
    end;

    if(String(Nations[Player.Character.Base.Nation-1].Cerco.Defensoras.Estrategista) =
    String(OtherGuild1.Name)) then
    begin
      Nations[Player.Base.Character.Nation-1].TacticianGuildID := 0;
      ZeroMemory(@Nations[Player.Base.Character.Nation-1].Cerco.Defensoras.Estrategista,
        sizeof(Nations[Player.Base.Character.Nation-1].Cerco.Defensoras.Estrategista));
      UpdateNation := True;
    end;

    if(String(Nations[Player.Character.Base.Nation-1].Cerco.Defensoras.Juiz) =
      String(OtherGuild1.Name)) then
    begin
      Nations[Player.Base.Character.Nation-1].JudgeGuildID := 0;
      ZeroMemory(@Nations[Player.Base.Character.Nation-1].Cerco.Defensoras.Juiz,
        sizeof(Nations[Player.Base.Character.Nation-1].Cerco.Defensoras.Juiz));
      UpdateNation := True;
    end;

    if(String(Nations[Player.Character.Base.Nation-1].Cerco.Defensoras.Tesoureiro) =
      String(OtherGuild1.Name)) then
    begin
      Nations[Player.Base.Character.Nation-1].TreasurerGuildID := 0;
      ZeroMemory(@Nations[Player.Base.Character.Nation-1].Cerco.Defensoras.Tesoureiro,
        sizeof(Nations[Player.Base.Character.Nation-1].Cerco.Defensoras.Tesoureiro));
      UpdateNation := True;
    end;

    if((xGuild.Index <> 0) and (OtherGuild1.Index <> 0)) then
    begin
      ZeroMemory(@xGuild.Ally.Guilds[SlotTo], sizeof(xGuild.Ally.Guilds[SlotTo]));
      ZeroMemory(@OtherGuild1.Ally, sizeof(OtherGuild1.Ally));
      OtherGuild1.Ally.Leader := OtherGuild1.Index;
      OtherGuild1.Ally.Guilds[0].Index := OtherGuild1.Index;
      System.AnsiStrings.StrPLCopy(OtherGuild1.Ally.Guilds[0].Name,
        String(OtherGuild1.Name), 18);

      if(OtherGuild2 <> nil) then
        Move(xGuild.Ally, OtherGuild2.Ally, sizeof(TGuildAlly));
      if(OtherGuild3 <> nil) then
        Move(xGuild.Ally, OtherGuild3.Ally, sizeof(TGuildAlly));

      for I := 0 to 127 do
       begin
         //talvez tenha que fazer para todos os servidores
         if(xGuild.Members[i].Logged) then
         begin
           if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(xGuild.Members[i].CharIndex, AnotherPlayer)) then
           begin
             AnotherPlayer.SendGuildInfo;
             AnotherPlayer.SendClientMessage('Sua alian鏰 teve mudan鏰s.');

             AnotherPlayer.SendNationInformation;
             AnotherPlayer.Base.GetCurrentScore;
             AnotherPlayer.Base.SendRefreshPoint;
             AnotherPlayer.Base.SendStatus;
             AnotherPlayer.Base.SendRefreshLevel;
             AnotherPlayer.Base.SendCurrentHPMP();

           end;
         end;

         if(OtherGuild1 <> nil) then
           if(OtherGuild1.Members[i].Logged) then
           begin
             if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(OtherGuild1.Members[i].CharIndex, AnotherPlayer)) then
             begin
               AnotherPlayer.SendGuildInfo;
               AnotherPlayer.SendClientMessage('Sua alian鏰 teve mudan鏰s.');

               AnotherPlayer.SendNationInformation;
               AnotherPlayer.Base.GetCurrentScore;
               AnotherPlayer.Base.SendRefreshPoint;
               AnotherPlayer.Base.SendStatus;
               AnotherPlayer.Base.SendRefreshLevel;
               AnotherPlayer.Base.SendCurrentHPMP();

             end;
           end;

         if(OtherGuild2 <> nil) then
           if(OtherGuild2.Members[i].Logged) then
           begin
             if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(OtherGuild2.Members[i].CharIndex, AnotherPlayer)) then
             begin
               AnotherPlayer.SendGuildInfo;
               AnotherPlayer.SendClientMessage('Sua alian鏰 teve mudan鏰s.');

               AnotherPlayer.SendNationInformation;
               AnotherPlayer.Base.GetCurrentScore;
               AnotherPlayer.Base.SendRefreshPoint;
               AnotherPlayer.Base.SendStatus;
               AnotherPlayer.Base.SendRefreshLevel;
               AnotherPlayer.Base.SendCurrentHPMP();

             end;
           end;

         if(OtherGuild3 <> nil) then
           if(OtherGuild3.Members[i].Logged) then
           begin
             if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(OtherGuild3.Members[i].CharIndex, AnotherPlayer)) then
             begin
               AnotherPlayer.SendGuildInfo;
               AnotherPlayer.SendClientMessage('Sua alian鏰 teve mudan鏰s.');

               AnotherPlayer.SendNationInformation;
               AnotherPlayer.Base.GetCurrentScore;
               AnotherPlayer.Base.SendRefreshPoint;
               AnotherPlayer.Base.SendStatus;
               AnotherPlayer.Base.SendRefreshLevel;
               AnotherPlayer.Base.SendCurrentHPMP();

             end;
           end;
       end;

       if(xGuild <> nil) then
        begin
          TFunctions.SaveGuilds(xGuild.Slot);
        end;
        if(OtherGuild1 <> nil) then
        begin
          TFunctions.SaveGuilds(OtherGuild1.Slot);
        end;
        if(OtherGuild2 <> nil) then
        begin
          TFunctions.SaveGuilds(OtherGuild2.Slot);
        end;
        if(OtherGuild3 <> nil) then
        begin
          TFunctions.SaveGuilds(OtherGuild3.Slot);
        end;

        if(UpdateNation) then
        begin
          for I := 1 to High(Servers[Player.ChannelIndex].Players) do
          begin
            if(Servers[Player.ChannelIndex].Players[i].Status >= Playing) then
              Servers[Player.ChannelIndex].Players[i].SendNationInformation;
          end;

          Nations[Player.Base.Character.Nation-1].SaveNation;
        end;
    end;
  end;

  Result := True;
end;

class function TNPCHandlers.ExitAlliance(var Player: TPlayer): Boolean;
var
  xGuild, LeaderGuild, OtherGuild2, OtherGuild3: PGuild;
  OldSlot, i: Integer;
  AnotherPlayer: PPlayer;
  UpdateNation: Boolean;
begin
  Result := False;
  xGuild := nil;
  LeaderGuild := nil;
  OtherGuild2 := nil;
  OtherGuild3 := nil;
  UpdateNation := False;

  xGuild := @Guilds[Player.Character.GuildSlot];
  if(xGuild.Ally.Leader = xGuild.Index) then
  begin
    Player.SendClientMessage('Voc?n鉶 pode sair de uma alian鏰 sendo o lider dela.');
    Exit;
  end;

  for I := 0 to 3 do
  begin
    if(String(Nations[Player.Character.Base.Nation-1].Cerco.Atacantes[i].LordMarechal) =
      String(xGuild.Name)) then
    begin
      Player.SendClientMessage('Voc?n鉶 pode sair da alian鏰 estando cadastrado na guerra.');
      Exit;
    end;
    if(String(Nations[Player.Character.Base.Nation-1].Cerco.Atacantes[i].Estrategista) =
      String(xGuild.Name)) then
    begin
      Player.SendClientMessage('Voc?n鉶 pode sair da alian鏰 estando cadastrado na guerra.');
      Exit;
    end;
    if(String(Nations[Player.Character.Base.Nation-1].Cerco.Atacantes[i].Juiz) =
      String(xGuild.Name)) then
    begin
      Player.SendClientMessage('Voc?n鉶 pode sair da alian鏰 estando cadastrado na guerra.');
      Exit;
    end;
    if(String(Nations[Player.Character.Base.Nation-1].Cerco.Atacantes[i].Tesoureiro) =
      String(xGuild.Name)) then
    begin
      Player.SendClientMessage('Voc?n鉶 pode sair da alian鏰 estando cadastrado na guerra.');
      Exit;
    end;
  end;

  if(String(Nations[Player.Character.Base.Nation-1].Cerco.Defensoras.LordMarechal) =
    String(xGuild.Name)) then
  begin
    Player.SendClientMessage('Voc?n鉶 pode sair da alian鏰 estando cadastrado na guerra.');
    Exit;
  end;

  if(String(Nations[Player.Character.Base.Nation-1].Cerco.Defensoras.Estrategista) =
    String(xGuild.Name)) then
  begin
    Nations[Player.Base.Character.Nation-1].TacticianGuildID := 0;
    ZeroMemory(@Nations[Player.Base.Character.Nation-1].Cerco.Defensoras.Estrategista,
      sizeof(Nations[Player.Base.Character.Nation-1].Cerco.Defensoras.Estrategista));
    UpdateNation := True;
  end;

  if(String(Nations[Player.Character.Base.Nation-1].Cerco.Defensoras.Juiz) =
    String(xGuild.Name)) then
  begin
    Nations[Player.Base.Character.Nation-1].JudgeGuildID := 0;
    ZeroMemory(@Nations[Player.Base.Character.Nation-1].Cerco.Defensoras.Juiz,
      sizeof(Nations[Player.Base.Character.Nation-1].Cerco.Defensoras.Juiz));
    UpdateNation := True;
  end;

  if(String(Nations[Player.Character.Base.Nation-1].Cerco.Defensoras.Tesoureiro) =
    String(xGuild.Name)) then
  begin
    Nations[Player.Base.Character.Nation-1].TreasurerGuildID := 0;
    ZeroMemory(@Nations[Player.Base.Character.Nation-1].Cerco.Defensoras.Tesoureiro,
      sizeof(Nations[Player.Base.Character.Nation-1].Cerco.Defensoras.Tesoureiro));
    UpdateNation := True;
  end;

  LeaderGuild := @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID(xGuild.Ally.Leader)];

  ZeroMemory(@xGuild.Ally, sizeof(xGuild.Ally));
  xGuild.Ally.Leader := xGuild.Index;
  xGuild.Ally.Guilds[0].Index := xGuild.Index;
  System.AnsiStrings.StrPLCopy(xGuild.Ally.Guilds[0].Name,
    String(xGuild.Name), 18);

  for I := 1 to 3 do
  begin
    if(LeaderGuild.Ally.Guilds[i].Index = xGuild.Index) then
    begin
      OldSlot := i;
    end
    else
    begin
      if(OtherGuild2 = nil) then
        OtherGuild2 := @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID(LeaderGuild.Ally.Guilds[i].Index)]
      else
      if(OtherGuild3 = nil) then
        OtherGuild3 := @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID(LeaderGuild.Ally.Guilds[i].Index)];
    end;
  end;

  ZeroMemory(@LeaderGuild.Ally.Guilds[OldSlot], sizeof(LeaderGuild.Ally.Guilds[OldSlot]));

  if(OtherGuild2 <> nil) then
  begin
    ZeroMemory(@OtherGuild2.Ally.Guilds[OldSlot], sizeof(OtherGuild2.Ally.Guilds[OldSlot]));
  end;

  if(OtherGuild3 <> nil) then
  begin
    ZeroMemory(@OtherGuild3.Ally.Guilds[OldSlot], sizeof(OtherGuild3.Ally.Guilds[OldSlot]));
  end;

  for I := 0 to 127 do
   begin
     //talvez tenha que fazer para todos os servidores
     if(xGuild.Members[i].Logged) then
     begin
       if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(xGuild.Members[i].CharIndex, AnotherPlayer)) then
       begin
         AnotherPlayer.SendGuildInfo;
         AnotherPlayer.SendClientMessage('Sua alian鏰 teve mudan鏰s.');

         AnotherPlayer.SendNationInformation;
         AnotherPlayer.Base.GetCurrentScore;
         AnotherPlayer.Base.SendRefreshPoint;
         AnotherPlayer.Base.SendStatus;
         AnotherPlayer.Base.SendRefreshLevel;
         AnotherPlayer.Base.SendCurrentHPMP();

       end;

       //TFunctions.SaveGuilds(xGuild.Slot);
     end;
     if(LeaderGuild <> nil) then
     begin
       if(LeaderGuild.Members[i].Logged) then
       begin
         if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(LeaderGuild.Members[i].CharIndex, AnotherPlayer)) then
         begin
           AnotherPlayer.SendGuildInfo;

           AnotherPlayer.SendNationInformation;
           AnotherPlayer.Base.GetCurrentScore;
           AnotherPlayer.Base.SendRefreshPoint;
           AnotherPlayer.Base.SendStatus;
           AnotherPlayer.Base.SendRefreshLevel;
           AnotherPlayer.Base.SendCurrentHPMP();

         end;
       end;

       //TFunctions.SaveGuilds(LeaderGuild.Slot);
     end;

     if(OtherGuild2 <> nil) then
     begin
       if(OtherGuild2.Members[i].Logged) then
       begin
         if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(OtherGuild2.Members[i].CharIndex, AnotherPlayer)) then
         begin
           AnotherPlayer.SendGuildInfo;

           AnotherPlayer.SendNationInformation;
           AnotherPlayer.Base.GetCurrentScore;
           AnotherPlayer.Base.SendRefreshPoint;
           AnotherPlayer.Base.SendStatus;
           AnotherPlayer.Base.SendRefreshLevel;
           AnotherPlayer.Base.SendCurrentHPMP();

         end;
       end;

       //TFunctions.SaveGuilds(OtherGuild2.Slot);
     end;

     if(OtherGuild3 <> nil) then
     begin
       if(OtherGuild3.Members[i].Logged) then
       begin
         if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(OtherGuild3.Members[i].CharIndex, AnotherPlayer)) then
         begin
           AnotherPlayer.SendGuildInfo;

           AnotherPlayer.SendNationInformation;
           AnotherPlayer.Base.GetCurrentScore;
           AnotherPlayer.Base.SendRefreshPoint;
           AnotherPlayer.Base.SendStatus;
           AnotherPlayer.Base.SendRefreshLevel;
           AnotherPlayer.Base.SendCurrentHPMP();

         end;
       end;

       //TFunctions.SaveGuilds(OtherGuild3.Slot);
     end;
   end;

  if(xGuild <> nil) then
  begin
    TFunctions.SaveGuilds(xGuild.Slot);
  end;
  if(LeaderGuild <> nil) then
  begin
    TFunctions.SaveGuilds(LeaderGuild.Slot);
  end;
  if(OtherGuild2 <> nil) then
  begin
    TFunctions.SaveGuilds(OtherGuild2.Slot);
  end;
  if(OtherGuild3 <> nil) then
  begin
    TFunctions.SaveGuilds(OtherGuild3.Slot);
  end;

  if(UpdateNation) then
  begin
    for I := 1 to High(Servers[Player.ChannelIndex].Players) do
    begin
      if(Servers[Player.ChannelIndex].Players[i].Status >= Playing) then
        Servers[Player.ChannelIndex].Players[i].SendNationInformation;
    end;

    Nations[Player.Base.Character.Nation-1].SaveNation;
  end;


end;

class function TNPCHandlers.SignInCastle(var Player: TPlayer;
  NpcId: WORD): Boolean;
var
  xGuild: PGuild;
  i: Integer;
  EmptyAttackSlot: Byte;
begin
  EmptyAttackSlot := 255;
  xGuild := nil;

  if(Player.Character.GuildSlot = 0) then
  begin
    Player.SendClientMessage('Voc?tem que estar em uma legi鉶 para se cadastrar no castelo.');
    Exit;
  end;

  xGuild := @Guilds[Player.Character.GuildSlot];

  if(xGuild.GuildLeaderCharIndex <> Player.Base.Character.CharIndex) then
  begin
    Player.SendClientMessage('Voc?deve ser o lider da legi鉶 para cadastrar na guerra.');
    Exit;
  end;

  if(xGuild.Ally.Leader <> xGuild.Index) then
  begin
    Player.SendClientMessage('Voc?deve ser o lider da alian鏰 para cadastrar na guerra.');
    Exit;
  end;

  for I := 0 to 3 do
  begin
    if(Trim(String(Nations[xGuild.Nation-1].Cerco.Atacantes[i].LordMarechal)) <> '') then
    begin
      if(String(Nations[xGuild.Nation-1].Cerco.Atacantes[i].LordMarechal) =
        String(xGuild.Name)) then
      begin
        Player.SendClientMessage('Voc?j?est?com a sua alian鏰 cadastrada na guerra.');
        Exit;
      end;
    end
    else
    begin
      EmptyAttackSlot := i;
    end;

    if(Trim(String(Nations[xGuild.Nation-1].Cerco.Defensoras.LordMarechal)) <> '') then
    begin
      if(String(Nations[xGuild.Nation-1].Cerco.Defensoras.LordMarechal) =
        String(xGuild.Name)) then
      begin
        Player.SendClientMessage('Sua alian鏰 j?est?cadastrada como defesa.');
        Exit;
      end;
    end;
  end;

  if(EmptyAttackSlot = 255) then
  begin
    Player.SendClientMessage('N鉶 existe mais espa鏾 para novas alian鏰s atacantes.');
    Exit;
  end;

  if(Servers[Player.ChannelIndex].CastleSiegeHandler.WarInProgress) then
  begin
    Player.SendClientMessage('Voc?n鉶 pode se registrar com a guerra em andamento.');
    Exit;
  end;

  if not(DayOfWeek(Now) in [2,3,4,5,6]) then
  begin
    Player.SendClientMessage('Voc?n鉶 pode se cadastrar agora.');
    Exit;
  end;

  if(xGuild.Ally.Guilds[0].Index <> 0) then
  begin
    System.AnsiStrings.StrPLCopy(Nations[xGuild.Nation-1].
      Cerco.Atacantes[EmptyAttackSlot].LordMarechal, xGuild.Name, 18);
  end;

  if(xGuild.Ally.Guilds[1].Index <> 0) then
  begin
    System.AnsiStrings.StrPLCopy(Nations[xGuild.Nation-1].
      Cerco.Atacantes[EmptyAttackSlot].Estrategista,
      Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID(xGuild.Ally.Guilds[1].Index)].Name, 18);
  end;

  if(xGuild.Ally.Guilds[2].Index <> 0) then
  begin
    System.AnsiStrings.StrPLCopy(Nations[xGuild.Nation-1].
      Cerco.Atacantes[EmptyAttackSlot].Juiz,
      Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID(xGuild.Ally.Guilds[2].Index)].Name, 18);
  end;

  if(xGuild.Ally.Guilds[3].Index <> 0) then
  begin
    System.AnsiStrings.StrPLCopy(Nations[xGuild.Nation-1].
      Cerco.Atacantes[EmptyAttackSlot].Tesoureiro,
      Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID(xGuild.Ally.Guilds[3].Index)].Name, 18);
  end;

  Servers[Player.ChannelIndex].SendServerMsgForNation('O cerco de guerra do castelo teve altera珲es.',
    Player.Base.Character.Nation, 32, 16);

  for I := 1 to High(Servers[Player.ChannelIndex].Players) do
  begin
    if(Servers[Player.ChannelIndex].Players[i].Status >= Playing) then
      Servers[Player.ChannelIndex].Players[i].SendNationInformation;
  end;

end;

class function TNPCHandlers.EnterInCastle(var Player: TPlayer;
  NpcId: WORD): Boolean;
var
  xGuild: PGuild;
  i, j, k: Integer;
  EmptyAttackSlot: Byte;
  RigthToWar: Boolean;
  SpawnPoint: TPosition;
  NationTemp: Byte;
begin
  NationTemp := $FF;
  //verificar se o dia ?sabado das 20h ~ 21h
  //iniciar a guerra por aqui initilizing thread
  RigthToWar := False;

  SpawnPoint.Create(0,0);

  if(Player.Character.GuildSlot = 0) then
  begin
    Player.SendClientMessage('Voc?tem que estar em uma legi鉶 para entrar no castelo.');
    Exit;
  end;

  if(Player.Character.Base.Nation = 0) then
  begin
    Player.SendClientMessage('Voc?tem que estar em uma na玢o para entrar no castelo.');
    Exit;
  end;

  xGuild := @Guilds[Player.Character.GuildSlot];

  for I := 0 to 3 do
  begin
    if(String(Nations[Player.Character.Base.Nation-1].Cerco.Atacantes[i].LordMarechal) =
      String(xGuild.Name)) then
    begin
      RigthToWar := True;
    end;
    if(String(Nations[Player.Character.Base.Nation-1].Cerco.Atacantes[i].Estrategista) =
      String(xGuild.Name)) then
    begin
      RigthToWar := True;
    end;
    if(String(Nations[Player.Character.Base.Nation-1].Cerco.Atacantes[i].Juiz) =
      String(xGuild.Name)) then
    begin
      RigthToWar := True;
    end;
    if(String(Nations[Player.Character.Base.Nation-1].Cerco.Atacantes[i].Tesoureiro) =
      String(xGuild.Name)) then
    begin
      RigthToWar := True;
    end;

    case i of
      0:
        begin
          if not(SpawnPoint.IsValid) then
          begin
            SpawnPoint := TPosition.Create(3827, 2883);
            NationTemp := 7;
          end;
        end;
      1:
        begin
          if not(SpawnPoint.IsValid) then
          begin
            SpawnPoint := TPosition.Create(3341, 2883);
            NationTemp := 8;
          end;
        end;
      2:
        begin
          if not(SpawnPoint.IsValid) then
          begin
            SpawnPoint := TPosition.Create(3434, 2598);
            NationTemp := 9;
          end;
        end;
      3:
        begin
          if not(SpawnPoint.IsValid) then
          begin
            SpawnPoint := TPosition.Create(3734, 2598);
            NationTemp := 10;
          end;
        end;
    end;
  end;

  if not(RigthToWar) then
  begin
    if(String(Nations[Player.Character.Base.Nation-1].Cerco.Defensoras.LordMarechal) =
      String(xGuild.Name)) then
    begin
      RigthToWar := True;
      SpawnPoint := TPosition.Create(3583, 2804);
    end;
    if(String(Nations[Player.Character.Base.Nation-1].Cerco.Defensoras.Estrategista) =
      String(xGuild.Name)) then
    begin
      RigthToWar := True;
      SpawnPoint := TPosition.Create(3606, 2900);
    end;
    if(String(Nations[Player.Character.Base.Nation-1].Cerco.Defensoras.Juiz) =
      String(xGuild.Name)) then
    begin
      RigthToWar := True;
      SpawnPoint := TPosition.Create(3659, 2742);
    end;
    if(String(Nations[Player.Character.Base.Nation-1].Cerco.Defensoras.Tesoureiro) =
      String(xGuild.Name)) then
    begin
      RigthToWar := True;
      SpawnPoint := TPosition.Create(3548, 2714);
    end;

    if(RigthToWar) then
    begin
      NationTemp := 6;
    end;
  end;

  if not(RigthToWar) then
  begin
    Player.SendClientMessage('Voc?tem que estar registrado na guerra para entrar no castelo.');
    Exit;
  end;

  if(xGuild.GuildLeaderCharIndex = Player.Base.Character.CharIndex) then
  begin
    if(xGuild.Index = xGuild.Ally.Leader) then
    begin
      if not(Servers[player.ChannelIndex].CastleSiegeHandler.WarInProgress) then
      begin
        if((DayOfWeek(Now) = 7) and (HourOf(Now) >= 20)) then
        begin
          Player.SendClientMessage('A guerra s?pode se iniciar as 20h todos os s醔ados.');
          Exit;
        end;

        Servers[player.ChannelIndex].CastleSiegeThread :=
          TCastleSiegeThread.Create(1000, player.ChannelIndex);
        Servers[player.ChannelIndex].CastleSiegeHandler.WarInProgress := True;
        Servers[player.ChannelIndex].CastleSiegeHandler.WarTimeInit := Now;

        Servers[player.ChannelIndex].SendServerMsg(
          'A guerra de castelo come鏾u. Preparem-se...', 16, 32, 16);
      end;
    end;
  end;

  if(Servers[player.ChannelIndex].CastleSiegeHandler.WarInProgress) then
  begin
    Player.Teleport(SpawnPoint);
    Player.Base.PositionSpawnedInCastle := SpawnPoint;
    Player.Base.InClastleVerus := True;
    Player.Base.NationForCastle := NationTemp;
  end
  else
  begin
    Player.SendClientMessage('A guerra ainda n鉶 come鏾u.');
    Exit;
  end;

end;

end.
