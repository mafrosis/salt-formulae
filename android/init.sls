build-tools-deps:
  pkg.latest:
    - names:
      - openjdk-7-jdk
      - git
      - gnupg
      - ccache
      - lzop
      - flex
      - bison
      - gperf
      - build-essential
      - zip
      - curl
      - zlib1g-dev
      - zlib1g-dev:i386
      - libc6-dev
      - lib32bz2-1.0
      - lib32ncurses5-dev
      - x11proto-core-dev
      - libx11-dev:i386
      - libreadline6-dev:i386
      - lib32z1-dev
      - libgl1-mesa-glx:i386
      - libgl1-mesa-dev
      - g++-multilib
      - mingw32
      - tofrodos
      - python-markdown
      - libxml2-utils
      - xsltproc
      - libreadline6-dev
      - lib32readline-gplv2-dev
      - libncurses5-dev
      - bzip2
      - libbz2-dev
      - libbz2-1.0
      - libghc-bzlib-dev
      - lib32bz2-dev
      - squashfs-tools
      - pngcrush
      - schedtool
      - dpkg-dev
  file.symlink:
    - name: /usr/lib/i386-linux-gnu/libGL.so
    - target: /usr/lib/i386-linux-gnu/mesa/libGL.so.1
    - watch:
      - pkg: build-tools-deps

/usr/local/bin/repo:
  file.managed:
    - source: http://commondatastorage.googleapis.com/git-repo-downloads/repo
    - source_hash: sha1=b8bd1804f432ecf1bab730949c82b93b0fc5fede
    - mode: 777

init-android-source:
  cmd.run:
    - name: repo init -u https://android.googlesource.com/platform/manifest -b android-5.1.0_r1
    - cwd: /opt/android
    - user: {{ pillar['login_user'] }}
    - require:
      - file: /usr/local/bin/repo


/opt/android/.repo/local_manifests:
  file.directory:
    - user: {{ pillar['login_user'] }}

/opt/android/.repo/local_manifests/sony.xml:
  file.managed:
    - user: {{ pillar['login_user'] }}
    - group: {{ pillar['login_user'] }}
    - contents: |
        <?xml version="1.0" encoding="UTF-8"?>
        <manifest>
        <remote name="sony" fetch="git://github.com/sonyxperiadev/" />
        <project path="device/sony/amami" name="device-sony-amami" groups="device" remote="sony" revision="master" />
        <project path="device/sony/aries" name="device-sony-aries" groups="device" remote="sony" revision="master" />
        <project path="device/sony/castor" name="device-sony-castor" groups="device" remote="sony" revision="master" />
        <project path="device/sony/eagle" name="device-sony-eagle" groups="device" remote="sony" revision="master" />
        <project path="device/sony/flamingo" name="device-sony-flamingo" groups="device" remote="sony" revision="master" />
        <project path="device/sony/honami" name="device-sony-honami" groups="device" remote="sony" revision="master" />
        <project path="device/sony/leo" name="device-sony-leo" groups="device" remote="sony" revision="master" />
        <project path="device/sony/rhine" name="device-sony-rhine" groups="device" remote="sony" revision="master" />
        <project path="device/sony/scorpion" name="device-sony-scorpion" groups="device" remote="sony" revision="master" />
        <project path="device/sony/seagull" name="device-sony-seagull" groups="device" remote="sony" revision="master" />
        <project path="device/sony/shinano" name="device-sony-shinano" groups="device" remote="sony" revision="master" />
        <project path="device/sony/sirius" name="device-sony-sirius" groups="device" remote="sony" revision="master" />
        <project path="device/sony/tianchi" name="device-sony-tianchi" groups="device" remote="sony" revision="master" />
        <project path="device/sony/togari" name="device-sony-togari" groups="device" remote="sony" revision="master" />
        <project path="device/sony/yukon" name="device-sony-yukon" groups="device" remote="sony" revision="master" />
        <project path="kernel/sony/msm" name="kernel" groups="device" remote="sony" revision="aosp/AU_LINUX_ANDROID_LA.BF.2.1_RB1.05.00.00.173.012" />
        <project path="vendor/sony/system/thermanager" name="thermanager" groups="device" remote="sony" revision="master" />
        <project path="vendor/sony/system/mkqcdtbootimg" name="mkqcdtbootimg" groups="device" remote="sony" revision="master" />
        <project path="vendor/sony/system/timekeep" name="timekeep" groups="device" remote="sony" revision="master" />
        </manifest>


unzip:
  pkg.installed

sony-xperia-binaries-clear:
  file.absent:
    - name: /opt/android/vendor/sony

sony-xperia-binaries-extract:
  cmd.run:
    - name: unzip SW_binaries_for_Xperia_AOSP_L_MR1_v1.zip
    - cwd: /opt/android
    - user: {{ pillar['login_user'] }}
    - require:
      - pkg: unzip
      - file: sony-xperia-binaries-clear


/opt/android/reset-and-sync.sh:
  file.managed:
    - user: {{ pillar['login_user'] }}
    - group: {{ pillar['login_user'] }}
    - mode: 700
    - contents: |
        #! /bin/bash
        repo forall -vc "git reset --hard"
        repo sync -cd -j32

/opt/android/patch-for-xperia.sh:
  file.managed:
    - user: {{ pillar['login_user'] }}
    - group: {{ pillar['login_user'] }}
    - mode: 700
    - contents: |
        #! /bin/bash
        set -e
        cd hardware/qcom/bt
        git cherry-pick 5a6037f1c8b5ff0cf263c9e63777444ba239a056
        cd ../display
        git revert ab05b00fefd34a761dfaf1ccaf8ad14d325873f4
        cd ../../../external/libnfc-nci/
        git fetch https://android.googlesource.com/platform/external/libnfc-nci refs/changes/42/103142/1 && git cherry-pick FETCH_HEAD
        git fetch https://android.googlesource.com/platform/external/libnfc-nci refs/changes/23/103123/1 && git cherry-pick FETCH_HEAD
        git fetch https://android.googlesource.com/platform/external/libnfc-nci refs/changes/51/97051/1 && git cherry-pick FETCH_HEAD
        cd ../../hardware/libhardware/
        git fetch https://android.googlesource.com/platform/hardware/libhardware refs/changes/21/103221/2 && git cherry-pick FETCH_HEAD

/opt/android/build-xperia-rom.sh:
  file.managed:
    - user: {{ pillar['login_user'] }}
    - group: {{ pillar['login_user'] }}
    - mode: 700
    - contents: |
        #! /bin/bash
        source build/envsetup.sh && lunch
        make -j 4
