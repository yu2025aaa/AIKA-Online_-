unit CommandHandlers;

interface

uses
  Player, Classes, StrUtils, SysUtils;

type
  TCommandHandlers = class(TObject)
  public
    class procedure ProcessCommands(var Player: TPlayer; Command: string;
      Parameter: string);
  private
    class procedure AddItem(var Player: TPlayer; Data: TStringList);
    class procedure EquipItem(var Player: TPlayer; Data: TStringList);
    class procedure MoveItem(var Player: TPlayer; Data: TStringList);

    class procedure AddLevel(var Player: TPlayer; Data: TStringList);
    class procedure AddGold(var Player: TPlayer; Data: TStringList);
    class procedure AddExp(var Player: TPlayer; Data: TStringList);
    class procedure AddCash(var Player: TPlayer; Data: TStringList);

    class procedure AddBuff(var Player: TPlayer; Data: TStringList);
    class procedure RemoveBuff(var Player: TPlayer; Data: TStringList);

    class procedure SetRank(var Player: TPlayer; Data: TStringList);

    class procedure MovePlayer(var Player: TPlayer; Data: TStringList);
    class procedure WalkTo(var Player: TPlayer; Data: TStringList);

    class procedure Disconnect(var Player: TPlayer; Parameter: string);
    class procedure SetDnType(Parameter: string);

    class procedure Demage(var Player: TPlayer; Data: TStringList);

    class procedure AddMob(var Player: TPlayer; Data: TStringList);

    class procedure AddEff(var Player: TPlayer; Data: TStringList);
    class procedure RemoveEff(var Player: TPlayer; Data: TStringList);

    class procedure AddGuildExp(var Player: TPlayer; Data: TStringList);

    class procedure AddTitle(var Player: TPlayer; Data: TStringList);
    class procedure UpdateTitle(var Player: TPlayer; Data: TStringList);
    class procedure RemoveTitle(var Player: TPlayer; Data: TStringList);
  end;

implementation

uses
  GlobalDefs, ItemFunctions, MiscData, PlayerData, BaseMob, Windows;

class procedure TCommandHandlers.ProcessCommands(var Player: TPlayer;
  Command: string; Parameter: string);
var
  CMD: TStringList;
  i: Integer;
begin
  Command := LowerCase(ReplaceStr(Command, '/', ''));

  CMD := TStringList.Create;

  CMD.Delimiter := ' ';
  CMD.DelimitedText := Parameter;

{$REGION 'Mensagem de GM'}
  if (Command = 'msg') then
  begin
    Servers[Player.ChannelIndex].SendServerMsg
      (AnsiString('[' + Player.Base.Character.Name + '] ' +
      ShortString(Parameter)), 32, 16);
    Exit;
  end;

  if (Command = 'msgall') then
  begin
    for i := Low(Servers) to High(Servers) do
    begin
      if not(Servers[i].IsActive) then
        Continue;

      Servers[i].SendServerMsg
        (AnsiString('[' + Player.Base.Character.Name + '] ' +
        ShortString(Parameter)), 32, 16);
    end;

    Exit;
  end;

{$ENDREGION}
{$REGION 'Outros Commandos'}
  case AnsiIndexStr(Command, ['additem', 'equip', 'addexp', 'addgold',
    'addcash', 'addbuff', 'addlevel', 'move', 'walkto', 'dc', 'setdntype',
    'setrank', 'removebuff', 'dmg', 'addmob', 'addeff', 'removeeff', 'moveitem',
    'addguildexp', 'addtitle', 'updatetitle', 'removetitle']) of
    0:
      Self.AddItem(Player, CMD);
    1:
      Self.EquipItem(Player, CMD);
    2:
      Self.AddExp(Player, CMD);
    3:
      Self.AddGold(Player, CMD);
    4:
      Self.AddCash(Player, CMD);
    5:
      Self.AddBuff(Player, CMD);
    6:
      Self.AddLevel(Player, CMD);
    7:
      Self.MovePlayer(Player, CMD);
    8:
      Self.WalkTo(Player, CMD);
    9:
      Self.Disconnect(Player, CMD[0]);
    10:
      Self.SetDnType(CMD[0]);
    11:
      Self.SetRank(Player, CMD);
    12:
      Self.RemoveBuff(Player, CMD);
    13:
      Self.Demage(Player, CMD);
    14:
      Self.AddMob(Player, CMD);
    15:
      Self.AddEff(Player, CMD);
    16:
      Self.RemoveEff(Player, CMD);
    17:
      Self.MoveItem(Player, CMD);
    18:
      Self.AddGuildExp(Player, CMD);

    19:
      Self.AddTitle(Player, CMD);
    20:
      Self.UpdateTitle(Player, CMD);
    21:
      Self.RemoveTitle(Player, CMD);

  else
    begin
      Player.SendClientMessage('Comando inválido.');
    end;

  end;

{$ENDREGION}
end;

class procedure TCommandHandlers.AddItem(var Player: TPlayer;
  Data: TStringList);
var
  Index: WORD;
  Quanty: WORD;
  OtherPlayer: PPlayer;
begin
  if (Data.Count = 3) then
  begin
    try
      if not(Servers[Player.ChannelIndex].GetPlayerByName(Data[0], OtherPlayer))
      then
      begin
        Player.SendClientMessage('Jogador não encontrado.');
        Exit;
      end;

      try
        Index := Data[1].ToInteger;

        case Index of
          20051, 20052, 20053, 20054:
            begin
              Player.SendClientMessage('Itens banidos.');
              Exit;
            end;
        end;

        if (Data.Count = 2) then
        begin
          Quanty := 1;
        end
        else if (Data.Count = 3) then
        begin
          Quanty := Data[2].ToInteger;
        end;
      except
        Exit;
      end;
    finally
      TItemFunctions.PutItem(OtherPlayer^, Index, Quanty);
    end;

    Exit;
  end;

  try
    Index := Data[0].ToInteger;

    case Index of
      20051, 20052, 20053, 20054:
        begin
          Player.SendClientMessage('Itens banidos.');
          Exit;
        end;
    end;

    if (Data.Count = 1) then
    begin
      Quanty := 1;
    end
    else if (Data.Count = 2) then
    begin
      Quanty := Data[1].ToInteger;
    end
    else
      Exit;
  except
    Exit;
  end;

  TItemFunctions.PutItem(Player, Index, Quanty);
end;

class procedure TCommandHandlers.EquipItem(var Player: TPlayer;
  Data: TStringList);
begin
  Player.SendClientMessage('Ainda não setado.');
end;

class procedure TCommandHandlers.MoveItem(var Player: TPlayer;
  Data: TStringList);
var
  SourceSlot, DestSlot: BYTE;
  aux: TItem;
begin
  try
    if (Data.Count < 2) then
    begin
      Player.SendClientMessage('2 parametros necessários');
      Exit;
    end;

    SourceSlot := Data[0].ToInteger;
    DestSlot := Data[1].ToInteger;

    aux := Player.Character.Base.Inventory[DestSlot];
    Player.Character.Base.Inventory[DestSlot] := Player.Character.Base.Inventory
      [SourceSlot];
    Player.Character.Base.Inventory[SourceSlot] := aux;

    Player.Base.SendRefreshItemSlot(SourceSlot, false);
    Player.Base.SendRefreshItemSlot(DestSlot, false);
  except
    Exit;
  end;
end;

class procedure TCommandHandlers.AddLevel(var Player: TPlayer;
  Data: TStringList);
var
  Level: WORD;
  LevelExp: UInt64;
  AddExp: UInt64;
  OtherPlayer: PPlayer;
  Helper: Integer;
begin
  if (Data.Count = 2) then
  begin
    try
      Level := Data[1].ToInteger;
    except
      Exit;
    end;
  end
  else
  begin
    try
      Level := Data[0].ToInteger;
    except
      Exit;
    end;
  end;

  try
    LevelExp := ExpList[Player.Character.Base.Level + (Level - 1)] + 1;
  except
    LevelExp := High(ExpList);
  end;

  AddExp := LevelExp - UInt64(Player.Character.Base.Exp);

  if (Data.Count = 2) then
  begin
    if not(Servers[Player.ChannelIndex].GetPlayerByName(Data[0], OtherPlayer))
    then
    begin
      Player.SendClientMessage('Jogador não encontrado.');
      Exit;
    end;

    OtherPlayer.AddExp(AddExp, Helper);
    OtherPlayer.Base.SendRefreshLevel;
    Exit;
  end;

  Player.AddExp(AddExp, Helper);
  Player.Base.SendRefreshLevel;
end;

class procedure TCommandHandlers.AddGold(var Player: TPlayer;
  Data: TStringList);
var
  Gold: UInt64;
  OtherPlayer: PPlayer;
begin
  if (Data.Count = 2) then
  begin
    try
      Gold := Data[1].ToInt64;
    except
      Exit;
    end;
  end
  else
  begin
    try
      Gold := Data[0].ToInt64;
    except
      Exit;
    end;
  end;

  if (Data.Count = 2) then
  begin
    if not(Servers[Player.ChannelIndex].GetPlayerByName(Data[0], OtherPlayer))
    then
    begin
      Player.SendClientMessage('Jogador não encontrado.');
      Exit;
    end;

    OtherPlayer.AddGold(Gold);
    Exit;
  end;

  Player.AddGold(Gold);
end;

class procedure TCommandHandlers.AddExp(var Player: TPlayer; Data: TStringList);
var
  Exp: UInt64;
  OtherPlayer: PPlayer;
  Helper: Integer;
begin
  if (Data.Count = 2) then
  begin
    try
      Exp := Data[1].ToInt64;
    except
      Exit;
    end;
  end
  else
  begin
    try
      Exp := Data[0].ToInt64;
    except
      Exit;
    end;
  end;

  if (Data.Count = 2) then
  begin
    if not(Servers[Player.ChannelIndex].GetPlayerByName(Data[0], OtherPlayer))
    then
    begin
      Player.SendClientMessage('Jogador não encontrado.');
      Exit;
    end;

    OtherPlayer.AddExp(Exp, Helper);
    Exit;
  end;

  Player.AddExp(Exp, Helper);
end;

class procedure TCommandHandlers.AddCash(var Player: TPlayer;
  Data: TStringList);
var
  Cash: Cardinal;
  OtherPlayer: PPlayer;
begin
  if (Data.Count = 2) then
  begin
    try
      Cash := Data[1].ToInt64;
    except
      Exit;
    end;
  end
  else
  begin
    try
      Cash := Data[0].ToInt64;
    except
      Exit;
    end;
  end;

  if (Data.Count = 2) then
  begin
    if not(Servers[Player.ChannelIndex].GetPlayerByName(Data[0], OtherPlayer))
    then
    begin
      Player.SendClientMessage('Jogador não encontrado.');
      Exit;
    end;

    OtherPlayer.AddCash(Cash);
    Exit;
  end;

  Player.AddCash(Cash);
end;

class procedure TCommandHandlers.AddBuff(var Player: TPlayer;
  Data: TStringList);
var
  Buff: Cardinal;
  OtherPlayer: PPlayer;
begin
  Player.SendClientMessage('Comando temporariamente desativado.');
  Exit;

  if (Data.Count = 2) then
  begin
    try
      Buff := Data[1].ToInt64;
    except
      Exit;
    end;
  end
  else
  begin
    try
      Buff := Data[0].ToInt64;
    except
      Exit;
    end;
  end;

  if (Data.Count = 2) then
  begin
    if not(Servers[Player.ChannelIndex].GetPlayerByName(Data[0], OtherPlayer))
    then
    begin
      Player.SendClientMessage('Jogador não encontrado.');
      Exit;
    end;

    OtherPlayer.Base.AddBuff(Buff);
    Exit;
  end;

  Player.Base.AddBuff(Buff);
end;

class procedure TCommandHandlers.RemoveBuff(var Player: TPlayer;
  Data: TStringList);
var
  Buff: Cardinal;
  OtherPlayer: PPlayer;
begin
  if (Data.Count = 2) then
  begin
    try
      Buff := Data[1].ToInt64;
    except
      Exit;
    end;
  end
  else
  begin
    try
      Buff := Data[0].ToInt64;
    except
      Exit;
    end;
  end;

  if (Data.Count = 2) then
  begin
    if not(Servers[Player.ChannelIndex].GetPlayerByName(Data[0], OtherPlayer))
    then
    begin
      Player.SendClientMessage('Jogador não encontrado.');
      Exit;
    end;

    OtherPlayer.Base.RemoveBuff(Buff);
    Exit;
  end;

  Player.Base.RemoveBuff(Buff);
end;

class procedure TCommandHandlers.SetRank(var Player: TPlayer;
  Data: TStringList);
var
  Rank: BYTE;
  OtherPlayer: PPlayer;
begin
  if not(Player.Account.Header.AccountType = TAccountType.Admin) then
    Exit;

  if (Data.Count = 2) then
  begin
    try
      Rank := Data[1].ToInteger;
    except
      Exit;
    end;
  end
  else
  begin
    try
      Rank := Data[0].ToInteger;
    except
      Exit;
    end;
  end;

  if (Data.Count = 2) then
  begin
    if not(Servers[Player.ChannelIndex].GetPlayerByName(Data[0], OtherPlayer))
    then
    begin
      Player.SendClientMessage('Jogador não encontrado.');
      Exit;
    end;

    OtherPlayer.Account.Header.AccountType := TAccountType(Rank);
    Exit;
  end;

  Player.Account.Header.AccountType := TAccountType(Rank);
end;

class procedure TCommandHandlers.MovePlayer(var Player: TPlayer;
  Data: TStringList);
var
  Pos: TPosition;
  OtherPlayer: PPlayer;
begin
  if (Data.Count = 1) then
  begin
    if not(Servers[Player.ChannelIndex].GetPlayerByName(Data[0], OtherPlayer))
    then
    begin
      Player.SendClientMessage('Jogador não encontrado.');
      Exit;
    end;

    Player.Teleport(OtherPlayer.Base.PlayerCharacter.LastPos);

    Exit;
  end
  else if (Data.Count = 3) then
  begin
    if not(Servers[Player.ChannelIndex].GetPlayerByName(Data[0], OtherPlayer))
    then
    begin
      Player.SendClientMessage('Jogador não encontrado.');
      Exit;
    end;

    try
      Pos.Create(Data[1].ToSingle, Data[2].ToSingle);
    except
      Pos.Create(50, 50);
    end;

    OtherPlayer.Teleport(Pos);

    Exit;
  end;

  try
    Pos.Create(Data[0].ToSingle, Data[1].ToSingle);
  except
    Pos.Create(50, 50);
  end;

  Player.Teleport(Pos);
end;

class procedure TCommandHandlers.WalkTo(var Player: TPlayer; Data: TStringList);
var
  Pos: TPosition;
  mob: PBaseMob;
begin
  Player.SendClientMessage('Comando temporariamente indisponível.');
  Exit;

  if not(Data.Count = 3) then
  begin
    Player.SendClientMessage('Formato do comando: [Index X Y].');
    Exit;
  end;

  if not(TBaseMob.GetMob(Data[0].ToInteger, Player.ChannelIndex, mob)) then
  begin
    Player.SendClientMessage('Não instanciado.');
    Exit;
  end;

  try
    Pos.Create(Data[1].ToSingle, Data[2].ToSingle);
  except
    Pos.Create(000, 000);
  end;

  mob.WalkTo(Pos);
end;

class procedure TCommandHandlers.Disconnect(var Player: TPlayer;
  Parameter: string);
var
  OtherPlayer: PPlayer;
begin
  Player.SendClientMessage('Comando temporariamente indisponivel.');
  Exit;

  if not(Servers[Player.ChannelIndex].GetPlayerByName(Parameter, OtherPlayer))
  then
  begin
    Player.SendClientMessage('Jogador não encontrado.');
    Exit;
  end;

  if (OtherPlayer.Account.Header.AccountType > Player.Account.Header.AccountType)
  then
  begin
    Player.SendClientMessage('Você não tem autoridade pra isso.');
    Exit;
  end;

  // OtherPlayer.SendSignal($7535, $313);

  Servers[Player.ChannelIndex].Disconnect(OtherPlayer.Base.ClientId);
end;

class procedure TCommandHandlers.Demage(var Player: TPlayer; Data: TStringList);
var
  Dano: Cardinal;
begin
  Player.SendClientMessage('Comando temporariamente desativado!');
  Exit;

  Dano := 0;
  try
    Dano := Data[0].ToInt64;
  finally
    Player.Base.RemoveHP(Dano, true);
  end;
end;

class procedure TCommandHandlers.AddMob(var Player: TPlayer; Data: TStringList);
begin

end;

class procedure TCommandHandlers.SetDnType(Parameter: string);
begin
  try
    DamageType := Parameter.ToInteger;
  except
    DamageType := $1A;
  end;
end;

class procedure TCommandHandlers.AddEff(var Player: TPlayer; Data: TStringList);
begin
  Player.SendEffect(Data[0].ToInteger());
end;

class procedure TCommandHandlers.RemoveEff(var Player: TPlayer;
  Data: TStringList);
begin
  Player.SendEffect(0);
end;

class procedure TCommandHandlers.AddGuildExp(var Player: TPlayer;
  Data: TStringList);
var
  i: Integer;
  GuildLeveled: Boolean;
  OtherPlayer: PPlayer;
begin
  GuildLeveled := false;

  if (DWORD(Guilds[Player.Character.GuildSlot].GuildLeaderCharIndex)
    = Player.Base.PlayerCharacter.Index) then
  begin
    Inc(Guilds[Player.Character.GuildSlot].Exp, Data[0].ToInteger);

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

        if (GuildLeveled) then
        begin
          OtherPlayer.SendClientMessage('A sua guild subiu de level!');
        end;
      end;
    end;
  end
  else
  begin
    Player.SendClientMessage('Você não é o lider de sua guild.');
  end;
end;

class procedure TCommandHandlers.AddTitle(var Player: TPlayer; Data: TStringList);
begin
  Player.AddTitle(Data[0].ToInteger(), Data[1].ToInteger());
end;

class procedure TCommandHandlers.UpdateTitle(var Player: TPlayer; Data: TStringList);
begin
  Player.UpdateTitleLevel(Data[0].ToInteger(), Data[1].ToInteger());
end;

class procedure TCommandHandlers.RemoveTitle(var Player: TPlayer; Data: TStringList);
begin
  Player.RemoveTitle(Data[0].ToInteger());
end;

end.
