# Installing BIND on the primary and secondary servers

## Network interfaces (primary)

Command (on `primario`):

```bash
ip a
```

Output:

```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:8d:c0:4d brd ff:ff:ff:ff:ff:ff
    altname enp0s3
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 85883sec preferred_lft 85883sec
    inet6 fd17:625c:f037:2:a00:27ff:fe8d:c04d/64 scope global dynamic mngtmpaddr
       valid_lft 86193sec preferred_lft 14193sec
    inet6 fe80::a00:27ff:fe8d:c04d/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:fe:df:b9 brd ff:ff:ff:ff:ff:ff
    altname enp0s8
    inet 192.168.56.10/24 brd 192.168.56.255 scope global eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fefe:dfb9/64 scope link
       valid_lft forever preferred_lft forever
```

The `eth1` interface has IP address `192.168.56.10/24` (private network `192.168.56.0/24`). `eth0` is Vagrant's NAT adapter.

## Network interfaces (secondary)

Command (on `secundario`):

```bash
ip a
```

Output:

```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:8d:c0:4d brd ff:ff:ff:ff:ff:ff
    altname enp0s3
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 86197sec preferred_lft 86197sec
    inet6 fd17:625c:f037:2:a00:27ff:fe8d:c04d/64 scope global dynamic mngtmpaddr
       valid_lft 86198sec preferred_lft 14198sec
    inet6 fe80::a00:27ff:fe8d:c04d/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:92:4c:a4 brd ff:ff:ff:ff:ff:ff
    altname enp0s8
    inet 192.168.56.11/24 brd 192.168.56.255 scope global eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe92:4ca4/64 scope link
       valid_lft forever preferred_lft forever
```

The `eth1` interface has IP address `192.168.56.11/24`, the next address after the primary's.

## Package installation

Command (on both servers):

```bash
dpkg -l | grep -E "bind9|dnsutils"
```

Output:

```
vagrant@debian:~$ dpkg -l | grep -E "bind9|dnsutils"
ii  bind9-dnsutils                1:9.18.28-1~deb12u2            amd64        Clients provided with BIND 9
ii  bind9-host                    1:9.18.28-1~deb12u2            amd64        DNS Lookup Utility
ii  bind9-libs:amd64              1:9.18.28-1~deb12u2            amd64        Shared Libraries used by BIND 9
```

`bind9`, `bind9-utils`, `bind9-doc`, and `bind9-dnsutils` are installed (on Debian 12, `bind9utils` and `dnsutils` are transitional packages for these). The provisioning scripts (`config/01-primario-instalacion.sh` and `config/04-secundario-instalacion.sh`) install them without manual intervention.

## IPv4 only

Command:

```bash
grep OPTIONS /etc/default/named
```

Output:

```
OPTIONS="-u bind -4"
```

BIND is configured to use IPv4 only.
