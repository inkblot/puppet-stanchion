# ex: syntax=puppet si ts=4 sw=4 et
class stanchion (
    $version             = $::stanchion::params::version,
    $package_name        = $::stanchion::params::package_name,
    $service_name        = $::stanchion::params::service_name,
    $stanchion_ipaddress = $::stanchion::params::stanchion_ipaddress,
    $riak_ipaddress      = $::stanchion::params::riak_ipaddress,
    $admin_key           = $::stanchion::params::admin_key,
    $admin_secret        = $::stanchion::params::admin_secret,
) inherits stanchion::params {
    # See riakcs class for cluster bootstrap information.  The fact values
    # must be either established as fact or passed 
    if $::riakcs_admin_key != '' and $::riakcs_admin_secret != '' {
        $_admin_key = $::riakcs_admin_key
        $_admin_secret = $::riakcs_admin_secret
    } elsif $admin_key != '' and $admin_secret != '' {
        $_admin_key = $admin_key
        $_admin_secret = $admin_secret
    } else {
        $_admin_key = 'admin-key'
        $_admin_secret = 'admin-secret'
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

    if $_admin_key == 'admin-key' {
        class { 'stanchion::config_admin': }
    }
}
