clear 
parted /dev/sda mklabel gpt 
parted -a optimal /dev/sda mkpart primary fat32 1MiB 129MiB 
parted -a optimal /dev/sda mkpart primary ext4 129MiB 513MiB 
parted -a optimal /dev/sda mkpart primary ext4 513MiB 100% 
parted /dev/sda set 1 boot on parted /dev/sda set 3 lvm on 
modprobe dm_crypt  
clear
echo Preparing to encrypt the Archlinux system. 
cryptsetup -c aes-xts-plain -y -s 512 luksFormat /dev/sda3 
clear 
echo Enter the encryption password to unlock the encrypted drive 
cryptsetup luksOpen /dev/sda3 ArchSysLuks  
pvcreate /dev/mapper/ArchSysLuks 
vgcreate ArchSys /dev/mapper/ArchSysLuks 
lvcreate -C y -L 2G -n swap ArchSys 
lvcreate -L 20G -n root ArchSys 
lvcreate -l100%FREE -n home ArchSys 
mkfs.vfat -F32 /dev/sda1 
mkfs.ext4 /dev/sda2 
mkfs.ext4 /dev/ArchSys/root 
mkfs.ext4 /dev/ArchSys/home 
mkswap /dev/ArchSys/swap 
mount /dev/ArchSys/root /mnt  
mkdir /mnt/home 
mount /dev/ArchSys/home /mnt/home 
mkdir /mnt/boot 
mount /dev/sda2 /mnt/boot 
mkdir /mnt/boot/efi 
mount /dev/sda1 /mnt/boot/efi 
sed -i  '1i\Server = http://mirror.nus.edu.sg/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist 
pacstrap /mnt base base-devel 
swapon /dev/ArchSys/swap 
genfstab -U -p /mnt >> /mnt/etc/fstab 
sed -i  's/codepage=cp437/codepage=437/' /mnt/etc/fstab 
sed -i  's/,data=ordered//' /mnt/etc/fstab 
modprobe efivars
ls -1 /sys/firmware/efi/vars/  
clear 
echo Changing root to the newly installed Archlinuz system 
#arch-chroot /mnt
#git clone git://github.com/kyoshirou/GitTest

arch_chroot() { #{{{
    arch-chroot /mnt /bin/bash -c "${1}"
  }
  #}}}
clear
arch_chroot "echo Enter the Hostname for the new ArchLinux System:"
read hostname
arch_chroot "echo $hostname > /etc/hostname"
clear
arch_chroot "echo Enter the root\'s password for the new system:"
arch_chroot "passwd"
clear
arch_chroot "echo Enter a user name for the new system:"
read usr
usr=$(echo $usr | tr '[A-Z]' '[a-z]')
arch_chroot "useradd -m -g users -G wheel,audio,video,storage,power -s /bin/bash $usr"
clear
arch_chroot "echo Enter the password for $usr to logon to the new system:"
arch_chroot "passwd $usr"
arch_chroot "sed -i '96a\[multilib]\n\SigLevel = PackageRequired\nInclude = /etc/pacman.d/mirrorlist\n' /etc/pacman.conf"
arch_chroot "pacman -Syy"
arch_chroot "sed -i  '1i\en_US.UTF-8 UTF-8' /etc/locale.gen"
arch_chroot "locale-gen"
arch_chroot "echo LANG=en_US.UTF-8 > /etc/locale.conf"
arch_chroot "export LANG=en_US.UTF-8"
arch_chroot "ln -s /usr/share/zoneinfo/Singapore /etc/localtime"
arch_chroot "hwclock --systohc --utc"
arch_chroot "sed -i  '1i\use_lvmetab=1' /etc/lvm/lvm.conf"
arch_chroot "pacman -S networkmanager network-manager-applet --noconfirm"
arch_chroot "systemctl enable NetworkManager.service"
arch_chroot "sed -i  's@autodetect modconf block@autodetect modconf block encrypt lvm2 @g' /etc/mkinitcpio.conf"
arch_chroot "mkinitcpio -p linux"
arch_chroot "pacman -S xorg-server xorg-xinit xorg-server-utils virtualbox-guest-utils xfce4 xfce4-goodies firefox lxdm --noconfirm"
arch_chroot "systemctl enable lxdm.service"
arch_chroot "sed -i '/# session=\/usr\/bin\/startlxde/a\\nsession=\/usr\/bin\/startxfce4\nautologin='$usr'' /etc/lxdm/lxdm.conf"
arch_chroot "echo -e "vboxguest\nvboxsf\nvboxvideo" > /etc/modules-load.d/virtualbox.conf "
arch_chroot "pacman -S grub-efi-x86_64 efibootmgr --noconfirm"
arch_chroot "grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck"
arch_chroot "cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo ID=$(df /boot/efi/EFI |egrep -o /dev/sd'[a-z][0-9]' | sed 's/[0-9]*//g')" 
arch_chroot "DN=$(df /boot/efi/EFI |egrep -o /dev/sd'[a-z][0-9]' | sed 's/[/a-z]*//g')"
arch_chroot "efibootmgr -c -g -d $ID -p $DN -w -L "Arch Linux (GRUB)" -l '\EFI\arch_grub\grubx64.efi'"
arch_chroot "grub-mkconfig -o /boot/grub/grub.cfg"
arch_chroot "RO=$(blkid | grep crypto_LUKS | egrep -o /dev/sd'[a-z][0-99]')"
arch_chroot "sed -i 's@/vmlinuz-linux@/vmlinuz-linux cryptdevice='$RO':ArchSysLuks @g' /boot/grub/grub.cfg"
arch_chroot "mkdir -p /boot/efi/EFI/boot"
arch_chroot "cp /boot/efi/EFI/arch_grub/grubx64.efi /boot/efi/EFI/boot/bootx64.efi"
clear
clear 
arch_chroot "echo -e "The new Archlinux system installation is completed. Please Reboot ;)""
exit

