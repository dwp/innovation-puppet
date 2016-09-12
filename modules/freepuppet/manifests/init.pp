
#
# freepuppet moduled used to install the basics of a masterless puppet configuration.
# @author jonty.bale@dwp.gsi.gov.uk
#
class freepuppet (
	$ensure = 'present'
) {	
	# ensure the run script is in place
	file { "/usr/local/bin/freepuppet-run":
		ensure => $ensure,
		source => "puppet:///modules/freepuppet/cron/run.sh"
	}
	
	# ensure we have a cron in place which runs every 15min
	cron { "freepuppet-run":
		ensure => $ensure,
		command => "/usr/local/bin/freepuppet-run",
		minute  => '*/15'
	}
}