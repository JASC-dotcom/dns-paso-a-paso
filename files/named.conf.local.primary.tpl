zone "@DOMAIN@" {
    type master;
    file "/var/lib/bind/@DOMAIN@.dns";
};

zone "@REV_ZONE@.in-addr.arpa" {
    type master;
    file "/var/lib/bind/@DOMAIN@.rev";
};
