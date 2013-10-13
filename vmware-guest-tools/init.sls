# This RC script will install VMWare Tools into a kernel at boot.
# It prevents vagrant hanging at configuring shared folders after a kernel upgrade.
#
# Requires the vmware grain from:
# https://github.com/saltstack/salt-contrib/blob/master/grains/vmware.py

{% if grains.get('vmware', false) %}
vmware-guest-tools-update-rc:
  file.managed:
    - name: /etc/rc2.d/S01vmware-guest-tools-update
    - source: salt://vmware-guest-tools/guest-tools-update-rc.sh
    - mode: 744
{% endif %}
