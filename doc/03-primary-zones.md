# Zones on the primary server

> The zone serial is generated from the provisioning date and time (`YYMMDDhhmm`).

## Forward zone declaration

Command:

```bash
cat /etc/bind/named.conf.local
```

Output:

```
zone "joseantonio.test" {
    type master;
    file "/var/lib/bind/joseantonio.test.dns";
    allow-transfer { 192.168.56.11; };
};

zone "56.168.192.in-addr.arpa" {
    type master;
    file "/var/lib/bind/joseantonio.test.rev";
    allow-transfer { 192.168.56.11; };
};
```

The primary is the `master` for the `joseantonio.test` zone. The zone file will be created in the next step.

### Loading the zone without a file (expected error)

Commands:

```bash
sudo systemctl restart named
sudo systemctl status named --no-pager
dig @192.168.56.10 debian.joseantonio.test
```

Output:

```
vagrant@debian:~$ sudo systemctl restart named
vagrant@debian:~$ sudo systemctl status named --no-pager
● named.service - BIND Domain Name Server
     Loaded: loaded (/lib/systemd/system/named.service; enabled; preset: enabled)
     Active: active (running) since Sun 2026-10-25 18:56:07 UTC; 7s ago
       Docs: man:named(8)
   Main PID: 2429 (named)
     Status: "running"
      Tasks: 6 (limit: 496)
     Memory: 23.1M
        CPU: 89ms
     CGroup: /system.slice/named.service
             └─2429 /usr/sbin/named -f -u bind -4

Oct 25 18:56:07 debian named[2429]: zone localhost/IN: loaded serial 2
Oct 25 18:56:07 debian named[2429]: zone 0.in-addr.arpa/IN: loaded serial 1
Oct 25 18:56:07 debian named[2429]: zone 127.in-addr.arpa/IN: loaded serial 1
Oct 25 18:56:07 debian named[2429]: zone 56.168.192.in-addr.arpa/IN: loaded serial 2610251850
Oct 25 18:56:07 debian named[2429]: zone joseantonio.test/IN: loaded serial 2610251850
Oct 25 18:56:07 debian named[2429]: all zones loaded
Oct 25 18:56:07 debian systemd[1]: Started named.service - BIND Domain Name Server.
Oct 25 18:56:07 debian named[2429]: running
Oct 25 18:56:07 debian named[2429]: zone joseantonio.test/IN: sending notifies (serial 2610251850)
Oct 25 18:56:07 debian named[2429]: zone 56.168.192.in-addr.arpa/IN: sending notifies (serial 2610251850)
vagrant@debian:~$ dig @192.168.56.10 debian.joseantonio.test

; <<>> DiG 9.18.49-1~deb12u2-Debian <<>> @192.168.56.10 debian.joseantonio.test
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 15280
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 45fe39cf2c21a3bf010000006ade50d51b5d989a605f5ee3 (good)
;; QUESTION SECTION:
;debian.joseantonio.test.       IN      A

;; ANSWER SECTION:
debian.joseantonio.test. 86400  IN      A       192.168.56.10

;; Query time: 4 msec
;; SERVER: 192.168.56.10#53(192.168.56.10) (UDP)
;; WHEN: Sun Oct 25 18:56:21 UTC 2026
;; MSG SIZE  rcvd: 96
```

The service starts (`active (running)`), but the query returns `status: SERVFAIL`. `named-checkconf` alone does not detect anything because it only checks the syntax. To find the cause:

Commands:

```bash
sudo named-checkconf -z
sudo journalctl -u named --no-pager | tail -n 10
```

Output:

```
vagrant@debian:~$ sudo named-checkconf -z
zone joseantonio.test/IN: loaded serial 2610251850
zone 56.168.192.in-addr.arpa/IN: loaded serial 2610251850
zone localhost/IN: loaded serial 2
zone 127.in-addr.arpa/IN: loaded serial 1
zone 0.in-addr.arpa/IN: loaded serial 1
zone 255.in-addr.arpa/IN: loaded serial 1
vagrant@debian:~$ sudo journalctl -u named --no-pager | tail -n 10
Oct 25 18:56:07 debian named[2429]: zone localhost/IN: loaded serial 2
Oct 25 18:56:07 debian named[2429]: zone 0.in-addr.arpa/IN: loaded serial 1
Oct 25 18:56:07 debian named[2429]: zone 127.in-addr.arpa/IN: loaded serial 1
Oct 25 18:56:07 debian named[2429]: zone 56.168.192.in-addr.arpa/IN: loaded serial 2610251850
Oct 25 18:56:07 debian named[2429]: zone joseantonio.test/IN: loaded serial 2610251850
Oct 25 18:56:07 debian named[2429]: all zones loaded
Oct 25 18:56:07 debian systemd[1]: Started named.service - BIND Domain Name Server.
Oct 25 18:56:07 debian named[2429]: running
Oct 25 18:56:07 debian named[2429]: zone joseantonio.test/IN: sending notifies (serial 2610251850)
Oct 25 18:56:07 debian named[2429]: zone 56.168.192.in-addr.arpa/IN: sending notifies (serial 2610251850)
```

The zone is declared, but the `/var/lib/bind/joseantonio.test.dns` file does not exist yet: the log reports that the file cannot be found and that the zone was not loaded. Create the file to fix this.

## Forward lookup zone (solution)

Command:

```bash
cat /var/lib/bind/joseantonio.test.dns
```

Output:

```
;
; joseantonio.test
;
$TTL    86400
@   IN  SOA debian.joseantonio.test. admin.joseantonio.test. (
            2610251850 ; Serial (YYMMDDhhmm)
            3600     ; Refresh
            1800     ; Retry
            604800   ; Expire
            86400 )  ; Negative Cache TTL
;
@        IN  NS    debian.joseantonio.test.
@        IN  NS    debian2.joseantonio.test.
@        IN  TXT   "jasc-dotcom-github"
debian   IN  A     192.168.56.10
debian2  IN  A     192.168.56.11
web      IN  CNAME debian.joseantonio.test.
```

Command:

```bash
named-checkzone joseantonio.test. /var/lib/bind/joseantonio.test.dns
sudo systemctl restart named
dig @192.168.56.10 debian.joseantonio.test
```

Output:

```
vagrant@debian:~$
vagrant@debian:~$ named-checkzone joseantonio.test. /var/lib/bind/joseantonio.test.dns
zone joseantonio.test/IN: loaded serial 2610251850
OK
vagrant@debian:~$ sudo systemctl restart named
vagrant@debian:~$ dig @192.168.56.10 debian.joseantonio.test

; <<>> DiG 9.18.49-1~deb12u2-Debian <<>> @192.168.56.10 debian.joseantonio.test
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 28933
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: eb91e383af785518010000006ade5167b5be45788ebd34f7 (good)
;; QUESTION SECTION:
;debian.joseantonio.test.       IN      A

;; ANSWER SECTION:
debian.joseantonio.test. 86400  IN      A       192.168.56.10

;; Query time: 0 msec
;; SERVER: 192.168.56.10#53(192.168.56.10) (UDP)
;; WHEN: Sun Oct 25 18:58:47 UTC 2026
;; MSG SIZE  rcvd: 96
```

The zone passes the check (`OK`), and the query returns `status: NOERROR` with IP address `192.168.56.10`.

## Reverse zone declaration

Command:

```bash
cat /etc/bind/named.conf.local
```

Output:

```
zone "joseantonio.test" {
    type master;
    file "/var/lib/bind/joseantonio.test.dns";
    allow-transfer { 192.168.56.11; };
};

zone "56.168.192.in-addr.arpa" {
    type master;
    file "/var/lib/bind/joseantonio.test.rev";
    allow-transfer { 192.168.56.11; };
};
```

### Reverse zone without a file (expected error)

Commands:

```bash
sudo systemctl restart named
sudo named-checkconf -z
dig @192.168.56.10 -x 192.168.56.10
```

Output:

```
vagrant@debian:~$ sudo systemctl restart named
vagrant@debian:~$ sudo named-checkconf -z
zone joseantonio.test/IN: loaded serial 2610251850
zone 56.168.192.in-addr.arpa/IN: loaded serial 2610251850
zone localhost/IN: loaded serial 2
zone 127.in-addr.arpa/IN: loaded serial 1
zone 0.in-addr.arpa/IN: loaded serial 1
zone 255.in-addr.arpa/IN: loaded serial 1
vagrant@debian:~$ dig @192.168.56.10 -x 192.168.56.10

; <<>> DiG 9.18.49-1~deb12u2-Debian <<>> @192.168.56.10 -x 192.168.56.10
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 25426
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 68a205407cf596b5010000006ade51be5a3f61909a43708f (good)
;; QUESTION SECTION:
;10.56.168.192.in-addr.arpa.    IN      PTR

;; ANSWER SECTION:
10.56.168.192.in-addr.arpa. 86400 IN    PTR     debian.joseantonio.test.

;; Query time: 0 msec
;; SERVER: 192.168.56.10#53(192.168.56.10) (UDP)
;; WHEN: Sun Oct 25 19:00:14 UTC 2026
;; MSG SIZE  rcvd: 120
```

The same error occurs as before: the `56.168.192.in-addr.arpa` zone is declared, but its `/var/lib/bind/joseantonio.test.rev` file is missing; the reverse query returns `SERVFAIL`.

## Reverse lookup zone (solution)

Command:

```bash
cat /var/lib/bind/joseantonio.test.rev
```

Output:

```
;
; 56.168.192.in-addr.arpa
;
$TTL    86400
@   IN  SOA debian.joseantonio.test. admin.joseantonio.test. (
            2610251850 ; Serial
            3600     ; Refresh
            1800     ; Retry
            604800   ; Expire
            86400 )  ; Negative Cache TTL
;
@                 IN  NS   debian.joseantonio.test.
@                 IN  NS   debian2.joseantonio.test.
10                IN  PTR  debian.joseantonio.test.
11                IN  PTR  debian2.joseantonio.test.
```

Commands:

```bash
named-checkzone 56.168.192.in-addr.arpa. /var/lib/bind/joseantonio.test.rev
sudo systemctl restart named
dig @192.168.56.10 -x 192.168.56.10 +short
```

Output:

```
vagrant@debian:~$ named-checkzone 56.168.192.in-addr.arpa. /var/lib/bind/joseantonio.test.rev
zone 56.168.192.in-addr.arpa/IN: loaded serial 2610251850
OK
vagrant@debian:~$ sudo systemctl restart named
vagrant@debian:~$ dig @192.168.56.10 -x 192.168.56.10 +short
debian.joseantonio.test.
```

The reverse zone passes the check, and IP address `192.168.56.10` resolves to `debian.joseantonio.test.`.

## Zone loading in the log

Command:

```bash
sudo journalctl -u named --no-pager | grep "loaded serial"
```

Output:

```
Oct 25 18:50:15 debian named[2107]: managed-keys-zone: loaded serial 0
Oct 25 18:50:15 debian named[2107]: zone 127.in-addr.arpa/IN: loaded serial 1
Oct 25 18:50:15 debian named[2107]: zone 0.in-addr.arpa/IN: loaded serial 1
Oct 25 18:50:15 debian named[2107]: zone localhost/IN: loaded serial 2
Oct 25 18:50:15 debian named[2107]: zone 255.in-addr.arpa/IN: loaded serial 1
Oct 25 18:50:19 debian named[2175]: managed-keys-zone: loaded serial 2
Oct 25 18:50:19 debian named[2175]: zone 255.in-addr.arpa/IN: loaded serial 1
Oct 25 18:50:19 debian named[2175]: zone 127.in-addr.arpa/IN: loaded serial 1
Oct 25 18:50:19 debian named[2175]: zone 0.in-addr.arpa/IN: loaded serial 1
Oct 25 18:50:19 debian named[2175]: zone localhost/IN: loaded serial 2
Oct 25 18:50:20 debian named[2219]: managed-keys-zone: loaded serial 3
Oct 25 18:50:20 debian named[2219]: zone localhost/IN: loaded serial 2
Oct 25 18:50:20 debian named[2219]: zone 127.in-addr.arpa/IN: loaded serial 1
Oct 25 18:50:20 debian named[2219]: zone 0.in-addr.arpa/IN: loaded serial 1
Oct 25 18:50:20 debian named[2219]: zone 255.in-addr.arpa/IN: loaded serial 1
Oct 25 18:50:20 debian named[2261]: managed-keys-zone: loaded serial 4
Oct 25 18:50:20 debian named[2261]: zone 0.in-addr.arpa/IN: loaded serial 1
Oct 25 18:50:20 debian named[2261]: zone 127.in-addr.arpa/IN: loaded serial 1
Oct 25 18:50:20 debian named[2261]: zone localhost/IN: loaded serial 2
Oct 25 18:50:20 debian named[2261]: zone 255.in-addr.arpa/IN: loaded serial 1
Oct 25 18:50:21 debian named[2277]: managed-keys-zone: loaded serial 4
Oct 25 18:50:21 debian named[2277]: zone 0.in-addr.arpa/IN: loaded serial 1
Oct 25 18:50:21 debian named[2277]: zone 127.in-addr.arpa/IN: loaded serial 1
Oct 25 18:50:21 debian named[2277]: zone joseantonio.test/IN: loaded serial 2610251850
Oct 25 18:50:21 debian named[2277]: zone 56.168.192.in-addr.arpa/IN: loaded serial 2610251850
Oct 25 18:50:21 debian named[2277]: zone 255.in-addr.arpa/IN: loaded serial 1
Oct 25 18:50:21 debian named[2277]: zone localhost/IN: loaded serial 2
Oct 25 18:50:21 debian named[2316]: managed-keys-zone: loaded serial 4
Oct 25 18:50:21 debian named[2316]: zone 0.in-addr.arpa/IN: loaded serial 1
Oct 25 18:50:21 debian named[2316]: zone localhost/IN: loaded serial 2
Oct 25 18:50:21 debian named[2316]: zone joseantonio.test/IN: loaded serial 2610251850
Oct 25 18:50:21 debian named[2316]: zone 127.in-addr.arpa/IN: loaded serial 1
Oct 25 18:50:21 debian named[2316]: zone 255.in-addr.arpa/IN: loaded serial 1
Oct 25 18:50:21 debian named[2316]: zone 56.168.192.in-addr.arpa/IN: loaded serial 2610251850
Oct 25 18:56:07 debian named[2429]: managed-keys-zone: loaded serial 4
Oct 25 18:56:07 debian named[2429]: zone 255.in-addr.arpa/IN: loaded serial 1
Oct 25 18:56:07 debian named[2429]: zone localhost/IN: loaded serial 2
Oct 25 18:56:07 debian named[2429]: zone 0.in-addr.arpa/IN: loaded serial 1
Oct 25 18:56:07 debian named[2429]: zone 127.in-addr.arpa/IN: loaded serial 1
Oct 25 18:56:07 debian named[2429]: zone 56.168.192.in-addr.arpa/IN: loaded serial 2610251850
Oct 25 18:56:07 debian named[2429]: zone joseantonio.test/IN: loaded serial 2610251850
Oct 25 18:58:33 debian named[2461]: managed-keys-zone: loaded serial 4
Oct 25 18:58:33 debian named[2461]: zone 0.in-addr.arpa/IN: loaded serial 1
Oct 25 18:58:33 debian named[2461]: zone joseantonio.test/IN: loaded serial 2610251850
Oct 25 18:58:33 debian named[2461]: zone 127.in-addr.arpa/IN: loaded serial 1
Oct 25 18:58:33 debian named[2461]: zone 255.in-addr.arpa/IN: loaded serial 1
Oct 25 18:58:33 debian named[2461]: zone 56.168.192.in-addr.arpa/IN: loaded serial 2610251850
Oct 25 18:58:33 debian named[2461]: zone localhost/IN: loaded serial 2
Oct 25 19:00:04 debian named[2482]: managed-keys-zone: loaded serial 4
Oct 25 19:00:04 debian named[2482]: zone 0.in-addr.arpa/IN: loaded serial 1
Oct 25 19:00:04 debian named[2482]: zone localhost/IN: loaded serial 2
Oct 25 19:00:04 debian named[2482]: zone 56.168.192.in-addr.arpa/IN: loaded serial 2610251850
Oct 25 19:00:04 debian named[2482]: zone 255.in-addr.arpa/IN: loaded serial 1
Oct 25 19:00:04 debian named[2482]: zone joseantonio.test/IN: loaded serial 2610251850
Oct 25 19:00:04 debian named[2482]: zone 127.in-addr.arpa/IN: loaded serial 1
Oct 25 19:01:27 debian named[2504]: managed-keys-zone: loaded serial 4
Oct 25 19:01:27 debian named[2504]: zone localhost/IN: loaded serial 2
Oct 25 19:01:27 debian named[2504]: zone 0.in-addr.arpa/IN: loaded serial 1
Oct 25 19:01:27 debian named[2504]: zone 255.in-addr.arpa/IN: loaded serial 1
Oct 25 19:01:27 debian named[2504]: zone 127.in-addr.arpa/IN: loaded serial 1
Oct 25 19:01:27 debian named[2504]: zone 56.168.192.in-addr.arpa/IN: loaded serial 2610251850
Oct 25 19:01:27 debian named[2504]: zone joseantonio.test/IN: loaded serial 2610251850
```

BIND has loaded both zones (`joseantonio.test` and `56.168.192.in-addr.arpa`).