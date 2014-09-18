# This state configures instances of watchdog to monitor a service
#
# https://pypi.python.org/pypi/watchdog
#
# Watchdog processes are daemonized in Supervisor and added to a process
# group called "watchdog:"
#
# A dictionary like this needs to be configured in pillar:
#   watchdog:
#     gunicorn:
#       pattern: "*.py"
#       command: "supervisorctl restart gunicorn"
#       dir: /srv/application
#     celeryd:
#       pattern: "tasks.py"
#       command: "supervisorctl restart celeryd"
#       dir: /srv/application

{% if 'watchdog' in pillar %}

{% set app_name = pillar.get('app_name', 'app_name') %}
{% set app_user = pillar.get('app_user', pillar.get('login_user', 'root')) %}
{% set venv_name = pillar.get('virtualenv_name', pillar.get('app_name', 'venv')) %}
{% set log_path = pillar.get('app_name', 'app_logs') %}

watchdog-service:
  supervisord.running:
    - name: "watchdog:"
    - update: true
    - require:
      - service: supervisor
      - pip: watchdog
      - file: watchdog-supervisor-config

watchdog:
  pip.installed:
    - user: {{ app_user }}
    - bin_env: /home/{{ app_user }}/.virtualenvs/{{ venv_name }}

watchdog-supervisor-config:
  file.managed:
    - name: /etc/supervisor/conf.d/watchdog.{{ app_name }}.conf
    - source: salt://watchdog/supervisord.conf
    - template: jinja
    - context:
        venv_name: {{ venv_name }}
        log_path: {{ log_path }}
        app_user: {{ app_user }}
        watches: {{ pillar['watchdog'] }}
    - require:
      - pip: watchdog
    - require_in:
      - service: supervisor

{% endif %}
