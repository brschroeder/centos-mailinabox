# This VM is setup to use NFS mounts since during development we want to edit
# files from the host and have changes appear in the VM immediately so we can
# test. NOTE: NFS version 4 is used - very simple to setup on Fedora.
# NEED A REFERENCE

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"

  config.vm.provider :libvirt do |libvirt|
    libvirt.memory = 1024
  end

  # use Vagrant's insecure private key, allows new boxes to be shared w/o having
  # to share your own private key(s). Vagrants are pre-installed but you also get
  # them from https://github.com/hashicorp/vagrant/tree/master/keys
  config.ssh.insert_key = false

  config.vm.hostname ="cmiab.lan"

  config.vm.synced_folder ".", "/vagrant",
    type: "nfs",
    nfs_version: 4,
    nfs_udp: false,
    linux__nfs_options: ['rw','no_subtree_check','no_root_squash']

  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances of the same base box.
    # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
    config.cache.scope = :box
    config.cache.synced_folder_opts = {
      type: :nfs,
      nfs_version: 4,
      nfs_udp: false
    }
  end

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
