## 📌 TODO

- [ ] Grafiken/Screenshots hinzufügen  
- [ ] Farbschema verbessern  

# 🐧 Arch Linux – Schritt-für-Schritt Installation
![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793D1?logo=arch-linux&logoColor=white)
![UEFI](https://img.shields.io/badge/Boot-UEFI-blue)
![Status](https://img.shields.io/badge/status-in--progress-yellow)
![License](https://img.shields.io/badge/license-MIT-green)

Dies ist eine Anleitung zur Installation von Arch Linux mit UEFI, Partitionierung, Bootloader-Konfiguration, Netzwerk und Installation einer grafischen Oberfläche. Die Anleitung wird weiterhin entwickelt, und ich freue mich über jede Anregung, da noch viele Verbesserungen nötig sind.



<details>
<summary><h2>📚 Inhaltsverzeichnis</h2></summary>

> ⚠️ Abschnitt wird erweitert

- [Systeminstallation](#instalacja-systemu)
- [Bootloader](#instalacja-programu-rozruchowego)
- [Treiber](#instalacja-sterowników)
- [Anpassung](#personalizacja)
- [Grafische Oberfläche](#instalacja-nakładki-graficznej)
- [Hinweise](#uwagi)

</details>


<details>
<summary><h2 id="instalacja-systemu">🧩 Systeminstallation</h2></summary>

### 1. UEFI-Modus überprüfen

Stelle sicher, dass das System im UEFI-Modus gestartet wurde:

```bash
ls /sys/firmware/efi/efivars
```

Wenn das Verzeichnis existiert, befindest du dich im UEFI-Modus.



### 2. Netzwerkverbindung überprüfen und Systemzeit einstellen

Internetverbindung testen:

```bash
ping -c 3 archlinux.org
```

Zeitsynchronisierung aktivieren:

```bash
timedatectl set-ntp true && timedatectl set-local-rtc true
```



### 3. Festplatte partitionieren

```bash
fdisk -l
cfdisk /dev/sdX
```

Beispielaufteilung für UEFI:

- `/dev/sdb1` — EFI 512M, FAT32  
- `/dev/sdb2` — root, ext4/btrfs  
- `/dev/sdb3` — home, btrfs  

Passe die Gerätenamen an dein System an.



<details>
<summary>🔓 System ohne Verschlüsselung</summary>

### 4. Dateisysteme erstellen

```bash
mkfs.fat -F32 /dev/sdb1
mkfs.ext4 /dev/sdb2
mkfs.btrfs /dev/sdb3
```

Falls root auf btrfs sein soll:

```bash
mkfs.btrfs /dev/sdb2
```



### 5. Partitionen einhängen

```bash
mount /dev/sdb2 /mnt
mkdir -p /mnt/{boot,home}
mount /dev/sdb1 /mnt/boot
mount /dev/sdb3 /mnt/home
```



### 6. Basissystem installieren

```bash
pacstrap /mnt base base-devel linux linux-firmware nano usbutils amd-ucode btrfs-progs networkmanager
```

> Für Intel-Prozessoren verwende `intel-ucode` anstelle von `amd-ucode`.

```bash
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```



### 7. System konfigurieren

```bash
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
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

Datei `/etc/vconsole.conf`:

```ini
KEYMAP=pl
FONT=Lat2-Terminus16.psfu
```

```bash
echo "mojhost" > /etc/hostname
```

Datei `/etc/hosts`:

```txt
127.0.0.1 localhost.localdomain localhost
::1       localhost.localdomain localhost
127.0.1.1 mojhost.localdomain mojhost
```



### 8. Initramfs erstellen und Root-Passwort setzen

```bash
mkinitcpio -P
passwd
```

Benutzer hinzufügen:

```bash
useradd -m -g users -G wheel,storage,power -s /bin/bash -d /home/<uzytkownik> <uzytkownik>
passwd <uzytkownik>
```

</details>


<details>
<summary>🔐 LUKS</summary>

> ⚠️ Abschnitt wird repariert

## 4. Dateisystem erstellen und Partitionen einhängen

```bash
cryptsetup luksFormat /dev/sdX2
cryptsetup open /dev/sdX2 luks
mkfs.btrfs -L arch /dev/mapper/luks
mount /dev/mapper/luks /mnt
```

## 5. BTRFS-Subvolumes und Swap erstellen

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


## 6. Basissystem installieren

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


## 7. System konfigurieren

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
<summary><h2 id="instalacja-programu-rozruchowego">🚀 Bootloader-Installation</h2></summary>

## 9. Netzwerk und Bootloader installieren

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


## 10. Installation abschließen

```bash
exit
umount -R /mnt
reboot
```

</details>

</details>


<details>

<summary><h2 id="instalacja-sterowników">🎮 Treiber</h2></summary>

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
<summary><h2 id="personalizacja">⚙️ Anpassung</h2></summary>
> ⚠️ Abschnitt wird erweitert

## 11. Multilib aktivieren

```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

```bash
pacman -Syu
```

## 12. Mirrorlist und reflector

```bash
pacman -S reflector rsync curl
```

```bash
reflector --verbose --country "your country" --age 24 --sort rate --save /etc/pacman.d/mirrorlist
```

## 13. AUR und Firmware installieren

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
<summary><h2 id="instalacja-nakładki-graficznej">🖥️ Grafische Oberfläche</h2></summary>

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
> ⚠️ Abschnitt im Aufbau

</details>


<details>
<summary><h3>Hyprland</h3></summary>
> ⚠️ Abschnitt im Aufbau

</details>


## 15. Neustart

```bash
reboot
```

</details>

---

## Hinweise

- Ersetze `/dev/sdX`, `/dev/sdb1`, `/dev/sdb2`, `/dev/sdb3` durch die richtigen Geräte  
- Verwende `amd-ucode` oder `intel-ucode` entsprechend deinem Prozessor  
- Das Paket `base-devel` wird zum Erstellen von AUR-Paketen benötigt  
