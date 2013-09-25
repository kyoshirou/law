sudo pacman -S wget --noconfirm
wget https://aur.archlinux.org/packages/pa/packer/packer.tar.gz
tar -xvzf packer.tar.gz
cd packer
makepkg -s --asroot
pacman -U *.xz  --noconfirm
rm -f ~/packer
