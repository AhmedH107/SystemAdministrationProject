# https://docs.python-guide.org/writing/tests/
# https://docs.pytest.org/en/latest/
# pip install --user pytest
# ~/.local/bin/pytest <fil>


import subprocess

# ^root = lines begining with 'root', capture_output = save the output in res 
def test_root():
    res = subprocess.run(["grep", "^root:", "/etc/passwd"], capture_output=True, text=True)
    assert res.returncode == 0

def test_true():
    shells = subprocess.run(["cat", "/etc/shells"], capture_output=True, text=True)
    lines = shells.stdout.splitlines()

    valid = []

    for line in lines:
        name = line.strip()
        if name and not name.startswith('#'):
            valid.append(name.split()[0]) #remove white space, might be really un-needed

    res = subprocess.run(["grep", "^games:", "/etc/passwd"], capture_output=True, text=True)
    strings = res.stdout.strip()
    fields = strings.split(":")
    gameshell = fields[-1].strip() 

    assert gameshell not in valid