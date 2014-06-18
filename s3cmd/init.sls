s3cmd:
  pkg.installed

s3cfg:
  file.managed:
    - name: /home/{{ pillar['login_user'] }}/.s3cfg
    - source: salt://s3cmd/s3cfg
    - template: jinja
    - defaults:
        aws_region: ap-southeast-2
