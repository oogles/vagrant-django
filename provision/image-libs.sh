#!/usr/bin/env bash

echo " "
echo " --- Image libraries ---"

# Install various image processing libraries, namely for Pillow.
# Pillow itself is not installed - if necessary, it should be listed in requirements.txt.
# But a Django project is highly likely to use it, so these are included.
# See http://pillow.readthedocs.org/en/3.0.x/installation.html#external-libraries

# Exact packages taken from:
# https://github.com/python-pillow/Pillow/blob/master/depends/ubuntu_14.04.sh
# (not all are installed)

apt-get -y install libtiff5-dev libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev
