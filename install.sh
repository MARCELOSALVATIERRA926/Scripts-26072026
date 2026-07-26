#!/bin/bash

module="$(pwd)/module"
rm -rf ${module}
wget -O ${module} "https://raw.githubusercontent.com/MARCELOSALVATIERRA926/Scripts-26072026/main/Herramientas/module/module" &>/dev/null
[[ ! -e ${module} ]] && exit
chmod +x ${module} &>/dev/null
source ${module}

CTRL_C(){ rm -rf ${module}; exit; }

if [[ ! $(id -u) = 0 ]]; then
  clear; msg -bar; print_center -ama "ERROR: EJECUTAR COMO ROOT"; msg -bar; CTRL_C
fi

trap "CTRL_C" INT TERM EXIT

ADMRufu="/etc/ADMRufu" && mkdir -p ${ADMRufu} ${ADMRufu}/install ${ADMRufu}/tmp
SCPinstal="$HOME/install"

cp -f $0 ${ADMRufu}/install.sh
rm -f $(pwd)/$0

# ✅ ELIMINAMOS POR COMPLETO LA VALIDACIÓN DE LICENCIA
rm -f /usr/bin/install-LIC
echo -e '#!/bin/bash\nexit 0' > /usr/bin/install-LIC
chmod +x /usr/bin/install-LIC
# NO EJECUTAMOS NINGUNA LICENCIA

stop_install(){ title "INSTALACION CANCELADA"; exit; }
time_reboot(){ print_center -ama "REINICIANDO EN $1 SEGUNDOS"; sleep $1; reboot; }

fixDeb12Ubu24(){
  command -v ldd &>/dev/null || return
  _glibc=$(ldd --version|head -1|grep -o '[0-9]\+\.[0-9]\+'|sed 's/\.//g'|head -1)
  if [[ $_glibc -ge 235 ]]; then
    wget -O /root/fix https://raw.githubusercontent.com/MARCELOSALVATIERRA926/Scripts-26072026/main/fix &>/dev/null
    [[ -f /root/fix ]] && chmod 755 /root/fix && /root/fix
  fi
}

repo_install(){
  link="https://raw.githubusercontent.com/MARCELOSALVATIERRA926/Scripts-26072026/main/Repositorios/$VERSION_ID.list"
  case $VERSION_ID in
    8*|9*|10*|11*|16.*|18.*|20.*|21.*|22.*) [[ ! -e /etc/apt/sources.list.back ]] && cp /etc/apt/sources.list /etc/apt/sources.list.back; wget -O /etc/apt/sources.list ${link} &>/dev/null;;
    12*|24.*) fixDeb12Ubu24;;
  esac
}

dependencias(){
  soft="sudo bsdmainutils zip unzip ufw curl python python3 python3-pip openssl screen cron iptables lsof nano at mlocate gawk grep bc jq npm nodejs socat netcat netcat-traditional net-tools cowsay figlet lolcat sqlite3 libsqlite3-dev locales"
  for install in $soft; do
    printf -v pts '%*s' $((21-${#install})) ''; pts=${pts// /.}
    msg -nazu "      instalando $install $(msg -ama "$pts")"
    if apt install $install -y &>/dev/null; then msg -verd "INSTALL"
    else msg -verm2 "FAIL"; sleep 2; del 1
      [[ $install = "python" ]] && { apt install python2 -y &>/dev/null && ln -sf /usr/bin/python2 /usr/bin/python; msg -verd "INSTALL" || msg -verm2 "FAIL"; continue; }
      dpkg --configure -a &>/dev/null; sleep 2; del 1
      apt install $install -y &>/dev/null && msg -verd "INSTALL" || msg -verm2 "FAIL"
    fi
  done
}

verificar_arq(){
  case $1 in menu|menu_inst.sh|tool_extras.sh|chekup.sh|bashrc) ARQ=${ADMRufu};; ADMRufu) ARQ=/usr/bin;; message.txt) ARQ=${tmp};; *) ARQ=${ADM_inst};; esac
  mv -f ${SCPinstal}/$1 ${ARQ}/$1; chmod +x ${ARQ}/$1
}

error_fun(){ msg -bar3; print_center -verm "FALLA EN: $1"; msg -bar3; rm -rf ${SCPinstal}; exit; }
post_reboot(){ echo 'clear; sleep 2; /etc/ADMRufu/install.sh --continue' >> /root/.bashrc; title "ADMRufu"; print_center -ama "CONTINUA DESPUES DEL REINICIO"; msg -bar; }

install_start(){
  title "INSTALADOR ADMRufU"
  print_center -ama "ACTUALIZANDO SISTEMA"
  read -rp "$(msg -verm2 " CONTINUAR? [S/N]:") " -e -i S opcion; [[ $opcion != [sS] ]] && stop_install
  source <(curl -sSL "https://raw.githubusercontent.com/MARCELOSALVATIERRA926/Scripts-26072026/main/online/timeZone.sh")
  repo_install; apt update -y; apt upgrade -y
  [[ $VERSION_ID = '9' ]] && curl -sL https://deb.nodesource.com/setup_10.x | bash - &>/dev/null
}

install_continue(){
  title "INSTALADOR ADMRufU"; print_center -ama "$PRETTY_NAME"; print_center -verd "INSTALANDO DEPENDENCIAS"; msg -bar3
  dependencias; msg -bar3; apt autoremove -y &>/dev/null
  [[ $VERSION_ID = '9' ]] && apt remove unscd -y &>/dev/null; sleep 2
  print_center -ama "SI FALLA ALGO, INSTALAR MANUALMENTE"; enter
}

source /etc/os-release; export PRETTY_NAME

while $1; do
  case $1 in
    -s|--start) install_start; post_reboot; time_reboot 15;;
    -c|--continue) sed -i '/Rufu/d' /root/.bashrc; install_continue; break;;
    -u|--update) install_start; rm -rf ${ADMRufu}/tmp/style; install_continue; break;;
    *) exit;;
  esac
  shift
done

msg -ne " VERIFICANDO: "; cd $HOME
arch='ADMRufu bashrc budp.sh cert.sh chekup.sh chekuser.sh confDNS.sh domain.sh filebrowser.sh limitador.sh menu menu_inst.sh openvpn.sh PDirect.py PGet.py POpen.py PPriv.py PPub.py sockspy.sh squid.sh swapfile.sh tcpbbr.sh tool_extras.sh userHWID userSSH userTOKEN userV2ray.sh userWG.sh v2ray.sh wireguard.sh ws-cdn.sh WS-Proxy.js'
lisArq="https://raw.githubusercontent.com/MARCELOSALVATIERRA926/Scripts-26072026/main/old"
ver=$(curl -sSL "https://raw.githubusercontent.com/MARCELOSALVATIERRA926/Scripts-26072026/main/vercion")
echo "$ver" > ${ADMRufu}/vercion
echo -e "Idioma=es_ES.utf8\nRutaLocales=locale" > ${ADMRufu}/lang.ini

title -ama '[TU VERSION]'; print_center -ama 'INSTALANDO...'; sleep 2; del 1
mkdir -p ${SCPinstal}

for arqx in $arch; do
  wget -qO ${SCPinstal}/${arqx} ${lisArq}/${arqx} && verificar_arq "$arqx" || { del 1; print_center -verm2 "FALLA: $arqx"; sleep 2; error_fun "$arqx"; }
done

url='https://raw.githubusercontent.com/MARCELOSALVATIERRA926/Scripts-26072026/main/Utils'
autoStart=${ADMRufu}/bin; varEntorno=${ADMRufu}/sbin
mkdir -p $autoStart $varEntorno

echo -e '#!/bin/bash\necho menu; ls /etc/ADMRufu/sbin' > $varEntorno/ls-cmd; chmod +x $varEntorno/ls-cmd

wget -qO $autoStart/autoStart "$url/autoStart/autoStart" && chmod +x $autoStart/autoStart
wget -qO $autoStart/auto-update "$url/auto-update/auto-update" && chmod +x $autoStart/auto-update
wget -qO ${ADMRufu}/install/udp-custom "$url/udp-custom/udp-custom" && chmod +x ${ADMRufu}/install/udp-custom
wget -qO ${ADMRufu}/install/psiphon-manager "$url/psiphon/psiphon-manager" && chmod +x ${ADMRufu}/install/psiphon-manager
wget -qO $varEntorno/dropBear "$url/dropBear/dropBear" && chmod +x $varEntorno/dropBear
wget -qO $varEntorno/protocolsUDP "$url/protocolsUDP/protocolsUDP" && chmod +x $varEntorno/protocolsUDP
wget -qO $varEntorno/udprequest "$url/protocolsUDP/udprequest/udprequest" && chmod +x $varEntorno/udprequest
wget -qO $varEntorno/udpcustom "$url/protocolsUDP/udpcustom/udpcustom" && chmod +x $varEntorno/udpcustom
wget -qO $varEntorno/udp-udpmod "$url/protocolsUDP/udpmod/udp-udpmod" && chmod +x $varEntorno/udp-udpmod
wget -qO $varEntorno/Stunnel "$url/Stunnel/Stunnel" && chmod +x $varEntorno/Stunnel
wget -qO $varEntorno/Slowdns "$url/SlowDNS/Slowdns" && chmod +x $varEntorno/Slowdns
wget -qO $varEntorno/cmd "$url/mine_port/cmd" && chmod +x $varEntorno/cmd
wget -qO $varEntorno/epro-ws "$url/epro-ws/epro-ws" && chmod +x $varEntorno/epro-ws
wget -qO $varEntorno/socksPY "$url/socksPY/socksPY" && chmod +x $varEntorno/socksPY
wget -qO $varEntorno/monitor "$url/user-manager/monitor/monitor" && chmod +x $varEntorno/monitor
wget -qO $varEntorno/online "$url/user-manager/monitor/online/online" && chmod +x $varEntorno/online
wget -qO $varEntorno/user-info "$url/user-managers/user-info" && chmod +x $varEntorno/user-info
wget -qO $varEntorno/aToken-mng "$url/aToken/aToken-mng" && chmod +x $varEntorno/aToken-mng
wget -qO $varEntorno/makeUser "$url/user-managers/makeUser" && chmod +x $varEntorno/makeUser
wget -qO $varEntorno/genssl "$url/genCert/genssl" && chmod +x $varEntorno/genssl
wget -qO $autoStart/sql "$url/Csqlite/sql" && chmod +x $autoStart/sql
wget -qO $varEntorno/banner "$url/banner/banner" && chmod +x $varEntorno/banner
wget -qO $varEntorno/monitor-m "$url/user-manager/monitor/monitor-m/monitor-m" && chmod +x $varEntorno/monitor-m
wget -qO $varEntorno/userSSH "$url/user-managers/userSSH/userSSH" && chmod +x $varEntorno/userSSH
wget -qO $varEntorno/userHWID "$url/user-managers/userHWID/userHWID" && chmod +x $varEntorno/userHWID
wget -qO $varEntorno/userTOKEN "$url/user-managers/userTOKEN/userTOKEN" && chmod +x $varEntorno/userTOKEN
wget -qO $autoStart/limit "$url/user-managers/limitador/limit" && chmod +x $autoStart/limit
${autoStart}/limit

wget -qO /etc/ADMRufu/uninstall "https://raw.githubusercontent.com/MARCELOSALVATIERRA926/Scripts-26072026/main/uninstall" && chmod +x /etc/ADMRufu/uninstall

rm -rf /etc/profile.d/rufu.sh
for i in $(ls $varEntorno); do ln -sf $varEntorno/$i /usr/bin/$i; done

rm -rf ${SCPinstal} /usr/bin/menu /usr/bin/adm
ln -sf /usr/bin/ADMRufu /usr/bin/menu
ln -sf /usr/bin/ADMRufu /usr/bin/adm
ln -sf ${ADMRufu}/reseller ${tmp}/message.txt
sed -i '/Rufu/d' /etc/bash.bashrc /root/.bashrc
echo 'source /etc/ADMRufu/bashrc' >> /etc/bash.bashrc
locale-gen en_US.UTF-8; update-locale LANG=en_US.UTF-8
echo -e "/bin/false" >> /etc/shells

clear; title "-- ADMRufU TU VERSION --"
mv -f ${module} ${ADMRufu}/module
time_reboot 10
