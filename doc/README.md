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
