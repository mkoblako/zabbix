#!/usr/bin/env python
import re

with open('/tmp/tcpdump_output.txt', 'r') as file:
    lines = file.readlines()[-700:]

white_list_ips = ['100.20.76.137', '192.168.1.1', '10.0.0.1']

unauthorized_ips = []

for line in lines:
    parts = line.split()
    if len(parts) >= 7 and parts[1] == "IP":
        ip_matches = re.findall(r'\d+\.\d+\.\d+\.\d+', line)
        if len(ip_matches) >= 2:
            src_ip = ip_matches[0]
            dst_ip = ip_matches[1]
            if src_ip.startswith('195.248.225'):
               src_port = parts[2].split('.')[-1].split(':')[0]
               if src_port in ['80', '443'] and (dst_ip not in white_list_ips):
                  unauthorized_ips.append(dst_ip)

if unauthorized_ips:
    result = ",".join(set(unauthorized_ips))
    print(result)
else:
    print(" ")


