# Configuring named.conf.options

## Backup

Command (on `primario`):

```bash
ls -l /etc/bind/*.backup
```

Output:

```
-rw-r--r-- 1 root bind 165 Oct 25 18:50 /etc/bind/named.conf.local.backup
-rw-r--r-- 1 root bind 846 Oct 25 18:50 /etc/bind/named.conf.options.backup
```

The provisioning script saves a `.backup` copy of the original files before modifying them.

## Configuration file

Command:

```bash
cat /etc/bind/named.conf.options
```

Output:

```
acl confiables {
    127.0.0.1;
    192.168.56.0/24;
};

options {
    directory "/var/cache/bind";

    // forwarders {
    //   0.0.0.0;
    // };

    allow-transfer { none; };
    listen-on port 53 { 127.0.0.1; 192.168.56.10; };

    recursion yes;
    allow-recursion { confiables; };

    dnssec-validation yes;

    // listen-on-v6 { any; };
};
```

- `acl confiables`: only `127.0.0.1` and the `192.168.56.0/24` network can make recursive queries.
- `listen-on`: listens on port 53 on localhost and `192.168.56.10`.
- `allow-transfer { none; }`: no zones are transferred by default; the secondary is then authorized zone by zone.
- `listen-on-v6` is commented out because IPv6 is not used.

## Syntax check

Command:

```bash
named-checkconf /etc/bind/named.conf.options
```

Output:

```
(no output: the configuration is valid)
```

## Service status

Command:

```bash
sudo systemctl status named --no-pager
```

Output:

```
● named.service - BIND Domain Name Server
     Loaded: loaded (/lib/systemd/system/named.service; enabled; preset: enabled)
     Active: active (running) since Sun 2026-10-25 18:50:21 UTC; 3min 22s ago
       Docs: man:named(8)
   Main PID: 2316 (named)
     Status: "running"
      Tasks: 6 (limit: 496)
     Memory: 23.9M
        CPU: 210ms
     CGroup: /system.slice/named.service
             └─2316 /usr/sbin/named -f -u bind -4

Oct 25 18:50:21 debian named[2316]: zone localhost/IN: loaded serial 2
Oct 25 18:50:21 debian named[2316]: zone joseantonio.test/IN: loaded serial 2610251850
Oct 25 18:50:21 debian named[2316]: zone 127.in-addr.arpa/IN: loaded serial 1
Oct 25 18:50:21 debian named[2316]: zone 255.in-addr.arpa/IN: loaded serial 1
Oct 25 18:50:21 debian named[2316]: zone 56.168.192.in-addr.arpa/IN: loaded serial 2610251850
Oct 25 18:50:21 debian named[2316]: all zones loaded
Oct 25 18:50:21 debian named[2316]: zone 56.168.192.in-addr.arpa/IN: sending notifies (serial 2610251850)
Oct 25 18:50:21 debian named[2316]: running
Oct 25 18:50:21 debian named[2316]: zone joseantonio.test/IN: sending notifies (serial 2610251850)
Oct 25 18:50:21 debian systemd[1]: Started named.service - BIND Domain Name Server.
```

The service is `active (running)`.

## Listening port

Command:

```bash
sudo ss -lntu | grep ':53'
```

Output:

```
udp   UNCONN 0      0      192.168.56.10:53        0.0.0.0:*
udp   UNCONN 0      0      192.168.56.10:53        0.0.0.0:*
udp   UNCONN 0      0          127.0.0.1:53        0.0.0.0:*
udp   UNCONN 0      0          127.0.0.1:53        0.0.0.0:*
tcp   LISTEN 0      10     192.168.56.10:53        0.0.0.0:*
tcp   LISTEN 0      10     192.168.56.10:53        0.0.0.0:*
tcp   LISTEN 0      10         127.0.0.1:53        0.0.0.0:*
tcp   LISTEN 0      10         127.0.0.1:53        0.0.0.0:*
```

`named` listens on port 53 (UDP and TCP) on `127.0.0.1` and `192.168.56.10`.

## Syntax error (deliberately introduced)

To check that `named-checkconf` detects errors, deliberately remove the `;` from the `recursion yes;` line (on the machine, without changing the repository template).

Commands (on `primario`):

```bash
sudo sed -i 's/recursion yes;/recursion yes/' /etc/bind/named.conf.options
named-checkconf /etc/bind/named.conf.options
```

Output:

```
vagrant@debian:~$ sudo sed -i 's/recursion yes;/recursion yes/' /etc/bind/named.conf.options
vagrant@debian:~$ named-checkconf /etc/bind/named.conf.options
/etc/bind/named.conf.options:17: missing ';' before 'allow-recursion'
```

`named-checkconf` reports the file, the line number, and that a `;` is missing. To fix it, restore the `;` or reprovision the machine.

Commands:

```bash
sudo sed -i 's/recursion yes$/recursion yes;/' /etc/bind/named.conf.options
named-checkconf /etc/bind/named.conf.options && echo "[OK] named.conf.options"
```

Output:

```
[OK] named.conf.options
```