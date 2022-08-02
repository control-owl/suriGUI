# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
#
# coder: ro0t
# stamp: 2022-08-02

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
    - name: "export https_proxy=127.0.0.1:8082 && git clone https://github.com/control-owl/suriGUI.git /home/user/suriGUI"

suriGUI-link:
  cmd.run:
    - name: "chmod +x /home/user/suriGUI/suriGUI && ln -s /home/user/suriGUI/suriGUI /usr/bin/suriGUI"

suriGUI-chown:
  cmd.run:
    - name: "chown user:user /home/user/suriGUI -R"

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

suriGUI-startup-file:
  cmd.run:
    - name: "chmod +x /etc/xdg/autostart/suriGUI.desktop"

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
        Requires=network-online.target
        [Service]
        Type=simple
        ExecStartPre=+/bin/bash -c "if [[ ! -e /home/user/suriGUI/conf/suricata/suricata.rules ]]; then /bin/suricata-update --output /home/user/suriGUI/conf/suricata --data-dir /home/user/suriGUI/tmp --no-test ; fi"
        ExecStartPre=+/bin/bash -c "if [[ ! -d /home/user/suriGUI/log/$$(date +%%Y-%%m-%%d) ]]; then /bin/mkdir -p /home/user/suriGUI/log/$$(date +%%Y-%%m-%%d) ; fi"
        ExecStart=+/bin/bash -c '/usr/bin/suricata -l /home/user/suriGUI/log/$$(date +%%Y-%%m-%%d) -c /home/user/suriGUI/conf/suricata/suricata.yaml -q 0'
        ExecReload=/usr/bin/suricatasc -c reload-rules ; /bin/kill -HUP $MAINPID
        ExecStop=/usr/bin/suricatasc -c shutdown
        ProtectSystem=full
        ProtectHome=true
        [Install]
        WantedBy=multi-user.target

#
# Services
#
enable-nfqueue-service:
  cmd.run:
    - name: "systemctl enable nfqueue"

enable-suricata-service:
  cmd.run:
    - name: "systemctl enable suricata"



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
