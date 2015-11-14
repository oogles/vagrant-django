===========================
Configuring the environment
===========================

The environment of the Vagrant guest machine is designed to provide everything necessary for developing and hosting Django-based projects with minimal configuration. However, several configuration files are recognised and utilised by the provisioning scripts. Each of these files is described below.

.. _conf-vagrantfile:

Vagrantfile
===========

The use and feature set of the ``Vagrantfile`` are beyond the scope of this documentation. For more information on the file itself, see `the Vagrant documentation <https://docs.vagrantup.com/v2/vagrantfile/>`_.

An example ``Vagrantfile`` is included. This can be used with some minor modifications, or the relevant provisioner can be added to a custom ``Vagrantfile``. In either case, the ``provision/bootstrap.sh`` shell provisioner needs to be configured.

.. code-block:: ruby
    
    config.vm.provision "shell" do |s|
        s.path = "provision/bootstrap.sh"
        s.args = ["<project name>" "<build mode>"]
    end

Two variables are required to be passed to the provisioner:

* Project name: The name of the project. This dictates several features of the environment, as :ref:`described below <conf-var-project-name>`.
* Build mode: The build mode to use, see :ref:`build-modes` for details.

.. _conf-var-project-name:

Project name
------------

The name of the project is used by the provisioning scripts for the following:

* The name of the default PostgreSQL database created.
* The name of the default PostgreSQL database user created.
* The name of the virtualenv created.
* The location of the ``env.py`` Python settings file: ``<project root>/<project name>/env.py``. It is assumed this is the directory containing ``settings.py``.

This means that the name given must be valid for each of those uses.


.. _conf-env-sh:

env.sh
======

Location: ``provision/config/env.sh``

The primary configuration file is ``env.sh``. It is simply a shell script that gets executed by the provisioning scripts to load the variables it contains. Each of the variables is discussed below. An example file is included.

.. note::
    
    The settings contained in ``env.py`` are sensitive and/or environment-specific, and thus should not be committed to source control.

.. _conf-var-db-pass:

DB_PASS
-------

**Required**

The password to use for the default database user.

.. warning:: Do NOT use the password in the example ``env.sh`` file.

.. note:: This setting affects ``env.py``. See :ref:`feat-env-py` for the virtues of using these values over values hardcoded in ``settings.py``.

.. _conf-var-public-key:

PUBLIC_KEY
----------

*Optional*

If given, the public key will be installed into ``/home/vagrant/.ssh/authorized_keys`` so it may be used to SSH into the Vagrant guest machine.

.. note:: No additional system users are created, the key will simply grant SSH login access for the default ``vagrant`` user.

.. _conf-var-debug:

DEBUG
-----

*Optional*

This flag controls whether or not the Vagrant guest environment is a development or production environment. A value of ``1`` indicates a development environment, otherwise (including when it is not specified at all) it indicates a production environment.

The flag affects:

* :ref:`feat-dependencies`: If ``1``, a ``dev_requirements.txt`` file will be used, if present, to install development-only Python dependencies.
* :ref:`feat-env-py`: If ``1``, ``DEBUG=True`` is set, otherwise ``DEBUG=False`` is.

.. note:: This setting affects ``env.py``. See :ref:`feat-env-py` for the virtues of using these values over values hardcoded in ``settings.py``.

.. _conf-var-timezone:

TIMEZONE
--------

*Optional*

The timezone that the Vagrant guest machine should be set to. Defaults to "Australia/Sydney".


.. _conf-gitconfig:

.gitconfig
==========

Location: ``provision/config/.gitconfig``

A ``.gitconfig`` file, if present, will be copied verbatim into ``/home/vagrant/.gitconfig``. It should be a standard user-specific ``.gitconfig`` file, used to configure :ref:`git <feat-git>` behaviour for the ``vagrant`` user.

See `the docs on .gitconfig files <https://git-scm.com/docs/git-config#_configuration_file>`_.

An example ``.gitconfig``, simply specifying the commit credentials of the user, might be:

::
    
    [user]
        name = Some User
        email = someuser@example.com

.. note::
    
    The ``.gitconfig`` file is user-specific, and thus should not be committed to source control.


.. _conf-agignore:

.agignore
=========

Location: ``provision/config/.agignore``

An ``.agignore`` file, if present, will be copied verbatim into ``/home/vagrant/.agignore``. This file can be used to add additional automatic "ignores" to the :ref:`silver searcher <feat-ag>` ``ag`` command.

See `the docs on .agignore files <https://github.com/ggreer/the_silver_searcher/wiki/Advanced-Usage#agignore>`_.

An example ``.agignore`` file is included, containing some excludes of standard files that would typically be irrelevant to a code search:

::
    
    Vagrantfile
    README*
    docs/
    */migrations/
