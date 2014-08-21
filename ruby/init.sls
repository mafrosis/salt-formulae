{% set ruby_version = pillar.get('ruby_version', '') %}

ruby:
  pkg.installed:
    - name: ruby{{ ruby_version }}

ruby-switch:
  pkg.installed

# install the -dev headers for the current ruby version
ruby-dev:
  cmd.run:
    - name: aptitude install $(ruby-switch --check | awk '/using/ {print $3}')-dev
    - require:
      - pkg: ruby-switch

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
