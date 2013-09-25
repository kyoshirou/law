pacman -S virtualbox-guest-utils xfce4 xfce4-goodies lxdm --noconfirm
systemctl enable lxdm.service
read usr
sed -i '/# session=\/usr\/bin\/startlxde/a\\nsession=\/usr\/bin\/startxfce4\nautologin='$usr'' /etc/lxdm/lxdm.conf
echo -e "vboxguest\nvboxsf\nvboxvideo" > /etc/modules-load.d/virtualbox.conf 
