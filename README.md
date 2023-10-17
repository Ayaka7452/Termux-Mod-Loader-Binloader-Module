# Termux-Mod-Loader-Binloader-Module
A binloader mod that provides interfaces to inject files to Termux app
## Installation
Installs it using universal binloader mod installation method. see binloader repository guide to get more info
## Usage
Usage: termod [Options] [Param]<br>
install - installs a tmod<br>
remove - removes a tmod<br>
patch - perform patch<br>
ls - lists exist pkgs<br>
inject - inject files to termux<br>
help - show help screen<br>
Powered by Ayaka7452<br>
## Make a Patch Package
### Package Structure
─ patch_1.0 [folder]<br />
----programs [folder] ---- custom_applet<br />
----programs [folder] ---- patch.sh [termod will executing this script while patching]<br>
----pkginfo [file]<br />
### pkginfo File Content
Total 4 tags of this metadata file, they are:<br />
pkgname=[Name_of_Patch]
pkgtype=[tmod] ---- default value 'tmod', used to differentiate to other package
version=[PATCH_VERSION]
restorable=[False] ---- some patches can restore unless reseting Termux app, then give it False
## 'inject' Option Usage
Usage: termod+inject+[tmodid]+[execname/path]+[target_folder(bin, lib, etc)]+[mode_code]
For mode_code: 0 - injecting mode; 1 - removing mode.
## About
This is a command-line utility which is working at binloader environment, it has been tested working fine with Magisk v26.3 and Android 13. But still, this utility does NOT responsible for any losses by using this program, please use it at your own risk.
