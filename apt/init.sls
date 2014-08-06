apt-no-recommends:
  file.managed:
    - name: /etc/apt/apt.conf.d/00NoRecommends
    - contents: |
        APT::Install-Recommends "0";
        APT::Install-Suggests "0";
    - order: first
