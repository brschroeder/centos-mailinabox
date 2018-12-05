Ubuntu
======
* Ubuntu bionic running on libvirt......build own box? need a script? vagrant-mutate

fuctions.sh
===========

* firewall_allow
    does it permenantly open a port or a service?
    used in these places
    [brett@nuc mailinabox]$ pwd
    /home/brett/mailinabox
    [brett@nuc mailinabox]$ grep ufw_allow ./setup/*
    ./setup/dns.sh:ufw_allow domain
    ./setup/functions.sh:function ufw_allow {
    ./setup/mail-dovecot.sh:ufw_allow imaps
    ./setup/mail-dovecot.sh:ufw_allow pop3s
    ./setup/mail-dovecot.sh:ufw_allow sieve
    ./setup/mail-postfix.sh:ufw_allow smtp
    ./setup/mail-postfix.sh:ufw_allow submission
    ./setup/system.sh:	ufw_allow ssh;
    ./setup/system.sh:	ufw_allow $SSH_PORT #NODOC
    ./setup/web.sh:ufw_allow http
    ./setup/web.sh:ufw_allow https
    [brett@nuc mailinabox]$ grep ufw_allow ./tests/*
    [brett@nuc mailinabox]$ grep ufw_allow ./tools/*
    ./tools/readable_bash.py:	grammar = (ZERO_OR_MORE(SPACE), L("ufw_allow "), REST_OF_LINE, EOL)


