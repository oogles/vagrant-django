===================
Usage in Production
===================

The provisioning scripts are designed to be run independently of Vagrant in order to provision production environments that match those used in development. While provisioning is not as simple as ``vagrant up``, it is very straightforward.


.. _production-features:

Production-specific features
============================

There are several features that are only available in production environments. These include:

* :ref:`feat-firewall`
* :ref:`feat-nginx`
* :ref:`feat-gunicorn`

In addition, the following features behave differently when in a production environment:

* SSH access: the ``vagrant`` user is not on the list of SSH allowed users
* Python dependencies: only ``requirements.txt`` is considered, ``dev_requirements.txt`` is ignored
* Node dependencies: in ``package.json``, only ``dependencies`` is considered, ``devDependencies`` is ignored
* The ``pull+`` :ref:`shortcut command <feat-commands>` performs additional steps


.. _production-configuration:

Configuration
=============

Due to the additional features supported in production environments, some additional configuration may be required. The following are some of the things to consider:

* :ref:`conf-firewall`
* :ref:`conf-nginx`
* :ref:`conf-gunicorn`
* :ref:`conf-supervisor`

Of particular importance is the nginx site config. It **must** be modified to, at least, provide the ``server_name`` directive.


.. _production-provisioning:

Provisioning
============

Provisioning in a production environment is not quite as simple as ``vagrant up``, it requires a few more steps:

#. Create the ``/opt/app/src`` directory.
#. Copy the project source, including provisioning files into ``/opt/app/src``. The provisioning files should be at ``/opt/app/src/provision``. The easiest way to do this is probably to clone your git repository, if you use one.
#. Manually invoke the provisioning bootstrap script **as root**, passing it the name of the project:

    .. code-block:: bash

        $ /opt/app/src/provision/scripts/bootstrap.sh project_name_here


There are several final steps that automated provisioning does not take care of. This may be because they are unsafe to include in the provisioning process (e.g. in the event of re-provisioning), or because user input is required.

* ``sudo apt-get upgrade`` (see the :ref:`limitations documentation <limitations-apt-get>` for more details)
* In order to have sudo privileges, a password needs to be created for the ``webmaster`` user. When logged in as the ``webmaster`` user, simply run the ``passwd`` command to set a password.
