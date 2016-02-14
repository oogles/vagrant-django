========
Features
========

The following features are available in the Vagrant guest machine environment constructed by the included provisioning scripts.


.. _feat-public-key:

Custom SSH public key
=====================

A user-defined SSH public key can be provided as the :ref:`conf-var-public-key` variable in the ``env.sh`` file. This will be installed into ``/home/vagrant/.ssh/authorized_keys``, allowing it to be used to SSH into the guest machine as the ``vagrant`` user.

This is useful in situations where ``vagrant ssh`` is not supported out of the box, and you already have an alternate SSH client with an existing private/public key pair in operation. E.g. Using PuTTY under Windows.


.. _feat-time-zone:

Time zone
=========

The time zone of the guest machine can be set using the :ref:`conf-var-time-zone` setting in the ``env.sh`` file.


.. _feat-git:

Git
===

`Git <https://git-scm.com/>`_ is installed in the guest machine.

.. note::
    A ``.gitconfig`` file can be placed in ``provision/conf/`` to enable configuration of the git environment for the ``vagrant`` user.


.. _feat-ag:

Ag (silver searcher)
====================

The `"silver searcher" <https://github.com/ggreer/the_silver_searcher>`_ commandline utility, ``ag``, is installed in the guest machine. ``ag`` provides fast code search that is `better than ack <http://geoff.greer.fm/2011/12/27/the-silver-searcher-better-than-ack/>`_.

.. note::
    An ``.agignore`` file can be placed in ``provision/conf/`` to add some additional automatic "ignores" for the command. This can be used, for example, to exclude documentation from the search. A sample ``.agignore`` file is included.


.. _feat-image-libs:

Image libraries
===============

Various system-level image libraries used by `Pillow <https://python-pillow.github.io/>`_ are installed in the guest machine.

To install Pillow itself, it should be included in ``requirements.txt`` along with other Python dependencies. But considering many of its features `require external libraries <http://pillow.readthedocs.org/en/3.0.x/installation.html#external-libraries>`_, and the high likelihood that a Django project will require Pillow, those libraries are installed in readiness.

The exact packages installed are taken from the Pillow `"depends" script for Ubuntu <https://github.com/python-pillow/Pillow/blob/master/depends/ubuntu_14.04.sh>`_, though not all are used.

Installed packages:

* libtiff5-dev
* libjpeg8-dev
* zlib1g-dev
* libfreetype6-dev
* liblcms2-dev


.. _feat-postgres:

PostgreSQL
==========

PostgreSQL is installed in the guest machine.

In addition, a database user is created with a username equal to the :ref:`project name <conf-var-project-name>` and a password equal to :ref:`conf-var-db-pass`. A database is also created, also with a name equal to the :ref:`project name <conf-var-project-name>`, with the aforementioned user as the owner.

The Postgres installation is configured to listen on the default port (5432).


.. _feat-virtualenv:

Virtualenv
==========

A virtualenv with a name equal to the :ref:`project name <conf-var-project-name>` is created in the guest machine, at ``/home/vagrant/.virtualenvs/<project name>``. This virtualenv is automatically activated when the ``vagrant`` user SSHs into the machine.

.. _feat-py-dependencies:

Python dependency installation
------------------------------

If using the "project" build mode, the provisioner will look for a ``requirements.txt`` file defined in the project root directory (``/vagrant/`` in the guest machine). If found, these requirements will be installed into the virtualenv. This is designed to allow installation of Python packages required in a production environment. It is not suitable for "app" builds, as apps should specify their dependencies in other ways, so they can be identified and installed along with the app.

For both "project" and "app" build modes, and where :ref:`conf-var-debug` is ``1``, the provisioner will also look for a ``dev_requirements.txt`` file, also in the project root directory. If found, these requirements will also be installed into the virtualenv. This is designed to enable specification of Python packages required during development, that are *not* required for the project/application to run in production. An example might include `sphinx <http://sphinx-doc.org/>`_, for documentation generation.


.. _feat-node:

Node.js/npm
===========

`Node.js <https://nodejs.org/en/>`_ and `npm <https://www.npmjs.com/>`_ are installed in the guest machine for development environments. They are included to provide development support (e.g. linting, concatenating, minifying, compiling css, etc).

A ``node_modules`` directory is created at ``/home/vagrant/node_modules/`` and a symlink to this directory is created in the project root directory (``/vagrant/node_modules``). Keeping the ``node_modules`` directory out of the synced folder helps avoid potential issues with Windows host machines - path names generated by installing certain npm packages can exceed the maximum Windows allows.

.. note::
    In order to create the ``node_modules`` symlink when running a Windows host and using VirtualBox shared folders, ``vagrant up`` must be run with Administrator privileges to allow the creation of symlinks in the synced folder. See :ref:`assumptions-dependencies-windows` for details.

.. _feat-node-dependencies:

Node.js dependency installation
-------------------------------

The provisioner will look for a ``package.json`` file defined in the project root directory (``/vagrant/`` in the guest machine). If found, ``npm install`` will be run in the same directory.

If :ref:`conf-var-debug` is not set to ``1``, ``npm install --production`` will be used, limiting the installed dependencies to those listed in the ``dependencies`` section of ``package.json``. If it *is* set to ``1``, ``dependencies`` and ``devDependencies`` will be installed. See the `documentation on npm install <https://docs.npmjs.com/cli/install>`_.


.. _feat-migrations:

Running migrations
==================

If a ``manage.py`` file is found in the project root directory, the management command ``manage.py migrate`` will be run after the virtualenv is built and activated, Postgres is installed and the database created.

.. note::
    In order for ``manage.py migrate`` to execute, Django must have been installed via ``requirements.txt`` or ``dev_requirements.txt`` and the ``DATABASES`` setting in ``settings.py`` must be correctly configured.


.. _feat-env-py:

env.py
======

*Only available when using the "project" build mode*

Several of the :ref:`conf-env-sh` settings are designed to eliminate hardcoding environment-specific and/or sensitive settings in Django's ``settings.py`` file. Things like the database password, the ``SECRET_KEY`` and the ``DEBUG`` flag should be configured per environment and not be committed to source control.

`12factor <http://12factor.net/>`_ recommends these types of settings `be loaded into environment variables <http://12factor.net/config>`_, with these variables subsequently used in ``settings.py``. But environment variables can be a kind of invisible magic, and it is not easy to simply view the entire set of environment variables that exist for this a given project's use. To make this possible, an ``env.py`` file is written by the provisioning scripts.

This ordinary Python file simply defines a dictionary called ``environ``, containing settings defined as key/value pairs. It can then be imported by ``settings.py`` and used in a manner very similar to using environment variables.

.. code-block:: python
    
    # Using env.py
    from . import env
    env.environ.get('DEBUG')
    
    # Using environment variables
    import os
    os.environ.get('DEBUG')

The ``environ`` dictionary is used rather than simply providing a set of module-level constants primarily to allow simple definition of default values:

.. code-block:: python
    
    env.environ.get('DEBUG', False)

The ``environ`` dictionary will always contain each of the following key/values:

* DEBUG: Will be True if :ref:`conf-var-debug` is set to ``1``, False otherwise (including when it is not defined at all).
* DB_USER: Set to the value of the :ref:`project name <conf-var-project-name>`.
* DB_PASSWORD: Set to the value of :ref:`conf-var-db-pass`.
* TIME_ZONE: Set to the value of :ref:`conf-var-time-zone`.
* SECRET_KEY: Automatically generated when the ``env.py`` file is first written. More secure than the default provided by Django's ``startproject``, this version containing 128 characters from an expanded alphabet, chosen pseudorandomly using Python's ``random.SystemRandom().choice``.

.. note::
    
    The ``env.py`` file should not be committed to source control. Doing to would defeat the purpose!


.. _feat-commands:

Shortcut commands
=================

The following shell commands are made available for convenience:

* shell+: Simply a shortcut to ``manage.py shell_plus``. Assumes installation of `django-extensions <https://github.com/django-extensions/django-extensions>`_, which defines the ``shell_plus`` command.
* runserver+: A shortcut to ``manage.py runserver_plus``. It takes a port number as a required first argument, using it to call ``manage.py runserver_plus 0.0.0.0:<port>``. Any further arguments provided will also be added to the ``runserver_plus`` command call. It has the following additional features:

  * Calls ``manage.py clean_pyc`` prior to calling ``runserver_plus``.
  * Automatically restarts the runserver, after a 3 second delay, if it exits. This avoids the need to babysit the runserver - if an error occurs that causes it to exit, it will automatically restart. It will keep trying to get going until the error is fixed, without you needing to interact with it. Note that ``clean_pyc`` is not called between automatic restarts.
  
  Assumes installation of `django-extensions <https://github.com/django-extensions/django-extensions>`_, which defines the ``runserver_plus`` and ``clean_pyc`` commands.


.. _feat-project-provisioning:

Project-specific provisioning
=============================

In addition to the above generic provisioning, any special steps required by your individual project can be included using the ``provision/project.sh`` file. If found, this shell script file will be executed during the provisioning process. This file can be used to install additional system libraries, create/edit configuration files, etc.

.. note::
    Project-specific provisioning is performed prior to the installation of Python and Node.js dependencies, so additional system libraries required by these dependencies can be installed.
