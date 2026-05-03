# https://docs.python-guide.org/writing/tests/
# https://docs.pytest.org/en/latest/
# pip install --user pytest
# ~/.local/bin/pytest <fil>

#Fucking retarded how to run test o VM?? ran
import subprocess

def test_DNS():
    getDNS = subprocess.run("cat /etc/resolv.conf | grep 10.0.0", capture_output=True, shell=True, text=True)

    DNSAddr = getDNS.stdout.split()[1] 

    assert DNSAddr.strip() == "10.0.0.2"
