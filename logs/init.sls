{% set app_name = pillar.get('app_name', 'app_logs') %}

include:
  - create-app-user

app-log-directory:
  file.directory:
    - name: /var/log/{{ app_name }}
    - user: {{ pillar['app_user'] }}
    - group: {{ pillar['app_user'] }}
    - dir_mode: 755
    - file_mode: 600
    - recurse:
      - user
      - group
      - mode
    - require:
      - user: {{ pillar['app_user'] }}

app-logrotate-crontab:
  file.managed:
    - name: /etc/logrotate.d/{{ app_name }}
    - source: salt://logs/logrotate.conf
    - mode: 644
    - template: jinja
    - context:
        owner: {{ pillar['app_user'] }}
