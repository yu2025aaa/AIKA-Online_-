unit CastleSiege;

interface

uses
  Player, Windows;

{$OLDTYPELAYOUT ON}

type
  PCastleSiege = ^TCastleSiege;

  TCastleSiege = class(TObject)
  var
    OrbHolder: ARRAY [0..2] OF PPlayer;
    OrbsHolded: Integer;

    SealHolder: PPlayer;
    SealHoldingStart: TDateTime;
    SealBeingHold: Boolean;
    SealHoldingSeconds: Integer;

    WarInProgress: Boolean;
    WarTimeInit: TDateTime;
  public
    procedure SendHoldingOrbPacket(var Player: TPlayer; ObjectIndex: word);
    procedure SendHoldingSeal(var Player: TPlayer);
  end;

{$OLDTYPELAYOUT OFF}

implementation

uses
  Packets;

procedure TCastleSiege.SendHoldingOrbPacket(var Player: TPlayer; ObjectIndex: word);
var
  Packet: TCollectItem;
begin
  ZeroMemory(@Packet, sizeof(TCollectItem));

  Packet.Header.size := sizeof(TCollectItem);
  Packet.Header.Code := $336;

  Packet.Index := ObjectIndex;

  Packet.Time := $FFFFFFFF;

  Packet.Null := 5;

  Player.SendPacket(Packet, Packet.Header.size);
end;

procedure TCastleSiege.SendHoldingSeal(var Player: TPlayer);
var
  Packet: TCollectItem;
begin
  ZeroMemory(@Packet, sizeof(TCollectItem));

  Packet.Header.size := sizeof(TCollectItem);
  Packet.Header.Code := $336;

  Packet.Index := 3373;

  Packet.Time := 120;

  Packet.Null := 5;

  Player.SendPacket(Packet, Packet.Header.size);
end;

end.
