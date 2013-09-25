arch_chroot() { #{{{
    arch-chroot /mnt /bin/bash -c "${1}"
  }
#ID=$(df /mnt/boot/efi/EFI |egrep -o /dev/sd'[a-z][0-9]' | sed 's/[0-9]*//g')
#DN=$(df /mnt/boot/efi/EFI |egrep -o /dev/sd'[a-z][0-9]' | sed 's/[/a-z]*//g')
arch_chroot "efibootmgr -c -g -d /dev/sda -p 1 -w -L 'Arch Linux (GRUB)' -l '\EFI\arch_grub\grubx64.efi'"
arch_chroot "grub-mkconfig -o /boot/grub/grub.cfg"
RO=$(blkid | grep crypto_LUKS | egrep -o /dev/sd'[a-z][0-99]')
arch_chroot "sed -i 's@/vmlinuz-linux@/vmlinuz-linux cryptdevice='$RO':ArchSysLuks @g' /boot/grub/grub.cfg"
arch_chroot "mkdir -p /boot/efi/EFI/boot"
#arch_chroot "cp /boot/efi/EFI/arch_grub/grubx64.efi /boot/efi/EFI/boot/bootx64.efi"

arch_chroot "echo -e 'The new Archlinux system installation is completed. Please Reboot ;)'"
exit
