unit R_Paneil;

interface

uses
  Player, PacketHandlers, Packets;

{$REGION 'Estruturas de pacotes do painel'}

type
  TAddGoldPacket = packed record
    PacketHeader: TPacketHeader;
    Amount: Int64; // 8 bytes dps do header no pacote 00 00 00 00 00 00 00 00
  end;

{$ENDREGION}

type
  GMPacketHandlers = class(TObject)
  public
    { Painel GM }
    Class function AdicionarGold(var Player: TPlayer;
      Buffer: Array Of Byte): Boolean;
    Class function AdicionarCash(var Player: TPlayer;
      Buffer: Array Of Byte): Boolean;

  End;

implementation

uses
  GlobalDefs, Functions, Log, PlayerData, Util, MiscData, Windows,
  NPCHandlers, ItemFunctions, SkillFunctions, DateUtils, PartyData,
  CommandHandlers, BaseMob, GuildData, MOB;

class function GMPacketHandlers.AdicionarGold(var Player: TPlayer;
  Buffer: Array Of Byte): Boolean;
var
  Packet: TAddGoldPacket absolute Buffer;
begin
  result := false;

  if (Player.Account.Header.AccountType >= GameMaster) then
  begin
    //Player.AddGold(Packet.Amount);
    result := true;
  end;
end;

class function GMPacketHandlers.AdicionarCash(var Player: TPlayer;
  Buffer: Array Of Byte): Boolean;
var
  Value: integer;
begin
  result := false;

  if (Player.Account.Header.AccountType >= GameMaster) then
  begin
    Value := Pinteger(@Buffer[12])^;
    //Player.AddCash(Value);
    result := true;
  end;
end;

{
  if (Player.Account.Header.AccountType >= GameMaster) and
  (Packet.Nick[0] = '/') then
  begin

  Result := true;
  Exit;
  end;
}

end.
