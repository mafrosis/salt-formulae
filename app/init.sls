include:
  - github

{% set app_name = pillar.get('app_name', 'app_name') %}

app-directory:
  file.directory:
    - name: /srv/{{ app_name }}
    - user: {{ pillar['app_user'] }}
    - group: {{ pillar['app_user'] }}
    - makedirs: true

git-clone-app:
  git.latest:
    - name: git@github.com:{{ pillar['app_repo'] }}.git
    {% if pillar.get('app_repo_rev', false) %}
    - rev: {{ pillar['app_repo_rev'] }}
    {% endif %}
    - target: /srv/{{ app_name }}
    - runas: {{ pillar['app_user'] }}
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
    - user: {{ pillar['app_user'] }}
    - group: {{ pillar['app_user'] }}
    - require:
      - git: git-clone-app
{% endif %}
