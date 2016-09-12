
/**
 * Node used for running the knowbot related application infrastructure.
 */
node 'knowbot-app' {
  
	include ::bootstrap
	include ::freepuppet
  
}

/**
 * Node used for runnin the Spark / EMR enviroment for generating the social graph.
 */
node 'knowbot-spark' {
  
	include ::bootstrap
	include ::freepuppet
	
}