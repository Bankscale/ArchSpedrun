#!/bin/bash

pacman-key --init
pacman-key --populate archlinux

systemctl enable sshd
systemctl enable dhcpcd
systemctl enable NetworkManager
systemctl enable sddm

timedatectl set-timezone America/Chicago
localectl set-locale LANG=en_US.UTF-8

sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers

grub-install --efi-directory /boot
grub-mkconfig -o /boot/grub/grub.cfg

echo "$1" > /etc/hostname

useradd -m -G wheel -s /bin/zsh "$2"

echo set user and root password

rm "$0"

