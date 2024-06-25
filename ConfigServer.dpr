program ConfigServer;

uses
  Vcl.Forms,
  ConfigForm in 'Src\Forms\ConfigForm.pas' {FormConfig},
  GlobalDefs in 'Src\Data\GlobalDefs.pas',
  Functions in 'Src\Functions\Functions.pas',
  Log in 'Src\Functions\Log.pas',
  EncDec in 'Src\Connections\EncDec.pas',
  LoginSocket in 'Src\Connections\LoginSocket.pas',
  ServerSocket in 'Src\Connections\ServerSocket.pas',
  TokenSocket in 'Src\Connections\TokenSocket.pas',
  ConnectionsThread in 'Src\Threads\ConnectionsThread.pas',
  PlayerThread in 'Src\Threads\PlayerThread.pas',
  UpdateThreads in 'Src\Threads\UpdateThreads.pas',
  BaseMob in 'Src\Mob\BaseMob.pas',
  NPC in 'Src\Mob\NPC.pas',
  Player in 'Src\Mob\Player.pas',
  FilesData in 'Src\Data\FilesData.pas',
  MiscData in 'Src\Data\MiscData.pas',
  Packets in 'Src\Data\Packets.pas',
  PlayerData in 'Src\Data\PlayerData.pas',
  CpuUsage in 'Src\Functions\CpuUsage.pas',
  ItemFunctions in 'Src\Functions\ItemFunctions.pas',
  Load in 'Src\Functions\Load.pas',
  SkillFunctions in 'Src\Functions\SkillFunctions.pas',
  Util in 'Src\Functions\Util.pas',
  PartyData in 'Src\Party\PartyData.pas',
  AuthHandlers in 'Src\PacketHandlers\AuthHandlers.pas',
  NPCHandlers in 'Src\PacketHandlers\NPCHandlers.pas',
  PacketHandlers in 'Src\PacketHandlers\PacketHandlers.pas',
  CharacterMail in 'Src\Mail\CharacterMail.pas',
  MailFunctions in 'Src\Mail\MailFunctions.pas',
  GuildData in 'Src\Guild\GuildData.pas',
  CommandHandlers in 'Src\PacketHandlers\CommandHandlers.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormConfig, FormConfig);
  Application.Run;
end.
