#!/bin/bash

# Script to install python3-pip, sshpass and ansible on the host machine

# Considering the mininum installation after hirsute debotstrapped chroot variant buildd
[ ! -e netboot.xyz.img ] && axel https://boot.netboot.xyz/ipxe/netboot.xyz.img
mkdir chroot-hirsute
sudo debootstrap --variant=buildd hirsute chroot-hirsute
for i in dev proc sys /dev/pts run ; do mount --bind /$i chroot-hirsute/$i; done
chroot chroot-hirsute <<EOF
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
cp /srv/tftp/boot/grub/x86_64-efi/grubnetx64.efi.signed /srv/tftp/boot/grub/x86_64-efi/grubx64.efi
EOF
for i in /dev/pts dev proc sys run ; do umount -l chroot-hirsute/$i; done
mkisofs -o hirsute.iso chroot-hirsute/
