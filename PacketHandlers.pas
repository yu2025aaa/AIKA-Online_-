unit PacketHandlers;
interface
{$O+}
uses
  Player, Packets, SysUtils, AnsiStrings, Clipbrd, MMSystem, Generics.Collections, Winsock2, Math;
type
  TPacketHandlers = class(TObject)
  public
    class function CheckLogin(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function CreateCharacter(var Player: TPlayer;
      var Buffer: array of BYTE): Boolean;
    class function RequestDeleteChar(var Player: TPlayer;
      var Buffer: Array of BYTE): Boolean;
    class function DeleteChar(var Player: TPlayer; var Buffer: array of BYTE)
      : Boolean; static;
    class function NumericToken(var Player: TPlayer; var Buffer: array of BYTE)
      : Boolean; static;
    class function MovementCommand(var Player: TPlayer;
      var Buffer: array of BYTE): Boolean;
    class function OpenNPC(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function CloseNPCOption(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function UpdateRotation(var Player: TPlayer;
      var Buffer: array of BYTE): Boolean;
    class function UpdateAction(var Player: TPlayer;
      var Buffer: array of BYTE): Boolean;
    class function ChangeGold(var Player: TPlayer;
      var Buffer: array of BYTE): Boolean;
    { Chat Functions }
    class function SendClientSay(var Player: TPlayer;
      var Buffer: array of BYTE): Boolean;
    class function SendItemChat(var Player: TPlayer;
      var Buffer: array of BYTE): Boolean;
    class function PKMode(var Player: TPlayer;
      var Buffer: array of BYTE): Boolean;
    class function BuyNPCItens(var Player: TPlayer;
      var Buffer: array of BYTE): Boolean;
    class function SellNPCItens(var Player: TPlayer;
      var Buffer: array of BYTE): Boolean;
    { Inventory Item Functions }
    class function DeleteItem(var Player: TPlayer;
      var Buffer: array of BYTE): Boolean;
    class function UngroupItem(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function AgroupItem(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function MoveItem(var Player: TPlayer;
      var Buffer: array of BYTE): Boolean;
    { Change Item Atributes [Refine/etc] }
    class function ChangeItemAttribute(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    { Troca }
    class function TradeRequest(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function TradeResponse(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function TradeRefresh(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function TradeCancel(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    { Item Bar Functions }
    class function ChangeItemBar(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    { Mob Functions }
    class function UpdateMobInfo(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    { Premium Items }
    class function BuyItemCash(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function SendGift(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function ReclaimCoupom(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    { Item Functions }
    class function UseItem(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function UseBuffItem(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function UnsealItem(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    { Buff Functions }
    class function RemoveBuff(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    { Attack & Skill Functions }
    class function UseSkill(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function LearnSkill(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function ResetSkills(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function AttackTarget(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE; ByUseSkill: Boolean = False): Boolean;
    class function RevivePlayer(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function CancelSkillLaunching(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    { Friend List }
    class function AddFriendRequest(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function AddFriendResponse(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function DeleteFriend(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    { Friend Chat }
    class function OpenFriendWindow(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function SendFriendSay(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function CloseFriendWindow(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    { Ver Char Info }
    class function RequestCharInfo(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    { Party }
    class function SendParty(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function AcceptParty(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function KickParty(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function DestroyParty(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function GiveLeaderParty(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function UpdateMemberPosition(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function AddSelfParty(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function PartyAlocateConfig(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    { Raid }
    class function SendRaid(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function AcceptRaid(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function ExitRaid(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function DestroyRaid(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function GiveLeaderRaid(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function RemoveFromRaid(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    { PersonalShop }
    class function CreatePersonalShop(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function OpenPersonalShop(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function BuyPersonalShopItem(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function ClosePersonalShop(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    { Change Channel }
    class function ChangeChannel(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function LoginIntoChannel(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    { Guild }
    class function CreateGuild(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function CloseGuildChest(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function ChangeGuildMemberRank(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function UpdateGuildRanksConfig(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function UpdateGuildNotices(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function UpdateGuildSite(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function InviteToGuildRequest(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function InviteToGuildAccept(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function InviteToGuildDeny(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function KickMemberOfGuild(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function ExitGuild(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function RequestGuildToAlly(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): Boolean;
    class function ChangeMasterGuild(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): Boolean;
    { Request Time }
    class function RequestServerTime(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): Boolean;
    class function RequestServerPing(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): Boolean;
    { Other Handlers }
    class function GetStatusPoint(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): Boolean;
    class function ReceiveEventItem(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): Boolean;
    { Duel }
    class function SendRequestDuel(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): Boolean;
    class function DuelResponse(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): Boolean;
    { Quest }
    class function AbandonQuest(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): Boolean;
    { Teleport do FC }
    class function TeleportSetPosition(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): Boolean;
    { Titles }
    class function UpdateActiveTitle(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): Boolean;
    { Pran }
    class function RenamePran(var Player: TPlayer;
      Buffer: Array of BYTE): Boolean;
    { Mail }
    class function openMail(var Player: TPlayer;
      var Buffer: array of BYTE): Boolean;
    class function withdrawMailItem(var Player: TPlayer;
      var Buffer: array of BYTE): Boolean;
    class function checkSendMailRequirements(var Player: TPlayer;
      var Buffer: array of BYTE): Boolean;
    class function sendCharacterMail(var Player: TPlayer;
      var Buffer: array of BYTE): Boolean;
    { Dungeons }
    class function RequestEnterDungeon(var Player: TPlayer;
      Buffer: Array of BYTE): Boolean;
    class function DungeonLobbyConfirm(var Player: TPlayer;
      Buffer: Array of BYTE): Boolean;
    { MakeItems }
    class function MakeItem(var Player: TPlayer; Buffer: Array of BYTE)
      : Boolean;
    class function RepairItens(var Player: TPlayer; Buffer: Array of BYTE)
      : Boolean;
    class function RenoveItem(var Player: TPlayer; Buffer: Array of BYTE)
      : Boolean;
    { Nation Packets }
    class function UpdateNationGold(var Player: TPlayer;
      Buffer: Array of BYTE): Boolean;
    class function UpdateNationTaxes(var Player: TPlayer;
      Buffer: Array of BYTE): Boolean;

    { GM Tool Functions }
    class function CheckGMLogin(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): Boolean;
    class function GMPlayerMove(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): Boolean;
    class function GMSendChat(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): Boolean;
    class function GMGoldManagment(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): Boolean;
    class function GMCashManagment(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): Boolean;
    class function GMLevelManagment(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): Boolean;
    class function GMBuffsManagment(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): Boolean;
    class function GMDisconnect(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): Boolean;
    class function GMBan(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
    class function GMEventItem(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
    class function GMEventItemForAll(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
    class function GMRequestServerInformation(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
    class function GMSendSpawnMob(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
    class function GMRequestPlayerAccount(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
    class function GMReceiveAccBackup(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
    class function GMRequestGMUsernames(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
    class function GMRequestCommandsAutoriz(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
<<<<<<< HEAD
    class function GMApproveCommand(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
    class function GMReproveCommand(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
    class function GMSendAddEffect(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
    class function GMRequestCreateCoupom(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
    class function GMRequestComprovantSearchID(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
    class function GMRequestComprovantSearchName(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
    class function GMRequestCreateComprovant(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
    class function GMRequestComprovantValidate(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
    class function GMRequestDeletePrans(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;

=======
>>>>>>> parent of 2438a94 (modificacoes 05/12)
    { All Attributes Aika Functions }
    class function RequestAllAttributes(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): Boolean;
    class function RequestAllAttributesTarget(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): Boolean;
    { Auction }
    class function RequestAuctionItems(var Player: TPlayer;
      Buffer: Array of BYTE): Boolean;
    class function RequestRegisterItem(var Player: TPlayer;
      Buffer: Array of BYTE): Boolean;
    class function RequestOwnAuctionItems(var Player: TPlayer;
      Buffer: Array of BYTE): Boolean;
    class function RequestAuctionOfferCancel(var Player: TPlayer;
      Buffer: Array of BYTE): Boolean;
    class function RequestAuctionOfferBuy(var Player: TPlayer;
      Buffer: Array of BYTE): Boolean;

    { Reliquares }
    class function RequestUpdateReliquare(var Player: TPlayer;
      Buffer: Array of BYTE): Boolean;
    class function MoveItemToReliquare(var Player: TPlayer;
      Buffer: Array of BYTE): Boolean;

    { Collect Item }
    class function CollectMapItem(var Player: TPlayer;
      Buffer: Array of BYTE): Boolean;
    class function CancelCollectMapItem(var Player: TPlayer;
      Buffer: Array of BYTE): Boolean;
  end;
implementation
uses
  GlobalDefs, Functions, Log, PlayerData, Util, MiscData, Windows,
  NPCHandlers, ItemFunctions, SkillFunctions, DateUtils, PartyData,
  CommandHandlers, BaseMob, GuildData, MOB, EntityMail, FilesData,
  AuctionFunctions, SQL;
{$REGION 'Login Functions'}
class function TPacketHandlers.CheckLogin(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TRequestLoginPacket absolute Buffer;
  Username, Token: String;
  I: Integer;
  Cid: WORD;
  dcs: Boolean;
begin
  Result := False;
  if (Packet.Version <> SERVER_VERSION) then
  begin
    Player.SendClientMessage
      ('Client desatualizado. Abrir pelo Launcher como Administrador.');
    Logger.Write(Packet.Version.ToString, TLogType.Packets);
    Player.SocketClosed := True;
    //Servers[Player.ChannelIndex].Disconnect(Player);
    Exit;
  end;
  Username := TFunctions.CharArrayToString(Packet.Username);
  Token := TFunctions.CharArrayToString(Packet.Token);
  ZeroMemory(@Player.Account.Characters, sizeof(TCharacterDB) * 3);
  if not(Player.LoadAccSQL(Username)) then
  begin
    Player.SendClientMessage('Conta não encontrada.');
    Player.SocketClosed := True;
    //Servers[Player.ChannelIndex].Disconnect(Player);
    Exit;
  end;
  if (Player.Account.Header.AccountStatus = 8) then
  begin
    Player.SendClientMessage
      ('Conta bloqueada. Entre em contato com o suporte.');
    //Servers[Player.ChannelIndex].Disconnect(Player);
    Player.SocketClosed := True;
    Exit;
  end;
  dcs := False;
  for I := Low(Servers) to High(Servers) do
  begin
    if(Player.ChannelIndex = i) then
      Cid := Servers[i].GetPlayerByUsernameAux(Username, Player.Base.ClientID)
    else
      Cid := Servers[i].GetPlayerByUsername(Username);
    if(Cid > 0) then
    begin
      //Servers[i].Disconnect(Cid);
      //Servers[i].Disconnect(Servers[i].Players[Cid]);
      Servers[i].Players[Cid].SocketClosed := True;
<<<<<<< HEAD

      if(Assigned(Servers[i].Players[Cid].Thread)) then
      begin
        closesocket(Servers[i].Players[Cid].Socket);
         if not(Servers[i].Players[Cid].Thread.Finished) then
           Servers[i].Players[Cid].Thread.Terminate;
          //WaitForSingleObject(Servers[i].Players[Cid].Thread.Handle, 10000);
      end;
      {waitTimes := 0;
      while(Servers[i].Players[cid].Base.ClientID > 0) do
      begin
        waitTimes := waitTimes + 1;
        Sleep(1000);

        if(waitTimes >= 10) then
        begin
          Player.SocketClosed := True;
          Exit;
        end;
      end; }
      {if(Servers[i].Players[Cid].Thread.ClientID > 0) then
=======
      if(Servers[i].Players[Cid].Thread.ClientID > 0) then
>>>>>>> parent of a46c38b (30)
      begin
        if(Assigned(Servers[i].Players[Cid].Thread)) then
          if not(Servers[i].Players[Cid].Thread.Finished) then
            WaitForSingleObject(Servers[i].Players[Cid].Thread.Handle, INFINITE);
      end;

      //ZeroMemory(@Servers[i].Players[Cid], sizeof(TPlayer));
      dcs := True;
    end;
  end;
  if(dcs) then
  begin
    Player.SendClientMessage('Conexão anterior finalizada.');
    Player.Account.Header.IsActive := true;
    Player.Base.IsActive := true;
    Player.Status := CharList;
    //Servers[Player.ChannelIndex].Disconnect(Player);
    Player.SocketClosed := True;
    Exit;
  end;

 { if (Player.Account.Header.IsActive) then
  begin
    Player.SendClientMessage('Conexão anterior finalizada.');
    Player.Account.Header.IsActive := true;
    Player.Base.IsActive := true;
    Player.Status := CharList;
    //Servers[Player.ChannelIndex].Disconnect(Player);
    Player.Socket := INVALID_SOCKET;
    closesocket(Player.Socket);
    for I := Low(Servers) to High(Servers) do
      Servers[I].Disconnect(Username);
    Exit;
  end;}
  Player.Account.Header.IsActive := true;
  Logger.Write('[' + string(ServerList[Player.ChannelIndex].Name) +
    ']: Usuário conectado [' + Username + '].', TLogType.ConnectionsTraffic);
  Player.Authenticated := True;
  Player.SaveStatus(Username);
  Player.SendCharList;
  Result := true;
end;
class function TPacketHandlers.NumericToken(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TNumericTokenPacket absolute Buffer;
begin
  Result := true; // 0 Não tem  // 1 tem numerica //2 trocar
  if (Player.Account.Header.NumError[Packet.Slot] >= 5) then
  begin
    //Servers[Player.ChannelIndex].Disconnect(Player);
    Player.SocketClosed := True;
   // Servers[Player.ChannelIndex].Disconnect(Player);
    Exit;
  end;
  case Packet.RequestChange of
    0:
      if (Player.Account.Header.NumericToken[Packet.Slot] = '') then
      begin
        Player.Account.Header.NumericToken[Packet.Slot] := Packet.Numeric_1;
        Player.SaveCharOnCharRoom(Packet.Slot);
        Player.SendToWorld(Packet.Slot);
      end;
    1:
      if (AnsiCompareText(Packet.Numeric_1,
        Trim(Player.Account.Header.NumericToken[Packet.Slot])) = 0) and
        (Player.Account.Header.NumError[Packet.Slot] < 5) then
      begin
        Player.Account.Header.NumError[Packet.Slot] := 0;
        Player.SendToWorld(Packet.Slot);
      end
      else
      begin
        Inc(Player.Account.Header.NumError[Packet.Slot], 1);
        Player.SubStatus := Waiting;
        Player.SendPacket(Packet, Packet.Header.Size);
        Player.SaveCharOnCharRoom(Packet.Slot);
        Player.SendCharList;
      end;
    2:
      if (AnsiCompareText(Packet.Numeric_2,
        Trim(Player.Account.Header.NumericToken[Packet.Slot])) = 0) and
        (Player.Account.Header.NumError[Packet.Slot] < 5) then
      begin
        Player.Account.Header.NumericToken[Packet.Slot] := Packet.Numeric_1;
        Player.SaveCharOnCharRoom(Packet.Slot);
        Player.SendToWorld(Packet.Slot);
      end
      else
      begin
        Inc(Player.Account.Header.NumError[Packet.Slot], 1);
        Player.SubStatus := Waiting;
        Player.SendPacket(Packet, Packet.Header.Size);
        Player.SaveCharOnCharRoom(Packet.Slot);
      end;
  end;
end;
{$ENDREGION}
{$REGION 'Character Functions'}
class function TPacketHandlers.CreateCharacter(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TCreateCharacterRequestPacket absolute Buffer;
  ClasseChar: BYTE;
  PlayerSQLComp: TQuery;
begin
  Result := true;
  if not(Player.VerifyAmount(string(Packet.Name))) then
  begin
    Player.SendClientMessage('Você já tem 3 personagens.', 16, 0, 1);
    Exit;
  end;

  if not(TFunctions.IsLetter(string(Packet.Name))) then
  begin
    Player.SendClientMessage('Você só pode usar caracteres alfanuméricos.', 16, 0, 1);
    Exit;
  end;

  if (Length(string(Packet.Name)) > 14) then
  begin
    Player.SendClientMessage('Limitado a 14 caracteres apenas.', 16, 0, 1);
    Exit;
  end;

  if Player.NameExists(string(Packet.Name)) then
  begin
    Player.SendClientMessage('Já existe um personagem com esse nome.',
      16, 0, 1);
    Exit;
  end;
  if (Packet.SlotIndex > 2) then
  begin
    Player.SendClientMessage('SLOT_ERROR', 16, 0, 1);
    Exit;
  end;
  if (Packet.ClassIndex < 10) then
  begin
    Player.SendClientMessage('class_id error, try to create your toon again.',
      16, 0, 1);
    Exit;
  end;
  ClasseChar := 0;
  // war
  if (Packet.ClassIndex >= 10) and (Packet.ClassIndex <= 19) then
    ClasseChar := 0;
  // templar
  if (Packet.ClassIndex >= 20) and (Packet.ClassIndex <= 29) then
    ClasseChar := 1;
  // att
  if (Packet.ClassIndex >= 30) and (Packet.ClassIndex <= 39) then
    ClasseChar := 2;
  // dual
  if (Packet.ClassIndex >= 40) and (Packet.ClassIndex <= 49) then
    ClasseChar := 3;
  // mago
  if (Packet.ClassIndex >= 50) and (Packet.ClassIndex <= 59) then
    ClasseChar := 4;
  // cleriga
  if (Packet.ClassIndex >= 60) and (Packet.ClassIndex <= 69) then
    ClasseChar := 5;
  if (Packet.Cabelo < 7700) or (Packet.Cabelo > 7731) then
    Exit;
  // Move os atributos iniciais para a database qndo cria o char
  Move(InitialAccounts[ClasseChar], Player.Account.Characters[Packet.SlotIndex],
    sizeof(TCharacterDB));
  Player.Account.Characters[Packet.SlotIndex].Base.Equip[0].Index :=
    Packet.ClassIndex;
  Player.Account.Characters[Packet.SlotIndex].Base.Equip[1].Index :=
    Packet.Cabelo;
  Player.Account.Characters[Packet.SlotIndex].Base.Inventory[60].Index := 5300;
  Player.Account.Header.Storage.Itens[80].Index := 5310;
{$REGION 'Setando as balas que vao no slot inv[5,6] e equip[15]'}
  case ClasseChar of
    2:
      begin
        Player.Account.Characters[Packet.SlotIndex].Base.Equip[15].
          Index := 4615;
        Player.Account.Characters[Packet.SlotIndex].Base.Equip[15].APP := 4615;
        Player.Account.Characters[Packet.SlotIndex].Base.Equip[15].Refi := 1000;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[5].
          Index := 4615;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[5]
          .APP := 4615;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[5]
          .Refi := 1000;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[6].
          Index := 4615;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[6]
          .APP := 4615;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[6]
          .Refi := 1000;
      end;
    3:
      begin
        Player.Account.Characters[Packet.SlotIndex].Base.Equip[15].
          Index := 4600;
        Player.Account.Characters[Packet.SlotIndex].Base.Equip[15].APP := 4600;
        Player.Account.Characters[Packet.SlotIndex].Base.Equip[15].Refi := 1000;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[5].
          Index := 4600;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[5]
          .APP := 4600;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[5]
          .Refi := 1000;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[6].
          Index := 4600;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[6]
          .APP := 4600;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[6]
          .Refi := 1000;
      end;
  end;
{$ENDREGION}
  Player.Account.Characters[Packet.SlotIndex].Base.CreationTime :=
    DateTimeToUnix(Now);
  Move(Packet.Name, Player.Account.Characters[Packet.SlotIndex]
    .Base.Name[0], 16);
  case Packet.Local of
    0:
      begin
        Player.Account.Characters[Packet.SlotIndex].LastPos.Create(3450, 690);
      end; // 0 = 3450 690
    1:
      begin // 1 = 3470 935
        Player.Account.Characters[Packet.SlotIndex].LastPos.Create(3470, 935);
      end;
  end;
  { Char Index }
  //Player.Account.Characters[Packet.SlotIndex].Index :=
    //TFunctions.IncCharactersCount(@Player);
  //Player.Account.Characters[Packet.SlotIndex].Base.CharIndex :=
    //Player.Account.Characters[Packet.SlotIndex].Index;
  Logger.Write(string(Player.Account.Header.Username) +
    ' criou um novo personagem [' + String(Packet.Name) + '].',
    TLogType.ConnectionsTraffic);
  if not(Player.SaveCreatedChar(string(Packet.Name), Packet.SlotIndex)) then
  begin
    ZeroMemory(@Player.Account.Characters[Packet.SlotIndex],
      sizeof(TCharacterDB));
    //TFunctions.DecCharactersCount(@Player);
    Player.SendCharList;
    Exit;
  end;

  PlayerSQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(PlayerSQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[CreateCharacter]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[CreateCharacter]', TlogType.Error);
    PlayerSQLComp.Destroy;
    Exit;
  end;

  PlayerSQLComp.SetQuery('select coalesce(av.referrer, "") from account_validate av inner join '+
  'accounts a on a.mail=av.email WHERE a.id = ' +
    Player.Account.Header.AccountId.ToString);
  PlayerSQLComp.Run();

  if(PlayerSQLComp.Query.RecordCount > 0) then
  begin
    if(PlayerSQLComp.Query.Fields[0].asstring <> '') then
    begin
      TItemFunctions.PutItemOnEvent(Player, 4357, 500);
    end;
  end;

  PlayerSQLComp.Destroy;

  Player.SendCharList;
end;
class function TPacketHandlers.RequestDeleteChar(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  RecvPacket: TDeleteCharacterRequestPacket absolute Buffer;
  FTime: TDateTime;
  Time: String;
  TimeNow: String;
  Day: Integer;
begin
  Result := False;

  //Player.SendClientMessage('Desativado até análise de risco de bugar sua conta.', 16);
  //Exit;

  if (RecvPacket.Delete = true) then
  begin
    if (AnsiCompareText(String(Player.Account.Characters[RecvPacket.SlotIndex]
      .Base.Numeric), String(RecvPacket.Numeric)) <> 0) then
    begin
      Player.SendCharList;
      Player.SendClientMessage('Numerica não correspondente!', 16);
      Exit;
    end;
    if (Player.Account.CharactersDelete[RecvPacket.SlotIndex] = true) then
    begin
      Player.Account.CharactersDelete[RecvPacket.SlotIndex] := False;
      Player.Account.CharactersDeleteTime[RecvPacket.SlotIndex] := '';
      Player.SaveCharOnCharRoom(RecvPacket.SlotIndex);
      Player.SendCharList;
      Player.SendClientMessage('Exclusão de personagem cancelada!', 16);
      Exit;
    end;
  end;
  if (Player.Account.Characters[RecvPacket.SlotIndex].Base.Name = '') then
  begin
    Player.SendCharList;
    Player.SendClientMessage
      ('Parece que esse personagem não existe!', 16);
    Exit;
  end;
  if (Player.Account.Characters[RecvPacket.SlotIndex].Base.Numeric <> '') then
  begin
    if (String(RecvPacket.Numeric) <> String(Player.Account.Characters
      [RecvPacket.SlotIndex].Base.Numeric)) then
    begin
      Player.SendCharList;
      Player.SendClientMessage('Numerica não correspondente!', 16);
      Exit;
    end;
  end
  else
  begin
    Player.SendCharList;
    Player.SendClientMessage('Você não possui uma numérica. Crie uma.', 16);
    Exit;
  end;
  if (Player.Account.CharactersDelete[RecvPacket.SlotIndex] = False) then
  begin
    FTime := IncDay(Now, DELETE_DAYS_INC);
    Player.Account.CharactersDelete[RecvPacket.SlotIndex] := true;
{$WARNINGS OFF}
    Player.Account.CharactersDeleteTime[RecvPacket.SlotIndex] :=
      DateTimeToStr(FTime);
{$WARNINGS ON}
    Player.SaveCharOnCharRoom(RecvPacket.SlotIndex);
    Player.SendCharList;
    Result := true;
    Exit;
  end;
  FTime := StrToDateTime(String(Player.Account.CharactersDeleteTime
    [RecvPacket.SlotIndex]));
  if (FTime < Now) then
  begin
    Player.SendCharList;
    Player.SendClientMessage
      ('Você ainda não pode excluir este personagem!', 16);
    Exit;
  end;
  Result := true;
end;
class function TPacketHandlers.DeleteChar(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  RecvPacket: TDeleteChar absolute Buffer;
  Slot: BYTE;
  FTime: TDateTime;
  Time: String;
  TimeNow: String;
  CharFileDir, MailsFileDir, FriendsFileDir, Name: string;
  Guild: PGuild;
begin
  Result := False;
  //Player.SendClientMessage('Desativado até análise de risco de bugar sua conta.', 16);
  //Exit;

  Slot := BYTE(RecvPacket.Slot);
  if (String(Player.Account.Characters[Slot].Base.Numeric) <> '') then
  begin
    if (String(RecvPacket.Numeric) <> String(Player.Account.Characters[Slot]
      .Base.Numeric)) then
    begin
      Player.SendCharList;
      Player.SendClientMessage('Numerica não correspondente!', 16);
      Exit;
    end;
  end;
  FTime := StrToDateTime(String(Player.Account.CharactersDeleteTime[Slot]));
  if (CompareDateTime(Now, FTime) = -1) then
  begin
    Player.SendCharList;
    Player.SendClientMessage
      ('Você ainda não pode excluir este personagem!', 16);
    Exit;
  end;
  if (Player.Account.CharactersDelete[Slot] = true) and
    (String(Player.Account.Characters[Slot].Base.Name) <> '') then
  begin
    if Player.Account.Characters[Slot].Base.GuildIndex > 0 then
    begin
      Guild := @Guilds[Player.Account.Characters[Slot].Base.GuildIndex];
      Guild.RemoveMember(Player.Account.Characters[Slot].Index, False);
      Player.Account.Characters[Slot].Base.GuildIndex := 0;
    end;
    Name := string(Player.Account.Characters[Slot].Base.Name);
    { if (TFunctions.IsLetter(Name)) then
      begin
      CharFileDir := 'C:\Database\Chars\' + Trim(Name)[1] + '\' + Trim(Name)
      + '.char';
      MailsFileDir := 'C:\Database\Mails\' + Trim(Name)[1] + '\' + Trim(Name)
      + '.mail';
      FriendsFileDir := 'C:\Database\Friends\' + Trim(Name)[1] + '\' +
      Trim(Name) + '.friends'
      end
      else
      begin
      CharFileDir := 'C:\Database\Chars\etc\' + Trim(Name) + '.char';
      MailsFileDir := 'C:\Database\Mails\etc\' + Trim(Name) + '.mail';
      FriendsFileDir := 'C:\Database\Friends\etc\' + Trim(Name) + '.friends';
      end;
      DeleteFile(PWideChar(CharFileDir));
      DeleteFile(PWideChar(MailsFileDir));
      DeleteFile(PWideChar(FriendsFileDir)); }
    Player.DeleteCharacter(Slot);
    ZeroMemory(@Player.Account.Characters[Slot], sizeof(TCharacterDB));
    Player.Account.Header.NumericToken[Slot] := '';
    Player.Account.Header.NumError[Slot] := 0;
    Player.Account.Header.PlayerDelete[Slot] := False;
    Player.SendCharList;
    Player.SendClientMessage('Personagem deletado com sucesso!', 16);
  end
  else
  begin
    Player.SendClientMessage('Você não pode deletar esse personagem!', 16);
    Player.SendCharList;
    Exit;
  end;
  // ZeroMemory(@RecvPacket, sizeof(RecvPacket));
  Result := true;
end;
{$ENDREGION}
{$REGION 'Character Status Functions [Move/PK/Rotation]'}
class function TPacketHandlers.MovementCommand(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TMovementPacket absolute Buffer;
  NewPranPosition: TPosition;
  UpdatedPosition: Boolean;
  I: WORD;
  SecIntoMoving, SecIntoMessageHack, RealSecIntoMoving: Int64;
begin
  Result := False;
  UpdatedPosition := False;
  //if not(Packet.Destination.IsValid) or (Packet.MoveType <> MOVE_NORMAL)
  { (Player.OpennedNPC > 0) or (Player.OpennedOption > 0) } //then
    //Exit;
 { if (Player.Base.PlayerCharacter.LastPos = Packet.Destination) then
  begin
    Result := true;
    Exit;
  end;
  SecIntoMoving := MilliSecondsBetween(Now, Player.Base.LastMovedTime);
  RealSecIntoMoving := 1000;
  if(SecIntoMoving < 600) then
  begin
    RealSecIntoMoving := SecIntoMoving;
    SecIntoMoving := 600;
  end;
  if(SecIntoMoving <= 3000) then
  begin
    if(Player.Base.PlayerCharacter.LastPos.Distance(Packet.Destination) >
      (Round(SecIntoMoving / 1000) * (Player.Base.PlayerCharacter.SpeedMove / 5.5))) then
    begin
      Player.SendClientMessage('Você se moveu além do que conseguiria de acordo com sua velocidade / tempo.');
      SecIntoMessageHack := SecondsBetween(Now, Player.Base.LastMovedMessageHack);
      if(SecIntoMessageHack <= 3) then
      begin //dar dc no cara
        Servers[Player.ChannelIndex].Disconnect(Player);
        Exit;
      end
      else //apenas volta a posicao
      begin
        Player.Base.LastMovedMessageHack := Now;
        Packet.Destination := Player.Base.PlayerCharacter.LastPos;
        Player.Base.SendToVisible(Packet, Packet.Header.Size, True);
      end;
      Player.Base.LastMovedTime := Now;
      Exit;
    end;
    {if(RealSecIntoMoving <= 300) then
    begin
      //Packet.Destination := Player.Base.PlayerCharacter.LastPos;
      //Player.Base.SendToVisible(Packet, Packet.Header.Size, True);
      Exit;
    end; }
  {end;
  if(Player.Base.PlayerCharacter.LastPos.Distance(Packet.Destination) >
      (Player.Base.PlayerCharacter.SpeedMove / 5.5)) then
  begin
    Player.SendClientMessage('Você se moveu além do que conseguiria de acordo com sua velocidade.');
    SecIntoMessageHack := SecondsBetween(Now, Player.Base.LastMovedMessageHack);
    if(SecIntoMessageHack <= 3) then
    begin //dar dc no cara
      Servers[Player.ChannelIndex].Disconnect(Player);
      Exit;
    end
    else //apenas volta a posicao
    begin
      Player.Base.LastMovedMessageHack := Now;
      Packet.Destination := Player.Base.PlayerCharacter.LastPos;
      Player.Base.SendToVisible(Packet, Packet.Header.Size, True);
    end;
    Player.Base.LastMovedTime := Now;
    Exit;
  end;     }
  // if Packet.Destination.Distance(Player.Base.PlayerCharacter.LastPos) > 30 then
  // Exit;
  { if not Servers[Player.ChannelIndex].UpdateWorld(Player.Base.ClientId,
    Packet.Destination, WORLD_MOB) then
    begin
    Result := true;
    Exit;
    end; }
  if(Player.Base.IsDead) then
    Exit;
  Player.Base.PlayerCharacter.LastPos := Packet.Destination;
  Player.Base.SendToVisible(Packet, Packet.Header.Size, False);
  if Player.Base.PlayerCharacter.LastPos.Distance(Player.Character.LastPos) >= 3
  then
  begin
    Player.Character.LastPos := Packet.Destination;
    if (Player.GetCurrentCity <> Player.CurrentCity) then
    begin
      //Player.CurrentCity := Player.GetCurrentCity;
      Player.CurrentCityID := Player.GetCurrentCityID;
      Player.RefreshMeToFriends;
    end;
    Player.Base.UpdateVisibleList();
    Player.SetCurrentNeighbors;
    if (Player.PartyIndex <> 0) then
    begin
      for I in Player.Party.Members do
      begin
        if (I = Player.Base.ClientId) then
          Continue;
        Player.SendPositionParty(I);
      end;
    end;
    UpdatedPosition := true;
    Player.OpennedOption := 0;
    Player.OpennedNPC := 0;
  end;
  if (UpdatedPosition) then
  begin
    if (Player.Account.Header.Pran1.Iddb > 0) then
    begin
      if (Player.Account.Header.Pran1.IsSpawned) then
      begin
        Randomize;
        NewPranPosition := Player.Base.Neighbors[Random(7)].pos;
        if (NewPranPosition.Distance(Player.Account.Header.Pran1.Position) >= 2)
        then
        begin
          Player.Account.Header.Pran1.Position := NewPranPosition;
          ZeroMemory(@Packet, sizeof(Packet));
          Packet.Header.Size := sizeof(Packet);
          Packet.Header.Index := Player.Base.PranClientID;
          Packet.Header.Code := $301;
          Packet.Destination := Player.Account.Header.Pran1.Position;
          Packet.MoveType := MOVE_NORMAL;
          Packet.Speed := Player.Base.PlayerCharacter.SpeedMove-10;
          if (NewPranPosition.Distance(Player.Base.PlayerCharacter.LastPos) >= 15) then
          begin
            Packet.Speed := Player.Base.PlayerCharacter.SpeedMove + 10;
          end;
          Player.Base.SendToVisible(Packet, Packet.Header.Size, true);
        end;
      end;
    end;
    if (Player.Account.Header.Pran2.Iddb > 0) then
    begin
      if (Player.Account.Header.Pran2.IsSpawned) then
      begin
        Randomize;
        NewPranPosition := Player.Base.Neighbors[Random(7)].pos;
        if (NewPranPosition.Distance(Player.Account.Header.Pran2.Position) >= 2)
        then
        begin
          Player.Account.Header.Pran2.Position := NewPranPosition;
          ZeroMemory(@Packet, sizeof(Packet));
          Packet.Header.Size := sizeof(Packet);
          Packet.Header.Index := Player.Base.PranClientID;
          Packet.Header.Code := $301;
          Packet.Destination := Player.Account.Header.Pran2.Position;
          Packet.MoveType := MOVE_NORMAL;
          Packet.Speed := Player.Base.PlayerCharacter.SpeedMove-10;
          if (NewPranPosition.Distance(Player.Base.PlayerCharacter.LastPos) >= 15) then
          begin
            Packet.Speed := Player.Base.PlayerCharacter.SpeedMove + 10;
          end;
          Player.Base.SendToVisible(Packet, Packet.Header.Size, true);
        end;
      end;
    end;
  end;
  Player.Base.LastMovedTime := Now;

  Player.Base.CurrentAction := 0;

  Result := true;
end;
class function TPacketHandlers.PKMode(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TSignalData absolute Buffer;
begin
  if Packet.Data > 255 then
  begin
    Result := False;
    Exit;
  end;
  if ((Player.Character.PlayerKill = False) and (Player.Dueling)) then
  begin
    Player.SendClientMessage('Você não ligar o PvP em duelo.');
    Result := False;
    Exit;
  end;
  Player.Character.PlayerKill := IFThen(Packet.Data = 1);
  Player.Base.PlayerCharacter.PlayerKill := Player.Character.PlayerKill;
  Player.Base.SendToVisible(Packet, Packet.Header.Size);
  Result := true;
end;
class function TPacketHandlers.UpdateRotation(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TSignalData absolute Buffer;
begin
  Result := False;
  if (Player.Character.Rotation = Packet.Data) then
    Exit;
  Player.Character.Rotation := Packet.Data;
  // Player.Character.LastPos := Player.Character.CurrentPos;
  Player.Base.SendToVisible(Packet, Packet.Header.Size, False);
  Result := true;
end;
class function TPacketHandlers.UpdateAction(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TSendActionPacket absolute Buffer;
begin
  //Logger.Write(Packet.Data.ToString, TLogType.Packets);

  //40, 65
  if(Packet.Index in [40, 65]) then
  begin
    Player.Base.CurrentAction := Packet.Index;
  end;

  Player.Base.SendToVisible(Packet, Packet.Header.Size, false);
end;
class function TPacketHandlers.ChangeGold(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TChangeChestGoldPacket absolute Buffer;
  Guild: PGuild;
begin
  Result := False;
  if (Packet.ChestType < 2) or (Packet.ChestType > 3) then
    Exit;
  if Packet.Value = 0 then
    Exit;
  case Packet.ChestType of
    STORAGE_TYPE:
      begin
        {if not(Player.OpennedOption = 7) or (Player.OpennedNPC <= 0) then
          Exit;}
        if Packet.Value < 0 then
        begin
          if Player.Account.Header.Storage.Gold < abs(Packet.Value) then
            Exit;
          if (Player.Character.Base.Gold + abs(Packet.Value)) > 2000000000 then
          begin
            Player.SendClientMessage('Gold máximo: 2000000000.');
            Exit;
          end;
        end;
        if Packet.Value > 0 then
        begin
          if Player.Character.Base.Gold < Packet.Value then
            Exit;
          if (Player.Account.Header.Storage.Gold + Packet.Value) > 2000000000
          then
          begin
            Player.SendClientMessage('Gold máximo: 2000000000.');
            Exit;
          end;
        end;
        Player.Account.Header.Storage.Gold := Player.Account.Header.Storage.Gold
          + Packet.Value;
        Player.Character.Base.Gold := Player.Character.Base.Gold +
          (0 - Packet.Value);
        Player.RefreshMoney;
        Player.Character.IsStorageSend := False;
        Player.SendStorage(STORAGE_TYPE_PLAYER);
      end;
    GUILDCHEST_TYPE:
      begin
        if not(Player.OpennedOption = 11) or (Player.OpennedNPC <= 0) then
          Exit;
        if Player.Character.Base.GuildIndex <= 0 then
          Exit;
        Guild := @Guilds[Player.Character.GuildSlot];
        if Guild.MemberInChest <> Guild.FindMemberFromCharIndex
          (Player.Character.Index) then
          Exit;
        Guild.LastChestActionDate := Now;
        if Guild.GetRankConfig
          (Guild.Members[Guild.FindMemberFromCharIndex(Player.Character.Index)
          ].Rank).UseGWH = False then
        begin
          Player.SendClientMessage('Você não tem permissão para isso.');
          Exit;
        end;
        if Packet.Value < 0 then
        begin
          if Guild.Chest.Gold < abs(Packet.Value) then
            Exit;
          if (Player.Character.Base.Gold + abs(Packet.Value)) > 2000000000 then
          begin
            Player.SendClientMessage('Gold máximo: 2000000000.');
            Exit;
          end;
        end;
        if Packet.Value > 0 then
          if Player.Character.Base.Gold < Packet.Value then
            Exit;
        Guild.Chest.Gold := Guild.Chest.Gold + UInt64(Packet.Value);
        Player.Character.Base.Gold := Player.Character.Base.Gold +
          (0 - Packet.Value);
        Player.RefreshMoney;
        Player.RefreshGuildChestGold;
      end;
  end;
  Result := true;
end;
{$ENDREGION}
{$REGION 'Chat Functions'}
class function TPacketHandlers.SendClientSay(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TChatPacket absolute Buffer;
  OtherPlayer: PPlayer;
  ItemSlot: BYTE;
  PingString, strAux: String;
  PingInt, I, j: Integer;
begin
  strAux:='';
  Result := False;
  case Packet.TypeChat of
    CHAT_TYPE_NORMAL:
      begin
        if (String(Packet.Fala) = '`ping') then
        begin
          Player.SendData(Player.Base.ClientID, $F93B, 0);
          Player.PingCommandUsed := Now;
          Result := true;
          Exit;
        end;

        if(Packet.Fala[0] = '%') then
        begin
          if(Player.IsArchon) then
          begin
            Packet.TypeChat := CHAT_TYPE_NATION;

            if(Nations[Player.Base.Character.Nation-1].TacticianGuildID =
              Guilds[Player.Character.GuildSlot].Index) then
            begin
              Packet.NotUse[0] := 1;
            end;

            if(Nations[Player.Base.Character.Nation-1].JudgeGuildID =
              Guilds[Player.Character.GuildSlot].Index) then
            begin
              Packet.NotUse[0] := 2;
            end;

            if(Nations[Player.Base.Character.Nation-1].TreasurerGuildID =
              Guilds[Player.Character.GuildSlot].Index) then
            begin
              Packet.NotUse[0] := 3;
            end;

            strAux := string(Packet.Fala);
            strAux := ReplaceStr(strAux, '%', '');

            System.AnsiStrings.StrPLCopy(Packet.Fala, strAux, 128);

            for I := Low(Servers) to High(Servers) do
            begin
              for j := Low(Servers[I].Players) to High(Servers[I].Players) do
              begin
                if (Servers[I].Players[j].Status < Playing) then
                  Continue;
                if ((Servers[I].Players[j].Base.Character.Nation = Player.Base.
                  Character.Nation) and
                  not(Servers[I].Players[j].Base.Character.Nation = 0)) then
                begin
                  Servers[I].Players[j].SendPacket(Packet, Packet.Header.Size);
                end;
              end;
            end;
          end
          else
          begin
            Player.Base.SendToVisible(Packet, Packet.Header.Size);
          end;
        end
        else
        begin
          Player.Base.SendToVisible(Packet, Packet.Header.Size);
        end;
      end;
    CHAT_TYPE_SUSSURO:
      begin
        if (Player.Account.Header.AccountType >= GameMaster) and
          (Packet.Nick[0] = '/') then
        begin
          TCommandHandlers.ProcessCommands(Player, string(Packet.Nick),
            string(Packet.Fala));
          Result := true;
          Exit;
        end;
        if not(Servers[Player.ChannelIndex].GetPlayerByName(string(Packet.Nick),
          OtherPlayer)) then
        begin
          Player.SendClientMessage('Personagem não encontrado.');
          Exit;
        end;
        Player.SendPacket(Packet, Packet.Header.Size);
        AnsiStrings.StrLCopy(Packet.Nick, Player.Character.Base.Name, 16);
        OtherPlayer.SendPacket(Packet, Packet.Header.Size);
      end;
    CHAT_TYPE_GRUPO:
      begin
        Player.SendToParty(Packet, Packet.Header.Size);
      end;
    CHAT_TYPE_GUILD:
      begin
        if Player.Character.Base.GuildIndex <= 0 then
        begin
          Player.SendClientMessage('Você não está em uma guild.');
          Exit;
        end;
        Guilds[Player.Character.GuildSlot].SendChatMessage(Packet,
          Packet.Header.Size);
      end;
    CHAT_TYPE_GRITO:
      begin
        if (SecondsBetween(Now, Player.ShoutTime) < 5) then
        begin
          Player.SendClientMessage('Você não pode floodar o grito.');
        end
        else
        begin
          if(Player.Base.Character.Nation > 0) then
          begin
            for I := 1 to MAX_CONNECTIONS do
            begin
              if((Servers[Player.ChannelIndex].Players[i].Status < Playing) or
                (Servers[Player.ChannelIndex].Players[i].SocketClosed)) then
                Continue;

              if(Servers[Player.ChannelIndex].Players[i].Base.Character.Nation > 0) then
              begin
                if(Servers[Player.ChannelIndex].Players[i].Base.Character.Nation =
                  Player.Base.Character.Nation) then
                begin
                  Servers[Player.ChannelIndex].SendPacketTo(i,Packet, Packet.Header.Size);
                end;
              end
              else
              begin
                Servers[Player.ChannelIndex].SendPacketTo(i,Packet, Packet.Header.Size);
              end;

            end;
          end
          else
          begin
            Servers[Player.ChannelIndex].SendToAll(Packet, Packet.Header.Size);
          end;
          Player.ShoutTime := Now;
          for I := Low(Servers) to High(Servers) do
          begin
            for j := Low(Servers[i].Players) to High(Servers[i].Players) do
            begin
              if((Servers[i].Players[j].CheckGameMasterLogged) or
                (Servers[i].Players[j].CheckAdminLogged)) then
              begin
                //Sleep(100);
                Servers[i].Players[j].SendMessageGritoForGameMaster(String(Player.Base.Character.Name),
                  Player.ChannelIndex+1, String(Packet.Fala));
              end;
            end;
          end;
        end;
      end;
    CHAT_TYPE_ALLY:
      begin
        if Player.Character.Base.GuildIndex <= 0 then
        begin
          Player.SendClientMessage('Você não está em uma guild.');
          Exit;
        end;

        if(Guilds[Player.Character.GuildSlot].GetAllyGuildCount <= 1) then
          Exit;

        Guilds[Player.Character.GuildSlot].SendChatAllyMessage(Packet,
          Packet.Header.Size);
      end;
    CHAT_TYPE_NATION:
      begin
        if not(Player.IsArchon) then
        begin
          if not(Player.IsMarshal) then
            Exit;
        end;
        for I := Low(Servers) to High(Servers) do
        begin
          for j := Low(Servers[I].Players) to High(Servers[I].Players) do
          begin
            if (Servers[I].Players[j].Status < Playing) then
              Continue;
            if ((Servers[I].Players[j].Base.Character.Nation = Player.Base.
              Character.Nation) and
              not(Servers[I].Players[j].Base.Character.Nation = 0)) then
            begin
              Servers[I].Players[j].SendPacket(Packet, Packet.Header.Size);
            end;
          end;
        end;
      end;
    CHAT_TYPE_MEGAFONE:
      begin
        ItemSlot := TItemFunctions.GetItemSlotByItemType(Player, 80,
          INV_TYPE, 0);
        if (ItemSlot = 255) then
        begin
          Player.SendClientMessage
            ('Você precisa ter o item [Ticket do Megafone]');
          Exit;
        end
        else
        begin
          TItemFunctions.DecreaseAmount(@Player.Base.Character.Inventory
            [ItemSlot], 1);
          Player.Base.SendRefreshItemSlot(INV_TYPE, ItemSlot,
            Player.Base.Character.Inventory[ItemSlot], False);
          Servers[Player.ChannelIndex].SendToAll(Packet, Packet.Header.Size);
        end;
      end
  else
    begin
      Logger.Write('packet-> chatType: ' + Packet.TypeChat.ToString,
        TLogType.Packets);
      Exit;
    end;
  end;
  Result := true;
end;
class function TPacketHandlers.SendItemChat(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TLinkItemPacket absolute Buffer;
begin
  Result := False;
  if not(Player.Base.IsActive) then
    Exit;
  if not(Packet.LinkItem) then
    Exit;
  Result := Player.SendItemChat(Packet.ItemSlot, Packet.ChatType,
    string(Packet.Fala));
end;
{$ENDREGION}
{$REGION 'NPC Functions'}
class function TPacketHandlers.OpenNPC(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TOpenNPCPacket absolute Buffer;
  PacketReliqShow: TSendDevirInfoPacket;
  ReliqSlot: BYTE;
  i, InvSlotFree: Integer;
begin
  Result := False;
  if (Packet.Index = 0) and not(Packet.Type1 = 8) then
  begin
    Player.OpennedNPC := 0;
    Player.OpennedOption := 0;
    Exit;
  end;
  if(((Packet.Index >= 3048) and (Packet.Index <= 3334)) or ((Packet.Index >= 3380) and (Packet.Index <= 9147))) then
  begin //clique nos guardas da própia nação
    Player.OpennedNPC := 0;
    Player.OpennedOption := 0;
    Exit;
  end;
  if(Packet.Index >= 10148) and (Packet.Index <= 10239) then
  begin //clique nos objetos de coletar (baú/ reliquias/etc)
    case Servers[Player.ChannelIndex].OBJ[Packet.Index].Face of
      320:
      begin
        InvSlotFree := TItemFunctions.GetInvAvailableSlots(Player);
        if(InvSlotFree <= 0) then
        begin
          Player.SendClientMessage('Inventário cheio para coletar relíquias.');
          Exit;
        end;
        if (Player.Base.BuffExistsByIndex(77)) then
        begin // inv dual
          Player.Base.RemoveBuffByIndex(77);
        end;
        if (Player.Base.BuffExistsByIndex(53)) then
        begin // inv att
          Player.Base.RemoveBuffByIndex(53);
        end;
        if (Player.Base.BuffExistsByIndex(153)) then
        begin // predador
          Player.Base.RemoveBuffByIndex(153);
        end;
        Servers[Player.ChannelIndex].CollectReliquare(@Player, Packet.Index);
      end;
    else
      begin
        //programar aqui para as caixas de item/gold/evento
      end;
    end;
    Exit;
  end;
  if (Packet.Index <= MAX_CONNECTIONS) and not(Packet.Type1 = 8) then
  begin
    Player.SendClientMessage('Esta opção não funciona em jogadores.');
    Player.OpennedNPC := 0;
    Player.OpennedOption := 0;
    Exit;
  end;
  {if (Packet.Index > 3339) then
  begin
    Player.OpennedNPC := 0;
    Player.OpennedOption := 0;
    Exit; // nao se podem abrir mobs/guardas
  end;}
  case Packet.Type1 of
    1,2,21: //Conversa, Quests, Menu não fecha o NPC
      begin
      end;
  else
    begin
      Player.SendSignal($7535, $10F); //fecha o npc pra reabrir
    end;
  end;
  case Packet.Index of
    3335: // amk devir
      begin
        if not(Player.Base.PlayerCharacter.LastPos.InRange
          (Servers[Player.ChannelIndex].DevirNpc[3335].PlayerChar.LastPos, 10))
        then
        begin
          Player.SendClientMessage('Você está muito longe do templo.');
          Player.OpennedNPC := 0;
          Player.OpennedOption := 0;
          Exit;
        end;
        if (Integer(Player.Account.Header.Nation) = 0) then
        begin
          Player.SendClientMessage
            ('Você não pode abrir templos. Registre-se em uma nação primeiro!');
          Player.OpennedNPC := 0;
          Player.OpennedOption := 0;
          Exit;
        end;
        if (Servers[Player.ChannelIndex].Devires[0].NationID =
          Integer(Player.Account.Header.Nation)) then
        begin
          ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);
          if (ReliqSlot = 255) then
          begin
            Player.SendClientMessage
              ('Você não pode abrir o templo de sua própia nação.');
            Player.OpennedNPC := 0;
            Player.OpennedOption := 0;
            Exit;
          end
          else
          begin // [ENTREGAR RELIQUIA]
            {if(Servers[Player.ChannelIndex].Devires[0].PlayerIndexGettingReliq <> 0) then
            begin
              Player.SendClientMessage('O jogador <' +
                AnsiString(Servers[Player.ChannelIndex].Players[
                Servers[Player.ChannelIndex].Devires[0].PlayerIndexGettingReliq].
                Base.Character.Name) + '> está com o devir aberto agora.');
              Exit;
            end; }
            ZeroMemory(@PacketReliqShow, sizeof(PacketReliqShow));
            PacketReliqShow.Header.Size := sizeof(PacketReliqShow);
            PacketReliqShow.Header.Index := 0;
            PacketReliqShow.Header.Code := $B52;
            PacketReliqShow.DevirID := 00;
            PacketReliqShow.TypeOpen := 5;
            for I := 0 to 4 do
            begin
              if(Servers[Player.ChannelIndex].Devires[0].Slots[i].ItemId <> 0) then
              begin
                PacketReliqShow.DevirReliq.Slots[i].ItemID :=
                  Servers[Player.ChannelIndex].Devires[0].Slots[i].ItemId;
                PacketReliqShow.DevirReliq.Slots[i].APP :=
                  PacketReliqShow.DevirReliq.Slots[i].ItemID;
                PacketReliqShow.DevirReliq.Slots[i].Unknown := i;
                PacketReliqShow.DevirReliq.Slots[i].TimeToEstabilish :=
                   TFunctions.DateTimeToUNIXTimeFAST(
                    Servers[Player.ChannelIndex].Devires[0].Slots[i].TimeToEstabilish);
                PacketReliqShow.DevirReliq.Slots[i].UnkByte1 := 2;
                PacketReliqShow.DevirReliq.Slots[i].UnkByte2 := 1;
                PacketReliqShow.DevirReliInfo.Slots[i].ItemID :=
                  Servers[Player.ChannelIndex].Devires[0].Slots[i].ItemId;
                PacketReliqShow.DevirReliInfo.Slots[i].IsActive := 1;
                PacketReliqShow.DevirReliInfo.Slots[i].TimeCapped :=
                TFunctions.DateTimeToUNIXTimeFAST(
                    Servers[Player.ChannelIndex].Devires[0].Slots[i].TimeCapped);
                System.AnsiStrings.StrPLCopy(PacketReliqShow.DevirReliInfo.Slots[i].NameCapped,
                String(Servers[Player.ChannelIndex].Devires[0].Slots[i].NameCapped), 16);
              end
              else
              begin
                PacketReliqShow.DevirReliInfo.Slots[i].IsActive :=
                  Servers[Player.ChannelIndex].Devires[0].Slots[i].IsAble.ToInteger;
              end;
            end;
            Player.SendPacket(PacketReliqShow, PacketReliqShow.Header.Size);
            Player.OpennedNPC := Packet.Index;
            Player.OpennedOption := 5;
            Player.OpennedDevir := 0;
            Player.OpennedTemple := Packet.Index;
            Servers[Player.ChannelIndex].Devires[0].PlayerIndexGettingReliq :=
              Player.Base.ClientID;
            Exit;
          end;
        end
        else
        begin
          if(Servers[Player.ChannelIndex].Devires[0].IsOpen) then
          begin
            {if(Servers[Player.ChannelIndex].Devires[0].PlayerIndexGettingReliq <> 0) then
            begin
              Player.SendClientMessage('O jogador <' +
                AnsiString(Servers[Player.ChannelIndex].Players[
                Servers[Player.ChannelIndex].Devires[0].PlayerIndexGettingReliq].
                Base.Character.Name) + '> está com o devir aberto agora.');
              Exit;
            end;}
            ZeroMemory(@PacketReliqShow, sizeof(PacketReliqShow));
            PacketReliqShow.Header.Size := sizeof(PacketReliqShow);
            PacketReliqShow.Header.Index := 0;
            PacketReliqShow.Header.Code := $B52;
            PacketReliqShow.DevirID := 00;
            PacketReliqShow.TypeOpen := 05;
            for I := 0 to 4 do
            begin
              if(Servers[Player.ChannelIndex].Devires[0].Slots[i].ItemId <> 0) then
              begin
                PacketReliqShow.DevirReliq.Slots[i].ItemID :=
                  Servers[Player.ChannelIndex].Devires[0].Slots[i].ItemId;
                PacketReliqShow.DevirReliq.Slots[i].APP :=
                  PacketReliqShow.DevirReliq.Slots[i].ItemID;
                PacketReliqShow.DevirReliq.Slots[i].Unknown := i;
                PacketReliqShow.DevirReliq.Slots[i].TimeToEstabilish :=
                   TFunctions.DateTimeToUNIXTimeFAST(
                    Servers[Player.ChannelIndex].Devires[0].Slots[i].TimeToEstabilish);
                PacketReliqShow.DevirReliq.Slots[i].UnkByte1 := 2;
                PacketReliqShow.DevirReliq.Slots[i].UnkByte2 := 1;
                PacketReliqShow.DevirReliInfo.Slots[i].ItemID :=
                  Servers[Player.ChannelIndex].Devires[0].Slots[i].ItemId;
                PacketReliqShow.DevirReliInfo.Slots[i].IsActive := 1;
                PacketReliqShow.DevirReliInfo.Slots[i].TimeCapped :=
                TFunctions.DateTimeToUNIXTimeFAST(
                    Servers[Player.ChannelIndex].Devires[0].Slots[i].TimeCapped);
                System.AnsiStrings.StrPLCopy(PacketReliqShow.DevirReliInfo.Slots[i].NameCapped,
                String(Servers[Player.ChannelIndex].Devires[0].Slots[i].NameCapped), 16);

              end
              else
              begin
                PacketReliqShow.DevirReliInfo.Slots[i].IsActive :=
                  Servers[Player.ChannelIndex].Devires[0].Slots[i].IsAble.ToInteger;
              end;
            end;
            Player.SendPacket(PacketReliqShow, PacketReliqShow.Header.Size);
            Player.OpennedNPC := Packet.Index;
            Player.OpennedOption := 5;
            Player.OpennedDevir := 0;
            Player.OpennedTemple := Packet.Index;
            Servers[Player.ChannelIndex].Devires[0].PlayerIndexGettingReliq :=
              Player.Base.ClientID;
            Exit;
          end
          else
          begin
            Player.OpennedNPC := 0;
            Player.OpennedOption := 0;
            Exit;
          end;
        end;
      end;
    3336: // sig devir
      begin
        if not(Player.Base.PlayerCharacter.LastPos.InRange
          (Servers[Player.ChannelIndex].DevirNpc[3336].PlayerChar.LastPos, 10))
        then
        begin
          Player.SendClientMessage('Você está muito longe do templo.');
          Player.OpennedNPC := 0;
          Player.OpennedOption := 0;
          Exit;
        end;
        if (Integer(Player.Account.Header.Nation) = 0) then
        begin
          Player.SendClientMessage
            ('Você não pode abrir templos. Registre-se em uma nação primeiro!');
          Player.OpennedNPC := 0;
          Player.OpennedOption := 0;
          Exit;
        end;
        if (Servers[Player.ChannelIndex].Devires[1].NationID =
          Integer(Player.Account.Header.Nation)) then
        begin
          ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);
          if (ReliqSlot = 255) then
          begin
            Player.SendClientMessage
              ('Você não pode abrir o templo de sua própia nação.');
            Player.OpennedNPC := 0;
            Player.OpennedOption := 0;
            Exit;
          end
          else
          begin // [ENTREGAR RELIQUIA]
            {if(Servers[Player.ChannelIndex].Devires[1].PlayerIndexGettingReliq <> 0) then
            begin
              Player.SendClientMessage('O jogador <' +
                AnsiString(Servers[Player.ChannelIndex].Players[
                Servers[Player.ChannelIndex].Devires[1].PlayerIndexGettingReliq].
                Base.Character.Name) + '> está com o devir aberto agora.');
              Exit;
            end;}
            ZeroMemory(@PacketReliqShow, sizeof(PacketReliqShow));
            PacketReliqShow.Header.Size := sizeof(PacketReliqShow);
            PacketReliqShow.Header.Index := 0;
            PacketReliqShow.Header.Code := $B52;
            PacketReliqShow.DevirID := 01;
            PacketReliqShow.TypeOpen := 05;
            for I := 0 to 4 do
            begin
              if(Servers[Player.ChannelIndex].Devires[1].Slots[i].ItemId <> 0) then
              begin
                PacketReliqShow.DevirReliq.Slots[i].ItemID :=
                  Servers[Player.ChannelIndex].Devires[1].Slots[i].ItemId;
                PacketReliqShow.DevirReliq.Slots[i].APP :=
                  PacketReliqShow.DevirReliq.Slots[i].ItemID;
                PacketReliqShow.DevirReliq.Slots[i].Unknown := i;
                PacketReliqShow.DevirReliq.Slots[i].TimeToEstabilish :=
                   TFunctions.DateTimeToUNIXTimeFAST(
                    Servers[Player.ChannelIndex].Devires[1].Slots[i].TimeToEstabilish);
                PacketReliqShow.DevirReliq.Slots[i].UnkByte1 := 2;
                PacketReliqShow.DevirReliq.Slots[i].UnkByte2 := 1;
                PacketReliqShow.DevirReliInfo.Slots[i].ItemID :=
                  Servers[Player.ChannelIndex].Devires[1].Slots[i].ItemId;
                PacketReliqShow.DevirReliInfo.Slots[i].IsActive := 1;
                PacketReliqShow.DevirReliInfo.Slots[i].TimeCapped :=
                TFunctions.DateTimeToUNIXTimeFAST(
                    Servers[Player.ChannelIndex].Devires[1].Slots[i].TimeCapped);
                System.AnsiStrings.StrPLCopy(PacketReliqShow.DevirReliInfo.Slots[i].NameCapped,
                String(Servers[Player.ChannelIndex].Devires[1].Slots[i].NameCapped), 16);
              end
              else
              begin
                PacketReliqShow.DevirReliInfo.Slots[i].IsActive :=
                  Servers[Player.ChannelIndex].Devires[1].Slots[i].IsAble.ToInteger;
              end;
            end;
            Player.SendPacket(PacketReliqShow, PacketReliqShow.Header.Size);
            Player.OpennedNPC := Packet.Index;
            Player.OpennedOption := 5;
            Player.OpennedDevir := 1;
            Player.OpennedTemple := Packet.Index;
            Servers[Player.ChannelIndex].Devires[1].PlayerIndexGettingReliq :=
              Player.Base.ClientID;
            Exit;
          end;
        end
        else
        begin
          if(Servers[Player.ChannelIndex].Devires[1].IsOpen) then
          begin
            {if(Servers[Player.ChannelIndex].Devires[1].PlayerIndexGettingReliq <> 0) then
            begin
              Player.SendClientMessage('O jogador <' +
                AnsiString(Servers[Player.ChannelIndex].Players[
                Servers[Player.ChannelIndex].Devires[1].PlayerIndexGettingReliq].
                Base.Character.Name) + '> está com o devir aberto agora.');
              Exit;
            end; }

            ZeroMemory(@PacketReliqShow, sizeof(PacketReliqShow));
            PacketReliqShow.Header.Size := sizeof(PacketReliqShow);
            PacketReliqShow.Header.Index := 0;
            PacketReliqShow.Header.Code := $B52;
            PacketReliqShow.DevirID := 01;
            PacketReliqShow.TypeOpen := 05;
            for I := 0 to 4 do
            begin
              if(Servers[Player.ChannelIndex].Devires[1].Slots[i].ItemId <> 0) then
              begin
                PacketReliqShow.DevirReliq.Slots[i].ItemID :=
                  Servers[Player.ChannelIndex].Devires[1].Slots[i].ItemId;
                PacketReliqShow.DevirReliq.Slots[i].APP :=
                  PacketReliqShow.DevirReliq.Slots[i].ItemID;
                PacketReliqShow.DevirReliq.Slots[i].Unknown := i;
                PacketReliqShow.DevirReliq.Slots[i].TimeToEstabilish :=
                   TFunctions.DateTimeToUNIXTimeFAST(
                    Servers[Player.ChannelIndex].Devires[1].Slots[i].TimeToEstabilish);
                PacketReliqShow.DevirReliq.Slots[i].UnkByte1 := 2;
                PacketReliqShow.DevirReliq.Slots[i].UnkByte2 := 1;
                PacketReliqShow.DevirReliInfo.Slots[i].ItemID :=
                  Servers[Player.ChannelIndex].Devires[1].Slots[i].ItemId;
                PacketReliqShow.DevirReliInfo.Slots[i].IsActive := 1;
                PacketReliqShow.DevirReliInfo.Slots[i].TimeCapped :=
                TFunctions.DateTimeToUNIXTimeFAST(
                    Servers[Player.ChannelIndex].Devires[1].Slots[i].TimeCapped);
                System.AnsiStrings.StrPLCopy(PacketReliqShow.DevirReliInfo.Slots[i].NameCapped,
                String(Servers[Player.ChannelIndex].Devires[1].Slots[i].NameCapped), 16);
              end
              else
              begin
                PacketReliqShow.DevirReliInfo.Slots[i].IsActive :=
                  Servers[Player.ChannelIndex].Devires[1].Slots[i].IsAble.ToInteger;
              end;
            end;
            Player.SendPacket(PacketReliqShow, PacketReliqShow.Header.Size);
            Player.OpennedNPC := Packet.Index;
            Player.OpennedOption := 5;
            Player.OpennedDevir := 1;
            Player.OpennedTemple := Packet.Index;
            Servers[Player.ChannelIndex].Devires[1].PlayerIndexGettingReliq :=
              Player.Base.ClientID;
            Exit;
          end
          else
          begin
            Player.OpennedNPC := 0;
            Player.OpennedOption := 0;
            Exit;
          end;
        end;
      end;
    3337: // cahil devir
      begin
        if not(Player.Base.PlayerCharacter.LastPos.InRange
          (Servers[Player.ChannelIndex].DevirNpc[3337].PlayerChar.LastPos, 10))
        then
        begin
          Player.SendClientMessage('Você está muito longe do templo.');
          Player.OpennedNPC := 0;
          Player.OpennedOption := 0;
          Exit;
        end;
        if (Integer(Player.Account.Header.Nation) = 0) then
        begin
          Player.SendClientMessage
            ('Você não pode abrir templos. Registre-se em uma nação primeiro!');
          Player.OpennedNPC := 0;
          Player.OpennedOption := 0;
          Exit;
        end;
        if (Servers[Player.ChannelIndex].Devires[2].NationID =
          Integer(Player.Account.Header.Nation)) then
        begin
          ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);
          if (ReliqSlot = 255) then
          begin
            Player.SendClientMessage
              ('Você não pode abrir o templo de sua própia nação.');
            Player.OpennedNPC := 0;
            Player.OpennedOption := 0;
            Exit;
          end
          else
          begin // [ENTREGAR RELIQUIA]
            {if(Servers[Player.ChannelIndex].Devires[2].PlayerIndexGettingReliq <> 0) then
            begin
              Player.SendClientMessage('O jogador <' +
                AnsiString(Servers[Player.ChannelIndex].Players[
                Servers[Player.ChannelIndex].Devires[2].PlayerIndexGettingReliq].
                Base.Character.Name) + '> está com o devir aberto agora.');
              Exit;
            end;}
            ZeroMemory(@PacketReliqShow, sizeof(PacketReliqShow));
            PacketReliqShow.Header.Size := sizeof(PacketReliqShow);
            PacketReliqShow.Header.Index := 0;
            PacketReliqShow.Header.Code := $B52;
            PacketReliqShow.DevirID := 02;
            PacketReliqShow.TypeOpen := 05;
            for I := 0 to 4 do
            begin
              if(Servers[Player.ChannelIndex].Devires[2].Slots[i].ItemId <> 0) then
              begin
                PacketReliqShow.DevirReliq.Slots[i].ItemID :=
                  Servers[Player.ChannelIndex].Devires[2].Slots[i].ItemId;
                PacketReliqShow.DevirReliq.Slots[i].APP :=
                  PacketReliqShow.DevirReliq.Slots[i].ItemID;
                PacketReliqShow.DevirReliq.Slots[i].Unknown := i;
                PacketReliqShow.DevirReliq.Slots[i].TimeToEstabilish :=
                   TFunctions.DateTimeToUNIXTimeFAST(
                    Servers[Player.ChannelIndex].Devires[2].Slots[i].TimeToEstabilish);
                PacketReliqShow.DevirReliq.Slots[i].UnkByte1 := 2;
                PacketReliqShow.DevirReliq.Slots[i].UnkByte2 := 1;
                PacketReliqShow.DevirReliInfo.Slots[i].ItemID :=
                  Servers[Player.ChannelIndex].Devires[2].Slots[i].ItemId;
                PacketReliqShow.DevirReliInfo.Slots[i].IsActive := 1;
                PacketReliqShow.DevirReliInfo.Slots[i].TimeCapped :=
                TFunctions.DateTimeToUNIXTimeFAST(
                    Servers[Player.ChannelIndex].Devires[2].Slots[i].TimeCapped);
                System.AnsiStrings.StrPLCopy(PacketReliqShow.DevirReliInfo.Slots[i].NameCapped,
                String(Servers[Player.ChannelIndex].Devires[2].Slots[i].NameCapped), 16);
              end
              else
              begin
                PacketReliqShow.DevirReliInfo.Slots[i].IsActive :=
                  Servers[Player.ChannelIndex].Devires[2].Slots[i].IsAble.ToInteger;
              end;
            end;
            Player.SendPacket(PacketReliqShow, PacketReliqShow.Header.Size);
            Player.OpennedNPC := Packet.Index;
            Player.OpennedOption := 5;
            Player.OpennedDevir := 2;
            Player.OpennedTemple := Packet.Index;
            Servers[Player.ChannelIndex].Devires[2].PlayerIndexGettingReliq :=
              Player.Base.ClientID;
            Exit;
          end;
        end
        else
        begin
          if(Servers[Player.ChannelIndex].Devires[2].IsOpen) then
          begin
            {if(Servers[Player.ChannelIndex].Devires[2].PlayerIndexGettingReliq <> 0) then
            begin
              Player.SendClientMessage('O jogador <' +
                AnsiString(Servers[Player.ChannelIndex].Players[
                Servers[Player.ChannelIndex].Devires[2].PlayerIndexGettingReliq].
                Base.Character.Name) + '> está com o devir aberto agora.');
              Exit;
            end;}
            ZeroMemory(@PacketReliqShow, sizeof(PacketReliqShow));
            PacketReliqShow.Header.Size := sizeof(PacketReliqShow);
            PacketReliqShow.Header.Index := 0;
            PacketReliqShow.Header.Code := $B52;
            PacketReliqShow.DevirID := 02;
            PacketReliqShow.TypeOpen := 05;
            for I := 0 to 4 do
            begin
              if(Servers[Player.ChannelIndex].Devires[2].Slots[i].ItemId <> 0) then
              begin
                PacketReliqShow.DevirReliq.Slots[i].ItemID :=
                  Servers[Player.ChannelIndex].Devires[2].Slots[i].ItemId;
                PacketReliqShow.DevirReliq.Slots[i].APP :=
                  PacketReliqShow.DevirReliq.Slots[i].ItemID;
                PacketReliqShow.DevirReliq.Slots[i].Unknown := i;
                PacketReliqShow.DevirReliq.Slots[i].TimeToEstabilish :=
                   TFunctions.DateTimeToUNIXTimeFAST(
                    Servers[Player.ChannelIndex].Devires[2].Slots[i].TimeToEstabilish);
                PacketReliqShow.DevirReliq.Slots[i].UnkByte1 := 2;
                PacketReliqShow.DevirReliq.Slots[i].UnkByte2 := 1;
                PacketReliqShow.DevirReliInfo.Slots[i].ItemID :=
                  Servers[Player.ChannelIndex].Devires[2].Slots[i].ItemId;
                PacketReliqShow.DevirReliInfo.Slots[i].IsActive := 1;
                PacketReliqShow.DevirReliInfo.Slots[i].TimeCapped :=
                TFunctions.DateTimeToUNIXTimeFAST(
                    Servers[Player.ChannelIndex].Devires[2].Slots[i].TimeCapped);
                System.AnsiStrings.StrPLCopy(PacketReliqShow.DevirReliInfo.Slots[i].NameCapped,
                String(Servers[Player.ChannelIndex].Devires[2].Slots[i].NameCapped), 16);
              end
              else
              begin
                PacketReliqShow.DevirReliInfo.Slots[i].IsActive :=
                  Servers[Player.ChannelIndex].Devires[2].Slots[i].IsAble.ToInteger;
              end;
            end;
            Player.SendPacket(PacketReliqShow, PacketReliqShow.Header.Size);
            Player.OpennedNPC := Packet.Index;
            Player.OpennedOption := 5;
            Player.OpennedDevir := 2;
            Player.OpennedTemple := Packet.Index;
            Servers[Player.ChannelIndex].Devires[2].PlayerIndexGettingReliq :=
              Player.Base.ClientID;
            Exit;
          end
          else
          begin
            Player.OpennedNPC := 0;
            Player.OpennedOption := 0;
            Exit;
          end;
        end;
      end;
    3338: // mirza devir
      begin
        if not(Player.Base.PlayerCharacter.LastPos.InRange
          (Servers[Player.ChannelIndex].DevirNpc[3338].PlayerChar.LastPos, 10))
        then
        begin
          Player.SendClientMessage('Você está muito longe do templo.');
          Player.OpennedNPC := 0;
          Player.OpennedOption := 0;
          Exit;
        end;
        if (Integer(Player.Account.Header.Nation) = 0) then
        begin
          Player.SendClientMessage
            ('Você não pode abrir templos. Registre-se em uma nação primeiro!');
          Player.OpennedNPC := 0;
          Player.OpennedOption := 0;
          Exit;
        end;
        if (Servers[Player.ChannelIndex].Devires[3].NationID =
          Integer(Player.Account.Header.Nation)) then
        begin
          ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);
          if (ReliqSlot = 255) then
          begin
            Player.SendClientMessage
              ('Você não pode abrir o templo de sua própia nação.');
            Player.OpennedNPC := 0;
            Player.OpennedOption := 0;
            Exit;
          end
          else
          begin // [ENTREGAR RELIQUIA]
            {if(Servers[Player.ChannelIndex].Devires[3].PlayerIndexGettingReliq <> 0) then
            begin
              Player.SendClientMessage('O jogador <' +
                AnsiString(Servers[Player.ChannelIndex].Players[
                Servers[Player.ChannelIndex].Devires[3].PlayerIndexGettingReliq].
                Base.Character.Name) + '> está com o devir aberto agora.');
              Exit;
            end;}
            ZeroMemory(@PacketReliqShow, sizeof(PacketReliqShow));
            PacketReliqShow.Header.Size := sizeof(PacketReliqShow);
            PacketReliqShow.Header.Index := 0;
            PacketReliqShow.Header.Code := $B52;
            PacketReliqShow.DevirID := 03;
            PacketReliqShow.TypeOpen := 5;
            for I := 0 to 4 do
            begin
              if(Servers[Player.ChannelIndex].Devires[3].Slots[i].ItemId <> 0) then
              begin
                PacketReliqShow.DevirReliq.Slots[i].ItemID :=
                  Servers[Player.ChannelIndex].Devires[3].Slots[i].ItemId;
                PacketReliqShow.DevirReliq.Slots[i].APP :=
                  PacketReliqShow.DevirReliq.Slots[i].ItemID;
                PacketReliqShow.DevirReliq.Slots[i].Unknown := i;
                PacketReliqShow.DevirReliq.Slots[i].TimeToEstabilish :=
                   TFunctions.DateTimeToUNIXTimeFAST(
                    Servers[Player.ChannelIndex].Devires[3].Slots[i].TimeToEstabilish);
                PacketReliqShow.DevirReliq.Slots[i].UnkByte1 := 2;
                PacketReliqShow.DevirReliq.Slots[i].UnkByte2 := 1;
                PacketReliqShow.DevirReliInfo.Slots[i].ItemID :=
                  Servers[Player.ChannelIndex].Devires[3].Slots[i].ItemId;
                PacketReliqShow.DevirReliInfo.Slots[i].IsActive := 1;
                PacketReliqShow.DevirReliInfo.Slots[i].TimeCapped :=
                TFunctions.DateTimeToUNIXTimeFAST(
                    Servers[Player.ChannelIndex].Devires[3].Slots[i].TimeCapped);
                System.AnsiStrings.StrPLCopy(PacketReliqShow.DevirReliInfo.Slots[i].NameCapped,
                String(Servers[Player.ChannelIndex].Devires[3].Slots[i].NameCapped), 16);
              end
              else
              begin
                PacketReliqShow.DevirReliInfo.Slots[i].IsActive :=
                  Servers[Player.ChannelIndex].Devires[3].Slots[i].IsAble.ToInteger;
              end;
            end;
            Player.SendPacket(PacketReliqShow, PacketReliqShow.Header.Size);
            Player.OpennedNPC := Packet.Index;
            Player.OpennedOption := 5;
            Player.OpennedDevir := 3;
            Player.OpennedTemple := Packet.Index;
            Servers[Player.ChannelIndex].Devires[3].PlayerIndexGettingReliq :=
              Player.Base.ClientID;
            Exit;
          end;
        end
        else
        begin
          if(Servers[Player.ChannelIndex].Devires[3].IsOpen) then
          begin
            {if(Servers[Player.ChannelIndex].Devires[3].PlayerIndexGettingReliq <> 0) then
            begin
              Player.SendClientMessage('O jogador <' +
                AnsiString(Servers[Player.ChannelIndex].Players[
                Servers[Player.ChannelIndex].Devires[3].PlayerIndexGettingReliq].
                Base.Character.Name) + '> está com o devir aberto agora.');
              Exit;
            end;}
            ZeroMemory(@PacketReliqShow, sizeof(PacketReliqShow));
            PacketReliqShow.Header.Size := sizeof(PacketReliqShow);
            PacketReliqShow.Header.Index := 0;
            PacketReliqShow.Header.Code := $B52;
            PacketReliqShow.DevirID := 03;
            PacketReliqShow.TypeOpen := 05;
            for I := 0 to 4 do
            begin
              if(Servers[Player.ChannelIndex].Devires[3].Slots[i].ItemId <> 0) then
              begin
                PacketReliqShow.DevirReliq.Slots[i].ItemID :=
                  Servers[Player.ChannelIndex].Devires[3].Slots[i].ItemId;
                PacketReliqShow.DevirReliq.Slots[i].APP :=
                  PacketReliqShow.DevirReliq.Slots[i].ItemID;
                PacketReliqShow.DevirReliq.Slots[i].Unknown := i;
                PacketReliqShow.DevirReliq.Slots[i].TimeToEstabilish :=
                   TFunctions.DateTimeToUNIXTimeFAST(
                    Servers[Player.ChannelIndex].Devires[3].Slots[i].TimeToEstabilish);
                PacketReliqShow.DevirReliq.Slots[i].UnkByte1 := 2;
                PacketReliqShow.DevirReliq.Slots[i].UnkByte2 := 1;
                PacketReliqShow.DevirReliInfo.Slots[i].ItemID :=
                  Servers[Player.ChannelIndex].Devires[3].Slots[i].ItemId;
                PacketReliqShow.DevirReliInfo.Slots[i].IsActive := 1;
                PacketReliqShow.DevirReliInfo.Slots[i].TimeCapped :=
                TFunctions.DateTimeToUNIXTimeFAST(
                    Servers[Player.ChannelIndex].Devires[3].Slots[i].TimeCapped);
                System.AnsiStrings.StrPLCopy(PacketReliqShow.DevirReliInfo.Slots[i].NameCapped,
                String(Servers[Player.ChannelIndex].Devires[3].Slots[i].NameCapped), 16);
              end
              else
              begin
                PacketReliqShow.DevirReliInfo.Slots[i].IsActive :=
                  Servers[Player.ChannelIndex].Devires[3].Slots[i].IsAble.ToInteger;
              end;
            end;
            Player.SendPacket(PacketReliqShow, PacketReliqShow.Header.Size);
            Player.OpennedNPC := Packet.Index;
            Player.OpennedOption := 5;
            Player.OpennedDevir := 3;
            Player.OpennedTemple := Packet.Index;
            Servers[Player.ChannelIndex].Devires[3].PlayerIndexGettingReliq :=
              Player.Base.ClientID;
            Exit;
          end
          else
          begin
            Player.OpennedNPC := 0;
            Player.OpennedOption := 0;
            Exit;
          end;
        end;
      end;
    3339: // zelant devir
      begin
        if not(Player.Base.PlayerCharacter.LastPos.InRange
          (Servers[Player.ChannelIndex].DevirNpc[3339].PlayerChar.LastPos, 10))
        then
        begin
          Player.SendClientMessage('Você está muito longe do templo.');
          Player.OpennedNPC := 0;
          Player.OpennedOption := 0;
          Exit;
        end;
        if (Integer(Player.Account.Header.Nation) = 0) then
        begin
          Player.SendClientMessage
            ('Você não pode abrir templos. Registre-se em uma nação primeiro!');
          Player.OpennedNPC := 0;
          Player.OpennedOption := 0;
          Exit;
        end;
        if (Servers[Player.ChannelIndex].Devires[4].NationID =
          Integer(Player.Account.Header.Nation)) then
        begin
          ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);
          if (ReliqSlot = 255) then
          begin
            Player.SendClientMessage
              ('Você não pode abrir o templo de sua própia nação.');
            Player.OpennedNPC := 0;
            Player.OpennedOption := 0;
            Exit;
          end
          else
          begin // [ENTREGAR RELIQUIA]
            {if(Servers[Player.ChannelIndex].Devires[4].PlayerIndexGettingReliq <> 0) then
            begin
              Player.SendClientMessage('O jogador <' +
                AnsiString(Servers[Player.ChannelIndex].Players[
                Servers[Player.ChannelIndex].Devires[4].PlayerIndexGettingReliq].
                Base.Character.Name) + '> está com o devir aberto agora.');
              Exit;
            end;}
            ZeroMemory(@PacketReliqShow, sizeof(PacketReliqShow));
            PacketReliqShow.Header.Size := sizeof(PacketReliqShow);
            PacketReliqShow.Header.Index := 0;
            PacketReliqShow.Header.Code := $B52;
            PacketReliqShow.DevirID := 04;
            PacketReliqShow.TypeOpen := 5;
            for I := 0 to 4 do
            begin
              if(Servers[Player.ChannelIndex].Devires[4].Slots[i].ItemId <> 0) then
              begin
                PacketReliqShow.DevirReliq.Slots[i].ItemID :=
                  Servers[Player.ChannelIndex].Devires[4].Slots[i].ItemId;
                PacketReliqShow.DevirReliq.Slots[i].APP :=
                  PacketReliqShow.DevirReliq.Slots[i].ItemID;
                PacketReliqShow.DevirReliq.Slots[i].Unknown := i;
                PacketReliqShow.DevirReliq.Slots[i].TimeToEstabilish :=
                   TFunctions.DateTimeToUNIXTimeFAST(
                    Servers[Player.ChannelIndex].Devires[4].Slots[i].TimeToEstabilish);
                PacketReliqShow.DevirReliq.Slots[i].UnkByte1 := 2;
                PacketReliqShow.DevirReliq.Slots[i].UnkByte2 := 1;
                PacketReliqShow.DevirReliInfo.Slots[i].ItemID :=
                  Servers[Player.ChannelIndex].Devires[4].Slots[i].ItemId;
                PacketReliqShow.DevirReliInfo.Slots[i].IsActive := 1;
                PacketReliqShow.DevirReliInfo.Slots[i].TimeCapped :=
                TFunctions.DateTimeToUNIXTimeFAST(
                    Servers[Player.ChannelIndex].Devires[4].Slots[i].TimeCapped);
                System.AnsiStrings.StrPLCopy(PacketReliqShow.DevirReliInfo.Slots[i].NameCapped,
                String(Servers[Player.ChannelIndex].Devires[4].Slots[i].NameCapped), 16);
              end
              else
              begin
                PacketReliqShow.DevirReliInfo.Slots[i].IsActive :=
                  Servers[Player.ChannelIndex].Devires[4].Slots[i].IsAble.ToInteger;
              end;
            end;
            Player.SendPacket(PacketReliqShow, PacketReliqShow.Header.Size);
            Player.OpennedNPC := Packet.Index;
            Player.OpennedOption := 5;
            Player.OpennedDevir := 4;
            Player.OpennedTemple := Packet.Index;
            Servers[Player.ChannelIndex].Devires[4].PlayerIndexGettingReliq :=
              Player.Base.ClientID;
            Exit;
          end;
        end
        else
        begin
          if(Servers[Player.ChannelIndex].Devires[4].IsOpen) then
          begin
            {if(Servers[Player.ChannelIndex].Devires[4].PlayerIndexGettingReliq <> 0) then
            begin
              Player.SendClientMessage('O jogador <' +
                AnsiString(Servers[Player.ChannelIndex].Players[
                Servers[Player.ChannelIndex].Devires[4].PlayerIndexGettingReliq].
                Base.Character.Name) + '> está com o devir aberto agora.');
              Exit;
            end;}
            ZeroMemory(@PacketReliqShow, sizeof(PacketReliqShow));
            PacketReliqShow.Header.Size := sizeof(PacketReliqShow);
            PacketReliqShow.Header.Index := 0;
            PacketReliqShow.Header.Code := $B52;
            PacketReliqShow.DevirID := 04;
            PacketReliqShow.TypeOpen := 05;
            for I := 0 to 4 do
            begin
              if(Servers[Player.ChannelIndex].Devires[4].Slots[i].ItemId <> 0) then
              begin
                PacketReliqShow.DevirReliq.Slots[i].ItemID :=
                  Servers[Player.ChannelIndex].Devires[4].Slots[i].ItemId;
                PacketReliqShow.DevirReliq.Slots[i].APP :=
                  PacketReliqShow.DevirReliq.Slots[i].ItemID;
                PacketReliqShow.DevirReliq.Slots[i].Unknown := i;
                PacketReliqShow.DevirReliq.Slots[i].TimeToEstabilish :=
                   TFunctions.DateTimeToUNIXTimeFAST(
                    Servers[Player.ChannelIndex].Devires[4].Slots[i].TimeToEstabilish);
                PacketReliqShow.DevirReliq.Slots[i].UnkByte1 := 2;
                PacketReliqShow.DevirReliq.Slots[i].UnkByte2 := 1;
                PacketReliqShow.DevirReliInfo.Slots[i].ItemID :=
                  Servers[Player.ChannelIndex].Devires[4].Slots[i].ItemId;
                PacketReliqShow.DevirReliInfo.Slots[i].IsActive := 1;
                PacketReliqShow.DevirReliInfo.Slots[i].TimeCapped :=
                TFunctions.DateTimeToUNIXTimeFAST(
                    Servers[Player.ChannelIndex].Devires[4].Slots[i].TimeCapped);
                System.AnsiStrings.StrPLCopy(PacketReliqShow.DevirReliInfo.Slots[i].NameCapped,
                String(Servers[Player.ChannelIndex].Devires[4].Slots[i].NameCapped), 16);
              end
              else
              begin
                PacketReliqShow.DevirReliInfo.Slots[i].IsActive :=
                  Servers[Player.ChannelIndex].Devires[4].Slots[i].IsAble.ToInteger;
              end;
            end;
            Player.SendPacket(PacketReliqShow, PacketReliqShow.Header.Size);
            Player.OpennedNPC := Packet.Index;
            Player.OpennedOption := 5;
            Player.OpennedDevir := 4;
            Player.OpennedTemple := Packet.Index;
            Servers[Player.ChannelIndex].Devires[4].PlayerIndexGettingReliq :=
              Player.Base.ClientID;
            Exit;
          end
          else
          begin
            Player.OpennedNPC := 0;
            Player.OpennedOption := 0;
            Exit;
          end;
        end;
      end;
  end;

  if (Packet.Index >= 3370) and (Packet.Index <= 3390) then
  begin
    if not(Player.Base.PlayerCharacter.LastPos.InRange
      (Servers[Player.ChannelIndex].CastleObjects[Packet.Index].PlayerChar.LastPos, 3))
    then
    begin
      Player.SendClientMessage('Você está muito longe da orbe.');
      Player.OpennedNPC := 0;
      Player.OpennedOption := 0;
      Exit;
    end;

    if (Integer(Player.Account.Header.Nation) = 0) then
    begin
      Player.SendClientMessage
        ('Você não pode abrir templos. Registre-se em uma nação primeiro!');
      Player.OpennedNPC := 0;
      Player.OpennedOption := 0;
      Exit;
    end;

    case Packet.Index of

    3370: //orbe da agua 3551 2759
      begin
        Servers[Player.ChannelIndex].CastleSiegeHandler.OrbHolder[0] :=
          @Servers[Player.ChannelIndex].Players[Player.Base.ClientId];
        //Inc(Servers[Player.ChannelIndex].CastleSiegeHandler.OrbsHolded);
        Servers[Player.ChannelIndex].CastleSiegeHandler.SendHoldingOrbPacket(Player, Packet.Index);
      end;
    3371:  //orbe do vento 3616 2759
      begin
        Servers[Player.ChannelIndex].CastleSiegeHandler.OrbHolder[1] :=
          @Servers[Player.ChannelIndex].Players[Player.Base.ClientId];
        //Inc(Servers[Player.ChannelIndex].CastleSiegeHandler.OrbsHolded);
        Servers[Player.ChannelIndex].CastleSiegeHandler.SendHoldingOrbPacket(Player, Packet.Index);
      end;
    3372: //orbe do fogo 3584 2860
      begin
        Servers[Player.ChannelIndex].CastleSiegeHandler.OrbHolder[2] :=
          @Servers[Player.ChannelIndex].Players[Player.Base.ClientId];
        //Inc(Servers[Player.ChannelIndex].CastleSiegeHandler.OrbsHolded);
        Servers[Player.ChannelIndex].CastleSiegeHandler.SendHoldingOrbPacket(Player, Packet.Index);
      end;

    3373: //bandeira do marechal 3584 2805
      begin
        if (Servers[Player.ChannelIndex].CastleSiegeHandler.OrbsHolded < 3) then
        begin
          Player.SendClientMessage('As orbes precisam ser ocupadas antes de iniciar o selo');
          Exit;
        end;

        if(Player.Character.GuildSlot > 0) then
        begin
          if(Guilds[Player.Character.GuildSlot].Index <>
            Guilds[Player.Character.GuildSlot].Ally.Leader) then
          begin
            Player.SendClientMessage('Somente lider da aliança pode pegar a bandeira.');
            Exit;
          end;

          if(Guilds[Player.Character.GuildSlot].GuildLeaderCharIndex <>
            Player.Base.Character.CharIndex) then
          begin
            Player.SendClientMessage('Somente lider da aliança pode pegar a bandeira.');
            Exit;
          end;

          Servers[Player.ChannelIndex].CastleSiegeHandler.SealHolder :=
            @Servers[Player.ChannelIndex].Players[Player.Base.ClientId];
          Servers[Player.ChannelIndex].CastleSiegeHandler.SealHoldingStart := Now;
          Servers[Player.ChannelIndex].CastleSiegeHandler.SealBeingHold := True;
          Servers[Player.ChannelIndex].CastleSiegeHandler.SendHoldingSeal(Player);
        end;
      end;
    end;

    Player.OpennedNPC := Packet.Index;
    Exit;
  end;

  case Packet.Type1 of
    $0:
      if (Player.OpennedNPC = 0) then
        Result := TNPCHandlers.ShowOptions(Player,
          Servers[Player.ChannelIndex].NPCs[Packet.Index])
      else
      begin
        Player.SendSignal(Player.Base.ClientId, $10F);
        Player.OpennedNPC := 0;
      end;
    $1:
      begin
        Player.OpennedNPC := Packet.Index;
        Player.OpennedOption := Packet.Type1;
        Result := TNPCHandlers.SendTalk(Player, Packet.Index);
        Exit;
      end;
    $2:
      begin
        Player.OpennedNPC := Packet.Index;
        Player.OpennedOption := Packet.Type1;
        Result := TNPCHandlers.SendQuests(Player, Packet.Index, Packet.Type2);
        Exit;
      end;
    $4: // entrar no castelo
      begin
        Result := TNPCHandlers.EnterInCastle(Player, Packet.Index);
        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;
        Exit;
      end;
    $5:
      Result := TNPCHandlers.ShowShop(Player, Servers[Player.ChannelIndex].NPCs
        [Packet.Index]);
    $6:
      Result := TNPCHandlers.ShowSkills(Player,
        Servers[Player.ChannelIndex].NPCs[Packet.Index]);
    $7:
      Player.SendStorage(STORAGE_TYPE_PLAYER);
    $8:
      begin
        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;
        Exit;
      end;
    12: // cadastrar no castelo
      begin
        Result := TNPCHandlers.SignInCastle(Player, Packet.Index);
        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;
        Exit;
      end;
    $A:
      begin
        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;
        Player.SendData(Player.Base.ClientId, $341, 0);
        Exit;
      end;
    $B:
      begin
        if Player.Character.Base.GuildIndex <= 0 then
        begin
          Player.OpennedNPC := 0;
          Player.OpennedOption := 0;
          Exit;
        end;
        if (Guilds[Player.Character.GuildSlot].OpenChest(Player.Character.Index,
          Player.ChannelIndex) = False) then
        begin
          Player.OpennedNPC := 0;
          Player.OpennedOption := 0;
          Exit;
        end;
      end;
    $D:
      Player.SendStorage(STORAGE_TYPE_PRANS);
    $F:
      Result := TNPCHandlers.ShowBigorna(Player);
    $1F:
      Result := TNPCHandlers.ShowRepareItens(Player);
    $11:
      Result := TNPCHandlers.ShowEnchant(Player);
    $12:
      Result := TNPCHandlers.ShowChangeApp(Player);
    $13:
      Result := TNPCHandlers.ShowNivelament(Player);
    $14:
      begin
        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;
        Result := TNPCHandlers.ShowChangeNation(Player);
        Exit;
      end;
    $15: //reenviar pro menu
      begin
        Player.OpennedNPC := Packet.Index;
        Player.OpennedOption := Packet.Type1;
        Result := TNPCHandlers.ShowOptions(Player,
          Servers[Player.ChannelIndex].NPCs[Packet.Index]);
        Exit;
      end;

    $16:
      begin
        TNPCHandlers.GetQuest(Player, Packet.Type2, Packet.Index);
        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;
        Exit;
      end;
    $18:
      begin
        TNPCHandlers.FinishQuest(Player, Packet.Type2);
        Servers[player.ChannelIndex].NPCS[Player.OpennedNPC].Base.SendCreateMob(
          SPAWN_NORMAL, Player.Base.ClientID, False);
        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;
        Exit;
      end;
    $19:
      begin
        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;
        TNPCHandlers.SaveLocation(Player, Packet.Index);
        Exit;
      end;
    $1A:
      Result := TNPCHandlers.ShowDungeonDialog(Player);
    $20:
      Result := TNPCHandlers.ShowRepareAllItens(Player);
    $21:
      Result := TNPCHandlers.ShowDesmontItem(Player);
    $10:
      Result := TNPCHandlers.ShowReinforce(Player);
    $23:
      begin
        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;
        TNPCHandlers.LilolaBuff(Player, Packet.Index);
        Exit;
      end;
    $30:
      Result := TNPCHandlers.ShowActionHouse(Player);
    $2C:
      Result := TNPCHandlers.ShowMountEnchant(Player);
    $3E:
      Result := TNPCHandlers.ShowPranEnchant(Player);
    $41:
      begin
        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;
        Player.SendClientMessage('A benção por gold está indisponível.');
        Exit;

        if(Player.Base.Character.Gold < 50000) then
        begin
          Player.SendClientMessage('Você não possuí gold suficiente.');
          Exit;
        end;

        Player.DecGold(50000);

        Player.Base.AddBuff(6498, True);
        Player.Base.AddBuff(6499, True);
        Player.Base.AddBuff(201, True, False, 3000);
        Player.Base.AddBuff(263, True, False, 3000);
        Player.Base.AddBuff(340, True, False, 3000);
        Player.Base.AddBuff(5155, True, False, 3000);
        //Player.Base.AddBuff(5185, True, False, 3000);

        Exit;
      end;
    67: //ursula
      begin //3087 3621
        Player.Teleport(TPosition.Create(3087, 3621));
        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;
        Exit;
      end;

    68: //basilan
      begin //1635 2218
        if(Player.Base.Character.Gold >= 2500) then
        begin
          Player.DecGold(2500);
          Player.Teleport(TPosition.Create(1635, 2218));
        end;
        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;
        Exit;
      end;
    69: //regenchain
      begin //3399, 564
        Player.Teleport(TPosition.Create(3399, 564));
        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;
        Exit;
      end;

    70:
      begin //Desfazer aliança
        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;

        if(Player.Character.GuildSlot = 0) then
        begin
          Player.SendClientMessage('Você não está em uma guilda.');
          Exit;
        end;

        if(Guilds[Player.Character.GuildSlot].GuildLeaderCharIndex <>
          Player.Base.Character.CharIndex) then
        begin
          Player.SendClientMessage('Você não é o lider da sua guilda.');
          Exit;
        end;

        if(Guilds[Player.Character.GuildSlot].GetAllyGuildCount <= 1) then
        begin
          Player.SendClientMessage('A aliança atual não pode ser desfeita.');
          Exit;
        end;

        if(Guilds[Player.Character.GuildSlot].Index <>
          Guilds[Player.Character.GuildSlot].Ally.Leader) then
        begin
          Player.SendClientMessage('Somente o lider da aliança pode desfazê-la.');
          Exit;
        end;

        TNPCHandlers.DestroyAlliance(Player);
        Exit;
      end;
    71: //'Remover aliado 01
      begin
        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;

        if(Player.Character.GuildSlot = 0) then
        begin
          Player.SendClientMessage('Você não está em uma guilda.');
          Exit;
        end;

        if(Guilds[Player.Character.GuildSlot].GuildLeaderCharIndex <>
          Player.Base.Character.CharIndex) then
        begin
          Player.SendClientMessage('Você não é o lider da sua guilda.');
          Exit;
        end;

        if(Guilds[Player.Character.GuildSlot].GetAllyGuildCount <= 1) then
        begin
          Player.SendClientMessage('O aliado selecionado não pode ser removido.');
          Exit;
        end;

        if(Guilds[Player.Character.GuildSlot].Ally.Guilds[1].Index = 0) then
        begin
          Player.SendClientMessage('O aliado 01 não existe para ser removido.');
          Exit;
        end;

        if(Guilds[Player.Character.GuildSlot].Index <>
          Guilds[Player.Character.GuildSlot].Ally.Leader) then
        begin
          Player.SendClientMessage('Somente o lider da aliança pode retirar um aliado.');
          Exit;
        end;

        TNPCHandlers.RemoveMemberAlliance(Player, 1);
        Exit;
      end;
    72: //Remover aliado 02
      begin
        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;

        if(Player.Character.GuildSlot = 0) then
        begin
          Player.SendClientMessage('Você não está em uma guilda.');
          Exit;
        end;

        if(Guilds[Player.Character.GuildSlot].GuildLeaderCharIndex <>
          Player.Base.Character.CharIndex) then
        begin
          Player.SendClientMessage('Você não é o lider da sua guilda.');
          Exit;
        end;

        if(Guilds[Player.Character.GuildSlot].GetAllyGuildCount <= 1) then
        begin
          Player.SendClientMessage('O aliado selecionado não pode ser removido.');
          Exit;
        end;

        if(Guilds[Player.Character.GuildSlot].Ally.Guilds[2].Index = 0) then
        begin
          Player.SendClientMessage('O aliado 02 não existe para ser removido.');
          Exit;
        end;

        if(Guilds[Player.Character.GuildSlot].Index <>
          Guilds[Player.Character.GuildSlot].Ally.Leader) then
        begin
          Player.SendClientMessage('Somente o lider da aliança pode retirar um aliado.');
          Exit;
        end;

        TNPCHandlers.RemoveMemberAlliance(Player, 2);
        Exit;
      end;
    73: //Remover aliado 03
      begin
        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;

        if(Player.Character.GuildSlot = 0) then
        begin
          Player.SendClientMessage('Você não está em uma guilda.');
          Exit;
        end;

        if(Guilds[Player.Character.GuildSlot].GuildLeaderCharIndex <>
          Player.Base.Character.CharIndex) then
        begin
          Player.SendClientMessage('Você não é o lider da sua guilda.');
          Exit;
        end;

        if(Guilds[Player.Character.GuildSlot].GetAllyGuildCount <= 1) then
        begin
          Player.SendClientMessage('O aliado selecionado não pode ser removido.');
          Exit;
        end;

        if(Guilds[Player.Character.GuildSlot].Ally.Guilds[3].Index = 0) then
        begin
          Player.SendClientMessage('O aliado 03 não existe para ser removido.');
          Exit;
        end;

        if(Guilds[Player.Character.GuildSlot].Index <>
          Guilds[Player.Character.GuildSlot].Ally.Leader) then
        begin
          Player.SendClientMessage('Somente o lider da aliança pode retirar um aliado.');
          Exit;
        end;

        TNPCHandlers.RemoveMemberAlliance(Player, 3);
        Exit;
      end;
    74: //Sair da aliança
      begin
        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;

        if(Player.Character.GuildSlot = 0) then
        begin
          Player.SendClientMessage('Você não está em uma guilda.');
          Exit;
        end;

        if(Guilds[Player.Character.GuildSlot].GuildLeaderCharIndex <>
          Player.Base.Character.CharIndex) then
        begin
          Player.SendClientMessage('Você não é o lider da sua guilda.');
          Exit;
        end;

        if(Guilds[Player.Character.GuildSlot].GetAllyGuildCount <= 1) then
        begin
          Player.SendClientMessage('Você não pode sair da sua aliança');
          Exit;
        end;

        TNPCHandlers.ExitAlliance(Player);
        Exit;
      end;
    75: //voltar para regenchain
      begin
        if(Player.Base.InClastleVerus) then
        begin
          Player.Teleport(Tposition.Create(3399, 564));
        end;

        Player.Base.InClastleVerus := False;

        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;
        Exit;
      end;
    76: //[Defesa] Torre 01
      begin //3584 2848
        Player.SendSignal(Player.Base.ClientId, $10F);

        if(Player.Character.GuildSlot > 0) then
        begin
          if(Guilds[Player.Character.GuildSlot].Index in
            [Nations[Player.Base.Character.Nation-1].MarechalGuildID,
            Nations[Player.Base.Character.Nation-1].TacticianGuildID,
            Nations[Player.Base.Character.Nation-1].JudgeGuildID,
            Nations[Player.Base.Character.Nation-1].treasurerGuildID]) then
          begin
            if(Player.Base.InClastleVerus) then
            begin
              Player.Teleport(Tposition.Create(3584, 2848));
            end;
          end;
        end;

        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;
        Exit;
      end;
    77: //[Defesa] Torre 02
      begin //3558 2769
        Player.SendSignal(Player.Base.ClientId, $10F);

        if(Player.Character.GuildSlot > 0) then
        begin
          if(Guilds[Player.Character.GuildSlot].Index in
            [Nations[Player.Base.Character.Nation-1].MarechalGuildID,
            Nations[Player.Base.Character.Nation-1].TacticianGuildID,
            Nations[Player.Base.Character.Nation-1].JudgeGuildID,
            Nations[Player.Base.Character.Nation-1].treasurerGuildID]) then
          begin
            if(Player.Base.InClastleVerus) then
            begin
              Player.Teleport(Tposition.Create(3558, 2769));
            end;
          end;
        end;

        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;
        Exit;
      end;
    78: //[Defesa] Torre 03
      begin //3608 2771
        Player.SendSignal(Player.Base.ClientId, $10F);

        if(Player.Character.GuildSlot > 0) then
        begin
          if(Guilds[Player.Character.GuildSlot].Index in
            [Nations[Player.Base.Character.Nation-1].MarechalGuildID,
            Nations[Player.Base.Character.Nation-1].TacticianGuildID,
            Nations[Player.Base.Character.Nation-1].JudgeGuildID,
            Nations[Player.Base.Character.Nation-1].treasurerGuildID]) then
          begin
            if(Player.Base.InClastleVerus) then
            begin
              Player.Teleport(Tposition.Create(3608, 2771));
            end;
          end;
        end;

        Player.OpennedNPC := 0;
        Player.OpennedOption := 0;
        Exit;
      end;
  else
    begin
      Player.SendSignal(Player.Base.ClientId, $10F);
      Player.OpennedNPC := 0;
      Player.OpennedOption := 0;
      Exit;
    end;
  end;
  Player.OpennedNPC := Packet.Index;
  Player.OpennedOption := Packet.Type1;
end;
class function TPacketHandlers.CloseNPCOption(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TSignalData absolute Buffer;
begin
  Result := False;
  if (Packet.Data = 0) then
    Exit;
  if not(Player.OpennedNPC >= 2048) then
    Exit;
  Player.OpennedNPC := 0;
  Player.OpennedOption := 0;
  case Player.OpennedDevir of
    0..4:
    begin
      Servers[Player.ChannelIndex].Devires[Player.OpennedDevir].PlayerIndexGettingReliq := 0;
      Player.OpennedDevir := 255;
      Player.OpennedTemple := 255;
    end;
  end;

  if (Packet.Data >= 3370) and (Packet.Data <= 3372) then
  begin
    if not(Player.OpennedNPC = Packet.Data) then
      Exit;

    Servers[Player.ChannelIndex].CastleSiegeHandler.
      OrbHolder[3370-Packet.Data] := nil;
  end;
  Result := true;
end;
class function TPacketHandlers.BuyNPCItens(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TBuyNPCItemPacket absolute Buffer;
  BuyItem: TItem;
  ReliqIndex: WORD;
  EmptySlot, AuxSlot: Byte;
  PriceItem: TItemPrice;
  AlreadyReliq: Byte;
  i: Integer;
  TimeEst: TDateTime;
  AuxSlotItem: DWORD;
begin
  Result := False;
  if (Player.OpennedNPC <> Packet.Index) then
  begin
    Exit;
  end;
  if((Packet.Index >= 3335) and (Packet.Index <= 3339)) then
  begin
    Exit;
  end;
  BuyItem := Servers[Player.ChannelIndex].NPCs[Packet.Index].Character.Inventory
    [Packet.Slot];
  if (BuyItem.Index = 0) then
  begin
    Exit;
  end;
  if (Packet.Quantidade = 0) then
  begin
    Exit;
  end;
  if(TItemFunctions.GetInvAvailableSlots(Player) = 0) then
  begin
    Player.SendClientMessage('Inventário cheio.');
    Exit;
  end;
  if (TItemFunctions.GetBuyItemPrice(BuyItem, PriceItem, Packet.Quantidade))
  then
  begin
    if(BuyItem.Index = 4204) then
    begin
      PriceItem.PriceType := PRICE_MEDAL;
    end;

    if ((Player.OpennedNPC = 2296) and not(Player.IsAuxilyUser)) then
    begin
      Player.SendClientMessage('Não é usuário do Aika Tem. Compre o auxílio na loja premium com iNiz Coins.');
      Exit;
    end;

    case PriceItem.PriceType of
      PRICE_HONOR:
        begin
          if not(Player.Character.Base.CurrentScore.Honor >= PriceItem.Value1)
          then
          begin
            Exit;
          end;
          DecCardinal(Player.Character.Base.CurrentScore.Honor,
            PriceItem.Value1);
          BuyItem.APP := BuyItem.Index;
          BuyItem.Refi := Packet.Quantidade;
          // BuyItem.MIN := ItemList[BuyItem.Index].Durabilidade;
          // BuyItem.MAX := BuyItem.MIN;
          if (TItemFunctions.GetItemEquipSlot(BuyItem.Index) = 0) then
            TItemFunctions.PutItem(Player, BuyItem)
          else
            TItemFunctions.PutEquipament(Player, BuyItem.Index);
        end;
      PRICE_MEDAL:
        begin
          if not(Player.Character.Base.CurrentScore.Honor >= PriceItem.Value1)
          then
          begin
            Exit;
          end;
          if(PriceItem.Value2 > 0) then
          begin
            AuxSlot := TItemFunctions.GetItemSlot2(Player, 4204);
            if(AuxSlot = 255) then
              Exit;
            if(Player.Base.Character.Inventory[AuxSlot].Refi < PriceItem.Value2) then
              Exit;
            TItemFunctions.DecreaseAmount(@Player.Base.Character.Inventory[AuxSlot],
              PriceItem.Value2);
            Player.Base.SendRefreshItemSlot(AuxSlot, False);
          end;
          DecCardinal(Player.Character.Base.CurrentScore.Honor,
            PriceItem.Value1);
          Player.Base.SendRefreshKills;
          BuyItem.APP := BuyItem.Index;
          if (TItemFunctions.GetItemEquipSlot(BuyItem.Index) = 0) then
          begin
            BuyItem.Refi := Packet.Quantidade;
            TItemFunctions.PutItem(Player, BuyItem);
          end
          else
          begin
            BuyItem.Refi := 1;
            TItemFunctions.PutEquipament(Player, BuyItem.Index);
          end;
        end;
      PRICE_GOLD:
        begin
          if(PriceItem.Value1 <= 1) then
            Exit;
          if (PriceItem.Value1 > Player.Character.Base.Gold) then
            Exit;
          Player.DecGold(PriceItem.Value1);
          BuyItem.Refi := Packet.Quantidade;
          BuyItem.APP := BuyItem.Index;
          // BuyItem.MIN := ItemList[BuyItem.Index].Durabilidade;
          // BuyItem.MAX := BuyItem.MIN;
          AuxSlotItem := TItemFunctions.GetItemEquipSlot(BuyItem.Index);
          if ((AuxSlotItem = 0) or (AuxSlotItem = 15)) then
            TItemFunctions.PutItem(Player, BuyItem)
          else
            TItemFunctions.PutEquipament(Player, BuyItem.Index);
          Player.RefreshMoney;
        end;
      PRICE_ITEM:
        begin
          AuxSlot := TItemFunctions.GetItemSlot2(Player, PriceItem.Value1);

          if(AuxSlot = 255) then
            Exit;

          if(Player.Base.Character.Inventory[AuxSlot].Refi <
            PriceItem.Value2) then
          begin
            Player.SendClientMessage('Você não possui a quantidade de itens necessária.');
            Exit;
          end;

          TItemFunctions.DecreaseAmount(Player, AuxSlot, PriceItem.Value2);
          Player.Base.SendRefreshItemSlot(AuxSlot, False);

          BuyItem.Refi := Packet.Quantidade;
          BuyItem.APP := BuyItem.Index;
          AuxSlotItem := TItemFunctions.GetItemEquipSlot(BuyItem.Index);

          if((AuxSlotItem >= 1) and (AuxSlotItem <= 15)) then
          begin
            TItemFunctions.PutEquipament(Player, BuyItem.Index);
          end
          else
          begin
            TItemFunctions.PutItem(Player, BuyItem.Index, BuyItem.Refi);
          end;
        end;
    end;
  end;
  Result := true;
end;
class function TPacketHandlers.SellNPCItens(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TSellNPCItemPacket absolute Buffer;
  Item: pItem;
  SellPrice, i, j, Honor, ItemSLot, AuxPrice,k: Integer;
  TempleSpace: TSpaceTemple;
begin
  Result := False;
  if Packet.Index <> Player.OpennedNPC then
  begin
    Result := true;
    Player.SendClientMessage('NPC Não esta aberto.');
    Exit;
  end;

  Item := @Player.Character.Base.Inventory[Packet.Slot];

  if TItemFunctions.CanAgroup(Item^) then
  begin
    if(Item^.Time > 0) then
    begin
      Player.SendClientMessage('Esse item não pode ser vendido.');
      Exit;
    end;

    if ItemList[Item.Index].SellPrince <= 0 then
    begin
      Player.SendClientMessage('Esse item não pode ser vendido.');
      Exit;
    end;

    if(ItemList[Item.Index].TypeItem = 7) then
    begin
      Player.SendClientMessage('Esse item não pode ser vendido.');
      Exit;
    end;

    if(ItemList[Item.Index].SellPrince < 5) then
    begin
      SellPrice := (ItemList[Item.Index].SellPrince * Item.Refi);
    end
    else
    begin
      case ItemList[Item.Index].ItemType of
<<<<<<< HEAD
        60,61:
=======
        60:
>>>>>>> parent of a46c38b (30)
          begin
            SellPrice := ((ItemList[Item.Index].SellPrince div 4) * Item.Refi);
          end;

      else
        begin
          SellPrice := ((ItemList[Item.Index].SellPrince div 5) * Item.Refi);
        end;
      end;
    end;

    Player.AddGold(SellPrice);
    ZeroMemory(Item, sizeof(TItem));
    Player.RefreshMoney;
    Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.Slot, Item^, False);
    Result := true;
    Exit;
  end
  else
  begin
    // Calcula o preço de forma diferente;
    if ((Packet.Index >= 3335) and (Packet.Index <= 3339)) then
    begin // clicou nos npc pra entregar relíquia

    end
    else
    begin
      //Player.SendClientMessage('Item não agrupavel.');

      if(Item^.Time > 0) then
      begin
        Player.SendClientMessage('Esse item não pode ser vendido.');
        Exit;
      end;

      if ItemList[Item.Index].SellPrince <= 0 then
      begin
        Player.SendClientMessage('Esse item não pode ser vendido.');
        Exit;
      end;

      if(ItemList[Item.Index].TypeItem = 7) then
      begin
        Player.SendClientMessage('Esse item não pode ser vendido.');
        Exit;
      end;

      if(ItemList[Item.Index].TypeTrade = 0) then
      begin
        if(ItemList[Item.Index].Durabilidade > 0) then
        begin
          SellPrice := (ItemList[Item.Index].SellPrince div 5);

          AuxPrice := Round((Item.MIN / Item.MAX) * SellPrice);

          Player.AddGold(AuxPrice);
          ZeroMemory(Item, sizeof(TItem));
          Player.RefreshMoney;
          Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.Slot, Item^, False);
        end
        else
        begin
          Player.SendClientMessage('Item não agrupável para venda.');
        end;
      end
      else
      begin
        Player.SendClientMessage('Esse item não pode ser vendido.');
      end;
    end;
  end;

  Result := True;
end;
{$ENDREGION}
{$REGION 'Inventory Item Functions'}
class function TPacketHandlers.DeleteItem(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TDeleteItemPacket absolute Buffer;
  Item: pItem;
begin
  Result := False;
  case Packet.TypeSlot of
    EQUIP_TYPE:
      Item := @Player.Character.Base.Equip[Packet.Slot];
    INV_TYPE:
      Item := @Player.Character.Base.Inventory[Packet.Slot];
    PRAN_INV_TYPE:
    begin
      case Player.SpawnedPran of
        0:
          Item := @Player.Account.Header.Pran1.Inventory[Packet.Slot];
        1:
          Item := @Player.Account.Header.Pran2.Inventory[Packet.Slot];
      else
        Exit;
      end;
    end;
  else
    Exit;
  end;
  case ItemList[Item.Index].ItemType of
    40: //relíquias
    begin
      {Servers[Player.ChannelIndex].CreateMapObject(@Player, 320, Item.Index);
      Servers[Player.ChannelIndex].SendServerMsg('O jogador ' +
        AnsiString(Player.Character.Base.Name) + ' dropou a relíquia <' +
        AnsiString(ItemList[Item.Index].Name) + '>.');
      ZeroMemory(Item, sizeof(TItem));
      Player.Base.SendRefreshItemSlot(Packet.TypeSlot, Packet.Slot, Item^, False);
      Player.SendEffect(0);}
      Result := True;
      Exit;
    end;
  end;
  if(ItemList[Item.Index].ItemType = 716) then
  begin //remover buff de experiencia / quest double
    Player.Base.RemoveBuff(ItemList[Item.Index].UseEffect);
  end;
  Player.SendClientMessage('O item [' + AnsiString(ItemList[Item.Index].Name) +
    '] foi deletado.', 0);
  ZeroMemory(Item, sizeof(TItem));
  Player.Base.SendRefreshItemSlot(Packet.TypeSlot, Packet.Slot, Item^, False);
  Result := true;
end;
class function TPacketHandlers.UngroupItem(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TUngroupItemPacket absolute Buffer;
  srcItem, destItem: pItem;
  Slot: BYTE;
begin
  Result := False;
  srcItem := nil;
  case Packet.SlotType of
    EQUIP_TYPE:
      begin
        Result := true;
        Exit;
      end;
    INV_TYPE:
      begin
        srcItem := @Player.Character.Base.Inventory[Packet.Slot];
      end;
    STORAGE_TYPE:
      begin
        Result := true;
        Exit;
      end;
    PRAN_INV_TYPE:
      begin
        case Player.SpawnedPran of
          0:
            begin
              srcItem := @Player.Account.Header.Pran1.Inventory[Packet.Slot];
              if ((Packet.Quantidade >= srcItem.Refi) or (ItemList[srcItem.Index].Expires))
              then
              begin
                Exit;
              end;
              Slot := TItemFunctions.GetEmptyPranSlot(Player);
              if (Slot = 255) then
              begin
                Player.SendClientMessage('Inventario cheio.');
                Exit;
              end;
              destItem := @Player.Account.Header.Pran1.Inventory[Slot];
              Move(srcItem^, destItem^, sizeof(TItem));
              TItemFunctions.SetItemAmount(destItem^, Packet.Quantidade);
              Dec(srcItem.Refi, Packet.Quantidade);
              Player.Base.SendRefreshItemSlot(Packet.SlotType, Packet.Slot,
                srcItem^, False);
              Player.Base.SendRefreshItemSlot(Packet.SlotType, Slot, destItem^, False);
              Result := true;
              Exit;
            end;
          1:
            begin
              srcItem := @Player.Account.Header.Pran2.Inventory[Packet.Slot];
              if ((Packet.Quantidade >= srcItem.Refi) or (ItemList[srcItem.Index].Expires))
              then
              begin
                Exit;
              end;
              Slot := TItemFunctions.GetEmptyPranSlot(Player);
              if (Slot = 255) then
              begin
                Player.SendClientMessage('Inventario cheio.');
                Exit;
              end;
              destItem := @Player.Account.Header.Pran2.Inventory[Slot];
              Move(srcItem^, destItem^, sizeof(TItem));
              TItemFunctions.SetItemAmount(destItem^, Packet.Quantidade);
              Dec(srcItem.Refi, Packet.Quantidade);
              Player.Base.SendRefreshItemSlot(Packet.SlotType, Packet.Slot,
                srcItem^, False);
              Player.Base.SendRefreshItemSlot(Packet.SlotType, Slot, destItem^, False);
              Result := true;
              Exit;
            end;
        else
          begin
            Result := True;
            Exit;
          end;
        end;
      end;
    PRAN_EQUIP_TYPE:
      begin
        Result := True;
        Exit;
      end;
  end;
  if ((Packet.Quantidade >= srcItem.Refi) or (ItemList[srcItem.Index].Expires))
  then
  begin
    Exit;
  end;
  Slot := TItemFunctions.GetEmptySlot(Player);
  if (Slot = 255) then
  begin
    Player.SendClientMessage('Inventario cheio.');
    Exit;
  end;
  destItem := @Player.Character.Base.Inventory[Slot];
  Move(srcItem^, destItem^, sizeof(TItem));
  TItemFunctions.SetItemAmount(destItem^, Packet.Quantidade);
  Dec(srcItem.Refi, Packet.Quantidade);
  Player.Base.SendRefreshItemSlot(Packet.SlotType, Packet.Slot,
    srcItem^, False);
  Player.Base.SendRefreshItemSlot(Packet.SlotType, Slot, destItem^, False);
  Result := true;
end;
class function TPacketHandlers.AgroupItem(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TAgroupItemPacket absolute Buffer;
  srcItem, destItem: pItem;
begin
  srcItem := @Player.Character.Base.Inventory[Packet.srcSlot];
  destItem := @Player.Character.Base.Inventory[Packet.destSlot];
  if (srcItem.Index <> destItem.Index) then
  begin
    Result := true;
    Exit;
  end;
  TItemFunctions.SetItemAmount(destItem^, srcItem.Refi, true);
  ZeroMemory(srcItem, sizeof(TItem));
  Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.srcSlot, srcItem^, False);
  Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.destSlot, destItem^, False);
  Result := true;
end;
class function TPacketHandlers.MoveItem(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TMoveItemPacket absolute Buffer;
  Aux: TItem;
  ReSpawn, UpdatePoint, PranRespawn: Boolean;
  TypeEquip, Helper, Helper2: Integer;
  destItem, srcItem: pItem;
  DestBag, SrcBag: Integer;
  Guild: PGuild;
  SpawnPran, UnspawnPran: BYTE;
begin
  Result := False;
  SrcBag := 0;
  DestBag := 0;
  SpawnPran := 255;
  UnspawnPran := 255;
  if (Packet.SrcType = EQUIP_TYPE) then
    if (Packet.DestType <> INV_TYPE) then
      Exit;
  if (Packet.DestType = EQUIP_TYPE) then
    if (Packet.SrcType <> INV_TYPE) then
      Exit;
  TypeEquip := 0;
  ReSpawn := False;
  PranRespawn := False;
  UpdatePoint := False;
  srcItem := nil;
  destItem := nil;
  case (Packet.SrcType) of
    INV_TYPE:
      begin
        SrcBag := 0;
        if (Packet.srcSlot < 60) then
        begin
          case Packet.srcSlot of
            0 .. 14:
              SrcBag := 60;
            15 .. 29:
              SrcBag := 61;
            30 .. 44:
              SrcBag := 62;
            45 .. 59:
              SrcBag := 63;
          end;
          if Player.Character.Base.Inventory[SrcBag].Index <= 0 then
            Exit;
          srcItem := @Player.Character.Base.Inventory[Packet.srcSlot];
        end
        else
          Exit;
      end;
    EQUIP_TYPE:
      begin
        if (Packet.srcSlot < 16) and (Packet.srcSlot > 1) then
        begin
          srcItem := @Player.Character.Base.Equip[Packet.srcSlot];
          TypeEquip := EQUIPING_TYPE;
          case Packet.srcSlot of
            2, 3, 4, 5, 6, 7:
              ReSpawn := true;
          else
            UpdatePoint := true;
          end;
        end
        else
          Exit;
      end;
    STORAGE_TYPE:
      begin
        // if not(Player.OpennedOption = 7) or not(Player.OpennedOption = 13)  or (Player.OpennedNPC <= 0) then
        // Exit;
        // Player.SendClientMessage('Sim passou');
        SrcBag := 0;
        if (Packet.srcSlot < 80) then
        begin
          case Packet.srcSlot of
            0 .. 19:
              SrcBag := 80;
            20 .. 39:
              SrcBag := 81;
            40 .. 59:
              SrcBag := 82;
            60 .. 79:
              SrcBag := 83;
          end;
          if Player.Account.Header.Storage.Itens[SrcBag].Index <= 0 then
            Exit;
          srcItem := @Player.Account.Header.Storage.Itens[Packet.srcSlot];
        end
        else
        begin
          if ((Packet.srcSlot = 84) or (Packet.srcSlot = 85)) then
          begin // central da pran pro inventário
            if (ItemList[Player.Account.Header.Storage.Itens[Packet.srcSlot].
              Index].ItemType = 10) then
            begin // o item movido pode ser apenas pran
              srcItem := @Player.Account.Header.Storage.Itens[Packet.srcSlot];
            end
            else
              Exit;
          end
          else
            Exit;
        end;
      end;
    GUILDCHEST_TYPE:
      begin
        if not(Player.OpennedOption = 11) or (Player.OpennedNPC <= 0) then
          Exit;
        if (Packet.srcSlot < 50) then
        begin
          if Player.Character.Base.GuildIndex <= 0 then
            Exit;
          Guild := @Guilds[Player.Character.GuildSlot];
          if Guild.MemberInChest <> Guild.FindMemberFromCharIndex
            (Player.Character.Index) then
            Exit;
          if Guild.GetRankConfig
            (Guild.Members[Guild.FindMemberFromCharIndex(Player.Character.Index)
            ].Rank).UseGWH = False then
          begin
            Player.SendClientMessage('Você não tem permissão para isso.');
            Exit;
          end;
          srcItem := @Guild.Chest.Items[Packet.srcSlot];
        end
        else
          Exit;
      end;
    PRAN_EQUIP_TYPE:
      begin
        if (Packet.srcSlot <= 5) and (Packet.srcSlot > 0) and
          not(Player.spawnedPran = 255) then
        begin
          case Player.spawnedPran of
            0:
              srcItem := @Player.Account.Header.Pran1.Equip[Packet.srcSlot];
            1:
              srcItem := @Player.Account.Header.Pran2.Equip[Packet.srcSlot];
          end;
          TypeEquip := EQUIPING_TYPE;
          PranRespawn := true;
        end
        else
          Exit;
      end;
    PRAN_INV_TYPE:
      begin
        if (Packet.srcSlot <= 39) and not(Player.spawnedPran = 255) then
        begin
          case Player.spawnedPran of
            0:
              begin
                case Packet.srcSlot of
                  0 .. 19:
                    SrcBag := 40;
                  20 .. 39:
                    SrcBag := 41;
                end;
                if (Player.Account.Header.Pran1.Inventory[SrcBag].Index = 0)
                then
                  Exit;
                srcItem := @Player.Account.Header.Pran1.Inventory
                  [Packet.srcSlot];
              end;
            1:
              begin
                case Packet.srcSlot of
                  0 .. 19:
                    SrcBag := 40;
                  20 .. 39:
                    SrcBag := 41;
                end;
                if (Player.Account.Header.Pran2.Inventory[SrcBag].Index = 0)
                then
                  Exit;
                srcItem := @Player.Account.Header.Pran2.Inventory
                  [Packet.srcSlot];
              end;
          end;
        end
        else
          Exit;
      end;
  end;
  case (Packet.DestType) of
    INV_TYPE:
      begin
        DestBag := 0;
        if (Packet.destSlot < 60) then
        begin
          case Packet.destSlot of
            0 .. 14:
              DestBag := 60;
            15 .. 29:
              DestBag := 61;
            30 .. 44:
              DestBag := 62;
            45 .. 59:
              DestBag := 63;
          end;
          if Player.Character.Base.Inventory[DestBag].Index <= 0 then
            Exit;
          destItem := @Player.Character.Base.Inventory[Packet.destSlot];
        end
        else
          Exit;
      end;
    EQUIP_TYPE:
      begin
        if (Packet.destSlot < 16) and (Packet.destSlot > 1) then
        begin
          destItem := @Player.Character.Base.Equip[Packet.destSlot];
          TypeEquip := DESEQUIPING_TYPE;
          case Packet.destSlot of
            2, 3, 4, 5, 6, 7:
              ReSpawn := true;
          else
            UpdatePoint := true;
          end;
        end
        else
          Exit;
      end;
    STORAGE_TYPE:
      begin
        if ((not(Player.OpennedOption = 7) and not(Player.OpennedOption = 13))
          or (Player.OpennedNPC <= 0)) then
          Exit;
        DestBag := 0;
        if (Packet.destSlot < 80) then
        begin
          case Packet.destSlot of
            0 .. 19:
              DestBag := 80;
            20 .. 39:
              DestBag := 81;
            40 .. 59:
              DestBag := 82;
            60 .. 79:
              DestBag := 83;
          end;
          if Player.Account.Header.Storage.Itens[DestBag].Index <= 0 then
            Exit;
          destItem := @Player.Account.Header.Storage.Itens[Packet.destSlot];
        end
        else
        begin
          if ((Packet.destSlot = 84) or (Packet.destSlot = 85)) then
          begin // inventário pra central pran
            if (ItemList[Player.Character.Base.Inventory[Packet.srcSlot].Index]
              .ItemType = 10) then
            begin // o item movido pode ser apenas pran
              destItem := @Player.Account.Header.Storage.Itens[Packet.destSlot];
            end
            else
              Exit;
          end
          else
            Exit;
        end;
      end;
    GUILDCHEST_TYPE:
      begin
        if not(Player.OpennedOption = 11) or (Player.OpennedNPC <= 0) then
          Exit;
        if (Packet.destSlot < 50) then
        begin
          if Player.Character.Base.GuildIndex <= 0 then
            Exit;
          Guild := @Guilds[Player.Character.GuildSlot];
          if Guild.MemberInChest <> Guild.FindMemberFromCharIndex
            (Player.Character.Index) then
            Exit;
          if Guild.GetRankConfig
            (Guild.Members[Guild.FindMemberFromCharIndex(Player.Character.Index)
            ].Rank).UseGWH = False then
          begin
            Player.SendClientMessage('Você não tem permissão para isso.');
            Exit;
          end;
          destItem := @Guild.Chest.Items[Packet.destSlot];
        end
        else
          Exit;
      end;
    PRAN_EQUIP_TYPE:
      begin
        if (Packet.destSlot <= 5) and (Packet.destSlot > 0) and
          not(Player.spawnedPran = 255) then
        begin
          case Player.spawnedPran of
            0:
              destItem := @Player.Account.Header.Pran1.Equip[Packet.destSlot];
            1:
              destItem := @Player.Account.Header.Pran2.Equip[Packet.destSlot];
          end;
          TypeEquip := DESEQUIPING_TYPE;
          PranRespawn := true;
        end
        else
          Exit;
      end;
    PRAN_INV_TYPE:
      begin
        if (Packet.destSlot <= 39) and not(Player.spawnedPran = 255) then
        begin
          case Player.spawnedPran of
            0:
              begin
                case Packet.destSlot of
                  0 .. 19:
                    DestBag := 40;
                  20 .. 39:
                    DestBag := 41;
                end;
                if (Player.Account.Header.Pran1.Inventory[DestBag].Index = 0)
                then
                  Exit;
                destItem := @Player.Account.Header.Pran1.Inventory
                  [Packet.destSlot];
              end;
            1:
              begin
                case Packet.destSlot of
                  0 .. 19:
                    DestBag := 40;
                  20 .. 39:
                    DestBag := 41;
                end;
                if (Player.Account.Header.Pran2.Inventory[DestBag].Index = 0)
                then
                  Exit;
                destItem := @Player.Account.Header.Pran2.Inventory
                  [Packet.destSlot];
              end;
          end;
        end
        else
          Exit;
      end;
  end;

  //Player.Base.SendRefreshItemSlot(Packet.destType, Packet.destSlot,
    //destItem^, False);
  //Player.Base.SendRefreshItemSlot(Packet.SrcType, Packet.srcSlot,
    //srcItem^, False);

  if ((Packet.SrcType = INV_TYPE) and (Packet.DestType = STORAGE_TYPE) and
    not(ItemList[Player.Character.Base.Inventory[Packet.srcSlot].Index]
    .ItemType = 10)) then
  begin
    if (srcItem^.Index > 0) and (ItemList[srcItem^.Index].TypeTrade = 1) then
      Exit;
    if (destItem^.Index > 0) and (ItemList[destItem^.Index].TypeTrade = 1) then
      Exit;
  end;
  if (Packet.SrcType = INV_TYPE) and (Packet.DestType = PRAN_INV_TYPE) then
  begin
    if (srcItem^.Index > 0) and (ItemList[srcItem^.Index].TypeTrade = 1) then
      Exit;
  end;
  if (Packet.SrcType = PRAN_INV_TYPE) and (Packet.DestType = INV_TYPE) then
  begin
    if (destItem^.Index > 0) and (ItemList[destItem^.Index].TypeTrade = 1) then
      Exit;
  end;
  if (Packet.SrcType = PRAN_INV_TYPE) and (Packet.DestType = PRAN_EQUIP_TYPE)
  then
    Exit;
  if (Packet.SrcType = PRAN_EQUIP_TYPE) and (Packet.DestType = PRAN_INV_TYPE)
  then
    Exit;
  if ((Packet.DestType = PRAN_EQUIP_TYPE) and (Packet.SrcType = PRAN_EQUIP_TYPE))
  then
    Exit;

  if((ItemList[destItem.Index].ItemType = 8) and
    (ItemList[srcItem.Index].ItemType = 8)) then
    Exit;

  if((ItemList[destItem.Index].ItemType in [50, 52]) and (Packet.SrcType = EQUIP_TYPE)
    and (srcItem.Index > 0)) then
  begin
    if(ItemList[destItem.Index].Rank <> ItemList[srcItem.Index].Rank) then
      Exit;
  end;

  if (Packet.SrcType = INV_TYPE) and (Packet.DestType = PRAN_EQUIP_TYPE) then
  begin
    if (TItemFunctions.GetItemEquipPranSlot(srcItem.Index) <> Packet.destSlot)
    then
      Exit;
    case Player.spawnedPran of
      0:
        begin
          if (ItemList[srcItem.Index].Level > (Player.Account.Header.Pran1.Level
            + 1)) then
            Exit;
          if (Player.GetPranClassStoneItem
            (Player.Account.Header.Pran1.ClassPran) <> ItemList[srcItem.Index]
            .Classe) then
          begin
            if(ItemList[srcItem.Index].Classe > 0) then
              Exit;
          end;
        end;
      1:
        begin
          if (ItemList[srcItem.Index].Level > (Player.Account.Header.Pran2.Level
            + 1)) then
            Exit;
          if (Player.GetPranClassStoneItem
            (Player.Account.Header.Pran2.ClassPran) <> ItemList[srcItem.Index]
            .Classe) then
          begin
            if(ItemList[srcItem.Index].Classe > 0) then
              Exit;
          end;
        end;
    end;
  end;
  if (Packet.SrcType = PRAN_EQUIP_TYPE) and (Packet.DestType = INV_TYPE) then
  begin
    if (destItem^.Index > 0) and
      (TItemFunctions.GetItemEquipPranSlot(destItem.Index) <> Packet.destSlot)
    then
      Exit;
    if (destItem.Index > 0) then
      case Player.spawnedPran of
        0:
          begin
            if (ItemList[destItem.Index].Level >
              (Player.Account.Header.Pran1.Level + 1)) then
              Exit;
            if (Player.GetPranClassStoneItem
              (Player.Account.Header.Pran1.ClassPran) <> ItemList[destItem.
              Index].Classe) then
            begin
              if(ItemList[destItem.Index].Classe > 0) then
                Exit;
            end;
          end;
        1:
          begin
            if (ItemList[destItem.Index].Level >
              (Player.Account.Header.Pran2.Level + 1)) then
              Exit;
            if (Player.GetPranClassStoneItem
              (Player.Account.Header.Pran2.ClassPran) <> ItemList[destItem.
              Index].Classe) then
            begin
              if(ItemList[destItem.Index].Classe > 0) then
                Exit;
            end;
          end;
      end;
  end;
  if (Packet.SrcType = INV_TYPE) and (Packet.DestType = GUILDCHEST_TYPE) then
  begin
    if (srcItem^.Index > 0) and not(ItemList[srcItem^.Index].TypeTrade = 0) then
      Exit;
    if (destItem^.Index > 0) and not(ItemList[destItem^.Index].TypeTrade = 0)
    then
      Exit;
  end;
  if (Packet.SrcType = STORAGE_TYPE) and (Packet.DestType = INV_TYPE) then
  begin
    if (destItem^.Index > 0) and (ItemList[destItem^.Index].TypeTrade = 1) then
      Exit;
  end;
  if (Packet.SrcType = GUILDCHEST_TYPE) and (Packet.DestType = INV_TYPE) then
  begin
    if (destItem^.Index > 0) and not(ItemList[destItem^.Index].TypeTrade = 0)
    then
      Exit;
  end;
  if (Packet.SrcType = INV_TYPE) and (Packet.DestType = EQUIP_TYPE) then
  begin // do invent�rio para o equip
    if (TItemFunctions.GetItemEquipSlot(srcItem^.Index) <> Packet.destSlot) then
      Exit;
    if (Player.Character.Base.Level < ItemList[srcItem^.Index].Level) then
      Exit;
    if (ItemList[srcItem^.Index].ItemType = 10) then
    begin // movendo pran do invent�rio pro equip, mandar sendtoworld e spawn
      if (Player.Account.Header.Pran1.ItemID = srcItem^.Identific) then
      begin
        SpawnPran := 0;
      end
      else if (Player.Account.Header.Pran2.ItemID = srcItem^.Identific) then
      begin
        SpawnPran := 1;
      end;
      if (destItem^.Index > 0) then
      begin
        if (Player.Account.Header.Pran1.ItemID = destItem^.Identific) then
        begin
          UnspawnPran := 0;
        end
        else if (Player.Account.Header.Pran2.ItemID = destItem^.Identific) then
        begin
          UnspawnPran := 1;
        end;
      end;
    end
    else
    begin
      if (Player.Base.GetMobClass() <> Player.Base.GetMobClass
        (ItemList[srcItem^.Index].Classe)) then
      begin
        Exit;
      end;
    end;
  end;
  if (Packet.SrcType = EQUIP_TYPE) and (Packet.DestType = INV_TYPE) then
  begin // do equip para o inventario
    if (destItem^.Index > 0) then
    begin
      if (TItemFunctions.GetItemEquipSlot(destItem^.Index) <> Packet.srcSlot)
      then
        Exit;
      if (Player.Character.Base.Level < ItemList[destItem^.Index].Level) then
        Exit;
      if (Player.Base.GetMobClass() <> Player.Base.GetMobClass
        (ItemList[destItem^.Index].Classe)) then
      begin
        Exit;
      end;
    end;
    if (ItemList[srcItem^.Index].ItemType = 10) then
    begin // movendo pran do equip para o inv, mandar unspawn
      if (Player.Account.Header.Pran1.ItemID = srcItem^.Identific) then
      begin
        UnspawnPran := 0;
      end
      else if (Player.Account.Header.Pran2.ItemID = srcItem^.Identific) then
      begin
        UnspawnPran := 1;
      end;
      if (destItem^.Index > 0) then
      begin
        if (Player.Account.Header.Pran1.ItemID = destItem^.Identific) then
        begin
          SpawnPran := 0;
        end
        else if (Player.Account.Header.Pran2.ItemID = destItem^.Identific) then
        begin
          SpawnPran := 1;
        end;
      end;
    end;
  end;

  if (srcItem.Index = destItem.Index) and (ItemList[destItem.Index].CanAgroup)
  then
    TItemFunctions.AgroupItem(srcItem, destItem)
  else
  begin
    Move(destItem^, Aux, sizeof(TItem));
    Move(srcItem^, destItem^, sizeof(TItem));
    Move(Aux, srcItem^, sizeof(TItem));
    if (TypeEquip = EQUIPING_TYPE) then
    begin
      Player.Base.SetEquipEffect(srcItem^, EQUIPING_TYPE);
      Player.Base.SetEquipEffect(destItem^, DESEQUIPING_TYPE);
    end
    else if (TypeEquip = DESEQUIPING_TYPE) then
    begin
      Player.Base.SetEquipEffect(srcItem^, DESEQUIPING_TYPE);
      Player.Base.SetEquipEffect(destItem^, EQUIPING_TYPE);
    end;
  end;
  Player.Base.SendRefreshItemSlot(Packet.DestType, Packet.destSlot,
    destItem^, False);
  Player.Base.SendRefreshItemSlot(Packet.SrcType, Packet.srcSlot,
    srcItem^, False);

  if(ItemList[destItem.Index].ItemType = 8) then
  begin
    if((Packet.DestType = EQUIP_TYPE) and (Packet.SrcType = INV_TYPE)) then
    begin //criar o PET no array e spawnar
      if(Player.Base.PetClientID > 0) then
      begin
        Player.SendClientMessage
          ('Você não pode possuir dois PETs ao mesmo tempo.');
        Exit;
      end;

      Helper := Servers[Player.ChannelIndex].GetFreePetClientID;

      if(Helper = 0) then
      begin
        Player.SendClientMessage('Erro ao spawnar mascote. Contate o suporte.');
      end
      else
      begin
        Randomize;
        Player.Base.CreatePet(NORMAL_PET, Player.Base.Neighbors[RandomRange(0,8)].pos,
          destItem.Index);

        Player.SpawnPet(Player.Base.PetClientID);

        for Helper2 in Player.Base.VisiblePlayers do
        begin
          Servers[Player.ChannelIndex].Players[Helper2].SpawnPet(Player.Base.PetClientID);
          if not(Servers[Player.ChannelIndex].Players[Helper2].Base.VisibleMobs.Contains(Player.Base.PetClientID)) then
            Servers[Player.ChannelIndex].Players[Helper2].Base.VisibleMobs.Add(Player.Base.PetClientID);
        end;
      end;
    end
    else if((Packet.DestType = INV_TYPE) and (Packet.SrcType = EQUIP_TYPE)) then
    begin //despawnar o PET e limpar o array dele
      Player.Base.DestroyPet(Player.Base.PetClientID);
      Player.Base.PetClientID := 0;
    end;
  end;


  if (ReSpawn) then
  begin
    Player.Base.GetCurrentScore;
    Player.Base.SendStatus;
    Player.Base.SendRefreshPoint;
    Player.Base.SendCurrentHPMP;
    Player.Base.SendCreateMob(SPAWN_NORMAL);
  end
  else if(UpdatePoint) then
  begin
    Player.Base.GetCurrentScore;
    Player.Base.SendStatus;
    Player.Base.SendRefreshPoint;
    Player.Base.SendCurrentHPMP;
  end;
  if (PranRespawn) then
  begin
    Player.Base.GetCurrentScore;
    Player.Base.SendStatus;
    Player.Base.SendRefreshPoint;
    Player.Base.SendCurrentHPMP;
    Player.SendPranSpawn(Player.spawnedPran);
  end;
  if not(UnspawnPran = 255) then
  begin
    Player.spawnedPran := 255;
    Player.SendPranToWorld(255);
    Player.SendPranUnspawn(UnspawnPran);
    Player.SetPranPassiveSkill(UnspawnPran, 0);
    Player.SetPranEquipAtributes(UnspawnPran, False);
    Player.Base.GetCurrentScore;
    Player.Base.SendStatus;
    Player.Base.SendRefreshPoint;
    Player.Base.SendCurrentHPMP;
  end;
  if not(SpawnPran = 255) then
  begin
    Player.SendPranSpawn(SpawnPran);
    Player.SendPranToWorld(SpawnPran);
    Player.SetPranPassiveSkill(SpawnPran, 1);
    Player.SetPranEquipAtributes(SpawnPran, true);
    Player.Base.GetCurrentScore;
    Player.Base.SendStatus;
    Player.Base.SendRefreshPoint;
    Player.Base.SendCurrentHPMP;
    Player.spawnedPran := SpawnPran;
  end;
  Result := true;
end;
{$ENDREGION}
{$REGION 'Change Item Atributes [Refine/etc]'}
class function TPacketHandlers.ChangeItemAttribute(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TChangeItemAttPacket absolute Buffer;
  Reinforced: BYTE;
  MaterialSlot: WORD;
begin
  Reinforced := 0;
  Result := False;
  case Packet.ChangeType of
{$REGION 'Reinforce'}
    CHANGE_REINFORCE:
      begin
        Reinforced := TItemFunctions.ReinforceItem(Player, Packet.ItemSlot,
          Packet.Item2, Packet.Item3);
        if (Reinforced = 4) then
        begin
          Player.SendClientMessage('Algo de errado não está certo.');
          Exit;
        end;
        if (Reinforced = 5) then
        begin
          Player.SendClientMessage('Você não possui gold suficiente.');
          Exit;
        end;
        if (Reinforced = 6) then
        begin
          Player.SendClientMessage('Refinação máxima permitida: +11');
          Exit;
        end;
        Result := true;
      end;
{$ENDREGION}
{$REGION 'Enchant'}
    CHANGE_ENCHANTS:
      begin
        Reinforced := TItemFunctions.EnchantItem(Player, Packet.ItemSlot,
          Packet.Item2);
        if (Reinforced = 0) then
        begin
          Player.SendClientMessage('Algo de errado não está certo!', 16);
          Exit;
        end;
        if (Reinforced = 1) then
        begin
          Player.SendClientMessage('Erro de item. Contatue o suporte!', 16);
          Exit;
        end;
        if(Reinforced = 3) then
        begin
          Player.SendClientMessage('Já existe esse atributo encantado no item.', 16);
          Exit;
        end;
        if(Reinforced = 4) then
        begin
          Player.SendClientMessage('O vaizan que você usou resultou em um atributo já encantado.', 16);
          Exit;
        end;
        if (Reinforced = 2) then
        begin
          Result := true;
        end;
      end;
{$ENDREGION}
{$REGION 'Change APP'}
    CHANGE_APP:
      begin
        MaterialSlot := TItemFunctions.GetItemSlot2(Player, 4580);
        if (MaterialSlot = 255) then
        begin
          Player.SendClientMessage('Você não possui Athlon!', 16);
          Exit;
        end;
        Reinforced := TItemFunctions.ChangeApp(Player, Packet.ItemSlot,
          MaterialSlot, Packet.Item2);
        if (Reinforced = 0) then
        begin
          Player.SendClientMessage('Algo de errado não está certo!', 16);
          Exit;
        end;
        if (Reinforced = 1) then
        begin
          Player.SendClientMessage
            ('Este item não pode ser colocado como aparência!', 16);
          Exit;
        end;
        if (Player.Character.Base.Gold < 500) then
        begin
          Player.SendClientMessage('Você não tem o gold necessário!', 16);
          Exit;
        end;
        if (Reinforced = 2) then
        begin
          Dec(Player.Character.Base.Gold, 500);
          Result := true;
        end;
      end;
{$ENDREGION}
{$REGION 'Mount Enchant'}
    CHANGE_MOUNT_ENCHANTS:
      begin
        Reinforced := TItemFunctions.EnchantMount(Player, Packet.ItemSlot,
          Packet.Item2);
        if (Reinforced = 0) then
        begin
          Player.SendClientMessage('Algo de errado não está certo!', 16);
          Exit;
        end;
        if (Reinforced = 1) then
        begin
          Player.SendClientMessage('Erro de item. Contatue o suporte!', 16);
          Exit;
        end;
        if (Reinforced = 2) then
        begin
          Result := true;
        end;
      end;
    CHANGE_PRAN_ENCHANTS:
      begin
        Reinforced := TItemFunctions.EnchantItem(Player, Packet.ItemSlot,
          Packet.Item2);
        if (Reinforced = 0) then
        begin
          Player.SendClientMessage('Algo de errado não está certo!', 16);
          Exit;
        end;
        if (Reinforced = 1) then
        begin
          Player.SendClientMessage('Erro de item. Contatue o suporte!', 16);
          Exit;
        end;
        if (Reinforced = 2) then
        begin
          Result := true;
        end;
      end;
{$ENDREGION}
  end;
  Player.RefreshMoney;
  Player.Base.SendRefreshItemSlot(Packet.ItemSlot, False);
  Player.Base.SendRefreshItemSlot(Packet.Item2, False);
  if not(Packet.Item3 = $FFFFFFFF) then
  begin
    Player.Base.SendRefreshItemSlot(Packet.Item3, False);
  end;
  Player.SendChangeItemResponse(Reinforced, Packet.ChangeType);
  {
    case Packet.ChangeType of
    CHANGE_ENCHANTS:
    begin
    Player.SendPacket(Packet, Packet.Header.Size);
    end;
    CHANGE_APP:
    begin
    Player.SendPacket(Packet, Packet.Header.Size);
    end;
    CHANGE_MOUNT_ENCHANTS:
    begin
    Player.SendPacket(Packet, Packet.Header.Size);
    end;
    end; }
end;
{$ENDREGION}
{$REGION 'Troca'}
class function TPacketHandlers.TradeRequest(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TSignalData absolute Buffer;
begin
  Result := False;
  if (Packet.Data <= 0) or (Packet.Data > MAX_CONNECTIONS) then
  begin
    Player.SendClientMessage('Você não pode negociar com esse jogador.');
    Exit;
  end;
  if ((Player.Character.TradingWith <> 0) or
    (Servers[Player.ChannelIndex].Players[Packet.Data].Character.TradingWith
    <> 0)) then
  begin
    Player.SendClientMessage('Jogador ja está em negociação.');
    Exit;
  end;
  Servers[Player.ChannelIndex].Players[Packet.Data]
    .SendData(Player.Base.ClientId, $315, { Packet.Data } Player.Base.ClientId);
  Result := true;
end;
class function TPacketHandlers.TradeResponse(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TResponseTradePacket absolute Buffer;
  I: Integer;
begin
  Result := False;
  Player.Character.TradingWith := Packet.OtherClient;
  case Packet.Response of
    TRADE_ACEPT:
      begin
        Packet.OtherClient := Player.Base.ClientId;
        Servers[Player.ChannelIndex].SendPacketTo(Player.Character.TradingWith,
          Packet, Packet.Header.Size);
        Servers[Player.ChannelIndex].Players[Player.Character.TradingWith]
          .Character.TradingWith := Player.Base.ClientId;
        ZeroMemory(@Player.Character.Trade, sizeof(TTrade));
        ZeroMemory(@Servers[Player.ChannelIndex].Players
          [Player.Character.TradingWith].Character.Trade, sizeof(TTrade));
        for I := 0 to 9 do
        begin
          Player.Character.Trade.Slots[I] := $FF;
          Servers[Player.ChannelIndex].Players[Player.Character.TradingWith]
            .Character.Trade.Slots[I] := $FF;
        end;
        Player.Character.Trade.OtherClientid := Player.Character.TradingWith;
        Servers[Player.ChannelIndex].Players[Player.Character.TradingWith]
          .Character.Trade.OtherClientid := Player.Base.ClientId;
        Player.RefreshTrade;
        Player.RefreshTradeTo(Player.Character.TradingWith);
        Servers[Player.ChannelIndex].Players[Player.Character.TradingWith]
          .RefreshTrade;
        Servers[Player.ChannelIndex].Players[Player.Character.TradingWith]
          .RefreshTradeTo(Player.Base.ClientId);
        Result := true;
      end;
    TRADE_REFUSE:
      begin
        Packet.OtherClient := Player.Base.ClientId;
        Servers[Player.ChannelIndex].Players[Player.Character.TradingWith]
          .SendClientMessage('Pedido de troca recusado!');
        Servers[Player.ChannelIndex].SendPacketTo(Player.Character.TradingWith,
          Packet, Packet.Header.Size);
        Player.Character.TradingWith := 0;
      end;
  end;
end;
class function TPacketHandlers.TradeRefresh(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TTradePacket absolute Buffer;
  OtherPlayer: PPlayer;
  i: Integer;
  slot_cnt: Integer;
begin
  Result := False;
  if (Packet.Header.Index = 0) then
    Exit;
  if (Player.Character.TradingWith = 0) or
    (Player.Character.TradingWith > MAX_CONNECTIONS) then
    Exit;
  OtherPlayer := @Servers[Player.ChannelIndex].Players
    [Player.Character.TradingWith];

  if(Packet.Trade.Ready) then
  begin
    slot_cnt := 0;
    for I := 0 to 9 do
    begin
      if(Packet.Trade.Slots[i] <> 255) then
        inc(slot_cnt);
    end;

    if(TItemFunctions.GetInvAvailableSlots(OtherPlayer^) < slot_cnt) then
    begin
      OtherPlayer.SendClientMessage('Libere mais espaço no inventário antes.');
      Player.SendClientMessage('O inventário do alvo não possui espaço suficiente.');
      Packet.Trade.Ready := False;
      OtherPlayer.Character.Trade.Ready := False;
      //Player.Character.Trade.Ready := False;
      OtherPlayer.RefreshTradeTo(Player.Base.ClientID);
    end;
  end;



  {if ((Player.Character.Trade.Ready) or (OtherPlayer.Character.Trade.Ready)) then
  begin
    slot_cnt := 0;
    for I := 0 to 9 do
    begin
      if(Packet.Trade.Slots[i] <> 255) then
        inc(slot_cnt);
    end;

    if(TItemFunctions.GetInvAvailableSlots(OtherPlayer^) < slot_cnt) then
    begin
      OtherPlayer.SendClientMessage('Libere mais espaço no inventário antes.');
      OtherPlayer.Character.Trade.Ready := False;
      //Move(Packet.Trade, Player.Character.Trade, sizeof(TTrade));
      //OtherPlayer.RefreshTradeTo(Player.Base.ClientID);
      //OtherPlayer.RefreshTrade;
      //Player.RefreshTrade;
      //Player.RefreshTradeTo(OtherPlayer.Base.ClientID);
      Exit;
    end;
  end;}

  for I := 0 to 9 do
  begin
    if(Packet.Trade.Itens[i].Index = 0) then
      Continue;

    if(ItemList[Packet.Trade.Itens[i].Index].TypeTrade > 0) then
    begin
      //Packet.Trade.Confirm := False;
      //OtherPlayer.Character.Trade := False;
      ZeroMemory(@OtherPlayer.Character.Trade, sizeof(TTrade));
      ZeroMemory(@Player.Character.Trade, sizeof(TTrade));
      OtherPlayer.CloseTrade;
      Player.CloseTrade;
      Player.SendClientMessage('Não é possível trocar itens que não são trocáveis.');
      OtherPlayer.SendClientMessage('Não é possível trocar itens que não são trocáveis.');
      Exit;
    end;

    if(ItemList[Player.Base.Character.Inventory[Packet.Trade.Slots[i]].Index].TypeTrade > 0) then
    begin
      //Packet.Trade.Confirm := False;
      //OtherPlayer.Character.Trade := False;
      ZeroMemory(@OtherPlayer.Character.Trade, sizeof(TTrade));
      ZeroMemory(@Player.Character.Trade, sizeof(TTrade));
      OtherPlayer.CloseTrade;
      Player.CloseTrade;
      Player.SendClientMessage('Não é possível trocar itens que não são trocáveis.');
      OtherPlayer.SendClientMessage('Não é possível trocar itens que não são trocáveis.');
      Exit;
    end;
  end;

  if (Packet.Trade.Confirm) and (OtherPlayer.Character.Trade.Confirm) then
  begin
    Result := TFunctions.ExecuteTrade(Player, OtherPlayer);
    OtherPlayer.RefreshTradeTo(Player.Base.ClientId);
    OtherPlayer.CloseTrade;
    Player.CloseTrade;
    Player.SendClientMessage('Troca realizada com sucesso.');
    OtherPlayer.SendClientMessage('Troca realizada com sucesso.');
    Exit;
  end;

  Move(Packet.Trade, Player.Character.Trade, sizeof(TTrade));
  Player.RefreshTradeTo(OtherPlayer.Base.ClientId);
  Result := true;
end;
class function TPacketHandlers.TradeCancel(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TSignalData absolute Buffer;
begin
  Result := False;
  if (Player.Base.PersonalShop.Index > 0) or (Player.Base.PersonalShopIndex > 0)
  then
  begin
    Result := Self.ClosePersonalShop(Player, Buffer);
    Exit;
  end;
  if (Player.Character.TradingWith = 0) then
  begin
    Exit;
  end;
  Servers[Player.ChannelIndex].Players[Player.Character.TradingWith].CloseTrade;
  Player.Character.TradingWith := 0;
  Result := true;
end;
{$ENDREGION}
{$REGION 'Item Bar Functions'}
class function TPacketHandlers.ChangeItemBar(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TChangeItemBarPacket absolute Buffer;
begin
  Result := true;
  case Packet.SrcType of
    0:
      begin
        Player.RefreshItemBarSlot(Packet.destSlot, 0, Packet.SrcIndex);
        Player.Character.Base.ItemBar[Packet.destSlot] := 0;
      end;
    2:
      begin
        Player.Character.Base.ItemBar[Packet.destSlot] :=
          ((Packet.SrcIndex) * 16) + 2;
        Player.RefreshItemBarSlot(Packet.destSlot, 2, Packet.SrcIndex);
      end;
    3: // pran skill bar
      begin
        if (SkillData[Packet.SrcIndex+5760].Duration = 0) and not(Packet.SrcIndex=0) then
        begin //skills de pran que são passivas e não podem ser colocadas na barra
          Exit;
        end;
        Player.RefreshItemBarSlot(Packet.destSlot, 3, Packet.SrcIndex);
        case Player.spawnedPran of
          0:
            begin
              Player.Account.Header.Pran1.ItemBar[Packet.destSlot] :=
                Packet.SrcIndex;
            end;
          1:
            begin
              Player.Account.Header.Pran2.ItemBar[Packet.destSlot] :=
                Packet.SrcIndex;
            end;
        end;
      end;
    6:
      begin
        { Aqui ira a verificação se o player tem o item }
        if(TItemFunctions.GetItemSlot2(Player, Packet.SrcIndex) = 255) then
        begin
          Exit;
        end;
        Player.Character.Base.ItemBar[Packet.destSlot] := Packet.SrcIndex;
        Player.RefreshItemBarSlot(Packet.destSlot, 6, Packet.SrcIndex);
      end;
  else
    begin
      Result := False;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'MOB Functions'}
class function TPacketHandlers.UpdateMobInfo(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TRequestMobInfoPacket absolute Buffer;
  MOB: TBaseMob;
begin
  Result := False;
  if (Packet.Index = 0) or (Packet.Index > 3048) then
    Exit;
  case Packet.Type1 of
    1:
      begin
        Packet.Index := 2047 + Packet.Index;
      end;
  end;
  if not(TBaseMob.GetMob(Packet.Index, Player.ChannelIndex, MOB)) then
    Exit;
  if (Player.Base.VisibleNPCS.Contains(Packet.Index)) then
    Exit;
  MOB.SendCreateMob(SPAWN_NORMAL, Player.Base.ClientId, False);
  Result := true;
end;
{$ENDREGION}
{$REGION 'Premium Items'}
class function TPacketHandlers.BuyItemCash(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TSignalData absolute Buffer;
  Slot: Integer;
  CashInventory: PCashInventory;
begin
  Result := False;

  if(Packet.Data = 0) then
  begin
    Player.SendClientMessage('Item inválido.');
    Exit;
  end;

  if(PremiumItems[Packet.Data].show = 0) then
  begin
    Player.SendClientMessage('Item não pode ser comprado.');
    Exit;
  end;

  CashInventory := @Player.Account.Header.CashInventory;
  if (CashInventory.Cash >= PremiumItems[Packet.Data].Price) then
  begin
    Slot := CashInventory.AddItem(Packet.Data);
    { Reduz o cash apos a compra }
    if (Slot >= 0) then
    begin
      DecCardinal(CashInventory.Cash, PremiumItems[Packet.Data].Price);
      Player.Base.SendRefreshItemSlot(CASH_TYPE, Slot,
        CashInventory.Items[Slot].ToItem, False);
      Player.SendClientMessage('Item comprado com sucesso.');
      Player.SendPlayerCash;
      Result := true;
    end
    else
    begin
      Player.SendClientMessage('Você não tem espaço suficiente na loja cash.');
    end;
  end
  else
  begin
    Player.SendClientMessage('Você não tem cash suficiente.');
  end;
end;
class function TPacketHandlers.SendGift(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSendGiftPacket absolute Buffer;
  SelfPremium: PCashInventory;
  OtherPremium: PCashInventory;
begin
  Result := False;
  SelfPremium := @Player.Account.Header.CashInventory;
  if not(Servers[Player.ChannelIndex].Players[Packet.Target].Base.IsActive) then
    Exit;
  OtherPremium := @Servers[Player.ChannelIndex].Players[Packet.Target]
    .Account.Header.CashInventory;
  if (SelfPremium.IsEmpyt(Packet.Slot)) then
    Exit;
  if (OtherPremium.AddItem(SelfPremium.Items[Packet.Slot].Index) = -1) then
  begin
    Player.SendClientMessage('Inventario cash do destinatario já esta cheio.');
    Exit;
  end;
  Servers[Player.ChannelIndex].Players[Packet.Target].SendClientMessage
    ('Recebeu presente de ' + AnsiString(Player.Character.Base.Name) + '.');
  ZeroMemory(@SelfPremium.Items[Packet.Slot], sizeof(TItemCash));
  Servers[Player.ChannelIndex].Players[Packet.Target].SendCashInventory;
  Player.SendCashInventory;
  Result := true;
end;
class function TPacketHandlers.ReclaimCoupom(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TPacketReclaimCoupom absolute Buffer;
  SQLComp: TQuery;
  RealCupom: String;
  i: Integer;
  CashAmount: Integer;
  CommandID: Integer;
begin
  Result := False;

  if(Trim(String(Packet.Coupom)) <> '') then
  begin
    if(Length(String(Packet.Coupom)) < 16) then
    begin
      Player.SendClientMessage('Cupom inválido.');
      Exit;
    end;

    SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
      AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
      AnsiString(MYSQL_DATABASE), True);
    if not(SQLComp.Query.Connection.Connected) then
    begin
      Logger.Write('Falha de conexão individual com mysql.[CheckGMLogin]',
        TlogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[CheckGMLogin]', TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
    RealCupom := '';
    for I := 1 to 16 do
    begin
      SetLength(RealCupom, Length(RealCupom)+1);
      RealCupom[High(RealCupom)] := Char(Packet.Coupom[i-1]);

      if(i in [4,8,12]) then
      begin
        SetLength(RealCupom, Length(RealCupom)+1);
        RealCupom[High(RealCupom)] := '-';
      end;
    end;

    SQLComp.SetQuery('select id, target_itemid, command_type, target_itemcnt from gm_commands where coupom = ' +
      QuotedStr(RealCupom) + ' and runned=1 and refused=0 and target_name=""');
    SQLComp.Run();

    if(SQLComp.Query.RecordCount = 0) then
    begin
      Player.SendClientMessage('Cupom inválido.');
      SQLComp.Destroy;
      Exit;
    end
    else
    begin
      CommandID := SQLComp.Query.Fields[0].AsInteger;

      case SQLComp.Query.Fields[2].AsInteger of
        COUPOM_GMCOMMAND:
          begin
            CashAmount := (SQLComp.Query.Fields[1].AsInteger*1000);
            Player.AddCash(CashAmount);
            Player.SendPlayerCash;
            Player.SendClientMessage('You has activated a PinCode [' +
              CashAmount.ToString + ' iNizCoins].');
          end;
        FOUNDER_GMCOMMAND:
          begin
            if(TItemFunctions.GetEmptySlot(Player) = 255) then
            begin
              Player.SendClientMessage('ESVAZIE SEU INVENTÁRIO.');
              SQLComp.Destroy;
              Exit;
            end;

            CashAmount := (SQLComp.Query.Fields[1].AsInteger);
            TItemFunctions.PutItem(Player, CashAmount, SQLComp.Query.Fields[3].AsInteger);

            case CashAmount of
              14134, 14135, 14136, 14137:
                begin
                  Player.SendClientMessage('Seu pacote fundador foi ativado. Aproveite.');
                end;
            else
              begin
                Player.SendClientMessage('Seu item [' + ItemList[CashAmount].Name + '] foi entregue com sucesso.');
              end;
            end;
          end;
      end;

      SQLComp.SetQuery('update gm_commands set target_name=' +
        QuotedStr(String(Player.Base.Character.Name)) + ' where id='+
          CommandID.ToString);
      SQLComp.Query.Connection.StartTransaction;
      SQLComp.Run(False);
      SQLComp.Query.Connection.Commit;
    end;
  end
  else
  begin
    Player.SendClientMessage('Cupom inválido.');
    SQLComp.Destroy;
    Exit;
  end;

  SQLComp.Destroy;
  Result := True;
end;
{$ENDREGION}
{$REGION 'Item Functions'}
class function TPacketHandlers.UseItem(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TUseItemPacket absolute Buffer;
begin
  Result := False;
  if (Player.Base.IsDead) then
    Exit;
  case Packet.TypeSlot of
    INV_TYPE:
      Result := TItemFunctions.UseItem(Player, Packet.Slot, Packet.Type1);
    ITEM_USE_TYPE:
      begin//repare item by here
        if(Player.Base.Character.Inventory[Packet.Slot].Index = 0) then
          Exit;

         case ItemList[Player.Base.Character.Inventory[Packet.Slot].Index].ItemType of
          708:
            begin
              if(Packet.Type1 > 16) then
              begin //reparar no invent
                Packet.Type1 := Packet.Type1 -16;

                if(TItemFunctions.GetItemEquipSlot(Player.Base.Character.Inventory[Packet.Type1].Index) = 6) then
                begin
                  Player.Base.Character.Inventory[Packet.Type1].Min :=
                      Player.Base.Character.Inventory[Packet.Type1].Max;
                  Player.Base.sendrefreshitemslot(INV_TYPE, Packet.Type1,
                    Player.Base.Character.Inventory[
                    Packet.Type1], False);
                end;
              end
              else //reparar no equip
              begin
                if(TItemFunctions.GetItemEquipSlot(Player.Base.Character.Equip[Packet.Type1].Index) = 6) then
                begin
                  Player.Base.Character.Equip[Packet.Type1].Min :=
                      Player.Base.Character.Equip[Packet.Type1].Max;
                  Player.Base.sendrefreshitemslot(EQUIP_TYPE, Packet.Type1,
                    Player.Base.Character.Equip[
                    Packet.Type1], False);
                end;
              end;

              Player.SendClientMessage('Item reparado com sucesso.');
            end;

          709:
            begin
              if(Packet.Type1 > 16) then
              begin //reparar no invent
                Packet.Type1 := Packet.Type1 -16;

                if(TItemFunctions.GetItemEquipSlot(Player.Base.Character.Inventory[Packet.Type1].Index) in
                  [2,3,4,5,7]) then
                begin
                  Player.Base.Character.Inventory[Packet.Type1].Min :=
                      Player.Base.Character.Inventory[Packet.Type1].Max;
                  Player.Base.sendrefreshitemslot(INV_TYPE, Packet.Type1,
                    Player.Base.Character.Inventory[
                    Packet.Type1], False);
                end;
              end
              else //reparar no equip
              begin
                if(TItemFunctions.GetItemEquipSlot(Player.Base.Character.Equip[Packet.Type1].Index) in
                  [2,3,4,5,7]) then
                begin
                  Player.Base.Character.Equip[Packet.Type1].Min :=
                      Player.Base.Character.Equip[Packet.Type1].Max;
                  Player.Base.sendrefreshitemslot(EQUIP_TYPE, Packet.Type1,
                    Player.Base.Character.Equip[
                    Packet.Type1], False);
                end;
              end;

              Player.SendClientMessage('Item reparado com sucesso.');
            end;

         else
            begin
              Player.SendClientMessage('Item ainda não configurado.');
            end;

         end;

        TItemFunctions.DecreaseAmount(@Player.Base.Character.Inventory[Packet.Slot]);
        Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.Slot,
          Player.Base.Character.Inventory[Packet.Slot], False);
      end;

    CASH_TYPE:
      Result := TItemFunctions.UsePremiumItem(Player, Packet.Slot);
  end;
end;
class function TPacketHandlers.UseBuffItem(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TUseBuffItemPacket absolute Buffer;
  Item: pItem;
  i: Integer;
begin
  Result := False;

  Item := @Player.Character.Base.Inventory[Packet.Slot];

  if (Item.IsSealed) then
  begin
    Exit;
  end;

  case ItemList[Item.Index].ItemType of

    0:
      Result := False;

    ITEM_TYPE_BUFF:
      begin
        if(SkillData[ItemList[Item.Index].UseEffect].Index = 285) then
        begin
          if(Player.Base.BuffExistsByIndex(285)) then
          begin
            Player.SendClientMessage('Não é combinável com [' +
              AnsiString(SkillData[ItemList[Item.Index].UseEffect].Name + '].'));
            Exit;
          end;
        end;

        case SkillData[ItemList[Item.Index].UseEffect].Index of
          280: //buque de rosas brancas
            begin
              if(Player.Base.BuffExistsByIndex(281)) then
              begin
                PLayer.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[Item.Index].UseEffect].Name + '].'));
                Exit;
              end;
            end;

          281: //buque de rosas vermelhas
            begin
              if(Player.Base.BuffExistsByIndex(280)) then
              begin
                Player.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[Item.Index].UseEffect].Name + '].'));
                Exit;
              end;
            end;

          305: //poção halloween, ronire, pascoa, premiuns
            begin
              if(Player.Base.BuffExistsByIndex(305)) then
              begin
                Player.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[Item.Index].UseEffect].Name + '].'));
                Exit;
              end;
            end;
        end;

        case ItemList[Item.Index].UseEffect of
          9134:
            begin
              Player.Base.AddBuff(ItemList[Item.Index].UseEffect);
            end;
        else
          begin
            Player.Base.AddBuff(ItemList[Item.Index].UseEffect);
          end;
        end;
      end;

    ITEM_TYPE_BUFF2:
      begin
        if(SkillData[ItemList[Item.Index].UseEffect].Index = 251) then
        begin
          if(Player.Base.BuffExistsByIndex(251)) then
          begin
            Player.SendClientMessage('Não é combinável com [' +
              AnsiString(SkillData[ItemList[Item.Index].UseEffect].Name + '].'));
            Exit;
          end;
        end;

        case ItemList[Item.Index].UseEffect of
          8124:
            begin
              if(Player.Base.BuffExistsByIndex(251)) then
                Exit;

              Player.Base.AddBuff(ItemList[Item.Index].UseEffect);
            end;

        else
          begin
            Player.Base.AddBuff(ItemList[Item.Index].UseEffect);
          end;
        end;
      end;
  end;
end;
class function TPacketHandlers.UnsealItem(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSignalData absolute Buffer;
  Item: pItem;
begin
  Result := False;
  Item := @Player.Character.Base.Inventory[Packet.Data];
  if (Item.Index = 0) then
    Exit;
  if (Item.IsSealed) then
    Item.IsSealed := False;
  TItemFunctions.UseItem(Player, Packet.Data);
  Player.Base.SendRefreshItemSlot(Packet.Data, False);
  Result := true;
end;
{$ENDREGION}
{$REGION 'Buff Functions'}
class function TPacketHandlers.RemoveBuff(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TRemoveBuffPacket absolute Buffer;
begin
  Result := Player.Base.RemoveBuff(Packet.BuffIndex);
  if (Result) then
  begin
    Player.Base.SendRefreshBuffs;
    Player.Base.SendCurrentHPMP;
    Player.Base.SendStatus;
    Player.Base.SendRefreshPoint;
  end;
end;
{$ENDREGION}
{$REGION 'Attack & Skill Functions'}
class function TPacketHandlers.UseSkill(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TSendSkillUse absolute Buffer;
  Packet2: TSendAtkPacket;
  //MPToRemove: Integer;
  OtherMob: PBaseMob;
  Bufferx: Array of Byte;
  MobId, mobpid: Integer;
  // OtherPlayer: PPlayer;
  // MOB: PBaseMob;
  // mobid, mobpid: Integer;
begin
  // Result := False;
  Player.Base.SendToVisible(Packet, Packet.Header.Size);
  if (Player.Base.IsDead) then
  begin
    Player.Base.Character.CurrentScore.CurHP := 0;
    Player.Base.SendCurrentHPMP();
    Player.Base.SendEffect($0);
    Exit;
  end;

  if(Packet.Skill = 0) then
    Exit;

  //if not(Player.Base.CheckCooldown2(Packet.Skill)) then
  //begin
   // Exit;
  //end;

  if ((SkillData[Packet.Skill].Classe >= 61) and (SkillData[Packet.Skill].Classe <= 84) and
    (SkillData[Packet.Skill].Duration = 0)) then
  begin //skills de pran que são passivas e não podem ser lancadas
    Exit;
  end;

  case Packet.Skill of //patching usar skill de pran vazia pelo atalho
    5760, 5860, 5960:
      Exit;
  end;

  if(Player.Base.Character.Level < SkillData[Packet.Skill].MinLevel) then
  begin
    Player.SendClientMessage('Você não pode usar essa skill. Somente no nível ' +
      SkillData[Packet.Skill].MinLevel.ToString + '.');
    Exit;
  end;

  Player.Base.CurrentAction := 0;

  Player.LastPositionLongSkill := Packet.pos;


  Player.Base.UsingSkill := Packet.Skill;

  case Player.Base.GetMobClass() of
    2,3:
      begin
        if(Player.Base.Character.Equip[15].Index = 0) then
        begin
          Player.SendClientMessage('Você está sem balas.');
          Exit;
        end;
      end;
  end;

  if not((SkillData[Packet.Skill].Classe >= 61) and
    (SkillData[Packet.Skill].Classe <= 84)) then
  begin
    if (Player.Base.BuffExistsByIndex(77)) then
    begin // inv dual
      Player.Base.RemoveBuffByIndex(77);
    end;
    if (Player.Base.BuffExistsByIndex(53)) then
    begin // inv att
      Player.Base.RemoveBuffByIndex(53);
    end;
  end;

  if not(SkillData[Packet.Skill].CastTime > 0) then
  begin
    ZeroMemory(@Packet2, sizeof(Packet2));

    Packet2.Header.Size := sizeof(Packet2);
    Packet2.Header.Index := Player.Base.ClientID;
    Packet2.Header.Code := $302;

    Packet2.Index := Packet.Index;
    if(Packet.Skill > 0) and (Packet.Skill < 11999) then
    begin
      Packet2.Anim := SkillData[Packet.Skill].SelfAnimation;
    end;

    Packet2.Skill := Packet.Skill;

    Packet2.MyPos := Player.Base.PlayerCharacter.LastPos;

    if((Packet.Index > 0) and (Packet.Index <= MAX_CONNECTIONS)) then
    begin
      if((Servers[Player.ChannelIndex].Players[Packet.Index].Status >= Playing) and
        not(Servers[Player.ChannelIndex].Players[Packet.Index].SocketClosed)) then
      begin
        Packet2.TargetPos := Servers[Player.ChannelIndex].Players[Packet.Index].Base.PlayerCharacter.LastPos;
      end;
    end
    else if((Packet.Index >= 3048) and (Packet.Index < 9148)) then
    begin
      OtherMob := Player.Base.GetTargetInList(Packet.Index);

      if not(OtherMob = nil) then
      begin
        if (OtherMob.IsDead) then
          Exit;

        case Packet.Index of
          3340 .. 3354:
            begin //stones
              Packet2.TargetPos := Servers[Player.ChannelIndex].DevirStones[OtherMob.ClientID].PlayerChar.LastPos;
            end;

          3355 .. 3369:
            begin // guards
              Packet2.TargetPos := Servers[Player.ChannelIndex].DevirGuards[OtherMob.ClientID].PlayerChar.LastPos;
            end;

        else
          begin
            Packet2.TargetPos := Servers[Player.ChannelIndex].Mobs.TMobS[OtherMob.Mobid].MobsP[OtherMob.SecondIndex].CurrentPos;
          end;

        end;
      end
      else
      begin
        mobid := TMobFuncs.GetMobGeralID(Player.ChannelIndex, Packet.Index, mobpid);
        if (mobid = -1) then
        begin
          Logger.Write('retornando -1 no GetMobGeralID mobid', TLogType.error);
          Exit;
        end;
        OtherMob := @Servers[Player.ChannelIndex].MOBS.TMobS[mobid].MobsP
        [mobpid].Base;
        Player.Base.AddTargetToList(OtherMob);

        Packet2.TargetPos := Servers[Player.ChannelIndex].Mobs.TMobS[OtherMob.Mobid].MobsP[OtherMob.SecondIndex].CurrentPos;
      end;
    end
    else if(Packet.Index >= 9148) then
    begin
      OtherMob := Player.Base.GetTargetInList(Packet.Index);

      if (OtherMob = nil) then
      begin
        //Player.Base.AddTargetToList()
        if (Player.Base.VisibleMobs.Contains(Packet.Index)) then
        begin
          Player.Base.VisibleMobs.Remove(Packet.Index);

          mobid := TMobFuncs.GetMobGeralID(Player.ChannelIndex, Packet.Index, mobpid);

          Player.UnspawnMob(mobid, mobpid);

          if (Servers[Player.ChannelIndex].MOBS.TMobS[mobid].MobsP[mobpid].Base.VisibleMobs.Contains(Player.Base.ClientId)) then
          begin
            Servers[Player.ChannelIndex].MOBS.TMobS[mobid].MobsP[mobpid].Base.VisibleMobs.Remove(Player.Base.ClientId);
          end;
        end;

        Exit;
      end;

      if (OtherMob.IsDead) then
        Exit;

      Packet2.TargetPos := Servers[Player.ChannelIndex].PETS[OtherMob.ClientID].Base.PlayerCharacter.LastPos;
    end;

    SetLength(Bufferx, sizeof(Packet2));
    //ZeroMemory(@Bufferx, sizeof(Bufferx));
    Move(Packet2, Bufferx[0], sizeof(Packet2));

    Self.AttackTarget(Player, Bufferx, True);
  end;

  // Result := true;
  // Player.Base.CheckCooldown(Packet);
  // if (Player.InDungeon) then
  // begin
  // Result := true;
  // Exit;
  // end;
  { if (Packet.Index >= 3048) and (Packet.Index <= 9147) then
    begin
    //mobid := TMobFuncs.GetMobGeralID(Player.ChannelIndex, Packet.Index, mobpid);
    //MOB := @Servers[Player.ChannelIndex].MOBS.TMobS[mobid].MobsP[mobpid].Base;
    //Player.Base.Target := MOB;
    //Player.Base.CheckCooldown(Packet);
    Result := true;
    Exit;
    end; }
  { OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(Packet.Index);
    if not(OtherPlayer.Base.IsActive) then
    begin
    Player.SendClientMessage('O alvo não está disponível.');
    Exit;
    end;
    Player.Base.Target := @OtherPlayer.Base;
    if ((Player.Base.ClientId = Player.Base.Target.ClientId) and
    not(SkillData[Packet.Skill].Index = 113)) then
    begin
    Packet.pos := Player.Base.PlayerCharacter.LastPos;
    end; }
  Result := true;
end;
class function TPacketHandlers.LearnSkill(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TLearnSkillPacket absolute Buffer;
  BarIndex: Integer;
  SkillID: Integer;
begin
  Result := False;
  if (SkillData[Packet.SkillIndex].MinLevel > Player.Character.Base.Level) then
  begin
    Player.SendClientMessage('Não possui level necessário.');
    Exit;
  end;
  if (SkillData[Packet.SkillIndex].SkillPoints >
    Player.Character.Base.CurrentScore.SkillPoint) then
  begin
    Player.SendClientMessage('Não possui pontos de habilidade necessário.');
    Exit;
  end;
  if (SkillData[Packet.SkillIndex].LearnCosts > Player.Character.Base.Gold) then
  begin
    Player.SendClientMessage('Não possui gold suficiente.');
    Exit;
  end;
  if not(Player.Base.MatchClassInfo(SkillData[Packet.SkillIndex].Classe)) then
  begin
    Player.SendClientMessage('Esta habilidade não pertence a sua classe.');
    Exit;
  end;
  if (SkillData[Packet.SkillIndex].MinLevel > Player.Base.Character.Level) then
  begin
    Exit;
  end;
  if (Player.SkillUpgraded = Packet.SkillIndex) then
  begin
    Exit;
  end;
  if(SkillData[Packet.SkillIndex].Index = 427) then
  begin
    Player.SendClientMessage('Esta habilidade não está disponível.');
    Exit;
  end;
  if (TSkillFunctions.IncremmentSkillLevel(Player, Packet.SkillIndex, SkillID))
  then
  begin
    if (Player.Character.Base.CurrentScore.SkillPoint = 1) then
    begin
      Player.Character.Base.CurrentScore.Status := 0;
      Player.Base.Character.CurrentScore.SkillPoint := 0;
    end
    else
      Dec(Player.Character.Base.CurrentScore.SkillPoint,
        SkillData[Packet.SkillIndex].SkillPoints);
    Dec(Player.Character.Base.Gold, SkillData[Packet.SkillIndex].LearnCosts);
    Player.SendPlayerSkills(Packet.NPCIndex);
    Player.RefreshMoney;
    Player.SendPlayerSkillsLevel;
    Player.SetActiveSkillPassive(SkillID, Packet.SkillIndex);
    Player.Base.SendCurrentHPMP;
    Player.Base.SendStatus;
    Player.Base.SendRefreshPoint;
    Player.SkillUpgraded := Packet.SkillIndex;
    TSkillFunctions.UpdateAllOnBar(Player, Packet.SkillIndex - 1,
      Packet.SkillIndex, BarIndex);
    Result := true;
  end;
end;
class function TPacketHandlers.ResetSkills(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Taxa: Integer;
  I: BYTE;
begin
  Result := False;
  Taxa := ((Player.Base.Character.Level * 1000) div 2);
  if (Player.Base.Character.Gold < Taxa) then
  begin
    Player.SendClientMessage
      ('Você não possui gold sulficiente para reniciar as suas habilidades!',
      16);
    Exit;
  end;
  for I := 0 to 31 do
  begin
    Player.Base.Character.ItemBar[I] := 0;
    Player.RefreshItemBarSlot(I, 0, Player.Base.Character.ItemBar[I]);
  end;
  Player.SearchSkillsPassive(1);
  Player.Base.SendCurrentHPMP;
  move(InitialAccounts[Player.Base.GetMobClass].Skills,
    Player.Character.Skills, sizeof(InitialAccounts[Player.Base.GetMobClass].Skills));
  {for I := 0 to Length(Player.Character.Skills.Others) - 1 do
  begin
    Player.Character.Skills.Others[I].Level := 0;
  end;
  Player.Character.Skills.Others[0].Level := 1;}
  Dec(Player.Base.Character.Gold, Taxa);
  Player.Character.Base.CurrentScore.SkillPoint :=
    Player.CalcSkillPoints(Player.Base.Character.Level);
  Player.SendPlayerSkills;
  Player.RefreshMoney;
  Player.SendPlayerSkillsLevel;
  Player.Base.SendStatus;
  Player.Base.SendRefreshPoint;
  Player.OpennedNPC := 0;
  Player.OpennedOption := 0;
  Result := true;
end;
class function TPacketHandlers.AttackTarget(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE; ByUseSkill: Boolean): Boolean;
var
  Packet: TSendAtkPacket absolute Buffer;
  OtherMob: PBaseMob;
  mobid, MPToRemove: Integer;
  mobpid: Integer;
  DataSkill: P_SkillData;
  DelayForAttack, sk: Integer;
begin
  Result := true;

  if (Player.Base.IsDead) then
  begin
    Player.Base.Character.CurrentScore.CurHP := 0;
    Player.Base.SendCurrentHPMP();
    Player.Base.SendEffect($0);
    Exit;
  end;

  if((Packet.Index > 0) and (Packet.Index <= MAX_CONNECTIONS) and not(Packet.Index = Player.Base.ClientID) and not(Player.PartyIndex > 0)) then
  begin
    if(Servers[Player.ChannelIndex].Players[
      Packet.Index].SocketClosed) then
      Exit;

   if((Player.Character.GuildSlot > 0) and (Servers[Player.ChannelIndex].Players[
    Packet.Index].Character.GuildSlot > 0)) then
    begin
      if((Guilds[Player.Character.GuildSlot].Ally.Leader =
        Guilds[Servers[Player.ChannelIndex].Players[
        Packet.Index].Character.GuildSlot].Ally.Leader) and not(Player.Dueling)) then
      Exit;
    end;

   if (Player.Dueling) then
    begin
      if (Packet.Index <> Player.DuelingWith) then
        Exit;
      if (SecondsBetween(Now, Player.DuelInitTime) <= 15) then
        Exit;
    end;
  end;

  if not(ByUseSkill) then
  begin
    if(Packet.Skill > 0) then
    begin
      if not(SkillData[Packet.Skill].CastTime > 0) then
      begin
        if not((SkillData[Packet.Skill].Classe >= 61) and
          (SkillData[Packet.Skill].Classe <= 84)) then
            Exit;
      end
      else
      begin
        MPToRemove := 0;

        if (Packet.Index = 0) then
        begin
          case SkillData[Packet.Skill].Index of
             107, 110,166,167:
               begin
                 MPToRemove := SkillData[Packet.Skill].MP div 10;
               end;
          end;
        end
        else
        begin
          if(SkillData[Packet.Skill].Index = 107) then
            MPToRemove := SkillData[Packet.Skill].MP div 10;
        end;

        if(MpToRemove = 0) then
          MPToRemove := SkillData[Packet.Skill].MP;

        if (Player.Base.GetMobAbility(EF_PRAN_REQUIRE_MP) > 0) then
          Dec(MPToRemove, ((MPToRemove div 100) * Player.Base.GetMobAbility
            (EF_PRAN_REQUIRE_MP)));

        if(SkillData[Packet.Skill].Attribute in [25, 50]) then
        begin
          Dec(MPToRemove, ((MPToRemove div 100) * Player.Base.GetMobAbility(EF_MPCURE)));
        end;

        if(Player.Base.GetMobAbility(EF_REQUIRE_MP) > 0) then
        begin
          Dec(MPToRemove, ((MPToRemove div 100) * Player.Base.GetMobAbility(EF_REQUIRE_MP)));
        end;

        if (Player.Base.Character.CurrentScore.CurMP < MPToRemove)
        then
        begin
          Servers[Player.Base.ChannelId].Players[Player.Base.ClientId]
            .SendClientMessage
            ('Você não possui MP necessário para realizar a habilidade.');
          Result := true;
          Exit;
        end
        else
        begin
          Player.Base.RemoveMP(MPToRemove, true);
        end;
      end;

    end
    else
    begin
      {sk := 1;
      case Player.Base.GetMobClass() of
        0:
          begin
            sk := 1;
          end;

        1:
          begin
            sk := 961;
          end;

        2:
          begin
            sk := 1921;
          end;

        3:
          begin
            sk := 2881;
          end;

        4:
          begin
            sk := 3841;
          end;

        5:
          begin
            sk := 4801;
          end;

      end;

      if not(Player.Base.CheckCooldown2(sk)) then
      begin
        Exit;
      end;
          }
    end;
  end
  else
  begin
    MPToRemove := 0;

    if (Packet.Index = 0) then
    begin
      case SkillData[Packet.Skill].Index of
         110,166,167:
           begin
             MPToRemove := SkillData[Packet.Skill].MP div 10;
           end;
      end;
    end;

    if(MpToRemove = 0) then
      MPToRemove := SkillData[Packet.Skill].MP;

    if (Player.Base.GetMobAbility(EF_PRAN_REQUIRE_MP) > 0) then
      Dec(MPToRemove, ((MPToRemove div 100) * Player.Base.GetMobAbility
        (EF_PRAN_REQUIRE_MP)));

    if(SkillData[Packet.Skill].Attribute in [25, 50]) then
    begin
      Dec(MPToRemove, ((MPToRemove div 100) * Player.Base.GetMobAbility(EF_MPCURE)));
    end;

    if(Player.Base.GetMobAbility(EF_REQUIRE_MP) > 0) then
    begin
      Dec(MPToRemove, ((MPToRemove div 100) * Player.Base.GetMobAbility(EF_REQUIRE_MP)));
    end;

    if (Player.Base.Character.CurrentScore.CurMP < MPToRemove)
    then
    begin
      Servers[Player.Base.ChannelId].Players[Player.Base.ClientId]
        .SendClientMessage
        ('Você não possui MP necessário para realizar a habilidade.');
      Result := true;
      Exit;
    end
    else
    begin
      Player.Base.RemoveMP(MPToRemove, true);
    end;


  end;

  case Packet.Skill of //patching usar skill de pran vazia pelo atalho
    5760, 5860, 5960:
      Exit;
  end;

  {case Player.Base.GetMobClass(Player.Base.Character.ClassInfo) of
    0:
      begin
        DelayForAttack := MIN_DELAY_ATTACK-100;
      end;
    1:
      begin
        DelayForAttack := MIN_DELAY_ATTACK+50;
      end;

    2:
      begin
        DelayForAttack := MIN_DELAY_ATTACK+250;
      end;

    3:
      begin
        DelayForAttack := MIN_DELAY_ATTACK+150;
      end;
  end;  }
   // patch no fast_attack
  if (MilliSecondsBetween(Player.Base.LastBasicAttack, Now) <= MIN_DELAY_ATTACK)
  then
  begin
    Inc(Player.Base.AttackMsgCount);
    case Player.Base.AttackMsgCount of
      1:
        begin
          //Player.SendClientMessage('Outros programas detectados.');
        end;
      2:
        begin
          Player.SendClientMessage('Outros programas detectados.');
        end;
      3:
        begin
          Player.SendClientMessage('Outros programas detectados.');
          Player.Base.AttackMsgCount := 3;
          Player.Base.LastAttackMsg := Now;
        end;
    end;
    Exit;
  end;

  if (MilliSecondsBetween(Now, Player.Base.LastAttackMsg) <= 5000) then
  begin
    //Servers[Player.ChannelIndex].Disconnect(Player);
    Player.SocketClosed := True;
    Exit;
  end
  else
  begin
    Player.Base.AttackMsgCount := 0;
  end;

  Player.Base.LastBasicAttack := Now;
  DataSkill := @SkillData[Packet.Skill];

  {if not(Player.Base.CheckCooldown2(Packet.Skill)) then
  begin
    case DataSkill^.Index of
       107,166,167:
       begin
         inc(Player.Base.LongSkillTimes);
         if(player.Base.LongSkillTimes >= 10) then
           Exit;
       end;
    //else
      //begin
       // Player.Base.SendCurrentAllSkillCooldown();
       // Exit;
     // end;
    end;
  end
  else
  begin
    player.Base.LongSkillTimes := 0;
  end;}

  if (not(DataSkill^.Index in [196, 220, 244]) and (DataSkill^.Classe < 61)) then   // patch no uso de skills de outra classe
    if (Player.Base.GetMobClass(Player.Base.Character.ClassInfo) <>
      Player.Base.GetMobClass(DataSkill^.Classe)) then
        Exit;

  if(DataSkill^.Level > Player.Base.Character.Level) then
    Exit;

  if not((SkillData[Packet.Skill].Classe >= 61) and
    (SkillData[Packet.Skill].Classe <= 84)) then
  begin
    if (Player.Base.BuffExistsByIndex(77)) then
    begin // inv dual
      Player.Base.RemoveBuffByIndex(77);
    end;
    if (Player.Base.BuffExistsByIndex(53)) then
    begin // inv att
      Player.Base.RemoveBuffByIndex(53);
    end;
  end;

  if (DataSkill^.SuccessRate = 1) and (DataSkill^.range > 0) then
  begin // skills de ataque em area[targets]
    if ((Player.LastPositionLongSkill.X = 0) or
      (Player.LastPositionLongSkill.Y = 0)) then
    begin
      Player.LastPositionLongSkill := Packet.TargetPos;
    end;
    Player.Base.AreaSkill(Packet.Skill, Packet.Anim, nil,
      Player.LastPositionLongSkill, DataSkill);
    Exit;
  end;

  if not(Player.Base.Character.Equip[6].Index > 0) then
    Exit;

  if(Packet.Skill > 0) then
    if not(Player.Base.CheckCooldown2(Packet.Skill)) then
    begin
      Exit;
    end;

  if (Player.InDungeon) then
  begin
    if (Packet.Index = Player.Base.ClientId) then
    begin
      OtherMob := @Player.Base;
      if not(Packet.Skill = 0) then
      begin
        Player.Base.HandleSkill(Packet.Skill, Packet.Anim, OtherMob,
          Packet.TargetPos, DataSkill);
      end
      else
        Player.Base.SendDamage(Packet.Skill, Packet.Anim, OtherMob, DataSkill);
      Exit;
    end;
    mobid := TMobFuncs.GetMobDgGeralID(Player.ChannelIndex, Packet.Index,
      Player.DungeonInstanceID);
    if (mobid = -1) then
    begin
      Player.SendClientMessage('mobid -1 cannot got mob_geral_id_array INDEX: '
        + AnsiString(Packet.Index.ToString));
      Exit;
    end;
    OtherMob := @DungeonInstances[Player.DungeonInstanceID].MOBS[mobid].Base;
    if (OtherMob.IsDead) then
      Exit;
    if (DungeonInstances[Player.DungeonInstanceID].MOBS[mobid]
      .IsAttacked = False) then
    begin
      DungeonInstances[Player.DungeonInstanceID].MOBS[mobid].IsAttacked := true;
      DungeonInstances[Player.DungeonInstanceID].MOBS[mobid].FirstPlayerAttacker
        := Player.Base.ClientId;
    end;
    DungeonInstances[Player.DungeonInstanceID].MOBS[mobid].AttackerID :=
      Player.Base.ClientId;
    if not(Packet.Skill = 0) then
    begin
      Player.Base.HandleSkill(Packet.Skill, Packet.Anim, OtherMob,
        Packet.TargetPos, DataSkill);
    end
    else
      Player.Base.SendDamage(Packet.Skill, Packet.Anim, OtherMob, DataSkill);
  end;

  if (Packet.Index <= MAX_CONNECTIONS) then // só player
  begin
    if (Packet.Index > 0) then
      OtherMob := @Servers[Player.ChannelIndex].Players[Packet.Index].Base
    else
      OtherMob := @Player.Base;
    if not(OtherMob.IsActive) then
      Exit;
    if (OtherMob.IsDead) then
    begin
      if not(SkillData[Packet.Skill].Index = 126) then
        Exit;
    end;
    if (Packet.Skill = 0) then
    begin
      Player.Base.SendDamage(Packet.Skill, Packet.Anim, OtherMob, DataSkill);
    end
    else
      Player.Base.HandleSkill(Packet.Skill, Packet.Anim, OtherMob,
        Packet.TargetPos, DataSkill);

    Inc(Player.Base.AttacksAccumulated);
    Inc(OtherMob.AttacksReceivedAccumulated);

    if(Player.Base.AttacksAccumulated >= 48) then
    begin
      case Player.Base.Character.Equip[6].Refi of
        1..80:
          begin
            if not(Player.Base.BuffExistsByIndex(303)) then
              Dec(Player.Base.Character.Equip[6].MIN, 1);
          end;
        81..160:
          begin
            if not(Player.Base.BuffExistsByIndex(303)) then
              Dec(Player.Base.Character.Equip[6].MIN, 2);
          end;
        161..240:
          begin
            if not(Player.Base.BuffExistsByIndex(303)) then
              Dec(Player.Base.Character.Equip[6].MIN, 3);
          end;
      end;
      Player.Base.AttacksAccumulated := 0;
      Player.Base.SendRefreshItemSlot(EQUIP_TYPE, 6,
        Player.Base.Character.Equip[6], False);
    end;

    if(OtherMob.AttacksReceivedAccumulated >= 48) then
    begin
      if(OtherMob.Character.Equip[2].Index > 0) then
      begin
        case OtherMob.Character.Equip[2].Refi of
          1..80:
            begin
              if not(OtherMob.BuffExistsByIndex(303)) then
                Dec(OtherMob.Character.Equip[2].MIN, 1);
            end;
          81..160:
            begin
              if not(OtherMob.BuffExistsByIndex(303)) then
                Dec(OtherMob.Character.Equip[2].MIN, 2);
            end;
          161..240:
            begin
              if not(OtherMob.BuffExistsByIndex(303)) then
                Dec(OtherMob.Character.Equip[2].MIN, 3);
            end;
        end;
        OtherMob.AttacksReceivedAccumulated := 0;
        OtherMob.SendRefreshItemSlot(EQUIP_TYPE, 2,
          OtherMob.Character.Equip[2], False);
      end;
      if(OtherMob.Character.Equip[3].Index > 0) then
      begin
        case OtherMob.Character.Equip[3].Refi of
          1..80:
            begin
              if not(OtherMob.BuffExistsByIndex(303)) then
                Dec(OtherMob.Character.Equip[3].MIN, 1);
            end;
          81..160:
            begin
              if not(OtherMob.BuffExistsByIndex(303)) then
                Dec(OtherMob.Character.Equip[3].MIN, 2);
            end;
          161..240:
            begin
              if not(OtherMob.BuffExistsByIndex(303)) then
                Dec(OtherMob.Character.Equip[3].MIN, 3);
            end;
        end;
        OtherMob.AttacksReceivedAccumulated := 0;
        OtherMob.SendRefreshItemSlot(EQUIP_TYPE, 3,
          OtherMob.Character.Equip[3], False);
      end;
      if(OtherMob.Character.Equip[4].Index > 0) then
      begin
        case OtherMob.Character.Equip[4].Refi of
          1..80:
            begin
              if not(OtherMob.BuffExistsByIndex(303)) then
                Dec(OtherMob.Character.Equip[4].MIN, 1);
            end;
          81..160:
            begin
              if not(OtherMob.BuffExistsByIndex(303)) then
                Dec(OtherMob.Character.Equip[4].MIN, 2);
            end;
          161..240:
            begin
              if not(OtherMob.BuffExistsByIndex(303)) then
                Dec(OtherMob.Character.Equip[4].MIN, 3);
            end;
        end;
        OtherMob.AttacksReceivedAccumulated := 0;
        OtherMob.SendRefreshItemSlot(EQUIP_TYPE, 4,
          OtherMob.Character.Equip[4], False);
      end;
      if(OtherMob.Character.Equip[5].Index > 0) then
      begin
        case OtherMob.Character.Equip[5].Refi of
          1..80:
            begin
              if not(OtherMob.BuffExistsByIndex(303)) then
                Dec(OtherMob.Character.Equip[5].MIN, 1);
            end;
          81..160:
            begin
              if not(OtherMob.BuffExistsByIndex(303)) then
                Dec(OtherMob.Character.Equip[5].MIN, 2);
            end;
          161..240:
            begin
              if not(OtherMob.BuffExistsByIndex(303)) then
                Dec(OtherMob.Character.Equip[5].MIN, 3);
            end;
        end;
        OtherMob.AttacksReceivedAccumulated := 0;
        OtherMob.SendRefreshItemSlot(EQUIP_TYPE, 5,
          OtherMob.Character.Equip[5], False);
      end;
      if(OtherMob.Character.Equip[7].Index > 0) then
      begin
        case OtherMob.Character.Equip[7].Refi of
          1..80:
            begin
              if not(OtherMob.BuffExistsByIndex(303)) then
                Dec(OtherMob.Character.Equip[7].MIN, 1);
            end;
          81..160:
            begin
              if not(OtherMob.BuffExistsByIndex(303)) then
                Dec(OtherMob.Character.Equip[7].MIN, 2);
            end;
          161..240:
            begin
              if not(OtherMob.BuffExistsByIndex(303)) then
                Dec(OtherMob.Character.Equip[7].MIN, 3);
            end;
        end;
        OtherMob.AttacksReceivedAccumulated := 0;
        OtherMob.SendRefreshItemSlot(EQUIP_TYPE, 7,
          OtherMob.Character.Equip[7], False);
      end;
    end;
  end
  else if ((Packet.Index >= 3048) and (Packet.Index <= 9147)) then // só mob
  begin
    Inc(Player.Base.AttacksAccumulated);

    if(Player.Base.AttacksAccumulated >= 48) then
    begin
      case Player.Base.Character.Equip[6].Refi of
        1..80:
          begin
            if not(Player.Base.BuffExistsByIndex(303)) then
              Dec(Player.Base.Character.Equip[6].MIN, 1);
          end;
        81..160:
          begin
            if not(Player.Base.BuffExistsByIndex(303)) then
              Dec(Player.Base.Character.Equip[6].MIN, 2);
          end;
        161..240:
          begin
            if not(Player.Base.BuffExistsByIndex(303)) then
              Dec(Player.Base.Character.Equip[6].MIN, 3);
          end;
      end;
      Player.Base.AttacksAccumulated := 0;
      Player.Base.SendRefreshItemSlot(EQUIP_TYPE, 6,
        Player.Base.Character.Equip[6], False);
    end;

    { mobid := TMobFuncs.GetMobGeralID(Player.ChannelIndex, Packet.Index, mobpid);
      if (mobid = -1) then
      begin
      Logger.Write('retornando -1 no GetMobGeralID mobid', TLogType.Packets);
      Exit;
      end;
      OtherMob := @Servers[Player.ChannelIndex].MOBS.TMobS[mobid].MobsP
      [mobpid].Base; }
    OtherMob := Player.Base.GetTargetInList(Packet.Index);
    if (OtherMob = nil) then
    begin
      mobid := TMobFuncs.GetMobGeralID(Player.ChannelIndex, Packet.Index, mobpid);
      if (mobid = -1) then
      begin
        Logger.Write('retornando -1 no GetMobGeralID mobid', TLogType.error);
        Exit;
      end;
      OtherMob := @Servers[Player.ChannelIndex].MOBS.TMobS[mobid].MobsP
      [mobpid].Base;
      Player.Base.AddTargetToList(OtherMob);
      //Exit;
    end;

    if not(Servers[Player.ChannelIndex].MOBS.TMobS[OtherMob.Mobid].IsActiveToSpawn) then
      Exit;

    if (OtherMob^.IsDead) then
      Exit;
    if (OtherMob^.ClientId >= 3340) and (OtherMob^.ClientId <= 3369) then
    begin
      case OtherMob^.ClientId of
        3340 .. 3354:
          begin // stones
            if (Servers[Player.ChannelIndex].DevirStones[OtherMob^.ClientId]
              .IsAttacked = False) then
              Servers[Player.ChannelIndex].DevirStones[OtherMob^.ClientId]
                .FirstPlayerAttacker := Player.Base.ClientId;
            Servers[Player.ChannelIndex].DevirStones[OtherMob^.ClientId]
              .IsAttacked := true;
            Servers[Player.ChannelIndex].DevirStones[OtherMob^.ClientId]
              .AttackerID := Player.Base.ClientId;
          end;
        3355 .. 3369:
          begin // guardas
            if (Servers[Player.ChannelIndex].DevirGuards[OtherMob^.ClientId]
              .IsAttacked = False) then
              Servers[Player.ChannelIndex].DevirGuards[OtherMob^.ClientId]
                .FirstPlayerAttacker := Player.Base.ClientId;
            Servers[Player.ChannelIndex].DevirGuards[OtherMob^.ClientId]
              .IsAttacked := true;
            Servers[Player.ChannelIndex].DevirGuards[OtherMob^.ClientId]
              .AttackerID := Player.Base.ClientId;
          end;
      end;
    end
    else
    begin
      if (Servers[Player.ChannelIndex].MOBS.TMobS[OtherMob^.mobid].MobsP
        [OtherMob^.SecondIndex].IsAttacked = False) then
        Servers[Player.ChannelIndex].MOBS.TMobS[OtherMob^.mobid].MobsP
          [OtherMob^.SecondIndex].FirstPlayerAttacker := Player.Base.ClientId;
      Servers[Player.ChannelIndex].MOBS.TMobS[OtherMob^.mobid].MobsP
        [OtherMob^.SecondIndex].IsAttacked := true;
      Servers[Player.ChannelIndex].MOBS.TMobS[OtherMob^.mobid].MobsP
        [OtherMob^.SecondIndex].AttackerID := Player.Base.ClientId;
    end;
    if not(Packet.Skill = 0) then
    begin
      Player.Base.HandleSkill(Packet.Skill, Packet.Anim, OtherMob,
        Packet.TargetPos, DataSkill);
    end
    else
      Player.Base.SendDamage(Packet.Skill, Packet.Anim, OtherMob, DataSkill);
  end
  else if (Packet.Index >= 9148) then // só pet
  begin
    OtherMob := @Servers[Player.ChannelIndex].PETS[Packet.Index].Base;
    if not(OtherMob.IsActive) then
      Exit;
    if (OtherMob.IsDead) then
      Exit;
    if not(Packet.Skill = 0) then
    begin
      Player.Base.HandleSkill(Packet.Skill, Packet.Anim, OtherMob,
        Packet.TargetPos, DataSkill);
    end
    else
      Player.Base.SendDamage(Packet.Skill, Packet.Anim, OtherMob, DataSkill);
  end;
  Result := true;
end;
class function TPacketHandlers.RevivePlayer(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
begin
  Result := False;
  // if not(Player.Base.IsDead) then
  // Exit;

  if(Player.Base.InClastleVerus) then
  begin
    Player.Teleport(Player.Base.PositionSpawnedInCastle);
  end
  else
  begin
    if ((Player.Character.Base.Nation <> 0) and (Player.Character.Base.Nation <> Servers[Player.ChannelIndex].NationID))
    then
    begin
      Player.Teleport(TPosition.Create(2944, 1664));
    end
    else
    begin
      Player.SendPlayerToSavedPosition();
    end;
  end;

  Player.Character.Base.CurrentScore.CurHP := (Player.Base.GetCurrentHP div 10);
  Player.Character.Base.CurrentScore.CurMP := (Player.Base.GetCurrentMP div 10);
  Player.Base.IsDead := False;
  Player.Base.RevivedTime := Now;
  Player.Base.RemoveAllDebuffs;
  Player.Base.ResolutoPoints := 0;
  Player.Base.SendCurrentHPMP;
  Result := true;
end;

class function TPacketHandlers.CancelSkillLaunching(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSignalData absolute Buffer;
begin
  if(Player.SocketClosed) then
    Exit;

  if(Player.Base.IsDead) then
    Exit;

  if(Player.Status < Playing) then
    Exit;

  Player.Base.SendToVisible(Packet, Packet.Header.Size, False);
end;
{$ENDREGION}
{$REGION 'Friend List'}
class function TPacketHandlers.AddFriendRequest(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TAddFriendRequestPacket absolute Buffer;
  OtherPlayer: PPlayer;
begin
  Result := False;
  if Packet.Nick = '' then
    Exit;
  if not(Servers[Player.ChannelIndex].GetPlayerByName(string(Packet.Nick),
    OtherPlayer)) then
  begin
    Player.SendClientMessage('Jogador não encontrado.');
    Exit;
  end;
  if (Player.FriendList.Count >= 50) then
  begin
    Player.SendClientMessage('Lista de amigos cheia.');
    Exit;
  end;
  if (Player.FriendList.ContainsKey(OtherPlayer.Character.Index)) then
  begin
    Player.SendClientMessage('Jogador já adicionado.');
    Exit;
  end;
  if (OtherPlayer^.FriendList.Count >= 50) then
  begin
    Player.SendClientMessage('Lista de amigos do usuário cheia.');
    Exit;
  end;
  if((Player.Base.Character.Nation <> 0) and (OtherPlayer.Base.Character.Nation <> 0)) then
  begin
    if(Player.Base.Character.Nation <> OtherPlayer.Base.Character.Nation) then
    begin
      Player.SendClientMessage('Não é possível adicionar jogadores de outras nações.');
      Exit;
    end;
  end;
  Packet.Id := Player.Base.ClientId;
  AnsiStrings.StrCopy(Packet.Nick, Player.Character.Base.Name);
  OtherPlayer^.SendPacket(Packet, Packet.Header.Size);
end;
class function TPacketHandlers.AddFriendResponse(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TAddFriendResponsePacket absolute Buffer;
  OtherPlayer: PPlayer;
begin
  Result := False;
  if (Packet.Id = 0) or (Packet.Id > MAX_CONNECTIONS) then
    Exit;
  OtherPlayer := @Servers[Player.ChannelIndex].Players[Packet.Id];
  if not(OtherPlayer^.Base.IsActive) then
  begin
    Player.SendClientMessage('Jogador não encontrado.');
    Exit;
  end;
  if Packet.Response = 0 then
  begin
    OtherPlayer^.SendClientMessage('Pedido de amizade recusado.');
    Exit;
  end;
  case Player.AddFriend(Packet.Id) of
    0:
      Result := true;
    1:
      Player.SendClientMessage('Personagem offline ou não existe.');
    2:
      Player.SendClientMessage('Lista de amigos cheia.');
    3:
      Player.SendClientMessage('Lista de amigos do usuário cheia.');
  end;
  if(Result) then
  begin
    Player.SendClientMessage(Pchar('Você aceitou amizade de ' + OtherPlayer^.Base.Character.Name));
    OtherPlayer^.SendClientMessage(Pchar('Jogador ' +
      Player.Base.Character.Name + ' aceitou seu pedido de amizade.'));
  end;
end;
class function TPacketHandlers.DeleteFriend(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TDeleteFriendPacket absolute Buffer;
begin
  Result := False;
  if Packet.CharIndex <= 0 then
    Exit;
  if (Player.EntityFriend.removeFriend(Packet.CharIndex)) then
    Exit;
  Result := true;
end;
{$ENDREGION}
{$REGION 'Friend Chat'}
class function TPacketHandlers.OpenFriendWindow(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TOpenFriendWindowPacket absolute Buffer;
  OtherPlayer: WORD;
  OtherServer: Byte;
  // FriendSlot: BYTE;
begin
  Result := False;
{$OLDTYPELAYOUT ON}
  if not(Player.EntityFriend.getFriend(Packet.CharIndex, OtherPlayer, OtherServer))
  then
    Exit;
{$OLDTYPELAYOUT OFF}
  if (Player.FriendOpenWindowns.Count >= 6) then
    Exit;
  Player.SendPacket(Packet, Packet.Header.Size);
  Player.FriendOpenWindowns.Add(Packet.WindowIndex, Packet.CharIndex);
  Result := true;
end;
class function TPacketHandlers.SendFriendSay(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSendFriendChatPacket absolute Buffer;
  OtherPlayer: WORD;
  OtherServer: Byte;
  OtherWinIndex: DWORD;
  Key: DWORD;
  friendCharacterId: UInt64;
  I: BYTE;
begin
  Result := False;
  OtherWinIndex := $FF;
{$OLDTYPELAYOUT ON}
  if not(Player.FriendOpenWindowns.TryGetValue(Packet.WindowIndex,
    friendCharacterId)) then
    Exit;
  if not(Player.EntityFriend.getFriend(friendCharacterId, OtherPlayer, OtherServer))
  then
  begin
    Player.SendClientMessage('O jogador está offline.');
    Exit;
  end;
{$REGION 'Verifica se ajanela ja ta aberta pro outro jogador'}
  if not(Servers[OtherServer].Players[OtherPlayer].FriendOpenWindowns.ContainsValue(Player.Character.Index))
  then
  begin
    if (Servers[OtherServer].Players[OtherPlayer].FriendOpenWindowns.Count >= 6) then
      Exit;
    for I := 0 to 5 do
    begin
      if not(Servers[OtherServer].Players[OtherPlayer].FriendOpenWindowns.ContainsKey(I)) then
      begin
        OtherWinIndex := I;
        Break;
      end;
    end;
    if (OtherWinIndex = $FF) then
      Exit;
    Servers[OtherServer].Players[OtherPlayer].FriendOpenWindowns.Add(OtherWinIndex, Player.Character.Index);
    Servers[OtherServer].Players[OtherPlayer].OpenFriendWindow(Player.Character.Index, OtherWinIndex);
  end
  else
  begin
    for Key in Servers[OtherServer].Players[OtherPlayer].FriendOpenWindowns.Keys do
    begin
      if (Player.Character.Index = Servers[OtherServer].Players[OtherPlayer].FriendOpenWindowns.Items[Key])
      then
      begin
        OtherWinIndex := Key;
      end;
    end;
  end;
{$ENDREGION}
  if (OtherWinIndex = $FF) then
    Exit;
  Player.SendPacket(Packet, Packet.Header.Size);
  Packet.Header.Index := Servers[OtherServer].Players[OtherPlayer].Base.ClientId;
  Packet.WindowIndex := OtherWinIndex;
  Servers[OtherServer].Players[OtherPlayer].SendPacket(Packet, Packet.Header.Size);
{$OLDTYPELAYOUT OFF}
  Result := true;
end;
class function TPacketHandlers.CloseFriendWindow(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TCloseFriendWindowPacket absolute Buffer;
begin
  Result := False;
  if not(Player.FriendOpenWindowns.ContainsKey(Packet.WindowIndex)) then
    Exit;
  Player.FriendOpenWindowns.Remove(Packet.WindowIndex);
  Result := true;
end;
{$ENDREGION}
{$REGION 'Ver Char Info'}
class function TPacketHandlers.RequestCharInfo(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TRequestCharInfoPacket absolute Buffer;
  OtherPlayer: PPlayer;
  CharName: String;
  Id: WORD;
  i: Integer;
begin
  Result := False;
  Id := 0;
  if(Packet.Index >= 0) or (Packet.Index <= MAX_CONNECTIONS) then
  begin
    if Packet.Index <= 0 then
    begin
      CharName := String(Packet.Nick);
      if(Trim(CharName) = '') then
        Exit;

      for I := Low(Servers) to High(Servers) do
      begin
        OtherPlayer := Servers[i].GetPlayer(CharName);

        if(OtherPlayer <> nil) then
          break;
      end;

      if (OtherPlayer = nil) then
        Exit;
      if(OtherPlayer.SocketClosed) then
        Exit;
      if ((OtherPlayer.Status < Playing) or (OtherPlayer.Socket = INVALID_SOCKET)) then
        Exit;
      Id := OtherPlayer.Base.ClientId;
    end
    else
    begin
      OtherPlayer := @Servers[Player.ChannelIndex].Players[Packet.Index];

      if(OtherPlayer.SocketClosed) then
        Exit;

      if ((OtherPlayer.Status < Playing) or (OtherPlayer.Socket = INVALID_SOCKET)) then
        Exit;

      Id := OtherPlayer.Base.ClientId;
    end;
    if not(Id = 0) then
      Player.CharInfoResponse(id);
  end;
  Result := true;
end;
{$ENDREGION}
{$REGION 'Party'}
class function TPacketHandlers.SendParty(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSendPartyPacket absolute Buffer;
  OtherPlayer: PPlayer;
begin
  Result := False;
  if Player.Party <> nil then
    if Player.Party.Members.Count >= 6 then
    begin
      Player.SendClientMessage('O grupo está cheio.');
      Exit;
    end;
  if not(Packet.PlayerIndex = 0) and not(Packet.PlayerIndex > MAX_CONNECTIONS)
  then
    OtherPlayer := @Servers[Player.ChannelIndex].Players[Packet.PlayerIndex]
  else if not(Servers[Player.ChannelIndex].GetPlayerByName(string(Packet.Name),
    OtherPlayer)) then
    Exit;
  if not(OtherPlayer.Base.IsActive) then
    Exit;
  if not(OtherPlayer.PartyIndex = 0) then
  begin
    Player.SendClientMessage('O jogador já esta em um grupo.');
    Exit;
  end;
  if((Player.Base.Character.Nation <> 0) and (OtherPlayer.Base.Character.Nation <> 0)) then
  begin
    if(Player.Base.Character.Nation <> OtherPlayer.Base.Character.Nation) then
    begin
      Player.SendClientMessage('Não é possível convidar jogadores de outras nações.');
      Exit;
    end;
  end;
  Packet.Header.Index := Packet.PlayerIndex;
  Packet.PlayerIndex := Player.Base.ClientId;
  AnsiStrings.StrLCopy(Packet.Name, Player.Character.Base.Name, 16);
  OtherPlayer.PartyRequester := Player.Base.ClientId;
  OtherPlayer.SendPacket(Packet, Packet.Header.Size);
  Result := true;
end;
class function TPacketHandlers.AcceptParty(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TAcceptPartyPacket absolute Buffer;
  OtherPlayer: PPlayer;
begin
  Result := False;
  if (Player.PartyRequester = 0) then
    Exit;
  OtherPlayer := @Servers[Player.ChannelIndex].Players[Player.PartyRequester];
  if not(OtherPlayer.Base.IsActive) then
    Exit;
  case Packet.AceptType of
    BOOL_ACCEPT:
      begin
        if (OtherPlayer.PartyIndex = 0) then
        begin
          if (TParty.CreateParty(OtherPlayer.Base.ClientId, Player.ChannelIndex))
          then
          begin
            if not(OtherPlayer.AddMemberParty(Player.Base.ClientId)) then
              OtherPlayer.SendClientMessage
                ('Não foi possivel adicionar o jogador ao grupo.');
          end
          else
            OtherPlayer.SendClientMessage('Não foi possivel criar o grupo.');
        end
        else if not(OtherPlayer.Party.AddMember(Player.Base.ClientId)) then
          OtherPlayer.SendClientMessage
            ('Não foi possivel adicionar o jogador ao grupo.');

        Player.Party.RefreshParty;
      end;
    BOOL_REFUSE:
      OtherPlayer.SendClientMessage
        (AnsiString(Player.Character.Base.Name + ' recusou entrar no grupo.'));
  end;
  Result := true;
end;
class function TPacketHandlers.KickParty(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TKickPartyPacket absolute Buffer;
  I: WORD;
begin
  Result := False;

  if (Player.Party = Nil) then
    Exit;

  if (Packet.PlayerIndex > MAX_CONNECTIONS) then
    Exit;

  if (Player.Base.ClientId = Packet.PlayerIndex) then
  begin
    if (Player.Base.ClientId = Player.Party.Leader) then
    begin
      if (Player.InDungeon) then
      begin
        DungeonInstances[Player.DungeonInstanceID].InstanceOnline := False;





        DungeonInstances[Player.DungeonInstanceID].Index := 0;
        DungeonInstances[Player.DungeonInstanceID].CreateTime := Now;
        DungeonInstances[Player.DungeonInstanceID].Party := nil;
        DungeonInstances[Player.DungeonInstanceID].DungeonID := 0;
        DungeonInstances[Player.DungeonInstanceID].Dificult := 0;
        ZeroMemory(@DungeonInstances[Player.DungeonInstanceID].MOBS,
          sizeof(DungeonInstances[Player.DungeonInstanceID].MOBS));

        for I in Player.Party.Members do
        begin
          Servers[Player.ChannelIndex].Players[I].SendClientMessage
            ('O jogador [' + AnsiString(Player.Base.Character.Name) +
            '] era líder do grupo e saiu, todos foram expulsos do calabouço.');

          Servers[Player.ChannelIndex].Players[I].DungeonLobbyIndex := 0;
          Servers[Player.ChannelIndex].Players[I].DungeonLobbyDificult := 0;
          Servers[Player.ChannelIndex].Players[I].DungeonID := 0;
          Servers[Player.ChannelIndex].Players[I].DungeonIDDificult := 0;
          Servers[Player.ChannelIndex].Players[I].DungeonInstanceID := 0;
          Servers[Player.ChannelIndex].Players[I].InDungeon := False;

          if(Servers[Player.ChannelIndex].Players[I].SavedPos.IsValid) then
            Servers[Player.ChannelIndex].Players[I].Teleport(Servers[Player.ChannelIndex].Players[I].SavedPos)
          else
            Servers[Player.ChannelIndex].Players[I].Teleport(TPosition.Create(3399, 564));
        end;
      end;
    end
    else
    begin
      if (Player.InDungeon) then
      begin
          //Player.DungeonInstanceID
        DungeonInstances[Player.DungeonInstanceID].InstanceOnline := False;
        Player.DungeonLobbyIndex := 0;
        Player.DungeonLobbyDificult := 0;
        Player.DungeonID := 0;
        Player.DungeonIDDificult := 0;
        Player.DungeonInstanceID := 0;
        Player.InDungeon := False;
        if(Player.SavedPos.IsValid) then
          Player.Teleport(Player.SavedPos)
        else
          Player.Teleport(TPosition.Create(3399, 564));

        for I in Player.Party.Members do
        begin
          Servers[Player.ChannelIndex].Players[I].SendClientMessage
            ('O jogador [' + AnsiString(Player.Base.Character.Name) +
            '] saiu do grupo e foi expulso do calabouço.');
        end;
      end;
    end;

    Player.Party.RemoveMember(Packet.PlayerIndex);

    Player.Party.RefreshParty;
    Player.RefreshParty;
    Result := true;

    Exit;
  end;

  if (Player.Base.ClientId = Player.Party.Leader) then
  begin
    if (Player.InDungeon) then
    begin
      DungeonInstances[Player.DungeonInstanceID].InstanceOnline := False;

      DungeonInstances[Player.DungeonInstanceID].Index := 0;
      DungeonInstances[Player.DungeonInstanceID].CreateTime := Now;
      DungeonInstances[Player.DungeonInstanceID].Party := nil;
      DungeonInstances[Player.DungeonInstanceID].DungeonID := 0;
      DungeonInstances[Player.DungeonInstanceID].Dificult := 0;
      ZeroMemory(@DungeonInstances[Player.DungeonInstanceID].MOBS,
        sizeof(DungeonInstances[Player.DungeonInstanceID].MOBS));


      for I in Player.Party.Members do
      begin
        Servers[Player.ChannelIndex].Players[I].SendClientMessage
          ('O jogador [' + AnsiString(Player.Base.Character.Name) +
          '] era líder do grupo e saiu, todos foram expulsos do calabouço.');

        Servers[Player.ChannelIndex].Players[I].DungeonLobbyIndex := 0;
        Servers[Player.ChannelIndex].Players[I].DungeonLobbyDificult := 0;
        Servers[Player.ChannelIndex].Players[I].DungeonID := 0;
        Servers[Player.ChannelIndex].Players[I].DungeonIDDificult := 0;
        Servers[Player.ChannelIndex].Players[I].DungeonInstanceID := 0;
        Servers[Player.ChannelIndex].Players[I].InDungeon := False;

        if(Servers[Player.ChannelIndex].Players[I].SavedPos.IsValid) then
          Servers[Player.ChannelIndex].Players[I].Teleport(Servers[Player.ChannelIndex].Players[I].SavedPos)
        else
          Servers[Player.ChannelIndex].Players[I].Teleport(TPosition.Create(3399, 564));
      end;
    end;
    //ver aqui para me retirar da party
    Player.Party.RemoveMember(Packet.PlayerIndex);
    Player.Party.RefreshParty;
    Servers[Player.ChannelIndex].Players[Packet.PlayerIndex].RefreshParty;
  end
  else
  begin
    Player.SendClientMessage('Você não é o lider do grupo.');
  end;
  Result := true;
end;
class function TPacketHandlers.DestroyParty(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TDestroyPartyPacket absolute Buffer;
  I: WORD;
begin
  Result := False;
  if not(Player.Base.ClientId = Packet.PlayerIndex) then
    Exit;
  if (Player.Party = Nil) then
    Exit;
  if not(Packet.PlayerIndex = Player.Party.Leader) then
  begin
    Player.SendClientMessage('Você não é o lider do grupo.');
    Exit;
  end;
  if (Player.InDungeon) then
  begin
    DungeonInstances[Player.DungeonInstanceID].Index := 0;
    DungeonInstances[Player.DungeonInstanceID].CreateTime := Now;
    DungeonInstances[Player.DungeonInstanceID].Party := nil;
    DungeonInstances[Player.DungeonInstanceID].DungeonID := 0;
    DungeonInstances[Player.DungeonInstanceID].Dificult := 0;
    ZeroMemory(@DungeonInstances[Player.DungeonInstanceID].MOBS,
      sizeof(DungeonInstances[Player.DungeonInstanceID].MOBS));
    DungeonInstances[Player.DungeonInstanceID].InstanceOnline := False;
    for I in Player.Party.Members do
    begin
      Servers[Player.ChannelIndex].Players[I].SendClientMessage
        ('O jogador [' + AnsiString(Player.Base.Character.Name) +
        '] era líder do grupo e saiu, todos foram expulsos do calabouço.');
      Servers[Player.ChannelIndex].Players[I].DungeonLobbyIndex := 0;
      Servers[Player.ChannelIndex].Players[I].DungeonLobbyDificult := 0;
      Servers[Player.ChannelIndex].Players[I].DungeonID := 0;
      Servers[Player.ChannelIndex].Players[I].DungeonIDDificult := 0;
      Servers[Player.ChannelIndex].Players[I].DungeonInstanceID := 0;
      Servers[Player.ChannelIndex].Players[I].InDungeon := False;
      Servers[Player.ChannelIndex].Players[I].Teleport
        (TPosition.Create(3450, 690));
    end;
  end;
  Player.Party.DestroyParty(Packet.PlayerIndex);
end;
class function TPacketHandlers.GiveLeaderParty(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TGiveLeaderPartyPacket absolute Buffer;
begin
  Result := False; //ver como se encaixa se eu for o lider raid
  if (Player.Party = Nil) then
    Exit;
  if (Packet.PlayerIndex > MAX_CONNECTIONS) then
    Exit;
  if (Player.Party.Leader <> Player.Base.ClientId) then
    Exit;
  if not(Player.Party.Members.Contains(Packet.PlayerIndex)) then
    Exit;
  Player.Party.Leader := Packet.PlayerIndex;
  Player.Party.RefreshParty;
  Result := true;
end;
class function TPacketHandlers.UpdateMemberPosition(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TPartyMemberPositionPacket absolute Buffer;
  Party: PParty;
  OtherPlayer: PPlayer;
begin
  Result := False;   //ver como ficam as raids aqui
  if (Player.PartyIndex = 0) then
    Exit;
  Party := @Servers[Player.ChannelIndex].Parties[Player.PartyIndex];
  if not(Party.Members.Contains(Packet.PlayerIndex)) then
    Exit;
  if (Packet.PlayerIndex = Player.Base.ClientId) then
  begin
    Exit;
  end;
  OtherPlayer := @Servers[Player.ChannelIndex].Players[Packet.PlayerIndex];
  OtherPlayer.SendPositionParty(Player.Base.ClientId);
  Result := true;
end;
class function TPacketHandlers.AddSelfParty(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
begin
  if (Player.PartyIndex = 0) then
  begin
    if (TParty.CreateParty(Player.Base.ClientId, Player.ChannelIndex)) then
    begin
      Player.RefreshParty;
    end
    else
      Player.SendClientMessage('Não foi possével criar o grupo.');
  end
  else
  begin
    Player.SendClientMessage('Você ja está em um grupo.');
  end;
  Result := true;
end;
class function TPacketHandlers.PartyAlocateConfig(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TUpdatePartyAlocate absolute Buffer;
  I: WORD;
  // RefreshMessage, RefreshMessage2: String;
begin
  Result := False;
  if (Player.PartyIndex = 0) then
    Exit;
  if not(Player.Party.Leader = Player.Base.ClientId) then
  begin
    Player.SendClientMessage('Voccê não é o lider do grupo.');
    Exit;
  end;
  if ((Player.Party.InRaid) and not(Player.Party.IsRaidLeader)) then
  begin
    Player.SendClientMessage('Voccê não é o lider da raid.');
    Exit;
  end;
  Player.Party.ExpAlocate := Packet.ExpAlocate;
  Player.Party.ItemAlocate := (Packet.ItemAlocate);
  if not(Player.Party.InRaid) then
    Player.Party.RefreshParty
  else
  begin
    for I := 1 to 3 do
    begin
      if(Player.Party.PartyAllied[i] = 0) then
        Continue;
      Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[i]].ExpAlocate :=
       Player.Party.ExpAlocate;
      Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[i]].ItemAlocate :=
       Player.Party.ItemAlocate;
    end;
    Player.Party.RefreshRaid;
  end;
  { case Packet.ExpAlocate of
    1:
    begin
    RefreshMessage := 'A exp será IGUALMENTE distribuida.';
    end;
    2:
    begin
    RefreshMessage := 'A exp será INDIVIDUALMENTE distribuida.';
    end;
    else
    Exit;
    end;
    case Packet.ItemAlocate of
    1:
    begin
    RefreshMessage2 := 'Os itens serão distribuidos em ORDEM.';
    end;
    2:
    begin
    RefreshMessage2 := 'Os itens serão distribuidos ALEATORIAMENTE.';
    end;
    3:
    begin
    RefreshMessage2 := 'Os itens serão distribuidos INDIVIDUALMENTE.';
    end;
    4:
    begin
    RefreshMessage2 := 'Os itens serão distribuidos apenas para o LIDER.';
    end;
    else
    Exit;
    end; }
  Result := true;
end;
{$ENDREGION}
{$REGION 'Raids'}
class function TPacketHandlers.SendRaid(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSendInviteToRaid absolute Buffer;
  OtherPlayer: PPlayer;
begin
  if(Packet.SendTo = 0) or (Packet.SendTo > MAX_CONNECTIONS) then
    Exit;
  if(Player.PartyIndex = 0) then
    Exit;
  OtherPlayer := @Servers[Player.ChannelIndex].Players[Packet.SendTo];
  if(OtherPlayer.Status < Playing) then
  begin
    Player.SendClientMessage('O alvo não está disponível.');
    Exit;
  end;
  if(OtherPlayer.Base.PlayerCharacter.LastPos.Distance(
    Player.Base.PlayerCharacter.LastPos) > 20) then
  begin
    Player.SendClientMessage('O alvo está muito longe.');
    Exit;
  end;
  if(OtherPlayer.PartyIndex = 0) then
  begin
    Player.SendClientMessage('O alvo não está em grupo.');
    Exit;
  end;
  if(OtherPlayer.Party.Leader <> OtherPlayer.Base.ClientID) then
  begin
    Player.SendClientMessage('O alvo não é lider do outro grupo.');
    Exit;
  end;
  if(OtherPlayer.Party.InRaid) then
  begin
    Player.SendClientMessage('O alvo já está em uma legião.');
    Exit;
  end;
  if(Player.Party.Leader <> Player.Base.ClientID) then
  begin
    Player.SendClientMessage('Você não é lider do seu grupo.');
    Exit;
  end;
  if not(Player.Party.IsRaidLeader) then
  begin
    Player.SendClientMessage('Seu grupo não pode convidar outros grupos. Peça ao lider da legião.');
    Exit;
  end;
  if(Player.Party.PartyRaidCount >= 4) then
  begin
    Player.SendClientMessage('Sua legião já está completa, com 4 grupos.');
    Exit;
  end;
  if((Player.Base.Character.Nation <> 0) and (OtherPlayer.Base.Character.Nation <> 0)) then
  begin
    if(Player.Base.Character.Nation <> OtherPlayer.Base.Character.Nation) then
    begin
      Player.SendClientMessage('Não é possível convidar jogadores de outras nações para a raid.');
      Exit;
    end;
  end;
  Packet.Header.Index := Packet.SendTo;
  Packet.SendTo := Player.Base.ClientId;
  OtherPlayer.RaidRequester := Player.Base.ClientId;
  OtherPlayer.SendPacket(Packet, Packet.Header.Size);
  Result := True;
end;
class function TPacketHandlers.AcceptRaid(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TInviteToRaidResponse absolute Buffer;
  OtherPlayer, AnotherPlayer: PPlayer;
  Guild, OtherGuild, OtherGuild2, OtherGuild3: PGuild;
  i: Integer;
  SelfNationID, EmptySlot: Integer;
  newGrade: Boolean;
begin

  if(Player.AliianceByLegion) then
  begin
    Guild := nil;
    OtherGuild := nil;
    OtherGuild2 := nil;
    OtherGuild3 := nil;
    Player.AliianceByLegion := False;
    newGrade := False;
    if(Player.AllianceRequester = 0) then
      Exit;
    OtherPlayer := @Servers[Player.ChannelIndex].Players[Player.AllianceRequester];
    if(Player.Status < Playing) then
      Exit;
    case Packet.Accept of
       BOOL_ACCEPT:
       begin
         EmptySlot := 255;
         Guild := @Guilds[Player.Character.GuildSlot];
         OtherGuild := @Guilds[OtherPlayer.Character.GuildSlot];

         for I := 1 to 3 do
         begin
           if(OtherGuild.Ally.Guilds[i].Index = 0) then
           begin
             EmptySlot := i;
             break;
           end;
         end;

         OtherGuild.Ally.Guilds[EmptySlot].Index := Guild.Index;
         System.AnsiStrings.StrPLCopy(OtherGuild.Ally.Guilds[EmptySlot].Name,
          String(Guild.Name), 18);

         case EmptySlot of
            1:
              begin
                if(OtherGuild.Ally.Guilds[2].Index <> 0) then
                begin
                  OtherGuild2 := @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID(OtherGuild.Ally.Guilds[2].Index)];
                end;

                if(OtherGuild.Ally.Guilds[3].Index <> 0) then
                begin
                  OtherGuild3 := @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID(OtherGuild.Ally.Guilds[3].Index)];
                end;
              end;
            2:
              begin
                if(OtherGuild.Ally.Guilds[1].Index <> 0) then
                begin
                  OtherGuild2 := @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID(OtherGuild.Ally.Guilds[1].Index)];
                end;

                if(OtherGuild.Ally.Guilds[3].Index <> 0) then
                begin
                  OtherGuild3 := @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID(OtherGuild.Ally.Guilds[3].Index)];
                end;
              end;
            3:
              begin
                if(OtherGuild.Ally.Guilds[1].Index <> 0) then
                begin
                  OtherGuild2 := @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID(OtherGuild.Ally.Guilds[1].Index)];
                end;

                if(OtherGuild.Ally.Guilds[2].Index <> 0) then
                begin
                  OtherGuild3 := @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID(OtherGuild.Ally.Guilds[2].Index)];
                end;
              end;
          end;

         if(Guild <> nil) then
         begin
           Move(OtherGuild.Ally, Guild.Ally, sizeof(TGuildAlly));
         end;

         if(OtherGuild2 <> nil) then
         begin
           Move(OtherGuild.Ally, OtherGuild2.Ally, sizeof(TGuildAlly));
         end;

         if(OtherGuild3 <> nil) then
         begin
           Move(OtherGuild.Ally, OtherGuild3.Ally, sizeof(TGuildAlly));
         end;

         if(OtherPlayer.IsMarshal) then
         begin
           SelfNationID := OtherPlayer.Character.Base.Nation - 1;
           if(Nations[SelfNationID].TacticianGuildID = 0) then
           begin
             Nations[SelfNationID].TacticianGuildID := Guild.Index;
             System.AnsiStrings.StrPlCopy(Nations[SelfNationID].Cerco.Defensoras.Estrategista,
              String(Guild.Name), sizeof(String(Guild.Name)));
           end
           else if(Nations[SelfNationID].JudgeGuildID = 0) then
           begin
             Nations[SelfNationID].JudgeGuildID := Guild.Index;
             System.AnsiStrings.StrPlCopy(Nations[SelfNationID].Cerco.Defensoras.Juiz,
              String(Guild.Name), sizeof(String(Guild.Name)));
           end
           else if(Nations[SelfNationID].TreasurerGuildID = 0) then
           begin
             Nations[SelfNationID].TreasurerGuildID := Guild.Index;
             System.AnsiStrings.StrPlCopy(Nations[SelfNationID].Cerco.Defensoras.Tesoureiro,
              String(Guild.Name), sizeof(String(Guild.Name)));
           end;
           Nations[SelfNationID].SaveNation;
           newGrade := True;
         end;
         for I := 0 to 127 do
         begin
           //talvez tenha que fazer para todos os servidores
           if(Guild <> nil) then
           begin
             if(Guild.Members[i].Logged) then
             begin
               if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(Guild.Members[i].CharIndex, AnotherPlayer)) then
               begin
                 AnotherPlayer.SendGuildInfo;
                 AnotherPlayer.SendClientMessage('Sua aliança teve mudanças.');
                 if(newGrade) then
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
             end;

             //TFunctions.SaveGuilds(Guild.Slot);
           end;
           if(OtherGuild <> nil) then
           begin
             if(OtherGuild.Members[i].Logged) then
             begin
               if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(OtherGuild.Members[i].CharIndex, AnotherPlayer)) then
               begin
                 AnotherPlayer.SendGuildInfo;
                 AnotherPlayer.SendClientMessage('Sua aliança teve mudanças.');
                 if(newGrade) then
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
             end;

             //TFunctions.SaveGuilds(OtherGuild.Slot);
           end;

           if(OtherGuild2 <> nil) then
           begin
             if(OtherGuild2.Members[i].Logged) then
             begin
               if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(OtherGuild2.Members[i].CharIndex, AnotherPlayer)) then
               begin
                 AnotherPlayer.SendGuildInfo;
                 AnotherPlayer.SendClientMessage('Sua aliança teve mudanças.');

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
                 AnotherPlayer.SendClientMessage('Sua aliança teve mudanças.');

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

         if(Guild <> nil) then
          begin
            TFunctions.SaveGuilds(Guild.Slot);
          end;
          if(OtherGuild <> nil) then
          begin
            TFunctions.SaveGuilds(OtherGuild.Slot);
          end;
          if(OtherGuild2 <> nil) then
          begin
            TFunctions.SaveGuilds(OtherGuild2.Slot);
          end;
          if(OtherGuild3 <> nil) then
          begin
            TFunctions.SaveGuilds(OtherGuild3.Slot);
          end;
         //Player.SendGuildInfo;
       end;
       BOOL_REFUSE:
       begin
         OtherPlayer.SendClientMessage('O lider da guild escolhida recusou-se a entrar na aliança.');
       end;
    end;
  end
  else
  begin
    if(Player.RaidRequester = 0) then
      Exit;
    OtherPlayer := @Servers[Player.ChannelIndex].Players[Player.RaidRequester];
    if(OtherPlayer.Status < Playing) then
      Exit;
    case Packet.Accept of
      BOOL_ACCEPT:
        begin
          if not(OtherPlayer.Party.InRaid) then
          begin
            if not(TParty.CreateRaid(Player.RaidRequester, Player.Base.ClientID,
              Player.ChannelIndex)) then
            begin
              OtherPlayer.SendClientMessage('Não foi possível criar a raid.');
            end
            else
              OtherPlayer.Party.RefreshParty;
          end
          else
          begin
            if not(TParty.AddPartyToRaid(Player.RaidRequester, Player.Base.ClientID,
              Player.ChannelIndex)) then
            begin
              OtherPlayer.SendClientMessage('Não foi possível adicionar o grupo na raid.');
            end
            else
              OtherPlayer.Party.RefreshParty;
          end;
        end;
      BOOL_REFUSE:
        OtherPlayer.SendClientMessage
          (AnsiString(Player.Character.Base.Name + ' recusou entrar na legião.'));
    end;
    Result := true;
  end;
end;
class function TPacketHandlers.ExitRaid(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  i, j, k: Byte;
  NewPartyID: WORD;
begin
  if(Player.Base.PartyId = 0) then
  begin
    Exit;
  end;
  if(Player.Party.InRaid = False) then
  begin
    Exit;
  end;
  if(Player.Party.IsRaidLeader) then
  begin //transferir o lider da raid para outro grupo
    j := 0;
    for I := 1 to 3 do
    begin
      if(Player.Party.PartyAllied[i] = 0) then
        Continue;
      if(j = 0) then
      begin
        NewPartyID := Player.Party.PartyAllied[i];
        Servers[Player.ChannelIndex].Parties[NewPartyID].IsRaidLeader := True;
        inc(j);
      end;
      Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[i]].PartyRaidCount :=
        Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[i]].PartyRaidCount -1;
      for k := 1 to 3 do
      begin
        if(Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[i]].PartyAllied[k] = 0) then
          Continue;
        if(Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[i]].PartyAllied[k] = Player.Party.Index) then
        begin
          Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[i]].PartyAllied[k] := 0;
          break;
        end;
      end;
    end;
    Servers[Player.ChannelIndex].Parties[NewPartyID].RefreshRaid;
    ZeroMemory(@Player.Party.PartyAllied[i], sizeof(Player.Party.PartyAllied[i]));
    Player.Party.InRaid := False;
    Player.Party.PartyRaidCount := 0;
    Player.Party.RaidPartyId := 0;
    Player.Party.RefreshParty;
  end
  else //apenas sair e atualizar pro restante
  begin
    j := 0;
    for I := 1 to 3 do
    begin
      if(Player.Party.PartyAllied[i] = 0) then
        Continue;
      if(j = 0) then
      begin
        NewPartyID := Player.Party.PartyAllied[i];
        inc(j);
      end;
      Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[i]].PartyRaidCount :=
        Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[i]].PartyRaidCount -1;
      for k := 1 to 3 do
      begin
        if(Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[i]].PartyAllied[k] = 0) then
          Continue;
        if(Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[i]].PartyAllied[k] = Player.Party.Index) then
        begin
          Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[i]].PartyAllied[k] := 0;
          break;
        end;
      end;
    end;
    Servers[Player.ChannelIndex].Parties[NewPartyID].RefreshRaid;
    ZeroMemory(@Player.Party.PartyAllied[i], sizeof(Player.Party.PartyAllied[i]));
    Player.Party.InRaid := False;
    Player.Party.PartyRaidCount := 0;
    Player.Party.RaidPartyId := 0;
    Player.Party.RefreshParty;
  end;
end;
class function TPacketHandlers.DestroyRaid(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
begin
end;
class function TPacketHandlers.GiveLeaderRaid(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TGiveRaidLeader absolute Buffer;
  OtherPlayer: PPlayer;
  cnt, i: Integer;
begin
  if(Player.PartyIndex = 0) then
  begin
    Exit;
  end;
  if(Packet.GiveTo = 0) then
    Exit;
  if(Player.Party.InRaid = False) then
  begin
    Player.SendClientMessage('Você não está em raid.');
    Exit;
  end;
  if not((Player.Party.Leader = Player.Base.ClientID) and (Player.Party.IsRaidLeader)) then
  begin
    Player.SendClientMessage('Você não é o lider da raid.');
    Exit;
  end;
  OtherPlayer := nil;
  OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(Packet.GiveTo);
  if(OtherPlayer = nil) then
  begin
    Player.SendClientMessage('O alvo não está disponível.');
    Exit;
  end;
  if(OtherPlayer.PartyIndex = 0) then
  begin
    Player.SendClientMessage('Alvo não está em grupo.');
    Exit;
  end;
  cnt := 0;
  for I := 1 to 3 do
  begin
    if(Player.Party.PartyAllied[i] = OtherPlayer.Party.Index) then
    begin
      cnt := i;
      break;
    end;
  end;
  if(cnt = 0) then
  begin
    Player.SendClientMessage('O alvo está em um grupo que não pertence a sua raid.');
    Exit;
  end;
  if not(OtherPlayer.Party.Index = OtherPlayer.Base.ClientID) then
  begin
    Player.SendClientMessage('O alvo não é o lider do grupo.');
    Exit;
  end;
  Player.Party.IsRaidLeader := False;
  OtherPlayer.Party.IsRaidLeader := True;
  Player.Party.RefreshRaid;
  Result := True;
end;
class function TPacketHandlers.RemoveFromRaid(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
begin
end;
{$ENDREGION}

{$REGION 'PersonalShop'}
class function TPacketHandlers.CreatePersonalShop(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TPersonalShopPacket absolute Buffer;
  i, j: Integer;
  breakis: boolean;
begin
  Result := False;
  if (Player.Base.ClientId <> Packet.Shop.Index) then
    Exit;
  if (Packet.Shop.Name <= '') then
    Exit;

  breakis := False;
  for I := 0 to 9 do
  begin
    if(Packet.Shop.Products[i].Slot = $ffff) then
      Continue;

    if(ItemList[Player.Base.Character.Inventory
      [Packet.Shop.Products[i].Slot].Index].TypeTrade > 0) then
      Packet.Shop.Products[i].Slot := $ffff;

    for j := 0 to 9 do
      begin
        if(i = j) then
          Continue;

        if(Packet.Shop.Products[j].Slot = $ffff) then
          Continue;

        if(Packet.Shop.Products[i].Slot =
          Packet.Shop.Products[j].Slot) then
        begin
          breakis := True;

          Player.ClosePersonalShop;
          Player.SendClientMessage('Você não pode vender o mesmo item várias vezes.');
          break;
        end;
      end;

    if(breakis) then
      break;
  end;

  if(breakis) then
    Exit;

  Move(Packet.Shop, Player.Base.PersonalShop, sizeof(Packet.Shop));
  Player.Base.SendCreateMob;
  Player.SendPersonalShop(Player.Base.PersonalShop);
end;
class function TPacketHandlers.OpenPersonalShop(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TSignalData absolute Buffer;
  BufferNil: ARRAY [0 .. sizeof(TPersonalShopData) - 1] OF BYTE;
begin
  Result := False;
  if (Packet.Header.Index = Packet.Data) then
    Exit;
  ZeroMemory(@BufferNil, sizeof(BufferNil));
  if (CompareMem(@Servers[Player.ChannelIndex].Players[Packet.Data]
    .Base.PersonalShop, @BufferNil, sizeof(BufferNil))) then
    Exit;
  Player.SendPersonalShop(Servers[Player.ChannelIndex].Players[Packet.Data]
    .Base.PersonalShop);
  Player.Base.PersonalShopIndex := Packet.Data;
  Result := true;
end;
class function TPacketHandlers.BuyPersonalShopItem(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TBuyPersonalShopItemPacket absolute Buffer;
  OtherPlayer: PPlayer;
begin
  Result := False;
  if (Packet.Header.Index = Packet.Index) then
    Exit;
  if (Player.Base.PersonalShopIndex = 0) or
    (Player.Base.PersonalShopIndex <> Packet.Index) then
    Exit;

  if(TItemFunctions.GetEmptySlot(Player) = 255) then
  begin
    Player.SendClientMessage('Inventário cheio.');
    Exit;
  end;

  OtherPlayer := @Servers[Player.ChannelIndex].Players[Packet.Index];
  if CompareMem(@Packet.Product, @OtherPlayer.Base.PersonalShop.Products
    [Packet.Slot], sizeof(Packet.Product)) then
  begin
    if Packet.Product.Price > Player.Base.Character.Gold then
    begin
      Player.SendClientMessage('Gold insuficiente.');
      Exit;
    end;
    Player.DecGold(Packet.Product.Price);
    TItemFunctions.PutItem(Player, OtherPlayer.Character.Base.Inventory
      [Packet.Product.Slot]);
    OtherPlayer.AddGold(Packet.Product.Price);
    ZeroMemory(@OtherPlayer.Character.Base.Inventory[Packet.Product.Slot],
      sizeof(TItem));
    OtherPlayer.Base.SendRefreshItemSlot(Packet.Product.Slot, False);
    ZeroMemory(@OtherPlayer.Base.PersonalShop.Products[Packet.Slot],
      sizeof(TPersonalShopItem));
    Player.SendClientMessage('Item comprado com sucesso.');
    Player.SendPersonalShop(OtherPlayer.Base.PersonalShop);
    OtherPlayer.SendPersonalShop(OtherPlayer.Base.PersonalShop);
    Exit;
  end;
  Player.SendClientMessage('Item inválido.');
end;
class function TPacketHandlers.ClosePersonalShop(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TSignalData absolute Buffer;
begin
  Result := False;
  if not(Player.Base.PersonalShopIndex = 0) then
  begin
    Player.Base.PersonalShopIndex := 0;
    Exit;
  end;
  Player.SendData(Packet.Header.Index, Packet.Header.Code, 0);
  if (Packet.Header.Index = Player.Base.PersonalShop.Index) then
  begin
    ZeroMemory(@Player.Base.PersonalShop, sizeof(TPersonalShopData));
    Player.Base.SendCreateMob;
    Player.Base.SendStatus;
  end;
  Result := true;
end;
{$ENDREGION}
{$REGION 'Change Channel'}
class function TPacketHandlers.ChangeChannel(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TChangeChannelPacket absolute Buffer;
  ChangeChannelToken: TChangeChannelToken;
  ChangeTokenIndParty: TChangeChannelToken;
  i, j, k: Integer;
  OtherChannelid: Byte;
begin
  Result := False;

  OtherChannelid := Packet.Info1;
  if not(Assigned(Servers[OtherChannelid])) then
  begin
    Player.SendClientMessage('Canal destino não válido. ERR_1.');
    Exit;
  end;
  if not(Servers[OtherChannelid].IsActive) then
  begin
    Player.SendClientMessage('Canal destino não válido. ERR_2.');
    Exit;
  end;
  if(Player.ChannelIndex = OtherChannelid) then
  begin
    Player.SendClientMessage('Canal destino não válido. ERR_3.');
    Exit;
  end;
  ZeroMemory(@ChangeChannelToken, sizeof(TChangeChannelToken));
  ChangeChannelToken.CharSlot := Player.SelectedCharacterIndex;
  ChangeChannelToken.ChangeTime := Now;
  ChangeChannelToken.OldChannelID := Player.ChannelIndex;
  ChangeChannelToken.OldClientID := Player.Base.ClientID;
  ChangeChannelToken.PartyTeleport.ChannelId := OtherChannelid;

  ChangeChannelToken.accFromOther := Player.Account;
  ChangeChannelToken.charFromOther := Player.Character;
  ChangeChannelToken.buffFromOther := Player.Base.PlayerCharacter.Buffs;
  if(Player.PartyIndex <> 0) then
  begin
    if(Player.Party.Leader = Player.Base.ClientID) then
    begin
      if(Player.Party.PartyRaidCount > 1) then
      begin
        if not(Player.Party.IsRaidLeader) then
        begin //telar apenas minha party
          //for i := 1 to Length(Servers[OtherChannelid].Parties) do
          //begin
            //if (Servers[OtherChannelid].Parties[i].Members.Count = 0) then
            //begin //achei uma party vazia no canal destino
              ChangeChannelToken.PartyTeleport.RequestId := Player.Party.RequestId;
              ChangeChannelToken.PartyTeleport.ExpAlocate := Player.Party.ExpAlocate;
              ChangeChannelToken.PartyTeleport.ItemAlocate := Player.Party.ItemAlocate;
              ChangeChannelToken.PartyTeleport.LastSlotItemReceived := Player.Party.LastSlotItemReceived;
              ChangeChannelToken.PartyTeleport.InRaid := False;
              ChangeChannelToken.PartyTeleport.IsRaidLeader := True;
              ChangeChannelToken.PartyTeleport.PartyRaidCount := Player.Party.PartyRaidCount;
              ChangeChannelToken.PartyTeleport.MemberName := TList<Integer>.Create;
              ChangeChannelToken.AccountStatus := 0;
              if(Player.CheckGameMasterLogged) then
              begin
                ChangeChannelToken.AccountStatus := 1;
              end;
              if(Player.CheckAdminLogged) then
              begin
                ChangeChannelToken.AccountStatus := 2;
              end;

              for j in Player.Party.Members do
              begin
                if not(Servers[Player.ChannelIndex].Players[j].Base.PlayerCharacter.LastPos.InRange(
                  Player.Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)) then
                begin
                  Player.Party.RemoveMember(j);
                  Continue;
                end;
                if not(j = Player.Party.Leader) then
                begin
                  Packet.TypeChanel := OtherChannelid;
                  Packet.Info1 := Servers[Player.ChannelIndex].Players[j].Account.Header.AccountId;
                  Packet.Header.Index := j;
                  Servers[Player.ChannelIndex].Players[j].SendPacket(Packet, Packet.Header.Size);
                  Servers[Player.ChannelIndex].Players[j].SocketClosed := True;
                end;
              end;
              for j in Player.Party.Members do
              begin
                if not(ChangeChannelToken.PartyTeleport.MemberName.Contains(Servers[Player.ChannelIndex].Players[j].Base.Character.CharIndex)) then
                  ChangeChannelToken.PartyTeleport.MemberName.Add(Servers[Player.ChannelIndex].Players[j].Base.Character.CharIndex);
                Servers[Player.ChannelIndex].Players[j].DesconectedByOtherChannel := True;
                if not(j = Player.Party.Leader) then
                begin //mandar informação de telar pros outros
                  Randomize;
                  Servers[Player.ChannelIndex].Players[j].Base.PlayerCharacter.LastPos :=
                    Player.Base.Neighbors[RandomRange(0,8)].pos;
                  ZeroMemory(@ChangeTokenIndParty, sizeof(TChangeChannelToken));
                  ChangeTokenIndParty.CharSlot := Servers[Player.ChannelIndex].Players[j].SelectedCharacterIndex;
                  ChangeTokenIndParty.ChangeTime := Now;
                  ChangeTokenIndParty.OldClientID := Servers[Player.ChannelIndex].Players[j].Base.ClientID;
                  ChangeTokenIndParty.OldChannelID := Player.ChannelIndex;
                  ChangeTokenIndParty.AccountStatus := 0;
                  ChangeTokenIndParty.accFromOther := Servers[Player.ChannelIndex].Players[j].Account;
                  ChangeTokenIndParty.charFromOther := Servers[Player.ChannelIndex].Players[j].Character;
                  ChangeTokenIndParty.buffFromOther :=
                    Servers[Player.ChannelIndex].Players[j].Base.PlayerCharacter.Buffs;
                  if(Servers[Player.ChannelIndex].Players[j].CheckGameMasterLogged) then
                  begin
                    ChangeTokenIndParty.AccountStatus := 1;
                  end;
                  if(Servers[Player.ChannelIndex].Players[j].CheckAdminLogged) then
                  begin
                    ChangeTokenIndParty.AccountStatus := 2;
                  end;
                  if not(ChangeChannelList.ContainsKey(Servers[Player.ChannelIndex].Players[j].Account.Header.AccountId)) then
                  begin
                    ChangeChannelList.Add(Servers[Player.ChannelIndex].Players[j].Account.Header.AccountId, ChangeTokenIndParty);
                  end;

                  //Servers[Player.ChannelIndex].Players[j].SocketClosed := True;
                end;
              end;
              //Break;
            //end;
          //end;
        end
        else
        begin //telar a raid inteira
          //telar minha party primeiro
          //for i := 1 to Length(Servers[OtherChannelid].Parties) do
          //begin
            //if (Servers[OtherChannelid].Parties[i].Members.Count = 0) then
            //begin //achei uma party vazia no canal destino
              ChangeChannelToken.PartiesTeleport[0].RequestId := Player.Party.RequestId;
              ChangeChannelToken.PartiesTeleport[0].ExpAlocate := Player.Party.ExpAlocate;
              ChangeChannelToken.PartiesTeleport[0].ItemAlocate := Player.Party.ItemAlocate;
              ChangeChannelToken.PartiesTeleport[0].LastSlotItemReceived := Player.Party.LastSlotItemReceived;
              ChangeChannelToken.PartiesTeleport[0].InRaid := True;
              ChangeChannelToken.PartiesTeleport[0].IsRaidLeader := True;
              ChangeChannelToken.PartiesTeleport[0].PartyRaidCount := Player.Party.PartyRaidCount;
              ChangeChannelToken.PartiesLeader[0] := Player.Base.Character.CharIndex;
              ChangeChannelToken.PartiesTeleport[0].MemberName := TList<Integer>.Create;
              ChangeChannelToken.AccountStatus := 0;
              if(Player.CheckGameMasterLogged) then
              begin
                ChangeChannelToken.AccountStatus := 1;
              end;
              if(Player.CheckAdminLogged) then
              begin
                ChangeChannelToken.AccountStatus := 2;
              end;
              for j in Player.Party.Members do
              begin
                if not(Servers[Player.ChannelIndex].Players[j].Base.PlayerCharacter.LastPos.InRange(
                  Player.Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)) then
                begin
                  Player.Party.RemoveMember(j);
                  Continue;
                end;
                if not(j = Player.Party.Leader) then
                begin
                  Packet.TypeChanel := OtherChannelid;
                  Packet.Info1 := Servers[Player.ChannelIndex].Players[j].Account.Header.AccountId;
                  Packet.Header.Index := j;
                  Servers[Player.ChannelIndex].Players[j].SendPacket(Packet, Packet.Header.Size);
                  //Servers[Player.ChannelIndex].Disconnect(
                    //Servers[Player.ChannelIndex].Players[j]);
                  Servers[Player.ChannelIndex].Players[j].SocketClosed := True;
                end;
              end;
              for j in Player.Party.Members do
              begin
                if not(ChangeChannelToken.PartiesTeleport[0].MemberName.Contains(Servers[Player.ChannelIndex].Players[j].Base.Character.CharIndex)) then
                  ChangeChannelToken.PartiesTeleport[0].MemberName.Add(Servers[Player.ChannelIndex].Players[j].Base.Character.CharIndex);
                Servers[Player.ChannelIndex].Players[j].DesconectedByOtherChannel := True;
                if not(j = Player.Party.Leader) then
                begin //mandar informação de telar pros outros
                  Randomize;
                  Servers[Player.ChannelIndex].Players[j].Base.PlayerCharacter.LastPos :=
                    Player.Base.Neighbors[RandomRange(0,8)].pos;
                  ZeroMemory(@ChangeTokenIndParty, sizeof(TChangeChannelToken));
                  ChangeTokenIndParty.CharSlot := Servers[Player.ChannelIndex].Players[j].SelectedCharacterIndex;
                  ChangeTokenIndParty.ChangeTime := Now;
                  ChangeTokenIndParty.AccountStatus := 0;
                  ChangeTokenIndParty.OldClientID := Servers[Player.ChannelIndex].Players[j].Base.ClientID;
                  ChangeTokenIndParty.OldChannelID := Player.ChannelIndex;
                  ChangeTokenIndParty.accFromOther := Servers[Player.ChannelIndex].Players[j].Account;
                  ChangeTokenIndParty.charFromOther := Servers[Player.ChannelIndex].Players[j].Character;
                  ChangeTokenIndParty.buffFromOther :=
                    Servers[Player.ChannelIndex].Players[j].Base.PlayerCharacter.Buffs;
                  if(Servers[Player.ChannelIndex].Players[j].CheckGameMasterLogged) then
                  begin
                    ChangeTokenIndParty.AccountStatus := 1;
                  end;
                  if(Servers[Player.ChannelIndex].Players[j].CheckAdminLogged) then
                  begin
                    ChangeTokenIndParty.AccountStatus := 2;
                  end;
                  if not(ChangeChannelList.ContainsKey(Servers[Player.ChannelIndex].Players[j].Account.Header.AccountId)) then
                  begin
                    ChangeChannelList.Add(Servers[Player.ChannelIndex].Players[j].Account.Header.AccountId, ChangeTokenIndParty);
                  end;
                  //Packet.TypeChanel := OtherChannelid;
                  ///Packet.Info1 := Servers[Player.ChannelIndex].Players[j].Account.Header.AccountId;
                  //Packet.Header.Index := j;
                  //Servers[Player.ChannelIndex].Players[j].SendPacket(Packet, Packet.Header.Size);
                  //Servers[Player.ChannelIndex].Players[j].SocketClosed := True;
                end;
              end;
             // Break;
            //end;
          //end;
          //depois telar as outras 3 pts
          for k := 1 to 3 do
          begin
            if(Player.Party.PartyAllied[k] = 0) then
              Continue;
            //for i := 1 to Length(Servers[OtherChannelid].Parties) do
            //begin
              //if (Servers[OtherChannelid].Parties[i].Members.Count = 0) then
              //begin //achei uma party vazia no canal destino
                ChangeChannelToken.PartiesTeleport[k].RequestId := Player.Party.RequestId;
                ChangeChannelToken.PartiesTeleport[k].ExpAlocate := Player.Party.ExpAlocate;
                ChangeChannelToken.PartiesTeleport[k].ItemAlocate := Player.Party.ItemAlocate;
                ChangeChannelToken.PartiesTeleport[k].LastSlotItemReceived := Player.Party.LastSlotItemReceived;
                ChangeChannelToken.PartiesTeleport[k].InRaid := True;
                ChangeChannelToken.PartiesTeleport[k].IsRaidLeader := False;
                ChangeChannelToken.PartiesTeleport[k].PartyRaidCount := Player.Party.PartyRaidCount;
                ChangeChannelToken.PartiesTeleport[k].MemberName := TList<Integer>.Create;
                for j in Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[k]].Members do
                begin
                  if not(Servers[Player.ChannelIndex].Players[j].Base.PlayerCharacter.LastPos.InRange(
                    Player.Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)) then
                  begin
                    Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[k]].RemoveMember(j);
                    continue;
                  end;

                  Packet.TypeChanel := OtherChannelid;
                  Packet.Info1 := Servers[Player.ChannelIndex].Players[j].Account.Header.AccountId;
                  Packet.Header.Index := j;
                  Servers[Player.ChannelIndex].Players[j].SendPacket(Packet, Packet.Header.Size);
                  //Servers[Player.ChannelIndex].Disconnect(
                    //Servers[Player.ChannelIndex].Players[j]);
                  Servers[Player.ChannelIndex].Players[j].SocketClosed := True;
                end;
                for j in Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[k]].Members do
                begin
                  if not(ChangeChannelToken.PartiesTeleport[k].MemberName.Contains(Servers[Player.ChannelIndex].Players[j].Base.Character.CharIndex)) then
                    ChangeChannelToken.PartiesTeleport[k].MemberName.Add(Servers[Player.ChannelIndex].Players[j].Base.Character.CharIndex);
                  ZeroMemory(@ChangeTokenIndParty, sizeof(TChangeChannelToken));
                  ChangeTokenIndParty.CharSlot := Servers[Player.ChannelIndex].Players[j].SelectedCharacterIndex;
                  ChangeTokenIndParty.ChangeTime := Now;
                  ChangeTokenIndParty.AccountStatus := 0;
                  ChangeTokenIndParty.OldClientID := Servers[Player.ChannelIndex].Players[j].Base.ClientID;
                  ChangeTokenIndParty.OldChannelID := Player.ChannelIndex;
                  ChangeTokenIndParty.accFromOther := Servers[Player.ChannelIndex].Players[j].Account;
                  ChangeTokenIndParty.charFromOther := Servers[Player.ChannelIndex].Players[j].Character;
                  ChangeTokenIndParty.buffFromOther :=
                    Servers[Player.ChannelIndex].Players[j].Base.PlayerCharacter.Buffs;
                  if(Servers[Player.ChannelIndex].Players[j].CheckGameMasterLogged) then
                  begin
                    ChangeTokenIndParty.AccountStatus := 1;
                  end;
                  if(Servers[Player.ChannelIndex].Players[j].CheckAdminLogged) then
                  begin
                    ChangeTokenIndParty.AccountStatus := 2;
                  end;
                  Servers[Player.ChannelIndex].Players[j].DesconectedByOtherChannel := True;
                  if(j = Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[k]].Leader) then
                  begin
                    ChangeChannelToken.PartiesLeader[k] := Servers[Player.ChannelIndex].Players[j].Base.Character.CharIndex;
                  end
                  else
                  begin
                    Randomize;
                    Servers[Player.ChannelIndex].Players[j].Base.PlayerCharacter.LastPos :=
                      Servers[Player.ChannelIndex].Players[
                      Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[k]].Leader].Base.Neighbors[RandomRange(0,8)].pos;
                  end;
                  if not(ChangeChannelList.ContainsKey(Servers[Player.ChannelIndex].Players[j].Account.Header.AccountId)) then
                  begin
                    ChangeChannelList.Add(Servers[Player.ChannelIndex].Players[j].Account.Header.AccountId, ChangeTokenIndParty);
                  end;
                  //Packet.TypeChanel := OtherChannelid;
                  //Packet.Info1 := Servers[Player.ChannelIndex].Players[j].Account.Header.AccountId;
                  //Packet.Header.Index := j;
                  //Servers[Player.ChannelIndex].Players[j].SendPacket(Packet, Packet.Header.Size);
                  //Servers[Player.ChannelIndex].Players[j].SocketClosed := True;
                end;
                //Break;
              //end;
            //end;
          end;
        end;
      end
      else
      begin //telar apenas minha party
        //for i := 1 to Length(Servers[OtherChannelid].Parties) do
        //begin
          //if (Servers[OtherChannelid].Parties[i].Members.Count = 0) then
          //begin //achei uma party vazia no canal destino
            ChangeChannelToken.PartyTeleport.RequestId := Player.Party.RequestId;
            ChangeChannelToken.PartyTeleport.ExpAlocate := Player.Party.ExpAlocate;
            ChangeChannelToken.PartyTeleport.ItemAlocate := Player.Party.ItemAlocate;
            ChangeChannelToken.PartyTeleport.LastSlotItemReceived := Player.Party.LastSlotItemReceived;
            ChangeChannelToken.PartyTeleport.InRaid := False;
            ChangeChannelToken.PartyTeleport.IsRaidLeader := True;
            ChangeChannelToken.PartyTeleport.PartyRaidCount := Player.Party.PartyRaidCount;
            ChangeChannelToken.PartyTeleport.MemberName := TList<Integer>.Create;
            ChangeChannelToken.AccountStatus := 0;
            if(Player.CheckGameMasterLogged) then
            begin
              ChangeChannelToken.AccountStatus := 1;
            end;
            if(Player.CheckAdminLogged) then
            begin
              ChangeChannelToken.AccountStatus := 2;
            end;
            for j in Player.Party.Members do
            begin
              if not(Servers[Player.ChannelIndex].Players[j].Base.PlayerCharacter.LastPos.InRange(
                Player.Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)) then
              begin
                Player.Party.RemoveMember(j);
                Continue;
              end;
              if not(j = Player.Party.Leader) then
              begin
                Packet.TypeChanel := OtherChannelid;
                Packet.Info1 := Servers[Player.ChannelIndex].Players[j].Account.Header.AccountId;
                Packet.Header.Index := j;
                Servers[Player.ChannelIndex].Players[j].SendPacket(Packet, Packet.Header.Size);
                //Servers[Player.ChannelIndex].Disconnect(
                   // Servers[Player.ChannelIndex].Players[j]);
                Servers[Player.ChannelIndex].Players[j].SocketClosed := True;
              end;
            end;
            for j in Player.Party.Members do
            begin
              if not(ChangeChannelToken.PartyTeleport.MemberName.Contains(Servers[Player.ChannelIndex].Players[j].Base.Character.CharIndex)) then
                ChangeChannelToken.PartyTeleport.MemberName.Add(Servers[Player.ChannelIndex].Players[j].Base.Character.CharIndex);
              Servers[Player.ChannelIndex].Players[j].DesconectedByOtherChannel := True;
              if not(j = Player.Party.Leader) then
              begin //mandar informação de telar pros outros
                Randomize;
                Servers[Player.ChannelIndex].Players[j].Base.PlayerCharacter.LastPos :=
                  Player.Base.Neighbors[RandomRange(0,8)].pos;
                ZeroMemory(@ChangeTokenIndParty, sizeof(TChangeChannelToken));
                ChangeTokenIndParty.CharSlot := Servers[Player.ChannelIndex].Players[j].SelectedCharacterIndex;
                ChangeTokenIndParty.ChangeTime := Now;
                ChangeTokenIndParty.AccountStatus := 0;
                ChangeTokenIndParty.OldClientID := Servers[Player.ChannelIndex].Players[j].Base.ClientID;
                ChangeTokenIndParty.OldChannelID := Player.ChannelIndex;
                ChangeTokenIndParty.accFromOther := Servers[Player.ChannelIndex].Players[j].Account;
                ChangeTokenIndParty.charFromOther := Servers[Player.ChannelIndex].Players[j].Character;
                ChangeTokenIndParty.buffFromOther :=
                  Servers[Player.ChannelIndex].Players[j].Base.PlayerCharacter.Buffs;
                if(Servers[Player.ChannelIndex].Players[j].CheckGameMasterLogged) then
                begin
                  ChangeTokenIndParty.AccountStatus := 1;
                end;
                if(Servers[Player.ChannelIndex].Players[j].CheckAdminLogged) then
                begin
                  ChangeTokenIndParty.AccountStatus := 2;
                end;
                if not(ChangeChannelList.ContainsKey(Servers[Player.ChannelIndex].Players[j].Account.Header.AccountId)) then
                begin
                  ChangeChannelList.Add(Servers[Player.ChannelIndex].Players[j].Account.Header.AccountId, ChangeTokenIndParty);
                end;
                //Packet.TypeChanel := OtherChannelid;
                //Packet.Info1 := Servers[Player.ChannelIndex].Players[j].Account.Header.AccountId;
                //Packet.Header.Index := j;
                //Servers[Player.ChannelIndex].Players[j].SendPacket(Packet, Packet.Header.Size);
                //Servers[Player.ChannelIndex].Players[j].SocketClosed := True;
              end;
            end;
            //Break;
          //end;
        //end;
      end;
    end;
  end
  else
  begin
    Player.DesconectedByOtherChannel := True;
  end;
  Packet.TypeChanel := OtherChannelid;
  Packet.Info1 := Player.Account.Header.AccountId;
  Packet.Header.Index := player.Base.ClientID;
  if not(ChangeChannelList.ContainsKey(Player.Account.Header.AccountId)) then
  begin
    ChangeChannelList.Add(Player.Account.Header.AccountId, ChangeChannelToken);
  end;
  Player.SendPacket(Packet, Packet.Header.Size);
  //Servers[Player.ChannelIndex].Disconnect(Player);
  Player.SocketClosed := True;
  Result := true;
end;
class function TPacketHandlers.LoginIntoChannel(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TChannelSendInfoPacket absolute Buffer;
  ChangeChannelToken: TChangeChannelToken;
  i, j, k: Integer;
  OtherPlayer, xOtherPlayer: PPlayer;
  xParty: PParty;
  cnt: Integer;
  cid: WORD;
begin
  Result := False;
  if(string(Packet.Username) = '') then
  begin
    Player.SocketClosed := True;
    Exit;
  end;
  Player.SendP131;
  Player.SendChannelClientIndex;
  ZeroMemory(@ChangeChannelToken, sizeof(TChangeChannelToken));

 { for I := Low(Servers) to High(Servers) do
  begin
    if(Player.ChannelIndex = i) then
      Cid := Servers[i].GetPlayerByUsernameAux(string(Packet.Username), Player.Base.ClientID)
    else
      Cid := Servers[i].GetPlayerByUsername(string(Packet.Username));
    if(Cid > 0) then
    begin
      //Servers[i].Disconnect(Cid);
      //Servers[i].Disconnect(Servers[i].Players[Cid]);
      while not(Servers[i].Players[Cid].xdisconnected) do
        Sleep(10);
      {.SocketClosed := True;
      if(Servers[i].Players[Cid].Thread.ClientID > 0) then
      begin
        if(Assigned(Servers[i].Players[Cid].Thread)) then
          if not(Servers[i].Players[Cid].Thread.Finished) then
            WaitForSingleObject(Servers[i].Players[Cid].Thread.Handle, INFINITE);
      end;}

      //ZeroMemory(@Servers[i].Players[Cid], sizeof(TPlayer));
    //end;
  //end;
  //if not(Player.LoadAccSQL(string(Packet.Username))) then
  //begin
    //Servers[Player.ChannelIndex].Disconnect(Player);
   // Player.SocketClosed := True;
   // Exit;
  //end;
  if not(ChangeChannelList.ContainsKey(Packet.Serial)) then
  begin
    Player.SocketClosed := True;
    Exit;
  end;
  if not(ChangeChannelList.TryGetValue(Packet.Serial,
    ChangeChannelToken)) then
  begin
    Player.SocketClosed := True;
    Exit;
  end;
  if(ChangeChannelToken.OldClientID = 0) then
  begin
    Player.SocketClosed := True;
    Exit;
  end;

<<<<<<< HEAD
  Player.Account := ChangeChannelToken.accFromOther;
  Player.Character := ChangeChannelToken.charFromOther;
  Player.Character.Buffs := ChangeChannelToken.buffFromOther;
 { if(Assigned(Servers[ChangeChannelToken.OldChannelID].
    Players[ChangeChannelToken.OldClientID].Thread)) then
  begin
    Servers[ChangeChannelToken.OldChannelID].
      Players[ChangeChannelToken.OldClientID].SocketClosed := True;


    while(Assigned(Servers[ChangeChannelToken.OldChannelID].
      Players[ChangeChannelToken.OldClientID].Thread)) do
    begin
      Sleep(1);
    end;}
    {timeinit := Now;
    IncSecond(timeinit, 20);
    while (not(Servers[ChangeChannelToken.OldChannelID].
      Players[ChangeChannelToken.OldClientID].Thread.Term) and
      (timeinit<=now)) do
    begin
      Sleep(1);
    end;}
  //end;

  {while(Servers[ChangeChannelToken.OldChannelID].
=======
  while(Servers[ChangeChannelToken.OldChannelID].
>>>>>>> parent of a46c38b (30)
    Players[ChangeChannelToken.OldClientID].Base.ClientID > 0) do
    Sleep(10);

  {if(WaitForSingleObject(Servers[ChangeChannelToken.OldChannelID].
    Players[ChangeChannelToken.OldClientID].Thread.Handle, 10000) <> WAIT_OBJECT_0) then
  begin
    Player.SocketClosed := True;
    Exit;
  end;}

  if(Player.SocketClosed) then
    Exit;

<<<<<<< HEAD
  Player.Authenticated := True;
  Player.LoggedByOtherChannel := true;
=======
  Player.SendP131;
  Player.SendChannelClientIndex;
  Player.Authenticated := True;
  Player.LoggedByOtherChannel := true;

>>>>>>> parent of a46c38b (30)
  ChangeChannelList.Remove(Player.Account.Header.AccountId);
  Player.SelectedCharacterIndex := ChangeChannelToken.CharSlot;
  Player.Account.Header.IsActive := true;
  ZeroMemory(@Player.Base.MOB_EF, sizeof(Player.Base.MOB_EF));
  ZeroMemory(@Player.Base.PlayerCharacter, sizeof(TPlayerCharacter));
  //Player.LoadCharacterMisc(Player.SelectedCharacterIndex);
  //Move(Player.Account.Characters[ChangeChannelToken.CharSlot], Player.Character,
   // sizeof(TCharacterDB));
  //Move(Player.Character, Player.Base.PlayerCharacter, sizeof(TPlayerCharacter));
<<<<<<< HEAD
  //Logger.Write('[' + string(ServerList[Player.ChannelIndex].Name) +
   // ']: Usuario conectado [' + string(Packet.Username) + '].',
    //TLogType.ConnectionsTraffic);
  //Player.SendP131;
  //Player.SendChannelClientIndex;
=======
  Logger.Write('[' + string(ServerList[Player.ChannelIndex].Name) +
    ']: Usuario conectado [' + string(Packet.Username) + '].',
    TLogType.ConnectionsTraffic);

>>>>>>> parent of a46c38b (30)
  //Sleep(1500); //ver isso aq no sendtoworld se tempo ajudaria no dc
  Player.SendToWorld(ChangeChannelToken.CharSlot, False);
  //Sleep(300);
  //Sleep(300);
 // Player.SendP131;
  //Player.SendChannelClientIndex;
  //Sleep(300);
  Player.SendToWorldSends(True);
 // Sleep(300);
 // Player.SendP131;
  //Player.SendChannelClientIndex;
  //(300);
  //patch no dc quando tela entre tiamats
  Player.Base.LastAttackMsg := IncSecond(Now, -6);
  //Sleep(2000); //ver isso aq no sendtoworld se tempo ajudaria no dc
  if(ChangeChannelToken.AccountStatus > 0) then
  begin
    Player.Base.SessionOnline := true;
    Player.Base.SessionUsername := String(Player.Account.Header.Username);
    Player.Base.SessionMasterPriv := TMasterPrives(ChangeChannelToken.AccountStatus);
  end;
  if(ChangeChannelToken.PartyTeleport.MemberName = nil) then
  begin//talvez tenha uma raid pra verificar
    //verificando se estou usando o partiesTeleport para teleportar todo mundo
    if(ChangeChannelToken.PartiesTeleport[0].MemberName = nil) then
      Exit;
    for k := 0 to 3 do
    begin
      if(ChangeChannelToken.PartiesTeleport[k].MemberName = nil) then
        Continue;
      for i := 1 to Length(Servers[Player.ChannelIndex].Parties) do
      if (Servers[Player.ChannelIndex].Parties[i].Members.Count = 0) then
      begin
        xParty := @Servers[Player.ChannelIndex].Parties[i];
        OtherPlayer := nil;
        if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[k],
          OtherPlayer)) then
        begin
          xParty.Leader := OtherPlayer.Base.ClientID;
        end;
        xParty.RequestId := ChangeChannelToken.PartiesTeleport[k].RequestId;
        xParty.ExpAlocate := ChangeChannelToken.PartiesTeleport[k].ExpAlocate;
        xParty.ItemAlocate := ChangeChannelToken.PartiesTeleport[k].ItemAlocate;
        xParty.LastSlotItemReceived := ChangeChannelToken.PartiesTeleport[k].LastSlotItemReceived;
        xParty.InRaid := True;
        if(k = 0) then
          xParty.IsRaidLeader := True
        else
          xParty.IsRaidLeader := False;
        xParty.PartyRaidCount := ChangeChannelToken.PartiesTeleport[k].PartyRaidCount;
        for j in ChangeChannelToken.PartiesTeleport[k].MemberName do
        begin
          OtherPlayer := nil;
          if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(j, OtherPlayer)) then
          begin
            if not(xParty.Members.Contains(OtherPlayer.Base.ClientID)) then
            begin
              xParty.Members.Add(OtherPlayer.Base.ClientID);
            end;
            if(xParty.Leader = 0) then
              xParty.Leader := OtherPlayer.Base.ClientID;
          end;
        end;
        for j in xParty.Members do
        begin
          Servers[Player.ChannelIndex].Players[j].Party := @Servers[Player.ChannelIndex].Parties[i];
          Servers[Player.ChannelIndex].Players[j].PartyIndex := xParty.Index;
          Servers[Player.ChannelIndex].Players[j].Base.PartyId := xParty.Index;
        end;
        xParty.RefreshParty;
        //ChangeChannelToken.PartyTeleport.MemberName.Clear;
        //FreeAndNil(ChangeChannelToken.PartyTeleport.MemberName);
        Break;
      end;
    end;
    OtherPlayer := nil;
    if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[0],
      OtherPlayer)) then
    begin
      xOtherPlayer := nil;
      if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[1],
        xOtherPlayer)) then
          OtherPlayer.Party.PartyAllied[1] := xOtherPlayer.Party.Index;
      xOtherPlayer := nil;
      if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[2],
        xOtherPlayer)) then
          OtherPlayer.Party.PartyAllied[2] := xOtherPlayer.Party.Index;
      xOtherPlayer := nil;
      if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[3],
        xOtherPlayer)) then
          OtherPlayer.Party.PartyAllied[3] := xOtherPlayer.Party.Index;
    end;
    //OtherPlayer := nil;
    if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[1],
      OtherPlayer)) then
    begin
      xOtherPlayer := nil;
      if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[0],
        xOtherPlayer)) then
          OtherPlayer.Party.PartyAllied[1] := xOtherPlayer.Party.Index;
      xOtherPlayer := nil;
      if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[2],
        xOtherPlayer)) then
          OtherPlayer.Party.PartyAllied[2] := xOtherPlayer.Party.Index;
      xOtherPlayer := nil;
      if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[3],
        xOtherPlayer)) then
          OtherPlayer.Party.PartyAllied[3] := xOtherPlayer.Party.Index;
    end;
    if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[2],
      OtherPlayer)) then
    begin
      xOtherPlayer := nil;
      if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[0],
        xOtherPlayer)) then
          OtherPlayer.Party.PartyAllied[1] := xOtherPlayer.Party.Index;
      xOtherPlayer := nil;
      if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[1],
        xOtherPlayer)) then
          OtherPlayer.Party.PartyAllied[2] := xOtherPlayer.Party.Index;
      xOtherPlayer := nil;
      if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[3],
        xOtherPlayer)) then
          OtherPlayer.Party.PartyAllied[3] := xOtherPlayer.Party.Index;
    end;
    if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[3],
      OtherPlayer)) then
    begin
      xOtherPlayer := nil;
      if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[0],
        xOtherPlayer)) then
          OtherPlayer.Party.PartyAllied[1] := xOtherPlayer.Party.Index;
      xOtherPlayer := nil;
      if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[1],
        xOtherPlayer)) then
          OtherPlayer.Party.PartyAllied[2] := xOtherPlayer.Party.Index;
      xOtherPlayer := nil;
      if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[2],
        xOtherPlayer)) then
          OtherPlayer.Party.PartyAllied[3] := xOtherPlayer.Party.Index;
    end;
    if not(Otherplayer = nil) then
      OtherPlayer.Party.RefreshRaid;
  end
  else //então é minha party
  begin
    for i := 1 to Length(Servers[Player.ChannelIndex].Parties) do
      if (Servers[Player.ChannelIndex].Parties[i].Members.Count = 0) then
      begin
        xParty := @Servers[Player.ChannelIndex].Parties[i];
        xParty.Leader := Player.Base.ClientID;
        xParty.RequestId := ChangeChannelToken.PartyTeleport.RequestId;
        xParty.ExpAlocate := ChangeChannelToken.PartyTeleport.ExpAlocate;
        xParty.ItemAlocate := ChangeChannelToken.PartyTeleport.ItemAlocate;
        xParty.LastSlotItemReceived := ChangeChannelToken.PartyTeleport.LastSlotItemReceived;
        xParty.InRaid := False;
        xParty.IsRaidLeader := True;
        xParty.PartyRaidCount := 1;
        for j in ChangeChannelToken.PartyTeleport.MemberName do
        begin
          OtherPlayer := nil;
          if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(j, OtherPlayer)) then
          begin
            if not(xParty.Members.Contains(OtherPlayer.Base.ClientID)) then
            begin
              xParty.Members.Add(OtherPlayer.Base.ClientID);
            end;
          end;
        end;
        for j in xParty.Members do
        begin
          Servers[Player.ChannelIndex].Players[j].Party := @Servers[Player.ChannelIndex].Parties[i];
          Servers[Player.ChannelIndex].Players[j].PartyIndex := xParty.Index;
          Servers[Player.ChannelIndex].Players[j].Base.PartyId := xParty.Index;
        end;
        xParty.RefreshParty;
       { if(Assigned(ChangeChannelToken.PartyTeleport.MemberName)) then
        begin
          ChangeChannelToken.PartyTeleport.MemberName.Clear;
          FreeAndNil(ChangeChannelToken.PartyTeleport.MemberName);
        end; }
        Break;
      end;
  end;
  Result := true;
end;
{$ENDREGION}
{$REGION 'Guild'}
class function TPacketHandlers.CreateGuild(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TCreateGuildDialogPacket absolute Buffer;
  PartyMemberIndex: WORD;
  PartyMember: PPlayer;
  I, Helper: Integer;
const
  Taxa = 50000;
begin
  Result := False;
  case Packet.Stage of
    0:
      begin
        if (Player.Character.Base.Nation <= 0) then
        begin
          Player.SendClientMessage
            ('É necessário ter nação para criar uma guild.');
          Exit;
        end;
        if (Player.Character.Base.GuildIndex > 0) then
        begin
          Player.SendClientMessage('Você já está em uma guild.');
          Exit;
        end;
        if(Player.PartyIndex = 0) then
        begin
          Player.SendClientMessage('Você não está em um grupo.');
          Exit;
        end;
        if Player.Party.Members.Count < 6 then
        begin
          Player.SendClientMessage('Você precisa de um grupo com 6 pessoas para criar a guild.');
          Exit;
        end;
        if Player.Party.Leader <> Player.Character.Base.ClientId then
        begin
          Player.SendClientMessage('Você não é o líder do grupo.');
          Exit;
        end;
        for PartyMemberIndex in Player.Party.Members do
        begin
          PartyMember := @Servers[Player.ChannelIndex].Players
            [PartyMemberIndex];
          if PartyMember.Character.Base.Nation <= 0 then
          begin
            Player.SendClientMessage
              ('Todos os membros do grupo devem ter nação.');
            Exit;
          end;
          {if Player.Base.PlayerCharacter.LastPos.InRange
            (PartyMember.Base.PlayerCharacter.LastPos, 25) = False then
          begin
            Player.SendClientMessage
              ('Todos os membros do grupo devem estar perto.');
            Exit;
          end;  }
        end;
        if Player.Character.Base.Gold < Taxa then
        begin
          Player.SendClientMessage
            ('Você não tem gold suficiente para criar uma guild.');
          Exit;
        end;
        if Player.Character.Base.Level < 10 then
        begin
          Player.SendClientMessage('O level minímo para criar uma guild é 10.');
          Exit;
        end;
        Packet.Stage := 1;
        Packet.Rate := Taxa;
        Player.SendPacket(Packet, Packet.Header.Size);
      end;
    2:
      begin
        if (Player.Character.Base.Nation <= 0) then
        begin
          Player.SendClientMessage
            ('É necessário ter nação para criar uma guild.');
          Exit;
        end;
        if (Player.Character.Base.GuildIndex > 0) then
        begin
          Player.SendClientMessage('Você já está em uma guild.');
          Exit;
        end;
        if(Player.PartyIndex = 0) then
        begin
          Player.SendClientMessage('Você não está em um grupo.');
          Exit;
        end;
        if Player.Party.Members.Count < 6 then
        begin
          Player.SendClientMessage('Você precisa de um grupo com 6 pessoas para criar a guild.');
          Exit;
        end;
        if Player.Party.Leader <> Player.Character.Base.ClientId then
        begin
          Player.SendClientMessage('Você não é o líder do grupo.');
          Exit;
        end;
        for PartyMemberIndex in Player.Party.Members do
        begin
          PartyMember := @Servers[Player.ChannelIndex].Players
            [PartyMemberIndex];
          if PartyMember.Character.Base.Nation <= 0 then
          begin
            Player.SendClientMessage
              ('Todos os membros do grupo devem ter nação.');
            Exit;
          end;
         { if Player.Base.PlayerCharacter.LastPos.InRange
            (PartyMember.Base.PlayerCharacter.LastPos, 25) = False then
          begin
            Player.SendClientMessage
              ('Todos os membros do grupo devem estar perto.');
            Exit;
          end;}
        end;
        if Player.Character.Base.Gold < Taxa then
        begin
          Player.SendClientMessage
            ('Você não tem gold suficiente para criar uma guild.');
          Exit;
        end;
        if Player.Character.Base.Level < 10 then
        begin
          Player.SendClientMessage('O level minímo para criar uma guild é 10.');
          Exit;
        end;

        if not(TFunctions.IsLetter(String(Packet.GuildName))) then
        begin
          Player.SendClientMessage('Caracteres não permitidos.');
          Exit;
        end;

        Helper := 0;
        for I := Low(Guilds) to High(Guilds) do
        begin
          if AnsiString(Packet.GuildName) = AnsiString(Guilds[I].Name) then
          begin
            Player.SendClientMessage('Já existe uma guild com esse nome.');
            Exit;
          end;

          if(Guilds[i].Index = 0) then
            Helper := i;
        end;

        if(Helper = 0) then
        begin
          Player.SendClientMessage('Já atingimos o limite de criação de guildas.');
          Exit;
        end;

        Player.DecGold(Taxa);
        for I := Low(Guilds) to High(Guilds) do
          if Guilds[I].Index <= 0 then
          begin
            ZeroMemory(@Guilds[I], sizeof(Guilds[I]));
            Guilds[I].Slot := I;
            Guilds[I].CreateGuild(Packet.GuildName,
              Player.Base.Character.Nation, Player.ChannelIndex,
              Player.Party, @Player);
            Break;
          end;
      end;
  end;
  Result := true;
end;
class function TPacketHandlers.CloseGuildChest(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Guild: PGuild;
begin
  Result := False;
  if Player.Character.Base.GuildIndex <= 0 then
    Exit;
  Guild := @Guilds[Player.Character.GuildSlot];
  if Guild.MemberInChest = Guild.FindMemberFromCharIndex(Player.Base.Character.CharIndex)
  then
    Guild.CloseChest;
  Result := true;
end;
class function TPacketHandlers.ChangeGuildMemberRank(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TChangeGuildMemberRankPacket absolute Buffer;
  Guild: PGuild;
begin
  Result := False;
  if Player.Character.Base.GuildIndex <= 0 then
    Exit;
  Guild := @Guilds[Player.Character.GuildSlot];
  if Guild.Members[Guild.FindMemberFromCharIndex(Player.Base.Character.CharIndex)].Rank < 4
  then
  begin
    Player.SendClientMessage('Você não tem permissão para isso.');
    Exit;
  end;
  Guilds[Player.Character.GuildSlot].ChangeRank(Packet.CharIndex, Packet.Rank);

  TFunctions.SaveGuilds(Player.Character.GuildSlot);
  Result := true;
end;
class function TPacketHandlers.UpdateGuildRanksConfig(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TUpdateGuildRanksConfigPacket absolute Buffer;
  Guild: PGuild;
begin
  Result := False;
  if Player.Character.Base.GuildIndex <= 0 then
    Exit;
  if Player.Character.Base.GuildIndex <> Packet.GuildIndex then
    Exit;
  Guild := @Guilds[Player.Character.GuildSlot];
  if Guild.Members[Guild.FindMemberFromCharIndex(Player.Base.Character.CharIndex)].Rank < 4
  then
  begin
    Player.SendClientMessage('Você não tem permissão para isso.');
    Exit;
  end;
  Clipboard.AsText := Packet.RanksConfig[0].ToHexString(2);
  Guilds[Player.Character.GuildSlot].UpdateRanksConfig(Packet.RanksConfig);

  TFunctions.SaveGuilds(Player.Character.GuildSlot);
  Result := true;
end;
class function TPacketHandlers.UpdateGuildNotices(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TUpdateGuildNoticesPacket absolute Buffer;
  Guild: PGuild;
begin
  Result := False;
  if Player.Character.Base.GuildIndex <= 0 then
    Exit;
  Guild := @Guilds[Player.Character.GuildSlot];
  if Guild.GetRankConfig
    (Guild.Members[Guild.FindMemberFromCharIndex(Player.Base.Character.CharIndex)].Rank)
    .EditNotices = False then
  begin
    Player.SendClientMessage('Você não tem permissão para isso.');
    Exit;
  end;
  Guilds[Player.Character.GuildSlot].UpdateNotices(Packet.Notices[0],
    Packet.Notices[1], Packet.Notices[2]);

  TFunctions.SaveGuilds(Player.Character.GuildSlot);
  Result := true;
end;
class function TPacketHandlers.UpdateGuildSite(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TUpdateGuildSitePacket absolute Buffer;
  Guild: PGuild;
begin
  Result := False;
  if Player.Character.Base.GuildIndex <= 0 then
    Exit;
  Guild := @Guilds[Player.Character.GuildSlot];
  if Guild.GetRankConfig
    (Guild.Members[Guild.FindMemberFromCharIndex(Player.Base.Character.CharIndex)].Rank)
    .EditNotices = False then
  begin
    Player.SendClientMessage('Você não tem permissão para isso.');
    Exit;
  end;
  Guilds[Player.Character.GuildSlot].UpdateSite(Packet.Site);

  TFunctions.SaveGuilds(Player.Character.GuildSlot);
  Result := true;
end;
class function TPacketHandlers.InviteToGuildRequest(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TSignalData absolute Buffer;
  OtherPlayer: PPlayer;
  Guild: PGuild;
begin
  Result := False;
  if Player.Character.Base.GuildIndex <= 0 then
    Exit;
  Guild := @Guilds[Player.Character.GuildSlot];
  if Guild.GetRankConfig
    (Guild.Members[Guild.FindMemberFromCharIndex(Player.Base.Character.CharIndex)].Rank)
    .Invite = False then
  begin
    Player.SendClientMessage('Você não tem permissão para isso.');
    Exit;
  end;
  if Packet.Data > High(Servers[Player.ChannelIndex].Players) then
  begin
    Player.SendClientMessage('Player index inválida.');
    Exit;
  end;
  OtherPlayer := @Servers[Player.ChannelIndex].Players[Packet.Data];
  if (OtherPlayer.Base.IsActive = False) or
    (OtherPlayer.Account.Header.IsActive = False) then
  begin
    Player.SendClientMessage('Personagem não encontrado.');
    Exit;
  end;
  if (OtherPlayer.Character.Base.GuildIndex > 0) then
  begin
    Player.SendClientMessage('O jogador já está em uma guild.');
    Exit;
  end;
  if (OtherPlayer.GuildRecruterCharIndex > 0) and
    (MinutesBetween(Now, Player.GuildInviteTime) <= 1) then
  begin
    Player.SendClientMessage('O jogador já tem um convite pendente.');
    Exit;
  end;
  if (BYTE(OtherPlayer.Account.Header.Nation) <> Guild.Nation) then
  begin
    Player.SendClientMessage('O jogador não pertence a nação da guild.');
    Exit;
  end;
  OtherPlayer.GuildRecruterCharIndex := Servers[Player.ChannelIndex].Players
    [Packet.Header.Index].Base.Character.CharIndex;
  OtherPlayer.GuildInviteTime := Now;
  OtherPlayer.InviteToGuildRequest(Packet.Data);
  Result := true;
end;
class function TPacketHandlers.InviteToGuildAccept(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Recruter: PPlayer;
begin
  Result := False;
  if Player.GuildRecruterCharIndex <= 0 then
    Exit;
  if MinutesBetween(Now, Player.GuildInviteTime) > 1 then
  begin
    Player.SendClientMessage('O convite expirou.');
    Exit;
  end;
  if Servers[Player.ChannelIndex].GetPlayerByCharIndex
    (Player.GuildRecruterCharIndex, Recruter) then
  begin
    Guilds[Recruter.Character.GuildSlot].AddMember(Player.Base.Character.CharIndex,
      Player.ChannelIndex, 0, Player.GuildRecruterCharIndex);
    Player.SendP152;
  end;
  TFunctions.SaveGuilds(Recruter.Character.GuildSlot);
  Player.SendNationInformation;
  Result := true;
end;
class function TPacketHandlers.InviteToGuildDeny(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  OtherPlayer: TPlayer;
begin
  Result := False;
  if not Servers[Player.ChannelIndex].GetPlayerByCharIndex
    (Player.GuildRecruterCharIndex, OtherPlayer) then
    Exit;
  OtherPlayer.SendClientMessage('O personagem recusou o seu convite.');
  Player.GuildRecruterCharIndex := 0;
  Player.GuildInviteTime := 0;
  Result := true;
end;
class function TPacketHandlers.KickMemberOfGuild(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TSignalData absolute Buffer;
  Guild: PGuild;
  OtherPlayer: PPlayer;
  i: Integer;
begin
  Result := False;
  if Player.Character.Base.GuildIndex <= 0 then
    Exit;
  Guild := @Guilds[Player.Character.GuildSlot];
  if Guild.GetRankConfig
    (Guild.Members[Guild.FindMemberFromCharIndex(Player.Base.Character.CharIndex)].Rank)
    .Kick = False then
  begin
    Player.SendClientMessage('Você não tem permissão para isso.');
    Exit;
  end;

  if(Guild.Members[Guild.FindMemberFromCharIndex(Player.Base.Character.CharIndex)].Rank
    < Guild.Members[Guild.FindMemberFromCharIndex(Packet.Data)].Rank) then
  begin
    Player.SendClientMessage('O jogador selecionado possui rank maior que o seu.');
    Exit;
  end;

  Guilds[Player.Character.GuildSlot].RemoveMember(Packet.Data, true);
  for I := Low(Servers) to High(Servers) do
  begin
    OtherPlayer := nil;
    if(Servers[i].GetPlayerByCharIndex(Packet.Data, OtherPlayer) = True) then
    begin
      OtherPlayer.SendNationInformation;
      break;
    end
    else
      Continue;
  end;

  TFunctions.SaveGuilds(Player.Character.GuildSlot);

  Result := true;
end;
class function TPacketHandlers.ExitGuild(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  aux: WORD;
begin
  Result := False;
  if Player.Character.Base.GuildIndex <= 0 then
    Exit;
  if(Guilds[Player.Character.GuildSlot].GuildLeaderCharIndex =
    Player.Base.Character.CharIndex) then
  begin
    Player.SendClientMessage('Você não pode sair da guilda sendo o lider dela.');
    Exit;
  end;

  aux := Player.Character.GuildSlot;

  Guilds[Player.Character.GuildSlot].RemoveMember(Player.Base.Character.CharIndex, False);
  Player.SendNationInformation;

  TFunctions.SaveGuilds(aux);
  Result := true;
end;
class function TPacketHandlers.RequestGuildToAlly(var Player: TPlayer;
  Buffer: array of BYTE): Boolean;
var
  Packet: TGuildRequestAllyPacket absolute Buffer;
  xSendpacket: TSendInviteToRaid;
  Guild: PGuild;
  OtherGuild: PGuild;
  I, P: Integer;
  leadMemberId: WORD;
  LeadPlayer: PPlayer;
begin
  Result := False;
  if AnsiStrings.CompareStr(Packet.GuildName, '') = 0 then
    Exit;
  if Player.Base.Character.GuildIndex = 0 then
    Exit;
  Guild := @Guilds[Player.Character.GuildSlot];
  if Guild.Members[Guild.FindMemberFromCharIndex(Player.Base.Character.CharIndex)].Rank < 4
  then
  begin
    Player.SendClientMessage('Você não é o líder da guild.');
    Exit;
  end;
  // for I := Low(Guild.Ally.Guilds) to High(Guild.Ally.Guilds) do
  // if not(AnsiStrings.CompareStr(Guild.Ally.Guilds[I].Name, '') = 0) then
  if Guild.Ally.Leader <> Guild.Index then
  begin
    Player.SendClientMessage('Você não é o líder da aliança');
    Exit;
  end;
  for I := Low(Guilds) to High(Guilds) do
    if AnsiStrings.CompareStr(Guilds[I].Name, Packet.GuildName) = 0 then
    begin
      for P := Low(Guilds[I].Ally.Guilds) + 1 to High(Guilds[I].Ally.Guilds) do
        if not(AnsiStrings.CompareStr(Guilds[I].Ally.Guilds[P].Name, '') = 0)
        then
        begin
          Player.SendClientMessage('A guild já está em uma aliança.');
          Exit;
        end;
    end;
  for I := Low(Guild.Ally.Guilds) + 1 to High(Guild.Ally.Guilds) do
  begin
    if (AnsiStrings.CompareStr(Guilds[I].Ally.Guilds[I].Name, '') = 0) then
      Break
    else if not(AnsiStrings.CompareStr(Guilds[I].Ally.Guilds[I].Name, '') = 0) then
      if I = High(Guild.Ally.Guilds) then
      begin
        Player.SendClientMessage('Não há mais espaço na aliança.');
        Exit;
      end;
  end;
  OtherGuild := TFunctions.SearchGuildByName(String(Packet.GuildName));
  if(OtherGuild = nil) then
  begin
    Player.SendClientMessage('Erro de busca por guild para inclusão na aliança. Ticket pro suporte.');
    Exit;
  end;
  if(OtherGuild.Nation <> Guild.Nation) then
  begin
    Player.SendClientMessage('A guild escolhida é de outra nação.');
    Exit;
  end;
  leadMemberID := OtherGuild.FindMemberFromCharIndex(OtherGuild.GuildLeaderCharIndex);
  if not(OtherGuild.Members[leadMemberID].Logged) then
  begin
    Player.SendClientMessage('O lider da guild escolhida está offline.');
    Exit;
  end;
  if(OtherGuild.Index = guild.Index) then
  begin
    Player.SendClientMessage('Você não pode adicionar a própia legião na aliança.');
    Exit;
  end;

  ZeroMemory(@xSendpacket, sizeof(xSendpacket));
  xSendpacket.Header.Size := sizeof(xSendpacket);
  xSendpacket.Header.Code := $342;
  xSendpacket.Header.Index := Player.Base.ClientID;
  if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(OtherGuild.GuildLeaderCharIndex, LeadPlayer)) then
  begin
    xSendPacket.SendTo := LeadPlayer.Base.ClientID;
    LeadPlayer.SendClientMessage('A aliança de <' + AnsiString(Guild.Name) +
      '> lhe convida a participar da aliança com sua Legião.', 16, 32, 8);
    LeadPlayer.SendPacket(xSendPacket, xSendPacket.Header.Size);
    LeadPlayer.AliianceByLegion := True;
    LeadPlayer.AllianceRequester := Player.Base.ClientID;
    LeadPlayer.AllianceSlot := Packet.SlotAlly;
  end;
  Result := true;
end;
class function TPacketHandlers.ChangeMasterGuild(var Player: TPlayer;
  Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TChangeMasterGuild absolute Buffer;
  OtherPlayer, xOtherPlayer: PPlayer;
  i: Integer;
  SelfMemberID, TargetMemberId: Byte;
begin
  if(Player.Base.Character.GuildIndex = 0) then
  begin
    Player.SendClientMessage('Você não está em uma guilda.');
    Exit;
  end;
  if(Guilds[Player.Character.GuildSlot].GuildLeaderCharIndex <>
    Player.Base.Character.CharIndex) then
  begin
    Player.SendClientMessage('Você não é o lider atual para fazer isso.');
    Exit;
  end;
  if(Packet.CharIndex = 0) then
    Exit;

  for I := 0 to 3 do
  begin
    if(String(Nations[Player.Character.Base.Nation-1].Cerco.Atacantes[i].LordMarechal) =
      String(Guilds[Player.Character.GuildSlot].Name)) then
    begin
      Player.SendClientMessage('Você não pode alterar o mestre guild estando cadastrado na guerra.');
      Exit;
    end;
    if(String(Nations[Player.Character.Base.Nation-1].Cerco.Atacantes[i].Estrategista) =
      String(Guilds[Player.Character.GuildSlot].Name)) then
    begin
      Player.SendClientMessage('Você não pode alterar o mestre guild estando cadastrado na guerra.');
      Exit;
    end;
    if(String(Nations[Player.Character.Base.Nation-1].Cerco.Atacantes[i].Juiz) =
      String(Guilds[Player.Character.GuildSlot].Name)) then
    begin
      Player.SendClientMessage('Você não pode alterar o mestre guild estando cadastrado na guerra.');
      Exit;
    end;
    if(String(Nations[Player.Character.Base.Nation-1].Cerco.Atacantes[i].Tesoureiro) =
      String(Guilds[Player.Character.GuildSlot].Name)) then
    begin
      Player.SendClientMessage('Você não pode alterar o mestre guild estando cadastrado na guerra.');
      Exit;
    end;
  end;

  if(String(Nations[Player.Character.Base.Nation-1].Cerco.Defensoras.LordMarechal) =
    String(Guilds[Player.Character.GuildSlot].Name)) then
  begin
    Player.SendClientMessage('Você não pode alterar o mestre guild estando cadastrado na grade.');
    Exit;
  end;
  if(String(Nations[Player.Character.Base.Nation-1].Cerco.Defensoras.Estrategista) =
    String(Guilds[Player.Character.GuildSlot].Name)) then
  begin
    Player.SendClientMessage('Você não pode alterar o mestre guild estando cadastrado na grade.');
    Exit;
  end;
  if(String(Nations[Player.Character.Base.Nation-1].Cerco.Defensoras.Juiz) =
    String(Guilds[Player.Character.GuildSlot].Name)) then
  begin
    Player.SendClientMessage('Você não pode alterar o mestre guild estando cadastrado na grade.');
    Exit;
  end;
  if(String(Nations[Player.Character.Base.Nation-1].Cerco.Defensoras.Tesoureiro) =
    String(Guilds[Player.Character.GuildSlot].Name)) then
  begin
    Player.SendClientMessage('Você não pode alterar o mestre guild estando cadastrado na grade.');
    Exit;
  end;

  OtherPlayer := nil;
  if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(Packet.CharIndex, OtherPlayer)) then
  begin
    if(OtherPlayer.Base.Character.GuildIndex <> Player.Base.Character.GuildIndex) then
    begin
      Player.SendClientMessage('Alvo não pertence a mesma guild que a sua.');
      Exit;
    end;
    for I := 0 to 127 do
    begin
      if(Guilds[Player.Character.GuildSlot].Members[i].CharIndex = 0) then
        Continue;
      if(Guilds[Player.Character.GuildSlot].Members[i].CharIndex =
        OtherPlayer.Character.Base.CharIndex) then
      begin
        TargetMemberId := i;
      end;
      if(Guilds[Player.Character.GuildSlot].Members[i].CharIndex =
        Player.Character.Base.CharIndex) then
      begin
        SelfMemberId := i;
      end;
    end;
    Guilds[Player.Character.GuildSlot].Members[TargetMemberId].Rank :=
     Guilds[Player.Character.GuildSlot].Members[SelfMemberId].Rank;
    Guilds[Player.Character.GuildSlot].Members[SelfMemberId].Rank := 3;
    Guilds[Player.Character.GuildSlot].GuildLeaderCharIndex :=
    Guilds[Player.Character.GuildSlot].Members[TargetMemberId].CharIndex;
    for I := 0 to 127 do
    begin
      if(Guilds[Player.Character.GuildSlot].Members[i].CharIndex = 0) then
        Continue;
      xOtherPlayer := nil;
      if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(Guilds[Player.Character.GuildSlot].Members[i].CharIndex,
        xOtherPlayer)) then
      begin
        xOtherPlayer.SendGuildInfo;
        xOtherPlayer.UpdateGuildMemberRank(Player.Base.Character.CharIndex,
          Guilds[Player.Character.GuildSlot].Members[SelfMemberId].Rank);
        xOtherPlayer.UpdateGuildMemberRank(OtherPlayer.Base.Character.CharIndex,
          Guilds[Player.Character.GuildSlot].Members[TargetMemberId].Rank);
        xOtherPlayer.SendClientMessage('O lider guild passou a ser o personagem <' +
          AnsiString(OtherPlayer.Character.Base.Name) + '.>');
      end;
    end;

    TFunctions.SaveGuilds(Player.Character.GuildSlot);
  end
  else
  begin
    Player.SendClientMessage('Alvo não disponível.');
    Exit;
  end;
  Result := True;
end;
{$ENDREGION}
{$REGION 'Request Time'}
class function TPacketHandlers.RequestServerTime(var Player: TPlayer;
  Buffer: array of BYTE): Boolean;
begin
  Player.SendClientMessage(AnsiString(DateTimeToStr(Now)), 16);
  Result := true;
end;
class function TPacketHandlers.RequestServerPing(var Player: TPlayer;
  Buffer: ARRAY OF BYTE): Boolean;
var
  xMs: Single;
begin
  xMs := MilliSecondsBetween(Player.PingCommandUsed, Now);

  Player.SendClientMessage(xMs.ToString + ' ms.');

  Result := true;
end;
{$ENDREGION}
{$REGION 'Other Handlers'}
class function TPacketHandlers.GetStatusPoint(var Player: TPlayer;
  Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TGetStatusPointPacket absolute Buffer;
begin
  Result := False;
  if (Packet.StatusAmount > Player.Character.Base.CurrentScore.Status) then
    Exit;
  case Packet.StatusIndex of
    0: // str
      begin
        Inc(Player.Character.Base.CurrentScore.Str, Packet.StatusAmount);
      end;
    1: // agility
      begin
        Inc(Player.Character.Base.CurrentScore.agility, Packet.StatusAmount);
      end;
    2: // int
      begin
        Inc(Player.Character.Base.CurrentScore.Int, Packet.StatusAmount);
      end;
    3: // cons
      begin
        Inc(Player.Character.Base.CurrentScore.Cons, Packet.StatusAmount);
      end;
    4: // luck
      begin
        Inc(Player.Character.Base.CurrentScore.Luck, Packet.StatusAmount);
      end;
  end;
  if (Packet.StatusAmount = Player.Character.Base.CurrentScore.Status) then
    Player.Character.Base.CurrentScore.Status := 0
  else
    Dec(Player.Character.Base.CurrentScore.Status, Packet.StatusAmount);
  // Dec(Player.Base.Character.CurrentScore.Status, Packet.StatusAmount);
  Player.Base.GetCurrentScore;
  Player.Base.SendStatus;
  Player.Base.SendRefreshPoint;
  Player.Base.SendCurrentHPMP;
  Result := true;
end;
class function TPacketHandlers.ReceiveEventItem(var Player: TPlayer;
  Buffer: ARRAY OF BYTE): Boolean;
var
  PlayerSQLComp: TQuery;
begin
  if(Player.Status < Playing) then
    Exit;  //testar o bagulho pra ver se é conta sem estar ingame
  if (TItemFunctions.GetInvAvailableSlots(Player) = 0) then
  begin
    Player.SendClientMessage('Inventário cheio.');
    Exit;
  end;

  {if(Player.Account.Header.IsFounder) then
  begin
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

    TItemFunctions.PutItemOnEvent(Player, 14133 + Player.Account.Header.FounderLevel);

    PlayerSQLComp.SetQuery('update accounts set isfounder=0 where id=' +
      Player.Account.Header.AccountId.ToString);
    PlayerSQLComp.Run(False);

    Logger.Write('Jogador username: ' + Player.Account.Header.Username +
    ' nick: ' + String(Player.Base.Character.Name) + ' resgatou o fundador lv.' +
    Player.Account.Header.FounderLevel.ToString, TLogType.Painel);

    Player.Account.Header.IsFounder := False;
    Player.Account.Header.FounderLevel := 0;
  end; }

  if (Player.DiaryItemAvaliable) then
  begin
    TItemFunctions.PutItemOnEvent(Player, 10467);
  end;

  Player.GetAllEventItems;


  Result := true;
end;
{$ENDREGION}
{$REGION 'Duel'}
class function TPacketHandlers.SendRequestDuel(var Player: TPlayer;
  Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSendDuelResquest absolute Buffer;
  OtherPlayer: PPlayer;
begin
  Result := true;
  if (Packet.ClientId > 0) then
  begin
    OtherPlayer := @Servers[Player.ChannelIndex].Players[Packet.ClientId];
  end
  else
  begin
    OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(String(Packet.Nick));
  end;
  if (OtherPlayer.Status < Playing) then
  begin
    Player.SendClientMessage('Alvo não está logado.');
    Exit;
  end;
  if (Player.Base.PlayerCharacter.PlayerKill) then
  begin
    Player.SendClientMessage('Não é possível duelar com o PvP ligado.');
    Exit;
  end;
  if (OtherPlayer.Character.Base.Nation <> Player.Character.Base.Nation) then
  begin
    Player.SendClientMessage('O alvo não é da sua nação.');
    Exit;
  end;
  if ((Player.Character.Base.Level < 10) or (OtherPlayer.Character.Base.Level
    < 10)) then
  begin
    Player.SendClientMessage
      ('É necessário que os dois jogadores sejam nivel 10 para duelar.');
    Exit;
  end;
  if ((OtherPlayer.PartyIndex <> 0) and (Player.PartyIndex <> 0)) then
  begin
    if (OtherPlayer.PartyIndex = Player.PartyIndex) then
    begin
      Player.SendClientMessage('Jogador inválido. Pertence ao seu grupo.');
      Exit;
    end;
  end;
  if (OtherPlayer.Dueling) then
  begin
    Player.SendClientMessage('O jogador já está em um duelo.');
    Exit;
  end;
  Packet.Header.Index := Player.Base.ClientId;
  Packet.ClientId := Player.Base.ClientId;
  Move(Player.Base.Character.Name, Packet.Nick, 16);
  OtherPlayer.SendPacket(Packet, Packet.Header.Size);
  OtherPlayer.DuelRequester := Player.Base.ClientId;
end;
class function TPacketHandlers.DuelResponse(var Player: TPlayer;
  Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSendDuelResponse absolute Buffer;
  OtherPlayer: PPlayer;
begin
  Result := true;
  OtherPlayer := @Servers[Player.ChannelIndex].Players[Player.DuelRequester];
  if (OtherPlayer.Status < Playing) then
  begin
    Player.SendClientMessage('O jogador desafiante não está mais online.');
    Exit;
  end;
  if (Packet.Response = 0) then
  begin
    OtherPlayer.SendClientMessage
      ('O jogador desafiado recusou seu convite de duelo.');
    Exit;
  end;
  if (Player.Base.PlayerCharacter.LastPos.Distance
    (OtherPlayer.Base.PlayerCharacter.LastPos) > DISTANCE_TO_WATCH) then
  begin
    Player.SendClientMessage('O jogador desafiante está muito longe.');
    Exit;
  end;
  if (OtherPlayer.Base.IsDead) then
  begin
    Player.SendClientMessage('O jogador desafiante está morto.');
    Exit;
  end;
  if (Player.Base.PlayerCharacter.PlayerKill) then
  begin
    Player.SendClientMessage('Não possível duelar com o PvP ligado.');
    Exit;
  end;
  if (Player.Dueling) then
  begin
    Player.SendClientMessage('Você já está em um duelo.');
    Exit;
  end;
  Player.SendDuelTime;
  OtherPlayer.SendDuelTime;
  Player.CreateDuelSession(OtherPlayer);
end;
{$ENDREGION}
{$REGION 'Quest'}
class function TPacketHandlers.AbandonQuest(var Player: TPlayer;
  Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TAbandonQuestPacket absolute Buffer;
  QuestIndex, NpcIx: WORD;
begin
  if (Player.QuestExists(Packet.QuestID, QuestIndex)) then
  begin
    if(Servers[Player.ChannelIndex].NPCS[Player.PlayerQuests[QuestIndex].Quest.NPCID].Base.PlayerCharacter.LastPos.InRange(
      Player.Base.PlayerCharacter.LastPos, 30)) then
    begin
      NpcIx := Player.PlayerQuests[QuestIndex].Quest.NPCID;

      if(Player.PlayerQuests[QuestIndex].Quest.QuestMark = 11) then
      begin
        Player.PlayerQuests[QuestIndex].IsDone := True;
        Player.SendPacket(Packet, Packet.Header.Size);
      end
      else
      begin
        if not(Player.PlayerQuests[QuestIndex].IsDone) then
        begin
          ZeroMemory(@Player.PlayerQuests[QuestIndex],
            sizeof(Player.PlayerQuests[QuestIndex]));
          Player.SendPacket(Packet, Packet.Header.Size);
        end;
      end;

      Servers[Player.ChannelIndex].NPCS[NpcIx]
        .Base.SendCreateMob(SPAWN_NORMAL, Player.Base.ClientID, False);
    end
    else
    begin
      if(Player.PlayerQuests[QuestIndex].Quest.QuestMark = 11) then
      begin
        Player.PlayerQuests[QuestIndex].IsDone := True;
        Player.SendPacket(Packet, Packet.Header.Size);
      end
      else
      begin
        if not(Player.PlayerQuests[QuestIndex].IsDone) then
        begin
          ZeroMemory(@Player.PlayerQuests[QuestIndex],
            sizeof(Player.PlayerQuests[QuestIndex]));
          Player.SendPacket(Packet, Packet.Header.Size);
        end;
      end;
    end;
  end;
  Result := true;
end;
{$ENDREGION}
{$REGION 'Teleport do FC'}
class function TPacketHandlers.TeleportSetPosition(var Player: TPlayer;
  Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TTeleportFcPacket absolute Buffer;
begin
  if (Packet.Slot <= 5) then
  begin
    Player.TeleportList[Packet.Slot] := Player.Base.PlayerCharacter.LastPos;
    Packet.PosX := Round(Player.TeleportList[Packet.Slot].X);
    Packet.PosY := Round(Player.TeleportList[Packet.Slot].Y);
    Player.SendPacket(Packet, Packet.Header.Size);
    Player.SaveCharacterTeleportList
      (String(Player.Base.PlayerCharacter.Base.Name));
  end;
  Result := true;
end;
{$ENDREGION}
{$REGION 'Titles'}
class function TPacketHandlers.UpdateActiveTitle(var Player: TPlayer;
  Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSignalData absolute Buffer;
  I: BYTE;
begin
  Result := true;

  if (Packet.Data = 0) then
  begin
    Player.Base.SetOffTitleActiveEffect;
    ZeroMemory(@Player.Base.PlayerCharacter.ActiveTitle, sizeof(TTitle));
    Player.SendUpdateActiveTitle;
    Player.Base.GetCurrentScore;
    Player.Base.SendRefreshPoint;
    Player.Base.SendStatus;
    Player.Base.SendRefreshLevel;
    Player.Base.SendCurrentHPMP();

    Exit;
  end
  else
  begin
    Player.Base.SetOffTitleActiveEffect;
    //tirar o efeito aqui do titulo antigo
  end;

  for I := 0 to 95 do
  begin
    if (Player.Base.PlayerCharacter.Titles[I].Index = Packet.Data) then
    begin
      if(Player.Base.PlayerCharacter.Titles[I].Level = 0) then
        Continue;

      Player.Base.PlayerCharacter.ActiveTitle :=
        Player.Base.PlayerCharacter.Titles[I];
      Player.Base.SetOnTitleActiveEffect;
      //colocar o efeito do titulo aqui
      Player.SendUpdateActiveTitle;
      Break;
    end;
  end;

  Player.Base.GetCurrentScore;
  Player.Base.SendRefreshPoint;
  Player.Base.SendStatus;
  Player.Base.SendRefreshLevel;
  Player.Base.SendCurrentHPMP();
end;
{$ENDREGION}
{$REGION 'Pran'}
class function TPacketHandlers.RenamePran(var Player: TPlayer;
  Buffer: Array of BYTE): Boolean;
var
  Packet: TRenamePranPacket absolute Buffer;
  PranName: String;
begin
  Result := False;
  PranName := String(Packet.Name);

  if not(TFunctions.IsLetter(PranName)) then
  begin
    Player.SendClientMessage('O nome não pode conter esses caracteres.');
    Exit;
  end;

  if (TFunctions.VerifyNameAlreadyExists(Player, PranName)) then
  begin
    Player.SendClientMessage('O nome ja está em uso.');
    Exit;
  end;
  if (String(Player.Account.Header.Pran1.Name) = '') then
  begin
    AnsiStrings.StrPlCopy(Player.Account.Header.Pran1.Name,
      AnsiString(PranName), 16);
  end
  else if (String(Player.Account.Header.Pran2.Name) = '') then
  begin
    AnsiStrings.StrPlCopy(Player.Account.Header.Pran2.Name,
      AnsiString(PranName), 16);
  end
  else
  begin
    Player.SendClientMessage('Todas suas prans já possuem nome.');
    Exit;
  end;
  {
    if ((Player.Account.Header.Storage.Itens[84].Identific = Player.Account.
    Header.Pran1.ItemID) and not(Player.Account.Header.Storage.Itens[84]
    .Identific = 0)) then
    begin // colocar nome no slot1 de pran
    AnsiStrings.StrPlCopy(Player.Account.Header.Pran1.Name, PranName, 16);
    end
    else if ((Player.Account.Header.Storage.Itens[85].Identific = Player.Account.
    Header.Pran1.ItemID) and not(Player.Account.Header.Storage.Itens[85]
    .Identific = 0)) then
    begin // colocar nome no slot1 de pran
    AnsiStrings.StrPlCopy(Player.Account.Header.Pran1.Name, PranName, 16);
    end
    else if ((Player.Account.Header.Storage.Itens[84].Identific = Player.Account.
    Header.Pran2.ItemID) and not(Player.Account.Header.Storage.Itens[84]
    .Identific = 0)) then
    begin // colocar nome no slot2 de pran
    AnsiStrings.StrPlCopy(Player.Account.Header.Pran2.Name, PranName, 16);
    end
    else if ((Player.Account.Header.Storage.Itens[85].Identific = Player.Account.
    Header.Pran2.ItemID) and not(Player.Account.Header.Storage.Itens[85]
    .Identific = 0)) then
    begin // colocar nome no slot2 de pran
    AnsiStrings.StrPlCopy(Player.Account.Header.Pran2.Name, PranName, 16);
    <<<<<<< Updated upstream
    end
    else
    begin
    Player.SendClientMessage('Todas suas prans possuem nome.');
    =======
    end
    else
    begin
    Player.SendClientMessage('Todas suas prans ossuem nome.');
    >>>>>>> Stashed changes
    Exit;
    end; }
  Packet.AccountId := Player.Account.Header.AccountId;
  Player.Base.SendRefreshItemSlot(STORAGE_TYPE, 84,
    Player.Account.Header.Storage.Itens[84], False);
  Player.Base.SendRefreshItemSlot(STORAGE_TYPE, 85,
    Player.Account.Header.Storage.Itens[85], False);
  Player.SendPacket(Packet, Packet.Header.Size);
  Result := true;
end;
{$ENDREGION}
{$REGION 'Mail'}
class function TPacketHandlers.openMail(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TOpenMailPacket absolute Buffer;
  dwGold: DWORD;
  itemCount: BYTE;
begin
  Result := False;
  case Packet.OpenType of
{$REGION 'Ver conteúdo da carta'}
    0:
      begin
        if (TEntityMail.sendMailContent(Player, Packet.Index)) then
          TEntityMail.setMailRead(Player, Packet.Index)
        else
          Exit;
      end;
{$ENDREGION}
{$REGION 'Remove carta'}
    1:
      begin
        if not(TEntityMail.deleteMail(Player, Packet.Index)) then
          Exit;
        Packet.Slot := 0;
        Packet.CharIndex := Player.Character.Index;
        Packet.Delete := true;
        Player.SendPacket(Packet, Packet.Header.Size);
        TEntityMail.sendMailList(Player);
        Player.SendClientMessage('Correio excluído.');
      end;
{$ENDREGION}
{$REGION 'Devolver carta'}
    2:
      begin
        if not(TEntityMail.returnEmail(Player, Packet.Index)) then
        begin
          Exit;
        end;
        Packet.Slot := 0;
        Packet.CharIndex := Player.Character.Index;
        Packet.Delete := true;
        Player.SendPacket(Packet, Packet.Header.Size);
        TEntityMail.sendMailList(Player);
        Player.SendClientMessage('Correio retornado.');
      end;
{$ENDREGION}
{$REGION 'Pegar Gold Carta'}
    3:
      begin
        if not(TEntityMail.getMailGold(Player, Packet.Index, dwGold)) then
          Exit;
        if (dwGold = 0) then
          Exit;
        if not(TEntityMail.withdrawGold(Player, Packet.Index)) then
          Exit;
        Player.AddGold(dwGold);
        if not(TEntityMail.getMailItemCount(Player, Packet.Index, itemCount))
        then
        begin
          Exit;
        end;
        if (itemCount = 0) then
        begin
          Packet.Delete := true;
        end;
        Packet.CharIndex := Player.Base.Character.CharIndex;
        Player.SendPacket(Packet, Packet.Header.Size);
        Player.SendClientMessage('Gold recolhido.');
      end;
{$ENDREGION}
  end;
  Result := true;
end;
class function TPacketHandlers.withdrawMailItem(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TGetMailContentPacket absolute Buffer;
  Item: TItem;
  itemCount: BYTE;
  itemIndex: UInt64;
begin
  Result := False;
  if(TItemFunctions.GetEmptySlot(Player) = 255) then
  begin
    Player.SendClientMessage('Inventário cheio.');
    Exit;
  end;
  if (Packet.Slot > 4) then
  begin
    Exit;
  end;
  itemIndex := 0;
  if not(TEntityMail.getMailItemSlot(Player, Packet.Index, Packet.Slot, Item,
    itemIndex)) then
    Exit;
  if (Item.Index = 0) or (itemIndex = 0) then
    Exit;
  if (TItemFunctions.PutItem(Player, Item, 0, true) = -1) then
  begin
    Exit;
  end;
  TEntityMail.withdrawItem(Player, itemIndex, Packet.Index);
  if not(TEntityMail.getMailItemCount(Player, Packet.Index, itemCount)) then
    Exit;
  if (itemCount = 0) then
  begin
    TEntityMail.setAllItemsWithdraw(Player, Packet.Index);
  end;
  TEntityMail.sendMailContent(Player, Packet.Index);
  if (itemCount = 0) then
  begin
    TEntityMail.sendMailList(Player);
  end;
  Result := true;
end;
class function TPacketHandlers.checkSendMailRequirements(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TSendMailPacket absolute Buffer;
  Nation: TCitizenship;
begin
  Result := False;
  if not(TFunctions.GetCharacterNation(string(Packet.Nick), Nation)) then
  begin
    Packet.Send := BOOL_REFUSE;
    Player.SendPacket(Packet, Packet.Header.Size);
    Exit;
  end;
  if not(Player.Account.Header.Nation = TCitizenship.None) and
    (Player.Account.Header.Nation <> Nation) then
  begin
    Packet.Send := BOOL_REFUSE;
    Packet.Nation := Integer(Nation);
    Player.SendPacket(Packet, Packet.Header.Size);
    Exit;
  end;
  Packet.Send := BOOL_ACCEPT;
  Packet.Nation := Integer(Nation);
  Player.SendPacket(Packet, Packet.Header.Size);
  Player.CanSendMailTo := string(Packet.Nick);
  Result := true;
end;
class function TPacketHandlers.sendCharacterMail(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TContentMailPacket absolute Buffer;
  I: Integer;
  mailIndex: UInt64;
begin
  Result := False;
  if (string(Packet.Content.Nick) <> Player.CanSendMailTo) then
  begin
    Logger.Write('name differs from original target', TLogType.Packets);
    Exit;
  end;
  if not(Player.Character.Base.Gold >= 500) then
  begin
    Player.CanSendMailTo := '';
    Player.SendClientMessage('Não possuí gold suficiente.');
    Player.SendData(Player.Base.ClientId, $3F15, BOOL_REFUSE);
    Exit;
  end;
  if not(Player.Character.Base.Gold >= Packet.Content.Gold) then
  begin
    Player.CanSendMailTo := '';
    Player.SendClientMessage('Você não possui todo esse gold, sabia?');
    Player.SendData(Player.Base.ClientId, $3F15, BOOL_REFUSE);
    Exit;
  end;
  Player.DecGold(500);
  Player.DecGold(Packet.Content.Gold);
  if not(TEntityMail.AddMail(Player, Packet.Content, mailIndex)) then
  begin
    Logger.Write('add mail fail', TLogType.Packets);
    Exit;
  end;
  for I := 0 to 4 do
  begin
    if (Packet.Content.ItemSlot[I] = $FF) then
      Continue;
    if(ItemList[Player.Character.Base.Inventory[Packet.Content.ItemSlot[I]].Index].TypeTrade <> 0) then
      Continue;
    if not(TEntityMail.addMailItem(Player, Packet.Content.ItemSlot[I], I,
      mailIndex)) then
      Exit;
    ZeroMemory(@Player.Character.Base.Inventory[Packet.Content.ItemSlot[I]],
      sizeof(TItem));
    Player.Base.SendRefreshItemSlot(Packet.Content.ItemSlot[I], False);
  end;
  Player.SendData(Player.Base.ClientId, $3F15, BOOL_ACCEPT);
  Player.SendClientMessage('Correio enviado.');
  Player.CanSendMailTo := '';
end;
{$ENDREGION}
{$REGION 'Dungeons'}
class function TPacketHandlers.RequestEnterDungeon(var Player: TPlayer;
  Buffer: Array of BYTE): Boolean;
var
  Packet: TSelectDungeonToEnter absolute Buffer;
  I: WORD;
begin
  Result := False;
  player.SendClientMessage('Dungeons estão indisponíveis por enquanto.');
  exit;
  if (Player.OpennedOption = 26) then
  begin
    if (Player.PartyIndex <> 0) then
    begin // está em pt
      if (Player.Party.Leader <> Player.Base.ClientId) then
      begin
        Player.SendClientMessage('Você não é o lider do grupo.');
        Exit;
      end;
      case Player.OpennedNPC of
        DUNGEON_NPC_PRISON:
          begin
            // soon
          end;
        DUNGEON_NPC_MINA_1:
          begin
            for I in Player.Party.Members do
            begin
              if (Servers[Player.ChannelIndex].DGMines1[Packet.Dificult]
                .LevelMin > Servers[Player.ChannelIndex].Players[I]
                .Base.Character.Level) then
              begin
                Player.SendClientMessage('A dungeon selecionada requer nivel ['
                  + AnsiString(Servers[Player.ChannelIndex].DGMines1
                  [Packet.Dificult].LevelMin.ToString) + '].');
                Exit;
              end;
            end;
            Player.SendDungeonLobby(true, DUNGEON_LOST_MINES, Packet.Dificult);
          end;
        DUNGEON_NPC_MINA_2:
          begin
            // soon
          end;
        DUNGEON_NPC_EVG_INF:
          begin
            for I in Player.Party.Members do
            begin
              if (Servers[Player.ChannelIndex].DGEvgInf[Packet.Dificult]
                .LevelMin > Servers[Player.ChannelIndex].Players[I]
                .Base.Character.Level) then
              begin
                Player.SendClientMessage('A dungeon selecionada requer nivel ['
                  + AnsiString(Servers[Player.ChannelIndex].DGEvgInf
                  [Packet.Dificult].LevelMin.ToString) + '].');
                Exit;
              end;
            end;
            Player.SendDungeonLobby(true, DUNGEON_MARAUDER_HOLD,
              Packet.Dificult);
          end;
        DUNGEON_NPC_EVG_SUP:
          begin
            for I in Player.Party.Members do
            begin
              if (Servers[Player.ChannelIndex].DGEvgSup[Packet.Dificult]
                .LevelMin > Servers[Player.ChannelIndex].Players[I]
                .Base.Character.Level) then
              begin
                Player.SendClientMessage('A dungeon selecionada requer nivel ['
                  + AnsiString(Servers[Player.ChannelIndex].DGEvgSup
                  [Packet.Dificult].LevelMin.ToString) + '].');
                Exit;
              end;
            end;
            Player.SendDungeonLobby(true, DUNGEON_MARAUDER_CABIN,
              Packet.Dificult);
          end;
        DUNGEON_NPC_URSULA:
          begin
            for I in Player.Party.Members do
            begin
              if (Servers[Player.ChannelIndex].DGUrsula[Packet.Dificult]
                .LevelMin > Servers[Player.ChannelIndex].Players[I]
                .Base.Character.Level) then
              begin
                Player.SendClientMessage('A dungeon selecionada requer nivel ['
                  + AnsiString(Servers[Player.ChannelIndex].DGUrsula
                  [Packet.Dificult].LevelMin.ToString) + '].');
                Exit;
              end;
            end;
            Player.SendDungeonLobby(true, DUNGEON_ZANTORIAN_CITADEL,
              Packet.Dificult);
          end;
        DUNGEON_NPC_KINARY:
          begin
            for I := Low(Player.Party.Members.ToArray)
              to High(Player.Party.Members.ToArray) do
            begin
              if (Servers[Player.ChannelIndex].DGKinary[Packet.Dificult]
                .LevelMin > Servers[Player.ChannelIndex].Players[I]
                .Base.Character.Level) then
              begin
                Player.SendClientMessage('A dungeon selecionada requer nivel ['
                  + AnsiString(Servers[Player.ChannelIndex].DGKinary
                  [Packet.Dificult].LevelMin.ToString) + '].');
                Exit;
              end;
            end;
            Player.SendDungeonLobby(true, DUNGEON_KINARY_AVIARY,
              Packet.Dificult);
          end;
      end;
    end
    else
    begin
      case Player.OpennedNPC of
        DUNGEON_NPC_PRISON:
          begin
            // soon
          end;
        DUNGEON_NPC_MINA_1:
          begin
            if (Servers[Player.ChannelIndex].DGMines1[Packet.Dificult].LevelMin
              > Player.Base.Character.Level) then
            begin
              Player.SendClientMessage('A dungeon selecionada requer nivel [' +
                AnsiString(Servers[Player.ChannelIndex].DGMines1
                [Packet.Dificult].LevelMin.ToString) + '].');
              Exit;
            end;
            Player.SendDungeonLobby(False, DUNGEON_LOST_MINES, Packet.Dificult);
          end;
        DUNGEON_NPC_MINA_2:
          begin
            // soon
          end;
        DUNGEON_NPC_EVG_INF:
          begin
            if (Servers[Player.ChannelIndex].DGEvgInf[Packet.Dificult].LevelMin
              > Player.Base.Character.Level) then
            begin
              Player.SendClientMessage('A dungeon selecionada requer nivel [' +
                AnsiString(Servers[Player.ChannelIndex].DGEvgInf
                [Packet.Dificult].LevelMin.ToString) + '].');
              Exit;
            end;
            Player.SendDungeonLobby(False, DUNGEON_MARAUDER_HOLD,
              Packet.Dificult);
          end;
        DUNGEON_NPC_EVG_SUP:
          begin
            if (Servers[Player.ChannelIndex].DGEvgSup[Packet.Dificult].LevelMin
              > Player.Base.Character.Level) then
            begin
              Player.SendClientMessage('A dungeon selecionada requer nivel [' +
                AnsiString(Servers[Player.ChannelIndex].DGEvgSup
                [Packet.Dificult].LevelMin.ToString) + '].');
              Exit;
            end;
            Player.SendDungeonLobby(False, DUNGEON_MARAUDER_CABIN,
              Packet.Dificult);
          end;
        DUNGEON_NPC_URSULA:
          begin
            if (Servers[Player.ChannelIndex].DGUrsula[Packet.Dificult].LevelMin
              > Player.Base.Character.Level) then
            begin
              Player.SendClientMessage('A dungeon selecionada requer nivel [' +
                AnsiString(Servers[Player.ChannelIndex].DGUrsula
                [Packet.Dificult].LevelMin.ToString) + '].');
              Exit;
            end;
            Player.SendDungeonLobby(False, DUNGEON_ZANTORIAN_CITADEL,
              Packet.Dificult);
          end;
        DUNGEON_NPC_KINARY:
          begin
            if (Servers[Player.ChannelIndex].DGKinary[Packet.Dificult].LevelMin
              > Player.Base.Character.Level) then
            begin
              Player.SendClientMessage('A dungeon selecionada requer nivel [' +
                AnsiString(Servers[Player.ChannelIndex].DGKinary
                [Packet.Dificult].LevelMin.ToString) + '].');
              Exit;
            end;
            Player.SendDungeonLobby(False, DUNGEON_KINARY_AVIARY,
              Packet.Dificult);
          end;
      end;
    end;
  end;
  Result := true;
end;
class function TPacketHandlers.DungeonLobbyConfirm(var Player: TPlayer;
  Buffer: Array of BYTE): Boolean;
var
  Packet: TConfirmDungeonEnter absolute Buffer;
  PacketToSend: TSelectDungeonToEnter;
  I, cnt: WORD;
begin
  if (Packet.Index = 0) then
  begin // alguem desistiu, fechar pra todos
    if (Player.PartyIndex <> 0) then
    begin
      for I in Player.Party.Members do
      begin
        Servers[Player.ChannelIndex].Players[I].SendClientMessage
          ('[' + AnsiString(Player.Base.Character.Name) +
          '] se recusou a entrar na dungeon.');
        if (I = Player.Base.ClientId) then
          Continue;
        Servers[Player.ChannelIndex].SendPacketTo(I, Packet,
          Packet.Header.Size);
      end;
    end
    else
    begin
      Player.SendClientMessage('[' + AnsiString(Player.Base.Character.Name) +
        '] se recusou a entrar na dungeon.');
    end;
  end
  else
  begin
    if (Player.PartyIndex <> 0) then
    begin
      SetLength(Player.Party.DungeonLobbyConfirm, Player.Party.Members.Count);
      for I := Low(Player.Party.Members.ToArray)
        to High(Player.Party.Members.ToArray) do
      begin
        if (Player.Party.Members.ToArray[I] = Packet.Header.Index) then
        begin
          Player.Party.DungeonLobbyConfirm[I] := Packet.Header.Index;
          Player.Party.SendToParty(Packet, Packet.Header.Size);
          Break;
        end;
      end;
      cnt := 0;
      for I := Low(Player.Party.DungeonLobbyConfirm)
        to High(Player.Party.DungeonLobbyConfirm) do
      begin
        if (Player.Party.DungeonLobbyConfirm[I] > 0) then
          Inc(cnt);
      end;
      if (cnt = Length(Player.Party.DungeonLobbyConfirm)) then
      begin
        Player.createDungeonInstance(true, Player.DungeonLobbyIndex,
          Player.DungeonLobbyDificult);
        for I in Player.Party.Members do
        begin
          PacketToSend.Header.Size := sizeof(PacketToSend);
          PacketToSend.Header.Index := I;
          PacketToSend.Header.Code := $334;
          PacketToSend.Dificult := Player.DungeonInstanceID;
          Servers[Player.ChannelIndex].Players[I].SendPacket(PacketToSend,
            PacketToSend.Header.Size);
        end;
      end;
    end
    else
    begin
      Player.SendPacket(Packet, Packet.Header.Size);
      Player.createDungeonInstance(False, Player.DungeonLobbyIndex,
        Player.DungeonLobbyDificult);
      PacketToSend.Header.Size := sizeof(PacketToSend);
      PacketToSend.Header.Index := Player.Base.ClientId;
      PacketToSend.Header.Code := $334;
      PacketToSend.Dificult := Player.DungeonInstanceID;
      Player.SendPacket(PacketToSend, PacketToSend.Header.Size);
    end;
  end;
  Result := true;
end;
{$ENDREGION}
{$REGION 'Make Items'}
class function TPacketHandlers.MakeItem(var Player: TPlayer;
  Buffer: Array of BYTE): Boolean;
type
  TItemRequired = packed record
    ItemID, Amount, Slot: WORD;
  end;
var
  Packet: TMakeItemPacket absolute Buffer;
  MIIndex, RandomTax: WORD;
  I, cnt, EmptySlot: WORD;
  CurrentAmount, CurrentSlot: BYTE;
  ItemsRequired: Array of TItemRequired;
  VaizanSlot: BYTE;
  Helper1: Integer;
begin
  Result := False;
  if (Packet.Null3 = 1) then
  begin // not make item, destroying item here
    case (TItemFunctions.GetItemEquipSlot(Player.Base.Character.Inventory
      [Packet.ItemID].Index)) of
      2 .. 7, 11 .. 14:
        begin
          case ItemList[Player.Base.Character.Inventory[Packet.ItemID].
            Index].Level of
            1 .. 10:
              begin
                Randomize;
                RandomTax := Level_10_Destroy_Range
                  [RandomRange(0, Length(Level_10_Destroy_Range))];
                cnt := RandomRange(1,6); // até 255 itens por destruição
                TItemFunctions.RemoveItem(Player, INV_TYPE, Packet.ItemID);
                TItemFunctions.PutItem(Player, RandomTax, cnt);
              end;
            11 .. 20:
              begin
                Randomize;
                RandomTax := Level_10_Destroy_Range
                  [RandomRange(0, Length(Level_10_Destroy_Range))];
                cnt := RandomRange(1,6); // até 255 itens por destruição
                TItemFunctions.RemoveItem(Player, INV_TYPE, Packet.ItemID);
                TItemFunctions.PutItem(Player, RandomTax, cnt);
              end;
            21 .. 30:
              begin
                Randomize;
                RandomTax := Level_20_Destroy_Range
                  [RandomRange(0, Length(Level_20_Destroy_Range))];
                cnt := RandomRange(1,6); // até 255 itens por destruição
                TItemFunctions.RemoveItem(Player, INV_TYPE, Packet.ItemID);
                TItemFunctions.PutItem(Player, RandomTax, cnt);
              end;
            31 .. 40:
              begin
                Randomize;
                RandomTax := Level_30_Destroy_Range
                  [RandomRange(0, Length(Level_30_Destroy_Range))];
                cnt := RandomRange(1,6); // até 255 itens por destruição
                TItemFunctions.RemoveItem(Player, INV_TYPE, Packet.ItemID);
                TItemFunctions.PutItem(Player, RandomTax, cnt);
              end;
            41 .. 50:
              begin
                Randomize;
                RandomTax := Level_40_Destroy_Range
                  [RandomRange(0, Length(Level_40_Destroy_Range))];
                cnt := RandomRange(1,6); // até 255 itens por destruição
                TItemFunctions.RemoveItem(Player, INV_TYPE, Packet.ItemID);
                TItemFunctions.PutItem(Player, RandomTax, cnt);
              end;
            51 .. 60:
              begin
                Randomize;
                RandomTax := Level_50_Destroy_Range
                  [RandomRange(0, Length(Level_50_Destroy_Range))];
                cnt := RandomRange(1,6); // até 255 itens por destruição
                TItemFunctions.RemoveItem(Player, INV_TYPE, Packet.ItemID);
                TItemFunctions.PutItem(Player, RandomTax, cnt);
              end;
            61 .. 70:
              begin
                Randomize;
                RandomTax := Level_60_Destroy_Range
                  [RandomRange(0, Length(Level_60_Destroy_Range))];
                cnt := RandomRange(1,6); // até 255 itens por destruição
                TItemFunctions.RemoveItem(Player, INV_TYPE, Packet.ItemID);
                TItemFunctions.PutItem(Player, RandomTax, cnt);
              end;
            71 .. 80:
              begin
                Randomize;
                RandomTax := Level_70_Destroy_Range
                  [RandomRange(0, Length(Level_70_Destroy_Range))];
                cnt := RandomRange(1,6); // até 255 itens por destruição
                TItemFunctions.RemoveItem(Player, INV_TYPE, Packet.ItemID);
                TItemFunctions.PutItem(Player, RandomTax, cnt);
              end;
            81 .. 90:
              begin
                Randomize;
                RandomTax := Level_80_Destroy_Range
                  [RandomRange(0, Length(Level_80_Destroy_Range))];
                cnt := RandomRange(1,8); // até 255 itens por destruição
                TItemFunctions.RemoveItem(Player, INV_TYPE, Packet.ItemID);
                TItemFunctions.PutItem(Player, RandomTax, cnt);
              end;
            91 .. 99:
              begin
                Randomize;
                RandomTax := Level_90_Destroy_Range
                  [RandomRange(0, Length(Level_90_Destroy_Range))];
                cnt := RandomRange(1,8); // até 255 itens por destruição
                TItemFunctions.RemoveItem(Player, INV_TYPE, Packet.ItemID);
                TItemFunctions.PutItem(Player, RandomTax, cnt);
              end;
          else
            begin
              Player.SendClientMessage('Este item não pode ser desmontado.');
              Exit;
            end;
          end;
        end;
    else
      begin
        Player.SendClientMessage('Este item não pode ser desmontado.');
        Exit;
      end;
    end;
    Player.SendClientMessage('Item desmontado com sucesso.');
    Packet.ItemID := 0;
    Packet.Null := 0;
    Packet.Amount := 0;
    Packet.Null2 := 0;
    Packet.Null3 := 0;
    Packet.Null4 := 0;
    Player.SendPacket(Packet, Packet.Header.Size);
    Exit;
  end
  else if ((Packet.Null3 = 3) or (Packet.Null3 = 4)) then // limpar adds
  begin
    if (TItemFunctions.CanAgroup(Player.Base.Character.Inventory[Packet.ItemID]))
    then
    begin
      Player.SendClientMessage('Esse item não pode ser limpo.');
      Exit;
    end;
    case ItemList[Player.Base.Character.Inventory[Packet.ItemID].Index]
      .TypeItem of
      TYPE_ITEM_NORMAL:
        begin
          if (Packet.Amount = 0) then
          begin // vaizan que limpa tudo
            VaizanSlot := TItemFunctions.GetItemSlotByItemType(Player, 513,
              INV_TYPE);
            if (VaizanSlot = 255) then
            begin
              Player.SendClientMessage
                ('Você deve possuir o item Vaizan Cinza [Normal].');
              Exit;
            end;
          end
          else // vaizan selecionavel
          begin
            VaizanSlot := TItemFunctions.GetItemSlotByItemType(Player, 513,
              INV_TYPE);
            if (VaizanSlot = 255) then
            begin
              Player.SendClientMessage
                ('Você deve possuir o item Vaizan Cinza [Selecione].');
              Exit;
            end;
          end;
        end;
      TYPE_ITEM_RARE_SUPERIOR, TYPE_ITEM_SUPERIOR:
        begin
          if (Packet.Amount = 0) then
          begin // vaizan que limpa tudo
            VaizanSlot := TItemFunctions.GetItemSlotByItemType(Player, 514,
              INV_TYPE);
            if (VaizanSlot = 255) then
            begin
              Player.SendClientMessage
                ('Você deve possuir o item Vaizan Colorido [Superior].');
              Exit;
            end;
          end
          else // vaizan selecionavel
          begin
            VaizanSlot := TItemFunctions.GetItemSlotByItemType(Player, 514,
              INV_TYPE);
            if (VaizanSlot = 255) then
            begin
              Player.SendClientMessage
                ('Você deve possuir o item Vaizan Colorido [Selecione].');
              Exit;
            end;
          end;
        end;
      TYPE_ITEM_RARO, TYPE_ITEM_LEGENDARY:
        begin
          if (Packet.Amount = 0) then
          begin // vaizan que limpa tudo
            VaizanSlot := TItemFunctions.GetItemSlotByItemType(Player, 515,
              INV_TYPE);
            if (VaizanSlot = 255) then
            begin
              Player.SendClientMessage
                ('Você deve possuir o item Vaizan Brilhante [Raro].');
              Exit;
            end;
          end
          else // vaizan selecionavel
          begin
            VaizanSlot := TItemFunctions.GetItemSlotByItemType(Player, 515,
              INV_TYPE);
            if (VaizanSlot = 255) then
            begin
              Player.SendClientMessage
                ('Você deve possuir o item Vaizan Brilhante [Selecione].');
              Exit;
            end;
          end;
        end;
      TYPE_ITEM_PREMIUM:
        begin
          Player.SendClientMessage('Itens de cash não podem ser limpos.');
          Exit;
        end;
    end;
    case Packet.Amount of
      0: // limpar todos
        begin
          ZeroMemory(@Player.Base.Character.Inventory[Packet.ItemID]
            .Effects, 6);
          if (Player.Base.Character.Inventory[VaizanSlot].Refi > 1) then
          begin
            Dec(Player.Base.Character.Inventory[VaizanSlot].Refi, 1);
            Player.Base.SendRefreshItemSlot(INV_TYPE, VaizanSlot,
              Player.Base.Character.Inventory[VaizanSlot], False);
          end
          else
            TItemFunctions.RemoveItem(Player, INV_TYPE, VaizanSlot);
          Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.ItemID,
            Player.Base.Character.Inventory[Packet.ItemID], False);
          Player.SendClientMessage('Adicionais do item limpos com sucesso.');
          Player.SendPacket(Packet, Packet.Header.Size);
          Exit;
        end;
      1: // vaizan selecionavel, slot 1
        begin
          if(Player.Base.Character.Inventory[Packet.ItemID].Effects.Index[0] = 0) then
          begin
            if(Player.Base.Character.Inventory[Packet.ItemID].Effects.Index[1] = 0) then
            begin
              Player.Base.Character.Inventory[Packet.ItemID].Effects.Index[2] := 0;
              Player.Base.Character.Inventory[Packet.ItemID].Effects.Value[2] := 0;
            end
            else
            begin
              Player.Base.Character.Inventory[Packet.ItemID].Effects.Index[1] := 0;
              Player.Base.Character.Inventory[Packet.ItemID].Effects.Value[1] := 0;
            end;
          end
          else
          begin
            Player.Base.Character.Inventory[Packet.ItemID].Effects.Index[0] := 0;
            Player.Base.Character.Inventory[Packet.ItemID].Effects.Value[0] := 0;
          end;
          if (Player.Base.Character.Inventory[VaizanSlot].Refi > 1) then
          begin
            TItemFunctions.DecreaseAmount(
            @Player.Base.Character.Inventory[VaizanSlot], 1);
            //Player.Base.SendRefreshItemSlot(INV_TYPE, VaizanSlot,
              //Player.Base.Character.Inventory[VaizanSlot], False);
          end
          else
            TItemFunctions.RemoveItem(Player, INV_TYPE, VaizanSlot);

          Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.ItemID,
            Player.Base.Character.Inventory[Packet.ItemID], False);
          Player.Base.SendRefreshItemSlot(INV_TYPE, VaizanSlot,
              Player.Base.Character.Inventory[VaizanSlot], False);
          Player.SendClientMessage('Adicionais do item limpos com sucesso.');
          Player.SendPacket(Packet, Packet.Header.Size);
          Exit;
        end;
      2: // vaizan selecionavel, slot 2
        begin
          if(Player.Base.Character.Inventory[Packet.ItemID].Effects.Index[1] = 0) then
          begin
            Player.Base.Character.Inventory[Packet.ItemID].Effects.Index[2] := 0;
            Player.Base.Character.Inventory[Packet.ItemID].Effects.Value[2] := 0;
          end
          else
          begin
            Player.Base.Character.Inventory[Packet.ItemID].Effects.Index[1] := 0;
            Player.Base.Character.Inventory[Packet.ItemID].Effects.Value[1] := 0;
          end;
          if (Player.Base.Character.Inventory[VaizanSlot].Refi > 1) then
          begin
            TItemFunctions.DecreaseAmount(
            @Player.Base.Character.Inventory[VaizanSlot], 1);
            //Player.Base.SendRefreshItemSlot(INV_TYPE, VaizanSlot,
              //Player.Base.Character.Inventory[VaizanSlot], False);
          end
          else
            TItemFunctions.RemoveItem(Player, INV_TYPE, VaizanSlot);
          Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.ItemID,
            Player.Base.Character.Inventory[Packet.ItemID], False);
          Player.Base.SendRefreshItemSlot(INV_TYPE, VaizanSlot,
              Player.Base.Character.Inventory[VaizanSlot], False);
          Player.SendClientMessage('Adicionais do item limpos com sucesso.');
          Player.SendPacket(Packet, Packet.Header.Size);
          Exit;
        end;
      3: // vaizan selecionavel, slot 3
        begin
          if(Player.Base.Character.Inventory[Packet.ItemID].Effects.Index[2] = 0) then
          begin
            if(Player.Base.Character.Inventory[Packet.ItemID].Effects.Index[1] = 0) then
            begin
              Player.Base.Character.Inventory[Packet.ItemID].Effects.Index[0] := 0;
              Player.Base.Character.Inventory[Packet.ItemID].Effects.Value[0] := 0;
            end
            else
            begin
              Player.Base.Character.Inventory[Packet.ItemID].Effects.Index[1] := 0;
              Player.Base.Character.Inventory[Packet.ItemID].Effects.Value[1] := 0;
            end;
          end
          else
          begin
            Player.Base.Character.Inventory[Packet.ItemID].Effects.Index[2] := 0;
            Player.Base.Character.Inventory[Packet.ItemID].Effects.Value[2] := 0;
          end;
          if (Player.Base.Character.Inventory[VaizanSlot].Refi > 1) then
          begin
            TItemFunctions.DecreaseAmount(
            @Player.Base.Character.Inventory[VaizanSlot], 1);
            //Player.Base.SendRefreshItemSlot(INV_TYPE, VaizanSlot,
              //Player.Base.Character.Inventory[VaizanSlot], False);
          end
          else
            TItemFunctions.RemoveItem(Player, INV_TYPE, VaizanSlot);
          Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.ItemID,
            Player.Base.Character.Inventory[Packet.ItemID], False);
          Player.Base.SendRefreshItemSlot(INV_TYPE, VaizanSlot,
              Player.Base.Character.Inventory[VaizanSlot], False);
          Player.SendClientMessage('Adicionais do item limpos com sucesso.');
          Player.SendPacket(Packet, Packet.Header.Size);
          Exit;
        end;
    end;
  end
  else if (Packet.Null3 = 6) then // limpar aparencia
  begin
    if (TItemFunctions.CanAgroup(Player.Base.Character.Inventory[Packet.ItemID]))
    then
    begin
      Player.SendClientMessage('Esse item não pode ser limpo.');
      Exit;
    end;
    if (Player.Base.Character.Inventory[Packet.ItemID].APP = 0) then
    begin
      Player.SendClientMessage('Esse item não possui aparencia.');
      Exit;
    end;
    if (Player.Base.Character.Inventory[Packet.ItemID].
      Index = Player.Base.Character.Inventory[Packet.ItemID].APP) then
    begin
      Player.SendClientMessage('Esse item já está limpo.');
      Exit;
    end;
    VaizanSlot := TItemFunctions.GetItemSlotByItemType(Player, 517, INV_TYPE);
    if (VaizanSlot = 255) then
    begin
      Player.SendClientMessage
        ('Você deve possuir o item Pedra Mágica da Restauração.');
      Exit;
    end;
    Player.Base.Character.Inventory[Packet.ItemID].APP :=
      Player.Base.Character.Inventory[Packet.ItemID].Index;
    if (Player.Base.Character.Inventory[VaizanSlot].Refi > 1) then
    begin
      Dec(Player.Base.Character.Inventory[VaizanSlot].Refi, 1);
      Player.Base.SendRefreshItemSlot(INV_TYPE, VaizanSlot,
        Player.Base.Character.Inventory[VaizanSlot], False);
    end
    else
      TItemFunctions.RemoveItem(Player, INV_TYPE, VaizanSlot);
    Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.ItemID,
      Player.Base.Character.Inventory[Packet.ItemID], False);
    Player.SendClientMessage('Aparência do item removida.');
    Player.SendPacket(Packet, Packet.Header.Size);
    Exit;
  end;
  MIIndex := TFunctions.SearchMakeItemIDByRewardID(Packet.ItemID);
  if (MIIndex = 3000) then
  begin
    Player.SendClientMessage('Item não encontrado na forja.');
    Exit;
  end;
  if (MakeItems[MIIndex].LevelMin + 1 > Player.Base.Character.Level) then
  begin
    Player.SendClientMessage('Você não possui o nível necessário.');
    Exit;
  end;
  if ((MakeItems[MIIndex].Price*Packet.Amount) > Player.Base.Character.Gold) then
  begin
    Player.SendClientMessage('Você não possui o gold necessário. '+
    (MakeItems[MIIndex].Price*Packet.Amount).ToString + ' necessários.');
    Exit;
  end;
  EmptySlot := TItemFunctions.GetEmptySlot(Player);
  if (EmptySlot = 255) then
  begin
    Player.SendClientMessage('Inventário cheio.');
    Exit;
  end;
  Helper1 :=1;
  if not(TItemFunctions.GetItemEquipSlot(MakeItems[MIIndex].ResultItemID) in
    [2,3,4,5,6,7,11,12,13,14]) then
  begin
    Helper1 := Packet.Amount;
  end;

  cnt := 1;
  for I := Low(MakeItemsIngredients) to High(MakeItemsIngredients) do
  begin
    if not(MakeItems[MIIndex].ResultItemID = MakeItemsIngredients[I].Id) then
      Continue;
    if(Helper1=0) then
      Helper1 := 1;
    SetLength(ItemsRequired, cnt);
    ItemsRequired[cnt - 1].ItemID := MakeItemsIngredients[I].ItemID;
    ItemsRequired[cnt - 1].Amount := MakeItemsIngredients[I].Amount*Helper1;
    if (TItemFunctions.GetItemSlotAndAmountByIndex(Player,
      ItemsRequired[cnt - 1].ItemID, CurrentSlot, CurrentAmount)) then
    begin
      if (CurrentAmount < ItemsRequired[cnt - 1].Amount) then
      begin
        Player.SendClientMessage('Você precisa de (' +
          AnsiString(ItemsRequired[cnt - 1].Amount.ToString) + ') do item [' +
          AnsiString(ItemList[ItemsRequired[cnt - 1].ItemID].Name) + '].');
        Exit
      end;
    end
    else
    begin
      Player.SendClientMessage('Você precisa ter o item [' +
        AnsiString(ItemList[ItemsRequired[cnt - 1].ItemID].Name) + ']. Separe a quantidade correta em apenas UM slot.');
      Exit;
    end;
    ItemsRequired[cnt - 1].Slot := CurrentSlot;
    Inc(cnt);
  end;
  Randomize;
  RandomTax := RandomRange(1, (MakeItems[MIIndex].TaxSuccess div 10)+1);
  if (RandomTax <= (MakeItems[MIIndex].TaxSuccess div 10)) then
  begin
    Player.SendClientMessage('A criação do item foi bem sucedida.');
    Player.DecGold(MakeItems[MIIndex].Price*Helper1);
    TItemFunctions.PutItem(Player, MakeItems[MIIndex].ResultItemID,
      Helper1);
    for I := Low(ItemsRequired) to High(ItemsRequired) do
    begin
      if((TItemFunctions.GetItemEquipSlot(ItemsRequired[I].ItemID) >= 2) and
        (TItemFunctions.GetItemEquipSlot(ItemsRequired[I].ItemID) <= 14)) then
      begin
        TItemFunctions.RemoveItem(Player, INV_TYPE, ItemsRequired[I].Slot);
      end
      else
      begin
        TItemFunctions.DecreaseAmount(Player, ItemsRequired[I].Slot,
          ItemsRequired[I].Amount);
        Player.Base.SendRefreshItemSlot(INV_TYPE, ItemsRequired[I].Slot,
          Player.Base.Character.Inventory[ItemsRequired[I].Slot], False);
      end;
    end;
  end
  else
  begin
    Player.SendClientMessage('A criação do item falhou.');
  end;
  Result := true;
end;

class function TPacketHandlers.RepairItens(var Player: TPlayer; Buffer: Array of BYTE)
  : Boolean;
var
  Packet: TPacketRepareItens absolute Buffer;
  i, j, k: Integer;
  TotalToReapair: Single;
  TotalTo: Integer;
  LostDur: Integer;
  ItemsToRepairInv,ItemsToRepairEqp: Array of BYTE;
begin
  Result := False;

  if(Packet.Unk = 0) then
  begin
    TotalToReapair := 0;

    for I := 0 to 9 do
    begin
      case Packet.ItensToRepareSlotType[i] of
        0:  //equip
          begin
            if(Player.Base.Character.Equip[
              Packet.ItensToRepareSlot[i]].Index = 0) then
                Continue;

            LostDur := Player.Base.Character.Equip[
              Packet.ItensToRepareSlot[i]].Max - Player.Base.Character.Equip[
              Packet.ItensToRepareSlot[i]].Min;

            if(ItemList[Player.Base.Character.Equip[
                      Packet.ItensToRepareSlot[i]].Index].Rank = 0) then
            begin
              TotalToReapair := TotalToReapair +
                ((ItemList[Player.Base.Character.Equip[
                      Packet.ItensToRepareSlot[i]].Index].SellPrince * 0.00025) * LostDur);
            end
            else if(ItemList[Player.Base.Character.Equip[
                      Packet.ItensToRepareSlot[i]].Index].Rank = 1) then
            begin
              TotalToReapair := TotalToReapair +
                ((ItemList[Player.Base.Character.Equip[
                      Packet.ItensToRepareSlot[i]].Index].SellPrince * 0.00025) * LostDur);
            end
            else
            begin
              TotalToReapair := TotalToReapair +
                (((ItemList[Player.Base.Character.Equip[
                      Packet.ItensToRepareSlot[i]].Index].SellPrince * 0.00025)
                      * (ItemList[Player.Base.Character.Equip[
                      Packet.ItensToRepareSlot[i]].Index].Rank-1)) * LostDur);
            end;

             {case TItemFunctions.GetItemEquipSlot(Player.Base.Character.Equip[
                Packet.ItensToRepareSlot[i]].Index) of
                2:
                  begin
                    TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Equip[
                      Packet.ItensToRepareSlot[i]].Index].Level * 3.5) * LostDur);
                  end;
                3:
                  begin
                    TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Equip[
                      Packet.ItensToRepareSlot[i]].Index].Level * 8.24) * LostDur);
                  end;
                4:
                  begin
                    TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Equip[
                      Packet.ItensToRepareSlot[i]].Index].Level * 2.64) * LostDur);
                  end;
                5:
                  begin
                    TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Equip[
                      Packet.ItensToRepareSlot[i]].Index].Level * 2.64) * LostDur);
                  end;
                6:
                  begin
                    TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Equip[
                      Packet.ItensToRepareSlot[i]].Index].Level * 6.97) * LostDur);
                  end;
                7:
                  begin
                    TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Equip[
                      Packet.ItensToRepareSlot[i]].Index].Level * 6.97) * LostDur);
                  end;
             end;}
          end;

        1: //inventário
          begin
            if(Player.Base.Character.Inventory[
              Packet.ItensToRepareSlot[i]].Index = 0) then
                Continue;

            LostDur := Player.Base.Character.Inventory[
              Packet.ItensToRepareSlot[i]].Max - Player.Base.Character.Inventory[
              Packet.ItensToRepareSlot[i]].Min;

            if(ItemList[Player.Base.Character.Inventory[
                      Packet.ItensToRepareSlot[i]].Index].Rank = 0) then
            begin
              TotalToReapair := TotalToReapair +
                ((ItemList[Player.Base.Character.Inventory[
                      Packet.ItensToRepareSlot[i]].Index].SellPrince * 0.00025) * LostDur);
            end
            else if(ItemList[Player.Base.Character.Inventory[
                      Packet.ItensToRepareSlot[i]].Index].Rank = 1) then
            begin
              TotalToReapair := TotalToReapair +
                ((ItemList[Player.Base.Character.Inventory[
                      Packet.ItensToRepareSlot[i]].Index].SellPrince * 0.00025) * LostDur);
            end
            else
            begin
              TotalToReapair := TotalToReapair +
                (((ItemList[Player.Base.Character.Inventory[
                      Packet.ItensToRepareSlot[i]].Index].SellPrince * 0.00025)
                      * (ItemList[Player.Base.Character.Inventory[
                      Packet.ItensToRepareSlot[i]].Index].Rank-1)) * LostDur);
            end;

           { case TItemFunctions.GetItemEquipSlot(Player.Base.Character.Inventory[
              Packet.ItensToRepareSlot[i]].Index) of
              2:
                begin
                  TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Inventory[
                    Packet.ItensToRepareSlot[i]].Index].Level * 3.5) * LostDur);
                end;
              3:
                begin
                  TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Inventory[
                    Packet.ItensToRepareSlot[i]].Index].Level * 8.24) * LostDur);
                end;
              4:
                begin
                  TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Inventory[
                    Packet.ItensToRepareSlot[i]].Index].Level * 2.64) * LostDur);
                end;
              5:
                begin
                  TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Inventory[
                    Packet.ItensToRepareSlot[i]].Index].Level * 2.64) * LostDur);
                end;
              6:
                begin
                  TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Inventory[
                    Packet.ItensToRepareSlot[i]].Index].Level * 6.97) * LostDur);
                end;
              7:
                begin
                  TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Inventory[
                    Packet.ItensToRepareSlot[i]].Index].Level * 6.97) * LostDur);
                end;
            end; }
          end;

        255:
          begin
            Continue;
          end;
      end;
    end;

    TotalTo := Round(TotalToReapair);

    if(Player.Base.Character.Gold < TotalTo) then
    begin
      Player.SendClientMessage('Você necessita de ' + TotalTo.ToString +
        ' de gold para realizar essa ação.');
      Exit;
    end;

    Player.DecGold(TotalTo);

    for I := 0 to 9 do
    begin
      case Packet.ItensToRepareSlotType[i] of
        0:  //equip
          begin
            Player.Base.Character.Equip[
              Packet.ItensToRepareSlot[i]].Min :=
                Player.Base.Character.Equip[
              Packet.ItensToRepareSlot[i]].Max;
            Player.Base.sendrefreshitemslot(EQUIP_TYPE, Packet.ItensToRepareSlot[i],
              Player.Base.Character.Equip[
              Packet.ItensToRepareSlot[i]], False);
          end;

        1: //inventário
          begin
            Player.Base.Character.Inventory[
              Packet.ItensToRepareSlot[i]].Min :=
                Player.Base.Character.Inventory[
              Packet.ItensToRepareSlot[i]].Max;
            Player.Base.sendrefreshitemslot(INV_TYPE, Packet.ItensToRepareSlot[i],
              Player.Base.Character.Inventory[
              Packet.ItensToRepareSlot[i]], False);
          end;

        255:
          begin
            Continue;
          end;
      end;
    end;

    Player.SendPacket(Packet, Packet.header.size);
  end
  else if(Packet.Unk = 1) then
  begin
    SetLength(ItemsToRepairInv, 0);

    TotalToReapair := 0;

    for I := 0 to 59 do
    begin
      if(Player.Base.Character.Inventory[i].Index = 0) then
        Continue;

      if((Player.Base.Character.Inventory[i].MAX = 0) or
        (Player.Base.Character.Inventory[i].MIN=Player.Base.Character.Inventory[i].MAX)) then
          Continue;

      SetLength(ItemsToRepairInv, Length(ItemsToRepairInv)+1);
      ItemsToRepairInv[Length(ItemsToRepairInv)-1] := i;

      LostDur := Player.Base.Character.Inventory[i].Max - Player.Base.Character.Inventory[i].Min;
      if(ItemList[Player.Base.Character.Inventory[
                      i].Index].Rank = 0) then
      begin
        TotalToReapair := TotalToReapair +
          ((ItemList[Player.Base.Character.Inventory[
                i].Index].SellPrince * 0.00025) * LostDur);
      end
      else if(ItemList[Player.Base.Character.Inventory[
                i].Index].Rank = 1) then
      begin
        TotalToReapair := TotalToReapair +
          ((ItemList[Player.Base.Character.Inventory[
                i].Index].SellPrince * 0.00025) * LostDur);
      end
      else
      begin
        TotalToReapair := TotalToReapair +
          (((ItemList[Player.Base.Character.Inventory[
                i].Index].SellPrince * 0.00025)
                * (ItemList[Player.Base.Character.Inventory[
                i].Index].Rank-1)) * LostDur);
      end;

     { case TItemFunctions.GetItemEquipSlot(Player.Base.Character.Inventory[i].Index) of
        2:
          begin
            LostDur := Player.Base.Character.Inventory[i].Max - Player.Base.Character.Inventory[i].Min;
            TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Inventory[
              i].Index].Level * 3.5) * LostDur);
          end;
        3:
          begin
            LostDur := Player.Base.Character.Inventory[i].Max - Player.Base.Character.Inventory[i].Min;
            TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Inventory[
              i].Index].Level * 8.24) * LostDur);
          end;
        4:
          begin
            LostDur := Player.Base.Character.Inventory[i].Max - Player.Base.Character.Inventory[i].Min;
            TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Inventory[
              i].Index].Level * 2.64) * LostDur);
          end;
        5:
          begin
            LostDur := Player.Base.Character.Inventory[i].Max - Player.Base.Character.Inventory[i].Min;
            TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Inventory[
              i].Index].Level * 2.64) * LostDur);
          end;
        6:
          begin
            LostDur := Player.Base.Character.Inventory[i].Max - Player.Base.Character.Inventory[i].Min;
            TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Inventory[
              i].Index].Level * 6.97) * LostDur);
          end;
        7:
          begin
            LostDur := Player.Base.Character.Inventory[i].Max - Player.Base.Character.Inventory[i].Min;
            TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Inventory[
              i].Index].Level * 6.97) * LostDur);
          end;
      end; }
    end;

    SetLength(ItemsToRepairEqp, 0);

    for I := 2 to 7 do
    begin
      if(Player.Base.Character.Equip[i].Index = 0) then
        Continue;

      if((Player.Base.Character.Equip[i].MAX = 0) or
        (Player.Base.Character.Equip[i].MIN=Player.Base.Character.Equip[i].MAX)) then
          Continue;

      SetLength(ItemsToRepairEqp, Length(ItemsToRepairEqp)+1);
      ItemsToRepairEqp[Length(ItemsToRepairEqp)-1] := i;

      LostDur := Player.Base.Character.Equip[i].Max - Player.Base.Character.Equip[i].Min;
      if(ItemList[Player.Base.Character.Equip[
                      i].Index].Rank = 0) then
      begin
        TotalToReapair := TotalToReapair +
          ((ItemList[Player.Base.Character.Equip[
                i].Index].SellPrince * 0.00025) * LostDur);
      end
      else if(ItemList[Player.Base.Character.Equip[
                i].Index].Rank = 1) then
      begin
        TotalToReapair := TotalToReapair +
          ((ItemList[Player.Base.Character.Equip[
                i].Index].SellPrince * 0.00025) * LostDur);
      end
      else
      begin
        TotalToReapair := TotalToReapair +
          (((ItemList[Player.Base.Character.Equip[
                i].Index].SellPrince * 0.00025)
                * (ItemList[Player.Base.Character.Equip[
                i].Index].Rank-1)) * LostDur);
      end;

      {case i of
        2:
          begin
            LostDur := Player.Base.Character.Equip[i].Max - Player.Base.Character.Equip[i].Min;
            TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Equip[
              i].Index].Level * 3.5) * LostDur);
          end;
        3:
          begin
            LostDur := Player.Base.Character.Equip[i].Max - Player.Base.Character.Equip[i].Min;
            TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Equip[
              i].Index].Level * 8.24) * LostDur);
          end;
        4:
          begin
            LostDur := Player.Base.Character.Equip[i].Max - Player.Base.Character.Equip[i].Min;
            TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Equip[
              i].Index].Level * 2.64) * LostDur);
          end;
        5:
          begin
            LostDur := Player.Base.Character.Equip[i].Max - Player.Base.Character.Equip[i].Min;
            TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Equip[
              i].Index].Level * 2.64) * LostDur);
          end;
        6:
          begin
            LostDur := Player.Base.Character.Equip[i].Max - Player.Base.Character.Equip[i].Min;
            TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Equip[
              i].Index].Level * 6.97) * LostDur);
          end;
        7:
          begin
            LostDur := Player.Base.Character.Equip[i].Max - Player.Base.Character.Equip[i].Min;
            TotalToReapair := TotalToReapair + ((ItemList[Player.Base.Character.Equip[
              i].Index].Level * 6.97) * LostDur);
          end;
      end; }
    end;

    TotalTo := Round(TotalToReapair);

    if(Player.Base.Character.Gold < TotalTo) then
    begin
      Player.SendClientMessage('Você necessita de ' + TotalTo.ToString +
        ' de gold para realizar essa ação.');
      Exit;
    end;

    Player.DecGold(TotalTo);

    if(Length(ItemsToRepairInv) > 0) then
    begin
      for I := 0 to Length(ItemsToRepairInv)-1 do
      begin
        Player.Base.Character.Inventory[
          ItemsToRepairInv[i]].Min :=
            Player.Base.Character.Inventory[
          ItemsToRepairInv[i]].Max;
        Player.Base.sendrefreshitemslot(Inv_TYPE, ItemsToRepairInv[i],
          Player.Base.Character.Inventory[
          ItemsToRepairInv[i]], False);
      end;
    end;

    if(Length(ItemsToRepairEqp) > 0) then
    begin
      for I := 0 to Length(ItemsToRepairEqp)-1 do
      begin
        Player.Base.Character.Equip[
          ItemsToRepairEqp[i]].Min :=
            Player.Base.Character.Equip[
          ItemsToRepairEqp[i]].Max;
        Player.Base.sendrefreshitemslot(EQUIP_TYPE, ItemsToRepairEqp[i],
          Player.Base.Character.Equip[
          ItemsToRepairEqp[i]], False);
      end;
    end;

    Player.SendPacket(Packet, Packet.header.size);
  end;

  Result := True;
end;

class function TPacketHandlers.RenoveItem(var Player: TPlayer; Buffer: Array of BYTE)
  : Boolean;
var
  Packet: TPacketRenoveItem absolute Buffer;
begin
  Result := False;

  if(((Packet.SlotItemToRenove > 0) and (Packet.SlotItem1 > 0)) and
    ((Packet.SlotItemToRenove < 60) and (Packet.SlotItem1 < 60))) then
  begin
    case ItemList[Player.Base.Character.Inventory[Packet.SlotItem1].index].itemType of
      35: //reparador de roupa de pran
        begin
          if(ItemList[Player.Base.Character.Inventory[
            Packet.SlotItemToRenove].Index].Classe >= 100) and
            (ItemList[Player.Base.Character.Inventory[
            Packet.SlotItemToRenove].Index].Classe <= 104) then
           begin //é realmente roupa de pran
             Player.Base.Character.Inventory[
            Packet.SlotItemToRenove].Min := 0;
             Player.Base.Character.Inventory[
            Packet.SlotItemToRenove].Max := 0;
            Player.Base.Character.Inventory[
            Packet.SlotItemToRenove].ExpireDate := IncHour(Now,
              ItemList[Player.Base.Character.Inventory[Packet.SlotItem1].Index].UseEffect);

             TItemFunctions.DecreaseAmount(Player, Packet.SlotItem1, 1);
             Player
                .Base.SendRefreshItemSlot(INV_TYPE, Packet.SlotItem1,Player.Base.Character.Inventory[Packet.SlotItem1], False);
             Player
                .Base.SendRefreshItemSlot(INV_TYPE, Packet.SlotItemToRenove,Player.Base.Character.Inventory[
            Packet.SlotItemToRenove], False);

            Player.Base.SendPacket(Packet, Packet.Header.size);
            Player.sendclientmessage('Você renovou o item [' +
              ItemList[Player.Base.Character.Inventory[
            Packet.SlotItemToRenove].index].Name + '] por mais ' +
              (ItemList[Player.Base.Character.Inventory[Packet.SlotItem1].Index].UseEffect div 24).tostring + ' dias.');
           end;
        end;

      520://licença de montaria
        begin
          if(TItemFunctions.GetItemEquipSlot(Player.Base.Character.Inventory[
            Packet.SlotItemToRenove].Index) = 9) then
          begin //é realmente montaria
            Player.Base.Character.Inventory[
            Packet.SlotItemToRenove].ExpireDate := IncHour(Now,
              ItemList[Player.Base.Character.Inventory[Packet.SlotItem1].Index].UseEffect);

             TItemFunctions.DecreaseAmount(Player, Packet.SlotItem1, 1);
             Player
                .Base.SendRefreshItemSlot(INV_TYPE, Packet.SlotItem1,Player.Base.Character.Inventory[Packet.SlotItem1], False);
             Player
                .Base.SendRefreshItemSlot(INV_TYPE, Packet.SlotItemToRenove,Player.Base.Character.Inventory[
            Packet.SlotItemToRenove], False);

            Player.Base.SendPacket(Packet, Packet.Header.size);
            Player.sendclientmessage('Você renovou o item [' +
              ItemList[Player.Base.Character.Inventory[
            Packet.SlotItemToRenove].index].Name + '] por mais ' +
              (ItemList[Player.Base.Character.Inventory[Packet.SlotItem1].Index].UseEffect div 24).tostring + ' dias.');
          end;
        end;
    end;
  end;

  Result := True;
end;

{$ENDREGION}
{$REGION 'Nation Packets'}
class function TPacketHandlers.UpdateNationGold(var Player: TPlayer;
  Buffer: Array of BYTE): Boolean;
var
  Packet: TUpdateNationTreasure absolute Buffer;
  NationGold: Int64;
begin
  Result := true;
  NationGold := 0;
  if not(Player.Base.Character.Nation = 0) then
  begin
    NationGold := Nations[Player.Base.Character.Nation - 1].NationGold;
  end;
  Packet.Gold := NationGold;
  Player.SendPacket(Packet, sizeof(Packet));
end;
class function TPacketHandlers.UpdateNationTaxes(var Player: TPlayer;
  Buffer: Array of BYTE): Boolean;
var
  Packet: TUpdateNationTaxes absolute Buffer;
  CitizenTax, VisitorTax: BYTE;
  I, j: Integer;
begin
  Result := true;
  if not(Player.IsMarshal) then
    Exit;
  CitizenTax := Packet.CitizenTax;
  VisitorTax := Packet.VisitorTax;
  if (CitizenTax >= 5) and (CitizenTax <= 15) then
  begin
    if (VisitorTax >= 10) and (VisitorTax <= 20) then
    begin
      Nations[Player.Base.Character.Nation - 1].CitizenTax := CitizenTax;
      Nations[Player.Base.Character.Nation - 1].VisitorTax := VisitorTax;
      Nations[Player.Base.Character.Nation - 1].SaveNationTaxes;
      for I := Low(Servers) to High(Servers) do
      begin
        for j := Low(Servers[I].Players) to High(Servers[I].Players) do
        begin
          if (Servers[I].Players[j].Status < Playing) then
            Continue;
          if (Servers[I].Players[j].Base.Character.Nation = Player.Base.
            Character.Nation) then
          begin
            Servers[I].Players[j].SendClientMessage
              ('A taxa de sua nação foi setada em ' +
              AnsiString(CitizenTax.ToString) + '% para cidadãos e ' +
              AnsiString(VisitorTax.ToString) + '% para não-cidadãos.');
            Servers[I].Players[j].SendNationInformation;
            // SendPacket(Packet, Packet.Header.Size);
          end;
        end;
      end;
    end;
  end;
end;
class function TPacketHandlers.RequestUpdateReliquare(var Player: TPlayer;
  Buffer: Array of BYTE): Boolean;
var
  Packet: TRequestDevirInfoPacket absolute Buffer;
begin
  if(Packet.Channel = 4) then
    Packet.Channel := 2;
  if (Packet.Channel > (High(Servers) + 1)) then
    Player.SendUpdateReliquareInformation(Player.ChannelIndex)
  else
    Player.SendUpdateReliquareInformation(Packet.Channel);
end;
{$ENDREGION}
{$REGION 'GM Tool Packets'}
class function TPacketHandlers.CheckGMLogin(var Player: TPlayer;
  Buffer: array of BYTE): Boolean;
var
  Packet: TPacketLoginIntoServer absolute Buffer;
  Packet2: TPacketLoginIntoServerResponse;
  PasswordErrors: Integer;
  MasterPriv: Integer;
  xPassword: String;
  SQLComp: TQuery;
begin
  ZeroMemory(@Packet2, sizeof(TPacketLoginIntoServerResponse));
  Packet2.Header.Size := sizeof(TPacketLoginIntoServerResponse);
  Packet2.Header.Index := Player.Base.ClientId;
  Packet2.Header.Code := $3203;
  Packet2.Response := -1;
  if (Trim(String(Packet.Username)) = '') then
  begin
    Logger.Write('Username vazio', TLogType.Warnings);
    Player.SendPacket(Packet2, Packet2.Header.Size);
    Exit;
  end;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
    AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[CheckGMLogin]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[CheckGMLogin]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  SQLComp.SetQuery(Format('SELECT * FROM gm_accounts WHERE' +
    ' username=%s', [QuotedStr(String(Packet.Username))]));
  SQLComp.Run(true);
  if (SQLComp.Query.RowsAffected = 0) then
  begin
    Logger.Write('Username não encontrado. ' + String(Packet.Username),
      TLogType.Warnings);
    SQLComp.Destroy;
    Player.SendPacket(Packet2, Packet2.Header.Size);
    Exit;
  end;
  if (SQLComp.Query.FieldByName('account_status').AsInteger = 0) then
  begin
    Logger.Write('Account GM blocked by excessible passoword errors.',
      TLogType.Error);
    SQLComp.Destroy;
    Player.SendPacket(Packet2, Packet2.Header.Size);
    Exit;
  end;
  MasterPriv := SQLComp.Query.FieldByName('master_priv').AsInteger;
  xPassword := SQLComp.Query.FieldByName('password').AsString;
  if (String(Packet.Password) <> TFunctions.StringToMd5
    (xPassword)) then
  begin
    PasswordErrors := SQLComp.Query.FieldByName('password_errors')
      .AsInteger;
    if (PasswordErrors >= 5) then
    begin
      SQLComp.SetQuery
        (Format('UPDATE gm_accounts SET account_status = 0 where username = %s',
        [QuotedStr(String(Packet.Username))]));
      SQLComp.Run(False);
    end
    else
    begin
      Inc(PasswordErrors);
      SQLComp.SetQuery
        (Format('UPDATE gm_accounts SET password_errors = %d where username = %s',
        [PasswordErrors, QuotedStr(String(Packet.Username))]));
      SQLComp.Run(False);
    end;
    Logger.Write('As senhas diferem. packet: ' + String(Packet.Password) +
      ' db: ' + TFunctions.StringToMd5(xPassword), TLogType.Warnings);
    SQLComp.Destroy;
    Player.SendPacket(Packet2, Packet2.Header.Size);
    Exit;
  end
  else
  begin
    SQLComp.SetQuery
      (Format('UPDATE gm_accounts SET password_errors = %d where username = %s',
      [0, QuotedStr(String(Packet.Username))]));
    SQLComp.Run(False);
  end;
  Logger.Write('Super Usuário logado usando username: ' +
    String(Packet.Username), TLogType.ConnectionsTraffic);
  Packet2.Response := 1;
  Player.SendPacket(Packet2, Packet2.Header.Size);
  Player.Base.SessionOnline := true;
  Player.Base.SessionUsername := String(Packet.Username);
  Player.Base.SessionMasterPriv := TMasterPrives(MasterPriv);
  SQLComp.Destroy;
end;
class function TPacketHandlers.GMPlayerMove(var Player: TPlayer;
  Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TMovePacket absolute Buffer;
  OtherPlayer: PPlayer;
begin
  Result := False;
  if (Player.Base.SessionOnline) then
  begin
    if(Player.Base.SessionMasterPriv < ModeradorPriv) then
      Exit;
    if not(Packet.Position.IsValid) then
      Exit;
    if (Trim(String(Packet.NickName)) = '') then
      Exit;
    Servers[Player.ChannelIndex].GetPlayerByName(String(Packet.NickName),
      OtherPlayer);
    if (OtherPlayer^.Status < Playing) then
      Exit;
    OtherPlayer^.Teleport(Packet.Position);
    if (String(Player.Base.Character.Name) <> String(Packet.NickName)) then
    begin
      OtherPlayer^.SendClientMessage('Você foi teleportado pelo <' +
        String(Player.Base.Character.Name) +
        '> com atributos de Administrador.');
    end;
    Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
      '] logada no personagem <' + String(Player.Base.Character.Name) +
      '> MOVEU o personagem {' + String(OtherPlayer^.Base.Character.Name) +
      '} para a posição X: ' + Packet.Position.X.ToString + ' Y: ' + Packet.Position.Y.ToString,
      TLogType.Painel);
    Result := true;
  end;
end;
class function TPacketHandlers.GMSendChat(var Player: TPlayer;
  Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TClientMessagePacket2 absolute Buffer;
  I: Integer;
  str_aux: String;
begin
  try
    if (Player.Base.SessionOnline) then
    begin
      if(Player.Base.SessionMasterPriv < ModeradorPriv) then
        Exit;

      str_aux := Copy(Packet.Msg, 0, 90);
      if (Packet.Type2 = 1) then
      begin
        for I := Low(Servers) to High(Servers) do
        begin
          if not(Servers[I].IsActive) then
            Continue;
          Servers[I].SendServerMsg(AnsiString('<[GameMaster] ' + Player.Base.Character.name + '> ' +
            str_aux), Packet.Type1, Packet.Null);
        end;
        Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
          '] logada no personagem <' + String(Player.Base.Character.Name) +
          '> GRITOU mundialmente a seguinte mensagem {' + String(str_aux) + '}',
          TLogType.Painel);
        Exit;
      end;
      Servers[Player.ChannelIndex].SendServerMsg
        (AnsiString('<[GameMaster] ' + Player.Base.Character.name + '> ' + str_aux), Packet.Type1,
        Packet.Null);
      Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
        '] logada no personagem <' + String(Player.Base.Character.Name) +
        '> GRITOU localmente a seguinte mensagem {' + String(str_aux) + '}',
        TLogType.Painel);
    end;
  except
    {on E: Exception do
    begin
      Logger.Write('Erro TPacketHandlers.GMSendChat ' + E.Message + ' ' +
         , TlogType.Error);
    end; }
  end;
end;
class function TPacketHandlers.GMGoldManagment(var Player: TPlayer;
  Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSendGoldAddRemove absolute Buffer;
  I: Integer;
  OtherPlayer: PPlayer;
begin
  OtherPlayer := Nil;
  if (Player.CheckAdminLogged) then
  begin
    if (Trim(String(Packet.NickName)) = '') then
    begin // ir por targetid
      OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(Packet.TargetID);
      if (OtherPlayer <> nil) then
      begin
        if (Packet.Add) then
        begin // adicionar
          OtherPlayer.AddGold(Packet.Gold);
          Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
          '] logada no personagem <' + String(Player.Base.Character.Name) +
          '> CRIOU GOLD para o personagem {' + String(OtherPlayer^.Base.Character.Name) +
          '} na quantia de § ' + Packet.Gold.ToString + ' §',
          TLogType.Painel);
        end
        else
        begin
          if not(Packet.RemoveAllGold) then
          begin // remover
            if (((OtherPlayer.Character.Base.Gold - Packet.Gold) <= 0) or
              (OtherPlayer.Character.Base.Gold = 0)) then
            begin
              OtherPlayer.Character.Base.Gold := 0;
              OtherPlayer.RefreshMoney;
            end
            else
            begin
              OtherPlayer.Character.Base.Gold :=
                (OtherPlayer.Character.Base.Gold - Packet.Gold);
              OtherPlayer.RefreshMoney;
            end;
            Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
             '] logada no personagem <' + String(Player.Base.Character.Name) +
             '> REMOVEU GOLD para o personagem {' + String(OtherPlayer^.Base.Character.Name) +
             '} na quantia de § ' + Packet.Gold.ToString + ' §',
             TLogType.Painel);
          end
          else
          begin // zerar
            OtherPlayer.Character.Base.Gold := 0;
            OtherPlayer.RefreshMoney;
            Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
             '] logada no personagem <' + String(Player.Base.Character.Name) +
             '> ZEROU GOLD para o personagem {' + String(OtherPlayer^.Base.Character.Name) +'}',
             TLogType.Painel);
          end;
        end;

      end;
    end
    else // ir por nickname
    begin
      for I := Low(Servers) to High(Servers) do
      begin
        OtherPlayer := Nil;
        OtherPlayer := Servers[I].GetPlayer(String(Packet.NickName));
        if (OtherPlayer = nil) then
        begin
          Continue;
        end;
        if (Packet.Add) then
        begin // adicionar
          OtherPlayer.AddGold(Packet.Gold);
          Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
          '] logada no personagem <' + String(Player.Base.Character.Name) +
          '> CRIOU GOLD para o personagem {' + String(OtherPlayer^.Base.Character.Name) +
          '} na quantia de § ' + Packet.Gold.ToString + ' §',
          TLogType.Painel);
        end
        else
        begin
          if not(Packet.RemoveAllGold) then
          begin // remover
            if (((OtherPlayer.Character.Base.Gold - Packet.Gold) <= 0) or
              (OtherPlayer.Character.Base.Gold = 0)) then
            begin
              OtherPlayer.Character.Base.Gold := 0;
              OtherPlayer.RefreshMoney;
            end
            else
            begin
              OtherPlayer.Character.Base.Gold :=
                (OtherPlayer.Character.Base.Gold - Packet.Gold);
              OtherPlayer.RefreshMoney;
            end;
            Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
             '] logada no personagem <' + String(Player.Base.Character.Name) +
             '> REMOVEU GOLD para o personagem {' + String(OtherPlayer^.Base.Character.Name) +
             '} na quantia de § ' + Packet.Gold.ToString + ' §',
             TLogType.Painel);
          end
          else
          begin // zerar
            OtherPlayer.Character.Base.Gold := 0;
            OtherPlayer.RefreshMoney;
            Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
             '] logada no personagem <' + String(Player.Base.Character.Name) +
             '> ZEROU GOLD para o personagem {' + String(OtherPlayer^.Base.Character.Name) +'}',
             TLogType.Painel);
          end;
        end;
      end;
    end;
  end;
end;
class function TPacketHandlers.GMCashManagment(var Player: TPlayer;
  Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSendCashAddRemove absolute Buffer;
  I: Integer;
  OtherPlayer: PPlayer;
begin
  OtherPlayer := Nil;
  if (Player.CheckAdminLogged) then
  begin
    if (Trim(String(Packet.NickName)) = '') then
    begin // ir por targetid
      OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(Packet.TargetID);
      if (OtherPlayer <> nil) then
      begin
        if (Packet.Add) then
        begin // adicionar
          OtherPlayer.AddCash(Packet.Cash);
          Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
           '] logada no personagem <' + String(Player.Base.Character.Name) +
           '> CRIOU CASH para o personagem {' + String(OtherPlayer^.Base.Character.Name) +
           '} na quantia de § ' + Packet.Cash.ToString + ' §',
           TLogType.Painel);
        end
        else
        begin
          if not(Packet.RemoveAllCash) then
          begin // remover
            if (((OtherPlayer.Account.Header.CashInventory.Cash - Packet.Cash)
              <= 0) or (OtherPlayer.Account.Header.CashInventory.Cash = 0)) then
            begin
              OtherPlayer.Account.Header.CashInventory.Cash := 0;
              OtherPlayer.SendPlayerCash;
            end
            else
            begin
              OtherPlayer.Account.Header.CashInventory.Cash :=
                (OtherPlayer.Account.Header.CashInventory.Cash - Packet.Cash);
              OtherPlayer.SendPlayerCash;
            end;
            Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
            '] logada no personagem <' + String(Player.Base.Character.Name) +
            '> REMOVEU CASH para o personagem {' + String(OtherPlayer^.Base.Character.Name) +
            '} na quantia de § ' + Packet.Cash.ToString + ' §',
            TLogType.Painel);
          end
          else
          begin // zerar
            OtherPlayer.Account.Header.CashInventory.Cash := 0;
            OtherPlayer.SendPlayerCash;
            Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
             '] logada no personagem <' + String(Player.Base.Character.Name) +
             '> ZEROU CASH para o personagem {' + String(OtherPlayer^.Base.Character.Name) +'}',
             TLogType.Painel);
          end;
        end;
      end;
    end
    else // ir por nickname
    begin
      for I := Low(Servers) to High(Servers) do
      begin
        OtherPlayer := Nil;
        OtherPlayer := Servers[I].GetPlayer(String(Packet.NickName));
        if (OtherPlayer = nil) then
        begin
          Continue;
        end;
        if (Packet.Add) then
        begin // adicionar
          OtherPlayer.AddCash(Packet.Cash);
          Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
           '] logada no personagem <' + String(Player.Base.Character.Name) +
           '> CRIOU CASH para o personagem {' + String(OtherPlayer^.Base.Character.Name) +
           '} na quantia de § ' + Packet.Cash.ToString + ' §',
           TLogType.Painel);
        end
        else
        begin
          if not(Packet.RemoveAllCash) then
          begin // remover
            if (((OtherPlayer.Account.Header.CashInventory.Cash - Packet.Cash)
              <= 0) or (OtherPlayer.Account.Header.CashInventory.Cash = 0)) then
            begin
              OtherPlayer.Account.Header.CashInventory.Cash := 0;
              OtherPlayer.SendPlayerCash;
            end
            else
            begin
              OtherPlayer.Account.Header.CashInventory.Cash :=
                (OtherPlayer.Account.Header.CashInventory.Cash - Packet.Cash);
              OtherPlayer.SendPlayerCash;
            end;
            Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
             '] logada no personagem <' + String(Player.Base.Character.Name) +
             '> REMOVEU CASH para o personagem {' + String(OtherPlayer^.Base.Character.Name) +
             '} na quantia de § ' + Packet.Cash.ToString + ' §',
             TLogType.Painel);
          end
          else
          begin // zerar
            OtherPlayer.Account.Header.CashInventory.Cash := 0;
            OtherPlayer.SendPlayerCash;
            Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
             '] logada no personagem <' + String(Player.Base.Character.Name) +
             '> ZEROU CASH para o personagem {' + String(OtherPlayer^.Base.Character.Name) +'}',
             TLogType.Painel);
          end;
        end;
      end;
    end;
  end;
end;
class function TPacketHandlers.GMLevelManagment(var Player: TPlayer;
  Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSendLevelAddRemove absolute Buffer;
  I, gmuid, Helper: Integer;
  OtherPlayer: PPlayer;
  LevelExp: UInt64;
  AddExp: UInt64;
  MySQLComp: TQuery;
begin
  OtherPlayer := Nil;
  if (Player.CheckGameMasterLogged) then
  begin
    if(Player.CheckAdminLogged) then
    begin
      if (Trim(String(Packet.NickName)) = '') then
      begin // ir por targetid
        OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(Packet.TargetID);
        if (OtherPlayer <> nil) then
        begin
          if (Packet.Add) then
          begin // adicionar
            try
              LevelExp := ExpList[Player.Character.Base.Level +
                (Packet.Level - 1)] + 1;
            except
              LevelExp := High(ExpList);
            end;
            AddExp := LevelExp - UInt64(Player.Character.Base.Exp);
            OtherPlayer.AddExp(AddExp, Helper);
            OtherPlayer.Base.SendRefreshLevel;
            Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
             '] logada no personagem <' + String(Player.Base.Character.Name) +
             '> CRIOU LEVEL para o personagem {' + String(OtherPlayer^.Base.Character.Name) +
             '} na quantia de § ' + Packet.Level.ToString + ' §',
             TLogType.Painel);
          end
          else
          begin
            if not(Packet.RemoveAllLevel) then
            begin // remover
              if (((OtherPlayer.Base.Character.Level - Packet.Level) <= 0) or
                (OtherPlayer.Base.Character.Level = 1)) then
              begin
                OtherPlayer.Base.Character.Level := 1;
                OtherPlayer.Base.Character.Exp := 1;
                OtherPlayer.Base.SendRefreshLevel;
              end
              else
              begin
                OtherPlayer.Base.Character.Level :=
                  (OtherPlayer.Base.Character.Level - Packet.Level);
                OtherPlayer.Base.Character.Exp :=
                  ExpList[OtherPlayer.Base.Character.Level];
                OtherPlayer.Base.SendRefreshLevel;
              end;
              Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
               '] logada no personagem <' + String(Player.Base.Character.Name) +
               '> REMOVEU LEVEL para o personagem {' + String(OtherPlayer^.Base.Character.Name) +
               '} na quantia de § ' + Packet.Level.ToString + ' §',
               TLogType.Painel);
            end
            else
            begin // zerar
              OtherPlayer.Base.Character.Level := 1;
              OtherPlayer.Base.Character.Exp := 1;
              OtherPlayer.Base.SendRefreshLevel;
              Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
               '] logada no personagem <' + String(Player.Base.Character.Name) +
               '> ZEROU LEVEL para o personagem {' + String(OtherPlayer^.Base.Character.Name) +'}',
               TLogType.Painel);
            end;
          end;
        end;
      end
      else // ir por nickname
      begin
        for I := Low(Servers) to High(Servers) do
        begin
          OtherPlayer := Nil;
          OtherPlayer := Servers[I].GetPlayer(String(Packet.NickName));
          if (OtherPlayer = nil) then
          begin
            Continue;
          end;
          if (Packet.Add) then
          begin // adicionar
            try
              LevelExp := ExpList[Player.Character.Base.Level +
                (Packet.Level - 1)] + 1;
            except
              LevelExp := High(ExpList);
            end;
            AddExp := LevelExp - UInt64(Player.Character.Base.Exp);
            OtherPlayer.AddExp(AddExp, Helper);
            OtherPlayer.Base.SendRefreshLevel;
            Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
             '] logada no personagem <' + String(Player.Base.Character.Name) +
             '> CRIOU LEVEL para o personagem {' + String(OtherPlayer^.Base.Character.Name) +
             '} na quantia de § ' + Packet.Level.ToString + ' §',
             TLogType.Painel);
          end
          else
          begin
            if not(Packet.RemoveAllLevel) then
            begin // remover
              if (((OtherPlayer.Base.Character.Level - Packet.Level) <= 0) or
                (OtherPlayer.Base.Character.Level = 1)) then
              begin
                OtherPlayer.Base.Character.Level := 1;
                OtherPlayer.Base.Character.Exp := 1;
                OtherPlayer.Base.SendRefreshLevel;
              end
              else
              begin
                OtherPlayer.Base.Character.Level :=
                  (OtherPlayer.Base.Character.Level - Packet.Level);
                OtherPlayer.Base.Character.Exp :=
                  ExpList[OtherPlayer.Base.Character.Level];
                OtherPlayer.Base.SendRefreshLevel;
              end;
              Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
               '] logada no personagem <' + String(Player.Base.Character.Name) +
               '> REMOVEU LEVEL para o personagem {' + String(OtherPlayer^.Base.Character.Name) +
               '} na quantia de § ' + Packet.Level.ToString + ' §',
               TLogType.Painel);
            end
            else
            begin // zerar
              OtherPlayer.Base.Character.Level := 1;
              OtherPlayer.Base.Character.Exp := 1;
              OtherPlayer.Base.SendRefreshLevel;
              Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
               '] logada no personagem <' + String(Player.Base.Character.Name) +
               '> ZEROU LEVEL para o personagem {' + String(OtherPlayer^.Base.Character.Name) +'}',
               TLogType.Painel);
            end;
          end;
        end;
      end;
    end
    else //gerar a assinatura do comando
    begin
      MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
        AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
        AnsiString(MYSQL_DATABASE), False);
      if not(MySQLComp.Query.Connection.Connected) then
      begin
        Logger.Write('Falha de conexão individual com mysql.[GMLevelManagment]',
          TlogType.Warnings);
        Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMLevelManagment]', TlogType.Error);
        Exit;
      end;

      MySQLComp.SetQuery('select id from gm_accounts where username = ' +
        QuotedStr(Player.Base.SessionUsername));
      MySQLComp.Run();

      if(MySQLComp.Query.RecordCount > 0) then
      begin
        gmuid := MySQLComp.Query.Fields[0].AsInteger;

        if (Trim(String(Packet.NickName)) = '') then
        begin
          MySQLComp.SetQuery(Format('INSERT INTO gm_commands (owner_gmid,command_type,runned,command,'+
            'created_at, runned_at, runned_by, target_name, target_itemid, target_itemcnt, refused,'+
            'refused_at, reason_run, reason_refuse) VALUES (%d, %d, %d, %s, %s, %s, %s, %s, %d, %d,'+
            '%d, %s, %s, %s)', [gmuid, LEVEL_GMCOMMAND, 0,
            QuotedStr('UPDATE characters SET level = (level + '+Packet.Level.ToString+') WHERE ' +
            'clientid = ' + QuotedStr(Packet.TargetID.ToString) + ';'), QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)),
            QuotedStr('1899-12-30'), QuotedStr(''), QuotedStr(String(Servers[Player.ChannelIndex].Players[Packet.TargetID].Base.Character.Name)),
            0, Packet.Level, 0, QuotedStr('1899-12-30'), QuotedStr(''), QuotedStr('')]));
        end
        else
        begin
          MySQLComp.SetQuery(Format('INSERT INTO gm_commands (owner_gmid,command_type,runned,command,'+
            'created_at, runned_at, runned_by, target_name, target_itemid, target_itemcnt, refused,'+
            'refused_at, reason_run, reason_refuse) VALUES (%d, %d, %d, %s, %s, %s, %s, %s, %d, %d,'+
            '%d, %s, %s, %s)', [gmuid, LEVEL_GMCOMMAND, 0,
            QuotedStr('UPDATE characters SET level = (level + '+Packet.Level.ToString+') WHERE ' +
            'name = ' + QuotedStr(String(Packet.Nickname)) + ';'), QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)),
            QuotedStr('1899-12-30'), QuotedStr(''), QuotedStr(String(Packet.Nickname)),
            0, Packet.Level, 0, QuotedStr('1899-12-30'), QuotedStr(''), QuotedStr('')]));
        end;
        MySQLComp.Run(False);

        MySQLComp.Destroy;
      end;
    end;
  end;
end;
class function TPacketHandlers.GMBuffsManagment(var Player: TPlayer;
  Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSendBuffAddRemove absolute Buffer;
  I: Integer;
  OtherPlayer: PPlayer;
begin
  OtherPlayer := Nil;
  if (Player.CheckAdminLogged) then
  begin
    OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(Packet.TargetID);
    if (OtherPlayer <> nil) then
    begin
      if (Packet.Add = 1) then
      begin // adicionar
        OtherPlayer.Base.AddBuff(Packet.BuffID);
        Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
         '] logada no personagem <' + String(Player.Base.Character.Name) +
         '> BUFFOU o personagem {' + String(OtherPlayer^.Base.Character.Name) +
         '} com o buff § [' + Packet.BuffID.ToString + '] ' + String(SkillData[Packet.BuffID].Name) + ' §',
         TLogType.Painel);
      end
      else
      begin
        if not(Packet.RemoveAllBuff = 1) then
        begin // remover
          OtherPlayer.Base.RemoveBuff(Packet.BuffID);
          Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
           '] logada no personagem <' + String(Player.Base.Character.Name) +
           '> REMOVEU BUFF do personagem {' + String(OtherPlayer^.Base.Character.Name) +
           '} buff § [' + Packet.BuffID.ToString + '] ' + String(SkillData[Packet.BuffID].Name) + ' §',
           TLogType.Painel);
        end
        else
        begin // zerar
          OtherPlayer.Base.ZerarBuffs();
          OtherPlayer.Base.GetCurrentScore;
          OtherPlayer.Base.SendStatus;
          OtherPlayer.Base.SendRefreshPoint;
          OtherPlayer.Base.SendRefreshBuffs;
          Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
           '] logada no personagem <' + String(Player.Base.Character.Name) +
           '> ZEROU BUFFS do personagem {' + String(OtherPlayer^.Base.Character.Name) +'}',
           TLogType.Painel);
        end;
      end;
    end;
  end;
  Result := True;
end;
class function TPacketHandlers.GMDisconnect(var Player: TPlayer;
  Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSendDisconnect absolute Buffer;
  I: Integer;
  OtherPlayer: PPlayer;
begin
  OtherPlayer := Nil;
  if (Player.CheckGameMasterLogged) then
  begin
    if (Trim(String(Packet.NickName)) = '') then
    begin // ir por targetid
      OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(Packet.TargetID);
      if (OtherPlayer <> nil) then
      begin
        OtherPlayer.SendCloseClient;
        Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
         '] logada no personagem <' + String(Player.Base.Character.Name) +
         '> DESCONECTOU o personagem {' + String(OtherPlayer^.Base.Character.Name) +'}',
         TLogType.Painel);
      end;
    end
    else
    begin // ir por nickname
      for I := Low(Servers) to High(Servers) do
      begin
        OtherPlayer := Nil;
        OtherPlayer := Servers[I].GetPlayer(String(Packet.NickName));
        if (OtherPlayer = nil) then
        begin
          Continue;
        end;
        OtherPlayer.SendCloseClient;
        Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
         '] logada no personagem <' + String(Player.Base.Character.Name) +
         '> DESCONECTOU o personagem {' + String(OtherPlayer^.Base.Character.Name) +'}',
         TLogType.Painel);
      end;
    end;
  end;
end;
class function TPacketHandlers.GMBan(var Player: TPlayer;
  Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSendBan absolute Buffer;
  I, j: Integer;
  OtherPlayer: PPlayer;
begin
  OtherPlayer := Nil;
  if (Player.CheckGameMasterLogged) then
  begin
    if (Trim(String(Packet.NickName)) = '') then
    begin // ir por targetid
      OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(Packet.TargetID);
      if (OtherPlayer <> nil) then
      begin
        if (Packet.Days >= 1000) then
        begin // ban perma
          OtherPlayer.Account.Header.AccountStatus := 8;
          for j := Low(Servers) to High(Servers) do
          begin
            if (Trim(String(Packet.Reason)) = '') then
            begin
              Servers[j].SendServerMsg
                ('O jogador <' + AnsiString(OtherPlayer.Base.Character.Name) +
                '> foi banido permanentemente. Motivo do ban não apresentado.',
                16, 32, 16);
            end
            else
            begin
              Servers[j].SendServerMsg
                ('O jogador <' + AnsiString(OtherPlayer.Base.Character.Name) +
                '> foi banido permanentemente. Motivo do ban: ', 16, 32, 16);
              Servers[j].SendServerMsg(AnsiString(Packet.Reason), 16, 32, 16);
            end;
          end;
          OtherPlayer.SendCloseClient;
          Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
           '] logada no personagem <' + String(Player.Base.Character.Name) +
           '> BANIU PERMANENTE o personagem {' + String(OtherPlayer^.Base.Character.Name) +
           '} com o motivo § ' + String(Packet.Reason) + ' §',
           TLogType.Painel);
        end
        else // ban by days
        begin
          OtherPlayer.Account.Header.AccountStatus := 8;
          OtherPlayer.Account.Header.BanDays := Packet.Days;
          for j := Low(Servers) to High(Servers) do
          begin
            if (Trim(String(Packet.Reason)) = '') then
            begin
              Servers[j].SendServerMsg
                ('O jogador <' + AnsiString(OtherPlayer.Base.Character.Name) +
                '> foi banido por ' + AnsiString(IntToStr(Packet.Days)) +
                ' dias. Motivo do ban não apresentado.', 16, 32, 16);
            end
            else
            begin
              Servers[j].SendServerMsg
                ('O jogador <' + AnsiString(OtherPlayer.Base.Character.Name) +
                '> foi banido por ' + AnsiString(IntToStr(Packet.Days)) +
                ' dias. Motivo do ban: ', 16, 32, 16);
              Servers[j].SendServerMsg(AnsiString(Packet.Reason), 16, 32, 16);
            end;
          end;
          OtherPlayer.SendCloseClient;
          Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
           '] logada no personagem <' + String(Player.Base.Character.Name) +
           '> BANIU POR ' + Packet.Days.ToString + ' dia(s) o personagem {' + String(OtherPlayer^.Base.Character.Name) +
           '} com o motivo § ' + String(Packet.Reason) + ' §',
           TLogType.Painel);
        end;
      end;
    end
    else
    begin
      for I := Low(Servers) to High(Servers) do
      begin
        OtherPlayer := Nil;
        OtherPlayer := Servers[I].GetPlayer(String(Packet.NickName));
        if (OtherPlayer = nil) then
        begin
          Continue;
        end;
        if (Packet.Days >= 1000) then
        begin // ban perma
          OtherPlayer.Account.Header.AccountStatus := 8;
          for j := Low(Servers) to High(Servers) do
          begin
            if (Trim(String(Packet.Reason)) = '') then
            begin
              Servers[j].SendServerMsg
                ('O jogador <' + AnsiString(OtherPlayer.Base.Character.Name) +
                '> foi banido permanentemente. Motivo do ban não apresentado.',
                16, 32, 16);
            end
            else
            begin
              Servers[j].SendServerMsg
                ('O jogador <' + AnsiString(OtherPlayer.Base.Character.Name) +
                '> foi banido permanentemente. Motivo do ban: ', 16, 32, 16);
              Servers[j].SendServerMsg(AnsiString(Packet.Reason), 16, 32, 16);
            end;
          end;
          OtherPlayer.SendCloseClient;
          Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
           '] logada no personagem <' + String(Player.Base.Character.Name) +
           '> BANIU PERMANENTE o personagem {' + String(OtherPlayer^.Base.Character.Name) +
           '} com o motivo § ' + String(Packet.Reason) + ' §',
           TLogType.Painel);
        end
        else // ban by days
        begin
          OtherPlayer.Account.Header.AccountStatus := 8;
          OtherPlayer.Account.Header.BanDays := Packet.Days;
          for j := Low(Servers) to High(Servers) do
          begin
            if (Trim(String(Packet.Reason)) = '') then
            begin
              Servers[j].SendServerMsg
                ('O jogador <' + AnsiString(OtherPlayer.Base.Character.Name) +
                '> foi banido por ' + AnsiString(IntToStr(Packet.Days)) +
                ' dias. Motivo do ban não apresentado.', 16, 32, 16);
            end
            else
            begin
              Servers[j].SendServerMsg
                ('O jogador <' + AnsiString(OtherPlayer.Base.Character.Name) +
                '> foi banido por ' + AnsiString(IntToStr(Packet.Days)) +
                ' dias. Motivo do ban: ', 16, 32, 16);
              Servers[j].SendServerMsg(AnsiString(Packet.Reason), 16, 32, 16);
            end;
          end;
          OtherPlayer.SendCloseClient;
          Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
           '] logada no personagem <' + String(Player.Base.Character.Name) +
           '> BANIU POR ' + Packet.Days.ToString + ' dia(s) o personagem {' + String(OtherPlayer^.Base.Character.Name) +
           '} com o motivo § ' + String(Packet.Reason) + ' §',
           TLogType.Painel);
        end;
      end;
    end;
  end;
end;
class function TPacketHandlers.GMEventItem(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSendItemEventOne absolute Buffer;
  I, j: Integer;
  OtherPlayer: PPlayer;
  SQLComp: TQuery;
begin
  if (Player.CheckModeratorLogged) then
  begin
<<<<<<< HEAD
    if(Player.CheckAdminLogged) then
    begin
      if (Trim(String(Packet.NickName)) = '') then
      begin // ir por targetid
        OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(Packet.TargetID);
        if (OtherPlayer <> nil) then
        begin
          SQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
            AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
            AnsiString(MYSQL_DATABASE), True);
          if not(SQLComp.Query.Connection.Connected) then
          begin
            Logger.Write('Falha de conexão individual com mysql.[GMEventItem]',
              TlogType.Warnings);
            Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMEventItem]', TlogType.Error);
            SQLComp.Destroy;
            Exit;
          end;

          SQLComp.SetQuery(Format
            ('INSERT INTO items (id, slot_type, owner_id, slot, item_id, app, '+
            'identific, effect1_index, effect1_value, effect2_index, effect2_value, '+
            'effect3_index, effect3_value, min, max, refine, time, owner_mail_slot) ' +
            'VALUES (0, %d, %d, 0, %d, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, %d, 0, 0)', [EVENT_ITEM,
            OtherPlayer.Character.Base.CharIndex, Packet.ItemID, Packet.Amount]));
          SQLComp.Query.Connection.StartTransaction;
          SQLComp.Run(False);
          SQLComp.Query.Connection.Commit;
          Player.SendClientMessage('Item de Evento "T" enviado com sucesso.', 32, 16, 32);
          Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
           '] logada no personagem <' + String(Player.Base.Character.Name) +
           '> ENVIOU ITEM EVENTO "T" o personagem {' + String(OtherPlayer^.Base.Character.Name) +
           '} item § [' + Packet.ItemID.ToString + '] ' + String(ItemList[Packet.ItemID].Name) +
           ' QTDE: ' + Packet.Amount.ToString + ' §',
           TLogType.Painel);
          SQLComp.Destroy;
        end;
      end
      else
=======
    if (Trim(String(Packet.NickName)) = '') then
    begin // ir por targetid
      OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(Packet.TargetID);
      if (OtherPlayer <> nil) then
>>>>>>> parent of 2438a94 (modificacoes 05/12)
      begin
        SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
          AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
          AnsiString(MYSQL_DATABASE));
        if not(SQLComp.Query.Connection.Connected) then
        begin
<<<<<<< HEAD
          OtherPlayer := Nil;
          OtherPlayer := Servers[I].GetPlayer(String(Packet.NickName));
          if (OtherPlayer = nil) then
          begin
            Continue;
          end;
          SQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
            AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
            AnsiString(MYSQL_DATABASE), True);
          if not(SQLComp.Query.Connection.Connected) then
          begin
            Logger.Write('Falha de conexão individual com mysql.[GMEventItem-else]',
              TlogType.Warnings);
            Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMEventItem-else]', TlogType.Error);
            SQLComp.Destroy;
            Exit;
          end;
          SQLComp.SetQuery(Format
            ('INSERT INTO items (id, slot_type, owner_id, slot, item_id, app, '+
            'identific, effect1_index, effect1_value, effect2_index, effect2_value, '+
            'effect3_index, effect3_value, min, max, refine, time, owner_mail_slot) ' +
            'VALUES (0, %d, %d, 0, %d, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, %d, 0, 0)', [EVENT_ITEM,
            OtherPlayer.Character.Base.CharIndex, Packet.ItemID, Packet.Amount]));
          SQLComp.Query.Connection.StartTransaction;
          SQLComp.Run(False);
          SQLComp.Query.Connection.Commit;
          Player.SendClientMessage('Item de Evento "T" enviado com sucesso.', 32, 16, 32);
          Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
           '] logada no personagem <' + String(Player.Base.Character.Name) +
           '> ENVIOU ITEM EVENTO "T" o personagem {' + String(OtherPlayer^.Base.Character.Name) +
           '} item § [' + Packet.ItemID.ToString + '] ' + String(ItemList[Packet.ItemID].Name) +
            ' QTDE: ' + Packet.Amount.ToString + ' §',
           TLogType.Painel);
           SQLComp.Destroy;
=======
          Logger.Write('Falha de conexão individual com mysql.[GMEventItem]',
            TlogType.Warnings);
          Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMEventItem]', TlogType.Error);
          SQLComp.Destroy;
          Exit;
>>>>>>> parent of 2438a94 (modificacoes 05/12)
        end;
        SQLComp.SetQuery(Format
          ('INSERT INTO items (id, slot_type, owner_id, slot, item_id, app, '+
          'identific, effect1_index, effect1_value, effect2_index, effect2_value, '+
          'effect3_index, effect3_value, min, max, refine, time, owner_mail_slot) ' +
          'VALUES (0, %d, %d, 0, %d, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, %d, 0, 0)', [EVENT_ITEM,
          OtherPlayer.Character.Base.CharIndex, Packet.ItemID, Packet.Amount]));
        SQLComp.Run(False);
        Player.SendClientMessage('Item de Evento "T" enviado com sucesso.', 32, 16, 32);
        Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
         '] logada no personagem <' + String(Player.Base.Character.Name) +
         '> ENVIOU ITEM EVENTO "T" o personagem {' + String(OtherPlayer^.Base.Character.Name) +
         '} item § [' + Packet.ItemID.ToString + '] ' + String(ItemList[Packet.ItemID].Name) +
         ' QTDE: ' + Packet.Amount.ToString + ' §',
         TLogType.Painel);
        SQLComp.Destroy;
      end;
    end
    else
    begin
<<<<<<< HEAD
       MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
        AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
        AnsiString(MYSQL_DATABASE), True);
      if not(MySQLComp.Query.Connection.Connected) then
=======
      for I := Low(Servers) to High(Servers) do
>>>>>>> parent of 2438a94 (modificacoes 05/12)
      begin
        OtherPlayer := Nil;
        OtherPlayer := Servers[I].GetPlayer(String(Packet.NickName));
        if (OtherPlayer = nil) then
        begin
<<<<<<< HEAD
          MySQLComp.SetQuery(Format('INSERT INTO gm_commands (owner_gmid,command_type,runned,command,'+
            'created_at, runned_at, runned_by, target_name, target_itemid, target_itemcnt, refused,'+
            'refused_at, reason_run, reason_refuse, reason_create) VALUES (%d, %d, %d, %s, %s, %s, %s, %s, %d, %d,'+
            '%d, %s, %s, %s, %s)', [gmuid, ITEM_GMCOMMAND, 0,
            QuotedStr('INSERT INTO items (item, refi, slot_type) VALUES (' + Packet.ItemID.ToString+', '+
            Packet.Amount.ToString + ', 17) WHERE ' +
            'owner_id = ' + QuotedStr(Packet.TargetID.ToString) + ';'), QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)),
            QuotedStr('1899-12-30'), QuotedStr(''), QuotedStr(String(Servers[Player.ChannelIndex].Players[Packet.TargetID].Base.Character.Name)),
            Packet.ItemID, Packet.Amount, 0, QuotedStr('1899-12-30'), QuotedStr(''), QuotedStr(''),
            QuotedStr(String(Packet.Reason))]));
        end
        else
        begin
          MySQLComp.SetQuery(Format('INSERT INTO gm_commands (owner_gmid,command_type,runned,command,'+
            'created_at, runned_at, runned_by, target_name, target_itemid, target_itemcnt, refused,'+
            'refused_at, reason_run, reason_refuse, reason_create) VALUES (%d, %d, %d, %s, %s, %s, %s, %s, %d, %d,'+
            '%d, %s, %s, %s, %s)', [gmuid, ITEM_GMCOMMAND, 0,
            QuotedStr('INSERT INTO items (item, refi, slot_type) VALUES (' + Packet.ItemID.ToString+', '+
            Packet.Amount.ToString + ', 17) WHERE ' +
            'owner_id = ' + QuotedStr(String(Packet.Nickname)) + ';'), QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)),
            QuotedStr('1899-12-30'), QuotedStr(''), QuotedStr(String(Packet.Nickname)),
            Packet.ItemID, Packet.Amount, 0, QuotedStr('1899-12-30'), QuotedStr(''), QuotedStr(''),
            QuotedStr(String(Packet.Reason))]));
        end;
        MySQLComp.Query.Connection.StartTransaction;
        MySQLComp.Run(False);
        MySQLComp.Query.Connection.Commit;

        Player.SendMessageToPainel('Seu comando foi recebido e passará por análise.',
          MB_ICONINFORMATION, 0);
=======
          Continue;
        end;
        SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
          AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
          AnsiString(MYSQL_DATABASE));
        if not(SQLComp.Query.Connection.Connected) then
        begin
          Logger.Write('Falha de conexão individual com mysql.[GMEventItem-else]',
            TlogType.Warnings);
          Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMEventItem-else]', TlogType.Error);
          SQLComp.Destroy;
          Exit;
        end;
        SQLComp.SetQuery(Format
          ('INSERT INTO items (id, slot_type, owner_id, slot, item_id, app, '+
          'identific, effect1_index, effect1_value, effect2_index, effect2_value, '+
          'effect3_index, effect3_value, min, max, refine, time, owner_mail_slot) ' +
          'VALUES (0, %d, %d, 0, %d, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, %d, 0, 0)', [EVENT_ITEM,
          OtherPlayer.Character.Base.CharIndex, Packet.ItemID, Packet.Amount]));
        SQLComp.Run(False);
        Player.SendClientMessage('Item de Evento "T" enviado com sucesso.', 32, 16, 32);
        Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
         '] logada no personagem <' + String(Player.Base.Character.Name) +
         '> ENVIOU ITEM EVENTO "T" o personagem {' + String(OtherPlayer^.Base.Character.Name) +
         '} item § [' + Packet.ItemID.ToString + '] ' + String(ItemList[Packet.ItemID].Name) +
          ' QTDE: ' + Packet.Amount.ToString + ' §',
         TLogType.Painel);
         SQLComp.Destroy;
>>>>>>> parent of 2438a94 (modificacoes 05/12)
      end;
    end;
  end;
end;
class function TPacketHandlers.GMEventItemForAll(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSendItemEventForAll absolute Buffer;
  I, j: Integer;
  OtherPlayer: PPlayer;
  SQLComp, SQLCompAux: TQuery;
begin
  if (Player.CheckAdminLogged) then
  begin
    SQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
    AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
    AnsiString(MYSQL_DATABASE));
    if not(SQLComp.Query.Connection.Connected) then
    begin
      Logger.Write('Falha de conexão individual com mysql.[GMEventItemForAll]',
        TlogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMEventItemForAll]', TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
    SQLCompAux := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
    AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
    AnsiString(MYSQL_DATABASE));
    if not(SQLCompAux.Query.Connection.Connected) then
    begin
      Logger.Write('Falha de conexão individual com mysql.[GMEventItemForAll2]',
        TlogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMEventItemForAll2]', TlogType.Error);
      SQLCompAux.Destroy;
      Exit;
    end;
    SQLComp.SetQuery('SELECT id FROM characters');
    SQLComp.Run();
    SQLComp.Query.First;
    for I := 0 to SQLComp.Query.RowsAffected-1 do
    begin
      SQLCompAux.SetQuery(Format
          ('INSERT INTO items (id, slot_type, owner_id, slot, item_id, app, '+
          'identific, effect1_index, effect1_value, effect2_index, effect2_value, '+
          'effect3_index, effect3_value, min, max, refine, time, owner_mail_slot) ' +
          'VALUES (0, %d, %d, 0, %d, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, %d, 0, 0)', [EVENT_ITEM,
          SQLComp.Query.FieldByName('id').AsInteger, Packet.ItemID, Packet.Amount]));
      SQLCompAux.Run(False);
      SQLComp.Query.Next;
    end;
    Player.SendClientMessage('Item de Evento "T" enviado PARA TODOS com sucesso.', 32, 16, 32);
    Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
      '] logada no personagem <' + String(Player.Base.Character.Name) +
      '> ENVIOU ITEM EVENTO "T" PARA TODOS PERSONAGENS' +
      ' item § [' + Packet.ItemID.ToString + '] ' + String(ItemList[Packet.ItemID].Name) +
      ' QTDE: ' + Packet.Amount.ToString +' §',
      TLogType.Painel);
    SQLComp.Destroy;
    SQLCompAux.Destroy;
  end;
end;
class function TPacketHandlers.GMRequestServerInformation(var Player: TPlayer;
  Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSendServerInfos;
  i: Integer;
begin
  if(Player.Base.SessionMasterPriv < ModeradorPriv) then
    Exit;

  ZeroMemory(@Packet, sizeof(TSendServerInfos));
  Packet.Header.Size := sizeof(Packet);
  Packet.Header.Code := $3215;
  Packet.Header.Index := Player.Base.ClientID;
  for I := Low(Servers) to High(Servers) do
  begin
    case Servers[i].NationID of
      1:
        begin
          Packet.Server01Online := Servers[i].ActivePlayersNowHere;
          Packet.Server01Reliq := Servers[i].ActiveReliquaresOnTemples;
        end;
      2:
        begin
          Packet.Server02Online := Servers[i].ActivePlayersNowHere;
          Packet.Server02Reliq := Servers[i].ActiveReliquaresOnTemples;
        end;
      3:
        begin
          Packet.Server03Online := Servers[i].ActivePlayersNowHere;
          Packet.Server03Reliq := Servers[i].ActiveReliquaresOnTemples;
        end;
      4:
        begin
          Packet.Server04Online := Servers[i].ActivePlayersNowHere;
          Packet.Server04Reliq := Servers[i].ActiveReliquaresOnTemples;
        end;
      5:
        begin
          Packet.Server05Online := Servers[i].ActivePlayersNowHere;
          Packet.Server05Reliq := Servers[i].ActiveReliquaresOnTemples;
        end;
    end;
  end;
  Player.SendPacket(Packet, Packet.Header.Size);
  //Sleep(10);
end;
class function TPacketHandlers.GMSendSpawnMob(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSendSpawnMob absolute Buffer;
  i, j, Helper: Integer;
  Spawned: Boolean;
begin
  Result := False;
  Spawned:= False;
  if not(Player.CheckGameMasterLogged) then
    if not(Player.CheckAdminLogged) then
      if not(Player.CheckModeratorLogged) then
        Exit;
 // if(Player.CheckGameMasterLogged) then
  //begin
    if(Packet.MobID > 450) then
      Exit;
    if(Packet.Position.IsValid) then
    begin //spawnar usando posicao
      for I := 1 to 50 do
      begin
        if(Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.ClientID <> 0) then
          Continue;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].index := ((Packet.MobID + i) + 9148);
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].InitPos.X := Packet.Position.X;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].InitPos.Y := Packet.Position.Y;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].DestPos.X := Packet.Position.X;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].DestPos.Y := Packet.Position.Y;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.Create(nil, ((Packet.MobID + i) + 9148),
          Player.ChannelIndex);
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.Mobid := Packet.MobID;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.IsActive := true;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.ClientId := (Packet.MobID + i) + 9148;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.SecondIndex := i;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].MovedTo := TypeMobLocation.Init;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].LastMyAttack := now;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].LastSkillAttack := now;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].CurrentPos := Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].InitPos;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].XPositionsToMove := 1;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].YPositionsToMove := 1;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].NeighborIndex := -1;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].HP := Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].InitHP;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].MP := Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].InitHP;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.PlayerCharacter.Base.CurrentScore.DNFis :=
          i + RandomRange(200, 299);
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.PlayerCharacter.Base.CurrentScore.DNMag :=
          Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.PlayerCharacter.Base.CurrentScore.DNFis;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.PlayerCharacter.Base.CurrentScore.DefFis
          := i + RandomRange(200, 299);
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.PlayerCharacter.Base.CurrentScore.DefMag
          := Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.PlayerCharacter.Base.
          CurrentScore.DefFis;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.PlayerCharacter.Base.CurrentScore.Esquiva
          := MOB_ESQUIVA; // estava 0
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.PlayerCharacter.CritRes := MOB_CRIT_RES;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.PlayerCharacter.DuploRes := MOB_DUPLO_RES;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.PlayerCharacter.Base.Nation :=
          Player.Base.Character.Nation; // Self.ChannelId + 1;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].LastMyAttack := now;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].isTemp := True;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].GeneratedAt := Now;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].IsActiveToSpawn := True;
        Spawned := True;
        break;
      end;
      Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
      '] logada no personagem <' + String(Player.Base.Character.Name) +
      '> SPAWNOU MOB em posição específica' +
      ' § [' + Packet.MobID.ToString + '] X: ' + Packet.Position.X.ToString + ' Y: ' +
       Packet.Position.Y.ToString + ' §',
      TLogType.Painel);
    end
    else //spawnar usando neighbor do persona
    begin
      for I := 1 to 50 do
      begin
        if(Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.ClientID <> 0) then
          Continue;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].index := ((Packet.MobID + i) + 9148);
        Randomize;
        Helper := RandomRange(1, 8);
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].InitPos.X := Player.Base.Neighbors[Helper].pos.X;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].InitPos.Y := Player.Base.Neighbors[Helper].pos.Y;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].DestPos.X := Player.Base.Neighbors[Helper].pos.X;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].DestPos.Y := Player.Base.Neighbors[Helper].pos.Y;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.Create(nil, ((Packet.MobID + i) + 9148),
          Player.ChannelIndex);
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.Mobid := Packet.MobID;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.IsActive := true;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.ClientId := (Packet.MobID + i) + 9148;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.SecondIndex := i;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].MovedTo := TypeMobLocation.Init;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].LastMyAttack := now;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].LastSkillAttack := now;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].CurrentPos := Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].InitPos;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.PlayerCharacter.LastPos :=
          Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].CurrentPos;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].XPositionsToMove := 1;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].YPositionsToMove := 1;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].NeighborIndex := -1;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].HP := Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].InitHP;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].MP := Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].InitHP;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.PlayerCharacter.Base.CurrentScore.DNFis :=
          i + RandomRange(200, 299);
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.PlayerCharacter.Base.CurrentScore.DNMag :=
          Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.PlayerCharacter.Base.CurrentScore.DNFis;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.PlayerCharacter.Base.CurrentScore.DefFis
          := i + RandomRange(200, 299);
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.PlayerCharacter.Base.CurrentScore.DefMag
          := Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.PlayerCharacter.Base.
          CurrentScore.DefFis;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.PlayerCharacter.Base.CurrentScore.Esquiva
          := MOB_ESQUIVA; // estava 0
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.PlayerCharacter.CritRes := MOB_CRIT_RES;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.PlayerCharacter.DuploRes := MOB_DUPLO_RES;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.PlayerCharacter.Base.Nation :=
          Player.Base.Character.Nation; // Self.ChannelId + 1;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].LastMyAttack := now;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].isTemp := True;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].GeneratedAt := Now;
        Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].IsActiveToSpawn := True;
        Spawned := True;
        break;
      end;
      Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
      '] logada no personagem <' + String(Player.Base.Character.Name) +
      '> SPAWNOU MOB em posição vizinha do personagem' +
      ' § [' + Packet.MobID.ToString + '] X: ' + Player.Base.Neighbors[Helper].pos.X.ToString + ' Y: ' +
       Player.Base.Neighbors[Helper].pos.Y.ToString + ' §',
      TLogType.Painel);
    end;
    if(Spawned = False) then
    begin
      Player.SendClientMessage('Não foi possível spawnar o mob ' +
        AnsiString(Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].Name));
    end;
  //end;
  Result := True;
end;
class function TPacketHandlers.GMRequestPlayerAccount(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TRequestSearchAccountFile absolute Buffer;
begin
  if(Player.Base.SessionMasterPriv < ModeradorPriv) then
    Exit;

  TFunctions.GetAccountsBackup(Player, Packet.TypeOfCommand, String(Packet.Username));
end;
class function TPacketHandlers.GMReceiveAccBackup(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSendAccountRecovery absolute Buffer;
  PacketToSend: TSendAccountRecoveryReturn;
  i, cid: Integer;
  TempPlayer: TPlayer;
begin
  if(Player.Base.SessionMasterPriv < GameMasterPriv) then
    Exit;

  ZeroMemory(@PacketToSend, sizeof(PacketToSend));
  PacketToSend.Header.Size := sizeof(PacketToSend);
  PacketToSend.Header.Index := Player.Base.ClientID;
  PacketToSend.Header.Code := $3227;

  PacketToSend.Response := 255;

  if not(FileExists(String(DATABASE_PATH + 'ACCS\' + Packet.AccountBackup.Header.Username + '\' +
    String(Packet.FileName) + '.acc'))) then
  begin
    PacketToSend.Response := 253;

    Player.SendPacket(PacketToSend, PacketToSend.Header.Size);
    Exit;
  end;

  for I := Low(Servers) to High(Servers) do
  begin
    Cid := Servers[i].GetPlayerByUsername(Packet.AccountBackup.Header.Username);

    if(Cid > 0) then
    begin
      Servers[i].Disconnect(Servers[i].Players[Cid]);
      Servers[i].Players[Cid].SocketClosed := True;

      if(Servers[i].Players[Cid].Thread.ClientID > 0) then
      begin
        if(Assigned(Servers[i].Players[Cid].Thread)) then
          if not(Servers[i].Players[Cid].Thread.Finished) then
            WaitForSingleObject(Servers[i].Players[Cid].Thread.Handle, INFINITE);
      end;

      //ZeroMemory(@Servers[i].Players[Cid], sizeof(TPlayer));
    end;
  end;

  try
    ZeroMemory(@TempPlayer, sizeof(TempPlayer));

    TempPlayer.Account := Packet.AccountBackup;

    Move(TempPlayer.Account.Characters[0], TempPlayer.Character, sizeof(TPlayerCharacter));
    TempPlayer.Base.Create(@TempPlayer.Character.Base, 998, Player.ChannelIndex);
    TempPlayer.Base.PlayerCharacter.LastPos := TPosition.Create(3450, 690);
    TempPlayer.SaveInGame(0, true);
    TempPlayer.Base.Destroy();

    Move(TempPlayer.Account.Characters[1], TempPlayer.Character, sizeof(TPlayerCharacter));
    TempPlayer.Base.Create(@TempPlayer.Character.Base, 998, Player.ChannelIndex);
    TempPlayer.Base.PlayerCharacter.LastPos := TPosition.Create(3450, 690);
    TempPlayer.SaveInGame(1, true);
    TempPlayer.Base.Destroy();

    Move(TempPlayer.Account.Characters[2], TempPlayer.Character, sizeof(TPlayerCharacter));
    TempPlayer.Base.Create(@TempPlayer.Character.Base, 998, Player.ChannelIndex);
    TempPlayer.Base.PlayerCharacter.LastPos := TPosition.Create(3450, 690);
    TempPlayer.SaveInGame(2, true);
    TempPlayer.Base.Destroy();

    PacketToSend.Response := 1;
  finally
    Player.SendPacket(PacketToSend, PacketToSend.Header.Size);
  end;
end;

class function TPacketHandlers.GMRequestGMUsernames(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSendRequestGMUsernames absolute Buffer;
  PacketToSend: TSendGMUsernameToClient;
  MySQLComp: TQuery;
  i: Integer;
begin
  if(Player.Base.SessionMasterPriv < AdministratorPriv) then
    Exit;

  if(Packet.Data = 1) then
  begin
    MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
      AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
      AnsiString(MYSQL_DATABASE), False);
    if not(MySQLComp.Query.Connection.Connected) then
    begin
      Logger.Write('Falha de conexão individual com mysql.[GMRequestGMUsernames]',
        TlogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMRequestGMUsernames]', TlogType.Error);
      Exit;
    end;

    MySQLComp.SetQuery('select username from gm_accounts');
    MySQLComp.Run();

    if(MySQLComp.Query.RecordCount > 0) then
    begin
      MySQLComp.Query.First;

      for I := 0 to MySQLComp.Query.RecordCount-1 do
      begin
        ZeroMemory(@PacketToSend, sizeof(PacketToSend));
        PacketToSend.Header.Size := sizeof(PacketToSend);
        PacketToSend.Header.Code := $322F;
        PacketToSend.Header.Index := Player.Base.ClientID;

        System.AnsiStrings.StrPLCopy(PacketToSend.GMUsernameTo,
           MySQLComp.Query.Fields[0].AsString, 16);

        Player.SendPacket(PacketToSend, PacketToSend.Header.Size);
        Sleep(75);

        MySQLComp.Query.Next;
      end;
    end;
    MySQLComp.Destroy;
  end;
end;

class function TPacketHandlers.GMRequestCommandsAutoriz(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSendAutorizSearchCommands absolute Buffer;
  PacketToSend: TReceiveAutorizCommandFromServer;
  gmuid, i: Integer;
  MySQLComp: TQuery;
begin
  if(Player.Base.SessionMasterPriv < AdministratorPriv) then
    Exit;

  MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
    AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
    AnsiString(MYSQL_DATABASE), False);
  if not(MySQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GMRequestGMUsernames]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMRequestGMUsernames]', TlogType.Error);
    Exit;
  end;

  if(Trim(String(Packet.GMUsername)) <> '') then
  begin //pegar os comandos filtrados por username
    MySQLComp.SetQuery('select id from gm_accounts where username = ' +
      QuotedStr(String(Packet.GMUsername)));
    MySQLComp.Run();

    if(MySQLComp.Query.RecordCount > 0) then
    begin
      gmuid := MySQLComp.Query.Fields[0].AsInteger;

      case Packet.TypeOfView of
        0:
          begin
            MySQLComp.SetQuery('select * from gm_commands where runned=1 and refused=0 and'
              + ' owner_gmid = ' + gmuid.ToString);
          end;
        1:
          begin
            MySQLComp.SetQuery('select * from gm_commands where runned=0 and refused=1 and'
              + ' owner_gmid = ' + gmuid.ToString);
          end;

        2:
          begin
            MySQLComp.SetQuery('select * from gm_commands where runned=0 and refused=0 and'
              + ' owner_gmid = ' + gmuid.ToString);
          end;

      else
        begin
          MySQLComp.Destroy;
          Exit;
        end;
      end;


      MySQLComp.Run();

      if(MySQLComp.Query.RecordCount > 0) then
      begin
        MySQLComp.Query.First;
        for I := 0 to MySQLComp.Query.RecordCount-1 do
        begin
          ZeroMemory(@PacketToSend, sizeof(PacketToSend));
          PacketToSend.Header.Size := sizeof(PacketToSend);
          PacketToSend.Header.Code := $322B;
          PacketToSend.Header.Index := Player.Base.ClientID;

          PacketToSend.GMID := gmuid;

          System.AnsiStrings.StrPLCopy(PacketToSend.GMUsername,
            String(Packet.GMUsername), 16);

          PacketToSend.CommandType := MySQLComp.Query.FieldByName('command_type').AsInteger;
          System.AnsiStrings.StrPLCopy(PacketToSend.CommandSQL,
            MySQLComp.Query.FieldByName('command').AsString, 1025);
          PacketToSend.CreatedAt := MySQLComp.Query.FieldByName('created_at').AsDateTime;
          PacketToSend.TargetItemID := MySQLComp.Query.FieldByName('target_itemid').AsInteger;
          PacketToSend.TargetItemCnt := MySQLComp.Query.FieldByName('target_itemcnt').AsInteger;
          System.AnsiStrings.StrPLCopy(PacketToSend.TargetName,
            MySQLComp.Query.FieldByName('target_name').AsString, 16);
          System.AnsiStrings.StrPLCopy(PacketToSend.ReasonCreate,
            MySQLComp.Query.FieldByName('reason_create').AsString, 16);

          Player.SendPacket(PacketToSend, PacketToSend.Header.Size);
          Sleep(75);

          MySQLComp.Query.Next;
        end;
      end;

    end;
  end
  else //pegar os comandos filtrados por data
  begin
<<<<<<< HEAD
    case Packet.TypeOfView of
      0:
        begin
          MySQLComp.SetQuery('select gc.*, ga.username from gm_commands gc inner join gm_accounts ga on ga.id = gc.owner_gmid where runned=1 and refused=0 and'
            + ' created_at >= ' + QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss',
              Packet.InitDate)) + ' and created_at <= '+ QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss',
              Packet.FinalDate)));
        end;
      1:
        begin
          MySQLComp.SetQuery('select gc.*, ga.username from gm_commands gc inner join gm_accounts ga on ga.id = gc.owner_gmid where runned=0 and refused=1 and'
            + ' created_at >= ' + QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss',
              Packet.InitDate)) + ' and created_at <= '+ QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss',
              Packet.FinalDate)));
        end;

      2:
        begin
          MySQLComp.SetQuery('select gc.*, ga.username from gm_commands gc inner join gm_accounts ga on ga.id = gc.owner_gmid where runned=0 and refused=0 and'
            + ' created_at >= ' + QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss',
              Packet.InitDate)) + ' and created_at <= '+ QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss',
              Packet.FinalDate)));
        end;

    else
      begin
        MySQLComp.Destroy;
        Exit;
      end;
    end;


    MySQLComp.Run();

    if(MySQLComp.Query.RecordCount > 0) then
    begin
      MySQLComp.Query.First;
      for I := 0 to MySQLComp.Query.RecordCount-1 do
      begin
        ZeroMemory(@PacketToSend, sizeof(PacketToSend));
        PacketToSend.Header.Size := sizeof(PacketToSend);
        PacketToSend.Header.Code := $322B;
        PacketToSend.Header.Index := Player.Base.ClientID;

        PacketToSend.CommandID := MySQLComp.Query.FieldByName('id').AsInteger;

        PacketToSend.GMID := MySQLComp.Query.FieldByName('owner_gmid').AsInteger;

        System.AnsiStrings.StrPLCopy(PacketToSend.GMUsername,
          MySQLComp.Query.FieldByName('username').AsString, 16);

        PacketToSend.CommandType := MySQLComp.Query.FieldByName('command_type').AsInteger;
        System.AnsiStrings.StrPLCopy(PacketToSend.CommandSQL,
          MySQLComp.Query.FieldByName('command').AsString, 1025);
        PacketToSend.CreatedAt := MySQLComp.Query.FieldByName('created_at').AsDateTime;
        PacketToSend.TargetItemID := MySQLComp.Query.FieldByName('target_itemid').AsInteger;
        PacketToSend.TargetItemCnt := MySQLComp.Query.FieldByName('target_itemcnt').AsInteger;
        System.AnsiStrings.StrPLCopy(PacketToSend.TargetName,
          MySQLComp.Query.FieldByName('target_name').AsString, 16);
        System.AnsiStrings.StrPLCopy(PacketToSend.ReasonCreate,
            MySQLComp.Query.FieldByName('reason_create').AsString, 16);

        Player.SendPacket(PacketToSend, PacketToSend.Header.Size);
        Sleep(75);

        MySQLComp.Query.Next;
      end;
    end
    else
    begin
      Player.SendMessageToPainel('Não foram encontrados registros para autorização.', MB_ICONEXCLAMATION, 0);
    end;
  end;

  MySQLComp.Destroy;
end;

class function TPacketHandlers.GMApproveCommand(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TAcceptCommandPacket absolute Buffer;
  MySQLComp: TQuery;
  TargetToName: String;
  CharIndex, i: Integer;
  ItemID, ItemAmount, CommandType: WORD;
  OtherPlayer: PPlayer;
  AlreadyGived: Boolean;
  CharLevel: WORD;
  LevelExp: UInt64;
  LevelNow: WORD;
  Cupom, Commandx: String;
begin
  Cupom := '';
  if(Player.Base.SessionMasterPriv < AdministratorPriv) then
    Exit;

  MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
    AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
    AnsiString(MYSQL_DATABASE), False);
  if not(MySQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GMApproveCommand]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMApproveCommand]', TlogType.Error);
    MySQLComp.Destroy;
    Exit;
  end;

  MySQLComp.SetQuery('SELECT command, command_type, target_itemid, target_itemcnt, target_name, runned, refused FROM '+
    'gm_commands WHERE id = ' + Packet.CommandID.ToString);
  MySQLComp.Run();

  if(MySQLComp.Query.RecordCount > 0) then
  begin

    if((MySQLComp.Query.FieldByName('runned').AsInteger = 1) or
    (MySQLComp.Query.FieldByName('refused').AsInteger = 1)) then
    begin
      MySQLComp.Destroy;
      Exit;
    end;

    TargetToName := MySQLComp.Query.FieldByName('target_name').AsString;
    ItemID := MySQLComp.Query.FieldByName('target_itemid').AsInteger;
    ItemAmount := MySQLComp.Query.FieldByName('target_itemcnt').AsInteger;
    CommandType := MySQLComp.Query.FieldByName('command_type').AsInteger;
    Commandx := MySQLComp.Query.FieldByName('command').AsString;

    MySQLComp.SetQuery('SELECT id, level FROM characters WHERE name = ' +
      QuotedStr(TargetToName));
    MySQLComp.Run();

    if((MySQLComp.Query.RecordCount > 0) or
    (CommandType in [3, 4])) then
    begin
      if not(CommandType in [3, 4]) then
      begin
        CharIndex := MySQLComp.Query.FieldByName('id').AsInteger;
        CharLevel := MySQLComp.Query.FieldByName('level').AsInteger;
      end;

      case CommandType of
        1: //level
          begin

            AlreadyGived := False;

            for I := Low(Servers) to High(Servers) do
            begin
              if(Servers[i].GetPlayerByName(TargetToName, OtherPlayer)) then
              begin //da o level ao vivo
                OtherPlayer.AddLevel(ItemAmount);

                AlreadyGived := True;
                break;
              end;
            end;

            if not(AlreadyGived) then
            begin //atualiza na db
              if((CharLevel + ItemAmount) >= LEVEL_CAP) then
                LevelNow := LEVEL_CAP
              else
                LevelNow := (CharLevel + ItemAmount);

              LevelExp := ExpList[LevelNow-1] + 1;

              MySQLComp.SetQuery('UPDATE characters SET level=' +
                LevelNow.ToString + ', experience=' + LevelExp.ToString +
                ' WHERE id = ' + CharIndex.ToString);
              MySQLComp.Run(False);
            end;
          end;

        2: //item
          begin
            MySQLComp.SetQuery(Format
              ('INSERT INTO items (id, slot_type, owner_id, slot, item_id, app, '+
              'identific, effect1_index, effect1_value, effect2_index, effect2_value, '+
              'effect3_index, effect3_value, min, max, refine, time, owner_mail_slot) ' +
              'VALUES (0, %d, %d, 0, %d, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, %d, 0, 0)', [EVENT_ITEM,
              CharIndex, ItemID, ItemAmount]));
            MySQLComp.Run(False);

            for I := Low(Servers) to High(Servers) do
            begin
              if(Servers[i].GetPlayerByName(TargetToName, OtherPlayer)) then
              begin
                OtherPlayer.SendClientMessage('Você recebeu um item de evento. Pressione T.');
                break;
              end;
            end;
          end;

        3, 4: //cupom
          begin
            Cupom := Commandx;
          end;
      end;
    end;
  end;

  MySQLComp.SetQuery(Format('UPDATE gm_commands SET runned = 1, reason_run=%s,'+
    'runned_at=%s, runned_by=%s, command=CONCAT(command,%s), coupom=%s WHERE id=%d', [QuotedStr(String(Packet.Reason)),
    QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)), QuotedStr(Player.Base.SessionUsername),
    QuotedStr(#13 + 'Motivo Aprovado: ' + String(Packet.Reason)),
      QuotedStr(Cupom),Packet.CommandID]));
  MySQLComp.Run(False);

  MySQLComp.Destroy;

  Player.SendMessageToPainel('Comando APROVADO com sucesso.',
    MB_ICONINFORMATION, 0);
end;

class function TPacketHandlers.GMReproveCommand(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TRefuseCommandPacket absolute Buffer;
  MySQLComp: TQuery;
begin
  if(Player.Base.SessionMasterPriv < AdministratorPriv) then
    Exit;

  MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
    AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
    AnsiString(MYSQL_DATABASE), False);
  if not(MySQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GMReproveCommand]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMReproveCommand]', TlogType.Error);
    MySQLComp.Destroy;
    Exit;
  end;

  MySQLComp.SetQuery(Format('UPDATE gm_commands SET refused = 1, reason_refuse=%s,'+
    'refused_at=%s, runned_by=%s, command=CONCAT(command,%s) WHERE id=%d', [QuotedStr(String(Packet.Reason)),
    QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)), QuotedStr(Player.Base.SessionUsername),
    QuotedStr(#13 + 'Motivo Reprovado: ' + String(Packet.Reason)), Packet.CommandID]));
  MySQLComp.Run(False);

  MySQLComp.Destroy;

  Player.SendMessageToPainel('Comando REPROVADO com sucesso.',
    MB_ICONINFORMATION, 0);
=======

  end;
>>>>>>> parent of 2438a94 (modificacoes 05/12)
end;

class function TPacketHandlers.GMSendAddEffect(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSendAddEffectGMPacket absolute Buffer;
  OtherPlayer: PPlayer;
begin
  Result := False;

  if(Player.Base.SessionMasterPriv < GameMasterPriv) then
    Exit;

  if(Packet.TargetID = 0) then
    Packet.TargetID := Player.Base.ClientID;

  OtherPlayer := nil;
  OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(Packet.TargetID);

  if(OtherPlayer <> nil) then
  begin
    OtherPlayer.SendEffect(Packet.EffectID);
  end;

  Result := True;
end;

class function TPacketHandlers.GMRequestCreateCoupom(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSendCreateCoupomRequest absolute Buffer;
  MySQLComp: TQuery;
  gmuid: Integer;
  Coupom, xx: String;
  Product, i: Integer;
  cmdto, cntto: Integer;
begin
  Product := 0;
  if(Player.Base.SessionMasterPriv < ModeradorPriv) then
    Exit;

  if(Trim(String(Packet.GMUsername)) = '') then
    Exit;

  MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
    AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
    AnsiString(MYSQL_DATABASE), True);
  if not(MySQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GMRequestCreateCoupom]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMRequestCreateCoupom]', TlogType.Error);
    MySQLComp.Destroy;
    Exit;
  end;

  MySQLComp.SetQuery('select id from gm_accounts where username = ' +
    QuotedStr(Player.Base.SessionUsername));
  MySQLComp.Run();

  if(MySQLComp.Query.RecordCount = 0) then
  begin
    MySQLComp.Destroy;
    Exit;
  end;

  if(Packet.ItemID > 0) then
  begin
    Product := Packet.ItemID;
    cmdto := FOUNDER_GMCOMMAND;

    if(Packet.ItemAmount > 0) then
    begin
      cntto := Packet.ItemAmount;
    end
    else
    begin
      cntto := 1;
    end;
  end
  else
  begin
    case Packet.PinCodeType of
      0:
        Product := 10;
      1:
        Product := 20;
      2:
        Product := 50;
      3:
        Product := 100;
    end;
    cntto := 0;
    cmdto := COUPOM_GMCOMMAND;
  end;
  Coupom :=  '';
  xx := UpperCase(TFunctions.StringToMd5(DateTimeToStr(Now)));
  for I := 1 to 16 do
  begin
    SetLength(Coupom, Length(Coupom)+1);
    Coupom[High(Coupom)] := xx[i];
    if(i in [4,8,12]) then
    begin
      SetLength(Coupom, Length(Coupom)+1);
      Coupom[High(Coupom)] := '-';
    end;
  end;

  gmuid := MySQLComp.Query.FieldByName('id').AsInteger;

  MySQLComp.SetQuery(Format('INSERT INTO gm_commands (owner_gmid,command_type,runned,command,'+
    'created_at, runned_at, runned_by, target_name, target_itemid, target_itemcnt, refused,'+
    'refused_at, reason_run, reason_refuse, reason_create, coupom) VALUES (%d, %d, %d, %s, %s, %s, %s, %s, %d, %d,'+
    '%d, %s, %s, %s, %s, %s)', [gmuid, cmdto, 0,
    QuotedStr(Coupom), QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)),
    QuotedStr('1899-12-30'), QuotedStr(''), QuotedStr(''),
    Product, cntto, 0, QuotedStr('1899-12-30'), QuotedStr(''), QuotedStr(''),
    QuotedStr(String(Packet.Reason)), QuotedStr(Coupom)]));
  MySQLComp.Query.Connection.StartTransaction;
  MySQLComp.Run(False);
  MySQLComp.Query.Connection.Commit;

  if(MySQLComp.Query.RowsAffected > 0) then
  begin
    Player.SendMessageToPainel('Cupom ['+Coupom+'] registrado com sucesso.' + #13+
      'Aguardando aprovação do administrador para cupom ter validade.', MB_ICONINFORMATION, 0);
  end;

  MySQLComp.Destroy;
end;

class function TPacketHandlers.GMRequestComprovantSearchID(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSearchComprovantByID absolute Buffer;
  PacketToSend: TComprovantReceive;
  MySQLComp, MySQLCompAux: TQuery;
begin
  if not((Player.CheckGameMasterLogged) or (Player.CheckAdminLogged)) then
    Exit;

  MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
    AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
    AnsiString(MYSQL_DATABASE), False);
  if not(MySQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GMRequestComprovantSearchID]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMRequestComprovantSearchID]', TlogType.Error);
    MySQLComp.Destroy;
    Exit;
  end;

  if(String(Packet.TransactionID) <> '') then
  begin
    MySQLComp.SetQuery('select * from founders where idtransaction=' +
      QuotedStr(UPPERCASE(String(Packet.TransactionID))));
    MySQLComp.Run();

    if(MySQLComp.Query.RecordCount = 0) then
    begin
      Player.SendMessageToPainel('O comprovante em questão não foi encontrado.',
        MB_ICONERROR, 0);
      MySQLComp.Destroy;
      Exit;
    end;

    ZeroMemory(@PacketToSend, sizeof(TComprovantReceive));
    PacketToSend.Header.Size := sizeof(PacketToSend);
    PacketToSend.Header.Code := $3244;
    PacketToSend.Header.Index := Player.Base.ClientID;

    PacketToSend.ComprovantDBID := MySQLComp.Query.FieldByName('id').AsInteger;

    System.AnsiStrings.StrPLCopy(PacketToSend.TransactionID,
      MySQLComp.Query.FieldByName('idtransaction').AsString, 256);
    System.AnsiStrings.StrPLCopy(PacketToSend.NameOfComprovant,
      MySQLComp.Query.FieldByName('name').AsString, 256);
    PacketToSend.ValueOfComprovant :=
      MySQLComp.Query.FieldByName('valueofcomprovant').AsFloat;
    PacketToSend.DateOfComprovant :=
      MySQLComp.Query.FieldByName('dateofcomprovant').AsDateTime;
    PacketToSend.IsValidated := Boolean(MySQLComp.Query.FieldByName('validated').AsInteger);

    MySQLCompAux := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), False);
    if not(MySQLCompAux.Query.Connection.Connected) then
    begin
      Logger.Write('Falha de conexão individual com mysql.[GMRequestComprovantSearchID_aux]',
        TlogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMRequestComprovantSearchID_aux]', TlogType.Error);
      MySQLCompAux.Destroy;
      Exit;
    end;

    MySQLCompAux.SetQuery('select username from gm_accounts where id='+
      MySQLComp.Query.FieldByName('validated_gmid').AsString);
    MySQLCompAux.Run();

    if(MySQLCompAux.Query.RecordCount > 0) then
    begin
      System.AnsiStrings.StrPLCopy(PacketToSend.ValidatedBy,
      MySQLCompAux.Query.FieldByName('username').AsString, 64);
    end;

    System.AnsiStrings.StrPLCopy(PacketToSend.CoupomAttributed,
      MySQLComp.Query.FieldByName('coupom').AsString, 64);

    MySQLCompAux.Destroy;


    Player.SendPacket(PacketToSend, PacketToSend.Header.Size);
  end;

  MySQLComp.Destroy;
end;

class function TPacketHandlers.GMRequestComprovantSearchName(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TSearchComprovantByName absolute Buffer;
  PacketToSend: TComprovantReceive;
  MySQLComp, MySQLCompAux: TQuery;
  i: Integer;
begin
  if not((Player.CheckGameMasterLogged) or (Player.CheckAdminLogged)) then
    Exit;

  MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
    AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
    AnsiString(MYSQL_DATABASE), False);
  if not(MySQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GMRequestComprovantSearchName]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMRequestComprovantSearchName]', TlogType.Error);
    MySQLComp.Destroy;
    Exit;
  end;

  if(String(Packet.NameOfComprovant) <> '') then
  begin
    MySQLComp.SetQuery('select * from founders where name LIKE "%' +
      (String(Packet.NameOfComprovant)) + '%"');
    MySQLComp.Run();

    if(MySQLComp.Query.RecordCount = 0) then
    begin
      Player.SendMessageToPainel('O comprovante em questão não foi encontrado.',
        MB_ICONERROR, 0);
      MySQLComp.Destroy;
      Exit;
    end;

    MySQLComp.Query.First;

    for I := 0 to MySQLComp.Query.RecordCount-1 do
    begin
      ZeroMemory(@PacketToSend, sizeof(TComprovantReceive));
      PacketToSend.Header.Size := sizeof(PacketToSend);
      PacketToSend.Header.Code := $3244;
      PacketToSend.Header.Index := Player.Base.ClientID;

      PacketToSend.ComprovantDBID := MySQLComp.Query.FieldByName('id').AsInteger;

      System.AnsiStrings.StrPLCopy(PacketToSend.TransactionID,
        MySQLComp.Query.FieldByName('idtransaction').AsString, 256);
      System.AnsiStrings.StrPLCopy(PacketToSend.NameOfComprovant,
        MySQLComp.Query.FieldByName('name').AsString, 256);
      PacketToSend.ValueOfComprovant :=
        MySQLComp.Query.FieldByName('valueofcomprovant').AsFloat;
      PacketToSend.DateOfComprovant :=
        MySQLComp.Query.FieldByName('dateofcomprovant').AsDateTime;
      PacketToSend.IsValidated := Boolean(MySQLComp.Query.FieldByName('validated').AsInteger);

      MySQLCompAux := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
      AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
      AnsiString(MYSQL_DATABASE), False);
      if not(MySQLCompAux.Query.Connection.Connected) then
      begin
        Logger.Write('Falha de conexão individual com mysql.[GMRequestComprovantSearchName_aux]',
          TlogType.Warnings);
        Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMRequestComprovantSearchName_aux]', TlogType.Error);
        MySQLCompAux.Destroy;
        Exit;
      end;

      MySQLCompAux.SetQuery('select username from gm_accounts where id='+
        MySQLComp.Query.FieldByName('validated_gmid').AsString);
      MySQLCompAux.Run();

      if(MySQLCompAux.Query.RecordCount > 0) then
      begin
        System.AnsiStrings.StrPLCopy(PacketToSend.ValidatedBy,
        MySQLCompAux.Query.FieldByName('username').AsString, 64);
      end;

      System.AnsiStrings.StrPLCopy(PacketToSend.CoupomAttributed,
        MySQLComp.Query.FieldByName('coupom').AsString, 64);

      MySQLCompAux.Destroy;


      Player.SendPacket(PacketToSend, PacketToSend.Header.Size);

      MySQLComp.Query.Next;
    end;
  end;

  MySQLComp.Destroy;
end;

class function TPacketHandlers.GMRequestCreateComprovant(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TComprovantCreate absolute Buffer;
  MySQLComp: TQuery;
  gmuid: Integer;
  Coupom, xx: String;
  Product, i: Integer;
begin
  if not(Player.CheckAdminLogged) then
    Exit;
  Product := 0;
  MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
    AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
    AnsiString(MYSQL_DATABASE), True);
  if not(MySQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GMRequestCreateComprovant]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMRequestCreateComprovant]', TlogType.Error);
    MySQLComp.Destroy;
    Exit;
  end;

  if((Packet.TransactionID <> '') and (Packet.NameOfComprovant <> '') and
    (Packet.ValueOfComprovant <> 0) and (DateToStr(Packet.DateOfComprovant) <> '')) then
  begin
    MySQLComp.SetQuery('SELECT id from gm_accounts where username = ' +
      QuotedSTr(Player.Base.SessionUsername));
    MySQLComp.Run();

    gmuid := MySQLComp.Query.FieldByName('id').AsInteger;

    MySQLComp.SetQuery('SELECT id from founders where idtransaction=' +
      QuotedStr(string(packet.TransactionID)));
    MySQLComp.Run();

    if(MySQLComp.Query.RecordCount > 0) then
    begin
      Player.SendMessageToPainel('Esse ID de transação já existe.', MB_ICONERROR, 0);
      MySQLComp.Destroy;
      Exit;
    end;

    case Round(Packet.ValueOfComprovant) of
      1..30:
        Product := 14134;
      31..59:
        Product := 14135;
      60..228:
        Product := 14136;
      229..330:
        Product := 14137;
    end;
    Coupom :=  '';

    if(Product > 0) then
    begin
      xx := UpperCase(TFunctions.StringToMd5(DateTimeToStr(Now)));
      for I := 1 to 16 do
      begin
        SetLength(Coupom, Length(Coupom)+1);
        Coupom[High(Coupom)] := xx[i];
        if(i in [4,8,12]) then
        begin
          SetLength(Coupom, Length(Coupom)+1);
          Coupom[High(Coupom)] := '-';
        end;
      end;
    end;

    MySQLComp.SetQuery(Format('INSERT INTO gm_commands (owner_gmid,command_type,runned,command,'+
    'created_at, runned_at, runned_by, target_name, target_itemid, target_itemcnt, refused,'+
    'refused_at, reason_run, reason_refuse, reason_create, coupom) VALUES (%d, %d, %d, %s, %s, %s, %s, %s, %d, %d,'+
    '%d, %s, %s, %s, %s, %s)', [gmuid, FOUNDER_GMCOMMAND, 1,
    QuotedStr(Coupom), QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)),
    QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)), QuotedStr(Player.Base.SessionUsername), QuotedStr(''),
    Product, 1, 0, QuotedStr('1899-12-30'), QuotedStr(''), QuotedStr(''),
    QuotedStr(String('Criação de cupom para recebimento de founder via comprovante.')), QuotedStr(Coupom)]));
    MySQLComp.Query.Connection.StartTransaction;
    MySQLComp.Run(False);
    MySQLComp.Query.Connection.Commit;

    MySQLComp.SetQuery(Format('INSERT INTO founders (idtransaction, name, dateofcomprovant, '+
      'valueofcomprovant, coupom) VALUES (%s, %s, %s, %s, %s)',
      [QuotedStr(String(Packet.TransactionID)), QuotedStr(String(Packet.NameOfComprovant)),
      QuotedStr(FormatDateTime('yyyy-mm-dd', Packet.DateOfComprovant)),
      ReplaceStr(FloatToStr(Packet.ValueOfComprovant), ',', '.'),
      QuotedStr(Coupom)]));
    MySQLComp.Query.Connection.StartTransaction;
    MySQLComp.Run(False);
    MySQLComp.Query.Connection.Commit;

    if(MySQLComp.Query.RowsAffected > 0) then
    begin
      if(Coupom <> '') then
      begin
        Player.SendMessageToPainel('Comprovante cadastrado com sucesso.' +
          #13 + 'Cupom de ativação do founder: ' + Coupom, MB_ICONINFORMATION, 0);
      end
      else
      begin
        Player.SendMessageToPainel('Comprovante cadastrado com sucesso.' +
        #13 + 'Parece que o valor foi diferente do cadastrado. Necessária criação manual do cupom.', MB_ICONINFORMATION, 0);
      end;
    end;
  end
  else
  begin
    Player.SendMessageToPainel('Dados corrompidos durante transmissão.', MB_ICONERROR, 0);
  end;

  MySQLComp.Destroy;
end;

class function TPacketHandlers.GMRequestComprovantValidate(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TComprovantValidate absolute Buffer;
  MySQLComp: TQuery;
  gmuid, founderuid: Integer;
begin
  if not((Player.CheckGameMasterLogged) or (Player.CheckAdminLogged)) then
    Exit;

  MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
    AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
    AnsiString(MYSQL_DATABASE), True);
  if not(MySQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GMRequestComprovantValidate]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMRequestComprovantValidate]', TlogType.Error);
    MySQLComp.Destroy;
    Exit;
  end;

  if(Packet.ComprovantDBID > 0) then
  begin
    MySQLComp.SetQuery('SELECT id from gm_accounts where username = ' +
      QuotedSTr(Player.Base.SessionUsername));
    MySQLComp.Run();

    gmuid := MySQLComp.Query.FieldByName('id').AsInteger;

    MySQLComp.SetQuery('select * from founders where id='+
      Packet.ComprovantDBID.ToString);
    MySQLComp.Run();

    if(MySQLComp.Query.RecordCount = 0) then
    begin
      Player.SendMessageToPainel('Solicitação não encontrada.', MB_ICONERROR, 0);
      MySQLComp.Destroy;
      Exit;
    end
    else
    begin
      if(MySQLComp.Query.FieldByName('validated').AsInteger = 1) then
      begin
        Player.SendMessageToPainel('Solicitação já foi validada.', MB_ICONERROR, 0);
        MySQLComp.Destroy;
        Exit;
      end;

      founderuid := MySQLComp.Query.FieldByName('id').AsInteger;

      MySQLComp.SetQuery('UPDATE founders SET validated=1, validated_gmid='+
        gmuid.ToString + ' WHERE id =' + founderuid.ToString);
      MySQLComp.Run(False);

      if(MySQLComp.Query.RowsAffected > 0) then
      begin
        Player.SendMessageToPainel('Você LEU o ticket, ACHOU o compovante, MARCOU como entregue e ENTREGOU o produto no mesmo ticket.', MB_ICONINFORMATION, 0);
      end;
    end;
  end;

  MySQLComp.Destroy;
end;

class function TPacketHandlers.GMRequestDeletePrans(var Player: TPlayer; Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TPacketSendDeletePrans absolute Buffer;
  MySQLComp: TQuery;
  charID: Integer;
begin
  if not((Player.CheckGameMasterLogged) or (Player.CheckAdminLogged)) then
    Exit;

  MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
    AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
    AnsiString(MYSQL_DATABASE), True);
  if not(MySQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GMRequestDeletePrans]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMRequestDeletePrans]', TlogType.Error);
    MySQLComp.Destroy;
    Exit;
  end;

  if(Packet.AccountIndex > 0) then
  begin
    MySQLComp.SetQuery('SELECT * from prans where acc_id = ' +
      Packet.AccountIndex.ToString);
    MySQLComp.Run();

    if(MySQLComp.Query.RecordCount > 0) then
    begin
      try
        charID := MySQLComp.Query.FieldByName('char_id').AsInteger;

        MySQLComp.SetQuery
        ('delete from quests where questid in (39, 40, 41, 406, 407) and charid = ' +
          charID.ToString);
        MySQLComp.Run(False);
        MySQLComp.SetQuery('delete from items where owner_id = '+
          charID.ToString +' and slot_type = 0 and item_id in (100,101,102,103,104,105)');
        MySQLComp.Run(False);
        MySQLComp.SetQuery('delete from items where owner_id = '+
          charID.ToString +' and slot_type = 1 and item_id in (100,101,102,103,104,105)');
        MySQLComp.Run(False);
        MySQLComp.SetQuery('delete from items where owner_id = '+
          Packet.AccountIndex.ToString +' and slot_type = 2 and item_id in (100,101,102,103,104,105)');
        MySQLComp.Run(False);
      finally
        Player.SendMessageToPainel('Procedimento executado.' + #13 +
          'tables affected: prans, items, quests',
         MB_ICONINFORMATION, 0);
      end;
    end
    else
    begin
      Player.SendMessageToPainel('Não existem prans no banco de dados linkados a conta.',
         MB_ICONERROR, 0);
    end;
  end;

end;

class function TPacketHandlers.RequestAllAttributes(var Player: TPlayer;
  Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TRequestAllAttributes absolute Buffer;
  Packet2: TResponseAllAttributes;
begin
  if not(Player.Status >= Playing) then
  begin
    Exit;
  end;
  Player.Base.GetCurrentScore;
  ZeroMemory(@Packet2, sizeof(TResponseAllAttributes));
  Packet2.Header.size := sizeof(TResponseAllAttributes);
  Packet2.Header.Index := Player.Base.ClientID;
  Packet2.Header.code := $23FF;
  Packet2.Resfriamento := Player.Base.PlayerCharacter.ReduceCooldown;
  Packet2.DanoHab := Player.Base.PlayerCharacter.HabAtk;
  Packet2.Cura := Player.Base.PlayerCharacter.CureTax;
  Packet2.DanoPvp := Player.Base.PlayerCharacter.PvPDamage;
  Packet2.DefPvp := Player.Base.PlayerCharacter.PvPDefense;
  Packet2.PerFis := Player.Base.PlayerCharacter.FisPenetration;
  Packet2.PerMag := Player.Base.PlayerCharacter.MagPenetration;
  Packet2.RecHP := Player.Base.GetMobAbility(EF_REGENHP) +
    Player.Base.GetMobAbility(EF_PRAN_REGENHP) +
    (Player.Base.PlayerCharacter.Base.CurrentScore.CONS * 3);
  Packet2.RecMP := Player.Base.GetMobAbility(EF_REGENMP) +
    Player.Base.GetMobAbility(EF_PRAN_REGENMP) +
    (Player.Base.PlayerCharacter.Base.CurrentScore.CONS * 3);
  Packet2.DanoCrit := Player.Base.PlayerCharacter.DamageCritical;
  Packet2.ResisCrit := Player.Base.PlayerCharacter.CritRes;
  Packet2.ResisDuplo := Player.Base.PlayerCharacter.DuploRes;
  Packet2.DiminDanoCrit := Player.Base.PlayerCharacter.ResDamageCritical;
  Packet2.ResisLent := Player.Base.GetMobAbility(EF_IM_RUNSPEED) + Player.Base.PlayerCharacter.Resistence;
  Packet2.ResisStun := Player.Base.GetMobAbility(EF_IM_SKILL_STUN) + Player.Base.PlayerCharacter.Resistence;
  Packet2.ResisSilence := Player.Base.GetMobAbility(EF_IM_SILENCE1) + Player.Base.PlayerCharacter.Resistence;
  Packet2.ResisChoque := Player.Base.GetMobAbility(EF_IM_SKILL_SHOCK) + Player.Base.PlayerCharacter.Resistence;
  Packet2.ResisImobi := Player.Base.GetMobAbility(EF_IM_SKILL_IMMOVABLE) + Player.Base.PlayerCharacter.Resistence;
  Packet2.ResisMedo := Player.Base.GetMobAbility(EF_IM_FEAR) + Player.Base.PlayerCharacter.Resistence;
  Player.SendPacket(Packet2, Packet2.Header.size);
end;
class function TPacketHandlers.RequestAllAttributesTarget(var Player: TPlayer;
  Buffer: ARRAY OF BYTE): Boolean;
var
  Packet: TRequestAllAttributesTarget absolute Buffer;
  Packet2: TResponseAllAttributesTarget;
  OtherPlayer: PPlayer;
begin
  if not(Player.Status >= Playing) then
  begin
    Exit;
  end;
  OtherPlayer := @Servers[Player.ChannelIndex].Players[Packet.TargetID];
  if(OtherPlayer.Base.Character.Nation > 0) then
  begin
    if(OtherPlayer.Base.Character.Nation <> Player.Base.Character.Nation) then
    begin
      Player.SendClientMessage('O alvo não pertence a sua nação.');
      Exit;
    end;
  end;
  OtherPlayer.Base.GetCurrentScore;
  ZeroMemory(@Packet2, sizeof(TResponseAllAttributesTarget));
  Packet2.Header.size := sizeof(TResponseAllAttributesTarget);
  Packet2.Header.Index := OtherPlayer.Base.ClientID;
  Packet2.Header.code := $23FC;
  Packet2.Resfriamento := OtherPlayer.Base.PlayerCharacter.ReduceCooldown;
  Packet2.DanoHab := OtherPlayer.Base.PlayerCharacter.HabAtk;
  Packet2.Cura := OtherPlayer.Base.PlayerCharacter.CureTax;
  Packet2.DanoPvp := OtherPlayer.Base.PlayerCharacter.PvPDamage;
  Packet2.DefPvp := OtherPlayer.Base.PlayerCharacter.PvPDefense;
  Packet2.PerFis := OtherPlayer.Base.PlayerCharacter.FisPenetration;
  Packet2.PerMag := OtherPlayer.Base.PlayerCharacter.MagPenetration;
  Packet2.RecHP := OtherPlayer.Base.GetMobAbility(EF_REGENHP) +
    OtherPlayer.Base.GetMobAbility(EF_PRAN_REGENHP) +
    (OtherPlayer.Base.PlayerCharacter.Base.CurrentScore.CONS * 3);
  Packet2.RecMP := OtherPlayer.Base.GetMobAbility(EF_REGENMP) +
    OtherPlayer.Base.GetMobAbility(EF_PRAN_REGENMP) +
    (OtherPlayer.Base.PlayerCharacter.Base.CurrentScore.CONS * 3);
  Packet2.DanoCrit := OtherPlayer.Base.PlayerCharacter.DamageCritical;
  Packet2.ResisCrit := OtherPlayer.Base.PlayerCharacter.CritRes;
  Packet2.ResisDuplo := OtherPlayer.Base.PlayerCharacter.DuploRes;
  Packet2.DiminDanoCrit := OtherPlayer.Base.PlayerCharacter.ResDamageCritical;
  Packet2.ResisLent := OtherPlayer.Base.GetMobAbility(EF_IM_RUNSPEED) + OtherPlayer.Base.PlayerCharacter.Resistence;
  Packet2.ResisStun := OtherPlayer.Base.GetMobAbility(EF_IM_SKILL_STUN) + OtherPlayer.Base.PlayerCharacter.Resistence;
  Packet2.ResisSilence := OtherPlayer.Base.GetMobAbility(EF_IM_SILENCE1) + OtherPlayer.Base.PlayerCharacter.Resistence;
  Packet2.ResisChoque := OtherPlayer.Base.GetMobAbility(EF_IM_SKILL_SHOCK) + OtherPlayer.Base.PlayerCharacter.Resistence;
  Packet2.ResisImobi := OtherPlayer.Base.GetMobAbility(EF_IM_SKILL_IMMOVABLE) + OtherPlayer.Base.PlayerCharacter.Resistence;
  Packet2.ResisMedo := OtherPlayer.Base.GetMobAbility(EF_IM_FEAR) + OtherPlayer.Base.PlayerCharacter.Resistence;
  Player.SendPacket(Packet2, Packet2.Header.size);
end;
{$ENDREGION}
{$REGION 'Auction'}
class function TPacketHandlers.RequestAuctionItems(var Player: TPlayer;
  Buffer: Array of BYTE): Boolean;
var
  Packet: TRequestAuctionItemsPacket absolute Buffer;
begin
  Result := true;
  Player.SendClientMessage('O leilão foi desativado por questões do crash.');
  Exit;

  if not(TAuctionFunctions.GetAuctionItems(Player, Packet.ItemType,
    Packet.LevelMin, Packet.LevelMax, Packet.ReinforceMin, Packet.ReinforceMax,
    Packet.SearchByName)) then
  begin
    Player.SendClientMessage('Erro ao obter items do leilão!');
    Result := False;
  end;
end;
class function TPacketHandlers.RequestRegisterItem(var Player: TPlayer;
  Buffer: Array of BYTE): Boolean;
var
  Packet: TAuctionRegisterItemPacket absolute Buffer;
begin
  Player.SendClientMessage('O leilão foi desativado por questões do crash.');
  Exit;

  if not(TAuctionFunctions.RegisterAuctionItem(Player, Packet.Price,
    Packet.Slot, Packet.Time)) then
  begin
    Player.SendClientMessage('Erro ao registrar item no leilão!');
  end;
end;
class function TPacketHandlers.RequestOwnAuctionItems(var Player: TPlayer;
  Buffer: Array of BYTE): Boolean;
begin
  Player.SendClientMessage('O leilão foi desativado por questões do crash.');
  Exit;

  if not(TAuctionFunctions.GetSelfAuctionItems(Player)) then
  begin
    Player.SendClientMessage('Erro ao consultar seus itens no leilão!');
  end;
end;
class function TPacketHandlers.RequestAuctionOfferCancel(var Player: TPlayer;
  Buffer: Array of BYTE): Boolean;
var
  Packet: TAuctionCancelOfferPacket absolute Buffer;
begin
  Player.SendClientMessage('O leilão foi desativado por questões do crash.');
  Exit;

  if(TItemFunctions.GetEmptySlot(Player) = 255) then
  begin
    Player.SendClientMessage('Inventário cheio.');
    Exit;
  end;

  if not(TAuctionFunctions.CancelItemOffer(Player, Packet.AuctionOfferId)) then
  begin
    Player.SendClientMessage('Erro ao cancelar oferta no leilão!');
  end;
end;
class function TPacketHandlers.RequestAuctionOfferBuy(var Player: TPlayer;
  Buffer: Array of BYTE): Boolean;
var
  Packet: TAuctionCancelOfferPacket absolute Buffer;
begin
  Player.SendClientMessage('O leilão foi desativado por questões do crash.');
  Exit;

  if(TItemFunctions.GetEmptySlot(Player) = 255) then
  begin
    Player.SendClientMessage('Inventário cheio.');
    Exit;
  end;

  if not(TAuctionFunctions.RequestBuyItem(Player, Packet.AuctionOfferId)) then
  begin
    Player.SendClientMessage('Erro ao comprar oferta no leilão!');
  end;
end;
{$ENDREGION}
{$REGION 'Reliquiares'}

class function TPacketHandlers.MoveItemToReliquare(var Player: TPlayer;
  Buffer: Array of BYTE): Boolean;
var
  Packet: TMoveItemToReliquare absolute Buffer;
  item: pItem;
  SellPrice, i, j, Honor, ItemSLot, AuxPrice,k: Integer;
  TempleSpace: TSpaceTemple;
  ReliqIndex: WORD;
  EmptySlot, AuxSlot: Byte;
  PriceItem: TItemPrice;
  AlreadyReliq: Byte;
  TimeEst: TDateTime;
  AuxSlotItem: DWORD;
begin


  if(Packet.DevirClientID = 263) then
  begin //entregar reliquia
    Item := @Player.Character.Base.Inventory[Packet.SrcSlot];

    case Item^.Index of
      { Sistema de Cap Reliquias }
      6370 .. 6444 , 12000 .. 12032:
        begin
          //if(Packet.DevirID = 0) then
            //TempleSpace := Servers[Player.ChannelIndex].GetFreeTempleSpaceByIndex(Packet.DevirID-1)
          //else
            TempleSpace := Servers[Player.ChannelIndex].GetFreeTempleSpaceByIndex(Player.OpennedDevir);

          if (TempleSpace.DevirID = 255) then
          begin
            Player.SendClientMessage
              ('Todos os espaços sagrados disponíveis estão lotados.');
            Exit;
          end;
          if((Player.Base.Character.Nation = 0) or (
            Player.Base.Character.Nation <> Servers[Player.ChannelIndex].Devires[TempleSpace.DevirID].NationID)) then
          begin
            Player.SendClientMessage
              ('Para que seja computado a relíquia, deve se ter nacionalidade no país.');
            Exit;
          end;

          for I := Low(Servers) to High(Servers) do
          begin
            if not(Servers[i].IsActive) then
              Continue;
            for j := 0 to 5 do
            begin
              for k := 0 to 5 do
              begin
                if(Servers[i].Devires[j].Slots[k].Furthed) then
                begin
                  if(Servers[i].Devires[j].Slots[k].ItemFurthed =
                    Item.Index) then
                  begin
                    Servers[i].Devires[j].Slots[k].Furthed := False;
                    Servers[i].Devires[j].Slots[k].ItemFurthed := 0;
                    break;
                  end;
                end;
              end;
            end;
          end;

          Servers[Player.ChannelIndex].Devires[TempleSpace.DevirID]
            .Slots[TempleSpace.SlotID].ItemID := Item^.Index;
          Servers[Player.ChannelIndex].Devires[TempleSpace.DevirID]
            .Slots[TempleSpace.SlotID].APP := Item^.Index;
          Servers[Player.ChannelIndex].Devires[TempleSpace.DevirID]
            .Slots[TempleSpace.SlotID].TimeCapped := IncHour(Now, 3);
          Servers[Player.ChannelIndex].Devires[TempleSpace.DevirID]
            .Slots[TempleSpace.SlotID].TimeToEstabilish := IncHour(Now, RELIQ_EST_TIME + 3);
          Move(Player.Base.Character.Name,
            Servers[Player.ChannelIndex].Devires[TempleSpace.DevirID]
            .Slots[TempleSpace.SlotID].NameCapped[0], 16);
          Inc(Servers[Player.ChannelIndex].ReliqEffect[ItemList[Item^.Index].EF[0]
            ], ItemList[Item^.Index].EFV[0]);
           //:= Servers[Player.ChannelIndex].ReliqEffect
            //[ItemList[Item^.Index].EF[0]] + ;
          Servers[Player.ChannelIndex].SaveTemplesDB(@Player);
          Servers[Player.ChannelIndex].UpdateReliquaresForAll;
          Servers[Player.ChannelIndex].SendServerMsgForNation('O tesouro sagrado <' +
            AnsiString(ItemList[Item^.Index].Name) +
            '> foi colocado no templo, efeito será aplicado.', Player.Base.Character.Nation, 16, 16, 16);

          Player.UpdateReliquareOpennedDevir(TempleSpace.DevirID);

          if(Player.PartyIndex <> 0) then
          begin
            if not(Player.Party.InRaid) then
            begin //honra só pra minha party
              for I in Player.Party.Members do
              begin
                if(Servers[Player.ChannelIndex].Players[i].Base.PlayerCharacter.LastPos.InRange(
                  Player.Base.PlayerCharacter.LastPos, 20)) then
                begin
                  Honor := ((ItemList[Item^.Index].Level+1) * INC_HONOR_RELIQ_LEVEL);
                  Inc(Servers[Player.ChannelIndex].Players[i].Base.Character.CurrentScore.
                    Honor, Honor);
                  Servers[Player.ChannelIndex].Players[i].SendClientMessage
                    ('Adquiriu ' + AnsiString(Honor.ToString) + ' pontos de honra.');
                  Servers[Player.ChannelIndex].Players[i].Base.SendRefreshKills();
                  TItemFunctions.PutItem(Servers[Player.ChannelIndex].Players[i], 8544);
                end;
              end;
            end
            else
            begin //honra pra raid inteira
              for I in Player.Party.Members do
              begin
                if(Servers[Player.ChannelIndex].Players[i].Base.PlayerCharacter.LastPos.InRange(
                  Player.Base.PlayerCharacter.LastPos, 20)) then
                begin
                  Honor := ((ItemList[Item^.Index].Level+1) * INC_HONOR_RELIQ_LEVEL);
                  Inc(Servers[Player.ChannelIndex].Players[i].Base.Character.CurrentScore.
                    Honor, Honor);
                  Servers[Player.ChannelIndex].Players[i].SendClientMessage
                    ('Adquiriu ' + AnsiString(Honor.ToString) + ' pontos de honra.');
                  Servers[Player.ChannelIndex].Players[i].Base.SendRefreshKills();
                  TItemFunctions.PutItem(Servers[Player.ChannelIndex].Players[i], 8544);
                end;
              end;
              for j := 1 to 3 do
              begin
               if(Player.Party.PartyAllied[j] = 0) then
                Continue;
                for I in Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[j]].Members do
                begin
                  if(Servers[Player.ChannelIndex].Players[i].Base.PlayerCharacter.LastPos.InRange(
                    Player.Base.PlayerCharacter.LastPos, 20)) then
                  begin
                    Honor := ((ItemList[Item^.Index].Level+1) * INC_HONOR_RELIQ_LEVEL);
                    Inc(Servers[Player.ChannelIndex].Players[i].Base.Character.CurrentScore.
                      Honor, Honor);
                    Servers[Player.ChannelIndex].Players[i].SendClientMessage
                      ('Adquiriu ' + AnsiString(Honor.ToString) + ' pontos de honra.');
                    Servers[Player.ChannelIndex].Players[i].Base.SendRefreshKills();
                    TItemFunctions.PutItem(Servers[Player.ChannelIndex].Players[i], 8544);
                  end;
                end;
              end;
            end;
          end
          else //sem nenhuma party
          begin
            Honor := ((ItemList[Item^.Index].Level+1) * INC_HONOR_RELIQ_LEVEL);
            Inc(Player.Base.Character.CurrentScore.Honor, Honor);
            Player.SendClientMessage
              ('Adquiriu ' + AnsiString(Honor.ToString) + ' pontos de honra.');
            Player.Base.SendRefreshKills();
            TItemFunctions.PutItem(Player, 8544);
          end;
          TItemFunctions.RemoveItem(Player, INV_TYPE, Packet.SrcSlot);
          Player.SendSignal(Player.Base.ClientId, $10F);
          Player.SendEffect(0);
        end;
    end;
  end
  else if(Packet.DevirClientID = 1793) then
  begin //puxar relíquia
    if(Servers[Player.Channelindex].Devires[Player.OpennedDevir].NationID =
      Player.Base.Character.Nation) then
    begin
      Player.SendClientMessage('Você não pode pegar seus própios tesouros.');
      Exit;
    end;
    EmptySlot := TItemFunctions.GetEmptySlot(Player);
    if(EmptySlot = 255) then
    begin
      Player.SendClientMessage('Inventário cheio.');
      Exit;
    end;
    AlreadyReliq := TItemFunctions.GetItemSlotByItemType(Player, 40, INV_TYPE, 0);
    if(AlreadyReliq <> 255) then
    begin
      Player.SendClientMessage('Você não pode carregar mais de uma relíquia por vez.');
      Exit;
    end;
    TimeEst := IncHour(Servers[Player.Channelindex].Devires[Player.OpennedDevir].Slots[Packet.SrcSlot].TimeToEstabilish
      ,-3); //-3 por ser -3 GMT
    if(TimeEst > Now) then
    begin
      Player.SendClientMessage('Relíquia não liberada ainda.');
      Exit;
    end;
    ReliqIndex :=
      Servers[Player.Channelindex].Devires[Player.OpennedDevir].Slots[Packet.SrcSlot].ItemId;
    if(ReliqIndex = 0) then
      Exit;
    TItemFunctions.PutItem(Player, ReliqIndex, 1);
    Servers[Player.Channelindex].Devires[Player.OpennedDevir].Slots[Packet.SrcSlot].ItemFurthed :=
      Servers[Player.Channelindex].Devires[Player.OpennedDevir].Slots[Packet.SrcSlot].ItemID;
    Servers[Player.Channelindex].Devires[Player.OpennedDevir].Slots[Packet.SrcSlot].ItemID := 0;
    Servers[Player.Channelindex].Devires[Player.OpennedDevir].Slots[Packet.SrcSlot].App := 0;
    //Servers[Player.Channelindex].Devires[Player.OpennedDevir].Slots[Packet.Slot].TimeCapped := StrToDateTime('01/01/2001 01:02:03');
    Servers[Player.Channelindex].Devires[Player.OpennedDevir].Slots[Packet.SrcSlot].TimeToEstabilish := IncHour(Now, 3);
    ZeroMemory(@Servers[Player.Channelindex].Devires[Player.OpennedDevir].Slots[Packet.SrcSlot].NameCapped, 16);
    Servers[Player.Channelindex].Devires[Player.OpennedDevir].Slots[Packet.SrcSlot].TimeFurthed := IncHour(Now, 3);
    Servers[Player.Channelindex].Devires[Player.OpennedDevir].Slots[Packet.SrcSlot].Furthed := True;
    Player.SendSignal(Player.Base.ClientId, $10F);
    Servers[Player.Channelindex].SaveTemplesDB(@Player);
    Servers[Player.Channelindex].CloseDevir(Player.OpennedDevir, Player.OpennedTemple,
      Player.Base.ClientID);
    Servers[Player.ChannelIndex].Devires[Player.OpennedDevir].PlayerIndexGettingReliq := 0;

    DecInt(Servers[Player.ChannelIndex].ReliqEffect[ItemList[ReliqIndex].EF[0]],
      ItemList[ReliqIndex].EFV[0]);
     //:=
      //Servers[Player.ChannelIndex].ReliqEffect[ItemList[ReliqIndex].EF[0]] -
        //ItemList[ReliqIndex].EFV[0];
    Player.UpdateReliquareOpennedDevir(Player.OpennedDevir);
    Servers[Player.Channelindex].Devires[Player.OpennedDevir].CollectedReliquare := True;
    Player.OpennedDevir := 255;
    Player.OpennedTemple := 255;
    Servers[Player.ChannelIndex].UpdateReliquaresForAll;
    Player.SendPacket(Packet, Packet.Header.Size);


    Servers[Player.Channelindex].SendServerMsgForNation('O tesouro sagrado [' +
      AnsiString(ItemList[ReliqIndex].Name) +
      '] foi roubado do templo. Efeito sagrado cancelado.',
      Servers[Player.Channelindex].NationId, 16, 32, 16);

  end;


end;

{$ENDREGION}

{$REGION 'Collect Items'}
class function TPacketHandlers.CollectMapItem(var Player: TPlayer;
  Buffer: Array of BYTE): Boolean;
var
  Packet: TCollectItem absolute Buffer;
  xPacket: TSendRemoveMobPacket;
  i, AlreadyReliq: Integer;
  xPos: TPosition;
begin
  Result := False;
  if(Packet.Index = 0) then
  begin
    Player.CollectingReliquare := False;
    Player.CollectingID := 0;
    Exit;
  end;
  if((Packet.Index < 10148) or (Packet.Index > 10239)) then
  begin
    Player.CollectingReliquare := False;
    Player.CollectingID := 0;
    Exit;
  end;
  if(Servers[Player.ChannelIndex].OBJ[Packet.Index].Index = 0) then
  begin
    Player.CollectingReliquare := False;
    Player.CollectingID := 0;
    Exit;
  end;
  AlreadyReliq := TItemFunctions.GetItemSlotByItemType(Player, 40, INV_TYPE, 0);
  if(AlreadyReliq <> 255) then
  begin
    Player.SendClientMessage('Você não pode carregar mais de uma relíquia por vez.');
    Exit;
  end;
  if(Player.CollectingReliquare) then
  begin
    if( Servers[Player.ChannelIndex].OBJ[Packet.Index].Index = 0) then
      Exit;

    if(Player.CollectingID <> Packet.Index) then
    begin
      Player.CollectingReliquare := False;
      Player.CollectingID := 0;
      Exit;
    end;

    if(SecondsBetween(Now, Player.CollectInitTime) <= 9) then
    begin
      Player.CollectingReliquare := False;
      Player.CollectingID := 0;
      Exit;
    end;

    TItemFunctions.PutItem(Player, Servers[Player.ChannelIndex].OBJ[Packet.Index].ContentItemID);
    ZeroMemory(@xPacket, sizeof(xPacket));
    xPacket.Header.Size := sizeof(xPacket);
    xPacket.Header.Index := $7535;
    xPacket.Header.Code := $101;
    xPacket.Index := Packet.Index;
    if(Player.Base.VisibleMobs.Contains(Packet.Index)) then
     Player.Base.VisibleMobs.Remove(Packet.Index);

    xPos := Servers[Player.ChannelIndex].OBJ[Packet.Index].Position;

    ZeroMemory(@Servers[Player.ChannelIndex].OBJ[Packet.Index], sizeof(
      Servers[Player.ChannelIndex].OBJ[Packet.Index]));

    for I := Low(Servers[Player.ChannelIndex].Players) to
      High(Servers[Player.ChannelIndex].Players) do
    begin
      if(Servers[Player.ChannelIndex].Players[i].Status < Playing) then
        Continue;

      if(Servers[Player.ChannelIndex].Players[i].Base.PlayerCharacter.
        LastPos.Distance(xPos)
        <= DISTANCE_TO_WATCH) then
      begin
        Servers[Player.ChannelIndex].Players[i].SendPacket(xPacket, xPacket.Header.Size);

        if(Servers[Player.ChannelIndex].Players[i].Base.VisibleMobs.Contains(Packet.Index)) then
          Servers[Player.ChannelIndex].Players[i].Base.VisibleMobs.Remove(Packet.Index);

        Servers[Player.ChannelIndex].Players[i].Base.UpdateVisibleList();
      end;
    end;

    {for I in Player.Base.VisiblePlayers do
    begin
      if(Servers[Player.ChannelIndex].Players[i].Status < Playing) then
        Continue;

      Servers[Player.ChannelIndex].Players[i].SendPacket(xPacket, xPacket.Header.Size);


      if(Servers[Player.ChannelIndex].Players[i].Base.VisibleMobs.Contains(Packet.Index)) then
        Servers[Player.ChannelIndex].Players[i].Base.VisibleMobs.Remove(Packet.Index);
    end;}
  end;
  Result := True;
end;
class function TPacketHandlers.CancelCollectMapItem(var Player: TPlayer;
  Buffer: Array of BYTE): Boolean;
var
  Packet: TCancelCollectItem absolute Buffer;
begin
  Player.CollectingReliquare := False;
  Player.CollectingID := 0;

  if (Packet.Index >= 3370) and (Packet.Index <= 3372) then
  begin
    if (Servers[Player.ChannelIndex].CastleSiegeHandler.OrbHolder
      [Packet.Index-3370].Base.ClientID = Player.Base.ClientID) then
    begin
      Servers[Player.ChannelIndex].CastleSiegeHandler.OrbHolder
      [Packet.Index-3370] := nil;
    end;

  end;

  Result := True;
end;
{$ENDREGION}

end.
