unit adb.Logcat;

interface

uses
    System.SysUtils
  , System.Rtti
  , System.Generics.Collections
  , System.Generics.Defaults
  , System.RegularExpressions
  , System.Character
  , System.Threading
  , System.Classes
  , System.AtomicTypes
  , System.DateUtils
  , adb.AndroidDebugBridge
  , adb.Receiver.MultiLineReceiver
  ;

type
  IRunnable = interface
  ['{C02B8A1C-BD60-4B89-BFA2-50EAF00DDDCA}']
    procedure Run;
  end;

  TLogLevel = (
    NONE    = 0,
    VERBOSE = 2,
    DEBUG   = 3,
    INFO    = 4,
    WARN    = 5,
    ERROR   = 6,
    ASSERT  = 7
  );

  TLogLevelHelper = record helper for TLogLevel
  strict private const
    S_VERBOSE = 'verbose';
    S_DEBUG   = 'debug';
    S_INFO    = 'info';
    S_WARN    = 'warn';
    S_ERROR   = 'error';
    S_ASSERT  = 'assert';
  public
    class function GetByString(Value: string): TLogLevel; static;
    class function GetByLetterString(Letter: string): TLogLevel; static;

    function GetPriorityLetter: Char;
    function GetPriority: integer;
    function GetStringValue: string;
  end;

  /// Model a single log message output from {@code logcat -v long}.
  /// A logcat message has a {@link LogLevel}, the pid (process id) of the process
  /// generating the message, the time at which the message was generated, and
  /// the tag and message itself.
  TLogcatMessage = record
  private
    FLogLevel: TLogLevel;
    FPid: string;
    FTid: string;
    FAppName: string;
    FTag: string;
    FTime: string;
    FMessage: string;
  public
    /// Construct an immutable log message object.
    constructor New(ALogLevel: TLogLevel; APid, ATid, AAppName, ATag, ATime, AMessage: string);

    property LogLevel : TLogLevel read FLogLevel;
    property Pid      : string read FPid;
    property Tid      : string read FTid;
    property AppName  : string read FAppName;
    property Tag      : string read FTag;
    property Time     : string read FTime;
    property &Message : string read FMessage write FMessage;

    function TryToTime(out AResult: TDateTime): boolean;
    function ToString: string;
  end;

  ILogcatListener = interface
  ['{4C2ACD67-161D-4134-BF08-03CC66B3EA8F}']
    procedure Log(const [ref] MsgList: TArray<TLogcatMessage>);
  end;

  ILogcatReceiverTask = interface(IRunnable)
  ['{5B91A17E-FA04-402B-A1AA-76EFA972F1C8}']
    procedure Stop;

    procedure AddLogcatListener(Listener: ILogcatListener);
    procedure RemoveLogcatListener(Listener: ILogcatListener);
  end;

  /// Class to parse raw output of {@code adb logcat -v long} to {@link LogCatMessage} objects.
  TLogcatMessageParser = class sealed
  private
    FCurLogLevel: TLogLevel;
    FCurPid   : string;
    FCurTid   : string;
    FCurTag   : string;
    FCurTime  : string;
  private const
    // This pattern is meant to parse the first line of a log message with the option
    // 'logcat -v long'. The first line represents the date, tag, severity, etc.. while the
    // following lines are the message (can be several lines).<br>
    // This first line looks something like:<br>
    // {@code "[ 00-00 00:00:00.000 <pid>:0x<???> <severity>/<tag>]"}
    // <br>
    // Note: severity is one of V, D, I, W, E, A? or F. However, there doesn't seem to be
    //       a way to actually generate an A (assert) message. Log.wtf is supposed to generate
    //       a message with severity A, however it generates the undocumented F level. In
    //       such a case, the parser will change the level from F to A.<br>
    // Note: the fraction of second value can have any number of digit.<br>
    // Note: the tag should be trimmed as it may have spaces at the end.
    RX_LogHeaderPattern = '^\[\s(\d\d-\d\d\s\d\d:\d\d:\d\d\.\d+)\s+(\d*):\s*(\S+)\s([VDIWEAF])\/(.*)\]$';
  public
    constructor Create;
    function ProcessLogLines(const [ref] Lines: TArray<string>; Device: IDevice): TList<TLogcatMessage>;
  end;

  TFilterExclude = (&is, pid, app, tag, text);
  TFilterExcludes = set of TFilterExclude;
  /// A Filter for logcat messages. A filter can be constructed to match
  /// different fields of a logcat message. It can then be queried to see if
  /// a message matches the filter's settings.
  TLogcatFilter = class sealed
  private const
    RX_QUERY = '((?<prefix>-?)(?<key>age|is|level|message|package|tag|pid)(?<postfix>[=~]?):)(?<value>.+?(?=\s(?:-?(?:age|is|level|message|package|tag|pid)[=~]?:)|$))?';
    RX_ORIG  = '(?>(?:\x{5E}\x{5C}\x{51})|(?:\x{5C}\x{51})|^)(?<regex>.+?(?=(?:\x{5C}\x{45}\x{24})|(?:\x{5C}\x{45}))|$)';
  private const
    LEVEL_KEYWORD     = 'level';
    PID_KEYWORD       = 'pid';
    PACKAGE_KEYWORD   = 'package';
    TAG_KEYWORD       = 'tag';
    MESSAGE_KEYWORD   = 'message';
  private
    FName     : string;
    FTag      : string;
    FText     : string;
    FPid      : string;
    FAppName  : string;
    FIs       : string;
    FLogLevel : TLogLevel;

    FExcludes: TFilterExcludes;

    FCheckPid     : boolean;
    FCheckAppName : boolean;
    FCheckTag     : boolean;
    FCheckText    : boolean;
    FCheckIs      : boolean;

    FAppNamePattern : TRegEx;
    FTagPattern     : TRegEx;
    FTextPattern    : TRegEx;
  private

    // Obtain the flags to pass to {@link Pattern#compile(String, int)}. This method
    // tries to figure out whether case sensitive matching should be used. It is based on
    // the following heuristic: if the regex has an upper case character, then the match
    // will be case sensitive. Otherwise it will be case insensitive.
    function GetPatternCompileFlags(RegEx: string): TRegExOptions;

    function IsNeg: boolean;
  public

    // Construct a filter with the provided restrictions for the logcat message. All the text
    // fields accept Java regexes as input, but ignore invalid regexes.
    // @param name name for the filter
    // @param tag value for the logcat message's tag field.
    // @param text value for the logcat message's text field.
    // @param pid value for the logcat message's pid field.
    // @param appName value for the logcat message's app name field.
    // @param logLevel value for the logcat message's log level. Only messages of
    // higher priority will be accepted by the filter.
    constructor Create(Name, Tag, Text, Pid, AppName, &Is: string; LogLevel: TLogLevel; Excludes: TFilterExcludes = []);


    // Construct a list of {@link LogCatFilter} objects by decoding the query.
    // @param query encoded search string. The query is simply a list of words (can be regexes)
    // a user would type in a search bar. These words are searched for in the text field of
    // each collected logcat message. To search in a different field, the word could be prefixed
    // with a keyword corresponding to the field name. Currently, the following keywords are
    // supported: "pid:", "tag:" and "text:". Invalid regexes are ignored.
    // @param minLevel minimum log level to match
    // @return list of filter settings that fully match the given query
    class function FromString(Query: string; MinLevel: TLogLevel): TList<TLogcatFilter>; static;

    property Name      : string read FName;
    property Tag       : string read FTag;
    property Text      : string read FText;
    property Pid       : string read FPid;
    property AppName   : string read FAppName;
    property LogLevel  : TLogLevel read FLogLevel;

    // Check whether a given message will make it through this filter.
    // @param m message to check
    // @return true if the message matches the filter's conditions.
    function Matches(const [ref] M: TLogcatMessage): boolean; overload;

    class function Matches(const [ref] Filters: TArray<TLogcatFilter>; const [ref] M: TLogcatMessage): boolean; overload; static;
  end;

  TLogcatReceiverTask = class(TInterfacedObject, ILogcatReceiverTask)
  private const
    LOGCAT_COMMAND = 'logcat -v long';
    DEVICE_POOL_INTERVAL_MSEC = 1000;
  private
    class var DeviceDisconnectedMsg : TLogcatMessage;
    class var ConnectionTimeoutMsg  : TLogcatMessage;
    class var ConnectionErrorMsg    : TLogcatMessage;

    class constructor Ceeate;
  private
    class function ErrorMessage(Msg: string): TLogcatMessage; static;

  private type
    TLogcatOutputReceiver = class(TMultiLineReceiver)
    private
      FOwner: TLogcatReceiverTask;

      procedure ProcessLogLines(const [ref] Lines: TArray<string>);
    public
      constructor Create(AOwner: TLogcatReceiverTask);

      //IShellOutputReceiver
      function IsCancelled: boolean; override;

      procedure ProcessNewLines(const [ref] Lines: TArray<string>); override;
    end;

  private
    FDevice: IDevice;
    FReceiver: IShellOutputReceiver;
    FParser: TLogcatMessageParser;
    FCancelled: TAtomicBoolean;
    FListeners: TThreadList<ILogcatListener>;

    procedure NotifyListeners(const [ref] Messages: TArray<TLogcatMessage>);
  public
    constructor Create(Device: IDevice);
    destructor Destroy; override;

    //IRunnable
    procedure Run;

    //ILogcatReceiverTask
    procedure Stop;
    procedure AddLogcatListener(Listener: ILogcatListener);
    procedure RemoveLogcatListener(Listener: ILogcatListener);
  end;


implementation

uses
    adb.Device
  ;

{$REGION 'TLogcatMessage' }

constructor TLogcatMessage.New(ALogLevel: TLogLevel; APid, ATid, AAppName, ATag, ATime, AMessage: string);
begin
  FLogLevel := ALogLevel;
  FPid      := APid;
  FAppName  := AAppName;
  FTag      := ATag;
  FTime     := ATime;
  FMessage  := AMessage;

  // Thread id's may be in hex on some platforms.
  // Decode and store them in radix 10.
  var tidValue := StrToInt64Def(ATid, -1);
  FTid := tidValue.ToString;
end;

function TLogcatMessage.ToString: string;
begin
  result := FTime + ': '+#9
              + FAppName+#9
              + FLogLevel.GetPriorityLetter + '/'
              + FTag + '('
              + FPid + '): '+#9
              + FMessage;
end;

function TLogcatMessage.TryToTime(out AResult: TDateTime): boolean;
begin
  result := TRegEx.IsMatch(FTime, '(?<m>\d\d)-(?<d>\d\d)\s(?<h>\d\d):(?<n>\d\d):(?<s>\d\d)\.(?<z>\d+)');
  if result then
  begin
    var Match := TRegEx.Match(FTime, '(?<m>\d\d)-(?<d>\d\d)\s(?<h>\d\d):(?<n>\d\d):(?<s>\d\d)\.(?<z>\d+)');
    AResult := EncodeDateTime(Now.GetYear,
                             Match.Groups['m'].Value.ToInteger,
                             Match.Groups['d'].Value.ToInteger,
                             Match.Groups['h'].Value.ToInteger,
                             Match.Groups['n'].Value.ToInteger,
                             Match.Groups['s'].Value.ToInteger,
                             Match.Groups['n'].Value.ToInteger);
  end;
end;

{$ENDREGION}

{$REGION 'TLogLevelHelper' }

class function TLogLevelHelper.GetByLetterString(Letter: string): TLogLevel;
begin
  if S_VERBOSE.StartsWith(Letter.ToLower) then
    exit(TLogLevel.VERBOSE);
  if S_DEBUG.StartsWith(Letter.ToLower) then
    exit(TLogLevel.DEBUG);
  if S_INFO.StartsWith(Letter.ToLower) then
    exit(TLogLevel.INFO);
  if S_WARN.StartsWith(Letter.ToLower) then
    exit(TLogLevel.WARN);
  if S_ERROR.StartsWith(Letter.ToLower) then
    exit(TLogLevel.ERROR);
  if S_ASSERT.StartsWith(Letter.ToLower) then
    exit(TLogLevel.ASSERT);

  result := TLogLevel.NONE;
end;

class function TLogLevelHelper.GetByString(Value: string): TLogLevel;
begin
  result := GetByLetterString(Value.Chars[0]);
end;

function TLogLevelHelper.GetPriority: integer;
begin
  result := ord(self);
end;

function TLogLevelHelper.GetPriorityLetter: Char;
begin
  case self of
    NONE:     result := 'N';
    VERBOSE:  result := 'V';
    DEBUG:    result := 'D';
    INFO:     result := 'I';
    WARN:     result := 'W';
    ERROR:    result := 'E';
    ASSERT:   result := 'A';
  else
              result := ' ';
  end;
end;

function TLogLevelHelper.GetStringValue: string;
begin
  case self of
    NONE:     result := 'none';
    VERBOSE:  result := 'verbose';
    DEBUG:    result := 'debug';
    INFO:     result := 'info';
    WARN:     result := 'warn';
    ERROR:    result := 'error';
    ASSERT:   result := 'assert';
  else
              result := ' ';
  end;
end;

{$ENDREGION}

{$REGION 'TLogcatMessageParser' }

constructor TLogcatMessageParser.Create;
begin
  FCurLogLevel := TLogLevel.WARN;
  FCurPid   := '?';
  FCurTid   := '?';
  FCurTag   := '?';
  FCurTime  := '?:??';
end;

function TLogcatMessageParser.ProcessLogLines(const [ref] Lines: TArray<string>; Device: IDevice): TList<TLogcatMessage>;
begin
  result := TList<TLogcatMessage>.Create;

  for var Line in Lines do
  begin
    if Line.IsEmpty then
      continue;

    if TRegEx.IsMatch(Line, RX_LogHeaderPattern) then
    begin
      var Match := TRegEx.Match(Line, RX_LogHeaderPattern);
      FCurTime      := Match.Groups[1].Value;
      FCurPid       := Match.Groups[2].Value;
      FCurTid       := Match.Groups[3].Value;
      FCurLogLevel  := TLogLevel.GetByLetterString(Match.Groups[4].Value);
      FCurTag       := Match.Groups[5].Value.Trim;

      // LogLevel doesn't support messages with severity "F". Log.wtf() is supposed
      // to generate "A", but generates "F".
      if (FCurLogLevel = TLogLevel.NONE) and (Match.Groups[4].Value.Equals('F')) then
        FCurLogLevel := TLogLevel.ASSERT;
    end
    else
    begin
      var PkgName := string.Empty; //$NON-NLS-1$
      var pid: integer := 0;
      if Integer.TryParse(FCurPid, pid) and (Device <> nil) then
        PkgName := Device.GetClientName(pid);

      var m := TLogcatMessage.New(FCurLogLevel, FCurPid, FCurTid, PkgName, FCurTag, FCurTime, Line);
      Result.Add(m);
    end;
  end;
end;

{$ENDREGION}

{$REGION 'TLogcatFilter' }

constructor TLogcatFilter.Create(Name, Tag, Text, Pid, AppName, &Is: string; LogLevel: TLogLevel; Excludes: TFilterExcludes);
begin
  FName     := Name.Trim;
  FTag      := Tag.Trim;
  FText     := Text.Trim;
  FPid      := Pid.Trim;
  FAppName  := AppName.Trim;
  FIs       := &Is.Trim;
  FLogLevel := LogLevel;
  FExcludes := Excludes;

  FCheckAppName := false;
  FCheckTag     := false;
  FCheckText    := false;
  FCheckIs      := false;

  FCheckPid := not FPid.IsEmpty;
  FCheckIs  :=  not FIs.IsEmpty;

  if not FAppName.IsEmpty then
    try
      FAppNamePattern := TRegEx.Create(FAppName, GetPatternCompileFlags(FAppName));
      FCheckAppName := true;
    except
      on E: Exception do
        FCheckAppName := false;
    end;

  if not FTag.IsEmpty then
    try
      FTagPattern := TRegEx.Create(FTag, GetPatternCompileFlags(FTag));
      FCheckTag := true;
    except
      on E: Exception do
        FCheckTag := false;
    end;

  if not FText.IsEmpty then
    try
      FTextPattern := TRegEx.Create(FText, GetPatternCompileFlags(FText));
      FCheckText := true;
    except
      on E: Exception do
        FCheckText := false;
    end;
end;

class function TLogcatFilter.FromString(Query: string; MinLevel: TLogLevel): TList<TLogcatFilter>;

  function TryGetGroupValue(const [ref] Match: TMatch; const GroupName: string; out Value: string): boolean;
  begin
    var g: TGroup;
    if Match.Groups.TryGetNamedGroup(GroupName, g) then
    begin
      Value := g.Value.Trim;
      exit(true);
    end;

    value  := string.Empty;
    result := false;
  end;

begin
  if Query.Trim.IsEmpty and (MinLevel = TLogLevel.NONE) then
    exit(nil);

  result := TObjectList<TLogcatFilter>.Create;

  if Query.Trim.IsEmpty then
  begin
    result.Add(TLogcatFilter.Create('Livefilter-onlyMin', '', '', '', '', '', MinLevel));
    exit;
  end;

  var RXQuery := TRegEx.Create(RX_QUERY, [TRegExOption.roIgnoreCase]);
  var Matches := RXQuery.Matches(Query);
  if Matches.Count = 0 then
  begin
    result.Add(TLogcatFilter.Create('Livefilter-'+query, '', query, '', '', '', MinLevel));
    exit;
  end;

  for var Match in Matches do
  begin
    var MatchName := Match.Value;
    var key     := string.Empty;
    var prefix  := string.Empty;
    var postfix := string.Empty;

    var value   := string.Empty;

    var IsNeg := false;
    var IsEqu := false;
    var IsReg := false;

    key := Match.Groups['key'].Value;
    TryGetGroupValue(Match, 'value', value);
    TryGetGroupValue(Match, 'prefix', prefix);
    TryGetGroupValue(Match, 'postfix', postfix);

    IsNeg := prefix.Equals('-');
    IsEqu := postfix.Equals('=');
    IsReg := postfix.Equals('~');

    if isReg then
      value := value.Trim
    else
    if (not key.Equals(PID_KEYWORD)) and (not (key.Equals(LEVEL_KEYWORD))) then
    begin
      if isEqu then
        value := '^\Q'+value+'\E$'
      else
        value := '\Q'+value+'\E';
    end;

    var tag   : string  := '';
    var text  : string  := '';
    var pid   : string  := '';
    var app   : string  := '';
    var &is   : string  := '';
    var exl   : TFilterExcludes := [];

    if key.Equals(PID_KEYWORD) then
    begin
      pid := value;
      if IsNeg then
        include(exl, TFilterExclude.pid);
    end
    else if key.Equals(PACKAGE_KEYWORD) then
    begin
      app := value;
      if IsNeg then
        include(exl, TFilterExclude.app);
    end
    else if key.Equals(TAG_KEYWORD) then
    begin
      tag := value;
      if IsNeg then
        include(exl, TFilterExclude.tag);
    end
    else if key.Equals(MESSAGE_KEYWORD) then
    begin
      text := value;
      if IsNeg then
        include(exl, TFilterExclude.text);
    end
    else if key.Equals(LEVEL_KEYWORD) then
    begin
      &is := value;
      if IsNeg then
        include(exl, TFilterExclude.is);
    end;

    result.Add(TLogcatFilter.Create('Livefilter-'+MatchName, tag, text, pid, app, &is, MinLevel, exl));
  end;

  result.Sort(TComparer<TLogcatFilter>.Construct(
    function(const Left, Right: TLogcatFilter): Integer
    begin
      var L := Left.IsNeg.ToInteger;
      var R := Right.IsNeg.ToInteger;

      if L > R then exit(1);
      if L < R then exit(-1);
      result := 0;
    end
    ));
end;

function TLogcatFilter.GetPatternCompileFlags(RegEx: string): TRegExOptions;
begin
  result := [TRegExOption.roCompiled];

  var LRegEx := RegEx;
  var Match := TRegEx.Match(RegEx, RX_ORIG);
  if Match.Success then
    LRegEx := Match.Groups['regex'].Value;

  for var c in LRegEx.ToCharArray do
    if c.IsUpper then
      exit;

  Include(result, TRegExOption.roIgnoreCase);
end;

function TLogcatFilter.IsNeg: boolean;
begin
  result := FExcludes <> [];
end;

class function TLogcatFilter.Matches(const [ref] Filters: TArray<TLogcatFilter>; const [ref] M: TLogcatMessage): boolean;
begin
  if Length(Filters) = 0 then
    exit(true);

  for var I := 0 to length(Filters) - 1 do
  begin
    var F := Filters[I];
    if I = 0 then
      result := F.Matches(M)
    else
    begin
      if F.IsNeg then
        result := result and F.Matches(M)
      else
        result := result or F.Matches(M);
    end;
  end;
end;

function TLogcatFilter.Matches(const [ref] M: TLogcatMessage): boolean;
begin
  var IsNotMatch: boolean;
  // filter out messages of a lower priority
  if M.LogLevel.GetPriority < FLogLevel.GetPriority then
    exit(false);

  if FCheckIs then
  begin
    if TFilterExclude.is in FExcludes then
      IsNotMatch := (M.LogLevel.GetPriorityLetter.ToUpper = FIs.ToUpper) or (M.LogLevel.GetStringValue.ToUpper.Equals(FIs.ToUpper))
    else
      IsNotMatch := not ((M.LogLevel.GetPriorityLetter.ToUpper = FIs.ToUpper) or (M.LogLevel.GetStringValue.ToUpper.Equals(FIs.ToUpper)));

    if IsNotMatch then
      exit(false);
  end;

  // if pid filter is enabled, filter out messages whose pid does not match
  // the filter's pid
  if FCheckPid then
  begin
    if TFilterExclude.pid in FExcludes then
      IsNotMatch := M.Pid.Equals(FPid)
    else
      IsNotMatch := not M.Pid.Equals(FPid);

    if IsNotMatch then
      exit(false);
  end;

  // if app name filter is enabled, filter out messages not matching the app name
  if FCheckAppName then
  begin
    if TFilterExclude.app in FExcludes then
      IsNotMatch := FAppNamePattern.IsMatch(M.AppName)
    else
      IsNotMatch := not FAppNamePattern.IsMatch(M.AppName);

    if IsNotMatch then
      exit(false);
  end;

  // if tag filter is enabled, filter out messages not matching the tag
  if FCheckTag then
  begin
    if TFilterExclude.tag in FExcludes then
      IsNotMatch := FTagPattern.IsMatch(M.Tag)
    else
      IsNotMatch := not FTagPattern.IsMatch(M.Tag);

    if IsNotMatch then
      exit(false);
  end;

  if FCheckText then
  begin
    if TFilterExclude.text in FExcludes then
      IsNotMatch := FTextPattern.IsMatch(M.Message)
    else
      IsNotMatch := not FTextPattern.IsMatch(M.Message);

    if IsNotMatch then
      exit(false);
  end;

  result := true;
end;

{$ENDREGION}



{ TLogcatReceiverTask }

procedure TLogcatReceiverTask.AddLogcatListener(Listener: ILogcatListener);
begin
  FListeners.Add(Listener);
end;

class constructor TLogcatReceiverTask.Ceeate;
begin
  DeviceDisconnectedMsg := ErrorMessage('Device disconnected: 1');
  ConnectionTimeoutMsg  := ErrorMessage('Logcat Connection timed out');
  ConnectionErrorMsg    := ErrorMessage('Logcat Connection error');
end;

constructor TLogcatReceiverTask.Create(Device: IDevice);
begin
  FDevice := Device;

  FReceiver := TLogcatOutputReceiver.Create(self) as IShellOutputReceiver;
  FParser   := TLogcatMessageParser.Create;
  FCancelled.Exchange(false);

  FListeners := TThreadList<ILogcatListener>.Create;
end;

destructor TLogcatReceiverTask.Destroy;
begin
  Stop;
  FListeners.Clear;
  FListeners.Free;
  inherited;
end;

class function TLogcatReceiverTask.ErrorMessage(Msg: string): TLogcatMessage;
begin
  result := TLogcatMessage.New(TLogLevel.ERROR, string.Empty, string.Empty, string.Empty, string.Empty, Now.Format('mm-dd hh:nn:ss.zzz'), Msg);
end;

procedure TLogcatReceiverTask.NotifyListeners(const [ref] Messages: TArray<TLogcatMessage>);
begin
  var List := FListeners.LockList;
  try
    for var Listener in List do
      Listener.Log(Messages);
  finally
    FListeners.UnlockList;
  end;
end;

procedure TLogcatReceiverTask.RemoveLogcatListener(Listener: ILogcatListener);
begin
  FListeners.Remove(Listener);
end;

procedure TLogcatReceiverTask.Run;
begin
  // wait while device comes online
  while not FDevice.IsOnline do
  begin
    try
      TThread.Current.Sleep(DEVICE_POOL_INTERVAL_MSEC)
    except
      on E: Exception do
        exit;
    end;
  end;

  try
    TDevice(FDevice).ExecuteShellCommand(LOGCAT_COMMAND, FReceiver, 1000);
  except
    on E: Exception do
    {$MESSAGE WARN 'TODO LogcatReceiverTask'}
  end;

  NotifyListeners([DeviceDisconnectedMsg]);
end;

procedure TLogcatReceiverTask.Stop;
begin
  FCancelled.Exchange(true);
end;

{ TLogcatReceiverTask.TLogcatOutputReceiver }

constructor TLogcatReceiverTask.TLogcatOutputReceiver.Create(AOwner: TLogcatReceiverTask);
begin
  inherited Create;
  FOwner := AOwner;
  SetTrimLine(false);
end;

function TLogcatReceiverTask.TLogcatOutputReceiver.IsCancelled: boolean;
begin
  result := FOwner.FCancelled.Get;
end;

procedure TLogcatReceiverTask.TLogcatOutputReceiver.ProcessLogLines(const [ref] Lines: TArray<string>);
begin
  var NewMessages := FOwner.FParser.ProcessLogLines(Lines, FOwner.FDevice);
  try
    if not NewMessages.IsEmpty then
      FOwner.NotifyListeners(NewMessages.ToArray);
  finally
    NewMessages.Free;
  end;
end;

procedure TLogcatReceiverTask.TLogcatOutputReceiver.ProcessNewLines(const [ref] Lines: TArray<string>);
begin
  if not FOwner.FCancelled.Get then
    ProcessLogLines(Lines);
end;

end.
