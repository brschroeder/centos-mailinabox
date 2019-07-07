# Ideas/Features Beyond MIAB #

## System ##
* How to know if reboot is required? See yum-utils on RHEL7 or dnf-utils on RHEL8 (probably, this package exists on Fedora 29). This examines running apps but does it capture kernel updates as well? See [here](https://serverfault.com/questions/122178/how-can-i-check-from-the-command-line-if-a-reboot-is-required-on-rhel-or-centos) for an example

## Spam Filtering ##
* Spam filtering should be adaptive i.e. should adapt over time after being trained by user. The user should move flag mails somehow, then spam filter should learn from them and adapt it's behavior. Should this be an a per-user basis or server wide (learning from all users is combined into one pool)?
* What does "autolearn=no autolearn_force=no" in Spam-Status header block actually mean?
* Implement [Postscreen](http://www.postfix.org/POSTSCREEN_README.html) feature in Postfix that uses DNSBL scoring to identify spam bots, black listed IPs etc. See [this](https://github.com/mail-in-a-box/mailinabox/issues/910), and [this](http://rob0.nodns4.us/postscreen.html) and good linux.com review article in two parts, [Part 1](https://www.linux.com/learn/empower-smtp-postscreen-part-1) and [Part 2](https://www.linux.com/learn/how-use-postfix-postscreen-test-email-spam-part-2). A good example of Postfix/postscreen config files is [her](http://rob0.nodns4.us/postscreen.html)
* SpamAssassins scoring based on Baysian probabilities seems low e.g. "0.2 BAYES_999 BODY: Bayes spam probability is 99.9 to 100%" taken from mail headers, means that a message that is >=99.9% probability of being spam is only given a spam score of 0.2 !!!

## SPF ##
* MIAB does not actually block SPF failures on incoming mail. See [this](https://github.com/mail-in-a-box/mailinabox/pull/760) - is this PR actually implemented now or not?
* NOTE: SPF will fail if email is forwarded. See [this](https://www.dmarcanalyzer.com/spf/)
* Good explanation of SPF, DKIM and DMARCH [here](https://www.linode.com/docs/email/postfix/configure-spf-and-dkim-in-postfix-on-debian-8/)

## IMAP ##
* Implement quotas (even if they are huge), this will limit all disk space being consumed if a user repeatedly receives email with very large attachments. See [this](https://wiki2.dovecot.org/Quota).
