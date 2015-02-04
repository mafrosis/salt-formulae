s3cmd-pip:
  pkg.installed:
    - name: python-pip

s3cmd:
  pip.installed:
    - name: s3cmd==1.5.0
    - require:
      - pkg: s3cmd-pip

s3cfg:
  file.managed:
    - name: /home/{{ pillar['login_user'] }}/.s3cfg
    - user: {{ pillar['login_user'] }}
    - group: {{ pillar['login_user'] }}
    - source: salt://s3cmd/s3cfg
    - template: jinja
    - defaults:
        aws_region: ""
        access_key: ""
        secret_key: ""
        host_base: "s3.amazonaws.com"
        host_bucket: "%(bucket)s.s3.amazonaws.com"
        proxy_host: ""
        proxy_port: 0
