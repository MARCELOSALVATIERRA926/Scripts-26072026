#!/bin/bash

module="$(pwd)/module"
rm -rf ${module}
wget -O ${module} "https://raw.githubusercontent.com/MARCELOSALVATIERRA926/Scripts-26072026/main/Herramientas/module/module" &>/dev/null
[[ ! -e ${module} ]] && exit
chmod +x ${module} &>/dev/null
source ${module}

CTRL_C(){
  rm -rf ${module}; exit
}

if [[ ! $(id -u) = 0 ]]; then
  clear
  msg -bar
  print_center -ama "ERROR DE EJECUCION"
  msg -bar
  print_center -ama "DEBE EJECUTARSE DESDE EL USUARIO ROOT"
  msg -bar
  CTRL_C
fi

trap "CTRL_C" INT TERM EXIT

ADMRufu="/etc/ADMRufu" && [[ ! -d ${ADMRufu} ]] && mkdir ${ADMRufu}
ADM_inst="${ADMRufu}/install" && [[ ! -d ${ADM_inst} ]] && mkdir ${ADM_inst}
tmp="${ADMRufu}/tmp" && [[ ! -d ${tmp} ]] && mkdir ${tmp}
SCPinstal="$HOME/install"

cp -f $0 ${ADMRufu}/install.sh
rm $(pwd)/$0 &> /dev/null

# ✅ VALIDACION EXACTA: SOLO ACEPTA fenix
if [[ $(which install-LIC.bin) = "" ]]; then
  cat > /usr/bin/install-LIC.bin << 'EOF'
#!/bin/bash
ARCHIVO="/etc/ADMRufu/acceso.valido"

if [[ "$1" == "-r" ]]; then
    rm -f "$ARCHIVO"
    echo "Validacion reiniciada"
    exit 0
fi

if [[ -f "$ARCHIVO" ]]; then
    exit 0
fi

clear
echo "============================================"
echo "        PRIMERA CONFIGURACION"
echo "============================================"
read -p " INGRESAR CLAVE: " CLAVE

if [[ "$CLAVE" == "fenix" ]]; then
    echo "OK" > "$ARCHIVO"
    chmod 600 "$ARCHIVO"
    echo ""
    echo " CLAVE CORRECTA"
    echo " NO SE PEDIRA NUNCA MAS"
    sleep 2
    exit 0
else
    echo ""
    echo " CLAVE INCORRECTA"
    sleep 2
    exit 1
fi
EOF
  chmod +x /usr/bin/install-LIC.bin
fi
install-LIC.bin
[[ $? = 1 ]] && exit

stop_install(){
  title "INSTALACION CANCELADA"
  exit
}

time_reboot(){
  print_center -ama "REINICIANDO VPS EN $1 SEGUNDOS"
  REBOOT_TIMEOUT="$1"
  while [ $REBOOT_TIMEOUT -gt 0 ]; do
     print_center -ne "-$REBOOT_TIMEOUT-\r"
     sleep 1
     : $((REBOOT_TIMEOUT--))
  done
  reboot
}

repo_install(){
  link="https://raw.githubusercontent.com/MARCELOSALVATIERRA926/Scripts-26072026/main/Repositorios/$VERSION_ID.list"
  case $VERSION_ID in
    8*|9*|10*|11*|16.04*|18.04*|20.04*|20.10*|21.04*|21.10*|22.04*) [[ ! -e /etc/apt/sources.list.back ]] && cp /etc/apt/sources.list /etc/apt/sources.list.back; wget -O /etc/apt/sources.list ${link} &>/dev/null;;
  esac
}

dependencias(){
  soft="sudo bsdmainutils zip unzip ufw curl python python3 python3-pip openssl screen cron iptables lsof nano at mlocate gawk grep bc jq curl npm nodejs socat netcat netcat-traditional net-tools cowsay figlet lolcat"
  for install in $soft; do
    leng="${#install}"
    puntos=$(( 21 - $leng))
    pts="."
    for (( a = 0; a < $puntos; a++ )); do
      pts+="."
    done
    msg -nazu "      instalando $install $(msg -ama "$pts")"
    if apt install $install -y &>/dev/null ; then
      msg -verd "INSTALADO"
    else
      msg -verm2 "FALLO"
      sleep 2
      del 1
      if [[ $install = "python" ]]; then
        pts=$(echo ${pts:1})
        msg -nazu "      instalando python2 $(msg -ama "$pts")"
        if apt install python2 -y &>/dev/null ; then
          [[ ! -e /usr/bin/python ]] && ln -s /usr/bin/python2 /usr/bin/python
          msg -verd "INSTALADO"
        else
          msg -verm2 "FALLO"
        fi
        continue
      fi
      print_center -ama "aplicando correccion a $install"
      dpkg --configure -a &>/dev/null
      sleep 2
      del 1
      msg -nazu "      instalando $install $(msg -ama "$pts")"
      if apt install $install -y &>/dev/null ; then
        msg -verd "INSTALADO"
      else
        msg -verm2 "FALLO"
      fi
    fi
  done
}

verificar_arq(){
  unset ARQ
  case $1 in
    menu|menu_inst.sh|tool_extras.sh|chekup.sh|bashrc)ARQ="${ADMRufu}";;
    ADMRufu)ARQ="/usr/bin";;
    message.txt)ARQ="${tmp}";;
    *)ARQ="${ADM_inst}";;
  esac
  mv -f ${SCPinstal}/$1 ${ARQ}/$1
  chmod +x ${ARQ}/$1
}

error_fun(){
  msg -bar3
  print_center -verm "Falla al descargar $1"
  msg -bar3
  [[ -d ${SCPinstal} ]] && rm -rf ${SCPinstal}
  exit
}

post_reboot(){
  echo 'clear; sleep 2; /etc/ADMRufu/install.sh --continue' >> /root/.bashrc
  title "FENIX-M&M"
  print_center -ama "La instalacion continuara despues del reinicio!!!"
  msg -bar
}

install_start(){
  title "FENIX-M&M"
  print_center -ama "A continuacion se actualizaran los paquetes del sistema."
  msg -bar3
  read -rp "$(msg -verm2 " Desea continuar? [S/N]:") " -e -i S opcion
  [[ "$opcion" != @(s|S) ]] && stop_install
  title "FENIX-M&M"
  print_center -ama 'Esto modificara la hora y fecha automatica segun la zona horaria.'
  msg -bar
  read -rp "$(msg -ama " Modificar la zona horaria? [S/N]:") " -e -i N opcion
  [[ "$opcion" != @(n|N) ]] && source <(curl -sSL "https://raw.githubusercontent.com/MARCELOSALVATIERRA926/Scripts-26072026/main/online/timeZone.sh")
  title "FENIX-M&M"
  repo_install
  apt update -y; apt upgrade -y
  [[ "$VERSION_ID" = '9' ]] && source <(curl -sL https://deb.nodesource.com/setup_10.x)
}

install_continue(){
  title "FENIX-M&M"
  print_center -ama "$PRETTY_NAME"
  print_center -verd "INSTALANDO DEPENDENCIAS"
  msg -bar3
  dependencias
  msg -bar3
  print_center -azu "Eliminando paquetes obsoletos"
  apt autoremove -y &>/dev/null
  sleep 2
  print_center -ama "si alguna falla, instalar manualmente."
  enter
}

source /etc/os-release; export PRETTY_NAME

while :
do
  case $1 in
    -s|--start)install_start; post_reboot; time_reboot "15";;
    -c|--continue)sed -i '/Rufu/d' /root/.bashrc; install_continue; break;;
    -u|--update)install_start; rm -rf /etc/ADMRufu/tmp/style; install_continue; break;;
    -t|--test)break;;
    *)exit;;
  esac
done

title "FENIX-M&M"
fun_ip

msg -ne " Verificando archivos: "
cd $HOME

arch='ADMRufu
bashrc
budp.sh
cert.sh
chekup.sh
chekuser.sh
confDNS.sh
domain.sh
filebrowser.sh
limitador.sh
menu
menu_inst.sh
openvpn.sh
PDirect.py
PGet.py
POpen.py
PPriv.py
PPub.py
slowdns.sh
sockspy.sh
squid.sh
swapfile.sh
tcpbbr.sh
tool_extras.sh
userHWID
userSSH
userTOKEN
userV2ray.sh
userWG.sh
v2ray.sh
wireguard.sh
ws-cdn.sh
WS-Proxy.js'

lisArq="https://raw.githubusercontent.com/MARCELOSALVATIERRA926/Scripts-26072026/main/old"

ver=$(curl -sSL "https://raw.githubusercontent.com/MARCELOSALVATIERRA926/Scripts-26072026/main/vercion")
echo "$ver" > ${ADMRufu}/vercion

title -ama '[FENIX-M&M]'
print_center -ama 'INSTALANDO...'
sleep 2; del 1

[[ ! -d ${SCPinstal} ]] && mkdir ${SCPinstal}

for arqx in $(echo $arch); do
  wget --no-check-certificate -O ${SCPinstal}/${arqx} ${lisArq}/${arqx} && {
    verificar_arq "${arqx}"
  } || {
    del 1
    print_center -verm2 'Instalacion fallida'
    sleep 2s
    error_fun
  }
done

url='https://raw.githubusercontent.com/MARCELOSALVATIERRA926/Scripts-26072026/main/Utils'

autoStart="${ADMRufu}/bin" && [[ ! -d $autoStart ]] && mkdir $autoStart
varEntorno="${ADMRufu}/sbin" && [[ ! -d $varEntorno ]] && mkdir $varEntorno
 
wget -O $autoStart/autoStart "$url/autoStart/autoStart"; chmod +x $autoStart/autoStart
wget -O $autoStart/auto-update "$url/auto-update/auto-update"; chmod +x $autoStart/auto-update
wget -O ${ADMRufu}/install/cmd "$url/mine_port/cmd"; chmod +x ${ADMRufu}/install/cmd
wget -O ${ADMRufu}/install/udp-custom "$url/udp-custom/udp-custom"; chmod +x ${ADMRufu}/install/udp-custom
wget -O ${ADMRufu}/install/psiphon-manager "$url/psiphon/psiphon-manager"; chmod +x ${ADMRufu}/install/psiphon-manager
wget -O ${varEntorno}/dropBear "$url/dropBear/dropBear"; chmod +x ${varEntorno}/dropBear
wget -O ${varEntorno}/protocolsUDP "$url/protocolsUDP/protocolsUDP"; chmod +x ${varEntorno}/protocolsUDP 
wget -O ${varEntorno}/udprequest   "$url/protocolsUDP/udprequest/udprequest"; chmod +x ${varEntorno}/udprequest
wget -O ${varEntorno}/udpcustom    "$url/protocolsUDP/udpcustom/udpcustom"; chmod +x ${varEntorno}/udpcustom
wget -O ${varEntorno}/udp-udpmod   "$url/protocolsUDP/udpmod/udp-udpmod"; chmod +x ${varEntorno}/udp-udpmod
wget -O ${varEntorno}/Stunnel      "$url/Stunnel/Stunnel"; chmod +x ${varEntorno}/Stunnel
wget -O ${varEntorno}/monitor "$url/user-manager/monitor/monitor"; chmod +x ${varEntorno}/monitor
wget -O ${varEntorno}/online "$url/user-manager/monitor/online/online"; chmod +x ${varEntorno}/online

if [[ -e $autoStart/autoStart ]]; then
  $autoStart/autoStart -e /etc/ADMRufu/autoStart
fi

sed -i '/Rufu99/d' ${ADMRufu}/menu ${ADMRufu}/ADMRufu ${ADMRufu}/bashrc
sed -i '/TU LICENCIA/d' ${ADMRufu}/menu ${ADMRufu}/ADMRufu
sed -i '/LICENCIA SE DAÑO/d' ${ADMRufu}/menu ${ADMRufu}/ADMRufu
sed -i '/REQUIERE INSTALAR/d' ${ADMRufu}/menu ${ADMRufu}/ADMRufu
sed -i '/Rufu/d' /etc/bash.bashrc /root/.bashrc

del 1
print_center -verd '✅ SCRIPT INSTALADO Y LIMPIO'
print_center -ama '🔑 CLAVE: fenix'
print_center -ama '✅ NO SE PEDIRA NUNCA MAS DESPUES DE LA PRIMERA VEZ'
sleep 3

rm -f $HOME/lista-arq
[[ -d ${SCPinstal} ]] && rm -rf ${SCPinstal}
rm -rf /usr/bin/menu /usr/bin/adm
ln -sf /etc/ADMRufu/menu /usr/bin/ADMRufu
ln -sf /etc/ADMRufu/menu /usr/bin/menu
ln -sf /etc/ADMRufu/menu /usr/bin/adm
ln -s /etc/ADMRufu/reseller /etc/ADMRufu/tmp/message.txt

echo '[[ -e /etc/ADMRufu/bashrc ]] && source /etc/ADMRufu/bashrc' >> /etc/bash.bashrc
update-locale LANG=en_US.UTF-8 LANGUAGE=en
[[ ! $(cat /etc/shells|grep "/bin/false") ]] && echo -e "/bin/false" >> /etc/shells
clear
title "-- FENIX-M&M --"

# ✅ CORRECIONES INCLUIDAS AHORA MISMO:
# Agregamos carga de funciones al menú
sed -i '1i source /etc/ADMRufu/module' /etc/ADMRufu/menu
# Creamos el archivo que falta si no existe
mkdir -p /etc/ADMRufu/tmp
[[ ! -f /etc/ADMRufu/tmp/message.txt ]] && echo "@FENIX-M&M" > /etc/ADMRufu/tmp/message.txt

mv -f ${module} /etc/ADMRufu/module
time_reboot "10"
