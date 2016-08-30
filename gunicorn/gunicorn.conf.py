# vim: set ft=jinja:
#################################################
# Gunicorn config for {{ app_name }}
#################################################

bind = '{{ gunicorn_host }}:{{ gunicorn_port }}'
worker_class = '{{ worker_class }}'

# configure number of gunicorn workers
{% if grains.get('env', 'dev') == 'dev' %}
workers = 1
{% elif workers is defined %}
workers = {{ workers }}
{% else %}
import multiprocessing
workers = multiprocessing.cpu_count() * 2 + 1
{% endif %}

# dont daemonize; use supervisor
daemon = False
timeout = {{ timeout }}
proc_name = '{{ app_name }}-gunicorn'
pidfile = '/tmp/{{ app_name }}-gunicorn.pid'

# error log to STDERR
errorlog = '-'
{% if grains.get('env', 'dev') in ['dev','staging'] %}
loglevel = 'debug'
{% else %}
loglevel = '{{ loglevel }}'
{% endif %}
