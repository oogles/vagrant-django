==============
vagrant-django
==============

The building blocks for a `Vagrant <https://www.vagrantup.com/>`_ environment for `Django <https://www.djangoproject.com/>`_ development.


How to use
==========

#.  Copy the ``provision/`` directory into your project.
#.  Copy the included ``Vagrantfile`` or add ``provision/bootstrap.sh`` as a shell provisioner in your existing ``Vagrantfile``, specifying the project name and build mode. The included ``Vagrantfile`` is pretty basic, but it can be used as a foundation. See :ref:`conf-vagrantfile` for details.
#.  Modify the example ``env.sh`` file in ``provision/config/``. See :ref:`conf-env-sh` for details.
#.  Add further customisation files to ``provision/config/`` if necessary. See :doc:`config` for details on what further customisation options are available.
#.  Add ``provision/config/env.sh`` (and any other necessary config files, such as :ref:`conf-gitconfig`) to your ``.gitignore`` file, or equivalent. Environment-specific configurations should not be committed to source control.
#. ``vagrant up``


.. _build-modes:

Build modes
===========

The provisioning scripts support building the Vagrant guest machine in two slightly different ways:

* "project": For a full Django project. The environment will be suitable for development as well as serving a Django website.
* "app": For a single Django app.

The documentation of the :doc:`available features <features>` indicates which mode each feature applies to - most apply to both. At a glance, the differences are:

* Full project builds install from a ``requirements.txt`` file, if one can be found. App builds simply install a fixed list of :ref:`development aids <feat-dev-aids>`.
* The :ref:`feat-env-py` settings file is written for full project builds only.

Which mode is used is specified by the :ref:`conf-vagrantfile`.


.. _assumptions-dependencies:

Assumptions and dependencies
============================

The provisioning scripts assume:

* The code is shared at ``/vagrant/`` in the Vagrant guest machine.
* If a ``manage.py`` file exists, it will be at ``/vagrant/``. For full projects, this effectively means that the Django project root directory should *be* ``/vagrant/``.
* Full Django projects will have a post-1.4 project structure, having a directory with a name equal to the specified :ref:`project name <conf-var-project-name>` under the project root directory (i.e. in the guest machine: ``/vagrant/<project name>/``).

Several features are only enabled if a ``manage.py`` file is detected:

* Running migrations.
* The :ref:`shortcut commands <feat-commands>`, as they are shortcuts to ``manage.py`` commands.

The shortcut commands also depend on the `django-extensions <https://github.com/django-extensions/django-extensions>`_ app. It will need to be installed for them to work. For full project builds, this means including it in your ``requirements.txt`` file. For single app builds, it is automatically installed among the :ref:`development aids <feat-dev-aids>`.


Further Reading
===============

.. toctree::
   :maxdepth: 2
   
   config
   features
