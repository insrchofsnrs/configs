#!/bin/bash

for var in "$@"
    do
    sudo firewall-cmd --zone=public --permanent --add-port="$var"/tcp
    done
sudo systemctl restart firewalld.service