unit CharacterAutcion;

interface

uses
  Windows, MiscData;

{$OLDTYPELAYOUT ON}

type
  PAutcionItem = ^TAutcionItem;

  TAutcionItem = packed record
    Index: UInt64;
    CharIndex : DWORD;
    Price: DWORD;
    Item: TItem;
    ExpireDate: TDateTime;
    RegisterDate : TDateTime;
    Time: WORD;
  end;

type
  TCharacterAuction = ARRAY [0..11] OF TAutcionItem;

{$OLDTYPELAYOUT OFF}

implementation

end.
