Salt Formulae
=============

Personal set of formula states which are used in several projects.

This repo is best used with the [GitFS method](http://docs.saltstack.com/topics/tutorials/gitfs.html), which is
useable from the Salt master and in Salt masterless mode as of [v2014.7.1](https://github.com/saltstack/salt/issues/18860).


Configure your Salt config for GitFS
------------------------------------

This is taken from the Salt tutorial on [GitFS](http://docs.saltstack.com/topics/tutorials/gitfs.html).

The important configuration that must be changed is here:

    fileserver_backend:
      - roots
      - git
    
    file_roots:
      base:
        - /srv/my/salt/states
    
    gitfs_remotes:
      - https://github.com/mafrosis/salt-formulae
        - base: v0.1.0


When operating in masterless mode, on a vagrant box for instance, the following is more useful. In the
`Vagrantfile`, the directory `/my/salt/states` can be mapped to a folder on your host machine via Vagrant's
`config.vm.synced_folder` option.

    file_client: local
    
    fileserver_backend:
      - roots
      - git
    
    file_roots:
      base:
        - /mnt/my/salt/states
    
    gitfs_remotes:
      - https://github.com/mafrosis/salt-formulae
        - base: v0.1.0
