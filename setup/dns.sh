#!/bin/bash
# DNS
# -----------------------------------------------

# This script installs packages, but the DNS zone files are only
# created by the /dns/update API in the management server because
# the set of zones (domains) hosted by the server depends on the
# mail users & aliases created by the user later.

source setup/functions.sh # load our functions
source /etc/mailinabox.conf # load global vars

# Install the packages.
#
# * nsd: The non-recursive nameserver that publishes our DNS records.
# * openssh-client: Provides ssh-keyscan which we use to create SSHFP records.
echo "Installing nsd (DNS server)..."

# *********************** REMOVE AFTER NSD IN EPEL 2019-10-26
sed -i '/^#.* /s/^#\ //' /etc/yum.repos.d/epel-testing.repo
dnf config-manager --set-enabled epel-testing

hide_output yum --assumeyes --quiet install nsd


# *********************** REMOVE AFTER NSD IN EPEL 2019-10-26
dnf config-manager --disable epel-testing

# Prepare nsd's configuration.

# not needed on CentOS. Dir is created on install and owned by nsd:nsd
# mkdir -p /var/run/nsd

cat > /etc/nsd/server.d/nsd-cmiab.conf << EOF;
# Do not edit. Overwritten by CentOS-Mail-in-a-Box setup.
server:
  hide-version: yes
  logfile: "/var/log/nsd.log"

  # identify the server (CH TXT ID.SERVER entry).
  identity: ""

  # The directory for zonefile: files.
  zonesdir: "/etc/nsd/zones"

  # Allows NSD to bind to IP addresses that are not (yet) added to the
  # network interface. This allows nsd to start even if the network stack
  # isn't fully ready, which apparently happens in some cases.
  # See https://www.nlnetlabs.nl/projects/nsd/nsd.conf.5.html.
  ip-transparent: yes

EOF

# Add log rotation
cat > /etc/logrotate.d/nsd <<EOF;
/var/log/nsd.log {
  weekly
  missingok
  rotate 12
  compress
  delaycompress
  notifempty
}
EOF

# Since we have bind9 listening on localhost for locally-generated
# DNS queries that require a recursive nameserver, and the system
# might have other network interfaces for e.g. tunnelling, we have
# to be specific about the network interfaces that nsd binds to.
for ip in $PRIVATE_IP $PRIVATE_IPV6; do
	echo "  ip-address: $ip" >> /etc/nsd/server.d/nsd-cmiab.conf;
done

echo "include: /etc/nsd/zones.conf" >> /etc/nsd/server.d/nsd-cmiab.conf;

# Create DNSSEC signing keys.

mkdir -p "$STORAGE_ROOT/dns/dnssec";

# TLDs don't all support the same algorithms, so we'll generate keys using a few
# different algorithms. RSASHA1-NSEC3-SHA1 was possibly the first widely used
# algorithm that supported NSEC3, which is a security best practice. However TLDs
# will probably be moving away from it to a a SHA256-based algorithm.
#
# Supports `RSASHA1-NSEC3-SHA1` (didn't test with `RSASHA256`):
#
#  * .info
#  * .me
#
# Requires `RSASHA256`
#
#  * .email
#  * .guide
#
# Supports `RSASHA256` (and defaulting to this)
#
#  * .fund

FIRST=1 #NODOC
for algo in NSEC3RSASHA1 RSASHA256; do
if [ ! -f "$STORAGE_ROOT/dns/dnssec/$algo.conf" ]; then
	if [ $FIRST == 1 ]; then
		echo "Generating DNSSEC signing keys..."
		FIRST=0 #NODOC
	fi

	# Create the Key-Signing Key (KSK) (with `-f KSK`) which is the so-called
	# Secure Entry Point. The domain name we provide ("_domain_") doesn't
	#  matter -- we'll use the same keys for all our domains.
	#
	# `dnssec-keygen` outputs the new key's filename to stdout, which
	# we're capturing into the `KSK` variable.
	#
	# dnssec-keygen uses /dev/random for generating random numbers by default.
	# This is slow and unecessary if we ensure /dev/urandom is seeded properly,
	# so we use /dev/urandom. See randomize.sh for an explanation. See #596, #115.

    if [ $algo == NSEC3RSASHA1 ]; then
        DIGEST_ALGO=-1
    elif [ $algo == RSASHA256 ]; then
        DIGEST_ALGO=-2
    else
        echo "Unknown digest algorithm...."
        exit 1
    fi

    KSK=$(umask 077; cd $STORAGE_ROOT/dns/dnssec; dnssec-keygen -q -r /dev/urandom -a $algo -b 2048 -f KSK _domain_);
    umask 077; dnssec-dsfromkey $DIGEST_ALGO $STORAGE_ROOT/dns/dnssec/$KSK > $STORAGE_ROOT/dns/dnssec/$KSK.ds

    # Now create a Zone-Signing Key (ZSK) which is expected to be
	# rotated more often than a KSK, although we have no plans to
	# rotate it (and doing so would be difficult to do without
	# disturbing DNS availability.) Drop `-f KSK` and use a shorter key length.

    ZSK=$(umask 077; cd $STORAGE_ROOT/dns/dnssec; dnssec-keygen -q -r /dev/urandom -a $algo -b 1024 _domain_);
    umask 077; dnssec-dsfromkey $DIGEST_ALGO $STORAGE_ROOT/dns/dnssec/$ZSK > $STORAGE_ROOT/dns/dnssec/$ZSK.ds


    # These generate two sets of files like:
	#
	# * `K_domain_.+007+08882.ds`: DS record normally provided to domain name registrar
    #       (but it's actually invalid with `_domain_`)
	# * `K_domain_.+007+08882.key`: public key
	# * `K_domain_.+007+08882.private`: private key (secret!)

	# The filenames are unpredictable and encode the key generation
	# options. So we'll store the names of the files we just generated.
	# We might have multiple keys down the road. This will identify
	# what keys are the current keys.
	cat > $STORAGE_ROOT/dns/dnssec/$algo.conf << EOF;
KSK=$KSK
ZSK=$ZSK
EOF
fi

	# And loop to do the next algorithm...
done

# Force the dns_update script to be run every day to re-sign zones for DNSSEC
# before they expire. When we sign zones (in `dns_update.py`) we specify a
# 30-day validation window, so we had better re-sign before then.
cat > /etc/cron.daily/mailinabox-dnssec << EOF;
#!/bin/bash
# CentOS-Mail-in-a-Box
# Re-sign any DNS zones with DNSSEC because the signatures expire periodically.
`pwd`/tools/dns_update
EOF
chmod +x /etc/cron.daily/mailinabox-dnssec

# Permit DNS queries on TCP/UDP in the firewall.
hide_output firewall-cmd --quiet --permanent --add-service=dns
hide_output systemctl --quiet reload firewalld
