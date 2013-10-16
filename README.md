Salt Formulae
=============

Personal set of formula states which are used in several projects.

This repo can be used with either the [GitFS method](http://docs.saltstack.com/topics/tutorials/gitfs.html) or by 
manually including the states from this repo.

The following config and salt state will grab and include all these states into your local tree (which is useful for
testing in Vagrant and such until [this ticket](https://github.com/saltstack/salt/issues/6660) is resolved).


Hacky SLS Solution
------------------

One option is to manually create a state such as this `salt-formulae` one below:

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

Unfortunately the first call to highstate will fail with this state since all the states at salt-formulae are missing.
The second call will be successful.
