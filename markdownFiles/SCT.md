## ahmha095 & felma217
 
## Shebang - [SCT.1](https://www.ida.liu.se/~TDDI41/2025/uppgifter/sct/index.sv.shtml#sct.1)

Svar:

Den ledande raden i skriptet som börjar med '#!'. Den används så att operativsystemet vet hur den ska tolka och köra skriptet skriptet. Utan den hade man behövt själv skriva 'bash skript.sh' eller 'python3 skript.py'.

## Skript för att automatiskt skapa användarkonto - [SCT.2](https://www.ida.liu.se/~TDDI41/2025/uppgifter/sct/index.sv.shtml#sct.2)

```bash
#!/bin/bash

filename=$1

# check if file actually exists, might not be needed
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

    #Get last name, in case person is annoying and puts in middlenames
    last=${!#}

    # remove weird signs
    first=$(echo "$first" | tr -cd 'a-zA-Z')
    last=$(echo "$last" | tr -cd 'a-zA-Z')

    letters="${first:0:3}${last:0:2}"

   


    #not enough letters for 5 letter string, put random ones in
    while [ ${#letters} -lt 5 ]; do
    extra=$(tr -dc 'a-z' </dev/urandom | head -c 1)
    letters="${letters}${extra}"
    done 

    #Make them lowercase
    letters="${letters,,}" 

    ##Add 3 random nummbers
    username="${letters}${number}"

    echo "$username"
}

getPassword()
{
    #Use dev/urandom script to get a random 8 sign long password
    password=$(tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 8)
    echo "$password"
}

# While the text file still has content and it's not an 'empty' name we continue reading
while IFS= read -r name || [ -n "$name" ]; do
    [ -z "$name" ] && continue
    echo "Creating account for: $name"
    username=$(getUsername "$name")
    password=$(getPassword)
    
    # -m = create user home directory, -s = defines default login shell, /bin/bash in our case.
    sudo useradd -m -s /bin/bash "$username"

    #make a bash here-document, should only show chpasswd <<END in history.
sudo chpasswd <<END
${username}:${password}
END

done < "$filename"
```

## Skript för automatiserad testning - [SCT.3](https://www.ida.liu.se/~TDDI41/2025/uppgifter/sct/index.sv.shtml#sct.3)

```python
# https://docs.python-guide.org/writing/tests/
# https://docs.pytest.org/en/latest/
# pip install --user pytest
# ~/.local/bin/pytest <fil>


import subprocess

# ^root = lines begining with 'root', capture_output = save the output in res 
def test_root():
    res = subprocess.run(["grep", "^root:", "/etc/passwd"], capture_output=True, text=True)
    assert res.returncode == 0

def test_games():
    shells = subprocess.run(["cat", "/etc/shells"], capture_output=True, text=True)
    lines = shells.stdout.splitlines()

    valid = []

    for line in lines:
        name = line.strip()
        if name and not name.startswith('#'): # Remove annoying comment, might be really stupid and un-needed to include
            valid.append(name.split()[0]) #remove white space. Again, might be really un-needed

    res = subprocess.run(["grep", "^games:", "/etc/passwd"], capture_output=True, text=True)
    strings = res.stdout.strip()
    fields = strings.split(":")
    gameshell = fields[-1].strip() 

    assert gameshell not in valid    
```
## Förklaring för test skripten 

Svar: 

test_root: /etc/passwd har information om användarkonton för systemet, någonting likt 'användarnamn : lösenord : userID : groupID : kommentar : hemkatalog : skal' så vi kollar där om det finns en 'root' eller inte.

test_games: vi öppnar /etc/shells för där finns alla våra giltiga skal och spara det i valid variabeln. Sedan så öppnar vi etc/passwd igen och letar efter games den här gången och hittar dess skall, eller det som finns i slutet iallafall. När vi har det så sparar vi det i gameshell och ser till att den inte finns i några av elementen i valid.


## Bonus 

det funkar att ssha in, tror jag.

```console
ahmha095@su12-204:~$ ssh -p 2220 svepe745@127.0.0.1
svepe745@127.0.0.1's password: 
Linux debian 5.10.0-25-amd64 #1 SMP Debian 5.10.191-1 (2023-08-16) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
svepe745@debian:~$ shutdown
-bash: shutdown: command not found
svepe745@debian:~$ exit
logout
Connection to 127.0.0.1 closed.
ahmha095@su12-204:~$ 
```