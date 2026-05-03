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
    

    # Hämta lokal UID/GID
    uid=$(id -u "$username")
    gid=$(id -g "$username")
    echo "  Lokal UID: $uid, GID: $gid"

    # 2) Skapa användaren i LDAP med ldapscripts (UID blir först fel, men vi fixar det)
    ldapadduser "$username" users
    if [ $? -ne 0 ]; then
        echo "  [FEL] ldapadduser misslyckades för $username" >&2
        tail -n 10 /var/log/syslog
        continue
    fi

    # 3) Modifiera LDAP så att uidNumber/gidNumber matchar lokalt
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
        echo "  [FEL] ldapmodify misslyckades för $username (uid/gid sync)" >&2
        continue
    fi

    # 4) Sätt samma lösenord i LDAP
     ldapsetpasswd "$username" <<END
${password}
${password}
END

    if [ $? -ne 0 ]; then
        echo "  [VARNING] ldapsetpasswd misslyckades för $username" >&2
    fi

    echo "  -> Klar med $username"
    echo ${username}:${password}
    echo
done < "$filename"

root@server:~# ls
DNS  LDAP  ou_groups.ldif  ou_users.ldif  user_john.ldif
root@server:~# cd LDAP/
root@server:~/LDAP# chmod +x generate_accounts.sh 


root@server:~/LDAP# ./generate_accounts.sh tests.txt
Creating account for: Sven Persson
  Lokal UID: 1001, GID: 1001
Successfully added user svepe673 to LDAP
Successfully set password for user svepe673
Enter LDAP Password: 
modifying entry "uid=svepe673,ou=Users,dc=superldap,dc=se"

Changing password for user uid=svepe673,ou=Users,dc=superldap,dc=se
New Password: stty: 'standard input': Inappropriate ioctl for device
stty: 'standard input': Inappropriate ioctl for device

Retype New Password: stty: 'standard input': Inappropriate ioctl for device
stty: 'standard input': Inappropriate ioctl for device

Successfully set password for user uid=svepe673,ou=Users,dc=superldap,dc=se
  -> Klar med svepe673
svepe673:JOLxP7Px

Creating account for: Malte Lindeman
  Lokal UID: 1002, GID: 1002
Successfully added user malli194 to LDAP
Successfully set password for user malli194
Enter LDAP Password: 
modifying entry "uid=malli194,ou=Users,dc=superldap,dc=se"

Changing password for user uid=malli194,ou=Users,dc=superldap,dc=se
New Password: stty: 'standard input': Inappropriate ioctl for device
stty: 'standard input': Inappropriate ioctl for device

Retype New Password: stty: 'standard input': Inappropriate ioctl for device
stty: 'standard input': Inappropriate ioctl for device

Successfully set password for user uid=malli194,ou=Users,dc=superldap,dc=se
  -> Klar med malli194
malli194:41gKkaMc

Creating account for: Valfrid Lindeman
  Lokal UID: 1003, GID: 1003
Successfully added user valli809 to LDAP
Successfully set password for user valli809
Enter LDAP Password: 
modifying entry "uid=valli809,ou=Users,dc=superldap,dc=se"

Changing password for user uid=valli809,ou=Users,dc=superldap,dc=se
New Password: stty: 'standard input': Inappropriate ioctl for device
stty: 'standard input': Inappropriate ioctl for device

Retype New Password: stty: 'standard input': Inappropriate ioctl for device
stty: 'standard input': Inappropriate ioctl for device

Successfully set password for user uid=valli809,ou=Users,dc=superldap,dc=se
  -> Klar med valli809
valli809:TUq3NG38

root@server:~/LDAP# 
