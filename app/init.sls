include:
  - github

{% set app_name = pillar.get('app_name', 'app_name') %}
{% set app_user = pillar.get('app_user', pillar.get('login_user', 'root')) %}

app-directory:
  file.directory:
    - name: /srv/{{ pillar.get('app_directory_name', app_name) }}
    - user: {{ app_user }}
    - group: {{ app_user }}
    - makedirs: true

git-clone-app:
  git.latest:
    - name: git@github.com:{{ pillar['app_repo'] }}.git
    {% if pillar.get('app_repo_rev', false) %}
    - rev: {{ pillar['app_repo_rev'] }}
    {% endif %}
    - target: /srv/{{ pillar.get('app_directory_name', app_name) }}
    - runas: {{ app_user }}
    - require:
      - pkg: git
      - file: github.pky
      - file: app-directory

{% if pillar.get('upstream_repo', false) %}
git-app-add-upstream:
  cmd.run:
    - name: git remote add upstream git@github.com:{{ pillar['upstream_repo'] }}
    - unless: git remote | grep upstream
    - cwd: /srv/{{ app_name }}
    - user: {{ app_user }}
    - group: {{ app_user }}
    - require:
      - git: git-clone-app
{% endif %}
