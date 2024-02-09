#!/bin/bash
#basicApache configs v1.0

ECHO="/usr/bin/echo"
APACHECTL="/usr/sbin/apachectl"
SED="/usr/bin/sed"

if [ "$EUID" -ne 0 ]; then
	$ECHO "É necessario executar com privilégios de root"
	$ECHO "Ex: sudo ./basicapache.sh"
	exit 1
else
	#preparando efeitos pirotecnicos:3
	steps=50
	for ((i=1; i<=steps;i++)); do
		percentage=$((i * 100 / steps))
		$ECHO -ne "Progresso: ["
    		for ((j=0; j<i; j++)); do
        		$ECHO -ne "#"
    		done
    		for ((j=i; j<total_steps; j++)); do
        		$ECHO -ne " "
    		done
    		$ECHO -ne "] $percentage% \r"

    	# Simula algum trabalho
    		sleep 0.01

	done
	$ECHO ""
fi

APACHE_CONF="/etc/apache2/apache2.conf"
APACHE_SEC="/etc/apache2/conf-enabled/security.conf"
APACHE_MODS="/etc/apache2/mods-enabled"
#APACHE_SITES_ENABLE="/etc/apache2/sites-enabled"

#Backup apache2.conf e security.conf
/usr/bin/cp "$APACHE_CONF" "/etc/apache2/backup_apache2.conf"
/usr/bin/cp "$APACHE_SEC" "/etc/apache2/conf-enabled/backup_security.conf"

$ECHO "[Backup dos arquivos padrão foram criados]"
sleep 1.0

#Modificando arquivos
$SED -i 's/Options Indexes FollowSymLinks/Options FollowSymLinks/g' "$APACHE_CONF" #index of solved;
$SED -i 's/ServerTokens OS/ServerTokens Prod/' "$APACHE_SEC" #banner grabbing solved
$SED -i 's/ServerSignature On/ServerSignature Off/' "$APACHE_SEC"

$ECHO "[Arquivos modificados]"
$ECHO " $APACHE_CONF"
$ECHO " $APACHE_SEC"
sleep 1.0

#instalando mod evasive
if $APACHECTL -M | /usr/bin/grep 'evasive20_module' >/dev/null; then
	$ECHO "[MOD_EVASIVE encontrado]"

else
	$ECHO "[Instalando mod-evasive]"
        apt-get install libapache2-mod-evasive -y >/dev/null
	if $APACHECTL -M | /usr/bin/grep 'evasive20_module' > /dev/null; then
		continue
	else
		$ECHO -e "\e[1;91mAVISO: NÃO FOI POSSIVEL INSTALAR O MOD_EVASIVE \e[0m"
	fi
fi

#instalando mod security
if $APACHECTL -M |/usr/bin/grep 'security2_module' >/dev/null; then
        $ECHO "[MOD_SECURITY encontrado]"

else
        $ECHO "[Instalando mod-security]"
        apt-get install libapache2-mod-security2 -y > /dev/null
	if $APACHECTL -M | /usr/bin/grep 'security2_module' >/dev/null; then
		MOD_SECURITY_PATH="/etc/modsecurity/"
		/usr/bin/cp "$MOD_SECURITY_PATH/modsecurity.conf-recommended" "$MOD_SECURITY_PATH/modsecurity.conf"
		continue
	else
		$ECHO -e "\e[1;91mAVISO: NÃO FOI POSSIVEL INSTALAR O MOD_SECURITY \e[0m"
	fi

fi

$ECHO "[Baixando OWASP-CRS:  https://github.com/coreruleset/coreruleset/archive/v3.3.0.zip]"

/usr/bin/mkdir ./crs_zip
/usr/bin/wget -P ./crs_zip  https://github.com/coreruleset/coreruleset/archive/v3.3.0.zip -O ./crs_zip/coreruleset.zip
/usr/bin/unzip ./crs_zip/coreruleset.zip -d ./crs_zip

/usr/bin/mv ./crs_zip/coreruleset-3.3.0/crs-setup.conf.example /etc/modsecurity/crs-setup.conf
/usr/bin/mv ./crs_zip/coreruleset-3.3.0/rules /etc/modsecurity/

$SED -i '/IncludeOptional \/usr\/share\/modsecurity-crs\/\*\.load/s/^\(\s*\)/\1# /' "$APACHE_MODS/security2.conf"
$SED -i '/<\/IfModule>/i \ \ \ \ \ \ \ \ IncludeOptional \/etc\/modsecurity/rules/*.conf' "$APACHE_MODS/security2.conf"

service apache2 restart
$ECHO "Apache configurado =)"
