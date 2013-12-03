# Setup tmux and tmux-powerline
#
# Assumes usage of dotfiles repo at pillar['github_username']
# via the dev-user state
# 
# Assumes a tmux.conf file is provided in the dotfiles

# TODO support no .tmux.conf in dotfiles; install a default

# tmux-powerline theme for this project_name (or generic, if not a project deployment)
{% set theme_name = pillar.get('project_name', pillar['login_user']) %}

include:
  - common

tmux:
  pkg.latest:
    {% if grains['oscodename'] == "wheezy" %}
    - fromrepo: wheezy-backports
    {% endif %}
    - order: 1

tmux-stow:
  pkg.latest:
    - name: stow

dotfiles-install-tmux:
  cmd.run:
    - name: ./install.sh -f tmux &> /dev/null
    - unless: test -L /home/{{ pillar['login_user'] }}/.tmux.conf
    - cwd: /home/{{ pillar['login_user'] }}/dotfiles
    - user: {{ pillar['login_user'] }}
    - require:
      - git: dotfiles
      - pkg: tmux-stow

# install tmux-powerline from git
tmux-powerline-install:
  git.latest:
    - name: https://github.com/mafrosis/tmux-powerline.git
    - target: /home/{{ pillar['login_user'] }}/tmux-powerline
    - runas: {{ pillar['login_user'] }}
    - unless: test -d /home/{{ pillar['login_user'] }}/tmux-powerline
    - require:
      - pkg: git

# create tmux-powerline theme
tmux-powerline-theme:
  file.managed:
    - name: /home/{{ pillar['login_user'] }}/tmux-powerline/themes/{{ theme_name }}.sh
    - source: salt://tmux/theme.sh
    - template: jinja
    - user: {{ pillar['login_user'] }}
    - group: {{ pillar['login_user'] }}
    - defaults:
        in_cloud: false
        gunicorn: false
        celeryd: false
        weather: {{ pillar.get('yahoo_weather_location', false) }}
    - require:
      - git: tmux-powerline-install

# patch tmux.conf ensure .tmux-powerline.conf is loaded
tmux-powerline-conf-patch:
  file.append:
    - name: /home/{{ pillar['login_user'] }}/.tmux.conf
    - text: "\n# AUTOMATICALLY ADDED TMUX POWERLINE CONFIG\nsource-file ~/.tmux-powerline.conf"
    - require:
      - cmd: dotfiles-install-tmux

# create a basic tmux-powerline.conf if not part of user's dotfiles
# this config is sourced into tmux's config file
tmux-powerline-conf:
  file.managed:
    - name: /home/{{ pillar['login_user'] }}/.tmux-powerline.conf
    - source: salt://tmux/tmux-powerline.conf
    - template: jinja
    - unless: test -f /home/{{ pillar['login_user'] }}/.tmux-powerline.conf
    - user: {{ pillar['login_user'] }}
    - group: {{ pillar['login_user'] }}
    - require:
      - cmd: dotfiles-install-tmux

# create a basic tmux-powerlinerc if not part of user's dotfiles
# this config sets up tmux-powerline
tmux-powerlinerc:
  file.managed:
    - name: /home/{{ pillar['login_user'] }}/.tmux-powerlinerc
    - source: salt://tmux/tmux-powerlinerc
    - template: jinja
    - unless: test -f /home/{{ pillar['login_user'] }}/.tmux-powerlinerc
    - user: {{ pillar['login_user'] }}
    - group: {{ pillar['login_user'] }}
    - context:
        theme: {{ theme_name }}
        patched_font_in_use: {{ pillar.get('tmux_patched_font', 'false') }}
        yahoo_weather_location: {{ pillar.get('yahoo_weather_location', '') }}
    - default:
        theme: minimal
    - require:
      - cmd: dotfiles-install-tmux
