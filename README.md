![](https://github.com/control-owl/suriGUI/blob/main/res/suriGUI.png)

### Still in development

This project is still in development and it is almost finished.

-------------

### Intro

- Basic concept is to create GUI Interface for Suricata IPS
- Option to show Desktop notifications on every alert

-------------

### QUBES draw.io

![](https://github.com/control-owl/suriGUI/blob/main/res/sys-ips.jpg)


#### System Tray statuses: Active and Inactive icon
![](https://github.com/control-owl/suriGUI/blob/main/res/status.png)
-------------

### Installation for Qubes 4.1 (Tested)

##### sys-firewall qube
```sh
git clone https://github.com/control-owl/suriGUI/
```
##### dom0
```sh
sudo mkdir /srv/salt/config

sudo qvm-run --pass-io sys-firewall ’cat /home/user/suriGUI/salt/sys-ips.top’ | sudo tee /srv/salt/sys-ips.top
sudo qvm-run --pass-io sys-firewall ’cat /home/user/suriGUI/salt/config/sys-ips.sls’ | sudo tee /srv/salt/config/sys-ips.sls
sudo qvm-run --pass-io sys-firewall ’cat /home/user/suriGUI/salt/config/sys-ips-template.sls’ | sudo tee /srv/salt/config/sys-ips-template.sls
sudo qvm-run --pass-io sys-firewall ’cat /home/user/suriGUI/salt/config/sys-ips-template-config.sls’ | sudo tee /srv/salt/config/sys-ips-template-config.sls
sudo qvm-run --pass-io sys-firewall ’cat /home/user/suriGUI/salt/config/sys-ips-config.sls’ | sudo tee /srv/salt/config/sys-ips-config.sls

sudo qubesctl top.enable sys-ips
sudo qubesctl --show-output --all state.highstate
```

-------------

### Process for Qubes 4 explained

1. dom0: Install debian-11-minimal
2. dom0: Clone debian-11-minimal as sys-ips-template
3. sys-ips-template: Install required apps
4. sys-ips-template: Install suriGUI in /usr/share/suriGUI
5. sys-ips-template: create autostart script for suriGUI
6. dom0: Create qube sys-ips based on sys-ips-template
7. sys-ips: bind-dir /usr/share/suriGUI
8. sys-ips: start suriGUI

-------------

### Installation for Debian 11/Ubuntu (Not tested)

1. git clone https://github.com/control-owl/suriGUI
2. ln -s suriGUI/ /usr/share/suriGUI
2. ln -s /usr/share/suriGUI/suriGUI /bin/suriGUI
3. sudo suriGUI

-------------

Project is free.
Donation are welcome.
Motivation even more.
BTC 1JDYtxVvisQxFX1KrZ8yhYYQiqnfS4sFaa


-------------

### NEXT STEPS:

* d3bug to log
* program parameters --debug --output --silent
