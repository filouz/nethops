#!/bin/bash

# Variables
CLIENT_ID=$1
DEFAULT_DIR="/ovpn"
DEFAULT_SCRIPT_DIR="/scripts"

# Directory passed as an argument, or the default
DIR=${2:-$DEFAULT_DIR}
SCRIPT_DIR=${3:-$DEFAULT_SCRIPT_DIR}

# Create a secure temporary file
TMP_OVPN_FILE=$(mktemp)

# Check if client.ovpn exists
if [ -f "$DIR/client$CLIENT_ID.ovpn" ]; then
    # If a custom script directory is provided, replace in .ovpn file
    if [ -n "$3" ]; then
        sed "s|$DEFAULT_SCRIPT_DIR|$SCRIPT_DIR|g" "$DIR/client$CLIENT_ID.ovpn" > "$TMP_OVPN_FILE"
    else
        cp "$DIR/client$CLIENT_ID.ovpn" "$TMP_OVPN_FILE"
    fi

    # Secure the permissions of the temporary file
    chmod 600 "$TMP_OVPN_FILE"
    

    # Check if client.pwd exists
    if [ -f "$DIR/client.pwd" ]; then
        openvpn --script-security 2 --config "$TMP_OVPN_FILE" --askpass "$DIR/client.pwd"
    else
        openvpn --script-security 2 --config "$TMP_OVPN_FILE"
    fi

    # Remove temporary file
    rm -f "$TMP_OVPN_FILE"
else
    echo "client$CLIENT_ID.ovpn not found in $DIR"
fi
