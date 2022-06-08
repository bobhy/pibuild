#!/usr/bin/env -S "bash"

adduser --add_extra_groups skuser
adduser -q skuser sudo
adduser -q skuser adm
adduser -q skuser netdev
adduser -q skuser gpio

# application tailoring

# enable nmea2000 canbus

cat >> '/boot/config.txt' <<EOF
enable_uart=1
dtparam=i2c_arm=on
dtparam=spi=on
dtoverlay=mcp2515-can0,oscillator=16000000,interrupt=25
dtoverlay=spi-bcm2835-overlay
EOF

cat > /etc/systemd/system/socketcan-interface.service <<EOF
[Unit]
Description=SocketCAN interface can0 with a baudrate of 250000
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/sbin/ip link set can0 type can bitrate 250000 ; /sbin/ifconfig can0 up
ExecReload=/sbin/ifconfig can0 down ; /sbin/ip link set can0 type can bitrate 250000 ; /sbin/ifconfig can0 up
ExecStop=/sbin/ifconfig can0 down
[Install]
WantedBy=multi-user.target
EOF

chmod 644 /etc/systemd/system/socketcan-interface.service

# prepare to get nodejs (16, the prereq for SignalK)

curl -fsSL https://deb.nodesource.com/setup_16.x | sudo bash -

# prepare to get grafana

wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# prepare to get influxdb 1.18

wget -qO- https://repos.influxdata.com/influxdb.key | gpg --dearmor > /etc/apt/trusted.gpg.d/influxdb.gpg
export DISTRIB_ID=$(lsb_release -si); export DISTRIB_CODENAME=$(lsb_release -sc)
echo "deb [signed-by=/etc/apt/trusted.gpg.d/influxdb.gpg] https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" > /etc/apt/sources.list.d/influxdb.list

# now do all the installs

apt update

apt install -y \
    mtr-tiny \
    fail2ban \
    cockpit \
    can-utils \
    nodejs \
    influxdb \
    grafana

npm install --location=global npm@latest
npm install --location=global signalk-server

### Start services

systemctl enable socketcan-interface influxdb grafana

echo ""
echo "core apps installed.  to set them up, see /pibuild/from_apps/*setup.sh"