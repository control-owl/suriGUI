### Intro

- Basic concept is to create intrusion Prevention System (IPS) with Suricata, Debian 11 and Qubes 4.1

### Features

- Block all malicious incoming and outgoing packets
- Notification daemon
- Qubes firewall still working, globally and per-qube

### draw.io

![](https://github.com/control-owl/qubes-sys-ips/blob/main/sys-ips.jpg)

### Installation

- Copy sys-ips.top to dom0: /srv/salt/sys-ips.top
- Copy config/ directory to dom0: /srv/salt/config/
- sudo qubesctl top.enable sys-ips
- sudo qubesctl --all state.highstate

### Explanation
