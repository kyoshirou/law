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

arch-chroot clear
arch-chroot echo Enter the Hostname for the new ArchLinux System:
arch-chroot read hostname
arch-chroot echo $hostname > /etc/hostname
arch-chroot clear
arch-chroot echo Enter the root\'s password for the new system:
arch-chroot passwd
arch-chroot clear
arch-chroot echo Enter a user name for the new system:
arch-chroot read usr
arch-chroot usr=$(echo $usr | tr '[A-Z]' '[a-z]')
arch-chroot useradd -m -g users -G wheel,audio,video,storage,power -s /bin/bash $usr
arch-chroot clear
arch-chroot as=\'s
arch-chroot echo Enter the $usr$as password for the new system:
arch-chroot passwd $usr
arch-chroot sed -i '96a\[multilib]\n\SigLevel = PackageRequired\nInclude = /etc/pacman.d/mirrorlist\n' /etc/pacman.conf
arch-chroot pacman -Syy
arch-chroot sed -i  '1i\en_US.UTF-8 UTF-8' /etc/locale.ge
arch-chroot locale-gen
arch-chroot echo LANG=en_US.UTF-8 > /etc/locale.conf
arch-chroot export LANG=en_US.UTF-8
arch-chroot ln -s /usr/share/zoneinfo/Singapore /etc/localtime
arch-chroot hwclock --systohc --utc
arch-chroot pacman -S networkmanager network-manager-applet --noconfirm
arch-chroot systemctl enable NetworkManager.service
arch-chroot sed -i  's@autodetect modconf block@autodetect modconf block encrypt lvm2 @g' /etc/mkinitcpio.conf
arch-chroot mkinitcpio -p linux
arch-chroot pacman -S xorg-server xorg-xinit xorg-server-utils --noconfirm
arch-chroot pacman -S grub-bios --noconfirm
arch-chroot grub-install --target=i386-pc --recheck /dev/sda
arch-chroot mkdir -p /boot/grub/locale && grub-mkconfig -o /boot/grub/grub.cfg
arch-chroot sed -i 's@/vmlinuz-linux@/vmlinuz-linux cryptdevice=/dev/sda3:ArchSysLuks@g' /boot/grub/grub.cfg
arch-chroot clear
arch-chroot echo The new Archlinux system installation is completed. Please Reboot
arch-chroot exit

reboot
