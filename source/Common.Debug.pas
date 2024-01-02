unit Common.Debug;

interface

type
  TDebug = class
    class procedure WriteLine(const Msg: string); static;
  end;

implementation

uses
  System.DateUtils,
  System.SysUtils,
  Winapi.Windows;

{$REGION 'TDebug'}

class procedure TDebug.WriteLine(const Msg: string);
{$IFDEF DEBUG}
var
  LMsg: string;
{$ENDIF}
begin
  {$IFDEF DEBUG}
  LMsg := format('[<%s> %s] ', [Now.ToString, Msg]);
  OutputDebugString(PChar(LMsg));
  {$ENDIF}
end;

{$ENDREGION}

end.
