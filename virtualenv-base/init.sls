include:
  - apt
  - common
  - create-app-user

{% set app_user = pillar.get('app_user', pillar['login_user']) %}
{% set app_name = pillar.get('app_name', 'should-be-overriden-in-template') %}

pip-dependencies:
  pkg.latest:
    - names:
      - python-dev
      - build-essential
      - python-virtualenv
    - require:
      - file: apt-no-recommends
      - pkg: required-packages
      - pip: pip-pip

virtualenvwrapper:
  pip.installed:
    - require:
      - pkg: pip-dependencies

virtualenv-init:
  virtualenv.managed:
    - name: /home/{{ app_user }}/.virtualenvs/{{ app_name }}
    - user: {{ app_user }}
    - setuptools: true
    - require:
      - pip: virtualenvwrapper
      - pkg: pip-dependencies
      - user: create-app-user

virtualenv-init-pip:
  pip.installed:
    - name: pip==1.4
    - upgrade: true
    - ignore_installed: true
    - user: {{ app_user }}
    - bin_env: /home/{{ app_user }}/.virtualenvs/{{ app_name }}
    - require:
      - virtualenv: virtualenv-init

virtualenv-init-setuptools:
  pip.installed:
    - name: setuptools
    - upgrade: true
    - ignore_installed: true
    - user: {{ app_user }}
    - bin_env: /home/{{ app_user }}/.virtualenvs/{{ app_name }}
    - require:
      - pip: virtualenv-init-pip
