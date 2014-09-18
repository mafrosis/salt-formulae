include:
  - app
  - virtualenv-base

{% set venv_name = pillar.get('virtualenv_name', pillar.get('app_name', 'venv')) %}

app-virtualenv:
  virtualenv.managed:
    - name: /home/{{ pillar['app_user'] }}/.virtualenvs/{{ venv_name }}
    - user: {{ pillar['app_user'] }}
    - require:
      - pip: virtualenv-init-setuptools
      - git: git-clone-app
