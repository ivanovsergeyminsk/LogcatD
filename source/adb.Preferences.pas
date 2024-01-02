unit adb.Preferences;

interface

type
  TAdbPreferences = class
  const
    /// Default value for thread update flag upon client connection.
    DEFAULT_INITIAL_THREAD_UPDATE = false;

    /// Default value for heap update flag upon client connection.
    DEFAULT_INITIAL_HEAP_UPDATE = false;

    /// Default value for the debug port base
    DEFAULT_DEBUG_PORT_BASE = 8600;

    /// Default timeout values for adb connection (milliseconds)
    DEFAULT_TIMEOUT = 5000; // standard delay, in ms

    /// Default value for the selected client debug port
    DEFAULT_SELECTED_DEBUG_PORT = 8700;
  private
    class var FDebugPortBase: integer;
    class var FTimeout: integer;
    class var FThreadUpdate: boolean;
    class var FInitialHeapUpdate: boolean;
    class var FSelectedDebugPort: integer;

    class constructor Create;
  public
    /// Returns the debug port used by the first {@link Client}. Following clients,
    /// will use the next port.
    class function GetDebugPortBase: integer; static;

    /// Returns the timeout to be used in adb connections (milliseconds).
    class function GetTimeout: integer; static;

    /// Returns the initial {@link Client} flag for thread updates.
    /// @see #setInitialThreadUpdate(boolean)
    class function GetInitialThreadUpdate: boolean; static;

    /// Returns the initial {@link Client} flag for heap updates.
    /// @see #setInitialHeapUpdate(boolean)
    class function GetInitialHeapUpdate: boolean; static;

    /// Returns the debug port used by the selected {@link Client}.
    class function GetSelectedDebugPort: integer; static;


    /// Sets the debug port used by the first {@link Client}.
    /// <p/>Once a port is used, the next Client will use port + 1. Quitting applications will
    /// release their debug port, and new clients will be able to reuse them.
    /// <p/>This must be called before {@link AndroidDebugBridge#init(boolean)}.
    class procedure SetDebugPortBase(Value: integer); static;

    /// Sets the timeout value for adb connection.
    /// <p/>This change takes effect for newly created connections only.
    /// @param timeOut the timeout value (milliseconds).
    class procedure SetTimeout(Value: integer); static;

    /// Sets the initial {@link Client} flag for thread updates.
    /// <p/>This change takes effect right away, for newly created {@link Client} objects.
    class procedure SetInitialThreadUpdate(Value: boolean); static;

    /// Sets the initial {@link Client} flag for heap updates.
    /// <p/>If <code>true</code>, the {@link ClientData} will automatically be updated with
    /// the VM heap information whenever a GC happens.
    /// <p/>This change takes effect right away, for newly created {@link Client} objects.
    class procedure SetInitialHeapUodate(Value: boolean); static;

    /// Sets the debug port used by the selected {@link Client}.
    /// <p/>This change takes effect right away.
    /// @param port the new port to use.
    class procedure SetSelectedDebugPort(Value: integer); static;
  end;

implementation


{ TAdbPreferences }

class constructor TAdbPreferences.Create;
begin
  FThreadUpdate       := DEFAULT_INITIAL_THREAD_UPDATE;
  FInitialHeapUpdate  := DEFAULT_INITIAL_HEAP_UPDATE;
  FDebugPortBase      := DEFAULT_DEBUG_PORT_BASE;
  FTimeout            := DEFAULT_TIMEOUT;
  FSelectedDebugPort  := DEFAULT_SELECTED_DEBUG_PORT;
end;

class function TAdbPreferences.GetDebugPortBase: integer;
begin
  result := FDebugPortBase;
end;

class function TAdbPreferences.GetInitialHeapUpdate: boolean;
begin
  result := FInitialHeapUpdate;
end;

class function TAdbPreferences.GetInitialThreadUpdate: boolean;
begin
  result := FThreadUpdate;
end;

class function TAdbPreferences.GetSelectedDebugPort: integer;
begin
  result := FSelectedDebugPort;
end;

class function TAdbPreferences.GetTimeout: integer;
begin
  result := FTimeout;
end;

class procedure TAdbPreferences.SetDebugPortBase(Value: integer);
begin
  FDebugPortBase := Value;
end;

class procedure TAdbPreferences.SetInitialHeapUodate(Value: boolean);
begin
  FInitialHeapUpdate := Value;
end;

class procedure TAdbPreferences.SetInitialThreadUpdate(Value: boolean);
begin
  FThreadUpdate := Value;
end;

class procedure TAdbPreferences.SetSelectedDebugPort(Value: integer);
begin
//  FSelectedDebugPort := Value;
//  var MonitorThread := TMonitorThread.GetInstance;
//  if MonitorThread <> nil then
//    MonitorThread.SetDebugSelectedPort(Value);
end;

class procedure TAdbPreferences.SetTimeout(Value: integer);
begin
  FTimeout := Value;
end;

end.
