unit ConfigForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Grids,
  Vcl.StdCtrls, Vcl.Buttons;

type
  TFormConfig = class(TForm)
    PageOptions: TPageControl;
    TabServerList: TTabSheet;
    PanelRightSL: TPanel;
    GridServers: TStringGrid;
    lblChannelName: TLabel;
    edtChannelName: TEdit;
    edtIpAddress: TEdit;
    lblIpAddress: TLabel;
    BtnUpdateServer: TButton;
    PanelUpdateServer: TPanel;
    PanelSLFile: TPanel;
    LabelSLFile: TLabel;
    EditSLFile: TEdit;
    lblChannelNationIndex: TLabel;
    edtChannelNationIndex: TEdit;
    lblChannelIndex: TLabel;
    edtChannelIndex: TEdit;
    BtnOpenFile: TButton;
    BtnSaveFile: TButton;
    OpenDialog: TOpenDialog;
    lblCheck: TLabel;
    edtUnk: TEdit;
    edtCheck: TEdit;
    lblUnk: TLabel;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnOpenFileClick(Sender: TObject);
    procedure GridServersSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure BtnSaveFileClick(Sender: TObject);
    procedure BtnUpdateServerClick(Sender: TObject);
  private
    { Private declarations }

    SelectedChannel: BYTE;
  public

    { Server List }
    procedure LoadFormServerList;
    procedure SetSLGridHeader;
    procedure ClearFormServerList;
    procedure FillChannelInformation;
  end;

var
  FormConfig: TFormConfig;

implementation

{$R *.dfm}

uses
  GlobalDefs, Functions;

{$REGION 'Form Functions'}

procedure TFormConfig.FormCreate(Sender: TObject);
begin
{$REGION 'Set SL'}
  Self.SetSLGridHeader;

{$ENDREGION}
end;

procedure TFormConfig.FormResize(Sender: TObject);
begin
{$REGION 'SL'}
  Self.GridServers.ColWidths[1] := Trunc((Self.GridServers.Width - Self.GridServers.ColWidths[0] - 7) / 2);
  Self.GridServers.ColWidths[2] := Self.GridServers.ColWidths[1] - 17;
{$ENDREGION}
end;

{$ENDREGION}
{$REGION 'Server List'}

procedure TFormConfig.LoadFormServerList;
var
  i: WORD;
begin
  Self.GridServers.RowCount := Length(ServerList) - 1;

  for i := 0 to Length(ServerList) - 1 do
  begin
    Self.GridServers.Rows[i + 1].Add(i.ToString);
    Self.GridServers.Rows[i + 1].Add(string(ServerList[i].Name));
    Self.GridServers.Rows[i + 1].Add(string(ServerList[i].Ip));
  end;
end;

procedure TFormConfig.SetSLGridHeader;
begin
  Self.GridServers.Cells[0, 0] := 'Index';
  Self.GridServers.Cells[1, 0] := 'Channel name';
  Self.GridServers.Cells[2, 0] := 'IP';
end;

procedure TFormConfig.ClearFormServerList;
var
  i: WORD;
begin
  for i := 0 to (Self.GridServers.RowCount) - 1 do
    Self.GridServers.Rows[i + 1].Clear;
end;

procedure TFormConfig.FillChannelInformation;
begin
  if (Length(ServerList) = 0) then
    Exit;

  try
    Self.edtChannelName.Text := Trim(ServerList[SelectedChannel].Name);
    Self.edtIpAddress.Text := Trim(ServerList[SelectedChannel].Ip);
    Self.edtChannelNationIndex.Text := Trim(ServerList[SelectedChannel].NationIndex.ToString);
    Self.edtChannelIndex.Text := Trim(ServerList[SelectedChannel].ChannelNationIndex.ToString);
    Self.edtCheck.Text := '$' + Trim(ServerList[SelectedChannel].Check.ToHexString(8));
    Self.edtUnk.Text := '$' + Trim(ServerList[SelectedChannel].Unk_0.ToHexString(8));
  except
    on E: Exception do
    begin
      MessageBox(Self.Handle, PChar(E.Message), PChar(E.ClassName), MB_ICONERROR);
    end;
  end;
end;

{$ENDREGION}
{$REGION 'Server List Form Functions'}

procedure TFormConfig.GridServersSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  if (ARow = 0) then
    Exit;

  Self.SelectedChannel := ARow - 1;
  Self.FillChannelInformation;
end;

procedure TFormConfig.BtnOpenFileClick(Sender: TObject);
var
  FileName: string;
begin
  Self.OpenDialog.Filter := 'Server List|*.bin';
  Self.OpenDialog.Execute(Self.Handle);

  FileName := Self.OpenDialog.FileName;

  if (FileName = '') then
    Exit;

  if not(FileExists(FileName)) then
  begin
    MessageBox(Self.Handle, 'Arquivo não encontrado !', 'Arquivo inválido', MB_ICONERROR);
    Exit;
  end;

  if not(TFunctions.LoadSL(FileName)) then
  begin
    MessageBox(Self.Handle, 'Não possivel carregar a Server List !', 'Arquivo inválido', MB_ICONERROR);
    Exit;
  end;

  Self.ClearFormServerList;
  Self.LoadFormServerList;

  Self.EditSLFile.Text := FileName;
  Self.EditSLFile.SelStart := Length(Self.EditSLFile.Text);
end;

procedure TFormConfig.BtnSaveFileClick(Sender: TObject);
begin
  TFunctions.SaveSL(Self.EditSLFile.Text);
end;

procedure TFormConfig.BtnUpdateServerClick(Sender: TObject);
begin
  try
    StrPCopy(ServerList[SelectedChannel].Ip, AnsiString(Self.edtIpAddress.Text));
    StrPCopy(ServerList[SelectedChannel].Name, AnsiString(Self.edtChannelName.Text));

    ServerList[SelectedChannel].NationIndex := StrToInt(edtChannelNationIndex.Text);
    ServerList[SelectedChannel].ChannelNationIndex := StrToInt(edtChannelIndex.Text);
    ServerList[SelectedChannel].Check := StrToInt(edtCheck.Text);
    ServerList[SelectedChannel].Unk_0 := StrToInt(edtUnk.Text);
  finally
    Self.GridServers.Cells[1, Self.SelectedChannel + 1] := ServerList[SelectedChannel].Name;
    Self.GridServers.Cells[2, Self.SelectedChannel + 1] := ServerList[SelectedChannel].Ip;
  end;
end;

{$ENDREGION}

end.
