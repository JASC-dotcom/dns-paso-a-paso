#!/usr/bin/env bash
# Provisioning of the primary server. The blocks were added step by step.
# (see Git history). Block (restart) always goes at the end.
set -euo pipefail
source /vagrant/config/common.sh
LISTEN_IP="$PRIMARY_IP"
export DEBIAN_FRONTEND=noninteractive

### INSTALATION
apt-get update -y
apt-get install -y bind9 bind9-utils bind9-doc bind9-dnsutils

### ONLY IPv4 AND BACKUPS
sed -i 's/^OPTIONS=.*/OPTIONS="-u bind -4"/' /etc/default/named
for f in named.conf.options named.conf.local; do
  [ -f /etc/bind/$f.backup ] || cp /etc/bind/$f /etc/bind/$f.backup
done

### RESTART
systemctl restart named
systemctl --no-pager --lines=5 status named
