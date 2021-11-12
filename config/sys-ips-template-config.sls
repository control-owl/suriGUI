# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
#
# coder: ro0t
# stamp: 0.211111-jo


# Install all necessery packets
suricata-install-packages:
  pkg.installed:
    - pkgs:
      - qubes-core-agent-networking # install network support and iptables
      - qubes-core-agent-passwordless-root # needed to run iptables
      - libnetfilter-queue-dev # NFQUEUE support
      - suricata # IPS
      - jq # for proccessing suricata's output
      - libnotify-bin # notification daemon
      - zenity # not sur if needed ??


# Config to enable NFQUEUE and packet forwarding to iptables
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


# Apply custom config
suricata-enable-ips-mode:
  cmd.run:
    - name: "echo include: ips.yaml >> /etc/suricata/suricata.yaml"


# Update Suricata Rules
#
# Use Qubes proxy to download files to no-internet template
# All rules are saved in one file: /etc/suricata/rules/suricata.rules
suricata-update-rules:
  cmd.run:
    - name: "export https_proxy=127.0.0.1:8082 && suricata-update --output /etc/suricata/rules/ --config /etc/suricata/suricata.yaml --data-dir /etc/suricata/ --no-test"


# Set all Rules to rejectboth (IPS)
#
# Possible actions are:
#   alert - generate an alert (Default)
#   pass - stop further inspection of the packet
#   drop - drop packet and generate alert
#   reject - send RST/ICMP unreach error to the sender of the matching packet.
#   rejectsrc - same as just reject
#   rejectdst - send RST/ICMP error packet to receiver of the matching packet.
#   rejectboth - send RST/ICMP error packets to both sides of the conversation. (Our)
suricata-reject-both:
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
    - name: "sudo systemctl enable suricata"


# Create Suricata notification daemon
#
# This script tails eve.json (Suricata output)
# jq is filtering all messages that has alert as event_type
# notify-send displays those messages
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

# last edit 20-11-12-22-31
