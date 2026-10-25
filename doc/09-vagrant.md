# Infrastructure as code with Vagrant

## Configuration variables

Command:

```bash
cat /vagrant/config/vars.env
```

Output:

```
# The ONLY file you need to edit.
# Domain: joseantonio.test -> replace "joseantonio" with your own name
DOMAIN=joseantonio.test
# Private network 192.168.X (X = 56 or 57; never use .1, which belongs to the host)
NET=192.168.56
PRIMARY_LAST=10
SECONDARY_LAST=11
# TXT record value (your GitHub username or full name)
TXT_VALUE="jasc-dotcom-github"
```

This is the only file you need to edit: the domain, network, IP addresses, and TXT record value.

## Vagrantfile

Command:

```bash
cat /vagrant/Vagrantfile
```

Output:

```
# -*- mode: ruby -*-
# Read the variables from config/vars.env
vars = File.readlines(File.join(__dir__, "config", "vars.env"))
           .map(&:strip).reject { |l| l.empty? || l.start_with?("#") }
           .map { |l| l.split("=", 2) }.to_h.transform_values { |v| v.delete('"') }

PRIMARY_IP   = "#{vars['NET']}.#{vars['PRIMARY_LAST']}"
SECONDARY_IP = "#{vars['NET']}.#{vars['SECONDARY_LAST']}"

Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"
  config.vm.synced_folder ".", "/vagrant"

  # Primary (master) server
  config.vm.define "primario" do |p|
    p.vm.hostname = "debian"
    p.vm.network "private_network", ip: PRIMARY_IP
    p.vm.provision "shell", path: "config/01-primario-installation.sh"
    p.vm.provision "shell", path: "config/02-primario-options.sh"
    p.vm.provision "shell", path: "config/03-primario-zones.sh"
    p.vm.provision "shell", path: "config/06-primario-transfers.sh"
    p.vm.provision "shell", inline: "bash /vagrant/test.sh primario"
  end

  # Secondary (slave) server: it is created after the primary
  config.vm.define "secundario" do |s|
    s.vm.hostname = "debian2"
    s.vm.network "private_network", ip: SECONDARY_IP
    s.vm.provision "shell", path: "config/04-secundario-installation.sh"
    s.vm.provision "shell", path: "config/05-secundario-zones.sh"
    s.vm.provision "shell", inline: "bash /vagrant/test.sh secundario"
  end
end
```

It defines the `primario` and `secundario` machines, each with its private IP address and its provisioning scripts (installation, configuration, and `test.sh` at the end).

## Provisioning scripts

Command:

```bash
tail -n +1 config/0*.sh
```

Output:

```
==> config/01-primario-installation.sh <==
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

==> config/02-primario-options.sh <==
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

==> config/03-primario-zones.sh <==
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

==> config/04-secundario-installation.sh <==
#!/usr/bin/env bash
# Install BIND9 on the secondary server, restrict it to IPv4 and set its options
set -euo pipefail
source /vagrant/config/common.sh
LISTEN_IP="$SECONDARY_IP"
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

# Same ACL as the primary, listening on the secondary's own IP address
[ -f /etc/bind/named.conf.options.backup ] || cp /etc/bind/named.conf.options /etc/bind/named.conf.options.backup
render /vagrant/files/named.conf.options.tpl /etc/bind/named.conf.options

named-checkconf
systemctl enable named
systemctl restart named

==> config/05-secundario-zones.sh <==
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

==> config/06-primario-transfers.sh <==
#!/usr/bin/env bash
# Allow zone transfers to the secondary server only
set -euo pipefail
source /vagrant/config/common.sh

# This template is named.conf.local with an allow-transfer line in each zone
render /vagrant/files/named.conf.local.primary-xfer.tpl /etc/bind/named.conf.local
named-checkconf
systemctl restart named
```

Each script handles one part: installation (`01`, `04`), options (`02`), zones (`03`, `05`), and transfers (`06`). They run in the order specified in the `Vagrantfile`.

## Deployment

Commands:

```bash
vagrant destroy -f
vagrant up
```

With a single `vagrant up`, both the primary and secondary are installed, configured, and checked, with no manual steps.