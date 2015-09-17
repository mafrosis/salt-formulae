include:
  - create-app-user
  - virtualenv

{% set venv_name = pillar.get('virtualenv_name', pillar.get('app_name', 'venv')) %}
{% set app_user = pillar.get('app_user', pillar.get('login_user', 'root')) %}

app-virtualenv:
  virtualenv.managed:
    - name: /home/{{ app_user }}/.virtualenvs/{{ venv_name }}
    - user: {{ app_user }}
    - require:
      - pip: virtualenvwrapper
      - user: {{ app_user }}
