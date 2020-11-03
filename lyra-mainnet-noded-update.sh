#!/bin/bash

cd /home/lyra/
releases=$(git ls-remote --tags "https://github.com/LYRA-Block-Lattice/Lyra-Core/" | awk '{print $2}' | grep -v '{}' | awk -F"/" '{print $3}' | sort -n -t. -k1,1 -k2,2 -k3,3)
releases_array=($(echo $releases | tr "\n" "\n"))
len=${#releases_array[@]}
release=${releases_array[len-1]}
minor=($(echo $release | tr "." "\n"))
current=$(monodis --assembly /home/lyra/lyra/noded/Lyra.Data.dll | grep -Po 'Version:\s\K.*')
if [ $release != $current ]; then
        if [ ${minor[3]} != "0" ]; then
                echo "Minor is: "${minor[3]}
                echo "Not mainnet"
                exit
        fi
        echo "Not the same"
        wget https://github.com/LYRA-Block-Lattice/Lyra-Core/releases/download/${release}/lyra.permissionless-${release}.tar.bz2
        cp lyra/noded/config.mainnet.json /home/lyra/
        tar -xjvf lyra.permissionless-${release}.tar.bz2
        cp config.mainnet.json lyra/noded/
        wget -O /etc/systemd/system/lyra.service https://raw.githubusercontent.com/MorgothCreator/LYRA-node-setup-on-UBUNTU-18.0.4/main/lyra-linux-mainnet.service
        ufw allow 5503
        ufw allow 5504
        ufw allow 5505
        ufw reload
        systemctl daemon-reload
        systemctl restart lyra.service
fi
cd ~/

