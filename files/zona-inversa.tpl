;
; @REV_ZONE@.in-addr.arpa
;
$TTL    86400
@   IN  SOA debian.@DOMAIN@. admin.@DOMAIN@. (
            @SERIAL@ ; Serial
            3600     ; Refresh
            1800     ; Retry
            604800   ; Expire
            86400 )  ; Negative Cache TTL
;
@                 IN  NS   debian.@DOMAIN@.
@                 IN  NS   debian2.@DOMAIN@.
@PRIMARY_LAST@                IN  PTR  debian.@DOMAIN@.
@SECONDARY_LAST@                IN  PTR  debian2.@DOMAIN@.
