zone "@DOMAIN@" {
    type master;
    file "/var/lib/bind/@DOMAIN@.dns";
    allow-transfer { @SECONDARY_IP@; };
};

zone "@REV_ZONE@.in-addr.arpa" {
    type master;
    file "/var/lib/bind/@DOMAIN@.rev";
    allow-transfer { @SECONDARY_IP@; };
};
