arch_chroot() { #{{{
    arch-chroot /mnt /bin/bash -c "${1}"
  }
  #}}}

arch_chroot "echo Enter the Hostname for the new ArchLinux System:"
read hostname
arch_chroot "echo $hostname > /etc/hostname"
arch_chroot "echo Enter the root\'s password for the new system:"
arch_chroot "passwd"
arch_chroot "echo Enter a user name for the new system:"
read usr
usr=$(echo $usr | tr '[A-Z]' '[a-z]')
arch_chroot "useradd -m -g users -G wheel,audio,video,storage,power -s /bin/bash $usr"
#as=\'s
arch_chroot "echo Enter the $usr password for the new system:"
arch_chroot "passwd $usr"
arch_chroot "sed -i '96a\[multilib]\n\SigLevel = PackageRequired\nInclude = /etc/pacman.d/mirrorlist\n' /etc/pacman.conf"
arch_chroot "pacman -Syy"
arch_chroot "sed -i  '1i\en_US.UTF-8 UTF-8' /etc/locale.ge"
arch_chroot "locale-gen"
arch_chroot "echo LANG=en_US.UTF-8 > /etc/locale.conf"
arch_chroot "export LANG=en_US.UTF-8"
arch_chroot "ln -s /usr/share/zoneinfo/Singapore /etc/localtime"
arch_chroot "hwclock --systohc --utc"
arch_chroot "pacman -S networkmanager network-manager-applet --noconfirm"
arch_chroot "systemctl enable NetworkManager.service"
arch_chroot "sed -i  's@autodetect modconf block@autodetect modconf block encrypt lvm2 @g' /etc/mkinitcpio.conf"
arch_chroot "mkinitcpio -p linux"
arch_chroot "pacman -S xorg-server xorg-xinit xorg-server-utils --noconfirm"
arch_chroot "pacman -S grub-bios --noconfirm"
arch_chroot "grub-install --target=i386-pc --recheck /dev/sda"
arch_chroot "mkdir -p /boot/grub/locale"
arch_chroot "grub-mkconfig -o /boot/grub/grub.cfg"
arch_chroot "sed -i 's@/vmlinuz-linux@/vmlinuz-linux cryptdevice=/dev/sda3:ArchSysLuks@g' /boot/grub/grub.cfg"
arch_chroot "echo The new Archlinux system installation is completed. Please Reboot"
arch_chroot "exit"
