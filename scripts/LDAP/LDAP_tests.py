# https://docs.python-guide.org/writing/tests/
# https://docs.pytest.org/en/latest/
# pip install --user pytest
# ~/.local/bin/pytest <fil>

hostname = open("/etc/hostname", "r").read().strip()

import subprocess

def test_nslcd():
    if hostname == 'gw' or hostname == 'server':
        return
    
    result = subprocess.run(["systemctl", "is-active", "nslcd"],capture_output=True, text=True)
    assert result.stdout.strip() == "active"

def test_slapd():
    if hostname != 'server':
        return
    
    result = subprocess.run(["systemctl", "is-active", "slapd"],capture_output=True, text=True)
    assert result.stdout.strip() == "active"


def test_nssconfig():
    if hostname == 'gw' or hostname == 'server':
        return
    
    nssconfigs = open("/etc/nsswitch.config", "r").read()

    assert 'passwd:         files systemd ldap' in nssconfigs
    assert 'group:          files systemd ldap' in nssconfigs
    assert 'shadow:         files ldap' in nssconfigs

def test_ldapsearch():
    result = subprocess.run(["ldapsearch", "-x", "-H", "ldap://server.grupp13.liu.se", "-b", "dc=superldap,dc=se", "uid=*"], capture_output=True, text=True)
    
    assert result.returncode == 0 #the search worked.

    assert 'dn' in result.stdout # result actually found something

def test_getent():
    result = subprocess.run(["getent", "passwd", "svepe646"], capture_output=True, text=True)
    
    assert result.returncode == 0
    assert 'svepe673' in result.stdout