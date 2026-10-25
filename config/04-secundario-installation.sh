#!/usr/bin/env bash
# Install BIND9 on the secondary server, restrict it to IPv4 and set its options
set -euo pipefail
source /vagrant/config/common.sh
LISTEN_IP="$SECONDARY_IP"
export DEBIAN_FRONTEND=noninteractive

# BIND and its tools (dig and nslookup come with dnsutils)
apt-get update -y
apt-get install -y bind9 bind9utils bind9-doc dnsutils

# IPv4 only: set "-4" in /etc/default/named (add the line if it does not exist)
if grep -q '^OPTIONS=' /etc/default/named; then
  sed -i 's/^OPTIONS=.*/OPTIONS="-u bind -4"/' /etc/default/named
else
  echo 'OPTIONS="-u bind -4"' >> /etc/default/named
fi

# Same ACL as the primary, listening on the secondary's own IP address
[ -f /etc/bind/named.conf.options.backup ] || cp /etc/bind/named.conf.options /etc/bind/named.conf.options.backup
render /vagrant/files/named.conf.options.tpl /etc/bind/named.conf.options

named-checkconf
systemctl enable named
systemctl restart named
