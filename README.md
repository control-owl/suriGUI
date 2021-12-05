### Still in development

-------------

### Intro

- Basic concept is to create intrusion Prevention System (IPS) with Suricata, Debian 11 and Qubes 4.1

-------------

### Features

- Block all malicious incoming and outgoing packets
- Notification daemon
- Use Suricata and Qubes Firewall

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

Only 5 files are needed to configure IPS.

1. **sys-ips.top** - It tells dom0 what to install and where.
2. **sys-ips.sls** - Configuration for sys-ips qube: memory, cpu, autostart
3. **sys-ips-config.sls** - This is main configuration file for sys-ips qube
4. **sys-ips-template.sls** - It tells dom0 that our system is based on debian 11 minimal
5. **sys-ips-template-config.sls** - This is main configuration file to set up our template qube with all necessary tools and config

-------------

### Installation

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
Then just wait for dom0 to download and configure it all.

-------------

This project is still in heavy development.
I am writing peaces of code every day.
In theory basic stuff is working.
I will try to update as much as I can.
But, before this peaces are not done, I am calling this not even a beta.

- [X] Transfer all variables to suriGUISettings
- [X] Create setting file for suriGUISettings
    - [X] Load setting file if exists
    - [x] If not load default values
- [X] Option to switch mode: IPS and IDS
- [ ] Notification daemon
- [ ] try to avoid sudo
- [X] run suricata as program, not service
- [X] new notebook: rules
    - [X] change rule mode with suriGUISettings
    - [ ] control rule sources
    - [ ] update rules
