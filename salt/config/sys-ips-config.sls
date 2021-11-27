# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
#
# coder: ro0t
# stamp: 0.211127-so

/rw/config/qubes-bind-dirs.d/50_user.conf:
  file.managed:
    - makedirs: True
    - contents: |
        binds+=( '/etc/suricata/rules/' )
        binds+=( '/usr/share/suriGUI' )
