========
Features
========

The following features are available in the Vagrant guest machine environment constructed by the included provisioning scripts.


.. _feat-public-key:

Custom SSH public key
=====================

A user-defined SSH public key can be provided as the :ref:`conf-var-public-key` variable in the ``env.sh`` file. This will be installed into ``/home/vagrant/.ssh/authorized_keys``, allowing it to be used to SSH into the guest machine as the ``vagrant`` user.

This is useful in situations where ``vagrant ssh`` is not supported out of the box, and you already have an alternate SSH client with an existing private/public key pair in operation. E.g. Using PuTTY for SSH under Windows.


.. _feat-timezone:

Time zone
=========

The time zone of the guest machine can be set using the :ref:`conf-var-timezone` setting in the ``env.sh`` file.


.. _feat-git:

Git
===

`Git <https://git-scm.com/>`_ is installed in the guest machine, and a ``.gitconfig`` file :ref:`can be specified <conf-gitconfig>` to enable configuration of the git environment for the ``vagrant`` user.


.. _feat-virtualenv:

Virtualenv
==========

A virtualenv with a name equal to the :ref:`project name <conf-var-project-name>` is created in the guest machine, at ``/home/vagrant/.virtualenvs/<project name>``. This virtualenv is automatically activated when the ``vagrant`` user SSHs into the machine.


.. _feat-dependencies:

Dependency installation
=======================

If using the "project" build mode, the provisioner will look for a ``requirements.txt`` file defined in the project root directory (``/vagrant/`` in the guest machine). If found, these requirements will be installed into the virtualenv. This is designed to allow installation of Python packages required in a production environment. It is not suitable for "app" builds, as apps should specify their dependencies in other ways, so they can be identified and installed along with the app.

For both "project" and "app" build modes, and where :ref:`conf-var-debug` is ``1``, the provisioner will also look for a ``dev_requirements.txt`` file, also in the project root directory. If found, these requirements will also be installed into the virtualenv. This is designed to enable specification of Python packages required during development, that are *not* required for the project/application to run in production. An example might include `sphinx <http://sphinx-doc.org/>`_, for documentation generation.


.. _feat-postgres:

PostgreSQL
==========

PostgreSQL is installed in the guest machine.

In addition, a database user is created with a username equal to the :ref:`project name <conf-var-project-name>` and a password equal to :ref:`conf-var-db-pass`. A database is also created, also with a name equal to the :ref:`project name <conf-var-project-name>`, with the aforementioned user as the owner.

The Postgres installation is configured to listen on the default port (5432).


.. _feat-migrations:

Running migrations
==================

If a ``manage.py`` file is found in the project root directory, the management command ``manage.py migrate`` will be run after the virtualenv is built and activated, Postgres is installed and the database created.


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
* DB_USER: Same as the :ref:`project name <conf-var-project-name>`.
* DB_PASSWORD: Set to the value of :ref:`conf-var-db-pass`.
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
