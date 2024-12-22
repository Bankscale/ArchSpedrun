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


  # Executes second part after chroot
  arch-chroot /mnt pacman-key --init
  arch-chroot /mnt pacman-key --populate archlinux
  arch-chroot /mnt systemctl enable sshd
  arch-chroot /mnt systemctl enable dhcpcd
  arch-chroot /mnt systemctl enable NetworkManager
  arch-chroot /mnt systemctl enable sddm
  arch-chroot /mnt timedatectl set-timezone America/Chicago
  arch-chroot /mnt localectl set-locale LANG=en_US.UTF-8
  arch-chroot /mnt sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers
  arch-chroot /mnt sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub
  arch-chroot /mnt grub-install --efi-directory /boot
  arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
  arch-chroot /mnt echo "$2" > /etc/hostname
  arch-chroot /mnt useradd -m -G wheel -s /bin/zsh "$3"
  arch-chroot /mnt echo please set user and root password with passwd


}

  # Added check before wiping disks
while true; do
    read -p "Is $1 the correct disk? " yn
    case $yn in
      [Yy]* ) install $1 $2 $3; break;;
      [Nn]* ) exit;;
    esac
done
