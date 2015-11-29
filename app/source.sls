{% set app_name = pillar.get('app_name', 'app_name') %}
{% set app_user = pillar.get('app_user', pillar.get('login_user', 'root')) %}
{% set env = grains.get('env', '') %}

app-directory:
  file.directory:
    - name: /srv/{{ pillar.get('app_directory_name', app_name) }}
    - user: {{ app_user }}
    - group: {{ app_user }}
    - makedirs: true

{% if pillar.get('github_key', false) %}
git-clone-key:
  file.managed:
    - contents_pillar: github_key
    - name: /etc/ssh/git.{{ grains['host'] }}.pky
    - user: {{ app_user }}
    - group: {{ app_user }}
    - mode: 600
{% endif %}

git-clone-app:
  git.latest:
    {% if pillar.get('github_key', false) or pillar.get('github_key_path', false) %}
    - name: git@github.com:{{ pillar['app_repo'] }}.git
    {% else %}
    - name: https://github.com/{{ pillar['app_repo'] }}.git
    {% endif %}
    {% if pillar.get('app_repo_rev', false) %}
    - rev: {{ pillar['app_repo_rev'] }}
    {% endif %}
    - target: /srv/{{ pillar.get('app_directory_name', app_name) }}
    {% if pillar.get('github_key', false) %}
    - identity: /etc/ssh/git.{{ grains['host'] }}.pky
    {% endif %}
    - submodules: true
    - user: {{ app_user }}
    - require:
      - pkg: git
      {% if pillar.get('github_key', false) %}
      - file: git-clone-key
      {% endif %}
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
