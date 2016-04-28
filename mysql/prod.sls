include:
  - mysql

{% set root_pw = pillar['mysql_root_password'] %}

extend:
  create-mysql-db:
    mysql_database.present:
      - connection_user: root
      - connection_pass: {{ root_pw }}

  create-mysql-user:
    mysql_user.present:
      - connection_user: root
      - connection_pass: {{ root_pw }}

  create-mysql-user-perms:
    mysql_grants.present:
      - connection_user: root
      - connection_pass: {{ root_pw }}

root:
  mysql_user.present:
    - host: {{ pillar['mysql_host'] }}
    - password: {{ root_pw }}
    - require_in:
      - mysql_database: create-mysql-db
      - mysql_user: create-mysql-user
      - mysql_grants: create-mysql-user-perms
