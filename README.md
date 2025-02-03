# **topic is in bulid, but feel free**

## AnotherArch-PC
rfkill unblock all

#https://wiki.archlinux.org/title/Iwd
iwctl
[iwd]# device list
[iwd]# station name get-networks
[iwd]# station name connect SSID
# If network is hidden:
[iwd]# station name connect-hidden SSID
  exit
lsblk
cfdisk /dev/...

Name Partition Size Type
sda1 /boot 512M EFI
sda2 / 60G ext4 or btrfs
sda3 swap 16G swap
sda4 /home Remaining space

mkfs.fat -F32 /dev/sdb1
mkfs.btrfs /dev/sdb{root,home}

mount /dev/sdb2 /mnt
mkdir /mnt/{home,boot}
mount /dev/sda1 /mnt/boot
mount /dev/sdb3 /mnt/home



simple script to install arch (lvl:medium)
archinstall 😉

after reboot
https://github.com/binoymanoj/Hypr-Arch
