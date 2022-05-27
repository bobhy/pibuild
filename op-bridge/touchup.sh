#!/usr/bin/env bash
target=.

chmod 600 /etc/hostapd/hostapd.conf

systemctl enable accesspoint@wlan0.service
rfkill unblock wlan

chmod 600 /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
systemctl disable wpa_supplicant.service
