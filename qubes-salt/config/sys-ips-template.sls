# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
#
# coder: ro0t
# stamp: 0.211222

qvm-template-installed:
    qvm.template_installed:
        - name: debian-11-minimal
        - fromrepo: qubes-templates-itl-testing

create-sys-ips-template:
  qvm.clone:
    - name: sys-ips-template
    - source: debian-11-minimal
    - label: black
