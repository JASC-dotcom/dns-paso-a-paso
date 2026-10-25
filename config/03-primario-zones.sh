#!/usr/bin/env bash
# Forward and reverse zones on the primary server
set -euo pipefail
source /vagrant/config/common.sh

# ---------- [phase A] declare the zones ----------
[ -f /etc/bind/named.conf.local.backup ] || cp /etc/bind/named.conf.local /etc/bind/named.conf.local.backup
render /vagrant/files/named.conf.local.primary.tpl /etc/bind/named.conf.local
named-checkconf
systemctl restart named

# ---------- [phase B] create the zone files ----------
render /vagrant/files/zona-directa.tpl /var/lib/bind/$DOMAIN.dns
render /vagrant/files/zona-inversa.tpl /var/lib/bind/$DOMAIN.rev
chown root:bind /var/lib/bind/$DOMAIN.dns /var/lib/bind/$DOMAIN.rev
chmod 644 /var/lib/bind/$DOMAIN.dns /var/lib/bind/$DOMAIN.rev

# Check both zone files before the final restart
named-checkzone "$DOMAIN." /var/lib/bind/$DOMAIN.dns
named-checkzone "$REV_ZONE.in-addr.arpa." /var/lib/bind/$DOMAIN.rev
systemctl restart named
