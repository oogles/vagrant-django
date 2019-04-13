============
Introduction
============

Included are shell provisioning scripts and sample configuration files allowing the construction of a Vagrant guest machine designed to support development of Django projects.

The scripts are also designed to be run independently of Vagrant in order to provision production environments that match those used in development. See :doc:`production`.

While various aspects of the provisioned environment are configurable, some are not. Therefore, it may not be suitable for all projects. In particular, the locations of various important directories (such as the Vagrant synced folder) and the system users used for various tasks are fixed.

Be sure to check out the :doc:`features` and :doc:`limitations` documentation.


How to use
==========

#.  Copy the ``provision/`` directory into your project.
#.  Copy and modify the included ``Vagrantfile`` or make the necessary modifications to an existing ``Vagrantfile``. The included ``Vagrantfile`` is pretty basic, but it can be used as a foundation. See :ref:`conf-vagrantfile` for details.
#.  Modify the example ``provision/env.sh`` file. See :ref:`conf-env-sh` for details.
#.  Add/modify any further configuration files in ``provision/conf/``. See :doc:`config` for details on what further customisation options are available.
#.  Add any project-specific provisioning steps to a ``provision/project.sh`` file. See :doc:`project-provisioning` for details.
#.  Add ``provision/env.sh`` to your ``.gitignore`` file, or equivalent. Environment-specific configurations should not be committed to source control.
#. ``vagrant up``

In production environments, a few additional steps are necessary. See :doc:`production` for details.

.. note::
    When running a Windows host and using VirtualBox shared folders, ``vagrant up`` must be run with Administrator privileges to allow the creation of symlinks in the synced folder. See :ref:`limitations-windows` for details.


Re-provisioning
===============

The provisioning scripts can be re-run on existing environments to update them with any changes.

* Any newly-added provisioning steps will be run.
* Dependency packages will be updated if the specified versions have changed (e.g. in ``requirements.txt`` or ``package.json``).
* Config files in ``provision/conf`` will be re-copied.
* Existing software will NOT be updated (the scripts do not run ``apt-get upgrade``). This step will need to be run manually if required. **Note: This is particularly important when provisioning a new environment.**
* ``env.py`` will NOT be overwritten if it exists. This allows it to be modified as necessary (either changing existing settings or adding new ones) without those changes getting replaced. As such, if the file *needs* rewriting (e.g. provisioning has been updated to change what it writes to ``env.py``), it should be deleted first.
* :ref:`Supervisor <feat-supervisor>` will be reloaded. This, in turn, will stop all processes it is currently running, and restart those configured to start automatically (not necessarily the ones that were running at the time of reprovisioning).


Upgrading
=========

When upgrading to a new version of ``vagrant-django``, do not replace the entire ``provision/`` directory - that will wipe out any customised configuration files. The ``provision/scripts/`` subdirectory is not designed to be customised, so it can safely be replaced as a whole. Modifications/additions to files in other subdirectories will be specified in the `change log <https://github.com/oogles/vagrant-django/blob/master/CHANGELOG.rst>`_, and can be updated individually.
