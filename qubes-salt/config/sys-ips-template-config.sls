# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
#
# coder: ro0t
# stamp: 0.211222

# Install all necessery packets
suricata-install-packages:
  pkg.installed:
    - pkgs:
      - qubes-core-agent-networking # Qubes
      - qubes-core-agent-passwordless-root # Qubes
      - libnetfilter-queue-dev # NFQUEUE support suriGUI
      - suricata # IPS
      - jq # for proccessing suriNotif
      - libnotify-bin # suriNotif
      - zenity # not sure if needed ?? maybe Qubes need it
      - yad # suriGUI
      - git # suriGUI

stop-suricata-service:
  cmd.run:
    - name: "systemctl stop suricata"

disable-suricata-service:
  cmd.run:
    - name: "systemctl disable suricata"

# check for update
# better solution needed????


suriGUI-install:
  cmd.run:
    - name: "[ ! -d /usr/share/suriGUI ] && (export https_proxy=127.0.0.1:8082 && git clone https://github.com/control-owl/suriGUI /usr/share/suriGUI && chmod +x /usr/share/suriGUI/suriGUI && ln -s /usr/share/suriGUI/suriGUI /usr/bin/suriGUI)"

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