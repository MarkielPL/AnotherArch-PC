## 📌 TODO

- [ ] Dodać grafiki/zrzuty ekranu  
- [ ] poprawić kolorystyke


# 🐧 Arch Linux – Instalacja krok po kroku
[![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793D1?logo=arch-linux&logoColor=white)](https://wiki.archlinux.org/title/Arch_Linux_(Polski))
![UEFI](https://img.shields.io/badge/Boot-UEFI-blue)
![Status](https://img.shields.io/badge/status-in--progress-yellow)
![License](https://img.shields.io/badge/license-MIT-green)

To jest instrukcja instalacji Arch Linux z UEFI, tworzeniem partycji, konfiguracją bootloadera, sieci i instalacją środowiska graficznego. Wciąż ją rozwijam i dziekuję za wszelkie sugestię, bo zostało sporo poprawek.



<!-- <details>
<summary><h2>📚 Spis treści</h2></summary>

> > [!NOTE]
> Sekcja w trakcie rozbudowy

- [Instalacja systemu](#instalacja-systemu)
- [Bootloader](#instalacja-programu-rozruchowego)
- [Sterowniki](#instalacja-sterowników)
- [Personalizacja](#personalizacja)
- [Środowisko graficzne](#instalacja-nakładki-graficznej)
- [Uwagi](#uwagi)

</details> -->


<details>
<summary><h2>🧩 Instalacja systemu</h2></summary>

<details> 
<summary><h2> Opcja A - oficjalny skrypt instalator</h2> </summary>

```bash
archinstall
```
> <sup>- <ins>[oficjalna strona projektu](https://wiki.archlinux.org/title/Archinstall)</ins></sup>

</details>

<details> 
<summary><h2> Opcja B - fanowski instalator</h2> </summary>

```bash
curl -LO archfi.sf.net/archfi
```

> uruchom pobrany skrypt

```bash
sh archfi
```


> <sup>- <ins>[MatMoul/archfi](https://github.com/MatMoul/archfi)</ins></sup>

</details>


<details> 
<summary><h2> Opcja C - ręczna instalacja </h2> </summary>

### 1. Sprawdź tryb UEFI

> upewnij się, że system instalacyjny wystartował w trybie UEFI:

```bash
ls /sys/firmware/efi/efivars
```

> jeśli katalog istnieje, jesteś w trybie UEFI



### 2. Sprawdź połączenie sieciowe i ustaw zegar systemowy

> przetestuj łączność

```bash
ping -c 3 archlinux.org
```

> włącz synchronizację czasu

```bash
timedatectl set-ntp true && timedatectl set-local-rtc true
```

### 3. Partycjonowanie dysku

> [!IMPORTANT]
>
>  Zastąp `/dev/sdX`(`/dev/sdb1`, `/dev/sdb2`, `/dev/sdb3`) właściwymi urządzeniami, pomocna komenda to `lsblk`
```bash
fdisk -l
cfdisk /dev/sdX
```

### Przykładowy schemat partycji dysku

| Partycja    | System plików | Rozmiar | Opis                                                                                |
| ----------- | ------------- | ------- | ----------------------------------------------------------------------------------- |
| `/dev/sdb1` | FAT32         | 512 MB  | Partycja EFI wykorzystywana jako dysk rozruchowy `/boot`                            |
| `/dev/sdb2` | ext4 / btrfs  | 80–120 GB       | Główna partycja systemowa `root` (`/`)                                              |
| `/dev/sdb3` | btrfs         | Pozostałe miejsce       | Partycja użytkownika `home` (`/home`) przechowująca dane i konfiguracje użytkownika |

---

<details>
<summary>🔓 system bez szyfrowania</summary>

### 4. Utwórz systemy plików (*formatowanie dysków*)

```bash
mkfs.fat -F32 /dev/sdb1
mkfs.ext4 /dev/sdb2
mkfs.btrfs /dev/sdb3
```

>Jeśli root ma być na btrfs:

```bash
mkfs.btrfs /dev/sdb2
```


### 5. Zamontuj partycje

```bash
mount /dev/sdb2 /mnt
mkdir -p /mnt/{boot,home}
mount /dev/sdb1 /mnt/boot
mount /dev/sdb3 /mnt/home
```

</details>


<details>
<summary>🔐 LUKS</summary>

 > # [!CAUTION]
 > Sekcja w trakcie naprawy - przyda się pomoc.

  ## 4. Utwórz system plików i zamontuj partycje
  
  ```bash
  cryptsetup luksFormat /dev/sdX2
  cryptsetup open /dev/sdX2 luks
  mkfs.btrfs -L arch /dev/mapper/luks
  mount /dev/mapper/luks /mnt
  ```
  
  
  ## 5. Utwórz podwoluminy BTRFS i swap
  
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
  mount -o noatime,ssd,compress=zstd,subvol=@cache /dev/mapper/luks /mnt/var/  cache
  mount -o noatime,ssd,compress=zstd,subvol=@scratch /dev/mapper/luks /mnt/  scratch
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
</details>

--- 

## 6. Zainstaluj system podstawowy

```bash
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
reflector -c "PL" -f 12 -l 10 -n 12 --verbose --save /etc/pacman.d/mirrorlist
```


```bash
pacstrap -K /mnt base base-devel linux linux-firmware nano usbutils <architectureCPU>-ucode btrfs-progs sudo git reflector
```

> w przypadku procesora Intel użyj `intel-ucode` jeśli AMD użyj `amd-ucode`
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

> poniższa komenda pozwala "wejsc" do świeżo zainstalowanego systemu i konfigurować go od środka, czyli:
> - ustawienie hasła;
> - strefy czasowej;
> - bootloadera;
> - konfiguracji systemu.
```
arch-chroot /mnt
```
<sup>***chroot = change root***</sup> :mechanical_arm:


## 7. Konfiguracja systemu

> poprawić linie w pliku `/etc/pacman.conf`

> [!TIP]
> ![pacmanCONF](https://github.com/user-attachments/assets/c6ec226d-c0f7-4192-9173-cb4888888d40)

```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

> wymuszenie ponownego pobrania wszystkich baz danych repozytoriów pakietów

```bash
pacman -Syy
```

>ustawienie strefy czasowej

```bash
ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
hwclock --systohc --utc
```

 > odkomentować linie w pliku `/etc/locale.gen`
```txt
en_US.UTF-8 UTF-8
pl_PL.UTF-8 UTF-8
```

```bash
locale-gen
```

> poprawić zawartośc pliku `/etc/vconsole.conf`
```ini
KEYMAP=pl
FONT=Lat2-Terminus16.psfu.gz
FONT_MAP=8859-2
```

```bash
echo "<MachineName>" > /etc/hostname
```

> dostosować zawartość pliku `/etc/hosts`
```txt
127.0.0.1 localhost.localdomain localhost
::1       localhost.localdomain localhost
127.0.1.1 <MachineName>.localdomain <MachineName>
```
> zastąpić `<MachineName>` własną nazwą hosta

> hasło dla admina
```bash
passwd
```

> dodanie nowego użytkownika
```bash
useradd -mG wheel,storage,power,log,adm,uucp,tss,rfkill -g users -s /bin/bash -d /home/<UserName> <UserName>
passwd <UserName>
```

> odkomenttować wiersz w `/etc/sudoers`
```ini
%wheel ALL=(ALL:ALL) ALL
```

<!-- ```bash
systemctl enable NetworkManager
``` -->
---
---
> jeśli system jest na partycji zaszyfrowanej, należy zakualizować zawartość **"HOOKS"** w
`/etc/mkinitcpio.conf`


```ini
HOOKS=(base keyboard systemd autodetect modconf kms block keymap sd-vconsole sd-encrypt btrfs filesystems fsck)
```
```bash
mkinitcpio -P
```
---
---

## 8. Instalacja *internetu* :)

```bash
pacman -S networkmanager
systemctl enable NetworkManager
```
> - <ins>[NetworkManager](https://networkmanager.dev/)</ins>

> uruchomienie usługi obsługi sieci podczas uruchamiania

```bash
nmcli device wifi connect <SSID> password <PASSWORD>
```

> [!IMPORTANT]
> Aby system się urucomił należy zainstalować program rozruchowy 


<details>
<summary><h2>🚀 Instalacja programu rozruchowego</h2></summary>
  
  ## 9. Instalacja  bootloadera
  
<details>
<summary><h3>Opcja 1: systemd-boot</h3></summary>

> ⚠️
> niesprawdzone jeszcze


```bash
pacman -S --needed efibootmgr dosfstools
bootctl --path=/boot install
```

> edytować plik `/boot/loader/loader.conf`

```ini
default arch
timeout 3
console-mode max
editor no
```

> edytować plik `/boot/loader/entries/arch.conf`

```ini
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=/dev/sdb2 rw
```

</details>


<details>
<summary><h3>Opcja 2: GRUB</h3></summary>

```bash
pacman -S --needed grub efibootmgr os-prober
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

</details>
  
  
<details>
<summary><h3>Opcja 3: rEFInd</h3></summary>

```bash
pacman -S --needed refind
refind-install
```

</details>

## 10. Zakończenie instalacji
> Powrót do systemu instalacyjnego *liveISO*, odmontowanie dysków i porowne uruchomienie

```bash
exit
umount -R /mnt
reboot
```
> wyjmij nośnik instalacyjny :saluting_face:
</details>
</details>


<details>

<summary><h2>🎮 Sterowniki</h2></summary>

<details>
<summary><h3>NVIDIA</h3></summary>

```bash
sudo pacman -S --needed nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader
```

</details>


<details>
<summary><h3>AMD</h3></summary>

> ⚠️
> niesprawdzone jeszcze

```bash
sudo pacman -S --needed lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader
```

</details>


<details>
<summary><h3>Intel</h3></summary>

> ⚠️
> niesprawdzone jeszcze

```bash
sudo pacman -S --needed lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader
```

</details>

</details>

</details>


<details>
<summary><h2>⚙️ Personalizacja</h2></summary>
 
> [!WARNING]
 > Sekcja w trakcie rozbudowy


## 11. Włącz multilib

```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

```bash
pacman -Syu
```

## 12. Mirrorlist i reflector

```bash
pacman -S rsync curl
```

```bash
reflector --verbose --country "your country" --age 24 --sort rate --save /etc/pacman.d/mirrorlist
```

> [!NOTE]
>
> - Dodać skrypt:
>   - aktualizacja reflector z systemd
>   - czyszczący system po kazdej aktualizacji


## 13. Instalacja AUR i firmware

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

<!-- ```bash
mkinitcpio -p linux
``` -->

</details>


<details>
<summary><h2>🖥️ Środowisko graficzne</h2></summary>

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
> ⚠️ Sekcja w trakcie budowy

</details>


<details>
<summary><h3>Hyprland</h3></summary>
> ⚠️ Sekcja w trakcie budowy

https://github.com/shell-ninja/hyprconf-install

https://github.com/JaKooLit/Arch-Hyprland

</details>


## 15. Restart

```bash
reboot
```

</details>

---

## Uwagi

> [!TIP]
> - Użyj `amd-ucode` lub `intel-ucode` zgodnie z procesorem  
> - Pakiet `base-devel` jest potrzebny do budowania pakietów z AUR  


