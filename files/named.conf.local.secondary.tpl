zone "@DOMAIN@" {
    type slave;
    masters { @PRIMARY_IP@; };
    file "/var/cache/bind/@DOMAIN@.dns";
};

zone "@REV_ZONE@.in-addr.arpa" {
    type slave;
    masters { @PRIMARY_IP@; };
    file "/var/cache/bind/@DOMAIN@.rev";
};
