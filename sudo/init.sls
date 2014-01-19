sudo:
  pkg.installed

{% if grains['os'] == "Debian" and pillar.get('login_user', False) %}
/etc/sudoers.local:
  file.managed:
    - contents: "Defaults env_reset\nDefaults env_keep += \"HOME\"\n"

/etc/sudoers:
  file.append:
    - text: "{{ pillar['login_user'] }}\tALL=(ALL:ALL) ALL\n#include /etc/sudoers.local"
    - require:
      - file: /etc/sudoers.local
{% endif %}
