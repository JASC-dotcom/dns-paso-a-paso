#!/usr/bin/env bash
# Allow zone transfers to the secondary server only
set -euo pipefail
source /vagrant/config/common.sh

# This template is named.conf.local with an allow-transfer line in each zone
render /vagrant/files/named.conf.local.primary-xfer.tpl /etc/bind/named.conf.local
named-checkconf
systemctl restart named
