include:
  - supervisor

{{ set supervisor_name = pillar.get('supervisor_name', pillar.get('app_name', 'supervisord')) }}

# app config for supervisor
/etc/supervisor/conf.d/{{ supervisor_name }}.conf:
  file.managed:
    - source: salt://{{ supervisor_name }}/supervisord.conf
    - template: jinja
    - defaults:
        purge: false
        app_user: {{ pillar['app_user'] }}
        loglevel: warning
    - require:
      - user: {{ pillar['app_user'] }}
    - require_in:
      - service: supervisor

# app supervisor process
{{ supervisor_name }}-supervisor-service:
  supervisord.running:
    - name: "{{ supervisor_name }}:"
    - update: true
    - require:
      - service: supervisor
    - watch:
      - file: /etc/supervisor/conf.d/{{ supervisor_name }}.conf
