include:
  - virtualenv

{% set venv_name = pillar.get('virtualenv_name', pillar.get('app_name', 'venv')) %}
{% set app_user = pillar.get('app_user', pillar.get('login_user', 'root')) %}
{% set reqs_path = pillar.get('pip_requirements_path', False) %}

app-virtualenv:
  virtualenv.managed:
    - name: /home/{{ app_user }}/.virtualenvs/{{ venv_name }}
    {% if reqs_path %}
    - requirements: {{ reqs_path }}
    {% endif %}
    - user: {{ app_user }}
    - require:
      - pip: virtualenvwrapper
      - user: {{ app_user }}
