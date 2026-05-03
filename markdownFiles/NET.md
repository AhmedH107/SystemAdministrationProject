
## ahmha095

## Guides och annat jag använde

nftables wikin: https://wiki.nftables.org/wiki-nftables/index.php/Quick_reference-nftables_in_10_minutes

Video om nftables : https://www.youtube.com/watch?v=LLbxgVbu4S8


## ping - [NET.1](https://www.ida.liu.se/~TDDI41/2025/uppgifter/net/index.sv.shtml#net.1)  

1.ping -c 5 localhost

2.ping -c 3 -i 2 localhost

## ip - [NET.2](https://www.ida.liu.se/~TDDI41/2025/uppgifter/net/index.sv.shtml#net.2)  

1.ip addr

2.ip link set ens4 up

3.ip addr add 192.168.1.2/24 dev ens4

4.ip route


## nätvärkskonfiguration - [NET.3](https://www.ida.liu.se/~TDDI41/2025/uppgifter/net/index.sv.shtml#net.3)  

öppnade /etc/network/interfaces på routern och la till detta:

```bash
allow-hotplug ens4
iface ens4 inet static
address 10.0.0.1
netmask 255.255.255.0
```
addresen för routern sätter jag till 10.0.0.1 och netmasken gör så att den nu kan kommunicera med maskiner som har adressen 10.0.0.2 till 10.0.0.254.


för resterande maskiner gjorde jag så här (address 10.0.0.2 för servern, 10.0.0.3 för client-1 och 10.0.0.4 för client):
```bash
allow-hotplug ens3
iface ens3 inet static
address 10.0.0.x
netmask 255.255.255.0
gateway 10.0.0.1
root@client-1:~# exit
```
vi satte netmask likt routern men la till en gateway som säger att all trafik går ut genom routern.


## IP-forwarding och -masquerading - [NET.4](https://www.ida.liu.se/~TDDI41/2025/uppgifter/net/index.sv.shtml#net.4)  

öppnade /etc/sysctl.conf med nano och tog bort följande kommentar:

för IP-forwarding
```bash
#net.ipv4.ip_forward=1. 
```



för ip-masquerading lag jag till detta : 

```bash
table inet nat {
	chain postrouting{
	type nat hook postrouting priority 100; policy accept;
	oifname "ens3" masquerade
	}
}
```
detta ändrar ip adressen för allt som lämnar ens3 till routerns address, d.v.s 10.0.0.1

## Justering av värdnamn - [NET.5](https://www.ida.liu.se/~TDDI41/2025/uppgifter/net/index.sv.shtml#net.5)  

ändrade alla hostname till det som stod. Ändrade även /etc/hosts i router till detta:

```console
root@gw:~# cat /etc/hosts
127.0.0.1	localhost
127.0.1.1	gw.grupp13.liu.se	gw

10.0.0.1	gw.grupp13.liu.se	gw
10.0.0.2	server.grupp13.liu.se	server
10.0.0.3	client-1.grupp13.liu.se	client-1
10.0.0.4	client-2.grpp13.liu.se	client-2

 The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
root@gw:~# 
```


## Brandväggar med nftables - [NET.6](https://www.ida.liu.se/~TDDI41/2025/uppgifter/net/index.sv.shtml#net.6)  

Ändrade /etc/nftables.conf till detta : 

```console
root@client-1:~# cat /etc/nftables.conf 
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
	chain input {
		type filter hook input priority 0; policy drop; #drop all trafic if they don't fit the requriements below
		iifname "lo" accept  # accept loop-back
	
		ct state established,related accept #släpper igenom traffik som redan är anslutet, dvs vårt interna nätverk med maskiner

		ip protocol icmp accept #tillåter ping
		ip6 nexthdr icmpv6 accept # accepts neighbour discovery, MAC-addreser ect

		tcp dport {22} accept #tillåter port 22 som ansvarar för ssh
	}
	chain forward {
		type filter hook forward priority 0; policy drop; # drop all trafic passing through the machine, maschine isn’t a router
	}
	chain output {
		type filter hook output priority 0; policy accept; # outgoing traffic from the machine is valid though
	}
}
root@client-1:~# 
```

för routern är det så här:
```console
root@gw:~# cat /etc/nftables.conf 
#!/usr/sbin/nft -f

flush ruleset

table inet filter {

	chain input{
	type filter hook input priority 0; policy drop;

	iifname "lo" accept
	ct state vmap { established : accept, related : accept, invalid : drop }
	
	ip protocol icmp accept
	ip6 nexthdr icmpv6 accept

	tcp dport {22} accept
	}

	chain forward{
	type filter hook forward priority 0; policy drop;
	
	iifname "ens4" oifname "ens3" ct state new, established accept // LAN får starta nya anslutningar till internet
	iifname "ens3" oifname "ens4" ct state established, related accept // Internet får enbart skicka traffik till på anslutningar som LAN har startat  
	}

	chain output{
	type filter hook output priority 0; policy accept;
	}
}

table inet nat {
	chain postrouting{
	type nat hook postrouting priority 100; policy accept;
	oifname "ens3" masquerade
	}
}
root@gw:~# 
```

## Testning av nätverkskonfiguration - [NET.7](https://www.ida.liu.se/~TDDI41/2025/uppgifter/net/index.sv.shtml#net.7)  

```python
  # https://docs.python-guide.org/writing/tests/
# https://docs.pytest.org/en/latest/
# pip install --user pytest
# ~/.local/bin/pytest <fil>

import subprocess

hostname = open("/etc/hostname", "r").read().strip() # can now be used dynamically for all devices

IpTables = {
    "gw" : "10.0.0.1",
    "server" : "10.0.0.2",
    "client-1" : "10.0.0.3",
    "client-2" : "10.0.0.4",
} #map with all our addresses needed

def test_IP(): #Simpely check that we have the correct name with the corect ip adress using our previous map
    getIpAddr = subprocess.run(["hostname","-I"], capture_output=True, text=True)

    IpAddr = getIpAddr.stdout.split()[0] 

    assert IpTables[hostname].strip() == IpAddr  

def test_netmask(): 
    getNetmask = subprocess.run("ip addr| grep inet | grep 10.0.0", capture_output=True, shell=True, text=True)
    
    lines = getNetmask.stdout.strip()
    netmask = lines.split()[1] 
    assert IpTables[hostname].strip() + "/24" == netmask # /24 equals the netmask we put on previously  

def test_gateway():
    getGateway = subprocess.run("ip route | grep default", capture_output=True, shell=True, text=True)

    lines = getGateway.stdout.strip() # get default (10.0.0.1 or 10.0.2.2) via ens3
    gateway = lines.split()[2] # we take the address (10.0.2.2 for router or 10.0.0.1 for everything else)
    if hostname != "gw":
        assert gateway == IpTables["gw"].strip()
    else:
        assert gateway == "10.0.2.2"  

def test_reachRouter(): # we just ping the router and make sure it's no issues
    result = subprocess.run(["ping","-c", "1", IpTables["gw"].strip()], capture_output=True, text=True, timeout=3)

    assert result.returncode == 0

def test_reach_10022(): #we just ping it and make sure it's no issues
    result = subprocess.run(["ping","-c", "1", "10.0.2.2" ], capture_output=True, text=True,timeout=3)

    assert result.returncode == 0


def test_ipForwarding(): # we open the file we edited and make sure that it returns a 1
    if hostname != "gw":
        return
    
    getIPForward = subprocess.run("cat /proc/sys/net/ipv4/ip_forward", capture_output=True, shell=True, text=True)

    result = getIPForward.stdout.strip()

   
    assert result == "1"

def test_masquerade(): # we open the nft rulsets we edited and check that masquerade is on
    if hostname != "gw": #only other machines than router
        return
    
    getMasquerade = subprocess.run("nft list ruleset | grep masquerade", capture_output=True, shell=True, text=True, timeout=3)

    result = getMasquerade.stdout.strip()

    assert result == 'oifname "ens3" masquerade' # for any packet going through ens3, masquerade it's ip
    

def test_ssh(): # using nc we can check if we can ssh or not, by checking if it's open
    getSSh = subprocess.run(["nc", "-zv","localhost", "22"], capture_output=True, text=True, timeout=3)

    lines = getSSh.stderr.strip() #No clue why it's stderr, nc just works like that i guess
    SSHtest = lines.split()[-1]

    assert SSHtest == "open"

def test_lo(): # test for loopback, we just ping ourselves and make sure it had no issues
    result = subprocess.run(["ping","-c", "1", IpTables[hostname].strip()], capture_output=True, text=True,timeout=3)

    assert result.returncode == 0
```