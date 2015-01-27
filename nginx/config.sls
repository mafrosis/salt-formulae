include:
  - nginx

{% set app_name = pillar.get('app_name', 'app_logs') %}

extend:
  nginx:
    service.running:
      - watch:
        - file: /etc/nginx/sites-available/{{ app_name }}.conf


# support a HTTP, and a HTTPS config if configured
{% if pillar.get('ssl', false) %}
{% set ports = [80, 443] %}
{% else %}
{% set ports = [80] %}
{% endif %}

{% for port in ports %}
nginx-app-config-{{ port }}:
  file.managed:
    {% if port == 80 %}
    - name: /etc/nginx/sites-available/{{ app_name }}.conf
    {% else %}
    - name: /etc/nginx/sites-available/{{ app_name }}-{{ port }}.conf
    {% endif %}
    {% if pillar.get('upstream_host', false) %}
    - source: salt://nginx/upstream.tmpl.conf
    {% else %}
    - source: salt://nginx/simple.tmpl.conf
    {% endif %}
    - template: jinja
    - defaults:
        port: {{ port }}
        server_name: localhost
        root: /srv/{{ app_name }}
        app_name: {{ app_name }}
        static_gzip: true
        static_gzip_types: web
        {% if pillar.get('upstream_host', false) %}
        upstream_host: {{ pillar['upstream_host'] }}
        upstream_port: {{ pillar['upstream_port'] }}
        upstream_gzip: false
        upstream_gzip_types: ''
        {% endif %}
        ssl: {{ pillar.get('ssl', false) }}
    - require:
      - pkg: nginx
    - require_in:
      - service: nginx
{% endfor %}

/etc/nginx/sites-enabled/{{ app_name }}.conf:
  file.symlink:
    - target: /etc/nginx/sites-available/{{ app_name }}.conf
    - require:
      - file: /etc/nginx/sites-available/{{ app_name }}.conf
    - require_in:
      - service: nginx
