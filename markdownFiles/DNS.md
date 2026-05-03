## ahmha095

## Guide jag använde

följde denna guide [How to Configure BIND9 as a Primary DNS Server on Ubuntu 20.04](https://serverspace.io/support/help/configure-bind9-dns-server-on-ubuntu/#stepone) 


## Grunderna i DNS - [DNS.1](https://www.ida.liu.se/~TDDI41/2025/uppgifter/dns/index.sv.shtml#dns.1) 

1.

En DNS server som har det slutliga svaret för en viss domän. Den äger den riktiga DNS zonen och ger definitiva svar, inte enbart cachade resultat.

2.

En rekursiv namnserver. En rekursiv namnserver har inte originalinformationen själv, utan hämtar den åt användaren genom att fråga andra namnservrar (till exempel auktoritativa). När den hittat svaret kan den spara det tillfälligt i cache för snabbare svar nästa gång.

3.

Domän = Namnet i DNS-hierarkin (t.ex. example.com).

Zon = Den del av domänen som faktiskt administreras av en namnserver och innehåller DNS-poster.

4.

Rekurasive: DNS-servern som blir frågad letar rätt efter den slutliga svaret

Iterativ: DNS-servern hänvisar till en annan server som är närmare svaret. Går vidare steg för steg.

5.

DNS kan ha många domännamn, vore omöjligt för en central server att hantera allt. Att dela i zoner gör det skalbart.

6.

För en omvänd DNS-uppslagning vänds IP-adressen baklänges och man lägger till domänen in-addr.arpa. DNS söker sedan efter en PTR-post som kopplar IP-adressen till ett domännamn. 


## dig - [DNS.2](https://www.ida.liu.se/~TDDI41/2025/uppgifter/dns/index.sv.shtml#dns.2)

1.

```console
; <<>> DiG 9.11.3-1ubuntu1.13-Ubuntu <<>> www.liu.se # Version av Dig som körs o vilekn fråga som ställs
;; global options: +cmd # globala inställningar
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 64544 #Hearders på vår fråga
;; flags: qr rd ra ad; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1 #


;; QUESTION SECTION:
;www.liu.se.			IN	A # klienten fråga efter en A post (Ipv4) för liu.se

;; ANSWER SECTION:
www.liu.se.		7882	IN	A	130.236.18.52 # DNS-servens svar

;; Query time: 0 msec #Hur långt tid frågan tog
;; SERVER: 130.236.1.9#53(130.236.1.9) # DNS servern som svarade
;; WHEN: Fri Oct 23 10:01:05 CEST 2020 # När frågan skickades
;; MSG SIZE  rcvd: 55 # Storleken på svaret
```

2.

A: en ipv4 adress

AAAA: IPv6 adress

NS: namnet på den auktorativa namnservern för zonen

MX: en mailserver

SOA: Informationen om en zon så som, TTL, expire time,


3.

visar hela DNS processen steg för steg. Från root till top domän till auktorativ server (google.com) till sist www.google.com

## Konfiguration av namnserver - [DNS.3](https://www.ida.liu.se/~TDDI41/2025/uppgifter/dns/index.sv.shtml#dns.3) 

1.

Genom att ändra i /etc/resolv.conf. nameserver ip-adress som önskas

2.

Den anger vilken server som är den primära auktoriteten för zonenoch innehåller info om zonen.

fälten i SOA har dessa fält:

```console
example.com.  IN  SOA  ns1.example.com. admin.example.com. (
                2024102301 ; Serial, version nummer
                7200       ; Refresh time  
                3600       ; Retry time
                1209600    ; Expire time
                3600 )     ; Minimum TTL (Time to live)
```

## Labbgenomgång 

öppnade upd port 53 i brandvägen för den är ansvarig för DNS förfrågning

ändrade i /etc/resolv.conf i alla maskiner till detta: 

```console
nameserver 10.0.0.2.
```


utöver så la jag till detta i /etc/dhcp/dhclient.conf : 

```python
prepend domain-name-servers 10.0.0.2;.  #Detta gör att vår DNS server alltid ska prioriteras över DHCP-klienten.
```

Skrev in detta I /etc/bind/named.conf.local:

```console
#det här gör att maskinen dvs servern har auktoritet för vår zon.

zone "grupp13.liu.se" {
	type master;
	file "/etc/bind/db.grupp13.liu.se";
};

zone "0.0.10.in-addr.arpa" {
	type master;
	file "/etc/bind/db.10.0.0";
};
```


Sedan skapade jag de två filerna som vi /etc/bind/db.grupp13.liu.se och /etc/bind/db.10.0.0

```console
grupp 13:
;
;
;
$TTL    3600
@       IN      SOA     server.grupp13.liu.se. admin.grupp13.liu.se. (
                     2025103001        ; Serial
                         3600          ; Refresh
                          86400        ; Retry
                        2419200        ; Expire
                         3600 )      ; Negative Cache TTL
;
        IN      NS      server.grupp13.liu.se. ; Detta är vår auktoritet server för zonen
server  IN      A       10.0.0.2                
gw      IN      A       10.0.0.1
client-1 IN      A       10.0.0.3              ; kopplar up våra addresser med namn
client-2 IN      A       10.0.0.4
```

```console
10.0.0:
$TTL 3600
@   IN SOA  server.grupp13.liu.se. admin.grupp13.liu.se. (
        2025110201 ; Serial
        3600       ; Refresh
        1800       ; Retry
        1209600    ; Expire
        3600 )     ; Minimum TTL

    IN NS  server.grupp13.liu.se.

1   IN PTR gw.grupp13.liu.se.  ; if we get 10.0.0.1 we poitn towards gw.grupp.liu.se, 2 -> server, 3->client-1 ect
2   IN PTR server.grupp13.liu.se.
3   IN PTR client-1.grupp13.liu.se.
4   IN PTR client-2.grupp13.liu.se.
```

Jag satte serial till dagens datum, Refresh till att vi ska hämta uppdateringar varje timme, retry till att vi ska vänta 30 min ifall refresh misslyckas, expire spelar ingen roll eftersom jag inte har en sekundär namnserver, minimum TTL till att andra DNS servrar kan cacha ett negativt svar i en timme. Om jag ska vara helt ärlig kopierade jag de från guiden jag hittade ovan.  




sist så ändrade jag /etc/bind/named.conf.options och la till detta

```console
	recursion yes; # tillåter rekurision
	allow-query{127.0.0.1; 10.0.0.0/24;}; # endast våra maskiner får ställa frågor
	allow-recursion{127.0.0.1; 10.0.0.0/24;}; #endast våra maskiner får slå up externa adresser
	 forwarders {
		8.8.8.8; # checkar ifall google har svaret chachat eller ej, enklare sökning
		1.1.1.1; # checkar ifall cloudflare har svaret
	};

```

## Testning av DNS-konfiguration - [DNS.4](https://www.ida.liu.se/~TDDI41/2025/uppgifter/dns/index.sv.shtml#dns.4) 

för minaa klienter kollar jag bara ifall vi har satt rätt ip för vår DNS

```python
# https://docs.python-guide.org/writing/tests/
# https://docs.pytest.org/en/latest/
# pip install --user pytest
# ~/.local/bin/pytest <fil>

import subprocess

def test_DNS():
    getDNS = subprocess.run("cat /etc/resolv.conf | grep 10.0.0", capture_output=True, shell=True, text=True)

    DNSAddr = getDNS.stdout.split()[1] 

    assert DNSAddr.strip() == "10.0.0.2"
```

Tester för min server

```python
# https://docs.python-guide.org/writing/tests/
# https://docs.pytest.org/en/latest/
# pip install --user pytest
# ~/.local/bin/pytest <fil>

import subprocess

IpTables = {
    "gw" : "10.0.0.1",
    "server" : "10.0.0.2",
    "client-1" : "10.0.0.3",
    "client-2" : "10.0.0.4",
} 

def test_DNS(): # testar att vi har rätt ip på vår DNS
    getDNS = subprocess.run("cat /etc/resolv.conf | grep 10.0.0", capture_output=True, shell=True, text=True)

    DNSAddr = getDNS.stdout.split()[1] 

    assert DNSAddr.strip() == "10.0.0.2"

def test_config(): # testar att vi har rätt konfiguration
   getConfig= subprocess.run(["named-checkconf"], capture_output=True, text=True)
   assert getConfig.returncode == 0

def test_forward_zone(): # Vår zon kan laddas av vår DNS
    forward_zone = "grupp13.liu.se"
    forward_file = "/etc/bind/db.grupp13.liu.se"

    
    result = subprocess.run(["named-checkzone", forward_zone, forward_file],capture_output=True, text=True)

    assert result.returncode == 0
    assert "OK" in result.stdout


def test_reverse_zone(): #vår zon kan laddas av vår DNS
    reverse_zone = "0.0.10.in-addr.arpa"
    reverse_file = "/etc/bind/db.10.0.0"

    result = subprocess.run(["named-checkzone", reverse_zone, reverse_file],capture_output=True, text=True)

    assert result.returncode == 0
    assert "OK" in result.stdout

def test_running(): # bind9, dvs våra zoner är aktiva
    result = subprocess.run(["systemctl", "is-active", "bind9"],capture_output=True, text=True)
    assert result.stdout.strip() == "active"

def test_name_forward(): #Varje maskin ger rätt ip adresser
    for name in IpTables: # vår map med namn och ip addresser
        machineName = f"{name}.grupp13.liu.se"
        result = subprocess.run(["dig","+short","@10.0.0.2", machineName],capture_output=True, text=True) #10.0.0.2 är adressen på min DNS server.
        assert result.stdout.strip() == IpTables[name].strip() 

def test_name_reverse(): # Varje ip adress ger rätt namn
    for name in IpTables:
        machineName = f"{name}.grupp13.liu.se."
        result = subprocess.run(["dig","+short","@10.0.0.2", "-x", IpTables[name]],capture_output=True, text=True)
        assert result.stdout.strip() == machineName 
```
## Utdata för name forawrd och name reverse

```console
root@server:~# dig +short @10.0.0.2 -x 10.0.0.3
client-1.grupp13.liu.se.
root@server:~# dig +short @10.0.0.2  client-1.grupp13.liu.se
10.0.0.3
root@server:~# ^C
```