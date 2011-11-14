class pacemaker::service::slapd ( $clustername = 'default' ) {
    pacemaker::service { "slapd":
        clustername => $clustername,
        servicename => 'slapd',
        require => [Package["slapd","ldap-utils"],File["/usr/lib/ocf/resource.d/heartbeat/slapd"]]
    }
    package { ["slapd","ldap-utils"]:
        ensure => present,
    }
    service { ["slapd"]:
        ensure => stopped,
        enable => false,
        subscribe => Package["slapd"],
        require => Package["slapd"],
    }
    file { "/usr/lib/ocf/resource.d/heartbeat/slapd":
        source => "modules/pacemaker/slapd",
        ensure => present,
        mode => 755,
        owner => root,
        group => root,
        require => Package['pacemaker'],
    }
}
