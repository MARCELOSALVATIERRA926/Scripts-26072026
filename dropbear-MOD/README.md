# dropbear-MOD

## install

`wget --no-cache https://raw.githubusercontent.com/MARCELOSALVATIERRA926/Scripts-26072026/main/dropbear-MOD/install; chmod +x install; ./install`

luego de la instalacion requiere activar dropbear

comando activar

`sed -i 's/NO_START=1/NO_START=0/' /etc/default/dropbear`

comando desactivar

`sed -i 's/NO_START=0/NO_START=1/' /etc/default/dropbear`

comando modificar puerto, replaza el numero de puerto por el que gustes

`sed -i '/DROPBEAR_PORT/c\DROPBEAR_PORT=223' /etc/default/dropbear`

lugo de cada modificacion reinicion servicio

`service dropbear restart`

si desean ver el estado del servicio, ya sea por fallo u otro

`service dropbear status`

## unistall

`apt remove dropbear dropbear-bin -y; apt autoremove; apt autoclean`

## Fuente

Original: https://matt.ucc.asn.au/dropbear/dropbear.html
