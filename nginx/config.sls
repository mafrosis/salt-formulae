include:
  - nginx

extend:
  nginx:
    service.running:
      - watch:
        - file: /etc/nginx/conf.d/http.conf
        - file: /etc/nginx/conf.d/proxy.conf
        - file: /etc/nginx/sites-available/{{ pillar['app_name'] }}.conf


/etc/nginx/sites-available/{{ pillar['app_name'] }}.conf:
  file.managed:
    {% if pillar.get('gunicorn_host', false) %}
    - source: salt://nginx/gunicorn.tmpl.conf
    {% else %}
    - source: salt://nginx/simple.tmpl.conf
    {% endif %}
    - template: jinja
    - defaults:
        port: 80
        server_name: localhost
        root: /srv
        app_name: {{ pillar['app_name'] }}
        {% if pillar.get('gunicorn_host', false) %}
        gunicorn_host: {{ pillar['gunicorn_host'] }}
        gunicorn_port: {{ pillar['gunicorn_port'] }}
        {% endif %}
    - require:
      - pkg: nginx

/etc/nginx/sites-enabled/{{ pillar['app_name'] }}.conf:
  file.symlink:
    - target: /etc/nginx/sites-available/{{ pillar['app_name'] }}.conf
    - require:
      - file: /etc/nginx/sites-available/{{ pillar['app_name'] }}.conf
    - require_in:
      - service: nginx
