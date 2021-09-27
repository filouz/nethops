#!/bin/bash

declare -A IP_MAP

# Read domains from the config file
while IFS= read -r line || [[ -n "$line" ]]
do
    [[ $line = \#* ]] || [[ -z $line ]] && continue
    domains+=("$line")
done < /scripts/domains.conf

# Populate the IP_MAP with IP addresses for each domain
for domain in "${domains[@]}"; do
  IP_LIST=($(dig +short "$domain" | grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}'))
  if [ ${#IP_LIST[@]} -gt 0 ]; then
    IP_MAP["$domain"]=${IP_LIST[@]}
  else
    echo "Unable to resolve IP for domain: $domain"
  fi
done

# Flush all existing rules and set default policy
iptables -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Allow loopback traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT


# allow dns traffic
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT

iptables -A FORWARD -i tun0 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -o tun0 -p udp --sport 53 -j ACCEPT


# allow openvpn traffic
iptables -A INPUT -p udp --dport 1194 -j ACCEPT
iptables -A OUTPUT -p udp --sport 1194 -j ACCEPT

# Allow traffic to predefined domains and their subdomains
for domain in "${domains[@]}"; do
  IP_LIST=(${IP_MAP["$domain"]})
  for IP in "${IP_LIST[@]}"; do
    if [ -n "$IP" ]; then
      echo "Allowing domain: $domain ($IP)"

      iptables -A OUTPUT -p tcp -d "$IP" -m multiport --dports 80,443 -j ACCEPT
      iptables -A INPUT -i tun0 -s "$IP" -j ACCEPT
      iptables -A FORWARD -i tun0 -d "$IP" -j ACCEPT
      iptables -A FORWARD -o tun0 -s "$IP" -j ACCEPT
    else
      echo "Unable to resolve IP for domain: $domain"
    fi
  done
done


# Allow related/established traffic
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT



echo "VPN client access restricteddomains and its subdomains. Other traffic is blocked."
