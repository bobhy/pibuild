#!/usr/bin/env -S "bash"

hostname skserv
adduser --add_extra_groups skuser
adduser -q skuser sudo
adduser -q skuser adm
adduser -q skuser netdev
adduser -q skuser gpio

# application tailoring

# prepare to get nodejs (16, the prereq for SignalK)

curl -fsSL https://deb.nodesource.com/setup_16.x | sudo bash -

# prepare to get grafana
# and grafna
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# now do all the installs

apt update

apt install -y \
    mtr-tiny \
    cockpit \
    nodejs \
    grafana

npm install --location=global npm@latest

npm install --location=global signalk-server

# manual install influxdb 1.8, the arm64 version.
mkdir temp
pushd temp
wget https://dl.influxdata.com/influxdb/releases/influxdb-1.8.10_linux_arm64.tar.gz
tar xvfz influxdb-1.8.10_linux_arm64.tar.gz
cd influxdb-1.8.10-1
rsync -arv --mkpath ./ /
popd
rmdir -rf temp

### Start services

systemctl enable influxdb
systemctl enable grafana


echo "You will have to run 'sudo signalk-server-setup' to complete config for signal K and its service."



