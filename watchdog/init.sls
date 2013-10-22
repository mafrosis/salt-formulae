# This state configures instances of watchdog to monitor a service
# https://pypi.python.org/pypi/watchdog
#
# Watchdog processes are daemonized in Supervisor and added to a process
# group with the service they're watching
#
# A dictionary like this needs to be configured in pillar:
#   watchdog:
#     - gunicorn: "*.py"
#     - celeryd: "*.py"
#
# Notes
# - The service (ie. gunicorn) is expected to have a supervisord.running
#   state elsewhere in the state tree, which is extended below.
# - This supervisord state must be named gunicorn-service.

extend:
{% for service in pillar.get('watchdog', []) %}
  {{ service }}-service:
    supervisord.running:
      - name: "{{ pillar['project_name'] }}.{{ service }}:"
      - update: true
      - require:
        - service: supervisor
        - pip: watchdog
{% endfor %}

watchdog:
  pip.installed:
    - user: {{ pillar['app_user'] }}
    - bin_env: /home/{{ pillar['app_user'] }}/.virtualenvs/{{ pillar['app_name'] }}

{% for service in pillar.get('watchdog', []) %}
watchdog-{{ service }}-supervisor-config:
  file.managed:
    - name: /etc/supervisor/conf.d/watchdog.{{ service }}.{{ pillar['app_name'] }}.conf
    - source: salt://watchdog/supervisord.conf
    - template: jinja
    - context:
        directory: /srv/{{ pillar['project_name'] }}/{{ pillar['app_name'] }}
        venv: /home/{{ pillar['app_user'] }}/.virtualenvs/{{ pillar['app_name'] }}
        app_name: {{ pillar['app_name'] }}
        watch_name: {{ service }}
        patterns: "*.py"
        command: "supervisorctl restart {{ pillar['project_name'] }}.{{ service }}:{{ pillar['app_name'] }}.{{ service }}"
        user: {{ pillar['app_user'] }}
    - require:
      - pip: watchdog
    - require_in:
      - service: supervisor
{% endfor %}
