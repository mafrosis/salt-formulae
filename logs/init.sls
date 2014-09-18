{% set app_name = pillar.get('app_name', 'app_logs') %}
{% set app_user = pillar.get('app_user', pillar.get('login_user', 'root')) %}

include:
  - create-app-user

app-log-directory:
  file.directory:
    - name: /var/log/{{ app_name }}
    - user: {{ app_user }}
    - group: {{ app_user }}
    - dir_mode: 755
    - file_mode: 600
    - recurse:
      - user
      - group
      - mode
    - require:
      - user: {{ app_user }}

app-logrotate-crontab:
  file.managed:
    - name: /etc/logrotate.d/{{ app_name }}
    - source: salt://logs/logrotate.conf
    - mode: 644
    - template: jinja
    - context:
        owner: {{ app_user }}
