unit adb.ClientData;

interface

uses
    adb.AndroidDebugBridge
  , System.Generics.Collections
  ;

type
  TClientData = class(TInterfacedObject, IClientData)
  private
    // the client's procedd ID
    FPid: integer;
    // client's self-description
    FClientDescription: string;
  public
    constructor Create(pid: integer);
    destructor Destroy; override;

    //IClientData
    function GetPid: integer;
    function GetClientDescription: string;
  end;

implementation

{ TClientData }

constructor TClientData.Create(pid: integer);
begin
  FPid := pid;
end;

destructor TClientData.Destroy;
begin
  inherited;
end;

function TClientData.GetClientDescription: string;
begin
  result := FClientDescription;
end;

function TClientData.GetPid: integer;
begin
  result := FPid;
end;

end.
