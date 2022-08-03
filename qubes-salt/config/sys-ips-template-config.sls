# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
#
# coder: ro0t
# stamp: 2022-08-03


#
# Dependencies
#
suricata-install-dependencies:
  pkg.installed:
    - pkgs:
      - qubes-core-agent-networking
      - qubes-core-agent-passwordless-root
      - git
      - yad
      - jq
      - libnetfilter-queue-dev
      - suricata


#
# suriGUI
#
suriGUI-install:
  cmd.run:
    - name: "export https_proxy=127.0.0.1:8082 && git clone -b opt https://github.com/control-owl/suriGUI.git /opt/suriGUI"

suriGUI-chown:
  cmd.run:
    - name: "chown user:user /opt/suriGUI -R"

suriGUI-link:
  cmd.run:
    - name: "chmod +x /opt/suriGUI/suriGUI && ln -s /opt/suriGUI/suriGUI /usr/bin/suriGUI"

suriGUI-status-link:
  cmd.run:
    - name: "chmod +x /opt/suriGUI/suriGUI-status && ln -s /opt/suriGUI/suriGUI-status /usr/bin/suriGUI-status"

/etc/xdg/autostart/suriGUI-status.desktop:
  file.managed:
    - makedirs: True
    - contents: |
        [Desktop Entry]
        Version=1.0
        Encoding=UTF-8
        Name=suriGUI-status
        Exec=/usr/bin/suriGUIsuriGUI-status
        Terminal=false
        Type=Application

suriGUI-status-startup-file:
  cmd.run:
    - name: "chmod +x /etc/xdg/autostart/suriGUI-status.desktop"


#
# NFQUEUE service
#
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


#
# SURICATA
#
stop-suricata-service:
  cmd.run:
    - name: "systemctl stop suricata"

/lib/systemd/system/suricata.service:
  file.managed:
    - makedirs: True
    - contents: |
        [Unit]
        Description=Suricata IPS daemon
        After=nfqueue.service
        Before=suriGUI.service
        Requires=network-online.target
        [Service]
        Type=simple
        ExecStartPre=+/bin/bash -c "if [[ ! -e /opt/suriGUI/conf/suricata/suricata.rules ]]; then /bin/suricata-update --output /opt/suriGUI/conf/suricata --data-dir /opt/suriGUI/tmp --no-test ; fi"
        ExecStartPre=+/bin/bash -c "if [[ ! -d /opt/suriGUI/log/$$(date +%%Y-%%m-%%d) ]]; then /bin/mkdir -p /opt/suriGUI/log/$$(date +%%Y-%%m-%%d) ; fi"
        ExecStart=+/bin/bash -c '/usr/bin/suricata -l /opt/suriGUI/log/$$(date +%%Y-%%m-%%d) -c /opt/suriGUI/conf/suricata/suricata.yaml -q 0'
        ExecReload=/usr/bin/suricatasc -c reload-rules ; /bin/kill -HUP $MAINPID
        ExecStop=/usr/bin/suricatasc -c shutdown
        ProtectSystem=full
        ProtectHome=true
        [Install]
        WantedBy=multi-user.target



#
# suriGUI service
#
/lib/systemd/system/suriGUI.service:
  file.managed:
    - makedirs: True
    - contents: |
        [Unit]
        Description=suriGUI service
        After=multi-user.target
        [Service]
        Type=forking
        User=user
        ExecStart=/usr/bin/suriGUI &
        [Install]
        WantedBy=graphical.target

#
#
# [Install]
# WantedBy=graphical.target
# Restart=always
# Services
#
enable-nfqueue-service:
  cmd.run:
    - name: "systemctl enable nfqueue"

enable-suricata-service:
  cmd.run:
    - name: "systemctl enable suricata"

enable-suriGUI-service:
  cmd.run:
    - name: "systemctl enable suriGUI"



#after stable version
#
# suriGUI service
#
# /lib/systemd/system/suriGUI.service:
#   file.managed:
#     - makedirs: True
#     - contents: |
#     [Unit]
#     Description=suriGUI service
#     After=suricata.target
#     [Service]
#     Type=oneshot
#     ExecStart=suriGUI
#     RemainAfterExit=true
#     [Install]
#     WantedBy=multi-user.target
#
# enable-suriGUI-service:
#   cmd.run:
#     - name: "systemctl enable suricata"
