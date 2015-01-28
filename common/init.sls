include:
  - apt
  - vmware-guest-tools

git:
  pkg.latest:
    - order: 1

required-packages:
  pkg.latest:
    - names:
      - coreutils
      - ntp
      - man-db
      - debconf-utils
      - swig
      - python-apt
      - python-pip
      - software-properties-common
      - vim
      {% if grains['os'] == 'Ubuntu' %}
      - language-pack-en
      {% endif %}
    - require:
      - file: apt-no-recommends

esky:
  pip.installed:
    - require:
      - pkg: required-packages

{% if pillar.get('timezone', false) %}
{{ pillar['timezone'] }}:
  timezone.system:
    - utc: True
{% endif %}
