============================
Limitations and Restrictions
============================

While various aspects of the provisioned environment are configurable, some are not. The following are some of the limitations and restrictions the provisioning scripts are subject to.


.. _limitations-os:

Target OS
=========

The provisioning scripts have only been tested on Ubuntu Linux, specifically 18.04 Bionic Beaver.

While some versions have been tested in Ubuntu 18.04 production environments (outside of Vagrant), recent and in-development versions will probably only have been tested via Vagrant, using the "bento/ubuntu-18.04" box.


.. _limitations-apt-get:

apt-get upgrade
===============

The provisioning scripts do NOT run ``apt-get upgrade``. They avoid this specifically so that re-provisioning does not trigger updates to installed packages beyond the scope of provisioning (i.e. system packages that provisioning didn't install in the first place).

The scripts *do* run ``apt-get update``, so the packages they do install are the latest repository versions at the time of installation.

.. important::

    It is incumbent on the user to run ``apt-get upgrade``, especially for a newly provisioned system. **This is particularly important in production environments**.


.. _limitations-python:

Python
======

Python (either 2 or 3) is required to be installed on the *unprovisioned* system. This is due to its use generating random strings, which is potentially one of the first things the provisioning scripts do (if ``env.sh`` settings such as ``DB_PASS`` and ``SECRET_KEY`` are not given).


.. _limitations-dir-structure:

Directory structure
===================

The provisioning process creates the ``/opt/app/`` directory to store most things related to the project.

The provisioning scripts and various configuration files expect this directory, and its subdirectories, to exist and contain the relevant files.

See :ref:`feat-dir-structure` for a description of this structure.


.. _limitations-users:

Users
=====

The provisioning process creates a ``webmaster`` user. This is the only user with SSH access and is granted ``sudo`` privileges. See :ref:`the feature documentation <feat-users>` for more details.

The ``webmaster`` user is placed in the ``www-data`` group.

File ownership of almost everything under ``/opt/app/`` is ``www-data:www-data``. Various services, such as nginx and gunicorn, are configured to run under ``www-data``.

.. _limitations-windows:

Windows Hosts
=============

If using `Virtualbox <https://www.virtualbox.org/>`_ as a provider for Vagrant under Windows, the synced folders will be handled by Virtualbox's "shared folders" feature by default. When creating symlinks in this mode, which the provisioning scripts do when installing Node.js (see :ref:`feat-node`), requires Administrator privileges. Specifically, ``vagrant up`` needs to be run from a command prompt with Administrator privileges.

This can be done by right-clicking the command prompt shortcut and choosing "Run as administrator", then running ``vagrant up`` from that command prompt.

Alternatively, the Windows ``.cmd`` script `found here <https://gist.github.com/oogles/a6de0462cfa755013a90>`_ can be used to automatically launch a command prompt with Administrator privileges requested from UAC, opened to a given development directory, ready for ``vagrant`` commands to be issued. See the script's comments for details on usage.
