#!/bin/bash

# Create python3 virtual environment and install email_validator
# See https://developers.redhat.com/blog/2018/08/13/install-python3-rhel/ for
# official Redhat recommendations on creating python3 environment
# Examples on CentOS using software-collections-repositiory
# found here https://linuxize.com/post/how-to-install-python-3-on-centos-7/
# Python 3 is installed in /opt/rh/rh-python3X/root/bin

echo Creating Python 3 virtual environment...
inst_dir=/usr/local/lib/mailinabox
mkdir -p $inst_dir
venv=$inst_dir/env
hide_output yum --assumeyes --quiet install centos-release-scl || exit 1
hide_output yum --assumeyes --quiet install rh-python36
/opt/rh/rh-python36/root/bin/python3 -m venv $venv
# Upgrade pip because the CentOS-packaged version is out of date.
hide_output $venv/bin/pip install --upgrade pip || exit 1
