{% set app_user = pillar.get('app_user', pillar.get('login_user', 'root')) %}

# https://github.com/google/closure-compiler/wiki/Binary-Downloads

openjdk-7-jre-headless:
  pkg.installed

closure-compiler:
  file.managed:
    - name: /tmp/compiler.tar.gz
    - source: http://dl.google.com/closure-compiler/compiler-20150920.tar.gz
    - source_hash: sha1=a089d955537c938ae87727db9b3c1df95ee862b0
    - unless: test -f /usr/local/lib/compiler.jar
  cmd.wait:
    - name: tar xzf compiler.tar.gz && chmod +r compiler.jar && mv compiler.jar /usr/local/lib
    - cwd: /tmp
    - watch:
      - file: closure-compiler
    - require:
      - pkg: openjdk-7-jre-headless

# javascript compiler pre-commit hook
publish-jscript-precommit-hook:
  file.managed:
    - name: /srv/{{ pillar['app_directory_name'] }}/.git/hooks/pre-commit
    - source: salt://closure-compiler/pre-commit-hook
    - user: {{ pillar['app_user'] }}
    - group: {{ pillar['app_user'] }}
    - mode: 755
