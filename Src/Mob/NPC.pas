unit NPC;
interface
uses BaseMob, PlayerData, MiscData;
{$OLDTYPELAYOUT ON}
type
  PNpc = ^TNpc;
  TNpc = record
  public
    Base: TBaseMob;
    Character: TCharacter;
    PlayerChar: TPlayerCharacter;
    NPCFile: TNPCFile;
    GenerID: Integer;
    IsInstantiated: Boolean;
    IsAttacked: Boolean;
    AttackerID: WORD;
    FirstPlayerAttacker: Integer;
    LastMyAttack: TDateTime;
    LastSkillAttack: TDateTime;
    DeadTime: TDateTime;
    LastUpdatedHP: TDateTime;
    FirstPosition: TPosition;
    DevirName: String;
    { TNpc }
    procedure Create(Id: Integer; Name: string; Channel: BYTE);
    function LoadFile(NPCName: string): Boolean;
    function InstanciateNPC: Boolean;
    procedure MobMove(Position: TPosition; Speed: BYTE = 25;
      MoveType: BYTE = 0);
    procedure AttackPlayer(OtherPlayer: Pointer; InitialDamage: Integer;
      SkillID: WORD = 0);
    procedure UpdateHPForVisibles();
    procedure KillStone(id: Integer; KillerId: Integer);
    procedure KillGuard(id: Integer; KillerId: Integer);
    function GetDevirIdByStoneOrGuardId(id: Integer): Integer;
  end;
{$OLDTYPELAYOUT OFF}
implementation
uses GlobalDefs, Windows, SysUtils, Functions, Packets, Player, Math,
  DateUtils, ServerSocket, ItemFunctions;
{$REGION 'TNpc'}
procedure TNpc.Create(Id: Integer; Name: string; Channel: BYTE);
begin
  if (Self.LoadFile(Name)) then
  begin
    Move(NPCFile.Base.Base, Self.Character, sizeof(TCharacter));
    Base.Create(@Self.Character, Id, Channel);
  end;
end;
function TNpc.LoadFile(NPCName: string): Boolean;
var
  f: file of TNPCFile;
  local: string;
begin
  Result := False;
  ZeroMemory(@NPCFile, sizeof(TAccountFile));
  local := 'C:\Database\NPCs\' + Trim(NPCName) + '.npc';
  if not(FileExists(local)) then
    exit;
  try
    AssignFile(f, local);
    Reset(f);
    Read(f, NPCFile);
    CloseFile(f);
    Result := true;
  except
    CloseFile(f);
  end;
end;
function TNpc.InstanciateNPC;
// var
// i: BYTE;
begin
  Result := False;
  try
    Move(NPCFile.Base, Self.PlayerChar, sizeof(TCharacterDB));
    Move(Self.PlayerChar, Self.Base.PlayerCharacter, sizeof(TPlayerCharacter));
    { for i := 0 to Length(Servers) - 1 do
      begin
      Servers[i].MobGrid[Round(Base.PlayerCharacter.LastPos.Y)][Round(Base.PlayerCharacter.LastPos.X)] := Base.Clientid;
      end; }
  except
    exit;
  end;
  Result := true;
end;
procedure TNpc.MobMove(Position: TPosition; Speed: BYTE = 25;
  MoveType: BYTE = 0);
var
  Packet: TMobMovimentPacket;
  i: Integer;
begin
  ZeroMemory(@Packet, sizeof(TMobMovimentPacket));
  Packet.Header.size := sizeof(TMobMovimentPacket);
  Packet.Header.Index := Self.PlayerChar.Base.ClientID;
  Packet.Header.Code := $301;
  Packet.Destination := Position;
  Packet.MoveType := MoveType;
  Packet.Speed := Speed;
  for i in Self.Base.VisibleMobs do
  begin
    if (i <= MAX_CONNECTIONS) then
    begin
      if (Servers[Self.Base.ChannelId].Players[i].status < TPlayerStatus.Playing)
      then
        continue;
      Servers[Self.Base.ChannelId].Players[i].SendPacket(Packet,
        Packet.Header.size);
    end;
  end;
end;
procedure TNpc.AttackPlayer(OtherPlayer: Pointer; InitialDamage: Integer;
  SkillID: WORD = 0);
var
  MPLayer: PPlayer;
  Packet: TRecvDamagePacket;
  DANO, cnt: Integer;
  PlDef, AttackResultType: Integer;
  Item: PItem;
  RlkSlot: Integer;
begin
  MPLayer := OtherPlayer;
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.PlayerChar.Base.ClientID;
  Packet.Header.Code := $102;
  Packet.SkillID := SkillID;
  Packet.AttackerPos := Self.PlayerChar.LastPos;
  Packet.AttackerID := Packet.Header.Index;
  Packet.Animation := 06;
  Packet.AttackerHP := Self.PlayerChar.Base.CurrentScore.CurHP;
  Packet.TargetID := Self.AttackerID;
  Packet.MobAnimation := 26;
  DANO := InitialDamage;
  PlDef := ((MPLayer.Base.Character.CurrentScore.DefMag + MPLayer.Base.Character.CurrentScore.DefFis) div 2);
  DANO := DANO - (PlDef shr 3);
  inc(DANO, ((RandomRange(10, 49) div 2) + 5));
  Randomize;
  AttackResultType := RandomRange(1, 100);
  case AttackResultType of
    1 .. 20:
      begin
        Packet.DnType := TDamageType.Miss;
      end;
    21 .. 50:
      begin
        Packet.DnType := TDamageType.Critical;
      end;
    51 .. 100:
      begin
        Packet.DnType := TDamageType.Normal;
      end;
  else
    Packet.DnType := TDamageType.Normal;
  end;
  if (Packet.DnType = TDamageType.Miss) then
  begin
    DANO := 0;
  end
  else
  begin
    if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(19)) then
    begin
      DANO := 0;
      Packet.DnType := TDamageType.Block;
      Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.RemoveBuffByIndex(19);
    end;
    if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(91)) then
    begin
      DANO := 0;
      Packet.DnType := TDamageType.Miss2;
      Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.RemoveBuffByIndex(91);
    end;
  end;
  Packet.DANO := DANO;
  if (Packet.DANO >= Servers[Self.Base.ChannelId].Players[Self.AttackerID]
    .Base.Character.CurrentScore.CurHP) then
  begin
    Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.CurrentScore.CurHP := 0;
    Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.IsDead := true;
    Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.SendEffect($0);
    cnt := 0;
    while (TItemFunctions.GetItemSlotByItemType(Servers[Self.Base.ChannelId].Players[Self.AttackerID],
      40, INV_TYPE, 0) <> 255) do
    begin
      RlkSlot := TItemFunctions.GetItemSlotByItemType(Servers[Self.Base.ChannelId].Players[Self.AttackerID],
        40, INV_TYPE, 0);
      if(RlkSlot <> 255) then
      begin
        Item := @Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.Character.Inventory[RlkSlot];
        Servers[Self.Base.ChannelId].CreateMapObject(@Servers[Self.Base.ChannelId].Players[Self.AttackerID],
          320, Item.Index);
        Servers[Self.Base.ChannelId].SendServerMsg('O jogador ' +
          AnsiString(Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.Character.Name) + ' dropou a relíquia <' +
          AnsiString(ItemList[Item.Index].Name) + '>.');
        ZeroMemory(Item, sizeof(TItem));
        Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, False);
        cnt := cnt + 1;
      end;
    end;
    if(cnt > 0) then
    begin
      Servers[Self.Base.ChannelId].Players[Self.AttackerID].SendEffect(0);
    end;
    Packet.MobAnimation := 30;
    Self.IsAttacked := False;
    Self.PlayerChar.LastPos := Self.PlayerChar.CurrentPos;
    Self.MobMove(Self.PlayerChar.LastPos, 45);
  end
  else
  begin
    Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.CurrentScore.CurHP :=
      (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.CurrentScore.CurHP - Packet.DANO);
  end;
  Servers[Self.Base.ChannelId].Players[Self.AttackerID]
    .Base.LastReceivedAttack := Now;
  Packet.MobCurrHP := Servers[Self.Base.ChannelId].Players[Self.AttackerID]
    .Base.Character.CurrentScore.CurHP;
  Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.SendToVisible
    (Packet, Packet.Header.size, true);
end;
procedure TNpc.UpdateHPForVisibles();
var
  Packet: TSendCurrentHPMPPacket;
begin
  if ((Now >= IncSecond(Self.LastUpdatedHP, 10)) and Assigned(Self.Base.VisibleMobs)) then
  begin
    if (Self.Base.VisibleMobs.Count > 0) then
    begin
      ZeroMemory(@Packet, sizeof(TSendCurrentHPMPPacket));
      Packet.Header.size := sizeof(TSendCurrentHPMPPacket);
      Packet.Header.Code := $103; // AIKA
      Packet.Header.Index := Self.PlayerChar.Base.ClientID;
      Packet.CurHP := Self.PlayerChar.Base.CurrentScore.CurHP;
      Packet.MaxHp := Self.PlayerChar.Base.CurrentScore.MaxHp;
      Packet.CurMP := Self.PlayerChar.Base.CurrentScore.CurMP;
      Packet.MaxMP := Self.PlayerChar.Base.CurrentScore.MaxMP;
      Self.Base.SendToVisible(Packet, Packet.Header.size);
    end;
  end;
end;
procedure TNPC.KillStone(id: Integer; KillerId: Integer);
var
  DId, oldDid, i, deadCnt: Integer;
  TempId: Integer;
  AllDied: Boolean;
begin
  Did := Self.GetDevirIdByStoneOrGuardId(id);
  if(Did = 255) then
    Exit;
  case Did of
    0:
    TempId := 3335;
    1:
    TempId := 3336;
    2:
    TempId := 3337;
    3:
    TempId := 3338;
    4:
    TempId := 3339;
  end;
  oldDid := Did;
  Inc(Servers[Self.Base.ChannelId].Devires[Did].StonesDied, 1);
  deadCnt := 0;
  for I := 3340 to 3354 do
  begin
    Did := Self.GetDevirIdByStoneOrGuardId(i);
    if(Did = 255) then
      Continue;
    if(Did <> oldDid) then
      Continue;
    if(Servers[Self.Base.ChannelId].DevirStones[i].Base.IsDead) then
      Inc(deadCnt, 1);
  end;
  if(deadCnt >= 3) then
  begin
    if(Servers[Self.Base.ChannelId].Devires[oldDid].IsOpen = True) then
      Exit;
     Servers[Self.Base.ChannelId].SendServerMsg('O templo de ' +
    AnsiString(
    Servers[Self.Base.ChannelId].DevirNpc[Tempid].DevirName) +
    ' foi aberto, e poderá ser roubado.', 16, 16, 16);
    Servers[Self.Base.ChannelId].Devires[oldDid].IsOpen := True;
    Servers[Self.Base.ChannelId].Devires[oldDid].OpenTime := Now;
    Servers[Self.Base.ChannelId].OpenDevir(oldDid, Tempid, KillerId);
  end;
end;
procedure TNPC.KillGuard(id: Integer; KillerId: Integer);
//var
  //DId: Integer;
  //TempId: Integer;
begin
  {Did := Self.GetDevirIdByStoneOrGuardId(id);
  if(Did = 255) then
    Exit;
  case Did of
    0:
    TempId := 3335;
    1:
    TempId := 3336;
    2:
    TempId := 3337;
    3:
    TempId := 3338;
    4:
    TempId := 3339;
  end;
  Inc(Servers[Self.Base.ChannelId].Devires[Did].GuardsDied, 1);
  if(Servers[Self.Base.ChannelId].Devires[Did].ReliqCount <= 2) then
  begin //tenho que checar pra ver se os totens estão vivos ou não
    if(Servers[Self.Base.ChannelId].Devires[Did].StonesDied >= 3) then
    begin
      if(Servers[Self.Base.ChannelId].Devires[Did].GuardsDied >= 3) then
      begin
        if(Servers[Self.Base.ChannelId].Devires[Did].IsOpen = True) then
          Exit;
        Servers[Self.Base.ChannelId].SendServerMsg('O templo de ' +
        AnsiString(
        Servers[Self.Base.ChannelId].DevirNpc[Tempid].PlayerChar.Base.PranName[0]) +
        ' foi aberto, e poderá ser roubado.', 16, 16, 16);
        Servers[Self.Base.ChannelId].Devires[Did].IsOpen := True;
        Servers[Self.Base.ChannelId].Devires[Did].OpenTime := Now;
        Servers[Self.Base.ChannelId].OpenDevir(Did, Tempid, KillerId);
      end;
    end;
  end
  else //tenho que checar pra ver se apenas as pedras estão vivas ou não
  begin
    if(Servers[Self.Base.ChannelId].Devires[Did].StonesDied >= 3) then
    begin
      if(Servers[Self.Base.ChannelId].Devires[Did].IsOpen = True) then
        Exit;
       Servers[Self.Base.ChannelId].SendServerMsg('O templo de ' +
        AnsiString(
        Servers[Self.Base.ChannelId].DevirNpc[Tempid].PlayerChar.Base.PranName[0]) +
        ' foi aberto, e poderá ser roubado.', 16, 16, 16);
       Servers[Self.Base.ChannelId].Devires[Did].IsOpen := True;
       Servers[Self.Base.ChannelId].Devires[Did].OpenTime := Now;
       Servers[Self.Base.ChannelId].OpenDevir(Did, Tempid, KillerId);
    end;
  end;}
end;
function TNPC.GetDevirIdByStoneOrGuardId(id: Integer): Integer;
var
  i: Integer;
begin
  Result := 255;
  case id of
    3340,3345,3350,3355,3360,3365: //amk devir
      Result := 0;
    3341,3346,3351,3356,3361,3366: //sig devir
      Result := 1;
    3342,3347,3352,3357,3362,3367: //cah devir
      Result := 2;
    3343,3348,3353,3358,3363,3368: //mir devir
      Result := 3;
    3344,3349,3354,3359,3364,3369: //zel devir
      Result := 4;
  end;
end;
{$ENDREGION}
end.
