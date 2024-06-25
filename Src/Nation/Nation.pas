unit Nation;
interface
uses
  Windows, SysUtils, DateUtils, StrUtils, Classes, MiscData, ServerSocket;
{$OLDTYPELAYOUT ON}
type
  TNationCerco = packed record
    Defensoras: TGuildsAlly;
    Atacantes: ARRAY [0 .. 3] OF TGuildsAlly;
  end;
type
  TNationData = packed record
    NationID: Integer;
    ChannelName: Array [0 .. 31] of AnsiChar;
    ChannelID: Byte;
    NationRank: Byte;
    MarechalGuildID: Integer;
    TacticianGuildID: Integer;
    JudgeGuildID: Integer;
    TreasurerGuildID: Integer;
    CitizenTax: WORD;
    VisitorTax: WORD;
    Settlement: Integer;
    NationIDAlly: Integer;
    MarechalAllyName: Array [0 .. 31] of AnsiChar;
    AllyDate: DWORD;
    NationGold: Int64;
    Cerco: TNationCerco;
    Server: PServerSocket;
  public
    procedure CreateNation(ChannelID: Byte);
    procedure LoadNation();
    procedure SaveNation();
    procedure SaveNationTaxes();
  end;
{$OLDTYPELAYOUT OFF}
implementation
uses
  GlobalDefs, Log, System.AnsiStrings, SQL, Functions;
procedure TNationData.CreateNation(ChannelID: Byte);
begin
  Self.ChannelID := ChannelID;
  Self.Server := @Servers[ChannelID];
end;
procedure TNationData.LoadNation;
var
  StringHelper: String;
  NationComp: TQuery;
  i: Integer;
  DevirId: Integer;
  Slot: Integer;
  TimeToEst: TDateTime;
begin
  NationComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(NationComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[LoadNation]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[LoadNation]', TlogType.Error);
    NationComp.Destroy;
    Exit;
  end;
  try
    NationComp.SetQuery(format('SELECT * FROM nations WHERE channel_id=%d',
      [ChannelID]));
    // Server.cSQL.AddParameter2('pchannel_id', ChannelID);
    NationComp.Run();
    if (NationComp.Query.RecordCount = 0) then
    begin
      Logger.Write('O servidor não encontrou o ChannelIndex ' +
        ChannelID.ToString + ' para carregar a nação do MySQL.',
        TlogType.Warnings);
      NationComp.Destroy;
      Exit;
    end;
    Self.NationID := NationComp.Query.FieldByName('nation_id').AsInteger;
    System.AnsiStrings.StrPLCopy(Self.ChannelName,
      AnsiString(NationComp.Query.FieldByName('nation_name').AsString), 32);
    Self.NationRank := NationComp.Query.FieldByName('nation_rank').AsInteger;
    Self.MarechalGuildID := NationComp.Query.FieldByName('guild_id_marshal')
      .AsInteger;
    Self.TacticianGuildID := NationComp.Query.FieldByName('guild_id_tactician')
      .AsInteger;
    Self.JudgeGuildID := NationComp.Query.FieldByName('guild_id_judge')
      .AsInteger;
    Self.TreasurerGuildID := NationComp.Query.FieldByName('guild_id_treasurer')
      .AsInteger;
    Self.CitizenTax := NationComp.Query.FieldByName('citizen_tax').AsInteger;
    Self.VisitorTax := NationComp.Query.FieldByName('visitor_tax').AsInteger;
    Self.Settlement := NationComp.Query.FieldByName('settlement').AsInteger;
    Self.NationIDAlly := NationComp.Query.FieldByName('nation_ally').AsInteger;
    System.AnsiStrings.StrPLCopy(Self.MarechalAllyName,
      AnsiString(NationComp.Query.FieldByName('marechal_ally').AsString), 32);
    Self.AllyDate := NationComp.Query.FieldByName('ally_date').AsInteger;
    Self.NationGold := NationComp.Query.FieldByName('nation_gold').AsInteger;
    { Zona E }
    if (Self.MarechalGuildID > 0) then
    begin
      StringHelper := Server.GetGuildByIndex(Self.MarechalGuildID);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Defensoras.LordMarechal,
        AnsiString(StringHelper), 20);
    end;
    if (Self.TacticianGuildID > 0) then
    begin
      StringHelper := Server.GetGuildByIndex(Self.TacticianGuildID);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Defensoras.Estrategista,
        AnsiString(StringHelper), 20);
    end;
    if (Self.JudgeGuildID > 0) then
    begin
      StringHelper := Server.GetGuildByIndex(Self.JudgeGuildID);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Defensoras.Juiz,
        AnsiString(StringHelper), 20);
    end;
    if (Self.TreasurerGuildID > 0) then
    begin
      StringHelper := Server.GetGuildByIndex(Self.TreasurerGuildID);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Defensoras.Tesoureiro,
        AnsiString(StringHelper), 20);
    end;
    { Zona A }
    if (NationComp.Query.FieldByName('cerco_guildid_attack_A1').AsInteger > 0)
    then
    begin
      StringHelper := Server.GetGuildByIndex
        (NationComp.Query.FieldByName('cerco_guildid_attack_A1').AsInteger);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Atacantes[0].LordMarechal,
        AnsiString(StringHelper), 20);
    end;
    if (NationComp.Query.FieldByName('cerco_guildid_attack_A2').AsInteger > 0)
    then
    begin
      StringHelper := Server.GetGuildByIndex
        (NationComp.Query.FieldByName('cerco_guildid_attack_A2').AsInteger);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Atacantes[0].Estrategista,
        AnsiString(StringHelper), 20);
    end;
    if (NationComp.Query.FieldByName('cerco_guildid_attack_A3').AsInteger > 0)
    then
    begin
      StringHelper := Server.GetGuildByIndex
        (NationComp.Query.FieldByName('cerco_guildid_attack_A3').AsInteger);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Atacantes[0].Juiz,
        AnsiString(StringHelper), 20);
    end;
    if (NationComp.Query.FieldByName('cerco_guildid_attack_A4').AsInteger > 0)
    then
    begin
      StringHelper := Server.GetGuildByIndex
        (NationComp.Query.FieldByName('cerco_guildid_attack_A4').AsInteger);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Atacantes[0].Tesoureiro,
        AnsiString(StringHelper), 20);
    end;
    { Zona B }
    if (NationComp.Query.FieldByName('cerco_guildid_attack_B1').AsInteger > 0)
    then
    begin
      StringHelper := Server.GetGuildByIndex
        (NationComp.Query.FieldByName('cerco_guildid_attack_B1').AsInteger);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Atacantes[1].LordMarechal,
        AnsiString(StringHelper), 20);
    end;
    if (NationComp.Query.FieldByName('cerco_guildid_attack_B2').AsInteger > 0)
    then
    begin
      StringHelper := Server.GetGuildByIndex
        (NationComp.Query.FieldByName('cerco_guildid_attack_B2').AsInteger);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Atacantes[1].Estrategista,
        AnsiString(StringHelper), 20);
    end;
    if (NationComp.Query.FieldByName('cerco_guildid_attack_B3').AsInteger > 0)
    then
    begin
      StringHelper := Server.GetGuildByIndex
        (NationComp.Query.FieldByName('cerco_guildid_attack_B3').AsInteger);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Atacantes[1].Juiz,
        AnsiString(StringHelper), 20);
    end;
    if (NationComp.Query.FieldByName('cerco_guildid_attack_B4').AsInteger > 0)
    then
    begin
      StringHelper := Server.GetGuildByIndex
        (NationComp.Query.FieldByName('cerco_guildid_attack_B4').AsInteger);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Atacantes[1].Tesoureiro,
        AnsiString(StringHelper), 20);
    end;
    {
      if(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_B1').AsInteger > 0) then
      Move(Server.GetGuildByIndex(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_B1').AsInteger),
      Self.Cerco.Atacantes[1].LordMarechal, 19);
      if(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_B2').AsInteger > 0) then
      Move(Server.GetGuildByIndex(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_B2').AsInteger),
      Self.Cerco.Atacantes[1].Estrategista, 19);
      if(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_B3').AsInteger > 0) then
      Move(Server.GetGuildByIndex(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_B3').AsInteger),
      Self.Cerco.Atacantes[1].Juiz, 19);
      if(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_B4').AsInteger > 0) then
      Move(Server.GetGuildByIndex(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_B4').AsInteger),
      Self.Cerco.Atacantes[1].Tesoureiro, 19);
      { Zona C }
    if (NationComp.Query.FieldByName('cerco_guildid_attack_C1').AsInteger > 0)
    then
    begin
      StringHelper := Server.GetGuildByIndex
        (NationComp.Query.FieldByName('cerco_guildid_attack_C1').AsInteger);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Atacantes[2].LordMarechal,
        AnsiString(StringHelper), 20);
    end;
    if (NationComp.Query.FieldByName('cerco_guildid_attack_C2').AsInteger > 0)
    then
    begin
      StringHelper := Server.GetGuildByIndex
        (NationComp.Query.FieldByName('cerco_guildid_attack_C2').AsInteger);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Atacantes[2].Estrategista,
        AnsiString(StringHelper), 20);
    end;
    if (NationComp.Query.FieldByName('cerco_guildid_attack_C3').AsInteger > 0)
    then
    begin
      StringHelper := Server.GetGuildByIndex
        (NationComp.Query.FieldByName('cerco_guildid_attack_C3').AsInteger);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Atacantes[2].Juiz,
        AnsiString(StringHelper), 20);
    end;
    if (NationComp.Query.FieldByName('cerco_guildid_attack_C4').AsInteger > 0)
    then
    begin
      StringHelper := Server.GetGuildByIndex
        (NationComp.Query.FieldByName('cerco_guildid_attack_C4').AsInteger);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Atacantes[2].Tesoureiro,
        AnsiString(StringHelper), 20);
    end;
    {
      if(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_C1').AsInteger > 0) then
      Move(Server.GetGuildByIndex(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_C1').AsInteger),
      Self.Cerco.Atacantes[2].LordMarechal, 19);
      if(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_C2').AsInteger > 0) then
      Move(Server.GetGuildByIndex(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_C2').AsInteger),
      Self.Cerco.Atacantes[2].Estrategista, 19);
      if(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_C3').AsInteger > 0) then
      Move(Server.GetGuildByIndex(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_C3').AsInteger),
      Self.Cerco.Atacantes[2].Juiz, 19);
      if(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_C4').AsInteger > 0) then
      Move(Server.GetGuildByIndex(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_C4').AsInteger),
      Self.Cerco.Atacantes[2].Tesoureiro, 19);
      { Zona D }
    if (NationComp.Query.FieldByName('cerco_guildid_attack_D1').AsInteger > 0)
    then
    begin
      StringHelper := Server.GetGuildByIndex
        (NationComp.Query.FieldByName('cerco_guildid_attack_D1').AsInteger);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Atacantes[3].LordMarechal,
        AnsiString(StringHelper), 20);
    end;
    if (NationComp.Query.FieldByName('cerco_guildid_attack_D2').AsInteger > 0)
    then
    begin
      StringHelper := Server.GetGuildByIndex
        (NationComp.Query.FieldByName('cerco_guildid_attack_D2').AsInteger);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Atacantes[3].Estrategista,
        AnsiString(StringHelper), 20);
    end;
    if (NationComp.Query.FieldByName('cerco_guildid_attack_D3').AsInteger > 0)
    then
    begin
      StringHelper := Server.GetGuildByIndex
        (NationComp.Query.FieldByName('cerco_guildid_attack_D3').AsInteger);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Atacantes[3].Juiz,
        AnsiString(StringHelper), 20);
    end;
    if (NationComp.Query.FieldByName('cerco_guildid_attack_D4').AsInteger > 0)
    then
    begin
      StringHelper := Server.GetGuildByIndex
        (NationComp.Query.FieldByName('cerco_guildid_attack_D4').AsInteger);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Atacantes[3].Tesoureiro,
        AnsiString(StringHelper), 20);
    end;
    {
      if(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_D1').AsInteger > 0) then
      Move(Server.GetGuildByIndex(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_D1').AsInteger),
      Self.Cerco.Atacantes[3].LordMarechal, 19);
      if(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_D2').AsInteger > 0) then
      Move(Server.GetGuildByIndex(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_D2').AsInteger),
      Self.Cerco.Atacantes[3].Estrategista, 19);
      if(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_D3').AsInteger > 0) then
      Move(Server.GetGuildByIndex(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_D3').AsInteger),
      Self.Cerco.Atacantes[3].Juiz, 19);
      if(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_D4').AsInteger > 0) then
      Move(Server.GetGuildByIndex(Server.cSQL.Query.FieldByName
      ('cerco_guildid_attack_D4').AsInteger),
      Self.Cerco.Atacantes[3].Tesoureiro, 19);
    }
    NationComp.SetQuery(format('SELECT * FROM devires WHERE nation_id=%d',
      [Self.NationID]));
    NationComp.Run();
    if not(NationComp.Query.RecordCount = 0) then
    begin
      NationComp.Query.First;
      while not NationComp.Query.Eof do
      begin
        DevirId := NationComp.Query.FieldByName('devir_id').AsInteger;
        if (Self.NationID > 1) then
        begin
          Slot := (DevirId - ((Self.NationID - 1) * 5));
        end
        else
        begin
          Slot := DevirId;
        end;
        Slot := Slot - 1;
        Server.Devires[Slot].DevirId := DevirId;
        Server.Devires[Slot].NationID := Self.NationID;
        Server.Devires[Slot].IsOpen := False;
        Server.Devires[Slot].StonesDied := 0;
        Server.Devires[Slot].GuardsDied := 0;
        for i := 0 to 4 do
        begin
          case i of
            0:
              begin
                Server.Devires[Slot].Slots[i].ItemID :=
                  NationComp.Query.FieldByName('slot1_itemid').AsInteger;
                Server.Devires[Slot].Slots[i].App := Server.Devires[Slot].Slots
                  [i].ItemID;
                Server.Devires[Slot].Slots[i].IsAble :=
                  Boolean(NationComp.Query.FieldByName('slot1_able').AsInteger);
                if (NationComp.Query.FieldByName('slot1_timecap')
                  .AsString <> '01:02:03 01/01/2001') then
                begin
                  Server.ReliqEffect[
                  ItemList[Server.Devires[Slot].Slots[i].ItemID].EF[0]] :=
                  Server.ReliqEffect[
                  ItemList[Server.Devires[Slot].Slots[i].ItemID].EF[0]] +
                  ItemList[Server.Devires[Slot].Slots[i].ItemID].EFV[0];
                  Server.Devires[Slot].Slots[i].TimeCapped :=
                    StrToDateTime(NationComp.Query.FieldByName('slot1_timecap')
                    .AsString);
                  TimeToEst :=
                    IncHour(StrToDateTime(NationComp.Query.FieldByName
                    ('slot1_timecap').AsString), RELIQ_EST_TIME);
                  Server.Devires[Slot].Slots[i].TimeToEstabilish := TimeToEst;
                end;
                System.AnsiStrings.StrPLCopy(Server.Devires[Slot].Slots[i]
                  .NameCapped, NationComp.Query.FieldByName('slot1_name')
                  .AsString, 16);
              end;
            1:
              begin
                Server.Devires[Slot].Slots[i].ItemID :=
                  NationComp.Query.FieldByName('slot2_itemid').AsInteger;
                Server.Devires[Slot].Slots[i].App := Server.Devires[Slot].Slots
                  [i].ItemID;
                Server.Devires[Slot].Slots[i].IsAble :=
                  Boolean(NationComp.Query.FieldByName('slot2_able').AsInteger);
                if (NationComp.Query.FieldByName('slot2_timecap')
                  .AsString <> '01:02:03 01/01/2001') then
                begin
                  Server.ReliqEffect[
                  ItemList[Server.Devires[Slot].Slots[i].ItemID].EF[0]] :=
                  Server.ReliqEffect[
                  ItemList[Server.Devires[Slot].Slots[i].ItemID].EF[0]] +
                  ItemList[Server.Devires[Slot].Slots[i].ItemID].EFV[0];
                  Server.Devires[Slot].Slots[i].TimeCapped :=
                    StrToDateTime(NationComp.Query.FieldByName('slot2_timecap')
                    .AsString);
                  TimeToEst :=
                    IncHour(StrToDateTime(NationComp.Query.FieldByName
                    ('slot2_timecap').AsString), RELIQ_EST_TIME);
                  Server.Devires[Slot].Slots[i].TimeToEstabilish := TimeToEst;
                end;
                System.AnsiStrings.StrPLCopy(Server.Devires[Slot].Slots[i]
                  .NameCapped, NationComp.Query.FieldByName('slot2_name')
                  .AsString, 16);
              end;
            2:
              begin
                Server.Devires[Slot].Slots[i].ItemID :=
                  NationComp.Query.FieldByName('slot3_itemid').AsInteger;
                Server.Devires[Slot].Slots[i].App := Server.Devires[Slot].Slots
                  [i].ItemID;
                Server.Devires[Slot].Slots[i].IsAble :=
                  Boolean(NationComp.Query.FieldByName('slot3_able').AsInteger);
                if (NationComp.Query.FieldByName('slot3_timecap')
                  .AsString <> '01:02:03 01/01/2001') then
                begin
                  Server.ReliqEffect[
                  ItemList[Server.Devires[Slot].Slots[i].ItemID].EF[0]] :=
                  Server.ReliqEffect[
                  ItemList[Server.Devires[Slot].Slots[i].ItemID].EF[0]] +
                  ItemList[Server.Devires[Slot].Slots[i].ItemID].EFV[0];
                  Server.Devires[Slot].Slots[i].TimeCapped :=
                    StrToDateTime(NationComp.Query.FieldByName('slot3_timecap')
                    .AsString);
                  TimeToEst :=
                    IncHour(StrToDateTime(NationComp.Query.FieldByName
                    ('slot3_timecap').AsString), RELIQ_EST_TIME);
                  Server.Devires[Slot].Slots[i].TimeToEstabilish := TimeToEst;
                end;
                System.AnsiStrings.StrPLCopy(Server.Devires[Slot].Slots[i]
                  .NameCapped, NationComp.Query.FieldByName('slot3_name')
                  .AsString, 16);
              end;
            3:
              begin
                Server.Devires[Slot].Slots[i].ItemID :=
                  NationComp.Query.FieldByName('slot4_itemid').AsInteger;
                Server.Devires[Slot].Slots[i].App := Server.Devires[Slot].Slots
                  [i].ItemID;
                Server.Devires[Slot].Slots[i].IsAble :=
                  Boolean(NationComp.Query.FieldByName('slot4_able').AsInteger);
                if (NationComp.Query.FieldByName('slot4_timecap')
                  .AsString <> '01:02:03 01/01/2001') then
                begin
                  Server.ReliqEffect[
                  ItemList[Server.Devires[Slot].Slots[i].ItemID].EF[0]] :=
                  Server.ReliqEffect[
                  ItemList[Server.Devires[Slot].Slots[i].ItemID].EF[0]] +
                  ItemList[Server.Devires[Slot].Slots[i].ItemID].EFV[0];
                  Server.Devires[Slot].Slots[i].TimeCapped :=
                    StrToDateTime(NationComp.Query.FieldByName('slot4_timecap')
                    .AsString);
                  TimeToEst :=
                    IncHour(StrToDateTime(NationComp.Query.FieldByName
                    ('slot4_timecap').AsString), RELIQ_EST_TIME);
                  Server.Devires[Slot].Slots[i].TimeToEstabilish := TimeToEst;
                end;
                System.AnsiStrings.StrPLCopy(Server.Devires[Slot].Slots[i]
                  .NameCapped, NationComp.Query.FieldByName('slot4_name')
                  .AsString, 16);
              end;
            4:
              begin
                Server.Devires[Slot].Slots[i].ItemID :=
                  NationComp.Query.FieldByName('slot5_itemid').AsInteger;
                Server.Devires[Slot].Slots[i].App := Server.Devires[Slot].Slots
                  [i].ItemID;
                Server.Devires[Slot].Slots[i].IsAble :=
                  Boolean(NationComp.Query.FieldByName('slot5_able').AsInteger);
                if (NationComp.Query.FieldByName('slot5_timecap')
                  .AsString <> '01:02:03 01/01/2001') then
                begin
                  Server.ReliqEffect[
                  ItemList[Server.Devires[Slot].Slots[i].ItemID].EF[0]] :=
                  Server.ReliqEffect[
                  ItemList[Server.Devires[Slot].Slots[i].ItemID].EF[0]] +
                  ItemList[Server.Devires[Slot].Slots[i].ItemID].EFV[0];
                  Server.Devires[Slot].Slots[i].TimeCapped :=
                    StrToDateTime(NationComp.Query.FieldByName('slot5_timecap')
                    .AsString);
                  TimeToEst :=
                    IncHour(StrToDateTime(NationComp.Query.FieldByName
                    ('slot5_timecap').AsString), RELIQ_EST_TIME);
                  Server.Devires[Slot].Slots[i].TimeToEstabilish := TimeToEst;
                end;
                System.AnsiStrings.StrPLCopy(Server.Devires[Slot].Slots[i]
                  .NameCapped, NationComp.Query.FieldByName('slot5_name')
                  .AsString, 16);
              end;
          end;
        end;
        NationComp.Query.Next;
      end;
    end;
    Logger.Write('Nation ' + String(Self.ChannelName) + ' loaded.',
      TlogType.ServerStatus);
  except
    on E: Exception do
    begin
      Logger.Write('Nation Load Error: ' + E.Message, TlogType.Warnings);
    end;
  end;
  NationComp.Destroy;
end;
procedure TNationData.SaveNation();
var
  NationComp: TQuery;
  cerco_guildid_attack_A1,
  cerco_guildid_attack_A2,
  cerco_guildid_attack_A3,
  cerco_guildid_attack_A4,
  cerco_guildid_attack_B1,
  cerco_guildid_attack_B2,
  cerco_guildid_attack_B3,
  cerco_guildid_attack_B4,
  cerco_guildid_attack_C1,
  cerco_guildid_attack_C2,
  cerco_guildid_attack_C3,
  cerco_guildid_attack_C4,
  cerco_guildid_attack_D1,
  cerco_guildid_attack_D2,
  cerco_guildid_attack_D3,
  cerco_guildid_attack_D4: Integer;
begin
  if (Self.NationID = 0) then
    Exit;
  NationComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);
  if not(NationComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SaveNation]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveNation]', TlogType.Error);
    NationComp.Destroy;
    Exit;
  end;

  cerco_guildid_attack_A1 := 0;
  cerco_guildid_attack_A2 := 0;
  cerco_guildid_attack_A3 := 0;
  cerco_guildid_attack_A4 := 0;
  cerco_guildid_attack_B1 := 0;
  cerco_guildid_attack_B2 := 0;
  cerco_guildid_attack_B3 := 0;
  cerco_guildid_attack_B4 := 0;
  cerco_guildid_attack_C1 := 0;
  cerco_guildid_attack_C2 := 0;
  cerco_guildid_attack_C3 := 0;
  cerco_guildid_attack_C4 := 0;
  cerco_guildid_attack_D1 := 0;
  cerco_guildid_attack_D2 := 0;
  cerco_guildid_attack_D3 := 0;
  cerco_guildid_attack_D4 := 0;

  if(String(Self.Cerco.Atacantes[0].LordMarechal) <> '') then
    cerco_guildid_attack_A1 :=
      Server.GetGuildByName(String(Self.Cerco.Atacantes[0].LordMarechal));
  if(String(Self.Cerco.Atacantes[0].Estrategista) <> '') then
    cerco_guildid_attack_A2 :=
      Server.GetGuildByName(String(Self.Cerco.Atacantes[0].Estrategista));
  if(String(Self.Cerco.Atacantes[0].Juiz) <> '') then
    cerco_guildid_attack_A3 :=
      Server.GetGuildByName(String(Self.Cerco.Atacantes[0].Juiz));
  if(String(Self.Cerco.Atacantes[0].Tesoureiro) <> '') then
    cerco_guildid_attack_A4 :=
      Server.GetGuildByName(String(Self.Cerco.Atacantes[0].Tesoureiro));

  if(String(Self.Cerco.Atacantes[1].LordMarechal) <> '') then
    cerco_guildid_attack_B1 :=
      Server.GetGuildByName(String(Self.Cerco.Atacantes[1].LordMarechal));
  if(String(Self.Cerco.Atacantes[1].Estrategista) <> '') then
    cerco_guildid_attack_B2 :=
      Server.GetGuildByName(String(Self.Cerco.Atacantes[1].Estrategista));
  if(String(Self.Cerco.Atacantes[1].Juiz) <> '') then
    cerco_guildid_attack_B3 :=
      Server.GetGuildByName(String(Self.Cerco.Atacantes[1].Juiz));
  if(String(Self.Cerco.Atacantes[1].Tesoureiro) <> '') then
    cerco_guildid_attack_B4 :=
      Server.GetGuildByName(String(Self.Cerco.Atacantes[1].Tesoureiro));

  if(String(Self.Cerco.Atacantes[2].LordMarechal) <> '') then
    cerco_guildid_attack_C1 :=
      Server.GetGuildByName(String(Self.Cerco.Atacantes[2].LordMarechal));
  if(String(Self.Cerco.Atacantes[2].Estrategista) <> '') then
    cerco_guildid_attack_C2 :=
      Server.GetGuildByName(String(Self.Cerco.Atacantes[2].Estrategista));
  if(String(Self.Cerco.Atacantes[2].Juiz) <> '') then
    cerco_guildid_attack_C3 :=
      Server.GetGuildByName(String(Self.Cerco.Atacantes[2].Juiz));
  if(String(Self.Cerco.Atacantes[2].Tesoureiro) <> '') then
    cerco_guildid_attack_C4 :=
      Server.GetGuildByName(String(Self.Cerco.Atacantes[2].Tesoureiro));

  if(String(Self.Cerco.Atacantes[3].LordMarechal) <> '') then
    cerco_guildid_attack_D1 :=
      Server.GetGuildByName(String(Self.Cerco.Atacantes[3].LordMarechal));
  if(String(Self.Cerco.Atacantes[3].Estrategista) <> '') then
    cerco_guildid_attack_D2 :=
      Server.GetGuildByName(String(Self.Cerco.Atacantes[3].Estrategista));
  if(String(Self.Cerco.Atacantes[3].Juiz) <> '') then
    cerco_guildid_attack_D3 :=
      Server.GetGuildByName(String(Self.Cerco.Atacantes[3].Juiz));
  if(String(Self.Cerco.Atacantes[3].Tesoureiro) <> '') then
    cerco_guildid_attack_D4 :=
      Server.GetGuildByName(String(Self.Cerco.Atacantes[3].Tesoureiro));


  NationComp.Query.Connection.StartTransaction;
  try
    NationComp.SetQuery
      ('UPDATE nations SET nation_rank='+
      Self.NationRank.ToString+', guild_id_marshal='+
      Self.MarechalGuildID.ToString+',' +
      ' guild_id_tactician='+Self.TacticianGuildID.ToString
      +', guild_id_judge='+Self.JudgeGuildID.ToString+',' +
      ' guild_id_treasurer='+Self.TreasurerGuildID.ToString+
      ', citizen_tax='+Self.CitizenTax.ToString+',' +
      ' visitor_tax='+Self.VisitorTax.ToString+', nation_ally='+
      Self.NationIDAlly.ToString+', marechal_ally="'+
      String(Self.MarechalAllyName)+'",' +
      ' ally_date='+Self.AllyDate.ToString+', nation_gold='+
      Self.NationGold.ToString+', cerco_guildid_attack_A1='+
      cerco_guildid_attack_A1.ToString+',' +
      ' cerco_guildid_attack_A2='+
      cerco_guildid_attack_A2.ToString+', cerco_guildid_attack_A3='+
      cerco_guildid_attack_A3.ToString+',' +
      ' cerco_guildid_attack_A4='+
      cerco_guildid_attack_A4.ToString+', cerco_guildid_attack_B1='+
      cerco_guildid_attack_B1.ToString+',' +
      ' cerco_guildid_attack_B2='+
      cerco_guildid_attack_B2.ToString+', cerco_guildid_attack_B3='+
      cerco_guildid_attack_B3.ToString+',' +
      ' cerco_guildid_attack_B4='+
      cerco_guildid_attack_B4.ToString+', cerco_guildid_attack_C1='+
      cerco_guildid_attack_C1.ToString+',' +
      ' cerco_guildid_attack_C2='+
      cerco_guildid_attack_C2.ToString+', cerco_guildid_attack_C3='+
      cerco_guildid_attack_C3.ToString+',' +
      ' cerco_guildid_attack_C4='+
      cerco_guildid_attack_C4.ToString+', cerco_guildid_attack_D1='+
      cerco_guildid_attack_D1.ToString+',' +
      ' cerco_guildid_attack_D2='+
      cerco_guildid_attack_D2.ToString+', cerco_guildid_attack_D3='+
      cerco_guildid_attack_D3.ToString+',' +
      ' cerco_guildid_attack_D4='+
      cerco_guildid_attack_D4.ToString+' WHERE nation_id='+Self.NationID.ToString+';');
    { Server.cSQL.AddParameter2('pnation_rank', Self.NationRank);
      Server.cSQL.AddParameter2('pguild_id_marshal', Self.MarechalGuildID);
      Server.cSQL.AddParameter2('pguild_id_tactician', Self.TacticianGuildID);
      Server.cSQL.AddParameter2('pguild_id_judge', Self.JudgeGuildID);
      Server.cSQL.AddParameter2('pguild_id_treasurer', Self.TreasurerGuildID);
      Server.cSQL.AddParameter2('pcitizen_tax', Self.CitizenTax);
      Server.cSQL.AddParameter2('pvisitor_tax', Self.VisitorTax);
      Server.cSQL.AddParameter2('pnation_ally', Self.NationIDAlly);
      Server.cSQL.AddParameter2('pmarechal_ally', String(Self.MarechalAllyName));
      Server.cSQL.AddParameter2('pally_date', Self.AllyDate);
      Server.cSQL.AddParameter2('pnation_gold', Self.NationGold);
      Server.cSQL.AddParameter2('pcerco_guildid_attack_A1',
      Server.GetGuildByName(String(Self.Cerco.Atacantes[0].LordMarechal)));
      Server.cSQL.AddParameter2('pcerco_guildid_attack_A2',
      Server.GetGuildByName(String(Self.Cerco.Atacantes[0].Estrategista)));
      Server.cSQL.AddParameter2('pcerco_guildid_attack_A3',
      Server.GetGuildByName(String(Self.Cerco.Atacantes[0].Juiz)));
      Server.cSQL.AddParameter2('pcerco_guildid_attack_A4',
      Server.GetGuildByName(String(Self.Cerco.Atacantes[0].Tesoureiro)));
      Server.cSQL.AddParameter2('pcerco_guildid_attack_B1',
      Server.GetGuildByName(String(Self.Cerco.Atacantes[1].LordMarechal)));
      Server.cSQL.AddParameter2('pcerco_guildid_attack_B2',
      Server.GetGuildByName(String(Self.Cerco.Atacantes[1].Estrategista)));
      Server.cSQL.AddParameter2('pcerco_guildid_attack_B3',
      Server.GetGuildByName(String(Self.Cerco.Atacantes[1].Juiz)));
      Server.cSQL.AddParameter2('pcerco_guildid_attack_B4',
      Server.GetGuildByName(String(Self.Cerco.Atacantes[1].Tesoureiro)));
      Server.cSQL.AddParameter2('pcerco_guildid_attack_C1',
      Server.GetGuildByName(String(Self.Cerco.Atacantes[2].LordMarechal)));
      Server.cSQL.AddParameter2('pcerco_guildid_attack_C2',
      Server.GetGuildByName(String(Self.Cerco.Atacantes[2].Estrategista)));
      Server.cSQL.AddParameter2('pcerco_guildid_attack_C3',
      Server.GetGuildByName(String(Self.Cerco.Atacantes[2].Juiz)));
      Server.cSQL.AddParameter2('pcerco_guildid_attack_C4',
      Server.GetGuildByName(String(Self.Cerco.Atacantes[2].Tesoureiro)));
      Server.cSQL.AddParameter2('pcerco_guildid_attack_D1',
      Server.GetGuildByName(String(Self.Cerco.Atacantes[3].LordMarechal)));
      Server.cSQL.AddParameter2('pcerco_guildid_attack_D2',
      Server.GetGuildByName(String(Self.Cerco.Atacantes[3].Estrategista)));
      Server.cSQL.AddParameter2('pcerco_guildid_attack_D3',
      Server.GetGuildByName(String(Self.Cerco.Atacantes[3].Juiz)));
      Server.cSQL.AddParameter2('pcerco_guildid_attack_D4',
      Server.GetGuildByName(String(Self.Cerco.Atacantes[3].Tesoureiro)));
      Server.cSQL.AddParameter2('pnation_id', Self.NationID); }
    NationComp.Run(False);

    NationComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      NationComp.Query.Connection.Rollback;
      Logger.Write('Error while saving nation: ' + String(Self.ChannelName) +
        ' ' + E.Message, TlogType.Error);
    end;
  end;
  NationComp.Destroy;
end;
procedure TNationData.SaveNationTaxes();
var
  NationComp: TQuery;
begin
  NationComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(NationComp.Query.Connection.Connected) then
  begin
    NationComp.Destroy;
    Logger.Write('Falha de conexão individual com mysql.[SaveNation]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveNation]', TlogType.Error);
    Exit;
  end;
  try
    NationComp.SetQuery
      (format('UPDATE nations SET citizen_tax=%d, visitor_tax=%d,' +
      ' nation_gold=%d WHERE nation_id=%d', [Self.CitizenTax, Self.VisitorTax,
      Self.NationGold, Self.NationID]));
    { Server.cSQL.AddParameter2('pcitizen_tax', Self.CitizenTax);
      Server.cSQL.AddParameter2('pvisitor_tax', Self.VisitorTax);
      Server.cSQL.AddParameter2('pnation_gold', Self.NationGold);
      Server.cSQL.AddParameter2('pnation_id', Self.NationID); }
    NationComp.Run(False);
  except
    on E: Exception do
    begin
      Logger.Write('Error while saving nation_taxes: ' +
        String(Self.ChannelName) + ' ' + E.Message, TlogType.Error);
    end;
  end;
  NationComp.Destroy;
end;
end.
