========
Features
========

The following features are available in the environment constructed by the included provisioning scripts.

Several features may only apply in a production or development environment. This is differentiated based on the :ref:`conf-var-debug` setting in the ``env.sh`` file.


.. _feat-dir-structure:

Well-defined project structure
==============================

The provisioning process creates a well-defined directory structure for all project-related files.

The root of this structure is ``/opt/app/``.

The most important subdirectory is ``/opt/app/src/``. This is the project root directory, and the target of the Vagrant synced folder. Subsequently, ``/opt/app/src/provision/`` contains all the provisioning scripts.

Some of the other directories in this structure are:

* ``/opt/app/conf/``: For storage of configuration files such as ``nginx.conf`` and gunicorn's ``conf.py``. Such files are copied here instead of being referenced directly from within ``provision/conf/`` so they may be modified without affecting the committed source files.
* ``/opt/app/logs/``: For storage of log files output by supervisor, etc.
* ``/opt/app/media/``: Target for Django's ``MEDIA_ROOT``.
* ``/opt/app/static/``: Target for Django's ``STATIC_ROOT`` (in production environments).


.. _feat-users:

Locked down user access
=======================

SSH access is locked down to the custom ``webmaster`` user created during provisioning. SSH is available via public key authentication only - no passwords. In a development environment, only the ``webmaster`` and ``vagrant`` users are allowed SSH access. In a production environment, only ``webmaster`` is granted access. No other users, including ``root``, can SSH into the machine.

The public key to use for the ``webmaster`` user must be provided via the :ref:`conf-var-public-key` variable in the ``env.sh`` file. This will be installed into ``/home/webmaster/.ssh/authorized_keys``.

The ``webmaster`` user is given sudo privileges. In development environments, for convenience, it does not require a password. In production environments, it does. A password is not configured as part of the provisioning process, one needs to be manually created afterwards. When logged in as the ``webmaster`` user, simply run the ``passwd`` command to set a password.

Most provisioned services, such as nginx and gunicorn, are designed to run under the default ``www-data`` user.

.. warning::

    Using the provisioning scripts in a production environment with :ref:`conf-var-debug` set to ``1`` will leave the ``webmaster`` user with open ``sudo`` access, unprotected by a password prompt. This is a Bad Idea.


.. _feat-time-zone:

Time zone
=========

The time zone can be set using the :ref:`conf-var-time-zone` setting in the ``env.sh`` file.


.. _feat-firewall:

Firewall
========

In production environments, and if a :ref:`firewall rules configuration file <conf-firewall>` is provided, a firewall is provisioned using `UncomplicatedFirewall <https://wiki.ubuntu.com/UncomplicatedFirewall>`_.


.. _feat-git:

Git
===

`Git <https://git-scm.com/>`_ is installed.

.. note::
    A ``.gitconfig`` file can be placed in ``provision/conf/`` to enable configuration of the git environment for the ``webmaster`` user.


.. _feat-ag:

Ag (silver searcher)
====================

The `"silver searcher" <https://github.com/ggreer/the_silver_searcher>`_ commandline utility, ``ag``, is installed in the guest machine. ``ag`` provides fast code search that is `better than ack <http://geoff.greer.fm/2011/12/27/the-silver-searcher-better-than-ack/>`_.

.. note::
    An ``.agignore`` file can be placed in ``provision/conf/`` to add some additional automatic "ignores" for the command.


.. _feat-image-libs:

Image libraries
===============

Various system-level image libraries used by `Pillow <https://python-pillow.github.io/>`_ are installed in the guest machine.

To install Pillow itself, it should be included in ``requirements.txt`` along with other Python dependencies (see :ref:`feat-py-dependencies` below). But considering many of its features `require external libraries <http://pillow.readthedocs.io/en/3.0.x/installation.html#external-libraries>`_, and the high likelihood that a Django project will require Pillow, those libraries are installed in readiness.

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

`PostgreSQL <https://www.postgresql.org/>`_ is installed.

In addition, a database user is created with a username equal to the :ref:`project name <conf-var-project-name>` and a password equal to :ref:`conf-var-db-pass`. A database is also created, also with a name equal to the :ref:`project name <conf-var-project-name>`, with the aforementioned user as the owner.

The Postgres installation is configured to listen on the default port (5432).


.. _feat-nginx:

Nginx
=====

In production environments, `nginx <https://nginx.org/en/>`_ is installed.

The ``nginx.conf`` file used can be modified. Also, the site config can - and must - be modified. See :ref:`conf-nginx` for details.

Nginx is controlled and monitored by :ref:`feat-supervisor`. A default supervisor program is provided, but can be modified. See :ref:`conf-supervisor-programs` for details.


.. _feat-gunicorn:

Gunicorn
========

In production environments, `gunicorn <http://gunicorn.org/>`_ is installed.

The ``conf.py`` file used can be modified. See :ref:`conf-gunicorn` for details.

Gunicorn is controlled and monitored by :ref:`feat-supervisor`. A default supervisor program is provided, but can be modified. See :ref:`conf-supervisor-programs` for details.


.. _feat-supervisor:

Supervisor
==========

`Supervisor <http://supervisord.org/>`_ is installed.

The ``supervisord.conf`` file used can be modified. See :ref:`conf-supervisor` for details.

Default programs for :ref:`feat-nginx` and :ref:`feat-gunicorn` are provided, but any number of additional programs can be added. See :ref:`conf-supervisor-programs` for details.


.. _feat-virtualenv:

Virtualenv
==========

A virtualenv is created at ``/opt/app/virtualenv/``, and is automatically activated when the ``webmaster`` user logs in via SSH.

.. _feat-py-dependencies:

Python dependency installation
------------------------------

If a ``requirements.txt`` file is found in the project root directory (``/opt/app/src/``), the included requirements will be installed into the virtualenv (via ``pip -r requirements.txt``).

In development environments, a ``dev_requirements.txt`` file can also be specified to install additional development-specific dependencies, e.g. debugging tools, documentation building packages, etc. This keeps these kinds of packages out of the project's primary ``requirements.txt``.


.. _feat-node:

Node.js/npm
===========

If a ``package.json`` file is found in the project root directory (``/opt/app/src/``), `node.js <https://nodejs.org/en/>`_ and `npm <https://www.npmjs.com/>`_ are installed. If a ``package.json`` file is added to the project at a later date, provisioning can be safely re-run to perform this step (using the ``vagrant provision`` command).

A ``node_modules`` directory is created at ``/opt/app/node_modules/`` and a symlink to this directory is created in the project root directory (``/opt/app/src/node_modules``). Keeping the ``node_modules`` directory out of the synced folder helps avoid potential issues with Windows host machines - path names generated by installing certain npm packages can exceed the maximum Windows allows.

.. note::
    In order to create the ``node_modules`` symlink when running a Windows host and using VirtualBox shared folders, ``vagrant up`` must be run with Administrator privileges to allow the creation of symlinks in the synced folder. See :ref:`limitations-windows` for details.

.. _feat-node-dependencies:

Node.js dependency installation
-------------------------------

``npm install`` will be run in the project root directory.

In production environments, ``npm install --production`` will be used, limiting the installed dependencies to those listed in the ``dependencies`` section of ``package.json``. Otherwise, dependencies listed in ``dependencies`` and ``devDependencies`` will be installed. See the `documentation on npm install <https://docs.npmjs.com/cli/install>`_.


.. _feat-env-py:

env.py
======

Several of the :ref:`conf-env-sh` settings are designed to eliminate hardcoding environment-specific and/or sensitive settings in Django's ``settings.py`` file. Things like the database password, the ``SECRET_KEY`` and the ``DEBUG`` flag should be configured per environment and not be committed to source control.

`12factor <http://12factor.net/>`_ recommends these types of settings `be loaded into environment variables <http://12factor.net/config>`_, with these variables subsequently used in ``settings.py``. But environment variables can be a kind of invisible magic, and it is not easy to simply view the entire set of environment variables that exist for a given project's use. To make this possible, an ``env.py`` file is written by the provisioning scripts.

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

The default ``environ`` dictionary will contain the following key/values:

* DEBUG: Will be True if :ref:`conf-var-debug` is set to ``1``, False otherwise (including when it is not defined at all).
* DB_USER: Set to the value of the :ref:`project name <conf-var-project-name>`.
* DB_PASSWORD: Set to the value of :ref:`conf-var-db-pass`.
* TIME_ZONE: Set to the value of :ref:`conf-var-time-zone`.
* SECRET_KEY: Automatically generated. More secure than the default provided by Django's ``startproject``, this version contains 128 characters from an expanded alphabet, chosen using Python's ``random.SystemRandom().choice``.

If a specific project has additional sensitive or environment-specific settings that are better not committed to source control, it is possible to modify the way ``env.py`` is written such that it can contain those settings as well, or at least placeholders for them. See :ref:`conf-env-py` for more details.

.. note::

    The ``env.py`` file should not be committed to source control. Doing so would defeat the purpose!


.. _feat-project-provisioning:

Project-specific provisioning
=============================

In addition to the above generic provisioning, any special steps required by individual projects can be included using the ``provision/project.sh`` file. If found, this shell script file will be executed during the provisioning process. This file can be used to install additional system libraries, create/edit configuration files, etc.

For more information, see the :doc:`project-provisioning` documentation.


.. _feat-commands:

Shortcut commands
=================

The following shell commands are made available on the system path for convenience:

* ``pull+``: For git users. A helper script for pulling in the latest changes from origin/master and performing several post-pull updates. It must be run from the project root directory (``/opt/app/src/``). Specifically, and in order of operation, the script:

    * Runs ``git pull origin master`` as the ``www-data`` user
    * Runs ``python manage.py collectstatic`` (production environments only), also as the ``www-data`` user
    * Checks for differences in requirements.txt\ :sup:`#`
    * Asks to install from requirements, if any differences were found
    * Runs ``pip install -r requirements.txt`` if installing was requested
    * Checks for unapplied migrations (using Django's ``showmigrations`` management command)
    * Asks to apply the migrations, if any were found
    * Runs ``python manage.py migrate`` if applying was requested
    * Runs ``python manage.py remove_stale_contenttypes`` if using Django 1.11+
    * Restarts gunicorn (production environments only)

#: When first run, ``pull+`` detects differences between the ``requirements.txt`` file as it existed *before* the pull vs *after* the pull. Even if no differences are found, the installed packages may still be out of date if an updated ``requirements.txt`` was pulled in prior to running the command. After the first run, it stores a temporary copy of ``requirements.txt`` any time updates are chosen to be installed. It can then compare the newly-pulled file to this temporary copy, enabling it to detect changes from any pulls that took place in the meantime as well. However, if the requirements are updated manually (outside of using this command), it will detect differences in the files even if the installed packages are up to date.
