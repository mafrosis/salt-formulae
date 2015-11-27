nodejs-apt-transport-https:
  pkg.installed:
    - name: apt-transport-https

nodesource:
  pkgrepo.managed:
    - humanname: Node 5 Source Repo
    - name: deb https://deb.nodesource.com/node_5.x {{ grains['oscodename'] }} main
    - file: /etc/apt/sources.list.d/node5source.list
    - key_url: https://deb.nodesource.com/gpgkey/nodesource.gpg.key
    - require:
      - pkg: apt-transport-https

nodejs-install:
  pkg.installed:
    - name: nodejs
    - require:
      - pkgrepo: nodesource
