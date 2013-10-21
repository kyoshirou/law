arch_chroot() { 
  arch-chroot /mnt /bin/bash -c "${1}"
  }
arch_chroot "pacman -S virtualbox-guest-utils  --noconfirm"
#arch_chroot "systemctl enable lxdm.service"
#read usrx
#arch_chroot "sed -i '/# session=\/usr\/bin\/startlxde/a\session=\/usr\/bin\/startxfce4\nautologin='$usrx'' /etc/lxdm/lxdm.conf"
arch_chroot "echo -e "vboxguest\nvboxsf\nvboxvideo" > /etc/modules-load.d/virtualbox.conf"
