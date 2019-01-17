#!/bin/bash
#
# Dovecot (IMAP/POP and LDA)
# ----------------------
#
# Dovecot is *both* the IMAP/POP server (the protocol that email applications
# use to query a mailbox) as well as the local delivery agent (LDA),
# meaning it is responsible for writing emails to mailbox storage on disk.
# You could imagine why these things would be bundled together.
#
# As part of local mail delivery, Dovecot executes actions on incoming
# mail as defined in a "sieve" script.
#
# Dovecot's LDA role comes after spam filtering. Postfix hands mail off
# to Spamassassin which in turn hands it off to Dovecot. This all happens
# using the LMTP protocol.

source setup/functions.sh # load our functions
source /etc/mailinabox.conf # load global vars


# Install packages for dovecot. These are all core dovecot plugins,
# but dovecot-lucene is packaged by *us* in the Mail-in-a-Box PPA,
# not by Ubuntu.

echo "Installing Dovecot (IMAP server)..."
hide_output yum --quiet --assumeyes install dovecot dovecot-pigeonhole


# Set basic daemon options.

# The `default_process_limit` is 100, which constrains the total number
# of active IMAP connections (at, say, 5 open connections per user that
# would be 20 users). Set it to 250 times the number of cores this
# machine has, so on a two-core machine that's 500 processes/100 users).
# The `default_vsz_limit` is the maximum amount of virtual memory that
# can be allocated. It should be set *reasonably high* to avoid allocation
# issues with larger mailboxes. We're setting it to 1/3 of the total
# available memory (physical mem + swap) to be sure.
# See here for discussion:
# - https://www.dovecot.org/list/dovecot/2012-August/137569.html
# - https://www.dovecot.org/list/dovecot/2011-December/132455.html
tools/editconf.py /etc/dovecot/conf.d/10-master.conf \
	default_process_limit=$(echo "`nproc` * 250" | bc) \
	default_vsz_limit=$(echo "`free -tm  | tail -1 | awk '{print $2}'` / 3" | bc)M \
	log_path=/var/log/maillog

# The inotify `max_user_instances` default is 128, which constrains
# the total number of watched (IMAP IDLE push) folders by open connections.
# See http://www.dovecot.org/pipermail/dovecot/2013-March/088834.html.
# A reboot is required for this to take effect (which we don't do as
# as a part of setup). Test with `cat /proc/sys/fs/inotify/max_user_instances`.
tools/editconf.py /etc/sysctl.conf \
	fs.inotify.max_user_instances=1024

# Set the location where we'll store user mailboxes. '%d' is the domain name and '%n' is the
# username part of the user's email address. We'll ensure that no bad domains or email addresses
# are created within the management daemon.
tools/editconf.py /etc/dovecot/conf.d/10-mail.conf \
	mail_location=maildir:$STORAGE_ROOT/mail/mailboxes/%d/%n \
	mail_privileged_group=mail \
	first_valid_uid=0

# Create, subscribe, and mark as special folders: INBOX, Drafts, Sent, Trash, Spam and Archive.
cp conf/dovecot-mailboxes.conf /etc/dovecot/conf.d/15-mailboxes.conf

# ### IMAP/POP

# Require that passwords are sent over SSL only, and allow the usual IMAP authentication mechanisms.
# The LOGIN mechanism is supposedly for Microsoft products like Outlook to do SMTP login (I guess
# since we're using Dovecot to handle SMTP authentication?).
tools/editconf.py /etc/dovecot/conf.d/10-auth.conf \
	disable_plaintext_auth=yes \
	"auth_mechanisms=plain login"

# Enable SSL, specify the location of the SSL certificate and private key files.
# Disable obsolete SSL protocols and allow only good ciphers per http://baldric.net/2013/12/07/tls-ciphers-in-postfix-and-dovecot/.
# Enable strong ssl dh parameters
tools/editconf.py /etc/dovecot/conf.d/10-ssl.conf \
	ssl=required \
	"ssl_cert=<$STORAGE_ROOT/ssl/ssl_certificate.pem" \
	"ssl_key=<$STORAGE_ROOT/ssl/ssl_private_key.pem" \
	"ssl_protocols=!SSLv3 !SSLv2" \
	"ssl_cipher_list=ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS" \
	"ssl_prefer_server_ciphers = yes" \
	"ssl_dh_parameters_length = 2048"

# Disable in-the-clear IMAP/POP because there is no reason for a user to transmit
# login credentials outside of an encrypted connection. Only the over-TLS versions
# are made available (IMAPS on port 993; POP3S on port 995).
sed -i "s/#port = 143/port = 0/" /etc/dovecot/conf.d/10-master.conf
sed -i "s/#port = 110/port = 0/" /etc/dovecot/conf.d/10-master.conf

# Make IMAP IDLE slightly more efficient. By default, Dovecot says "still here"
# every two minutes. With K-9 mail, the bandwidth and battery usage due to
# this are minimal. But for good measure, let's go to 4 minutes to halve the
# bandwidth and number of times the device's networking might be woken up.
# The risk is that if the connection is silent for too long it might be reset
# by a peer. See [#129](https://github.com/mail-in-a-box/mailinabox/issues/129)
# and [How bad is IMAP IDLE](http://razor.occams.info/blog/2014/08/09/how-bad-is-imap-idle/).
tools/editconf.py /etc/dovecot/conf.d/20-imap.conf \
	imap_idle_notify_interval="4 mins"

# Set POP3 UIDL.
# UIDLs are used by POP3 clients to keep track of what messages they've downloaded.
# For new POP3 servers, the easiest way to set up UIDLs is to use IMAP's UIDVALIDITY
# and UID values, the default in Dovecot.
tools/editconf.py /etc/dovecot/conf.d/20-pop3.conf \
	pop3_uidl_format="%08Xu%08Xv"

# ### LDA (LMTP)

# Enable Dovecot's LDA service with the LMTP protocol. It will listen
# on port 10026, and Spamassassin will be configured to pass mail there.
#
# The disabled unix socket listener is normally how Postfix and Dovecot
# would communicate (see the Postfix setup script for the corresponding
# setting also commented out).
#
# Also increase the number of allowed IMAP connections per mailbox because
# we all have so many devices lately.
cat > /etc/dovecot/conf.d/99-local.conf << EOF;
service lmtp {
  #unix_listener /var/spool/postfix/private/dovecot-lmtp {
  #  user = postfix
  #  group = postfix
  #}
  inet_listener lmtp {
    address = 127.0.0.1
    port = 10026
  }
}

protocol imap {
  mail_max_userip_connections = 20
}
EOF

# Setting a `postmaster_address` is required or LMTP won't start. An alias
# will be created automatically by our management daemon.
tools/editconf.py /etc/dovecot/conf.d/15-lda.conf \
	postmaster_address=postmaster@$PRIMARY_HOSTNAME

# ### Sieve

# Enable the Dovecot sieve plugin which let's users run scripts that process
# mail as it comes in.
sed -i "s/#mail_plugins = .*/mail_plugins = \$mail_plugins sieve/" /etc/dovecot/conf.d/20-lmtp.conf

# Configure sieve. We'll create a global script that moves mail marked
# as spam by Spamassassin into the user's Spam folder.
#
# * `sieve_before`: The path to our global sieve which handles moving spam to the Spam folder.
#
# * `sieve_before2`: The path to our global sieve directory for sieve which can contain .sieve files
# to run globally for every user before their own sieve files run.
#
# * `sieve_after`: The path to our global sieve directory which can contain .sieve files
# to run globally for every user after their own sieve files run.
#
# * `sieve`: The path to the user's main active script. ManageSieve will create a symbolic
# link here to the actual sieve script. It should not be in the mailbox directory
# (because then it might appear as a folder) and it should not be in the sieve_dir
# (because then I suppose it might appear to the user as one of their scripts).
# * `sieve_dir`: Directory for :personal include scripts for the include extension. This
# is also where the ManageSieve service stores the user's scripts.
cat > /etc/dovecot/conf.d/99-local-sieve.conf << EOF;
plugin {
  sieve_before = /etc/dovecot/sieve-spam.sieve
  sieve_before2 = $STORAGE_ROOT/mail/sieve/global_before
  sieve_after = $STORAGE_ROOT/mail/sieve/global_after
  sieve = $STORAGE_ROOT/mail/sieve/%d/%n.sieve
  sieve_dir = $STORAGE_ROOT/mail/sieve/%d/%n
}
EOF


# Copy the global sieve script into where we've told Dovecot to look for it. Then
# compile it. Global scripts must be compiled now because Dovecot won't have
# permission later.
cp conf/sieve-spam.txt /etc/dovecot/sieve-spam.sieve
sievec /etc/dovecot/sieve-spam.sieve

# PERMISSIONS

# fix SELinux ACLs recursively on entire directory
restorecon -F -r /etc/dovecot/


# Ensure configuration files are owned by dovecot and not world readable.
chown -R mail:dovecot /etc/dovecot
chmod -R o-rwx /etc/dovecot

# Ensure mailbox files have a directory that exists and are owned by the mail user.
mkdir -p $STORAGE_ROOT/mail/mailboxes
chown -R mail.mail $STORAGE_ROOT/mail/mailboxes

# Same for the sieve scripts.
mkdir -p $STORAGE_ROOT/mail/sieve
mkdir -p $STORAGE_ROOT/mail/sieve/global_before
mkdir -p $STORAGE_ROOT/mail/sieve/global_after
chown -R mail.mail $STORAGE_ROOT/mail/sieve

# Allow the IMAP/POP ports in the firewall.
hide_output firewall-cmd --quiet --permanent --add-service=imaps
hide_output firewall-cmd --quiet --permanent --add-service=pop3s

# Allow the Sieve port in the firewall.
hide_output firewall-cmd --permanent --add-service=managesieve

# Reload firewall config
hide_output systemctl --quiet reload firewalld


# Enable and restart services but first need to create a SELinux rule to allow 
# dovecot to bind to tcp port 10026
hide_output systemctl --quiet enable dovecot
cat > /tmp/dovecot-tcp-10026.te << EOF;

module dovecot-tcp-10026 1.0;

require {
	type dovecot_t;
	type spamd_port_t;
	class tcp_socket name_bind;
}

#============= dovecot_t ==============
allow dovecot_t spamd_port_t:tcp_socket name_bind;
EOF

hide_output checkmodule -M -m -o /tmp/dovecot-tcp-10026.mod /tmp/dovecot-tcp-10026.te
hide_output semodule_package -o /tmp/dovecot-tcp-10026.pp -m /tmp/dovecot-tcp-10026.mod
hide_output semodule -i /tmp/dovecot-tcp-10026.pp
rm -f /tmp/dovecot-tcp-10026.*

# SELinux rule to allow dovecot acces to /var/log/maillog
cat > /tmp/dovecot-var-log.te << EOF;

module dovecot-var-log 1.0;

require {
	type var_log_t;
	type dovecot_t;
	class file open;
}

#============= dovecot_t ==============
allow dovecot_t var_log_t:file open;
EOF

hide_output checkmodule -M -m -o /tmp/dovecot-var-log.mod /tmp/dovecot-var-log.te
hide_output semodule_package -o /tmp/dovecot-var-log.pp -m /tmp/dovecot-var-log.mod
hide_output semodule -i /tmp/dovecot-var-log.pp
rm -f /tmp/dovecot-var-log.*

hide_output systemctl --quiet start dovecot
