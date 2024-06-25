unit ItemFunctions;
interface
uses MiscData, Player, BaseMob, Windows, PlayerData;
type
  TItemFunctions = class(TObject)
  public
    { Item Amount }
    class function GetItemAmount(item: TItem): BYTE; static;
    class procedure SetItemAmount(var item: TItem; quant: WORD;
      Somar: Boolean = False); static;
    class procedure DecreaseAmount(item: PItem; Quanti: WORD = 1); overload;
    class procedure DecreaseAmount(var Player: TPlayer; Slot: BYTE;
      Quanti: WORD = 1); overload;
    class function AgroupItem(SrcItem, DestItem: PItem): Boolean;
    { Item Price }
    class function GetBuyItemPrice(item: TItem; var Price: TItemPrice;
      quant: WORD = 1): Boolean;
    { Item Propertys }
    class function CanAgroup(item: TItem): Boolean; overload;
    class function CanAgroup(item: TItem; Quanti: WORD): Integer; overload;
    { Put e Remove item }
    class function PutItem(var Player: TPlayer; item: TItem;
      StartSlot: BYTE = 0; Notice: Boolean = False): Integer; overload;
    class function PutItem(var Player: TPlayer; Index: WORD; quant: WORD = 1)
      : Integer; overload;
    class function PutEquipament(var Player: TPlayer; Index: Integer;
      Refine: Integer = 0): Integer;
    class function RemoveItem(var Player: TPlayer;
      const SlotType, Slot: Integer): Boolean;
    class function PutItemOnEvent(var Player: TPlayer; ItemIndex: WORD; ItemAmount: WORD = 1)
      : Boolean;
    class function PutItemOnEventByCharIndex(var Player: TPlayer; CharIndex: Integer;
      ItemIndex: WORD): Boolean;
    { Item Duration }
    class function SetItemDuration(var item: TItem): Boolean;
    { Conjunt & Equip }
    class function GetItemEquipSlot(Index: Integer): Integer;
    class function GetItemEquipPranSlot(Index: Integer): Integer;
    class function GetConjuntCount(const BaseMB: TBaseMob;
      Index: Integer): Integer;
    class function GetItemBySlot(var Player: TPlayer; Slot: BYTE;
      out item: TItem): Boolean;
    class function GetClass(ClassInfo: Integer = 0): Integer;
    { Inventory Slots }
    class function GetInvItemCount(const Player: TPlayer): Integer;
    class function GetInvAvailableSlots(const Player: TPlayer): Integer;
    class function GetInvMaxSlot(const Player: TPlayer): Integer;
    class function GetInvPranMaxSlot(const Player: TPlayer): Integer;
    class function GetEmptySlot(const Player: TPlayer): BYTE; static;
    class function GetEmptyPranSlot(const Player: TPlayer): BYTE; static;
    class function VerifyItemSlot(var Player: TPlayer; Slot: Integer;
      const item: TItem): Boolean;
    class function VerifyBagSlot(const Player: TPlayer; Slot: Integer): Boolean;
    class function GetItemSlot(const Player: TPlayer; item: TItem;
      SlotType: BYTE; StartSlot: BYTE = 0): BYTE; static;
    class function GetItemSlot2(const Player: TPlayer; ItemID: WORD)
      : BYTE; static;
    class function GetItemSlotByItemType(const Player: TPlayer; ItemType: WORD;
      SlotType: BYTE; StartSlot: BYTE = 0): BYTE;
    class function GetItemSlotAndAmountByIndex(const Player: TPlayer;
      ItemIndex: WORD; out Slot, Refi: BYTE): Boolean;
    class function GetItemReliquareSlot(const Player: TPlayer): Byte;
    class function GetItemThatExpires(const Player: TPlayer; SlotType: BYTE): Byte;
    { Ramdom Select Functions }
    class function SelectRamdomItem(const Items: ARRAY OF WORD;
      const Chances: ARRAY OF WORD): WORD;
    { Reinforce }
    class function GetResultRefineItem(const item: WORD; Extract: WORD;
      Refine: BYTE): BYTE;
    class function GetItemReinforceChance(const item: WORD; Refine: BYTE): WORD;
    class function ReinforceItem(var Player: TPlayer; item: DWORD; Item2: DWORD;
      Item3: DWORD): BYTE;
    class function GetArmorReinforceIndex(const item: WORD): WORD;
    class function GetReinforceCust(const Index: WORD): Cardinal;
    class function GetItemReinforce2Index(ItemIndex: WORD): WORD;
    class function GetItemReinforce3Index(ItemIndex: WORD): WORD;
    { Enchant }
    class function Enchantable(item: TItem): Boolean;
    class function GetEmptyEnchant(item: TItem): BYTE;
    class function EnchantItem(var Player: TPlayer; ItemSlot: DWORD;
      Item2: DWORD): BYTE;
    { Change App }
    class function Changeable(item: TItem): Boolean;
    class function ChangeApp(var Player: TPlayer; item: DWORD; Athlon: DWORD;
      NewApp: DWORD): BYTE;
    { Mount Enchant }
    class function EnchantMount(var Player: TPlayer; ItemSlot: DWORD;
      Item2: DWORD): BYTE;
    { Premium Inventory Function }
    class function FindPremiumIndex(Index: WORD): WORD;
    { Use item }
    class function UsePremiumItem(var Player: TPlayer; Slot: Integer): Boolean;
    class function UseItem(var Player: TPlayer; Slot: Integer;
      Type1: DWORD = 0): Boolean;
    { Item Reinforce Stats }
    class function GetItemReinforceDamageReduction(Index: WORD;
      Refine: BYTE): WORD;
    class function GetItemReinforceHPMPInc(Index: WORD; Refine: BYTE): WORD;
    class function GetReinforceFromItem(const item: TItem): BYTE;
    { ItemDB Functions }
    class function UpdateMovedItems(var Player: TPlayer;
      SrcItemSlot, DestItemSlot: BYTE; SrcSlotType, DestSlotType: BYTE;
      SrcItem, DestItem: PItem): Boolean;
    { Recipe Functions }
    class function GetIDRecipeArray(RecipeItemID: WORD): WORD;
  end;
implementation
uses GlobalDefs, Log, SysUtils, DateUtils, FilesData, Math, Util, SQL,
  NPCHandlers;
{$REGION 'Item Amount'}
class function TItemFunctions.GetItemAmount(item: TItem): BYTE;
begin
  if ItemList[item.Index].CanAgroup then
  begin
    Result := item.Refi;
  end
  else
  begin
    Result := 1;
  end;
end;
class procedure TItemFunctions.SetItemAmount(var item: TItem; quant: WORD;
  Somar: Boolean = False);
begin
  if ItemList[item.Index].CanAgroup then
  begin
    if (Somar = True) then
    begin
      Inc(item.Refi, quant);
    end
    else
    begin
      item.Refi := quant;
    end;
  end
  else
  begin
    Exit;
  end;
end;
class procedure TItemFunctions.DecreaseAmount(item: PItem; Quanti: WORD = 1);
begin
  if (item.Refi - Quanti) > 0 then
  begin
    Dec(item.Refi, Quanti);
  end
  else
  begin
    ZeroMemory(item, sizeof(TItem));
  end;
end;
class procedure TItemFunctions.DecreaseAmount(var Player: TPlayer; Slot: BYTE;
  Quanti: WORD = 1);
var
  item: PItem;
begin
  item := @Player.Character.Base.Inventory[Slot];
  Self.DecreaseAmount(item, Quanti);
end;
class function TItemFunctions.AgroupItem(SrcItem: PItem;
  DestItem: PItem): Boolean;
var
  quant: WORD;
  Aux: TItem;
begin
  Result := False;
  if ItemList[SrcItem.Index].CanAgroup then
  begin
    if (SrcItem.Refi + DestItem.Refi) > MAX_SLOT_AMOUNT then
    begin
      if (SrcItem.Refi = 1000) or (DestItem.Refi = 1000) then
      begin
        Move(DestItem^, Aux, sizeof(TItem));
        Move(SrcItem^, DestItem^, sizeof(TItem));
        Move(Aux, SrcItem^, sizeof(TItem));
        Result := True;
        Exit;
      end;
      quant := (SrcItem.Refi + DestItem.Refi) - MAX_SLOT_AMOUNT;
      TItemFunctions.SetItemAmount(SrcItem^, MAX_SLOT_AMOUNT);
      TItemFunctions.SetItemAmount(DestItem^, quant);
    end
    else
    begin
      Inc(SrcItem^.Refi, DestItem^.Refi);
      ZeroMemory(DestItem, sizeof(TItem));
      Result := True;
      Exit;
    end;
  end
end;
{$ENDREGION}
{$REGION 'Item Price'}
class function TItemFunctions.GetBuyItemPrice(item: TItem;
  var Price: TItemPrice; quant: WORD = 1): Boolean;
begin
  if (ItemList[item.Index].TypePriceItem > 0) then
  begin
    Price.PriceType := PRICE_ITEM;
    Price.Value1 := ItemList[item.Index].TypePriceItem;
    Price.Value2 := ItemList[item.Index].TypePriceItemValue * quant;
    Result := True;
    Exit;
  end
  else if ((ItemList[item.Index].PriceHonor > 0) and (
    ItemList[item.Index].SellPrince = 0)) then
  begin
    Price.PriceType := PRICE_HONOR;
    Price.Value1 := ItemList[item.Index].PriceHonor * quant;
    Price.Value2 := ItemList[item.Index].PriceMedal * quant;
    Result := True;
    Exit;
  end
  else if (ItemList[item.Index].PriceMedal > 0) then
  begin
    Price.PriceType := PRICE_MEDAL;
    Price.Value1 := ItemList[item.Index].PriceMedal * quant;
    Price.Value2 := ItemList[item.Index].PriceGold * quant;
    Result := True;
    Exit;
  end
  else
  begin
    Price.PriceType := PRICE_GOLD;
    Price.Value1 := ItemList[item.Index].SellPrince * quant;
    Result := True;
    Exit;
  end;
end;
{$ENDREGION}
{$REGION 'Item Propertys'}
class function TItemFunctions.CanAgroup(item: TItem): Boolean;
begin
  if (ItemList[item.Index].CanAgroup) then
  begin
    Result := True;
    Exit;
  end;
  Result := False;
end;
class function TItemFunctions.CanAgroup(item: TItem; Quanti: WORD): Integer;
begin
  if not(ItemList[item.Index].CanAgroup) then
  begin
    Result := ITEM_UNAGRUPABLE;
  end
  else if (item.Refi + Quanti > 1000) then
  begin
    Result := ITEM_QUANT_EXCEDE;
  end
  else
  begin
    Result := ITEM_AGRUPABLE;
  end;
end;
{$ENDREGION}
{$REGION 'Put & Remove Item'}
class function TItemFunctions.PutItem(var Player: TPlayer; item: TItem;
  StartSlot: BYTE = 0; Notice: Boolean = False): Integer;
var
  Slot, InInventory: BYTE;
  quant, i, j: WORD;
  ItemInv: TItem;
begin
  Slot := 0;
  Result := -1;
  InInventory := Self.GetItemSlot(Player, item, INV_TYPE, StartSlot);
  if (ItemList[item.Index].Expires) and not(ItemList[item.Index].CanSealed) then
  begin
    Self.SetItemDuration(item);
  end;
  if (ItemList[item.Index].CanSealed) then
  begin
    item.IsSealed := True;
  end;
  case InInventory of
    0 .. 128:
      begin
        case Self.CanAgroup(Player.Character.Base.Inventory[InInventory],
          item.Refi) of
          ITEM_UNAGRUPABLE:
            begin
              Slot := Self.GetEmptySlot(Player);
              if (Slot = 255) then
              begin
                Player.SendClientMessage('Inventário cheio!');
                Exit;
              end;
              if (item.Index = 5300) then
              begin
                if (Player.Character.Base.Inventory[61].Index = 0) then
                  Slot := 61
                else if (Player.Character.Base.Inventory[62].Index = 0) then
                  Slot := 62
                else
                  Exit;
              end;
              Move(item, Player.Character.Base.Inventory[Slot], sizeof(TItem));
              Player.Base.SendRefreshItemSlot(INV_TYPE, Slot,
                Player.Character.Base.Inventory[Slot], Notice);
            end;
          ITEM_QUANT_EXCEDE:
            begin
              Move(item, ItemInv, sizeof(TItem));
              quant := MAX_SLOT_AMOUNT - Player.Character.Base.Inventory
                [InInventory].Refi;
              if (quant > 0) then
              begin
                Self.SetItemAmount(Player.Character.Base.Inventory[InInventory],
                  MAX_SLOT_AMOUNT);
                Player.Base.SendRefreshItemSlot(INV_TYPE, InInventory,
                  Player.Character.Base.Inventory[InInventory], Notice);
                Dec(ItemInv.Refi, quant);
                Result := Self.PutItem(Player, ItemInv, InInventory + 1);
              end
              else
              begin
                Result := Self.PutItem(Player, ItemInv, InInventory + 1);
              end;
            end;
          ITEM_AGRUPABLE:
            begin
              Self.SetItemAmount(Player.Character.Base.Inventory[InInventory],
                item.Refi, True);
              Player.Base.SendRefreshItemSlot(INV_TYPE, InInventory,
                Player.Character.Base.Inventory[InInventory], Notice);
            end;
        end;
      end;
    255:
      begin
        Slot := Self.GetEmptySlot(Player);
        Move(item, Player.Character.Base.Inventory[Slot], sizeof(TItem));
        Player.Base.SendRefreshItemSlot(INV_TYPE, Slot,
          Player.Character.Base.Inventory[Slot], Notice);
        if(ItemList[Player.Character.Base.Inventory[Slot].Index].ItemType = 40) then
        begin
          for I := Low(Servers) to High(Servers) do
          begin
            Servers[i].SendServerMsgForNation
              ('O jogador <'+AnsiString(Player.Base.Character.Name)+
              '> adquiriu o tesouro sagrado [' +
                AnsiString(ItemList[Player.Character.Base.Inventory[Slot].Index].Name) + '].'
                {'] do templo de ' +
                 AnsiString(
              Servers[Player.Channelindex].DevirNpc[Player.OpennedTemple].
              PlayerChar.Base.PranName[0])}, Integer(
              Player.Account.Header.Nation), 16, 32, 16);
          end;
          Player.SendEffect(32);
        end;
      end;
  end;
  if (Result = -1) and (Slot <> 255) then
    Result := Slot;
end;
class function TItemFunctions.PutItem(var Player: TPlayer;
  Index, quant: WORD): Integer;
var
  item: TItem;
begin
  ZeroMemory(@item, sizeof(item));
  item.Index := Index;
  item.APP := Index;
  item.Refi := quant;
  item.MIN := ItemList[item.Index].Durabilidade;
  item.MAX := item.MIN;
  Result := Self.PutItem(Player, item, 0, True)
end;
class function TItemFunctions.PutEquipament(var Player: TPlayer; Index: Integer;
  Refine: Integer = 0): Integer;
var
  item: TItem;
begin
  ZeroMemory(@item, sizeof(TItem));
  item.Index := Index;
  item.APP := Index;
  item.MAX := ItemList[item.Index].Durabilidade;
  item.MIN := item.MAX;
  item.Refi := Refine;
  Result := Self.PutItem(Player, item, 0, True)
end;
class function TItemFunctions.RemoveItem(var Player: TPlayer;
  const SlotType, Slot: Integer): Boolean;
var
  item: PItem;
begin
  Result := False;
  item := Nil;
  case SlotType of
    INV_TYPE:
      begin
        if (Slot >= 0) and (Slot <= 63) then
        begin
          item := @Player.Character.Base.Inventory[Slot];
        end
        else
          Exit;
      end;
    STORAGE_TYPE:
      begin
        if (Slot >= 0) and (Slot <= 83) then
        begin
          item := @Player.Account.Header.Storage.Itens[Slot];
        end
        else
          Exit;
      end;
    CASH_TYPE:
      begin
        if (Slot >= 0) and (Slot <= 23) then
        begin
          item^ := Player.Account.Header.CashInventory.Items[Slot].ToItem;
        end
        else
          Exit;
      end;
    EQUIP_TYPE:
      begin
        if (Slot >= 0) and (Slot <= 15) then
        begin
          item := @Player.Character.Base.Equip[Slot];
        end
        else
          Exit;
      end;
    PRAN_EQUIP_TYPE:
      begin
        if(Player.SpawnedPran = 255) then
          Exit;

        case Player.SpawnedPran of
          0:
          begin
            if (Slot >= 1) and (Slot <= 5) then
            begin
              item := @Player.Account.Header.Pran1.Equip[Slot];
            end
            else
              Exit;
          end;

          1:
          begin
            if (Slot >= 1) and (Slot <= 5) then
            begin
              item := @Player.Account.Header.Pran2.Equip[Slot];
            end
            else
              Exit;
          end;
        end;


      end;
    PRAN_INV_TYPE:
      begin
        if(Player.SpawnedPran = 255) then
          Exit;

        case Player.SpawnedPran of
          0:
          begin
            if (Slot >= 0) and (Slot <= 41) then
            begin
              item := @Player.Account.Header.Pran1.Inventory[Slot];
            end
            else
              Exit;
          end;

          1:
          begin
            if (Slot >= 0) and (Slot <= 41) then
            begin
              item := @Player.Account.Header.Pran2.Inventory[Slot];
            end
            else
              Exit;
          end;
        end;
      end;

  else
    begin
      Exit;
    end;
  end;
  if (item = Nil) then
    Exit;
  ZeroMemory(item, sizeof(TItem));
  Player.Base.SendRefreshItemSlot(SlotType, Slot, item^, False);
  Result := True;
end;
class function TItemFunctions.PutItemOnEvent(var Player: TPlayer;
  ItemIndex: WORD; ItemAmount: WORD): Boolean;
var
  SQLComp: TQuery;
  charid: Integer;
begin
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[PutItemOnEvent]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[PutItemOnEvent]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    if(Player.Base.Character.CharIndex = 0) then
      charid := Player.Account.Characters[0].Index
    else
      charid := Player.Base.Character.CharIndex;

    SQLComp.SetQuery
      (format('INSERT INTO items (slot_type, owner_id, item_id, refine, slot) VALUES '
      + '(%d, %d, %d, %d, 0)', [EVENT_ITEM, charid, ItemIndex, ItemAmount]));
    SQLComp.Run(False);
  except
    on E: Exception do
    begin
      Logger.Write('TItemFunctions.PutItemOnEvent ' + E.Message,
        TLogType.Error);
    end;
  end;
  SQLComp.Destroy;
end;
class function TItemFunctions.PutItemOnEventByCharIndex(var Player: TPlayer; CharIndex: Integer;
  ItemIndex: WORD): Boolean;
var
  SQLComp: TQuery;
begin
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[PutItemOnEventByCharIndex]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[PutItemOnEventByCharIndex]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    SQLComp.SetQuery
      (format('INSERT INTO items (slot_type, owner_id, item_id, refine, slot) VALUES '
      + '(%d, %d, %d, %d, 0)', [EVENT_ITEM, CharIndex, ItemIndex, 1]));
    SQLComp.Run(False);
  except
    on E: Exception do
    begin
      Logger.Write('TItemFunctions.PutItemOnEvent ' + E.Message,
        TLogType.Error);
    end;
  end;
  SQLComp.Destroy;
end;
{$ENDREGION}
{$REGION 'Item Duration'}
class function TItemFunctions.SetItemDuration(var item: TItem): Boolean;
begin
  Result := True;
  if (ItemList[item.Index].Expires) then
  begin
    item.ExpireDate := IncHour(Now, ItemList[item.Index].Duration + 2);
  end
  else
  begin
    Result := False;
  end;
end;
{$ENDREGION}
{$REGION 'Conjunt & Equip'}
class function TItemFunctions.GetItemEquipSlot(Index: Integer): Integer;
begin
  Result := 0;
  if (ItemList[Index].ItemType = 50) or (ItemList[Index].ItemType = 52) then
  begin
    Result := 15;
  end;
  if (ItemList[Index].ItemType > 0) and (ItemList[Index].ItemType < 16) then
  begin
    Result := ItemList[Index].ItemType;
    Exit;
  end
  else if (ItemList[Index].ItemType > 1000) and (ItemList[Index].ItemType < 1011)
  then
  begin
    Result := 6;
    Exit;
  end;
end;
class function TItemFunctions.GetItemEquipPranSlot(Index: Integer): Integer;
begin
  Result := ItemList[Index].ItemType - 18;
end;
class function TItemFunctions.GetConjuntCount(const BaseMB: TBaseMob;
  Index: Integer): Integer;
var
  Count, Conjunt: Integer;
  i: Integer;
begin
  Conjunt := Conjuntos[Index];
  Count := 0;
  for i := 0 to 15 do
  begin
    if BaseMB.EQUIP_CONJUNT[i] = Conjunt then
      Inc(Count, 1);
  end;
  Result := Count;
end;
class function TItemFunctions.GetItemBySlot(var Player: TPlayer; Slot: BYTE;
  out item: TItem): Boolean;
begin
  Result := False;
  if (Slot > 63) then
    Exit;
  item := Player.Base.Character.Inventory[Slot];
  Result := True;
end;
class function TItemFunctions.GetClass(ClassInfo: Integer = 0): Integer;
begin
  Result := 0;
  // war
  if (ClassInfo >= 1) and (ClassInfo <= 9) then
    Result := 0;
  // templar
  if (ClassInfo >= 11) and (ClassInfo <= 19) then
    Result := 1;
  // att
  if (ClassInfo >= 21) and (ClassInfo <= 29) then
    Result := 2;
  // dual
  if (ClassInfo >= 31) and (ClassInfo <= 39) then
    Result := 3;
  // mago
  if (ClassInfo >= 41) and (ClassInfo <= 49) then
    Result := 4;
  // cleriga
  if (ClassInfo >= 51) and (ClassInfo <= 59) then
    Result := 5;
end;
{$ENDREGION}
{$REGION 'Inventory Slots'}
class function TItemFunctions.VerifyItemSlot(var Player: TPlayer; Slot: Integer;
  const item: TItem): Boolean;
var
  OriginalItem: TItem;
begin
  ZeroMemory(@OriginalItem, sizeof(TItem));
  OriginalItem := Player.Character.Base.Inventory[Slot];
  Result := False;
  if not(CompareMem(@OriginalItem, @item, sizeof(TItem))) then
    Exit;
  Result := True;
end;
class function TItemFunctions.GetInvItemCount(const Player: TPlayer): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Self.GetInvMaxSlot(Player) do
  begin
    if (Player.Character.Base.Inventory[i].Index > 0) then
    begin
      Inc(Result);
    end;
  end;
end;
class function TItemFunctions.GetInvAvailableSlots(const Player
  : TPlayer): Integer;
var
  Used: Integer;
  Available: Integer;
begin
  Used := Self.GetInvItemCount(Player);
  Available := 15;
  if Player.Character.Base.Inventory[61].Index > 0 then
    Inc(Available, 15);
  if Player.Character.Base.Inventory[62].Index > 0 then
    Inc(Available, 15);
  if Player.Character.Base.Inventory[63].Index > 0 then
    Inc(Available, 15);
  Result := Available - Used;
end;
class function TItemFunctions.GetInvMaxSlot(const Player: TPlayer): Integer;
begin
  Result := 14;
  if Player.Character.Base.Inventory[61].Index > 0 then
    Result := 29;
  if Player.Character.Base.Inventory[62].Index > 0 then
    Result := 44;
  if Player.Character.Base.Inventory[63].Index > 0 then
    Result := 59;
end;
class function TItemFunctions.GetInvPranMaxSlot(const Player: TPlayer): Integer;
begin
  Result := 19;
  case Player.SpawnedPran of
    0:
      begin
        if(Player.Account.Header.Pran1.Inventory[41].Index > 0) then
          Result := 39;
      end;
    1:
      begin
        if(Player.Account.Header.Pran2.Inventory[41].Index > 0) then
          Result := 39;
      end;
  end;
end;
class function TItemFunctions.GetEmptySlot(const Player: TPlayer): BYTE;
var
  i: BYTE;
  MAX_SLOT: BYTE;
begin
  Result := 255;
  MAX_SLOT := GetInvMaxSlot(Player);
  for i := 0 to MAX_SLOT do
  begin
    if Player.Character.Base.Inventory[i].Index <> 0 then
      Continue;
    case i of
      0 .. 14:
        begin
          Result := i;
          Exit;
        end;
      15 .. 29:
        begin
          if (Player.Character.Base.Inventory[61].Index > 0) then
          begin
            Result := i;
            Exit;
          end;
        end;
      30 .. 44:
        begin
          if (Player.Character.Base.Inventory[62].Index > 0) then
          begin
            Result := i;
            Exit;
          end;
        end;
      45 .. 59:
        begin
          if (Player.Character.Base.Inventory[63].Index > 0) then
          begin
            Result := i;
            Exit;
          end;
        end;
    end;
  end;
end;
class function TItemFunctions.GetEmptyPranSlot(const Player: TPlayer): BYTE;
var
  i: BYTE;
  MAX_SLOT: BYTE;
begin
  Result := 255;
  MAX_SLOT := GetInvPranMaxSlot(Player);
  case Player.SpawnedPran of
    0:
      begin
        for i := 0 to MAX_SLOT do
        begin
          if (Player.Account.Header.Pran1.Inventory[i].Index <> 0) then
            Continue;
          case i of
            0..19:
              begin
                Result := i;
                Exit;
              end;
            20..39:
              begin
                if(Player.Account.Header.Pran1.Inventory[41].Index <> 0) then
                begin
                  Result := i;
                  Exit;
                end;
              end;
          end;
        end;
      end;
    1:
      begin
        for i := 0 to MAX_SLOT do
        begin
          if (Player.Account.Header.Pran2.Inventory[i].Index <> 0) then
            Continue;
          case i of
            0..19:
              begin
                Result := i;
                Exit;
              end;
            20..39:
              begin
                if(Player.Account.Header.Pran2.Inventory[41].Index <> 0) then
                begin
                  Result := i;
                  Exit;
                end;
              end;
          end;
        end;
      end;
  end;
end;
class function TItemFunctions.VerifyBagSlot(const Player: TPlayer;
  Slot: Integer): Boolean;
begin
  Result := False;
  case Slot of
    0 .. 14:
      Result := True;
    15 .. 29:
      begin
        if (Player.Character.Base.Inventory[61].Index > 0) then
          Result := True;
      end;
    30 .. 44:
      if (Player.Character.Base.Inventory[62].Index > 0) then
        Result := True;
    45 .. 59:
      if (Player.Character.Base.Inventory[63].Index > 0) then
        Result := True;
  end;
end;
class function TItemFunctions.GetItemSlot(const Player: TPlayer; item: TItem;
  SlotType: BYTE; StartSlot: BYTE = 0): BYTE;
var
  i: Integer;
begin
  case SlotType of
    INV_TYPE:
      begin
        for i := StartSlot to 63 do
        begin
          if Player.Character.Base.Inventory[i].Index <> item.Index then
          begin
            Continue;
          end;
          Result := i;
          Exit;
        end;
      end;
    EQUIP_TYPE:
      begin
        for i := StartSlot to 15 do
        begin
          if Player.Character.Base.Equip[i].Index <> item.Index then
          begin
            Continue;
          end;
          Result := i;
          Exit;
        end;
      end;
    STORAGE_TYPE:
      begin
        for i := StartSlot to 85 do
        begin
          if Player.Account.Header.Storage.Itens[i].Index <> item.Index then
          begin
            Continue;
          end;
          Result := i;
          Exit;
        end;
      end;
  end;
  Result := 255;
end;
class function TItemFunctions.GetItemSlot2(const Player: TPlayer;
  ItemID: WORD): BYTE;
var
  i: BYTE;
begin
  Result := 255;
  for i := 0 to 59 do // inventory
  begin
    if (Player.Character.Base.Inventory[i].Index = ItemID) then
    begin
      Result := i;
      Break;
    end
    else
    begin
      Continue;
    end;
  end;
end;
class function TItemFunctions.GetItemSlotByItemType(const Player: TPlayer;
  ItemType: WORD; SlotType: BYTE; StartSlot: BYTE = 0): BYTE;
var
  i: Integer;
begin
  case SlotType of
    INV_TYPE:
      begin
        for i := StartSlot to 63 do
        begin
          if ItemList[Player.Character.Base.Inventory[i].Index].ItemType <> ItemType
          then
          begin
            Continue;
          end;
          Result := i;
          Exit;
        end;
      end;
    EQUIP_TYPE:
      begin
        for i := StartSlot to 15 do
        begin
          if ItemList[Player.Character.Base.Equip[i].Index].ItemType <> ItemType
          then
          begin
            Continue;
          end;
          Result := i;
          Exit;
        end;
      end;
    STORAGE_TYPE:
      begin
        for i := StartSlot to 85 do
        begin
          if ItemList[Player.Account.Header.Storage.Itens[i].Index].ItemType <> ItemType
          then
          begin
            Continue;
          end;
          Result := i;
          Exit;
        end;
      end;
  end;
  Result := 255;
end;
class function TItemFunctions.GetItemSlotAndAmountByIndex(const Player: TPlayer;
  ItemIndex: WORD; out Slot, Refi: BYTE): Boolean;
var
  i: WORD;
begin
  Result := False;
  for i := 0 to 59 do
  begin
    if (Player.Base.Character.Inventory[i].Index = ItemIndex) then
    begin
      Result := True;
      Slot := i;
      Refi := Player.Base.Character.Inventory[i].Refi;
      Break;
    end
    else
      Continue;
  end;
end;
class function TItemFunctions.GetItemReliquareSlot(const Player: TPlayer): Byte;
var
  i: Byte;
begin
  Result := 255;
  for I := 0 to 59 do
  begin
    if(Player.base.character.inventory[i].Index = 0) then
      Continue;
    if(ItemList[Player.base.character.inventory[i].Index].ItemType = 40) then
    begin
      Result := i;
      break;
    end;
  end;
end;
class function TItemFunctions.GetItemThatExpires(const Player: TPlayer; SlotType: BYTE): Byte;
var
  i: Byte;
  Item: PItem;
begin
  Result := 255;
  case SlotType of
    INV_TYPE:
      begin
        for I := 0 to 59 do
        begin
          Item := @Player.Base.Character.Inventory[i];
          if(item.Index = 0) then
            Continue;
          if(ItemList[item.Index].Expires) then
          begin
            Result := i;
            Break;
          end;
        end;
      end;
    EQUIP_TYPE:
      begin
        for I := 0 to 15 do
        begin
          Item := @Player.Base.Character.Equip[i];
          if(item.Index = 0) then
            Continue;
          if(ItemList[item.Index].Expires) then
          begin
            Result := i;
            Break;
          end;
        end;
      end;
  end;
end;
{$ENDREGION}
{$REGION 'Ramdom Select Functions'}
class function TItemFunctions.SelectRamdomItem(const Items: ARRAY OF WORD;
  const Chances: ARRAY OF WORD): WORD;
var
  RandomTax, cnt: BYTE;
  RamdomArray: ARRAY OF WORD;
  i, j: Integer;
  RamdomSlot: Integer;
begin
  Result := 0;
  try
    Randomize;
    RandomTax := Random(100);
    cnt := 0;
    for i := 0 to Length(Items) - 1 do
    begin
      if (RandomTax <= Chances[i]) then
      begin
        SetLength(RamdomArray, cnt + 1);
        RamdomArray[cnt] := Items[i];
        Inc(cnt);
      end
      else
        Continue;
    end;
    if(Length(RamdomArray) = 0) then
    begin
      Randomize;
      RamdomSlot := RandomRange(0, Length(Items));
      Result := Items[RamdomSlot];
    end
    else
    begin
      Randomize;
      RamdomSlot := RandomRange(0, Length(RamdomArray));
      Result := RamdomArray[RamdomSlot];
    end;
  except
    on E: Exception do
    begin
      Logger.Write('TItemFunctions.SelectRamdomItem ' + E.Message,
        TLogType.Error);
      Logger.Write('TItemFunctions.SelectRamdomItem ' + E.Message,
        TLogType.Warnings);
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Reinforce'}
class function TItemFunctions.GetResultRefineItem(const item: WORD;
  Extract: WORD; Refine: BYTE): BYTE;
var
  //RamdomArray: ARRAY [0 .. 999] OF BYTE;
  RamdomSlot: Integer;
  Chance{, BreakChance, ReduceChance}: WORD;
{  procedure SetChance(const Chance: WORD; const Type1: BYTE);
  var
    i: Integer;
  begin
    if (Chance = 0) then
      Exit;
    for i := 0 to Chance - 1 do
    begin
      RamdomSlot := Random(1000);
      while (RamdomArray[RamdomSlot] <> 3) do
      begin
        RamdomSlot := Random(1000);
      end;
      RamdomArray[RamdomSlot] := Type1;
    end;
  end;  }
begin
  //FillMemory(@RamdomArray, Length(RamdomArray), $3);
  { Pega a chance de refine }
  //Self.GetItemReinforceChance(item, Refine);
  //0 volta -2
  //1 volta -1
  //2 sucesso
  if(Refine <= 0) then
    Chance := ChancesOfRefinament[Refine]
  else
    Chance := ChancesOfRefinament[Refine-1];

  Randomize;
  RamdomSlot := 100;
  RamdomSlot := RandomRange(1, 101);

  if(ItemList[item].Rank > 0) then
    RamdomSlot := RamdomSlot * ItemList[item].Rank;

  if(RamdomSlot <= Chance) then
  begin //deu bom
    Result := 2;
    Exit;
  end
  else
  begin
    case Refine of
      0..3: //de +0 até +3
      begin  //100% de chance, impossivel voltar
        Result := 2;
        Exit;
      end;
      4..5: //de +4 até +6
      begin
        if(Extract = 0) then
        begin
          Result := 1;
          Exit;
        end;
        case ItemList[Extract].ItemType of
          63, 65: //extrato normal
          begin
            Result := 1;
            Exit;
          end;
          64, 66: //extrato enriquecido
          begin
            Result := 3;
            Exit;
          end;
        end;
      end;
      6..12: //de +7 até +11
      begin
         if(Extract = 0) then
        begin
          Result := 0;
          Exit;
        end;
        case ItemList[Extract].ItemType of
          63, 65: //extrato normal
          begin
            Result := 1;
            Exit;
          end;
          64, 66: //extrato enriquecido
          begin
            Result := 3;
            Exit;
          end;
        end;
      end;
    end;
  end;
{$REGION 'Seta as Chances'}
 { BreakChance := Trunc((1000 - Chance) / 3);
  ReduceChance := BreakChance;
  case ItemList[Extract].ItemType of
    63:
      begin
        BreakChance := 0;
      end;
    65:
      begin
        BreakChance := 0;
      end;
    64:
      begin
        BreakChance := 0;
        ReduceChance := 0;
      end;
    66:
      begin
        BreakChance := 0;
        ReduceChance := 0;
      end;
  end;       }
{$ENDREGION}
{$REGION 'Seta as Chances na array'}
{  Randomize;
  SetChance(BreakChance, 0);
  SetChance(ReduceChance, 1);
  SetChance(Chance, 2);
                          }
{$ENDREGION}
  //RamdomSlot := Random(1000);
  //Result := RamdomArray[RamdomSlot];
end;
class function TItemFunctions.GetItemReinforceChance(const item: WORD;
  Refine: BYTE): WORD;
begin
  Result := 0;
  if (ItemList[item].UseEffect <= 0) then
    Exit;
  case Self.GetItemEquipSlot(item) of
    0 .. 5:
      begin
        Result := ReinforceA01[ItemList[item].UseEffect].Chance[Refine];
      end;
    6:
      begin
        Result := ReinforceW01[ItemList[item].UseEffect].Chance[Refine];
      end;
    7:
      begin
        Result := ReinforceA01[ItemList[item].UseEffect].Chance[Refine];
      end;
  else
    begin
      Result := 0;
    end;
  end;
end;
class function TItemFunctions.ReinforceItem(var Player: TPlayer; item: DWORD;
  Item2: DWORD; Item3: DWORD): BYTE;
var
  ItemIndex: Integer;
  HiraKaize: PItem;
  Extract: Integer;
  Refine: Integer;
begin
  Result := 4;
  ItemIndex := Player.Character.Base.Inventory[item].Index;
  HiraKaize := @Player.Character.Base.Inventory[Item2];
  if (Item3 = $FFFFFFFF) then
  begin
    Extract := 0;
  end
  else
  begin
    Extract := Player.Character.Base.Inventory[Item3].Index;
  end;
{$REGION 'Checagens Importantes'}
  if (ItemList[HiraKaize.Index].Rank < ItemList[ItemIndex].Rank) then
  begin
    Exit;
  end;
  if (Extract > 0) and (ItemList[Extract].Rank < ItemList[ItemIndex].Rank) then
  begin
    Exit;
  end;
  if (Self.GetReinforceCust(ItemIndex) > Player.Character.Base.Gold) then
  begin
    Result := 5;
    Exit;
  end;
  if(Player.Character.Base.Inventory[item].Refi >= 175) then
  begin
    Result := 6;
    Exit;
  end;
{$ENDREGION}
  if not(ItemList[ItemIndex].Fortification) then
  begin
    if not(HiraKaize.Refi > 0) then
    begin
      Exit;
    end;
    if (Extract > 0) then
    begin
      if (Player.Base.Character.Inventory[Item3].Refi > 0) then
      begin
        Self.DecreaseAmount(Player, Item3);
      end
      else
      begin
        Exit;
      end;
    end;
    Self.DecreaseAmount(HiraKaize);
    Dec(Player.Base.Character.Gold, Self.GetReinforceCust(ItemIndex));
    Result := Self.GetResultRefineItem(ItemIndex, Extract,
      Trunc(Player.Character.Base.Inventory[item].Refi / $10));
    case Result of
      0:
        begin
          ZeroMemory(@Player.Character.Base.Inventory[item], sizeof(TItem));
          //Dec(Player.Character.Base.Inventory[item].Refi, 32);
        end;
      1:
        begin
          Dec(Player.Character.Base.Inventory[item].Refi, $10);
        end;
      2:
        begin
          Inc(Player.Character.Base.Inventory[item].Refi, $10);
        end;
      3:
      begin
        //Player.SendClientMessage('Refinação falhou. O item não será destruido.');
        Exit;
      end;
    end;
  end
  else
  begin
    Player.SendClientMessage('Esse item não pode ser refinado.');
    Exit;
  end;
  if(Player.Character.Base.Inventory[item].Index = 0) then
  begin
    Player.Base.SendRefreshItemSlot(INV_TYPE, item, Player.Character.Base.Inventory[item],
      False);
  end
  else
  begin
    Refine := Round(Player.Character.Base.Inventory[item].Refi / 16);
    if (Result = 2) and (Refine >= 9) then
    begin
      Servers[Player.ChannelIndex].SendServerMsg
        (AnsiString(string(Player.Character.Base.Name) + ' refinou com sucesso ' +
        string(ItemList[ItemIndex].Name) + ' +' + Refine.ToString), 16, 0, 0,
        False, Player.Base.ClientID);
    end;
  end;
end;
class function TItemFunctions.GetArmorReinforceIndex(const item: WORD): WORD;
  function GetRefineClass(Classe: BYTE): BYTE;
  begin
    Result := 6;
    case Classe of
      01 .. 10:
        Result := 1;
      11 .. 20:
        Result := 0;
      21 .. 30:
        Result := 2;
      31 .. 40:
        Result := 3;
      41 .. 50:
        Result := 4;
      51 .. 60:
        Result := 5;
    end;
  end;
var
  ItemType: WORD;
begin
  Result := 0;
  if not(ItemList[item].ItemType >= 2) and not(ItemList[item].ItemType <= 7)
  then
    Exit;
  ItemType := ItemList[item].ItemType;
  if (ItemType = 7) then
    ItemType := 6;
  Result := ((ItemType - 2) * 30) + ItemList[item].UseEffect;
end;
class function TItemFunctions.GetReinforceCust(const Index: WORD): Cardinal;
begin
  case Self.GetItemEquipSlot(Index) of
    2 .. 5:
      begin
        Result := ReinforceA01[ItemList[Index].UseEffect-1].ReinforceCust;
      end;
    6:
      begin
        Result := ReinforceW01[ItemList[Index].UseEffect-1].ReinforceCust;
      end;
    7:
      begin
        Result := ReinforceA01[ItemList[Index].UseEffect-1].ReinforceCust;
      end;
  else
    begin
      Result := 0;
    end;
  end;
end;
class function TItemFunctions.GetItemReinforce2Index(ItemIndex: WORD): WORD;
var
  ReinforceIndex: WORD;
  ItemUseEffect: WORD;
  ClassInfo: BYTE;
  EquipSlot: BYTE;
begin
  ReinforceIndex := 0;
  ItemUseEffect := ItemList[ItemIndex].UseEffect;
  case ItemUseEffect of
    0 .. 35:
      ReinforceIndex := reinforce2sectionSize * 0;
    36 .. 70:
      begin
        ReinforceIndex := reinforce2sectionSize * 1;
        Dec(ReinforceIndex, 35);
      end;
    71 .. 105:
      begin
        ReinforceIndex := reinforce2sectionSize * 2;
        Dec(ReinforceIndex, 70);
      end;
  end;
  ClassInfo := Self.GetClass(ItemList[ItemIndex].Classe);
  EquipSlot := Self.GetItemEquipSlot(ItemIndex);
  if (EquipSlot = 6) then
  begin
    case ClassInfo of
      0:
        begin
          Inc(ReinforceIndex, WORD(Reinforce2_Area_Sword));
        end;
      1:
        begin
          Inc(ReinforceIndex, WORD(Reinforce2_Area_Blade));
        end;
      2:
        begin
          Inc(ReinforceIndex, WORD(Reinforce2_Area_Rifle));
        end;
      3:
        begin
          Inc(ReinforceIndex, WORD(Reinforce2_Area_Pistol));
        end;
      4:
        begin
          Inc(ReinforceIndex, WORD(Reinforce2_Area_Staff));
        end;
      5:
        begin
          Inc(ReinforceIndex, WORD(Reinforce2_Area_Wand));
        end;
    end;
    Result := (ReinforceIndex + ItemUseEffect);
    Exit;
  end;
  case EquipSlot of
    2:
      begin
        Inc(ReinforceIndex, (WORD(Reinforce2_Area_Helmet) + (ClassInfo * 30)));
      end;
    3:
      begin
        Inc(ReinforceIndex, (WORD(Reinforce2_Area_Armor) + (ClassInfo * 30)));
      end;
    4:
      begin
        Inc(ReinforceIndex, (WORD(Reinforce2_Area_Gloves) + (ClassInfo * 30)));
      end;
    5:
      begin
        Inc(ReinforceIndex, (WORD(Reinforce2_Area_Shoes) + (ClassInfo * 30)));
      end;
    7:
      begin
        Inc(ReinforceIndex, WORD(Reinforce2_Area_Shield));
      end;
  end;
  Result := (ReinforceIndex + ItemUseEffect);
end;
class function TItemFunctions.GetItemReinforce3Index(ItemIndex: WORD): WORD;
var
  ReinforceIndex: WORD;
  ItemUseEffect: WORD;
  EquipSlot: BYTE;
begin
  ReinforceIndex := 0;
  ItemUseEffect := ItemList[ItemIndex].UseEffect;
  case ItemUseEffect of
    0 .. 35:
      ReinforceIndex := reinforce3sectionSize * 0;
    36 .. 70:
      begin
        ReinforceIndex := reinforce3sectionSize * 1;
        Dec(ReinforceIndex, 35);
      end;
    71 .. 105:
      begin
        ReinforceIndex := reinforce3sectionSize * 2;
        Dec(ReinforceIndex, 70);
      end;
  end;
  EquipSlot := Self.GetItemEquipSlot(ItemIndex);
  case (EquipSlot) of
    2:
      Inc(ReinforceIndex, WORD(Reinforce3_Area_Helmet));
    3:
      Inc(ReinforceIndex, WORD(Reinforce3_Area_Armor));
    4:
      Inc(ReinforceIndex, WORD(Reinforce3_Area_Gloves));
    5:
      Inc(ReinforceIndex, WORD(Reinforce3_Area_Shoes));
    7:
      Inc(ReinforceIndex, WORD(Reinforce3_Area_Shield));
  end;
  Result := (ReinforceIndex + ItemUseEffect);
end;
{$ENDREGION}
{$REGION 'Enchant'}
class function TItemFunctions.Enchantable(item: TItem): Boolean;
var
  i: BYTE;
begin
  Result := False;
  for i := 0 to 2 do
  begin
    if (item.Effects.Index[i] = 0) then
    begin
      Result := True;
      Break;
    end
    else
      Continue;
  end;
end;
class function TItemFunctions.GetEmptyEnchant(item: TItem): BYTE;
var
  i: BYTE;
begin
  Result := 255;
  for i := 0 to 2 do
  begin
    if (item.Effects.Index[i] = 0) then
    begin
      Result := i;
      Break;
    end
    else
      Continue;
  end;
end;
class function TItemFunctions.EnchantItem(var Player: TPlayer;
  ItemSlot, Item2: DWORD): BYTE;
var
  EmptyEnchant: BYTE;
  EnchantIndex, EnchantValue: WORD;
  ItemSlotType: Integer;
  R1, RandomEnch, OldRandomEnch: Integer;
  i: Integer;
begin
  Result := 0;
  if (Player.Base.Character.Inventory[ItemSlot].Index = 0) then
    Exit;
  if (Player.Base.Character.Inventory[Item2].Index = 0) then
    Exit;
  if (Self.Enchantable(Player.Base.Character.Inventory[ItemSlot])) then
  begin
    if (ItemList[Player.Base.Character.Inventory[Item2].Index].ItemType = 508)
    then
    begin
      if (ItemList[Player.Base.Character.Inventory[Item2].Index].EF[0] = 0) then
      begin
        ItemSlotType := Self.GetItemEquipSlot(Player.Base.Character.Inventory
          [ItemSlot].Index);
        Randomize;
        RandomEnch := 0;
        case ItemSlotType of
          2 .. 5, 7:
            begin
              case Player.Base.Character.Inventory[Item2].Index of
                5320:
                  begin
                    R1 := RandomRange(0, Length(VaizanP_Set));
                    RandomEnch := VaizanP_Set[R1];
                  end;
                5321:
                  begin
                    R1 := RandomRange(0, Length(VaizanM_Set));
                    RandomEnch := VaizanM_Set[R1];
                  end;
                5322:
                  begin
                    R1 := RandomRange(0, Length(VaizanG_Set));
                    RandomEnch := VaizanG_Set[R1];
                  end;
              end;
            end;
          6:
            begin
              case Player.Base.Character.Inventory[Item2].Index of
                5320:
                  begin
                    R1 := RandomRange(0, Length(VaizanP_Wep));
                    RandomEnch := VaizanP_Wep[R1];
                  end;
                5321:
                  begin
                    R1 := RandomRange(0, Length(VaizanM_Wep));
                    RandomEnch := VaizanM_Wep[R1];
                  end;
                5322:
                  begin
                    R1 := RandomRange(0, Length(VaizanG_Wep));
                    RandomEnch := VaizanG_Wep[R1];
                  end;
              end;
            end;
          11 .. 14:
            begin
              case Player.Base.Character.Inventory[Item2].Index of
                5320:
                  begin
                    R1 := RandomRange(0, Length(VaizanP_Acc));
                    RandomEnch := VaizanP_Acc[R1];
                  end;
                5321:
                  begin
                    R1 := RandomRange(0, Length(VaizanM_Acc));
                    RandomEnch := VaizanM_Acc[R1];
                  end;
                5322:
                  begin
                    R1 := RandomRange(0, Length(VaizanG_Acc));
                    RandomEnch := VaizanG_Acc[R1];
                  end;
              end;
            end;
        end;
        EmptyEnchant := Self.GetEmptyEnchant(Player.Base.Character.Inventory
          [ItemSlot]);
        if (EmptyEnchant = 255) then
        begin
          Result := 1; // SendPlayerError
          Exit;
        end;
        for I := 0 to 2 do
        begin
          if(Player.Character.Base.Inventory[ItemSlot].Effects.Index[i] =
            ItemList[RandomEnch].EF[0]) then
          begin
            OldRandomEnch := RandomEnch;

            case ItemSlotType of
              2 .. 5, 7:
                begin
                  case Player.Base.Character.Inventory[Item2].Index of
                    5320:
                      begin
                        R1 := RandomRange(0, Length(VaizanP_Set));
                        RandomEnch := VaizanP_Set[R1];

                        if(RandomEnch = OldRandomEnch) then
                        begin
                          if(R1 > 0) then
                            RandomEnch := VaizanP_Set[R1-1]
                          else
                            RandomEnch := VaizanP_Set[R1+1];
                        end;
                      end;
                    5321:
                      begin
                        R1 := RandomRange(0, Length(VaizanM_Set));
                        RandomEnch := VaizanM_Set[R1];

                        if(RandomEnch = OldRandomEnch) then
                        begin
                          if(R1 > 0) then
                            RandomEnch := VaizanM_Set[R1-1]
                          else
                            RandomEnch := VaizanM_Set[R1+1];
                        end;
                      end;
                    5322:
                      begin
                        R1 := RandomRange(0, Length(VaizanG_Set));
                        RandomEnch := VaizanG_Set[R1];

                        if(RandomEnch = OldRandomEnch) then
                        begin
                          if(R1 > 0) then
                            RandomEnch := VaizanG_Set[R1-1]
                          else
                            RandomEnch := VaizanG_Set[R1+1];
                        end;
                      end;
                  end;
                end;
              6:
                begin
                  case Player.Base.Character.Inventory[Item2].Index of
                    5320:
                      begin
                        R1 := RandomRange(0, Length(VaizanP_Wep));
                        RandomEnch := VaizanP_Wep[R1];

                        if(RandomEnch = OldRandomEnch) then
                        begin
                          if(R1 > 0) then
                            RandomEnch := VaizanP_Wep[R1-1]
                          else
                            RandomEnch := VaizanP_Wep[R1+1];
                        end;
                      end;
                    5321:
                      begin
                        R1 := RandomRange(0, Length(VaizanM_Wep));
                        RandomEnch := VaizanM_Wep[R1];

                        if(RandomEnch = OldRandomEnch) then
                        begin
                          if(R1 > 0) then
                            RandomEnch := VaizanM_Wep[R1-1]
                          else
                            RandomEnch := VaizanM_Wep[R1+1];
                        end;
                      end;
                    5322:
                      begin
                        R1 := RandomRange(0, Length(VaizanG_Wep));
                        RandomEnch := VaizanG_Wep[R1];

                        if(RandomEnch = OldRandomEnch) then
                        begin
                          if(R1 > 0) then
                            RandomEnch := VaizanG_Wep[R1-1]
                          else
                            RandomEnch := VaizanG_Wep[R1+1];
                        end;
                      end;
                  end;
                end;
              11 .. 14:
                begin
                  case Player.Base.Character.Inventory[Item2].Index of
                    5320:
                      begin
                        R1 := RandomRange(0, Length(VaizanP_Acc));
                        RandomEnch := VaizanP_Acc[R1];

                        if(RandomEnch = OldRandomEnch) then
                        begin
                          if(R1 > 0) then
                            RandomEnch := VaizanP_Acc[R1-1]
                          else
                            RandomEnch := VaizanP_Acc[R1+1];
                        end;
                      end;
                    5321:
                      begin
                        R1 := RandomRange(0, Length(VaizanM_Acc));
                        RandomEnch := VaizanM_Acc[R1];

                        if(RandomEnch = OldRandomEnch) then
                        begin
                          if(R1 > 0) then
                            RandomEnch := VaizanM_Acc[R1-1]
                          else
                            RandomEnch := VaizanM_Acc[R1+1];
                        end;
                      end;
                    5322:
                      begin
                        R1 := RandomRange(0, Length(VaizanG_Acc));
                        RandomEnch := VaizanG_Acc[R1];

                        if(RandomEnch = OldRandomEnch) then
                        begin
                          if(R1 > 0) then
                            RandomEnch := VaizanG_Acc[R1-1]
                          else
                            RandomEnch := VaizanG_Acc[R1+1];
                        end;
                      end;
                  end;
                end;
            end;
            //Result := 4; // SendPlayerMessage
            //Exit;
          end;
        end;
        EnchantIndex := ItemList[RandomEnch].EF[0];
        EnchantValue := ItemList[RandomEnch].EFV[0];
        Player.Character.Base.Inventory[ItemSlot].Effects.Index[EmptyEnchant] :=
          EnchantIndex;
        Player.Character.Base.Inventory[ItemSlot].Effects.Value[EmptyEnchant] :=
          (EnchantValue);
        Self.DecreaseAmount(@Player.Character.Base.Inventory[Item2]);
      end
      else
      begin
        EmptyEnchant := Self.GetEmptyEnchant(Player.Base.Character.Inventory
          [ItemSlot]);
        if (EmptyEnchant = 255) then
        begin
          Result := 1; // SendPlayerError
          Exit;
        end;
        for I := 0 to 2 do
        begin
          if(Player.Character.Base.Inventory[ItemSlot].Effects.Index[i] =
            ItemList[Player.Base.Character.Inventory[Item2].
          Index].EF[0]) then
          begin
            if not(ItemList[Player.Base.Character.Inventory[Item2].
              Index].ItemType = 33) then //pular se for estrela da pran
            begin
              Result := 3; // SendPlayerMessage
              Exit;
            end;
          end;
        end;
        EnchantIndex := ItemList[Player.Base.Character.Inventory[Item2].
          Index].EF[0];
        EnchantValue := ItemList[Player.Base.Character.Inventory[Item2].
          Index].EFV[0];
        Player.Character.Base.Inventory[ItemSlot].Effects.Index[EmptyEnchant] :=
          EnchantIndex;
        Player.Character.Base.Inventory[ItemSlot].Effects.Value[EmptyEnchant] :=
          EnchantValue;
        Self.DecreaseAmount(@Player.Character.Base.Inventory[Item2]);
      end;
      Result := 2;
      Exit;
    end;
    EmptyEnchant := Self.GetEmptyEnchant(Player.Base.Character.Inventory
      [ItemSlot]);
    if (EmptyEnchant = 255) then
    begin
      Result := 1; // SendPlayerError
      Exit;
    end;
    for I := 0 to 2 do
    begin
      if(Player.Character.Base.Inventory[ItemSlot].Effects.Index[i] =
        ItemList[Player.Base.Character.Inventory[Item2].
      Index].EF[0]) then
      begin
        if not(ItemList[Player.Base.Character.Inventory[Item2].
          Index].ItemType = 33) then //pular se for estrela da pran
        begin
          Result := 3; // SendPlayerMessage
          Exit;
        end;
      end;
    end;
    EnchantIndex := ItemList[Player.Base.Character.Inventory[Item2].
      Index].EF[0];
    EnchantValue := ItemList[Player.Base.Character.Inventory[Item2].
      Index].EFV[0];
    Player.Character.Base.Inventory[ItemSlot].Effects.Index[EmptyEnchant] :=
      EnchantIndex;
    Player.Character.Base.Inventory[ItemSlot].Effects.Value[EmptyEnchant] :=
      EnchantValue;
    Self.DecreaseAmount(@Player.Character.Base.Inventory[Item2]);
  end;
  Result := 2;
end;
{$ENDREGION}
{$REGION 'Change APP'}
class function TItemFunctions.Changeable(item: TItem): Boolean;
begin
  Result := False;
  if (item.APP = 0) or (item.Index = item.APP) then
  begin
    Result := True;
  end;
end;
class function TItemFunctions.ChangeApp(var Player: TPlayer;
  item, Athlon, NewApp: DWORD): BYTE;
var
  MItem, MAthlon, MNewApp: TItem;
begin
  Result := 0;
  MItem := Player.Character.Base.Inventory[item];
  MAthlon := Player.Character.Base.Inventory[Athlon];
  MNewApp := Player.Character.Base.Inventory[NewApp];
  if (MItem.Index = 0) then
    Exit;
  if (MAthlon.Index = 0) then
    Exit;
  if (MNewApp.Index = 0) then
    Exit;
  if not(Player.Base.GetMobClass(ItemList[MNewApp.Index].Classe)
    = Player.Base.GetMobClass(ItemList[MItem.Index].Classe)) then
  begin
    Result := 1;
    Exit;
  end;
  if (ItemList[MItem.Index].CanAgroup) then
  begin
    Result := 1;
    Exit;
  end;
  if (ItemList[MNewApp.Index].CanAgroup) then
  begin
    Result := 1;
    Exit;
  end;
  if (Self.Changeable(MItem)) then
  begin
    Player.Character.Base.Inventory[item].APP := Player.Character.Base.Inventory
      [NewApp].Index;
    ZeroMemory(@Player.Character.Base.Inventory[NewApp], sizeof(TItem));
    Self.DecreaseAmount(@Player.Character.Base.Inventory
      [Self.GetItemSlot2(Player, MAthlon.Index)]);
    Player.Base.SendRefreshItemSlot(Self.GetItemSlot2(Player,
      MAthlon.Index), False);
    Result := 2;
  end;
end;
{$ENDREGION}
{$REGION 'Enchant Mount'}
class function TItemFunctions.EnchantMount(var Player: TPlayer;
  ItemSlot, Item2: DWORD): BYTE;
type
  TSpecialRefi = record
    hi, lo: BYTE;
  end;
var
  EmptyEnchant: BYTE;
  EnchantIndex, EnchantValue: WORD;
begin
  Result := 0;
  if (Player.Base.Character.Inventory[ItemSlot].Index = 0) then
    Exit;
  if (Player.Base.Character.Inventory[Item2].Index = 0) then
    Exit;
  if (ItemList[Player.Base.Character.Inventory[Item2].Index].ItemType <> 518)
  then
  begin
    Exit;
  end;
  if (Self.Enchantable(Player.Base.Character.Inventory[ItemSlot])) then
  begin
    EmptyEnchant := Self.GetEmptyEnchant(Player.Base.Character.Inventory
      [ItemSlot]);
    if (EmptyEnchant = 255) then
    begin
      Result := 1; // SendPlayerError
      Exit;
    end;
    EnchantIndex := ItemList[Player.Base.Character.Inventory[Item2].
      Index].EF[0];
    EnchantValue := ItemList[Player.Base.Character.Inventory[Item2].
      Index].EFV[0];
    { case EmptyEnchant of
      0:
      begin
      Player.Character.Base.Inventory[ItemSlot].Effects.Index[0] :=
      EnchantIndex;
      Player.Character.Base.Inventory[ItemSlot].MIN :=
      EnchantValue;
      end;
      1:
      begin
      Player.Character.Base.Inventory[ItemSlot].Effects.Index[2] :=
      EnchantIndex;
      Player.Character.Base.Inventory[ItemSlot].MAX :=
      EnchantValue;
      end;
      2:
      begin
      Refi1.lo := EnchantValue;
      Player.Character.Base.Inventory[ItemSlot].Effects.Value[1] :=
      EnchantIndex;
      Move(Refi1, Player.Character.Base.Inventory[ItemSlot].Refi, 2);
      end;
      end; }
    Player.Character.Base.Inventory[ItemSlot].Effects.Index[EmptyEnchant] :=
      EnchantIndex;
    Player.Character.Base.Inventory[ItemSlot].Effects.Value[EmptyEnchant] :=
      EnchantValue;
    Self.DecreaseAmount(@Player.Character.Base.Inventory[Item2]);
  end
  else
  begin
    Result := 1;
    Exit;
  end;
  Result := 2;
end;
{$ENDREGION}
{$REGION 'Premium Inventory Function'}
class function TItemFunctions.FindPremiumIndex(Index: WORD): WORD;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Length(PremiumItems) - 1 do
  begin
    if (PremiumItems[i].Index = Index) then
    begin
      Result := i;
      Break;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Use Item'}
class function TItemFunctions.UsePremiumItem(var Player: TPlayer;
  Slot: Integer): Boolean;
var
  item: TItem;
  Premium: PItemCash;
begin
  if (Self.GetInvAvailableSlots(Player) = 0) then
  begin
    Player.SendClientMessage('Inventário cheio.');
    Exit;
  end;
  Premium := @Player.Account.Header.CashInventory.Items[Slot];
  ZeroMemory(@item, sizeof(TItem));
  item.Index := PremiumItems[Premium.Index].ItemIndex;
  Self.SetItemAmount(item, PremiumItems[Premium.Index].Amount);
  if (ItemList[item.Index].Expires) then
  begin
    Self.SetItemAmount(item, 0);
  end;
  Self.PutItem(Player, item, 0, True);
  ZeroMemory(@item, sizeof(TItem));
  ZeroMemory(Premium, sizeof(TItemCash));
  Player.Base.SendRefreshItemSlot(CASH_TYPE, Slot, item, False);
  Result := (Premium.Index = 0);
end;
class function TItemFunctions.UseItem(var Player: TPlayer; Slot: Integer;
  Type1: DWORD): Boolean;
var
  item, SecondItem: PItem;
  i: Integer;
  BagSlot: Integer;
  Decrease: Cardinal;
  RecipeIndex, RandomTax, EmptySlot: WORD;
  ItemSlot, ItemAmount: BYTE;
  ItemExists, HaveAmount: Boolean;
  Level, ReliqSlot: WORD;
  LevelExp: UInt64;
  AddExp: UInt64;
  Rand: Integer;
  PosX: TPosition;
  // Personalities: Array [0 .. 5] of Integer;
  // p: Integer;
begin
  item := @Player.Character.Base.Inventory[Slot];

  Result := False;

  Decrease := 1;

  if Player.Character.Base.Level < ItemList[item.Index].Level then
    Exit;

  case ItemList[item.Index].ItemType of
{$REGION 'Gold e Cash'}
    ITEM_TYPE_USE_GOLD_COIN:
      begin
        Player.AddGold((ItemList[item.Index].SellPrince));

        Player.SendClientMessage('Você recebeu o valor de [' +
          ItemList[item.Index].SellPrince.ToString() + '] em gold.');
      end;

      ITEM_TYPE_USE_CASH_COIN:
      begin
        Player.AddCash((ItemList[item.Index].UseEffect));

        Player.SendClientMessage('Você recebeu o valor de [' +
          ItemList[item.Index].UseEffect.ToString() + '] em cash.');
      end;

      ITEM_TYPE_USE_RICH_GOLD_COIN:
      begin
        Player.AddGold(950000000);

        Player.SendClientMessage('Você recebeu o valor de [950.000.00] em gold.');
      end;
{$ENDREGION}
{$REGION 'Baús e Caixas'}
    ITEM_TYPE_BAU:
      begin
        case ItemList[item.Index].UseEffect of
{$REGION 'Caixa do Elter Aposentado'}
          1133: //caixa que vem raro 50 evento full +9
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 2822, 48);
                    Self.PutEquipament(Player, 2852, 48);
                    Self.PutEquipament(Player, 2882, 48);
                    Self.PutEquipament(Player, 2912, 48);
                    Self.PutEquipament(Player, 6724, 48);
                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 2792, 48);
                    Self.PutEquipament(Player, 2942, 48);
                    Self.PutEquipament(Player, 2972, 48);
                    Self.PutEquipament(Player, 3002, 48);
                    Self.PutEquipament(Player, 3032, 48);
                    Self.PutEquipament(Player, 6689, 48);
                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 3062, 48);
                    Self.PutEquipament(Player, 3092, 48);
                    Self.PutEquipament(Player, 3122, 48);
                    Self.PutEquipament(Player, 3152, 48);
                    Self.PutEquipament(Player, 6864, 48);
                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 3182, 48);
                    Self.PutEquipament(Player, 3212, 48);
                    Self.PutEquipament(Player, 3242, 48);
                    Self.PutEquipament(Player, 3272, 48);
                    Self.PutEquipament(Player, 6829, 48);
                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 3302, 48);
                    Self.PutEquipament(Player, 3332, 48);
                    Self.PutEquipament(Player, 3362, 48);
                    Self.PutEquipament(Player, 3392, 48);
                    Self.PutEquipament(Player, 6934, 48);
                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 3422, 48);
                    Self.PutEquipament(Player, 3452, 48);
                    Self.PutEquipament(Player, 3482, 48);
                    Self.PutEquipament(Player, 3512, 48);
                    Self.PutEquipament(Player, 6899, 48);
                  end;
              end;
            end;
{$ENDREGION}
{$REGION 'Caixa dos Fundadores'}
          1134: //caixa dos fundadores 01
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              Self.PutItem(Player, 13562, 1);	//XP
			        Self.PutItem(Player, 8013, 1);	//Bag
              Self.PutItem(Player, 8029, 1);	//Pran
			        Self.PutItem(Player, 8106, 100);	//ComidaPran
              Self.PutItem(Player, 4359, 150);	//Lagrima
              Player.AddTitle(80, 1);
            end;

          1135: //caixa dos fundadores 02
            begin
              if (Self.GetInvAvailableSlots(Player) < 8) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              //titulo
              Self.PutItem(Player, 8012, 1);	//XP
              Self.PutItem(Player, 7903, 1);	//Bag
              Self.PutItem(Player, 7909, 1);	//Pran
              self.PutItem(player, 8106, 200);	//ComidaPran
              self.PutItem(player, 4359, 350);	//4359

              Player.AddCash(10000);
              Player.SendCashInventory;
              Player.AddTitle(81, 1);
            end;

          1136: //caixa dos fundadores 03
            begin
               if (Self.GetInvAvailableSlots(Player) < 8) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              //titulo
              Self.PutItem(Player, 8065, 1); //xp 30 dias
              Self.PutItem(Player, 7904, 1);
              Self.PutItem(Player, 7910, 1);
              self.PutItem(player, 8106, 500);
              self.PutItem(player, 4359, 750);
              self.PutItem(player, 8087, 1);
              self.PutItem(player, 14143, 1);
              self.PutItem(player, 14144, 1);

              Player.AddCash(30000);
              Player.SendCashInventory;
              Player.AddTitle(82, 1);
            end;

          1137: //caixa dos fundadores 04
            begin
              if (Self.GetInvAvailableSlots(Player) < 8) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              //titulo
              Self.PutItem(Player, 8065, 1); //xp 30 dias
              Self.PutItem(Player, 8031, 1);
              Self.PutItem(Player, 8032, 1);
              Self.PutItem(Player, 8106, 1000);
              Self.PutItem(Player, 4359, 1000);
              self.PutItem(Player, 8250, 1);
              self.PutItem(player, 8088, 1);
              self.PutItem(player, 14145, 1);


              Player.AddCash(60000);
              Player.SendCashInventory;
              Player.AddTitle(83, 1);
            end;
{$ENDREGION}
{$REGION 'caixa dos carrascos fundadores'}

            1138: //caixa que vem raro 50 evento full +4
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 2579, 64);
                    Self.PutEquipament(Player, 2834, 64);
                    Self.PutEquipament(Player, 2864, 64);
                    Self.PutEquipament(Player, 2894, 64);
                    Self.PutEquipament(Player, 2924, 64);
                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 2544, 64);
                    Self.PutEquipament(Player, 2954, 64);
                    Self.PutEquipament(Player, 2984, 64);
                    Self.PutEquipament(Player, 3014, 64);
                    Self.PutEquipament(Player, 3044, 64);
                    Self.PutEquipament(Player, 2804, 64);
                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 2719, 64);
                    Self.PutEquipament(Player, 3074, 64);
                    Self.PutEquipament(Player, 3104, 64);
                    Self.PutEquipament(Player, 3134, 64);
                    Self.PutEquipament(Player, 3164, 64);
                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 2684, 64);
                    Self.PutEquipament(Player, 3194, 64);
                    Self.PutEquipament(Player, 3224, 64);
                    Self.PutEquipament(Player, 3254, 64);
                    Self.PutEquipament(Player, 3284, 64);
                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 2789, 64);
                    Self.PutEquipament(Player, 3314, 64);
                    Self.PutEquipament(Player, 3344, 64);
                    Self.PutEquipament(Player, 3374, 64);
                    Self.PutEquipament(Player, 3404, 64);
                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 2754, 64);
                    Self.PutEquipament(Player, 3434, 64);
                    Self.PutEquipament(Player, 3464, 64);
                    Self.PutEquipament(Player, 3494, 64);
                    Self.PutEquipament(Player, 3524, 64);
                  end;
              end;
            end;

            1139: //caixa que vem raro 50 evento full +6
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 2579, 64);
                    Self.PutEquipament(Player, 2834, 64);
                    Self.PutEquipament(Player, 2864, 64);
                    Self.PutEquipament(Player, 2894, 64);
                    Self.PutEquipament(Player, 2924, 64);
                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 2544, 64);
                    Self.PutEquipament(Player, 2954, 64);
                    Self.PutEquipament(Player, 2984, 64);
                    Self.PutEquipament(Player, 3014, 64);
                    Self.PutEquipament(Player, 3044, 64);
                    Self.PutEquipament(Player, 2804, 64);
                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 2719, 64);
                    Self.PutEquipament(Player, 3074, 64);
                    Self.PutEquipament(Player, 3104, 64);
                    Self.PutEquipament(Player, 3134, 64);
                    Self.PutEquipament(Player, 3164, 64);
                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 2684, 64);
                    Self.PutEquipament(Player, 3194, 64);
                    Self.PutEquipament(Player, 3224, 64);
                    Self.PutEquipament(Player, 3254, 64);
                    Self.PutEquipament(Player, 3284, 64);
                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 2789, 64);
                    Self.PutEquipament(Player, 3314, 64);
                    Self.PutEquipament(Player, 3344, 64);
                    Self.PutEquipament(Player, 3374, 64);
                    Self.PutEquipament(Player, 3404, 64);
                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 2754, 64);
                    Self.PutEquipament(Player, 3434, 64);
                    Self.PutEquipament(Player, 3464, 64);
                    Self.PutEquipament(Player, 3494, 64);
                    Self.PutEquipament(Player, 3524, 64);
                  end;
              end;
            end;

            1140: //caixa que vem raro 50 evento full +6
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 2579, 128);
                    Self.PutEquipament(Player, 2834, 128);
                    Self.PutEquipament(Player, 2864, 128);
                    Self.PutEquipament(Player, 2894, 128);
                    Self.PutEquipament(Player, 2924, 128);
                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 2544, 128);
                    Self.PutEquipament(Player, 2954, 128);
                    Self.PutEquipament(Player, 2984, 128);
                    Self.PutEquipament(Player, 3014, 128);
                    Self.PutEquipament(Player, 3044, 128);
                    Self.PutEquipament(Player, 2804, 128);
                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 2719, 128);
                    Self.PutEquipament(Player, 3074, 128);
                    Self.PutEquipament(Player, 3104, 128);
                    Self.PutEquipament(Player, 3134, 128);
                    Self.PutEquipament(Player, 3164, 128);
                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 2684, 128);
                    Self.PutEquipament(Player, 3194, 128);
                    Self.PutEquipament(Player, 3224, 128);
                    Self.PutEquipament(Player, 3254, 128);
                    Self.PutEquipament(Player, 3284, 128);
                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 2789, 128);
                    Self.PutEquipament(Player, 3314, 128);
                    Self.PutEquipament(Player, 3344, 128);
                    Self.PutEquipament(Player, 3374, 128);
                    Self.PutEquipament(Player, 3404, 128);
                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 2754, 128);
                    Self.PutEquipament(Player, 3434, 128);
                    Self.PutEquipament(Player, 3464, 128);
                    Self.PutEquipament(Player, 3494, 128);
                    Self.PutEquipament(Player, 3524, 128);
                  end;
              end;
            end;

            1141: //caixa que vem raro 50 evento full +9
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 2579, 128);
                    Self.PutEquipament(Player, 2834, 128);
                    Self.PutEquipament(Player, 2864, 128);
                    Self.PutEquipament(Player, 2894, 128);
                    Self.PutEquipament(Player, 2924, 128);
                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 2544, 128);
                    Self.PutEquipament(Player, 2954, 128);
                    Self.PutEquipament(Player, 2984, 128);
                    Self.PutEquipament(Player, 3014, 128);
                    Self.PutEquipament(Player, 3044, 128);
                    Self.PutEquipament(Player, 2804, 128);
                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 2719, 128);
                    Self.PutEquipament(Player, 3074, 128);
                    Self.PutEquipament(Player, 3104, 128);
                    Self.PutEquipament(Player, 3134, 128);
                    Self.PutEquipament(Player, 3164, 128);
                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 2684, 128);
                    Self.PutEquipament(Player, 3194, 128);
                    Self.PutEquipament(Player, 3224, 128);
                    Self.PutEquipament(Player, 3254, 128);
                    Self.PutEquipament(Player, 3284, 128);
                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 2789, 128);
                    Self.PutEquipament(Player, 3314, 128);
                    Self.PutEquipament(Player, 3344, 128);
                    Self.PutEquipament(Player, 3374, 128);
                    Self.PutEquipament(Player, 3404, 128);
                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 2754, 128);
                    Self.PutEquipament(Player, 3434, 128);
                    Self.PutEquipament(Player, 3464, 128);
                    Self.PutEquipament(Player, 3494, 128);
                    Self.PutEquipament(Player, 3524, 128);
                  end;
              end;
            end;

            1142: //caixa que vem conjunto primeiro ano comemorativo
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutEquipament(Player, 13216, 1);
              Self.PutEquipament(Player, 13217, 1);
              Self.PutEquipament(Player, 13218, 1);
              Self.PutEquipament(Player, 13219, 1);
            end;

            1143: //caixa que vem app azul academia
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 12074, 1);
                    Self.PutEquipament(Player, 12380, 1);
                    Self.PutEquipament(Player, 12410, 1);
                    Self.PutEquipament(Player, 12440, 1);
                    Self.PutEquipament(Player, 12470, 1);
                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12109, 1);
                    Self.PutEquipament(Player, 12350, 1);
                    Self.PutEquipament(Player, 12500, 1);
                    Self.PutEquipament(Player, 12530, 1);
                    Self.PutEquipament(Player, 12560, 1);
                    Self.PutEquipament(Player, 12590, 1);
                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 12214, 1);
                    Self.PutEquipament(Player, 12620, 1);
                    Self.PutEquipament(Player, 12650, 1);
                    Self.PutEquipament(Player, 12680, 1);
                    Self.PutEquipament(Player, 12710, 1);
                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 12249, 1);
                    Self.PutEquipament(Player, 12740, 1);
                    Self.PutEquipament(Player, 12770, 1);
                    Self.PutEquipament(Player, 12800, 1);
                    Self.PutEquipament(Player, 12830, 1);
                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 12284, 1);
                    Self.PutEquipament(Player, 12860, 1);
                    Self.PutEquipament(Player, 12890, 1);
                    Self.PutEquipament(Player, 12920, 1);
                    Self.PutEquipament(Player, 12950, 1);
                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 12319, 1);
                    Self.PutEquipament(Player, 12980, 1);
                    Self.PutEquipament(Player, 13010, 1);
                    Self.PutEquipament(Player, 13040, 1);
                    Self.PutEquipament(Player, 13070, 1);
                  end;
              end;
            end;

            1144: //caixa que vem app vermelha academia
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 12075, 1);
                    Self.PutEquipament(Player, 12381, 1);
                    Self.PutEquipament(Player, 12411, 1);
                    Self.PutEquipament(Player, 12441, 1);
                    Self.PutEquipament(Player, 12471, 1);
                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 12110, 1);
                    Self.PutEquipament(Player, 12351, 1);
                    Self.PutEquipament(Player, 12501, 1);
                    Self.PutEquipament(Player, 12531, 1);
                    Self.PutEquipament(Player, 12561, 1);
                    Self.PutEquipament(Player, 12591, 1);
                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 12215, 1);
                    Self.PutEquipament(Player, 12621, 1);
                    Self.PutEquipament(Player, 12651, 1);
                    Self.PutEquipament(Player, 12681, 1);
                    Self.PutEquipament(Player, 12711, 1);
                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 12250, 1);
                    Self.PutEquipament(Player, 12741, 1);
                    Self.PutEquipament(Player, 12771, 1);
                    Self.PutEquipament(Player, 12801, 1);
                    Self.PutEquipament(Player, 12831, 1);
                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 12285, 1);
                    Self.PutEquipament(Player, 12861, 1);
                    Self.PutEquipament(Player, 12891, 1);
                    Self.PutEquipament(Player, 12921, 1);
                    Self.PutEquipament(Player, 12951, 1);
                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 12320, 1);
                    Self.PutEquipament(Player, 12981, 1);
                    Self.PutEquipament(Player, 13011, 1);
                    Self.PutEquipament(Player, 13041, 1);
                    Self.PutEquipament(Player, 13071, 1);
                  end;
              end;
            end;

            1145: //caixa que vem app conquistador
            begin
              if (Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case Player.Base.GetMobClass of
                0:
                  begin
                    Self.PutEquipament(Player, 1687, 1);
                    Self.PutEquipament(Player, 1717, 1);
                    Self.PutEquipament(Player, 1747, 1);
                    Self.PutEquipament(Player, 1777, 1);
                    Self.PutEquipament(Player, 1063, 1);
                  end;

                1:
                  begin
                    if (Self.GetInvAvailableSlots(Player) < 6) then
                    begin  //tp tem o escudo a mais
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 1807, 1);
                    Self.PutEquipament(Player, 1837, 1);
                    Self.PutEquipament(Player, 1867, 1);
                    Self.PutEquipament(Player, 1897, 1);
                    Self.PutEquipament(Player, 1028, 1);
                    Self.PutEquipament(Player, 1301, 1);
                  end;

                2:
                  begin
                    Self.PutEquipament(Player, 1927, 1);
                    Self.PutEquipament(Player, 1957, 1);
                    Self.PutEquipament(Player, 1987, 1);
                    Self.PutEquipament(Player, 2017, 1);
                    Self.PutEquipament(Player, 1203, 1);
                  end;

                3:
                  begin
                    Self.PutEquipament(Player, 2047, 1);
                    Self.PutEquipament(Player, 2077, 1);
                    Self.PutEquipament(Player, 2107, 1);
                    Self.PutEquipament(Player, 2137, 1);
                    Self.PutEquipament(Player, 1168, 1);
                  end;

                4:
                  begin
                    Self.PutEquipament(Player, 2167, 1);
                    Self.PutEquipament(Player, 2197, 1);
                    Self.PutEquipament(Player, 2227, 1);
                    Self.PutEquipament(Player, 2257, 1);
                    Self.PutEquipament(Player, 1273, 1);
                  end;

                5:
                  begin
                    Self.PutEquipament(Player, 2287, 1);
                    Self.PutEquipament(Player, 2317, 1);
                    Self.PutEquipament(Player, 2347, 1);
                    Self.PutEquipament(Player, 2377, 1);
                    Self.PutEquipament(Player, 1238, 1);
                  end;
              end;
            end;
{$ENDREGION}
{$REGION 'Caixa de Presente para Novatos'}
          1:
            begin
              case Player.Base.GetMobClass of
                0: // set war
                  begin
                    if Self.GetInvAvailableSlots(Player) < 5 then
                    begin
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 6727, 1);

                    Self.PutEquipament(Player, 6997, 1);
                    Self.PutEquipament(Player, 7027, 1);
                    Self.PutEquipament(Player, 7057, 1);
                    Self.PutEquipament(Player, 7087, 1);
                  end;

                1: // set tp
                  begin
                    if Self.GetInvAvailableSlots(Player) < 6 then
                    begin
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 6692, 1);
                    Self.PutEquipament(Player, 1304, 1);

                    Self.PutEquipament(Player, 7117, 1);
                    Self.PutEquipament(Player, 7147, 1);
                    Self.PutEquipament(Player, 7177, 1);
                    Self.PutEquipament(Player, 7207, 1);
                  end;

                2: // set att
                  begin
                    if Self.GetInvAvailableSlots(Player) < 5 then
                    begin
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 6867, 112);

                    Self.PutEquipament(Player, 7237, 112);
                    Self.PutEquipament(Player, 7267, 112);
                    Self.PutEquipament(Player, 7297, 112);
                    Self.PutEquipament(Player, 7327, 112);
                  end;

                3: // set dual
                  begin
                    if Self.GetInvAvailableSlots(Player) < 5 then
                    begin
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 6832, 112);

                    Self.PutEquipament(Player, 7357, 112);
                    Self.PutEquipament(Player, 7387, 112);
                    Self.PutEquipament(Player, 7417, 112);
                    Self.PutEquipament(Player, 7447, 112);
                  end;

                4: // set fc
                  begin
                    if Self.GetInvAvailableSlots(Player) < 5 then
                    begin
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 6937, 112);

                    Self.PutEquipament(Player, 7477, 112);
                    Self.PutEquipament(Player, 7507, 112);
                    Self.PutEquipament(Player, 7537, 112);
                    Self.PutEquipament(Player, 7567, 112);
                  end;

                5: // set cl
                  begin
                    if Self.GetInvAvailableSlots(Player) < 5 then
                    begin
                      Player.SendClientMessage('Inventário cheio.');
                      Exit;
                    end;

                    Self.PutEquipament(Player, 6902, 112);

                    Self.PutEquipament(Player, 7597, 112);
                    Self.PutEquipament(Player, 7627, 112);
                    Self.PutEquipament(Player, 7657, 112);
                    Self.PutEquipament(Player, 7687, 112);
                  end;
              end;
            end;

{$ENDREGION}
{$REGION 'Caixa de batalha do comandante'}
          357: // caixa do T diário 10467
            begin
              if Self.GetInvAvailableSlots(Player) < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 4520, 5);
              Self.PutItem(Player, 4521, 5);
              Self.PutItem(Player, 8200, 5);
              Self.PutItem(Player, 4358, 10);
              Self.PutItem(Player, 4398, 10);
            end;
{$ENDREGION}
{$REGION 'Baús da Jornada Elter'}
{$REGION 'Baú da Jornada Elter [Início]'}
          666:
            begin
              if Self.GetInvAvailableSlots(Player) < 3 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              Self.PutItem(Player, 8025);
              Self.PutItem(Player, 1611);
              Self.PutItem(Player, 10045);

            end;
{$ENDREGION}
{$REGION 'Baú da Jornada Elter [Nv10]'}
          667:
            begin
              if Self.GetInvAvailableSlots(Player) < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 8027, 1);
              Self.PutItem(Player, 1612, 1);
              Self.PutItem(Player, 4514, 50);
              Self.PutItem(Player, 8189, 50);
              Self.PutItem(Player, 4438, 1);
              Self.PutItem(Player, 10046, 1);
            end;
{$ENDREGION}
{$REGION 'Baú da Jornada Elter [Nv20]'}
          668:
            begin
              if Self.GetInvAvailableSlots(Player) < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 13528, 1);
              Self.PutItem(Player, 1614, 1);
              Self.PutItem(Player, 4514, 50);
              Self.PutItem(Player, 8189, 50);
              Self.PutItem(Player, 10047, 1);
            end;
{$ENDREGION}
{$REGION 'Baú da Jornada Elter [Nv30]'}
          669:
            begin
              if Self.GetInvAvailableSlots(Player) < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 7930, 1);
              Self.PutItem(Player, 1613, 1);
              Self.PutItem(Player, 4514, 50);
              Self.PutItem(Player, 8212, 20);
              Self.PutItem(Player, 10048, 1);
            end;
{$ENDREGION}
{$REGION 'Baú da Jornada Elter [Nv40]'}
          670:
            begin
              if Self.GetInvAvailableSlots(Player) < 4 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 7927, 1);
              Self.PutItem(Player, 4514, 50);
              Self.PutItem(Player, 8212, 20);
              Self.PutItem(Player, 10049, 1);
            end;
{$ENDREGION}
{$REGION 'Baú da Jornada Elter [Nv50]'}
          671:
            begin
              if Self.GetInvAvailableSlots(Player) < 9 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 8199, 100);
              Self.PutItem(Player, 8253, 100);
              Self.PutItem(Player, 8185, 4);	//Extrato Hira - D
              Self.PutItem(Player, 8187, 4);	//Extrato Kaize - D
              Self.PutItem(Player, 8206, 2);	//Enriquecido Hira - D
              Self.PutItem(Player, 8209, 2);	//Enriquecido Kaize -D
              Self.PutItem(Player, 4483, 1);
              Self.PutItem(Player, 4487, 1);

            end;
{$ENDREGION}
{$REGION 'Baú da Jornada Elter [Nv60]'}
          672:
            begin
              if Self.GetInvAvailableSlots(Player) < 11 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 4480, 1);
              Self.PutItem(Player, 4481, 1);
              Self.PutItem(Player, 8252, 100);
              Self.PutItem(Player, 8254, 100);
              Self.PutItem(Player, 8204, 4);
              Self.PutItem(Player, 8205, 4);
              Self.PutItem(Player, 8208, 2);
              Self.PutItem(Player, 8211, 2);
              Self.PutItem(Player, 4373, 1000);
              Self.PutItem(Player, 4405, 1000);
              Self.PutItem(Player, 10051, 1);

            end;
{$ENDREGION}
{$REGION 'Baú da Jornada Elter [Nv70]'}
          673:
            begin
              if Self.GetInvAvailableSlots(Player) < 11 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 4480, 1);
              Self.PutItem(Player, 4481, 1);
              Self.PutItem(Player, 8259, 100);
              Self.PutItem(Player, 8260, 100);
              Self.PutItem(Player, 8222, 4);
              Self.PutItem(Player, 8171, 4);
              Self.PutItem(Player, 8229, 2);
              Self.PutItem(Player, 8243, 2);
              Self.PutItem(Player, 4376, 1000);
              Self.PutItem(Player, 4407, 1000);
              Self.PutItem(Player, 8858, 1);
            end;
{$ENDREGION}
{$ENDREGION}
{$REGION 'Líquidos'}
{$REGION 'Extrato de Líquido Facion [3 D] – Selado'}
          295:
            begin
              if Self.GetInvAvailableSlots(Player) < 1 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 8007)
            end;
{$ENDREGION}
{$REGION 'Extrato de Líquido Facion [30 D] – Selado'}
          288:
            begin
              if Self.GetInvAvailableSlots(Player) < 1 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 8009);
            end;
{$ENDREGION}
{$ENDREGION}
{$REGION 'Kit Essência do poder'}
          1600:
            begin
              if Self.GetInvAvailableSlots(Player) < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 10433);
              Self.PutItem(Player, 4271);
              Self.PutItem(Player, 11451);
              Self.PutItem(Player, 4480);
              Self.PutItem(Player, 4481);
            end;
{$ENDREGION}
{$REGION 'Caixas dos Pioneiros'}
{$REGION 'Caixa do Guerreiro Pioneiro'}
          137:
            begin
              if Self.GetInvAvailableSlots(Player) < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (2846) + i * 30, $50);
              end;

              Self.PutEquipament(Player, 2561, $50);
            end;
{$ENDREGION}
{$REGION 'Caixa da Templária Pioneira'}
          138:
            begin
              if Self.GetInvAvailableSlots(Player) < 6 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (2966) + i * 30, 5);
              end;

              Self.PutEquipament(Player, 2526, $50);
              Self.PutEquipament(Player, 2816, $50);
            end;
{$ENDREGION}
{$REGION 'Caixa do Atirador Pioneiro'}
          139:
            begin
              if Self.GetInvAvailableSlots(Player) < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (3086) + i * 30, $50);
              end;

              Self.PutEquipament(Player, 2701, $50);
            end;
{$ENDREGION}
{$REGION 'Caixa da Pistoleira Pioneira'}
          140:
            begin
              if Self.GetInvAvailableSlots(Player) < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (3206) + i * 30, $50);
              end;

              Self.PutEquipament(Player, 2666, $50);
            end;
{$ENDREGION}
{$REGION 'Caixa do Mago Pioneiro'}
          141:
            begin
              if Self.GetInvAvailableSlots(Player) < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (3326) + i * 30, $50);
              end;

              Self.PutEquipament(Player, 2771, $50);
            end;
{$ENDREGION}
{$REGION 'Caixa da Clériga Pioneira'}
          142:
            begin
              if Self.GetInvAvailableSlots(Player) < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (3446) + i * 30, $50);
              end;

              Self.PutEquipament(Player, 2736, $50);
            end;
{$ENDREGION}
{$ENDREGION}
{$REGION 'Conjuntos Avançados'}
{$REGION 'Conjunto Avançado [Guerreiro]'}
          39:
            begin
              if Self.GetInvAvailableSlots(Player) < 4 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (7008) + i * 30);
              end;
            end;
{$ENDREGION}
{$REGION 'Conjunto Avançado [Templária]'}
          41:
            begin
              if Self.GetInvAvailableSlots(Player) < 4 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (7127) + i * 30);
              end;
            end;
{$ENDREGION}
{$REGION 'Conjunto Avançado [Atirador]'}
          42:
            begin
              if Self.GetInvAvailableSlots(Player) < 4 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (7248) + i * 30);
              end;
            end;
{$ENDREGION}
{$REGION 'Conjunto Avançado [Pistoleira]'}
          43:
            begin
              if Self.GetInvAvailableSlots(Player) < 4 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (7368) + i * 30);
              end;
            end;
{$ENDREGION}
{$REGION 'Conjunto Avançado [Feiticeiro Negro]'}
          44:
            begin
              if Self.GetInvAvailableSlots(Player) < 4 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (7488) + i * 30);
              end;
            end;
{$ENDREGION}
{$REGION 'Conjunto Avançado [Clériga]'}
          45:
            begin
              if Self.GetInvAvailableSlots(Player) < 4 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              for i := 0 to 3 do
              begin
                Self.PutEquipament(Player, (7608) + i * 30);
              end;
            end;
{$ENDREGION}
{$ENDREGION}
{$REGION 'Cavalos de Fogo'}
{$REGION 'Kit do Cavalo de Fogo(Ataque)'}
          1858:
            begin
              if Self.GetInvAvailableSlots(Player) < 3 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 964);
              Self.PutItem(Player, 8163, 3);
              Self.PutItem(Player, 8164, 3);
            end;
{$ENDREGION}
{$REGION 'Kit do Cavalo de Fogo(Mágico)'}
          1859:
            begin
              if Self.GetInvAvailableSlots(Player) < 3 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 965);
              Self.PutItem(Player, 8163, 3);
              Self.PutItem(Player, 8164, 3);
            end;
{$ENDREGION}
{$REGION 'Kit do Cavalo de Fogo(Defesa)'}
          1860:
            begin
              if Self.GetInvAvailableSlots(Player) < 3 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutItem(Player, 963);
              Self.PutItem(Player, 8181, 3);
              Self.PutItem(Player, 8182, 3);
            end;
{$ENDREGION}
{$ENDREGION}
        end;
      end;

{$ENDREGION}
{$REGION 'Baus e caixas com itens aleatorios'}
    ITEM_TYPE_RANDOM_BAU:
      begin
        case ItemList[item.Index].UseEffect of
          1: //caixa do pre teste
            begin
              if (Self.GetInvAvailableSlots(Player) < 1) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              //Self.PutItem(Player, 5640, 1); //gold

              //Self.PutItem(Player, 5617, 1); //cash

              //Self.PutItem(Player, 5600, 1); //level

              Self.PutItem(Player, 11678, 1); //caixa set lv 50
             // Self.PutItem(Player, 11680, 1); //caixa acc lv 50
            end;

          629: //caixa do acessório do infrator
            begin
              if (Self.GetInvAvailableSlots(Player) < 4) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              Self.PutEquipament(Player, 1335, 1);
              Self.PutEquipament(Player, 1363, 1);
              Self.PutEquipament(Player, 1393, 1);
              Self.PutEquipament(Player, 1418, 1);
            end;

{$REGION 'Caixa dourada - obtida no PvP'}
          1030:
            begin
              if(Self.GetInvAvailableSlots(Player) = 0) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              Randomize;
              Rand := RandomRange(1, 101);

              case Rand of
                1: //vai dar enriquecido do cap
                  begin
                    case RandomRange(1, 101) of
                      1..20: //C Rico
                        begin
                          case RandomRange(1,4) of
                            1, 2: //Rico C Kaize
                              begin
                                Self.PutItem(Player, 8210, 1);
                              end;

                            3:
                              begin //rico C Hira
                                Self.PutItem(Player, 8207, 1);
                              end;

                          end;
                        end;

                      21..40: //C Normal
                        begin
                          case RandomRange(1,4) of
                            1, 2: //Rico C Kaize
                              begin
                                Self.PutItem(Player, 8188, 1);
                              end;

                            3:
                              begin //rico C Hira
                                Self.PutItem(Player, 8186, 1);
                              end;
                          end;
                        end;

                      41..100:
                        begin
                          Self.PutItem(Player, 5768, 1);
                        end;
                    end;
                  end;

                2..45:
                  begin
                    case RandomRange(1,101) of
                      1..5:
                        begin //pocao defesa 3hrs evento
                          Self.PutItem(Player, 8063, 1);
                        end;

                      6..10:
                        begin //pocao destruicao 3hrs evento
                          Self.PutItem(Player, 8064, 1);
                        end;

                      11..20:
                        begin //sopa status 01
                          Self.PutItem(Player, 4857, 1);
                        end;

                      21..30:
                        begin //sopa status 02
                          Self.PutItem(Player, 4858, 1);
                        end;

                      31..40:
                        begin //sopa status 03
                          Self.PutItem(Player, 4859, 1);
                        end;

                      41..100:
                        begin  //tocha
                          Self.PutItem(Player, 5768, 1);
                        end;
                    end;
                  end;

                46..85, 0: //tocha
                  begin
                    Self.PutItem(Player, 5768, 1);
                  end;

                86, 87: //caixa do tiamat (da a aparencia da academia de batalha)
                  begin
                    Self.PutItem(Player, 15978, 1);
                  end;

                88: // Baú do cristal sagrado
                  begin
                    Self.PutItem(Player, 17031, 1);
                  end;

                89: //cristal azul de montaria  9572
                  begin
                    Self.PutItem(Player, 9572, 1);
                  end;

                91: //presente cristal pran 8270
                  begin
                    Self.PutItem(Player, 8270, 1);
                  end;

                {93: //pacote carrasco +4
                  begin
                    Self.PutItem(Player, 14138, 1);
                  end;}

                94: // Baú do cristal sagrado
                  begin
                    Self.PutItem(Player, 17031, 1);
                    //Self.PutItem(Player, 14141, 1);
                  end;

                {95..100:
                  begin
                    Randomize;
                    case RandomRange(1,101) of
                      0..24: //anel quinto ano
                        begin
                          Self.PutItem(Player, 1335, 1);
                        end;

                      25..49: //brinco quinto ano
                        begin
                          Self.PutItem(Player, 1363, 1);
                        end;

                      50..74: //bracelete quinto ano
                        begin
                          Self.PutItem(Player, 1393, 1);
                        end;

                      75..101:
                        begin //colar quinto ano
                          Self.PutItem(Player, 1418, 1);
                        end;
                    end;
                  end; }
                else //tocha
                  begin
                    Self.PutItem(Player, 5768, 1);
                  end;
              end;
            end;

{$ENDREGION}

{$REGION 'Caixa do Tiamat - Aparencia da Academia de Batalha'}

          1089:
            begin
              if(Self.GetInvAvailableSlots(Player) < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              case RandomRange(1, 4) of
                1: //vermelha mais rara
                  begin
                    case Player.Base.GetMobClass of
                      0: //war
                        begin
                          Self.PutEquipament(Player, 12074);

                          Self.PutEquipament(Player, 12380);
                          Self.PutEquipament(Player, 12410);
                          Self.PutEquipament(Player, 12440);
                          Self.PutEquipament(Player, 12470);
                        end;

                      1: //tp
                        begin
                          if(Self.GetInvAvailableSlots(Player) < 6) then
                          begin
                            Player.SendClientMessage('Inventário cheio.');
                            Exit;
                          end;

                          Self.PutEquipament(Player, 12350);

                          Self.PutEquipament(Player, 12109);

                          Self.PutEquipament(Player, 12500);
                          Self.PutEquipament(Player, 12530);
                          Self.PutEquipament(Player, 12560);
                          Self.PutEquipament(Player, 12590);
                        end;

                      2: //att
                        begin
                          Self.PutEquipament(Player, 12214);

                          Self.PutEquipament(Player, 12620);
                          Self.PutEquipament(Player, 12650);
                          Self.PutEquipament(Player, 12680);
                          Self.PutEquipament(Player, 12710);
                        end;

                      3: //dual
                        begin
                          Self.PutEquipament(Player, 12249);

                          Self.PutEquipament(Player, 12740);
                          Self.PutEquipament(Player, 12770);
                          Self.PutEquipament(Player, 12800);
                          Self.PutEquipament(Player, 12830);
                        end;

                      4: //fc
                        begin
                          Self.PutEquipament(Player, 12284);

                          Self.PutEquipament(Player, 12860);
                          Self.PutEquipament(Player, 12890);
                          Self.PutEquipament(Player, 12920);
                          Self.PutEquipament(Player, 12950);
                        end;

                      5: //cl
                        begin
                          Self.PutEquipament(Player, 12319);

                          Self.PutEquipament(Player, 12980);
                          Self.PutEquipament(Player, 13010);
                          Self.PutEquipament(Player, 13040);
                          Self.PutEquipament(Player, 13070);
                        end;
                    end;
                  end;

                2, 3: //azul mais comum
                  begin
                    case Player.Base.GetMobClass of
                      0: //war
                        begin
                          Self.PutEquipament(Player, 12075);

                          Self.PutEquipament(Player, 12381);
                          Self.PutEquipament(Player, 12411);
                          Self.PutEquipament(Player, 12441);
                          Self.PutEquipament(Player, 12471);
                        end;

                      1: //tp
                        begin
                          if(Self.GetInvAvailableSlots(Player) < 6) then
                          begin
                            Player.SendClientMessage('Inventário cheio.');
                            Exit;
                          end;

                          Self.PutEquipament(Player, 12351);

                          Self.PutEquipament(Player, 12110);

                          Self.PutEquipament(Player, 12501);
                          Self.PutEquipament(Player, 12531);
                          Self.PutEquipament(Player, 12561);
                          Self.PutEquipament(Player, 12591);
                        end;

                      2: //att
                        begin
                          Self.PutEquipament(Player, 12215);

                          Self.PutEquipament(Player, 12621);
                          Self.PutEquipament(Player, 12651);
                          Self.PutEquipament(Player, 12681);
                          Self.PutEquipament(Player, 12711);
                        end;

                      3: //dual
                        begin
                          Self.PutEquipament(Player, 12250);

                          Self.PutEquipament(Player, 12741);
                          Self.PutEquipament(Player, 12771);
                          Self.PutEquipament(Player, 12801);
                          Self.PutEquipament(Player, 12831);
                        end;

                      4: //fc
                        begin
                          Self.PutEquipament(Player, 12285);

                          Self.PutEquipament(Player, 12861);
                          Self.PutEquipament(Player, 12891);
                          Self.PutEquipament(Player, 12921);
                          Self.PutEquipament(Player, 12951);
                        end;

                      5: //cl
                        begin
                          Self.PutEquipament(Player, 12320);

                          Self.PutEquipament(Player, 12981);
                          Self.PutEquipament(Player, 13011);
                          Self.PutEquipament(Player, 13041);
                          Self.PutEquipament(Player, 13071);
                        end;
                    end;
                  end;
              end;
            end;

{$ENDREGION}
{$REGION 'Caixa Cristal de montaria'}
          98:
            begin
              if (Self.GetInvAvailableSlots(Player) = 0) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              RandomTax := Self.SelectRamdomItem([4220, 4221, 4222, 4223, 4224,
                4225, 4226, 4227, 4228, 4229, 4230, 4231, 4234, 4235, 4240,
                4241], [20, 20, 20, 20, 20, 20, 15, 15, 15, 5, 25, 25, 3,
                5, 5, 5]);

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              Self.PutItem(Player, RandomTax);
            end;

{$ENDREGION}
{$REGION 'Caixa cristais de roupa pran'}
          910:
            begin
              if (Self.GetInvAvailableSlots(Player) = 0) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              RandomTax := Self.SelectRamdomItem([9451, 9452, 9453, 9454, 9455, 9456, 9457,
                9458, 9459, 9460, 9461, 9462, 9463, 9464, 9465],
                [5, 5, 2, 2, 2, 25, 25, 25, 25, 25, 15, 15, 5, 5, 30]);

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              Self.PutItem(Player, RandomTax);
            end;

{$ENDREGION}
{$REGION 'Bau do cristal sagrado'}
          1130, 950:
            begin
              if (Self.GetInvAvailableSlots(Player) = 0) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              {RandomTax := Self.SelectRamdomItem([15748, 15749, 15750, 15751,
                15752, 15753, 15755, 15756, 15758, 15759, 15760, 15761, 15701,
                15702, 15703, 15704, 15705, 15706, 15707, 15708, 15709, 15710,
                15713, 15714, 15715, 15731, 15732, 15733, 15734, 15735, 15738,
                15739, 15740, 15780, 15781, 15788], [10, 5, 5, 5, 10, 10, 5, 5,
                15, 15, 10, 20, 15, 5, 5, 5, 2, 3, 20, 20, 25, 25, 10, 10, 20,
                5, 25, 25, 25, 25, 25, 2, 5, 5, 2, 2]);  }

              RandomTax := Self.SelectRamdomItem([5329, 5332, 5335, 5338,
                5341, 5344, 5348, 5492, 5495, 5350, 5353, 5356, 5359,
                5362, 5365, 5368, 5371, 5374, 5497, 5396, 5398, 5402,
                5405, 5408, 5411, 5413, 5416, 5419, 5422, 5425, 5446,
                5449, 5499, 5500, 5490, 5498], [25, 25, 25, 15, 15, 5, 15, 15,
                15, 15, 5, 20, 15, 15, 15, 15, 5, 5, 20, 20, 25, 25, 5, 5, 20,
                15, 25, 25, 25, 25, 25, 5, 5, 5, 5, 5]);


              {RandomTax := Self.SelectRamdomItem([5329, 5332, 5335, 5338,
                5341, 5344, 5348, 5492, 5495, 5350, 5353, 5356, 5359,
                5362, 5365, 5368, 5371, 5374, 5497, 5396, 5398, 5402,
                5405, 5408, 5411, 5413, 5416, 5419, 5422, 5425, 5446,
                5449, 5499, 5500, 5490, 5498], [25, 25, 25, 15, 15, 10, 15, 15,
                15, 15, 10, 20, 15, 15, 15, 15, 12, 13, 20, 20, 25, 25, 10, 10, 20,
                15, 25, 25, 25, 25, 25, 12, 15, 15, 12, 5]);   }

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              Self.PutItem(Player, RandomTax);
            end;

{$ENDREGION}
//{$REGION 'Closed Beta'}
          10766:
            begin
              Player.AddTitle(78, 1);
            end;
//{$ENDREGION}
//{$REGION 'Closed Beta'}
          10767:
            begin
              Player.AddTitle(94, 1);
            end;

          10768:
            begin
              Player.AddTitle(95, 1);
            end;

{$REGION 'Baú Perdido do Cristal Sagrado [Pran]'}


          16004:
            begin
              if (Self.GetInvAvailableSlots(Player) = 0) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              RandomTax := Self.SelectRamdomItem(
                [8270, 11454, 8262, 4359, 4379, 8063, 8064], [2, 4, 8, 16, 16, 48, 48]);

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              Self.PutItem(Player, RandomTax);
            end;
{$ENDREGION}
{$REGION 'Baú Perdido do Cristal Sagrado [Montaria]'}
          16003:
            begin
              if (Self.GetInvAvailableSlots(Player) = 0) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              RandomTax := Self.SelectRamdomItem(
              [9572, 4274, 8262, 4359, 4379, 8063, 8064], [2, 4, 8, 16, 16, 48, 48]);

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              Self.PutItem(Player, RandomTax);
            end;
{$ENDREGION}
{$REGION 'Baú Perdido do Cristal Sagrado [Arma]'}
          16000:
            begin
              if (Self.GetInvAvailableSlots(Player) = 0) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              RandomTax := Self.SelectRamdomItem(
                [9572, 8151, 8159, 8262, 4359, 4379, 8063, 8064], [2, 2, 4, 8, 16, 16, 48, 48]);

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              if(RandomTax = 9572) then
              begin
                RandomTax := Self.SelectRamdomItem(
                [5349, 5335, 5338, 5341, 5329, 5332, 5344], [5,5,5,5, 15, 15, 20]);
              end;

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              Self.PutItem(Player, RandomTax);
            end;
{$ENDREGION}
{$REGION 'Baú Perdido do Cristal Sagrado [Armadura]'}
          16001:
            begin
              if (Self.GetInvAvailableSlots(Player) = 0) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              RandomTax := Self.SelectRamdomItem(
                [9572, 8169, 8177, 8262, 4359, 4379, 8063, 8064], [4, 2, 4, 8, 16, 16, 48, 48]);

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              if(RandomTax = 9572) then
              begin
                RandomTax := Self.SelectRamdomItem(
                [5369, 5365, 5362, 5359, 5353, 5350, 5356, 5371, 5374], [4,2,4,4, 15, 15, 20, 25, 25]);
              end;

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              Self.PutItem(Player, RandomTax);
            end;
{$ENDREGION}
{$REGION 'Baú Perdido do Cristal Sagrado [Acessório]'}
          16002:
            begin
              if (Self.GetInvAvailableSlots(Player) = 0) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              RandomTax := Self.SelectRamdomItem(
                [9572, 6502, 6503, 6504, 6505, 8262, 4359, 4379, 8063, 8064], [2, 1, 1, 1, 1, 8, 16, 16, 48, 48]);

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              if(RandomTax = 9572) then
              begin
                RandomTax := Self.SelectRamdomItem(
                [5404, 5402, 5395, 5411, 5413, 5416, 5419, 5422, 5425], [4,2,1,2,2, 15, 15, 15, 15, 15]);
              end;

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              Self.PutItem(Player, RandomTax);
            end;
{$ENDREGION}
{$REGION 'Festival da Ultima Jornada'}
          16020:
            begin
              if (Self.GetInvAvailableSlots(Player) < 2) then
              begin
                Player.SendClientMessage('Inventário cheio. 2 Espaços necessários.');
                Exit;
              end;

              RandomTax := Self.SelectRamdomItem([1, 2], [8, 98]);

              if (RandomTax = 0) then
              begin
                Player.SendClientMessage('Erro randomico, contate o suporte.');
                Exit;
              end;

              case RandomTax of
                1:
                  begin
                    case RandomRange(1, 41) of
                      1..20: //C Rico
                        begin
                          case RandomRange(1,4) of
                            1, 2: //Rico C Kaize
                              begin
                                Self.PutItem(Player, 8210, 1);
                              end;

                            3:
                              begin //rico C Hira
                                Self.PutItem(Player, 8207, 1);
                              end;

                          end;
                        end;

                      21..40: //C Normal
                        begin
                          case RandomRange(1,4) of
                            1,2: //Rico C Kaize
                              begin
                                Self.PutItem(Player, 8188, 1);
                              end;

                            3:
                              begin //rico C Hira
                                Self.PutItem(Player, 8186, 1);
                              end;
                          end;
                        end;
                    end;
                  end;
                2:
                  begin
                    case RandomRange(1,105) of
                      1..10:
                        begin //comida pran 01
                          Self.PutItem(Player, 8105, 1);
                        end;
                      11..20:
                        begin //comida pran 02
                          Self.PutItem(Player, 8106, 1);
                        end;
                      21..30:
                        begin //comida pran 03
                          Self.PutItem(Player, 8107, 1);
                        end;
                      31..40:
                        begin //comida pran 04
                          Self.PutItem(Player, 8108, 1);
                        end;
                      41..50:
                        begin //comida pran 05
                          Self.PutItem(Player, 8109, 1);
                        end;
                      51..60:
                        begin //comida pran 06
                          Self.PutItem(Player, 8110, 1);
                        end;
                      61..70:
                        begin //perga do portal
                          Self.PutItem(Player, 8111, 2);
                        end;
                      71..80:
                        begin //reparador D
                          Self.PutItem(Player, 8114, 1);
                          Self.PutItem(Player, 8124, 4);
                        end;
                      81..90:
                        begin //reparador C
                          Self.PutItem(Player, 8115, 1);
                          Self.PutItem(Player, 8125, 4);
                        end;
                      91,92:
                        begin //vaizan brilhante normal
                          Self.PutItem(Player, 8132, 1);
                        end;
                      93,94:
                        begin //vaizan brilhante Superior
                          Self.PutItem(Player, 8133, 1);
                        end;
                      95,96:
                        begin //vaizan brilhante Raro
                          Self.PutItem(Player, 8134, 1);
                        end;
                      97,98:
                        begin //pedra mágica da restauração
                          Self.PutItem(Player, 8137, 1);
                        end;
                      99,104:
                        begin  //double exp
                          Self.PutItem(Player, 4519, 1);
                        end;
                    end;
                  end;
              end;

            end;
{$ENDREGION}
        end;
      end;

{$ENDREGION}
{$REGION 'Poção de HP/MP'}
    ITEM_TYPE_HP_POTION:
      begin
        Inc(Player.Character.Base.CurrentScore.CurHP,
          ItemList[item.Index].UseEffect);
        Player.Base.SendCurrentHPMP(True);
      end;

    ITEM_TYPE_HPMP_LAGRIMAS:
      begin
        Inc(Player.Character.Base.CurrentScore.CurHP,
          ItemList[item.Index].UseEffect);
        Inc(Player.Character.Base.CurrentScore.CurMP,
          ItemList[item.Index].UseEffect);
        Player.Base.SendCurrentHPMP(True);
      end;
{$ENDREGION}
{$REGION 'Poção de HP'}
    ITEM_TYPE_HPMP_POTION:
      begin
        Inc(Player.Character.Base.CurrentScore.CurHP,
          ItemList[item.Index].UseEffect);
        Inc(Player.Character.Base.CurrentScore.CurMP,
          ItemList[item.Index].UseEffect);
        Player.Base.SendCurrentHPMP(True);
      end;

{$ENDREGION}
{$REGION 'Poção de MP'}
    ITEM_TYPE_MP_POTION:
      begin
        Inc(Player.Character.Base.CurrentScore.CurMP,
          ItemList[item.Index].UseEffect);
        Player.Base.SendCurrentHPMP(True);
      end;

{$ENDREGION}
{$REGION 'Símbolo do Viajante'}
    ITEM_TYPE_BAG_INV:
      begin
        Self.SetItemDuration(item^);

        Move(item^, Player.Character.Base.Inventory[63], sizeof(TItem));
        Player.Base.SendRefreshItemSlot(INV_TYPE, 63, item^, False);
        Player.SendClientMessage('Selo de [' +
          AnsiString(ItemList[item.Index].Name) + '] foi removido.');
        ZeroMemory(item, sizeof(TItem));
      end;

{$ENDREGION}
{$REGION 'Símbolo da Determinação'}
    ITEM_TYPE_BAG_STORAGE:
      begin

        BagSlot := 0;

        for i := 1 to 3 do
        begin
          if (Player.Account.Header.Storage.Itens[80 + i].Index = 0) then
          begin
            BagSlot := 80 + i;
          end;
        end;

        if (BagSlot = 0) then
        begin
          Player.SendClientMessage('Limite de expansão atingido.');
          Exit;
        end;

        Self.SetItemDuration(item^);

        Move(item^, Player.Account.Header.Storage.Itens[BagSlot],
          sizeof(TItem));
        Player.Base.SendRefreshItemSlot(INV_TYPE, BagSlot, item^, False);
        Player.SendClientMessage('Selo de [' +
          AnsiString(ItemList[item.Index].Name) + '] foi removido.');
        ZeroMemory(item, sizeof(TItem));
      end;

{$ENDREGION}
{$REGION 'Simbolo do Testamento (Bolsa Pran)'}
     ITEM_TYPE_BAG_PRAN:
      begin
        case Player.SpawnedPran of
          0:
            begin
              if(Player.Account.Header.Pran1.Inventory[41].Index <> 0) then
              begin
                Player.SendClientMessage('Você já possui duas bolsas nessa pran.');
                Exit;
              end;

              BagSlot := 41;

              Self.SetItemDuration(item^);

              Move(item^, Player.Account.Header.Pran1.Inventory[BagSlot],
                sizeof(TItem));
              //Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
              Player.Base.SendRefreshItemSlot(PRAN_INV_TYPE, BagSlot,
                Player.Account.Header.Pran1.Inventory[BagSlot], False);

              Player.SendClientMessage('Selo de [' +
                AnsiString(ItemList[item.Index].Name) + '] foi removido.');
              ZeroMemory(item, sizeof(TItem));
            end;

          1:
            begin
              if(Player.Account.Header.Pran2.Inventory[41].Index <> 0) then
              begin
                Player.SendClientMessage('Você já possui duas bolsas nessa pran.');
                Exit;
              end;

              BagSlot := 41;

              Self.SetItemDuration(item^);

              Move(item^, Player.Account.Header.Pran2.Inventory[BagSlot],
                sizeof(TItem));
              //Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
              Player.Base.SendRefreshItemSlot(PRAN_INV_TYPE, BagSlot,
                Player.Account.Header.Pran2.Inventory[BagSlot], False);

              Player.SendClientMessage('Selo de [' +
                AnsiString(ItemList[item.Index].Name) + '] foi removido.');
              ZeroMemory(item, sizeof(TItem));
            end;

        else
          Exit;
        end;
      end;
{$ENDREGION}

{$REGION 'Símbolo da Confiança'}
    ITEM_TYPE_STORAGE_OPEN:
      begin
        Player.OpennedOption := 7;
        Player.OpennedNPC := Player.Base.ClientID;
        Player.SendStorage(STORAGE_TYPE_PLAYER);
      end;
{$ENDREGION}
{$REGION 'Símbolo do vendedor'}
    ITEM_TYPE_SHOP_OPEN:
      begin
        Player.OpennedOption := 5;
        Player.OpennedNPC := 2070;
        TNPChandlers.ShowShop(Player, Servers[Player.ChannelIndex].NPCS[2070]);
      end;
{$ENDREGION}

{$REGION 'Poções que dão buff'}
    ITEM_TYPE_POTION_BUFF:
      begin
        if(Copy(String(ItemList[Item.Index].Name), 0, 4) = 'Sopa') then
        begin
          if not(Player.Base.BuffExistsSopa) then
          begin
            Player.Base.AddBuff(ItemList[item.Index].UseEffect);
            Self.DecreaseAmount(item, Decrease);
            Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
            Result := True;
            Exit;
          end
          else
          begin
            Player.SendClientMessage('Não é combinável com [' +
              AnsiString(SkillData[ItemList[Item.Index].UseEffect].Name + '].'));
            Exit;
          end;
        end;

        if(SkillData[ItemList[Item.Index].UseEffect].Index = 251) then
        begin
          if(Player.Base.BuffExistsByIndex(251)) then
          begin
            Player.SendClientMessage('Não é combinável com [' +
              AnsiString(SkillData[ItemList[Item.Index].UseEffect].Name + '].'));
            Exit;
          end;
        end;

        case SkillData[ItemList[Item.Index].UseEffect].Index of
          298:
            begin
              if(Player.Base.BuffExistsByIndex(176)) then
                Exit;
            end;
          493: //poção valor de batalha
          begin
            if(Player.Base.BuffExistsInArray([494, 495, 496, 497])) then
            begin
              Player.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[Item.Index].UseEffect].Name + '].'));
              Exit;
            end;
          end;

          494: //poção valor de batalha
          begin
            if(Player.Base.BuffExistsInArray([493, 495, 496, 497])) then
            begin
              Player.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[Item.Index].UseEffect].Name + '].'));
              Exit;
            end;
          end;

          495: //poção valor de batalha
          begin
            if(Player.Base.BuffExistsInArray([494, 493, 496, 497])) then
            begin
              Player.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[Item.Index].UseEffect].Name + '].'));
              Exit;
            end;
          end;

          496: //poção valor de batalha
          begin
            if(Player.Base.BuffExistsInArray([494, 495, 493, 497])) then
            begin
              Player.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[Item.Index].UseEffect].Name + '].'));
              Exit;
            end;
          end;

          497: //poção valor de batalha
          begin //poção de batalha pvp
            if(Player.Base.BuffExistsInArray([494, 495, 496, 493])) then
            begin
              Player.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[Item.Index].UseEffect].Name + '].'));
              Exit;
            end;
          end;
        end;

        Player.Base.AddBuff(ItemList[item.Index].UseEffect);
      end;
{$ENDREGION}
{$REGION 'Itens que dão Exp'}
    {ITEM_TYPE_ADD_EXP_PERC:
      begin
        Player.AddExpPerc(ItemList[item.Index].UseEffect);
      end;

    ITEM_TYPE_USE_TO_UP_LVL:
      begin
        case ItemList[item.Index].UseEffect of
          1:
          begin
            Level := ItemList[item.Index].UseEffect * 50;

            try
              LevelExp := ExpList[Player.Character.Base.Level + (Level - 1)] + 1;
            except
              LevelExp := High(ExpList);
            end;

            AddExp := LevelExp - UInt64(Player.Character.Base.Exp);

            Player.AddExp(AddExp);
            Player.Base.SendRefreshLevel;
          end;

        else
          begin
            Player.AddLevel(ItemList[item.Index].UseEffect);
          end;
        end;
      end;  }
{$ENDREGION}
{$REGION 'Pergaminho do portal'}
    ITEM_TYPE_SCROLL_PORTAL:
      begin
        if(Player.Base.InClastleVerus) then
        begin
          Player.SendClientMessage('Impossível usar em guerra. Use o teleporte.');
          Exit;
        end;

        try
          ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);

          if(ReliqSlot <> 255) then
          begin
            Player.SendClientMessage('Impossível usar com relíquia.');
            Exit;
          end;

          if (Player.Base.Character.Nation > 0) then
          begin
            if (Player.Base.Character.Nation <> Servers[Player.ChannelIndex]
              .NationID) then
            begin
              Player.SendClientMessage
                ('Impossível usar este item no canal desejado.');
              Exit;
            end;
          end;

          PosX := TPosition.Create(ScrollTeleportPosition[Type1]
            .PosX, ScrollTeleportPosition[Type1].PosY);

          if(PosX.IsValid) then
            Player.Teleport(PosX)
          else
          begin
            PosX := TPosition.Create(3450, 690);
            Player.Teleport(PosX);
          end;

        except
          on E: Exception do
          begin
            Player.Teleport(Player.Base.PlayerCharacter.LastPos);
            Logger.Write('erro ao se teleportar. ' + E.Message, TlogType.Error);
            Exit;
          end;

        end;
      end;

{$ENDREGION}
{$REGION 'Pergaminho:Regenchain'}
    ITEM_TYPE_CITY_SCROLL:
      begin
        if(Player.Base.InClastleVerus) then
        begin
          Player.SendClientMessage('Impossível usar em guerra. Use o teleporte.');
          Exit;
        end;

        ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);

        if(ReliqSlot <> 255) then
        begin
          Player.SendClientMessage('Impossível usar com relíquia.');
          Exit;
        end;

        if (Player.Base.Character.Nation > 0) then
        begin
          if (Player.Base.Character.Nation <> Servers[Player.ChannelIndex]
            .NationID) then
          begin
            Player.SendClientMessage
              ('Impossível usar este item no canal desejado.');
            Exit;
          end;
        end;

        Player.SendPlayerToCityPosition();
      end;
{$ENDREGION}
{$REGION 'Pergaminho:CidadeSalva'}
    ITEM_TYPE_LOC_SCROLL:
      begin
        if(Player.Base.InClastleVerus) then
        begin
          Player.SendClientMessage('Impossível usar em guerra. Use o teleporte.');
          Exit;
        end;

        ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);

        if(ReliqSlot <> 255) then
        begin
          Player.SendClientMessage('Impossível usar com relíquia.');
          Exit;
        end;

        if (Player.Base.Character.Nation > 0) then
        begin
          if (Player.Base.Character.Nation <> Servers[Player.ChannelIndex]
            .NationID) then
          begin
            Player.SendClientMessage
              ('Impossível usar este item no canal desejado.');
            Exit;
          end;
        end;

        Player.SendPlayerToSavedPosition();
      end;
{$ENDREGION}
{$REGION 'Símbolo de cidadania'}
    ITEM_TYPE_SET_ACCOUNT_NATION:
      begin
        case ItemList[item.Index].UseEffect of
          99:
            begin
              if Player.Account.Header.Nation > TCitizenship.None then
                Exit;

              Player.Character.Base.Nation := ServerList[Player.ChannelIndex]
                .NationIndex;
              Player.Account.Header.Nation :=
                TCitizenship(ServerList[Player.ChannelIndex].NationIndex);
              Player.RefreshPlayerInfos;
              Player.AddTitle(18, 1);
              //Player.SocketClosed := True;
            end;
        end;
      end;
{$ENDREGION}
{$REGION 'Comida de pran'}
    ITEM_TYPE_PRAN_FOOD:
      begin
        if (Player.SpawnedPran = 0) then
        begin
          if (Player.Account.Header.Pran1.Food >= 121) then
          begin
            Player.Account.Header.Pran1.Food := 121;
            Player.SendClientMessage('Sua pran não consegue comer mais.');
            Exit;
          end;

          case item.Index of // setar a personalidade
            8105: // sopa de batata doce (cute)
              begin
                Inc(Player.Account.Header.Pran1.Personality.Cute, 2);

                DecWord(Player.Account.Header.Pran1.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Corrupt, 3);
              end;

            8106: // perfait de cereja (sexy)
              begin
                Inc(Player.Account.Header.Pran1.Personality.Sexy, 2);

                DecWord(Player.Account.Header.Pran1.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Corrupt, 3);
              end;

            8107: // salada de caviar (smart)
              begin
                Inc(Player.Account.Header.Pran1.Personality.Smart, 2);

                DecWord(Player.Account.Header.Pran1.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Corrupt, 3);
              end;

            8108: // espetinho de camarao (energetic)
              begin
                Inc(Player.Account.Header.Pran1.Personality.Energetic, 2);

                DecWord(Player.Account.Header.Pran1.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Corrupt, 3);
              end;

            8109: // churrasco de york (tough)
              begin
                Inc(Player.Account.Header.Pran1.Personality.Tough, 2);

                DecWord(Player.Account.Header.Pran1.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Corrupt, 3);
              end;

            8110: // peixe duvidoso assado (corrupt)
              begin
                Inc(Player.Account.Header.Pran1.Personality.Corrupt, 2);

                DecWord(Player.Account.Header.Pran1.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Cute, 3);
              end;
          end;

          case Item.Index of
            8105..8110:
              begin
                if not(Player.Account.Header.Pran1.Devotion >= 226) then
                  Player.Account.Header.Pran1.Devotion :=
                    Player.Account.Header.Pran1.Devotion + 1;
              end;
          end;

          if (Player.Account.Header.Pran1.MovedToCentral = True) then
            Player.Account.Header.Pran1.MovedToCentral := False;

          if ((Player.Account.Header.Pran1.Food + 15) > 121) then
            Player.Account.Header.Pran1.Food := 121
          else
            Inc(Player.Account.Header.Pran1.Food, 15);

          Player.SendPranToWorld(0);
        end
        else
        if (Player.SpawnedPran = 1) then
        begin
          if (Player.Account.Header.Pran2.Food >= 121) then
          begin
            Player.Account.Header.Pran2.Food := 121;
            Player.SendClientMessage('Sua pran não consegue comer mais.');
            Exit;
          end;

          case item.Index of // setar a personalidade
            8105: // sopa de batata doce (cute)
              begin
                Inc(Player.Account.Header.Pran2.Personality.Cute, 2);

                DecWord(Player.Account.Header.Pran2.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Corrupt, 3);
              end;

            8106: // perfait de cereja (sexy)
              begin
                Inc(Player.Account.Header.Pran2.Personality.Sexy, 2);

                DecWord(Player.Account.Header.Pran2.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Corrupt, 3);
              end;

            8107: // salada de caviar (smart)
              begin
                Inc(Player.Account.Header.Pran2.Personality.Smart, 2);

                DecWord(Player.Account.Header.Pran2.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Corrupt, 3);
              end;

            8108: // espetinho de camarao (energetic)
              begin
                Inc(Player.Account.Header.Pran2.Personality.Energetic, 2);

                DecWord(Player.Account.Header.Pran2.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Corrupt, 3);
              end;

            8109: // churrasco de york (tough)
              begin
                Inc(Player.Account.Header.Pran2.Personality.Tough, 2);

                DecWord(Player.Account.Header.Pran2.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Corrupt, 3);
              end;

            8110: // peixe duvidoso assado (corrupt)
              begin
                Inc(Player.Account.Header.Pran2.Personality.Corrupt, 2);

                DecWord(Player.Account.Header.Pran2.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Cute, 3);
              end;
          end;

          if (Player.Account.Header.Pran2.MovedToCentral = True) then
            Player.Account.Header.Pran2.MovedToCentral := False;

          case Item.Index of
            8105..8110:
              begin
                if not(Player.Account.Header.Pran2.Devotion >= 226) then
                  Player.Account.Header.Pran2.Devotion :=
                    Player.Account.Header.Pran2.Devotion + 1;
              end;
          end;

          if ((Player.Account.Header.Pran2.Food + 15) > 121) then
            Player.Account.Header.Pran2.Food := 121
          else
            Inc(Player.Account.Header.Pran2.Food, 15);

          Player.SendPranToWorld(1);
        end
        else
          Exit;

      end;

    ITEM_TYPE_PRAN_DIGEST:
      begin //Digestivo da pran
        if (Player.Account.Header.Pran1.IsSpawned) then
        begin
          if(Player.Account.Header.Pran1.Food <= 13) then
          begin
            Player.SendClientMessage('Sua pran está com muita fome para usar o Digestivo.');
            Exit;
          end;

          Player.Account.Header.Pran1.Food := Player.Account.Header.Pran1.Food div 2;

          Player.SendPranToWorld(0);
        end
        else
        if (Player.Account.Header.Pran2.IsSpawned) then
        begin
          if(Player.Account.Header.Pran2.Food <= 13) then
          begin
            Player.SendClientMessage('Sua pran está com muita fome para usar o Digestivo.');
            Exit;
          end;

          Player.Account.Header.Pran2.Food := Player.Account.Header.Pran2.Food div 2;

          Player.SendPranToWorld(1);
        end;
      end;

{$ENDREGION}
{$REGION 'Receitas'}
    ITEM_TYPE_RECIPE:
      begin
        RecipeIndex := Self.GetIDRecipeArray(item.Index);

        if (RecipeIndex = 3000) then
        begin
          Player.SendClientMessage('A receita não existe no banco de dados.');
          Exit;
        end;

        if (Recipes[RecipeIndex].LevelMin > Player.Base.Character.Level) then
        begin
          Player.SendClientMessage('Level mínimo da receita é ' +
            AnsiString(Recipes[RecipeIndex].LevelMin.ToString) + '.');
          Exit;
        end;

        ItemExists := True;
        HaveAmount := True;

        for i := 0 to 11 do
        begin
          if (Recipes[RecipeIndex].ItemIDRequired[i] = 0) then
            Continue;

          if(Recipes[RecipeIndex].ItemIDRequired[i] = 4202) then
            Recipes[RecipeIndex].ItemIDRequired[i] := 4204;

          if not(Self.GetItemSlotAndAmountByIndex(Player,
            Recipes[RecipeIndex].ItemIDRequired[i], ItemSlot, ItemAmount)) then
          begin
            ItemExists := False;

            Player.SendClientMessage('Você não possui [' +
              AnsiString(ItemList[Recipes[RecipeIndex].ItemIDRequired[i]]
              .Name) + '].');
            Break;
          end
          else
          begin
            if (ItemAmount < Recipes[RecipeIndex].ItemRequiredAmount[i]) then
            begin
              HaveAmount := False;

              Player.SendClientMessage('Você precisa de ' +
                AnsiString(Recipes[RecipeIndex].ItemRequiredAmount[i].ToString)
                + ' do item [' +
                AnsiString(ItemList[Recipes[RecipeIndex].ItemIDRequired[i]]
                .Name) + ']. Separe a quantidade correta em apenas UM slot.');
              Break;
            end;
          end;
        end;

        if (not(ItemExists) or not(HaveAmount)) then
        begin
          Exit;
        end;

        EmptySlot := GetEmptySlot(Player);

        if (EmptySlot = 255) then
        begin
          Player.SendClientMessage('Seu inventário está cheio.');
          Exit;
        end;

        Randomize;
        RandomTax := RandomRange(1, (Recipes[RecipeIndex].SuccessTax div 10)+1);

        if (RandomTax <= (Recipes[RecipeIndex].SuccessTax div 10)) then
        begin // success
          Player.SendClientMessage('Receita bem sucedida.');

          Self.PutItem(Player, Recipes[RecipeIndex].Reward,
            Recipes[RecipeIndex].RewardAmount);

          for i := 0 to 11 do
          begin
            if (Recipes[RecipeIndex].ItemIDRequired[i] = 0) then
              Continue;

            if(Recipes[RecipeIndex].ItemIDRequired[i] = 4202) then
              Recipes[RecipeIndex].ItemIDRequired[i] := 4204;

            if (Self.GetItemSlotAndAmountByIndex(Player,
              Recipes[RecipeIndex].ItemIDRequired[i], ItemSlot, ItemAmount))
            then
            begin
              SecondItem := @Player.Base.Character.Inventory[ItemSlot];
              if((TItemFunctions.GetItemEquipSlot(Recipes[RecipeIndex].ItemRequiredAmount[i]) >= 2) and
                (TItemFunctions.GetItemEquipSlot(Recipes[RecipeIndex].ItemRequiredAmount[i]) <= 14)) then
              begin
                TItemFunctions.RemoveItem(Player, INV_TYPE, ItemSlot);
              end
              else
              begin
                Self.DecreaseAmount(SecondItem,
                  Recipes[RecipeIndex].ItemRequiredAmount[i]);
                Player.Base.SendRefreshItemSlot(INV_TYPE, ItemSlot,
                  SecondItem^, False);
              end;
            end;
          end;
        end
        else // quebrar receita
        begin
          Player.SendClientMessage('Receita falhou e foi perdida.');
        end;
      end;

{$ENDREGION}
  else
    Exit;

  end;

  Self.DecreaseAmount(item, Decrease);
  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
  Result := True;
end;
{$ENDREGION}
{$REGION 'Item Reinforce Stats'}
class function TItemFunctions.GetItemReinforceDamageReduction(Index: WORD;
  Refine: BYTE): WORD;
begin
  Result := Reinforce3[Self.GetItemReinforce3Index(Index)
    ].DamageReduction[Refine];
end;
class function TItemFunctions.GetItemReinforceHPMPInc(Index: WORD;
  Refine: BYTE): WORD;
begin
  Result := Reinforce3[Self.GetItemReinforce3Index(Index)
    ].HealthIncrementPoints[Refine];
end;
class function TItemFunctions.GetReinforceFromItem(const item: TItem): BYTE;
begin
  Result := 0;
  if (item.Refi = 0) then
    Exit;
  Result := Round(item.Refi / 16);
end;
{$ENDREGION}
{$REGION 'ItemDB Functions'}
class function TItemFunctions.UpdateMovedItems(var Player: TPlayer;
  SrcItemSlot, DestItemSlot: BYTE; SrcSlotType, DestSlotType: BYTE;
  SrcItem, DestItem: PItem): Boolean;
var
  SQLComp: TQuery;
begin
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[UpdateMovedItems]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[UpdateMovedItems]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    SQLComp.SetQuery
      ('UPDATE items SET slot_type=:pslot_type, slot=:pslot WHERE id=:pid');
    SQLComp.AddParameter2('pslot_type', SrcSlotType);
    SQLComp.AddParameter2('pslot', SrcItemSlot);
    // Player.PlayerSQL.AddParameter2('pid', SrcItem.Iddb);
    SQLComp.Run(False);
    SQLComp.SetQuery
      ('UPDATE items SET slot_type=:pslot_type, slot=:pslot WHERE id=:pid');
    SQLComp.AddParameter2('pslot_type', DestSlotType);
    SQLComp.AddParameter2('pslot', DestItemSlot);
    // Player.PlayerSQL.AddParameter2('pid', DestItem.Iddb);
    SQLComp.Run(False);
  except
    on E: Exception do
    begin
      Logger.Write('Erro ao salvar os itens movidos acc[' +
        String(Player.Account.Header.Username) + '] items[' +
        String(ItemList[SrcItem.Index].Name) + ' -> ' +
        String(ItemList[DestItem.Index].Name) + '] slot [' +
        SrcItemSlot.ToString + ' -> ' + DestItemSlot.ToString + '] error [' +
        E.Message + '] time [' + DateTimeToStr(Now) + ']', TLogType.Error);
    end;
  end;
  SQLComp.Destroy;
  Result := True;
end;
{$ENDREGION}
{$REGION 'Recipe Functions'}
class function TItemFunctions.GetIDRecipeArray(RecipeItemID: WORD): WORD;
var
  i: WORD;
begin
  Result := 3000;
  for i := Low(Recipes) to High(Recipes) do
  begin
    if (Recipes[i].ItemRecipeID = 0) then
      Continue;
    if (Recipes[i].ItemRecipeID = RecipeItemID) then
    begin
      Result := i;
      Break;
    end
    else
      Continue;
  end;
end;
{$ENDREGION}
end.
