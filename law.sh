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
