# vim: set ft=jinja:
#################################################
# Gunicorn config for {{ app_name }}
#################################################

bind = '{{ gunicorn_host }}:{{ gunicorn_port }}'
worker_class = '{{ worker_class }}'

# configure number of gunicorn workers
{% if grains.get('env', '') == 'dev' %}
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
proc_name = 'gunicorn-{{ app_name }}'
pidfile = '/tmp/gunicorn-{{ app_name }}.pid'

# error log to STDERR
errorlog = '-'
{% if grains.get('env', '') == 'dev' %}
loglevel = 'debug'
{% else %}
loglevel = '{{ loglevel }}'
{% endif %}
