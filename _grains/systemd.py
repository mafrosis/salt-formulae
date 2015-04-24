import os


def __virtual__():
    return 'systemd'


def has_systemd():
    grains = {}
    try:
        # This check does the same as sd_booted() from libsystemd-daemon:
        # http://www.freedesktop.org/software/systemd/man/sd_booted.html
        if os.stat('/run/systemd/system'):
            grains['systemd'] = True
    except OSError:
        grains['systemd'] = False
    return grains
