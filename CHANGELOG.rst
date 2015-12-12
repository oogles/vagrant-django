==========
Change Log
==========

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
