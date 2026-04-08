# Another Arch PC

This is the consolidated English installation guide for Arch Linux, with Polish character support.

<details>
<summary>System instalation</summary>
   
## 1. Verify UEFI
Make sure the live system booted in UEFI mode:

```sh
ls /sys/firmware/efi/efivars
```

If the directory exists, you are in UEFI mode;

## 2. Test the network
Check connection to the Internet:

```sh
ping -c 3 archlinux.org
```

Enable time synchronization:

```sh
timedatectl set-ntp true
```

## 3. Wi-Fi
Unblock radio devices and connect to the network:

```sh
rfkill unblock all
```

Run `iwctl` and perform these steps:

```sh
iwctl
device list
station <INTERFACE> get-networks
station <INTERFACE> connect <SSID>
```

If the network is hidden:

```sh
station <INTERFACE> connect-hidden <SSID>
exit
```

## 4. Initialize pacman keys
After connecting to the Internet, initialize the pacman keyring:

```sh
pacman-key --init
pacman-key --populate archlinux
```

- `pacman-key --init` creates the local GPG key database;
- `pacman-key --populate archlinux` imports official signing keys;

## 5. Installation options

### Option A: `archinstall`

```sh
archinstall
```

- Automatic Arch Linux installer;
- Good if you want a quick install without manual configuration;

### Option B: `archfi`

```sh
curl -L archfi.sf.net/archfi > archfi
sh archfi
```

- A scripted Arch Linux installer;
- Repository: https://github.com/MatMoul/archfi

### Option C: manual installation

1. Check disks and partitions:
   ```sh
   lsblk
   ```
2. Start `cfdisk` on the target disk:
   ```sh
   cfdisk /dev/sdX
   ```
3. Example partition layout:
   - `/dev/sdX1` — EFI 512M, FAT32
   - `/dev/sdX2` — root 60G ext4 or btrfs
   - `/dev/sdX3` — swap 16G
   - `/dev/sdX4` — /home remaining space

   Replace `sdX` with the correct disk letter;

4. Create filesystems:
   ```sh
   mkfs.fat -F32 /dev/sdX1
   mkfs.btrfs /dev/sdX2
   mkfs.btrfs /dev/sdX4
   mkswap /dev/sdX3
   swapon /dev/sdX3
   ```

   - If you prefer ext4 for `/`, use:
     ```sh
     mkfs.ext4 /dev/sdX2
     ```

5. Mount partitions:
   ```sh
   mount /dev/sdX2 /mnt
   mkdir -p /mnt/{boot,home}
   mount /dev/sdX1 /mnt/boot
   mount /dev/sdX4 /mnt/home
   ```

6. Install the base system:
   ```sh
   pacstrap /mnt base base-devel linux linux-firmware nano usbutils amd-ucode btrfs-progs
   ```

   - For Intel CPUs, use `intel-ucode` instead of `amd-ucode`;

7. Generate `fstab` and chroot:
   ```sh
   genfstab -U /mnt >> /mnt/etc/fstab
   arch-chroot /mnt
   ```

## 6. Configure the system in `arch-chroot`

1. Set the timezone:
   ```sh
   ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
   hwclock --systohc --utc
   ```

2. Enable locales:
   ```sh
   echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
   echo "pl_PL.UTF-8 UTF-8" >> /etc/locale.gen
   locale-gen
   ```

3. Set the system language:
   ```sh
   echo "LANG=en_US.UTF-8" > /etc/locale.conf
   ```

4. Configure console settings:
   ```sh
   nano > /etc/vconsole.conf
   KEYMAP=pl
   FONT=Lat2-Terminus16.psfu.gz
   ```

5. Set the hostname:
   ```sh
   echo "myhostname" > /etc/hostname
   ```

6. Configure `/etc/hosts`:
   ```sh
   nano > /etc/hosts
   127.0.0.1 localhost.localdomain localhost
   ::1       localhost.localdomain localhost
   127.0.1.1 myhostname.localdomain myhostname
   ```

   Replace `myhostname` with your chosen hostname.

7. Create initramfs and set the root password:
   ```sh
   mkinitcpio -P
   passwd
   ```

8. Create a regular user:
   ```sh
   useradd -m -g users -G wheel,storage,power -s /bin/bash -d /home/<username> <username>
   passwd <username>
   ```

   Replace `<username>` with your chosen username;

## 7. Install network and bootloader

1. Install NetworkManager:
   ```sh
   pacman -S networkmanager
   systemctl enable NetworkManager
   ```

   After reboot, connect to Wi-Fi:
   ```sh
   nmcli device wifi connect <SSID> password <PASSWORD>
   ```

</details>

<details>
<summary>Boot instalation</summary>

2. Install a bootloader:

## Option A:
### systemd-boot
   ```sh
   pacman -S --needed efibootmgr dosfstools
   bootctl --path=/boot install
   ```

   Create `/boot/loader/loader.conf`:
   ```ini
   default arch
   timeout 3
   console-mode max
   editor no
   ```

   Create `/boot/loader/entries/arch.conf`:
   ```ini
   title   Arch Linux
   linux   /vmlinuz-linux
   initrd  /initramfs-linux.img
   options root=/dev/sdX2 rw
   ```

## Option B:
### GRUB
   ```sh
   pacman -S --needed grub efibootmgr os-prober
   grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
   grub-mkconfig -o /boot/grub/grub.cfg
   ```

## Option C:
### rEFInd
   ```sh
   pacman -S --needed refind
   refind-install
   ```

   Optionally edit `/boot/EFI/refind/refind.conf` if you need custom kernel or initramfs paths.

3. Finish installation:
   ```sh
   exit
   umount -R /mnt
   reboot
   ```

## 8. After reboot

1. Update the system:
   ```sh
   pacman -Syu
   ```

2. Enable `multilib` in `/etc/pacman.conf`:
   ```ini
   # Misc options
   #UseSyslog
   Color
   #NoProgressBar
   CheckSpace
   #VerbosePkgLists
   ParallelDownloads = 5
   DownloadUser = alpm
   #DisableSandbox
   ILoveCandy
   
   [multilib]
   Include = /etc/pacman.d/mirrorlist
   ```

3. Synchronize packages again:
   ```sh
   pacman -Syu
   ```

4. Configure mirrors:
   ```sh
   pacman -S reflector rsync curl
   reflector --verbose --country "your country" --age 24 --sort rate --save /etc/pacman.d/mirrorlist
   ```

   Or:
   ```sh
   reflector --verbose --latest 200 --age 24 --protocol http,https --sort rate --save /etc/pacman.d/mirrorlist
   ```

5. Install `yay`:
   ```sh
   pacman -S git
   cd /opt
   git clone https://aur.archlinux.org/yay-git.git
   chown -R $USER:$USER yay-git
   cd yay-git
   makepkg -si
   ```

6. Install additional firmware from AUR if needed:
https://wiki.archlinux.org/title/Mkinitcpio#Possibly_missing_firmware_for_module_XXXX

   If needed, rebuild initramfs:
   ```sh
   mkinitcpio -p linux
   ```

8. Install example packages:
   ```sh
   yay -S brave-bin
   ```
   
</details>

<details>
<summary>GUI instalation</summary>


## 9. Desktop environment and configuration

### Hyprland / configs
- https://github.com/JaKooLit
- https://github.com/JaKooLit/Arch-Hyprland
- https://github.com/end-4/dots-hyprland/tree/main\?tab\=readme-ov-file

### KDE
- https://tuxinit.com/minimal-kde-plasma-install-arch-linux/
- https://wiki.archlinux.org/title/KDE

Install Xorg and KDE packages:

```sh
yay -S xorg xorg-xinit firefox plasma-nm plasma-pa dolphin konsole kdeplasma-addons yakuake
```

Enable SDDM:

```sh
systemctl enable sddm
```

## 10. Terminal styling

1. Install fonts:
   ```sh
   yay -S ttf-nerd-fonts-symbols
   ```
2. Install Oh My Zsh and Powerlevel10k:
   ```sh
   sh -c "$(wget https://raw.github.com/ohmyzsh/oh-my-zsh/master/tools/install.sh -O -)"
   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```
3. Install plugins:
   ```sh
   git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
```
4. Edit `~/.zshrc`:
   - set `ZSH_THEME="powerlevel10k/powerlevel10k"`
   - set `plugins=(git zsh-autosuggestions zsh-syntax-highlighting)`
   - uncomment `ENABLE_CORRECTION="true"`

</details>

## Notes
- Replace `/dev/sdX`, `/dev/sdX1`, `/dev/sdX2`, `/dev/sdX3`, `/dev/sdX4` with real devices.
- Use `amd-ucode` or `intel-ucode` depending on your CPU.
- `base-devel` is needed for building AUR packages.
