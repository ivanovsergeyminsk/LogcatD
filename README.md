# Android Logcat for RAD Studio

### 1. [About the project](#about)
### 2. [Depends](#depends)
### 3. [ToDo](#todo)
### 4. [How to install](#how_to_install)
### 5. [Bugs and Features](#bugs_features)
## About the project
<a name="about"></a>
When developing an Android application, it is often necessary to view system, service and other logs. RAD Studio IDE does not provide us with such a tool. Therefore, we had two options:

1. [Logcat](https://developer.android.com/tools/logcat) is a command-line tool;
2. [Logcat window](https://developer.android.com/studio/debug/logcat) in Android Studio IDE.

The first option is a command line tool and it is not very convenient to analyze logs. The second option requires us to install the Android Studio IDE. And you must agree that installing Android Studio for the sake of just one Logcat window is a bit redundant.

That's why this project was born, which solves this problem - **Android Logcat for RAD Studio** extension.
With this extension, you can analyze logs in the RAD Studio development environment almost as well as in Android Studio, without having to install the latter.

![image](https://github.com/ivanovsergeyminsk/LogcatD/assets/25233737/fef86f2b-a5d6-4f10-9533-e8ba9a203956)

After installing the extension, you can find the tool in the menu:
  View->Tool Windows->Android Logcat

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

[AndoridLogcat.mp4](https://github.com/ivanovsergeyminsk/LogcatD/assets/25233737/d2f6ba57-ae70-4681-aaac-95846ed815e0)

## Depends
<a name="depends"></a>
The project depends on two third-party libraries:
  
  1. SVGIconImageList
  2. VirtualTree

You can install them from GetIt - library repository in RAD Studio

## ToDo
<a name="todo"></a>
```
Define a limit on the number of stored messages in memory
```
## How to install
<a name="how_to_install"></a>
### 1. Install the **SVGIconImageList** and **VirtualTree** libraries
Open *Tools->GetIt Package Manager...*
![image](https://github.com/ivanovsergeyminsk/LogcatD/assets/25233737/f53968c6-00e9-4c54-86ae-a0ea18ca5329)

Type "SVGIconImageList" into the search bar
![image](https://github.com/ivanovsergeyminsk/LogcatD/assets/25233737/91b538e4-5bc6-4f1c-bf43-f41cdd2a35cb)

Click the "Install" button and follow the instructions
![image](https://github.com/ivanovsergeyminsk/LogcatD/assets/25233737/98d7f82e-9729-4c4b-9dbe-73a8f5afb834)

Type "VirtualTree" into the search bar and click the "Install" button and follow the instructions
![image](https://github.com/ivanovsergeyminsk/LogcatD/assets/25233737/11fa098e-db03-4751-8e0b-512635336010)

### 2. Build and install an extension
Open the *Logcat.dpk* project.

In the "Projects" tool window, right-click on "Logcat.bpl" and click on "Install" in the menu that appears
![image](https://github.com/ivanovsergeyminsk/LogcatD/assets/25233737/a25bdf52-2e9a-4b76-8a31-6e3d174ec9e6)

#### After installing the extension, you can find the tool in the menu: *View->Tool Windows->Android Logcat*

## Bugs and Features
<a name="bugs_features"></a>
If you find bugs or want to add features to the project, use GitHub's "Issues" and "Pull requests" tools.

### *Let's make RAD Studio better! let's make the World a better place!*
