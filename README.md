### Intro

- Basic concept is to create intrusion Prevention System (IPS) with Suricata, Debian 11 and Qubes 4.1

-------------

### Features

- Block all malicious incoming and outgoing packets
- Notification daemon
- Qubes firewall still working, globally and per-qube

-------------

### draw.io

![](https://github.com/control-owl/qubes-sys-ips/blob/main/sys-ips.jpg)

-------------

### Explanation

There are two ways how we can install IPS system.
1. Manually download every tool and configure it all by yourself.
2. Do it automatically with program Salt.

I will explain Step 2:

"Salt is Python-based, open-source software for event-driven IT automation, remote task execution, and configuration management." Wiki.

Since Qubes is already using Salt, there is no need to install anything on your system.

Only 4 files are needed to configure IPS.

1. **sys-ips.top** - It tells dom0 what to install and where.
2. **sys-ips.sls** - Configuration for sys-ips qube: memory, cpu, autostart
3. **sys-ips-template.sls** - It tells dom0 that our system is based on debian 11 minimal
4. **sys-ips-template-config.sls** - This is main configuration file to set up our template qube with all necessary tools and config

All configs and rules are done in template qube, NOT appVM qube.
This way if some code get foothold in our sys-ips, we only need to restart sys-ips and whole system is wiped clean.
(Next step is to make whole system disposable... still in progress)

-------------

### Installation

##### Personal qube
```sh
git clone https://github.com/control-owl/qubes-sys-ips
```
##### dom0
```sh
sudo qvm-run --pass-io personal ’cat /home/user/qubes-sys-ips/sys-ips.top’ > /srv/salt/sys.ips.top

sudo mkdir /srv/salt/config

sudo qvm-run --pass-io personal ’cat /home/user/qubes-sys-ips/config/sys-ips.sls’ > /srv/salt/config/sys-ips.sls

sudo qvm-run --pass-io personal ’cat /home/user/qubes-sys-ips/config/sys-ips-template.sls’ > /srv/salt/config/sys-ips-template.sls

sudo qvm-run --pass-io personal ’cat /home/user/qubes-sys-ips/config/sys-ips-template-config.sls’ > /srv/salt/config/sys-ips-template-config.sls
```

-------------

### To-do

- [ ] Detect if debian-11-minimal is already installed
    - [ ] If not, install it
- [ ] Create sys-ips as disposable
- [ ] Create sys-tray app for Suricata
    - [ ] Icon color is app status (green, red)
    - [ ] Start, stop, reset, update rules, change action
    - [ ] Log to gui
    - [ ] edit rules with gui
    - [ ] permanent log
