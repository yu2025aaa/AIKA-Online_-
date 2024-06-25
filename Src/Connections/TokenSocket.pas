unit TokenSocket;
interface
uses
  IdHTTPServer, IdCustomHTTPServer, IdContext, Classes,
  StrUtils, IdServerIOHandler, IdSSL, IdSSLOpenSSL, Windows, SysUtils;

type
  TSSLHelper = class
    procedure QuerySSLPort(APort: Word; var VUseSSL: boolean);
  end;

type
  TTokenServer = class(TObject)
    Requests: TIdHTTPServer;
    SSLServer: TIdServerIOHandlerSSLOpenSSL;
    SSLHelper: TSSLHelper;
  public
    procedure OnGetCommand(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure OnCommandError(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo; AException: Exception);
    function GetActive: Boolean;
    procedure SetActive(Active: Boolean);

    property IsActive: Boolean read GetActive write SetActive;
    constructor Create;
    function StartServer: Boolean;
    procedure CloseServer;
    function RequestControl(URL: string; Param: TStrings; var IsJson: Boolean): string;
  end;
type
  TTokenServerAdmin = class(TObject)
    Requests: TIdHTTPServer;
    SSLServer: TIdServerIOHandlerSSLOpenSSL;
  private
    procedure OnGetCommand(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    function GetActive: Boolean;
    procedure SetActive(Active: Boolean);
  public
    property IsActive: Boolean read GetActive write SetActive;
    constructor Create;
    function StartServer: Boolean;
    procedure CloseServer;
    function RequestControl(URL: string; Param: TStrings): string;
  end;


implementation
uses
  AuthHandlers, GlobalDefs, Log;
procedure TSSLHelper.QuerySSLPort(APort: Word; var VUseSSL: boolean);
begin
  VUseSSL := true;
end;
constructor TTokenServer.Create;
begin
  Self.Requests := TIdHTTPServer.Create(Nil);
  Self.Requests.DefaultPort := 8090;
  Self.Requests.OnCommandGet := Self.OnGetCommand;
  Self.Requests.OnCommandError := Self.OnCommandError;
  SSLServer := TIdServerIOHandlerSSLOpenSSL.Create(Nil);
  SSLServer.SSLOptions.CertFile := 'mycert.pem';
  SSLServer.SSLOptions.KeyFile := 'mycert.pem';
  SSLServer.SSLOptions.Mode := sslmServer;
  //SSLServer.
  SSLServer.SSLOptions.SSLVersions := [sslvSSLv2, sslvSSLv23, sslvSSLv3, sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
  //SSLServer.SSLContext.SSLVersions := [sslvTLSv1_2]; //
  SSLServer.SSLOptions.VerifyDepth := 1;
  Self.Requests.IOHandler := SSLServer;
  SSLHelper := TSSLHelper.Create;
  Self.Requests.OnQuerySSLPort := SSLHelper.QuerySSLPort;
  inherited Create;
end;
function TTokenServer.StartServer: Boolean;
begin
  Self.SetActive(True);
  Result := False;
  if (Self.GetActive) then
  begin
    Result := True;
    Logger.Write('Token Server iniciado com sucesso [Porta: 8090].',
      TLogType.ServerStatus);
  end
  else
  begin
    Logger.Write('Erro ao iniciar o TokenServer.', TLogType.Warnings);
  end;
end;
procedure TTokenServer.CloseServer;
begin
end;
procedure TTokenServer.OnGetCommand(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  SSLHelper: TSSLHelper;
  isJson: Boolean;
begin
  isJson := False;
  if (trim(ARequestInfo.Command) = '') then
  begin
    Exit;
  end;

  try
    if(trim(UPPERCASE(ARequestInfo.Command)) = 'POST') then
    begin
      AResponseInfo.ContentText := Self.RequestControl(ARequestInfo.Document,
        ARequestInfo.Params, isJson);

      if(isJson) then
        AResponseInfo.ContentType := 'application/json';
    end
    else
    begin
      AResponseInfo.ContentText := 'NGNIX iNiz Games © 2023 - 503 Forbidden';
    end;
  except
    on E: Exception do
    begin
      Logger.Write('Error at OnGetCommand TokenServer :: ' +
        E.Message + ' t: ' + DateTimeToStr(Now), TLogType.Error);
      //WebServerClosed := True;
    end;
  end;
end;

procedure TTokenServer.OnCommandError(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo; AException: Exception);
begin
  Logger.Write('Error at OnGetCommand TokenServer :: ' +
    AException.Message + ' t: ' + DateTimeToStr(Now), TLogType.Error);
  //WebServerClosed := True;
end;

function TTokenServer.GetActive: Boolean;
begin
  Result := Self.Requests.Active;
end;
procedure TTokenServer.SetActive(Active: Boolean);
begin
  Self.Requests.Active := Active;
end;
function TTokenServer.RequestControl(URL: string; Param: TStrings; var IsJson: Boolean): string;
begin
  if(xServerClosed) then
    Exit;
  case AnsiIndexStr(URL, ['/member/aika_get_token.asp',
    '/servers/aika_get_chrcnt.asp', '/servers/serv00.asp',
    '/servers/aika_reset_flag.asp',
    ('/gateway/v1/'+ASAAS_LINK_GATEWAY+'.asp')]) of
    0:
      begin
        if not(ServerHasClosed) then
          TAuthHandlers.AikaGetToken(Param, Result);
      end;
    1:
      begin
        if not(ServerHasClosed) then
          TAuthHandlers.AikaGetChrCnt(Param, Result);
      end;
    2:
      begin
        if not(ServerHasClosed) then
          TAuthHandlers.GetServerPlayers(Result);
      end;
    3:
      begin
        if not(ServerHasClosed) then
          TAuthHandlers.AikaResetFlag(Param, Result);
      end;
    4:
      begin
        if not(ServerHasClosed) then
          TAuthHandlers.CheckPingback(Param, Result);
        isJson := True;
      end;
  end;
end;

constructor TTokenServerAdmin.Create;
begin
  Self.Requests := TIdHTTPServer.Create(Nil);
  Self.Requests.DefaultPort := 9571;
  Self.Requests.OnCommandGet := Self.OnGetCommand;
  SSLServer := TIdServerIOHandlerSSLOpenSSL.Create(Nil);
  SSLServer.SSLOptions.CertFile := 'mycert.pem';
  SSLServer.SSLOptions.KeyFile := 'mycert.pem';
  SSLServer.SSLOptions.Mode := sslmServer;
  SSLServer.SSLOptions.VerifyDepth := 1;
  Self.Requests.IOHandler := SSLServer;
  inherited Create;
end;
function TTokenServerAdmin.StartServer: Boolean;
begin
  Self.SetActive(True);
  Result := False;
  if (Self.GetActive) then
  begin
    Result := True;
    Logger.Write('Token Server Admin iniciado com sucesso [Porta: 9571].',
      TLogType.ServerStatus);
  end
  else
  begin
    Logger.Write('Erro ao iniciar o TokenServerAdmin.', TLogType.Warnings);
  end;
end;
procedure TTokenServerAdmin.CloseServer;
begin
end;
procedure TTokenServerAdmin.OnGetCommand(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
    AResponseInfo.ContentText := Self.RequestControl(ARequestInfo.Document,
      ARequestInfo.Params);

end;
function TTokenServerAdmin.GetActive: Boolean;
begin
  Result := Self.Requests.Active;
end;
procedure TTokenServerAdmin.SetActive(Active: Boolean);
begin
  Self.Requests.Active := Active;
end;
function TTokenServerAdmin.RequestControl(URL: string; Param: TStrings): string;
begin
  //Logger.Write(URL, TLogType.Packets);
  case AnsiIndexStr(URL, ['/member/aika_get_token.asp',
    '/servers/aika_get_chrcnt.asp', '/servers/serv00.asp',
    '/servers/aika_reset_flag.asp'{, '/member/aika_create_account.asp'}]) of
    0:
      TAuthHandlers.AikaGetToken(Param, Result);
    1:
      TAuthHandlers.AikaGetChrCnt(Param, Result);
    2:
      TAuthHandlers.GetServerPlayers(Result);
    3:
      TAuthHandlers.AikaResetFlag(Param, Result);
    //4:
     // TAuthHandlers.AikaCreateAccount(Param, Result);
  end;
end;
end.
