=============================
Project-specific Provisioning
=============================

Individual projects will usually require some additional provisioning that isn't included in these generic provisioning scripts. The ``provision/project.sh`` file provides support for this. If found, this shell script file will be executed during the provisioning process. Execution happens:

* after the project directory structure under ``/opt/app/`` is generated, allowing additions to be made to it
* after the ``env.py`` file is written, allowing it to be modified
* before Python and Node.js dependencies are installed, allowing required system libraries to be installed first

Some common uses for ``project.sh`` are:

* installing additional software and services
* altering system configuration files
* modifying the ``env.py`` file with additional generated settings
* generating the necessary media directory structure under ``/opt/app/media/`` (any subdirectories specified in ``FileField``/``ImageField`` ``upload_to`` arguments will need to exist before any upload is attempted)


.. _project-access-settings:

Accessing ``env.sh`` settings
=============================

Any setting present in ``env.sh`` can be loaded into ``project.sh`` and can be used to control the provisioning done within. This includes any custom settings that may be added specifically for this process to use. Simply include the following at the top of the file:

.. code-block:: bash

    source /tmp/env.sh

.. note::

    ``/tmp/env.sh`` is a temporary copy of ``env.sh`` written when provisioning starts, simplifying the provisioning scripts' references to it.


.. _project-rand-str:

Generating random strings
=========================

A helper utility exists for generating random strings, such as those used for passwords. The same utility is used to generate the database password and the Django ``SECRET_KEY`` setting when they are not provided. It uses Python, specifically ``random.SystemRandom().choice()``, to pseudo-randomly generate a string of characters. The length of the string to generate is passed in. The alphabet used is a fixed set of letters, numbers and special characters, with several problem-causing characters excluded (such as quotes).

E.g. Generating a 12 character string:

.. code-block:: bash

    MY_RAND_STR=$("$PROVISION_DIR/scripts/utils/rand_str.sh" 12)

.. note::

    ``$PROVISION_DIR`` is a setting that can be loaded as per :ref:`project-access-settings` above.


.. _project-write-var:

Writing settings back to env.sh
===============================

Sometimes it is useful to write values back to ``env.sh`` so the same value can be read again in the event of re-provisioning. This is particularly important if :ref:`generating random strings <project-rand-str>`. A simple utility exists for doing exactly that. If the given variable name exists in ``env.sh``, it is replaced. If it does not already exist, it is added to the end of the file.

E.g. To write a value stored in ``$MY_VAR`` to a variable called ``SOME_VALUE`` in ``env.sh``:

.. code-block:: bash

    "$PROVISION_DIR/scripts/utils/write_var.sh" 'SOME_VALUE' "$MY_VAR" "$PROVISION_DIR/env.sh"

.. note::

    ``$PROVISION_DIR`` is a setting that can be loaded as per :ref:`project-access-settings` above.


.. _project-example:

Full example
============

The following example demonstrates a custom ``project.sh`` file that:

* loads settings from ``env.sh``
* installs and configures project-specific software - the `RabbitMQ <https://www.rabbitmq.com/>`_ message broker
* generates a random password
* writes the generated password back to ``env.sh``, to avoid generating a new one on re-provisioning
* injects the generated password into ``env.py``, assuming a :ref:`custom template <conf-env-py>`

.. code-block:: bash

    #!/usr/bin/env bash
    # project.sh

    # Source provisioning settings
    source /tmp/env.sh

    #
    # Install and configure RabbitMQ
    #

    # Generate a password if necessary, and write it back to env.sh
    if [[ ! "$RABBIT_PASSWORD" ]]; then
        $RABBIT_PASSWORD=$("$PROVISION_DIR/scripts/utils/rand_str.sh" 12)
        "$PROVISION_DIR/scripts/utils/write_var.sh" '$RABBIT_PASSWORD' "$RABBIT_PASSWORD" "$PROVISION_DIR/env.sh"
    fi

    # Install rabbitmq and create a user with the password
    apt-get -qq install rabbitmq-server
    rabbitmqctl add_user "$PROJECT_NAME" "$RABBIT_PASSWORD"

    # Replace the env.py placeholder for the password
    sed -i -r -e "s|\\\$RABBIT_PASSWORD|$RABBIT_PASSWORD|g" "$SRC_DIR/$PROJECT_NAME/env.py"


