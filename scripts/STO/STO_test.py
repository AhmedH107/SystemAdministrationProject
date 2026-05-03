# https://docs.python-guide.org/writing/tests/
# https://docs.pytest.org/en/latest/
# pip install --user pytest
# ~/.local/bin/pytest <fil>

hostname = open("/etc/hostname", "r").read().strip()

import subprocess

def test_exports_rights():
    if hostname != 'server':
        return
    
    result = subprocess.run(["exportfs", "-v"],capture_output=True, text=True)
    assert "/home-storage1	10.0.0.3(rw,wdelay,root_squash,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)" in result.stdout
    assert "/home-storage1	10.0.0.4(rw,wdelay,root_squash,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)" in result.stdout
    assert "/home-storage2	10.0.0.4(rw,wdelay,root_squash,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)" in result.stdout
    assert "/home-storage2	10.0.0.3(rw,wdelay,root_squash,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)" in result.stdout
    assert "/usr/local    	10.0.0.0/24(rw,wdelay,root_squash,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)" in result.stdout

def test_usrlocal():
    if hostname == 'server':
        return
    
    result = subprocess.run("cat /etc/fstab", capture_output=True, shell=True, text=True)

    assert "10.0.0.2:/usr/local   /mnt/usr-local   nfs4   defaults   0  0" in result.stdout 

def test_automount():
    if hostname != "client-1" or hostname != "clien1-2":
        return

    result = subprocess.run(["automount", "-m"],capture_output=True, text=True)
    
    assert "type: ldap" in result.stdout