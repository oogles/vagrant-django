==========
Change Log
==========

0.4
=====

* Added provisioning for supervisor.
* Added provisioning for gunicorn as a production application server for Django, managed by supervisor.
* Added provisioning for nginx as a reverse proxy to gunicorn, managed by supervisor.
* Added provisioning for firewall rules via ufw.

0.3.2
=====

* Fixed bug creating the ``node_modules`` symlink in some Windows environments.

0.3.1
=====

* Fixed bug referencing ``DEBUG`` in ``provision/scripts/node-npm.sh``.

0.3
===

* Updated ``provision/`` directory structure.
* Added support for project-specific provisioning.
* Updated copy of specific configuration files in ``provision/config/`` to copy of all configuration files in ``provision/conf/``.
* Updated Node.js/npm to install when ``DEBUG`` is set or not. Will use ``npm install --production`` when not set.
* Updated Node.js/npm to install only if a package.json file is present.
* Added provisioning for several of the image libraries Pillow requires for some of its features.
* Updated "app" build mode to always set ``DEBUG``.

0.2.3
=====

* Fixed #3: No permission to create test databases.
* Made env.py file accessible only to the owner (vagrant), at least in certain situations.

0.2.2
=====

* Fixed #2: root ownership of node_modules/.bin.

0.2.1
=====

* Fixed #1: Installing psycopg2 via ``requirements.txt`` or ``dev_requirements.txt`` before Postgres was installed caused the ``pip install -r`` to fail.

0.2
===

* Added provisioning for node.js/npm, and detection of a ``package.json``, for development environments.
* Fixed bug writing shortcut scripts.
* Added provisioning for the silver searcher (ag).
* Renamed ``env.sh`` setting ``TIMEZONE`` to ``TIME_ZONE``, and added to ``env.py``.
