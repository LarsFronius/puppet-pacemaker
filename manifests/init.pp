class pacemaker ( $cluster = 'default' ) {
    package { "pacemaker":
        ensure => present,
    }
    configfile { "/etc/corosync/authkey":
        source => "modules/pacemaker/cluster-$cluster/authkey",
        require => Package['pacemaker'],
    }
    configfile { "/etc/corosync/corosync.conf":
        source => "modules/pacemaker/cluster-$cluster/corosync.conf",
        require => Package['pacemaker'],
    }
    configfile { "/etc/default/corosync":
        source => "modules/pacemaker/corosync-yes",
        require => Package['pacemaker'],
    }
    service { "corosync":
        require => [Package['pacemaker'],File['/etc/default/corosync'],File['/etc/corosync/authkey'],File['/etc/corosync/corosync.conf']],
        ensure => running,
        enable => true,
    }
    exec { "reload cluster config":
        command     => "crm -F configure load update /etc/ha.d/crm.cib && test $(cat /etc/ha.d/crm.cib | wc -l) -eq $(crm configure show | sed 's/^ *//' | grep -c -F -f /etc/ha.d/crm.cib)",
#        command     => 'crm -F configure load update /etc/ha.d/crm.cib && test "$( cat /etc/ha.d/crm.cib | sed \'s/^[\t ]*//\' )" = "$( crm configure show | sed \'s/^[\t ]*//\' | grep -F -f <( cat /etc/ha.d/crm.cib | sed \'s/^[\t ]*//\' ) )"',
        refreshonly => true,
        require     => [Service["corosync"],File["/etc/ha.d/crm.cib"]],
        subscribe   => File["/etc/ha.d/crm.cib"],
        unless      => "test $(cat /etc/ha.d/crm.cib | wc -l) -eq $(crm configure show | 's/^ *//' | grep -c -F -f /etc/ha.d/crm.cib)",
#        unless      => 'test "$( cat /etc/ha.d/crm.cib | sed \'s/^[\t ]*//\' )" = "$( crm configure show | sed \'s/^[\t ]*//\' | grep -F -f <( cat /etc/ha.d/crm.cib | sed \'s/^[\t ]*//\' ) )"',
        tries       => 10,
        try_sleep   => 20,
    }
    configfile { "/etc/ha.d/crm.cib":
      source  => "modules/pacemaker/cluster-$cluster/crm.cib",
      require => Package["pacemaker"],
    }
}
define pacemaker::service ( $clustername, $servicename ) {
    class {'pacemaker': 
        cluster => $clustername 
    }
    $cibfile = "/etc/ha.d/$servicename.cib"
    exec { "reload service config":
        command     => "crm -F configure load update $cibfile && test $(cat $cibfile | wc -l) -eq $(crm configure show | sed 's/^ *//' | grep -c -F -f $cibfile)",
#        command     => "crm -F configure load update $cibfile && test \"$( cat $cibfile | sed 's/^[\t ]*//' )\" = \"$( crm configure show | sed 's/^[\t ]*//' | grep -F -f <( cat $cibfile | sed 's/^[\t ]*//' ) )\"",
        refreshonly => true,
        subscribe    => File["cib-file"],
        unless      => "test $(cat $cibfile | wc -l) -eq $(crm configure show | sed 's/^ *//' |grep -c -F -f $cibfile)",
#        unless      => "test \"$( cat $cibfile | sed 's/^[\t ]*//' )\" = \"$( crm configure show | sed 's/^[\t ]*//' | grep -F -f <( cat $cibfile | sed 's/^[\t ]*//' ) )\"",
        tries       => 20,
        try_sleep   => 6,
        require     => [Service["corosync"],Configfile["cib-file"],Exec["reload cluster config"]]
    }
    configfile { "cib-file":
        path    => "$cibfile",
        require => [Package["pacemaker"]],
        source  => "modules/pacemaker/$servicename.cib",
    }
}

import "services/*.pp"
