unit CharacterMail;

interface

uses
  Windows, MiscData;

{$OLDTYPELAYOUT ON}

type
  PMail = ^TMail;

  TMail = packed record
    Index: UInt64;
    CharIndex: DWORD;
    Nick: Array [0 .. 15] of AnsiChar;
    Titulo: Array [0 .. 31] of AnsiChar;
    Texto: Array [0 .. 511] of AnsiChar;
    Slot: WORD;
    Gold: DWORD;
    Item: Array [0 .. 6] of TItem;
    DataRetorno: TDateTime;
    DataEnvio: TDateTime;
    Checked: BOOLEAN;
    Return: BOOLEAN;
    CheckItem: BOOLEAN;
    Leilao: BOOLEAN;
  end;

type
  TCharacterMail = ARRAY OF TMail;

{$OLDTYPELAYOUT OFF}

implementation

end.
