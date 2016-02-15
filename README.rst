==============
vagrant-django
==============

The building blocks for a `Vagrant <https://www.vagrantup.com/>`_ environment for `Django <https://www.djangoproject.com/>`_ development.

Full documentation is available at: https://vagrant-django.readthedocs.org/.


Features
========

The environment of the Vagrant guest machine can be configured for hosting a full Django project, or for the development of a single Django app. The features of the environment will change depending on this.

See the `full documentation <https://vagrant-django.readthedocs.org/>`_ for details on all available features and when they apply.

A quick overview:

* Custom SSH public key
* Git
* Ag (silver searcher), for code search
* PostgreSQL, with default database and user
* Image libraries used by Pillow
* Virtualenv, plus installation of Python dependencies
* Node.js and npm, plus installation of Node.js dependencies
* Migrations run against new database
* An environment-specific Python settings file
* Shortcut shell commands


How to use
==========

#.  Copy the ``provision/`` directory into your project.
#.  Copy the included ``Vagrantfile`` or add ``provision/bootstrap.sh`` as a shell provisioner in your existing ``Vagrantfile``, specifying the project name and build mode. The included ``Vagrantfile`` is pretty basic, but it can be used as a foundation. See `documentation on the Vagrantfile <https://vagrant-django.readthedocs.org/en/latest/config.html#conf-vagrantfile>`_ for details.
#.  Modify the example ``env.sh`` file in ``provision/config/``. See `documentation on the env.sh file <https://vagrant-django.readthedocs.org/en/latest/config.html#conf-env-sh>`_ for details.
#.  Add further customisation files to ``provision/config/`` if necessary. See the `configuration documentation <https://vagrant-django.readthedocs.org/en/latest/config.html>`_ for details on what further customisation options are available.
#.  Add ``provision/config/env.sh`` (and any other necessary config files, such as `.gitconfig <https://vagrant-django.readthedocs.org/en/latest/config.html#conf-gitconfig>`_) to your ``.gitignore`` file, or equivalent. Environment-specific configurations should not be committed to source control.
#. ``vagrant up``

**IMPORTANT NOTE:** When running a Windows host and using VirtualBox shared folders, ``vagrant up`` must be run with Administrator privileges to allow the creation of symlinks in the synced folder. See `the documentation <https://vagrant-django.readthedocs.org/en/latest/overview.html#assumptions-dependencies-windows>`_ for details.


Assumptions and dependencies
============================

The provisioning scripts make various assumptions about the nature and structure of the Django project they are included in. Be sure to read the `full documentation <https://vagrant-django.readthedocs.org/>`_, in particular the `assumptions and dependencies <https://vagrant-django.readthedocs.org/#assumptions-dependencies>`_.
