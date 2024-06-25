unit Log;

interface

uses Windows, System.SysUtils;

type
  TLogType = (Packets, ConnectionsTraffic, Warnings, ServerStatus, Error, Painel);

type
  TLog = class(TObject)
  public
    procedure Write(str: string; logType: TLogType); overload;
    //procedure Write(obj: TObject; logType: TLogType); overload;
    procedure Space;
  end;

Procedure LogTxt(str: String);

implementation

{ TLog }

procedure LogTxt(str: String);
var
  NomeDoLog: string;
  Arquivo: TextFile;
begin
  NomeDoLog := GetCurrentDir + '\Logs\StatusLog.txt';

  if not(DirectoryExists(GetCurrentDir + '\Logs')) then
    ForceDirectories(GetCurrentDir + '\Logs');

  AssignFile(Arquivo, NomeDoLog);
  if FileExists(NomeDoLog) then
    Append(Arquivo)
    { se existir, apenas adiciona linhas }
  else
    ReWrite(Arquivo);
  { cria um novo se não existir }
  try
    WriteLn(Arquivo, str);
    WriteLn(Arquivo, '-------------------------------------------------------------------------------');
  finally
    CloseFile(Arquivo)
  end;
end;

procedure LogError(str: String);
var
  NomeDoLog: string;
  Arquivo: TextFile;
begin
  NomeDoLog := GetCurrentDir + '\Logs\ErrorLog.txt';

  if not(DirectoryExists(GetCurrentDir + '\Logs')) then
    ForceDirectories(GetCurrentDir + '\Logs');

  AssignFile(Arquivo, NomeDoLog);
  if FileExists(NomeDoLog) then
    Append(Arquivo)
    { se existir, apenas adiciona linhas }
  else
    ReWrite(Arquivo);
  { cria um novo se não existir }
  try
    WriteLn(Arquivo, str);
    WriteLn(Arquivo, '-------------------------------------------------------------------------------');
  finally
    CloseFile(Arquivo)
  end;
end;

procedure LogPainel(str: String);
var
  NomeDoLog: string;
  Arquivo: TextFile;
begin
  NomeDoLog := GetCurrentDir + '\Logs\PainelLog.txt';

  if not(DirectoryExists(GetCurrentDir + '\Logs')) then
    ForceDirectories(GetCurrentDir + '\Logs');

  AssignFile(Arquivo, NomeDoLog);
  if FileExists(NomeDoLog) then
    Append(Arquivo)
    { se existir, apenas adiciona linhas }
  else
    ReWrite(Arquivo);
  { cria um novo se não existir }
  try
    WriteLn(Arquivo, str);
    WriteLn(Arquivo, '-------------------------------------------------------------------------------');
  finally
    CloseFile(Arquivo)
  end;
end;

procedure TLog.Write(str: string; logType: TLogType);
begin
  case logType of
    Packets:
      begin
        WriteLn(str);
      end;

    ConnectionsTraffic:
      begin
        SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_GREEN OR FOREGROUND_INTENSITY);
        WriteLn(str);
        SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_RED OR FOREGROUND_GREEN OR FOREGROUND_BLUE);
      end;

    Warnings:
      begin
        SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_RED OR FOREGROUND_INTENSITY);
        WriteLn(str);
        SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_RED OR FOREGROUND_GREEN OR FOREGROUND_BLUE);
      end;

    ServerStatus:
      begin
        WriteLn(str);
        LogTxt(str);
      end;

    Error:
      begin
        LogError(str);
      end;

    Painel:
      begin
        str := str + ' [DATE_TIME: '+ DateTimeToStr(Now) +' ].';
        LogPainel(str);
      end;
  end;

end;
   {
procedure TLog.Write(str: string; logType: TLogType);
begin
  case logType of
    Packets:
      begin
        MessageBox(0, PChar(str), 'Packet Log', MB_ICONINFORMATION);
      end;

    ConnectionsTraffic:
      begin
        MessageBox(0, PChar(str), 'Traffic Log', MB_ICONINFORMATION);
      end;

    Warnings:
      begin
        MessageBox(0, PChar(str), 'Warning Log', MB_ICONERROR);
      end;

    ServerStatus:
      begin
        MessageBox(0, PChar(str), 'Status Log', MB_ICONEXCLAMATION);
      end;
  end;
end;    }

procedure TLog.Space;
begin
  WriteLn('-------------------------------------------------------------------------------');
end;
     {
procedure TLog.Write(obj: TObject; logType: TLogType);
begin
  Write(obj.ToString(), logType);
  LogTxt(obj.ToString);
end; }

end.
