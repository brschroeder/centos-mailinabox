# 2019-10-11 Official CentOS vagrant image has not been released yet
# Long term plan is to use official image with libvirt, NFS and cache plugin
# Short term plan will use generic/centos8. Have had problems with this vagrant
# getting IP addresses on libvirt so will use VirtualBox for now.
# Thus there are two major sections in this file, (un)comment one

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

Vagrant.configure("2") do |config|
  # config.vm.box = "generic/centos8"
  config.vm.box = "centos/8"

#################################################################################
# VIRTUAL BOX
# Does not work with cachier plugin

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
  end

  config.ssh.insert_key = false

  config.vm.hostname ="cmiab.lan"
  config.vm.network "private_network", ip: "10.0.2.15"

  config.vm.synced_folder ".", "/vagrant"


#################################################################################
# LIBVIRT:
# This VM is setup to use NFS mounts since during development we want to edit
# files from the host and have changes appear in the VM immediately so we can
# test. NOTE: NFS version 4 is used - very simple to setup on Fedora.
# See the accompanying Vagrantfile-HOWTO.md.

#  config.vm.provider :libvirt do |libvirt|
#    libvirt.memory = 2048
#  end
#
#  # use Vagrant's insecure private key, allows new boxes to be shared w/o having
#  # to share your own private key(s). Vagrants keys are pre-installed but you also get
#  # them from https://github.com/hashicorp/vagrant/tree/master/keys
#  config.ssh.insert_key = false
#
#  config.vm.hostname ="cmiab.lan"
#  config.vm.network "private_network", ip: "10.0.2.15"
#
#  config.vm.synced_folder ".", "/vagrant"
#    type: "nfs",
#    nfs_version: 4,
#    nfs_udp: false,
#    linux__nfs_options: ['rw','no_subtree_check','no_root_squash']
#
#  if Vagrant.has_plugin?("vagrant-cachier")
#    # Configure cached packages to be shared between instances of the same base box.
#    # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
#    config.cache.scope = :box
#    config.cache.synced_folder_opts = {
#      type: :nfs,
#      nfs_version: 4,
#      nfs_udp: false
#    }
#  end


#################################################################################
# PROVISIONING

  config.vm.provision :shell, :inline => <<-SHELL
    # Set environment variables so that the setup script does
    # not ask any questions during provisioning. We'll let the
    # machine figure out its own public IP.
    export NONINTERACTIVE=1
    export PUBLIC_IP=auto
    export PUBLIC_IPV6=auto
    export PRIMARY_HOSTNAME=auto
    export SKIP_NETWORK_CHECKS=1
    # Start the setup script.
    cd /vagrant
    setup/start.sh
SHELL


end
