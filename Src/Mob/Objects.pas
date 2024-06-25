unit Objects;

interface

uses
  Windows, SysUtils, MiscData;

{$OLDTYPELAYOUT ON}

{$REGION 'OBJECTS Threads'}

{$ENDREGION}

{$REGION 'Objects Data'}
type
  POBJ = ^TOBJ;

  TOBJ = record
    Index: WORD;
    Position: TPosition;
    ContentType: Byte;
    ContentAmount: WORD; //quantidade de itens depois de coletar
    ContentItemID: WORD;
    ContentCollectTime: WORD; //in seconds
    ReSpawn: Boolean;
    CreateTime: TDateTime;
    Face: WORD;
    Weapon: WORD;
    NameID: WORD;
  end;
{$ENDREGION}

{$OLDTYPELAYOUT OFF}
implementation

end.
