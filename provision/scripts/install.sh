#!/usr/bin/env bash

echo " "
echo " --- Install stuff ---"

# Install git and ag
apt-get -qq install git silversearcher-ag

# Install various image processing libraries, namely for Pillow.
# Pillow itself is not installed - if necessary, it should be listed in requirements.txt.
# But a Django project is highly likely to use it, so these are included.
# See http://pillow.readthedocs.io/en/3.0.x/installation.html#external-libraries

# Exact packages taken from:
# https://github.com/python-pillow/Pillow/blob/master/depends/ubuntu_14.04.sh
# (not all are installed)

apt-get -qq install libtiff5-dev libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev

echo "Done"
