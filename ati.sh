arch_chroot() { 
  arch-chroot /mnt /bin/bash -c "${1}"
  }
arch_chroot "packer -S xf86-video-intel xf86-video-ati lib32-ati-dri ttf-dejavu xcalib --noedit --noconfirm"
