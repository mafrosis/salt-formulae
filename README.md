Salt Formulae
=============

Personal set of formula states which are used in several projects.

This repo is best used with the [GitFS method](http://docs.saltstack.com/topics/tutorials/gitfs.html), which is fine
on a Salt master, but is unfortunately not yet available in the minion.

Alternatively, the Salt states can be included in your local tree with either method below. When 
[this ticket](https://github.com/saltstack/salt/issues/6660) is resolved, the `gitfs` method above will be useable
for both master and minion.


Share salt-formulae with your minion
------------------------------------

I test my salt state trees with Vagrant, so I need to expose the `salt-formulae` states to the minion.

### Clone the repo

    git clone git@github.com:mafrosis/salt-formulae.git /Users/mafro/Development/salt-formulae

https://github.com/mafrosis/dotfiles/blob/mousetrap/salty-vagrant/Vagrantfile#L17

### Share with Vagrant

    config.vm.synced_folder "/Users/mafro/Development/salt-formulae", "/srv/salt-formulae"

https://github.com/mafrosis/dotfiles/blob/mousetrap/salty-vagrant/salt-minion.conf#L12

### Add to Minion Config

    file_roots:
      base:
        - /srv/salt-formulae


Hacky SLS Solution
------------------

Another option is to manually create a state such as this `salt-formulae` one below. This method will also need the
salt minion config entry from above.

	salt-formulae-git:
	  pkg.installed:
	    - name: git

	/srv/salt-formulae:
	  file.directory

	# clone the salt-formulae repo
	salt-formulae-git-clone:
	  git.latest:
	    - name: https://github.com/mafrosis/salt-formulae.git
	    - target: /srv/salt-formulae
	    - require:
	      - pkg: salt-formulae-git
	      - file: /srv/salt-formulae

	salt-formulae-restart-minion:
	  cmd.run:
	    - name: /etc/init.d/salt-minion restart
	    - require:
	      - git: salt-formulae-git-clone
	    - order: 1

Unfortunately the first call to highstate will fail with this state since all the states in /srv/salt-formulae are
missing. The second call will be successful.

And worse than that, if there are errors in your `salt-formulae` states, you'll need to clear the cloned repo before
starting again..

    $ rm -rf /srv/salt-formulae
