#!/bin/bash

filename=$1

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
    sudo useradd -m -s /bin/bash "$username" || { echo "useradd failed for $username" >&2; exit 1; }

    #echo "$username:$password" | sudo chpasswd
sudo chpasswd <<END
${username}:${password}
END

done < "$filename"


# TODO ignore, remove later
if false; then
Creating account for: Sven Persson
Created svepe981 with password DHW0pyhh
Creating account for: Malte Lindeman
Created malli181 with password y9fUg6kc
Creating account for: Valfrid Lindeman
Created valli045 with password efUBl7pk
fi