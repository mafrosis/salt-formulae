# Directly import the module for cmd.run from salt since the modules aren't
# available in the __salt__ namespace in a grain
import salt.modules.cmdmod


def __virtual__():
    if salt.utils.which('vmware-checkvm'):
        return 'vmware'
    return False


def is_vmware():
    grains = {}
    res = salt.modules.cmdmod._run_quiet(
        'ps -ef | grep -P "(vmware|vmtoolsd)" | grep -v grep'
    )
    if len(res) > 0:
        grains['vmware'] = True

    return grains
