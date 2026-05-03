## Virtuella maskiner: 'Guest' vs 'Host'- [QEMU.1](https://www.ida.liu.se/~TDDI41/2025/uppgifter/qemu/index.sv.shtml#qemu.1)

1. Vilken/Vilka är gästmaskinerna?

   Gästmaskinen är den virtuella datorn som körs virtuellt på hårdvaran/operativsystemet på värdmaskinen.

2. Vilken/Vilka är värdmaskinerna?

   Värdmaskinen är enheten som tillhandahåller den virtuella maskinerna. Den allokerar resurser såsom minne till gäst maskinen.

## Kopiera mellan gäst- och värdmaskiner - [QEMU.2](https://www.ida.liu.se/~TDDI41/2025/uppgifter/qemu/index.sv.shtml#qemu.2)

1.  Hur kopierade ni filen /etc/network/interfaces från VM:en till er hemkatalog?

 Med hjälp av kommandot scp i själva VM:en, likt:

```console 
root@debian:~# scp /etc/network/interfaces ahmha095@ssh.edu.liu.se:~/
Password:
Password:
interfaces 100% 313 171.9KB/s 00:00
```

2.  Hur kopierade ni mappen /etc/default och allt dess innehåll från VM:en till er hemkatalog?

Med hjälp av kommandot scp och flaggan -r likt:

```console
  root@debian:~# scp -r /ect/default ahmha095@ssh.edu.liu.se:~/
```
