# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
#
# coder: ro0t
# stamp: 0.220111


# Install all necessery packets
suricata-install-packages:
  pkg.installed:
    - pkgs:
      - qubes-core-agent-networking # Qubes
      - qubes-core-agent-passwordless-root # Qubes
      - libnetfilter-queue-dev # Suricata NFQUEUE
      - suricata # IPS
      - jq # for proccessing output
      - yad # suriGUI
      - git # suriGUI


# Stop default Suricata service
stop-suricata-service:
  cmd.run:
    - name: "systemctl stop suricata"


# Install suriGUI
    suriGUI-install:
      cmd.run:
        - name: "[ ! -d /usr/share/suriGUI ] && (export https_proxy=127.0.0.1:8082 && git clone https://github.com/control-owl/suriGUI /usr/share/suriGUI && chmod +x /usr/share/suriGUI/suriGUI && ln -s /usr/share/suriGUI/suriGUI /usr/bin/suriGUI)"


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
        EnvironmentFile=-/usr/share/suriGUI/conf/suricata.env
        ExecStartPre=sudo iptables -I FORWARD -m mark ! --mark 1/1 -j NFQUEUE
        ExecStart=/usr/bin/suricata
        ExecReload=/bin/kill -HUP $MAINPID
        ExecStop=/usr/bin/suricatasc -c shutdown
        Restart=on-failure
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
