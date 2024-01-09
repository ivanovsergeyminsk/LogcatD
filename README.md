An extension for RAD Studio that displays logs of android devices

The project depends on:
  1. SVGIconImageList (GetIt)
  2. VirtualTree (GetIt)

After installing the package, you can find the tool in the menu:
  View->Tool Windows->Android Logcat

![image](https://github.com/ivanovsergeyminsk/LogcatD/assets/25233737/a453a3f7-280f-4a32-a872-1311de26f2d5)

You can use the following filters:
| Key      | Description                  |
|----------|------------------------------|
| pid:     | filter by pid                |
| package: | package name contain strings |
| tag:     | log tag contains string      |
| message: | log message contains string  |
| level:   | filter by min log level      |

Add *-* to a key to exclude logs with the value (such as, "*-tag:*").

Add *~* to use regex (such as, "*tag~:*" and "*-tag~:*").

Terms with the same key commbine with OR "*tag:foo tag:bar*" means "foo OR bar".

Negated terms combine with AND "*-tag:foo -tag:bar*" means "!foo AND !bar"

You can combine keys: *-level:i -package:libc tag:native*

```
TODO: Define a limit on the number of stored messages in memory
```
