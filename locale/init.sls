{% if pillar.get('locale', False) %}
locale-gen:
  cmd.run:
    - name: locale-gen --purge {{ pillar['locale'] }}

/etc/default/locale:
  file.managed:
    - contents: |
        LANG="{{ pillar['locale'] }}.UTF-8"
        LANGUAGE="{{ pillar['locale'] }}:en"
{% endif %}

{% if pillar.get('timezone', False) %}
/etc/timezone:
  file.managed:
    - contents: {{ pillar['timezone'] }}

set-timezone:
  cmd.run:
    - name: dpkg-reconfigure -f noninteractive tzdata
    - require:
      - file: /etc/timezone
{% endif %}
