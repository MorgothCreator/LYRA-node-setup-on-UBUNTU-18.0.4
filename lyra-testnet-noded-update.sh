#!/bin/bash

cd /home/lyra/
releases=$(git ls-remote --tags "https://github.com/LYRA-Block-Lattice/Lyra-Core/" | awk '{print $2}' | grep -v '{}' | awk -F"/" '{print $3}' | sort -n -t. -k1,1 -k2,2 -k3,3)
releases_array=($(echo $releases | tr "\n" "\n"))
len=${#releases_array[@]}
release=${releases_array[len-1]}
current=$(monodis --assembly /home/lyra/lyra/noded/Lyra.Data.dll | grep -Po 'Version:\s\K.*')
if [ $release != $current ]; then
echo "Not the same"
wget https://github.com/LYRA-Block-Lattice/Lyra-Core/releases/download/${release}/lyra.permissionless-${release}.tar.bz2
cp lyra/noded/config.testnet.json /home/lyra/
tar -xjvf lyra.permissionless-${release}.tar.bz2
cp config.testnet.json lyra/noded/
        ufw allow 5403
        ufw allow 5404
        ufw allow 5405
systemctl restart lyra.service
fi
cd ~/
