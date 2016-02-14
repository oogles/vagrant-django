===========================
Configuring the environment
===========================

The environment of the Vagrant guest machine is designed to provide everything necessary for developing and hosting Django-based projects with minimal configuration. However, several configuration files are recognised and utilised by the provisioning scripts. Each of these files is described below.

.. _conf-vagrantfile:

Vagrantfile
===========

The use and feature set of the ``Vagrantfile`` are beyond the scope of this documentation. For more information on the file itself, see `the Vagrant documentation <https://docs.vagrantup.com/v2/vagrantfile/>`_.

An example ``Vagrantfile`` is included. This can be used with some minor modifications, or the relevant provisioner can be added to a custom ``Vagrantfile``. In either case, the ``provision/scripts/bootstrap.sh`` shell provisioner needs to be configured.

.. code-block:: ruby
    
    config.vm.provision "shell" do |s|
        s.path = "provision/scripts/bootstrap.sh"
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

This means that the name given must be valid for each of those uses. E.g. names incorporating hyphens should use underscores instead (use ``project_name`` instead of ``project-name``).


.. _conf-env-sh:

env.sh
======

Location: ``provision/env.sh``

The primary configuration file is ``env.sh``. It is simply a shell script that gets executed by the provisioning scripts to load the variables it contains. Each of the variables is discussed below. An example file is included.

.. note::
    
    The settings contained in ``env.sh`` are sensitive and/or environment-specific, and thus should not be committed to source control.

.. note:: Several of these settings affect ``env.py``. See :ref:`feat-env-py` for the virtues of using these values over values hardcoded in ``settings.py``.

.. _conf-var-db-pass:

DB_PASS
-------

**Required**

The password to use for the default database user.

.. warning:: Do NOT use the password in the example ``env.sh`` file.

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

* :ref:`feat-py-dependencies`: If ``1``, a ``dev_requirements.txt`` file will be used, if present, to install development-only Python dependencies.
* :ref:`feat-env-py`: If ``1``, ``DEBUG=True`` is set, otherwise ``DEBUG=False`` is.

.. _conf-var-time-zone:

TIME_ZONE
---------

*Optional*

The time zone that the Vagrant guest machine should be set to. Defaults to "Australia/Sydney".

This value is also written to ``env.py`` so it may be imported into ``settings.py`` and used for Django's ``TIME_ZONE`` setting.



.. _conf-user-config:

User Environment Config Files
=============================

Location: ``provision/conf/``

Any files found in the ``provision/conf/`` directory will be copied verbatim into the ``vagrant`` user's home directory in the guest machine. This facility can be used to provide config files that affect the logged in user's shell environment. E.g. ``.gitignore`` for the configuration of :ref:`git <feat-git>`, ``.agignore`` for additional "ignores" for the :ref:`silver searcher <feat-ag>` ``ag`` command.

.. note::
    Files will not be copied if they already exist in the user's home directory. This means changes to these files on the guest machine will not be overwritten, and also that changes to the files in ``provision/conf/`` will not be applied (if re-running the provisioning process on an existing guest machine) unless the home directory file is removed.
