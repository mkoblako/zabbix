#!/bin/bash
dirdw="/tmp/zabins"
dirins="/etc/zabbix/scripts"
dirag="/etc/zabbix/agentd.d"

mkdir $dirdw

if [ ! -d "$dirins"]; then
    mkdir $dirins
fi

wget -P $dirdw "https://raw.githubusercontent.com/mkoblako/zabbix/main/mon_zimbra.conf"
wget -P $dirdw "https://raw.githubusercontent.com/mkoblako/zabbix/main/zimbra_services.sh"
wget -P $dirdw "https://github.com/mkoblako/zabbix/blob/main/zimbra_version.sh"
wget -P $dirdw "https://github.com/mkoblako/zabbix/blob/main/sudo_zabbix_agent.conf"

cp $dirdw/sudo_zabbix_agent.conf /etc/sudoers.d
cp $dirdw/mon_zimbra.conf $dirag
cp $dirdw/zimbra_services.sh $dirins
cp $dirdw/zimbra_version.sh $dirins

systemctl restart zabbix-agent
