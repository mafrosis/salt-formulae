include:
  - nginx

{% set app_name = pillar.get('app_name', 'app_logs') %}

extend:
  nginx:
    service.running:
      - watch:
        - file: /etc/nginx/sites-available/{{ app_name }}.conf


nginx-app-config:
  file.managed:
    - name: /etc/nginx/sites-available/{{ app_name }}.conf
    {% if pillar.get('gunicorn_host', false) %}
    - source: salt://nginx/gunicorn.tmpl.conf
    {% else %}
    - source: salt://nginx/simple.tmpl.conf
    {% endif %}
    - template: jinja
    - defaults:
        port: 80
        server_name: localhost
        root: /srv/{{ app_name }}
        app_name: {{ app_name }}
        {% if pillar.get('gunicorn_host', false) %}
        gunicorn_host: {{ pillar['gunicorn_host'] }}
        gunicorn_port: {{ pillar['gunicorn_port'] }}
        {% endif %}
    - require:
      - pkg: nginx

/etc/nginx/sites-enabled/{{ app_name }}.conf:
  file.symlink:
    - target: /etc/nginx/sites-available/{{ app_name }}.conf
    - require:
      - file: /etc/nginx/sites-available/{{ app_name }}.conf
    - require_in:
      - service: nginx
