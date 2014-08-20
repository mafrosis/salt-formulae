awscli:
  pip.installed

awscli-config-dir:
  file.directory:
    - name: /home/{{ pillar['login_user'] }}/.aws
    - user: {{ pillar['login_user'] }}
    - group: {{ pillar['login_user'] }}

awscli-config:
  file.managed:
    - name: /home/{{ pillar['login_user'] }}/.aws/config
    - source: salt://awscli/config
    - user: {{ pillar['login_user'] }}
    - group: {{ pillar['login_user'] }}
    - template: jinja
    - defaults:
        s3_access_key: ''
        s3_secret_key: ''
        aws_region: ap-southeast-2
    - require:
      - file: awscli-config-dir
