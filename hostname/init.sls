{% set hostname = pillar.get("hostname", pillar.get("app_name", "localhost")) %}


hostname-{{ hostname }}:
  host.present:
    - name: {{ hostname }}
    - ip: "127.0.1.1"

/etc/hostname:
  file.managed:
    - contents: {{ hostname }}

set-hostname:
  cmd.run:
    - name: hostname -F /etc/hostname
    - require:
      - file: /etc/hostname
      - host: hostname-{{ hostname }}
