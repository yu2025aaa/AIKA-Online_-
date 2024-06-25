unit AuthHandlers;

interface

uses
  Winsock2, Windows, Classes,
  StrUtils, SysUtils, DateUtils,
  LoginSocket, AnsiStrings, Player;

type
  TAuthHandlers = class(TObject)
  public
    { HTTP Request Functions }
    class function AikaGetToken(Params: TStrings; var Response: string)
      : Boolean;
    class function AikaGetChrCnt(Params: TStrings;
      var Response: string): Boolean;
    class function GetServerPlayers(var Response: string): Boolean;
    class function AikaResetFlag(Params: TStrings;
      var Response: string): Boolean;
    class function AikaCreateAccount(Params: TStrings;
      var Response: string): Boolean;

    { Login Functions }
    class function CheckToken(var Connection: TConnection;
      Buffer: ARRAY OF BYTE): Boolean;

    { PingBack Functions }
    class function CheckPingback(Params: TStrings;
      var Response: string): Boolean;
  end;

implementation

uses
  Functions, GlobalDefs, Log, Packets, EncDec, MMSystem, PlayerData,
  SQL;

{$REGION 'HTTP Request Functions'}

class function TAuthHandlers.AikaGetToken(Params: TStrings;
  var Response: string): Boolean;
var
  Player: TPlayer;
  Username, Password: string;
begin
  Result := False;

  Username := ReplaceStr(Params[0], 'id=', '');
  Password := ReplaceStr(Params[1], 'pw=', '');

  if (Player.LoadAccountSQL(Username)) then
  begin
    if (string(Player.Account.Header.Password) = Password) then
    begin
      case Player.Account.Header.AccountStatus of
        2: //conta cancelada
          begin
            Response := '-2';
          end;

        8: //usuario banido permanentemente
          begin
            if (Player.Account.Header.BanDays > 0) then
            begin
              if (IncDay(Player.Account.Header.Token.CreationTime,
                Player.Account.Header.BanDays) <= Now) then
              begin
                Player.Account.Header.BanDays := 0;
                Player.Account.Header.AccountStatus := 0;

                Response := '-22';
                Player.SaveStatus(Username);
              end
              else
              begin
                Response := '-8'; { Account Banned }
              end;
            end
            else
            begin
              Response := '-8'; { Account Banned }
            end;
          end;

        10: //usuario nao CBT
          begin
            Response := '-10';
          end

      else
        begin
          Player.Account.Header.Token.Generate(Password);
          { Gera o token a partir da senha }

          Logger.Write('Token [' + string(Player.Account.Header.Token.Token) +
            '] criado por ' + Username + '.', TlogType.ConnectionsTraffic);

          Response := string(Player.Account.Header.Token.Token);

          // Player.Account.Header.IsActive := FALSE;
          // Player.Base.IsActive := FALSE;

          Player.SaveAccountToken(Username);

          Result := True;
        end;
      end;
    end
    else
    begin
      Response := '-1'; { Incorret Password }
    end;
  end
  else
  begin
    Response := '0'; { Account not found }
  end;

  ZeroMemory(@Player, SizeOf(Player));
end;

class function TAuthHandlers.AikaGetChrCnt(Params: TStrings;
  var Response: string): Boolean;
var
  Player: TPlayer;
  Username, Password: string;
begin
  Result := False;

  Username := ReplaceStr(Params[0], 'id=', '');
  Password := ReplaceStr(Params[1], 'pw=', '');

  if (Player.LoadAccountSQL(Username)) then
  begin
    if (string(Player.Account.Header.Token.Token) = Password) then
    begin

      Response := 'CNT ' + Player.Account.GetCharCount
        (Player.Account.Header.AccountId, 0, @Player).ToString + ' 0 0 0<br>' +
        Integer(Player.Account.Header.Nation).ToString + ' 0 0 0';

      Result := True;

    end
    else
    begin
      Response := '-1'; { Incorret Password }
    end;
  end
  else
  begin
    Response := '0'; { Account not found }
  end;

  ZeroMemory(@Player, SizeOf(Player));
end;

class function TAuthHandlers.GetServerPlayers(var Response: string): Boolean;
var
  I: BYTE;
begin
  Result := False;
  Response := '';

  if not(LoginServer.IsActive) then
    Exit;

  for I := Low(Servers) to High(Servers) do
  begin
    if Servers[I].IsActive then
    begin
      if(Servers[I].InstantiatedPlayers = 0) then
        Response := Response + '1 '
      else
        Response := Response + Servers[I].InstantiatedPlayers.ToString + ' ';
    end
    else
      Response := Response + '-1 ';
  end;

  if Response[Length(Response)] = ' ' then
    Delete(Response, Length(Response), 1);

  Result := True;
end;

class function TAuthHandlers.AikaResetFlag(Params: TStrings;
  var Response: string): Boolean;
var
  Username, Password: string;
  Player: TPlayer;
begin
  Username := ReplaceStr(Params[0], 'id=', '');
  Password := ReplaceStr(Params[1], 'pw=', '');

  Result := False;

  if (Player.LoadAccountSQL(Username)) then
  begin
    if (string(Player.Account.Header.Token.Token) = Password) then
    begin

      Player.Account.Header.Token.CreationTime := Now;

      Logger.Write('Token criado por ' + Username + ' foi renovado.',
        TlogType.ConnectionsTraffic);

      Response := string(Player.Account.Header.Token.Token);

      Player.SaveAccountToken(Username);

      Result := True;
    end
    else
    begin
      Response := '-1'; { Incorret Password }
    end;
  end
  else
  begin
    Response := '0'; { Account not found }
  end;

  ZeroMemory(@Player, SizeOf(Player));
end;

class function TAuthHandlers.AikaCreateAccount(Params: TStrings;
  var Response: string): Boolean;
var
  Username, Password: string;
  Account: TAccountFile;
  AccType: TAccountType;
  MySQLComp: TQuery;
begin
  Username := ReplaceStr(Params[0], 'id=', '');
  Password := ReplaceStr(Params[1], 'pw=', '');
  AccType := TAccountType(StrToInt(ReplaceStr(Params[2], 'acctype=', '')));

  Result := False;
  Response := '0';

  MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(MySQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[AikaCreateAccount]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[AikaCreateAccount]', TlogType.Error);
    Exit;
  end;

  MySQLComp.SetQuery('INSERT INTO accounts (username, password, password_hash, last_token_creation_time'+
    ', nation, isactive, account_status, account_type, storage_gold, cash, ip_created, time_created'+
    ') VALUES ('+QuotedStr(Username)+','+QuotedStr(Password)+','+ QuotedStr(TFunctions.StringToMd5(Password)) +','+QuotedStr('01/01/0001 00:00:01')+',2,0,0,0,0,0,' + QuotedStr('::0')+ ',1)');

  MySQLComp.Run(False);
 { if (TFunctions.FindAccount(Username)) then
    Exit;

  if not(TFunctions.IsLetter(Username)) then
  begin
    Response := '-1';
    Exit;
  end;

  if (Length(Username) > 16) or (Length(Password) > 12) then
  begin
    Response := '-2';
    Exit;
  end;

  ZeroMemory(@Account, SizeOf(Account));

  try
    // Account.Header.AccountId := TFunctions.IncAccountsCount;
    Account.Header.Username := ShortString(Username);
    Account.Header.Password := ShortString(Password);
    Account.Header.AccountType := AccType;
  finally
    TFunctions.SaveAccountFile(Account, Username);
  end;                             }

  Result := True;
  Response := Account.Header.AccountId.ToString;

  Logger.Write('Conta: ' + string(Account.Header.Username) +
    ' criada com o privilégio: ' + BYTE(Account.Header.AccountType).ToString,
    TlogType.ConnectionsTraffic);

  ZeroMemory(@Account, SizeOf(Account));
end;

{$ENDREGION}
{$REGION 'Login Functions'}

class function TAuthHandlers.CheckToken(var Connection: TConnection;
  Buffer: array of BYTE): Boolean;
var
  Packet: TCheckTokenPacket absolute Buffer;
  Pacote: TResponseLoginPacket;
  Player: TPlayer;
begin

  if (Player.LoadAccountSQL(string(Packet.Username))) then
  begin
     //Logger.Write(String(Player.Account.Header.Token.Token), TlogType.Packets);

    if (Player.Account.Header.Token.Token = Packet.Token) and
      (SecondsBetween(Now, Player.Account.Header.Token.CreationTime) < 300) then
    begin
      if (Player.Account.Header.AccountStatus = 8) then
      begin
        Connection.Destroy;
        Result := False;
      end
      else
      begin
        ZeroMemory(@Pacote, SizeOf(TResponseLoginPacket));
        Pacote.Header.Size := SizeOf(TResponseLoginPacket);
        Pacote.Header.Code := $82;

        Pacote.Index := Player.Account.Header.AccountId;
        Pacote.Time := TimeGetTime;

        Pacote.Nation := Player.Account.Header.Nation;

        Connection.SendPacket(Pacote, Pacote.Header.Size);

        Logger.Write('Novo login de ' + Packet.Username + ' em ' + '[' +
          DateTimeToStr(Now) + '].', TlogType.ConnectionsTraffic);
        Connection.Checked := True;
        Connection.Destroy;
        Result := True;
      end;
    end
    else
    begin
      Logger.Write('Token enviada por ' + Packet.Username + ' está incorreta.',
        TlogType.ConnectionsTraffic);
      Connection.Destroy;
      Result := False;
    end;
  end
  else
  begin
    Connection.Destroy;
    Result := False;
  end;

  ZeroMemory(@Player, SizeOf(Player));
end;

{$ENDREGION}
{$REGION 'PingBack Functions'}

class function TAuthHandlers.CheckPingback(Params: TStrings;
  var Response: string): Boolean;
var
  TokenReceived, UsernameReceived: String;
  ProductReceived: Integer;
  i: Integer;
  ClientID: Integer;
  ServerID: Byte;
  BannedUser: Integer;
begin //checar token que vier
  BannedUser := 0;

  UsernameReceived := ReplaceStr(Params[0], 'user=', '');
  TokenReceived := ReplaceStr(Params[1], 'token=', '');

  if(length(TokenReceived) <> length(ASAAS_TOKEN_PINGBACK)) then
  begin
    Response := '{ "error": "Provided token length is invalid" }';
    Exit;
  end;

  if(TokenReceived <> ASAAS_TOKEN_PINGBACK) then
  begin
    Response := '{ "error": "Invalid token provided" }';
    Exit;
  end;

  if(trim(UsernameReceived) = '') or (length(UsernameReceived) < 4) then
  begin
    Response := '{ "error": "Invalid username provided" }';
    Exit;
  end;

  try
    ProductReceived := StrToInt(ReplaceStr(Params[2], 'value=', ''));
  except
    on E: Exception do
    begin
      Response := '{ "error": "Value is not a integer" }';
      Exit;
    end;
  end;

  BannedUser := StrToInt(ReplaceStr(Params[3], 'ban=', ''));

  ServerID := 255;

  for I := Low(Servers) to High(Servers) do
  begin
    ClientID := Servers[i].GetPlayerByUsername(UsernameReceived);

    if(ClientID <> 0) then
    begin
      ServerID := i;
      break;
    end;
  end;

  if(ServerID <> 255) then
  begin
    case ProductReceived of
      10000, -10000:
        begin
          Servers[ServerID].Players[ClientID].AddCash(ProductReceived);
          if(ProductReceived > 0) then
            Servers[ServerID].Players[ClientID].SendClientMessage('Suas [10.000 iNiz Coins] foram entregues, confira apertando J.', 16, 32, 16)
            else
            Servers[ServerID].Players[ClientID].SendClientMessage('Você teve seu saldo retirado em 10.000 iNiz Coins.', 16, 32, 16);
        end;
      20000, -20000:
        begin
          Servers[ServerID].Players[ClientID].AddCash(ProductReceived);
          if(ProductReceived > 0) then
            Servers[ServerID].Players[ClientID].SendClientMessage('Suas [20.000 iNiz Coins] foram entregues, confira apertando J.', 16, 32, 16)
            else
            Servers[ServerID].Players[ClientID].SendClientMessage('Você teve seu saldo retirado em 20.000 iNiz Coins.', 16, 32, 16);
        end;
      50000, -50000:
        begin
          Servers[ServerID].Players[ClientID].AddCash(ProductReceived);
          if(ProductReceived > 0) then
            Servers[ServerID].Players[ClientID].SendClientMessage('Suas [50.000 iNiz Coins] foram entregues, confira apertando J.', 16, 32, 16)
            else
            Servers[ServerID].Players[ClientID].SendClientMessage('Você teve seu saldo retirado em 50.000 iNiz Coins.', 16, 32, 16);
        end;
      100000, -100000:
        begin
          Servers[ServerID].Players[ClientID].AddCash(ProductReceived);
          if(ProductReceived > 0) then
            Servers[ServerID].Players[ClientID].SendClientMessage('Suas [100.000 iNiz Coins] foram entregues, confira apertando J.', 16, 32, 16)
          else
            Servers[ServerID].Players[ClientID].SendClientMessage('Você teve seu saldo retirado em 100.000 iNiz Coins.', 16, 32, 16);
        end;
    else
      begin
        Response := '{ "error": "Invalid value." }';
        Exit;
      end;
    end;

    if(BannedUser = 1) then
    begin
      Servers[ServerID].Players[ClientID].Account.Header.AccountStatus := 8;
      Servers[ServerID].Players[ClientID].SendCloseClient;
    end
    else if(BannedUser = 2) then
    begin
      Servers[ServerID].Players[ClientID].Account.Header.AccountStatus := 10;
      Servers[ServerID].Players[ClientID].SendCloseClient;
    end
  end
  else
  begin
    Response := '{ "error": "User isn'+#39+'t online." }';
    Exit;
  end;

  Response := '{ "success": "VALUE_INSERTED" }';
  if(BannedUser = 1) then
    Response := Response + #13 + '{ "success": "USER_BANNED" }';
end;

{$ENDREGION}

end.
