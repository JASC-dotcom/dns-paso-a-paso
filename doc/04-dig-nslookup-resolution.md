# Checking name resolution with dig and nslookup

## Forward lookup with dig

Command (on `primario`):

```bash
dig @192.168.56.10 debian.joseantonio.test
```

Output:

```
; <<>> DiG 9.18.49-1~deb12u2-Debian <<>> @192.168.56.10 debian.joseantonio.test
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 49404
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 819348c479a0258e010000006ade52647f9e4b48cffc9c12 (good)
;; QUESTION SECTION:
;debian.joseantonio.test.       IN      A

;; ANSWER SECTION:
debian.joseantonio.test. 86400  IN      A       192.168.56.10

;; Query time: 0 msec
;; SERVER: 192.168.56.10#53(192.168.56.10) (UDP)
;; WHEN: Sun Oct 25 19:03:00 UTC 2026
;; MSG SIZE  rcvd: 96
```

The response shows `status: NOERROR`, the `aa` flag, and `debian.joseantonio.test` with IP address `192.168.56.10` in the ANSWER section. The responding server is `192.168.56.10#53`.

## Forward lookup with nslookup

Command:

```bash
nslookup debian.joseantonio.test 192.168.56.10
```

Output:

```
Server:         192.168.56.10
Address:        192.168.56.10#53

Name:   debian.joseantonio.test
Address: 192.168.56.10
```

The queried server is `192.168.56.10`, and the response is `192.168.56.10`.

## Secondary server lookup

Command:

```bash
dig @192.168.56.10 debian2.joseantonio.test +short
```

Output:

```
192.168.56.11
```

It returns `192.168.56.11`, the secondary server's IP address.

## Query without specifying the server (expected error)

Command (on `primario`):

```bash
dig debian.joseantonio.test | grep -E "status|SERVER"
```

Output:

```
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 39325
;; SERVER: 100.100.1.1#53(100.100.1.1) (UDP)
```

Without `@192.168.56.10`, `dig` uses the DNS server in `/etc/resolv.conf` (the one on the VirtualBox NAT network), which does not know the `joseantonio.test` zone and returns `NXDOMAIN`. To fix this, query the server directly with `@192.168.56.10` or configure the client to use this DNS server as its primary.