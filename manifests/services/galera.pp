class pacemaker::service::galera-mysql ( $clustername = 'default' ) {
    pacemaker::service { "galera":
        clustername => $clustername,
        servicename => 'galera',
        require => [Class["galera"]]
    }
    class { "galera":
        cluster_name => "galera", 
        master_ip => "33.33.33.11"
    }
    service { ["mysql"]:
        ensure => stopped,
        enable => false,
        subscribe => Class["galera"],
        require => Class["galera"],
    }
    file { "/usr/lib/ocf/resource.d/heartbeat/mysql":
        source => "modules/pacemaker/mysql",
        ensure => present,
        mode => 755,
        owner => root,
        group => root,
        require => Package['pacemaker'],
    }
}
