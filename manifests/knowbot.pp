
# Node used for running the knowbot related application infrastructure.
node 'knowbot-app'
{
    include ::bootstrap
    # setup docker environment
    include ::docker
    class { '::docker::compose' :
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
        ensure => directory,
        mode   => 755,
    }
    # and run our docker compose
    docker_compose { '/opt/social-search-platform/docker-compose.yml':
      ensure  => present
    }
    
}

# Node used for runnin the Spark / EMR enviroment for generating the social graph.
node 'knowbot-spark'
{
    include ::bootstrap
}