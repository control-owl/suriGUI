# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
#
# coder: ro0t
# stamp: 2022-01-14

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
    - name: "[ ! -d /usr/share/suriGUI ] && ( export https_proxy=127.0.0.1:8082 && git clone https://github.com/control-owl/suriGUI.git /usr/share/suriGUI && chmod +x /usr/share/suriGUI/suriGUI && ln -s /usr/share/suriGUI/suriGUI /usr/bin/suriGUI )"

# Change ownership
suriGUI-chown:
  cmd.run:
    - name: "chown user:user /usr/share/suriGUI -R"

/lib/systemd/system/nfqueue.service:
  file.managed:
    - makedirs: True
    - contents: |
        [Unit]
        Description=NFQUEUE service
        After=network.target
        Before=suricata.service
        [Service]
        Type=oneshot
        ExecStart=sudo iptables -I FORWARD -m mark ! --mark 1/1 -j NFQUEUE
        RemainAfterExit=true
        [Install]
        WantedBy=multi-user.target

enable-nfqueue-service:
  cmd.run:
    - name: "systemctl enable nfqueue"

# Modify default Suricata service
/lib/systemd/system/suricata.service:
  file.managed:
    - makedirs: True
    - contents: |
        [Unit]
        Description=Suricata IPS daemon
        After=nfqueue.service
        Requires=network-online.target
        [Service]
        Type=simple
        ExecStartPre=+/bin/bash -c "if [[ ! -e /usr/share/suriGUI/conf/suricata.rules ]]; then /bin/suricata-update --output /usr/share/suriGUI/conf --no-test ; fi"
        ExecStartPre=+/bin/bash -c "if [[ ! -d /usr/share/suriGUI/log/$$(date +%%Y-%%m-%%d) ]]; then /bin/mkdir -p /usr/share/suriGUI/log/$$(date +%%Y-%%m-%%d) ; fi"
        ExecStart=+/bin/bash -c '/usr/bin/suricata -l /usr/share/suriGUI/log/$$(date +%%Y-%%m-%%d) -c /usr/share/suriGUI/conf/suricata.yaml -q 0'
        ExecReload=/usr/bin/suricatasc -c reload-rules ; /bin/kill -HUP $MAINPID
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
        Exec=suriGUI
        Terminal=false
        Type=Application

create-startup-file:
  cmd.run:
    - name: "chmod +x /etc/xdg/autostart/suriGUI.desktop"
