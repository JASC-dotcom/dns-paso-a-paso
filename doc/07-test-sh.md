# Self-check script (test.sh)

## Script contents

Command:

```bash
cat /vagrant/test.sh
```

Output:

```
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
```

The script reads the variables from `config/vars.env`, so it does not need to be edited. With the `primario` argument, it checks syntax, name resolution, and the `aa` flag; with `secundario`, it checks zone transfers.

## Running the script

Command (on `primario`):

```bash
bash /vagrant/test.sh primario
```

Output:

```
=== 1. File syntax checks ===
[OK] named.conf.options
[OK] named.conf (complete)
zone joseantonio.test/IN: loaded serial 2610251850
OK
[OK] Forward zone
zone 56.168.192.in-addr.arpa/IN: loaded serial 2610251850
OK
[OK] Reverse zone
=== 2. Name resolution checks ===
;; communications error to ::1#53: connection refused
;; communications error to ::1#53: connection refused
;; communications error to ::1#53: connection refused
192.168.56.10
;; communications error to ::1#53: connection refused
;; communications error to ::1#53: connection refused
;; communications error to ::1#53: connection refused
debian.joseantonio.test.
;; communications error to ::1#53: connection refused
;; communications error to ::1#53: connection refused
;; communications error to ::1#53: connection refused
"jasc-dotcom-github"
;; communications error to ::1#53: connection refused
;; communications error to ::1#53: connection refused
;; communications error to ::1#53: connection refused
debian.joseantonio.test.
=== 3. aa flag (local vs. external domain) ===
joseantonio.test    -> ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
google.es  -> ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
```

All syntax checks return `[OK]`, and the queries return the expected records.

## Running it on the secondary

Command (on `secundario`):

```bash
bash /vagrant/test.sh secundario
```

Output:

```
=== Secondary: zone transfers ===
[OK] named.conf
Primary serial   : 2610251850
Secondary serial : 2610251850
Secondary SOA (aa) -> ;; flags: qr aa ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3
192.168.56.10
debian.joseantonio.test.
```

The serial numbers on the primary and secondary match.

The script also runs automatically as the final provisioning step on each machine during `vagrant up`.