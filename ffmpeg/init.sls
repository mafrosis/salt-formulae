{% if grains['os'] == 'Debian' %}
include:
  - debian-nonfree

extend:
  nonfree-pkgrepo:
    pkgrepo.managed:
      - require_in:
        - pkg: ffmpeg-install-codecs
{% endif %}


/var/local/ffmpeg_sources:
  file.directory

ffmpeg-install-reqs:
  pkg.installed:
    - names:
      - autoconf
      - automake
      - build-essential
      - libass-dev
      - libfreetype6-dev
      - libgpac-dev
      - libtheora-dev
      - libtool
      - libvorbis-dev
      - pkg-config
      - texi2html
      - zlib1g-dev

ffmpeg-install-codecs:
  pkg.latest:
    - names:
      - libx264-dev
      - libfaac-dev
      - libmp3lame-dev

/var/local/ffmpeg_sources/yasm:
  file.directory

yasm-download:
  file.managed:
    - name: /var/local/ffmpeg_sources/yasm-1.3.0.tar.gz
    - source: http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
    - source_hash: sha1=b7574e9f0826bedef975d64d3825f75fbaeef55e
  cmd.wait:
    - name: tar xzf yasm-1.3.0.tar.gz -C /var/local/ffmpeg_sources/yasm --strip-components=1
    - cwd: /var/local/ffmpeg_sources
    - watch:
      - file: yasm-download

yasm-configure:
  cmd.run:
    - name: ./configure --prefix="$HOME/ffmpeg_build" --bindir="/usr/local/bin"
    - cwd: /var/local/ffmpeg_sources/yasm
    - unless: which yasm
    - require:
      - cmd: yasm-download

yasm-make-install:
  cmd.run:
    - name: make && make install && make distclean
    - cwd: /var/local/ffmpeg_sources/yasm
    - unless: which yasm
    - require:
      - cmd: yasm-configure

/var/local/ffmpeg_sources/ffmpeg:
  file.directory

ffmpeg-download:
  file.managed:
    - name: /var/local/ffmpeg_sources/ffmpeg-2.5.2.tar.gz
    - source: http://ffmpeg.org/releases/ffmpeg-2.5.2.tar.gz
    - source_hash: sha1=5553edb562419e86cd92e7e59ad25f12800e1fae
  cmd.wait:
    - name: tar xzf ffmpeg-2.5.2.tar.gz -C /var/local/ffmpeg_sources/ffmpeg --strip-components=1
    - cwd: /var/local/ffmpeg_sources
    - watch:
      - file: ffmpeg-download

ffmpeg-configure:
  cmd.run:
    - name: PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --extra-cflags="-I$HOME/ffmpeg_build/include" --extra-ldflags="-L$HOME/ffmpeg_build/lib" --bindir="/usr/local/bin" --enable-gpl --enable-libass --enable-libfaac --enable-libfreetype --enable-libmp3lame --enable-libtheora --enable-libvorbis --enable-libx264 --enable-nonfree
    - cwd: /var/local/ffmpeg_sources/ffmpeg
    - unless: which ffmpeg
    - require:
      - cmd: ffmpeg-download

ffmpeg-make-install:
  cmd.run:
    - name: make && make install && make distclean && hash -r
    - cwd: /var/local/ffmpeg_sources/ffmpeg
    - unless: which ffmpeg
    - require:
      - cmd: ffmpeg-configure
