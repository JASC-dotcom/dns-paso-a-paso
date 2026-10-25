# Documentation: primary and secondary DNS servers with BIND9

Environment (default values from `config/vars.env`):

| Machine | Hostname | IP |
|---|---|---|
| Primary | debian | 192.168.56.10 |
| Secondary | debian2 | 192.168.56.11 |

Domain: `joseantonio.test` · Reverse zone: `56.168.192.in-addr.arpa`

Deploy everything: `vagrant up`

## Contents

1. [Installing BIND on the servers](01-servers-installation.md)
2. [Configuring named.conf.options](02-named-conf-options.md)
3. [Zones on the primary server](03-primary-zones.md)
4. [Checking resolution with dig and nslookup](04-dig-nslookup-resolution.md)
5. [Adding records (CNAME, TXT, PTR)](05-adding-records.md)
6. [Checking authority (aa flag)](06-flag-aa.md)
7. [Self-check script (test.sh)](07-test-sh.md)
8. [Secondary server](08-secondary-server.md)
9. [Infrastructure as code with Vagrant](09-vagrant.md)