## ahmha095

## Grunderna i LDAP - [LDAP.1](https://www.ida.liu.se/~TDDI41/2025/uppgifter/ldap/index.sv.shtml#ldap.1) 

```console
1.DIT (Directory information tree), det säger hur informationen i en LDAP är organiserad. Den fungerar likt dictionaries i linux, ett hierarkiskt träd, med grupper som föregår andra.
 
2.DN(distinguished name): Den säger den fullständiga adressen i en katalog, D.v.s den sökvägen i mappstrukturen. DC(domain component): en ‘bit’ av domän namnet. exemplevis: dc:liu, dc:se för liu.se

3.En egenskap hos ett objekt. I ett användarkonto kan det exempelvis vara, namn, email, telefon nummer osv.

4.Bestämmer vilka attributes något har.

5.Structural: Varje LDAP objekt måste ha denna class object, och de fungerar som grunden till objektet. Auxillery: Denna objekt klass kan användas för att lägga till fler atributer.
```
## Grunderna i LDAP - [LDAP.2](https://www.ida.liu.se/~TDDI41/2025/uppgifter/ldap/index.sv.shtml#ldap.2) 

installerade paketen med dessa kommandon. y flaggan säger bara 'yes' till eventuella frågor.

```console
apt install slapd ldap-utils -y
```
konfiguerar den senare med 

```console
 dpkg-reconfigure slapd
```


får detta när jag använder ldapsearch

```console
root@server:~# ldapsearch -x -LLL -H ldap://server.grupp13.liu.se  -b dc=superldap,dc=se
dn: dc=superldap,dc=se
objectClass: top
objectClass: dcObject
objectClass: organization
o: grupp13
dc: superldap
```
förklaring för flaggor :
-x = allt som kommer härifrån är 'säckert'
-b = använd detta DN (superldap.se)
-H = visa extra info för sökningen
-LLL = ge tillbaka minimal LDIF data

installerade paketen för klienten med detta :

```console
apt install libnss-ldapd libpam-ldapd ldap-utils -y
```

passwd, group och shadow för LDAP lookup. Detta gör att systemet använder LDAP för att hämta användar konton istället för lokala mappar (t.ex /etc/passwd)

URL LDAP för vår server som vi gjorde tidigare ldap://server.grupp13.liu.se

och nslcd är aktiv:

```console
root@client-1:~# systemctl is-active nslcd
active
root@client-1:~# 
```
hitta konfigurations filen här:
```console
root@client-1:~# cat /etc/nslcd.conf 
# /etc/nslcd.conf
# nslcd configuration file. See nslcd.conf(5)
# for details.

# The user and group nslcd should run as.
uid nslcd
gid nslcd

# The location at which the LDAP server(s) should be reachable.
uri ldap://10.0.0.2

# The search base that will be used for all queries.
base dc=superldap,dc=se

# The LDAP protocol version to use.
#ldap_version 3

# The DN to bind with for normal lookups.
#binddn cn=annonymous,dc=example,dc=net
#bindpw secret

# The DN used for password modifications by root.
#rootpwmoddn cn=admin,dc=example,dc=com

# SSL options
#ssl off
#tls_reqcert never
tls_cacertfile /etc/ssl/certs/ca-certificates.crt

# The search scope.
#scope sub

root@client-1:~# 
```

## Lägg till en användare - [LDAP.3](https://www.ida.liu.se/~TDDI41/2025/uppgifter/ldap/index.sv.shtml#ldap.3)

skapade en fil med nano genom nano ou_users.ldif som ser ut sådan:

```console
root@server:~# cat ou_users.ldif 
dn: ou=Users,dc=superldap,dc=se
objectClass: organizationalUnit
ou: Users
```

sedan lag jag till det med denna kommando:

```console
ldapadd -x -D "cn=admin,dc=superldap,dc=se" -W -f ou_users.ldif
```

följde denna guide(https://docs.redhat.com/en/documentation/red_hat_directory_server/12/html/configuration_and_schema_reference/assembly_entry-object-class-reference_config-schema-reference-title)

jag skapade en annan fil för att lägga till en användare:

```console
root@server:~# cat user_john.ldif 
dn: uid=johndoe,ou=Users,dc=superldap,dc=se
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: top
cn: john doe
sn: doe
uid: johndoe
uidNumber: 10001
gidNumber: 10001
homeDirectory: /home/johndoe
loginShell: /bin/bash
userPassword: johndoe
root@server:~# 
```
Jag la till den med samma komnado som tidigare:

```console
sudo ldapadd -x -D "cn=admin,dc=superldap,dc=se" -W -f user_john.ldif
```

Verifiera att den hittated med ldapsearch:

```
root@server:~# ldapsearch -x -b dc=superldap,dc=se uid=johndoe
# extended LDIF
#
# LDAPv3
# base <dc=superldap,dc=se> with scope subtree
# filter: uid=johndoe
# requesting: ALL
#

# johndoe, Users, superldap.se
dn: uid=johndoe,ou=Users,dc=superldap,dc=se
objectClass: account
objectClass: posixAccount
cn: john doe
uid: doe
homeDirectory: /home/johndoe
loginShell: /bin/bash
gecos: johndoe
description: User account
uidNumber: 1001
gidNumber: 1001

# search result
search: 2
result: 0 Success

# numResponses: 2
# numEntries: 1
root@server:~# 
```
kan även hitta den i klienten:

```console
root@client-1:~# getent passwd johndoe
johndoe:*:1001:1001:johndoe:/home/johndoe:/bin/bash
root@client-1:~# 
```

sist går det att ssh:a in:

```console
root@client-1:~# ssh johndoe@client-1.grupp13.liu.se
johndoe@client-1.grupp13.liu.se's password: 
Linux client-1 5.10.0-15-amd64 #1 SMP Debian 5.10.120-1 (2022-06-09) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Mon Nov 24 20:59:52 2025 from 10.0.0.3
Could not chdir to home directory /home/johndoe: No such file or directory
johndoe@client-1:/$ 
```
## Lägg till en användare med ldapscript - [LDAP.4](https://www.ida.liu.se/~TDDI41/2025/uppgifter/ldap/index.sv.shtml#ldap.4)


installerade ldapscript genom:

```console
apt install ldapscripts -y
```

konfiguerade ldapscript genom filen /etc/ldapscripts/ldapscripts.conf:


```console
SERVER="ldap://server.grupp13.liu.se"
BINDDN="cn=admin,dc=superldap,dc=se"
BINDPWFILE="/etc/ldapscripts/ldapscripts.passwd"
SUFFIX="dc=superldap,dc=se"

USUFFIX="ou=Users"
GSUFFIX="ou=Groups"

GIDSTART="10000"
UIDSTART="10000"
```
skapade en användare lokalt:
```console
adduser testuser
id testuser
uid=1002(testuser) gid=1002(testuser) groups=1002(testuser)
```

gick inte att lägga till användaren genom ldapadduser först, la till en group ou fil:

```console
dn: ou=Groups,dc=superldap,dc=se
objectClass: organizationalUnit
ou: Groups
root@server:~# ldapadd -x -D "cn=admin,dc=superldap,dc=se" -W -f ou_groups.ldif 
```

ändrade /etc/ldapscripts/ldapscripts.passwd från 'secret' till lösenordet till min LDAP katalog

```console
nano /etc/ldapscripts/ldapscripts.passwd
chmod 600 /etc/ldapscripts/ldapscripts.passwd
```
Därefter gick det entligen att lägga till en användare med ldapadduser och att ssh in genom klienten


## Lägg till flera användare med ldapscript - [LDAP.5](https://www.ida.liu.se/~TDDI41/2025/uppgifter/ldap/index.sv.shtml#ldap.5)

```python
#!/bin/bash

filename=$1

LDAP_SUFFIX="dc=superldap,dc=se"
LDAP_USERS_OU="ou=Users"

# File actually exists, might not be needed
if [ ! -f "$filename" ]; then
    echo "Filen '$filename' finns inte."
    exit 1
fi

getUsername(){
    input="$1"

    # Get random numbers
    number=$(printf "%03d" $((RANDOM % 1000)))

   # -f = from encoding... -t = make ASCII and try to convert as good as you can.
    clean=$(echo "$input" | iconv -f UTF-8 -t ASCII//TRANSLIT)
    
    #Split the names based on space
    set -- $clean
    first=$1

    #Get last name
    last=${!#}

    # remove weird signs
    first=$(echo "$first" | tr -cd 'a-zA-Z')
    last=$(echo "$last" | tr -cd 'a-zA-Z')

    letters="${first:0:3}${last:0:2}"

   


    #not enough letters, put random ones in
    while [ ${#letters} -lt 5 ]; do
    extra=$(tr -dc 'a-z' </dev/urandom | head -c 1)
    letters="${letters}${extra}"
    done 

    letters="${letters,,}"
    username="${letters}${number}"

    echo "$username"
}

getPassword()
{
    #Use dev/urandom script to get a random 8 sign long password
    password=$(tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 8)
    echo "$password"
}


while IFS= read -r name || [ -n "$name" ]; do
    [ -z "$name" ] && continue
    echo "Creating account for: $name"
    username=$(getUsername "$name")
    password=$(getPassword)

    # -m = create user home directory, -s = defines default login shell
    useradd -m -s /bin/bash "$username" || { echo "useradd failed for $username" >&2; exit 1; }

chpasswd <<END
${username}:${password}
END
    # it's added to the server now we add to LDAP

    # Get local UID/GID
    uid=$(id -u "$username")
    gid=$(id -g "$username")
    echo " local UID: $uid, GID: $gid"

    # Create user in LDAP
    ldapadduser "$username" users
    if [ $? -ne 0 ]; then
        echo " ldapadduser failed for  $username" >&2
        continue
    fi

    # Make sure that the user in the LDAP cataloge has the same user id and group id as the servers uid and gid, asks for password which we pass after the -y flag
    ldapmodify -x -D "cn=admin,${LDAP_SUFFIX}" -y /etc/ldapscripts/ldapscripts.passwd <<EOF
dn: uid=${username},${LDAP_USERS_OU},${LDAP_SUFFIX}
changetype: modify
replace: uidNumber
uidNumber: ${uid}
-
replace: gidNumber
gidNumber: ${gid}
EOF

    if [ $? -ne 0 ]; then
        echo " LDAP modify fail" >&2
        continue
    fi

    # put the same password in LDAP
     ldapsetpasswd "$username" <<END
${password}
${password}
END

    if [ $? -ne 0 ]; then
        echo " password can't be set for $username" >&2
    fi

    echo " -> done with $username"
done < "$filename"
```

## TEST - [LDAP.6](https://www.ida.liu.se/~TDDI41/2025/uppgifter/ldap/index.sv.shtml#ldap.6)

```python
# https://docs.python-guide.org/writing/tests/
# https://docs.pytest.org/en/latest/
# pip install --user pytest
# ~/.local/bin/pytest <fil>

hostname = open("/etc/hostname", "r").read().strip()

import subprocess

def test_nslcd():
    if hostname == 'gw' or hostname == 'server': # nslcd is only in the clients
        return
    
    result = subprocess.run(["systemctl", "is-active", "nslcd"],capture_output=True, text=True)
    assert result.stdout.strip() == "active"

def test_slapd():
    if hostname != 'server': #slapd only in server
        return
    
    result = subprocess.run(["systemctl", "is-active", "slapd"],capture_output=True, text=True)
    assert result.stdout.strip() == "active"


def test_nssconfig():
    if hostname == 'gw' or hostname == 'server': 
        return
    
    nssconfigs = open("/etc/nsswitch.config", "r").read()

    assert 'passwd:         files systemd ldap' in nssconfigs
    assert 'group:          files systemd ldap' in nssconfigs
    assert 'shadow:         files ldap' in nssconfigs

def test_ldapsearch():
    result = subprocess.run(["ldapsearch", "-x", "-H", "ldap://server.grupp13.liu.se", "-b", "dc=superldap,dc=se", "uid=*"], capture_output=True, text=True)
    
    assert result.returncode == 0 #the search worked.

    assert 'dn' in result.stdout # result actually found something

def test_getent():
    result = subprocess.run(["getent", "passwd", "svepe646"], capture_output=True, text=True)
    
    assert result.returncode == 0
    assert 'svepe646' in result.stdout #known user
```
