acl confiables {
    127.0.0.1;
    @NET@.0/24;
};

options {
    directory "/var/cache/bind";

    // forwarders {
    //   0.0.0.0;
    // };

    allow-transfer { none; };
    listen-on port 53 { 127.0.0.1; @LISTEN_IP@; };

    recursion yes;
    allow-recursion { confiables; };

    dnssec-validation yes;

    // listen-on-v6 { any; };
};
