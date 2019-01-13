# Are we running as root?
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root. Please re-run like this:"
	echo
	echo "sudo $0"
	echo
	exit
fi

# Check that we are running on CentOS 7
if [ "$(sed 's/\.[0-9]\.[0-9]\{4\}.*//' /etc/redhat-release)" != "CentOS Linux release 7" ]; then
	echo "CentOS-Mail-in-a-Box only supports being installed on CentOS 7, sorry. You are running:"
	echo
	if [ -e /etc/redhat-release ]; then
        cat /etc/redhat-release
    else
        echo "Unknown"
    fi
	echo
	echo "We can't write scripts that run on every possible setup, sorry."
	exit
fi

# Check that we have enough memory.
#
# /proc/meminfo reports free memory in kibibytes. Our baseline will be 512 MB,
# which is 500000 kibibytes.
#
# We will display a warning if the memory is below 768 MB which is 750000 kibibytes
#
# Skip the check if we appear to be running inside of Vagrant, because that's really just for testing.
TOTAL_PHYSICAL_MEM=$(head -n 1 /proc/meminfo | awk '{print $2}')
if [ "$TOTAL_PHYSICAL_MEM" -lt 500000 ]; then
if [ ! -d /vagrant ]; then
	TOTAL_PHYSICAL_MEM=$(( TOTAL_PHYSICAL_MEM * 1024 / 1000 / 1000 ))
    echo "Your Mail-in-a-Box needs more memory (RAM) to function properly."
	echo "Please provision a machine with at least 512 MB, 1 GB recommended."
	echo "This machine has $TOTAL_PHYSICAL_MEM MB memory."
	exit
fi
fi
if [ $TOTAL_PHYSICAL_MEM -lt 750000 ]; then
	echo "WARNING: Your Mail-in-a-Box has less than 768 MB of memory."
	echo "         It might run unreliably when under heavy load."
fi

# Check that tempfs is mounted with exec
MOUNTED_TMP_AS_NO_EXEC=$(grep "/tmp.*noexec" /proc/mounts || /bin/true)
if [ -n "$MOUNTED_TMP_AS_NO_EXEC" ]; then
	echo "Mail-in-a-Box has to have exec rights on /tmp, please mount /tmp with exec"
	exit
fi

# Check that no .wgetrc exists
if [ -e ~/.wgetrc ]; then
	echo "Mail-in-a-Box expects no overrides to wget defaults, ~/.wgetrc exists"
	exit
fi

# Check that we are running on x86_64 architecture, it is the only one we support / test.
ARCHITECTURE=$(uname -m)
if [ "$ARCHITECTURE" != "x86_64" ]; then
	echo
	echo "WARNING:"
	echo "Mail-in-a-Box has only been tested on x86_64 and i686 platform"
	echo "architectures. Your architecture, $ARCHITECTURE, may not work."
	echo "You are on your own."
	echo
fi
