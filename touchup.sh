#!/usr/bin/env bash
target=.

rsync -arv --mkpath  /pibuild/fromsrc/ /
chmod 600 /etc/hostapd/hostapd.conf /etc/wpa_supplicant/wpa_supplicant.conf

systemctl enable sshd
systemctl disable --now networking NetworkManager wpa_supplicant* dhcpcd 
systemctl enable --now systemd-networkd systemd-resolved hostapd wpa_supplicant

rfkill unblock wlan

# let first startup of resolved symlink to /run/systemd/resolve/stub-resolv.conf
mv -f /etc/resolv.conf{,.bak}
ln -s /etc/resolv.conf /run/systemd/resolve/stub-resolv.conf

timedatectl set-timezone UTC
