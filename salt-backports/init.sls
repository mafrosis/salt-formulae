{% if grains['saltversion'].startswith("2014.1.0") %}

/usr/lib/python2.7/dist-packages/salt/states/rabbitmq_user.py:
  file.managed:
    - source: salt://salt-backports/rabbitmq_user.2014-1-0.state.py

/usr/lib/python2.7/dist-packages/salt/modules/mysql.py:
  file.managed:
    - source: salt://salt-backports/mysql.2014-1-0.module.py

salt-hack-restart:
  cmd.run:
    - name: service salt-minion restart
    - watch:
      - file: /usr/lib/python2.7/dist-packages/salt/states/rabbitmq_user.py
      - file: /usr/lib/python2.7/dist-packages/salt/modules/mysql.py
    - order: 1


{% elif grains['saltversion'].startswith("2014.1.1") %}

/usr/lib/python2.7/dist-packages/salt/states/rabbitmq_user.py:
  file.managed:
    - source: salt://salt-backports/rabbitmq_user.2014-1-1.state.py

salt-hack-restart:
  cmd.run:
    - name: service salt-minion restart
    - watch:
      - file: /usr/lib/python2.7/dist-packages/salt/states/rabbitmq_user.py
    - order: 1

{% endif %}
