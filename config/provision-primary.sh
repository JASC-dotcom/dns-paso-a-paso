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

### RESTART
systemctl restart named
systemctl --no-pager --lines=5 status named
