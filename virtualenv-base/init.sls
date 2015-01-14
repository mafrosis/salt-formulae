include:
  - apt
  - common
  - create-app-user

{% set app_name = pillar.get('app_name', 'venv') %}
{% set app_user = pillar.get('app_user', pillar.get('login_user', 'root')) %}

pip-dependencies:
  pkg.latest:
    - names:
      - python-dev
      - build-essential
    - require:
      - file: apt-no-recommends
      - pkg: required-packages

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
      - user: create-app-user
