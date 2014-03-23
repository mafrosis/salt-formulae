include:
  - apt
  - vmware-guest-tools

git:
  pkg.latest:
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
