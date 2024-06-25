unit AccCreatorForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL;

type
  TFormAccount = class(TForm)
    lblUsername: TLabel;
    edtUsername: TEdit;
    lblPassword: TLabel;
    edtPassword: TEdit;
    BtnCreateAccount: TButton;
    Request: TIdHTTP;
    SSL_IO: TIdSSLIOHandlerSocketOpenSSL;
    lblAccType: TLabel;
    edtAccType: TEdit;
    procedure BtnCreateAccountClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormAccount: TFormAccount;

implementation

{$R *.dfm}

uses
  StrUtils;

procedure TFormAccount.BtnCreateAccountClick(Sender: TObject);
var
  Response: string;
  acctype: string;
begin
  Response := Self.Request.Get
    ('https://127.0.0.1:8090/member/aika_create_account.asp?id=' +
    Self.edtUsername.Text + '&pw=' + Self.edtPassword.Text + '&acctype='
    + edtAccType.Text);

  case AnsiIndexStr(Response, ['0', '-1', '-2', '']) of

    0:
      begin
        MessageBox(0, 'Usuario já existe !', 'Conta', MB_ICONERROR);
      end;

    1:
      begin
        MessageBox(0, 'Nome de usuário invalido !', 'Conta', MB_ICONERROR);
      end;

    2:
      begin
        MessageBox(0, 'Usuario ou senha são muito grandes !', 'Conta',
          MB_ICONERROR);
      end;

    3:
      begin
        MessageBox(0, 'A conexão com o servidor falhou !', 'Conta',
          MB_ICONERROR);
      end;

  else
    begin
      MessageBox(0, 'Conta criada com sucesso !', 'Conta', MB_ICONINFORMATION);
    end;

  end;
end;

end.
