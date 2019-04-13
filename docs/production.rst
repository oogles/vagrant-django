===================
Usage in Production
===================

The provisioning scripts are designed to be run independently of Vagrant in order to provision production environments that match those used in development. While provisioning is not as simple as ``vagrant up``, it is very straightforward.


.. _production-features:

Production-specific features
============================

There are several features that are only available in production environments. These include:

* :ref:`feat-firewall`
* :ref:`feat-gunicorn`

In addition, the following features behave differently when in a production environment:

* :ref:`SSH access <feat-users>`: the ``vagrant`` user is not on the list of SSH allowed users
* :ref:`feat-nginx`: Nginx site configs are tailored to production sites and support :ref:`using Let's Encrypt to add TLS <feat-letsencrypt>`.
* :ref:`Python dependencies <feat-py-dependencies>`: only ``requirements.txt`` is considered, ``dev_requirements.txt`` is ignored
* :ref:`Node dependencies <feat-node-dependencies>`: in ``package.json``, only ``dependencies`` is considered, ``devDependencies`` is ignored
* The ``pull+`` :ref:`shortcut command <feat-commands>` performs additional steps


.. _production-configuration:

Configuration
=============

Due to the additional features supported in production environments, some additional configuration may be required. The following are some of the things to consider:

* :ref:`conf-firewall`
* :ref:`conf-nginx`, including :ref:`Let's Encrypt <conf-letsencrypt>`
* :ref:`conf-gunicorn`
* :ref:`conf-supervisor`


.. _production-provisioning:

Provisioning
============

Provisioning in a production environment is not quite as simple as ``vagrant up``, it requires a few more steps:

#. Create the ``/opt/app/src`` directory.
#. Copy the project source, including provisioning files into ``/opt/app/src``. The provisioning files should be at ``/opt/app/src/provision``. The easiest way to do this is probably to clone your git repository, if you use one.
#. Create an ``env.sh`` file (at ``/opt/app/src/provision/env.sh``) and populate it accordingly.
#. Manually invoke the provisioning bootstrap script **as root**:

    .. code-block:: bash

        $ /opt/app/src/provision/scripts/bootstrap.sh

#. Invoke the :ref:`separate Let's Encrypt configuration script <conf-letsencrypt>` **as root**:

    .. code-block:: bash

        $ /opt/app/src/provision/scripts/letsencrypt.sh email@example.com example.com www.example.com

There are several final steps that automated provisioning does not take care of. This may be because they are unsafe to include in the provisioning process (e.g. in the event of re-provisioning), or because user input is required.

* ``sudo apt-get upgrade`` (see the :ref:`limitations documentation <limitations-apt-get>` for more details)
* In order to have sudo privileges, a password needs to be created for the ``webmaster`` user. When logged in as the ``webmaster`` user, simply run the ``passwd`` command to set a password.
* Run any necessary commands to prepare the project, including:

    * Build commands, e.g. to compile CSS
    * ``manage.py collectstatic``
    * ``manage.py migrate``

.. warning::

    It is a good idea to ensure the sudo password for the ``webmaster`` user is set up and working prior to terminating the ``root`` user session used to run the provisioning scripts. Once the session is terminated, the ``root`` user will :ref:`no longer be able to SSH into the server <feat-users>`. If the ``webmaster`` user does not have a password configured, it will be unable to use sudo commands, and leave much of the server inaccessible.
