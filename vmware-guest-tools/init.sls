# This RC script will install VMWare Tools into a kernel at boot.
# It prevents vagrant hanging at configuring shared folders after a kernel upgrade.
#
# Requires the vmware grain from:
# https://github.com/mafrosis/salt-formulae/blob/master/_grains/vmware.py

{% if grains['os_family'] == "Debian" and (grains.get('vmware', false) or grains.get('virtual', '') == "VMware") %}
vmware-guest-tools-update-script:
  file.managed:
    - name: /etc/init.d/vmware-guest-tools-update
    - source: salt://vmware-guest-tools/guest-tools-update-rc.sh
    - mode: 744

vmware-guest-tools-update:
  service.enabled:
    - require:
      - file: vmware-guest-tools-update-script
{% endif %}
