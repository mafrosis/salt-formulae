{% set shell = pillar.get('shell', 'bash') %}

include:
  - common
  {% if grains['os'] == "Debian" %}
  - debian-backports
  {% endif %}
  - github
  - sudo
  {% if 'tmux' in pillar.get('extras', []) %}
  - tmux
  {% endif %}

dev_packages:
  pkg.latest:
    - names:
      - curl
      - man-db
      - telnet
      - htop
      - stow

# install extra packages from apt
{% for package_name in pillar.get('extras', []) %}
  {% if package_name == "vim" and grains['os'] == "Debian" %}
  {% set package = "vim-nox" %}
  {% else %}
  {% set package = package_name %}
  {% endif %}

extra_{{ package_name }}:
  pkg.latest:
    - name: {{ package }}
{% endfor %}

# install extra packages from pip
{% for package_name in pillar.get('pip', []) %}
extra_{{ package_name }}:
  pip.installed:
    - name: {{ package_name }}
{% endfor %}


# set the default shell
shell-{{ shell }}:
  pkg.installed:
    - name: {{ shell }}

modify-login-user:
  user.present:
    - name: {{ pillar['login_user'] }}
    - shell: /bin/{{ shell }}
    - remove_groups: false
    - unless: getent passwd $LOGNAME | grep {{ shell }}
    - require:
      - pkg: shell-{{ shell }}


{% if grains['os'] == "Debian" %}
extend:
  git:
    pkg.latest:
      - fromrepo: {{ grains['oscodename'] }}-backports
      - require:
        - pkgrepo: backports-pkgrepo
{% endif %}


# grab the user's dotfiles
dotfiles:
  git.latest:
    - name: git@github.com:{{ pillar['github_username'] }}/dotfiles.git
    - target: /home/{{ pillar['login_user'] }}/dotfiles
    - runas: {{ pillar['login_user'] }}
    - submodules: true
    - require:
      - pkg: git
      - ssh_known_hosts: github_known_hosts
      {% if pillar.get('github_key', False) or pillar.get('github_key_path', False) %}
      - file: github.pky
      {% endif %}

# run dotfiles install scripts
{% if 'vim' in pillar.get('extras', []) %}
dotfiles-install-vim:
  cmd.run:
    - name: ./install.sh -f vim
    - unless: test -L /home/{{ pillar['login_user'] }}/.vimrc
    - cwd: /home/{{ pillar['login_user'] }}/dotfiles
    - user: {{ pillar['login_user'] }}
    - require:
      - git: dotfiles
      - pkg: dev_packages
      - pkg: extra_vim

# prevent ~/.viminfo being owned by root
viminfo-touch:
  file.managed:
    - name: /home/{{ pillar['login_user'] }}/.viminfo
    - user: {{ pillar['login_user'] }}
    - group: {{ pillar['login_user'] }}
    - mode: 644
{% endif %}

{% if shell == 'zsh' %}
dotfiles-install-zsh:
  cmd.run:
    - name: ./install.sh -f zsh
    - cwd: /home/{{ pillar['login_user'] }}/dotfiles
    - user: {{ pillar['login_user'] }}
    - require:
      - git: dotfiles
      - pkg: dev_packages

/home/{{ pillar['login_user'] }}/.zhistory:
  file.managed:
    - user: {{ pillar['login_user'] }}
    - group: {{ pillar['login_user'] }}
{% endif %}

{% if 'git' in pillar.get('extras', []) %}
dotfiles-install-git:
  cmd.run:
    - name: ./install.sh -f git
    - cwd: /home/{{ pillar['login_user'] }}/dotfiles
    - user: {{ pillar['login_user'] }}
    - require:
      - git: dotfiles
      - pkg: dev_packages
{% endif %}
