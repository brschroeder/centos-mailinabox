CentOS-Mail-in-a-Box
======================

## NOTE: Project is on hold waiting for CentOS v8.0 release (expected around Sept 2019)


This is an attempt to port the Mail-in-a-Box project from Ubuntu to Centos. The home page of the original Ubuntu project is [here](https://mailinabox.email) and the code on Github is [here](https://github.com/mail-in-a-box/mailinabox).

Current development status/log is [here.](dev-status.md)

The goals of this project are the same as the original project

* Make deploying a good mail server easy.
* Promote [decentralization](http://redecentralize.org/), innovation, and privacy on the web.
* Have automated, auditable, and [idempotent](https://sharknet.us/2014/02/01/automated-configuration-management-challenges-with-idempotency/) configuration.
* **Not** make a totally unhackable, NSA-proof server.
* **Not** make something customizable by power users.
* Do it all on CentOS 7 with Security Enhanced Linux (SELinux) providing an additional layer of protection

The Box
-------

CentOS-Mail-in-a-Box will one day turn a fresh CentOS 7 64-bit machine into a working mail server by installing and configuring various components.

It is a one-click email appliance. There are no user-configurable setup options. It "just works".

The components installed are:

* SMTP ([postfix](http://www.postfix.org/)), IMAP ([dovecot](http://dovecot.org/)), CardDAV/CalDAV ([Nextcloud](https://nextcloud.com/)), Exchange ActiveSync ([z-push](http://z-push.org/))
* Webmail ([Roundcube](http://roundcube.net/)), static website hosting ([nginx](http://nginx.org/))
* Spam filtering ([spamassassin](https://spamassassin.apache.org/)), greylisting ([postgrey](http://postgrey.schweikert.ch/))
* DNS ([nsd4](https://www.nlnetlabs.nl/projects/nsd/)) with [SPF](https://en.wikipedia.org/wiki/Sender_Policy_Framework), DKIM ([OpenDKIM](http://www.opendkim.org/)), [DMARC](https://en.wikipedia.org/wiki/DMARC), [DNSSEC](https://en.wikipedia.org/wiki/DNSSEC), [DANE TLSA](https://en.wikipedia.org/wiki/DNS-based_Authentication_of_Named_Entities), and [SSHFP](https://tools.ietf.org/html/rfc4255) records automatically set
* Backups ([duplicity](http://duplicity.nongnu.org/)), firewall (firewalld), intrusion protection ([fail2ban](http://www.fail2ban.org/wiki/index.php/Main_Page)), system monitoring ([munin](http://munin-monitoring.org/))

It also includes:

* A control panel and API for adding/removing mail users, aliases, custom DNS records, etc. and detailed system monitoring.

For more information on how Mail-in-a-Box handles your privacy, see the [security details page](security.md).

Eventually tags/releases/commits will be crytographicall signed.My PGP key can be found on most key servers but you can get it directly from the MIT PGP system [here](http://pgp.mit.edu/pks/lookup?op=get&search=0x3A5877D361D6D391), or the PGP Public Key Server [here](https://pgp.key-server.io/0x3A5877D361D6D391) or look them up directly using "brett dot schroeder at gmail dot com". The key is self-signed but the fingerprint is

    $ gpg --fingerprint 61D6D391
      Key fingerprint = 4FA3 9DA3 636B 5902 175D  4419 3A58 77D3 61D6 D391


