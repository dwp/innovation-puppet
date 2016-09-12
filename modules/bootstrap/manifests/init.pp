
# Boostrap class to push standard tools and configuration on to managed hosts.
class bootstrap {
	
	# ensure everyones running off AWS standard time servers
	class { '::ntp':
		servers => [
			'0.amazon.pool.ntp.org',
			'1.amazon.pool.ntp.org',
			'2.amazon.pool.ntp.org',
			'3.amazon.pool.ntp.org'
		],
		iburst_enable => true
	}
}