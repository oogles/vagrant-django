===========================
Configuring the environment
===========================

The environment of the Vagrant guest machine (or production server) provisioned by these scripts is designed to provide everything necessary for developing and hosting Django-based projects with minimal configuration. Several configuration files are included and utilised by the scripts. For the most part, these configuration files do not *require* any modification, but can be modified if necessary. Files which *do* require modification are highlighted.

.. note::
    Any of the below configuration files that are listed as being located in ``provision/conf/`` are subject to :ref:`deployment-specific overrides <feat-deployments>`. While they reside in ``provision/conf/`` by default, they may be moved to or overridden by files in deployment-specific config directories.


.. _conf-vagrantfile:

Vagrantfile
===========

Location: project root (``/opt/app/src/``)

.. important:: Modification required

The use and feature set of the ``Vagrantfile`` are beyond the scope of this documentation. For more information on the file itself, see `the Vagrant documentation <https://docs.vagrantup.com/v2/vagrantfile/>`_.

An example ``Vagrantfile`` is included, which only requires minimal configuration to use: The project's name must be included. This is done by way of the ``project`` variable defined at the top of the file. The existing value (an empty string) should be replaced by your project's name, as a string.

Alternatively, an entirely custom ``Vagrantfile`` can be used. In either case, the following features are of note:

* **The provisioner**
    The ``provision/scripts/bootstrap.sh`` shell provisioner needs to be included and configured.

    .. code-block:: ruby

        config.vm.provision "shell" do |s|
            s.path = "provision/scripts/bootstrap.sh"
            s.args = ["<project_name>"]
        end

    ``<project_name>`` should be replaced with a suitable name for the project. It dictates multiple features of the environment. :ref:`See below <conf-var-project-name>` for details.
* **Synced folder**
    The type of synced folder used is not important, however the following aspects are:

    * The location of the folder on the guest machine must be ``/opt/app/src/``. Various provisioning scripts and included config files expect the project's source to be found there.
    * The owner and group should be ``www-data``. Various other files and directories will have their owners/groups set to ``www-data``, and certain included config files (such as the supervisor programs for nginx and gunicorn) run programs as ``www-data``.
* **The box**
    While not necessarily a requirement, the most recent versions of the provisioning scripts have only been tested on "bento/ubuntu-18.04".

.. _conf-var-project-name:

Project name
------------

The name of the project is used by the provisioning scripts for the following:

* The name of the default PostgreSQL database created.
* The name of the default PostgreSQL database user created.
* The location of the ``env.py`` Python settings file: ``<project root>/<project name>/env.py``. It is assumed this is the directory containing ``settings.py``.
* The name of the nginx site config file (placed in ``/etc/nginx/sites-available/`` and linked to in ``/etc/nginx/sites-enabled/``).

This means that the name given must be valid for each of those uses. E.g. names incorporating hyphens should use underscores instead (use ``project_name`` instead of ``project-name``).


.. _conf-env-sh:

env.sh
======

Location: ``provision/env.sh``

.. important:: Modification required

The primary configuration file is ``env.sh``. It is simply a shell script that gets executed by the provisioning scripts to load the variables it contains. An example file is included. Most variables can be left as-is, but some will require being set correctly - each of the variables is discussed below.

When provisioning is first run, it will modify this file. Some of the settings below generate defaults if no value is provided, and that default will get written back to the file so the same value will be used in the case of re-provisioning. Some additional settings may also be written to this file - these are convenience settings used internally by the provisioning process and should not be modified.

.. important::

    The settings contained in ``env.sh`` are sensitive and/or environment-specific, and thus should not be committed to source control.

.. note::

    Several of these settings affect ``env.py``. See :ref:`feat-env-py` for the virtues of using these values over values hardcoded in ``settings.py``.

.. _conf-var-debug:

DEBUG
-----

**Required**

This flag controls whether or not to provision a development or production environment. A value of ``1`` indicates a development environment, a value of ``0`` indicates a production environment.

This flag affects numerous aspects of the environment. For a breakdown of the features only available in production environments (when the flag is ``0``), see :doc:`production`.

This value is also written to ``env.py`` so it may be imported into ``settings.py`` and used for Django's ``DEBUG`` setting. A value of ``1`` is written as ``True``, a value of ``0`` is written as ``False``.

.. _conf-var-public-key:

PUBLIC_KEY
----------

**Required**

This public key will be installed into ``/home/webmaster/.ssh/authorized_keys`` so it may be used to SSH into the provisioned environment as the ``webmaster`` user.

.. _conf-var-deployment:

DEPLOYMENT
----------

*Optional*

The name of this deployment of the project. Naming a deployment allows the use of :ref:`deployment-specific configuration files <feat-deployments>`.

.. _conf-var-time-zone:

TIME_ZONE
---------

*Optional*

The time zone that the provisioned environment should use. Defaults to "Australia/Sydney".

This value is also written to ``env.py`` so it may be imported into ``settings.py`` and used for Django's ``TIME_ZONE`` setting.

.. _conf-var-secret-key:

SECRET_KEY
----------

*Optional*

A value for the Django ``SECRET_KEY`` setting. If provided as an empty string, or left out of the file altogether, a default random string will be generated. This generated value is more secure than the default provided by Django's ``startproject`` - containing 128 characters from an expanded alphabet, chosen using Python's ``random.SystemRandom().choice``.

If a default value is generated, it will be written back to this file so the same value can be used in the case of re-provisioning.

This value is also written to ``env.py`` so it may be imported into ``settings.py`` and used for Django's ``SECRET_KEY`` setting.

.. _conf-var-db-pass:

DB_PASS
-------

*Optional*

The password to use for the default database user. If provided as an empty string, or left out of the file altogether, a default 20-character password will be generated.

If a default value is generated, it will be written back to this file so the same value can be used in the case of re-provisioning.

This value is also written to ``env.py`` so it may be imported into ``settings.py`` and used as a database password in Django's ``DATABASES`` setting.

.. _conf-var-env-py-template:

ENV_PY_TEMPLATE
---------------

*Optional*

The template to use when writing the ``env.py`` file, as a file path relative to ``provision/templates/``. Defaults to ``env.py.txt``. A default template file is provided at ``provision/templates/env.py.txt``.

See :ref:`conf-env-py` for more details on using custom ``env.py`` templates.


.. _conf-versions-sh:

versions.sh
===========

Location: ``provision/versions.sh``

This file contains the versions of various packages to be installed during provisioning. Like ``env.sh``, it is simply a shell script that gets executed by the provisioning scripts to load the variables it contains. Unlike ``env.sh``, this file *should* be committed to source control. All environments should install the same versions of the software they use.

The included ``versions.sh`` contains default values for all variables. It will not require modification unless the default values are unsuitable for your project, or have since become outdated.

.. _conf-var-base-python:

BASE_PYTHON_VERSION
-------------------

The "base" Python version is the version that will be used to create the virtualenv under which all relevant Python processes for the project will be run. It can be left blank in order to use the operating system's standard version.

If specified, it must be the full version string, e.g. "2.7.14", "3.6.4", etc. In addition, it must be a version recognised and usable by `pyenv <https://github.com/pyenv/pyenv>`_. Pyenv is used to automate the process of downloading and installing the specified version of Python, and using it to build the virtualenv (via its `pyenv-virtualenv <https://github.com/pyenv/pyenv-virtualenv>`_ plugin).

.. _conf-var-python-versions:

PYTHON_VERSIONS
---------------

An array of Python versions to install, e.g. to use with `tox <https://tox.readthedocs.io/en/latest/>`_ for testing under multiple versions. It can be left empty to install no additional versions of Python on the provisioned system. If specified, each version should be a full version string, such as "2.7.14", "3.6.4", etc. For example:

.. code-block:: none

    PYTHON_VERSIONS=('2.7.14' '3.5.4' '3.6.4')

`Pyenv <https://github.com/pyenv/pyenv>`_ is used to automate the download and installation of the specified versions.

These versions are installed *in addition* to any :ref:`base version <conf-var-base-python>`, but the same base version can be included in the list in order to control its position in the version priority list used with the ``pyenv global`` command. If the base version is *not* included in the list, it will be added to the end of it for the purposes of the ``pyenv global`` command. See the :ref:`feature documentation <feat-python>` for more details.

.. _conf-var-node-version:

NODE_VERSION
------------

The version of `node.js <https://nodejs.org/en/>`_ to install. Only the major version should be specified - the latest minor version will always be used.

Installation is performed by first installing the relevant `Nodesource <https://nodesource.com/>`_ apt repo, using a script from the Nodesource `binary distribution repository <https://github.com/nodesource/distributions/tree/master/deb>`_ on GitHub. Therefore, the version must correspond to a installation script provided by Nodesource.

.. note::

    Regardless of this version setting, node.js will only be installed if a ``package.json`` file is present in the root directory of your project.


.. _conf-firewall:

Configuring the firewall
========================

**Only applicable in production environments**

Location: ``provision/conf/firewall-rules.conf``

In production environments, the existence of the ``provision/conf/firewall-rules.conf`` file determines whether a firewall will be configured. A default file is provided, so be sure to remove it if no firewall is desired. The default file also defines a default set of useful firewall rules, namely:

* Allowing incoming traffic on port 22, for SSH connections
* Allowing incoming traffic on ports 80 and 442, for web traffic

Any modifications to these rules or additions to them should be done in the ``firewall-rules.conf`` file. Each line in the file simply needs to be a valid argument sequence for the ``ufw`` command. Refer to `the manual <http://manpages.ubuntu.com/manpages/xenial/en/man8/ufw.8.html>`_ for details on the ``ufw`` command syntax.

Making changes to this file and re-provisioning via ``vagrant provision`` will enact the changes.


.. _conf-nginx:

Configuring nginx
=================

**Only applicable in production environments**

nginx.conf
----------

Location: ``provision/conf/nginx/nginx.conf``

In production environments, this file is copied to ``/opt/app/conf/nginx/nginx.conf`` as part of the provisioning process. The provided nginx supervisor program references that location when providing a config file to the ``nginx`` command.

A default file is provided which requires no configuration out of the box.

The only aspect of the default configuration to note is that it passes access and error logs through to be written and rotated by supervisor.

Making changes to this file and re-provisioning via ``vagrant provision`` will enact the changes. Alternatively, on-the-fly changes can be made to the copied file, simply restarting nginx via ``supervisorctl restart nginx`` to make them effective.

.. note::

    On-the-fly changes to the copied file will not survive re-provisioning. Any changes made to this file should be duplicated in ``provision/conf/nginx/nginx.conf``.

.. _conf-nginx-site:

Site config
-----------

Location: ``provision/conf/nginx/site``

.. important:: Modification required

In production environments, this file is copied to ``/etc/nginx/sites-available/<project_name>``, and symlinked into ``sites-enabled``, as part of the provisioning process.

A default file is provided, but it does require minimal configuration: setting the ``server_name`` directive.

The default configuration contains a single server context for port 80, with three location contexts:

* ``/static/``: Directly serving static content out of ``/opt/app/static/``.
* ``/media/``: Directly serving media content out of ``/opt/app/media/``.
* ``/``: Proxying to gunicorn via a unix socket.

Making changes to this file and re-provisioning via ``vagrant provision`` will enact the changes. Alternatively, on-the-fly changes can be made to the copied file, simply restarting nginx via ``supervisorctl restart nginx`` to make them effective.

.. note::

    On-the-fly changes to the copied file will not survive re-provisioning. Any changes made to this file should be duplicated in ``provision/conf/nginx/site``.


.. _conf-gunicorn:

Configuring gunicorn
====================

**Only applicable in production environments**

Location: ``provision/conf/gunicorn/conf.py``

In production environments, this file is copied to ``/opt/app/conf/gunicorn/conf.py`` as part of the provisioning process. The provided gunicorn supervisor program references that location when providing a config file to the ``gunicorn`` command.

A default file is provided which requires no configuration out of the box.

The default configuration binds to nginx via a unix socket and passes error logs through to be written and rotated by supervisor.

Making changes to this file and re-provisioning via ``vagrant provision`` will enact the changes. Alternatively, on-the-fly changes can be made to the copied file, simply restarting gunicorn via ``supervisorctl restart gunicorn`` to make them effective.

.. note::

    On-the-fly changes to the copied file will not survive re-provisioning. Any changes made to this file should be duplicated in ``provision/conf/gunicorn/conf.py``.


.. _conf-supervisor:

Configuring supervisor
======================

supervisord.conf
----------------

Location: ``provision/conf/supervisor/supervisor.conf``

This file is copied directly into ``/etc/supervisor/supervisord.conf`` as part of the provisioning process.

A default file is provided which requires no configuration out of the box.

The only aspect of the default configuration to note is that it makes the supervisor socket file writable by the ``supervisor`` group. The ``supervisor`` group itself is added during provisioning, and the ``webmaster`` user is added to it, enabling the ``webmaster`` user to interact with ``supervisorctl`` without needing ``sudo``.

Making changes to this file and re-provisioning via ``vagrant provision`` will enact the changes. Alternatively, on-the-fly changes can be made to the copied file, simply restarting supervisor via ``service supervisor restart`` to make them effective.

.. _conf-supervisor-programs:

Supervisor programs
-------------------

Location: ``provision/conf/supervisor/programs/``

The entire contents of the relevant ``programs/`` directory is copied into ``/etc/supervisor/conf.d/`` as part of the provisioning process.

Default programs are provided for running nginx and gunicorn in production environments:

* Nginx: ``provision/conf/supervisor/programs/nginx.conf``
* Gunicorn: ``provision/conf/supervisor/programs/gunicorn.conf``

Making changes or additions to program files and re-provisioning via ``vagrant provision`` will enact the changes.


.. _conf-user-config:

Configuring the user's shell environment
========================================

Location: ``provision/conf/user/``

Any files found in the ``provision/conf/user/`` directory will be copied directly into the ``webmaster`` user's home directory. This facility can be used to provide config files that affect the logged in user's shell environment. E.g. ``.gitconfig`` for the configuration of :ref:`git <feat-git>`, or additional shortcut scripts under the ``bin`` subdirectory.

.. note::

    Files will not be copied if they already exist in the user's home directory. This means local changes to these files will not be overwritten, and also that changes to the files in ``provision/conf/user/`` will not be applied when re-provisioning unless the home directory file is removed.

.. note::

    Any files present in the ``provision/conf/user/bin/`` directory will be marked as executable when they are copied, and will be available on the system path.


.. _conf-env-py:

Customising env.py
==================

Location: ``provision/templates/env.py.txt``

If a specific project has additional sensitive or environment-specific settings that are better not committed to source control, it is possible to modify the way ``env.py`` is written such that it can contain those settings, or at least placeholders for them.

The ``env.py`` file is written by taking a template and replacing placeholders with settings from ``env.sh``. The default template lives in ``provision/templates/env.py.txt``.

This template can be extended or replaced to produce a custom ``env.py`` file. ``env.py`` is just a Python file, so any custom template needs to generate valid Python code. Other than that, there is no limitation on what can be included in the ``env.py`` file, though it is recommended it remain a simple key/value store, with as little logic as possible.

.. note::

    The ``env.py`` file will not be overwritten once it is created, so if the template is modified, the existing file will need to be removed prior to re-provisioning if a new file is to be generated.

Placeholders
------------

The default template contains placeholders for the following settings: ``DEBUG``, ``SECRET_KEY``, ``TIME_ZONE``, ``PROJECT_NAME`` and ``DB_PASSWORD``.

These placeholders share the name of the setting, prefixed with a dollar sign. E.g. the placeholder for the ``DEBUG`` setting is ``$DEBUG``.

When the ``env.py`` file is written, any occurrence of these placeholders within the template will be replaced with that setting's actual value.

A custom ``env.py`` template can use as many additional placeholders for these settings as necessary.

On its own, just customising the template cannot inject *additional* settings. But it can define the structure, and all the keys, that are necessary - such that viewing the ``env.py`` file shows all the values that need to be provided.

The following shows the default ``env.py`` template compared to an example that modifies the structure and adds an additional entry for an API key that isn't known at the time of provisioning, but needs to be added afterward.

.. code-block:: none

    # Default template
    environ = {
        'DEBUG': $DEBUG,
        'SECRET_KEY': r'$SECRET_KEY',
        'TIME_ZONE': '$TIME_ZONE',
        'DB_USER': '$PROJECT_NAME',
        'DB_PASSWORD': r'$DB_PASSWORD'
    }

    # Example custom template
    environ = {
        'DEBUG': $DEBUG,
        'SECRET_KEY': r'$SECRET_KEY',
        'TIME_ZONE': '$TIME_ZONE',
        'DATABASE': {
            'NAME': '$PROJECT_NAME',
            'USER': '$PROJECT_NAME',
            'PASSWORD': r'$DB_PASSWORD'
        },
        'API_KEY': r'<replace_this>'
    }

Injecting additional settings
-----------------------------

If a project has other settings that are generated as part of the provisioning process, such as a random password or key, it is convenient to also be able to inject it into the ``env.py`` file. Customising the template allows defining a key, but injecting the generated value itself cannot be done through the custom template alone.

That's where :doc:`project-specific provisioning <project-provisioning>` comes in.

The custom template simply needs to provide a placeholder that can be identified for replacement. As per the main settings, a unique name prefixed with a dollar sign works well. E.g. ``$MY_CUSTOM_VALUE``. Then, in ``project.sh``, add the following:

.. code-block:: bash

    sed -i -r -e "s|\\\$MY_CUSTOM_VALUE|$MY_CUSTOM_VALUE|g" "/opt/app/src/project_name/env.py"

The following shows a custom template that includes extra entries for credentials generated for `RabbitMQ <https://www.rabbitmq.com/>`_, installed and configured as per the project-specific provisioning :ref:`example <project-example>`.

.. code-block:: none

    # Example custom template
    environ = {
        'DEBUG': $DEBUG,
        'SECRET_KEY': r'$SECRET_KEY',
        'TIME_ZONE': '$TIME_ZONE',
        'DB_USER': '$PROJECT_NAME',
        'DB_PASSWORD': r'$DB_PASSWORD',
        'RABBIT_USER': '$PROJECT_NAME',
        'RABBIT_PASSWORD': r'$RABBIT_PASSWORD'
    }
