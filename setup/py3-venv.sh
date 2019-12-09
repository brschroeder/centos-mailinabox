#!/bin/bash

# Create Python 3 virtual environment
# For guidelines on using Python in RHEL see the official docs here
#       https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html-single/installing_managing_and_removing_user_space_components/index
# For background info on new BaseOS vs AppStream concepts, see this Redhat dev blog
#       https://developers.redhat.com/blog/2018/11/14/python-in-rhel-8/
# Install Python 3.6 module (no user-space python is installed by default on CentOS 8)
# Python 3 is installed in /usr/bin/, note that this is different from "system-python".
# Our virtual environment is installed in /usr/local/lib/mailinabox/env

echo Creating Python 3 virtual environment...
hide_output yum --assumeyes --quiet install @python36
inst_dir=/usr/local/lib/mailinabox
mkdir -p $inst_dir
venv=$inst_dir/env
/usr/bin/python3 -m venv /usr/local/lib/mailinabox/env
# Upgrade pip because the CentOS-packaged version is out of date. Install wheel.
hide_output $venv/bin/pip install --upgrade pip || exit 1
hide_output $venv/bin/pip install wheel || exit 1
