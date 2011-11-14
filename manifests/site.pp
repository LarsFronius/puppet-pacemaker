# /etc/puppet/manifests/site.pp

import "nodes.pp"

Exec["apt-get-update"] -> Package <| |>

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

exec { "apt-get-update" :
    command => "/usr/bin/apt-get update",
}

define configfile($owner = root, $group = root, $mode = 0644, $ensure = file, $links = manage, $source, $recurse = false, $path = false) {
  file { $name :
    ensure => $ensure,
    links => $links,
    owner => $owner,
    group => $group,
    mode => $mode,
    recurse => $recurse,
    path => $path ? { false => $name, default => $path },
    source => $source,
  }
}
