unit PacketForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Player;

type
  TByteArr = ARRAY OF BYTE;

type
  TFormPackets = class(TForm)
    MemoPackets: TMemo;
    PanelContent: TPanel;
    PanelBottom: TPanel;
    BtnSend: TButton;
    procedure FormCreate(Sender: TObject);
    procedure BtnSendClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    Player : PPlayer;

    { String Functions}
    function StrToArray(const BufferStr : string) : TByteArr;
    function RemoveNonString(TextStr : string) : string;
  end;

var
  FormPackets: TFormPackets;

implementation

{$R *.dfm}

uses
  GlobalDefs, PlayerData;

{$REGION 'Form Functions'}

procedure TFormPackets.BtnSendClick(Sender: TObject);
var
  Packet : TByteArr;
begin

  if (Self.MemoPackets.Text = '') then
    Exit;

  Packet := Self.StrToArray(Self.MemoPackets.Text);

  Player.SendPacket(Packet, Length(Packet));
end;

procedure TFormPackets.FormCreate(Sender: TObject);
begin
 
end;

{$ENDREGION}
{$REGION 'String Functions'}

function TFormPackets.StrToArray(const BufferStr : string) : TByteArr;
var
  i: Integer;
  Data : TStringList;
  Passed : string;
begin
  Passed := Self.RemoveNonString(BufferStr);

  Data := TStringList.Create;
  if (Length(Passed) > 1) then begin
    try
      Data.Delimiter := ' ';
      Data.DelimitedText := Passed;

      if (Data.Count > 0) then begin
        SetLength(Result, Data.Count);
        for i := 0 to (Data.Count-1) do begin
          Result[i] := StrToInt('$' + Data[i]);
        end;
      end;
    except
      on E : Exception do begin
        E.Free;
      end;
    end;
  end;
end;

function TFormPackets.RemoveNonString(TextStr : string) : string;
begin
  Result := TextStr;
  Result := StringReplace(Result, #13, '', [rfReplaceAll]);
  Result := StringReplace(Result, '>', '', [rfReplaceAll]);
  Result := StringReplace(Result, '>>', '', [rfReplaceAll]);
  Result := StringReplace(Result, '[', '', [rfReplaceAll]);
  Result := StringReplace(Result, ']', '', [rfReplaceAll]);
  Result := StringReplace(Result, '{', '', [rfReplaceAll]);
  Result := StringReplace(Result, '}', '', [rfReplaceAll]);
  Result := StringReplace(Result, '(', '', [rfReplaceAll]);
  Result := StringReplace(Result, ')', '', [rfReplaceAll]);
end;

{$ENDREGION}

end.
