============
Introduction
============

Included are shell provisioning scripts and sample configuration files allowing the construction of a Vagrant guest machine designed to support either full Django projects (both development and production environments) and the development of single Django apps for packaging and distrubution.

The provisioning scripts are idempotent. Re-running the provisioner will not reinstall programs or overwrite config files that already exist, but will update anything where necessary. Therefore, it is safe to run the provisioner on an already established guest machine to perform updates.

.. _build-modes:

Build modes
===========

The provisioning scripts support building the Vagrant guest machine in two slightly different ways:

* "project": For a full Django project. The environment will be suitable for development as well as serving a Django website.
* "app": For a single Django app.

The documentation of the :doc:`available features <features>` indicates which mode each feature applies to - most apply to both. At a glance, the differences are:

* Full project builds install Python dependencies from a ``requirements.txt`` file, if one can be found. See :ref:`feat-py-dependencies` for details.
* The :ref:`feat-env-py` settings file is written for full project builds only.
* App builds always set the :ref:`DEBUG <conf-var-debug>` flag to ``1``.

Which mode is used is specified by the :ref:`conf-vagrantfile`.


.. _assumptions-dependencies:

Assumptions and dependencies
============================

The provisioning scripts assume:

* The guest machine is Ubuntu.
* The code is synced to ``/vagrant/`` in the Vagrant guest machine.
* If a ``manage.py`` file exists, it will be at ``/vagrant/``. For full projects, this effectively means that the Django project root directory should *be* ``/vagrant/``.
* Full Django projects will have a post-1.4 project structure, having a directory with a name equal to the specified :ref:`project name <conf-var-project-name>` under the project root directory (i.e. in the guest machine: ``/vagrant/<project name>/``).

Several features are only enabled if a ``manage.py`` file is detected:

* Running migrations.
* The :ref:`shortcut commands <feat-commands>`, as they are shortcuts to ``manage.py`` commands.

The shortcut commands also depend on the `django-extensions <https://github.com/django-extensions/django-extensions>`_ app. It will need to be installed for them to work. This means including it in either your ``requirements.txt`` or ``dev_requirements.txt`` file (see :ref:`feat-py-dependencies`).

.. _assumptions-dependencies-windows:

Windows hosts
-------------

If using `Virtualbox <https://www.virtualbox.org/>`_ as a provider for Vagrant under Windows, the synced folders will be handled by Virtualbox's shared folders feature by default. When creating symlinks in this mode, which the provisioning scripts do when installing Node.js (see :ref:`feat-node`), requires Administrator privileges. Specifically, ``vagrant up`` needs to be run from a command prompt with Administrator privileges.

This can be done by right-clicking the command prompt shortcut and choosing "Run as administrator", then running ``vagrant up`` from that command prompt.

Alternatively, the Windows ``.cmd`` script `found here <https://gist.github.com/oogles/a6de0462cfa755013a90>`_ can be used to automatically launch a command prompt with Administrator privileges requested from UAC, opened to a given development directory, ready for ``vagrant`` commands to be issued. See the script's comments for details on usage.


How to use
==========

#.  Copy the ``provision/`` directory into your project.
#.  Copy the included ``Vagrantfile`` or add ``provision/scripts/bootstrap.sh`` as a shell provisioner in your existing ``Vagrantfile``, specifying the project name and build mode. The included ``Vagrantfile`` is pretty basic, but it can be used as a foundation. See :ref:`conf-vagrantfile` for details.
#.  Modify the example ``provision/env.sh`` file. See :ref:`conf-env-sh` for details.
#.  Add any project-specific provisioning steps to a ``provision/project.sh`` file. See :ref:`feat-project-provisioning` for details.
#.  Add any further configuration files to ``provision/conf/``. See :ref:`conf-user-config` for details on how these files are applied.
#.  Add ``provision/env.sh`` (and any other necessary config files) to your ``.gitignore`` file, or equivalent. Environment-specific configurations should not be committed to source control.
#. ``vagrant up``

.. note::
    When running a Windows host and using VirtualBox shared folders, ``vagrant up`` must be run with Administrator privileges to allow the creation of symlinks in the synced folder. See :ref:`assumptions-dependencies-windows` for details.
