﻿unit adb.Receiver.GetPropReceiver;

interface

uses
    System.RegularExpressions
  , System.Diagnostics
  , adb.AndroidDebugBridge
  , adb.Receiver.MultiLineReceiver
  ;


type
  ///<summary>
  /// A receiver able to parse the result of the execution of<p/>
  /// {@link #GETPROP_COMMAND} on a device.
  ///</sumamry>
  TGetPropReceiver = class(TMultiLineReceiver)
  public const
    GETPROP_COMMAND = 'getprop';
  private const
    RX_GETPROP = '^\[([^]]+)\]\:\s*\[(.*)\]$';
  private
    /// indicates if we need to read the first
    FDevice: IDevice;
    FGetPropPattern: TRegEx;
    FIsCancelled: boolean;

    SW: TStopwatch;
  public
    constructor Create(Device: IDevice);

    procedure ProcessNewLines(const [ref] Lines: TArray<string>); override;
    function IsCancelled: boolean; override;
    procedure Flush; override;
    procedure Done; override;
  end;

implementation

uses
    System.SysUtils
  , adb.Device
  ;

{ TGetPropReceiver }

constructor TGetPropReceiver.Create(Device: IDevice);
begin
  inherited Create;

  FIsCancelled := false;
  FDevice := Device;
  FGetPropPattern := TRegEx.Create(RX_GETPROP, [roNotEmpty, roCompiled]);
end;

procedure TGetPropReceiver.Done;
begin
  TDevice(FDevice).Update([TDeviceChange.ChangeBuildInfo]);
end;

procedure TGetPropReceiver.Flush;
begin
  if SW.IsRunning then
  begin
    FIsCancelled := SW.ElapsedMilliseconds > 1000;
  end
  else
  begin
    SW.Reset;
    SW.Start;
    FIsCancelled := false;
  end;
end;

function TGetPropReceiver.IsCancelled: boolean;
begin
  result := FIsCancelled;
end;

procedure TGetPropReceiver.ProcessNewLines(const [ref] Lines: TArray<string>);
begin
  SW.Stop;
  SW.Reset;

  // We receive an array of lines. We're expecting
  // to have the build info in the first line, and the build
  // date in the 2nd line. There seems to be an empty line
  // after all that.

  for var Line in Lines do
  begin
    if Line.IsEmpty or Line.StartsWith('#') then
      continue;

    var m := FGetPropPattern.Match(Line);
    if m.Success then
    begin
      var PropLabel := m.Groups[1].Value;
      var PropValue := m.Groups[2].Value;

      if not PropLabel.IsEmpty then
        TDevice(FDevice).AddProperty(PropLabel, PropValue);
    end;

  end;
end;

end.
