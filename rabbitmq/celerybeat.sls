{% set app_user = pillar.get('app_user', pillar['login_user']) %}

# celerybeat schedule directory
/var/celerybeat:
  file.directory:
    - user: {{ app_user }}
    - group: {{ app_user }}
    - require_in:
      - service: supervisor
