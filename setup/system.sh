source /etc/mailinabox.conf
source setup/functions.sh # load our functions

# Basic System Configuration
# -------------------------

# ### Set hostname of the box

# If the hostname is not correctly resolvable sudo can't be used. This will result in
# errors during the install
#
# First set the hostname in the configuration file, then activate the setting

hostnamectl set-hostname $PRIMARY_HOSTNAME

# ### Add swap space to the system

# If the physical memory of the system is below 2GB it is wise to create a
# swap file. This will make the system more resiliant to memory spikes and
# prevent for instance spam filtering from crashing

# We will create a 1G file, this should be a good balance between disk usage
# and buffers for the system. We will only allocate this file if there is more
# than 5GB of disk space available

# The following checks are performed:
# - Check if swap is currently mountend by looking at /proc/swaps
# - Check if the user intents to activate swap on next boot by checking fstab entries.
# - Check if a swapfile already exists
# - Check if the root file system is not btrfs, might be an incompatible version with
#   swapfiles. User should hanle it them selves.
# - Check the memory requirements
# - Check available diskspace

# See https://www.digitalocean.com/community/tutorials/how-to-add-swap-on-ubuntu-14-04
# for reference

SWAP_MOUNTED=$(cat /proc/swaps | tail -n+2)
SWAP_IN_FSTAB=$(grep "swap" /etc/fstab || /bin/true)
ROOT_IS_BTRFS=$(grep "\/ .*btrfs" /proc/mounts || /bin/true)
TOTAL_PHYSICAL_MEM=$(head -n 1 /proc/meminfo | awk '{print $2}' || /bin/true)
AVAILABLE_DISK_SPACE=$(df / --output=avail | tail -n 1)
if
	[ -z "$SWAP_MOUNTED" ] &&
	[ -z "$SWAP_IN_FSTAB" ] &&
	[ ! -e /swapfile ] &&
	[ -z "$ROOT_IS_BTRFS" ] &&
	[ $TOTAL_PHYSICAL_MEM -lt 1900000 ] &&
	[ $AVAILABLE_DISK_SPACE -gt 5242880 ]
then
	echo "Adding a swap file to the system..."

	# Allocate and activate the swap file. Allocate in 1KB chuncks
	# doing it in one go, could fail on low memory systems
	dd if=/dev/zero of=/swapfile bs=1024 count=$[1024*1024] status=none
	if [ -e /swapfile ]; then
		chmod 600 /swapfile
		hide_output mkswap /swapfile
		swapon /swapfile
	fi

	# Check if swap is mounted then activate on boot
	if swapon -s | grep -q "\/swapfile"; then
		echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab
	else
		echo "ERROR: Swap allocation failed"
	fi
fi


# ### Update Packages

# Update system packages to make sure we have the latest versions

echo Updating system packages...
# hide_output yum --assumeyes --quiet update <-- TEMPORARILY DISABLED TO TEST AUTOMATIC UPDATES

# ### Install System Packages

# Install basic utilities
#
# git: we install some things directly from github
# curl: we need to download some files
# bc: allows us to do math to compute sane defaults
# cronie: cron daemon to run background process periodically
# chrony: network time protocol client
# dnf-automatic: automatic updates, both download and install

echo Installing support packages...
# Install applications
hide_output yum --assumeyes --quiet install wget curl git bc unzip
# Install services/daemons that run continuously
hide_output yum --assumeyes --quiet install cronie chrony dnf-automatic
restart_service crond
restart_service chronyd
# enable automatic downloads and installation of updates
sed -i 's/apply_updates = no/apply_updates = yes/' /etc/dnf/automatic.conf
hide_output systemctl enable --now dnf-automatic.timer

# ************ REMOVE UPON RELEASE ************************************************
# Install some tools needed to process SELinux alerts
hide_output yum --assumeyes --quiet install setools setools-console setroubleshoot
# *********************************************************************************

# ### Set the system timezone
#
# Some systems are missing /etc/localtime, which we cat into the configs for
# Z-Push and ownCloud, so we need to set it to something. Daily cron tasks
# like the system backup are run at a time tied to the system timezone, so
# letting the user choose will help us identify the right time to do those
# things (i.e. late at night in whatever timezone the user actually lives
# in).
#
# However, changing the timezone once it is set seems to confuse
# syslog (see #328). There might be other issues, and it's
# not likely the user will want to change this, so we only ask on first
# setup.

if [ -z "${NONINTERACTIVE:-}" ]; then
	if [ ! -f /etc/localtime ] || [ ! -z ${FIRST_TIME_SETUP:-} ]; then
		# If the file is missing or this is the user's first time running
		# Mail-in-a-Box setup, run the interactive timezone configuration
		# tool.
		NEW_TZ=$(tzselect)
		timedatectl set-timezone $NEW_TZ
		restart_service rsyslog
	fi
else
	# This is a non-interactive setup so we can't ask the user.
	# If /etc/localtime is missing, set it to UTC.
	if [ ! -f /etc/localtime ]; then
		echo "Setting timezone to UTC."
		timedatectl set-timezone UTC
		restart_service rsyslog
	fi
fi


# We need an ssh key to store backups via rsync, if it doesn't exist create one
if [ ! -f /root/.ssh/id_rsa_miab ]; then
	echo 'Creating SSH key for backup…'
	ssh-keygen -t rsa -b 2048 -a 100 -f /root/.ssh/id_rsa_miab -N '' -q
fi

# ### Firewall

# Explicity turn on and enable firewall
# Use `firewall-cmd --list-all` to see list of open ports/services
# By default the port for cockpit (TCP 9090) is open, close it
hide_output systemctl enable --quiet --now firewalld
hide_output firewall-cmd --quiet --permanent --remove-service=cockpit
hide_output systemctl --quiet reload firewalld

