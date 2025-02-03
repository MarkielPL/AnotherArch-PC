# *topic is in bulid, but feel free*

## AnotherArch-PC
> rfkill unblock all

#https://wiki.archlinux.org/title/Iwd

iwctl
```
[iwd]# device list
[iwd]# station name-insteraface show
[iwd]# station name-insteraface connect SSID
```
### If network is hidden:

```
[iwd]# station name connect-hidden SSID
  exit
```
```
pacman-hey --init
pacman-hey --populate archlinux
```

## option *A*:
```
archinstall 😉
```
## option *B*:
```
curl -L archfi.sf.net/archfi > archfi
sh archfi
```
## option *C*:
lsblk
>cfdisk /dev/...

Name Partition Size Type
```
sda1 /boot 512M EFI
sda2 / 60G ext4 or btrfs
sda3 swap 16G swap
sda4 /home Remaining space
```
```
mkfs.fat -F32 /dev/sdb1
mkfs.btrfs /dev/sdb{root,home}
```
```
mount /dev/sdb2 /mnt
mkdir /mnt/{home,boot}
mount /dev/sda1 /mnt/boot
mount /dev/sdb3 /mnt/home
```
cdn ...

after reboot
https://github.com/binoymanoj/Hypr-Arch
