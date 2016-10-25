
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
    
    # setup user permissions
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
    
    # setup webroots
    file { '/var/www':
        ensure  => directory,
        mode    => 775,
        owner   => 'www-data',
        group   => 'www-pub',
        require => Group['www-pub']
    }
    file { '/var/www/innovation-knowbot.itsbeta.net':
        ensure  => directory,
        mode    => 775,
        owner   => 'www-data',
        group   => 'www-pub',
        require => File['/var/www']
    }

    # install web server
    class { 'nginx': }
    nginx::resource::upstream { 'knowbot_app':
        members => [ 'localhost:8080' ]
    }
    nginx::resource::vhost { 'innovation-knowbot.itsbeta.net':
        proxy       => 'http://knowbot_app',
        require  => File['/var/www/innovation-knowbot.itsbeta.net']
    }
    nginx::resource::location { '/.well-known/':
        vhost => 'innovation-knowbot.itsbeta.net',
        www_root => '/var/www/innovation-knowbot.itsbeta.net/'
    }
    
    # and lets encrypt - no email validation
    class { ::letsencrypt:
        unsafe_registration => true
    }
    letsencrypt::certonly { 'innovation-knowbot.itsbeta.net':
      domains       => [ 'innovation-knowbot.itsbeta.net' ],
      plugin        => 'webroot',
      webroot_paths => [ '/var/www/innovation-knowbot.itsbeta.net' ],
      manage_cron   => true
    }
    
    # setup scripts to remove old containers at 07:00
    cron { 'docker_container_cleanup':
        ensure  => present,
        command => 'docker rm -v $(docker ps -a -q -f status=exited) > /dev/null 2>&1',
        hour    => '7',
        minute  => '0'
    }
    cron { 'docker_image_cleanup':
        ensure  => present,
        command => 'docker rmi $(docker images -f "dangling=true" -q) > /dev/null 2>&1',
        hour    => '7',
        minute  => '5'
    }
    
    # also install the acl library
    package { 'acl':
        ensure => present
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
        command     => '/usr/bin/setfacl -R -m u:www-data:rwX /var/social-search-platform/slack_export && /usr/bin/setfacl -dR -m u:www-data:rwX /var/social-search-platform/slack_export',
        require     => File['/var/social-search-platform/slack_export'],
        refreshonly => true
    }
    
    # adding a hack to ensure that we have the docker-compose env setup correctly
    exec { 'social-search-platform_docker-compose-env':
      command => "/bin/bash -c 'source /opt/social-search-platform/.env;'",
    }
    
    # and run our docker compose
    docker_compose { '/opt/social-search-platform/docker-compose.yml':
      ensure  => present,
      options => '-f/opt/social-search-platform/docker-compose.prod.yml',
      require => [
          File["/opt/social-search-platform"],
          File["/var/social-search-platform/slack_export"],
          Exec["social-search-platform_docker-compose-env"]
      ]
    }
    
    # setup a cron to run the full sync every day at 00:00 and 12:00
    cron { 'slack_export_full_sync':
        ensure  => present,
        command => '/usr/bin/docker-compose -f/opt/social-search-platform/docker-compose.yml -f/opt/social-search-platform/docker-compose.prod.yml run console slack:sync --env=prod > /dev/null 2>&1',
        hour    => '*/12',
        minute  => '0'
    }
}