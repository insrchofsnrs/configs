#!/bin/bash
# sh <(wget -qO - https://raw.githubusercontent.com/insrchofsnrs/configs/master/vps/raspberry-pi/start.sh)
# check for root access
echo "let's setup this damn server"
sudo apt update
sudo apt -y upgrade
sudo apt -y autoclean
sudo apt -y autoremove
sudo apt install -y mc screenfetch net-tools ncdu samba docker.io docker-compose
echo "chto to ne to"
# sudo groupadd docker
sudo usermod -aG docker $USER
echo 'posle sudo usermod -aG docker $USER'
# sudo newgrp docker
echo "do nordvpn"
wget -qO - https://downloads.nordcdn.com/apps/linux/install.sh | sudo bash
echo "posle nordvpn"
sudo nordvpn login --legacy
sudo nordvpn whitelist add subnet 192.168.0.0/16
sudo nordvpn whitelist add port 22
sudo nordvpn set technology NordLynx
sudo nordvpn set autoconnect on spain
sudo nordvpn c spain
mkdir bit-torrent
mkdir share
sudo chown 520 share
cd bit-torrent
mkdir config torrents
sudo chown 520 config torrents
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
sudo docker-compose up -d
cd /home/pi
sudo systemctl start smbd
sudo systemctl enable smbd
sudo tee -a /etc/samba/smb.conf <<EOF
[share]
    comment = Samba on Ubuntu
    path = /home/pi/share
    read only = no
    browsable = yes
EOF
sudo service smbd restart
sudo smbpasswd -a pi