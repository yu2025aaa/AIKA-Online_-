unit MailFunctions;

interface

uses
  Windows, SysUtils, Classes, Generics.Collections,
  CharacterMail, MiscData, Packets, Player, AnsiStrings;

type
  TMailFunctions = class(TObject)

  public
    { Mail Count }
    class function GetMailCount(var Player: TPlayer): WORD;
    class function MailItemsCount(const Mail: TMail): BYTE;

    class function GetUnreadMails(var Player: TPlayer): WORD; overload;
    class function GetUnreadMails(const Mails: TCharacterMail): WORD; overload;

    { Mail Index }
    class function LasMailIndex: UInt64;
    class function IncMailIndex: UInt64;

    { Mail File Functions }
    class function GetMails(CharacterName: string; var Mails: TCharacterMail): Boolean;
    class function GetMail(CharacterName: string; const Index: Int64; out Mail: TMail): Boolean; overload;
    class function GetMail(const Mails: TCharacterMail; const Index: Int64; out Mail: TMail): Boolean; overload;
    class function GetMailSlot(const Mails: TCharacterMail; const Index: Int64; out MailSlot: WORD): Boolean;
    class function SaveMails(CharacterName: string; const Mails: TCharacterMail): Boolean;
    class function SaveMail(var Mails: TCharacterMail; const Mail: TMail): Boolean;

    { Mail Add e Remove }
    class function AddMail(CharacterName: string; const Mail: TMail): Boolean;
    class function RemoveMail(CharacterName: string; const Index: UInt64): Boolean; overload;
    class function RemoveMail(var Mails: TCharacterMail; const Index: UInt64): Boolean; overload;
    class function RemoveExpiredMails(CharacterName: string): Boolean;

    { Parse Functions }
    class function ParseMail(const Mail: TMail; out Carta: TStructCarta): Boolean; overload;
    class function ParseMail(const Mail: TMail; out Packet: TRecvOpenMailPacket): Boolean; overload;
    class function ParseMail(const MailContent: TMailContent; out Mail: TMail): Boolean; overload;

    { Mail Sends }
    class function SendMailContent(var Player: TPlayer; const Mail: TMail): Boolean;
    class function SendRefreshMails(var Player: TPlayer; const Mails: TCharacterMail): Boolean;
    class procedure SendUnreadMails(var Player: TPlayer); overload;
    class procedure SendUnreadMails(var Player: TPlayer; const Mails: TCharacterMail); overload;

    { Packet Mail Handlers }
    class function SendCharacterMail(var Player: TPlayer; var Buffer: array of BYTE): Boolean;
    class function ConfirmSendMail(var Player: TPlayer; var Buffer: array of BYTE): Boolean;
    class function RefreshCharacterMail(var Player: TPlayer; var Buffer: array of BYTE): Boolean;
    class function OpenMail(var Player: TPlayer; var Buffer: array of BYTE): Boolean;
    class function GetMailContent(var Player: TPlayer; var Buffer: array of BYTE): Boolean;
  end;

implementation

uses
  GlobalDefs, DateUtils, PlayerData,
  Functions, ItemFunctions,
  Log, SQL;

{$REGION 'Mail Count'}

class function TMailFunctions.GetMailCount(var Player: TPlayer): WORD;
var
  SQLComp: TQuery;
begin
  Result := 0;

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GetMailCount]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetMailCount]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  try
    SQLComp.SetQuery('SELECT count(id) FROM mails WHERE `active` > 0 AND characterId = :owner_chracterId');
    SQLComp.AddParameter2('owner_chracterId', Player.Account.Header.AccountId);
    SQLComp.Run();

    Result := SQLComp.Query.RecordCount;
  except
    SQLComp.Destroy;
    Exit;
  end;

  SQLComp.Destroy;
end;

class function TMailFunctions.MailItemsCount(const Mail: TMail): BYTE;
var
  i: Integer;
begin
  Result := 0;

  for i := 0 to 5 do
  begin
    if (Mail.Item[i].Index > 0) then
    begin
      Inc(Result);
    end;
  end;
end;

class function TMailFunctions.GetUnreadMails(var Player: TPlayer): WORD;
var
  SQLComp: TQuery;
begin
  Result := 0;

  try
    SQLComp.SetQuery('SELECT count(id) FROM mails WHERE `active` > 0 AND characterId = :owner_chracterId AND `checked` = 0');
    SQLComp.AddParameter2('owner_chracterId', Player.Account.Header.AccountId);
    SQLComp.Run();

    Result := SQLComp.Query.RecordCount;
  except
    SQLComp.Destroy;
    Exit;
  end;

  SQLComp.Destroy;
end;

class function TMailFunctions.GetUnreadMails(const Mails: TCharacterMail): WORD;
var
  i: WORD;
begin
  Result := 0;

  for i := Length(Mails) - 1 downto 0 do
  begin
    if not(Mails[i].Checked) and (Mails[i].Index > 0) then
      Inc(Result);
  end;
end;

{$ENDREGION}
{$REGION 'Mail Index'}

class function TMailFunctions.LasMailIndex: UInt64;
var
  F: File of UInt64;
  FName: string;
begin
  Result := 0;

  FName := DATABASE_PATH + 'Mails\LastIndex.t3c';

  if not(FileExists(FName)) then
  begin
    AssignFile(F, FName);
    ReWrite(F);
    Write(F, Result);
    CloseFile(F);
    Exit;
  end;

  try
    AssignFile(F, FName);
    Reset(F);
    Read(F, Result);
    CloseFile(F);
  except
    CloseFile(F);
  end;
end;

class function TMailFunctions.IncMailIndex: UInt64;
var
  F: File of UInt64;
  FName: string;
  LastIndex: UInt64;
begin
  FName := DATABASE_PATH + 'Mails\LastIndex.t3c';

  LastIndex := Self.LasMailIndex;

  try
    AssignFile(F, FName);
    ReWrite(F);
    Inc(LastIndex);
    Write(F, LastIndex);
    CloseFile(F);
  except
    CloseFile(F);
  end;

  Result := LastIndex;
end;

{$ENDREGION}
{$REGION 'Mail File Functions'}

class function TMailFunctions.GetMails(CharacterName: string; var Mails: TCharacterMail): Boolean;
begin
//  Result := False;



  Result := True;
end;

class function TMailFunctions.GetMail(CharacterName: string; const Index: Int64; out Mail: TMail): Boolean;
var
  Mails: TCharacterMail;
  i: BYTE;
begin
  Result := False;

  if not(Self.GetMails(CharacterName, Mails)) then
  begin
    Exit;
  end;

  for i := Length(Mails) - 1 downto 0 do
  begin
    if (Mails[i].Index = Index) then
    begin
      Mail := Mails[i];
      Result := True;
      Break;
    end;
  end;
end;

class function TMailFunctions.GetMail(const Mails: TCharacterMail; const Index: Int64; out Mail: TMail): Boolean;
var
  i: DWORD;
begin
  Result := False;

  for i := Length(Mails) - 1 downto 0 do
  begin
    if (Mails[i].Index = Index) then
    begin
      Mail := Mails[i];
      Result := True;
      Break;
    end;
  end;
end;

class function TMailFunctions.GetMailSlot(const Mails: TCharacterMail; const Index: Int64; out MailSlot: WORD): Boolean;
var
  i: WORD;
begin
  Result := False;

  for i := Length(Mails) - 1 downto 0 do
  begin
    if (Mails[i].Index = Index) then
    begin
      MailSlot := i;
      Result := True;
      Break;
    end;
  end;
end;

class function TMailFunctions.SaveMails(CharacterName: string; const Mails: TCharacterMail): Boolean;
var
  F: File of TMail;
  FName: string;
  i: WORD;
begin
  Result := False;

  if TFunctions.IsLetter(CharacterName) then
  begin
    if not(DirectoryExists(DATABASE_PATH + 'Mails\' + UpperCase(CharacterName[1]))) then
      ForceDirectories(DATABASE_PATH + 'Mails\' + UpperCase(CharacterName[1]));

    FName := DATABASE_PATH + 'Mails\' + UpperCase(CharacterName[1]) + '\' + CharacterName + '.mail';
  end
  else
  begin
    if not(DirectoryExists(DATABASE_PATH + 'Mails\etc')) then
      ForceDirectories(DATABASE_PATH + 'Mails\etc');

    FName := DATABASE_PATH + 'Mails\etc\' + Trim(CharacterName) + '.mail';
  end;

  if (Length(Mails) = 0) then
  begin
    DeleteFile(FName);
    Result := True;
    Exit;
  end;

  try
    AssignFile(F, FName);
    ReWrite(F);

    for i := 0 to Length(Mails) - 1 do
      Write(F, Mails[i]);

    CloseFile(F);
  except
    on E: Exception do
    begin
      Logger.Write(E.ClassName + E.Message, TLogType.Packets);
      CloseFile(F);
      Exit;
    end;

  end;

  Result := True;
end;

class function TMailFunctions.SaveMail(var Mails: TCharacterMail; const Mail: TMail): Boolean;
var
  i: WORD;
begin
  Result := False;

  for i := Length(Mails) - 1 downto 0 do
  begin
    if (Mails[i].Index = Mail.Index) then
    begin
      Move(Mail, Mails[i], sizeof(TMail));
      Result := True;
      Break;
    end;
  end;
end;

{$ENDREGION}
{$REGION 'Mail Add e Remove'}

class function TMailFunctions.AddMail(CharacterName: string; const Mail: TMail): Boolean;
var
  Mails: TCharacterMail;
  MailCount: WORD;
begin
  MailCount := 0;
  Result := False;

  if (Self.GetMails(CharacterName, Mails)) then
  begin
    //MailCount := Self.GetMailCount(CharacterName);
  end
  else
  begin
    MailCount := 0;
  end;

  if (MailCount = 32000) then
  begin
    Exit;
  end;

  SetLength(Mails, MailCount + 1);

  Move(Mail, Mails[MailCount], sizeof(Mail));

  Self.SaveMails(CharacterName, Mails);

  Self.IncMailIndex;

  Result := True;
end;

class function TMailFunctions.RemoveMail(CharacterName: string; const Index: UInt64): Boolean;
var
  Mails: TCharacterMail;
  MailSlot: WORD;
  MailSizes: DWORD;
begin
  Result := False;

  if not(Self.GetMails(CharacterName, Mails)) then
  begin
    Exit;
  end;

  if not(Self.GetMailSlot(Mails, Index, MailSlot)) then
  begin
    Exit;
  end;

  ZeroMemory(@Mails[MailSlot], sizeof(TMail));

  if (MailSlot = 99) then
  begin
    Self.SaveMails(CharacterName, Mails);
    Exit;
  end;

  MailSizes := (99 - MailSlot) * sizeof(TMail);

  Move(Mails[MailSlot + 1], Mails[MailSlot], MailSizes);

  Self.SaveMails(CharacterName, Mails);

  Result := True;
end;

class function TMailFunctions.RemoveMail(var Mails: TCharacterMail; const Index: UInt64): Boolean;
var
  MailSlot: WORD;
  MailSizes: DWORD;
  MailCount: WORD;
begin
  Result := False;

  if not(Self.GetMailSlot(Mails, Index, MailSlot)) then
  begin
    Exit;
  end;

  MailCount := Length(Mails);

  ZeroMemory(@Mails[MailSlot], sizeof(TMail));

  if (MailSlot = (MailCount - 1)) then
  begin
    Result := True;
    SetLength(Mails, MailCount - 1);
    Exit;
  end;

  MailSizes := ((MailCount - 1) - MailSlot) * sizeof(TMail);

  Move(Mails[MailSlot + 1], Mails[MailSlot], MailSizes);

  SetLength(Mails, MailCount - 1);

  Result := True;
end;

class function TMailFunctions.RemoveExpiredMails(CharacterName: string): Boolean;
var
  Mails: TCharacterMail;
  i: WORD;
begin
  Result := False;

  if not(Self.GetMails(CharacterName, Mails)) then
  begin
    Exit;
  end;

  for i := Length(Mails) - 1 downto 0 do
  begin
    if (Mails[i].DataRetorno > Now) then
    begin
      Continue;
    end;

    Self.RemoveMail(Mails, Mails[i].Index);
    Result := True;
  end;
end;

{$ENDREGION}
{$REGION 'Parse Functions'}

class function TMailFunctions.ParseMail(const Mail: TMail; out Carta: TStructCarta): Boolean;
begin
  Result := False;

  try
    Carta.Index := Mail.Index;
    AnsiStrings.StrLCopy(Carta.NickEnviado, Mail.Nick, 16);
    AnsiStrings.StrLCopy(Carta.Titulo, Mail.Titulo, 32);
    AnsiStrings.StrPLCopy(Carta.DataRetorno, AnsiString(FormatDateTime('yyyy-mm-dd', Mail.DataRetorno)), 20);
    Carta.Checked := Mail.Checked;
    Carta.Return := Mail.Return;
    Carta.CheckItem := Mail.CheckItem;
    Carta.Leilao := Mail.Leilao;
  except
    Exit;
  end;

  Result := True;
end;

class function TMailFunctions.ParseMail(const Mail: TMail; out Packet: TRecvOpenMailPacket): Boolean;
begin
  ZeroMemory(@Packet, sizeof(Packet));

  Result := False;

  try
    Packet.Index := Mail.Index;
    Packet.CharIndex := Mail.CharIndex;
    Packet.Index2 := Mail.Index;
    AnsiStrings.StrLCopy(Packet.Nick, Mail.Nick, 16);
    AnsiStrings.StrLCopy(Packet.Titulo, Mail.Titulo, 32);
    AnsiStrings.StrLCopy(Packet.Texto, Mail.Texto, 512);
    AnsiStrings.StrPCopy(Packet.DataEnvio, AnsiString(FormatDateTime('yyyy-mm-dd hh:mm:ss', Mail.DataEnvio)));
    Packet.Unk_B01 := Mail.Checked;
    Packet.Return := Mail.Return;
    Packet.Unk_B02 := Mail.CheckItem;
    Packet.Unk_B03 := Mail.Leilao;

    Move(Mail.Item, Packet.Items, 5 * sizeof(TItem));
    Packet.Gold := Mail.Gold;
  except
    Exit;
  end;

  Result := True;
end;

class function TMailFunctions.ParseMail(const MailContent: TMailContent; out Mail: TMail): Boolean;
begin
  Result := False;

  ZeroMemory(@Mail, sizeof(TMail));

  try
    Mail.Index := Self.LasMailIndex + 1;
    AnsiStrings.StrLCopy(Mail.Titulo, MailContent.Titulo, 32);
    AnsiStrings.StrLCopy(Mail.Texto, MailContent.Texto, 512);
    Mail.Gold := MailContent.Gold;
    Mail.DataEnvio := Now;
    Mail.DataRetorno := IncDay(Now, 15);
  except
    Exit;
  end;

  Result := True;
end;

{$ENDREGION}
{$REGION 'Mail Sends'}

class function TMailFunctions.SendMailContent(var Player: TPlayer; const Mail: TMail): Boolean;
var
  Packet: TRecvOpenMailPacket;
begin
  Result := False;

  ZeroMemory(@Packet, sizeof(Packet));

  if not(Self.ParseMail(Mail, Packet)) then
  begin
    Exit;
  end;

  Packet.Header.Size := sizeof(Packet);
  Packet.Header.Index := Player.Base.ClientId;
  Packet.Header.Code := $3F18;

  Player.SendPacket(Packet, Packet.Header.Size);

  Result := True;
end;

class function TMailFunctions.SendRefreshMails(var Player: TPlayer; const Mails: TCharacterMail): Boolean;
var
  Packet: TPlayerMailsPacket;
  i, j: BYTE;
  LastMail: WORD;
begin
  Result := False;
  ZeroMemory(@Packet, sizeof(Packet));

  Packet.Header.Size := sizeof(Packet);
  Packet.Header.Index := Player.Base.ClientId;
  Packet.Header.Code := $3F17;

  if (Length(Mails) = 0) then
  begin
    Result := True;
    Player.SendPacket(Packet, Packet.Header.Size);
    Exit;
  end;

  if Length(Mails) >= 32 then
  begin
    LastMail := Length(Mails) - 32;
  end
  else
  begin
    LastMail := 0;
  end;

  j := 0;

  for i := (Length(Mails) - 1) downto (LastMail) do
  begin
    if (Mails[i].Index = 0) then
      Continue;

    if not(Self.ParseMail(Mails[i], Packet.Cartas[j])) then
      Exit;

    Inc(j);
  end;

  //Packet.MailsAmount := Self.GetMailCount(string(Player.Base.Character.Name));

  Player.SendPacket(Packet, Packet.Header.Size);

  Result := True;
end;

class procedure TMailFunctions.SendUnreadMails(var Player: TPlayer);
begin
  Player.SendData(Player.Base.ClientId, $3F1B, Self.GetUnreadMails(Player));
end;

class procedure TMailFunctions.SendUnreadMails(var Player: TPlayer; const Mails: TCharacterMail);
begin
  Player.SendData(Player.Base.ClientId, $3F1B, Self.GetUnreadMails(Mails));
end;

{$ENDREGION}
{$REGION 'Packet Mail Handlers'}

class function TMailFunctions.SendCharacterMail(var Player: TPlayer; var Buffer: array of BYTE): Boolean;
var
  Packet: TContentMailPacket absolute Buffer;
  Mail: TMail;
  i: Integer;
begin
  Result := False;

  if (string(Packet.Content.Nick) <> Player.CanSendMailTo) then
  begin
    Exit;
  end;

  if not(Self.ParseMail(Packet.Content, Mail)) then
  begin
    Exit;
  end;

  if not(Player.Character.Base.Gold >= 500) then
  begin
    Player.CanSendMailTo := '';
    Player.SendClientMessage('Não possuí gold suficiente.');
    Player.SendData(Player.Base.ClientId, $3F15, BOOL_REFUSE);
    Exit;
  end;

  if not(Player.Character.Base.Gold >= Mail.Gold) then
  begin
    Player.CanSendMailTo := '';
    Player.SendClientMessage('Você não possui todo esse gold, sabia?');
    Player.SendData(Player.Base.ClientId, $3F15, BOOL_REFUSE);
    Exit;
  end;

  Player.DecGold(500);

  Player.DecGold(Mail.Gold);

  for i := 0 to 4 do
  begin
    if (Packet.Content.ItemSlot[i] = $FF) then
      Continue;

    Mail.CheckItem := True;

    Mail.Return := True;

    Move(Player.Character.Base.Inventory[Packet.Content.ItemSlot[i]], Mail.Item[i], sizeof(TItem));

    ZeroMemory(@Player.Character.Base.Inventory[Packet.Content.ItemSlot[i]], sizeof(TItem));

    Player.Base.SendRefreshItemSlot(Packet.Content.ItemSlot[i], False);
  end;

  AnsiStrings.StrLCopy(Mail.Nick, Player.Character.Base.Name, 16);

  Mail.CharIndex := Player.Character.Index;

  if not(Self.AddMail(string(Packet.Content.Nick), Mail)) then
  begin
    Exit;
  end;

  Player.SendData(Player.Base.ClientId, $3F15, BOOL_ACCEPT);
  Player.SendClientMessage('Correio enviado.');

  Player.CanSendMailTo := '';
end;

class function TMailFunctions.ConfirmSendMail(var Player: TPlayer; var Buffer: array of BYTE): Boolean;
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

  if not(Player.Account.Header.Nation = TCitizenship.None) and (Player.Account.Header.Nation <> Nation) then
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

  Result := True;
end;

class function TMailFunctions.RefreshCharacterMail(var Player: TPlayer; var Buffer: array of BYTE): Boolean;
var
  Mails: TCharacterMail;
begin
  Result := False;

  Self.GetMails(string(Player.Character.Base.Name), Mails);

  if not(Self.SendRefreshMails(Player, Mails)) then
    Exit;

  Result := True;
end;

class function TMailFunctions.OpenMail(var Player: TPlayer; var Buffer: array of BYTE): Boolean;
var
  Packet: TOpenMailPacket absolute Buffer;
  Mails: TCharacterMail;
  Mail: TMail;
  MailLen, MailSlot: WORD;
  SendUser, Title: string;
begin
  Result := False;

  if not(Self.GetMails(string(Player.Character.Base.Name), Mails)) then
  begin
    Exit;
  end;

  MailLen := Length(Mails);

  if not(MailLen > Packet.Slot) then
  begin
    Exit;
  end;

  MailSlot := MailLen - 1 - Packet.Slot;

  if not(Mails[MailSlot].Index = Packet.Index) then
  begin
    if not(Self.GetMailSlot(Mails, Packet.Index, MailSlot)) then
      Exit;
  end;

  case Packet.OpenType of

{$REGION 'Ver conteúdo da carta'}
    0:
      begin
        if not(Mails[MailSlot].Index = Packet.Index) then
        begin
          Exit;
        end;

        if not(Self.SendMailContent(Player, Mails[MailSlot])) then
        begin
          Exit;
        end;

        Mails[MailSlot].Checked := True;

        if not(Mails[MailSlot].CheckItem) then
        begin
          Mails[MailSlot].DataRetorno := IncDay(Now, 4);
        end;

        Self.SaveMails(string(Player.Character.Base.Name), Mails);
      end;

{$ENDREGION}
{$REGION 'Remove carta'}
    1:
      begin
        if not(Mails[MailSlot].Index = Packet.Index) then
        begin
          Logger.Write('Wrong mail index.', TLogType.Packets);
          Exit;
        end;

        if not(Self.RemoveMail(Mails, Packet.Index)) then
        begin
          Logger.Write('Failed to remove mail.', TLogType.Packets);
          Exit;
        end;

        Self.SaveMails(string(Player.Character.Base.Name), Mails);

        Packet.Slot := 0;
        Packet.CharIndex := Player.Character.Index;
        Packet.Delete := True;

        Player.SendPacket(Packet, Packet.Header.Size);

        Self.SendRefreshMails(Player, Mails);
      end;

{$ENDREGION}
{$REGION 'Devolver carta'}
    2:
      begin
        if not(Self.GetMail(Mails, Packet.Index, Mail)) then
        begin
          Exit;
        end;

        Self.RemoveMail(Mails, Mail.Index);
        Self.SaveMails(string(Player.Character.Base.Name), Mails);

        SendUser := string(Mail.Nick);
        Mail.Return := False;
        Mail.Checked := False;
        IncDay(Mail.DataRetorno, 15);

        Title := '[Retornou] ' + Mail.Titulo;

        AnsiStrings.StrPLCopy(Mail.Titulo, AnsiString(Title), 32);

        AnsiStrings.StrLCopy(Mail.Nick, Player.Character.Base.Name, 16);

        if not(Self.AddMail(SendUser, Mail)) then
        begin
          Exit;
        end;

        Packet.Slot := 0;
        Packet.CharIndex := Player.Character.Index;
        Packet.Delete := True;

        Player.SendPacket(Packet, Packet.Header.Size);

        Self.SendRefreshMails(Player, Mails);
      end;
{$ENDREGION}
{$REGION 'Pegar Gold Carta'}
    3:
      begin
        if not(Self.GetMail(Mails, Packet.Index, Mail)) then
        begin
          Exit;
        end;

        if (Mail.Gold = 0) then
          Exit;

        Player.AddGold(Mail.Gold);
        Mail.Gold := 0;

        Mail.Return := False;

        if not(Self.SaveMail(Mails, Mail)) then
          Exit;

        Self.SaveMails(string(Player.Character.Base.Name), Mails);

        Self.SendMailContent(Player, Mail);
      end;

{$ENDREGION}
  end;

  Result := True;
end;

class function TMailFunctions.GetMailContent(var Player: TPlayer; var Buffer: array of BYTE): Boolean;
var
  Packet: TGetMailContentPacket absolute Buffer;
  Mails: TCharacterMail;
  Mail: TMail;
  ItemCount: BYTE;
begin
  Result := False;

  if not(Self.GetMails(string(Player.Character.Base.Name), Mails)) then
  begin
    Exit;
  end;

  if not(Self.GetMail(Mails, Packet.Index, Mail)) then
  begin
    Exit;
  end;

  if (Packet.Slot > 4) then
  begin
    Exit;
  end;

  if not(Mail.Item[Packet.Slot].Index <> 0) then
  begin
    Exit;
  end;

  if (TItemFunctions.PutItem(Player, Mail.Item[Packet.Slot], 0, True) = 255) then
  begin
    Exit;
  end;

  ZeroMemory(@Mail.Item[Packet.Slot], sizeof(TItem));

  ItemCount := Self.MailItemsCount(Mail);

  if (ItemCount = 0) then
  begin
    Mail.CheckItem := False;
  end;

  Mail.Return := False;

  Self.SaveMail(Mails, Mail);
  Self.SaveMails(string(Player.Character.Base.Name), Mails);

  Self.SendMailContent(Player, Mail);

  if (ItemCount = 0) then
  begin
    Self.SendRefreshMails(Player, Mails);
  end;

  Result := True;
end;

{$ENDREGION}

end.
