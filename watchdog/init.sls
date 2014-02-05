# This state configures instances of watchdog to monitor a service
#
# https://pypi.python.org/pypi/watchdog
#
# Watchdog processes are daemonized in Supervisor and added to a process
# group with the service they're watching
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
    - user: {{ pillar['app_user'] }}
    - bin_env: /home/{{ pillar['app_user'] }}/.virtualenvs/{{ pillar['app_name'] }}

watchdog-supervisor-config:
  file.managed:
    - name: /etc/supervisor/conf.d/watchdog.{{ pillar['app_name'] }}.conf
    - source: salt://watchdog/supervisord.conf
    - template: jinja
    - context:
        app_name: {{ pillar['app_name'] }}
        app_user: {{ pillar['app_user'] }}
        watches: {{ pillar['watchdog'] }}
    - require:
      - pip: watchdog
    - require_in:
      - service: supervisor

{% endif %}
