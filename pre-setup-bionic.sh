#!/bin/bash

# Script to install python3-pip, sshpass and ansible on the host machine

# Considering the mininum installation after focal debotstrapped chroot variant buildd
[ ! -e https://boot.netboot.xyz/ipxe/netboot.xyz.iso ] && axel https://boot.netboot.xyz/ipxe/netboot.xyz.iso
mkdir chroot-bionic
sudo debootstrap --variant=buildd bionic chroot-bionic
for i in dev proc sys /dev/pts run ; do mount --bind /$i chroot-bionic/$i; done
chroot chroot-bionic <<EOF
cd /root
apt-get update
apt-get upgrade -y
apt-get install software-properties-common -y || true
mv /var/lib/dpkg/info/systemd.postinst /var/lib/dpkg/info/systemd.postinst.orig
dpkg --configure --pending
add-apt-repository multiverse
apt-get install -y grub-efi-amd64-signed shim-signed
grub-mknetdir
cp /usr/lib/shim/shimx64.efi /srv/tftp/boot/grub/x86_64-efi/
cp /usr/lib/grub/x86_64-efi-signed/grubnetx64.efi.signed /srv/tftp/boot/grub/x86_64-efi/
EOF
for i in /dev/pts dev proc sys run ; do umount -l chroot-bionic/$i; done
mkisofs -o bionic.iso chroot-bionic/
