# install fedora 23 on host machine


#run virt tools installation as described in https://fedoraproject.org/wiki/Getting_started_with_virtualization
dnf install @virtualization
cd  /var/lib/libvirt/images/
wget https://getfedora.org/en/static/checksums/Fedora-Server-23-x86_64-CHECKSUM
wget https://download.fedoraproject.org/pub/fedora/linux/releases/23/Server/x86_64/iso/Fedora-Server-DVD-x86_64-23.iso
#verify checksum 
gpg --verify-files *-CHECKSUM #this one should show  Fedora-Server-DVD-x86_64-23.iso: OK




qemu-img create -f qcow2 storage-slave.qcow2 10G  # to preallocate raw image use 'fallocate -l 10G  ./storage-slave.img'
cd /var/lib/libvirt/images


virt-sysprep -a Fedora-Cloud-Base-20141203-21.x86_64.qcow2  --root-password password:$1

