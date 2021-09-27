#!/bin/bash

# Flush all existing rules and set default policy
iptables -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Allow loopback traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow DNS queries only from VPN clients
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT

iptables -A FORWARD -i tun0 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -o tun0 -p udp --sport 53 -j ACCEPT

iptables -A FORWARD -i tun0 -o eth0 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -i eth0 -o tun0 -p udp --sport 53 -m state --state RELATED,ESTABLISHED -j ACCEPT

# Allow connection to OpenVPN server
iptables -A INPUT -p udp --dport 1194 -j ACCEPT
iptables -A OUTPUT -p udp --sport 1194 -m state --state RELATED,ESTABLISHED -j ACCEPT

# Allow VPN clients to connect to Squid proxy (Squid listening on 3128)
iptables -A INPUT -i tun0 -p tcp --dport 3128 -j ACCEPT
iptables -A OUTPUT -o tun0 -p tcp --sport 3128 -m state --state RELATED,ESTABLISHED -j ACCEPT

# Redirect all other HTTP and HTTPS traffic from VPN clients to Squid
iptables -t nat -A PREROUTING -i tun0 -p tcp -m multiport --dports 80,443,15000 -j DNAT --to-destination 127.0.0.1:3128

# Allow Squid to access the internet
iptables -A OUTPUT -o eth0 -p tcp -m multiport --dports 80,443,15000 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p tcp -m multiport --sports 80,443,15000 -m state --state RELATED,ESTABLISHED -j ACCEPT
