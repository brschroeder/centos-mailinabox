# Development Status
## Mid-2019
* Ran into many problems trying to get recent versions of applications from Ubuntu 18.04 to run on CentOS 7
* Will switch to CentOS 8 - expected tob be released September 2019 (?)

## Jan 2019
* __Fail2ban:__ copied default mailinabox jail and filter definitons into place but do not start f2b now. Need to verify location of log files, owncloud vs nextcloud etc. _Significant change._
* __ssl.sh:__ Done
* __dns.sh:__ Done
* __mail-postfix.sh:__ Remove postfix v2.10 since it does not support DANE TLS, install version 3.2 from IUS repositories. Removing default postfix had side-effect of removing and stopping fail2ban.....another reason to move fail2ban to end of install process
* __editconf.py:__ Done. Changed hash-bang to python3 virtual environment. Worked perfectly on postfix config files
* __mail-dovecot.sh:__ Done. Needed two new SELinux rules to allow dovecot to bind to TCP 10026 and read /var/log/maillog
* __mail-users.sh:__ Done
* __dkim.sh:__ Done
* __spamassassin.sh:__ In progress...

## Dec 2018
* __functions.sh:__ Redefined for CentOS, removed Ubuntu specific items
* __preflight.sh:__ Done
* __randomize.sh:__ Want to start this early in install process so that entropy has chance to build up before using the random number generators to create security keys. _Significant change._
* __questions.sh:__ Created a Python 3 virtual environment and installed into final location /usr/local/lib/mailinabox/env. Will use this exclusively. _Significant change._
* __network-checks.sh:__ Done
* __migrate.py:__ Done but this file has minimal use during a fresh install. Will need to retest for upgrade process.
* __system.sh:__ Done but not able to test timezone checking in Vagrant
* __dns-local.sh:__ Broke this out of system.sh (more logical since this is a key component of cmiab). _Significant change._
* __fail2ban.sh:__ Broke this out of system.sh. Will use Fail2ban's default jail regex's if they exist e.g. Postfix, Dovecot etc. Current filter regex's seem dated...

## Nov 2018
* Working thru the files in order of installation process
* Tracking and (my) understanding of all files is in the file\_dscr.ods spreadsheet
* Setup Vagrant dev environment on Fedora (29)
