# Adding records to the zone

## Adding records to the zone

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

A TXT record was added at the zone apex, along with the `web` CNAME. After reprovisioning (`vagrant provision primario`), the service restarts and reloads the zone.

## CNAME record

Commands:

```bash
dig @192.168.56.10 web.joseantonio.test CNAME +short
nslookup -type=cname web.joseantonio.test 192.168.56.10
```

Output:

```
vagrant@debian:~$ dig @192.168.56.10 web.joseantonio.test CNAME +short
debian.joseantonio.test.
vagrant@debian:~$ nslookup -type=cname web.joseantonio.test 192.168.56.10
Server:         192.168.56.10
Address:        192.168.56.10#53

web.joseantonio.test    canonical name = debian.joseantonio.test.
```

`web.joseantonio.test` is an alias for the canonical name `debian.joseantonio.test.`.

## TXT record

Commands:

```bash
dig @192.168.56.10 joseantonio.test TXT +short
nslookup -type=txt joseantonio.test 192.168.56.10
```

Output:

```
vagrant@debian:~$ dig @192.168.56.10 joseantonio.test TXT +short
"jasc-dotcom-github"
vagrant@debian:~$ nslookup -type=txt joseantonio.test 192.168.56.10
Server:         192.168.56.10
Address:        192.168.56.10#53

joseantonio.test        text = "jasc-dotcom-github"
```

The TXT record at the zone apex contains the value defined by `TXT_VALUE` in `config/vars.env`.

## PTR record

Commands:

```bash
dig @192.168.56.10 -x 192.168.56.10 +short
nslookup 192.168.56.10 192.168.56.10
```

Output:

```
vagrant@debian:~$ dig @192.168.56.10 -x 192.168.56.10 +short
debian.joseantonio.test.
vagrant@debian:~$ nslookup 192.168.56.10 192.168.56.10
10.56.168.192.in-addr.arpa      name = debian.joseantonio.test.
```

IP address `192.168.56.10` resolves to `debian.joseantonio.test.`.