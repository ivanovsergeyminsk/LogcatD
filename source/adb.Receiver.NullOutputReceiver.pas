unit adb.Receiver.NullOutputReceiver;

interface

uses
    adb.AndroidDebugBridge
  ;

type
  ///<summary>
  /// Implementation of {@link IShellOutputReceiver} that does nothing.
  /// <p/>This can be used to execute a remote shell command when the output is not needed.
  ///</summary>
  TNullOutputReceiver = class(TInterfacedObject, IShellOutputReceiver)
    procedure AddOutput(const [ref] Data: TArray<byte>; offset, ALength: integer);
    procedure Flush;
    function IsCancelled: boolean;
  end;

implementation

{ TNullOutputReceiver }

procedure TNullOutputReceiver.AddOutput(const [ref] Data: TArray<byte>; offset, ALength: integer);
begin
  //nothing
end;

procedure TNullOutputReceiver.Flush;
begin
  //nothing
end;

function TNullOutputReceiver.IsCancelled: boolean;
begin
  result := false;
end;

end.
