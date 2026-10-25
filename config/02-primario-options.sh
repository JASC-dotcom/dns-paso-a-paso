#!/usr/bin/env bash
# Primary server options: ACL, listening addresses and recursion
set -euo pipefail
source /vagrant/config/common.sh
LISTEN_IP="$PRIMARY_IP"

# Keep a backup of the original file (only the first time)
[ -f /etc/bind/named.conf.options.backup ] || cp /etc/bind/named.conf.options /etc/bind/named.conf.options.backup
render /vagrant/files/named.conf.options.tpl /etc/bind/named.conf.options

# Check the syntax before restarting
named-checkconf /etc/bind/named.conf.options
systemctl restart named
