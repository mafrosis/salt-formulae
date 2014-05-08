include:
  - nginx


/etc/nginx/sites-available/{{ pillar['app_name'] }}.conf:
  file.managed:
    - source: salt://{{ pillar['app_name'] }}/nginx.conf
    - template: jinja
    - require:
      - pkg: nginx

/etc/nginx/sites-enabled/{{ pillar['app_name'] }}.conf:
  file.symlink:
    - target: /etc/nginx/sites-available/{{ pillar['app_name'] }}.conf
    - require:
      - file: /etc/nginx/sites-available/{{ pillar['app_name'] }}.conf
