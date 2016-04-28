mysql-server-5.5:
  pkg.latest

mysql:
  service.running:
    - enable: true
    - require:
      - pkg: mysql-server-5.5

python-mysqldb:
  pkg.latest


create-mysql-db:
  mysql_database.present:
    - name: {{ pillar['mysql_db'] }}
    - require:
      - pkg: python-mysqldb
      - service: mysql

create-mysql-user:
  mysql_user.present:
    - name: {{ pillar['mysql_user'] }}
    - host: {{ pillar['mysql_host'] }}
    - password: {{ pillar['mysql_pass'] }}
    - require:
      - pkg: python-mysqldb
      - service: mysql

create-mysql-user-perms:
  mysql_grants.present:
    - grant: all privileges
    - database: {{ pillar['mysql_db'] }}.*
    - user: {{ pillar['mysql_user'] }}
    - require:
      - mysql_database: create-mysql-db
      - mysql_user: create-mysql-user
