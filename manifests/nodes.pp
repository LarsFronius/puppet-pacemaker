# node-configuration

node 'host01' {
    include pacemaker::service::slapd
}

node /^host0([2-9])/ {
    include skeleton
}

