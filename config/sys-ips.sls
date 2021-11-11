# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
#
# coder: ro0t
# stamp: 0.211111-jo


include:
  - config.sys-ips-template

create-sys-ips:
  qvm.vm:
    - name: sys-ips
    - present:
      - template: sys-ips-template
      - label: red
    - prefs:
      - include-in-backup: False
      - netvm: sys-net
      - provides-network: True
    - require:
      - sls: config.sys-ips-template
