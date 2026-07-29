#!/bin/bash

rm -rf $(pwd)/$0

file="/etc/ADMRufu/sbin/userTOKEN"

[[ -f ${file} ]] && rm $file

wget --no-cache -O $file "https://github.com/MARCELOSALVATIERRA926/Scripts-26072026/raw/main/Utils/user-managers/userTOKEN/userTOKEN"

chmod +x $file

rm -rf /usr/bin/userTOKEN

ln -s $file /usr/bin/userTOKEN

echo "======================================"
echo "   instalacion completa FENIX-M&M"
echo "======================================"
echo "      use el comando: userTOKEN"
echo "======================================"

