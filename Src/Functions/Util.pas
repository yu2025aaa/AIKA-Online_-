unit Util;

interface

uses System.Threading, GLobalDefs;

function IFThen(cond: boolean; aTrue: variant; aFalse: variant): variant; overload;
function IFThen(cond: boolean): boolean; overload;
function IncWord(var Variable: Word; Value: Integer): boolean; overload;
function IncByte(var Variable: Byte; Value: Integer): boolean; overload;
function IntMV(var x: integer; Value: Integer): boolean; overload;
function Dec(var x: integer; Value: Integer): boolean; overload;
function DecCardinal(var x: Cardinal; Value: Integer): boolean; overload;
function DecInt(var x: Integer; Value: Integer): Boolean; overload;
function DecWORD(var x: WORD; Value: Integer): boolean; overload;
function Dec(var x: Word; Value: Integer): boolean; overload;
function Dec(var x: Byte; Value: Integer): boolean; overload;
function Dec(var x: Int64; Value: Variant): boolean; overload;
function DecUInt64(var x: UInt64; Value: Variant): boolean; overload;

function IncSpeedMove(var Variable: Word; Value: Integer): Boolean; overload;
function IncCooldown(var Variable: Word; Value: Integer): Boolean; overload;
function IncCritical(var Variable: Word; Value: Integer): Boolean; overload;

type
  DWORD = Longword;
  TLoopState = TParallel.TLoopState;

implementation

function IFThen(cond: boolean; aTrue: variant; aFalse: variant): variant;
begin
  if cond then
    Result := aTrue
  else
    Result := aFalse;
end;

function IFThen(cond: boolean): boolean;
begin
  Result := IFThen(cond, true, false);
end;

function IncWord(var Variable: Word; Value: Integer): boolean;
var
  Res: Integer;
begin
  Res := Variable + Value;

  if(Res >= MAX_WORD_SIZE) then
  begin
    Variable := MAX_WORD_SIZE;
  end
  else if (Res <= MIN_WORD_SIZE) then
  begin
    Variable := MIN_WORD_SIZE;
  end
  else
    Variable := Res;

  Result := True;
end;

function IncByte(var Variable: Byte; Value: Integer): boolean;
var
  Res: Integer;
begin
  Res := Variable + Value;

  if(Res >= MAX_BYTE_SIZE) then
  begin
    Variable := MAX_BYTE_SIZE;
  end
  else if (Res <= MIN_BYTE_SIZE) then
  begin
    Variable := MIN_BYTE_SIZE;
  end
  else
    Variable := Res;

  Result := True;
end;

function IntMV(var x: integer; Value: Integer): boolean;
var
  Res: Integer;
begin
  //if()
end;

function Dec(var x: integer; Value: Integer): boolean;
begin
  x := x - Value;

  Result := True;
end;

function DecCardinal(var x: Cardinal; Value: Integer): boolean;
var
  Res: Integer;
begin
  Res := x - Value;

  if (Res < MIN_WORD_SIZE) then
  begin
    x := 0;
  end
  else
    x := Res;

  Result := True;
end;

function DecInt(var x: Integer; Value: Integer): Boolean; overload;
var
  Res: Integer;
begin
  Res := x - Value;

  if (Res < MIN_WORD_SIZE) then
  begin
    x := 0;
  end
  else
    x := Res;

  Result := True;

end;

function DecWORD(var x: WORD; Value: Integer): boolean;
var
  Res: Integer;
begin
  Res := x - Value;

  if (Res < MIN_WORD_SIZE) then
  begin
    x := 0;
  end
  else if(Res > MAX_WORD_SIZE) then
  begin
    x := MAX_WORD_SIZE;
  end
  else
    x := Res;

  Result := True;
end;

function Dec(var x: Word; Value: Integer): boolean;
var
  Res: Integer;
begin
  Res := x - Value;

  if (Res < MIN_WORD_SIZE) then
  begin
    x := 0;
  end
  else if(Res > MAX_WORD_SIZE) then
  begin
    x := MAX_WORD_SIZE;
  end
  else
    x := Res;

  Result := True;
end;

function Dec(var x: Byte; Value: Integer): boolean;
var
  Res: Integer;
begin
  Res := x - Value;

  if (Res < MIN_BYTE_SIZE) then
  begin
    x := MIN_BYTE_SIZE;
  end
  else if(Res > MAX_BYTE_SIZE) then
  begin
    x := MAX_BYTE_SIZE;
  end
  else
    x := Res;

  Result := True;
end;

function Dec(var x: Int64; Value: Variant): boolean;
var
  Res: Variant;
begin
  Res := x - Value;

  if (Res < MIN_BYTE_SIZE) then
  begin
    x := 0;
  end
  else
    x := Res;

  Result := True;
end;

function DecUInt64(var x: UInt64; Value: Variant): boolean;
var
  Res: Variant;
begin
  Res := x - Value;

  if (Res < MIN_BYTE_SIZE) then
  begin
    x := 0;
  end
  else
    x := Res;

  Result := True;
end;

function IncSpeedMove(var Variable: Word; Value: Integer): Boolean; overload;
var
  Res: Integer;
begin
  Res := Variable + Value;

  if(Res >= 70) then
  begin
    Variable := 70;
  end
  else if (Res <= 15) then
  begin
    Variable := 15;
  end
  else
    Variable := Res;

  Result := True;

end;

function IncCooldown(var Variable: Word; Value: Integer): Boolean; overload;
var
  Res: Integer;
begin
  Res := Variable + Value;

  if(Res >= 70) then
  begin
    Variable := 70;
  end
  else if (Res <= 0) then
  begin
    Variable := 0;
  end
  else
    Variable := Res;

  Result := True;

end;

function IncCritical(var Variable: Word; Value: Integer): Boolean; overload;
var
  Res: Integer;
begin
  Res := Variable + Value;

  if(Res >= 255) then
  begin
    Variable := 255;
  end
  else if (Res <= 0) then
  begin
    Variable := 0;
  end
  else
    Variable := Res;

  Result := True;

end;

end.
