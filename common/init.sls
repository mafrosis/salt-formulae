include:
  - apt
  - vmware-guest-tools

{% if grains['oscodename'] == "wheezy" %}
wheezy-backports-pkgrepo:
  pkgrepo.managed:
    - humanname: Wheezy Backports
    - name: deb http://{{ pillar.get('deb_mirror_prefix', 'ftp.au') }}.debian.org/debian wheezy-backports main
    - file: /etc/apt/sources.list.d/wheezy-backports.list
    - require_in:
      - pkg: git
{% endif %}

git:
  pkg.latest:
    {% if grains['oscodename'] == "wheezy" %}
    - fromrepo: wheezy-backports
    {% endif %}
    - order: 1

required-packages:
  pkg.latest:
    - names:
      - ntp
      - man-db
      - debconf-utils
      - swig
      - python-pip
      - python-software-properties
      {% if grains['os'] == 'Ubuntu' %}
      - language-pack-en
      {% endif %}
    - require:
      - file: apt-no-recommends

esky:
  pip.installed:
    - require:
      - pkg: required-packages

pip-pip:
  pip.installed:
    - name: pip==1.4
    - upgrade: true
    - require:
      - pkg: required-packages

pip-setuptools:
  pip.installed:
    - name: setuptools
    - upgrade: true
    - require:
      - pkg: required-packages

{% if pillar.get('timezone', false) %}
{{ pillar['timezone'] }}:
  timezone.system:
    - utc: True
{% endif %}
