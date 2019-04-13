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

The use and feature set of the ``Vagrantfile`` are beyond the scope of this documentation. For more information on the file itself, see `the Vagrant documentation <https://docs.vagrantup.com/v2/vagrantfile/>`_.

An example ``Vagrantfile`` is included, which does not require any configuration to use, but of course can be modified as necessary. Alternatively, an entirely custom ``Vagrantfile`` can be used. In either case, the following features are of note:

* **The provisioner**
    The ``provision/scripts/bootstrap.sh`` shell provisioner needs to be included and configured.

    .. code-block:: ruby

        config.vm.provision "shell" do |s|
            s.path = "provision/scripts/bootstrap.sh"
        end

* **Synced folder**
    The type of synced folder used is not important, however the following aspects are:

    * The location of the folder on the guest machine must be ``/opt/app/src/``. Various provisioning scripts and included config files expect the project's source to be found there.
    * The owner and group should be ``www-data``. Various other files and directories will have their owners/groups set to ``www-data``, and certain included config files (such as the supervisor programs for nginx and gunicorn) run programs as ``www-data``.
* **The box**
    While not necessarily a requirement, the most recent versions of the provisioning scripts have only been tested on "bento/ubuntu-18.04".


.. _conf-settings-sh:

settings.sh
===========

Location: ``provision/settings.sh``

.. important:: Modification required

This file contains core settings for the provisioning process, which are consistent across all environments and deployments of the project.

It is simply a shell script that gets executed by the provisioning scripts to load the variables it contains. A default file is provided but requires modification before use. The variables it contains are discussed below.

.. _conf-var-project-name:

PROJECT_NAME
------------

The name of the project. The project name must be provided before provisioning is possible.

It is used by the provisioning scripts for the following:

* The name of the default PostgreSQL database created.
* The name of the default PostgreSQL database user created.
* The location of the ``env.py`` Python settings file: ``<project root>/<project name>/env.py``. It is assumed this is the directory containing ``settings.py``.
* The name of the nginx site config file (placed in ``/etc/nginx/sites-available/`` and linked to in ``/etc/nginx/sites-enabled/``).

This means that the name given must be valid for each of those uses. E.g. names incorporating hyphens should use underscores instead (use ``project_name`` instead of ``project-name``).

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

    PYTHON_VERSIONS=('2.7.16' '3.5.7' '3.6.8')

`Pyenv <https://github.com/pyenv/pyenv>`_ is used to automate the download and installation of the specified versions.

These versions are installed *in addition* to any :ref:`base version <conf-var-base-python>`, but the same base version can be included in the list in order to control its position in the version priority list used with the ``pyenv global`` command. If the base version is *not* included in the list, it will be added to the end of it for the purposes of the ``pyenv global`` command. See the :ref:`feature documentation <feat-python>` for more details.

.. _conf-var-node-version:

NODE_VERSION
------------

The version of `node.js <https://nodejs.org/en/>`_ to install. Only the major version should be specified - the latest minor version will always be used.

Installation is performed by first installing the relevant `Nodesource <https://nodesource.com/>`_ apt repo, using a script from the Nodesource `binary distribution repository <https://github.com/nodesource/distributions/tree/master/deb>`_ on GitHub. Therefore, the version must correspond to a installation script provided by Nodesource.

.. note::

    Regardless of this version setting, node.js will only be installed if a ``package.json`` file is present in the root directory of your project.


.. _conf-env-sh:

env.sh
======

Location: ``provision/env.sh``

.. important:: Modification required

This file contains many of the primary settings required by the provisioning process, but differs from :ref:`conf-settings-sh` in that these settings are either *sensitive* or *environment specific*. That is, they usually differ between development and production, or between multiple production deployments. As such, unlike :ref:`conf-settings-sh`, this file should not be committed to source control.

It is simply a shell script that gets executed by the provisioning scripts to load the variables it contains. An example file is included. Most variables can be left as-is, but some will require being set correctly - each of the variables is discussed below.

When provisioning is first run, it will modify this file. Some of the settings below generate defaults if no value is provided, and that default will get written back to the file so the same value will be used in the case of re-provisioning.

.. note::

    Several of these settings affect ``env.py``. See :ref:`feat-env-py` for the virtues of using these values over values hardcoded in ``settings.py``.

.. important::

    Again, due to the sensitive and/or environment-specific nature of the settings found in ``env.sh``, the file **should not be committed** to source control.

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

In the case of systems that require access by multiple keys, others can be manually added to ``/home/webmaster/.ssh/authorized_keys`` once the one provided here is used to log in initially.

.. _conf-var-nginx-conf:

NGINX_CONF_VARS
---------------

**Required**

An associative array containing replacement values for template variables found in :ref:`nginx configuration files <conf-nginx>`. An entry for the ``domain`` variable is included by default, and a value **must** be provided in production environments in order to generate valid configuration files. Any number of additional entries can be added to enable further dynamic configuration of nginx.

While the setting is always required to exist, it need not contain any entries in development environments. As noted above, the ``domain`` entry is required in production environments.

Any and all variables listed in ``NGINX_CONF_VARS`` will be applied to *all* nginx configuration files, though they will not have an effect unless the file contains a matching template variable.

.. _conf-var-deployment:

DEPLOYMENT
----------

*Optional*

The name of this deployment of the project. Naming a deployment allows the use of :ref:`deployment-specific configuration files <feat-deployments>`.

The included :ref:`conf-env-sh` file uses a default value of ``'dev'``, to take advantage of the included config files that are :ref:`customised for development environments <feat-deployments-dev>`.

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

Several configuration files for nginx are included under ``provision/conf/nginx/``. They are discussed individually in more detail below. However, they can all contain *template variables*, which will be replaced during the provisioning process, at the time of copying the config file to the appropriate location on the server's file system.

By default, several of the included nginx config files for production environments contain the ``{{domain}}`` template variable. Unless a value is provided for this variable, the copied configuration files will be invalid. A value can be provided by populating :ref:`conf-var-nginx-conf` in the :ref:`conf-env-sh` file.

None of the default config files for development environments make use of any template variables.

Regardless of environment, the config files can be modified to include additional template variables if desired.

Any and all variables listed in :ref:`conf-var-nginx-conf` will be applied to *all* nginx configuration files, though they will not have an effect unless the file contains a matching template variable.

nginx.conf
----------

Location: ``provision/conf/nginx/nginx.conf``

In production environments, this file is copied to ``/etc/nginx/nginx.conf`` as part of the provisioning process (the default location for the nginx config file).

A default file is provided which requires no configuration out of the box.

The only aspect of the default configuration to note is that it passes access and error logs through to be written and rotated by supervisor.

Making changes to this file and re-provisioning via ``vagrant provision`` will enact the changes. Alternatively, on-the-fly changes can be made to the copied file, simply restarting nginx via ``supervisorctl restart nginx`` to make them effective.

.. note::

    On-the-fly changes to the copied file will not survive re-provisioning. Any such changes made to this file should be duplicated in ``provision/conf/nginx/nginx.conf``.

.. _conf-nginx-site:

Default site config
-------------------

The default site config used depends on the :ref:`conf-var-deployment`. A different version is used in production vs development. In addition, in production deployments there are actually *two* different site configs: an unsecured version and a HTTPS-supporting secured version.

The files are located at:

* Development version: ``provision/conf-dev/nginx/site``
* Unsecured production version: ``provision/conf/nginx/site``
* Secured production version : ``provision/conf/nginx/secure-site``

The differences between the files are discussed below. Through the use of template variables, as described above, no configuration is required to the files themselves, although the ``"domain"`` entry is required to be populated in :ref:`conf-var-nginx-conf` for production environments.

As part of the provisioning process, all site configs for the deployment will be copied to ``/etc/nginx/sites-available/``, and be renamed to include the :ref:`conf-var-project-name`. Then, a symlink to the active site config will created in ``/etc/nginx/sites-enabled/``. See :ref:`conf-letsencrypt` for more information on switching between the unsecured and secured site configs in production.

In all cases, making changes to the files and re-provisioning via ``vagrant provision`` will enact the changes. Alternatively, on-the-fly changes can be made to the copied file, simply restarting nginx via ``supervisorctl restart nginx`` to make them effective.

.. note::

    On-the-fly changes to the copied file will not survive re-provisioning. Any such changes made to these files should be duplicated in their locations in ``provision/conf/nginx/``.

Development site config
~~~~~~~~~~~~~~~~~~~~~~~

The default site configuration for development contains a single server context for port 80, with two location contexts:

* ``/media/``: Directly serve media content out of ``/opt/app/media/``.
* ``/``: Proxy to a Django ``runserver`` on port 8460.

Static files are not configured to be served by nginx in development. These files are left to be served by the Django ``runserver`` command, which handles automatically locating the appropriate files among the various locations they can reside, avoiding the need to run the ``collectstatic`` command after every modification (as is required in production).

.. _conf-nginx-unsecured-site:

Unsecured production site config
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The unsecured version of the production site configuration is activated by the standard provisioning process. The default configuration contains a single server context for port 80, with a ``server_name`` of the domain listed in :ref:`conf-var-nginx-conf` and its "www." subdomain. E.g. if the domain in :ref:`conf-var-nginx-conf` was set to "example.com", the ``server_name`` would be "example.com www.example.com".

The included server context does very little - only enough to allow Let's Encrypt to verify the domain. It's purpose is as a placeholder until the :ref:`secured site configuration is enabled <conf-letsencrypt>`. If not enabling the secured config, this file will need to be modified to do something useful.

Secured production site config
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The secured version of the production site configuration is activated by a :ref:`secondary, post-provisioning process <conf-letsencrypt>`. Unlike the unsecured version, it is preconfigured to use a TLS certificate obtained from Let's Encrypt to provide HTTPS support. The default configuration contains multiple server contexts, using the domain listed in :ref:`conf-var-nginx-conf`:

* Port 80, listed domain and "www." subdomain (e.g. example.com and www.example.com): This context handles HTTP verification requests from Let's Encrypt and redirects all other traffic to HTTPS.
* Port 443, "www." subdomain only (e.g. www.example.com): This context handles HTTPS verification requests from Let's Encrypt and redirects all other traffic to the non-prefixed domain (e.g. example.com).
* Port 443, listed domain only (e.g. example.com): This context is the target of the redirections from the previous two and does all the real work. It handles HTTPS verification requests from Let's Encrypt and contains the following additional location contexts:

    * ``/static/``: Directly serving static content out of ``/opt/app/static/``.
    * ``/media/``: Directly serving media content out of ``/opt/app/media/``.
    * ``/``: Proxying to gunicorn via a unix socket.

Snippets
--------

Two "snippet" files are also included by default. These files are copied to ``/etc/nginx/snippets/`` during the provisioning process and referenced by the included site configurations. The snippet files are:

* ``provision/conf/nginx/snippets/letsencrypt.conf``: Contains the location context for handling verification requests from Let's Encrypt, included in multiple server contexts in both the secured and unsecured site configurations for production environments.
* ``provision/conf/nginx/snippets/ssl.conf``: Contains SSL/TLS-specific directives included in multiple server contexts in the secured site configuration.

As with all included config files, these may be modified as necessary. Additional snippet files may be also included and referenced in config files. All files found in ``provision/conf/nginx/snippets/`` will be copied during provisioning.

.. _conf-letsencrypt:

Enabling TLS via Let's Encrypt
------------------------------

The normal provisioning process for production deployments enables the *unsecured* nginx site config. As :ref:`discussed above <conf-nginx-unsecured-site>`, this site config has no support for serving the content of your project by default. It's purpose is to respond to verification requests from the `Let's Encrypt <https://letsencrypt.org/>`_ service. In order to actually *use* the Let's Encrypt service, trigger those verification requests, generate a TLS certificate, and switch to the *secured* site config, a separate step must be performed.

The ``provision/scripts/letsencrypt.sh`` script is designed to be run manually, after the initial provisioning process is complete. The script does the following:

* Installs the Let's Encrypt ``certbot`` utility.
* Creates the ``/opt/app/letsencrypt/.well-known/`` directory to house files created by ``certbot`` for verification purposes.
* Runs ``certbot`` to verify the domain/s and generate the TLS certificate. This command also configures automatic renewal of the certificate.
* Swaps the *unsecured* site config for the *secured* site config, which is preconfigured to use the obtained TLS certificate to provide HTTPS support.

The script takes at least two arguments:

* An email address. This is in turn passed to the ``certbot`` command to provide Let's Encrypt with an email address to use to contact you should your certificate get close to expiry without being automatically renewed.
* At least one domain name. Any additional arguments will interpreted as additional domain names. As per the `certbot documentation <https://certbot.eff.org/docs/using.html#certbot-command-line-options>`_: "The first domain provided will be the subject CN of the certificate, and all domains will be Subject Alternative Names on the certificate."

The script must be run **as root** and assumes that **nginx is running**. An example invocation is:

.. code-block:: bash

    /opt/app/src/provision/scripts/letsencrypt.sh email@example.com example.com www.example.com

.. note::

    The domain/s provided to the ``letsencrypt.sh`` script must match those handled by the nginx site configs. By default, the configs handle the domain listed in :ref:`conf-var-nginx-conf` and its "www." subdomain.


.. _conf-gunicorn:

Configuring gunicorn
====================

**Only applicable in production environments**

Location: ``provision/conf/gunicorn/conf.py``

In production environments, this file is copied to ``/etc/gunicorn/conf.py`` as part of the provisioning process. The provided gunicorn supervisor program references that location when providing a config file to the ``gunicorn`` command.

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

Location: ``provision/conf/supervisor/programs/`` and ``provision/conf-dev/supervisor/programs/``

The entire contents of the ``provision/conf/supervisor/programs/`` directory is copied into ``/etc/supervisor/conf.d/`` as part of the provisioning process. When the ``'dev'`` :ref:`deployment <feat-deployments>` is used, any overrides present in the ``provision/conf-dev/supervisor/programs/`` directory will also be copied, and take precedence.

Default programs are provided for running nginx and gunicorn in production environments:

* Nginx: ``provision/conf/supervisor/programs/nginx.conf``
* Gunicorn: ``provision/conf/supervisor/programs/gunicorn.conf``

The ``'dev'`` deployment overrides the gunicorn program to clear it. Gunicorn is not provisioned in development environments, so the supervisor command is unnecessary. In addition, including commands for services that are not available can potentially prevent supervisor from starting at all - e.g. if configured paths to log files do not exist.

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

Location: ``provision/conf/env.py``

If a specific project has additional sensitive or environment-specific settings that are better not committed to source control, it is possible to modify the way ``env.py`` is written such that it can contain those settings, or at least placeholders for them.

The ``env.py`` file is written by copying the file from ``provision/conf/env.py`` and replacing template variables with settings from ``env.sh``.

The config file can be extended or replaced to produce a custom ``env.py`` file. ``env.py`` is just a Python file, so it needs to contain valid Python code. Other than that, there is no limitation on what can be included in the ``env.py`` file, though it is recommended it remain a simple key/value store, with as little logic as possible.

.. note::

    Unlike most config files, ``env.py`` file will **not** be overwritten during re-provisioning. This would reset any values added/updated after the initial provisioning process. Unlike other config files, not all of the contents of ``env.py`` may be known at the time of provisioning, or are deliberately left to be populated manually. Therefore, if the config file is modified, the existing written file will need to be removed prior to re-provisioning if a new file is to be generated.

Config file
-----------

The default ``provision/conf/env.py`` file contains placeholders for the following settings, using the template variables as shown:

* ``DEBUG``: ``{{debug}}``
* ``SECRET_KEY``: ``{{secret_key}}``
* ``TIME_ZONE``: ``{{time_zone}}``
* ``PROJECT_NAME``: ``{{project_name}}``
* ``DB_PASSWORD``: ``{{db_password}}``

When the ``env.py`` file is written, any occurrence of these template variables within the config file will be replaced with that setting's actual value. A custom config file can use as many additional placeholders for these settings as necessary.

On its own, just customising the config file cannot inject *additional* settings - the provisioning process only knows about those listed above. But it can define the structure, and all the keys, that are necessary - such that viewing the ``env.py`` file shows all the values that need to be provided.

The following shows the default ``env.py`` config file compared to an example that modifies the structure and adds an additional entry for an API key that isn't known at the time of provisioning, but needs to be added afterward.

.. code-block:: none

    # Default template
    environ = {
        'DEBUG': {{debug}},
        'SECRET_KEY': r'{{secret_key}}',
        'TIME_ZONE': '{{time_zone}}',
        'DB_USER': '{{project_name}}',
        'DB_PASSWORD': r'{{db_password}}'
    }

    # Example custom template
    environ = {
        'DEBUG': {{debug}},
        'SECRET_KEY': r'{{secret_key}}',
        'TIME_ZONE': '{{time_zone}}',
        'DATABASE': {
            'NAME': '{{project_name}}',
            'USER': '{{project_name}}',
            'PASSWORD': r'{{db_password}}'
        },
        'API_KEY': r'<replace_this>'
    }

Injecting additional settings
-----------------------------

If a project has other settings that are generated as part of the provisioning process, such as a random password or key, may be convenient to also inject it into the ``env.py`` file. Customising the config file allows defining a key, but injecting the generated value itself cannot be done through the config file alone.

That's where :doc:`project-specific provisioning <project-provisioning>` comes in.

The config file simply needs to provide a placeholder that can be identified for replacement, e.g. ``{{my_custom_value}}``. Then, in ``project.sh``, add the following:

.. code-block:: bash

    my_custom_value='something'
    sed -i "s|{{my_custom_value}}|$my_custom_value|g" /opt/app/src/project_name/env.py

.. note::

    The pipe character (``|``) is used as a delimiter in the above ``sed`` command, instead of the conventional forward slash (``/``). This is used in ``sed`` commands throughout the provisioning scripts due to their use with URLs (which contain forward slashes). Any valid separator may be used.

The following shows a custom config file that includes extra entries for credentials generated for `RabbitMQ <https://www.rabbitmq.com/>`_, installed and configured as per the project-specific provisioning :ref:`example <project-example>`.

.. code-block:: none

    # Example custom template
    environ = {
        'DEBUG': {{debug}},
        'SECRET_KEY': r'{{secret_key}}',
        'TIME_ZONE': '{{time_zone}}',
        'DB_USER': '{{project_name}}',
        'DB_PASSWORD': r'{{db_password}}',
        'RABBIT_USER': '{{project_name}}',
        'RABBIT_PASSWORD': r'{{rabbit_password}}'
    }
