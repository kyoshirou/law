clear 
parted /dev/sda mklabel gpt 
parted -a optimal /dev/sda mkpart primary fat32 1MiB 129MiB 
parted -a optimal /dev/sda mkpart primary ext4 129MiB 513MiB 
parted -a optimal /dev/sda mkpart primary ext4 513MiB 100% 
parted /dev/sda set 1 boot on parted /dev/sda set 3 lvm on 
modprobe dm_crypt  
clear
echo Preparing to encrypt the Archlinux system. 
cryptsetup -c aes-xts-plain -y -s 512 luksFormat /dev/sda3 
clear 
echo Enter the encryption password to unlock the encrypted drive 
cryptsetup luksOpen /dev/sda3 ArchSysLuks  
pvcreate /dev/mapper/ArchSysLuks 
vgcreate ArchSys /dev/mapper/ArchSysLuks 
lvcreate -C y -L 2G -n swap ArchSys 
lvcreate -L 20G -n root ArchSys 
lvcreate -l100%FREE -n home ArchSys 
mkfs.vfat -F32 /dev/sda1 
mkfs.ext4 /dev/sda2 
mkfs.ext4 /dev/ArchSys/root 
mkfs.ext4 /dev/ArchSys/home 
mkswap /dev/ArchSys/swap 
mount /dev/ArchSys/root /mnt  
mkdir /mnt/home 
mount /dev/ArchSys/home /mnt/home 
mkdir /mnt/boot 
mount /dev/sda2 /mnt/boot 
mkdir /mnt/boot/efi 
mount /dev/sda1 /mnt/boot/efi 
sed -i  '1i\Server = http://mirror.nus.edu.sg/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist 
pacstrap /mnt base base-devel 
swapon /dev/ArchSys/swap 
genfstab -U -p /mnt >> /mnt/etc/fstab 
sed -i  's/codepage=cp437/codepage=437/' /mnt/etc/fstab 
sed -i  's/,data=ordered//' /mnt/etc/fstab 
modprobe efivars
ls -1 /sys/firmware/efi/vars/  
clear 
echo Changing root to the newly installed Archlinuz system 
arch-chroot /mnt


