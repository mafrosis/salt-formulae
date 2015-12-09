{% set acmetool_version = 'v0.0.23' %}
{% set acmetool_sha1 = 'f429f3b924d1432a88def03547f2d936e01690cd' %}
{% set server_url = pillar['dns'][grains['env']] %}

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
    - name: /tmp/acme-responses.yaml
    - contents: |
        acmetool-quickstart-choose-server: https://acme-v01.api.letsencrypt.org/directory
        acmetool-quickstart-choose-method: webroot
        acme-enter-email: {{ pillar['acmetool_email'] }}
        acmetool-quickstart-complete: true
        acmetool-quickstart-webroot-path: {{ pillar['acmetool_webroot'] }}/.well-known/acme-challenge
        acmetool-quickstart-webroot-path-unlikely: true
        acmetool-quickstart-install-cronjob: true
        acmetool-quickstart-install-haproxy-script: false
        acmetool-quickstart-install-redirector-systemd: false
        acmetool-quickstart-rsa-key-size: 2048
        acme-agreement:https://letsencrypt.org/documents/LE-SA-v1.0.1-July-27-2015.pdf: true

acmetool-quickstart:
  cmd.run:
    - name: acmetool quickstart --response-file=/tmp/acme-responses.yaml
    - require:
      - file: acmetool-install
      - file: acmetool-response-file

acmetool-want:
  cmd.run:
    - name: acmetool want --no-reconcile {{ server_url }}
    - require:
      - cmd: acmetool-quickstart

# a temporary SSL certificate is necessary to ensure nginx starts okay
# this is replaced by acmetool when the machine is booted for real
acmetool-temp-cert-dir:
  file.directory:
    - name: /var/lib/acme/live/{{ server_url }}
    - require:
      - cmd: acmetool-quickstart

acmetool-temp-key:
  x509.private_key_managed:
    - name: /var/lib/acme/live/{{ server_url }}/privkey
    - require:
      - file: acmetool-temp-cert-dir

acmetool-temp-cert:
  x509.certificate_managed:
    - name: /var/lib/acme/live/{{ server_url }}/fullchain
    - signing_private_key: /var/lib/acme/live/{{ server_url }}/privkey
    - CN: www.example.com
    - days_valid: 1
    - require:
      - x509: acmetool-temp-key
    - require_in:
      - service: nginx

acmetool-temp-cert-dir-cleanup:
  file.absent:
    - name: /var/lib/acme/live/{{ server_url }}
    - require:
      - service: nginx
