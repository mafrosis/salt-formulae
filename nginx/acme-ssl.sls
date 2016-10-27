{% set acmetool_version = 'v0.0.23' %}
{% set acmetool_sha1 = 'f429f3b924d1432a88def03547f2d936e01690cd' %}

{% if grains['env'] == 'prod' %}
{% set acme_server = 'acme-v01' %}
{% else %}
{% set acme_server = 'acme-staging' %}
{% endif %}

acmetool-download:
  file.managed:
    - name: /tmp/acmetool.tar.gz
    - source: https://github.com/hlandau/acme/releases/download/{{ acmetool_version }}/acmetool-{{ acmetool_version }}-linux_amd64.tar.gz
    - source_hash: sha1={{ acmetool_sha1 }}
  cmd.run:
    - name: tar xzf acmetool.tar.gz
    - cwd: /tmp
    - watch:
      - file: acmetool-download

acmetool-install:
  file.copy:
    - name: /usr/local/bin/acmetool
    - source: /tmp/acmetool-{{ acmetool_version }}-linux_amd64/bin/acmetool
    - require:
      - cmd: acmetool-download

acmetool-response-file:
  file.managed:
    - name: /var/lib/acme/conf/responses
    - makedirs: true
    - contents: |
        acmetool-quickstart-choose-server: https://{{ acme_server }}.api.letsencrypt.org/directory
        acmetool-quickstart-choose-method: webroot
        acme-enter-email: {{ pillar['acmetool_email'] }}
        acmetool-quickstart-complete: true
        acmetool-quickstart-webroot-path: {{ pillar['acmetool_webroot'] }}/.well-known/acme-challenge
        acmetool-quickstart-webroot-path-unlikely: true
        acmetool-quickstart-install-cronjob: true
        acmetool-quickstart-install-haproxy-script: false
        acmetool-quickstart-install-redirector-systemd: false
        acmetool-quickstart-rsa-key-size: 4096
        acme-agreement:https://letsencrypt.org/documents/LE-SA-v1.1.1-August-1-2016.pdf: true
