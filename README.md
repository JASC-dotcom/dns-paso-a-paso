# DNS step by step: primary server and secondary server with BIND9

Author: Jose Antonio Santiago Cabrera

A DNS server (BIND9) running on two Debian 12 virtual machines connected to a
private network (`192.168.56.0/24`): a **primary** (master) server and a
**secondary** (slave) server that receives zones via transfer.
The entire deployment is automated using Vagrant.

## Network Schema

| Server | Hostname | Role | Address |
|---|---|---|---|
| primary | `debian` | Master DNS for `joseantonio.test` | `eth0`: Vagrant NAT, `eth1`: 192.168.56.10/24 |
| secondary | `debian2` | Slave DNS (receives zones from the primary DNS server) | `eth0`: Vagrant NAT, `eth1`: 192.168.56.11/24 |

The `.1` address on the network is reserved for the host's *host-only* adapter.

## DNS Configuration Summary

- Software: `bind9`, `bind9-utils`, `bind9-doc`, and `bind9-dnsutils` (`dig`, `nslookup`).
- IPv4 only (`OPTIONS="-u bind -4"` in `/etc/default/named`).
- Forward zone: `joseantonio.test`. Reverse zone: `56.168.192.in-addr.arpa`.
- ACL `confiables` (127.0.0.1 and 192.168.56.0/24): only these clients can make recursive queries.
- `listen-on` on port 53 on localhost and each server's private IP address.
- `dnssec-validation yes`; `listen-on-v6` is disabled.
- Global `allow-transfer { none; }`; each zone on the primary server authorizes only the secondary server's IP address.
- Records: SOA, NS (`debian` and `debian2`), A, CNAME (`web`), TXT (zone apex), and PTR.
- The zone serial is generated during each provisioning run using the `YYMMDDhhmm` format.

## Repository Structure

```
.
├── Vagrantfile                      # primary and secondary machines
├── test.sh                          # self-test script
├── .gitignore                       # ignores .vagrant/
├── .gitattributes                   # enforces LF line endings in scripts
├── config/                          # provisioning scripts and variables
│   ├── vars.env                     # only file to edit (domain, network, IPs, TXT)
│   ├── common.sh                    # derived variables and template function
│   ├── 01-primario-installation.sh  # primary: BIND installation, IPv4 only
│   ├── 02-primario-options.sh       # primary: named.conf.options
│   ├── 03-primario-zones.sh         # primary: forward and reverse zones
│   ├── 04-secundario-installation.sh # secondary: installation, IPv4 only, options
│   ├── 05-secundario-zones.sh       # secondary: slave zones
│   └── 06-primario-transfers.sh     # primary: allow zone transfers to the secondary
├── files/                           # templates for files copied to the VMs
│   ├── named.conf.options.tpl
│   ├── named.conf.local.primary.tpl
│   ├── named.conf.local.primary-xfer.tpl   # same zones + allow-transfer
│   ├── named.conf.local.secondary.tpl
│   ├── zona-directa.tpl             # forward zone
│   └── zona-inversa.tpl             # reverse zone
└── doc/                             # step-by-step documentation, including commands and output
    └── img/                         # screenshots
```

## How to Run It

Edit `config/vars.env` (domain, network, IPs, and TXT value), then run:

```bash
vagrant up
```

The primary server is created first, followed by the secondary server. Each
machine runs its numbered scripts in the order defined in the `Vagrantfile`
and finishes with `test.sh`. To repeat the tests:

```bash
vagrant ssh primario -c "bash /vagrant/test.sh primario"
vagrant ssh secundario -c "bash /vagrant/test.sh secundario"
```

To start over from scratch: `vagrant destroy -f && vagrant up`.

## Documentation

The full index is available in [doc/README.md](doc/README.md).

| Step | Document |
|---|---|
| 1. Installing BIND on the servers | [doc/01-servers-installation.md](doc/01-servers-installation.md) |
| 2. Configuring `named.conf.options` | [doc/02-named-conf-options.md](doc/02-named-conf-options.md) |
| 3. Zones on the primary server | [doc/03-primary-zones.md](doc/03-primary-zones.md) |
| 4. Testing with `dig` and `nslookup` | [doc/04-dig-nslookup-resolution.md](doc/04-dig-nslookup-resolution.md) |
| 5. Adding records (CNAME, TXT, PTR) | [doc/05-adding-records.md](doc/05-adding-records.md) |
| 6. Verifying authority (the `aa` flag) | [doc/06-flag-aa.md](doc/06-flag-aa.md) |
| 7. Self-test script (`test.sh`) | [doc/07-test-sh.md](doc/07-test-sh.md) |
| 8. Secondary server | [doc/08-secondary-server.md](doc/08-secondary-server.md) |
| 9. Infrastructure as code with Vagrant | [doc/09-vagrant.md](doc/09-vagrant.md) |

## Status

- [ ] Steps 1–3: primary server with forward and reverse zones.
- [ ] Steps 4–7: tests, additional records, and `test.sh`.
- [ ] Step 8: secondary server and zone transfers.
- [ ] Step 9: complete deployment with `vagrant up` and no errors.

## Notes

- Before testing, remove any domain entries from `/etc/hosts` (Linux) or `C:\Windows\System32\drivers\etc\hosts` (Windows) so that name resolution actually uses the DNS server.
- The files in `files/` are templates: the provisioning scripts replace the variables from `config/vars.env` and copy the files to the virtual machine (`/etc/bind/` and `/var/lib/bind/`).
- The secondary server's zones are not created manually: the primary transfers them, and BIND stores them in `/var/cache/bind/`.
- If you edit a zone manually, increment its serial; provisioning generates a new one automatically.
- The `.sh` files must use LF line endings; `.gitattributes` ensures this when cloning on Windows.
