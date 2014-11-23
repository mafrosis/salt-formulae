{% set app_user = pillar.get('app_user', pillar.get('login_user', 'root')) %}

# https://github.com/google/closure-compiler/wiki/Binary-Downloads

closure-compiler:
  file.managed:
    - name: /tmp/compiler.tar.gz
    - source: http://dl.google.com/closure-compiler/compiler-20141120.tar.gz
    - source_hash: sha1=a8ce7b8f4241d180c8852ff740d1e8ebf243d57f
  cmd.wait:
    - name: tar xzf compiler.tar.gz && chmod +r compiler.jar && mv compiler.jar /usr/local/lib
    - cwd: /tmp
    - watch:
      - file: closure-compiler

openjdk-7-jre-headless:
  pkg.installed

# javascript compiler pre-commit hook
publish-jscript-precommit-hook:
  file.managed:
    - name: /srv/{{ pillar['app_directory_name'] }}/.git/hooks/pre-commit
    - source: salt://closure-compiler/pre-commit-hook
    - user: {{ pillar['app_user'] }}
    - group: {{ pillar['app_user'] }}
    - mode: 755
