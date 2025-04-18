# *topic is in bulid, but feel free to take whatever u want*

## AnotherArch-PC
### when using wifi
> rfkill unblock all

https://wiki.archlinux.org/title/Iwd

iwctl
```
device list
station NAME-INTERFACE show
station NAME-INTERFACE connect SSID
```
### If network is hidden:

```
station name connect-hidden SSID
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
```
curl -L archfi.sf.net/archfi > archfi
sh archfi
```
https://github.com/MatMoul/archfi
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

# after reboot


### in cli
```
nmcli device wifi connect SSID password PASSWORD
```
```
yay -S reflector rsync curl
reflector --verbose --country *"your country"* --age 48 --sort rate --save /etc/pacman.d/mirrorlist
```
### or
```
reflector --verbose --latest 200 --age 48 --protocol http,https --sort rate --save /etc/pacman.d/mirrorlist
```
```
cd /opt
git clone https://aur.archlinux.org/yay-git.git
sudo chonw -R USER:USER yay-git && cd yay-git
makepkg -si

yay -S firefox yakuake
```
### For AMD processors use
```
yay -S amd-ucode
```
### For Intel
```
yay -S intel-ucode
```
## Possibly missing firmware
```
yay -S aic94xx-firmware ast-firmware upd72020x-fw linux-firmware-qlogic wd719x-firmware
```
https://wiki.archlinux.org/title/Mkinitcpio#Possibly_missing_firmware_for_module_XXXX

## option 1:
```
https://github.com/JaKooLit
https://github.com/JaKooLit/Arch-Hyprland
```
or
https://github.com/end-4/dots-hyprland/tree/main?tab=readme-ov-file


## option 2:
https://tuxinit.com/minimal-kde-plasma-install-arch-linux/

### or

https://wiki.archlinux.org/title/KDE

### stylization
https://www.youtube.com/watch?v=uyz4-KZOzyI

## awsome
```
yay -S ttf-nerd-fonts-symbols
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```
### Plugins
```
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
```

### edit ~/.zshrc

In the file, search for “ZSH_THEME” (Mostly on line 11). The default value is "robbyrussell“, change it to **"powerlevel10k/powerlevel10k"**.

Inside the file search for “plugins=(git)"

```
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
```
Search for the line **“#ENABLE_CORRECTION=”true”** and just uncomment
Close the terminal and launch a new terminal.
