#!/usr/bin/env bash
# Slave zones on the secondary server
set -euo pipefail
source /vagrant/config/common.sh

[ -f /etc/bind/named.conf.local.backup ] || cp /etc/bind/named.conf.local /etc/bind/named.conf.local.backup
render /vagrant/files/named.conf.local.secondary.tpl /etc/bind/named.conf.local
# Do NOT create zone files here: they are transferred from the primary

named-checkconf
systemctl restart named

# Wait for the zones to be transferred (max. 30 s; do not fail if they do not arrive)
for i in $(seq 1 15); do
  [ -s /var/cache/bind/$DOMAIN.dns ] && [ -s /var/cache/bind/$DOMAIN.rev ] && break
  sleep 2
done
ls -l /var/cache/bind/ || true
