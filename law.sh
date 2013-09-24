parted /dev/sda mklabel msdos 
parted -a optimal /dev/sda mkpart primary fat32 1MiB 1024MiB
parted -a optimal /dev/sda mkpart primary ext4 1024MiB 1280MiB
parted -a optimal /dev/sda mkpart primary ext4 1280MiB 100%
parted /dev/sda set 1 boot on && parted /dev/sda set 3 lvm on
modprobe dm_crypt
clear
echo Starting Up LUKS 
cryptsetup -c aes-xts-plain -y -s 512 luksFormat /dev/sda3 
clear 
echo Enter the password to unlock the encrypted drive
cryptsetup luksOpen /dev/sda3 ArchSysLuks
pvcreate /dev/mapper/ArchSysLuks
vgcreate ArchSys /dev/mapper/ArchSysLuks 
lvcreate -L 8G -n root ArchSys
lvcreate -C y -L 1G -n swap ArchSys
lvcreate -l100%FREE -n home ArchSys
mkswap /dev/ArchSys/swap
mkfs.vfat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
mkfs.ext4 /dev/ArchSys/root
mkfs.ext4 /dev/ArchSys/home
mount /dev/ArchSys/root /mnt
mkdir /mnt/home
mount /dev/ArchSys/home /mnt/home
mkdir /mnt/boot
mount /dev/sda2 /mnt/boot
sed -i  '1i\Server = http://mirror.nus.edu.sg/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
pacstrap /mnt base base-devel
genfstab -U -p /mnt >> /mnt/etc/fstab
sed -i  's/codepage=cp437/codepage=437/' /mnt/etc/fstab
sed -i  's/,data=ordered//' /mnt/etc/fstab
#arch-chroot /mnt

clear
arch_chroot "echo Enter the Hostname for the new ArchLinux System:"
arch_chroot "read hostname"
arch_chroot "echo $hostname > /mnt/etc/hostname"
clear
arch_chroot "echo Enter the root\'s password for the new system:"
arch_chroot "passwd"
clear
arch_chroot "echo Enter a user name for the new system:"
arch_chroot "read usr"
arch_chroot "usr=$(echo $usr | tr '[A-Z]' '[a-z]')"
arch_chroot "useradd -m -g users -G wheel,audio,video,storage,power -s /bin/bash $usr"
clear
arch_chroot "as=\'s"
arch_chroot "echo Enter the $usr$as password for the new system:"
arch_chroot "passwd $usr"
arch_chroot "sed -i '96a\[multilib]\n\SigLevel = PackageRequired\nInclude = /etc/pacman.d/mirrorlist\n' /mnt/etc/pacman.conf"
arch_chroot "pacman -Syy"
arch_chroot "sed -i  '1i\en_US.UTF-8 UTF-8' /mnt/etc/locale.ge"
arch_chroot "locale-gen"
arch_chroot "echo LANG=en_US.UTF-8 > /mnt/etc/locale.conf"
arch_chroot "export LANG=en_US.UTF-8"
arch_chroot "ln -s /usr/share/zoneinfo/Singapore /mnt/etc/localtime"
arch_chroot "hwclock --systohc --utc"
arch_chroot "pacman -S networkmanager network-manager-applet --noconfirm"
arch_chroot "systemctl enable NetworkManager.service"
arch_chroot "sed -i  's@autodetect modconf block@autodetect modconf block encrypt lvm2 @g' /mnt/etc/mkinitcpio.conf"
arch_chroot "mkinitcpio -p linux"
arch_chroot "pacman -S xorg-server xorg-xinit xorg-server-utils --noconfirm"
arch_chroot "pacman -S grub-bios --noconfirm"
arch_chroot "grub-install --target=i386-pc --recheck /dev/sda"
arch_chroot "mkdir -p /mnt/boot/grub/locale"
arch_chroot "grub-mkconfig -o /mnt/boot/grub/grub.cfg"
arch_chroot "sed -i 's@/vmlinuz-linux@/vmlinuz-linux cryptdevice=/dev/sda3:ArchSysLuks@g' /mnt/boot/grub/grub.cfg"
clear
arch_chroot "echo The new Archlinux system installation is completed. Please Reboot"
arch_chroot "exit"

reboot

