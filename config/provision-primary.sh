#!/usr/bin/env bash
# Provisión del servidor primario. Los bloques se fueron añadiendo paso a paso
# (ver historial de Git). El bloque [6] (reinicio) va siempre al final.
set -euo pipefail
source /vagrant/config/common.sh
LISTEN_IP="$PRIMARY_IP"
export DEBIAN_FRONTEND=noninteractive

### INSTALATION
apt-get update -y
apt-get install -y bind9 bind9-utils bind9-doc bind9-dnsutils

### RESTART
systemctl restart named
systemctl --no-pager --lines=5 status named