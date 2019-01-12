#!/bin/bash
# Fail2Ban Service
# ---------------------------------------------------------------

# Version in EPEL is 0.9.7 but this does NOT support IPV6
# Version in Fedora is 0.10.4 which does support IPV6
# See https://github.com/fail2ban/fail2ban/tree/0.10
# Stick with EPEL version since RPM for CentOS already exists.
# Extension to include IPv6 blocking left as future project.

source setup/functions.sh # load our functions

yum --assumeyes --quiet install fail2ban

# Configure the Fail2Ban installation to prevent dumb bruce-force attacks 
# against dovecot, postfix, ssh, etc.
cat conf/fail2ban/jails.conf \
        | sed "s/PUBLIC_IP/$PUBLIC_IP/g" \
        | sed "s#STORAGE_ROOT#$STORAGE_ROOT#" \
        > /etc/fail2ban/jail.d/mailinabox.conf
cp -f conf/fail2ban/filter.d/* /etc/fail2ban/filter.d/

# On first installation, the log files that the jails look at don't all exist.
# e.g., The roundcube error log isn't normally created until someone logs into
# Roundcube for the first time. This causes fail2ban to fail to start. Later
# scripts will ensure the files exist and then fail2ban is given another
# restart at the very end of setup.

# #########################
#
# DON'T START FAIL2BAN NOW
# 
##########################

#restart_service fail2ban

