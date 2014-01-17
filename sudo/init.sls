{% if grains['os'] == "Debian" %}
/etc/sudoers.local:
  file.managed:
    - contents: "Defaults env_reset\nDefaults env_keep += \"HOME\"\n"

/etc/sudoers:
  file.append:
    - text: "#include /etc/sudoers.local"
    - require:
      - file: /etc/sudoers.local
{% endif %}
