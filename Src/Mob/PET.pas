unit PET;
interface
uses
  Windows, SysUtils, Classes, MiscData, BaseMob, System.SyncObjs;
{$OLDTYPELAYOUT ON}
{$REGION 'Pet Threads'}
type
  TPetHandler = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSect: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;
type
  TPetSpawner = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSect: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;
{$ENDREGION}
{$REGION 'Pet Data'}
type
  TPet = record
    Base: TBaseMob;
    IntName: WORD;
    PetType: TPetType;
    Duration: WORD;
    TimeActive: WORD;
    IsAttacked: Boolean;
    AttackerID: WORD;
    MasterClientID: WORD;
  public
    procedure AttackTarget();
    procedure AttackMob();
  end;
{$ENDREGION}
{$OLDTYPELAYOUT OFF}
implementation
uses
  GlobalDefs, PlayerData, MOB, Packets, Log, Util, Math;
{$REGION 'Pet Threads'}
{ TPetHandler }
constructor TPetHandler.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  fCritSect := TCriticalSection.Create;
  inherited Create(FALSE);
end;
procedure TPetHandler.Execute;
var
  i, j: WORD;
  mobid, mobpid: Integer;
  Packet: TMovementPacket;
begin
  while (Servers[Self.ChannelId].IsActive) do
  begin
    fCritSect.Acquire;
    for i := Low(Servers[Self.ChannelId].PETS)
      to High(Servers[Self.ChannelId].PETS) do
    begin
      try
        if not(Servers[Self.ChannelId].PETS[i].Base.IsActive) then
          Continue;

        if(Servers[Self.ChannelId].Players[
            Servers[Self.ChannelId].PETS[i].MasterClientID].SocketClosed) then
          Continue;

        if(Servers[Self.ChannelId].Players[
            Servers[Self.ChannelId].PETS[i].MasterClientID].Base.ClientID = 0) then
          Continue;

        case Servers[Self.ChannelId].PETS[i].PetType of
          X14:
            begin
              Inc(Servers[Self.ChannelId].PETS[i].TimeActive);

              if (Servers[Self.ChannelId].PETS[i].TimeActive >=
                Servers[Self.ChannelId].PETS[i].Duration+1) then
              begin
                Servers[Self.ChannelId].PETS[i].TimeActive := 0;
                Servers[Self.ChannelId].Players[
                  Servers[Self.ChannelId].PETS[i].MasterClientID].Base.PetClientID := 0;
                Servers[Self.ChannelId].Players[
                  Servers[Self.ChannelId].PETS[i].MasterClientID].Base.DestroyPet(i);
                {for j in Servers[Self.ChannelId].PETS[i].Base.VisibleMobs do
                begin
                  if not(j >= 3048) then
                  begin
                    Servers[Self.ChannelId].Players[j].UnSpawnPet
                      (Servers[Self.ChannelId].PETS[i].Base.ClientId);
                    Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Remove
                      (Servers[Self.ChannelId].PETS[i].Base.ClientId);
                  end;
                end;}
                //Servers[Self.ChannelId].PETS[i].Base.Destroy;
               //ZeroMemory(@Servers[Self.ChannelId].PETS[i], sizeof(TPet));
                Continue;
              end;
              if(Servers[Self.ChannelId].PETS[i].Base.IsDead) then
                Continue;
              if (Servers[Self.ChannelId].PETS[i].IsAttacked) then
              begin
                if (Servers[Self.ChannelId].PETS[i].AttackerID >= 3048) then
                  Servers[Self.ChannelId].PETS[i].AttackMob()
                else
                  Servers[Self.ChannelId].PETS[i].AttackTarget();
              end
              else
              begin
                for j in Servers[Self.ChannelId].PETS[i].Base.VisibleMobs do
                begin
                  if (j >= 3048) then
                  begin
                    mobid := TMobFuncs.GetMobGeralID(Self.ChannelId, j, mobpid);
                    if (Servers[Self.ChannelId].MOBS.TMobS[mobid].MobsP[mobpid]
                      .Base.IsDead) then
                      Continue; // não ataco mob morto
                    if not(Servers[Self.ChannelId].MOBS.TMobS[mobid].MobsP[mobpid].CurrentPos.InRange(
                      Servers[Self.ChannelId].PETS[i].Base.PlayerCharacter.LastPos, 15)) then
                        Continue;
                    Servers[Self.ChannelId].PETS[i].IsAttacked := True;
                    Servers[Self.ChannelId].PETS[i].AttackerID := j;
                    Servers[Self.ChannelId].PETS[i].AttackMob();
                    break;
                  end
                  else
                  begin
                    if not(Servers[Self.ChannelId].Players[j].Base.PlayerCharacter.LastPos
                      .InRange(Servers[Self.ChannelId].PETS[i].Base.PlayerCharacter.LastPos, 15)) then
                      Continue;  //não ataco mob longe
                    if (Servers[Self.ChannelId].Players[j].Base.IsDead) then
                      Continue; // verificando se meu alvo esta morto
                    if (Servers[Self.ChannelId].PETS[i].MasterClientID = Servers
                      [Self.ChannelId].Players[j].Base.ClientId) then
                      Continue; // verificando se não vou atacar meu dono
                    if ((Servers[Self.ChannelId].Players[j]
                      .Base.Character.Nation = Servers[Self.ChannelId].Players
                      [Servers[Self.ChannelId].PETS[i].MasterClientID]
                      .Base.Character.Nation) and
                      not(Servers[Self.ChannelId].Players
                      [Servers[Self.ChannelId].PETS[i].MasterClientID]
                      .Character.PlayerKill)) then
                      Continue; // verificando se quem vou atacar é amigo de nação
                    // e se meu pk estiver desligado, ele n ataca, se sim ele atk
                    if (Servers[Self.ChannelId].Players
                      [Servers[Self.ChannelId].PETS[i].MasterClientID]
                      .PartyIndex <> 0) then // se meu dono tiver pt
                    begin
                      if (Servers[Self.ChannelId].Players[j]
                        .PartyIndex = Servers[Self.ChannelId].Players
                        [Servers[Self.ChannelId].PETS[i].MasterClientID]
                        .PartyIndex) then
                        Continue; // se meu alvo estiver na pt não vai atacar
                    end;
                    Servers[Self.ChannelId].PETS[i].IsAttacked := True;
                    Servers[Self.ChannelId].PETS[i].AttackerID := j;
                    Servers[Self.ChannelId].PETS[i].AttackTarget();
                    break;
                  end;
                end;
              end;

            end;
          NORMAL_PET:
            begin
              if(Servers[Self.ChannelId].PETS[i].Base.PlayerCharacter.LastPos
                .Distance(Servers[Self.ChannelId].Players[
                Servers[Self.ChannelId].PETS[i].MasterClientID].Base.PlayerCharacter.LastPos) >= 4) then
              begin
                Randomize;
                Servers[Self.ChannelId].PETS[i].Base.PlayerCharacter.LastPos :=
                Servers[Self.ChannelId].Players[
                Servers[Self.ChannelId].PETS[i].MasterClientID].Base.Neighbors[
                  RandomRange(1, 7)].pos;

                ZeroMemory(@Packet, sizeof(Packet));
                Packet.Header.Size := sizeof(Packet);
                Packet.Header.Index := Servers[Self.ChannelId].PETS[i].Base.ClientID;
                Packet.Header.Code := $301;
                Packet.Destination := Servers[Self.ChannelId].PETS[i].Base.PlayerCharacter.LastPos;
                Packet.MoveType := MOVE_NORMAL;

                Packet.Speed := Servers[Self.ChannelId].Players[
                  Servers[Self.ChannelId].PETS[i].MasterClientID].Base.PlayerCharacter.SpeedMove-10;

                if (Packet.Destination.Distance(Servers[Self.ChannelId].Players[
                Servers[Self.ChannelId].PETS[i].MasterClientID].Base.PlayerCharacter.LastPos) >= 15) then
                begin
                  Packet.Speed := Servers[Self.ChannelId].Players[
                    Servers[Self.ChannelId].PETS[i].MasterClientID].Base.PlayerCharacter.SpeedMove + 10;
                end;

                Servers[Self.ChannelId].Players[
                Servers[Self.ChannelId].PETS[i].MasterClientID].Base.SendToVisible(Packet, Packet.Header.Size, true);
              end;
              for j := Low(Servers[Self.ChannelId].Players) to
                High(Servers[Self.ChannelId].Players) do
              begin
                if((Servers[Self.ChannelId].Players[j].Status >= Playing) and
                  not(Servers[Self.ChannelId].Players[j].SocketClosed)) then
                begin
                  if(Servers[Self.ChannelId].PETS[i].Base.PlayerCharacter.LastPos
                    .InRange(Servers[Self.ChannelId].Players[j].Base.PlayerCharacter.LastPos,
                    DISTANCE_TO_WATCH)) then
                  begin
                    if not(Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Contains(i)) then
                    begin
                      Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Add(i);
                      Servers[Self.ChannelId].Players[j].SpawnPet(i);
                    end;
                  end
                  else
                  begin
                    if (Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Contains(i)) then
                    begin
                      Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Remove(i);
                      Servers[Self.ChannelId].Players[j].UnspawnPet(i);
                    end;
                  end;
                end;
              end;
            end;
        end;
      except
        Continue;
      end;
    end;
    fCritSect.Release;
    Sleep(FDelay);
  end;
end;
{ TPetSpawner }
constructor TPetSpawner.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  fCritSect := TCriticalSection.Create;
  inherited Create(FALSE);
end;
procedure TPetSpawner.Execute;
var
  i, j: WORD;
begin
  while (Servers[Self.ChannelId].IsActive) do
  begin
    fCritSect.Acquire;
    for i := Low(Servers[Self.ChannelId].PETS)
      to High(Servers[Self.ChannelId].PETS) do
    begin
      try
        if not(Servers[Self.ChannelId].PETS[i].Base.IsActive) then
          Continue;
        for j := Low(Servers[Self.ChannelId].Players)
          to High(Servers[Self.ChannelId].Players) do
        begin
          if (Servers[Self.ChannelId].Players[j].Status < Playing) then
            Continue;
          if (Servers[Self.ChannelId].Players[j].Base.PlayerCharacter.LastPos.
            Distance(Servers[Self.ChannelId].PETS[i]
            .Base.PlayerCharacter.LastPos) <= DISTANCE_TO_WATCH) then
          begin
            if (Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Contains
              (Servers[Self.ChannelId].PETS[i].Base.ClientId)) then
              Continue;
            if(Servers[Self.ChannelId].PETS[i].Base.IsDead) then
              Continue;
            Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Add
              (Servers[Self.ChannelId].PETS[i].Base.ClientId);
            Servers[Self.ChannelId].PETS[i].Base.VisibleMobs.Add
              (Servers[Self.ChannelId].Players[j].Base.ClientId);
            Servers[Self.ChannelId].Players[j]
              .SpawnPet(Servers[Self.ChannelId].PETS[i].Base.ClientId);
          end
          else
          begin
            if not(Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Contains
              (Servers[Self.ChannelId].PETS[i].Base.ClientId)) then
              Continue;
            if (Servers[Self.ChannelId].PETS[i].IsAttacked) then
            begin
              if (Servers[Self.ChannelId].PETS[i].AttackerID = Servers
                [Self.ChannelId].Players[j].Base.ClientId) then
              begin
                Servers[Self.ChannelId].PETS[i].IsAttacked := FALSE;
                Servers[Self.ChannelId].PETS[i].AttackerID := 0;
              end;
            end;
            Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Remove
              (Servers[Self.ChannelId].PETS[i].Base.ClientId);
            Servers[Self.ChannelId].PETS[i].Base.VisibleMobs.Remove
              (Servers[Self.ChannelId].Players[j].Base.ClientId);
            Servers[Self.ChannelId].Players[j].UnSpawnPet
              (Servers[Self.ChannelId].PETS[i].Base.ClientId);
          end;
        end;
      except
        Continue;
      end;
    end;
    fCritSect.Release;
    Sleep(FDelay);
  end;
end;
{$ENDREGION}
{$REGION 'Pet Data'}
procedure TPet.AttackTarget();
var
  Packet: TRecvDamagePacket;
  WasDead: Boolean;
begin
  if (TPosition.Create(2947, 1664)
    .InRange(Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.PlayerCharacter.LastPos, 10)) then
  begin
    Self.IsAttacked := FALSE;
    Self.AttackerID := 0;
    Exit;
  end;
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.ClientId;
  Packet.Header.Code := $102;
  Packet.SkillID := 0;
  Packet.AttackerPos := Self.Base.PlayerCharacter.LastPos;
  Packet.AttackerID := Self.Base.ClientId;
  Packet.Animation := 06;
  Packet.AttackerHP := Self.Base.PlayerCharacter.Base.CurrentScore.CurHP;
  Packet.TargetID := Self.AttackerID;
  Packet.MobAnimation := 26;
  Packet.DANO := Self.Base.PlayerCharacter.Base.CurrentScore.DNFis;
  DecUInt64(Packet.DANO, (((Servers[Self.Base.ChannelId].Players[Self.AttackerID]
    .Base.Character.CurrentScore.DefFis +
      Servers[Self.Base.ChannelId].Players[Self.AttackerID]
    .Base.Character.CurrentScore.DefMag) div 5) shr 3));
  Randomize;
  Inc(Packet.DANO, Round((Random(99) / 2) + 5));
  Packet.dnType := TDamageType.Normal;
  WasDead := FALSE;
  if (Packet.DANO >= Servers[Self.Base.ChannelId].Players[Self.AttackerID]
    .Base.Character.CurrentScore.CurHP) then
  begin
    Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.CurrentScore.CurHP := 1;
    //Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.IsDead := True;
    Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.SendEffect($0);
    Packet.MobAnimation := 30;
    Self.Base.VisibleMobs.Remove(Self.AttackerID);
    WasDead := True;
  end
  else
  begin
    Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.RemoveHP(Packet.DANO, False, True);
  end;
  Servers[Self.Base.ChannelId].Players[Self.AttackerID]
    .Base.LastReceivedAttack := Now;
  Packet.MobCurrHP := Servers[Self.Base.ChannelId].Players[Self.AttackerID]
    .Base.Character.CurrentScore.CurHP;
 // Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.SendCurrentHPMP();
  Servers[Self.Base.ChannelId].Players[Self.AttackerID]
    .Base.SendToVisible(Packet, Packet.Header.size, True);
  if (WasDead = True) then
  begin
    Self.IsAttacked := FALSE;
    Self.AttackerID := 0;
  end;
end;
procedure TPet.AttackMob();
var
  Packet: TRecvDamagePacket;
  mobid, mobpid: Integer;
  DroppedExp, DroppedItem: Boolean;
  // i: WORD;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.Base.ClientId;
  Packet.Header.Code := $102;
  Packet.SkillID := 0;
  Packet.AttackerPos := Self.Base.PlayerCharacter.LastPos;
  Packet.AttackerID := Self.Base.ClientId;
  Packet.Animation := 06;
  Packet.AttackerHP := Self.Base.PlayerCharacter.Base.CurrentScore.CurHP;
  Packet.TargetID := Self.AttackerID;
  Packet.MobAnimation := 26;
  Packet.DANO := Self.Base.PlayerCharacter.Base.CurrentScore.DNFis;
  Randomize;
  Inc(Packet.DANO, Round((Random(99) / 2) + 5));
  Packet.dnType := TDamageType.Normal;
  mobid := TMobFuncs.GetMobGeralID(Self.Base.ChannelId,
    Self.AttackerID, mobpid);
  if(Servers[Self.Base.ChannelId].MOBS.TMobS[mobid].MobsP[mobpid].Base.IsDead) then
  begin
    Self.IsAttacked := False;
    Self.AttackerID := 0;
    Exit;
  end;
  Servers[Self.Base.ChannelId].MOBS.TMobS[mobid].MobsP[mobpid]
    .IsAttacked := True;
  Servers[Self.Base.ChannelId].MOBS.TMobS[mobid].MobsP[mobpid].AttackerID :=
    Self.MasterClientID;
  if (Packet.DANO >= Servers[Self.Base.ChannelId].MOBS.TMobS[mobid].MobsP
    [mobpid].HP) then
  begin
    Servers[Self.Base.ChannelId].MOBS.TMobS[mobid].MobsP[mobpid].HP := 0;
    Servers[Self.Base.ChannelId].MOBS.TMobS[mobid].MobsP[mobpid]
      .Base.IsDead := True;
    Packet.MobAnimation := 30;
    Self.Base.VisibleMobs.Remove(Servers[Self.Base.ChannelId].MOBS.TMobS[mobid]
      .MobsP[mobpid].Base.ClientId);
    { for i in Self.Base.VisibleMobs do
      begin
      if (i <= MAX_CONNECTIONS) then
      begin
      Servers[Self.Base.ChannelId].Players[i].UnspawnMob(mobid, mobpid);
      end;
      end; }
    Self.IsAttacked := FALSE;
    Self.AttackerID := 0;

    Servers[Self.Base.ChannelId].Players[MasterClientID].Base.MobKilled(
    @Servers[Self.Base.ChannelId].MOBS.TMobS[mobid].MobsP[mobpid].Base, DroppedExp, DroppedItem,
      False);
  end
  else
  begin
    Servers[Self.Base.ChannelId].MOBS.TMobS[mobid].MobsP[mobpid].HP :=
      (Servers[Self.Base.ChannelId].MOBS.TMobS[mobid].MobsP[mobpid].HP -
      Packet.DANO);
  end;
  Servers[Self.Base.ChannelId].MOBS.TMobS[mobid].MobsP[mobpid]
    .Base.LastReceivedAttack := Now;
  Packet.MobCurrHP := Servers[Self.Base.ChannelId].MOBS.TMobS[mobid].MobsP
    [mobpid].HP;
 // Self.Base.SendToVisible(Packet, Packet.Header.size, FALSE);
   Servers[Self.Base.ChannelId].MOBS.TMobS[mobid].MobsP[mobpid]
    .Base.SendToVisible(Packet, Packet.Header.size, True);
end;
{$ENDREGION}
end.
