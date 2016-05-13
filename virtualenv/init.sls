include:
  - apt


pip-dependencies:
  pkg.latest:
    - names:
      - python-dev
      - python-pip
      - build-essential
    - require:
      - file: apt-no-recommends

virtualenvwrapper:
  pip.installed:
    - require:
      - pkg: pip-dependencies
