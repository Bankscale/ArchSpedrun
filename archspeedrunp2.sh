#!/bin/bash

# Sets up pacman
pacman-key --init
pacman-key --populate archlinux

# Enables important services
systemctl enable sshd
systemctl enable dhcpcd
systemctl enable NetworkManager
systemctl enable sddm

# Set date and time
timedatectl set-timezone America/Chicago
localectl set-locale LANG=en_US.UTF-8

# Edit sudoers file to enable wheel and enables os-prober in grub
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers
sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub

# Sets up grub
grub-install --efi-directory /boot
grub-mkconfig -o /boot/grub/grub.cfg

# Changes hostname and creates a user in wheel group
echo "$1" > /etc/hostname

useradd -m -G wheel -s /bin/zsh "$2"

echo please set user and root password with passwd

rm "$0"

