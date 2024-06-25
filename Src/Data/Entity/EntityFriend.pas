unit EntityFriend;

interface

uses
  Windows, Generics.Collections;

{$OLDTYPELAYOUT ON}

type
  TFriend = packed record
  private
    bActive: Boolean;
  public
    id: UInt64;
    friendCharacterId: UInt64;
    friendCharacterName: AnsiString;

    procedure delete();
    procedure create(const id: UInt64; const friendCharacterId: UInt64;
      const friendCharacterName: AnsiString);
  end;

type
  TFriendList = TDictionary<UInt64, TFriend>;

type
  TEntityFriend = class(TObject)
  private
    fPlayer: Pointer;

    { add & remove friends }
    function setDisableFriend(const characterId: UInt64;
      const friendCharacterId: UInt64): Boolean;
  public
    { construct & destruct }
    constructor create(TargetPlayer: Pointer);

    { load  & save friends }
    function readFriendList(Player: Pointer): Boolean;

    { add & remove friends }
    function addFriend(characterIndex: UInt64): Boolean;
    function removeFriend(characterIndex: UInt64): Boolean;

    { get friend }
    function getFriend(const characterIndex: UInt64;
      out xPlayer: WORD; out xServer: Byte): Boolean;
  end;

{$OLDTYPELAYOUT OFF}

implementation

uses
  Player, SysUtils, Log, GlobalDefs, SQL;

{$REGION 'TFriend'}

procedure TFriend.delete;
begin
  self.bActive := False;
end;

procedure TFriend.create(const id: UInt64; const friendCharacterId: UInt64;
  const friendCharacterName: AnsiString);
begin
  self.bActive := True;

  self.id := id;
  self.friendCharacterId := friendCharacterId;
  self.friendCharacterName := friendCharacterName;
end;

{$ENDREGION}
{$REGION 'construct & destruct'}

constructor TEntityFriend.create(TargetPlayer: Pointer);
var
  Player: PPlayer;
begin
  inherited create;

  self.fPlayer := TargetPlayer;

  Player := (TargetPlayer); //tinha PPlayer()
  Player.FriendList := TFriendList.create(50);
  Player.FriendList.Clear();
end;

{$ENDREGION}
{$REGION 'load  & save friends'}

function TEntityFriend.readFriendList(Player: Pointer): Boolean;
var
  SPlayer: PPlayer;
  currentFriend: TFriend;
  i: BYTE;

  fID: UInt64;
  fCharID: UInt64;
  fName: String;
  SQLComp: TQuery;
begin
  Result := False;

  SPlayer := Player;

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[readFriendList]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[readFriendList]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  try
    SPlayer^.FriendList.Clear;

    SQLComp.SetQuery
      (format('SELECT friends.id, friends.friend_characterId, characters.name FROM friend_list as friends'
      + ' INNER JOIN characters ON friends.friend_characterId = characters.id '
      + 'WHERE active > 0 AND friends.owner_characterId = %d ORDER BY friends.id DESC LIMIT 50',
      [SPlayer^.Character.Base.CharIndex]));
    SQLComp.Run();

    {SPlayer^.PlayerSQL.SetQuery(
      format('SELECT id, friend_characterId FROM friend_list WHERE active=1 AND '+
      'owner_characterId = %d LIMIT 50', [SPlayer^.Character.Base.CharIndex]));
      }

   { SPlayer^.PlayerSQL.SetQuery(format('SELECT id, friend_characterId WHERE '+
    'owner_characterId=%d AND active=1', [SPlayer^.Character.Base.CharIndex]));
    SPlayer^.PlayerSQL.Run(); }

    if not(SQLComp.Query.RecordCount = 0) then
    begin
      SQLComp.Query.First;
      for i := 0 to (SQLComp.Query.RecordCount - 1) do
      begin
        ZeroMemory(@currentFriend, sizeof(TFriend));

        {fID := UInt64(SPlayer^.PlayerSQL.Query.FieldByName('id')
          .AsLargeInt);
        fCharID := UInt64(SPlayer^.PlayerSQL.Query.FieldByName('friend_characterId')
          .AsLargeInt);

        SPlayer^.PlayerSQL.SetQuery(format
        ('SELECT name FROM characters WHERE id=%d'), [fCharId]);
        SPlayer^.PlayerSQL.Run(); }

        currentFriend.create(UInt64(SQLComp.Query.FieldByName('id')
          .AsLargeInt),
          UInt64(SQLComp.Query.FieldByName('friend_characterId')
          .AsLargeInt), AnsiString(SQLComp.Query.FieldByName('name')
          .AsString));

        if not(SPlayer^.FriendList.ContainsKey(currentFriend.friendCharacterId)) then
          SPlayer^.FriendList.Add(currentFriend.friendCharacterId, currentFriend);

        SQLComp.Query.Next;
      end;
    end
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on loading friend list. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(SPlayer^.Character.Base.ClientId.ToString) + '] ' + DateTimeToStr(Now) +
        '.', TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
  end;

  SQLComp.Destroy;

  Result := True;
end;

{$ENDREGION}
{$REGION 'add & remove friends'}

function TEntityFriend.setDisableFriend(const characterId: UInt64;
  const friendCharacterId: UInt64): Boolean;
var
  Player: PPlayer;
  SQLComp: TQuery;
begin
  Result := False;

  Player := self.fPlayer;

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[setDisableFriend]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[setDisableFriend]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  try
    SQLComp.SetQuery
      (format('UPDATE friend_list SET active = 0, lastUpdateDate = NOW() WHERE '+
      'owner_characterId = %d AND friend_characterId = %d',
      [characterId, friendCharacterId]));

    //Player.PlayerSQL.AddParameter2('owner_characterId', characterId);
    //Player.PlayerSQL.AddParameter2('friend_characterId', friendCharacterId);
    SQLComp.Run(False);
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on setting friend disabled. msg[' + E.Message +
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

function TEntityFriend.addFriend(characterIndex: UInt64): Boolean;
var
  Player: PPlayer;
  SQLComp: TQuery;
begin
  Result := False;

  Player := self.fPlayer;

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[addFriend]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[addFriend]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  try
    //Player.FriendList.Clear;

    SQLComp.SetQuery
      (format('INSERT INTO friend_list (owner_characterId, friend_characterId, registerDate, lastUpdateDate)'
      + ' VALUES (%d, %d, NOW(), NOW())',
      [Player.Character.Index, characterIndex]));

    //Player.PlayerSQL.AddParameter2('owner_characterId', Player.Character.Index);
    //Player.PlayerSQL.AddParameter2('friend_characterId', characterIndex);
    SQLComp.Run(False);

  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on adding friend to list. msg[' + E.Message +
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

function TEntityFriend.removeFriend(characterIndex: UInt64): Boolean;
var
  Player: PPlayer;
  OtherPlayer: WORD;
  OtherServer: Byte;
begin
  Result := False;

  Player := self.fPlayer;

  try
    if not(self.setDisableFriend(Player^.Character.Index, characterIndex)) then
      Exit;

    if not(self.setDisableFriend(characterIndex, Player^.Character.Index)) then
      Exit;

    Player^.sendDeleteFriend(characterIndex);
    Player^.CloseFriendWindow(characterIndex);

    if (self.getFriend(characterIndex, OtherPlayer, OtherServer)) then //tinha Pointer()
    begin
      Servers[OtherServer].Players[OtherPlayer].sendDeleteFriend(Player^.Character.Index);
      Servers[OtherServer].Players[OtherPlayer].CloseFriendWindow(Player^.Character.Index);

      Servers[OtherServer].Players[OtherPlayer].FriendList.Remove(Player^.Character.Index);
    end;

    Player^.FriendList.Remove(characterIndex);
  except
    on E: Exception do
    begin
      Logger.Write('Error on deleting friend. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] clientId [' +
        String(Player^.Character.Base.ClientId.ToString) + '] ' + DateTimeToStr(Now) +
        '.', TlogType.Error);
      Exit;
    end;
  end;

  Result := True;
end;

{$ENDREGION}
{$REGION 'get friend'}

function TEntityFriend.getFriend(const characterIndex: UInt64;
  out xPlayer: WORD; out xServer: Byte): Boolean;
var
  i: BYTE;
  playerOut: TPlayer;
begin
  Result := False;

  for i := Low(Servers) to High(Servers) do
  begin
    if not(Servers[i].GetPlayerByCharIndex(characterIndex, playerOut)) then
      Continue;

    Result := True;
    xPlayer := playerOut.Base.ClientID; //tinha pointer()
    xServer := i;
    break;
  end;
end;

{$ENDREGION}

end.
