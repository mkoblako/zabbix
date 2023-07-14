#!/bin/bash

dirdw="/tmp/zabins"
dirins="/etc/zabbix/scripts"
dirag="/etc/zabbix/zabbix_agentd.d"

if [ ! -d "$dirdw"]; then
    mkdir -p "$dirdw"
fi

if [ ! -d "$dirins" ]; then
    mkdir -p "$dirins"
fi

# Скачивание файлов во временную директорию
wget -P "$dirdw" "https://raw.githubusercontent.com/mkoblako/zabbix/main/mon_zimbra.conf"
wget -P "$dirdw" "https://raw.githubusercontent.com/mkoblako/zabbix/main/zimbra_services.sh"
wget -P "$dirdw" "https://raw.githubusercontent.com/mkoblako/zabbix/main/zimbra_version.sh"
wget -P "$dirdw" "https://raw.githubusercontent.com/mkoblako/zabbix/main/sudo_zabbix_agent"


if [ $? -eq 0 ]; then
    echo "Файлы успешно скачаны."
else
    echo "Ошибка при скачивании файлов."
    exit 1
fi

# Копирование скриптов и конфигов
sudo cp "$dirdw/sudo_zabbix_agent" /etc/sudoers.d
cp "$dirdw/mon_zimbra.conf" "$dirag"
cp "$dirdw/zimbra_services.sh" "$dirins"
cp "$dirdw/zimbra_version.sh" "$dirins"


if [ $? -eq 0 ]; then
    echo "Файлы успешно скопированы."
else
    echo "Ошибка при копировании файлов."
    exit 1
fi

sudo chmod +x "$dirins/zimbra_services.sh"
sudo chmod +x "$dirins/zimbra_version.sh"

sudo systemctl restart zabbix-agent


if [ $? -eq 0 ]; then
    echo "Служба zabbix-agent успешно перезапущена."
else
    echo "Ошибка при перезапуске службы zabbix-agent."
    exit 1
fi

exit 0