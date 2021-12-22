# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
#
# coder: ro0t
# stamp: 0.211222


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
      - autostart: true
      - netvm: sys-net
      - provides-network: True
      - memory: 2048
      - vcpus: 2
    - require:
      - sls: config.sys-ips-template
