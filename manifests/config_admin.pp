# ex: syntax=puppet si ts=4 sw=4 et

class stanchion::config_admin {
    File {
        owner  => 'stanchion',
        group  => 'riak',
        mode   => '0755',
    }

    file { '/usr/local/stanchion':
        ensure => directory,
    }

    file { '/usr/local/stanchion/config-admin-user':
        ensure => present,
        source => 'puppet:///modules/stanchion/config-admin-user',
    }

    exec { 'stanchion config admin':
        command   => '/usr/local/stanchion/config-admin-user',
        user      => 'root',
        logoutput => on_failure,
        subscribe => Exec['riakcs create admin'],
    }

    exec { 'stanchion restart':
        command   => '/usr/sbin/service stanchion restart',
        user      => 'root',
        subscribe => Exec['stanchion config admin'],
    }
}
