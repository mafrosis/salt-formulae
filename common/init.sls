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
      - python-apt
      - python-pip
      - software-properties-common
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
    - name: pip==1.4.1
    - upgrade: true
    - require:
      - pkg: required-packages

pip-setuptools:
  pip.installed:
    - name: setuptools==4.0.1
    - upgrade: true
    - require:
      - pkg: required-packages

{% if pillar.get('timezone', false) %}
{{ pillar['timezone'] }}:
  timezone.system:
    - utc: True
{% endif %}
