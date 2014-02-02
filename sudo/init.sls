sudo:
  pkg.installed

{% if grains['os'] == "Debian" and pillar.get('login_user', False) %}

{% if pillar['login_user'] == "vagrant" %}

/etc/sudoers.d/vagrant:
  file.append:
    - text: "Defaults env_reset\nDefaults env_keep += \"HOME\""
    - require:
      - pkg: sudo

{% else %}

/etc/sudoers.d/{{ pillar['login_user'] }}:
  file.managed:
    - contents: "Defaults env_reset\nDefaults env_keep += \"HOME\"\n{{ pillar['login_user'] }}\tALL=(ALL:ALL) ALL"
    - require:
      - pkg: sudo

{% endif %}

{% endif %}
