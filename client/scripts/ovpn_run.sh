#!/bin/bash

if [ -f /ovpn/client$1.ovpn ]; then
    if [ -f /ovpn/client.pwd ]; then
        openvpn --script-security 2 --config /ovpn/client$1.ovpn --askpass /ovpn/client.pwd
    else
        openvpn --script-security 2 --config /ovpn/client$1.ovpn
    fi
else
    echo "client$1.ovpn not found"
fi