unit EntityMail;

interface

uses
  Windows, FireDAC.Comp.Client, MiscData, System.SysUtils, Player, AnsiStrings;

{$OLDTYPELAYOUT ON}

type
  PMail = ^TMail;

  TMail = packed record
    Index: UInt64;
    CharIndex: DWORD;
    Nick: Array [0 .. 15] of AnsiChar;
    Titulo: Array [0 .. 31] of AnsiChar;
    Texto: Array [0 .. 511] of AnsiChar;
    Slot: WORD;
    Gold: DWORD;
    Item: Array [0 .. 6] of TItem;
    DataRetorno: TDateTime;
    DataEnvio: TDateTime;
    Checked: BOOLEAN;
    Return: BOOLEAN;
    CheckItem: BOOLEAN;
    Leilao: BOOLEAN;
  end;

type
  TCharacterMail = ARRAY OF TMail;

type
  TMailList = ARRAY [0 .. 31] OF TStructCarta;

type
  TEntityMail = class(TObject)
  private
    { DataBase Get Functions }
    class function getMailsList(var Player: TPlayer;
      var mailList: TMailList): BOOLEAN;

    class function getUnreadCount(var Player: TPlayer;
      var dwUnreadMails: DWORD): BOOLEAN;

    class function getMailsCount(var Player: TPlayer;
      var dwMails: DWORD): BOOLEAN;

    class function getMailContent(var Player: TPlayer; const mailIndex: UInt64;
      var MailContet: TOpenMailContent): BOOLEAN;

  public
    { DataBase Get Functions }
    class function getMailGold(var Player: TPlayer; const mailIndex: UInt64;
      var dwGold: DWORD): BOOLEAN;

    class function getMailItemSlot(var Player: TPlayer; const mailIndex: UInt64;
      const Slot: BYTE; var Item: TItem; var itemIndex: UInt64): BOOLEAN;

    class function getMailItemCount(var Player: TPlayer;
      const mailIndex: UInt64; var itemCount: BYTE): BOOLEAN;

    class function getCharacterIdByName(var Player: TPlayer;
      characterName: AnsiString): UInt64;

    { Sends }
    class procedure sendUnreadMails(var Player: TPlayer);

    class function sendMailList(var Player: TPlayer): BOOLEAN;

    class function sendMailContent(var Player: TPlayer;
      const mailIndex: UInt64): BOOLEAN;

    { DataBase Update Mail Info }
    class function setMailRead(var Player: TPlayer;
      const mailIndex: UInt64): BOOLEAN;

    class function deleteMail(var Player: TPlayer;
      const mailIndex: UInt64): BOOLEAN;

    class function withdrawGold(var Player: TPlayer;
      const mailIndex: UInt64): BOOLEAN;

    class function setAllItemsWithdraw(var Player: TPlayer;
      const mailIndex: UInt64): BOOLEAN;

    class function withdrawItem(var Player: TPlayer; const itemIndex: UInt64;
      const mailIndex: UInt64): BOOLEAN;

    class function returnEmail(var Player: TPlayer;
      const mailIndex: UInt64): BOOLEAN;

    { DataBase Add Mail Info }
    class function addMail(var Player: TPlayer; const MailContet: TMailContent;
      out mailIndex: UInt64): BOOLEAN;

    class function addMailItem(var Player: TPlayer; const itemSlot: BYTE;
      const mailSlot: BYTE; const mailIndex: UInt64): BOOLEAN;
  end;

{$OLDTYPELAYOUT OFF}

implementation

uses
  GlobalDefs, Log, Packets, DateUtils, SQL;

{$REGION 'Database Get Functions'}

class function TEntityMail.getMailsList(var Player: TPlayer;
  var mailList: TMailList): BOOLEAN;
var
  i: BYTE;
  SQLComp: TQuery;
begin
  Result := False;

  ZeroMemory(@mailList, sizeof(TMailList));

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[getMailsList]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[getMailsList]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  try     //aspas no ReturnDate ``
    SQLComp.SetQuery
      (format('SELECT id, sentCharacterName, title, DATE(returnDate) as `ReturnDate`, '+
      'checked, canReturn, hasItems, isFromAuction FROM mails'
      + ' WHERE active > 0 AND characterId = %d ORDER BY id DESC LIMIT 32',
      [Player.Character.Index]));
    //Player.PlayerSQL.AddParameter2('owner_charId', Player.Character.Index);
    SQLComp.Run();

    if not(SQLComp.Query.RecordCount = 0) then
    begin
      SQLComp.Query.First;
      for i := 0 to (SQLComp.Query.RecordCount - 1) do
      begin
        mailList[i].Index := UInt64(SQLComp.Query.FieldByName('id')
          .AsLargeInt);

        AnsiStrings.StrPLCopy(mailList[i].NickEnviado,
          AnsiString(SQLComp.Query.FieldByName('sentCharacterName')
          .AsString), 16);

        AnsiStrings.StrPLCopy(mailList[i].Titulo,
          AnsiString(SQLComp.Query.FieldByName('title').AsString), 32);

        AnsiStrings.StrPLCopy(mailList[i].DataRetorno,
          AnsiString(SQLComp.Query.FieldByName('ReturnDate')
          .AsString), 20);

        mailList[i].Checked :=
          BOOLEAN(SQLComp.Query.FieldByName('checked').AsInteger);
        mailList[i].Return :=
          BOOLEAN(SQLComp.Query.FieldByName('canReturn').AsInteger);
        mailList[i].CheckItem :=
          BOOLEAN(SQLComp.Query.FieldByName('hasItems').AsInteger);
        mailList[i].Leilao :=
          BOOLEAN(SQLComp.Query.FieldByName('isFromAuction')
          .AsInteger);

        if(SQLComp.Query.RecordCount > 1) then
          SQLComp.Query.Next;
      end;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on loading mails list. msg[' + E.Message + ' : '
        + E.GetBaseException.Message + '] clientId [' +
        string(Player.Character.Base.ClientId.ToString) + '] ' + DateTimeToStr(Now) +
        '.', TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
  end;

  SQLComp.Destroy;

  Result := True;
end;

class function TEntityMail.getUnreadCount(var Player: TPlayer;
  var dwUnreadMails: DWORD): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;
  dwUnreadMails := 0;

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[getUnreadCount]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[getUnreadCount]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  try
    SQLComp.SetQuery
      (format('SELECT count(id) as `unreadMailsCount` FROM mails WHERE active > 0 '+
      'AND checked = 0 AND characterId = %d', [Player.Character.Index]));
    //Player.PlayerSQL.AddParameter2('owner_charId', Player.Character.Index);
    SQLComp.Run();

    if not(SQLComp.Query.RecordCount = 0) then
    begin
      dwUnreadMails := SQLComp.Query.FieldByName('unreadMailsCount')
        .AsInteger;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on loading unread mails count. msg[' + E.Message
        + ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' + DateTimeToStr(Now) +
        '.', TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
  end;

  SQLComp.Destroy;

  Result := True;
end;

class function TEntityMail.getMailsCount(var Player: TPlayer;
  var dwMails: DWORD): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;
  dwMails := 0;

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[getMailsCount]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[getMailsCount]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  try
    SQLComp.SetQuery
      (format('SELECT count(id) as `mailsCount` FROM mails WHERE active > 0 AND '+
      'characterId = %d', [Player.Character.Index]));  //tinha `` no mailsCount
    //Player.PlayerSQL.AddParameter2('owner_charId', Player.Character.Index);
    SQLComp.Run();

    if not(SQLComp.Query.RecordCount = 0) then
    begin
      dwMails := SQLComp.Query.FieldByName('mailsCount').AsInteger;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on loading mails count. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' + DateTimeToStr(Now) +
        '.', TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
  end;

  SQLComp.Destroy;

  Result := True;
end;

class function TEntityMail.getMailContent(var Player: TPlayer;
  const mailIndex: UInt64; var MailContet: TOpenMailContent): BOOLEAN;
var
  i: BYTE;
  itemSlot: BYTE;
  SQLComp: TQuery;
begin
  Result := False;

  ZeroMemory(@MailContet, sizeof(TMail));

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[getMailContent]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[getMailContent]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  try
    SQLComp.SetQuery(format('SELECT * FROM mails' +
      ' WHERE active > 0 AND id = %d LIMIT 1', [mailIndex]));
    //Player.PlayerSQL.AddParameter2('mail_id', mailIndex);
    SQLComp.Run();

    if not(SQLComp.Query.RecordCount = 0) then
    begin
      MailContet.Index := UInt64(SQLComp.Query.FieldByName('id')
        .AsInteger);
      MailContet.CharIndex :=
        UInt(SQLComp.Query.FieldByName('characterId').AsInteger);

      MailContet.Index2 := MailContet.Index;

      AnsiStrings.StrPLCopy(MailContet.Nick,
        AnsiString(SQLComp.Query.FieldByName('sentCharacterName')
        .AsString), 16);

      AnsiStrings.StrPLCopy(MailContet.Titulo,
        AnsiString(SQLComp.Query.FieldByName('title').AsString), 32);

      AnsiStrings.StrPLCopy(MailContet.Texto,
        AnsiString(SQLComp.Query.FieldByName('textBody')
        .AsString), 512);

      AnsiStrings.StrPLCopy(MailContet.DataEnvio,
        AnsiString(SQLComp.Query.FieldByName('sentDate')
        .AsString), 20);

      MailContet.Unk_B01 :=
        BOOLEAN(SQLComp.Query.FieldByName('checked').AsInteger);
      MailContet.Return :=
        BOOLEAN(SQLComp.Query.FieldByName('canReturn').AsInteger);
      MailContet.Unk_B02 :=
        BOOLEAN(SQLComp.Query.FieldByName('hasItems').AsInteger);
      MailContet.Unk_B03 :=
        BOOLEAN(SQLComp.Query.FieldByName('isFromAuction').AsInteger);

      MailContet.Gold := UInt64(SQLComp.Query.FieldByName('gold')
        .AsInteger);
    end;

    SQLComp.SetQuery(format('SELECT * FROM mails_items' +
      ' WHERE active > 0 AND mail_id = %d ORDER BY slot ASC LIMIT 6',
      [mailIndex]));
    //Player.PlayerSQL.AddParameter2('pmail_id', mailIndex);
    SQLComp.Run();

    if not(SQLComp.Query.RecordCount = 0) then
    begin
      SQLComp.Query.First;
      for i := 0 to (SQLComp.Query.RecordCount - 1) do
      begin
        itemSlot := BYTE(SQLComp.Query.FieldByName('slot').AsInteger);

        MailContet.Items[itemSlot].Index := SQLComp.Query.FieldByName
          ('item_id').AsInteger;
        MailContet.Items[itemSlot].APP := SQLComp.Query.FieldByName
          ('app').AsInteger;
        MailContet.Items[itemSlot].Identific :=
          SQLComp.Query.FieldByName('identific').AsInteger;

        MailContet.Items[itemSlot].Effects.Index[0] :=
          SQLComp.Query.FieldByName('effect1_index').AsInteger;
        MailContet.Items[itemSlot].Effects.Index[1] :=
          SQLComp.Query.FieldByName('effect2_index').AsInteger;
        MailContet.Items[itemSlot].Effects.Index[2] :=
          SQLComp.Query.FieldByName('effect3_index').AsInteger;

        MailContet.Items[itemSlot].Effects.Value[0] :=
          SQLComp.Query.FieldByName('effect1_value').AsInteger;
        MailContet.Items[itemSlot].Effects.Value[1] :=
          SQLComp.Query.FieldByName('effect2_value').AsInteger;
        MailContet.Items[itemSlot].Effects.Value[2] :=
          SQLComp.Query.FieldByName('effect3_value').AsInteger;

        MailContet.Items[itemSlot].MIN := SQLComp.Query.FieldByName
          ('min').AsInteger;
        MailContet.Items[itemSlot].MAX := SQLComp.Query.FieldByName
          ('max').AsInteger;

        MailContet.Items[itemSlot].Refi := SQLComp.Query.FieldByName
          ('refine').AsInteger;

        MailContet.Items[itemSlot].Time := SQLComp.Query.FieldByName
          ('time').AsInteger;

        SQLComp.Query.Next;
      end;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on loading mail content. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' + DateTimeToStr(Now) +
        '.', TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
  end;

  SQLComp.Destroy;

  Result := True;
end;

class function TEntityMail.getMailGold(var Player: TPlayer;
  const mailIndex: UInt64; var dwGold: DWORD): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;
  dwGold := 0;

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[getMailGold]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[getMailGold]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  try
    SQLComp.SetQuery
      (format('SELECT gold FROM mails WHERE active > 0 AND characterId = %d AND'+
      ' id = %d LIMIT 1', [Player.Character.Index, mailIndex]));
   // Player.PlayerSQL.AddParameter2('owner_charId', Player.Character.Index);
    //Player.PlayerSQL.AddParameter2('mail_id', mailIndex);
    SQLComp.Run();

    if not(SQLComp.Query.RecordCount = 0) then
    begin
      dwGold := SQLComp.Query.FieldByName('gold').AsInteger;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on loading mail gold amount. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' + DateTimeToStr(Now) +
        '.', TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
  end;

  SQLComp.Destroy;
  Result := True;
end;

class function TEntityMail.getMailItemSlot(var Player: TPlayer;
  const mailIndex: UInt64; const Slot: BYTE; var Item: TItem;
  var itemIndex: UInt64): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;

  ZeroMemory(@Item, sizeof(TItem));

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[getMailItemSlot]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[getMailItemSlot]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  try
    SQLComp.SetQuery
      (format('SELECT * FROM mails_items WHERE active > 0 AND mail_id = %d AND '+
      'slot = %d LIMIT 1', [mailIndex, Slot]));
    //Player.PlayerSQL.AddParameter2('pmail_id', mailIndex);
    //Player.PlayerSQL.AddParameter2('item_slot', Slot);
    SQLComp.Run();

    if not(SQLComp.Query.RecordCount = 0) then
    begin
      Item.Index := SQLComp.Query.FieldByName('item_id').AsInteger;
      Item.APP := SQLComp.Query.FieldByName('app').AsInteger;
      Item.Identific := SQLComp.Query.FieldByName('identific')
        .AsInteger;

      Item.Effects.Index[0] := SQLComp.Query.FieldByName
        ('effect1_index').AsInteger;
      Item.Effects.Index[1] := SQLComp.Query.FieldByName
        ('effect2_index').AsInteger;
      Item.Effects.Index[2] := SQLComp.Query.FieldByName
        ('effect3_index').AsInteger;

      Item.Effects.Value[0] := SQLComp.Query.FieldByName
        ('effect1_value').AsInteger;
      Item.Effects.Value[1] := SQLComp.Query.FieldByName
        ('effect2_value').AsInteger;
      Item.Effects.Value[2] := SQLComp.Query.FieldByName
        ('effect3_value').AsInteger;

      Item.MIN := SQLComp.Query.FieldByName('min').AsInteger;
      Item.MAX := SQLComp.Query.FieldByName('max').AsInteger;

      Item.Refi := SQLComp.Query.FieldByName('refine').AsInteger;

      Item.Time := SQLComp.Query.FieldByName('time').AsInteger;

      itemIndex := UInt64(SQLComp.Query.FieldByName('id').AsLargeInt);
    end;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on loading mail item slot. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' + DateTimeToStr(Now) +
        '.', TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
  end;

  SQLComp.Destroy;

  Result := True;
end;

class function TEntityMail.getMailItemCount(var Player: TPlayer;
  const mailIndex: UInt64; var itemCount: BYTE): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;
  itemCount := 0;

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[getMailItemCount]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[getMailItemCount]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  try
    SQLComp.SetQuery
      (format('SELECT count(id) as `itemsCount` FROM mails_items WHERE active > 0 '+
      'AND mail_id = %d LIMIT 6', [mailIndex]));
    //Player.PlayerSQL.AddParameter2('pmail_id', mailIndex);
    SQLComp.Run();

    if not(SQLComp.Query.RecordCount = 0) then
    begin
      itemCount := SQLComp.Query.FieldByName('itemsCount').AsInteger;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on loading mail items count. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' + DateTimeToStr(Now) +
        '.', TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
  end;

  SQLComp.Destroy;

  Result := True;
end;

class function TEntityMail.getCharacterIdByName(var Player: TPlayer;
  characterName: AnsiString): UInt64;
var
  SQLComp: TQuery;
begin
  Result := 0;

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[getCharacterIdByName]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[getCharacterIdByName]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  try
    SQLComp.SetQuery
     (format('SELECT id FROM characters WHERE name = %s LIMIT 1',
     [QuotedStr(String(characterName))]));
    //Player.PlayerSQL.AddParameter2('pcharacterName', characterName);
    SQLComp.Run();

    if not(SQLComp.Query.RecordCount = 0) then
    begin
      Result := SQLComp.Query.FieldByName('id').AsInteger;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on getting character id from name. msg[' +
        E.Message + ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' + DateTimeToStr(Now) +
        '.', TlogType.Error);

      SQLComp.Destroy;
      Exit;
    end;
  end;

  SQLComp.Destroy;
end;

{$ENDREGION}
{$REGION 'Sends'}

class procedure TEntityMail.sendUnreadMails(var Player: TPlayer);
var
  unReadMails: DWORD;
begin
  if not(Self.getUnreadCount(Player, unReadMails)) then
    Exit;

  Player.SendData(Player.Base.ClientId, $3F1B, unReadMails);
end;

class function TEntityMail.sendMailList(var Player: TPlayer): BOOLEAN;
var
  mailList: TMailList;
  Packet: TPlayerMailsPacket;
  mailsCount: DWORD;
begin
  Result := False;

  if not(Self.getMailsList(Player, mailList)) then
    Exit;

  if not(Self.getMailsCount(Player, mailsCount)) then
    Exit;

  ZeroMemory(@Packet, sizeof(Packet));

  Packet.Header.Size := sizeof(Packet);
  Packet.Header.Index := Player.Base.ClientId;
  Packet.Header.Code := $3F17;

  Move(mailList, Packet.Cartas, sizeof(TMailList));

  Packet.MailsAmount := mailsCount;

  Player.SendPacket(Packet, Packet.Header.Size);

  Result := True;
end;

class function TEntityMail.sendMailContent(var Player: TPlayer;
  const mailIndex: UInt64): BOOLEAN;
var
  Packet: TSendOpenMailContentPacket;
  MailContet: TOpenMailContent;
begin
  Result := False;

  if not(Self.getMailContent(Player, mailIndex, MailContet)) then
    Exit;

  ZeroMemory(@Packet, sizeof(Packet));

  Packet.Header.Size := sizeof(Packet);
  Packet.Header.Index := Player.Base.ClientId;
  Packet.Header.Code := $3F18;

  Packet.MailContent := MailContet;

  Player.SendPacket(Packet, Packet.Header.Size);

  Result := True;
end;

{$ENDREGION}
{$REGION 'DataBase Update Mail Info'}

class function TEntityMail.setMailRead(var Player: TPlayer;
  const mailIndex: UInt64): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[setMailRead]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[setMailRead]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  try
    SQLComp.SetQuery
      (format('UPDATE mails SET checked = 1 WHERE active > 0 AND id = %d '+
      'AND characterId = %d LIMIT 1', [mailIndex, Player.Character.Index]));
   // Player.PlayerSQL.AddParameter2('mail_id', mailIndex);
   // Player.PlayerSQL.AddParameter2('pcharacterId', Player.Character.Index);
    SQLComp.Run(False);

    //if not(Player.PlayerSQL.Query.RecordCount > 0) then
     // Exit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on setting mail readed. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' + DateTimeToStr(Now) +
        '.', TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
  end;

  SQLComp.Destroy;

  Result := True;
end;

class function TEntityMail.deleteMail(var Player: TPlayer;
  const mailIndex: UInt64): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[deleteMail]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[deleteMail]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  try
    SQLComp.SetQuery
      (format('UPDATE mails SET active = 0 WHERE id = %d AND characterId = '+
      '%d LIMIT 1', [mailIndex, Player.Character.Index]));
    //Player.PlayerSQL.AddParameter2('mail_id', mailIndex);
    //Player.PlayerSQL.AddParameter2('pcharacterId', Player.Character.Index);
    SQLComp.Run(False);

    //if not(Player.PlayerSQL.Query.RecordCount > 0) then
     // Exit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on deleting mail. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' + DateTimeToStr(Now) +
        '.', TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
  end;

  SQLComp.Destroy;

  Result := True;
end;

class function TEntityMail.withdrawGold(var Player: TPlayer;
  const mailIndex: UInt64): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[withdrawGold]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[withdrawGold]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  try
    SQLComp.SetQuery
      (format('UPDATE mails SET gold = 0, canReturn = 0 WHERE id = '+
      '%d AND characterId = %d LIMIT 1',
       [mailIndex, Player.Character.Index]));
    //Player.PlayerSQL.AddParameter2('mail_id', mailIndex);
    //Player.PlayerSQL.AddParameter2('pcharacterId', Player.Character.Index);
    SQLComp.Run(False);

    //if not(Player.PlayerSQL.Query.RecordCount > 0) then
     // Exit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on withdrawing gold from mail. msg[' + E.Message
        + ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' + DateTimeToStr(Now) +
        '.', TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
  end;

  SQLComp.Destroy;

  Result := True;
end;

class function TEntityMail.setAllItemsWithdraw(var Player: TPlayer;
  const mailIndex: UInt64): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[setAllItemsWithdraw]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[setAllItemsWithdraw]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  try
    SQLComp.SetQuery
      (format('UPDATE mails SET hasItems = 0 WHERE id = %d AND characterId = '+
      '%d LIMIT 1', [mailIndex, Player.Character.Index]));
   // Player.PlayerSQL.AddParameter2('mail_id', mailIndex);
   // Player.PlayerSQL.AddParameter2('pcharacterId', Player.Character.Index);
    SQLComp.Run(False);

   // if not(Player.PlayerSQL.Query.RecordCount > 0) then
    //  Exit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on setting all items got. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' + DateTimeToStr(Now) +
        '.', TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
  end;

  SQLComp.Destroy;

  Result := True;
end;

class function TEntityMail.withdrawItem(var Player: TPlayer;
  const itemIndex: UInt64; const mailIndex: UInt64): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[withdrawItem]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[withdrawItem]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  try
    SQLComp.SetQuery
      (format('UPDATE mails_items SET active = 0 WHERE id = %d AND mail_id = '+
      '%d LIMIT 1', [itemIndex, mailIndex]));
   // Player.PlayerSQL.AddParameter2('pmail_index', mailIndex);
    //Player.PlayerSQL.AddParameter2('item_index', itemIndex);
    SQLComp.Run(False);

    //if not(Player.PlayerSQL.Query.RecordCount > 0) then
     // Exit;

    SQLComp.SetQuery
      (format('UPDATE mails SET canReturn = 0 WHERE id = %d AND characterId = '+
      '%d LIMIT 1', [mailIndex, Player.Character.Index]));
    //Player.PlayerSQL.AddParameter2('pcharacterId', Player.Character.Index);
    //Player.PlayerSQL.AddParameter2('pmail_index', mailIndex);
    SQLComp.Run(False);

    //if not(Player.PlayerSQL.Query.RecordCount > 0) then
      //Exit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on withdraw item. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' + DateTimeToStr(Now) +
        '.', TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
  end;

  SQLComp.Destroy;

  Result := True;
end;

class function TEntityMail.returnEmail(var Player: TPlayer;
  const mailIndex: UInt64): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[returnEmail]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[returnEmail]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  try
    SQLComp.SetQuery
      (format('UPDATE mails SET characterId = sentCharacterId, title = '+
      'CONCAT("[Retornou] ", title), '+
        'returnDate = date_add(returnDate, INTERVAL 15 DAY), canReturn = 0, '+
        'mailReturned = 1 WHERE id = %d AND characterId = %d',
        [mailIndex, Player.Character.Index]));
    //Player.PlayerSQL.AddParameter2('mailIndex', mailIndex);
    //Player.PlayerSQL.AddParameter2('characterId', Player.Character.Index);
    SQLComp.Run(False);

    //if not(Player.PlayerSQL.Query.RecordCount > 0) then
      //Exit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on returning mail. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' + DateTimeToStr(Now) +
        '.', TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
  end;

  SQLComp.Destroy;

  Result := True;
end;

{$ENDREGION}
{$REGION 'DataBase Add Mail Info'}

class function TEntityMail.addMail(var Player: TPlayer;
  const MailContet: TMailContent; out mailIndex: UInt64): BOOLEAN;
var
  receiverCharacterId: UInt64;
  canReturn, hasItems: BYTE;
  SQLComp: TQuery;
  i: BYTE;
begin
  Result := False;

  try
    receiverCharacterId := Self.getCharacterIdByName(Player,
      AnsiString(MailContet.Nick));

    canReturn := 0;
    hasItems := 0;

    for i := 0 to 4 do
    begin
      if (MailContet.itemSlot[i] = $FF) then
        Continue;

      canReturn := 1;
      hasItems := 1;
    end;

    if (MailContet.Gold > 0) then
      canReturn := 1;

    Logger.Write('receiver charid: ' + receiverCharacterId.ToString, TlogType.Packets);

    if (receiverCharacterId = 0) then
      Exit;

    SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

    if not(SQLComp.Query.Connection.Connected) then
    begin
      Logger.Write('Falha de conexão individual com mysql.[addMail]',
        TlogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[addMail]', TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;

    SQLComp.SetQuery
      (format('INSERT INTO mails (characterId, sentCharacterId, sentCharacterName, '+
      'title, textBody, slot, sentGold, gold, returnDate, sentDate, canReturn, hasItems)'
      + ' VALUES (%d, %d, %s, %s, '+
      '%s, 0, %d, %d, %s, NOW(), %d, %d)',
      [receiverCharacterId, Player.Character.Index,
      QuotedStr(String(AnsiString(Player.Character.Base.Name))),
      QuotedStr(String(AnsiString(MailContet.Titulo))),
      QuotedStr(String(AnsiString(MailContet.Texto))),
      MailContet.Gold, MailContet.Gold, QuotedStr(FormatDateTime('yyyy-mm-dd hh:mm:ss', IncDay(Now, 15))),
      canReturn, hasItems]));
    {Player.PlayerSQL.AddParameter2('pcharacterId', receiverCharacterId);
    Player.PlayerSQL.AddParameter2('psentcharacterid', Player.Character.Index);
    Player.PlayerSQL.AddParameter2('pcharactername',
      AnsiString(Player.Character.Base.Name));
    Player.PlayerSQL.AddParameter2('ptitle', AnsiString(MailContet.Titulo));
    Player.PlayerSQL.AddParameter2('ptextbody', AnsiString(MailContet.Texto));
    Player.PlayerSQL.AddParameter2('pslot', 0);
    Player.PlayerSQL.AddParameter2('psentgold', MailContet.Gold);
    Player.PlayerSQL.AddParameter2('pgold', MailContet.Gold); }
    //SQLComp.AddParameter2('preturnDate',
      //FormatDateTime('yyyy-mm-dd hh:mm:ss', IncDay(Now, 15)));
   { Player.PlayerSQL.AddParameter2('psentdate',
      FormatDateTime('yyyy-mm-dd hh:mm:ss', Now));
    Player.PlayerSQL.AddParameter2('pcanReturn', canReturn);
    Player.PlayerSQL.AddParameter2('phasItems', hasItems);  }
    SQLComp.Run(False);

    //if not(Player.PlayerSQL.Query.RecordCount > 0) then
     // Exit;

    SQLComp.SetQuery
      (format('SELECT last_insert_id() as last_index FROM mails WHERE '+
      'characterId = %d LIMIT 1', [receiverCharacterId]));
    //Player.PlayerSQL.AddParameter2('pcharacterId', Player.Character.Index);
    SQLComp.Run();


    if (SQLComp.Query.RecordCount = 0) then
    begin
      SQLComp.Destroy;
      Exit;
    end;

    mailIndex := SQLComp.Query.FieldByName('last_index').AsInteger;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on adding mail. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' + DateTimeToStr(Now) +
        '.', TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
  end;

  SQLComp.Destroy;

  Result := True;
end;

class function TEntityMail.addMailItem(var Player: TPlayer;
  const itemSlot: BYTE; const mailSlot: BYTE; const mailIndex: UInt64): BOOLEAN;
var
  Item: TItem;
  SQLComp: TQuery;
begin
  Result := False;

  try
    ZeroMemory(@Item, sizeof(TItem));

    Move(Player.Character.Base.Inventory[itemSlot], Item, sizeof(TItem));

    if not(ItemList[Item.Index].TypeTrade = 0) then
      Exit;
  except
    Exit;
  end;

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[addMailItem]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[addMailItem]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  try
    SQLComp.SetQuery
      (format('INSERT INTO mails_items (mail_id, slot, item_id, app, identific, '+
      'effect1_index, effect1_value, effect2_index, effect2_value, effect3_index, '+
      'effect3_value, min, max, refine, time)'
      + ' VALUES (%d, %d, %d, %d, %d, %d, '+
      '%d, %d, %d, %d, '+
      '%d, %d, %d, %d, %d)',
      [mailIndex, mailSlot, Item.Index, Item.APP, Item.Identific, Item.Effects.Index[0],
      Item.Effects.Value[0], Item.Effects.Index[1],
      Item.Effects.Value[1], Item.Effects.Index[2], Item.Effects.Value[2],
      Item.MIN, Item.MAX, Item.Refi, Item.Time]));
    {Player.PlayerSQL.AddParameter2('mail_id', mailIndex);
    Player.PlayerSQL.AddParameter2('slot', mailSlot);
    Player.PlayerSQL.AddParameter2('item_id', Item.Index);
    Player.PlayerSQL.AddParameter2('app', Item.APP);
    Player.PlayerSQL.AddParameter2('identific', Item.Identific);
    Player.PlayerSQL.AddParameter2('effect1_index', Item.Effects.Index[0]);
    Player.PlayerSQL.AddParameter2('effect1_value', Item.Effects.Value[0]);
    Player.PlayerSQL.AddParameter2('effect2_index', Item.Effects.Index[1]);
    Player.PlayerSQL.AddParameter2('effect2_value', Item.Effects.Value[1]);
    Player.PlayerSQL.AddParameter2('effect3_index', Item.Effects.Index[2]);
    Player.PlayerSQL.AddParameter2('effect3_value', Item.Effects.Value[2]);
    Player.PlayerSQL.AddParameter2('min', Item.MIN);
    Player.PlayerSQL.AddParameter2('max', Item.MAX);
    Player.PlayerSQL.AddParameter2('refine', Item.Refi);
    Player.PlayerSQL.AddParameter2('time', Item.Time);
    }
    SQLComp.Run(False);

    //if not(Player.PlayerSQL.Query.RecordCount > 0) then
     // Exit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on adding mail item. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' + DateTimeToStr(Now) +
        '.', TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
  end;

  SQLComp.Destroy;

  Result := True;
end;

{$ENDREGION}

end.
