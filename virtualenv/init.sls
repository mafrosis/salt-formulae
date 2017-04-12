include:
  - apt
  - common


pip-dependencies:
  pkg.latest:
    - names:
      - python-dev
      - build-essential
    - require:
      - file: apt-no-recommends
      - pkg: required-packages
