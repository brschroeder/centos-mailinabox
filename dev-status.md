# Development Status
## Jan 2019
* __Fail2ban:__ copied default mailinabox jail and filter definitons into place but do not start f2b now. Need to verify location of log files, owncloud vs nextcloud etc. _Significant change._

## Dec 2018
* __functions.sh:__ Redefined for CentOS, removed Ubuntu specific items
* __preflight.sh:__ Done
* __randomize.sh:__ Want to start this early in install process so that entropy has chance to build up before using the random number generators to create security keys. _Significant change._
* __questions.sh:__ Created a Python 3 virtual environment and installed into final location /usr/local/lib/mailinabox/env. Will use this exclusively. _Significant change._
* __network-checks.sh:__ Done
* __migrate.py:__ Done but this file has minimal use during a fresh install. Will need to retest for upgrade process.
* __system.sh:__ Done but not able to test timezone checking in Vagrant
* __dns-local.sh:__ Broke this out of system.sh (more logical since this is a key component of cmiab). _Significant change._
* __fail2ban.sh:__ Broke this out of system.sh. Will use Fail2ban's default jail regex's if they exist e.g. Postfix, Dovecot etc. Current jail regex's seem dated...

## Nov 2018
* Working thru the files in order of installation process
* Tracking and (my) understanding of all files is in the file\_dscr.ods spreadsheet
* Setup Vagrant dev environment on Fedora (29)
