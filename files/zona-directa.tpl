;
; @DOMAIN@
;
$TTL    86400
@   IN  SOA debian.@DOMAIN@. admin.@DOMAIN@. (
            @SERIAL@ ; Serial (YYMMDDhhmm)
            3600     ; Refresh
            1800     ; Retry
            604800   ; Expire
            86400 )  ; Negative Cache TTL
;
@        IN  NS    debian.@DOMAIN@.
@        IN  NS    debian2.@DOMAIN@.
@        IN  TXT   "@TXT@"
debian   IN  A     @PRIMARY_IP@
debian2  IN  A     @SECONDARY_IP@
web      IN  CNAME debian.@DOMAIN@.
