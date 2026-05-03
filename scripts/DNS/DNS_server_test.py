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

def test_DNS():
    getDNS = subprocess.run("cat /etc/resolv.conf | grep 10.0.0", capture_output=True, shell=True, text=True)

    DNSAddr = getDNS.stdout.split()[1] 

    assert DNSAddr.strip() == "10.0.0.2"

def test_config(): #test for syntax or bad settings
   getConfig= subprocess.run(["named-checkconf"], capture_output=True, text=True)
   assert getConfig.returncode == 0

def test_forward_zone(): 
    forward_zone = "grupp13.liu.se"
    forward_file = "/etc/bind/db.grupp13.liu.se"

    
    result = subprocess.run(["named-checkzone", forward_zone, forward_file],capture_output=True, text=True)

    assert result.returncode == 0
    assert "OK" in result.stdout


def test_reverse_zone():
    reverse_zone = "0.0.10.in-addr.arpa"
    reverse_file = "/etc/bind/db.10.0.0"

    result = subprocess.run(["named-checkzone", reverse_zone, reverse_file],capture_output=True, text=True)

    assert result.returncode == 0
    assert "OK" in result.stdout

def test_running():
    result = subprocess.run(["systemctl", "is-active", "bind9"],capture_output=True, text=True)

    assert result.stdout.strip() == "active"

def test_name_forward():
    for name in IpTables:
        machineName = f"{name}.grupp13.liu.se"
        result = subprocess.run(["dig","+short","@10.0.0.2", machineName],capture_output=True, text=True)
        assert result.stdout.strip() == IpTables[name].strip() 

def test_name_reverse():
    for name in IpTables:
        machineName = f"{name}.grupp13.liu.se."
        result = subprocess.run(["dig","+short","@10.0.0.2", "-x", IpTables[name]],capture_output=True, text=True)
        assert result.stdout.strip() == machineName 