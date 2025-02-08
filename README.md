# *topic is in bulid, but feel free*

## AnotherArch-PC
### when using wifi
> rfkill unblock all

#https://wiki.archlinux.org/title/Iwd

iwctl
```
[iwd]# device list
[iwd]# station NAME-INTERFACE show
[iwd]# station NAME-INTERFACE connect SSID
```
### If network is hidden:

```
[iwd]# station name connect-hidden SSID
  exit
```

### and now
```
pacman-key --init
pacman-key --populate archlinux
```

## option *A*:
```
archinstall 😉
```
## option *B*:
>https://github.com/MatMoul/archfi

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
in cli
```
nmcli device wifi connect SSID password PASSWORD
```
```
cd /opt
git clone https://aur.archlinux.org/yay-git.git
sudo chonw -R USER:USER yay-git && cd yay-git
makepkg -si

yay -S firefox yakuake

# For AMD processors use
yay -S amd-ucode
# For Intel
yay -S intel-ucode

```

https://github.com/binoymanoj/Hypr-Arch
