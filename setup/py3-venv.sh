#!/bin/bash

# Install Python 3.6 module (no user-space python is installed by default on CentOS 8)
# Create python3 virtual environment and install email_validator
# See Redhat docs https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html-single/installing_managing_and_removing_user_space_components/index 
# for background info on new BaseOS vs AppStream concepts.
# See Redhat dev blog https://developers.redhat.com/blog/2018/11/14/python-in-rhel-8/
# for guidelines on using Python in RHEL.
# Python 3 is installed in /usr/bin/, note that this is different from "system-python".

echo Creating Python 3 virtual environment...
hide_output yum --assumeyes --quiet install @python36
inst_dir=/usr/local/lib/mailinabox
mkdir -p $inst_dir
venv=$inst_dir/env
/usr/bin/python3 -m venv /usr/local/lib/mailinabox/env
# Upgrade pip because the CentOS-packaged version is out of date. Install wheel.
hide_output $venv/bin/pip install --upgrade pip || exit 1
hide_output $venv/bin/pip install wheel || exit 1
