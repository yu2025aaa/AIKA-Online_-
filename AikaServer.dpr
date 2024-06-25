program AikaServer;
{$APPTYPE CONSOLE} // ָ������̨Ӧ�ó���
{$R *.res} // ������Դ�ļ�
uses
System.SysUtils, // ϵͳʵ�ù���
DateUtils, // ����ʵ�ù���
Windows, // Windows API
Vcl.Forms, // VCL ����
Vcl.Dialogs, // VCL �Ի���
StrUtils, // �ַ���ʵ�ù���
Winsock2, // Winsock2 API
Log in 'Src\Functions\Log.pas', // ��־����
GlobalDefs in 'Src\Data\GlobalDefs.pas', // ȫ�ֶ���
ServerSocket in 'Src\Connections\ServerSocket.pas', // ��������������
Load in 'Src\Functions\Load.pas', // ���ع���
NPC in 'Src\Mob\NPC.pas', // NPC
BaseMob in 'Src\Mob\BaseMob.pas', // ��������
Player in 'Src\Mob\Player.pas', // ���
CpuUsage in 'Src\Functions\CpuUsage.pas', // CPU ʹ���ʹ���
Functions in 'Src\Functions\Functions.pas', // ͨ�ù���
ItemFunctions in 'Src\Functions\ItemFunctions.pas', // ��Ʒ����
SkillFunctions in 'Src\Functions\SkillFunctions.pas', // ���ܹ���
Util in 'Src\Functions\Util.pas', // ʵ�ù���
ConnectionsThread in 'Src\Threads\ConnectionsThread.pas', // �����߳�
PlayerThread in 'Src\Threads\PlayerThread.pas', // ����߳�
UpdateThreads in 'Src\Threads\UpdateThreads.pas', // �����߳�
FilesData in 'Src\Data\FilesData.pas', // �ļ�����
MiscData in 'Src\Data\MiscData.pas', // ��������
Packets in 'Src\Data\Packets.pas', // ���ݰ�
PlayerData in 'Src\Data\PlayerData.pas', // �������
PartyData in 'Src\Party\PartyData.pas', // ��������
CharacterMail in 'Src\Mail\CharacterMail.pas', // ��ɫ�ʼ�
MailFunctions in 'Src\Mail\MailFunctions.pas', // �ʼ�����
EncDec in 'Src\Connections\EncDec.pas', // ���ܽ���
NPCHandlers in 'Src\PacketHandlers\NPCHandlers.pas', // NPC ���ݰ�����
PacketHandlers in 'Src\PacketHandlers\PacketHandlers.pas', // ���ݰ�����
LoginSocket in 'Src\Connections\LoginSocket.pas', // ��¼��������
AuthHandlers in 'Src\PacketHandlers\AuthHandlers.pas', // ��֤����
TokenSocket in 'Src\Connections\TokenSocket.pas', // ��������
CommandHandlers in 'Src\PacketHandlers\CommandHandlers.pas', // �����
GuildData in 'Src\Guild\GuildData.pas', // ��������
SQL in 'Src\Connections\SQL.pas', // SQL ����
MOB in 'Src\Mob\MOB.pas', // ����
PET in 'Src\Mob\PET.pas', // ����
R_Paneil in 'Src\Functions\R_Paneil.pas', // R_Paneil ����
EntityMail in 'Src\Data\Entity\EntityMail.pas', // ʵ���ʼ�
EntityFriend in 'Src\Data\Entity\EntityFriend.pas', // ʵ�����
SendPacketForm in 'Src\Forms\SendPacketForm.pas' {frmSendPacket}, // �������ݰ�����
Dungeon in 'Src\Dungeons\Dungeon.pas', // ����
Nation in 'Src\Nation\Nation.pas', // ����
PingBackForm in 'Src\Forms\PingBackForm.pas' {frmPingback}, // PingBack ����
AuctionFunctions in 'Src\Auction\AuctionFunctions.pas', // ��������
CharacterAutcion in 'Src\Auction\CharacterAutcion.pas', // ��ɫ����
Objects in 'Src\Mob\Objects.pas', // ����
CastleSiege in 'Src\Nation\CastleSiege.pas'; // ����

function ConsoleHandler(dwCtrlType: DWORD): BOOL; stdcall; // ����̨����������
var
i: BYTE;
begin
Result := False;
if (dwCtrlType in [CTRL_CLOSE_EVENT, CTRL_LOGOFF_EVENT, CTRL_SHUTDOWN_EVENT]) then // ������̨�رա�ע����ػ��¼�
begin
  if not ServerHasClosed then // ���������δ�ر�
  begin
    TFunctions.SaveGuilds; // ���湫������
    for i := Low(Nations) to High(Nations) do // �������й���
      Nations[i].SaveNation; // �����������
    for i := Low(Servers) to High(Servers) do // �������з�����
      Servers[i].CloseServer; // �رշ�����
    Logger.Write('�������رճɹ���', TLogType.ServerStatus); // ��¼�������رճɹ�
  end;
  Result := True;
end;
end;

procedure InitializeServer; // ��ʼ����������������
begin
TLoad.InitCharacters; // ��ʼ����ɫ����
TLoad.InitItemList; // ��ʼ����Ʒ�б�
TLoad.InitSkillData; // ��ʼ����������
TLoad.InitSetItem; // ��ʼ����װ��Ʒ
TLoad.InitConjunts; // ��ʼ�������Ʒ
TLoad.InitReinforce; // ��ʼ��ǿ������
TLoad.InitPremiumItems; // ��ʼ���߼���Ʒ
TLoad.InitExpList; // ��ʼ�������б�
TLoad.InitPranExpList; // ��ʼ��ܽ�������б�
TLoad.InitServerConf; // ��ʼ������������
TLoad.InitServerList; // ��ʼ���������б�
TLoad.LoadNPCOptions; // ����NPCѡ��
TLoad.InitMapsData; // ��ʼ����ͼ����
TLoad.InitScrollPositions; // ��ʼ���ݵ㴫��λ��
TLoad.InitQuestList; // ��ʼ�������б�
TLoad.InitQuests; // ��ʼ����������
TLoad.InitTitles; // ��ʼ���ƺ�����
TLoad.InitDropList; // ��ʼ�������б�
TLoad.InitRecipes; // ��ʼ��ͼֽ����
TLoad.InitMakeItems; // ��ʼ��������Ʒ����
end;

var
InputStr: string;
Uptime: TDateTime;
timeinit: Integer;
CreateSendPacketForm: Boolean = True;
i, j, k: Integer;
cmdto: String;
F: TextFile;
Path, MobN: String;
CsvLine: String;

begin
Logger := TLog.Create; // ������־����
SetConsoleTitleA('Aika Server'); // ���ÿ���̨����

try
  Uptime := Now; // ��ȡ��ǰʱ����Ϊ����ʱ��
  WebServerClosed := False; // ����Web�������رձ�־Ϊ��
  xServerClosed := False; // ���÷������رձ�־Ϊ��
  InitializeServer; // ��ʼ��������
  Logger.Space; // ��¼����
  TLoad.InitServers; // ��ʼ��������
  Logger.Space; // ��¼����
  TLoad.InitAuthServer; // ��ʼ����֤������
  Logger.Space; // ��¼����
  TLoad.InitNPCS; // ��ʼ��NPC
  TLoad.InitGuilds; // ��ʼ������

  for i := Low(Servers) to High(Servers) do // �������з�����
  begin
    Servers[i].ServerHasClosed := False; // ���÷������رձ�־Ϊ��
    Servers[i].StartThreads; // �����������߳�
    if i <= 2 then // �����ǰ����������
    begin
      Nations[Servers[i].NationID - 1].CreateNation(Servers[i].ChannelID); // ��������
      Nations[Servers[i].NationID - 1].LoadNation(); // ���ع�������
      Servers[i].UpdateReliquareEffects(); // ��������Ч��
    end;
  end;

  timeinit := MilliSecondsBetween(Now, Uptime); // �������������ʱ��
  Logger.Write('��������ȫ���غ�ʱ ' + IntToStr(Round(timeinit / 1000)) + ' �롣', TLogType.ServerStatus); // ��¼����������ʱ��
  Logger.Space; // ��¼����

  while True do // ����ѭ��
  begin
    ReadLn(cmdto); // ��ȡ�û����������
    case AnsiIndexStr(cmdto, ['close', 'savecsvmob', 'reloadskill', 'reloaditem', 'reloadserverconf', 'reloadmobs', 'reloaddrops', 'reloadpremiumshop', 'reloadquestsserver', 'reloadquestclient', 'reloadtitles', 'reloadrecipes', 'reloadmakeitem']) of
      0: // �رշ���������
        begin
          for i := Low(Servers) to High(Servers) do // �������з�����
          begin
            closesocket(Servers[i].Sock); // �رշ���������
            Servers[i].Sock := INVALID_SOCKET; // ��������Ϊ��Ч
          end;
          ServerHasClosed := True; // ���÷������رձ�־Ϊ��
          Logger.Write('���ڹرշ����������Ժ�...', TLogType.ConnectionsTraffic); // ��¼�رշ�������Ϣ
          TFunctions.SaveGuilds; // ���湫������
          Logger.Write('���������ѱ���..', TLogType.ConnectionsTraffic); // ��¼�������ݱ�����Ϣ
          for i := Low(Nations) to High(Nations) do // �������й���
            Nations[i].SaveNation; // �����������
          Logger.Write('���������ѱ���..', TLogType.ConnectionsTraffic); // ��¼�������ݱ�����Ϣ
          for i := Low(Servers) to High(Servers) do // �������з�����
          begin
            Servers[i].ServerHasCLosed := True; // ���÷������رձ�־Ϊ��
            Sleep(1000); // �ȴ�1��
            Servers[i].CloseServer; // �رշ�����
            Sleep(1000); // �ȴ�1��
          end;
          xServerClosed := True; // ���÷������رձ�־Ϊ��
          Logger.Write('�������رճɹ���', TLogType.ServerStatus); // ��¼�������رճɹ���Ϣ
          Logger.Write('��رմ˿���̨���ڡ����������ѱ��棡', TLogType.ConnectionsTraffic); // ��¼�رտ���̨��Ϣ
        end;
      1: { savecsvmob }
        begin
          // ʵ�� savecsvmob ����
        end;
      2: // ���¼��ؼ�������
        begin
          ZeroMemory(@SkillData, sizeof(SkillData)); // ��ռ�������
          TLoad.InitSkillData; // ��ʼ����������
        end;
      3: // ���¼�����Ʒ����
        begin
          ZeroMemory(@ItemList, sizeof(ItemList)); // �����Ʒ����
          TLoad.InitItemList; // ��ʼ����Ʒ����
        end;
      4: // ���¼��ط���������
        begin
          TLoad.InitServerConf; // ��ʼ������������
        end;
      5: // ���¼��ع�������
        begin
          for i := Low(Servers) to High(Servers) do // �������з�����
            Servers[i].StartMobs; // ��������
        end;
      6: // ���¼��ص�������
        begin
          TLoad.InitDropList; // ��ʼ�������б�
        end;
      7: // ���¼��ظ߼��̵�����
        begin
          TLoad.InitPremiumItems; // ��ʼ���߼���Ʒ
        end;
      8: // ���¼��ط�������������
        begin
          TLoad.InitQuests; // ��ʼ����������
        end;
      9: // ���¼��ؿͻ�����������
        begin
          TLoad.InitQuestList; // ��ʼ�������б�
        end;
      10: // ���¼��سƺ�����
        begin
          Tload.InitTitles; // ��ʼ���ƺ�����
        end;
      11: // ���¼���ͼֽ����
        begin
          TLoad.InitRecipes; // ��ʼ��ͼֽ����
        end;
      12: // ���¼���������Ʒ����
        begin
          TLoad.InitMakeItems; // ��ʼ��������Ʒ����
        end;
    else
      begin
        for i := Low(Servers) to High(Servers) do // �������з�����
          Servers[i].SendServerMsg(AnsiString('[SERVER] ' + cmdto), 32, 16); // ���ͷ�������Ϣ
      end;
    end;
  end;
except
  on E: Exception do // �����쳣
  begin
    Logger.Write(E.ClassName + ': ' + E.Message, TLogType.error); // ��¼�쳣��Ϣ
    ReadLn(InputStr); // ��ȡ�û�����
  end;
end;
end.
