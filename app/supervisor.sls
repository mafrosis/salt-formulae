include:
  - supervisor


# app config for supervisor
/etc/supervisor/conf.d/{{ pillar['app_name'] }}.conf:
  file.managed:
    - source: salt://{{ pillar['app_name'] }}/supervisord.conf
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
{{ pillar['app_name'] }}-supervisor-service:
  supervisord.running:
    - name: "{{ pillar['app_name'] }}:"
    - update: true
    - require:
      - service: supervisor
    - watch:
      - file: /etc/supervisor/conf.d/{{ pillar['app_name'] }}.conf
