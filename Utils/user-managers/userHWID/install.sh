#!/bin/bash

rm -rf $(pwd)/$0

file="/etc/ADMRufu/sbin/userHWID"

[[ -f ${file} ]] && rm $file

wget --no-cache -O $file "https://github.com/MARCELOSALVATIERRA926/Scripts-26072026/raw/main/Utils/user-managers/userHWID/userHWID"

chmod +x $file

rm -rf /usr/sbin/userHWID

ln -s $file /usr/sbin/userHWID

echo "======================================"
echo "   instalacion completa FENIX-M&M"
echo "======================================"
echo "      use el comando: userHWID"
echo "======================================"

