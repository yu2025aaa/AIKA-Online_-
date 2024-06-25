unit AuctionFunctions;
interface
uses
  Windows, Packets, Player, MiscData;
type
  TAuctionFunctions = class(TObject)
  public
    class function GetAuctionItems(var Player: TPlayer; itemType: DWORD;
      LevelMin: WORD; LevelMax: WORD; ReinforceMin: BYTE; ReinforceMax: BYTE;
      SearchByName: DWORD): Boolean;
    class function RegisterAuctionItem(var Player: TPlayer; Price: DWORD;
      Slot: WORD; Time: WORD): Boolean;
    class function GetSelfAuctionItems(var Player: TPlayer) : Boolean;
    class function CancelItemOffer(var Player: TPlayer; AuctionOfferId:
      UInt64) : Boolean;
    class function RequestBuyItem(var Player: TPlayer; AuctionOfferId:
      UInt64): Boolean;
    class function CheckAuctionItems(): Boolean;
  private
    class function SendAuctionItems(var Player: TPlayer;
      Items: ARRAY OF TAuctionItemData; Page: DWORD): Boolean;
    class function GetAuctionItemComission(AuctionRegisterTime: WORD;
      SellingPrice: DWORD): DWORD;
    class function RegisterItemDatabase(var Player: TPlayer; Item: TItem;
      OUT AuctionItemIndex: UInt64): Boolean;
    class function RegisterOfferDatabase(var Player: TPlayer; Item: TItem;
      SellingPrice: DWORD; RegisterTime: WORD; AuctionItemIndex: UInt64;
      OUT AuctionOfferIndex: UInt64): Boolean;
    class function SendSelfAuctionItems(var Player: TPlayer;
      Items: ARRAY OF TAuctionItemData; Page: DWORD): Boolean;
    class procedure SendCancelResult(var Player: TPlayer;
      AuctionOfferId: UInt64);
    class procedure SendBuyResult(var Player: TPlayer;
      AuctionOfferId: UInt64);
    class function RegisterAquisitionMail(var Player: TPlayer;
      AuctionOfferId: UInt64; OUT MailIndex: UInt64): Boolean;
    class function RegisterSellerAquisitionMail(var Player: TPlayer;
      AuctionOfferId: UInt64; OUT MailIndex: UInt64): Boolean;
    class function RegisterReturnMail(OUT MailIndex: UInt64): Boolean;
  end;
implementation
uses
  SysUtils, GlobalDefs, AnsiStrings, ItemFunctions, DateUtils, Log, SQL;
{$REGION 'View auction items'}
class function TAuctionFunctions.GetAuctionItems(var Player: TPlayer;
  itemType: DWORD; LevelMin: WORD; LevelMax: WORD; ReinforceMin: BYTE;
  ReinforceMax: BYTE; SearchByName: DWORD): Boolean;
var
  ItemsBuffer: ARRAY [0 .. 39] OF TAuctionItemData;
  I: Integer;
  GetQuery: string;
  QueryField: string;
  auxCounter: Integer;
  pageCount: Integer;
  SQLComp: TQuery;
  xPlayer: PPlayer;
begin
  Result := True;
  ZeroMemory(@ItemsBuffer, sizeof(ItemsBuffer));

  xPlayer := @Player;

  if(xPlayer = nil) then
  begin
    Result := False;
    Exit;
  end;

  case SearchByName of
    1:
      begin
        QueryField := 'ItemType';
      end;

    257:
      begin
        QueryField := 'ItemType';

        SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
          AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
          AnsiString(MYSQL_DATABASE));
        if not(SQLComp.Query.Connection.Connected) then
        begin
          Logger.Write('Falha de conexão individual com mysql.[GetAuctionItems]',
            TlogType.Warnings);
          Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetAuctionItems]', TlogType.Error);
          SQLComp.Destroy;
          Exit;
        end;

        GetQuery :=
          Format('SELECT AuctionId, CharacterId, CharacterName, ExpireDate, ' +
          'SellingPrice, ItemId, ItemLookId, IdentificableAddOns, EffectId_1, ' +
          'EffectId_2, EffectId_3, EffectValue_1, EffectValue_2, EffectValue_3, ' +
          'DurabilityMin, DurabilityMax, Amount_Reinforce, ItemTime ' +
          'FROM '+MYSQL_DATABASE+'.vwauction_getactiveoffers WHERE %s = %d AND (ItemLevel >= %d AND ItemLevel <= %d)'
          + ' AND (ReinforceLevel >= %d AND ReinforceLevel <= %d) ORDER BY SellingPrice ASC',
          [QueryField, itemType, LevelMin, LevelMax, ReinforceMin, ReinforceMax]);
        SQLComp.SetQuery(GetQuery);
        SQLComp.Run();
        ZeroMemory(@ItemsBuffer, sizeof(ItemsBuffer));
        if (SQLComp.Query.RecordCount = 0) then
        begin
          Self.SendAuctionItems(Player, ItemsBuffer, 0);
          SQLComp.Destroy;
          Exit;
        end;

        auxCounter := 0;
        pageCount := 1;
        SQLComp.Query.First;
        for I := 0 to SQLComp.Query.RecordCount - 1 do
        begin
          if(Player.Base.GetMobClass(ItemList[SQLComp.Query.FieldByName('ItemId')
            .AsInteger].Classe) <> 0) then
          begin
            SQLComp.Query.Next;
            Continue;
          end;

          ItemsBuffer[I].SellerCharacterIndex := SQLComp.Query.FieldByName
            ('CharacterId').AsInteger;
          ItemsBuffer[I].AuctionIndex := SQLComp.Query.FieldByName
            ('AuctionId').AsInteger;
          AnsiStrings.StrPLCopy(ItemsBuffer[I].SellerCharacterName,
            AnsiString(SQLComp.Query.FieldByName('CharacterName')
            .AsString), 16);
          AnsiStrings.StrPLCopy(ItemsBuffer[I].ExpireDate,
            AnsiString(FormatDateTime('mm-dd hh:nn',
            SQLComp.Query.FieldByName('ExpireDate').AsDateTime)), 12);
          ItemsBuffer[I].ItemPrice := SQLComp.Query.FieldByName
            ('SellingPrice').AsInteger;
          ItemsBuffer[I].Item.Index := SQLComp.Query.FieldByName('ItemId')
            .AsInteger;
          ItemsBuffer[I].Item.APP := SQLComp.Query.FieldByName('ItemLookId')
            .AsInteger;
          ItemsBuffer[I].Item.Identific := SQLComp.Query.FieldByName
            ('IdentificableAddOns').AsInteger;
          ItemsBuffer[I].Item.Effects.Index[0] := SQLComp.Query.FieldByName
            ('EffectId_1').AsInteger;
          ItemsBuffer[I].Item.Effects.Index[1] := SQLComp.Query.FieldByName
            ('EffectId_2').AsInteger;
          ItemsBuffer[I].Item.Effects.Index[2] := SQLComp.Query.FieldByName
            ('EffectId_3').AsInteger;
          ItemsBuffer[I].Item.Effects.Value[0] := SQLComp.Query.FieldByName
            ('EffectValue_1').AsInteger;
          ItemsBuffer[I].Item.Effects.Value[1] := SQLComp.Query.FieldByName
            ('EffectValue_2').AsInteger;
          ItemsBuffer[I].Item.Effects.Value[2] := SQLComp.Query.FieldByName
            ('EffectValue_3').AsInteger;
          ItemsBuffer[I].Item.Min := SQLComp.Query.FieldByName
            ('DurabilityMin').AsInteger;
          ItemsBuffer[I].Item.Max := SQLComp.Query.FieldByName
            ('DurabilityMax').AsInteger;
          ItemsBuffer[I].Item.Refi := SQLComp.Query.FieldByName
            ('Amount_Reinforce').AsInteger;
          ItemsBuffer[I].Item.Time := SQLComp.Query.FieldByName('ItemTime')
            .AsInteger;
          Inc(auxCounter);
          if (auxCounter = 39) then
          begin
            Self.SendAuctionItems(Player, ItemsBuffer, pageCount);
            ZeroMemory(@ItemsBuffer, sizeof(ItemsBuffer));
            Inc(pageCount);
            auxCounter := 0;
          end;

          SQLComp.Query.Next;
        end;
        Self.SendAuctionItems(Player, ItemsBuffer, pageCount);
        SQLComp.Destroy;

        Exit;
      end;

    513:
      begin
        QueryField := 'ItemType';

        SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
          AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
          AnsiString(MYSQL_DATABASE));
        if not(SQLComp.Query.Connection.Connected) then
        begin
          Logger.Write('Falha de conexão individual com mysql.[GetAuctionItems]',
            TlogType.Warnings);
          Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetAuctionItems]', TlogType.Error);
          SQLComp.Destroy;
          Exit;
        end;

        GetQuery :=
          Format('SELECT AuctionId, CharacterId, CharacterName, ExpireDate, ' +
          'SellingPrice, ItemId, ItemLookId, IdentificableAddOns, EffectId_1, ' +
          'EffectId_2, EffectId_3, EffectValue_1, EffectValue_2, EffectValue_3, ' +
          'DurabilityMin, DurabilityMax, Amount_Reinforce, ItemTime ' +
          'FROM '+MYSQL_DATABASE+'.vwauction_getactiveoffers WHERE %s = %d AND (ItemLevel >= %d AND ItemLevel <= %d)'
          + ' AND (ReinforceLevel >= %d AND ReinforceLevel <= %d) ORDER BY SellingPrice ASC',
          [QueryField, itemType, LevelMin, LevelMax, ReinforceMin, ReinforceMax]);
        SQLComp.SetQuery(GetQuery);
        SQLComp.Run();
        ZeroMemory(@ItemsBuffer, sizeof(ItemsBuffer));
        if (SQLComp.Query.RecordCount = 0) then
        begin
          Self.SendAuctionItems(Player, ItemsBuffer, 0);
          SQLComp.Destroy;
          Exit;
        end;

        auxCounter := 0;
        pageCount := 1;
        SQLComp.Query.First;
        for I := 0 to SQLComp.Query.RecordCount - 1 do
        begin
          if(Player.Base.GetMobClass(ItemList[SQLComp.Query.FieldByName('ItemId')
            .AsInteger].Classe) <> 1) then
          begin
            SQLComp.Query.Next;
            Continue;
          end;

          ItemsBuffer[I].SellerCharacterIndex := SQLComp.Query.FieldByName
            ('CharacterId').AsInteger;
          ItemsBuffer[I].AuctionIndex := SQLComp.Query.FieldByName
            ('AuctionId').AsInteger;
          AnsiStrings.StrPLCopy(ItemsBuffer[I].SellerCharacterName,
            AnsiString(SQLComp.Query.FieldByName('CharacterName')
            .AsString), 16);
          AnsiStrings.StrPLCopy(ItemsBuffer[I].ExpireDate,
            AnsiString(FormatDateTime('mm-dd hh:nn',
            SQLComp.Query.FieldByName('ExpireDate').AsDateTime)), 12);
          ItemsBuffer[I].ItemPrice := SQLComp.Query.FieldByName
            ('SellingPrice').AsInteger;
          ItemsBuffer[I].Item.Index := SQLComp.Query.FieldByName('ItemId')
            .AsInteger;
          ItemsBuffer[I].Item.APP := SQLComp.Query.FieldByName('ItemLookId')
            .AsInteger;
          ItemsBuffer[I].Item.Identific := SQLComp.Query.FieldByName
            ('IdentificableAddOns').AsInteger;
          ItemsBuffer[I].Item.Effects.Index[0] := SQLComp.Query.FieldByName
            ('EffectId_1').AsInteger;
          ItemsBuffer[I].Item.Effects.Index[1] := SQLComp.Query.FieldByName
            ('EffectId_2').AsInteger;
          ItemsBuffer[I].Item.Effects.Index[2] := SQLComp.Query.FieldByName
            ('EffectId_3').AsInteger;
          ItemsBuffer[I].Item.Effects.Value[0] := SQLComp.Query.FieldByName
            ('EffectValue_1').AsInteger;
          ItemsBuffer[I].Item.Effects.Value[1] := SQLComp.Query.FieldByName
            ('EffectValue_2').AsInteger;
          ItemsBuffer[I].Item.Effects.Value[2] := SQLComp.Query.FieldByName
            ('EffectValue_3').AsInteger;
          ItemsBuffer[I].Item.Min := SQLComp.Query.FieldByName
            ('DurabilityMin').AsInteger;
          ItemsBuffer[I].Item.Max := SQLComp.Query.FieldByName
            ('DurabilityMax').AsInteger;
          ItemsBuffer[I].Item.Refi := SQLComp.Query.FieldByName
            ('Amount_Reinforce').AsInteger;
          ItemsBuffer[I].Item.Time := SQLComp.Query.FieldByName('ItemTime')
            .AsInteger;
          Inc(auxCounter);
          if (auxCounter = 39) then
          begin
            Self.SendAuctionItems(Player, ItemsBuffer, pageCount);
            ZeroMemory(@ItemsBuffer, sizeof(ItemsBuffer));
            Inc(pageCount);
            auxCounter := 0;
          end;

          SQLComp.Query.Next;
        end;
        Self.SendAuctionItems(Player, ItemsBuffer, pageCount);
        SQLComp.Destroy;

        Exit;
      end;

    769:
      begin
        QueryField := 'ItemType';

        SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
          AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
          AnsiString(MYSQL_DATABASE));
        if not(SQLComp.Query.Connection.Connected) then
        begin
          Logger.Write('Falha de conexão individual com mysql.[GetAuctionItems]',
            TlogType.Warnings);
          Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetAuctionItems]', TlogType.Error);
          SQLComp.Destroy;
          Exit;
        end;

        GetQuery :=
          Format('SELECT AuctionId, CharacterId, CharacterName, ExpireDate, ' +
          'SellingPrice, ItemId, ItemLookId, IdentificableAddOns, EffectId_1, ' +
          'EffectId_2, EffectId_3, EffectValue_1, EffectValue_2, EffectValue_3, ' +
          'DurabilityMin, DurabilityMax, Amount_Reinforce, ItemTime ' +
          'FROM '+MYSQL_DATABASE+'.vwauction_getactiveoffers WHERE %s = %d AND (ItemLevel >= %d AND ItemLevel <= %d)'
          + ' AND (ReinforceLevel >= %d AND ReinforceLevel <= %d) ORDER BY SellingPrice ASC',
          [QueryField, itemType, LevelMin, LevelMax, ReinforceMin, ReinforceMax]);
        SQLComp.SetQuery(GetQuery);
        SQLComp.Run();
        ZeroMemory(@ItemsBuffer, sizeof(ItemsBuffer));
        if (SQLComp.Query.RecordCount = 0) then
        begin
          Self.SendAuctionItems(Player, ItemsBuffer, 0);
          SQLComp.Destroy;
          Exit;
        end;

        auxCounter := 0;
        pageCount := 1;
        SQLComp.Query.First;
        for I := 0 to SQLComp.Query.RecordCount - 1 do
        begin
          if(Player.Base.GetMobClass(ItemList[SQLComp.Query.FieldByName('ItemId')
            .AsInteger].Classe) <> 2) then
          begin
            SQLComp.Query.Next;
            Continue;
          end;

          ItemsBuffer[I].SellerCharacterIndex := SQLComp.Query.FieldByName
            ('CharacterId').AsInteger;
          ItemsBuffer[I].AuctionIndex := SQLComp.Query.FieldByName
            ('AuctionId').AsInteger;
          AnsiStrings.StrPLCopy(ItemsBuffer[I].SellerCharacterName,
            AnsiString(SQLComp.Query.FieldByName('CharacterName')
            .AsString), 16);
          AnsiStrings.StrPLCopy(ItemsBuffer[I].ExpireDate,
            AnsiString(FormatDateTime('mm-dd hh:nn',
            SQLComp.Query.FieldByName('ExpireDate').AsDateTime)), 12);
          ItemsBuffer[I].ItemPrice := SQLComp.Query.FieldByName
            ('SellingPrice').AsInteger;
          ItemsBuffer[I].Item.Index := SQLComp.Query.FieldByName('ItemId')
            .AsInteger;
          ItemsBuffer[I].Item.APP := SQLComp.Query.FieldByName('ItemLookId')
            .AsInteger;
          ItemsBuffer[I].Item.Identific := SQLComp.Query.FieldByName
            ('IdentificableAddOns').AsInteger;
          ItemsBuffer[I].Item.Effects.Index[0] := SQLComp.Query.FieldByName
            ('EffectId_1').AsInteger;
          ItemsBuffer[I].Item.Effects.Index[1] := SQLComp.Query.FieldByName
            ('EffectId_2').AsInteger;
          ItemsBuffer[I].Item.Effects.Index[2] := SQLComp.Query.FieldByName
            ('EffectId_3').AsInteger;
          ItemsBuffer[I].Item.Effects.Value[0] := SQLComp.Query.FieldByName
            ('EffectValue_1').AsInteger;
          ItemsBuffer[I].Item.Effects.Value[1] := SQLComp.Query.FieldByName
            ('EffectValue_2').AsInteger;
          ItemsBuffer[I].Item.Effects.Value[2] := SQLComp.Query.FieldByName
            ('EffectValue_3').AsInteger;
          ItemsBuffer[I].Item.Min := SQLComp.Query.FieldByName
            ('DurabilityMin').AsInteger;
          ItemsBuffer[I].Item.Max := SQLComp.Query.FieldByName
            ('DurabilityMax').AsInteger;
          ItemsBuffer[I].Item.Refi := SQLComp.Query.FieldByName
            ('Amount_Reinforce').AsInteger;
          ItemsBuffer[I].Item.Time := SQLComp.Query.FieldByName('ItemTime')
            .AsInteger;
          Inc(auxCounter);
          if (auxCounter = 39) then
          begin
            Self.SendAuctionItems(Player, ItemsBuffer, pageCount);
            ZeroMemory(@ItemsBuffer, sizeof(ItemsBuffer));
            Inc(pageCount);
            auxCounter := 0;
          end;

          SQLComp.Query.Next;
        end;
        Self.SendAuctionItems(Player, ItemsBuffer, pageCount);
        SQLComp.Destroy;

        Exit;
      end;

    1025:
      begin
        QueryField := 'ItemType';

        SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
          AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
          AnsiString(MYSQL_DATABASE));
        if not(SQLComp.Query.Connection.Connected) then
        begin
          Logger.Write('Falha de conexão individual com mysql.[GetAuctionItems]',
            TlogType.Warnings);
          Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetAuctionItems]', TlogType.Error);
          SQLComp.Destroy;
          Exit;
        end;

        GetQuery :=
          Format('SELECT AuctionId, CharacterId, CharacterName, ExpireDate, ' +
          'SellingPrice, ItemId, ItemLookId, IdentificableAddOns, EffectId_1, ' +
          'EffectId_2, EffectId_3, EffectValue_1, EffectValue_2, EffectValue_3, ' +
          'DurabilityMin, DurabilityMax, Amount_Reinforce, ItemTime ' +
          'FROM '+MYSQL_DATABASE+'.vwauction_getactiveoffers WHERE %s = %d AND (ItemLevel >= %d AND ItemLevel <= %d)'
          + ' AND (ReinforceLevel >= %d AND ReinforceLevel <= %d) ORDER BY SellingPrice ASC',
          [QueryField, itemType, LevelMin, LevelMax, ReinforceMin, ReinforceMax]);
        SQLComp.SetQuery(GetQuery);
        SQLComp.Run();
        ZeroMemory(@ItemsBuffer, sizeof(ItemsBuffer));
        if (SQLComp.Query.RecordCount = 0) then
        begin
          Self.SendAuctionItems(Player, ItemsBuffer, 0);
          SQLComp.Destroy;
          Exit;
        end;

        auxCounter := 0;
        pageCount := 1;
        SQLComp.Query.First;
        for I := 0 to SQLComp.Query.RecordCount - 1 do
        begin
          if(Player.Base.GetMobClass(ItemList[SQLComp.Query.FieldByName('ItemId')
            .AsInteger].Classe) <> 3) then
          begin
            SQLComp.Query.Next;
            Continue;
          end;

          ItemsBuffer[I].SellerCharacterIndex := SQLComp.Query.FieldByName
            ('CharacterId').AsInteger;
          ItemsBuffer[I].AuctionIndex := SQLComp.Query.FieldByName
            ('AuctionId').AsInteger;
          AnsiStrings.StrPLCopy(ItemsBuffer[I].SellerCharacterName,
            AnsiString(SQLComp.Query.FieldByName('CharacterName')
            .AsString), 16);
          AnsiStrings.StrPLCopy(ItemsBuffer[I].ExpireDate,
            AnsiString(FormatDateTime('mm-dd hh:nn',
            SQLComp.Query.FieldByName('ExpireDate').AsDateTime)), 12);
          ItemsBuffer[I].ItemPrice := SQLComp.Query.FieldByName
            ('SellingPrice').AsInteger;
          ItemsBuffer[I].Item.Index := SQLComp.Query.FieldByName('ItemId')
            .AsInteger;
          ItemsBuffer[I].Item.APP := SQLComp.Query.FieldByName('ItemLookId')
            .AsInteger;
          ItemsBuffer[I].Item.Identific := SQLComp.Query.FieldByName
            ('IdentificableAddOns').AsInteger;
          ItemsBuffer[I].Item.Effects.Index[0] := SQLComp.Query.FieldByName
            ('EffectId_1').AsInteger;
          ItemsBuffer[I].Item.Effects.Index[1] := SQLComp.Query.FieldByName
            ('EffectId_2').AsInteger;
          ItemsBuffer[I].Item.Effects.Index[2] := SQLComp.Query.FieldByName
            ('EffectId_3').AsInteger;
          ItemsBuffer[I].Item.Effects.Value[0] := SQLComp.Query.FieldByName
            ('EffectValue_1').AsInteger;
          ItemsBuffer[I].Item.Effects.Value[1] := SQLComp.Query.FieldByName
            ('EffectValue_2').AsInteger;
          ItemsBuffer[I].Item.Effects.Value[2] := SQLComp.Query.FieldByName
            ('EffectValue_3').AsInteger;
          ItemsBuffer[I].Item.Min := SQLComp.Query.FieldByName
            ('DurabilityMin').AsInteger;
          ItemsBuffer[I].Item.Max := SQLComp.Query.FieldByName
            ('DurabilityMax').AsInteger;
          ItemsBuffer[I].Item.Refi := SQLComp.Query.FieldByName
            ('Amount_Reinforce').AsInteger;
          ItemsBuffer[I].Item.Time := SQLComp.Query.FieldByName('ItemTime')
            .AsInteger;
          Inc(auxCounter);
          if (auxCounter = 39) then
          begin
            Self.SendAuctionItems(Player, ItemsBuffer, pageCount);
            ZeroMemory(@ItemsBuffer, sizeof(ItemsBuffer));
            Inc(pageCount);
            auxCounter := 0;
          end;

          SQLComp.Query.Next;
        end;
        Self.SendAuctionItems(Player, ItemsBuffer, pageCount);
        SQLComp.Destroy;

        Exit;
      end;

    1281:
      begin
        QueryField := 'ItemType';

        SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
          AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
          AnsiString(MYSQL_DATABASE));
        if not(SQLComp.Query.Connection.Connected) then
        begin
          Logger.Write('Falha de conexão individual com mysql.[GetAuctionItems]',
            TlogType.Warnings);
          Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetAuctionItems]', TlogType.Error);
          SQLComp.Destroy;
          Exit;
        end;

        GetQuery :=
          Format('SELECT AuctionId, CharacterId, CharacterName, ExpireDate, ' +
          'SellingPrice, ItemId, ItemLookId, IdentificableAddOns, EffectId_1, ' +
          'EffectId_2, EffectId_3, EffectValue_1, EffectValue_2, EffectValue_3, ' +
          'DurabilityMin, DurabilityMax, Amount_Reinforce, ItemTime ' +
          'FROM '+MYSQL_DATABASE+'.vwauction_getactiveoffers WHERE %s = %d AND (ItemLevel >= %d AND ItemLevel <= %d)'
          + ' AND (ReinforceLevel >= %d AND ReinforceLevel <= %d) ORDER BY SellingPrice ASC',
          [QueryField, itemType, LevelMin, LevelMax, ReinforceMin, ReinforceMax]);
        SQLComp.SetQuery(GetQuery);
        SQLComp.Run();
        ZeroMemory(@ItemsBuffer, sizeof(ItemsBuffer));
        if (SQLComp.Query.RecordCount = 0) then
        begin
          Self.SendAuctionItems(Player, ItemsBuffer, 0);
          SQLComp.Destroy;
          Exit;
        end;

        auxCounter := 0;
        pageCount := 1;
        SQLComp.Query.First;
        for I := 0 to SQLComp.Query.RecordCount - 1 do
        begin
          if(Player.Base.GetMobClass(ItemList[SQLComp.Query.FieldByName('ItemId')
            .AsInteger].Classe) <> 4) then
          begin
            SQLComp.Query.Next;
            Continue;
          end;

          ItemsBuffer[I].SellerCharacterIndex := SQLComp.Query.FieldByName
            ('CharacterId').AsInteger;
          ItemsBuffer[I].AuctionIndex := SQLComp.Query.FieldByName
            ('AuctionId').AsInteger;
          AnsiStrings.StrPLCopy(ItemsBuffer[I].SellerCharacterName,
            AnsiString(SQLComp.Query.FieldByName('CharacterName')
            .AsString), 16);
          AnsiStrings.StrPLCopy(ItemsBuffer[I].ExpireDate,
            AnsiString(FormatDateTime('mm-dd hh:nn',
            SQLComp.Query.FieldByName('ExpireDate').AsDateTime)), 12);
          ItemsBuffer[I].ItemPrice := SQLComp.Query.FieldByName
            ('SellingPrice').AsInteger;
          ItemsBuffer[I].Item.Index := SQLComp.Query.FieldByName('ItemId')
            .AsInteger;
          ItemsBuffer[I].Item.APP := SQLComp.Query.FieldByName('ItemLookId')
            .AsInteger;
          ItemsBuffer[I].Item.Identific := SQLComp.Query.FieldByName
            ('IdentificableAddOns').AsInteger;
          ItemsBuffer[I].Item.Effects.Index[0] := SQLComp.Query.FieldByName
            ('EffectId_1').AsInteger;
          ItemsBuffer[I].Item.Effects.Index[1] := SQLComp.Query.FieldByName
            ('EffectId_2').AsInteger;
          ItemsBuffer[I].Item.Effects.Index[2] := SQLComp.Query.FieldByName
            ('EffectId_3').AsInteger;
          ItemsBuffer[I].Item.Effects.Value[0] := SQLComp.Query.FieldByName
            ('EffectValue_1').AsInteger;
          ItemsBuffer[I].Item.Effects.Value[1] := SQLComp.Query.FieldByName
            ('EffectValue_2').AsInteger;
          ItemsBuffer[I].Item.Effects.Value[2] := SQLComp.Query.FieldByName
            ('EffectValue_3').AsInteger;
          ItemsBuffer[I].Item.Min := SQLComp.Query.FieldByName
            ('DurabilityMin').AsInteger;
          ItemsBuffer[I].Item.Max := SQLComp.Query.FieldByName
            ('DurabilityMax').AsInteger;
          ItemsBuffer[I].Item.Refi := SQLComp.Query.FieldByName
            ('Amount_Reinforce').AsInteger;
          ItemsBuffer[I].Item.Time := SQLComp.Query.FieldByName('ItemTime')
            .AsInteger;
          Inc(auxCounter);
          if (auxCounter = 39) then
          begin
            Self.SendAuctionItems(Player, ItemsBuffer, pageCount);
            ZeroMemory(@ItemsBuffer, sizeof(ItemsBuffer));
            Inc(pageCount);
            auxCounter := 0;
          end;

          SQLComp.Query.Next;
        end;
        Self.SendAuctionItems(Player, ItemsBuffer, pageCount);
        SQLComp.Destroy;

        Exit;
      end;

    1537:
      begin
        QueryField := 'ItemType';

        SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
          AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
          AnsiString(MYSQL_DATABASE));
        if not(SQLComp.Query.Connection.Connected) then
        begin
          Logger.Write('Falha de conexão individual com mysql.[GetAuctionItems]',
            TlogType.Warnings);
          Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetAuctionItems]', TlogType.Error);
          SQLComp.Destroy;
          Exit;
        end;

        GetQuery :=
          Format('SELECT AuctionId, CharacterId, CharacterName, ExpireDate, ' +
          'SellingPrice, ItemId, ItemLookId, IdentificableAddOns, EffectId_1, ' +
          'EffectId_2, EffectId_3, EffectValue_1, EffectValue_2, EffectValue_3, ' +
          'DurabilityMin, DurabilityMax, Amount_Reinforce, ItemTime ' +
          'FROM '+MYSQL_DATABASE+'.vwauction_getactiveoffers WHERE %s = %d AND (ItemLevel >= %d AND ItemLevel <= %d)'
          + ' AND (ReinforceLevel >= %d AND ReinforceLevel <= %d) ORDER BY SellingPrice ASC',
          [QueryField, itemType, LevelMin, LevelMax, ReinforceMin, ReinforceMax]);
        SQLComp.SetQuery(GetQuery);
        SQLComp.Run();
        ZeroMemory(@ItemsBuffer, sizeof(ItemsBuffer));
        if (SQLComp.Query.RecordCount = 0) then
        begin
          Self.SendAuctionItems(Player, ItemsBuffer, 0);
          SQLComp.Destroy;
          Exit;
        end;

        auxCounter := 0;
        pageCount := 1;
        SQLComp.Query.First;
        for I := 0 to SQLComp.Query.RecordCount - 1 do
        begin
          if(Player.Base.GetMobClass(ItemList[SQLComp.Query.FieldByName('ItemId')
            .AsInteger].Classe) <> 5) then
          begin
            SQLComp.Query.Next;
            Continue;
          end;

          ItemsBuffer[I].SellerCharacterIndex := SQLComp.Query.FieldByName
            ('CharacterId').AsInteger;
          ItemsBuffer[I].AuctionIndex := SQLComp.Query.FieldByName
            ('AuctionId').AsInteger;
          AnsiStrings.StrPLCopy(ItemsBuffer[I].SellerCharacterName,
            AnsiString(SQLComp.Query.FieldByName('CharacterName')
            .AsString), 16);
          AnsiStrings.StrPLCopy(ItemsBuffer[I].ExpireDate,
            AnsiString(FormatDateTime('mm-dd hh:nn',
            SQLComp.Query.FieldByName('ExpireDate').AsDateTime)), 12);
          ItemsBuffer[I].ItemPrice := SQLComp.Query.FieldByName
            ('SellingPrice').AsInteger;
          ItemsBuffer[I].Item.Index := SQLComp.Query.FieldByName('ItemId')
            .AsInteger;
          ItemsBuffer[I].Item.APP := SQLComp.Query.FieldByName('ItemLookId')
            .AsInteger;
          ItemsBuffer[I].Item.Identific := SQLComp.Query.FieldByName
            ('IdentificableAddOns').AsInteger;
          ItemsBuffer[I].Item.Effects.Index[0] := SQLComp.Query.FieldByName
            ('EffectId_1').AsInteger;
          ItemsBuffer[I].Item.Effects.Index[1] := SQLComp.Query.FieldByName
            ('EffectId_2').AsInteger;
          ItemsBuffer[I].Item.Effects.Index[2] := SQLComp.Query.FieldByName
            ('EffectId_3').AsInteger;
          ItemsBuffer[I].Item.Effects.Value[0] := SQLComp.Query.FieldByName
            ('EffectValue_1').AsInteger;
          ItemsBuffer[I].Item.Effects.Value[1] := SQLComp.Query.FieldByName
            ('EffectValue_2').AsInteger;
          ItemsBuffer[I].Item.Effects.Value[2] := SQLComp.Query.FieldByName
            ('EffectValue_3').AsInteger;
          ItemsBuffer[I].Item.Min := SQLComp.Query.FieldByName
            ('DurabilityMin').AsInteger;
          ItemsBuffer[I].Item.Max := SQLComp.Query.FieldByName
            ('DurabilityMax').AsInteger;
          ItemsBuffer[I].Item.Refi := SQLComp.Query.FieldByName
            ('Amount_Reinforce').AsInteger;
          ItemsBuffer[I].Item.Time := SQLComp.Query.FieldByName('ItemTime')
            .AsInteger;
          Inc(auxCounter);
          if (auxCounter = 39) then
          begin
            Self.SendAuctionItems(Player, ItemsBuffer, pageCount);
            ZeroMemory(@ItemsBuffer, sizeof(ItemsBuffer));
            Inc(pageCount);
            auxCounter := 0;
          end;

          SQLComp.Query.Next;
        end;
        Self.SendAuctionItems(Player, ItemsBuffer, pageCount);
        SQLComp.Destroy;

        Exit;
      end;

    else
      begin
        QueryField := 'ItemId';
      end;
  end;


  {if (SearchByName = 1) then
  begin

  end
  else
  begin
    //QueryField := 'ItemId';
  end; }
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GetAuctionItems]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetAuctionItems]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  GetQuery :=
    Format('SELECT AuctionId, CharacterId, CharacterName, ExpireDate, ' +
    'SellingPrice, ItemId, ItemLookId, IdentificableAddOns, EffectId_1, ' +
    'EffectId_2, EffectId_3, EffectValue_1, EffectValue_2, EffectValue_3, ' +
    'DurabilityMin, DurabilityMax, Amount_Reinforce, ItemTime ' +
    'FROM '+MYSQL_DATABASE+'.vwauction_getactiveoffers WHERE %s = %d AND (ItemLevel >= %d AND ItemLevel <= %d)'
    + ' AND (ReinforceLevel >= %d AND ReinforceLevel <= %d) ORDER BY SellingPrice ASC',
    [QueryField, itemType, LevelMin, LevelMax, ReinforceMin, ReinforceMax]);
  SQLComp.SetQuery(GetQuery);
  SQLComp.Run();
  ZeroMemory(@ItemsBuffer, sizeof(ItemsBuffer));
  if (SQLComp.Query.RecordCount = 0) then
  begin
    Self.SendAuctionItems(Player, ItemsBuffer, 0);
    SQLComp.Destroy;
    Exit;
  end;
  auxCounter := 0;
  pageCount := 1;
  SQLComp.Query.First;
  for I := 0 to SQLComp.Query.RecordCount - 1 do
  begin
    ItemsBuffer[I].SellerCharacterIndex := SQLComp.Query.FieldByName
      ('CharacterId').AsInteger;
    ItemsBuffer[I].AuctionIndex := SQLComp.Query.FieldByName
      ('AuctionId').AsInteger;
    AnsiStrings.StrPLCopy(ItemsBuffer[I].SellerCharacterName,
      AnsiString(SQLComp.Query.FieldByName('CharacterName')
      .AsString), 16);
    AnsiStrings.StrPLCopy(ItemsBuffer[I].ExpireDate,
      AnsiString(FormatDateTime('mm-dd hh:nn',
      SQLComp.Query.FieldByName('ExpireDate').AsDateTime)), 12);
    ItemsBuffer[I].ItemPrice := SQLComp.Query.FieldByName
      ('SellingPrice').AsInteger;
    ItemsBuffer[I].Item.Index := SQLComp.Query.FieldByName('ItemId')
      .AsInteger;
    ItemsBuffer[I].Item.APP := SQLComp.Query.FieldByName('ItemLookId')
      .AsInteger;
    ItemsBuffer[I].Item.Identific := SQLComp.Query.FieldByName
      ('IdentificableAddOns').AsInteger;
    ItemsBuffer[I].Item.Effects.Index[0] := SQLComp.Query.FieldByName
      ('EffectId_1').AsInteger;
    ItemsBuffer[I].Item.Effects.Index[1] := SQLComp.Query.FieldByName
      ('EffectId_2').AsInteger;
    ItemsBuffer[I].Item.Effects.Index[2] := SQLComp.Query.FieldByName
      ('EffectId_3').AsInteger;
    ItemsBuffer[I].Item.Effects.Value[0] := SQLComp.Query.FieldByName
      ('EffectValue_1').AsInteger;
    ItemsBuffer[I].Item.Effects.Value[1] := SQLComp.Query.FieldByName
      ('EffectValue_2').AsInteger;
    ItemsBuffer[I].Item.Effects.Value[2] := SQLComp.Query.FieldByName
      ('EffectValue_3').AsInteger;
    ItemsBuffer[I].Item.Min := SQLComp.Query.FieldByName
      ('DurabilityMin').AsInteger;
    ItemsBuffer[I].Item.Max := SQLComp.Query.FieldByName
      ('DurabilityMax').AsInteger;
    ItemsBuffer[I].Item.Refi := SQLComp.Query.FieldByName
      ('Amount_Reinforce').AsInteger;
    ItemsBuffer[I].Item.Time := SQLComp.Query.FieldByName('ItemTime')
      .AsInteger;
    Inc(auxCounter);
    if (auxCounter = 39) then
    begin
      Self.SendAuctionItems(Player, ItemsBuffer, pageCount);
      ZeroMemory(@ItemsBuffer, sizeof(ItemsBuffer));
      Inc(pageCount);
      auxCounter := 0;
    end;
    //if ((I + 1) < SQLComp.Query.RecordCount) then
    //begin
      SQLComp.Query.Next;
    //end;
  end;

  if(xPlayer = nil) then
  begin
    SQLComp.Destroy;
    Exit;
  end;
  if(auxCounter <> 0) then
    Self.SendAuctionItems(xPlayer^, ItemsBuffer, pageCount);
  SQLComp.Destroy;
end;
class function TAuctionFunctions.SendAuctionItems(var Player: TPlayer;
  Items: ARRAY OF TAuctionItemData; Page: DWORD): Boolean;
var
  Packet: TSendAuctionItemsPacket;
begin
  Result := True;
  ZeroMemory(@Packet, sizeof(TSendAuctionItemsPacket));
  Packet.Header.Size := sizeof(TSendAuctionItemsPacket);
  Packet.Header.Index := Player.Base.ClientID;
  Packet.Header.Code := $3F0D;
  try
    if (Length(Items) > 40) then
    begin
      Result := false;
      Exit;
    end;
    move(Items, Packet.Items, sizeof(Packet.Items));
  except
    Result := false;
  end;
  Packet.ItemCount := Page;
  Player.SendPacket(Packet, Packet.Header.Size);
end;
{$ENDREGION}
{$REGION 'View self auction items'}
class function TAuctionFunctions.GetSelfAuctionItems(var Player: TPlayer): Boolean;
var
  QueryString: string;
  ItemsBuffer: ARRAY [0 .. 11] OF TAuctionItemData;
  I, j: Integer;
  SQLComp: TQuery;
begin
  Result := True;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GetSelfAuctionItems]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetSelfAuctionItems]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  QueryString :=
    Format('SELECT AuctionId, CharacterId, CharacterName, ExpireDate, ' +
    'SellingPrice, ItemId, ItemLookId, IdentificableAddOns, EffectId_1, ' +
    'EffectId_2, EffectId_3, EffectValue_1, EffectValue_2, EffectValue_3, ' +
    'DurabilityMin, DurabilityMax, Amount_Reinforce, ItemTime ' +
    'FROM '+MYSQL_DATABASE+'.vwauction_getactiveoffers WHERE CharacterId = %d ORDER BY SellingPrice ASC LIMIT 12',
    [Player.Base.Character.CharIndex]);
  SQLComp.SetQuery(QueryString);
  SQLComp.Run();
  ZeroMemory(@ItemsBuffer, sizeof(ItemsBuffer));
  if (SQLComp.Query.RecordCount = 0) then
  begin
    Self.SendSelfAuctionItems(Player, ItemsBuffer, 0);
    Exit;
  end;
  SQLComp.Query.First;
  for I := 0 to SQLComp.Query.RecordCount - 1 do
  begin
    ItemsBuffer[I].SellerCharacterIndex := SQLComp.Query.FieldByName
      ('CharacterId').AsInteger;
    ItemsBuffer[I].AuctionIndex := SQLComp.Query.FieldByName
      ('AuctionId').AsInteger;
    AnsiStrings.StrPLCopy(ItemsBuffer[I].SellerCharacterName,
      AnsiString(SQLComp.Query.FieldByName('CharacterName')
      .AsString), 16);
    AnsiStrings.StrPLCopy(ItemsBuffer[I].ExpireDate,
      AnsiString(FormatDateTime('mm-dd hh:nn',
      SQLComp.Query.FieldByName('ExpireDate').AsDateTime)), 12);
    ItemsBuffer[I].ItemPrice := SQLComp.Query.FieldByName
      ('SellingPrice').AsInteger;
    ItemsBuffer[I].Item.Index := SQLComp.Query.FieldByName('ItemId')
      .AsInteger;
    ItemsBuffer[I].Item.APP := SQLComp.Query.FieldByName('ItemLookId')
      .AsInteger;
    ItemsBuffer[I].Item.Identific := SQLComp.Query.FieldByName
      ('IdentificableAddOns').AsInteger;
    ItemsBuffer[I].Item.Effects.Index[0] := SQLComp.Query.FieldByName
      ('EffectId_1').AsInteger;
    ItemsBuffer[I].Item.Effects.Index[1] := SQLComp.Query.FieldByName
      ('EffectId_2').AsInteger;
    ItemsBuffer[I].Item.Effects.Index[2] := SQLComp.Query.FieldByName
      ('EffectId_3').AsInteger;
    ItemsBuffer[I].Item.Effects.Value[0] := SQLComp.Query.FieldByName
      ('EffectValue_1').AsInteger;
    ItemsBuffer[I].Item.Effects.Value[1] := SQLComp.Query.FieldByName
      ('EffectValue_2').AsInteger;
    ItemsBuffer[I].Item.Effects.Value[2] := SQLComp.Query.FieldByName
      ('EffectValue_3').AsInteger;
    ItemsBuffer[I].Item.Min := SQLComp.Query.FieldByName
      ('DurabilityMin').AsInteger;
    ItemsBuffer[I].Item.Max := SQLComp.Query.FieldByName
      ('DurabilityMax').AsInteger;
    ItemsBuffer[I].Item.Refi := SQLComp.Query.FieldByName
      ('Amount_Reinforce').AsInteger;
    ItemsBuffer[I].Item.Time := SQLComp.Query.FieldByName('ItemTime')
      .AsInteger;

    SQLComp.Query.Next;
  end;
  j := SQLComp.Query.RecordCount;
  SQLComp.Destroy;
  Self.SendSelfAuctionItems(Player, ItemsBuffer, j);
end;
class function TAuctionFunctions.SendSelfAuctionItems(var Player: TPlayer;
  Items: ARRAY OF TAuctionItemData; Page: DWORD): Boolean;
var
  Packet: TCadastredItemsPacket;
begin
  Result := True;
  ZeroMemory(@Packet, sizeof(TCadastredItemsPacket));
  Packet.Header.Size := sizeof(TCadastredItemsPacket);
  Packet.Header.Index := Player.Base.ClientID;
  Packet.Header.Code := $3F11;
  try
    if (Length(Items) > 12) then
    begin
      Result := false;
      Exit;
    end;
    move(Items, Packet.Items, sizeof(Packet.Items));
  except
    Result := false;
  end;
  Packet.ItemCount := Page;
  Player.SendPacket(Packet, Packet.Header.Size);
end;
{$ENDREGION}
{$REGION 'Register auction item'}
class function TAuctionFunctions.RegisterAuctionItem(var Player: TPlayer;
  Price: DWORD; Slot: WORD; Time: WORD): Boolean;
var
  RegisterTax: DWORD;
  RegisterItem: PItem;
  AuctionItemIndex: UInt64;
  AuctionOfferIndex: UInt64;
begin
  Result := True;
  RegisterTax := Self.GetAuctionItemComission(Time, Price);
  RegisterItem := @Player.Base.Character.Inventory[Slot];
  if (RegisterTax > Player.Base.Character.Gold) then
  begin
    Player.SendClientMessage('Gold insuficiente! estranho !!!!!');
    Exit;
  end;
  if (RegisterItem.Index = 0) then
  begin
    Result := false;
    Exit;
  end;
  if (ItemList[RegisterItem.Index].TypeTrade > 0) then
  begin
    Player.SendClientMessage('Item não comercializavel! estranho !!!!!');
    Exit;
  end;
  if not(Self.RegisterItemDatabase(Player, RegisterItem^, AuctionItemIndex))
  then
  begin
    Result := false;
    Exit;
  end;
  if not(Self.RegisterOfferDatabase(Player, RegisterItem^, Price, Time,
    AuctionItemIndex, AuctionOfferIndex)) then
  begin
    Result := false;
    Exit;
  end;
  ZeroMemory(RegisterItem, sizeof(TItem));
  Player.Base.SendRefreshItemSlot(Slot, false);
  Player.DecGold(RegisterTax);
  Player.SendData(Player.Base.ClientID, $3F0B, 1);
  Self.GetSelfAuctionItems(Player);
end;
class function TAuctionFunctions.GetAuctionItemComission(AuctionRegisterTime
  : WORD; SellingPrice: DWORD): DWORD;
var
  sellPriceCalculated: DWORD;
begin
  sellPriceCalculated := Trunc(SellingPrice / 1000);
  if (SellingPrice < 1000) then
  begin
    sellPriceCalculated := Round(SellingPrice / 1000);
  end;
  Result := Round(sellPriceCalculated * (AuctionRegisterTime / 3));
end;
class function TAuctionFunctions.RegisterItemDatabase(var Player: TPlayer;
  Item: TItem; OUT AuctionItemIndex: UInt64): Boolean;
var
  QueryString: string;
  SQLComp: TQuery;
begin
  Result := True;
  AuctionItemIndex := 0;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[RegisterItemDatabase]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[RegisterItemDatabase]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    QueryString :=
      Format('INSERT INTO auction_items (item_id, app, identific, effect1_index,'
      + 'effect2_index, effect3_index, effect1_value, effect2_value, effect3_value, '
      + 'min, max, refine, time) VALUES (%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d);',
      [Item.Index, Item.APP, Item.Identific, Item.Effects.Index[0],
      Item.Effects.Index[1], Item.Effects.Index[2], Item.Effects.Value[0],
      Item.Effects.Value[1], Item.Effects.Value[2], Item.Min, Item.Max,
      Item.Refi, Item.Time]);
    SQLComp.Query.Connection.StartTransaction;
    SQLComp.SetQuery(QueryString);
    SQLComp.Run(False);
    SQLComp.Query.Connection.Commit;
    if (SQLComp.Query.RowsAffected = 0) then
    begin
      SQLComp.Destroy;
      Result := false;
      Exit;
    end;
    QueryString := 'SELECT max(id) as idx from auction_items;';
    SQLComp.SetQuery(QueryString);
    SQLComp.Run();
    AuctionItemIndex := SQLComp.Query.FieldByName('idx').AsInteger;
    if AuctionItemIndex = 0 then
    begin
      SQLComp.Destroy;
      Result := false;
      Exit;
    end;
  except
    begin
      SQLComp.Destroy;
      Result := false;
    end;
  end;
  SQLComp.Destroy;
end;
class function TAuctionFunctions.RegisterOfferDatabase(var Player: TPlayer;
  Item: TItem; SellingPrice: DWORD; RegisterTime: WORD;
  AuctionItemIndex: UInt64; OUT AuctionOfferIndex: UInt64): Boolean;
var
  QueryString: string;
  ItemLevel: WORD;
  ItemReinforce: WORD;
  SQLComp: TQuery;
begin
  Result := True;
  AuctionOfferIndex := 0;
  ItemLevel := ItemList[Item.Index].Level;
  if (ItemLevel = 0) then
  begin
    ItemLevel := 1;
  end;
  // Checa se o item pode ser Reforçado e seta um valor padrão caso não
  // Media para evitar problemas no filtro de Reforço
  if (ItemList[Item.Index].Fortification) and (ItemList[Item.Index].Classe > 0) then
  begin
    ItemReinforce := Trunc(Item.Refi / 16);
  end
  else
  begin
    ItemReinforce := 1;
  end;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[RegisterOfferDatabase]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[RegisterOfferDatabase]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    QueryString :=
      Format('INSERT INTO auction (CharacterId, ItemType, ItemLevel, ReinforceLevel, '
      + 'RegisterDate, RegisterTime, SellingPrice, auction_itemsId) VALUES (%d, %d, %d, %d, "%s", %d, %d, %d);',
      [Player.Base.Character.CharIndex, ItemList[Item.Index].itemType,
      ItemLevel, ItemReinforce, FormatDateTime('yyyy-mm-dd hh:nn:ss', Now()),
      RegisterTime, SellingPrice, AuctionItemIndex]);
    SQLComp.Query.Connection.StartTransaction;
    SQLComp.SetQuery(QueryString);
    SQLComp.Run(False);
    SQLComp.Query.Connection.Commit;
    if (SQLComp.Query.RowsAffected = 0) then
    begin
      SQLComp.Destroy;
      Result := false;
      Exit;
    end;
    QueryString := 'SELECT max(AuctionId) as idx from auction;';
    SQLComp.SetQuery(QueryString);
    SQLComp.Run();
    AuctionOfferIndex := SQLComp.Query.FieldByName('idx').AsInteger;
    if AuctionOfferIndex = 0 then
    begin
      SQLComp.Destroy;
      Result := false;
      Exit;
    end;
  except
     begin
      SQLComp.Destroy;
      Result := false;
      Exit;
    end;
  end;
  SQLComp.Destroy;
end;
{$ENDREGION}
{$REGION 'Cancel item offer'}
class function TAuctionFunctions.CancelItemOffer(var Player: TPlayer;
  AuctionOfferId: UInt64) : Boolean;
var
  QueryString: string;
  Item: TItem;
  SQLComp: TQuery;
begin
  Result := True;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[CancelItemOffer]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[CancelItemOffer]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    QueryString :=
      Format('SELECT ItemId, ItemLookId, IdentificableAddOns, EffectId_1, ' +
        'EffectId_2, EffectId_3, EffectValue_1, EffectValue_2, EffectValue_3, ' +
        'DurabilityMin, DurabilityMax, Amount_Reinforce, ItemTime ' +
        'FROM '+MYSQL_DATABASE+'.vwauction_getactiveoffers WHERE CharacterId = %d AND AuctionId = %d',
        [Player.Base.Character.CharIndex, AuctionOfferId]);
    SQLComp.SetQuery(QueryString);
    SQLComp.Run();
    if (SQLComp.Query.RecordCount = 0) then
    begin
      SQLComp.Destroy;
      Result := False;
      Exit;
    end;
    ZeroMemory(@Item, sizeof(TItem));
    {$REGION 'Set Item Data'}
    Item.Index := SQLComp.Query.FieldByName('ItemId')
      .AsInteger;
    Item.APP := SQLComp.Query.FieldByName('ItemLookId')
      .AsInteger;
    Item.Identific := SQLComp.Query.FieldByName
      ('IdentificableAddOns').AsInteger;
    Item.Effects.Index[0] := SQLComp.Query.FieldByName
      ('EffectId_1').AsInteger;
    Item.Effects.Index[1] := SQLComp.Query.FieldByName
      ('EffectId_2').AsInteger;
    Item.Effects.Index[2] := SQLComp.Query.FieldByName
      ('EffectId_3').AsInteger;
    Item.Effects.Value[0] := SQLComp.Query.FieldByName
      ('EffectValue_1').AsInteger;
    Item.Effects.Value[1] := SQLComp.Query.FieldByName
      ('EffectValue_2').AsInteger;
    Item.Effects.Value[2] := SQLComp.Query.FieldByName
      ('EffectValue_3').AsInteger;
    Item.Min := SQLComp.Query.FieldByName
      ('DurabilityMin').AsInteger;
    Item.Max := SQLComp.Query.FieldByName
      ('DurabilityMax').AsInteger;
    Item.Refi := SQLComp.Query.FieldByName
      ('Amount_Reinforce').AsInteger;
    Item.Time := SQLComp.Query.FieldByName('ItemTime')
      .AsInteger;
    {$ENDREGION}
    QueryString :=
      Format('UPDATE auction SET Active = 0 WHERE AuctionId = %d',
        [AuctionOfferId]);
    SQLComp.Query.Connection.StartTransaction;
    SQLComp.SetQuery(QueryString);
    SQLComp.Run(False);
    SQLComp.Query.Connection.Commit;
    if (SQLComp.Query.RowsAffected = 0) then
    begin
      SQLComp.Destroy;
      Result := False;
      Exit;
    end;
    Self.SendCancelResult(Player, AuctionOfferId);
    TItemFunctions.PutItem(Player, Item, 0, True);
  except
    begin
      SQLComp.Destroy;
      Result := False;
    end;
  end;
  SQLComp.Destroy;
end;
class procedure TAuctionFunctions.SendCancelResult(var Player: TPlayer;
  AuctionOfferId: UInt64);
var
  Packet: TAuctionCancelOfferPacket;
begin
  ZeroMemory(@Packet, sizeof(TAuctionCancelOfferPacket));
  Packet.Header.Size := sizeof(TAuctionCancelOfferPacket);
  Packet.Header.Index := Player.Base.ClientID;
  Packet.Header.Code := $3F10;
  Packet.AuctionOfferId := AuctionOfferId;
  Packet.ResponseStatus := 1;
  Player.SendPacket(Packet, Packet.Header.Size);
end;
{$ENDREGION}
{$REGION 'Buy item offer'}

class function TAuctionFunctions.RequestBuyItem(var Player: TPlayer; AuctionOfferId:
  UInt64): Boolean;
var
  QueryString: string;
  AcquisitionMailId: UInt64;
  AcquisitionMailItemId: UInt64;
  AcquisitionSellerMailId: UInt64;
  SellingPrice: DWORD;
  SQLComp: TQuery;
begin
  Result := True;
  AcquisitionMailId := 0;
  try
    if not(Self.RegisterAquisitionMail(Player, AuctionOfferId, AcquisitionMailId)) then
    begin
      Result := False;
      Exit;
    end;
    if not(Self.RegisterSellerAquisitionMail(Player, AuctionOfferId, AcquisitionSellerMailId)) then
    begin
      Result := False;
      Exit;
    end;
    SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);
    if not(SQLComp.Query.Connection.Connected) then
    begin
      Logger.Write('Falha de conexão individual com mysql.[RequestBuyItem]',
        TlogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[RequestBuyItem]', TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
    QueryString :=
      Format('INSERT INTO mails_items (mail_id, slot, item_id, app, identific, effect1_index, effect1_value, '+
        'effect2_index, effect2_value, effect3_index, effect3_value, min, max, refine, `time`) '+
        'SELECT %d AS MailIndex, 0, ItemId, ItemLookId, IdentificableAddOns, EffectId_1, EffectValue_1, EffectId_2, EffectValue_2, '+
        'EffectId_3, EffectValue_3, DurabilityMin, DurabilityMax, Amount_Reinforce, ItemTime '+
        'FROM '+MYSQL_DATABASE+'.vwauction_getactiveoffers WHERE AuctionId=%d;',
        [
            AcquisitionMailId,
            AuctionOfferId,
            AuctionOfferId
        ]);

    SQLComp.SetQuery(QueryString);
    SQLComp.Query.Connection.StartTransaction;
    SQLComp.Run(False);
    SQLComp.Query.Connection.Commit;
    if (SQLComp.Query.RowsAffected = 0) then
    begin
      SQLComp.Destroy;
      Result := False;
      Exit;
    end;

    QueryString := Format('UPDATE auction SET Active=0 WHERE AuctionId=%d;',
      [AuctionOfferId]);
    SQLComp.SetQuery(QueryString);
    SQLComp.Query.Connection.StartTransaction;
    SQLComp.Run(False);
    SQLComp.Query.Connection.Commit;
    if (SQLComp.Query.RowsAffected = 0) then
    begin
      SQLComp.Destroy;
      Result := False;
      Exit;
    end;

    QueryString := 'SELECT max(id) as idx from mails_items;';
    SQLComp.SetQuery(QueryString);
    SQLComp.Run();
    AcquisitionMailItemId := SQLComp.Query.FieldByName('idx').AsLargeInt;
    if AcquisitionMailItemId = 0 then
    begin
      SQLComp.Destroy;
      Result := False;
      Exit;
    end;

    QueryString := Format('SELECT SellingPrice FROM auction WHERE AuctionId=%d', [AuctionOfferId]);
    SQLComp.SetQuery(QueryString);
    SQLComp.Run();
    if (SQLComp.Query.RecordCount = 0) then
    begin
      SQLComp.Destroy;
      Result := False;
      Exit;
    end;

    SellingPrice := SQLComp.Query.FieldByName('SellingPrice').AsLargeInt;
    if (SellingPrice > Player.Base.Character.Gold) then
    begin
      SQLComp.Destroy;
      Player.SendClientMessage('Gold insuficiente! estranho !!!!!');
      Exit;
    end;

    Player.DecGold(SellingPrice);
    Self.SendBuyResult(Player, AuctionOfferId);
    Player.SendClientMessage('O item comprado será entregue por correio');
  except
    begin
      SQLComp.Destroy;
      Result := False;
      Exit;
    end;
  end;
  SQLComp.Destroy;
end;

class procedure TAuctionFunctions.SendBuyResult(var Player: TPlayer;
  AuctionOfferId: UInt64);
var
  Packet: TAuctionBuyOfferPacket;
begin
  ZeroMemory(@Packet, sizeof(TAuctionBuyOfferPacket));
  Packet.Header.Size := sizeof(TAuctionBuyOfferPacket);
  Packet.Header.Index := Player.Base.ClientID;
  Packet.Header.Code := $3F0C;
  Packet.AuctionOfferId := AuctionOfferId;
  Packet.ResponseStatus := 256;
  Player.SendPacket(Packet, Packet.Header.Size);
end;

class function TAuctionFunctions.RegisterAquisitionMail(var Player: TPlayer;
  AuctionOfferId: UInt64; OUT MailIndex: UInt64): Boolean;
var
  QueryString: string;
  SQLComp: TQuery;
begin
  Result := True;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[RegisterAquisitionMail]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[RegisterAquisitionMail]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    QueryString := 'SELECT CharacterId from auction where AuctionId = ' +
      AuctionOfferId.ToString;
    SQLComp.SetQuery(QueryString);
    SQLComp.Run();
    if(SQLComp.Query.RecordCount = 0) then
    begin
      SQLComp.Destroy;
      Result := False;
      Exit;
    end;
    if(Player.Base.Character.CharIndex = SQLComp.Query.Fields[0].AsInteger) then
    begin
      Player.SendClientMessage('Você não pode comprar seu própio item.');
      SQLComp.Destroy;
      Result := False;
      Exit;
    end;
    QueryString :=
      Format('INSERT INTO mails (characterId, sentCharacterId, sentCharacterName, title, ' +
        'textBody, slot, sentGold, gold, returnDate, ' +
        'sentDate, isFromAuction, canReturn, hasItems) VALUES (%d, 1, "Casa de Leilões", '+
        '"Item Comprado", "Entrega de item adquirido na casa de leilões", 0, '+
        '0, 0, "%s", "%s", 1, 0, 1);',
        [
          Player.Base.Character.CharIndex,
          FormatDateTime('yyyy-mm-dd hh:nn:ss', IncDay(Now, 90)),
          FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)
        ]);

    SQLComp.SetQuery(QueryString);
    SQLComp.Query.Connection.StartTransaction;
    SQLComp.Run(False);
    SQLComp.Query.Connection.Commit;

    if (SQLComp.Query.RowsAffected = 0) then
    begin
      SQLComp.Destroy;
      Result := False;
      Exit;
    end;

    QueryString := 'SELECT max(id) as idx from mails;';
    SQLComp.SetQuery(QueryString);
    SQLComp.Run();
    MailIndex := UInt64(SQLComp.Query.FieldByName('idx').AsLargeInt);
    if MailIndex = 0 then
    begin
      SQLComp.Destroy;
      Result := False;
      Exit;
    end;
  except
    begin
      SQLComp.Destroy;
      Result := False;
      Exit;
    end;
  end;
  SQLComp.Destroy;
end;
class function TAuctionFunctions.RegisterSellerAquisitionMail(var Player: TPlayer;
  AuctionOfferId: UInt64; OUT MailIndex: UInt64): Boolean;
var
  QueryString: string;
  SQLComp: TQuery;
begin
  Result := True;
  MailIndex := 0;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[RegisterSellerAquisitionMail]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[RegisterSellerAquisitionMail]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    QueryString :=
      Format('INSERT INTO mails (characterId, sentCharacterId, sentCharacterName, title, ' +
        'textBody, slot, sentGold, gold, returnDate, ' +
        'sentDate, isFromAuction, canReturn) SELECT CharacterId, 1, "Casa de Leilões", '+
        '"Item Vendido", "Entrega de gold por venda na casa de leilões", 0, '+
        'SellingPrice, SellingPrice, "%s", "%s", 1, 0 FROM '+MYSQL_DATABASE+'.vwauction_getactiveoffers WHERE AuctionId=%d;',
        [
          FormatDateTime('yyyy-mm-dd hh:nn:ss', IncDay(Now, 90)),
          FormatDateTime('yyyy-mm-dd hh:nn:ss', Now),
          AuctionOfferId
        ]);

    SQLComp.SetQuery(QueryString);
    SQLComp.Query.Connection.StartTransaction;
    SQLComp.Run(False);
    SQLComp.Query.Connection.Commit;
    if (SQLComp.Query.RowsAffected = 0) then
    begin
      SQLComp.Destroy;
      Result := False;
      Exit;
    end;
    QueryString := 'SELECT max(id) as idx from mails;';
    SQLComp.SetQuery(QueryString);
    SQLComp.Run();
    MailIndex := UInt64(SQLComp.Query.FieldByName('idx').AsLargeInt);
    if MailIndex = 0 then
    begin
      SQLComp.Destroy;
      Result := False;
      Exit;
    end;
  except
    begin
      SQLComp.Destroy;
      Result := False;
      Exit;
    end;
  end;
  SQLComp.Destroy;
end;
{$ENDREGION}
{$REGION 'Check offer expire time'}
class function TAuctionFunctions.CheckAuctionItems(): Boolean;
begin
end;
class function TAuctionFunctions.RegisterReturnMail(OUT MailIndex: UInt64): Boolean;
begin
end;
{$ENDREGION}

end.
