supervisor-install:
  pip.installed:
    - name: supervisor
    - update: true

supervisor-config-dir:
  file.directory:
    - name: /etc/supervisor/conf.d
    - makedirs: true
    - mode: 755

supervisor-config:
  file.managed:
    - name: /etc/supervisord.conf
    - source: salt://supervisor/supervisord.deb.conf
    - template: jinja
    - context:
        socket_mode: 0700

supervisor-log-dir:
  file.directory:
    - name: /var/log/supervisor
    - user: root

supervisor-init-script:
  file.managed:
    - name: /etc/init.d/supervisor
    - source: salt://supervisor/supervisor.init
    - user: root
    - mode: 744

supervisor:
  service.running:
    - enable: true
    - require:
      - pip: supervisor-install
    - watch:
      - file: supervisor-config
      - file: supervisor-log-dir
      - file: supervisor-init-script
