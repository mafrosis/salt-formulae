include:
  - ssh

{% set app_user = pillar.get('app_user', pillar['login_user']) %}

create-app-user:
  group.present:
    - name: {{ app_user }}
  user.present:
    - name: {{ app_user }}
    - home: /home/{{ app_user }}
    - shell: /bin/bash
    - gid_from_name: true
    - require:
      - group: {{ app_user }}
    - order: first
    - require_in:
      - file: ssh-home-dir
