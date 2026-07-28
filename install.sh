#!/bin/bash

module="$(pwd)/module"
wget -O ${module} "https://raw.githubusercontent.com/MARCELOSALVATIERRA926/Scripts-26072026/main/Herramientas/module/module" &>/dev/null
[[ ! -e ${module} ]] && exit
chmod +x ${module} &>/dev/null
source ${module}

CTRL_C(){
  exit
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

# ✅ VALIDACION EXACTA: SOLO ACEPTA fenix UNA VEZ
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

fixDeb12Ubu24(){
  if command -v ldd &>/dev/null; then
    _glibc=$(ldd --version|head -1|grep -o '[0-9]\+\.[0-9]\+'|sed 's/\.//g'|head -1)
    if [[ -n $_glibc && $_glibc -ge 235 ]]; then
      wget -O /root/fix https://raw.githubusercontent.com/MARCELOSALVATIERRA926/Scripts-26072026/main/fix && chmod 755 /root/fix && /root/fix
    fi
  fi
}

repo_install(){
  link="https://raw.githubusercontent.com/MARCELOSALVATIERRA926/Scripts-26072026/main/Repositorios/$VERSION_ID.list"
  case $VERSION_ID in
    8*|9*|10*|11*|16.04*|18.04*|20.04*|20.10*|21.04*|21.10*|22.04*) [[ ! -e /etc/apt/sources.list.back ]] && cp /etc/apt/sources.list /etc/apt/sources.list.back; wget -O /etc/apt/sources.list ${link} &>/dev/null;;
    12*|24.04*) fixDeb12Ubu24;;
  esac
}

dependencias(){
  soft="sudo bsdmainutils zip unzip ufw curl python python3 python3-pip openssl screen cron iptables lsof nano at mlocate gawk grep bc jq curl npm nodejs socat netcat netcat-traditional net-tools cowsay figlet lolcat sqlite3 libsqlite3-dev locales"
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
      apt install $install -y &>/dev/null && msg -verd "INSTALADO" || msg -verm2 "FALLO"
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
    -u|--update)install_start; install_continue; break;;
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
  wget -O ${SCPinstal}/${arqx} ${lisArq}/${arqx} &>/dev/null && {
    verificar_arq "${arqx}"
  } || {
    del 1
    print_center -verm2 'Instalacion fallida'
    sleep 2s
    error_fun "${arqx}"
  }
done

url='https://raw.githubusercontent.com/MARCELOSALVATIERRA926/Scripts-26072026/main/Utils'

autoStart="${ADMRufu}/bin" && [[ ! -d $autoStart ]] && mkdir $autoStart
varEntorno="${ADMRufu}/sbin" && [[ ! -d $varEntorno ]] && mkdir $varEntorno

cat <<EOF>$varEntorno/ls-cmd
#!/bin/bash
echo 'menu'
ls /etc/ADMRufu/sbin|sed 's/ /\n/'
EOF
chmod +x $varEntorno/ls-cmd

wget --no-cache -O $autoStart/autoStart "$url/autoStart/autoStart" &>/dev/null; chmod +x $autoStart/autoStart
wget --no-cache -O $autoStart/auto-update "$url/auto-update/auto-update" &>/dev/null; chmod +x $autoStart/auto-update
wget --no-cache -O ${ADMRufu}/install/cmd "$url/mine_port/cmd" &>/dev/null; chmod +x ${ADMRufu}/install/cmd
wget --no-cache -O ${ADMRufu}/install/udp-custom "$url/udp-custom/udp-custom" &>/dev/null; chmod +x ${ADMRufu}/install/udp-custom
wget --no-cache -O ${ADMRufu}/install/psiphon-manager "$url/psiphon/psiphon-manager" &>/dev/null; chmod +x ${ADMRufu}/install/psiphon-manager
wget --no-cache -O ${varEntorno}/dropbear "$url/dropBear/dropBear" &>/dev/null; chmod +x ${varEntorno}/dropbear
wget --no-cache -O ${varEntorno}/protocolsUDP "$url/protocolsUDP/protocolsUDP" &>/dev/null; chmod +x ${varEntorno}/protocolsUDP
wget --no-cache -O ${varEntorno}/udprequest   "$url/protocolsUDP/udprequest/udprequest" &>/dev/null; chmod +x ${varEntorno}/udprequest
wget --no-cache -O ${varEntorno}/udpcustom    "$url/protocolsUDP/udpcustom/udpcustom" &>/dev/null; chmod +x ${varEntorno}/udpcustom
wget --no-cache -O ${varEntorno}/udp-udpmod   "$url/protocolsUDP/udpmod/udp-udpmod" &>/dev/null; chmod +x ${varEntorno}/udp-udpmod
wget --no-cache -O ${varEntorno}/Stunnel      "$url/Stunnel/Stunnel" &>/dev/null; chmod +x ${varEntorno}/Stunnel
wget --no-cache -O ${varEntorno}/Slowdns      "$url/SlowDNS/Slowdns" &>/dev/null; chmod +x ${varEntorno}/Slowdns
wget --no-cache -O ${varEntorno}/epro-ws      "$url/epro-ws/epro-ws" &>/dev/null; chmod +x ${varEntorno}/epro-ws
wget --no-cache -O ${varEntorno}/socksPY      "$url/socksPY/socksPY" &>/dev/null; chmod +x ${varEntorno}/socksPY
wget --no-cache -O ${varEntorno}/monitor      "$url/user-manager/monitor/monitor" &>/dev/null; chmod +x ${varEntorno}/monitor
wget --no-cache -O ${varEntorno}/online       "$url/user-manager/monitor/online/online" &>/dev/null; chmod +x ${varEntorno}/online
wget --no-cache -O ${varEntorno}/user-info    "$url/user-managers/user-info" &>/dev/null; chmod +x ${varEntorno}/user-info
wget --no-cache -O ${varEntorno}/aToken-mng   "$url/aToken/aToken-mng" &>/dev/null; chmod +x ${varEntorno}/aToken-mng
wget --no-cache -O ${varEntorno}/makeUser     "$url/user-managers/makeUser" &>/dev/null; chmod +x ${varEntorno}/makeUser
wget --no-cache -O ${varEntorno}/genssl       "$url/genCert/genssl" &>/dev/null; chmod +x ${varEntorno}/genssl
wget --no-cache -O ${autoStart}/sql           "$url/Csqlite/sql" &>/dev/null; chmod +x ${autoStart}/sql
wget --no-cache -O ${varEntorno}/banner       "$url/banner/banner" &>/dev/null; chmod +x ${varEntorno}/banner
wget --no-cache -O ${varEntorno}/monitor-m    "$url/user-manager/monitor/monitor-m/monitor-m" &>/dev/null; chmod +x ${varEntorno}/monitor-m
wget --no-cache -O ${varEntorno}/userSSH      "$url/user-managers/userSSH/userSSH" &>/dev/null; chmod +x ${varEntorno}/userSSH
wget --no-cache -O ${varEntorno}/userHWID     "$url/user-managers/userHWID/userHWID" &>/dev/null; chmod +x ${varEntorno}/userHWID
wget --no-cache -O ${varEntorno}/userTOKEN    "$url/user-managers/userTOKEN/userTOKEN" &>/dev/null; chmod +x ${varEntorno}/userTOKEN
wget --no-cache -O ${autoStart}/limit         "$url/user-managers/limitador/limit" &>/dev/null; chmod +x ${autoStart}/limit
${autoStart}/limit

wget --no-cache -O /etc/ADMRufu/uninstall "https://raw.githubusercontent.com/MARCELOSALVATIERRA926/Scripts-26072026/main/uninstall" &>/dev/null; chmod +x /etc/ADMRufu/uninstall

if [[ -e $autoStart/autoStart ]]; then
  $autoStart/autoStart -e /etc/ADMRufu/autoStart
fi

sbinList=$(ls ${varEntorno})
for i in `echo $sbinList`; do
  ln -sf ${varEntorno}/$i /usr/bin/$i
done

sed -i '/Rufu/d' /etc/bash.bashrc /root/.bashrc
echo '[[ -e /etc/ADMRufu/bashrc ]] && source /etc/ADMRufu/bashrc' >> /etc/bash.bashrc

ln -sf /etc/ADMRufu/menu /usr/bin/ADMRufu
ln -sf /etc/ADMRufu/menu /usr/bin/menu
ln -sf /etc/ADMRufu/menu /usr/bin/adm

# ✅ CARGA AUTOMATICA DE FUNCIONES Y ARCHIVOS QUE FALTABAN
sed -i '1i source /etc/ADMRufu/module' /etc/ADMRufu/menu
mkdir -p /etc/ADMRufu/tmp
[[ ! -f /etc/ADMRufu/tmp/message.txt ]] && echo "@FENIX-M&M" > /etc/ADMRufu/tmp/message.txt

del 1
print_center -verd '✅ INSTALACION COMPLETA - FENIX-M&M'
sleep 3

mv -f ${module} /etc/ADMRufu/module
time_reboot "10"
