# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
#
# coder: ro0t
# stamp: 2022-01-11

# Install all necessery packets
suricata-install-packages:
  pkg.installed:
    - pkgs:
      - qubes-core-agent-networking
      - qubes-core-agent-passwordless-root
      - libnetfilter-queue-dev
      - suricata
      - jq
      - yad
      - git

# Stop default Suricata service
stop-suricata-service:
  cmd.run:
    - name: "systemctl stop suricata"

# Install suriGUI
suriGUI-install:
  cmd.run:
    - name: "[ ! -d /usr/share/suriGUI ] && ( export https_proxy=127.0.0.1:8082 && git clone -b systemctl https://github.com/control-owl/suriGUI.git /usr/share/suriGUI && chmod +x /usr/share/suriGUI/suriGUI && ln -s /usr/share/suriGUI/suriGUI /usr/bin/suriGUI )"

# Modify default Suricata service
/lib/systemd/system/suricata.service:
  file.managed:
    - makedirs: True
    - contents: |
        [Unit]
        Description=Suricata IPS daemon
        After=network.target network-online.target
        Requires=network-online.target
        [Service]
        Type=simple
        ExecStartPre=sudo iptables -I FORWARD -m mark ! --mark 1/1 -j NFQUEUE
        ExecStart=/bin/bash -c '/usr/bin/suricata -l /usr/share/suriGUI/log/$$(date +%%Y-%%m-%%d) -c /usr/share/suriGUI/conf/suricata.yaml --pidfile /usr/share/suriGUI/tmp/suricata.pid -q 0'
        ExecReload=/bin/kill -HUP $MAINPID
        ExecStop=/usr/bin/suricatasc -c shutdown
        ProtectSystem=full
        ProtectHome=true
        [Install]
        WantedBy=multi-user.target

enable-suricata-service:
  cmd.run:
    - name: "systemctl enable suricata"

/etc/xdg/autostart/suriGUI.desktop:
  file.managed:
    - makedirs: True
    - contents: |
        [Desktop Entry]
        Version=1.0
        Encoding=UTF-8
        Name=suriGUI
        Exec=sudo suriGUI
        Terminal=false
        Type=Application

create-startup-file:
  cmd.run:
    - name: "chmod +x /etc/xdg/autostart/suriGUI.desktop"
