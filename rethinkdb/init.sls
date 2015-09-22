{% set app_name = pillar.get('app_name', 'rethinkdb') %}

rethinkdb-pkgrepo:
  pkgrepo.managed:
    - humanname: RethinkDB PPA
    - name: deb http://download.rethinkdb.com/apt {{ grains['oscodename'] }} main
    - file: /etc/apt/sources.list.d/rethinkdb.list
    - key_url: http://download.rethinkdb.com/apt/pubkey.gpg
    - require_in:
      - pkg: rethinkdb

rethinkdb:
  user.present:
    - createhome: false
    - gid_from_name: true
  pkg.installed:
    - version: 2.1.4~0{{ grains['oscodename'] }}


python-pip-rethinkdb:
  pkg.installed:
    - name: python-pip

rethinkdb-python-driver:
  pip.installed:
    - name: rethinkdb
    - require:
      - pkg: python-pip-rethinkdb


rethinkdb-chown-lib:
  file.directory:
    - name: /var/lib/rethinkdb
    - user: rethinkdb
    - group: rethinkdb
    - require:
      - pkg: rethinkdb

rethinkdb-config:
  file.managed:
    - name: /etc/rethinkdb/instances.d/{{ app_name }}.conf
    - source: salt://rethinkdb/rethinkdb.instance.conf
    - template: jinja
    - user: rethinkdb
    - group: rethinkdb
    - defaults:
        app_name: {{ app_name }}
        data_directory: null
        production: true
        host: null
        canonical_address: null
        join: []
    - require:
      - pkg: rethinkdb
      - user: rethinkdb
  cmd.wait:
    - name: /etc/init.d/rethinkdb restart
    - require:
      - file: rethinkdb-chown-lib
    - watch:
      - file: rethinkdb-config
