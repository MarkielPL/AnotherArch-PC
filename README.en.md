> ## [!IMPORTANT]
> work in progress
- [ ] Add graphics/screenshots  
- [ ] Improve the color scheme  

# 🐧 Arch Linux – Step-by-step Installation
![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793D1?logo=arch-linux&logoColor=white)
![UEFI](https://img.shields.io/badge/Boot-UEFI-blue)
![Status](https://img.shields.io/badge/status-in--progress-yellow)
![License](https://img.shields.io/badge/license-MIT-green)

This is a guide for installing Arch Linux with UEFI, disk partitioning, bootloader configuration, networking, and desktop environment installation. It is still being developed, and I appreciate any suggestions because there are still many improvements to make.



<details>
<summary><h2>📚 Table of Contents</h2></summary>

> ⚠️ Section under development

- [System installation](#instalacja-systemu)
- [Bootloader](#instalacja-programu-rozruchowego)
- [Drivers](#instalacja-sterowników)
- [Customization](#personalizacja)
- [Desktop environment](#instalacja-nakładki-graficznej)
- [Notes](#uwagi)

</details>


<details>
<summary><h2 id="instalacja-systemu">🧩 System installation</h2></summary>

### 1. Check UEFI mode

Make sure the system booted in UEFI mode:

```bash
ls /sys/firmware/efi/efivars
```

If the directory exists, you are in UEFI mode.



### 2. Check network connection and set system clock

Test Internet connectivity:

```bash
ping -c 3 archlinux.org
```

Enable time synchronization:

```bash
timedatectl set-ntp true && timedatectl set-local-rtc true
```



### 3. Disk partitioning

```bash
fdisk -l
cfdisk /dev/sdX
```

Example layout for UEFI:

- `/dev/sdb1` — EFI 512M, FAT32  
- `/dev/sdb2` — root, ext4/btrfs  
- `/dev/sdb3` — home, btrfs  

Adjust device names according to your system.



<details>
<summary>🔓 System without encryption</summary>

### 4. Create file systems

```bash
mkfs.fat -F32 /dev/sdb1
mkfs.ext4 /dev/sdb2
mkfs.btrfs /dev/sdb3
```

If root should use btrfs:

```bash
mkfs.btrfs /dev/sdb2
```



### 5. Mount partitions

```bash
mount /dev/sdb2 /mnt
mkdir -p /mnt/{boot,home}
mount /dev/sdb1 /mnt/boot
mount /dev/sdb3 /mnt/home
```



### 6. Install the base system

```bash
pacstrap /mnt base base-devel linux linux-firmware nano usbutils amd-ucode btrfs-progs networkmanager
```

> For Intel processors, use `intel-ucode` instead of `amd-ucode`.

```bash
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```



### 7. System configuration

```bash
ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
hwclock --systohc --utc
```

```bash
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "pl_PL.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
```

```bash
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

`/etc/vconsole.conf` file:

```ini
KEYMAP=en
FONT=Lat2-Terminus16.psfu
```

```bash
echo "YourHost" > /etc/hostname
```

`/etc/hosts` file:

```txt
127.0.0.1 localhost.localdomain localhost
::1       localhost.localdomain localhost
127.0.1.1 mojhost.localdomain mojhost
```



### 8. Create initramfs and set the root password

```bash
mkinitcpio -P
passwd
```

Add a user:

```bash
useradd -m -g users -G wheel,storage,power -s /bin/bash -d /home/<uzytkownik> <uzytkownik>
passwd <uzytkownik>
```

</details>


<details>
<summary>🔐 LUKS</summary>

> ⚠️ Section under repair

## 4. Create the file system and mount partitions

```bash
cryptsetup luksFormat /dev/sdX2
cryptsetup open /dev/sdX2 luks
mkfs.btrfs -L arch /dev/mapper/luks
mount /dev/mapper/luks /mnt
```

## 5. Create BTRFS subvolumes and swap

```bash
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@swap
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@scratch
```

```bash
umount /mnt
mount -o noatime,ssd,compress=zstd,subvol=@ /dev/mapper/luks /mnt
```

```bash
mkdir -p /mnt/{boot,home,var/log,var/cache,scratch,btrfs}
```

```bash
mount -o noatime,ssd,compress=zstd,subvol=@home /dev/mapper/luks /mnt/home
mount -o noatime,ssd,compress=zstd,subvol=@log /dev/mapper/luks /mnt/var/log
mount -o noatime,ssd,compress=zstd,subvol=@cache /dev/mapper/luks /mnt/var/cache
mount -o noatime,ssd,compress=zstd,subvol=@scratch /dev/mapper/luks /mnt/scratch
mount -o noatime,ssd,compress=zstd,subvolid=5 /dev/mapper/luks /mnt/btrfs
```

```bash
mkfs.fat -F32 /dev/sdX1
mount /dev/sdX /mnt/boot
```

### swapfile

```bash
cd /mnt/btrfs/@swap
btrfs filesystem mkswapfile --size 20g --uuid clear ./swapfile
swapon ./swapfile
cd
```


## 6. Install the base system

```bash
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
reflector -c "PL" -f 12 -l 10 -n 12 --verbose --save /etc/pacman.d/mirrorlist
```

```bash
nano /etc/pacman.conf
```

```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

```bash
pacman -Syy
```

```bash
pacstrap -K /mnt base base-devel linux linux-firmware nano usbutils <architectureCPU>-ucode btrfs-progs networkmanager sudo git reflector
```

```bash
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```


## 7. System configuration

```bash
ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
hwclock --systohc --utc
```

```bash
nano /etc/locale.gen
```

```txt
#en_US.UTF-8 UTF-8
#pl_PL.UTF-8 UTF-8
```

```bash
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
```

```bash
nano /etc/vconsole.conf
```

```ini
KEYMAP=pl
FONT=Lat2-Terminus16.psfu.gz
FONT_MAP=8859-2
```

```bash
echo "ArchLinux" > /etc/hostname
```

```bash
nano /etc/hosts
```

```txt
127.0.0.1 ArchLinux.localdomain localhost
::1       localhost.localdomain localhost
```

```bash
passwd
```

```bash
useradd -mG wheel,storage,power,log,adm,uucp,tss,rfkill -g users -s /bin/bash -d /home/<username> <username>
passwd <username>
```

```bash
nano /etc/sudoers
```

```txt
# %wheel ALL=(ALL:ALL) ALL
```

```bash
systemctl enable NetworkManager
```

```bash
nano /etc/mkinitcpio.conf
```

```txt
HOOKS=(base keyboard systemd autodetect modconf kms block keymap sd-vconsole sd-encrypt btrfs filesystems fsck)
```

```bash
mkinitcpio -P
```

</details>

</details>


<details>
<summary><h2 id="instalacja-programu-rozruchowego">🚀 Bootloader installation</h2></summary>

## 9. Install networking and bootloader

```bash
pacman -S networkmanager
systemctl enable NetworkManager
```

```bash
nmcli device wifi connect <SSID> password <PASSWORD>
```


<details>
<summary><h3>Option 1: systemd-boot</h3></summary>


```bash
pacman -S --needed efibootmgr dosfstools
bootctl --path=/boot install
```

`/boot/loader/loader.conf`

```ini
default arch
timeout 3
console-mode max
editor no
```

`/boot/loader/entries/arch.conf`

```ini
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=/dev/sdb2 rw
```

</details>


<details>
<summary><h3>Option 2: GRUB</h3></summary>

```bash
pacman -S --needed grub efibootmgr os-prober
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

</details>


<details>
<summary><h3>Option 3: rEFInd</h3></summary>

```bash
pacman -S --needed refind
refind-install
```


## 10. Finish installation

```bash
exit
umount -R /mnt
reboot
```

</details>

</details>


<details>

<summary><h2 id="instalacja-sterowników">🎮 Drivers</h2></summary>

<details>
<summary><h3>NVIDIA</h3></summary>

```bash
sudo pacman -S --needed nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader
```

</details>


<details>
<summary><h3>AMD</h3></summary>

```bash
sudo pacman -S --needed lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader
```

</details>


<details>
<summary><h3>Intel</h3></summary>

```bash
sudo pacman -S --needed lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader
```

</details>

</details>


<details>
<summary><h2 id="personalizacja">⚙️ Customization</h2></summary>
> ⚠️ Section under development

## 11. Enable multilib

```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

```bash
pacman -Syu
```

## 12. Mirrorlist and reflector

```bash
pacman -S reflector rsync curl
```

```bash
reflector --verbose --country "your country" --age 24 --sort rate --save /etc/pacman.d/mirrorlist
```

## 13. Install AUR and firmware

```bash
pacman -S git
```

```bash
cd /opt
git clone https://aur.archlinux.org/yay-git.git
chown -R $USER:$USER yay-git
cd yay-git
makepkg -si
```

```bash
mkinitcpio -p linux
```

</details>


<details>
<summary><h2 id="instalacja-nakładki-graficznej">🖥️ Desktop environment</h2></summary>

<details>
<summary><h3>KDE Plasma</h3></summary>

```bash
yay -S xorg xorg-xinit brave-bin plasma-nm plasma-pa dolphin konsole kdeplasma-addons yakuake
```

```bash
systemctl enable sddm
```
</details>

<details>
<summary><h3>Gnome</h3></summary>
> ⚠️ Section under construction

</details>


<details>
<summary><h3>Hyprland</h3></summary>
> ⚠️ Section under construction

</details>


## 15. Restart

```bash
reboot
```

</details>

---

## Notes

- Replace `/dev/sdX`, `/dev/sdb1`, `/dev/sdb2`, `/dev/sdb3` with the correct devices  
- Use `amd-ucode` or `intel-ucode` according to your processor  
- The `base-devel` package is required for building AUR packages  
