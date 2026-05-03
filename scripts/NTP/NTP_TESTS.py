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


# ^root = lines begining with 'root', capture_output = save the output in res 
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

            assert  abs(delay) < 100
            assert jitters < 100
            assert delay < 500
        else:
            assert 0 == 1, "no * somehow"