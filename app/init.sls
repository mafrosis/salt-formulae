include:
  - github


app-directory:
  file.directory:
    - name: /srv/{{ pillar['app_name'] }}
    - user: {{ pillar['app_user'] }}
    - group: {{ pillar['app_user'] }}
    - makedirs: true

git-clone-app:
  git.latest:
    - name: git@github.com:{{ pillar['app_repo'] }}.git
    - target: /srv/{{ pillar['app_name'] }}
    - runas: {{ pillar['app_user'] }}
    - require:
      - pkg: git
      - file: github.pky
      - file: app-directory
