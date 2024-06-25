unit SendPacketForm;
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;
type
  TfrmSendPacket = class(TForm)
    memPacket: TMemo;
    edtNick: TEdit;
    btnSendPacket: TButton;
    lblPacket: TLabel;
    Label1: TLabel;
    btncloseserver: TButton;
    edtClientID: TEdit;
    Label2: TLabel;
    btnSendByClientID: TButton;
    gbServerOperation: TGroupBox;
    btnSendMsg: TButton;
    edtMsg: TEdit;
    Label3: TLabel;
    btnResetServer: TButton;
    btnClearMsg: TButton;
    cbServerInfo: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lblCpu: TLabel;
    lblRam: TLabel;
    lblActivePlayers: TLabel;
    TimerServerInfo: TTimer;
    GroupBox1: TGroupBox;
    Label7: TLabel;
    lblChannels: TLabel;
    procedure btnSendPacketClick(Sender: TObject);
    procedure btncloseserverClick(Sender: TObject);
    procedure btnSendByClientIDClick(Sender: TObject);
    procedure btnSendMsgClick(Sender: TObject);
    procedure btnResetServerClick(Sender: TObject);
    procedure btnClearMsgClick(Sender: TObject);
    procedure TimerServerInfoTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure UpdateCaption(Content: String);
  end;
var
  frmSendPacket: TfrmSendPacket;
implementation
{$R *.dfm}
uses
  GlobalDefs, Functions, Packets, Log, Player, PlayerData, Load;
type
  TByteArray = record
    Content: ARRAY OF BYTE;
  end;
procedure TfrmSendPacket.UpdateCaption(Content: String);
begin
  Self.Caption := Content;
end;
procedure TfrmSendPacket.btnClearMsgClick(Sender: TObject);
begin
  edtMsg.Text := '';
end;
procedure TfrmSendPacket.btncloseserverClick(Sender: TObject);
var
  i: Integer;
begin
  Logger.Write('Fechando o servidor, aguarde...', TLogType.ConnectionsTraffic);
  try
    TFunctions.SaveGuilds;
  except
  end;
  try
    for i := Low(Nations) to High(Nations) do
    begin
      Nations[i].SaveNation;
    end;
  except
  end;
  for i := Low(Servers) to High(Servers) do
  begin
    Servers[i].CloseServer;
  end;
  xServerClosed := True;
  Logger.Write('Server Closed Succesfully!', TLogType.ServerStatus);
  Logger.Write('Feche a janela deste console. Tudo foi salvo!',
    TLogType.ConnectionsTraffic);
  ServerHasClosed := True;
  {while(StrToInt(Self.lblActivePlayers.Caption) > 0) do
    Sleep(10);
  Application.Terminate;
  keybd_event(VK_CONTROL, 0, 0, 0);
  keybd_event(Ord('C'), 0, 0, 0);
  keybd_event(Ord('C'), 0, KEYEVENTF_KEYUP, 0);
  keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP, 0);}
  //Self.Close;
end;
procedure TfrmSendPacket.btnResetServerClick(Sender: TObject);
var
  i: Integer;
begin
  Logger.Write('Resetando o servidor, aguarde...', TLogType.ConnectionsTraffic);
  InstantiatedChannels := 0;
  TFunctions.SaveGuilds;
  for i := Low(Nations) to High(Nations) do
  begin
    Nations[i].SaveNation;
  end;
  for i := Low(Servers) to High(Servers) do
  begin
    Servers[i].CloseServer;
  end;
  Logger.Write('Server Closed Succesfully!', TLogType.ConnectionsTraffic);
  TLoad.InitServers;
  Logger.Write('O servidor foi reiniciado com sucesso.',
    TLogType.ConnectionsTraffic);
end;
procedure TfrmSendPacket.btnSendByClientIDClick(Sender: TObject);
var
  i: Integer;
  Len: Integer;
  Buffer: ARRAY [0 .. 8091] OF BYTE;
  MPlayer: PPlayer;
begin
  ZeroMemory(@Buffer, 8092);
  if (memPacket.Text <= '') or (edtClientID.Text <= '') then
    Exit;
  for i := 0 to Length(Servers) - 1 do
  begin
    MPlayer := Servers[i].GetPlayer(StrToInt(edtClientID.Text));
    if (MPlayer.Status >= Playing) then
    begin
      Len := TFunctions.StrToArray(memPacket.Text, Buffer);
      if Len > 1 then
        Servers[i].Players[MPlayer.Base.ClientId].SendPacket(Buffer, Len);
      Break;
    end;
  end;
end;
procedure TfrmSendPacket.btnSendMsgClick(Sender: TObject);
var
  i: Integer;
begin
  if (edtMsg.Text = '') then
  begin
    MessageBox(0, 'Você não pode deixar o campo mensagem em branco', 'Erro', 0);
    Exit;
  end;
  for i := Low(Servers) to High(Servers) do
  begin
    Servers[i].SendServerMsg(AnsiString('[SERVER] ' + edtMsg.Text), 32, 16);
  end;
end;
procedure TfrmSendPacket.btnSendPacketClick(Sender: TObject);
var
  i: Integer;
  ClientId: Integer;
  Len: Integer;
  Buffer: ARRAY [0 .. 8091] OF BYTE;
begin
  ZeroMemory(@Buffer, 8092);
  if (memPacket.Text <= '') or (edtNick.Text <= '') then
    Exit;
  for i := 0 to Length(Servers) - 1 do
  begin
    ClientId := Servers[i].GetPlayerByName(edtNick.Text);
    if ClientId > 0 then
    begin
      Len := TFunctions.StrToArray(memPacket.Text, Buffer);
      if Len > 1 then
        Servers[i].Players[ClientId].SendPacket(Buffer, Len);
      Break;
    end;
  end;
end;
procedure TfrmSendPacket.TimerServerInfoTimer(Sender: TObject);
var
  Ram, Ram2, ActivePlayers, ActivePlayersIsolated: Integer;
  Cpu: Single;
  i, j, k: Integer;
begin
  Cpu := TFunctions.GetCPUUsage;
  //Ram := Round(TFunctions.GetMemoryUsed / (1048576));
  //Ram := TFunctions.GetMemoryUsed;
  ActivePlayers:= 0;
  Ram := 0;
  for I := Low(Servers) to High(Servers) do
  begin
    ActivePlayersIsolated := 0;
    for j := Low(Servers[i].Players) to High(Servers[i].Players) do
    begin
      if(Servers[i].Players[j].Status >= CharList) then
      begin
        inc(ActivePlayers);
        inc(ActivePlayersIsolated);
      end;
    end;
    Servers[i].ActiveReliquaresOnTemples := 0;
    for j := Low(Servers[i].Devires) to High(Servers[i].Devires) do
    begin
      if(Servers[i].Devires[j].DevirId = 0) then
        Continue;

      for k := 0 to 4 do
      begin
        if(Servers[i].Devires[j].Slots[k].ItemID > 0) then
          Inc(Servers[i].ActiveReliquaresOnTemples, 1);
      end;
    end;

    Servers[i].ActivePlayersNowHere := ActivePlayersIsolated;
    Ram := Ram + 630;
  end;
  ActivePlayersNow := ActivePlayers;
  Self.lblCpu.Font.Size := 8;
  case Round(Cpu) of
    0 .. 20:
      Self.lblCpu.Font.Color := clLime;
    21 .. 40:
      Self.lblCpu.Font.Color := clYellow;
    41 .. 60:
      Self.lblCpu.Font.Color := clMaroon;
    61 .. 80:
      Self.lblCpu.Font.Color := clRed;
    81 .. 100:
      begin
        Self.lblCpu.Font.Color := clRed;
        Self.lblCpu.Font.Size := 10;
      end;
  end;
  Ram2 := Round(Ram / 10);
  Self.lblRam.Font.Size := 8;
  case Ram2 of
    0 .. 50:
      Self.lblRam.Font.Color := clLime;
    51 .. 100:
      Self.lblRam.Font.Color := clYellow;
    101 .. 150:
      Self.lblRam.Font.Color := clRed;
  else
    begin
      Self.lblRam.Font.Color := clRed;
      Self.lblRam.Font.Size := 10;
    end;
  end;
  Self.lblCpu.Caption := FormatFloat('0.00 %', Cpu);
  Self.lblRam.Caption := FormatFloat('0.0 MB', Ram);
  Self.lblActivePlayers.Font.Color := clWhite;
  Self.lblChannels.Font.Color := clWhite;
  Self.lblActivePlayers.Caption := ActivePlayers.ToString;
  Self.lblChannels.Caption := InstantiatedChannels.ToString;
end;
end.
