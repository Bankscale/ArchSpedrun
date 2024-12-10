#!/bin/bash
if [ "$EUID" != 0 ]
  then
    echo run as root
    exit
fi

install() {
  # Removes all partitions on drive
  sgdisk --zap-all "$1"

  # Creates boot, root, swap, home partitions
  sgdisk -n 1:0:+1G -t 1:ef00 "$1"
  sgdisk -n 2:0:+100G -t 1:8300 "$1"
  sgdisk -n 3:-4G:0 -t 1:8200 "$1"
  sgdisk -n 4:0:0 -t 1:8300 "$1"

  # Sorts the partitions
  sgdisk --sort "$1"

  # Checks for drive type
  if echo "$1" | grep -q "nmve"
  then

      # Formats the partitions
      mkfs.fat -F 32 "$1"p1
      mkfs.ext4 "$1"p2
      mkfs.ext4 "$1"p3
      mkswap "$1"p4
      swapon "$1"p4
      
      # Mounts the drives
      mount "$1"p2 /mnt
      mkdir /mnt/boot
      mount "$1"p1 /mnt/boot
      mkdir /mnt/home
      mount "$1"p3 /mnt/home
   else

      # Formats the partitions
      mkfs.fat -F 32 "$1"1
      mkfs.ext4 "$1"2
      mkfs.ext4 "$1"3
      mkswap "$1"4
      swapon "$1"4

      # Mounts the drives
      mount "$1"2 /mnt
      mkdir /mnt/boot
      mount "$1"1 /mnt/boot
      mkdir /mnt/home
      mount "$1"3 /mnt/home
  fi

  # Installs all "base" packages
  pacstrap -G /mnt base base-devel linux linux-firmware linux-headers vim zsh kitty sudo grub efibootmgr rofi dhcpcd networkmanager hyprland git wget curl openssh gdisk tldr btop fzf zsh-syntax-highlighting pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber python python-virtualenv sddm os-prober sof-firmware


  genfstab -U /mnt > /mnt/etc/fstab

  # Copies post-chroot part two onto /mnt
  cp ./archspeedrunp2.sh /mnt

  # Executes second part after chroot
  arch-chroot /mnt ./archspeedrunp2.sh "$2" "$3"

 # rm "$0"
}

  # Added check before wiping disks
while true; do
    read -p "Is $1 the correct disk? " yn
    case $yn in
      [Yy]* ) install $1 $2 $3; break;;
      [Nn]* ) exit;;
    esac
done
