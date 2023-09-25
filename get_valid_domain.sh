#!/bin/bash

convert_date() {
  date_string="$1"

  # convert string date to seconds
  date_in_seconds=$(date -d "$date_string" +"%s")

  # Convert seconds to format "20220101" for zabbix function date()
  formatted_date=$(date -d "@$date_in_seconds" +"%Y%m%d")

  echo "$formatted_date"
}

case "$1" in
  discovery)

    # Get zmxs ip
    eth0_ip=$(sudo /sbin/ip addr show eth0 | awk '/inet /{print $2}' | cut -d/ -f1)

    if [ -z "$eth0_ip" ]; then
    echo "ERROR: can't get zmxs ip."
    exit 1
    fi

    # Get all domains
    domains=$(sudo -u zimbra /opt/zimbra/bin/zmprov gad)

    valid_domains=()

    # Get A domain's records
    for domain in $domains; do
      # Get domain's ip
      domain_ip=$(nslookup "$domain" | awk '/^Address: /{print $2}' | head -n 1)
      if [ "$domain_ip" == "$eth0_ip" ]; then
        valid_domains+=("$domain")
      else
        mail_domain="mail.${domain}"
        mail_ip=$(nslookup "$mail_domain" | awk '/^Address: /{print $2}' | head -n 1)
          if [ "$mail_ip" == "$eth0_ip" ]; then
          valid_domains+=("$mail_domain")
          fi
      fi
    done

    first_iteration=true
    echo -n '{"data":['

    for domain_name in "${valid_domains[@]}"; do
      if [ "$first_iteration" = false ]; then
        echo -n ','
      else
        first_iteration=false
      fi
      echo -n "{\"{#DOMAIN}\": \"$domain_name\"}"
    done

    echo -n ']}'
  ;;
  *)

   domain_cert="https://"$1""

   if result=$(openssl s_client -servername "$1" -connect "$1":443 </dev/null 2>/dev/null); then
        response=$(curl -s -o /dev/null -w "%{http_code}" "$domain_cert")
        if [ "$response" != "200" ]; then
            if [[ "$response" == *"000"* ]]; then
                echo 0
            else
                echo "domain: "$1" has error : $response)"
            fi
        else
            expiration_date=$(echo "$result" | openssl x509 -noout -enddate | cut -d= -f2)
            echo "$(convert_date "$expiration_date")"
        fi
    else
        echo "openssl error"
    fi
  ;;
esac
