#!/bin/bash

rm -rf $(pwd)/$0

file="/etc/ADMRufu/sbin/userSSH"

[[ -f ${file} ]] && rm $file

wget --no-cache -O $file "https://github.com/MARCELOSALVATIERRA926/Scripts-26072026/raw/main/Utils/user-managers/userSSH/userSSH"

chmod +x $file

ln -s $file /usr/bin/userSSH

echo "======================================"
echo "   instalacion completa FENIX-M&M"
echo "======================================"
echo "      use el comando: userSSH"
echo "======================================"


