#!/bin/bash

filename=$1

LDAP_SUFFIX="dc=superldap,dc=se"
LDAP_USERS_OU="ou=Users"
NFS_SERVER="10.0.0.2"    
AUTOHOME_BASE="ou=auto.home,ou=automount,ou=Users,${LDAP_SUFFIX}"
LDAP_ADMIN_DN="cn=admin,${LDAP_SUFFIX}"
LDAP_PASS_FILE="/etc/ldapscripts/ldapscripts.passwd"

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

    # 2) create user
    ldapadduser "$username" users
    if [ $? -ne 0 ]; then
        echo "  [FEL] ldapadduser misslyckades för $username" >&2
        tail -n 10 /var/log/syslog
        continue
    fi

    # 3) put same UID and GID
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

    # 4) put same pwd
     ldapsetpasswd "$username" <<END
${password}
${password}
END

    if [ $? -ne 0 ]; then
        echo "  [WARNING] ldapsetpasswd failed for $username" >&2
    fi

    if [ $((RANDOM % 2)) -eq 0 ]; then # if even home_storage1 else homestorage2
      storage_base="/home-storage1"
    else
      storage_base="/home-storage2"
    fi

    user_home="${storage_base}/${username}"
    echo "  Skapar hemkatalog på servern: ${user_home}"

    mv "/home/${username}" "${user_home}"
    chown -R "${username}:${username}" "${user_home}"
    chmod 700 "${user_home}"

    echo "  Lägger till automount-entry i LDAP för ${username}"

    ldapadd -x -D "${LDAP_ADMIN_DN}" -y "${LDAP_PASS_FILE}" <<EOF
dn: cn=${username},${AUTOHOME_BASE}
objectClass: top
objectClass: automount
cn: ${username}
automountInformation: -fstype=nfs4,rw,sync ${NFS_SERVER}:${user_home}
EOF

    if [ $? -ne 0 ]; then
        echo "  [WARNING] ldapadd automount failed for ${username}" >&2
    fi


    echo "  -> Klar med $username"
    echo ${username}:${password}
    echo
done < "$filename"

  -> Klar med ahmha516
ahmha516:1VCWGZXP
