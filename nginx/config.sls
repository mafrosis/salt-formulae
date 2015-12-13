include:
  - nginx

{% set app_name = pillar.get('app_name', 'app_logs') %}

# always create port 80 config, port 443 if ssl set in pillar
{% if pillar.get('ssl', false) %}
{% set ports = [80, 443] %}
{% else %}
{% set ports = [80] %}
{% endif %}

extend:
  nginx:
    service.running:
      - watch:
        {% for port in ports %}
        - file: nginx-app-config-{{ port }}
        {% endfor %}

{% for port in ports %}
nginx-app-config-{{ port }}:
  file.managed:
    - name: /etc/nginx/sites-available/{{ app_name }}-{{ port }}.conf
    - source: salt://nginx/site.tmpl.conf
    - template: jinja
    - defaults:
        port: {{ port }}
        server_name: localhost
        root: /srv/{{ app_name }}
        app_name: {{ app_name }}
        static_gzip: true
        static_gzip_types: web
        static_dir: false
        static_alias: false
        upstream_host: {{ pillar.get('upstream_host', '') }}
        upstream_port: {{ pillar.get('upstream_port', '') }}
        upstream_gzip: false
        upstream_gzip_types: ''
        ssl: {{ pillar.get('ssl', false) }}
        ssl_only: {{ pillar.get('ssl_only', false) }}
        acmetool_ssl: {{ pillar.get('acmetool_ssl', false) }}
    - require:
      - pkg: nginx
    - require_in:
      - service: nginx
{% endfor %}

/etc/nginx/sites-enabled/{{ app_name }}.conf:
  file.symlink:
    - target: /etc/nginx/sites-available/{{ app_name }}-80.conf
    - require:
      - file: /etc/nginx/sites-available/{{ app_name }}-80.conf
    - require_in:
      - service: nginx
