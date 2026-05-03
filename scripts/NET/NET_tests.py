# https://docs.python-guide.org/writing/tests/
# https://docs.pytest.org/en/latest/
# pip install --user pytest
# ~/.local/bin/pytest <fil>

#Fucking retarded how to run test o VM?? ran
import subprocess

hostname = open("/etc/hostname", "r").read().strip()

IpTables = {
    "gw" : "10.0.0.1",
    "server" : "10.0.0.2",
    "client-1" : "10.0.0.3",
    "client-2" : "10.0.0.4",
} 

def test_IP():
    getIpAddr = subprocess.run(["hostname","-I"], capture_output=True, text=True)

    IpAddr = getIpAddr.stdout.split()[0] 

    assert IpTables[hostname].strip() == IpAddr  

def test_netmask():
    getNetmask = subprocess.run("ip addr| grep inet | grep 10.0.0", capture_output=True, shell=True, text=True)
    
    lines = getNetmask.stdout.strip()
    netmask = lines.split()[1] 
    assert IpTables[hostname].strip() + "/24" == netmask  

def test_gateway():
    getGateway = subprocess.run("ip route | grep default", capture_output=True, shell=True, text=True)

    lines = getGateway.stdout.strip()
    gateway = lines.split()[2]
    if hostname != "gw":
        assert gateway == IpTables["gw"].strip()
    else:
        assert gateway == "10.0.2.2"  

def test_reachRouter():
    result = subprocess.run(["ping","-c", "1", IpTables["gw"].strip()], capture_output=True, text=True, timeout=3)

    assert result.returncode == 0

def test_reach_10022():
    result = subprocess.run(["ping","-c", "1", "10.0.2.2" ], capture_output=True, text=True,timeout=3)

    assert result.returncode == 0


def test_ipForwarding():
    if hostname != "gw":
        return
    
    getIPForward = subprocess.run("cat /proc/sys/net/ipv4/ip_forward", capture_output=True, shell=True, text=True)

    result = getIPForward.stdout.strip()

   
    assert result == "1"

def test_masquerade():
    if hostname != "gw":
        return
    
    getMasquerade = subprocess.run("nft list ruleset | grep masquerade", capture_output=True, shell=True, text=True, timeout=3)

    result = getMasquerade.stdout.strip()

    assert result == 'oifname "ens3" masquerade'
    #getMasquerade = subprocess.run("ip route | grep masquerade", capture_output=True, shell=True, text=True)

    #lines = getMasquerade.stdout.strip()
    #masquerade = lines.split()[2] 

    #assert masquerade == "masquerade"

def test_ssh():
    getSSh = subprocess.run(["nc", "-zv","localhost", "22"], capture_output=True, text=True, timeout=3)

    lines = getSSh.stderr.strip() #No clue why it's stderr, nc just works like that i guess
    SSHtest = lines.split()[-1]

    assert SSHtest == "open"

def test_lo():
    result = subprocess.run(["ping","-c", "1", IpTables[hostname].strip()], capture_output=True, text=True,timeout=3)

    assert result.returncode == 0