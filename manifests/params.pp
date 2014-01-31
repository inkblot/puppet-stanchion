# ex: syntax=puppet si ts=4 sw=4 et
class stanchion::params {
    $version             = latest
    $package_name        = 'stanchion'
    $service_name        = 'stanchion'
    $stanchion_ipaddress = '127.0.0.1'
    $riak_ipaddress      = '127.0.0.1'
    $admin_key           = ''
    $admin_secret        = ''
}
