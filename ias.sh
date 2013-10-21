arch_chroot() { 
  arch-chroot /mnt /bin/bash -c "${1}"
  }
arch_chroot "sudo packer -S  \
lib32-sdl_ttf  \
opendesktop-fonts  \
sdl_ttf  \
ttf-arphic-ukai  \
ttf-arphic-uming  \
ttf-bitstream-vera  \
ttf-droid  \
ttf-freefont  \
ttf-gentium  \
ttf-google-fonts-git\
ttf-hanazono  \
ttf-hannom  \
ttf-inconsolata  \
ttf-liberation  \
ttf-linux-libertine  \
ttf-ms-fonts \
ttf-sazanami  \
ttf-tw \
ttf-ubuntu-font-family \
wqy-bitmapfont  \
wqy-microhei \
wqy-zenhei \
archey \
firefox  \
google-chrome-beta  \
chromium  \
icedtea-web-java7  \
easystroke  \
flashplugin  \
bleachbit  \
conky-colors  \
evince  \
openssl098 \
gigolo  \
uget  \
qt \
qt4 \
aria2  \
iptables  \
dnsmasq  \
openresolv  \
samba  \
gvfs-smb \
xarchiver tar gzip bzip2 zip unzip unrar p7zip arj xz lzop wxgtk xdg-user-dirs \
pulseaudio pavucontrol alsa-utils pulseaudio-alsa lib32-alsa-lib lib32-libpulse  \
jack ffmpeg lib32-alsa-plugins lib32-jack lib32-libsamplerate lib32-speex libcanberra-gstreamer \
smplayer vlc radiotray gstreamer0.10-plugins clementine unrar python2-gobject2 libcec libusb-compat  \
python-dbus flac librsvg vcdimager libcdio libxv sdl osdlyrics xvba-video \
faenza-icon-theme gtk gtk2 gtk3 \
thunderbird pidgin purple-plugin-pack pidgin-libnotify libcanberra libcanberra-pulse libcanberra-gstreamer  \
geany xterm python python2 \
gparted clonezilla dosfstools ntfs-3g"
