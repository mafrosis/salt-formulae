include:
  - hostname


{% set hostname = pillar.get("hostname", pillar.get("app_name", "localhost")) %}


/etc/cloud/cloud.cfg.d/99_{{ hostname }}.cfg:
  file.managed:
    - contents: 'manage_etc_hosts: false'
