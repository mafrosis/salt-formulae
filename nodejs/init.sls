{% if grains['os'] == "Debian" %}
include:
  - debian-backports
{% endif %}


nodejs-install:
  pkg.installed:
    {% if grains['os'] == "Debian" %}
    - name: nodejs-legacy
    {% else %}
    - name: nodejs
    {% endif %}

npm-install:
  cmd.run:
    - name: curl --insecure https://www.npmjs.org/install.sh | sudo bash
    - unless: which npm
