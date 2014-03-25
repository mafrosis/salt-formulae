# vim: set ft=jinja:
#################################################
# Gunicorn config for ogreserver
#################################################

bind = '{{ gunicorn_host }}:{{ gunicorn_port }}'
{% if 'env' in grains and grains['env'] == 'dev' %}
workers = 1
{% else %}
import multiprocessing
workers = multiprocessing.cpu_count() * 2 + 1
{% endif %}
#worker_class = 'socketio.sgunicorn.GeventSocketIOWorker'
backlog = 2048
worker_class = '{{ worker_class }}'
debug = True
daemon = False
timeout = {{ timeout }}
proc_name = 'gunicorn-{{ app_name }}'
pidfile = '/tmp/gunicorn-{{ app_name }}.pid'
errorlog = '-'
loglevel = '{{ loglevel }}'
