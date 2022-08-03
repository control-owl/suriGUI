# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
#
# coder: ro0t
# stamp: 2022-08-03

/rw/config/qubes-bind-dirs.d/50_user.conf:
  file.managed:
    - makedirs: True
    - contents: |
    binds+=( '/opt/suriGUI' )
