clear 
echo Enter the Hostname for the new ArchLinux System: 
read hostname 
echo $hostname > /etc/hostname 
clear 
echo Enter the root\'s password for the new system: 
passwd 
clear 
echo Enter a user name for the new system: 
read usr 
usr=$(echo $usr | tr '[A-Z]' '[a-z]') useradd -m -g users -G wheel,audio,video,storage,power -s /bin/bash $usr 
clear 
as=\'s 
echo Enter the $usr$as password for the new system: 
passwd $usr 
sed -i '96a\[multilib]\n\SigLevel = PackageRequired\nInclude = /etc/pacman.d/mirrorlist\n' /etc/pacman.conf 
pacman -Syy 
sed -i  '1i\en_US.UTF-8 UTF-8' /etc/locale.gen 
locale-gen 
echo LANG=en_US.UTF-8 > /etc/locale.conf 
export LANG=en_US.UTF-8 
ln -s /usr/share/zoneinfo/Singapore /etc/localtime 
hwclock --systohc --utc 
pacman -S networkmanager network-manager-applet --noconfirm 
systemctl enable NetworkManager.service 
sed -i  's@autodetect modconf block@autodetect modconf block encrypt lvm2 @g' /etc/mkinitcpio.conf 
mkinitcpio -p linux 
pacman -S xorg-server xorg-xinit xorg-server-utils virtualbox-guest-utils xfce4 xfce4-goodies firefox lxdm --noconfirm 
systemctl enable lxdm.service 
sed -i '/# session=\/usr\/bin\/startlxde/a\\nsession=\/usr\/bin\/startxfce4\nautologin='$usr'' /etc/lxdm/lxdm.conf 
echo -e "vboxguest\nvboxsf\nvboxvideo" > /etc/modules-load.d/virtualbox.conf 
pacman -S grub-efi-x86_64 efibootmgr --noconfirm 
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck 
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo ID=$(df /boot/efi/EFI |egrep -o /dev/sd'[a-z][0-9]' | sed 's/[0-9]*//g') 
DN=$(df /boot/efi/EFI |egrep -o /dev/sd'[a-z][0-9]' | sed 's/[/a-z]*//g') 
efibootmgr -c -g -d $ID -p $DN -w -L "Arch Linux (GRUB)" -l '\EFI\arch_grub\grubx64.efi'
grub-mkconfig -o /boot/grub/grub.cfg 
RO=$(blkid | grep crypto_LUKS | egrep -o /dev/sd'[a-z][0-99]') 
sed -i 's@/vmlinuz-linux@/vmlinuz-linux cryptdevice='$RO':ArchSysLuks @g' /boot/grub/grub.cfg 
mkdir -p /boot/efi/EFI/boot 
cp /boot/efi/EFI/arch_grub/grubx64.efi /boot/efi/EFI/boot/bootx64.efi
clear
clear 
echo -e "The new Archlinux system installation is completed. Please Reboot ;)"
exit
