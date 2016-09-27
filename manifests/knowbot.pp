
# Node used for running the knowbot related application infrastructure.
node 'knowbot-app'
{
    include ::bootstrap
    # setup docker environment
    include ::docker
    class { '::docker::compose':
        ensure => present,
        install_path => '/usr/bin'
    }
    
    # also install the acl library
    package { 'acl':
        ensure => present
    }
    
    # create a knowbot user for managing file permissions on the local drives
    group { 'www-pub':
        ensure  => present,
    }
    user { 'knowbot':
        ensure => present,
        groups => 'www-pub',
        require => Group['www-pub'],
    }
    user { 'www-data':
        ensure => present,
        groups => 'www-pub',
        require => Group['www-pub'],
    }
    
    # ensure directories are ready for social-search-platform code
    file { '/opt/social-search-platform':
        ensure => directory,
        mode   => 755,
        owner  => 'ubuntu',
        group  => 'ubuntu'
    }
    # and setup dir for docker to store it's data within.
    file { '/var/social-search-platform':
        ensure  => directory,
        mode    => 755,
    }
    file { '/var/social-search-platform/slack_export':
        ensure  => directory,
        mode    => 2755,
        owner   => 'knowbot',
        group   => 'www-pub',
        require => [
            File['/var/social-search-platform'],
            Group['www-pub']
        ],
        notify  => Exec['slack_export_acl']
    }
    file { '/var/social-search-platform/slack_export/cache': 
        ensure  => directory,
        mode    => 2755,
        owner   => 'knowbot',
        group   => 'www-pub',
        require => File['/var/social-search-platform/slack_export'],
        notify  => Exec['slack_export_acl'],
    }
    file { '/var/social-search-platform/slack_export/logs': 
        ensure  => directory,
        mode    => 2755,
        owner   => 'knowbot',
        group   => 'www-pub',
        require => File['/var/social-search-platform/slack_export'],
        notify  => Exec['slack_export_acl'],
    }
    file { '/var/social-search-platform/slack_export/messages': 
        ensure  => directory,
        mode    => 2755,
        owner   => 'knowbot',
        group   => 'www-pub',
        require => File['/var/social-search-platform/slack_export'],
        notify  => Exec['slack_export_acl'],
    }
    file { '/var/social-search-platform/slack_export/sessions': 
        ensure  => directory,
        mode    => 2755,
        owner   => 'knowbot',
        group   => 'www-pub',
        require => File['/var/social-search-platform/slack_export'],
        notify  => Exec['slack_export_acl'],
    }
    # hack together our file system acl
    exec { 'slack_export_acl':
        command => '/usr/bin/setfacl -R -m u:www-data:rwX /var/social-search-platform/slack_export && /usr/bin/setfacl -dR -m u:www-data:rwX /var/social-search-platform/slack_export',
        require => File['/var/social-search-platform/slack_export']
    }
    
    # and run our docker compose
    docker_compose { '/opt/social-search-platform/docker-compose.yml':
      ensure  => present,
      options => '-f/opt/social-search-platform/docker-compose.prod.yml',
      require => [
          File["/opt/social-search-platform"],
          File["/var/social-search-platform/slack_export"]
      ]
    }
    
}