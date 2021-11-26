# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
#
# coder: ro0t
# stamp: 0.211114-so

sys-ips-make-suricata-bind:
  cmd.run:
    - name: "mkdir -p /rw/config/qubes-bind-dirs.d"
    - name: "touch /rw/config/qubes-bind-dirs.d/50_user.conf"
    - name: "echo binds+=( \'/etc/suricata/rules/\' ) > /rw/config/qubes-bind-dirs.d/50_user.conf"
