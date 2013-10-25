/etc/gunicorn.d:
  file.directory:
    - mode: 655

# gunicorn config with defaults for production
gunicorn-config:
  file.managed:
    - name: /etc/gunicorn.d/{{ pillar['app_name'] }}.conf.py
    - source: salt://gunicorn/gunicorn.conf.py
    - template: jinja
    - mode: 644
    - defaults:
        app_name: {{ pillar['app_name'] }}
        bind_hostname: 127.0.0.1
        gunicorn_port: 8001
        worker_class: sync
        timeout: 30
        loglevel: error
    - require:
      - file: /etc/gunicorn.d
