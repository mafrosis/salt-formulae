{% set app_user = pillar.get('app_user', pillar['login_user']) %}

create-app-user:
  group.present:
    - name: {{ app_user }}
  user.present:
    - name: {{ app_user }}
    - home: /home/{{ app_user }}
    - gid_from_name: true
    - remove_groups: false
    - require:
      - group: {{ app_user }}
    - order: first

{% if grains.get('env', '') == 'prod' %}
set-app-user-shell:
  user.present:
    - name: {{ app_user }}
    - shell: /bin/bash
    - require:
      - user: create-app-user
{% endif %}
