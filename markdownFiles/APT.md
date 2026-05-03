
## ahmha095 & felma217
 
## Pakethantering - [APT.1](https://www.ida.liu.se/~TDDI41/2025/uppgifter/apt/index.sv.shtml#apt.1)

1. hur installerar man ett paket?

Svar: 
Sudo apt install paketnamn

2. hur avinstalerar man ett paket?

Svar:
Sudo apt remove paketnamn

3. hur avinstalerar man verkligen ett paket (d.v.s. hur tar man bort paketet och alla dess filer)

Svar:
Sudo apt purge paketnamn

4. Hur får man information om tillgängliga paket och versioner till sitt system?

Svar:
Sudo apt update

5. Hur får man de senaste uppdateringarna (av paket, inte bara information om vad som finns tillgängligt) till sitt system?

Svar:
Sudo apt-get upgrade


## Pakethantering, forts - [APT.2](https://www.ida.liu.se/~TDDI41/2025/uppgifter/apt/index.sv.shtml#apt.2)

1. hur ser man vilka filer som ett paket tillhandahåller?

Svar:
dpkg-query -L paketnamn

2. hur ser man vilket installerat paket som tillhandahåller en fil? Vilket installerat paket tillhandahåller filen /usr/bin/perldoc i VM:en?

Svar:
Perl

```console
root@debian:~# dpkg-query -S /usr/bin/perldoc
perl: /usr/bin/perldoc
root@debian:~# 
```

## Paketinstallation - [APT.3](https://www.ida.liu.se/~TDDI41/2025/uppgifter/apt/index.sv.shtml#apt.3)

1. Installera paketet cowsay

Svar:

```console
root@debian:~# sudo apt install cowsay
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following package was automatically installed and is no longer required:
  linux-image-5.10.0-13-amd64
Use 'sudo apt autoremove' to remove it.
```

2. Verifiera att det är instalerat, och testkör cowsay

Svar:

```console
root@debian:~# dpkg-query -L cowsay
root@debian:~# /usr/games/cowsay helloWorld
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LANGUAGE = "en_US:en",
	LC_ALL = (unset),
	LC_MESSAGES = "en_GB.UTF-8",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
 ____________
< helloWorld >
 ------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
root@debian:~# 

```

3. Avinstallera cowsay

Svar: 

```console
root@debian:~# apt purge cowsay
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following package was automatically installed and is no longer required:
  linux-image-5.10.0-13-amd64
Use 'apt autoremove' to remove it.
The following packages will be REMOVED:
  cowsay*
0 upgraded, 0 newly installed, 1 to remove and 0 not upgraded.
After this operation, 94.2 kB disk space will be freed.
Do you want to continue? [Y/n] y
apt-listchanges: Can't set locale; make sure $LC_* and $LANG are correct!
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LANGUAGE = "en_US:en",
	LC_ALL = (unset),
	LC_MESSAGES = "en_GB.UTF-8",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
locale: Cannot set LC_MESSAGES to default locale: No such file or directory
locale: Cannot set LC_ALL to default locale: No such file or directory
(Reading database ... 37619 files and directories currently installed.)
Removing cowsay (3.03+dfsg2-8) ...
Processing triggers for man-db (2.9.4-2) ...
root@debian:~# 
```
## Repository-hantering - [APT.4](https://www.ida.liu.se/~TDDI41/2025/uppgifter/apt/index.sv.shtml#apt.4)

1. Hur lägger man till ett nytt repo? Lägg till syncthing-repot ovan. Gör det med en drop-in-fil (sources.list.d, alltså inte apt-add-repository eller annat).

Svar:

```console
root@debian:~# echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable-v2" | sudo tee /etc/apt/sources.list.d/syncthing.list
deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable-v2
root@debian:~# sudo apt-get update
Get:1 http://security.debian.org/debian-security bullseye-security InRelease [27.2 kB]
Get:2 http://deb.debian.org/debian bullseye InRelease [75.1 kB]
Get:3 http://deb.debian.org/debian bullseye-updates InRelease [44.0 kB]
Get:4 https://apt.syncthing.net syncthing InRelease [24.2 kB]
Get:5 http://security.debian.org/debian-security bullseye-security/main Sources [253 kB]
Get:6 http://security.debian.org/debian-security bullseye-security/main amd64 Packages [394 kB]
Get:7 http://security.debian.org/debian-security bullseye-security/main Translation-en [263 kB]
Get:8 http://deb.debian.org/debian bullseye/main Sources [8500 kB]
Get:9 http://deb.debian.org/debian bullseye-updates/main Sources.diff/Index [26.3 kB]
Get:10 http://deb.debian.org/debian bullseye-updates/main amd64 Packages.diff/Index [26.3 kB]
Get:11 http://deb.debian.org/debian bullseye-updates/main Translation-en.diff/Index [12.8 kB]
Get:12 http://deb.debian.org/debian bullseye-updates/main Sources T-2023-12-29-1403.39-F-2023-11-13-2005.21.pdiff [2341 B]
Get:12 http://deb.debian.org/debian bullseye-updates/main Sources T-2023-12-29-1403.39-F-2023-11-13-2005.21.pdiff [2341 B]
Get:13 http://deb.debian.org/debian bullseye-updates/main amd64 Packages T-2023-12-29-1403.39-F-2023-11-13-2005.21.pdiff [2205 B]
Get:13 http://deb.debian.org/debian bullseye-updates/main amd64 Packages T-2023-12-29-1403.39-F-2023-11-13-2005.21.pdiff [2205 B]
Get:14 http://deb.debian.org/debian bullseye-updates/main Translation-en T-2025-07-21-2004.39-F-2023-11-13-2005.21.pdiff [965 B]
Get:14 http://deb.debian.org/debian bullseye-updates/main Translation-en T-2025-07-21-2004.39-F-2023-11-13-2005.21.pdiff [965 B]
Get:15 http://deb.debian.org/debian bullseye/main amd64 Packages [8066 kB]
Err:4 https://apt.syncthing.net syncthing InRelease      
  The following signatures couldn't be verified because the public key is not available: NO_PUBKEY E5665F9BD5970C47 NO_PUBKEY D26E6ED000654A3E
Get:16 http://deb.debian.org/debian bullseye/main Translation-en [6235 kB]
Reading package lists... Done                                  
N: Repository 'http://security.debian.org/debian-security bullseye-security InRelease' changed its 'Suite' value from 'oldstable-security' to 'oldoldstable-security'
N: Repository 'http://deb.debian.org/debian bullseye InRelease' changed its 'Version' value from '11.7' to '11.11'
N: Repository 'http://deb.debian.org/debian bullseye InRelease' changed its 'Suite' value from 'oldstable' to 'oldoldstable'
N: Repository 'http://deb.debian.org/debian bullseye-updates InRelease' changed its 'Suite' value from 'oldstable-updates' to 'oldoldstable-updates'
W: GPG error: https://apt.syncthing.net syncthing InRelease: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY E5665F9BD5970C47 NO_PUBKEY D26E6ED000654A3E
E: The repository 'https://apt.syncthing.net syncthing InRelease' is not signed.
N: Updating from such a repository can't be done securely, and is therefore disabled by default.
N: See apt-secure(8) manpage for repository creation and user configuration details.
root@debian:~# sudo apt-get install syncthing
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following package was automatically installed and is no longer required:
  linux-image-5.10.0-13-amd64
Use 'sudo apt autoremove' to remove it.
The following NEW packages will be installed:
  syncthing
0 upgraded, 1 newly installed, 0 to remove and 111 not upgraded.
Need to get 6774 kB of archives.
After this operation, 20.5 MB of additional disk space will be used.
Get:1 http://deb.debian.org/debian bullseye/main amd64 syncthing amd64 1.12.1~ds1-4 [6774 kB]
Fetched 6774 kB in 0s (69.4 MB/s)
apt-listchanges: Can't set locale; make sure $LC_* and $LANG are correct!
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LANGUAGE = "en_US:en",
	LC_ALL = (unset),
	LC_MESSAGES = "en_GB.UTF-8",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
locale: Cannot set LC_MESSAGES to default locale: No such file or directory
locale: Cannot set LC_ALL to default locale: No such file or directory
Selecting previously unselected package syncthing.
(Reading database ... 37558 files and directories currently installed.)
Preparing to unpack .../syncthing_1.12.1~ds1-4_amd64.deb ...
Unpacking syncthing (1.12.1~ds1-4) ...
Setting up syncthing (1.12.1~ds1-4) ...
Created symlink /etc/systemd/system/sleep.target.wants/syncthing-resume.service → /lib/systemd/system/syncthing-resume.service.
Processing triggers for man-db (2.9.4-2) ...
Processing triggers for mailcap (3.69) ...
```

2. Hur tar man bort ett repo?

Svar:

```console
root@debian:~# sudo apt-get purge syncthing
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following package was automatically installed and is no longer required:
  linux-image-5.10.0-13-amd64
Use 'sudo apt autoremove' to remove it.
The following packages will be REMOVED:
  syncthing*
0 upgraded, 0 newly installed, 1 to remove and 111 not upgraded.
After this operation, 20.5 MB disk space will be freed.
Do you want to continue? [Y/n] y
apt-listchanges: Can't set locale; make sure $LC_* and $LANG are correct!
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LANGUAGE = "en_US:en",
	LC_ALL = (unset),
	LC_MESSAGES = "en_GB.UTF-8",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
locale: Cannot set LC_MESSAGES to default locale: No such file or directory
locale: Cannot set LC_ALL to default locale: No such file or directory
(Reading database ... 37598 files and directories currently installed.)
Removing syncthing (1.12.1~ds1-4) ...
Processing triggers for mailcap (3.69) ...
Processing triggers for man-db (2.9.4-2) ...
(Reading database ... 37559 files and directories currently installed.)
Purging configuration files for syncthing (1.12.1~ds1-4) ...
root@debian:~# 
```

