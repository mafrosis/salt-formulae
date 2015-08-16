{% set ruby_version = pillar.get('ruby_version', '') %}

ruby:
  pkg.installed:
    - name: ruby{{ ruby_version }}

{% if grains['os_family'] == "Debian" and grains['osmajorrelease'] < 8 %}
ruby-switch:
  pkg.installed

# install the -dev headers for the current ruby version
ruby-dev:
  cmd.run:
    - name: apt-get install -y $(ruby-switch --check | awk '/using/ {print $3}')-dev
    - require:
      - pkg: ruby-switch

{% else %}
ruby-dev:
  cmd.run:
    - name: apt-get install -y ruby-dev
    - require:
      - pkg: ruby
{% endif %}

{% if ruby_version %}
ruby-set-version:
  cmd.run:
    - name: ruby-switch --set ruby{{ ruby_version }}
    - require:
      - pkg: ruby-switch
{% endif %}

# ruby1.8 requires separate rubygems package
{% if ruby_version.startswith('1.8') %}
rubygems:
  pkg.installed:
    - require_in:
      - pkg: ruby
{% endif %}
