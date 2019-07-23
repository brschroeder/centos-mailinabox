# Ideas/Features Beyond MIAB #

## System ##
* How to know if reboot is required? See yum-utils on RHEL7 or dnf-utils on RHEL8 (probably, this package exists on Fedora 29). This examines running apps but does it capture kernel updates as well? See [here](https://serverfault.com/questions/122178/how-can-i-check-from-the-command-line-if-a-reboot-is-required-on-rhel-or-centos) for an example
* When user restores a backup certain things are missing (secret key used to encrypt backups) and certain things are "duplicated" (details of the Let's Encrypt account, [see this](https://discourse.mailinabox.email/t/multiple-lets-encrypt-accounts-preventing-certificate-from-renewing/4468) which happened when users upgraded from Ubuntu 14.04 to 18.04). Need to ensure that fresh installs, like major OS upgrades or moving to different machines, don't conflict with backups.
* Choose a name but first check existing trademarks on [TESS](http://tmsearch.uspto.gov/bin/gate.exe?f=searchss&state=4801:d3huad.1.1)

## Spam Filtering ##
* Spam filtering should be adaptive i.e. should adapt over time after being trained by user. The user should move flag mails somehow, then spam filter should learn from them and adapt it's behavior. Should this be an a per-user basis or server wide (learning from all users is combined into one pool)?
* What does "autolearn=no autolearn_force=no" in Spam-Status header block actually mean?
* Implement [Postscreen](http://www.postfix.org/POSTSCREEN_README.html) feature in Postfix that uses DNSBL scoring to identify spam bots, black listed IPs etc. See [this](https://github.com/mail-in-a-box/mailinabox/issues/910), and [this](http://rob0.nodns4.us/postscreen.html) and good linux.com review article in two parts, [Part 1](https://www.linux.com/learn/empower-smtp-postscreen-part-1) and [Part 2](https://www.linux.com/learn/how-use-postfix-postscreen-test-email-spam-part-2). A good example of Postfix/postscreen config files is [here](http://rob0.nodns4.us/postscreen.html)
* SpamAssassins scoring based on Baysian probabilities seems low e.g. "0.2 BAYES_999 BODY: Bayes spam probability is 99.9 to 100%" taken from mail headers, means that a message that is >=99.9% probability of being spam is only given a spam score of 0.2 !!!

## SPF ##
* MIAB does not actually block SPF failures on incoming mail. See [this](https://github.com/mail-in-a-box/mailinabox/pull/760) - is this PR actually implemented now or not? Josh recommends using DMARC to block failures, not SPF only [see this](https://discourse.mailinabox.email/t/why-are-these-spoofed-emails-to-myself-not-blocked/4636/9)
* NOTE: SPF will fail if email is forwarded. See [this](https://www.dmarcanalyzer.com/spf/)
* Good explanation of SPF, DKIM and DMARC [here](https://www.linode.com/docs/email/postfix/configure-spf-and-dkim-in-postfix-on-debian-8/)

## IMAP ##
* Implement quotas (even if they are huge), this will limit all disk space being consumed if a user repeatedly receives email with very large attachments. See [this](https://wiki2.dovecot.org/Quota).
* Configure auto-expunge of user's Trash folder so deleted emails don't accumulate indefinitely. This could conflict with setting in a user's MUA, so set the server-side time to something larger than what most people would set in MUA e.g. 60 (90?) days. Details [here](https://wiki2.dovecot.org/MailboxSettings).
* Show mailbox size in control panel, was removed because it was too slow to do in realtime. See [this](https://github.com/mail-in-a-box/mailinabox/commit/c5c413b44725cea033a6b0ffeb3e77c7b447335e). Maybe do this at fixed time each day, save the info into  a temporary file (or database?) and then have the control panel read this file in real time.

## Cloud Integration (NextCloud) ##
* User authentication: currently uses [user_external](https://github.com/nextcloud/user_external/) plugin to authenticate against IMAP. Alternative is to directly authenticate against SQL database, see [user_sql](https://github.com/nextcloud/user_external/) plugin.
* How to configure quota for user's files? Does this include email messages?
* Plugins currently used: user_external, calendar, contacts. Add to this an email plugin and then it is a one-stop shop for a complete personal cloud service i.e. file synchronization and email with contacts and calendars!
