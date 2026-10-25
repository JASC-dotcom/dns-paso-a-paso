#!/usr/bin/env bash
# Install BIND9 on the primary server and restrict it to IPv4
set -euo pipefail
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

systemctl enable named
systemctl restart named
