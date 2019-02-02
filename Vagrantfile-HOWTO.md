# Vagrant Instructions

These are rough instructions for configuring Fedora to run vagrant and also serve NFSv4 **only** (no version 2 or 3 of NFS). Once this is done, you will be able to just "vagrant up" from within the procject directory and that will start a virtual machine and start executing the CentOS-Mail-in-a-Box installation scripts. NOTE: NFS is wanted so that we can edit-tes-run-repeat the scripts in the VM environment AND then capture all those edits in the main project directory outside the VM.

## NFS4 for Vagrant
* Edit `/etc/sysconfig/nfs` to include (this basically says do not run NFS v2 and v3)
    * `RPCNFSDARGS="-N 2 -N 3 -U"`
    * `RPCMOUNTDOPTS="-N 2 -N 3"`
* Disable NFS services not required for NFS v4
    * `systemctl mask --now rpc-statd.service rpcbind.service rpcbind.socket`
* Enable NFS (same as nfs-server)
    * `systemctl enable nfs`
* Allow NFS thru the firewall
    * `firewall-cmd --permanent --add-service=nfs`
    * `systemctl reload firewalld`
* Start the NFS server
    * `systemctl start nfs`

## Vagrant
* Install vagrant with ability to cache package downloads (this will also automatically install vagrant-libvirt from Fedora repositories)
    * `dnf install vagrant vagrant-cachier`
* Libvirtd is enabled but not yet running, so start it
    * `systemctl start libvirtd`
* Can now do a `vagrant up` to start the virtual machine but will repeatedly get asked for password to run as libvirt and also to change NFS mounts in `/etc/exports`
* To avoid entering passwords when starting, stopping, SSHing to vm continually add the local user to libvirt group
    * `sudo gpasswd -a ${USER} libvirt`
    * `newgrp libvirt`
* When using NFS the file `/etc/exports` needs to be edited but this file is owned by root:root. Edit `/etc/sudoers` to allow group vagrant (which already exists) permissions to edit this file and start/stop NFS services. Must use visudo (not vi or vim). Add this to file
    * `# Allow vagrant to manage exports`
    * `Cmnd_Alias VAGRANT_EXPORTS_ADD = /usr/bin/tee -a /etc/exports`
    * `Cmnd_Alias VAGRANT_NFSD_CHECK = /usr/bin/systemctl status --no-pager nfs-server.service`
    * `Cmnd_Alias VAGRANT_NFSD_START = /usr/bin/systemctl start nfs-server.service`
    * `Cmnd_Alias VAGRANT_NFSD_APPLY = /usr/sbin/exportfs -ar`
    * `Cmnd_Alias VAGRANT_EXPORTS_REMOVE = /bin/sed -r -e * d -ibak /*/exports`
    * `Cmnd_Alias VAGRANT_EXPORTS_REMOVE_2 = /bin/cp /*/exports /etc/exports`
    * `%vagrant ALL=(root) NOPASSWD: VAGRANT_EXPORTS_ADD, VAGRANT_NFSD_CHECK, VAGRANT_NFSD_START, VAGRANT_NFSD_APPLY, VAGRANT_EXPORTS_REMOVE, VAGRANT_EXPORTS_REMOVE_2`
*  Now need to add self to group vagrant but make sure `id` shows that you are currently member of own group (not libvirt from the previous `newgrp` command)
    * `sudo gpasswd -a ${USER} vagrant`
    * `newgrp vagrant`
* Now user username:groupname should not be asked for password when do starts with new NFS monuts, stops, SSHs etc.
