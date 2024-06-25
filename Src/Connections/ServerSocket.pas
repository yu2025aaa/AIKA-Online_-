unit ServerSocket;
interface
uses Winsock2, Windows, PlayerThread, Player, BaseMob, NPC, PlayerData,
  UpdateThreads, MiscData, PartyData, Generics.Collections, AnsiStrings,
  ConnectionsThread, GuildData, SQL, MOB, PET, Objects, classes, DUngeon, Math,
  CastleSiege;
{$OLDTYPELAYOUT ON}
type
  PServerSocket = ^TServerSocket;
  TServerSocket = class
    ServerAddr: TSockAddrIn;
    Name: AnsiString;
    Ip: AnsiString;
    ServerName: string;
    IsActive: Boolean;
    InstantiatedPlayers: WORD;
    ServerHasClosed: Boolean;
    //cSQL: TQuery;
    NationID: BYTE;
    NationType: BYTE;
    DuelCount: Integer;
    ChannelId: BYTE;
    ActivePlayersNowHere: Integer;
    ActiveReliquaresOnTemples: Integer;
    //PlayerThreads: Array [1 .. 200] of TPlayerThread;
    //FPlayerThreads: Array [1 .. 200] of PPlayerThread;
    Players: ARRAY [1 .. 1000] OF TPlayer; // reserved 1-2000
    NPCS: ARRAY [2048 .. 3047] OF TNpc; // reserved 2048-3048
    MOBS: TMobStruct; // reserved 3048 + 6099 mob spawns
    PETS: Array [9148 .. 10147] of TPet; // reserved 9148-10147
    OBJ: Array [10148..10239] of TOBJ;
    Prans: Array [10241 .. 11240] of Integer;
    // colocar o iddb(integer) (clientid = slot)
    // 10241 ~ 11240 reserved for prans
    // numero de pets tem que ser igual ao de players (200) e [futuramente] (2000)
    // atencao ao tamanho dessas structs ai pra nao dar erro de out of memory
    // mobgrid: array [0..4095] of array [0..4095] of array of WORD;
    DGUrsula: Array [0 .. 0] of TDungeon; //0..2
    DGEvgInf: Array [0 .. 0] of TDungeon;
    DGEvgSup: Array [0 .. 0] of TDungeon;
    DGMines1: Array [0 .. 0] of TDungeon;
    DGKinary: Array [0 .. 0] of TDungeon;
    Parties: ARRAY [1 .. 30] OF TParty;
    Devires: Array [0 .. 4] of TDevir;
    DevirNpc: Array [3335 .. 3339] of TNpc;
    DevirGuards: Array [3355 .. 3369] of TNpc;
    DevirStones: Array [3340 .. 3354] of TNpc;
    //SecureAreas: Array [0 .. 9] of TSecureArea;
    ReliqEffect: ARRAY [0 .. 395] OF Integer;
    CastleObjects: Array [3370 .. 3390] of TNpc;
    CastleSiegeHandler: TCastleSiege;
    //PranClientID: Array of WORD;
    ConnectionThread: TConnectionsThread;
    PlayerThreadsGarbage: TPlayerThreadGarbage;
    UpdateHpMpThread: TUpdateHpMpThread;
    UpdateBuffsThread: TUpdateBuffsThread;
    UpdateMailsThread: TUpdateMailsThread;
    UpdateVisibleThread: TUpdateVisibleThread;
    UpdateWorldAroundThread: TUpdateWorldAroundThread;
    UpdateTimeThread: TUpdateTimeThread;
    UpdateEventListenerThread: TUpdateEventListenerThread;
    SkillRegenerateThread: TSkillRegenerateThread;
    SkillDamageThread: TSkillDamageThread;
    MobSpawnThread1: TMobSpawnThread1;
    MobSpawnThread2: TMobSpawnThread2;
    MobSpawnThread3: TMobSpawnThread3;
    // MobSpawnThread4: TMobSpawnThread4;
    MobHandlerThread1: TMobHandlerThread1;
    MobHandlerThread2: TMobHandlerThread2;
    MobHandlerThread3: TMobHandlerThread3;
    // MobHandlerThread4: TMobHandlerThread4;
    // MobHandlerThread5: TMobHandlerThread5;
    // MobHandlerThread6: TMobHandlerThread6;
    // MobHandlerThread7: TMobHandlerThread7;
    // MobHandlerThread8: TMobHandlerThread8;
    MobMovimentThread1: TMobMovimentThread1;
    MobMovimentThread2: TMobMovimentThread2;
    MobMovimentThread3: TMobMovimentThread3;
    // MobMovimentThread4: TMobMovimentThread4;
    // MobMovimentThread5: TMobMovimentThread5;
    // MobMovimentThread6: TMobMovimentThread6;
    // MobMovimentThread7: TMobMovimentThread7;
    // MobMovimentThread8: TMobMovimentThread8;
    PetHandler: TPetHandler;
    PetSpawner: TPetSpawner;
    SaveInGame: TSaveInGame;
    TimeItensThread: TTimeItensThread;
    ItemQuestThread: TQuestItemThread;
    PranFoodThread: TPranFoodThread;
    TemplesManagmentThread: TTemplesManagmentThread;
    CastleSiegeThread : TCastleSiegeThread;
  var
    Sock: TSocket;
    ResetTime: LongInt;
  public
    { TServerSocket }
    function StartSocket(): Boolean;
    function StartServer(): Boolean;
    procedure CloseServer;
    procedure StartThreads;
    procedure StartPartys;
    procedure StartMobs;
    procedure InitDungeons;
    procedure AcceptConnection;
    { Player Functions }
    function GetPlayer(const ClientId: WORD): PPlayer; overload;
    function GetPlayer(const CharacterName: string): PPlayer; overload;
    { Disconnect Functions }
    procedure DisconnectAll;
    procedure Disconnect(var Player: TPlayer); overload;
    procedure Disconnect(ClientId: WORD); overload;
    procedure Disconnect(userName: string); overload;
    { Send Functions }
    procedure SendPacketTo(ClientId: Integer; var Packet; Size: WORD;
      Encrypt: Boolean = true);
    procedure SendSignalTo(ClientId: Integer; pIndex, opCode: WORD);
    procedure SendToVisible(var Base: TBaseMob; var Packet; Size: WORD);
    procedure SendToAll(var Packet; Size: WORD);
    procedure SendServerMsg(Mensg: AnsiString; MsgType: Integer = $10;
      Null: Integer = 0; Type2: Integer = 0; SendToSelf: Boolean = true;
      MyClientID: WORD = 0);
    procedure SendServerMsgForNation(Mensg: AnsiString; aNation: BYTE;
      MsgType: Integer = $10; Null: Integer = 0; Type2: Integer = 0;
      SendToSelf: Boolean = true; MyClientID: WORD = 0);
    { PacketControl }
    function PacketControl(var Player: TPlayer; var Size: Integer;
      var Buffer: array of BYTE; initialOffset: Integer): Boolean;
    { ServerTime }
    function GetResetTime: LongInt;
    function CheckResetTime: Boolean;
    function GetEndDayTime: LongInt;
    { Players }
    function GetPlayerByName(Name: string; out Player: PPlayer)
      : Boolean; overload;
    function GetPlayerByName(Name: string): Integer; overload;
    function GetPlayerByUsername(userName: string): Integer;
    function GetPlayerByUsernameAux(userName: string; CidAux: WORD): Integer;
    function GetPlayerByCharIndex(CharIndex: DWORD; out Player: PPlayer)
      : Boolean; overload;
    function GetPlayerByCharIndex(CharIndex: DWORD; out Player: TPlayer)
      : Boolean; overload;
    { Get Guild }
    function GetGuildByIndex(GuildIndex: Integer): String;
    function GetGuildByName(GuildName: String): Integer;
    function GetGuildSlotByID(GuildIndex: Integer): Integer;
    { Prans }
    function GetFreePranClientID(): Integer;
    { Pets }
    function GetFreePetClientID(): Integer;
    { Temples }
    function GetFreeTempleSpace(): TSpaceTemple;
    function GetFreeTempleSpaceByIndex(id: Integer): TSpaceTemple;
    procedure SaveTemplesDB(Player: PPlayer);
    procedure UpdateReliquaresForAll();
    procedure UpdateReliquareInfosForAll();
    procedure UpdateReliquareEffects();
    function CanOpenTempleNow(DevirId: BYTE): Boolean;
    function OpenDevir(DevId: Integer; TempID: Integer;
      WhoKilledLast: Integer): Boolean;
    function CloseDevir(DevId: Integer; TempID: Integer;
      WhoGetReliq: Integer): Boolean;
    function GetTheStonesFromDevir(DevId: Integer): TIdsArray;
    function GetTheGuardsFromDevir(DevId: Integer): TIdsArray;
    function GetEmptySecureArea(): BYTE;
    function RemoveSecureArea(AreaSlot: BYTE): Boolean; overload;
    function RemoveSecureArea(DevId: Integer): Boolean; overload;
    function RemoveSecureArea(TempID: WORD): Boolean; overload;
    function CreateMapObject(OtherPlayer: PPlayer; OBJID: WORD; ContentID: WORD = 0): Boolean;
    function GetFreeObjId(): WORD;
    procedure CollectReliquare(Player: PPlayer; Index: WORD);
    { Mob Grid }
    { function GetEmptyMobGrid(index: WORD; var pos: TPosition;
      radius: WORD = 6): Boolean;
      function UpdateWorld(index: Integer; var pos: TPosition;
      flag: BYTE): Boolean; }
  end;
{$OLDTYPELAYOUT OFF}
implementation
uses GlobalDefs, SysUtils, DateUtils, Log,
  PacketHandlers, StrUtils, Packets,
  Functions, MailFunctions,
  FilesData, Load, EntityMail, AuthHandlers;
{$REGION 'TServerSocket'}
function TServerSocket.StartSocket;
var
  wsa: TWsaData;
  Margv: Cardinal;
  Xargv: AnsiChar;
begin
  Result := false;
  ZeroMemory(@Self.Players, sizeof(Self.Players));
  if (WSAStartup(MAKEWORD(2, 2), wsa) <> 0) then
  begin
    Logger.Write('Ocorreu um erro ao inicializar o Winsock 2.',
      TLogType.ServerStatus);
    exit;
  end;
  Self.Sock := socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
  Self.ServerAddr.sin_family := AF_INET;
  Self.ServerAddr.sin_port := htons(8822); // port
  Self.ServerAddr.sin_addr.S_addr := inet_addr(PAnsiChar(Self.Ip));

  Xargv := '1';
  if (setsockopt(Self.Sock, IPPROTO_TCP, TCP_NODELAY, @Xargv, 1) <> 0) then
  begin
    Logger.Write
      ('Ocorreu um erro ao configurar o socket para TCP_NODELAY. ' +
        WSAGetLastError.ToString,
      TLogType.Warnings);
    closesocket(Self.Sock);
    Self.Sock := INVALID_SOCKET;
    exit;
  end;
 { Xargv := '0';
  if (setsockopt(Self.Sock, SOL_SOCKET, SO_SNDBUF, @Xargv, 4) <> 0) then
  begin
    Logger.Write
      ('Ocorreu um erro ao configurar o socket para SO_SNDBUF. ' +
        WSAGetLastError.ToString,
      TLogType.Warnings);
    closesocket(Self.Sock);
    Self.Sock := INVALID_SOCKET;
    exit;
  end;}

  if (bind(Sock, TSockAddr(ServerAddr), sizeof(ServerAddr)) = -1) then
  begin
    Logger.Write('Ocorreu um erro ao configurar o socket.',
      TLogType.ServerStatus);
    closesocket(Sock);
    Sock := INVALID_SOCKET;
    exit;
  end;
  if (listen(Sock, MAX_CONNECTIONS) = -1) then
  begin
    Logger.Write('Ocorreu um erro ao colocar o socket em modo de escuta.',
      TLogType.ServerStatus);
    closesocket(Sock);
    Sock := INVALID_SOCKET;
    exit;
  end;
  Result := true;
end;
function TServerSocket.StartServer: Boolean;
begin
  Result := false;
  if not(Self.StartSocket) then
    exit;
  InstantiatedPlayers := 0;
  {cSQL := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if (cSQL.Query.Connection.Connected) then
  begin
    Logger.Write(ServerList[Self.ChannelId].Name +
      ' Conexão geral do MySQL aberta. [' + MYSQL_SERVER + ':' +
      IntToStr(MYSQL_PORT) + ' (' + MYSQL_USERNAME + ') (' + MYSQL_DATABASE +
      ')]', TLogType.ServerStatus);
  end
  else
  begin
    Logger.Write
      ('Não foi possível abrir conexão geral do MySQL para o Servidor.',
      TLogType.Warnings);
    Logger.Write('MySQL Connection failed. [GENERAL CONNECION SERVER]',
      TLogType.Error);
    exit;
  end; }
  IsActive := true;
  ZeroMemory(@Self.Players, sizeof(Self.Players));
  ZeroMemory(@Self.MOBS, sizeof(Self.MOBS));
  ZeroMemory(@Self.Parties, sizeof(Self.Parties));
  ZeroMemory(@Self.DGUrsula, sizeof(TDungeon));
  ZeroMemory(@Self.DGEvgInf, sizeof(TDungeon));
  ZeroMemory(@Self.DGEvgSup, sizeof(TDungeon));
  ZeroMemory(@Self.DGMines1, sizeof(TDungeon));
  ZeroMemory(@Self.DGKinary, sizeof(TDungeon));
  //Self.StartThreads;
  Self.StartPartys;
  Self.StartMobs;

  CastleSiegeHandler := TCastleSiege.Create();
  //Self.InitDungeons;
  ZeroMemory(@Self.PETS, sizeof(Self.PETS));
  ZeroMemory(@Self.OBJ, sizeof(Self.OBJ));
  Logger.Write(ServerList[Self.ChannelId].Name +
    ' iniciado com sucesso [Porta: 8822].', TLogType.ServerStatus);
  Self.ResetTime := Self.GetResetTime;
  Result := true;
end;
procedure TServerSocket.CloseServer;
var
  i: Integer;
begin
  //if (Sock = INVALID_SOCKET) or not(IsActive) then
    //exit;
  //closesocket(Sock);
  //Sock := INVALID_SOCKET;
  Self.IsActive := False;
  for I := Low(Self.Players) to High(Self.Players) do
  begin
    Self.Players[i].SocketClosed := True;
    //if(Self.Players[i].Socket <> INVALID_SOCKET) then
      //closesocket(Self.Players[i].Socket);
  end;
   { Self.Players[i].Socket := INVALID_SOCKET;

   { if(Self.Players[i].Base.ClientID = 0) then
      Continue;
    if(Self.Players[i].Status < Playing) then
      Continue;
    if(Assigned(Self.Players[i].PlayerSQL)) then
    begin
      if(Self.Players[i].PlayerSQL.Query.Connection.Connected) then
        Self.Disconnect(Self.Players[i]);
    end;}
      //Sleep(100);
    //closesocket(Self.Players[i].Socket);
  //end;
  //IsActive := false;
  //DisconnectAll();
  //Self.cSQL.Destroy;
  //closesocket(Sock);
  // Self.Free;
end;
procedure TServerSocket.StartThreads;
begin
  ConnectionThread := TConnectionsThread.Create(ACCEPT_CONNECTIONS_DELAY,Self.ChannelId);
  UpdateHpMpThread := TUpdateHpMpThread.Create(2000, Self.ChannelId);
  UpdateBuffsThread := TUpdateBuffsThread.Create(1000, Self.ChannelId);
  UpdateTimeThread := TUpdateTimeThread.Create(500, Self.ChannelId);
  UpdateEventListenerThread := TUpdateEventListenerThread.Create(1000,Self.ChannelId);
  SkillRegenerateThread := TSkillRegenerateThread.Create(1000, Self.ChannelId);
  SkillDamageThread := TSkillDamageThread.Create(1000, Self.ChannelId);
  PetHandler := TPetHandler.Create(1500, Self.ChannelId);
  PetSpawner := TPetSpawner.Create(1000, Self.ChannelId);
  TimeItensThread := TTimeItensThread.Create(5000, Self.ChannelId);
  ItemQuestThread := TQuestItemThread.Create(1000, Self.ChannelId);
  PranFoodThread := TPranFoodThread.Create(200000, Self.ChannelId);
  TemplesManagmentThread := TTemplesManagmentThread.Create(1000,Self.ChannelId);
end;
procedure TServerSocket.StartPartys;
var
  i: Integer;
begin
  for i := 1 to Length(Self.Parties) do
  begin
    Self.Parties[i].index := i;
    Self.Parties[i].Leader := 0;
    Self.Parties[i].ChannelId := Self.ChannelId;
    Self.Parties[i].Members := TList<WORD>.Create;
    Self.Parties[i].MemberName := TList<Integer>.Create;
  end;
end;
procedure TServerSocket.StartMobs;
  function IfGuard(IntName: Integer): Boolean;
  begin
    Result := false;
    case IntName of
      81, 82, 117, 485, 486, 739,
      888,  889, 890,
      897,  901, 915,
      924, 1935, 1936,
      1925,  1926, 1927,
      1922,  1923, 2595:
      begin
        Result := true;
        Exit;
      end;
    end;
  end;
var
  Path: String;
  DataFile, F: TextFile;
  FileStrings: TStringList;
  Count: DWORD;
  LineFile: String;
  MobNameInit: String;
  MobN: String;
  id, id2: Integer;
  idGen: Integer;
  i, j: Integer;
begin
  Path := GetCurrentDir + '\Data\Mobs\MonsterListCSV.csv';
  if not(FileExists(Path)) then
  begin
    Logger.Write('O arquivo MonsterList.csv não foi encontrado.',
      TLogType.Warnings);
    exit;
  end;
  AssignFile(DataFile, Path);
  Reset(DataFile);
  FileStrings := TStringList.Create;
  Count := 0;
  id := 0;
  idGen := 1;
  MobNameInit := 'Max_Filhote';
  while not EOF(DataFile) do
  begin
    ReadLn(DataFile, LineFile);
    if(Trim(LineFile) = '') then
      Continue;
    ExtractStrings([','], [' '], PChar(LineFile), FileStrings);
    MobN := FileStrings[4];

    if (MobNameInit = MobN) then // same mob
    begin
      MOBS.TMobS[id].IndexGeneric := id;
      // CopyMemory(@MOBS.TMobS[id].Name, @MobN, sizeof(MobN));
      System.AnsiStrings.StrPLCopy(MOBS.TMobS[id].Name, AnsiString(MobN), 64);
      MOBS.TMobS[id].MobsP[idGen].index := Count + 3048;
      if ((pos('Mutante', MobN) <> 0) or (pos('Crenon', MobN) <> 0)) then
      begin // mutantes não andam
        MOBS.TMobS[id].MobsP[idGen].InitPos.X := FileStrings[9].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].InitPos.Y := FileStrings[10].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].DestPos.X := FileStrings[9].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].DestPos.Y := FileStrings[10].ToSingle();
        if not (pos('Crenon', MobN) <> 0) then
          MOBS.TMobS[id].MobsP[idGen].isMutant := True;
      end
      else
      begin
        MOBS.TMobS[id].MobsP[idGen].InitPos.X := FileStrings[9].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].InitPos.Y := FileStrings[10].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].DestPos.X := FileStrings[14].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].DestPos.Y := FileStrings[15].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].FirstDestPos.X :=
          FileStrings[14].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].FirstDestPos.Y :=
          FileStrings[15].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].DestPos.X :=
          MOBS.TMobS[id].MobsP[idGen].DestPos.X + 5;
        MOBS.TMobS[id].MobsP[idGen].DestPos.Y :=
          MOBS.TMobS[id].MobsP[idGen].DestPos.Y + 5;
      end;
      MOBS.TMobS[id].MobsP[idGen].InitAttackRange :=
        FileStrings[11].ToInteger();
      MOBS.TMobS[id].MobsP[idGen].InitMoveWait := FileStrings[12].ToInteger();
      MOBS.TMobS[id].MobsP[idGen].DestAttackRange :=
        FileStrings[16].ToInteger();
      MOBS.TMobS[id].MobsP[idGen].DestMoveWait := FileStrings[17].ToInteger();
      MOBS.TMobS[id].MoveSpeed := 22;
      MOBS.TMobS[id].MobsP[idGen].Base.Create(nil, (Count + 3048),
        Self.ChannelId);
      MOBS.TMobS[id].MobsP[idGen].Base.Mobid := id;
      MOBS.TMobS[id].MobsP[idGen].Base.IsActive := true;
      MOBS.TMobS[id].MobsP[idGen].Base.ClientId := Count + 3048;
      MOBS.TMobS[id].MobsP[idGen].Base.SecondIndex := idGen;
      MOBS.TMobS[id].MobsP[idGen].MovedTo := TypeMobLocation.Init;
      MOBS.TMobS[id].MobsP[idGen].LastMyAttack := now;
      MOBS.TMobS[id].MobsP[idGen].LastSkillAttack := now;
      MOBS.TMobS[id].MobsP[idGen].CurrentPos := MOBS.TMobS[id].MobsP
        [idGen].InitPos;
      MOBS.TMobS[id].MobsP[idGen].XPositionsToMove := 1;
      MOBS.TMobS[id].MobsP[idGen].YPositionsToMove := 1;
      MOBS.TMobS[id].MobsP[idGen].NeighborIndex := -1;
    end
    else
    begin // mob change
      MobNameInit := MobN;
      inc(id);
      idGen := 1;
      MOBS.TMobS[id].IndexGeneric := id;
      System.AnsiStrings.StrPLCopy(MOBS.TMobS[id].Name, AnsiString(MobN), 64);
      // CopyMemory(@MOBS.TMobS[id].Name, @MobN, sizeof(MobN));
      // := String(MobN);
      MOBS.TMobS[id].MobsP[idGen].index := Count + 3048;
      if ((pos('Mutante', MobN) <> 0) or (pos('Crenon', MobN) <> 0))then
      begin // mutantes não andam
        MOBS.TMobS[id].MobsP[idGen].InitPos.X := FileStrings[9].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].InitPos.Y := FileStrings[10].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].DestPos.X := FileStrings[9].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].DestPos.Y := FileStrings[10].ToSingle();
        if not(pos('Crenon', MobN) <> 0) then
          MOBS.TMobS[id].MobsP[idGen].isMutant := True;
      end
      else
      begin
        MOBS.TMobS[id].MobsP[idGen].InitPos.X := FileStrings[9].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].InitPos.Y := FileStrings[10].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].DestPos.X := FileStrings[14].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].DestPos.Y := FileStrings[15].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].FirstDestPos.X :=
          FileStrings[14].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].FirstDestPos.Y :=
          FileStrings[15].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].DestPos.X :=
          MOBS.TMobS[id].MobsP[idGen].DestPos.X + 5;
        MOBS.TMobS[id].MobsP[idGen].DestPos.Y :=
          MOBS.TMobS[id].MobsP[idGen].DestPos.Y + 5;
      end;
      MOBS.TMobS[id].MobsP[idGen].InitAttackRange :=
        FileStrings[11].ToInteger();
      MOBS.TMobS[id].MobsP[idGen].InitMoveWait := FileStrings[12].ToInteger();
      MOBS.TMobS[id].MobsP[idGen].DestAttackRange :=
        FileStrings[16].ToInteger();
      MOBS.TMobS[id].MobsP[idGen].DestMoveWait := FileStrings[17].ToInteger();
      MOBS.TMobS[id].MoveSpeed := 22;
      MOBS.TMobS[id].MobsP[idGen].Base.Create(nil, (Count + 3048),
        Self.ChannelId);
      MOBS.TMobS[id].MobsP[idGen].Base.Mobid := id;
      MOBS.TMobS[id].MobsP[idGen].Base.IsActive := true;
      MOBS.TMobS[id].MobsP[idGen].Base.ClientId := Count + 3048;
      MOBS.TMobS[id].MobsP[idGen].Base.SecondIndex := idGen;
      MOBS.TMobS[id].MobsP[idGen].MovedTo := TypeMobLocation.Init;
      MOBS.TMobS[id].MobsP[idGen].LastMyAttack := now;
      MOBS.TMobS[id].MobsP[idGen].LastSkillAttack := now;
      MOBS.TMobS[id].MobsP[idGen].CurrentPos := MOBS.TMobS[id].MobsP
        [idGen].InitPos;
      MOBS.TMobS[id].MobsP[idGen].XPositionsToMove := 1;
      MOBS.TMobS[id].MobsP[idGen].YPositionsToMove := 1;
      MOBS.TMobS[id].MobsP[idGen].NeighborIndex := -1;
    end;
    FileStrings.Clear;
    inc(Count);
    inc(idGen);
  end;
  Path := GetCurrentDir + '\Data\Mobs\AllMobsInfo.csv';
  if not(FileExists(Path)) then
  begin
    Logger.Write('O arquivo AllMobsInfo.csv não foi encontrado.',
      TLogType.Warnings);
    exit;
  end;
  AssignFile(F, Path);
  Reset(F);
  FileStrings.Clear;
  id2 := 0;
  while not EOF(F) do
  begin
    ReadLn(F, LineFile);
    if(Trim(LineFile) = '') then
      Continue;
    ExtractStrings([','], [' '], PChar(LineFile), FileStrings);
    MobN := FileStrings[1];
    MobN := StringReplace(MobN, ' ', '_', [rfReplaceAll, rfIgnoreCase]);
    for i := 0 to 449 do
    begin
      if (MobN = String(MOBS.TMobS[i].Name)) then
      begin
        MOBS.TMobS[i].IntName := FileStrings[0].ToInteger();
        MOBS.TMobS[i].Equip[0] := WORD(FileStrings[2].ToInteger());
        MOBS.TMobS[i].Equip[1] := WORD(FileStrings[3].ToInteger());
        MOBS.TMobS[i].Equip[6] := WORD(FileStrings[4].ToInteger());
        MOBS.TMobS[i].InitHP := FileStrings[5].ToInteger();
        if(MOBS.TMobS[i].InitHP = 0) then
        begin
          MOBS.TMobS[i].InitHP := 3500;
        end;
        MOBS.TMobS[i].Rotation := FileStrings[6].ToInteger();
        MOBS.TMobS[i].MobLevel := FileStrings[7].ToInteger();
        MOBS.TMobS[i].MobElevation := WORD(FileStrings[8].ToInteger());
        MOBS.TMobS[i].Cabeca := FileStrings[9].ToInteger();
        MOBS.TMobS[i].Perna := FileStrings[10].ToInteger();
        MOBS.TMobS[i].MobType := FileStrings[11].ToInteger();
        MOBS.TMobS[i].SpawnType := FileStrings[12].ToInteger();
        MOBS.TMobS[i].IsService := WordBool(FileStrings[13].ToInteger);

        MOBS.TMobS[i].ReespawnTime := FileStrings[18].ToInteger();
        MOBS.TMobS[i].Skill01 := FileStrings[19].ToInteger();
        MOBS.TMobS[i].Skill02 := FileStrings[20].ToInteger();
        MOBS.TMobS[i].Skill03 := FileStrings[21].ToInteger();
        MOBS.TMobS[i].Skill04 := FileStrings[22].ToInteger();
        MOBS.TMobS[i].Skill05 := FileStrings[23].ToInteger();

        MOBS.TMobS[i].MobExp := FileStrings[24].ToInteger();
        MOBS.TMobS[i].DropIndex := FileStrings[25].ToInteger();

        MOBS.TMobS[i].IsActiveToSpawn := Boolean(FileStrings[26].ToInteger());



        {MOBS.TMobS[i].FisAtk :=
          RandomRange(15, (MOBS.TMobS[i].MobLevel * 6)+15);
        MOBS.TMobS[i].MagAtk :=
          RandomRange(15, (MOBS.TMobS[i].MobLevel * 6)+15);
        MOBS.TMobS[i].FisDef
          := RandomRange(15, (MOBS.TMobS[i].MobLevel * 12)+15);
        MOBS.TMobS[i].MagDef
          := RandomRange(15, (MOBS.TMobS[i].MobLevel * 12)+15);}

        Randomize;
        for j := 0 to 49 do
        begin
          if (MOBS.TMobS[i].MobsP[j].index = 0) then
            continue;

          if(MOBS.TMobS[i].InitHP > 1000000) then
          begin
            MOBS.TMobS[i].MobsP[j].Base.IsBoss := True;
          end;

          MOBS.TMobS[i].MobsP[j].HP := MOBS.TMobS[i].InitHP;
          MOBS.TMobS[i].MobsP[j].MP := MOBS.TMobS[i].InitHP;

          MOBS.TMobS[i].MobsP[j].LastSkillUsedByMob := Now;

          MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.CurrentScore.DNFis :=
            FileStrings[14].ToInteger();
          MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.CurrentScore.DNMag :=
            FileStrings[15].ToInteger();
          MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.CurrentScore.DefFis
            := FileStrings[16].ToInteger();
          MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.CurrentScore.DefMag
            := FileStrings[17].ToInteger();

          if (pos('Mutante', MobN) <> 0) then
          begin
            MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.CurrentScore.Esquiva
              := MOB_ESQUIVA * 3; // estava 0
            MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.CritRes := MOB_CRIT_RES * 3;
            MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.DuploRes := MOB_DUPLO_RES * 3;
          end
          else
          begin
            MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.CurrentScore.Esquiva
              := MOB_ESQUIVA; // estava 0
            MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.CritRes := MOB_CRIT_RES;
            MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.DuploRes := MOB_DUPLO_RES;
          end;

          MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.Nation :=
            Self.NationID; // Self.ChannelId + 1;
          MOBS.TMobS[i].MobsP[j].LastMyAttack := now;
          MOBS.TMobS[i].MobsP[j].UpdatedMobSpawn := Now;
          MOBS.TMobS[i].MobsP[j].UpdatedMobHandler := Now;
          MOBS.TMobS[i].MobsP[j].UpdatedMobMoviment := Now;
          if (IfGuard(MOBS.TMobS[i].IntName) = true) then
          begin
            MOBS.TMobS[i].MobsP[j].isGuard := true;
            MOBS.TMobS[i].MobsP[j].CurrentPos := MOBS.TMobS[i].MobsP[j].InitPos;
            MOBS.TMobS[i].MobsP[j].DestPos := MOBS.TMobS[i].MobsP[j].InitPos;
            MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.CurrentScore.DNFis
              := MOB_GUARD_PATK;
            MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.CurrentScore.DNMag
              := MOB_GUARD_MATK;
            MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.CurrentScore.DefFis
              := MOB_GUARD_PDEF;
            MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.CurrentScore.DefMag
              := MOB_GUARD_MDEF;
          end;
        end;
        break;
      end
      else
      begin
        continue;
      end;
    end;
    inc(id2);
    FileStrings.Clear;
  end;
  //Logger.Write(MOBS.TMobS[294].IntName.toString, TLogType.Packets);
 { for I := 0 to 449 do
  begin
    if(MOBS.TMobS[i].Equip[0] = 0) and (String(MOBS.TMobS[i].Name) <> '') then
    begin
       ZeroMemory(@MOBS.TMobS[i], sizeof(MOBS.TMobS[i]));
    end;
  end; }
  if(MobSpawnThread1 = nil) then
    MobSpawnThread1 := TMobSpawnThread1.Create(1000, Self.ChannelId, 0);
  if(MobSpawnThread2 = nil) then
    MobSpawnThread2 := TMobSpawnThread2.Create(1000, Self.ChannelId, 0);
  if(MobSpawnThread3 = nil) then
    MobSpawnThread3 := TMobSpawnThread3.Create(1000, Self.ChannelId, 0);
  // MobSpawnThread4 := TMobSpawnThread4.Create(700, Self.ChannelId, 0);
  if(MobHandlerThread1 = nil) then
    MobHandlerThread1 := TMobHandlerThread1.Create(1000, Self.ChannelId, 0);
  if(MobHandlerThread2 = nil) then
    MobHandlerThread2 := TMobHandlerThread2.Create(1000, Self.ChannelId, 0);
  if(MobHandlerThread3 = nil) then
    MobHandlerThread3 := TMobHandlerThread3.Create(1000, Self.ChannelId, 0);
  // MobHandlerThread4 := TMobHandlerThread4.Create(2000, Self.ChannelId, 0);
  // MobHandlerThread5 := TMobHandlerThread5.Create(2000, Self.ChannelId, 0);
  // MobHandlerThread6 := TMobHandlerThread6.Create(2000, Self.ChannelId, 0);
  // MobHandlerThread7 := TMobHandlerThread7.Create(2000, Self.ChannelId, 0);
  // MobHandlerThread8 := TMobHandlerThread8.Create(2000, Self.ChannelId, 0);
  if(MobMovimentThread1 = nil) then
   MobMovimentThread1 := TMobMovimentThread1.Create(600, Self.ChannelId, 0);
  if(MobMovimentThread2 = nil) then
    MobMovimentThread2 := TMobMovimentThread2.Create(600, Self.ChannelId, 0);
  if(MobMovimentThread3 = nil) then
    MobMovimentThread3 := TMobMovimentThread3.Create(600, Self.ChannelId, 0);
  // MobMovimentThread4 := TMobMovimentThread4.Create(3000, Self.ChannelId, 0);
  // MobMovimentThread5 := TMobMovimentThread5.Create(3000, Self.ChannelId, 0);
  // MobMovimentThread6 := TMobMovimentThread6.Create(3000, Self.ChannelId, 0);
  // MobMovimentThread7 := TMobMovimentThread7.Create(3000, Self.ChannelId, 0);
  // MobMovimentThread8 := TMobMovimentThread8.Create(3000, Self.ChannelId, 0);
  FileStrings.Free;
  Logger.Write('[Server Mobs Init ] Mobs iniciados com sucesso. Mobs: ' +
    id.ToString + ' Spawns: ' + Count.ToString, TLogType.ServerStatus);
  CloseFile(DataFile);
  CloseFile(F);
end;
procedure TServerSocket.InitDungeons;
var
  Path: String;
  PathMobsInfo, PathMobsPos: String;
  PathMobsDropNon, PathMobsDropPrata, PathMobsDropDourada: String;
  DataFile, F: TextFile;
  FileStrings, MobFileStrings: TStringList;
  Count, count2, CountMob: DWORD;
  LineFile, LineMobFile: String;
  i, j: BYTE;
begin
  Path := GetCurrentDir + '\Data\Dungeons.csv';
  if not(FileExists(Path)) then
  begin
    Logger.Write('O arquivo Dungeons.csv não foi encontrado.',
      TLogType.Warnings);
    exit;
  end;
  AssignFile(DataFile, Path);
  Reset(DataFile);
  FileStrings := TStringList.Create;
  Count := 0;
  while not EOF(DataFile) do
  begin
    ReadLn(DataFile, LineFile);
    ExtractStrings([','], [' '], PChar(LineFile), FileStrings);
    case Count of
      0: // ursula
        begin
          for i := 0 to 2 do
          begin
            Self.DGUrsula[i].index := FileStrings[0].ToInteger();
            Self.DGUrsula[i].Dificult := i;
            Self.DGUrsula[i].EntranceNPCID := FileStrings[2].ToInteger();
            Self.DGUrsula[i].EntrancePosition.Create(FileStrings[3].ToInteger(),
              FileStrings[4].ToInteger());
            Self.DGUrsula[i].SpawnInDungeonPosition.Create
              (FileStrings[5].ToInteger(), FileStrings[6].ToInteger());
            case Self.DGUrsula[i].Dificult of
              0:
                begin
                  Self.DGUrsula[i].LevelMin := FileStrings[7].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Zantorian Citadel_Normal.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Zantorian Citadel_Normal.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\zantorian\11.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\zantorian\12.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\zantorian\13.txt';
                end;
              1:
                begin
                  Self.DGUrsula[i].LevelMin := FileStrings[8].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Zantorian Citadel_Dificil.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Zantorian Citadel_Dificil.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\zantorian\21.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\zantorian\22.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\zantorian\23.txt';
                end;
              2:
                begin
                  Self.DGUrsula[i].LevelMin := FileStrings[9].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Zantorian Citadel_Elite.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Zantorian Citadel_Elite.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\zantorian\31.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\zantorian\32.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\zantorian\33.txt';
                end;
            end;
            if not(FileExists(PathMobsInfo)) then
            begin
              Logger.Write(PathMobsInfo + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsInfo);
            Reset(F);
            MobFileStrings := TStringList.Create;
            CountMob := 0;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              Self.DGUrsula[i].MOBS.TMobS[CountMob].IntName :=
                MobFileStrings[0].ToInteger();
              Self.DGUrsula[i].MOBS.TMobS[CountMob].IndexGeneric :=
                CountMob + 2600;
              System.AnsiStrings.StrPLCopy(Self.DGUrsula[i].MOBS.TMobS[CountMob]
                .Name, AnsiString(MobFileStrings[1]), 64);
              Self.DGUrsula[i].MOBS.TMobS[CountMob].Equip[0] :=
                MobFileStrings[2].ToInteger();
              Self.DGUrsula[i].MOBS.TMobS[CountMob].Equip[1] :=
                MobFileStrings[3].ToInteger();
              Self.DGUrsula[i].MOBS.TMobS[CountMob].Equip[6] :=
                MobFileStrings[4].ToInteger();
              Self.DGUrsula[i].MOBS.TMobS[CountMob].MobElevation := 7;
              Self.DGUrsula[i].MOBS.TMobS[CountMob].Cabeca := 119;
              Self.DGUrsula[i].MOBS.TMobS[CountMob].Perna := 119;
              if (Self.DGUrsula[i].MOBS.TMobS[CountMob].Equip[6] > 0) then
                Self.DGUrsula[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGUrsula[i].MOBS.TMobS[CountMob].Equip[6]
              else
                Self.DGUrsula[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGUrsula[i].MOBS.TMobS[CountMob].Equip[0];
              Self.DGUrsula[i].MOBS.TMobS[CountMob].MagAtk :=
                Self.DGUrsula[i].MOBS.TMobS[CountMob].FisAtk;
              Self.DGUrsula[i].MOBS.TMobS[CountMob].FisDef :=
                (Self.DGUrsula[i].MOBS.TMobS[CountMob].FisAtk * 2);
              Self.DGUrsula[i].MOBS.TMobS[CountMob].MagDef :=
                Self.DGUrsula[i].MOBS.TMobS[CountMob].FisDef;
              Self.DGUrsula[i].MOBS.TMobS[CountMob].MoveSpeed := 25;
              Self.DGUrsula[i].MOBS.TMobS[CountMob].InitHP :=
                MobFileStrings[5].ToInteger();
              Self.DGUrsula[i].MOBS.TMobS[CountMob].MobExp :=
                Round(Self.DGUrsula[i].MOBS.TMobS[CountMob].InitHP * 1.8);
              Self.DGUrsula[i].MOBS.TMobS[CountMob].MobLevel :=
                MobFileStrings[7].ToInteger();
              Self.DGUrsula[i].MOBS.TMobS[CountMob].Rotation :=
                MobFileStrings[6].ToInteger();
              Self.DGUrsula[i].MOBS.TMobS[CountMob].MobType :=
                MobFileStrings[11].ToInteger();
              Self.DGUrsula[i].MOBS.TMobS[CountMob].cntControl := 0;
              Self.DGUrsula[i].MOBS.TMobS[CountMob].SpawnType :=
                MobFileStrings[16].ToInteger();
              Self.DGUrsula[i].MOBS.TMobS[CountMob].DungeonDropIndex :=
                MobFileStrings[18].ToInteger();
              inc(CountMob);
              MobFileStrings.Clear;
            end;
            Logger.Write('[Server Mobs Init] Ursula ' + TDungeonDificultNames
              [Self.DGUrsula[i].Dificult] + ' Mobs Info OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsPos)) then
            begin
              Logger.Write(PathMobsPos + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsPos);
            Reset(F);
            MobFileStrings := TStringList.Create;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              MobFileStrings.Clear;
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              for j := 0 to 44 do
              begin
                if (Self.DGUrsula[i].MOBS.TMobS[j].IntName = 0) then
                  continue;
                if (Self.DGUrsula[i].MOBS.TMobS[j].IntName = MobFileStrings[6]
                  .ToInteger()) then
                begin
                  CountMob := Self.DGUrsula[i].MOBS.TMobS[j].cntControl;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob].index :=
                    MobFileStrings[0].ToInteger();
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob].HP :=
                    MobFileStrings[2].ToInteger();
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob].MP :=
                    Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob].HP;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob].InitPos.Create
                    (MobFileStrings[3].ToInteger(),
                    MobFileStrings[4].ToInteger());
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob].DestPos :=
                    Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob].InitPos;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .InitAttackRange := 20;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .DestAttackRange := 20;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Create(nil, Self.DGUrsula[i].MOBS.TMobS[j].MobsP
                    [CountMob].index, Self.ChannelId);
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.IsActive := true;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob].Base.ClientId
                    := Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob].index;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Mobid := j;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.SecondIndex := CountMob;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.CurrentScore.Esquiva :=
                    MOB_ESQUIVA;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.CritRes := MOB_CRIT_RES;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.DuploRes := MOB_DUPLO_RES;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.Nation := Self.ChannelId + 1;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .LastMyAttack := now;
                  inc(Self.DGUrsula[i].MOBS.TMobS[j].cntControl);
                  break;
                end
                else
                  continue;
              end;
            end;
            Logger.Write('[Server Mobs Init] Ursula ' + TDungeonDificultNames
              [Self.DGUrsula[i].Dificult] + ' Mobs Position OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsDropNon)) then
            begin
              Logger.Write(PathMobsDropNon + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsDropNon);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGUrsula[i].MobsDrop.SemCoroa[count2] :=
                StrToInt(LineMobFile);
              inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Ursula ' + TDungeonDificultNames
              [Self.DGUrsula[i].Dificult] + ' Mobs Drops [Mobs sem Coroa] OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropPrata)) then
            begin
              Logger.Write(PathMobsDropPrata + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsDropPrata);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGUrsula[i].MobsDrop.CoroaPrata[count2] :=
                StrToInt(LineMobFile);
              inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Ursula ' + TDungeonDificultNames
              [Self.DGUrsula[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Prata] OK.', TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropDourada)) then
            begin
              Logger.Write(PathMobsDropDourada + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsDropDourada);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGUrsula[i].MobsDrop.CoroaDourada[count2] :=
                StrToInt(LineMobFile);
              inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Ursula ' + TDungeonDificultNames
              [Self.DGUrsula[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Dourada] OK.', TLogType.ServerStatus);
            CloseFile(F);
          end;
        end;
      1: // marauder hold
        begin
          for i := 0 to 2 do
          begin
            Self.DGEvgInf[i].index := FileStrings[0].ToInteger();
            Self.DGEvgInf[i].Dificult := i;
            Self.DGEvgInf[i].EntranceNPCID := FileStrings[2].ToInteger();
            Self.DGEvgInf[i].EntrancePosition.Create(FileStrings[3].ToInteger(),
              FileStrings[4].ToInteger());
            Self.DGEvgInf[i].SpawnInDungeonPosition.Create
              (FileStrings[5].ToInteger(), FileStrings[6].ToInteger());
            case Self.DGEvgInf[i].Dificult of
              0:
                begin
                  Self.DGEvgInf[i].LevelMin := FileStrings[7].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Marauder Hold_Normal.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Marauder Hold_Normal.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\marauder_hold\41.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\marauder_hold\42.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\marauder_hold\43.txt';
                end;
              1:
                begin
                  Self.DGEvgInf[i].LevelMin := FileStrings[8].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Marauder Hold_Dificil.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Marauder Hold_Dificil.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\marauder_hold\51.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\marauder_hold\52.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\marauder_hold\53.txt';
                end;
              2:
                begin
                  Self.DGEvgInf[i].LevelMin := FileStrings[9].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Marauder Hold_Elite.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Marauder Hold_Elite.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\marauder_hold\61.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\marauder_hold\62.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\marauder_hold\63.txt';
                end;
            end;
            if not(FileExists(PathMobsInfo)) then
            begin
              Logger.Write(PathMobsInfo + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsInfo);
            Reset(F);
            MobFileStrings := TStringList.Create;
            CountMob := 0;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].IntName :=
                MobFileStrings[0].ToInteger();
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].IndexGeneric :=
                CountMob + 2600;
              System.AnsiStrings.StrPLCopy(Self.DGEvgInf[i].MOBS.TMobS[CountMob]
                .Name, AnsiString(MobFileStrings[1]), 64);
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].Equip[0] :=
                MobFileStrings[2].ToInteger();
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].Equip[1] :=
                MobFileStrings[3].ToInteger();
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].Equip[6] :=
                MobFileStrings[4].ToInteger();
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].MobElevation := 7;
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].Cabeca := 119;
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].Perna := 119;
              if (Self.DGEvgInf[i].MOBS.TMobS[CountMob].Equip[6] > 0) then
                Self.DGEvgInf[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGEvgInf[i].MOBS.TMobS[CountMob].Equip[6]
              else
                Self.DGEvgInf[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGEvgInf[i].MOBS.TMobS[CountMob].Equip[0];
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].MagAtk :=
                Self.DGEvgInf[i].MOBS.TMobS[CountMob].FisAtk;
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].FisDef :=
                (Self.DGEvgInf[i].MOBS.TMobS[CountMob].FisAtk * 2);
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].MagDef :=
                Self.DGEvgInf[i].MOBS.TMobS[CountMob].FisDef;
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].MoveSpeed := 25;
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].InitHP :=
                MobFileStrings[5].ToInteger();
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].MobExp :=
                Round(Self.DGEvgInf[i].MOBS.TMobS[CountMob].InitHP * 1.8);
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].MobLevel :=
                MobFileStrings[7].ToInteger();
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].Rotation :=
                MobFileStrings[6].ToInteger();
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].MobType :=
                MobFileStrings[11].ToInteger();
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].cntControl := 0;
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].SpawnType :=
                MobFileStrings[16].ToInteger();
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].DungeonDropIndex :=
                MobFileStrings[18].ToInteger();
              inc(CountMob);
              MobFileStrings.Clear;
            end;
            Logger.Write('[Server Mobs Init] Evg Inf ' + TDungeonDificultNames
              [Self.DGEvgInf[i].Dificult] + ' Mobs Info OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsPos)) then
            begin
              Logger.Write(PathMobsPos + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsPos);
            Reset(F);
            MobFileStrings := TStringList.Create;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              MobFileStrings.Clear;
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              for j := 0 to 44 do
              begin
                if (Self.DGEvgInf[i].MOBS.TMobS[j].IntName = 0) then
                  continue;
                if (Self.DGEvgInf[i].MOBS.TMobS[j].IntName = MobFileStrings[6]
                  .ToInteger()) then
                begin
                  CountMob := Self.DGEvgInf[i].MOBS.TMobS[j].cntControl;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob].index :=
                    MobFileStrings[0].ToInteger();
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob].HP :=
                    MobFileStrings[2].ToInteger();
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob].MP :=
                    Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob].HP;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob].InitPos.Create
                    (MobFileStrings[3].ToInteger(),
                    MobFileStrings[4].ToInteger());
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob].DestPos :=
                    Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob].InitPos;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .InitAttackRange := 20;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .DestAttackRange := 20;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Create(nil, Self.DGEvgInf[i].MOBS.TMobS[j].MobsP
                    [CountMob].index, Self.ChannelId);
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.IsActive := true;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob].Base.ClientId
                    := Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob].index;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Mobid := j;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.SecondIndex := CountMob;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.CurrentScore.Esquiva :=
                    MOB_ESQUIVA;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.CritRes := MOB_CRIT_RES;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.DuploRes := MOB_DUPLO_RES;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.Nation := Self.ChannelId + 1;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .LastMyAttack := now;
                  inc(Self.DGEvgInf[i].MOBS.TMobS[j].cntControl);
                  break;
                end
                else
                  continue;
              end;
            end;
            Logger.Write('[Server Mobs Init] Evg Inf ' + TDungeonDificultNames
              [Self.DGEvgInf[i].Dificult] + ' Mobs Position OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsDropNon)) then
            begin
              Logger.Write(PathMobsDropNon + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsDropNon);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGEvgInf[i].MobsDrop.SemCoroa[count2] :=
                StrToInt(LineMobFile);
              inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Evg Inf ' + TDungeonDificultNames
              [Self.DGEvgInf[i].Dificult] + ' Mobs Drops [Mobs sem Coroa] OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropPrata)) then
            begin
              Logger.Write(PathMobsDropPrata + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsDropPrata);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGEvgInf[i].MobsDrop.CoroaPrata[count2] :=
                StrToInt(LineMobFile);
              inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Evg Inf ' + TDungeonDificultNames
              [Self.DGEvgInf[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Prata] OK.', TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropDourada)) then
            begin
              Logger.Write(PathMobsDropDourada + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsDropDourada);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGEvgInf[i].MobsDrop.CoroaDourada[count2] :=
                StrToInt(LineMobFile);
              inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Evg Inf ' + TDungeonDificultNames
              [Self.DGEvgInf[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Dourada] OK.', TLogType.ServerStatus);
            CloseFile(F);
          end;
        end;
      2: // marauder cabin
        begin
          for i := 0 to 2 do
          begin
            Self.DGEvgSup[i].index := FileStrings[0].ToInteger();
            Self.DGEvgSup[i].Dificult := i;
            Self.DGEvgSup[i].EntranceNPCID := FileStrings[2].ToInteger();
            Self.DGEvgSup[i].EntrancePosition.Create(FileStrings[3].ToInteger(),
              FileStrings[4].ToInteger());
            Self.DGEvgSup[i].SpawnInDungeonPosition.Create
              (FileStrings[5].ToInteger(), FileStrings[6].ToInteger());
            case Self.DGEvgSup[i].Dificult of
              0:
                begin
                  Self.DGEvgSup[i].LevelMin := FileStrings[7].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Marauder Cabin_Normal.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Marauder Cabin_Normal.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\marauder_cabin\71.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\marauder_cabin\72.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\marauder_cabin\73.txt';
                end;
              1:
                begin
                  Self.DGEvgSup[i].LevelMin := FileStrings[8].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Marauder Cabin_Dificil.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Marauder Cabin_Dificil.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\marauder_cabin\81.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\marauder_cabin\82.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\marauder_cabin\83.txt';
                end;
              2:
                begin
                  Self.DGEvgSup[i].LevelMin := FileStrings[9].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Marauder Cabin_Elite.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Marauder Cabin_Elite.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\marauder_cabin\91.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\marauder_cabin\92.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\marauder_cabin\93.txt';
                end;
            end;
            if not(FileExists(PathMobsInfo)) then
            begin
              Logger.Write(PathMobsInfo + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsInfo);
            Reset(F);
            MobFileStrings := TStringList.Create;
            CountMob := 0;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].IntName :=
                MobFileStrings[0].ToInteger();
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].IndexGeneric :=
                CountMob + 2600;
              System.AnsiStrings.StrPLCopy(Self.DGEvgSup[i].MOBS.TMobS[CountMob]
                .Name, AnsiString(MobFileStrings[1]), 64);
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].Equip[0] :=
                MobFileStrings[2].ToInteger();
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].Equip[1] :=
                MobFileStrings[3].ToInteger();
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].Equip[6] :=
                MobFileStrings[4].ToInteger();
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].MobElevation := 7;
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].Cabeca := 119;
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].Perna := 119;
              if (Self.DGEvgSup[i].MOBS.TMobS[CountMob].Equip[6] > 0) then
                Self.DGUrsula[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGEvgSup[i].MOBS.TMobS[CountMob].Equip[6]
              else
                Self.DGEvgSup[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGEvgSup[i].MOBS.TMobS[CountMob].Equip[0];
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].MagAtk :=
                Self.DGEvgSup[i].MOBS.TMobS[CountMob].FisAtk;
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].FisDef :=
                (Self.DGEvgSup[i].MOBS.TMobS[CountMob].FisAtk * 2);
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].MagDef :=
                Self.DGEvgSup[i].MOBS.TMobS[CountMob].FisDef;
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].MoveSpeed := 25;
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].InitHP :=
                MobFileStrings[5].ToInteger();
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].MobExp :=
                Round(Self.DGEvgInf[i].MOBS.TMobS[CountMob].InitHP * 1.8);
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].MobLevel :=
                MobFileStrings[7].ToInteger();
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].Rotation :=
                MobFileStrings[6].ToInteger();
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].MobType :=
                MobFileStrings[11].ToInteger();
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].cntControl := 0;
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].SpawnType :=
                MobFileStrings[16].ToInteger();
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].DungeonDropIndex :=
                MobFileStrings[18].ToInteger();
              inc(CountMob);
              MobFileStrings.Clear;
            end;
            Logger.Write('[Server Mobs Init] Evg Sup ' + TDungeonDificultNames
              [Self.DGEvgSup[i].Dificult] + ' Mobs Info OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsPos)) then
            begin
              Logger.Write(PathMobsPos + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsPos);
            Reset(F);
            MobFileStrings := TStringList.Create;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              MobFileStrings.Clear;
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              for j := 0 to 44 do
              begin
                if (Self.DGEvgSup[i].MOBS.TMobS[j].IntName = 0) then
                  continue;
                if (Self.DGEvgSup[i].MOBS.TMobS[j].IntName = MobFileStrings[6]
                  .ToInteger()) then
                begin
                  CountMob := Self.DGEvgSup[i].MOBS.TMobS[j].cntControl;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob].index :=
                    MobFileStrings[0].ToInteger();
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob].HP :=
                    MobFileStrings[2].ToInteger();
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob].MP :=
                    Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob].HP;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob].InitPos.Create
                    (MobFileStrings[3].ToInteger(),
                    MobFileStrings[4].ToInteger());
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob].DestPos :=
                    Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob].InitPos;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .InitAttackRange := 20;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .DestAttackRange := 20;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Create(nil, Self.DGEvgSup[i].MOBS.TMobS[j].MobsP
                    [CountMob].index, Self.ChannelId);
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.IsActive := true;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob].Base.ClientId
                    := Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob].index;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Mobid := j;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.SecondIndex := CountMob;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.CurrentScore.Esquiva :=
                    MOB_ESQUIVA;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.CritRes := MOB_CRIT_RES;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.DuploRes := MOB_DUPLO_RES;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.Nation := Self.ChannelId + 1;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .LastMyAttack := now;
                  inc(Self.DGEvgSup[i].MOBS.TMobS[j].cntControl);
                  break;
                end
                else
                  continue;
              end;
            end;
            Logger.Write('[Server Mobs Init] Evg Sup ' + TDungeonDificultNames
              [Self.DGEvgSup[i].Dificult] + ' Mobs Position OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsDropNon)) then
            begin
              Logger.Write(PathMobsDropNon + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsDropNon);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGEvgSup[i].MobsDrop.SemCoroa[count2] :=
                StrToInt(LineMobFile);
              inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Evg Sup ' + TDungeonDificultNames
              [Self.DGEvgSup[i].Dificult] + ' Mobs Drops [Mobs sem Coroa] OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropPrata)) then
            begin
              Logger.Write(PathMobsDropPrata + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsDropPrata);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGEvgSup[i].MobsDrop.CoroaPrata[count2] :=
                StrToInt(LineMobFile);
              inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Evg Sup ' + TDungeonDificultNames
              [Self.DGEvgSup[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Prata] OK.', TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropDourada)) then
            begin
              Logger.Write(PathMobsDropDourada + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsDropDourada);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGEvgSup[i].MobsDrop.CoroaDourada[count2] :=
                StrToInt(LineMobFile);
              inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Evg Sup ' + TDungeonDificultNames
              [Self.DGEvgSup[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Dourada] OK.', TLogType.ServerStatus);
            CloseFile(F);
          end;
        end;
      3: // Lost Mine 1
        begin
          for i := 0 to 2 do
          begin
            Self.DGMines1[i].index := FileStrings[0].ToInteger();
            Self.DGMines1[i].Dificult := i;
            Self.DGMines1[i].EntranceNPCID := FileStrings[2].ToInteger();
            Self.DGMines1[i].EntrancePosition.Create(FileStrings[3].ToInteger(),
              FileStrings[4].ToInteger());
            Self.DGMines1[i].SpawnInDungeonPosition.Create
              (FileStrings[5].ToInteger(), FileStrings[6].ToInteger());
            case Self.DGMines1[i].Dificult of
              0:
                begin
                  Self.DGMines1[i].LevelMin := FileStrings[7].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Lost Mine_Normal.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Lost Mine_Normal.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\mines1\101.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\mines1\102.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\mines1\103.txt';
                end;
              1:
                begin
                  Self.DGMines1[i].LevelMin := FileStrings[8].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Lost Mine_Dificil.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Lost Mine_Dificil.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\mines1\201.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\mines1\202.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\mines1\203.txt';
                end;
              2:
                begin
                  Self.DGMines1[i].LevelMin := FileStrings[9].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Lost Mine_Elite.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Lost Mine_Elite.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\mines1\301.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\mines1\302.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\mines1\303.txt';
                end;
            end;
            if not(FileExists(PathMobsInfo)) then
            begin
              Logger.Write(PathMobsInfo + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsInfo);
            Reset(F);
            MobFileStrings := TStringList.Create;
            CountMob := 0;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              Self.DGMines1[i].MOBS.TMobS[CountMob].IntName :=
                MobFileStrings[0].ToInteger();
              Self.DGMines1[i].MOBS.TMobS[CountMob].IndexGeneric :=
                CountMob + 2600;
              System.AnsiStrings.StrPLCopy(Self.DGMines1[i].MOBS.TMobS[CountMob]
                .Name, AnsiString(MobFileStrings[1]), 64);
              Self.DGMines1[i].MOBS.TMobS[CountMob].Equip[0] :=
                MobFileStrings[2].ToInteger();
              Self.DGMines1[i].MOBS.TMobS[CountMob].Equip[1] :=
                MobFileStrings[3].ToInteger();
              Self.DGMines1[i].MOBS.TMobS[CountMob].Equip[6] :=
                MobFileStrings[4].ToInteger();
              Self.DGMines1[i].MOBS.TMobS[CountMob].MobElevation := 7;
              Self.DGMines1[i].MOBS.TMobS[CountMob].Cabeca := 119;
              Self.DGMines1[i].MOBS.TMobS[CountMob].Perna := 119;
              if (Self.DGMines1[i].MOBS.TMobS[CountMob].Equip[6] > 0) then
                Self.DGMines1[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGMines1[i].MOBS.TMobS[CountMob].Equip[6]
              else
                Self.DGMines1[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGMines1[i].MOBS.TMobS[CountMob].Equip[0];
              Self.DGMines1[i].MOBS.TMobS[CountMob].MagAtk :=
                Self.DGMines1[i].MOBS.TMobS[CountMob].FisAtk;
              Self.DGMines1[i].MOBS.TMobS[CountMob].FisDef :=
                (Self.DGMines1[i].MOBS.TMobS[CountMob].FisAtk * 2);
              Self.DGMines1[i].MOBS.TMobS[CountMob].MagDef :=
                Self.DGMines1[i].MOBS.TMobS[CountMob].FisDef;
              Self.DGMines1[i].MOBS.TMobS[CountMob].MoveSpeed := 25;
              Self.DGMines1[i].MOBS.TMobS[CountMob].InitHP :=
                MobFileStrings[5].ToInteger();
              Self.DGMines1[i].MOBS.TMobS[CountMob].MobExp :=
                Round(Self.DGMines1[i].MOBS.TMobS[CountMob].InitHP * 1.8);
              Self.DGMines1[i].MOBS.TMobS[CountMob].MobLevel :=
                MobFileStrings[7].ToInteger();
              Self.DGMines1[i].MOBS.TMobS[CountMob].Rotation :=
                MobFileStrings[6].ToInteger();
              Self.DGMines1[i].MOBS.TMobS[CountMob].MobType :=
                MobFileStrings[11].ToInteger();
              Self.DGMines1[i].MOBS.TMobS[CountMob].cntControl := 0;
              Self.DGMines1[i].MOBS.TMobS[CountMob].SpawnType :=
                MobFileStrings[16].ToInteger();
              Self.DGMines1[i].MOBS.TMobS[CountMob].DungeonDropIndex :=
                MobFileStrings[18].ToInteger();
              inc(CountMob);
              MobFileStrings.Clear;
            end;
            Logger.Write('[Server Mobs Init] Lost Mine1 ' +
              TDungeonDificultNames[Self.DGMines1[i].Dificult] +
              ' Mobs Info OK.', TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsPos)) then
            begin
              Logger.Write(PathMobsPos + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsPos);
            Reset(F);
            MobFileStrings := TStringList.Create;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              MobFileStrings.Clear;
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              for j := 0 to 44 do
              begin
                if (Self.DGMines1[i].MOBS.TMobS[j].IntName = 0) then
                  continue;
                if (Self.DGMines1[i].MOBS.TMobS[j].IntName = MobFileStrings[6]
                  .ToInteger()) then
                begin
                  CountMob := Self.DGMines1[i].MOBS.TMobS[j].cntControl;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob].index :=
                    MobFileStrings[0].ToInteger();
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob].HP :=
                    MobFileStrings[2].ToInteger();
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob].MP :=
                    Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob].HP;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob].InitPos.Create
                    (MobFileStrings[3].ToInteger(),
                    MobFileStrings[4].ToInteger());
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob].DestPos :=
                    Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob].InitPos;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .InitAttackRange := 20;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .DestAttackRange := 20;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Create(nil, Self.DGMines1[i].MOBS.TMobS[j].MobsP
                    [CountMob].index, Self.ChannelId);
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.IsActive := true;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob].Base.ClientId
                    := Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob].index;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Mobid := j;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.SecondIndex := CountMob;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.CurrentScore.Esquiva :=
                    MOB_ESQUIVA;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.CritRes := MOB_CRIT_RES;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.DuploRes := MOB_DUPLO_RES;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.Nation := Self.ChannelId + 1;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .LastMyAttack := now;
                  inc(Self.DGMines1[i].MOBS.TMobS[j].cntControl);
                  break;
                end
                else
                  continue;
              end;
            end;
            Logger.Write('[Server Mobs Init] Lost Mine1 ' +
              TDungeonDificultNames[Self.DGMines1[i].Dificult] +
              ' Mobs Position OK.', TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsDropNon)) then
            begin
              Logger.Write(PathMobsDropNon + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsDropNon);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGMines1[i].MobsDrop.SemCoroa[count2] :=
                StrToInt(LineMobFile);
              inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Lost Mine1 ' +
              TDungeonDificultNames[Self.DGMines1[i].Dificult] +
              ' Mobs Drops [Mobs sem Coroa] OK.', TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropPrata)) then
            begin
              Logger.Write(PathMobsDropPrata + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsDropPrata);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGMines1[i].MobsDrop.CoroaPrata[count2] :=
                StrToInt(LineMobFile);
              inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Lost Mine1 ' +
              TDungeonDificultNames[Self.DGMines1[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Prata] OK.', TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropDourada)) then
            begin
              Logger.Write(PathMobsDropDourada + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsDropDourada);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGMines1[i].MobsDrop.CoroaDourada[count2] :=
                StrToInt(LineMobFile);
              inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Lost Mine1 ' +
              TDungeonDificultNames[Self.DGMines1[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Dourada] OK.', TLogType.ServerStatus);
            CloseFile(F);
          end;
        end;
      4: // kinary aviary
        begin
          for i := 0 to 2 do
          begin
            Self.DGKinary[i].index := FileStrings[0].ToInteger();
            Self.DGKinary[i].Dificult := i;
            Self.DGKinary[i].EntranceNPCID := FileStrings[2].ToInteger();
            Self.DGKinary[i].EntrancePosition.Create(FileStrings[3].ToInteger(),
              FileStrings[4].ToInteger());
            Self.DGKinary[i].SpawnInDungeonPosition.Create
              (FileStrings[5].ToInteger(), FileStrings[6].ToInteger());
            case Self.DGKinary[i].Dificult of
              0:
                begin
                  Self.DGKinary[i].LevelMin := FileStrings[7].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Kynari Aviary_Normal.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Kynari Aviary_Normal.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\kinary\401.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\kinary\402.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\kinary\403.txt';
                end;
              1:
                begin
                  Self.DGKinary[i].LevelMin := FileStrings[8].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Kynari Aviary_Dificil.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Kynari Aviary_Dificil.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\kinary\501.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\kinary\502.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\kinary\503.txt';
                end;
              2:
                begin
                  Self.DGKinary[i].LevelMin := FileStrings[9].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Kynari Aviary_Elite.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Kynari Aviary_Elite.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\kinary\601.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\kinary\602.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\kinary\603.txt';
                end;
            end;
            if not(FileExists(PathMobsInfo)) then
            begin
              Logger.Write(PathMobsInfo + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsInfo);
            Reset(F);
            MobFileStrings := TStringList.Create;
            CountMob := 0;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              Self.DGKinary[i].MOBS.TMobS[CountMob].IntName :=
                MobFileStrings[0].ToInteger();
              Self.DGKinary[i].MOBS.TMobS[CountMob].IndexGeneric :=
                CountMob + 2600;
              System.AnsiStrings.StrPLCopy(Self.DGKinary[i].MOBS.TMobS[CountMob]
                .Name, AnsiString(MobFileStrings[1]), 64);
              Self.DGKinary[i].MOBS.TMobS[CountMob].Equip[0] :=
                MobFileStrings[2].ToInteger();
              Self.DGKinary[i].MOBS.TMobS[CountMob].Equip[1] :=
                MobFileStrings[3].ToInteger();
              Self.DGKinary[i].MOBS.TMobS[CountMob].Equip[6] :=
                MobFileStrings[4].ToInteger();
              Self.DGKinary[i].MOBS.TMobS[CountMob].MobElevation := 7;
              Self.DGKinary[i].MOBS.TMobS[CountMob].Cabeca := 119;
              Self.DGKinary[i].MOBS.TMobS[CountMob].Perna := 119;
              if (Self.DGKinary[i].MOBS.TMobS[CountMob].Equip[6] > 0) then
                Self.DGKinary[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGKinary[i].MOBS.TMobS[CountMob].Equip[6]
              else
                Self.DGKinary[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGKinary[i].MOBS.TMobS[CountMob].Equip[0];
              Self.DGKinary[i].MOBS.TMobS[CountMob].MagAtk :=
                Self.DGKinary[i].MOBS.TMobS[CountMob].FisAtk;
              Self.DGKinary[i].MOBS.TMobS[CountMob].FisDef :=
                (Self.DGKinary[i].MOBS.TMobS[CountMob].FisAtk * 2);
              Self.DGKinary[i].MOBS.TMobS[CountMob].MagDef :=
                Self.DGKinary[i].MOBS.TMobS[CountMob].FisDef;
              Self.DGKinary[i].MOBS.TMobS[CountMob].MoveSpeed := 25;
              Self.DGKinary[i].MOBS.TMobS[CountMob].InitHP :=
                MobFileStrings[5].ToInteger();
              Self.DGKinary[i].MOBS.TMobS[CountMob].MobExp :=
                Round(Self.DGMines1[i].MOBS.TMobS[CountMob].InitHP * 1.8);
              Self.DGKinary[i].MOBS.TMobS[CountMob].MobLevel :=
                MobFileStrings[7].ToInteger();
              Self.DGKinary[i].MOBS.TMobS[CountMob].Rotation :=
                MobFileStrings[6].ToInteger();
              Self.DGKinary[i].MOBS.TMobS[CountMob].MobType :=
                MobFileStrings[11].ToInteger();
              Self.DGKinary[i].MOBS.TMobS[CountMob].cntControl := 0;
              Self.DGKinary[i].MOBS.TMobS[CountMob].SpawnType :=
                MobFileStrings[16].ToInteger();
              Self.DGKinary[i].MOBS.TMobS[CountMob].DungeonDropIndex :=
                MobFileStrings[18].ToInteger();
              inc(CountMob);
              MobFileStrings.Clear;
            end;
            Logger.Write('[Server Mobs Init] Kinary ' + TDungeonDificultNames
              [Self.DGKinary[i].Dificult] + ' Mobs Info OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsPos)) then
            begin
              Logger.Write(PathMobsPos + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsPos);
            Reset(F);
            MobFileStrings := TStringList.Create;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              MobFileStrings.Clear;
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              for j := 0 to 44 do
              begin
                if (Self.DGKinary[i].MOBS.TMobS[j].IntName = 0) then
                  continue;
                if (Self.DGKinary[i].MOBS.TMobS[j].IntName = MobFileStrings[6]
                  .ToInteger()) then
                begin
                  CountMob := Self.DGKinary[i].MOBS.TMobS[j].cntControl;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob].index :=
                    MobFileStrings[0].ToInteger();
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob].HP :=
                    MobFileStrings[2].ToInteger();
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob].MP :=
                    Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob].HP;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob].InitPos.Create
                    (MobFileStrings[3].ToInteger(),
                    MobFileStrings[4].ToInteger());
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob].DestPos :=
                    Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob].InitPos;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .InitAttackRange := 20;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .DestAttackRange := 20;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Create(nil, Self.DGKinary[i].MOBS.TMobS[j].MobsP
                    [CountMob].index, Self.ChannelId);
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.IsActive := true;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob].Base.ClientId
                    := Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob].index;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Mobid := j;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.SecondIndex := CountMob;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.CurrentScore.Esquiva :=
                    MOB_ESQUIVA;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.CritRes := MOB_CRIT_RES;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.DuploRes := MOB_DUPLO_RES;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.Nation := Self.ChannelId + 1;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .LastMyAttack := now;
                  inc(Self.DGKinary[i].MOBS.TMobS[j].cntControl);
                  break;
                end
                else
                  continue;
              end;
            end;
            Logger.Write('[Server Mobs Init] Kinary ' + TDungeonDificultNames
              [Self.DGKinary[i].Dificult] + ' Mobs Position OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsDropNon)) then
            begin
              Logger.Write(PathMobsDropNon + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsDropNon);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGKinary[i].MobsDrop.SemCoroa[count2] :=
                StrToInt(LineMobFile);
              inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Kinary ' + TDungeonDificultNames
              [Self.DGKinary[i].Dificult] + ' Mobs Drops [Mobs sem Coroa] OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropPrata)) then
            begin
              Logger.Write(PathMobsDropPrata + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsDropPrata);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGKinary[i].MobsDrop.CoroaPrata[count2] :=
                StrToInt(LineMobFile);
              inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Kinary ' + TDungeonDificultNames
              [Self.DGKinary[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Prata] OK.', TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropDourada)) then
            begin
              Logger.Write(PathMobsDropDourada + ' não foi encontrado.',
                TLogType.Warnings);
              exit;
            end;
            AssignFile(F, PathMobsDropDourada);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGKinary[i].MobsDrop.CoroaDourada[count2] :=
                StrToInt(LineMobFile);
              inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Kinary ' + TDungeonDificultNames
              [Self.DGKinary[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Dourada] OK.', TLogType.ServerStatus);
            CloseFile(F);
          end;
        end;
    end;
    FileStrings.Clear;
    inc(Count);
  end;
  CloseFile(DataFile);
end;
procedure TServerSocket.AcceptConnection;
var
  ClientInfo: PSockAddr;
  Clid: Integer;
  FSock: Cardinal;
  Margv: Cardinal;
<<<<<<< HEAD
  Xargv: AnsiChar;
=======
>>>>>>> parent of a46c38b (30)
begin
  ClientInfo := nil;
  FSock := accept(Self.Sock, ClientInfo, nil);
  try
    if ((FSock <> INVALID_SOCKET) and not(Self.ServerHasClosed)) then
    begin
      Clid := TFunctions.FreeClientId(Self.ChannelId);
      if not(Clid = 0) then
      begin
        Margv := 1;
        if (ioctlsocket(FSock, FIONBIO, Margv) < 0) then
        begin
          Logger.Write
            ('Ocorreu um erro ao configurar o socket para Non-Blocking.',
            TLogType.Warnings);
          closesocket(FSock);
          FSock := INVALID_SOCKET;
          exit;
        end;
<<<<<<< HEAD
        Xargv := '1';
        if (setsockopt(FSock, IPPROTO_TCP, TCP_NODELAY, @Xargv, 1) <> 0) then
        begin
          Logger.Write
            ('Ocorreu um erro ao configurar o socket para TCP_NODELAY. ' +
              WSAGetLastError.ToString,
            TLogType.Warnings);
          closesocket(FSock);
          FSock := INVALID_SOCKET;
          exit;
        end;
        {Xargv := '0';
        if (setsockopt(FSock, SOL_SOCKET, SO_SNDBUF, @Xargv, 4) <> 0) then
        begin
          Logger.Write
            ('Ocorreu um erro ao configurar o socket para SO_SNDBUF. ' +
              WSAGetLastError.ToString,
            TLogType.Warnings);
          closesocket(FSock);
          FSock := INVALID_SOCKET;
          exit;
        end;
        Xargv := '0';
        if (setsockopt(FSock, SOL_SOCKET, SO_RCVBUF, @Xargv, 4) <> 0) then
        begin
          Logger.Write
            ('Ocorreu um erro ao configurar o socket para SO_SNDBUF. ' +
              WSAGetLastError.ToString,
            TLogType.Warnings);
          closesocket(FSock);
          FSock := INVALID_SOCKET;
          exit;
        end; }

=======
>>>>>>> parent of a46c38b (30)
        ZeroMemory(@Self.Players[Clid], sizeof(TPlayer));
        Self.Players[Clid].socket := FSock;
        Self.Players[Clid].Authenticated := False;
        Self.Players[Clid].ConnectionedTime := Now;
        Self.Players[Clid].Thread :=
          TPlayerThread.Create(Clid, Self.Players[Clid].socket, Self.ChannelId);
        { Self.PlayerThreads[Clid] := TPlayerThread.Create(Clid,
          Self.Players[Clid].socket, Self.ChannelId);
          Self.FPlayerThreads[Clid] := @Self.PlayerThreads[Clid]; }
      end;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('Error at AcceptConnection ' + E.Message + chr(13) + E.StackTrace, TLogType.Error);
      {if not(Self.ServerHasCLosed) then
      begin
        Shutdown(Self.Sock, SD_BOTH);
        closesocket(Sock);
        Self.StartSocket;
      end;}
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Player Functions'}
function TServerSocket.GetPlayer(const ClientId: WORD): PPlayer;
begin
  if((Self.Players[clientid].Base.ClientID > 0) and
    not(Self.Players[clientid].SocketClosed)) then
  begin
    Result := @Self.Players[ClientId];
  end
  else
  begin
    Result := nil;
  end;
end;
function TServerSocket.GetPlayer(const CharacterName: string): PPlayer;
var
  i: Integer;
begin
  Result := Nil;
  for i := 1 to MAX_CONNECTIONS do
  begin
    if (Self.Players[i].Character.Base.Name = '') then
      continue;
    if (string(Players[i].Character.Base.Name) = CharacterName) then
    begin
      Result := @Self.Players[i];
      break;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Disconnect Functions'}
procedure TServerSocket.DisconnectAll;
var
  i: WORD;
  cnt: WORD;
begin
  cnt := 0;
  for i := 1 to MAX_CONNECTIONS do
    if Self.Players[i].Base.IsActive then
    begin
      // Self.PlayerThreads[i].Term := true;
      // Self.Players[i].PlayerThreadActive := false;
      Self.Disconnect(Self.Players[i]);
      inc(cnt, 1);
    end;
  if (cnt > 0) then
    Logger.Write('[' + string(ServerList[ChannelId].Name) +
      ']: Foram desconectados ' + IntToStr(cnt) + ' jogadores.',
      TLogType.ConnectionsTraffic);
end;
procedure TServerSocket.Disconnect(ClientId: WORD);
begin
  if (ClientId = 0) then
    exit;
  if not(Players[ClientId].Base.IsActive) then
    exit;
  Self.Disconnect(Players[ClientId]);
end;
procedure TServerSocket.Disconnect(var Player: TPlayer);
var
  cid: WORD;
begin
  // if not(Player.Base.IsActive) then
  // exit;
  // if (Player.Status > WaitingLogin) then
  // begin
  if (Trim(String(Player.Account.Header.userName)) = '') then
    exit;
  if (Player.Base.ClientId = 0) then
    exit;
  //Player.SocketClosed := true;
  // end;
  cid := Player.Base.ClientId;
  if not(Player.xdisconnected) then
  begin
    Player.Destroy;
    Logger.Write('[' + string(ServerList[ChannelId].Name) + ']: O jogador ' +
      string(Player.Account.Header.userName) + ' [ClientId: ' +
      IntToStr(cid) + '] se desconectou.', ConnectionsTraffic);
  end;
  Player.Party := nil;
  //ZeroMemory(@Player, sizeof(TPlayer));
end;
procedure TServerSocket.Disconnect(userName: string);
var
  i: Integer;
begin
  for i := 1 to (MAX_CONNECTIONS) do
  begin
    if not(Players[i].Base.IsActive) then
      continue;
    if (string(Players[i].Account.Header.userName) = userName) then
    begin
      Players[i].SocketClosed := True;
      //Self.Disconnect(Players[i]);
      break;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Send Functions'}
procedure TServerSocket.SendPacketTo(ClientId: Integer; var Packet; Size: WORD;
  Encrypt: Boolean);
begin
  if Self.Players[ClientId].Base.IsActive then
    Self.Players[ClientId].SendPacket(Packet, Size, Encrypt);
end;
procedure TServerSocket.SendSignalTo(ClientId: Integer; pIndex, opCode: WORD);
var
  Signal: TPacketHeader;
begin
  if (ClientId > MAX_CONNECTIONS) or not(Players[ClientId].Base.IsActive) then
    exit;
  ZeroMemory(@Signal, sizeof(TPacketHeader));
  Signal.Size := 12;
  Signal.index := pIndex;
  Signal.Code := opCode;
  Players[ClientId].SendPacket(Signal, Signal.Size, true);
end;
procedure TServerSocket.SendToVisible(var Base: TBaseMob; var Packet;
  Size: WORD);
var
  i: Integer;
begin
  for i in Base.VisiblePlayers do
  begin
    if Self.Players[i].Status <> Playing then
      continue;
    if(Self.Players[i].SocketClosed) then
      Continue;

    Self.SendPacketTo(i, Packet, Size);
  end;
end;
procedure TServerSocket.SendToAll(var Packet; Size: WORD);
var
  i: Integer;
begin
  for i := 1 to MAX_CONNECTIONS do
  begin
    if Self.Players[i].Status = Playing then
    begin
      if(Self.Players[i].SocketClosed) then
      Continue;
      Self.Players[i].SendPacket(Packet, Size);
    end
    else
      continue;
  end;
end;
procedure TServerSocket.SendServerMsg(Mensg: AnsiString; MsgType: Integer = 16;
  Null: Integer = 0; Type2: Integer = 0; SendToSelf: Boolean = true;
  MyClientID: WORD = 0);
var
  i: Integer;
begin
  for i := 1 to MAX_CONNECTIONS do
  begin
    if Self.Players[i].Status <> Playing then
      continue;
    if(Self.Players[i].SocketClosed) then
      Continue;
    if (SendToSelf = false) then
    begin
      if (i = MyClientID) then
        continue;
    end;
    Self.Players[i].SendClientMessage(Mensg, MsgType, Null, Type2);
  end;
end;
procedure TServerSocket.SendServerMsgForNation(Mensg: AnsiString; aNation: BYTE;
  MsgType: Integer = $10; Null: Integer = 0; Type2: Integer = 0;
  SendToSelf: Boolean = true; MyClientID: WORD = 0);
var
  i: Integer;
begin
  for i := 1 to MAX_CONNECTIONS do
  begin
    if Self.Players[i].Status <> Playing then
      continue;
    if(Self.Players[i].SocketClosed) then
      Continue;
    if (SendToSelf = false) then
    begin
      if (i = MyClientID) then
        continue;
    end;
    if (Self.Players[i].Base.Character.Nation = aNation) then
      Self.Players[i].SendClientMessage(Mensg, MsgType, Null, Type2);
  end;
end;
{$ENDREGION}
{$REGION 'PacketControl'}
function TServerSocket.PacketControl(var Player: TPlayer; var Size: Integer;
  var Buffer: array of BYTE; initialOffset: Integer): Boolean;
var
  Header: TPacketHeader;
  Log: String;
  i: Integer;
begin
  // Result := false;
  // inc(Player.RecvPackets, 1);
  ZeroMemory(@Header, sizeof(TPacketHeader));
  {if (initialOffset <> 0) then
  begin
    Move(Buffer[initialOffset], Buffer, Size);
    Player.RecvPackets := 1;
  end;}
  Move(Buffer, Header, sizeof(TPacketHeader));
  Header.index := Player.Base.ClientId;
  Result := true;
  case Header.Code of
    //0:
     // begin
      //end;
     $320:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.UseSkill(Player, Buffer);
      except
        on E: Exception do
          begin
            Logger.Write('PacketControl: UseSkill error. msg[' + E.Message + ' : '
              + E.GetBaseException.Message + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
              '.', TLogType.Error);
            //Player.SocketClosed := True;
<<<<<<< HEAD
=======

>>>>>>> parent of a46c38b (30)
          end;
      end;
     $302:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.AttackTarget(Player, Buffer);
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: AttackTarget error. msg[' + E.Message +
            ' : ' + E.GetBaseException.Message + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
          //Player.SocketClosed := True;
        end;
      end;
    $301:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.MovementCommand(Player, Buffer);
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: MovementCommand error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
          Player.SocketClosed := True;
<<<<<<< HEAD
          abort;
=======
>>>>>>> parent of a46c38b (30)
        end;
      end;
    $70F:
      try
        if (Player.IsInstantiated) then
        begin
          TPacketHandlers.MoveItem(Player, Buffer);
          {if not(TPacketHandlers.MoveItem(Player, Buffer)) then
          begin
            for I := 0 to 63 do
            begin
              Player.Base.SendRefreshItemSlot(INV_TYPE, i, Player.Base.Character.Inventory[i], False);
            end;

            for I := 0 to 15 do
            begin
              Player.Base.SendRefreshItemSlot(EQUIP_TYPE, i, Player.Base.Character.Equip[i], False);
            end;
          end;}
        end;
      except
        on E: Exception do
          Logger.Write('PacketControl: MoveItem error. msg[' + E.Message + ' : '
            + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;

    $31D:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.UseItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UseItem error. msg[' + E.Message + ' : '
            + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $21B:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.UseBuffItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UseBuffItem error. msg[' + E.Message +
            ' : ' +chr(13) + E.StackTrace+ '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $305:
      try
        TPacketHandlers.UpdateRotation(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UpdateRotation error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $30F:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.OpenNPC(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: OpenNPC error. msg[' + E.Message + ' : '
            + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $31E:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.ChangeItemBar(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: ChangeItemBar error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $668:
      try
        Player.SendClientMessage('Essa função foi temporariamente desativada.');
        //Player.BackToCharList;
      except
        on E: Exception do
          Logger.Write('PacketControl: BackToCharList error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F0B:
      try
        if (Player.LoggedByOtherChannel) then
        begin
          Player.LoggedByOtherChannel := false;
        end
        else
          Player.SendToWorldSends;
      except
        on E: Exception do
          Logger.Write('PacketControl: SendToWorldSends error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F86:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.SendClientSay(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: SendClientSay error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $20A:
      try
        Player.SendPlayerCash;
      except
        on E: Exception do
          Logger.Write('PacketControl: SendPlayerCash error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $327:
      try
        TPacketHandlers.CancelSkillLaunching(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CancelSkillLaunching error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $202:
      try
        TPacketHandlers.RequestServerTime(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestServerTime error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $207:
      try
        TPacketHandlers.GiveLeaderRaid(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GiveLeaderRaid error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $209:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.BuyItemCash(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: BuyItemCash error. msg[' + E.Message +
            ' : ' +chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $213:
      try
        TPacketHandlers.GetStatusPoint(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GetStatusPoint error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;

    $21A:
      try
        TPacketHandlers.RenoveItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RenoveItem error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $22A:
      try
        TPacketHandlers.RenoveItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RenoveItem error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $224:
      try
        TPacketHandlers.UnsealItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UnsealItem error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $22C:
      try
        if not(TPacketHandlers.RequestCharInfo(Player, Buffer)) then
        begin
          Player.SendClientMessage('Alvo não está logado.');
        end;
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: RequestCharInfo error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
          Player.SocketClosed := True;
        end;
      end;
    $22D:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.SendItemChat(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: SendItemChat error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $303:
      try
        TPacketHandlers.RevivePlayer(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RevivePlayer error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $304:
      try
        TPacketHandlers.UpdateAction(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CharacterActionSend(0x304) error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    { $306:
      try
        if(Player.IsInstantiated) then
          TPacketHandlers.UpdateMobInfo(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UpdateMobInfo(0x306) error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end; }
    $307:
      try
        TPacketHandlers.PKMode(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: PKMode error. msg[' + E.Message + ' : ' +
            chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $313:
      try
        TPacketHandlers.BuyNPCItens(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: BuyNPCItens error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $314:
      try
        TPacketHandlers.SellNPCItens(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: SellNPCItens error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $315:
      try
        TPacketHandlers.TradeRequest(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: TradeRequest error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $316:
      try
        TPacketHandlers.TradeResponse(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: TradeResponse error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $317:
      try
        TPacketHandlers.TradeRefresh(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: TradeRefresh error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $318:
      try
        TPacketHandlers.TradeCancel(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: TradeCancel error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $319:
      try
        TPacketHandlers.CreatePersonalShop(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CreatePersonalShop error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $31A:
      try
        TPacketHandlers.OpenPersonalShop(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: OpenPersonalShop error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $31B:
      try
        TPacketHandlers.BuyPersonalShopItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: BuyPersonalShopItem error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $31C:
      try
        TPacketHandlers.LearnSkill(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: LearnSkill error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $322:
      try
        TPacketHandlers.SendParty(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: SendParty error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $323:
      try
        TPacketHandlers.AcceptParty(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: AcceptParty error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $324:
      try
        TPacketHandlers.KickParty(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: KickParty error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $325:
      try
        TPacketHandlers.DestroyParty(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: DestroyParty error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $326:
      try
        TPacketHandlers.PartyAlocateConfig(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: PartyAlocateConfig error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $329:
      try
        TPacketHandlers.RemoveBuff(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RemoveBuff error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $32A:
      try
        TPacketHandlers.ResetSkills(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: ResetSkills error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $32B:
      try
        TPacketHandlers.MakeItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: MakeItem error. msg[' + E.Message + ' : '
            + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $32C:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.DeleteItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: DeleteItem error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $32D:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.ChangeItemAttribute(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: ChangeItemAttribute error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $32F:
      try
        TPacketHandlers.AbandonQuest(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: AbandonQuest error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $332:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.AgroupItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: AgroupItem error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $333:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.UngroupItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UngroupItem error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $334:
      try
        TPacketHandlers.RequestEnterDungeon(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestEnterDungeon error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $336:
      try
        TPacketHandlers.CollectMapItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestEnterDungeon error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $338:
      try
        TPacketHandlers.UpdateMemberPosition(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UpdateMemberPosition error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $33A:
      try
        TPacketHandlers.CancelCollectMapItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestEnterDungeon error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $340:
      try
        TPacketHandlers.RepairItens(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CreateGuild error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $341:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.CreateGuild(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CreateGuild error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $342:
      try
        TPacketHandlers.SendRaid(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: SendRaid error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $343:
      try
        TPacketHandlers.AcceptRaid(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: AcceptRaid error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $344:
       try
         TPacketHandlers.ExitRaid(Player, Buffer);
       except
         on E: Exception do
          Logger.Write('PacketControl: ExitRaid error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
       end;
    $348:
      try
        TPacketHandlers.CloseNPCOption(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CloseNPCOption error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $34A:
      try
        TPacketHandlers.TeleportSetPosition(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: TeleportSetPosition error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $34B:
      try
        TPacketHandlers.GiveLeaderParty(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GiveLeaderParty error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $355:
      try
        TPacketHandlers.DungeonLobbyConfirm(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: DungeonLobbyConfirm error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $356:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.SendGift(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: SendGift error. msg[' + E.Message + ' : '
            + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $359:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.ReceiveEventItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: ReceiveEventItem error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $361:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.UpdateActiveTitle(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UpdateActiveTitle error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $372:
      try
        TPacketHandlers.AddFriendRequest(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: AddFriendRequest error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $38F:
      try
        TPacketHandlers.AddSelfParty(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: AddSelfParty error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $395:
      try
        TPacketHandlers.SendRequestDuel(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: SendRequestDuel error. msg[' + E.Message
            + ' : ' +chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $396:
      try
        TPacketHandlers.DuelResponse(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: DuelResponse error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    { $397:
      try
        TPacketHandlers.ChangeChannel2(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: ChangeChannel2 error. msg[' + E.Message +
            ' : ' + E.GetBaseException.Message + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;}
    $673:
      try
        TPacketHandlers.AddFriendResponse(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: AddFriendResponse error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $619:
      try
        TPacketHandlers.ChangeMasterGuild(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: AddFriendResponse error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $67D:
      try
        TPacketHandlers.InviteToGuildAccept(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: InviteToGuildAccept error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $685:
      try
        TPacketHandlers.CheckLogin(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CheckLogin error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $603:
      try
        TPacketHandlers.RequestDeleteChar(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestDeleteChar error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $B52:
      try
        TPacketHandlers.RequestUpdateReliquare(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestUpdateReliquare error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $E3A:
      try
        TPacketHandlers.UpdateNationTaxes(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UpdateNationTaxes error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $E51:
      try
        TPacketHandlers.MoveItemToReliquare(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: MoveItemToReliquare error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;


    $F02:
      try
        TPacketHandlers.NumericToken(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: NumericToken error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F05:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.ChangeChannel(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: ChangeChannel error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F06:
      try
        TPacketHandlers.LoginIntoChannel(Player, Buffer);
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: LoginIntoChannel error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
          Player.SocketClosed := True;
          abort;
        end;
      end;
    $F1C:
      try
        TPacketHandlers.ExitGuild(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: ExitGuild error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F1D:
      try
        TPacketHandlers.ChangeGuildMemberRank(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: ChangeGuildMemberRank error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F12:
      try
        TPacketHandlers.RequestGuildToAlly(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestGuildAlliance error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F20:
      try
        TPacketHandlers.UpdateGuildNotices(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UpdateGuildNotices error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F21:
      try
        TPacketHandlers.UpdateGuildSite(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UpdateGuildSite error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F22:
      try
        TPacketHandlers.UpdateGuildRanksConfig(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UpdateGuildRanksConfig error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F26:
      try
        TPacketHandlers.SendFriendSay(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: SendFriendSay error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F2D:
      try
        TPacketHandlers.KickMemberOfGuild(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: KickMemberOfGuild error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F2F:
      try
        TPacketHandlers.CloseGuildChest(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CloseGuildChest error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F27:
      try
        TPacketHandlers.OpenFriendWindow(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: OpenFriendWindow error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F30:
      try
        TPacketHandlers.CloseFriendWindow(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CloseFriendWindow error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F34:
      try
        TPacketHandlers.UpdateNationGold(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UpdateNationGold error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F59:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.ChangeGold(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: ChangeGold error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F74:
      try
        TPacketHandlers.DeleteFriend(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: DeleteFriend error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F7B:
      try
        TPacketHandlers.InviteToGuildRequest(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: InviteToGuildRequest error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F7E:
      try
        TPacketHandlers.InviteToGuildDeny(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: InviteToGuildDeny error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3E01:
      try
        TPacketHandlers.DeleteChar(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: DeleteChar error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3E04:
      try
        TPacketHandlers.CreateCharacter(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CreateCharacter error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3E02:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.RenamePran(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RenamePran error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace+ '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3F15:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.sendCharacterMail(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: SendCharacterMail error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3F16:
      try
        TPacketHandlers.checkSendMailRequirements(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: checkSendMailRequirements error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3F17:
      try
        TEntityMail.sendMailList(Player);
      except
        on E: Exception do
          Logger.Write('PacketControl: sendMailList error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3F18:
      try
        TPacketHandlers.OpenMail(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: OpenMail error. msg[' + E.Message + ' : '
            + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3F1A:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.withdrawMailItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: withdrawMailItem error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3F0D:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.RequestAuctionItems(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestAuctionItems error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3F0B:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.RequestRegisterItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestRegisterItem error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3F11:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.RequestOwnAuctionItems(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestOwnAuctionItems error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3F10:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.RequestAuctionOfferCancel(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestAuctionOfferCancel error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3F0C:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.RequestAuctionOfferBuy(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestAuctionOfferBuy error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;

    $F93A:
      try
        TPacketHandlers.RequestServerPing(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestServerPing error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;

    $3E05:
      try
        TPacketHandlers.ReclaimCoupom(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: ReclaimCoupom error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
{$REGION 'Packets from GM TOOL'}
    $3202:
      try
        TPacketHandlers.CheckGMLogin(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CheckGMLogin error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3204:
      try
        TPacketHandlers.GMPlayerMove(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMPlayerMove error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3205:
      try
        TPacketHandlers.GMSendChat(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMSendChat error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3206:
      try
        TPacketHandlers.GMGoldManagment(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMGoldManagment error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3207:
      try
        TPacketHandlers.GMCashManagment(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMCashManagment error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3208:
      try
        TPacketHandlers.GMLevelManagment(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMLevelManagment error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3209:
      try
        TPacketHandlers.GMBuffsManagment(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMBuffsManagment error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3210:
      try
        TPacketHandlers.GMDisconnect(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMDisconnect error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3211:
      try
        TPacketHandlers.GMBan(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMBan error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3212:
      try
        TPacketHandlers.GMEventItem(Player, Buffer);
      except
         on E: Exception do
          Logger.Write('PacketControl: GMEventItem error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3299:
      try
        TPacketHandlers.GMEventItemForAll(Player, Buffer);
      except
         on E: Exception do
          Logger.Write('PacketControl: GMEventItemForAll error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3214:
      try
        TPacketHandlers.GMRequestServerInformation(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMRequestServerInformation error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3219:
      try
        TPacketHandlers.GMSendSpawnMob(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMSendSpawnMob error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;

    $3221:
      try
        TPacketHandlers.GMRequestPlayerAccount(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMRequestPlayerAccount error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;

    $3225:
      try
       TPacketHandlers.GMReceiveAccBackup(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMReceiveAccBackup error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;

    $3229:
      try
        TPacketHandlers.GMRequestCommandsAutoriz(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMRequestCommandsAutoriz error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;

    $322D:
      try
        TPacketHandlers.GMRequestGMUsernames(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMRequestGMUsernames error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
<<<<<<< HEAD

    $3234:
      try
        TPacketHandlers.GMReproveCommand(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMReproveCommand error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;

    $3236:
      try
        TPacketHandlers.GMApproveCommand(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMApproveCommand error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;

    $3238:
      try
        TPacketHandlers.GMSendAddEffect(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMSendAddEffect error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);

      end;

    $323A:
      try
        TPacketHandlers.GMRequestCreateCoupom(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMRequestCreateCoupom error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);

      end;

    $3240:
      try
        TPacketHandlers.GMRequestComprovantSearchID(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMRequestComprovantSearchID error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);

      end;

    $3242:
      try
        TPacketHandlers.GMRequestComprovantSearchName(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMRequestComprovantSearchName error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);

      end;

    $3246:
      try
        TPacketHandlers.GMRequestCreateComprovant(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMRequestCreateComprovant error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);

      end;

    $3248:
      try
        TPacketHandlers.GMRequestComprovantValidate(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMRequestComprovantValidate error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);

      end;

    $324A:
      try
        TPacketHandlers.GMRequestDeletePrans(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMRequestDeletePrans error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);

      end;
=======
>>>>>>> parent of 2438a94 (modificacoes 05/12)
{$ENDREGION}
{$REGION 'Pacotes Aika Other Attributes'}
    $23FE:
      try
        TPacketHandlers.RequestAllAttributes(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestAllAttributes error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $23FB:
      try
        TPacketHandlers.RequestAllAttributesTarget(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestAllAttributesTarget error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
{$ENDREGION}
  else
    {begin
      Log := '[' + string(ServerList[Player.ChannelIndex].Name) +
        ']: Recv - Code: ' + Format('0x%x', [Header.Code]) + ' / Size: ' +
        IntToStr(Size) + ' / ClientId: ' + IntToStr(Header.index);
      Logger.Write(Log, TLogType.Packets);
      //LogPackets := true;
    end; }
  end;

    {if (LogPackets) then
    begin
      if not(DirectoryExists(GetCurrentDir + '\Packets')) then
        ForceDirectories(GetCurrentDir + '\Packets');
      TFunctions.StrToFile(TFunctions.ByteArrToString(Buffer, Header.Size),
       GetCurrentDir + '\Packets\' + TFunctions.DateTimeToUNIXTimeFAST(now)
        .ToString + '_0x' + Header.Code.ToHexString + '.txt');
     LogPackets := false;
    end;}
  // end;
end;
{$ENDREGION}
{$REGION 'ServerTime'}
function TServerSocket.GetResetTime;
var
  Tomorrow: TDateTime;
begin
  Tomorrow := IncDay(now, 1);
  Result := DateTimeToUnix(IncHour(EncodeDate(YearOf(now), MonthOf(now),
    DayOf(Tomorrow)), 6));
end;
function TServerSocket.CheckResetTime;
begin
  Result := false;
  if (now > Self.ResetTime) then
  begin
    Result := true;
  end;
end;
function TServerSocket.GetEndDayTime;
var
  Tomorrow: TDateTime;
begin
  Tomorrow := IncDay(now, 1);
  Result := DateTimeToUnix(EncodeDate(YearOf(now), MonthOf(now),
    DayOf(Tomorrow)));
end;
{$ENDREGION}
{$REGION 'Players'}
function TServerSocket.GetPlayerByName(Name: string;
  out Player: PPlayer): Boolean;
var
  i: Integer;
begin
  Result := false;
  for i := Low(Players) to High(Players) do
  begin
    if not(Self.Players[i].Base.IsActive) then
      continue;
    if (string(Self.Players[i].Character.Base.Name) = Name) then
    begin
      Player := @Self.Players[i];
      Result := true;
      break;
    end;
  end;
end;
function TServerSocket.GetPlayerByName(Name: string): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to MAX_CONNECTIONS do
  begin
    if not(Self.Players[i].Base.IsActive) then
      continue;
    if (string(Self.Players[i].Character.Base.Name) = Name) then
    begin
      Result := i;
      break;
    end;
  end;
end;
function TServerSocket.GetPlayerByUsername(userName: string): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to MAX_CONNECTIONS do
  begin
    if not(Self.Players[i].Base.IsActive) then
      continue;
    if (string(Self.Players[i].Account.Header.userName) = userName) then
    begin
      Result := i;
      break;
    end;
  end;
end;
function TServerSocket.GetPlayerByUsernameAux(userName: string; CidAux: WORD): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to MAX_CONNECTIONS do
  begin
    if not(Self.Players[i].Base.IsActive) then
      continue;
    if (string(Self.Players[i].Account.Header.userName) = userName) then
    begin
      if(i = CidAux) then
        Continue;
      Result := i;
      break;
    end;
  end;
end;
function TServerSocket.GetPlayerByCharIndex(CharIndex: DWORD;
  out Player: PPlayer): Boolean;
var
  i: WORD;
begin
  Result := false;
  for i := Low(Players) to High(Players) do
  begin
    if not(Self.Players[i].Base.IsActive) then
      continue;
    if (Self.Players[i].Character.Base.CharIndex = CharIndex) then
    begin
      Player := @Self.Players[i];
      Result := true;
      break;
    end;
  end;
end;
function TServerSocket.GetPlayerByCharIndex(CharIndex: DWORD;
  out Player: TPlayer): Boolean;
var
  i: WORD;
begin
  Result := false;
  for i := Low(Players) to High(Players) do
  begin
    if not(Self.Players[i].Base.IsActive) then
      continue;
    if (Self.Players[i].Character.Base.CharIndex = CharIndex) then
    begin
      Player := Self.Players[i];
      Result := true;
      break;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'guild gets'}
function TServerSocket.GetGuildByIndex(GuildIndex: Integer): String;
var
  i: Integer;
begin
  Result := '';
  if (GuildIndex = 0) then
  begin
    exit;
  end;
  for i := Low(Guilds) to High(Guilds) do
  begin
    if (Guilds[i].index = DWORD(GuildIndex)) then
    begin
      Result := String(Guilds[i].Name);
      break;
    end;
  end;
end;
function TServerSocket.GetGuildByName(GuildName: String): Integer;
var
  i: Integer;
begin
  Result := 0;
  if (GuildName = '') then
    exit;
  for i := Low(Guilds) to High(Guilds) do
  begin
    if (String(Guilds[i].Name) = GuildName) then
    begin
      Result := Guilds[i].index;
      break;
    end;
  end;
end;
function TServerSocket.GetGuildSlotByID(GuildIndex: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  if (GuildIndex = 0) then
    exit;
  for i := Low(Guilds) to High(Guilds) do
  begin
    if (Guilds[i].index = (GuildIndex)) then
    begin
      Result := Guilds[i].Slot;
      break;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Prans'}
function TServerSocket.GetFreePranClientID(): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := Low(Self.Prans) to High(Self.Prans) do
  begin
    if (Self.Prans[i] = 0) then
    begin
      Result := i;
      break;
    end;
  end;
end;

function TServerSocket.GetFreePetClientID(): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := Low(Self.PETS) to High(Self.PETS) do
  begin
    if (Self.PETS[i].IntName = 0) then
    begin
      Result := i;
      break;
    end;
  end;

end;
{$ENDREGION}
{$REGION 'Temples'}
function TServerSocket.GetFreeTempleSpace(): TSpaceTemple;
var
  i, j: Integer;
begin
  Result.DevirId := 255;
  for i := 0 to 4 do
  begin
    for j := 0 to 4 do
    begin
      if (Self.Devires[i].Slots[j].IsAble) then
      begin
        if (Self.Devires[i].Slots[j].ItemID = 0) then
        begin
          Result.DevirId := i;
          Result.SlotID := j;
          break;
        end
        else
          continue;
      end
      else
        continue;
    end;
  end;
end;
function TServerSocket.GetFreeTempleSpaceByIndex(id: Integer): TSpaceTemple;
var
  j: Integer;
begin
  Result.DevirId := 255;
  for j := 0 to 4 do
  begin
    if (Self.Devires[id].Slots[j].IsAble) then
    begin
      if (Self.Devires[id].Slots[j].ItemID = 0) then
      begin
        Result.DevirId := id;
        Result.SlotID := j;
        break;
      end
      else
        continue;
    end
    else
      continue;
  end;
end;
procedure TServerSocket.SaveTemplesDB(Player: PPlayer);
var
  i, j, cnt: Integer;
  FieldNameItemID, FieldNameName, FieldTimeCap, FieldIsAble: String;
  SQLComp: TQuery;
begin
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SaveTemplesDB]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveTemplesDB]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  for i := 0 to 4 do
  begin
    for j := 0 to 4 do
    begin
      FieldNameItemID := 'slot' + IntToStr(j + 1) + '_itemid';
      FieldNameName := 'slot' + IntToStr(j + 1) + '_name';
      FieldTimeCap := 'slot' + IntToStr(j + 1) + '_timecap';
      FieldIsAble := 'slot' + IntToStr(j + 1) + '_able';
      SQLComp.SetQuery(Format('UPDATE devires SET ' + FieldNameItemID +
        '=%d, ' + FieldNameName + '=%s, ' + FieldTimeCap + '=%s, ' + FieldIsAble
        + '=%d WHERE devir_id=%d', [Self.Devires[i].Slots[j].ItemID,
        QuotedStr(String(Self.Devires[i].Slots[j].NameCapped)),
        QuotedStr(DateTimeToStr(Self.Devires[i].Slots[j].TimeCapped)), Self.Devires[i].Slots[j].IsAble.ToInteger,
        Self.Devires[i].DevirId]));
      SQLComp.Run(False);
    end;
  end;
  SQLComp.Destroy;
end;
procedure TServerSocket.UpdateReliquaresForAll();
var
  i: WORD;
begin
  for i := 1 to MAX_CONNECTIONS do
  begin
    if (Players[i].Status >= Playing) then
    begin
      Players[i].SendReliquesToPlayer;
      Players[i].Base.GetCurrentScore;
      Players[i].Base.SendStatus;
      Players[i].Base.SendRefreshPoint;
      Players[i].Base.SendCurrentHPMP();
    end;
  end;
end;
procedure TServerSocket.UpdateReliquareInfosForAll();
var
  i: WORD;
begin
  for i := 1 to MAX_CONNECTIONS do
  begin
    if (Players[i].Status >= Playing) then
    begin
      Players[i].SendUpdateReliquareInformation(Self.ChannelId);
    end;
  end;
end;
procedure TServerSocket.UpdateReliquareEffects();
var
  i, j: Integer;
begin
  ZeroMemory(@Self.ReliqEffect, sizeof(Self.ReliqEffect));
  for i := 0 to 4 do
  begin
    for j := 0 to 4 do
    begin
      if (Self.Devires[i].Slots[j].ItemID <> 0) then
      begin
        Self.ReliqEffect[ItemList[Self.Devires[i].Slots[j].ItemID].EF[0]] :=
          Self.ReliqEffect[ItemList[Self.Devires[i].Slots[j].ItemID].EF[0]] +
          ItemList[Self.Devires[i].Slots[j].ItemID].EFV[0];
        if(Self.ReliqEffect[ItemList[Self.Devires[i].Slots[j].ItemID].EF[0]] >= 20) then
        begin
          Self.ReliqEffect[ItemList[Self.Devires[i].Slots[j].ItemID].EF[0]] := 50;
        end
        else if(Self.ReliqEffect[ItemList[Self.Devires[i].Slots[j].ItemID].EF[0]] <= 0) then
        begin
          Self.ReliqEffect[ItemList[Self.Devires[i].Slots[j].ItemID].EF[0]] := 0;
        end;
      end;
    end;
  end;
end;
{ Servers[Player.ChannelIndex].ReliqEffect[
  ItemList[Count].EF[0]] := Servers[Player.ChannelIndex].ReliqEffect[
  ItemList[Count].EF[0]] + ItemList[Count].EFV[0]; }
function TServerSocket.CanOpenTempleNow(DevirId: BYTE): Boolean;
begin
end;
function TServerSocket.OpenDevir(DevId: Integer; TempID: Integer;
  WhoKilledLast: Integer): Boolean;
var
  PacketDevirSpawn: TSendCreateMobPacket;
  PacketDevirMobsSpawn: TSpawnMobPacket;
  i, rand, SecureId: Integer;
begin
  Result := false;
 {
  ZeroMemory(@PacketDevirMobsSpawn, sizeof(TSpawnMobPacket));
  PacketDevirMobsSpawn.Header.Size := sizeof(TSpawnMobPacket);
  PacketDevirMobsSpawn.Header.index := 3370 + DevId;
  PacketDevirMobsSpawn.Header.Code := $35E;
  PacketDevirMobsSpawn.Equip[0] := 305; // totem de proteção
  Randomize;
  rand := Random(7);
  PacketDevirMobsSpawn.Position := Self.Players[WhoKilledLast].Base.Neighbors
    [rand].pos;
  PacketDevirMobsSpawn.MaxHP := 100000;
  PacketDevirMobsSpawn.CurHP := PacketDevirMobsSpawn.MaxHP;
  PacketDevirMobsSpawn.MaxMP := PacketDevirMobsSpawn.MaxHP;
  PacketDevirMobsSpawn.CurMP := PacketDevirMobsSpawn.MaxHP;
  PacketDevirMobsSpawn.Level := 95;
  PacketDevirMobsSpawn.IsService := true;
  PacketDevirMobsSpawn.Effects[0] := $35;
  PacketDevirMobsSpawn.Altura := 10;
  PacketDevirMobsSpawn.Tronco := 119;
  PacketDevirMobsSpawn.Perna := 119;
  PacketDevirMobsSpawn.Corpo := 20;
  PacketDevirMobsSpawn.MobType := 4;
  PacketDevirMobsSpawn.MobName := StrToInt('942');
  SecureId := Self.GetEmptySecureArea();
  if (SecureId = 255) then
  begin
    Self.SendServerMsg
      ('Totem de segurança falhou. Contate a administração. TServerSocket.OpenDevir:Boolean');
    exit;
  end;
  Self.SecureAreas[SecureId].SecureClientiD :=
    PacketDevirMobsSpawn.Header.index;
  Self.SecureAreas[SecureId].IsActive := true;
  Self.SecureAreas[SecureId].SecureType := SECURE_DEVIR_TYPE;
  Self.SecureAreas[SecureId].SecureDevir := true;
  Self.SecureAreas[SecureId].DevirId := DevId;
  Self.SecureAreas[SecureId].TempID := TempID;
  Self.SecureAreas[SecureId].Position := PacketDevirMobsSpawn.Position;
  Self.SecureAreas[SecureId].TimeInit := now;
  Self.SecureAreas[SecureId].TotemFace := 339;
  Self.SecureAreas[SecureId].Effect := $35;
  Move(Self.Players[WhoKilledLast].Base.Character.Name,
    Self.SecureAreas[SecureId].WhoInitiated[0], 16);
  for i := 1 to MAX_CONNECTIONS do
  begin
    if not(Self.Players[i].Status >= Playing) then
      continue;
    if (Self.SecureAreas[SecureId].Position.InRange(Self.Players[i]
      .Base.PlayerCharacter.LastPos, 25)) then
    begin
      Self.Players[i].SendPacket(PacketDevirMobsSpawn,
        PacketDevirMobsSpawn.Header.Size);
      if not(Self.Players[i].Base.VisibleNPCs.Contains(Self.SecureAreas
        [SecureId].SecureClientiD)) then
        Self.Players[i].Base.VisibleNPCs.Add
          (Self.SecureAreas[SecureId].SecureClientiD);
    end;
  end; }
  Self.Players[WhoKilledLast].SendDevirChange(TempID, $1D);
  for I in Self.Players[WhoKilledLast].Base.VisiblePlayers do
  begin
    Self.Players[i].SendDevirChange(TempID, $1D);
  end;

  Self.Devires[DevId].CollectedReliquare := False;
  Self.Devires[DevId].OpenedThread := TDevirOpennedThread.Create(1000,
    Self.ChannelId, DevId, TempID, SecureId);
end;
function TServerSocket.CloseDevir(DevId: Integer; TempID: Integer;
  WhoGetReliq: Integer): Boolean;
var
  GuardsIds, StonesIds: TIdsArray;
  i: Integer;
begin
  GuardsIds := Self.GetTheGuardsFromDevir(DevId);
  StonesIds := Self.GetTheStonesFromDevir(DevId);
  for I := 0 to 2 do
  begin
    Self.DevirGuards[GuardsIds[i]].DeadTime := StrToDateTime('30/12/1899');
    Self.DevirStones[StonesIds[i]].DeadTime := StrToDateTime('30/12/1899');
    Self.DevirStones[StonesIds[i]].Base.IsDead := False;
    Self.DevirStones[StonesIds[i]].PlayerChar.Base.CurrentScore.CurHP :=
     Self.DevirStones[StonesIds[i]].PlayerChar.Base.CurrentScore.MaxHp;
  end;
  Self.Devires[DevId].OpenTime := StrToDateTime('30/12/1899');
  Self.Devires[DevId].IsOpen := False;
  Self.Devires[DevId].StonesDied := 0;
  Self.Devires[DevId].GuardsDied := 0;
  Self.Devires[DevId].CollectedReliquare := False;

  Self.Players[WhoGetReliq].SendDevirChange(TempID, $10);
  for I in Self.Players[WhoGetReliq].Base.VisiblePlayers do
  begin
    Self.Players[i].SendDevirChange(TempID, $10);
  end;
end;
function TServerSocket.GetTheStonesFromDevir(DevId: Integer): TIdsArray;
begin
  case DevId of
    0:
    begin
      Result[0] := 3340;
      Result[1] := 3345;
      Result[2] := 3350;
    end;
    1:
    begin
      Result[0] := 3341;
      Result[1] := 3346;
      Result[2] := 3351;
    end;
    2:
    begin
      Result[0] := 3342;
      Result[1] := 3347;
      Result[2] := 3352;
    end;
    3:
    begin
      Result[0] := 3343;
      Result[1] := 3348;
      Result[2] := 3353;
    end;
    4:
    begin
      Result[0] := 3344;
      Result[1] := 3349;
      Result[2] := 3354;
    end;
  end;
end;
function TServerSocket.GetTheGuardsFromDevir(DevId: Integer): TIdsArray;
begin
  case DevId of
    0:
    begin
      Result[0] := 3355;
      Result[1] := 3360;
      Result[2] := 3365;
    end;
    1:
    begin
      Result[0] := 3356;
      Result[1] := 3361;
      Result[2] := 3366;
    end;
    2:
    begin
      Result[0] := 3357;
      Result[1] := 3362;
      Result[2] := 3367;
    end;
    3:
    begin
      Result[0] := 3358;
      Result[1] := 3363;
      Result[2] := 3368;
    end;
    4:
    begin
      Result[0] := 3359;
      Result[1] := 3364;
      Result[2] := 3369;
    end;
  end;
end;
function TServerSocket.GetEmptySecureArea(): BYTE;
var
  i: Integer;
begin
  Result := 255;
  for i := 0 to 9 do
  begin
    //if (Self.SecureAreas[i].IsActive = false) then
    //begin
    //  Result := i;
   //   break;
   // end;
  end;
end;
function TServerSocket.RemoveSecureArea(AreaSlot: BYTE): Boolean;
begin
end;
function TServerSocket.RemoveSecureArea(DevId: Integer): Boolean;
begin
end;
function TServerSocket.RemoveSecureArea(TempID: WORD): Boolean;
begin
end;
function TServerSocket.CreateMapObject(OtherPlayer: PPlayer; OBJID: WORD; ContentID: WORD = 0): Boolean;
var
  NewId: WORD;
  newOBJ: POBJ;
  i: WORD;
begin
  if(OtherPlayer = nil) then
    Exit;
  NewId := Self.GetFreeObjId;
  if(NewId = 0) then
  begin
    OtherPlayer.SendClientMessage('Erro ao criar o objeto no mapa. ERR_01 Send ticket for support.');
    Exit;
  end;
  newOBJ := @Self.OBJ[NewID];
  case OBJID of
    320: //item id do bau das relíquias
    begin
      newOBJ.Index := NewId;
      newOBJ.Position := OtherPlayer.Base.Neighbors[RandomRange(1, 7)].pos;
      newOBJ.ContentType := OBJECT_RELIQUARE;
      newOBJ.ContentAmount := 1;
      newOBJ.ContentCollectTime := 10;
      newOBJ.ContentItemID := ContentID;
      newOBJ.ReSpawn := False;
      newOBJ.CreateTime := Now;
      newOBJ.Face := 320;
      newOBJ.NameID := 914;
      //for I := Low(Self.Players) to High(Self.Players) do
      //begin
      //  if not(Players[i].Status >= Playing) then
      //    Continue;
     ///   if(Players[i].Base.PlayerCharacter.LastPos.Distance(newOBJ.Position) <= DISTANCE_TO_WATCH) then
     ///     Players[i].Base.UpdateVisibleList();
     // end;
    end;
    325: //item id do bau de itens
    begin
    end;
    331: //item id do bau de gold
    begin
    end;
    332: //item id do bau de evento
    begin
    end;
  else
    begin
      //
    end;
  end;

end;
function TServerSocket.GetFreeObjId(): WORD;
var
  i: WORD;
begin
  Result := 0;
  for I := 10148 to 10239 do
  begin
    if(Self.OBJ[i].Index = 0) then
    begin
      Result := i;
      break;
    end;
  end;
end;
procedure TServerSocket.CollectReliquare(Player: PPlayer; Index: WORD);
var
  Packet: TCollectItem;
begin
  ZeroMemory(@Packet, sizeof(TCOllectItem));
  Packet.Header.Size := sizeof(TCOllectItem);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $336;
  Packet.Index := Index;
  Packet.Time := 10;
  Player.SendPacket(Packet, Packet.Header.Size);
  Player.CollectingReliquare := True;
  Player.CollectingID := Index;
  Player.CollectInitTime := Now;
end;
{$ENDREGION}
{$REGION 'Mob Grid / World Functions'}
{
  function TServerSocket.GetEmptyMobGrid(index: WORD; var pos: TPosition;
  radius: WORD = 6): Boolean;
  var
  nY, nX: Integer;
  r: BYTE;
  w, t, x, y: Integer;
  begin
  Result := false;
  if not(pos.IsValid) then
  exit;
  if (MobGrid[Round(pos.y)][Round(pos.x)] = Index) OR
  (MobGrid[Round(pos.y)][Round(pos.x)] = 0) then
  begin
  Result := true;
  exit;
  end;
  for r := 1 to radius do
  begin
  w := r * Round(Sqrt(Random));
  t := 2 * Round(Pi * Random);
  x := w * Round(Cos(t));
  y := w * Round(Sin(t));
  nX := Round(pos.x) + x;
  nY := Round(pos.y) + y;
  if (MobGrid[nY][nX] = 0) then
  begin
  pos.x := nX.ToSingle;
  pos.y := nY.ToSingle;
  Result := true;
  exit;
  end;
  end;
  end;
  function TServerSocket.UpdateWorld(index: Integer; var pos: TPosition;
  flag: BYTE): Boolean;
  var
  mob: TBaseMob;
  begin
  Result := false;
  if flag = WORLD_MOB then
  begin
  if not TBaseMob.GetMob(index, Self.ChannelId, mob) then
  exit;
  Result := GetEmptyMobGrid(index, pos);
  if Result then
  begin
  MobGrid[Round(mob.PlayerCharacter.LastPos.y)
  ][Round(mob.PlayerCharacter.LastPos.x)] := 0;
  MobGrid[Round(pos.y)][Round(pos.x)] := Index;
  end;
  exit;
  end;
  end; }
{$ENDREGION}
end.
