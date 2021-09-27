#!/bin/bash

RESOLV_CONF_BACKUP_PATH="/tmp/resolv.conf.bak"
# PROXY_SERVER=$route_vpn_gateway
PROXY_SERVER="192.168.255.1"
PROXY_PORT=3128
PROXY_URI="http://$PROXY_SERVER:$PROXY_PORT"
PROXY_BACKUP_PATH="/tmp/proxy.bak"
ZSHRC_PATH="/root/.zshrc"


extract_dns_servers() {
  local dns_servers=()
  for opt in foreign_option_1 foreign_option_2; do
    if [[ "${!opt}" == dhcp-option\ DNS* ]]; then
      dns_servers+=("${!opt#dhcp-option DNS }")
    fi
  done
  echo "${dns_servers[@]}"
}


case "$script_type" in
  up)
    case "$OSTYPE" in
      linux*)
        # Linux detected
        # Backup original resolv.conf and proxy settings
        cp /etc/resolv.conf $RESOLV_CONF_BACKUP_PATH
        echo $http_proxy > $PROXY_BACKUP_PATH
        # Clear resolv.conf and use custom DNS
        echo -n "" > /etc/resolv.conf 
        for DNS_SERVER in $(extract_dns_servers); do
          echo "nameserver $DNS_SERVER" >> /etc/resolv.conf 
        done
        # Setup proxy
        export http_proxy=$PROXY_URI
        export https_proxy=$PROXY_URI
        # Update .zshrc with new proxy settings
        if grep -q "export http_proxy" $ZSHRC_PATH; then
          sed -i "s|export http_proxy=.*|export http_proxy=$PROXY_URI|" $ZSHRC_PATH
        else
          echo "export http_proxy=$PROXY_URI" >> $ZSHRC_PATH
        fi
        if grep -q "export https_proxy" $ZSHRC_PATH; then
          sed -i "s|export https_proxy=.*|export https_proxy=$PROXY_URI|" $ZSHRC_PATH
        else
          echo "export https_proxy=$PROXY_URI" >> $ZSHRC_PATH
        fi
        ;;
      darwin*)
        # macOS detected
        for DNS_SERVER in $(extract_dns_servers); do
          /usr/sbin/networksetup -setdnsservers Wi-Fi $DNS_SERVER
        done
        # Backup and setup proxy
        # /usr/sbin/networksetup -getwebproxy Wi-Fi | grep Server > $PROXY_BACKUP_PATH
        /usr/sbin/networksetup -setwebproxy Wi-Fi $PROXY_SERVER 3128
        /usr/sbin/networksetup -setsecurewebproxy Wi-Fi $PROXY_SERVER 3128
        ;;
      msys*)
        # Windows detected - assuming we're using WSL. 
        echo "Cannot change DNS and Proxy settings from Windows Subsystem for Linux."
        ;;
      *)
        echo "Unknown operating system."
        ;;
    esac
    ;;
  down)
    case "$OSTYPE" in
      linux*)
        # Linux detected
        # Restore original resolv.conf and proxy settings from backup
        if [ -f $RESOLV_CONF_BACKUP_PATH ]; then
          cat $RESOLV_CONF_BACKUP_PATH > /etc/resolv.conf
        else
          echo "Backup resolv.conf not found. Not restoring DNS settings."
        fi
        if [ -f $PROXY_BACKUP_PATH ]; then
          export http_proxy=$(cat $PROXY_BACKUP_PATH)
          export https_proxy=$(cat $PROXY_BACKUP_PATH)
          # Restore original proxy settings in .zshrc
          sed -i "s|export http_proxy=.*|export http_proxy=$(cat $PROXY_BACKUP_PATH)|" $ZSHRC_PATH
          sed -i "s|export https_proxy=.*|export https_proxy=$(cat $PROXY_BACKUP_PATH)|" $ZSHRC_PATH
        else
          echo "Backup proxy not found. Not restoring Proxy settings."
          sed -i '/export http_proxy/d' $ZSHRC_PATH
          sed -i '/export https_proxy/d' $ZSHRC_PATH
        fi
        ;;
      darwin*)
        # macOS detected
        /usr/sbin/networksetup -setdnsservers Wi-Fi empty
        # Restore proxy settings
        /usr/sbin/networksetup -setwebproxy Wi-Fi "" ""
        /usr/sbin/networksetup -setsecurewebproxy Wi-Fi "" ""
        /usr/sbin/networksetup -setwebproxystate Wi-Fi off
        /usr/sbin/networksetup -setsecurewebproxystate Wi-Fi off

        # if [ -f $PROXY_BACKUP_PATH ]; then
        #   PROXY_BACKUP=$(cat $PROXY_BACKUP_PATH | awk '{print $2}')
        #   /usr/sbin/networksetup -setwebproxy Wi-Fi $PROXY_BACKUP
        #   /usr/sbin/networksetup -setsecurewebproxy Wi-Fi $PROXY_BACKUP
        # else
        #   echo "Backup proxy not found. Not restoring Proxy settings."
        # fi
        ;;
      msys*)
        # Windows detected - assuming we're using WSL. 
        echo "Cannot change DNS and Proxy settings from Windows Subsystem for Linux."
        ;;
      *)
        echo "Unknown operating system."
        ;;
    esac
    ;;
  *)
    echo "Unknown action '$script_type'. Expected 'up' or 'down'."
    ;;
esac
