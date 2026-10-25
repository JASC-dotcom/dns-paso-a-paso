#!/usr/bin/env bash
# Usage: test.sh [primario|secundario]   (default: primario)
ROLE="${1:-primario}"
source "$(dirname "$0")/config/common.sh"

if [ "$ROLE" = "primario" ]; then
  echo "=== 1. File syntax checks ==="
  named-checkconf /etc/bind/named.conf.options && echo "[OK] named.conf.options"
  named-checkconf && echo "[OK] named.conf (complete)"
  named-checkzone "$DOMAIN" /var/lib/bind/$DOMAIN.dns && echo "[OK] Forward zone"
  named-checkzone "$REV_ZONE.in-addr.arpa" /var/lib/bind/$DOMAIN.rev && echo "[OK] Reverse zone"

  echo "=== 2. Name resolution checks ==="
  dig @localhost debian.$DOMAIN A +short
  dig @localhost web.$DOMAIN CNAME +short
  dig @localhost $DOMAIN TXT +short
  dig @localhost -x $PRIMARY_IP +short

  echo "=== 3. aa flag (local vs. external domain) ==="
  echo -n "$DOMAIN    -> "; dig @localhost debian.$DOMAIN | grep -m1 'flags:'
  echo -n "google.es  -> "; dig @localhost www.google.es | grep -m1 'flags:'
else
  echo "=== Secondary: zone transfers ==="
  named-checkconf && echo "[OK] named.conf"
  echo -n "Primary serial   : "; dig @$PRIMARY_IP   $DOMAIN SOA +short | awk '{print $3}'
  echo -n "Secondary serial : "; dig @$SECONDARY_IP $DOMAIN SOA +short | awk '{print $3}'
  echo -n "Secondary SOA (aa) -> "; dig @$SECONDARY_IP $DOMAIN SOA +norecurse | grep -m1 'flags:'
  dig @$SECONDARY_IP debian.$DOMAIN A +short
  dig @$SECONDARY_IP -x $PRIMARY_IP +short
fi

# Never make the provisioning fail because of a check
exit 0
