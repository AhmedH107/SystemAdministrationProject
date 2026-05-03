## ahmha095


## Kommando för filsystem [STO.1](https://www.ida.liu.se/~TDDI41/2025/uppgifter/sto/index.sv.shtml#sto.1)

1. /etc/fstab talar om för systemet hur och vilka lagringsenheter som ska monteras automatiskt vid start/booting. 

2. mke2fs skapar ett nytt filsystem på disken. ext2,ext3 och ext4 säger vilken typ av filsystemstyp med ext4 som den mest morderna.

3. Hur mycket diskutrymme som finns, används och är ledigt på alla monterade filsystem.

4. Montera /dev/sdb2 av typen ext3 till katalogen /mnt/media. d.v.s man kommer att komma åt allt i /dev/sdb2 genom att kolla i katalogen /mnt/media.

## RAID [STO.2](https://www.ida.liu.se/~TDDI41/2025/uppgifter/sto/index.sv.shtml#sto.2)

1. Redundant Array of Independent Disks

2. Delar data i flera diskar, detta gör att läsning och skrivning av data sker snabbare då flera diskar kan arbeta samtidig

3. Skriver samma data till flera diskar, det finns en identisk kopia av informationen någonstans. Ger hög säkerhet, kostar dubbla lagringsutrymmet dock

4. Stoppar RAID-enheten /dev/md0. Den slutar vara aktiv och avmonteras av mdadm


## (Av)montera diskar - [STO.3](https://www.ida.liu.se/~TDDI41/2025/uppgifter/sto/index.sv.shtml#sto.3)


Skapa RAID-1 arrayen /dev/md0 av diskarna /dev/vda och /dev/vdb
```console
root@server:~# mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/vda /dev/vdb
root@server:~# 
``` 

Skapa ett ext4 filsystem på /dev/md0
```console
root@server:~# mkfs.ext4 /dev/md0
root@server:~# 
``` 

Montera /dev/md0 under /mnt och verifiera storleken på disken
```console
root@server:~# mount /dev/md0 /mnt
root@server:~# df -h /mnt
Filesystem      Size  Used Avail Use% Mounted on
/dev/md0        988M   24K  921M   1% /mnt
root@server:~# 
```

Avmontera /dev/md0
```console
root@server:~# umount /mnt
root@server:~# 
```

Skapa RAID-0 arrayen /dev/md1 av diskarna /dev/vdc och /dev/vdd 
```console
root@server:~# mdadm --create /dev/md1 --level=0 --raid-devices=2 /dev/vdc /dev/vdd
root@server:~# 
```

Montera /dev/md1 under /mnt och verifiera storleken på disken
```console
root@server:~# mount /dev/md1 /mnt
root@server:~# df -h /mnt
Filesystem      Size  Used Avail Use% Mounted on
/dev/md1        2.0G   24K  1.9G   1% /mnt
root@server:~# 
```

## LVM - [STO.4](https://www.ida.liu.se/~TDDI41/2025/uppgifter/sto/index.sv.shtml#sto.4)

1. 
```console
PV: physical volume, är den fysiska delen av av lagringssystemet (dvs hårddisk eller patrtitioner) som LVM använder.

VG: Volume group, skapas genom att slå ihop flera PV:n.

LV: Logical volume,skapas från VG och det som faktiskt används av ett OS som om de vore diskar eller partitioner.

Så vi förhållandet är PV -> VG -> LV.
```

2. pvcreate <disk eller partition>

3. vgcreate namnPåVG <disk eller partition>

4. vgextend namnPÅVG <disk eller patition>

5. lvcreate -L 100M -n namnPåLV namnPåVG



## Hantering av volymer och volymgrupper - [STO.5](https://www.ida.liu.se/~TDDI41/2025/uppgifter/sto/index.sv.shtml#sto.5)

1. Initiera/förbered /dev/md0 och /dev/md1 för användning i LVM – detta kommer ta bort filsystemet du skapade på dem
```console
root@server:~# pvcreate /dev/md0
WARNING: ext4 signature detected on /dev/md0 at offset 1080. Wipe it? [y/n]: y
  Wiping ext4 signature on /dev/md0.
  Physical volume "/dev/md0" successfully created.
root@server:~# pvcreate /dev/md1
WARNING: ext4 signature detected on /dev/md1 at offset 1080. Wipe it? [y/n]: y
  Wiping ext4 signature on /dev/md1.
  Physical volume "/dev/md1" successfully created.
root@server:~# 
```

2. Lägg till /dev/md0 till volymgruppen vgvirt.
```console
root@server:~# vgcreate vgvirt /dev/md0
  Volume group "vgvirt" successfully created
root@server:~# 
```

3. Utöka volymgruppen vgvirt med /dev/md1.
```console
root@server:~# vgextend vgvirt /dev/md1
  Volume group "vgvirt" successfully extended
root@server:~# 
```

4. Skapa två logiska volymer lvvol1 och lvvol2.
```console
root@server:~# lvcreate -n lvvol1 -L 100M vgvirt
  Logical volume "lvvol1" created.
root@server:~# lvcreate -n lvvol2 -L 100M vgvirt
  Logical volume "lvvol2" created.
root@server:~# 
```

5. Formatera dina nya logiska volymer med ett ext4 filsystem och se till att de monteras in vid boot under /home-storage1 respektive /home-storage2.

```console
root@server:~# mkfs.ext4 /dev/vgvirt/lvvol2
root@server:~# mkfs.ext4 /dev/vgvirt/lvvol2
```

kan använda enhetsnamn likt:
```console
/dev/vgvirt/lvvol1   /home-storage1   ext4   defaults   0  2
/dev/vgvirt/lvvol2   /home-storage2   ext4   defaults   0  2
```

men mer säckert med UUID:
```console
root@server:~# blkid /dev/vgvirt/lvvol1
/dev/vgvirt/lvvol1: UUID="dac219f3-ee41-4424-8c13-5bc5a7aaef52" BLOCK_SIZE="1024" TYPE="ext4"
root@server:~# blkid /dev/vgvirt/lvvol2
/dev/vgvirt/lvvol2: UUID="e97ad49d-796f-4478-ac63-f676d71b4d45" BLOCK_SIZE="1024" TYPE="ext4"
root@server:~# 
```

från denna guide (https://help.ubuntu.com/community/Fstab)

la in detta i /etc/fstab:
```console
UUID=dac219f3-ee41-4424-8c13-5bc5a7aaef52   /home-storage1   ext4   defaults   0  2
UUID=e97ad49d-796f-4478-ac63-f676d71b4d45   /home-storage2   ext4   defaults   0  2
```

## Konfigurering av NFS - [STO.6](https://www.ida.liu.se/~TDDI41/2025/uppgifter/sto/index.sv.shtml#sto.6)

1. apt install nfs-kernel-server


2. Konfigurera din server så att den exporterar /usr/local till alla era klienter:

la till detta i /etc/exports
```console
root@server:~# cat /etc/exports 
...
/usr/local 10.0.0.0/24(rw,sync,no_subtree_check)
root@server:~# 
```
verifierar att det funkade
```console
root@server:~# exportfs -a
root@server:~# exportfs -v
/usr/local    	10.0.0.0/24(rw,wdelay,root_squash,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
root@server:~# 
```

3. för klienten:

10.0.0.2 är min server

apt install nfs-common

mkdir -p /mnt/usr-local

la in detta i /etc/fstab: 10.0.0.2:/usr/local   /mnt/usr-local   nfs4   defaults   0  0


## autofs och automount  - [STO.7](https://www.ida.liu.se/~TDDI41/2025/uppgifter/sto/index.sv.shtml#sto.7) 

1. En konfigurationsfil som säger till autofs vad som ska monteras, vart det ska monteras och hur det ska monteras

2. apt install autofs

3. 
```console
direkta: Anger exakt vilken sökväg som ska vara mountpoint. Ingen huvudkatalog

indirekta: Anger en huvudkatalog i /etc/auto.master och autofs skapar undermapparna vid behov
```

4. Huvudkonfigurationsfilen heter: /etc/autofs.conf. Den pekar ut master-mapen genom master_map_name = /etc/auto.master i /etc/autofs.conf.

```console
root@server:~# cat /etc/autofs.conf | grep master_map_name
# master_map_name - default map name for the master map.
master_map_name = /etc/auto.master
root@server:~#
``` 
## autofs utan LDAP  - [STO.8](https://www.ida.liu.se/~TDDI41/2025/uppgifter/sto/index.sv.shtml#sto.8) 

skapade två anvädare, usera och userb
```console
root@server:~/LDAP# ./generate_accounts.sh tests.txt
```

flyttade deras hemkataloger
```console
root@server:~# mv /home/usela931 /home-storage1/usela931
root@server:~# mv /home/usela537 /home-storage2/usela537
root@server:~# chown -R usela931:usela931 /home-storage1/usela931
root@server:~# chown -R usela537:usela537 /home-storage2/usela537
```

lägger till detta i /etc/exports:

antog att home-storage bara sva vara i clinet-1(10.0.0.3) och client-2(10.0.0.4)
```console
/home-storage1	10.0.0.3(rw,wdelay,root_squash,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
/home-storage1	10.0.0.4(rw,wdelay,root_squash,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
/home-storage2	10.0.0.4(rw,wdelay,root_squash,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
/home-storage2	10.0.0.3(rw,wdelay,root_squash,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
root@server:~# exportfs -ra
```

följde denna guide (https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/managing_file_systems/mounting-file-systems-on-demand_managing-file-systems)

ändrade i /etc/auto.master:
```console
/home   /etc/auto.home   --timeout=60
```

lägger in detta I /etc/auto.home:
```console
usela931 -fstype=nfs4 10.0.0.2:/home-storage1/usela931
usela537 -fstype=nfs4 10.0.0.2:/home-storage2/usela537
```

går nu att både logga in och se hemkatalog:
```console
usela931@client-1:~$ pwd
/home/usela931
usela931@client-1:~$ 
```

skapar vår fil
```console
usela931@client-1:~$ echo "Bagagwa" > ~/merv.txt
```

Den finns även om vi loggar in i client-2:
```console
usela931@client-2:~$ ls
merv.txt
usela931@client-2:~$ 
```

användarna kan ej skriva i varandras hemkataloger:
```console
usela931@client-1:~$ echo "should not work" > /home/usela537/test.txt
-bash: /home/usela537/test.txt: Permission denied
usela931@client-1:~$ 
```

## autofs med LDAP  - [STO.9](https://www.ida.liu.se/~TDDI41/2025/uppgifter/sto/index.sv.shtml#sto.9) 

kopierade filed härifrån (https://launchpadlibrarian.net/55451730/autofs.ldif):
```console
root@server:~# ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/autofs-ldap.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
adding new entry "cn=autofs,cn=schema,cn=config"
root@server:~# 
```

la till mina nya ou filer med ldapadd -x -D "cn=admin,dc=superldap,dc=se" -W -f ou_automounttree.ldif:
```console
root@server:~# cat ou_automounttree.ldif 
dn: ou=automount,ou=Users,dc=superldap,dc=se
ou: automount
objectClass: top
objectClass: organizationalUnit

dn: ou=auto.master,ou=automount,ou=Users,dc=superldap,dc=se
ou: auto.master
objectClass: top
objectClass: automountMap

dn: cn=/home,ou=auto.master,ou=automount,ou=Users,dc=superldap,dc=se
cn: /home
objectClass: top
objectClass: automount
automountInformation: ldap:ou=auto.home,ou=automount,ou=Users,dc=superldap,dc=se --timeout=60 --ghost

dn: ou=auto.home,ou=automount,ou=Users,dc=superldap,dc=se
ou: auto.home
objectClass: top
objectClass: automountMap

dn: cn=usela931,ou=auto.home,ou=automount,ou=Users,dc=superldap,dc=se
cn: usela931
objectClass: top
objectClass: automount
automountInformation: -fstype=nfs4,rw,sync 10.0.0.2:/home-storage1/usela931

dn: cn=usela537,ou=auto.home,ou=automount,ou=Users,dc=superldap,dc=se
cn: usela537
objectClass: top
objectClass: automount
automountInformation: -fstype=nfs4,rw,sync 10.0.0.2:/home-storage2/usela537
```


öppnade /etc/default/autofs och la till detta:
```console
MASTER_MAP_NAME="ou=auto.master,ou=automount,ou=Users,dc=superldap,dc=se"
LDAP_URI="ldap://10.0.0.2"
SEARCH_BASE="ou=automount,ou=Users,dc=superldap,dc=se"

LOGGING="verbose"
MAP_OBJECT_CLASS="automountMap"
ENTRY_OBJECT_CLASS="automount"
MAP_ATTRIBUTE="ou"
ENTRY_ATTRIBUTE="cn"
VALUE_ATTRIBUTE="automountInformation"
```


sist så la jag till detta i mitt skript som skapar användare:

NOTE: 

LDAP_ADMIN_DN="cn=admin,dc=superldap,dc=se"

LDAP_PASS_FILE ="/etc/ldapscripts/ldapscripts.passwd"

AUTOHOME_BASE="ou=auto.home,ou=automount,ou=Users,dc=superldap,dc=se"

NFS_SERVER="10.0.0.2"  

```python
    if [ $((RANDOM % 2)) -eq 0 ]; then # if even random number get sent to home_storage1 else homestorage2
      storage_base="/home-storage1"
    else
      storage_base="/home-storage2"
    fi

    user_home="${storage_base}/${username}"
    echo "  Skapar hemkatalog på servern: ${user_home}"

    mv "/home/${username}" "${user_home}" #mount point for autofs
    chown -R "${username}:${username}" "${user_home}" #Make sure ownership is right
    chmod 700 "${user_home}" #security/ownership 

    echo "  Lägger till automount-entry i LDAP för ${username}"

    ldapadd -x -D "${LDAP_ADMIN_DN}" -y "${LDAP_PASS_FILE}" <<EOF #Magic happens here. we add automount to ldap 
dn: cn=${username},${AUTOHOME_BASE}
objectClass: top
objectClass: automount
cn: ${username}
automountInformation: -fstype=nfs4,rw,sync ${NFS_SERVER}:${user_home}
EOF
```

## tester  - [STO.10](https://www.ida.liu.se/~TDDI41/2025/uppgifter/sto/index.sv.shtml#sto.10) 
```python
# https://docs.python-guide.org/writing/tests/
# https://docs.pytest.org/en/latest/
# pip install --user pytest
# ~/.local/bin/pytest <fil>

hostname = open("/etc/hostname", "r").read().strip()

import subprocess

def test_exports_rights():
    if hostname != 'server':
        return
    
    #We only export home-storage to our clients (10.0.0.3 and 10.0.0.4)
    result = subprocess.run(["exportfs", "-v"],capture_output=True, text=True)
    assert "/home-storage1	10.0.0.3(rw,wdelay,root_squash,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)" in result.stdout
    assert "/home-storage1	10.0.0.4(rw,wdelay,root_squash,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)" in result.stdout
    assert "/home-storage2	10.0.0.4(rw,wdelay,root_squash,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)" in result.stdout
    assert "/home-storage2	10.0.0.3(rw,wdelay,root_squash,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)" in result.stdout
    assert "/usr/local    	10.0.0.0/24(rw,wdelay,root_squash,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)" in result.stdout

def test_usrlocal():
    if hostname == 'server':
        return
    
    result = subprocess.run("cat /etc/fstab", capture_output=True, shell=True, text=True)

    assert "10.0.0.2:/usr/local   /mnt/usr-local   nfs4   defaults   0  0" in result.stdout 

def test_automount():
    if hostname != "client-1" or hostname != "clien1-2":
        return

    result = subprocess.run(["automount", "-m"],capture_output=True, text=True)
    
    assert "type: ldap" in result.stdout #We do indeed use ldap and not local files.
```