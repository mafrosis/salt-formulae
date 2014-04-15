include:
  - app
  - virtualenv-base


app-virtualenv:
  virtualenv.managed:
    - name: /home/{{ pillar['app_user'] }}/.virtualenvs/{{ pillar['app_name'] }}
    - user: {{ pillar['app_user'] }}
    - require:
      - pip: virtualenv-init-setuptools
      - git: git-clone-app
