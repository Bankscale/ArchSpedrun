#!/bin/bash
if [ "$EUID" != 0 ]
  then
    echo run as root
    exit
fi

sgdisk --zap-all "$1"

sgdisk -n 1:0:+1G -t 1:ef00 "$1"
sgdisk -n 2:0:+100G -t 1:8300 "$1"
sgdisk -n 3:-4G:0 -t 1:8200 "$1"
sgdisk -n 4:0:0 -t 1:8300 "$1"

sgdisk --sort "$1"

if echo "$1" | grep -q "nmve"
then 
    mkfs.fat -F 32 "$1"p1
    mkfs.ext4 "$1"p2
    mkfs.ext4 "$1"p3
    mkswap "$1"p4
    swapon "$1"p4

    mount "$1"p2 /mnt
    mkdir /mnt/boot
    mount "$1"p1 /mnt/boot
    mkdir /mnt/home
    mount "$1"p3 /mnt/home
 else
    mkfs.fat -F 32 "$1"1
    mkfs.ext4 "$1"2
    mkfs.ext4 "$1"3
    mkswap "$1"4
    swapon "$1"4

    mount "$1"2 /mnt
    mkdir /mnt/boot
    mount "$1"1 /mnt/boot
    mkdir /mnt/home
    mount "$1"3 /mnt/home
fi

pacstrap -G /mnt base base-devel linux linux-firmware linux-headers vim zsh kitty sudo grub efibootmgr rofi dhcpcd networkmanager hyprland git wget curl openssh gdisk tldr btop fzf zsh-syntax-highlighting pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber python python-virtualenv sddm

genfstab -U /mnt > /mnt/etc/fstab

cp ./archspeedrunp2.sh /mnt

arch-chroot /mnt ./archspeedrunp2.sh "$2" "$3"

rm "$0"

