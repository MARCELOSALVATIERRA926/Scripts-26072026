# instalacion

mkdir -p /etc/ADMRufu/bin; mkdir -p /etc/ADMRufu/user; wget --no-cache -O /usr/bin/aToken-mng https://github.com/MARCELOSALVATIERRA926/Scripts-26072026/raw/main/Utils/aToken/aToken-mng; chmod +x /usr/bin/aToken-mng; aToken-mng

## demover la instalacion

1- desde el mismo script desactivas y desinstalas el protocolo

2- pos el siguiente codigo: rm -rf /etc/ADMRufu; rm -rf /usr/bin/aToken-mng

![Selección_015](https://github.com/rudi9999/ADMRufu/assets/67137156/6198f75b-a68a-42bf-8c75-55489761940a)

wget --no-cache -O /etc/ADMRufu/sbin/aToken-mng https://github.com/MARCELOSALVATIERRA926/Scripts-26072026/raw/main/Utils/aToken/aToken-mng; chmod +x /etc/ADMRufu/sbin/aToken-mng; ln -s /etc/ADMRufu/sbin/aToken-mng /usr/bin/aToken-mng
