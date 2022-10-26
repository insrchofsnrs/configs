#!/bin/bash

# check for root access
echo "let's setup this damn server"
sudo apt update
sudo apt -yq upgrade
sudo apt -yq autoclean
sudo apt -yq autoremove
sudo apt install -yq mc screenfetch net-tools ncdu samba
sudo snap install docker
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
# bash < <(wget -qO - https://downloads.nordcdn.com/apps/linux/install.sh)
nordvpn login --legacy
nordvpn whitelist add subnet 192.168.0.0/16
nordvpn whitelist add port 22
nordvpn set technology NordLynx
nordvpn set autoconnect on spain
nordvpn c
mkdir bit-torrent
mkdir share
sudo chown 520 share
cd bit-torrent
mkdir config torrents
sudo chown 520 config torrents downloads
cat > docker-compose.yaml <<EOF
version: "3.9"

services:
  torrent:
    container_name: 'bit-torrent'
    image: andreipoe/qbittorrent-aarch64
    volumes:
       - $PWD/config:/config
       - $PWD/torrents:/torrents
       - /home/pi/share:/downloads
       - /etc/timezone:/etc/timezone:ro
       - /etc/localtime:/etc/localtime:ro
    ports:
      - "80:8080"
      - "6881:6881/tcp"
      - "6881:6881/udp"
    restart: always
EOF
docker compose up -d
cd /home/pi
sudo systemctl start smbd
sudo tee -a /etc/samba/smb.conf <<EOF
[share]
    comment = Samba on Ubuntu
    path = /home/pi/share
    read only = no
    browsable = yes
EOF
sudo service smbd restart
sudo smbpasswd -a pi