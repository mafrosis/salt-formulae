include:
  - apt
  - vmware-guest-tools


required-packages:
  pkg.latest:
    - names:
      - coreutils
      - debconf-utils
      {% if grains['os'] == 'Ubuntu' %}
      - language-pack-en
      {% endif %}
      - libffi-dev
      - libssl-dev
      - man-db
      - ntp
      - python-apt
      - python-dev
      - python-pip
      - software-properties-common
      - swig
      - vim
    - require:
      - file: apt-no-recommends

esky:
  pip.installed:
    - require:
      - pkg: required-packages


{% if pillar.get('timezone', false) %}
{% if grains.get('systemd', False) %}
dbus:
  pkg.installed:
    - require_in:
      - timezone: {{ pillar['timezone'] }}
{% endif %}

{{ pillar['timezone'] }}:
  timezone.system:
    - utc: True
{% endif %}
