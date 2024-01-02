unit System.Net.SocketHelper;

interface

uses
    System.Net.Socket
  , System.SysUtils
  ;

type
  TSocketHelper = class helper for TSocket
    procedure ConfigureBlocking(IsBlocking: boolean);
    procedure SetTcpNoDelay(const Onn: boolean);
  end;

implementation

uses
    Winapi.WinSock2
  ;


{ TSocketHelper }

procedure TSocketHelper.ConfigureBlocking(IsBlocking: boolean);
var
  Arg: u_long;
begin
  if IsBlocking then
    Arg := 0
  else
    Arg := 1;

{$IFOPT R+}
  {$DEFINE RANGEON}
  {$R-}
{$ELSE}
  {$UNDEF RANGEON}
{$ENDIF}
  if ioctlsocket(self.Handle, FIONBIO, Arg) = SOCKET_ERROR then
  begin
    var LastError := WSAGetLastError;
    raise ESocketError.Create('CodeError : '+LastError.ToString);
  end;
{$IFDEF RANGEON}
  {$R+}
  {$UNDEF RANGEON}
{$ENDIF}
end;


procedure TSocketHelper.SetTcpNoDelay(const Onn: boolean);
begin
  if setsockopt(self.Handle, IPPROTO_TCP, TCP_NODELAY, @Onn, sizeof(Onn)) = SOCKET_ERROR then
  begin
    var LastError := WSAGetLastError;
    raise ESocketError.Create('CodeError : '+LastError.ToString);
  end;
end;

end.
