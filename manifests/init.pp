# ex: syntax=puppet si ts=4 sw=4 et
class stanchion (
    $version             = $::stanchion::params::version,
    $package_name        = $::stanchion::params::package_name,
    $service_name        = $::stanchion::params::service_name,
    $stanchion_ipaddress = $::stanchion::params::stanchion_ipaddress,
    $riak_ipaddress      = $::stanchion::params::riak_ipaddress,
) inherits stanchion::params {
    $admin_key = $::riakcs_admin_key ? {
        '' => 'admin-key',
        default => $::riakcs_admin_key,
    }
    $admin_secret = $::riakcs_admin_secret ? {
        '' => 'admin-secret',
        default => $::riakcs_admin_secret,
    }

    File {
        ensure => present,
        owner  => 'stanchion',
        group  => 'riak',
        mode   => '0644',
    }

    package { 'stanchion':
        ensure => $version,
        name   => $package_name,
        before => Service['stanchion'],
    }

    user { 'stanchion':
        ensure  => present,
        gid     => 'riak',
        require => Package['stanchion'],
    }

    file { '/etc/stanchion/app.config':
        content => template('stanchion/app.config.erb'),
        require => Package['stanchion'],
        notify  => Service['stanchion'],
    }

    file { '/etc/stanchion/vm.args':
        content => template('stanchion/vm.args.erb'),
        require => Package['stanchion'],
        notify  => Service['stanchion'],
    }

    service { 'stanchion':
        name    => $service_name,
        ensure  => running,
        require => Service['riak'],
        before  => Service['riak-cs'],
    }

    if $admin_key == 'admin-key' {
        class { 'stanchion::config_admin': }
    }
}
