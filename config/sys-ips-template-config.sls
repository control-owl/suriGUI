# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
#
# coder: ro0t
# stamp: 0.211111-jo


# Install all necessery packets for running NFQUEUE, Suricata and Notifications
install-suricata-packages:
  pkg.installed:
    - pkgs:
      - qubes-core-agent-networking
      - qubes-core-agent-passwordless-root
      - libnetfilter-queue-dev
      - suricata
      - jq
      - libnotify-bin
      - zenity


# Add custom config for NFQUEUE
enable-ips-mode:
  cmd.run:
    - name: "echo include: ips.yaml >> /etc/suricata/suricata.yaml"


# Enable NFQUEUE
/etc/suricata/ips.yaml:
  file.managed:
    - makedirs: True
    - contents: |
        %YAML 1.1
        ---
        
        nfq:
          mode: repeat
          repeat-mark: 1
          repeat-mask: 1


# Download latest Suricata Rules
update-suricata:
  cmd.run:
    - name: "export https_proxy=127.0.0.1:8082 && suricata-update --output /etc/suricata/rules/ --config /etc/suricata/suricata.yaml --data-dir /etc/suricata/ --no-test"


# Set all Rules to rejectboth (IPS)
reject-all:
  cmd.run:
    - name: "sed -i 's/alert/rejectboth/' /etc/suricata/rules/suricata.rules"


# Create Suricata service
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
        EnvironmentFile=-/etc/default/suricata
        ExecStartPre=sudo iptables -I FORWARD -m mark ! --mark 1/1 -j NFQUEUE
        ExecStart=/usr/bin/suricata -c /etc/suricata/suricata.yaml -q 0
        ExecReload=/bin/kill -HUP $MAINPID
        ExecStop=/usr/bin/suricatasc -c shutdown
        Restart=on-failure
        ProtectSystem=full
        ProtectHome=true
        
        [Install]
        WantedBy=multi-user.target


# Enable Suricata Service on boot
enable-suricata-service:
  cmd.run:
    - name: "systemctl enable suricata"


# Create Suricata notification daemon
/etc/suricata/suricata-notif:
  file.managed:
    - makedirs: True
    - contents: |
        #!/bin/bash
        if [[ ! -f /var/log/suricata/eve.json ]]; then
          sleep 5
        else
          /usr/lib/notification-daemon/notification-daemon &
          tail -f /var/log/suricata/eve.json \
           | jq --unbuffered -r -c 'select(.event_type=="alert")' \
           | jq --unbuffered -r '@sh  "sid=\(.alert.signature_id) category=\(.alert.category)  signature=\(.alert.signature) SRC=\(.src_ip) DEST=\(.dest_ip)  action=\(.alert.action)"' \
           | while read -r line; do \
               eval "$line" ; \
               notify-send  "$category"  "$(echo -e "Signature: $signature \nSID: $sid \nSource: $SRC \nDestination: $DEST  \nAction: $action")" -t 2000 ; \
             done &
        fi


# Start Suricata notification daemon on boot
/etc/xdg/autostart/suricata-notif.desktop:
  file.managed:
    - makedirs: True
    - contents: |
        [Desktop Entry]
        Version=1.0
        Encoding=UTF-8
        Name=Suricata notifications
        Exec=sudo /etc/suricata/suricata-notif
        Terminal=false
        Type=Application


# Make executable
make-executable:
  cmd.run:
    - name: "chmod +x /etc/suricata/suricata-notif /etc/xdg/autostart/suricata-notif.desktop"
