
#!/bin/bash

input_file="/tmp/tcpdump_output.pcap"
output_file="/tmp/tcpdump_output.txt"

rm "$input_file"
rm "$output_file"

ports="port 80 or port 443"

pid=$(ps -e | pgrep tcpdump)
sleep 5
kill -2 $pid

touch "$input_file"

/usr/sbin/tcpdump -i eth0 $ports -U -a -w $input_file &
while true; do
    if ! /usr/sbin/tcpdump -r "$input_file" -nn -q -G 60 >> "$output_file"; then
        sleep 60
    else
       break
    fi
done
