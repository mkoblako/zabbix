#!/bin/bash

if [[ -z "$1" ]]; then
  exit 1
fi

zimbra_log_file="/var/log/zimbra-stats.log"
zimbra_discovery="$(tail -n 1000 /var/log/zimbra-stats.log | grep STATUS | cut -d ':' -f 10 | sort | uniq)"


# мониторинг служб
case "$1" in
    discovery)
        echo -n '{"data":['
        # Проверяем, существует ли файл лога
        if [ ! -f "$zimbra_log_file" ]; then
            echo "zimbra-stats.log doesn't exist"
            exit 1
        fi
        
        for service in $zimbra_discovery; do
            echo -n "{\"{#ZIMBRASERVICE}\": \"$service\"},";
        done |sed -e 's:\},$:\}:'
        echo -n ']}'
    exit 0;
    ;;
    *)
        if [ $1 = "" ]; then
          echo "ERROR: argument required"
          exit 1
        fi

        # Проверяем, содержит ли файл лога строки с ключевым словом "STATUS"
        if ! /usr/bin/tail -n 1000 "$zimbra_log_file" | grep "STATUS" >/dev/null; then
          echo "zimbra-stats.log doesn't contain STATUS entries"
          exit 1
        fi
        state="$(/usr/bin/tail -n 1000 $zimbra_log_file | grep STATUS | tail -1 | awk '{print $NF}')"

        if [ "$state" != "Running" ]; then
          echo 0
        else
          echo 1
        fi
    ;;
esac