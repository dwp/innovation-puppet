
/**
 * Node used for running the knowbot related application infrastructure.
 */
node 'knowbot-app' {
  
	include ::bootstrap
	
	# setup docker environment
	include 'docker'
    class {'docker::compose': 
	  ensure => present
	}
  
}

/**
 * Node used for runnin the Spark / EMR enviroment for generating the social graph.
 */
node 'knowbot-spark' {
  
	include ::bootstrap
	
}