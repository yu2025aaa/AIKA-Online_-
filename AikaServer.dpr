program AikaServer;
{$APPTYPE CONSOLE} // 指定控制台应用程序
{$R *.res} // 包含资源文件
uses
System.SysUtils, // 系统实用工具
DateUtils, // 日期实用工具
Windows, // Windows API
Vcl.Forms, // VCL 窗体
Vcl.Dialogs, // VCL 对话框
StrUtils, // 字符串实用工具
Winsock2, // Winsock2 API
Log in 'Src\Functions\Log.pas', // 日志功能
GlobalDefs in 'Src\Data\GlobalDefs.pas', // 全局定义
ServerSocket in 'Src\Connections\ServerSocket.pas', // 服务器加密数据
Load in 'Src\Functions\Load.pas', // 加载功能
NPC in 'Src\Mob\NPC.pas', // NPC
BaseMob in 'Src\Mob\BaseMob.pas', // 基础怪物
Player in 'Src\Mob\Player.pas', // 玩家
CpuUsage in 'Src\Functions\CpuUsage.pas', // CPU 使用率功能
Functions in 'Src\Functions\Functions.pas', // 通用功能
ItemFunctions in 'Src\Functions\ItemFunctions.pas', // 物品功能
SkillFunctions in 'Src\Functions\SkillFunctions.pas', // 技能功能
Util in 'Src\Functions\Util.pas', // 实用工具
ConnectionsThread in 'Src\Threads\ConnectionsThread.pas', // 连接线程
PlayerThread in 'Src\Threads\PlayerThread.pas', // 玩家线程
UpdateThreads in 'Src\Threads\UpdateThreads.pas', // 更新线程
FilesData in 'Src\Data\FilesData.pas', // 文件数据
MiscData in 'Src\Data\MiscData.pas', // 杂项数据
Packets in 'Src\Data\Packets.pas', // 数据包
PlayerData in 'Src\Data\PlayerData.pas', // 玩家数据
PartyData in 'Src\Party\PartyData.pas', // 队伍数据
CharacterMail in 'Src\Mail\CharacterMail.pas', // 角色邮件
MailFunctions in 'Src\Mail\MailFunctions.pas', // 邮件功能
EncDec in 'Src\Connections\EncDec.pas', // 加密解密
NPCHandlers in 'Src\PacketHandlers\NPCHandlers.pas', // NPC 数据包处理
PacketHandlers in 'Src\PacketHandlers\PacketHandlers.pas', // 数据包处理
LoginSocket in 'Src\Connections\LoginSocket.pas', // 登录加密数据
AuthHandlers in 'Src\PacketHandlers\AuthHandlers.pas', // 认证处理
TokenSocket in 'Src\Connections\TokenSocket.pas', // 令牌数据
CommandHandlers in 'Src\PacketHandlers\CommandHandlers.pas', // 命令处理
GuildData in 'Src\Guild\GuildData.pas', // 公会数据
SQL in 'Src\Connections\SQL.pas', // SQL 连接
MOB in 'Src\Mob\MOB.pas', // 怪物
PET in 'Src\Mob\PET.pas', // 宠物
R_Paneil in 'Src\Functions\R_Paneil.pas', // R_Paneil 功能
EntityMail in 'Src\Data\Entity\EntityMail.pas', // 实体邮件
EntityFriend in 'Src\Data\Entity\EntityFriend.pas', // 实体好友
SendPacketForm in 'Src\Forms\SendPacketForm.pas' {frmSendPacket}, // 发送数据包窗体
Dungeon in 'Src\Dungeons\Dungeon.pas', // 副本
Nation in 'Src\Nation\Nation.pas', // 国家
PingBackForm in 'Src\Forms\PingBackForm.pas' {frmPingback}, // PingBack 窗体
AuctionFunctions in 'Src\Auction\AuctionFunctions.pas', // 拍卖功能
CharacterAutcion in 'Src\Auction\CharacterAutcion.pas', // 角色拍卖
Objects in 'Src\Mob\Objects.pas', // 对象
CastleSiege in 'Src\Nation\CastleSiege.pas'; // 攻城

function ConsoleHandler(dwCtrlType: DWORD): BOOL; stdcall; // 控制台处理函数声明
var
i: BYTE;
begin
Result := False;
if (dwCtrlType in [CTRL_CLOSE_EVENT, CTRL_LOGOFF_EVENT, CTRL_SHUTDOWN_EVENT]) then // 检查控制台关闭、注销或关机事件
begin
  if not ServerHasClosed then // 如果服务器未关闭
  begin
    TFunctions.SaveGuilds; // 保存公会数据
    for i := Low(Nations) to High(Nations) do // 遍历所有国家
      Nations[i].SaveNation; // 保存国家数据
    for i := Low(Servers) to High(Servers) do // 遍历所有服务器
      Servers[i].CloseServer; // 关闭服务器
    Logger.Write('服务器关闭成功！', TLogType.ServerStatus); // 记录服务器关闭成功
  end;
  Result := True;
end;
end;

procedure InitializeServer; // 初始化服务器过程声明
begin
TLoad.InitCharacters; // 初始化角色数据
TLoad.InitItemList; // 初始化物品列表
TLoad.InitSkillData; // 初始化技能数据
TLoad.InitSetItem; // 初始化套装物品
TLoad.InitConjunts; // 初始化组合物品
TLoad.InitReinforce; // 初始化强化数据
TLoad.InitPremiumItems; // 初始化高级物品
TLoad.InitExpList; // 初始化经验列表
TLoad.InitPranExpList; // 初始化芙兰经验列表
TLoad.InitServerConf; // 初始化服务器配置
TLoad.InitServerList; // 初始化服务器列表
TLoad.LoadNPCOptions; // 加载NPC选项
TLoad.InitMapsData; // 初始化地图数据
TLoad.InitScrollPositions; // 初始化据点传送位置
TLoad.InitQuestList; // 初始化任务列表
TLoad.InitQuests; // 初始化任务数据
TLoad.InitTitles; // 初始化称号数据
TLoad.InitDropList; // 初始化掉落列表
TLoad.InitRecipes; // 初始化图纸数据
TLoad.InitMakeItems; // 初始化制作物品数据
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
Logger := TLog.Create; // 创建日志对象
SetConsoleTitleA('Aika Server'); // 设置控制台标题

try
  Uptime := Now; // 获取当前时间作为启动时间
  WebServerClosed := False; // 设置Web服务器关闭标志为假
  xServerClosed := False; // 设置服务器关闭标志为假
  InitializeServer; // 初始化服务器
  Logger.Space; // 记录空行
  TLoad.InitServers; // 初始化服务器
  Logger.Space; // 记录空行
  TLoad.InitAuthServer; // 初始化认证服务器
  Logger.Space; // 记录空行
  TLoad.InitNPCS; // 初始化NPC
  TLoad.InitGuilds; // 初始化公会

  for i := Low(Servers) to High(Servers) do // 遍历所有服务器
  begin
    Servers[i].ServerHasClosed := False; // 设置服务器关闭标志为假
    Servers[i].StartThreads; // 启动服务器线程
    if i <= 2 then // 如果是前三个服务器
    begin
      Nations[Servers[i].NationID - 1].CreateNation(Servers[i].ChannelID); // 创建国家
      Nations[Servers[i].NationID - 1].LoadNation(); // 加载国家数据
      Servers[i].UpdateReliquareEffects(); // 更新遗物效果
    end;
  end;

  timeinit := MilliSecondsBetween(Now, Uptime); // 计算服务器启动时间
  Logger.Write('服务器完全加载耗时 ' + IntToStr(Round(timeinit / 1000)) + ' 秒。', TLogType.ServerStatus); // 记录服务器启动时间
  Logger.Space; // 记录空行

  while True do // 无限循环
  begin
    ReadLn(cmdto); // 读取用户输入的命令
    case AnsiIndexStr(cmdto, ['close', 'savecsvmob', 'reloadskill', 'reloaditem', 'reloadserverconf', 'reloadmobs', 'reloaddrops', 'reloadpremiumshop', 'reloadquestsserver', 'reloadquestclient', 'reloadtitles', 'reloadrecipes', 'reloadmakeitem']) of
      0: // 关闭服务器命令
        begin
          for i := Low(Servers) to High(Servers) do // 遍历所有服务器
          begin
            closesocket(Servers[i].Sock); // 关闭服务器数据
            Servers[i].Sock := INVALID_SOCKET; // 设置数据为无效
          end;
          ServerHasClosed := True; // 设置服务器关闭标志为真
          Logger.Write('正在关闭服务器，请稍候...', TLogType.ConnectionsTraffic); // 记录关闭服务器信息
          TFunctions.SaveGuilds; // 保存公会数据
          Logger.Write('公会数据已保存..', TLogType.ConnectionsTraffic); // 记录公会数据保存信息
          for i := Low(Nations) to High(Nations) do // 遍历所有国家
            Nations[i].SaveNation; // 保存国家数据
          Logger.Write('国家数据已保存..', TLogType.ConnectionsTraffic); // 记录国家数据保存信息
          for i := Low(Servers) to High(Servers) do // 遍历所有服务器
          begin
            Servers[i].ServerHasCLosed := True; // 设置服务器关闭标志为真
            Sleep(1000); // 等待1秒
            Servers[i].CloseServer; // 关闭服务器
            Sleep(1000); // 等待1秒
          end;
          xServerClosed := True; // 设置服务器关闭标志为真
          Logger.Write('服务器关闭成功！', TLogType.ServerStatus); // 记录服务器关闭成功信息
          Logger.Write('请关闭此控制台窗口。所有数据已保存！', TLogType.ConnectionsTraffic); // 记录关闭控制台信息
        end;
      1: { savecsvmob }
        begin
          // 实现 savecsvmob 功能
        end;
      2: // 重新加载技能数据
        begin
          ZeroMemory(@SkillData, sizeof(SkillData)); // 清空技能数据
          TLoad.InitSkillData; // 初始化技能数据
        end;
      3: // 重新加载物品数据
        begin
          ZeroMemory(@ItemList, sizeof(ItemList)); // 清空物品数据
          TLoad.InitItemList; // 初始化物品数据
        end;
      4: // 重新加载服务器配置
        begin
          TLoad.InitServerConf; // 初始化服务器配置
        end;
      5: // 重新加载怪物数据
        begin
          for i := Low(Servers) to High(Servers) do // 遍历所有服务器
            Servers[i].StartMobs; // 启动怪物
        end;
      6: // 重新加载掉落数据
        begin
          TLoad.InitDropList; // 初始化掉落列表
        end;
      7: // 重新加载高级商店数据
        begin
          TLoad.InitPremiumItems; // 初始化高级物品
        end;
      8: // 重新加载服务器任务数据
        begin
          TLoad.InitQuests; // 初始化任务数据
        end;
      9: // 重新加载客户端任务数据
        begin
          TLoad.InitQuestList; // 初始化任务列表
        end;
      10: // 重新加载称号数据
        begin
          Tload.InitTitles; // 初始化称号数据
        end;
      11: // 重新加载图纸数据
        begin
          TLoad.InitRecipes; // 初始化图纸数据
        end;
      12: // 重新加载制作物品数据
        begin
          TLoad.InitMakeItems; // 初始化制作物品数据
        end;
    else
      begin
        for i := Low(Servers) to High(Servers) do // 遍历所有服务器
          Servers[i].SendServerMsg(AnsiString('[SERVER] ' + cmdto), 32, 16); // 发送服务器消息
      end;
    end;
  end;
except
  on E: Exception do // 捕获异常
  begin
    Logger.Write(E.ClassName + ': ' + E.Message, TLogType.error); // 记录异常信息
    ReadLn(InputStr); // 读取用户输入
  end;
end;
end.
