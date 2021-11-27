# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
#
# coder: ro0t
# stamp: 0.211127-so

# Install all necessery packets
suricata-install-packages:
  pkg.installed:
    - pkgs:
      - qubes-core-agent-networking
      - qubes-core-agent-passwordless-root
      - libnetfilter-queue-dev # NFQUEUE support
      - suricata
      - jq # for proccessing suricata's output
      - libnotify-bin # notification daemon
      - zenity # not sure if needed ??
      - yad
      - git

stop-suricata-service:
  cmd.run:
    - name: "systemctl stop suricata"

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

suricata-enable-ips-mode:
  cmd.run:
    - name: "echo include: ips.yaml >> /etc/suricata/suricata.yaml"

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

enable-suricata-service:
  cmd.run:
    - name: "systemctl enable suricata"

clone-surigui:
  cmd.run:
    - name: "[ ! -d /usr/share/suriGUI ] && (export https_proxy=127.0.0.1:8082 && git clone https://github.com/control-owl/qubes-sys-ips /usr/share/suriGUI && chmod +x /usr/share/suriGUI/suriGUI && ln -s /usr/share/suriGUI/suriGUI /usr/bin/suriGUI) || (cd /usr/share/suriGUI/ && git pull origin main)"

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
