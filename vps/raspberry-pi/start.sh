#!/bin/bash
# sh <(wget -qO - https://raw.githubusercontent.com/insrchofsnrs/configs/master/vps/raspberry-pi/start.sh)
# check for root access
echo "let's setup this damn server"
sudo apt update
sudo apt -yq upgrade
sudo apt -yq autoclean
sudo apt -yq autoremove
sudo apt install -yq mc screenfetch net-tools ncdu

echo "Install docker"
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -yq


echo "chto to ne to"
# sudo groupadd docker
sudo usermod -aG docker $USER
echo 'posle sudo usermod -aG docker $USER'
# sudo newgrp docker


echo "Install nordvpn"
wget -qO - https://downloads.nordcdn.com/apps/linux/install.sh | sudo bash
sudo nordvpn login --legacy
sudo nordvpn whitelist add subnet 192.168.0.0/16
sudo nordvpn whitelist add port 22
sudo nordvpn set technology NordLynx
sudo nordvpn set autoconnect on spain
sudo nordvpn set meshnet on
sudo nordvpn c spain

echo "Creating folders for qbittorrent"
mkdir bit-torrent
mkdir share
sudo chown 520 share
cd bit-torrent
mkdir config torrents
sudo chown 520 config torrents

echo "starting cloning telegram bot for bittorrent"
git clone https://github.com/insrchofsnrs/qbittorrent-telegram-bot
cd qbittorrent-telegram-bot
docker buildx build --platform linux/arm64/v8 -t torrent-bot:latest .
cd ..


echo "Starting samba docker"

echo "Starting install samba share in docker"
sudo docker run -d \
    -p 139:139 \
    -p 445:445 \
    --restart always \
    --name samba\
    -v /home/pi/share:/share \
    elswork/samba \
    -u "$(id -u):$(id -g):$(id -un):$(id -gn):123" \
    -s "share:/share:rw:$(id -un)"

sudo reboot