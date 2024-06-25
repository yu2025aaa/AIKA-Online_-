unit PingBackForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  IdHTTPServer, IdCustomHTTPServer, IdContext,
  StrUtils, IdServerIOHandler;

type
  TfrmPingback = class(TForm)
    memLog: TMemo;
    btnClearLog: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;


type
  TPingbackServer = class(TObject)
    Requests: TIdHTTPServer;

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

var
  frmPingback: TfrmPingback;

implementation

{$R *.dfm}

uses
  GlobalDefs, AuthHandlers, Log;

constructor TPingbackServer.Create;
begin
  Self.Requests := TIdHTTPServer.Create(Nil);
  Self.Requests.DefaultPort := 8090;
  Self.Requests.OnCommandGet := Self.OnGetCommand;
 {
  SSLServer := TIdServerIOHandlerSSLOpenSSL.Create(Nil);
  SSLServer.SSLOptions.CertFile := 'mycert.pem';
  SSLServer.SSLOptions.KeyFile := 'mycert.pem';
  SSLServer.SSLOptions.Mode := sslmServer;
  SSLServer.SSLOptions.VerifyDepth := 1;

  Self.Requests.IOHandler := SSLServer;  }

  inherited Create;
end;

function TPingbackServer.StartServer: Boolean;
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
    Logger.Write('Erro ao iniciar o TokenServer.', TLogType.ServerStatus);
  end;
end;

procedure TPingbackServer.CloseServer;
begin

end;

procedure TPingbackServer.OnGetCommand(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  AResponseInfo.ContentText := Self.RequestControl(ARequestInfo.Document,
    ARequestInfo.Params);
end;

function TPingbackServer.GetActive: Boolean;
begin
  Result := Self.Requests.Active;
end;

procedure TPingbackServer.SetActive(Active: Boolean);
begin
  Self.Requests.Active := Active;
end;

function TPingbackServer.RequestControl(URL: string; Param: TStrings): string;
begin
  case AnsiIndexStr(URL, ['/pingback.asp']) of

    0:
      TAuthHandlers.CheckPingback(Param, Result);

  end;
end;

end.
