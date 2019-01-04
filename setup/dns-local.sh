#!/bin/bash
# Local DNS Service
# ---------------------------------------------------------------

source setup/functions.sh # load our functions

# Install a local recursive DNS server --- i.e. for DNS queries made by
# local services running on this machine.
#
# (This is unrelated to the box's public, non-recursive DNS server that
# answers remote queries about domain names hosted on this box. For that
# see dns.sh.)
#
# By default CentOS does not run any name resolution service locally. All 
# requests are relayed to any upstream servers listed in /etc/resolv.conf. 
# This means that DNSSEC may not be used in all DNS queries.
#
# This won't work for us for three reasons.
#
# 1) We have higher security goals --- we want DNSSEC to be enforced on all
#    DNS queries (some upstream DNS servers do, some don't).
# 2) We will configure postfix to use DANE, which uses DNSSEC to find TLS
#    certificates for remote servers. DNSSEC validation *must* be performed
#    locally because we can't trust an unencrypted connection to an external
#    DNS server.
# 3) DNS-based mail server blacklists (RBLs) typically block large ISP
#    DNS servers because they only provide free data to small users. Since
#    we use RBLs to block incoming mail from blacklisted IP addresses,
#    we have to run our own DNS server. See #1424.
#
# So we really need a local recursive nameserver.
#
# We'll install bind aka named, which has DNSSEC enabled by default via 
# "dnssec-enable yes"and "dnssec-validation yes" in /etc/named.conf
# We'll have it be bound to 127.0.0.1 so that it does not interfere with
# the public, recursive nameserver `nsd` bound to the public ethernet interfaces.
#
# About the settings:
#
# * Adding -4 to OPTIONS will have `bind9` not listen on IPv6 addresses
#   so that we're sure there's no conflict with nsd, our public domain
#   name server, on IPV6. This will also stop the management server (rndc)
#   listening on :::953 (management service will still listen on 127.0.0.1:953)
# * The listen-on directive in named.conf restricts `bind9` to
#   binding to the loopback interface instead of all interfaces.
#
# optional: add "querylog yes;" to the options section of /etc/named.conf.
# This will log all DNS queries in /var/log/messages

echo "Installing local DNS server..."
hide_output yum --assumeyes --quiet install bind bind-utils
sed -i "s/listen-on-v6/\/\/listen-on-v6/" /etc/named.conf
echo "OPTIONS=\"-4\"" >> /etc/sysconfig/named

# ___DANGER!!___ Sometimes cloud vendors automagically replace/modify 
# /etc/resolv.conf to include their own DNS servers.
echo "nameserver 127.0.0.1" > /etc/resolv.conf

# Configure bind to start after reboots, then start it
hide_output systemctl enable named
hide_output systemctl start named

