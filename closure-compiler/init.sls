# Helpers for using Google's Closure Compiler tool

# script to aid access to the Closure Compiler webservice
closure-compiler-service:
  file.managed:
    - name: /usr/local/bin/closure-compiler
    - source: salt://closure-compiler/closure-compiler.py
    - mode: 755
