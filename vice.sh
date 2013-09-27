arch_chroot() { #{{{
    arch-chroot /mnt /bin/bash -c "${1}"
  }
arch_chroot "sudo pacman -S wget --noconfirm"
arch_chroot "wget https://aur.archlinux.org/packages/pa/packer/packer.tar.gz"
arch_chroot "tar -xvzf packer.tar.gz"
arch_chroot "cd packer && makepkg -s --asroot --noconfirm && pacman -U *.xz  --noconfirm"
arch_chroot "rm -r packer"
arch_chroot "rm -f packer*"
