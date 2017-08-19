include:
  - apt


required-packages:
  pkg.latest:
    - names:
      - apt-transport-https
      - build-essential
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

# use pip to upgrade pip to latest
pip:
  pip.installed:
    - upgrade: true
    - require:
      - pkg: required-packages

setuptools:
  pip.installed:
    - upgrade: true
    - require:
      - pip: pip

pyOpenSSL:
  pip.installed:
    - upgrade: true


{% if pillar.get('timezone', false) %}
{% if grains.get('systemd', false) %}
dbus:
  pkg.installed:
    - require_in:
      - timezone: {{ pillar['timezone'] }}
{% endif %}

{{ pillar['timezone'] }}:
  timezone.system:
    - utc: true
{% endif %}
