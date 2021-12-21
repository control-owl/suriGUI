![](![](https://github.com/control-owl/qubes-sys-ips/blob/main/sys-ips.jpg))

### Still in development

This project is still in development and it is almost finished.

- [X] Transfer all variables to suriGUISettings
- [X] Create setting file for suriGUISettings
    - [X] Load setting file if exists
    - [x] If not load default values
- [X] Notification daemon
- [X] run suricata as program, not service
- [X] new notebook: rules
    - [X] change rule mode with suriGUISettings
    - [ ] control rule sources
    - [X] update rules
- [ ] only one instance

-------------

### Intro

- Basic concept is to create Intrusion Prevention System (IPS) with Suricata, Debian 11 and Qubes 4.1

-------------

### Features

- Block all malicious incoming and outgoing packets
- Get alerts with notifications
- Firewall per qube is working
- Control Suricata with GUI
- Sys-Tray Icon
-

-------------

### draw.io

![](https://github.com/control-owl/qubes-sys-ips/blob/main/sys-ips.jpg)

-------------

### Process for Qubes 4

1. dom0: Install debian-11-minimal
2. dom0: Clone debian-11-minimal as sys-ips-template
3. sys-ips-template: Install required apps
4. sys-ips-template: Install qubes-sys-ips in /usr/share/suriGUI
5. sys-ips-template: create autostart script for suriGUI
6. dom0: Create qube sys-ips based on sys-ips-template
7. sys-ips: bind-dir /usr/share/suriGUI
8. sys-ips: start suriGUI


-------------

### Installation for Qubes 4.1 (Tested)

##### Personal qube
```sh
git clone https://github.com/control-owl/qubes-sys-ips/
```
##### dom0
```sh
sudo mkdir /srv/salt/config

sudo qvm-run --pass-io personal ’cat /home/user/qubes-sys-ips/salt/sys-ips.top’ | sudo tee /srv/salt/sys-ips.top
sudo qvm-run --pass-io personal ’cat /home/user/qubes-sys-ips/salt/config/sys-ips.sls’ | sudo tee /srv/salt/config/sys-ips.sls
sudo qvm-run --pass-io personal ’cat /home/user/qubes-sys-ips/salt/config/sys-ips-template.sls’ | sudo tee /srv/salt/config/sys-ips-template.sls
sudo qvm-run --pass-io personal ’cat /home/user/qubes-sys-ips/salt/config/sys-ips-template-config.sls’ | sudo tee /srv/salt/config/sys-ips-template-config.sls
sudo qvm-run --pass-io personal ’cat /home/user/qubes-sys-ips/salt/config/sys-ips-config.sls’ | sudo tee /srv/salt/config/sys-ips-config.sls

sudo qubesctl top.enable sys-ips
sudo qubesctl --show-output --all state.highstate
```

-------------

### Installation for Debian 11/Ubuntu (Not tested)

1. git clone https://github.com/control-owl/suriGUI
2. ln -s suriGUI/ /usr/share/suriGUI
2. ln -s /usr/share/suriGUI/suriGUI /bin/suriGUI
3. sudo suriGUI

-------------
