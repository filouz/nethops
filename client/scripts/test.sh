#!/bin/bash

# Define the proxy server details
PROXY_SERVER="192.168.255.1:3128"

# Read domains from the config file
while IFS= read -r line || [[ -n "$line" ]]
do
    [[ $line = \#* ]] || [[ -z $line ]] && continue
    domains+=("$line")
done < domains_test.conf

# Iterate through the list of domains
for domain in "${domains[@]}"
do
    IP_DOMAIN=$(dig +short ${domain} | head -n 1)

    if [ -z "${IP_DOMAIN}" ]; then
        echo "Failed to resolve IP address for ${domain}"
        continue
    fi

    HEADERS=$(curl --connect-timeout 3 --max-time 3 -I --proxy $PROXY_SERVER --verbose -s https://${domain} 2>&1)

    IP_ADDRESS=$(echo "$HEADERS" | awk '/Trying/ {gsub(/\.\.\.$/, "", $NF); print $NF}' | head -n 1) 

    if echo "$HEADERS" | grep -q "X-Squid-Error: "; then
        echo "Failed: ${domain} $IP_ADDRESS / $IP_DOMAIN"
    elif echo "$HEADERS" | grep -q "TLS handshake, Finished"; then
        echo "Success: ${domain} $IP_ADDRESS / $IP_DOMAIN"
    else
        echo "Fatal: ${domain} $IP_ADDRESS / $IP_DOMAIN"
    fi
done
