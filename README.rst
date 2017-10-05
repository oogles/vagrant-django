==============
vagrant-django
==============

The building blocks for a `Vagrant <https://www.vagrantup.com/>`_ environment for `Django <https://www.djangoproject.com/>`_ development.

Full documentation is available at: https://vagrant-django.readthedocs.io/.


Features
========

See the `features documentation <https://vagrant-django.readthedocs.io/en/stable/features.html>`_ for details on all available features and when they apply.

Also be sure to check out the `limitations and restrictions <https://vagrant-django.readthedocs.io/en/stable/limitations.html>`_ that apply.

A quick feature overview:

* A secure environment, including locked down SSH access via public key and configurable firewall
* Development aids: git and ag (silver searcher)
* Image libraries used by Pillow
* PostgreSQL, with default database and user
* Nginx and Gunicorn, for production environments
* Supervisor
* Virtualenv, plus installation of Python dependencies
* Node.js and npm, plus installation of Node.js dependencies
* An environment-specific Python settings file
* Per-project customisation options


How to use
==========

#.  Copy the ``provision/`` directory into your project.
#.  Copy the included ``Vagrantfile`` or add ``provision/scripts/bootstrap.sh`` as a shell provisioner in your existing ``Vagrantfile``, specifying the project name. The included ``Vagrantfile`` is pretty basic, but it can be used as a foundation. See `documentation on the Vagrantfile <https://vagrant-django.readthedocs.io/en/stable/config.html#conf-vagrantfile>`_ for details.
#.  Modify the example ``provision/env.sh`` file. See `documentation on the env.sh file <https://vagrant-django.readthedocs.io/en/stable/config.html#conf-env-sh>`_ for details.
#.  Add/modify any further configuration files to ``provision/conf/``. See the `configuration documentation <https://vagrant-django.readthedocs.io/en/stable/config.html>`_ for details on what further customisation options are available.
#.  Add any project-specific provisioning steps to a ``provision/project.sh`` file. See the `project-specific provisioning documentation <https://vagrant-django.readthedocs.io/en/stable/features.html#feat-project-provisioning>`_ for details.
#.  Add ``provision/env.sh`` (and any other necessary config files) to your ``.gitignore`` file, or equivalent. Environment-specific configurations should not be committed to source control.
#. ``vagrant up``

Additional steps may be required in production environments. See `Usage in Production <https://vagrant-django.readthedocs.io/en/stable/production.html>`_ for details.
