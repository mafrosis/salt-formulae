{% if grains['os'] == "Debian" %}
include:
  - debian-repos.backports
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
    - name: curl -L --insecure https://www.npmjs.com/install.sh | sudo bash
    - unless: which npm
