## ahmha095

## Grunderna i NTP - [NTP.1](https://www.ida.liu.se/~TDDI41/2025/uppgifter/ntp/index.sv.shtml#ntp.1) 

1. Ett startum är en nivå i NTP hierarki som säger hur 'nära' en server är till den riktiga tidkällan. Man talar inte direkt med en referensserver, eftersom den servern skulle bli snabbt överbelastad. Istället gör man så att stratum 1 -> pratar direkt med klockan, startum 2 -> synkar mot stratum 1, stratum 3 -> synkar mot startum 2 ect

2. Det är för att bevara algoritmer som är beroende av tid, om vi hoppar direkt till rätt tidslag kan exemplevis timeouts, kernel-timers eller realtids kod brytas.

3. 

```console
root@gw:~# ntpq -p
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
 0.debian.pool.n .POOL.          16 p    -   64    0    0.000   +0.000   0.000
 1.debian.pool.n .POOL.          16 p    -   64    0    0.000   +0.000   0.000
 2.debian.pool.n .POOL.          16 p    -   64    0    0.000   +0.000   0.000
 3.debian.pool.n .POOL.          16 p    -   64    0    0.000   +0.000   0.000
+sth1.ntp.netnod .PPS.            1 u    6   64    1    3.622   +2.947   1.493
+172-232-146-46. 82.68.30.35      3 u    6   64    1    3.925   +1.697   1.432
+lul1.ntp.netnod .PPS.            1 u    5   64    1   15.046   +2.029   2.050
+45.83.221.52    194.58.204.148   2 u    5   64    1   10.515   +3.285   2.438
+lul2.ntp.netnod .PPS.            1 u    6   64    1   14.836   +2.555   1.987
+ntp1.vmar.se    194.58.202.148   2 u    2   64    1    5.437   +0.293   3.067
+time.cloudflare 10.6.8.11        3 u    1   64    1    4.830   -0.088   3.072
*sth3.ntp.netnod .PPS.            1 u    2   64    1    3.648   +0.687   2.992
+time.cloudflare 10.128.8.84      3 u    4   64    1    4.734   +1.450   2.623
+h-98-128-175-45 194.58.203.148   2 u    3   64    1   11.632   +0.905   2.977
#172-232-157-27. 82.68.30.35      3 u    1   64    1    4.423   +1.482   2.635
+172-232-132-19. 82.68.30.35      3 u    5   64    1    4.843   -0.592   2.704
+ntp2.flashdance 193.11.166.52    2 u    5   64    1    4.297   +1.431   2.635
+sto1.se.ntp.li  96.180.207.109   2 u    2   64    1    6.424   +1.031   2.442
+ntp3.flashdance 193.11.166.52    2 u    3   64    1    4.973   +0.201   3.121
#92.246.137.39 ( 194.58.203.148   2 u    3   64    1   44.621   +2.241   3.161
root@gw:~# 
```

remote: NTP servern klienten pratar med.

refid: vilken tidskälla den servern anänder, .PPS.(pulse per second), server upsteam IP-adress eller .POOL. (pool plats) 

st: Hur långt bort servern är från den riktiga tidskällan

t: hur klienten kommunicerar med servern, u(unicast), p(pool)

when: hur länge sedan den senaste kontaken skedde

poll: hur ofta klienten frågar servern (var 64 sekund)

reach:ifall klienten når servern eller inte, 1 = ja, 0 = nej

delay: round-trip time till servern

offset: Hur många millisekunder servern skiller sig från klockan

jitter: visar hur stabil servern är, säger hur mycket offset varierar med tiden

symbolerna längst till vänster i terminalen är viktiga de med.

*: den servern som används aktuellt.
+: server med bra kvalite
#: mindre bra servers
 siffrorna längst up: Vilka pooler vi slumpade fram

## Grunderna i NTP - [NTP.2](https://www.ida.liu.se/~TDDI41/2025/uppgifter/ntp/index.sv.shtml#ntp.2)

följde denna guide (https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-configuring_ntp_using_ntpd)
 
 efter installation så öppnade jag /etc/ntp.conf och la till några rader.

```console
 root@gw:~# cat /etc/ntp.conf 
# /etc/ntp.conf, configuration for ntpd; see ntp.conf(5) for help

driftfile /var/lib/ntp/ntp.drift

# Leap seconds definition provided by tzdata
leapfile /usr/share/zoneinfo/leap-seconds.list

# Enable this if you want statistics to be logged.
#statsdir /var/log/ntpstats/

statistics loopstats peerstats clockstats
filegen loopstats file loopstats type day enable
filegen peerstats file peerstats type day enable
filegen clockstats file clockstats type day enable


# You do need to talk to an NTP server or two (or three).
#server ntp.your-provider.example

# pool.ntp.org maps to about 1000 low-stratum NTP servers.  Your server will
# pick a different set every time it starts up.  Please consider joining the
# pool: <http://www.pool.ntp.org/join.html>
server 0.se.pool.ntp.org iburst #<----------------servern vi ville ha

# Access control configuration; see /usr/share/doc/ntp-doc/html/accopt.html for
# details.  The web page <http://support.ntp.org/bin/view/Support/AccessRestrictions>
# might also be helpful.
#
# Note that "restrict" applies to both servers and clients, so a configuration
# that might be intended to block requests from certain clients could also end
# up blocking replies from your own upstream servers.

# By default, exchange time with everybody, but don't allow configuration.
restrict -4 default kod notrap nomodify nopeer noquery
restrict -6 default kod notrap nomodify nopeer noquery

# Local users may interrogate the ntp server more closely.
restrict 127.0.0.1
restrict ::1

# Needed for adding pool entries
restrict source notrap nomodify noquery

# Clients from this (example!) subnet have unlimited access, but only if
# cryptographically authenticated.
restrict 10.0.0.0 mask 255.255.255.0 nomodify notrap #<--------acceptera våra maskiner och 


# If you want to provide time to your local subnet, change the next line.
# (Again, the address is an example only.)
#broadcast 10.0.0.255

# If you want to listen to time broadcasts on your local subnet, de-comment the
# next lines.  Please do this only if you trust everybody on the network!
#disable auth
#broadcastclient
root@gw:~# 
```


I klienten:

```console
root@client-1:~# cat /etc/ntp.conf 
...
# You do need to talk to an NTP server or two (or three).
server 10.0.0.1 iburst #<--------------------Vår Router 
...
root@client-1:~# 
```

genom ntpq -p :
```
root@client-1:~# ntpq -p
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
 gw.grupp13.liu. 194.58.205.148   2 u   18   64    1    1.932  +67.6   0.001
root@client-1:~# 
```
ser att vi får tid genom vår router (gw.grupp13.liu.), vi når den och får acceptabelt med jitter, delay och offset.

## Testning - [NTP.3](https://www.ida.liu.se/~TDDI41/2025/uppgifter/ntp/index.sv.shtml#ntp.3)
```python
# https://docs.python-guide.org/writing/tests/
# https://docs.pytest.org/en/latest/
# pip install --user pytest
# ~/.local/bin/pytest <fil>


import subprocess

hostname = open("/etc/hostname", "r").read().strip()

IpTables = {
    "gw" : "10.0.0.1",
    "server" : "10.0.0.2",
    "client-1" : "10.0.0.3",
    "client-2" : "10.0.0.4",
}



def test_routerconf():
    if hostname != "gw":
        return
    
    res = subprocess.run(["cat", "/etc/ntp.conf"], capture_output=True, text=True)
    
    assert res.returncode == 0

    assert  "restrict 10.0.0.0 mask 255.255.255.0 nomodify notrap" in res.stdout #Only our machines have access
    assert "server 0.se.pool.ntp.org iburst" in res.stdout # we have right server

def test_ntpqrouter(): #test local quries
    if hostname != "gw":
        return
    
    res = subprocess.run(["ntpq", "-p"], capture_output=True, text=True)

    assert "*" in res.stdout #There is our upstream server

def test_ntpqclient(): #test local quries
    if hostname == "gw" or hostname == "server":
        return
    
    res = subprocess.run(["ntpq", "-p"], capture_output=True, text=True)

    assert "*" in res.stdout #There is our upstream server
    assert "gw.grupp13.liu" in res.stdout #right ntp server

def test_clinetconf():
    if hostname == "gw" or hostname == "server":
        return
    
    res = subprocess.run(["cat", "/etc/ntp.conf"], capture_output=True, text=True)
    
    assert res.returncode == 0

    assert  "server 10.0.0.1 iburst" in res.stdout #We listin to the router

def test_delay_and_offset():
    if hostname == "gw":
        return
    
    res = subprocess.run(["ntpq", "-p"], capture_output=True, text=True)

    lines = res.stdout.splitlines()

    for line in lines:
        if '*' in line:
            columns = line.split()

            delay = float(columns[7]) 
            offset = float(columns[8])
            jitters = float(columns[9])

            assert  abs(offset) < 100 #acceptable offset
            assert jitters < 100 #acceptable jitter
            assert delay < 100 #acceptable delay
        else:
            assert 0 == 1, "no * somehow"
```