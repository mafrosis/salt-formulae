include:
  - common
  - ssh
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

# install some extra packages
{% for package_name in pillar.get('extras', []) %}
  {% if package_name == "vim" and grains['os'] == "Debian" %}
  {% set package_name = "vim-nox" %}
  {% endif %}

extra_{{ package_name }}:
  pkg.latest:
    - name: {{ package_name }}
{% endfor %}

# set the default shell
shell-{{ pillar['shell'] }}:
  pkg.latest:
    - name: {{ pillar['shell'] }}

modify-login-user:
  user.present:
    - name: {{ pillar['login_user'] }}
    - shell: /bin/{{ pillar['shell'] }}
    - unless: getent passwd $LOGNAME | grep {{ pillar['shell'] }}
    - require:
      - pkg: shell-{{ pillar['shell'] }}

# grab the user's dotfiles
dotfiles:
  git.latest:
    - name: git@github.com:{{ pillar['github_username'] }}/dotfiles.git
    - target: /home/{{ pillar['login_user'] }}/dotfiles
    - runas: {{ pillar['login_user'] }}
    - submodules: true
    - require:
      - pkg: git
      {% if pillar.get('github_key_path', False) %}
      - file: github.pky
      {% endif %}

# run dotfiles install scripts
{% if 'vim' in pillar.get('extras', []) %}
dotfiles-install-vim:
  cmd.run:
    - name: ./install.sh -f vim &> /dev/null
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

{% if 'zsh' in pillar.get('extras', []) %}
dotfiles-install-zsh:
  cmd.run:
    - name: ./install.sh -f zsh &> /dev/null
    - cwd: /home/{{ pillar['login_user'] }}/dotfiles
    - user: {{ pillar['login_user'] }}
    - require:
      - git: dotfiles
      - pkg: dev_packages
{% endif %}

{% if 'git' in pillar.get('extras', []) %}
dotfiles-install-git:
  cmd.run:
    - name: ./install.sh -f git &> /dev/null
    - cwd: /home/{{ pillar['login_user'] }}/dotfiles
    - user: {{ pillar['login_user'] }}
    - require:
      {% if 'vim' in pillar.get('extras', []) %}
      - file: viminfo-touch
      {% endif %}
      - git: dotfiles
      - pkg: dev_packages
{% endif %}
