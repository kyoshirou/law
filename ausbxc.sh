clear
parted /dev/sdc mklabel msdos
parted -a optimal /dev/sdc mkpart primary fat32 1MiB 5120MiB
parted -a optimal /dev/sdc mkpart primary ext4 5120MiB 6144MiB
parted -a optimal /dev/sdc mkpart primary ext4 6144MiB 100%
parted /dev/sdc set 1 boot on
parted /dev/sdc set 3 lvm on
modprobe dm_crypt
clear
echo Starting Up LUKS Hard Drive Encryption
cryptsetup -c aes-xts-plain -y -s 512 luksFormat /dev/sdc3 
clear 
echo Enter the password to unlock the encrypted drive
cryptsetup luksOpen /dev/sdc3 ArchSysLuks
pvcreate /dev/mapper/ArchSysLuks
vgcreate ArchSys /dev/mapper/ArchSysLuks 
lvcreate -L 10G -n root ArchSys
lvcreate -C y -L 2G -n swap ArchSys
lvcreate -l100%FREE -n home ArchSys
mkswap /dev/ArchSys/swap
mkfs.vfat -F32 /dev/sdc1
mkfs.ext4 /dev/sdc2
mkfs.ext4 /dev/ArchSys/root
mkfs.ext4 /dev/ArchSys/home
mount /dev/ArchSys/root /mnt
mkdir /mnt/home
mount /dev/ArchSys/home /mnt/home
mkdir /mnt/boot
mount /dev/sdc2 /mnt/boot
sed -i  '1i\Server = http://mirror.nus.edu.sg/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
pacstrap /mnt base base-devel
genfstab -U -p /mnt >> /mnt/etc/fstab
sed -i  's/codepage=cp437/codepage=437/' /mnt/etc/fstab
sed -i  's/,data=ordered//' /mnt/etc/fstab
arch_chroot() { 
  arch-chroot /mnt /bin/bash -c "${1}"
  }
clear
arch_chroot "echo Enter the Hostname for the new ArchLinux System:"
#read hostname
#arch_chroot "echo $hostname > /etc/hostname"
arch_chroot "echo VFX-ARCHX64U > /etc/hostname"
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
arch_chroot "sed -i '1a\nblacklist asus-wmi\ninstall asus-wmi /bin/false\nblacklist button\ninstall button /bin/false\nblacklist eeepc-wmi\ninstall eeepc-wmi /bin/false\nblacklist mxm-wmi\ninstall mxm-wmi /bin/false\nblacklist rfkill\ninstall rfkill /bin/false\nblacklist sparse-keymap\ninstall sparse-keymap /bin/false\nblacklist video\ninstall video /bin/false\nblacklist wmi\ninstall wmi /bin/false' /etc/modprobe.d/blacklist.conf"
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
arch_chroot "pacman -S xorg-server xorg-xinit xorg-server-utils --noconfirm"
arch_chroot "pacman -S grub-bios --noconfirm"
arch_chroot "grub-install --target=i386-pc --recheck /dev/sdc"
arch_chroot "mkdir -p /boot/grub/locale"
arch_chroot "grub-mkconfig -o /boot/grub/grub.cfg"
arch_chroot "sed -i 's@/vmlinuz-linux@/vmlinuz-linux cryptdevice=/dev/sdc3:ArchSysLuks@g' /boot/grub/grub.cfg"
arch_chroot "sudo pacman -S wget --noconfirm"
arch_chroot "wget https://aur.archlinux.org/packages/pa/packer/packer.tar.gz"
arch_chroot "tar -xvzf packer.tar.gz"
arch_chroot "cd packer && makepkg -s --asroot --noconfirm && pacman -U *.xz  --noconfirm"
arch_chroot "rm -r packer"
arch_chroot "rm -f packer*"
arch_chroot "packer -S google-chrome-beta xf86-video-intel xf86-video-ati lib32-ati-dri ttf-dejavu xcalib xfce4 xfce4-goodies lxdm --noedit --noconfirm"
arch_chroot "systemctl enable lxdm.service"
arch_chroot "echo 'blacklist pcspkr' > /etc/modprobe.d/nobeep.conf"
arch_chroot "packer -S xf86-video-intel xf86-video-ati lib32-ati-dri ttf-dejavu xcalib --noedit --noconfirm"
arch_chroot "sed -i '/# session=\/usr\/bin\/startlxde/a\nsession=\/usr\/bin\/startxfce4\nautologin='$usr'' /etc/lxdm/lxdm.conf"
arch_chroot "echo The new Archlinux system installation is completed. Please Reboot"
arch_chroot "exit"

