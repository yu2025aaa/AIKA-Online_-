unit Dungeon;

interface

uses
  Windows, SysUtils, MOB, MiscData, PartyData, NPC, BaseMob, Classes;
{$OLDTYPELAYOUT ON}

{$REGION 'Dungeon Thread'}

type
  TDungeonMainThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    InstanceID: BYTE;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; InstanceID: BYTE);
  end;
{$ENDREGION}
{$REGION 'Dungeons Data'}

type
  TDungeonMobDrop = packed record
    SemCoroa: Array [0 .. 41] of WORD; // 12 {1=ursula normal}{2=coroacinza}
    CoroaPrata: Array [0 .. 41] of WORD;
    CoroaDourada: Array [0 .. 41] of WORD;
  end;

type
  TDungeonMobDropData = packed record
    Drops: Array [0 .. 41] of WORD;
  end;

type
  TDungeon = record
    Index: DWORD;
    Dificult: BYTE;
    LevelMin: BYTE;
    EntranceNPCID: WORD;
    EntrancePosition: TPosition; // pra calcular se todos os players estão lá
    SpawnInDungeonPosition: TPosition; // posição que vai spawnar la dentro
    MOBS: TMobDungeonStruct; // até 45 tipos de mobs diferentes
    MobsDrop: TDungeonMobDrop;
    NPCS: Array [2600 .. 2609] of TNpc; // até 10 npcs dentro da dg
  end;

type
  PMobsStructDungeonInstance = ^TMobsStructDungeonInstance;

  TMobsStructDungeonInstance = packed record
    IntName: WORD;
    Equip: Array [0 .. 12] of WORD; // mob equips [face, weapon]
    Base: TBaseMob;
    MaxHP, CurrentHP: DWORD;
    Position: TPosition;
    MobLevel: BYTE;
    MobExp: DWORD;
    MobType: WORD;
    MobElevation, Cabeca, Perna: BYTE; // mob "altura"
    FisAtk, MagAtk, FisDef, MagDef: DWORD; // mob attributes

    DeadTime: TDateTime;
    LastMoviment: TDateTime;
    MovedTo: TypeMobLocation;
    MovimentsTime: BYTE;

    XPositionDif: Integer;
    YPositionDif: Integer;
    XPositionsToMove: Integer;
    YPositionsToMove: Integer;

    IsAttacked: Boolean;
    AttackerID: WORD;
    FirstPlayerAttacker: Integer;

    LastMyAttack: TDateTime;
    OrigPos: TPosition;

    NeighborIndex: Integer;

  public
    procedure AttackPlayer();
    procedure MobMove(Position: TPosition; DungeonInstance: BYTE;
      Speed: BYTE = 25; MoveType: BYTE = 0);
  end;

type
  PDungeonInstance = ^TDungeonInstance;

  TDungeonInstance = record
    Index: WORD;
    Party: PParty; // pointer da party que está entrando
    CreateTime: TDateTime;
    DungeonID: BYTE;
    Dificult: BYTE;
    MOBS: Array [1 .. 450] of TMobsStructDungeonInstance;
    MobsDrop: Array [1 .. 450] of TDungeonMobDropData;
    MainThread: TDungeonMainThread;
    InstanceOnline: Boolean;
  end;

{$ENDREGION}

{$OLDTYPELAYOUT OFF}
implementation

uses
  GlobalDefs, Packets, Log, DateUtils, PlayerData;

{$REGION 'Mob Dungeon Functions'}

procedure TMobsStructDungeonInstance.AttackPlayer();
var
  Packet: TRecvDamagePacket;
  dnType: TDamageType;
  SkillIDa: DWORD;
  Dano: Integer;
  AddBuff: Boolean;
begin
  try
    SkillIDa := 0;
    Dano := 0;

    ZeroMemory(@Packet, sizeof(Packet));

    Packet.Header.size := sizeof(Packet);
    Packet.Header.Index := Self.Base.ClientID;
    Packet.Header.Code := $102;

    Packet.SkillID := SkillIDa;

    Packet.AttackerPos := Self.Position;

    Packet.AttackerID := Self.Base.ClientID;
    Packet.Animation := 06;
    Packet.AttackerHP := Self.CurrentHP;

    Packet.TargetID := Self.AttackerID;

    Packet.MobAnimation := 26;

    if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.GetMobAbility(EF_IMMUNITY) > 0) then
    begin
      dnType := TDamageType.Immune;

      Packet.DNType := dnType;

      Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.LastReceivedAttack := Now;

      Packet.MobCurrHP := Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.Character.CurrentScore.CurHP;

      Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.SendToVisible
        (Packet, Packet.Header.size, True);
    end;

    if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(19)) then
    begin
      Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.RemoveBuffByIndex(19);

      dnType := TDamageType.Block;

      Packet.DNType := dnType;

      Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.LastReceivedAttack := Now;

      Packet.MobCurrHP := Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.Character.CurrentScore.CurHP;

      Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.SendToVisible
        (Packet, Packet.Header.size, True);
      Exit;
    end;

    if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(91)) then
    begin
      Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.RemoveBuffByIndex(91);
      dnType := TDamageType.Miss2;

      Packet.DNType := dnType;

      Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.LastReceivedAttack := Now;

      Packet.MobCurrHP := Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.Character.CurrentScore.CurHP;

      Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.SendToVisible
        (Packet, Packet.Header.size, True);
      Exit;
    end;

    Dano := Self.Base.PlayerCharacter.Base.CurrentScore.DNFis;

    case Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.Level of
      0 .. 20:
        begin
          Dano := 10;
        end;
      21 .. 40:
        begin
          Dano := 50;
        end;
      41 .. 60:
        begin
          Dano := 200;
        end;
    end;

    Randomize;
    inc(Dano, ((Random(99) div 2) + 3));

    dnType := TDamageType.Normal;

    Self.Base.AttackParseForMobs(0, 0,
      @Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base, Dano, dnType,
      AddBuff, Packet.MobAnimation);

    Packet.dnType := dnType;
    Packet.DANO := Dano;

    if (Packet.DANO >= Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.CurrentScore.CurHP) then
    begin
      Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.Character.CurrentScore.CurHP := 0;
      Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.IsDead := True;

      if (Servers[Self.Base.ChannelId].Players[Self.AttackerID].Party.Index > 0) then
      begin
        if (Servers[Self.Base.ChannelId].Players[Self.AttackerID].Party.Members.Count > 1) then
        begin
          Servers[Self.Base.ChannelId].Players[Self.AttackerID].Party.RemoveMember(
            Self.AttackerID);

          Servers[Self.Base.ChannelId].Players[Self.AttackerID].DungeonLobbyIndex := 0;
          Servers[Self.Base.ChannelId].Players[Self.AttackerID].DungeonLobbyDificult := 0;
          Servers[Self.Base.ChannelId].Players[Self.AttackerID].DungeonID := 0;
          Servers[Self.Base.ChannelId].Players[Self.AttackerID].DungeonIDDificult := 0;
          Servers[Self.Base.ChannelId].Players[Self.AttackerID].DungeonInstanceID := 0;
          Servers[Self.Base.ChannelId].Players[Self.AttackerID].InDungeon := False;
          Servers[Self.Base.ChannelId].Players[Self.AttackerID].Teleport(TPosition.Create(3399, 564));
        end
        else
        begin
          DungeonInstances[Servers[Self.Base.ChannelId].Players[Self.AttackerID].DungeonInstanceID].InstanceOnline := False;

          Servers[Self.Base.ChannelId].Players[Self.AttackerID].DungeonLobbyIndex := 0;
          Servers[Self.Base.ChannelId].Players[Self.AttackerID].DungeonLobbyDificult := 0;
          Servers[Self.Base.ChannelId].Players[Self.AttackerID].DungeonID := 0;
          Servers[Self.Base.ChannelId].Players[Self.AttackerID].DungeonIDDificult := 0;
          Servers[Self.Base.ChannelId].Players[Self.AttackerID].DungeonInstanceID := 0;
          Servers[Self.Base.ChannelId].Players[Self.AttackerID].InDungeon := False;
          Servers[Self.Base.ChannelId].Players[Self.AttackerID].Teleport(TPosition.Create(3399, 564));
        end;
      end;

      Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.SendEffect($0);
      Packet.MobAnimation := 30;

      Self.IsAttacked := FALSE;
      Self.LastMoviment := Now;
      Self.MovimentsTime := 0;
      Self.MovedTo := Init;
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
      (Packet, Packet.Header.size, True);
  except
    on E: Exception do
      Logger.Write('Error at mob Attack Player [' + E.Message + '] b.e: ' +
        E.BaseException.Message + ' user: ' +
        String(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.Character.Name) + ' t:' + DateTimeToStr(Now), TlogType.Error);
  end;
end;

procedure TMobsStructDungeonInstance.MobMove(Position: TPosition;
  DungeonInstance: BYTE; Speed: BYTE; MoveType: BYTE);
var
  Packet: TMobMovimentPacket;
  i: Integer;
begin
  ZeroMemory(@Packet, sizeof(TMobMovimentPacket));

  Packet.Header.size := sizeof(TMobMovimentPacket);
  Packet.Header.Index := Self.Base.ClientID;
  Packet.Header.Code := $301;

  Packet.Destination := Position;

  Packet.MoveType := MoveType;

  if (Speed = 25) then
    Packet.Speed := 25
  else
    Packet.Speed := Speed;

  Self.Base.PlayerCharacter.LastPos := Position;

  for i in Self.Base.VisibleMobs do
  begin
    if (i <= MAX_CONNECTIONS) then
    begin
      if (Servers[Self.Base.ChannelId].Players[i].Status < TPlayerStatus.Playing)
      then
        continue;

      Servers[Self.Base.ChannelId].Players[i].SendPacket(Packet,
        Packet.Header.size);
    end;
  end;
end;

{$ENDREGION}
{$REGION 'TDungeonMainThread'}

constructor TDungeonMainThread.Create(SleepTime: Integer; ChannelId: BYTE;
  InstanceID: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.InstanceID := InstanceID;

  inherited Create(FALSE);
end;

procedure TDungeonMainThread.Execute;
var
  i, j: WORD;
  Cid1, Cid2: WORD;
  SelfParty: PParty;
  Packet: TSendRemoveMobPacket;
  InstanceIDD, Dificult: BYTE;
  UpdatedBuffs: Integer;
  Rand: Integer;
begin
  SelfParty := DungeonInstances[Self.InstanceID].Party;

  while (DungeonInstances[Self.InstanceID].InstanceOnline) do
  begin
{$REGION 'Atualização do spawn dentro da dungeon'}
    if (SelfParty.Members.Count > 1) then
    begin
      for i in SelfParty.Members.ToArray do
      begin
        Cid1 := i;

        for j in SelfParty.Members.ToArray do
        begin
          Cid2 := j;

          if (Cid1 = Cid2) then
            continue;

          if (Servers[Self.ChannelId].Players[Cid1]
            .Base.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId]
            .Players[Cid2].Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH))
          then
          begin
            if (Servers[Self.ChannelId].Players[Cid1]
              .Base.VisiblePlayers.Contains(Servers[Self.ChannelId].Players
              [Cid2].Base.ClientID)) then
              continue;

            Servers[Self.ChannelId].Players[Cid1].Base.AddVisible
              (Servers[Self.ChannelId].Players[Cid2].Base);

            if (Servers[Self.ChannelId].Players[Cid2]
              .Account.Header.Pran1.IsSpawned) then
            begin
              Servers[Self.ChannelId].Players[Cid2].SendPranSpawn(0, Cid1, 0);
            end;

            if (Servers[           Self.ChannelId].Players[Cid2]
             .Account.Header.Pran2.IsSpawned) then
           begin
             Servers[Self.ChannelId].Players[Cid2].SendPranSpawn(1, Cid1, 0);
           end;

           if (Servers[Self.ChannelId].Players[Cid1]
             .Account.Header.Pran1.IsSpawned) then
           begin
             Servers[Self.ChannelId].Players[Cid1].SendPranSpawn(0, Cid2, 0);
           end;

           if (Servers[Self.ChannelId].Players[Cid1]
             .Account.Header.Pran2.IsSpawned) then
           begin
             Servers[Self.ChannelId].Players[Cid1].SendPranSpawn(1, Cid2, 0);
           end;
         end
         else
         begin
           if not(Servers[Self.ChannelId].Players[Cid1]
             .Base.VisiblePlayers.Contains(Servers[Self.ChannelId].Players
             [Cid2].Base.ClientID)) then
             continue;

           if (Servers[Self.ChannelId].Players[Cid1]
             .Account.Header.Pran1.IsSpawned) then
           begin
             Servers[Self.ChannelId].Players[Cid1].SendPranUnspawn(0, Cid2);
           end;

           if (Servers[Self.ChannelId].Players[Cid1]
             .Account.Header.Pran2.IsSpawned) then
           begin
             Servers[Self.ChannelId].Players[Cid1].SendPranUnspawn(1, Cid2);
           end;

           if (Servers[Self.ChannelId].Players[Cid2]
             .Account.Header.Pran1.IsSpawned) then
           begin
             Servers[Self.ChannelId].Players[Cid2].SendPranUnspawn(0, Cid1);
           end;

           if (Servers[Self.ChannelId].Players[Cid2]
             .Account.Header.Pran2.IsSpawned) then
           begin
             Servers[Self.ChannelId].Players[Cid2].SendPranUnspawn(1, Cid1);
           end;

           Servers[Self.ChannelId].Players[Cid1].Base.RemoveVisible
             (Servers[Self.ChannelId].Players[Cid2].Base);

           if (Servers[Self.ChannelId].Players[Cid2].Base.IsActive = FALSE)
           then
           begin
             ZeroMemory(@Packet, sizeof(Packet));

             Packet.Header.size := sizeof(Packet);
             Packet.Header.Index := $7535;
             Packet.Header.Code := $101;

             Packet.Index := Cid2;

             Servers[Self.ChannelId].Players[Cid1].Base.SendPacket(Packet,
               Packet.Header.size);
           end;
         end;
       end;

       Dificult := Servers[Self.ChannelId].Players[Cid1].DungeonIDDificult;
       InstanceIDD := Servers[Self.ChannelId].Players[Cid1].DungeonInstanceID;

       for j := Low(DungeonInstances[InstanceIDD].MOBS)
         to High(DungeonInstances[InstanceIDD].MOBS) do
       begin
         if (DungeonInstances[InstanceIDD].MOBS[j].IntName = 0) or
           (DungeonInstances[InstanceIDD].MOBS[j].Base.IsDead) then
           continue;

         if (Servers[Self.ChannelId].Players[Cid1]
           .Base.PlayerCharacter.LastPos.InRange(DungeonInstances[InstanceIDD]
           .MOBS[j].Position, DISTANCE_TO_WATCH)) then
         begin
           if (Servers[Self.ChannelId].Players[Cid1].Base.VisibleMobs.Contains
             (DungeonInstances[InstanceIDD].MOBS[j].Base.ClientID)) then
             continue;

           Servers[Self.ChannelId].Players[Cid1].Base.VisibleMobs.Add
             (DungeonInstances[InstanceIDD].MOBS[j].Base.ClientID);
           DungeonInstances[InstanceIDD].MOBS[j].Base.VisibleMobs.Add(Cid1);

           if (Servers[Self.ChannelId].Players[Cid1].Base.AddTargetToList
             (@DungeonInstances[InstanceIDD].MOBS[j].Base)) then
             Servers[Self.ChannelId].Players[Cid1].SendSpawnMobDungeon
               (@DungeonInstances[InstanceIDD].MOBS[j]);
         end
         else
         begin
           if not(Servers[Self.ChannelId].Players[Cid1]
             .Base.VisibleMobs.Contains(DungeonInstances[InstanceIDD].MOBS[j]
             .Base.ClientID)) then
             continue;

           Servers[Self.ChannelId].Players[Cid1].Base.VisibleMobs.Remove
             (DungeonInstances[InstanceIDD].MOBS[j].Base.ClientID);
           DungeonInstances[InstanceIDD].MOBS[j].Base.VisibleMobs.Remove(Cid1);

           if (Servers[Self.ChannelId].Players[Cid1].Base.RemoveTargetFromList
             (@DungeonInstances[InstanceIDD].MOBS[j].Base)) then
             Servers[Self.ChannelId].Players[Cid1].SendRemoveMobDungeon
               (@DungeonInstances[InstanceIDD].MOBS[j]);
         end;
       end;
     end;
   end
   else
   begin
     Cid1 := DungeonInstances[InstanceID].Party.Members.First;

     Dificult := Servers[Self.ChannelId].Players[Cid1].DungeonIDDificult;
     InstanceIDD := Servers[Self.ChannelId].Players[Cid1].DungeonInstanceID;

     for j := Low(DungeonInstances[InstanceIDD].MOBS)
       to High(DungeonInstances[InstanceIDD].MOBS) do
     begin
       if (DungeonInstances[InstanceIDD].MOBS[j].IntName = 0) or
         (DungeonInstances[InstanceIDD].MOBS[j].Base.IsDead) then
         continue;

       if (Servers[Self.ChannelId].Players[Cid1].Base.PlayerCharacter.LastPos.
         InRange(DungeonInstances[InstanceIDD].MOBS[j].Position,
         DISTANCE_TO_WATCH)) then
       begin
         if (Servers[Self.ChannelId].Players[Cid1].Base.VisibleMobs.Contains
           (DungeonInstances[InstanceIDD].MOBS[j].Base.ClientID)) then
           continue;

         Servers[Self.ChannelId].Players[Cid1].Base.VisibleMobs.Add
           (DungeonInstances[InstanceIDD].MOBS[j].Base.ClientID);
         DungeonInstances[InstanceIDD].MOBS[j].Base.VisibleMobs.Add(Cid1);

         if (Servers[Self.ChannelId].Players[Cid1].Base.AddTargetToList
             (@DungeonInstances[InstanceIDD].MOBS[j].Base)) then
             Servers[Self.ChannelId].Players[Cid1].SendSpawnMobDungeon
               (@DungeonInstances[InstanceIDD].MOBS[j]);
       end
       else
       begin
         if not(Servers[Self.ChannelId].Players[Cid1]
           .Base.VisibleMobs.Contains(DungeonInstances[InstanceIDD].MOBS[j]
           .Base.ClientID)) then
           continue;

         Servers[Self.ChannelId].Players[Cid1].Base.VisibleMobs.Remove
           (DungeonInstances[InstanceIDD].MOBS[j].Base.ClientID);
         DungeonInstances[InstanceIDD].MOBS[j].Base.VisibleMobs.Remove(Cid1);

         if (Servers[Self.ChannelId].Players[Cid1].Base.RemoveTargetFromList
             (@DungeonInstances[InstanceIDD].MOBS[j].Base)) then
             Servers[Self.ChannelId].Players[Cid1].SendRemoveMobDungeon
               (@DungeonInstances[InstanceIDD].MOBS[j]);
       end;
     end;
   end;
{$ENDREGION}
{$REGION 'Mob Handler dungeon'}
   for i := Low(DungeonInstances[Self.InstanceID].MOBS)
     to High(DungeonInstances[Self.InstanceID].MOBS) do
   begin
     if (DungeonInstances[Self.InstanceID].MOBS[i].Base.ClientID = 0) then
       continue;

     if (DungeonInstances[Self.InstanceID].MOBS[i].Base.IsDead = FALSE) then
     // attack and IA verifications
     begin
{$REGION 'Buffs'}
       UpdatedBuffs := DungeonInstances[Self.InstanceID].MOBS[i]
         .Base.RefreshBuffs;

       if (UpdatedBuffs > 0) then
       begin
         DungeonInstances[Self.InstanceID].MOBS[i].Base.SendRefreshBuffs;
       end;

{$ENDREGION}
{$REGION 'Attack'}
       if (DungeonInstances[Self.InstanceID].MOBS[i].IsAttacked) then
       // se o mob foi atacado, entao...
       begin
         if (DungeonInstances[Self.InstanceID].MOBS[i].Position.Distance
           (Servers[Self.ChannelId].Players[DungeonInstances[Self.InstanceID]
           .MOBS[i].AttackerID].Base.PlayerCharacter.LastPos) <= 5) then
         // atacar se tiver no range
         begin
           if (SecondsBetween(Now, DungeonInstances[Self.InstanceID].MOBS[i]
             .LastMyAttack) >= 2) then
           // se tiver 2 segundos entre
           // um ataque e outro, ele ataca...
           begin
             if not(Servers[Self.ChannelId].Players
               [DungeonInstances[Self.InstanceID].MOBS[i].AttackerID]
               .Base.IsDead) then
             begin
               if (DungeonInstances[Self.InstanceID]
                 .MOBS[i].Base.GetDebuffCount = 0) then
                begin
                  DungeonInstances[Self.InstanceID].MOBS[i].LastMyAttack := Now;
                  DungeonInstances[Self.InstanceID].MOBS[i].AttackPlayer;
                end;
             end;
           end;
         end
         else
         begin
           Randomize;

           Rand := Random(7);

           DungeonInstances[Self.InstanceID].MOBS[i].Position :=
             Servers[Self.ChannelId].Players
             [DungeonInstances[Self.InstanceID].MOBS[i].AttackerID]
             .Base.Neighbors[Rand].pos;

           DungeonInstances[Self.InstanceID].MOBS[i]
             .MobMove(DungeonInstances[Self.InstanceID].MOBS[i].Position,
             Self.InstanceID, 35);
         end;

         if not(DungeonInstances[InstanceIDD]
             .MOBS[i].Position.InRange(DungeonInstances[InstanceIDD]
             .MOBS[i].OrigPos, 15)) then
          begin
            DungeonInstances[InstanceIDD].MOBS[j].Position :=
            DungeonInstances[InstanceIDD].MOBS[j].OrigPos;

            DungeonInstances[Self.InstanceID].MOBS[j]
             .MobMove(DungeonInstances[Self.InstanceID].MOBS[j].Position,
            Self.InstanceID, 35);

           DungeonInstances[InstanceIDD].MOBS[j].AttackerID := 0;
           DungeonInstances[InstanceIDD].MOBS[i].IsAttacked := False;
          end;
       end
       else
       begin
         for j in DungeonInstances[InstanceIDD].Party.Members.ToArray do
         begin
           if (Servers[Self.ChannelId].Players[j]
             .Base.PlayerCharacter.LastPos.InRange(DungeonInstances[InstanceIDD]
               .MOBS[i].Position, 15)) then
            begin
              DungeonInstances[InstanceIDD].MOBS[i].OrigPos :=
               DungeonInstances[InstanceIDD].MOBS[i].Position;
              DungeonInstances[InstanceIDD].MOBS[i].IsAttacked := True;
              DungeonInstances[InstanceIDD].MOBS[i].AttackerID :=
                Servers[Self.ChannelId].Players[j].Base.ClientID;
              DungeonInstances[InstanceIDD].MOBS[i].LastMyAttack := Now;
              break;
            end;
         end;
       end;
{$ENDREGION}
     end;
   end;
{$ENDREGION}
   Sleep(FDelay);
 end;
end;

{$ENDREGION}

end.

