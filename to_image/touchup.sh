#!/usr/bin/env bash
target=.

apt update
apt install -y hostapd
apt -y full-upgrade 

# treecopy all the various patches into root of new image
rsync -arv --mkpath  /pibuild/fromsrc/ /

# pick up pieces
chmod 600 /etc/hostapd/hostapd.conf /etc/wpa_supplicant/wpa_supplicant.conf
chown root:root /etc/sudoers

# switch to systemd-networkdshu
systemctl disable networking NetworkManager avahi-daemon wpa_supplicant dhcpcd 
systemctl mask avahi-daemon dhcpcd
systemctl unmask hostapd
systemctl enable ssh systemd-networkd systemd-resolved hostapd wpa_supplicant

exit

## later
rfkill unblock wlan

# let first startup of resolved symlink to /run/systemd/resolve/stub-resolv.conf
mv -f /etc/resolv.conf{,.bak}
ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

timedatectl set-timezone UTC
