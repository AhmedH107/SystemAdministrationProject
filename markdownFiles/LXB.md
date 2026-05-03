

## Introduktion till man - [LXB.1](https://www.ida.liu.se/~TDDI41/2025/uppgifter/lxb/index.sv.shtml#lxb.1)

1. Vilka är de 9 avsnitten?

svar:

1 Exekverbara program eller skalkommandon

2 Systemanrop (funktioner som tillhandahålls av kerneln)

3 Biblioteksanrop (funktioner i programbibliotek)

4 Speciella filer (hittas vanligtvis i /dev)

5 Filformat och konventioner t.ex. /etc/passwd

6 Spel

7 Diverse (inklusive makropaket och konventioner), t.ex. man(7), groff(7)

8 Kommandon för systemadministration (vanligtvis bara för root)

9 Kernelrutiner [Icke-standard]

2. Vilket avsnitt dokumenterar kommandoradsverktyg så som cat eller ls?

svar:

I avsnitt ett.

## Introduktion till rör - [LXB.2](https://www.ida.liu.se/~TDDI41/2025/uppgifter/lxb/index.sv.shtml#lxb.2)

Kör journalctl, och med hjälp av tail visa bara de sista 5 raderna.

svar:

```console 
journalctl | tail -n 5
Sep 04 16:43:34 debian systemd[1]: apt-daily-upgrade.service: Succeeded.
Sep 04 16:43:34 debian systemd[1]: Finished Daily apt upgrade and clean activities.
Sep 04 16:45:23 debian systemd[1]: Starting Cleanup of Temporary Directories...
Sep 04 16:45:23 debian systemd[1]: systemd-tmpfiles-clean.service: Succeeded.
Sep 04 16:45:23 debian systemd[1]: Finished Cleanup of Temporary Directories.
root@debian:~# ^C
```
## Justering av filrättigheter - [LXB.3](https://www.ida.liu.se/~TDDI41/2025/uppgifter/lxb/index.sv.shtml#lxb.3)

1. Hur byter man ägare på en fil?

    svar:

    Genom kommandon sudo och chown, likt: “sudo chown grupp-som-ska-bli-ägare fil-som-ska-byta-ägare”

2. Hur gör man en fil körbar enbart för dess grupp?

    svar: 

    Genom kommandot => chmod g(group)+x(execute permission) fil. Utöver att ge den nya gruppen execute permission måste vi se till att ta bort execute permission från alla andra grupper först. Kan göras genom kommandot chmod a-x fil
    
## Arkivering och komprimering med tarballs - [LXB.4](https://www.ida.liu.se/~TDDI41/2025/uppgifter/lxb/index.sv.shtml#lxb.4)

1. Hur packar man upp en .tar.gz fil?

	svar: 

    Genom kommandot => tar -xzvf filnamn.tar.gz

2. Hur packar man ner en mapp i en .tar.xz fil?

    svar: 

    Genom kommandot => tar -cJvf namn.tar.xz mappen

## Miljövariabler - [LXB.5](https://www.ida.liu.se/~TDDI41/2025/uppgifter/lxb/index.sv.shtml#lxb.5)

svar: 

Jag öppnade min  .bashrc fil med emacs och la in “export PATH=$PATH:/courses/TDDI41” i filen. Då gick det att köra start_single.sh direkt från min hemkatalog. 
    
Man(1) är nu skriven i svenska då jag kör in: 
echo $LC_ALL
export LC_ALL= sv_SE.utf-8
man man

##  Introduktion till systemd - [LXB.6](https://www.ida.liu.se/~TDDI41/2025/uppgifter/lxb/index.sv.shtml#lxb.6)

1. Hur får man en lista över alla systemd-enheter (units)?

    svar: Genom kommandot systemctl. Man kan lägga till -state:active så kan man visa de units som är enbarts aktiva i stunden.

2. Hur startar man om sin ssh-server (starta systemtjänsten)?

    svar: Genom kommandot => sudo systemctl restart sshd

## systemloggar - [LXB.7](https://www.ida.liu.se/~TDDI41/2025/uppgifter/lxb/index.sv.shtml#lxb.7)

svar: 

```console 
root@debian:/var/log# sudo grep sshd /var/log/auth.log
....
Sep  4 18:07:53 debian sshd[374]: Accepted password for root from 10.0.2.2 port 58802 ssh2
Sep  4 18:07:53 debian sshd[374]: pam_unix(sshd:session): session opened for user root(uid=0) by (uid=0)

```

## SSH-nycklar för autentisering - [LXB.8](https://www.ida.liu.se/~TDDI41/2025/uppgifter/lxb/index.sv.shtml#lxb.8)

1. skapa en ed25519-nyckel som ni ger ett namn i stil med ~/.ssh/id-sysadminkurs-ed25519

Svar:

```console
ahmha095@su17-212:~/.ssh$ ssh-keygen -t ed25519
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/ahmha095/.ssh/id_ed25519): /home/ahmha095/.ssh/id-sysadminkurs-ed25519
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/ahmha095/.ssh/id-sysadminkurs-ed25519
Your public key has been saved in /home/ahmha095/.ssh/id-sysadminkurs-ed25519.pub
The key fingerprint is:
SHA256:XqmvjLn7GHrwGDEQJDKE5xygLSQKEgDyepvKfNzaRTk ahmha095@su17-212.ad.liu.se
The key's randomart image is:
+--[ED25519 256]--+
|^*o.             |
|@=+              |
|++oo             |
| oo o   .  .     |
|. .  o ES o      |
| . oo ...o       |
|  + .=..o        |
|o. ooo+* .       |
|.o..oo*++..      |
+----[SHA256]-----+
ahmha095@su17-212:~/.ssh$ 
```

2. Ange vilken fil som innehåller den publika delen av nyckeln.

Svar: id-sysadminkurs-ed25519.pub



3. Se till att man kan använda den för att logga in som root inuti VM:en. Visa upp relevant authorized_keys-fil

```console
root@debian:~/.ssh# cat authorized_keys 
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICKg33NxNKHZ11dta6kmtrHIScq821miXziG5qVFpQjC ahmha095@su17-212.ad.liu.se
```

4. Starta en ssh-agent och ladda in nyckeln. Ni kan skapa ett skript med detta för enkelhets skull.

```console
ahmha095@su17-212:~/Desktop$ ssh-add ~/.ssh/id-sysadminkurs-ed25519
Enter passphrase for /home/ahmha095/.ssh/id-sysadminkurs-ed25519: 
Identity added: /home/ahmha095/.ssh/id-sysadminkurs-ed25519 (ahmha095@su17-212.ad.liu.se)
ahmha095@su17-212:~/Desktop$ 
ahmha095@su17-212:~/Desktop$ ssh-add -L
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICKg33NxNKHZ11dta6kmtrHIScq821miXziG5qVFpQjC ahmha095@su17-212.ad.liu.se
ahmha095@su17-212:~/Desktop$ 


ahmha095@su17-212:~/Desktop$ start_single.sh
You can access your router using ssh root@127.0.0.1 -p 2220 (password as password)


ahmha095@su17-212:~$ ssh root@127.0.0.1 -p 2220
Linux debian 5.10.0-25-amd64 #1 SMP Debian 5.10.191-1 (2023-08-16) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Mon Sep  8 10:16:05 2025 from 10.0.2.2
root@debian:~# 


```



