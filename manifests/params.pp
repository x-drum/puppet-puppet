# Class: puppet::params
#
# Parameters for the puppet module.
#
# Sample Usage:
# *Don't include directly*
#
# === Authors
#
# Alessio Cassibba (X-Drum) <swapon@gmail.com>
#
# === Copyright
#
# Copyright 2014 Alessio Cassibba (X-Drum), unless otherwise noted.
#
class puppet::params {
	$puppet_config = "/etc/puppet/puppet.conf"
	$puppetmaster_standalone = true
	$puppetmaster_autosign = false
	$puppetmaster_servername = "${::fqdn}"
	$puppetmaster_modulepath = '$confdir/modules:/usr/share/puppet/modules'
	$puppetmaster_docroot = "/etc/puppet/rack"
	$puppetmaster_cert = "/var/lib/puppet/ssl/certs/${puppetmaster_servername}.pem"
	$puppetmaster_key = "/var/lib/puppet/ssl/private_keys/${puppetmaster_servername}.pem"
	$puppetmaster_ca = "/var/lib/puppet/ssl/ca/ca_crt.pem"
	$puppetmaster_crl = "/var/lib/puppet/ssl/ca/ca_crl.pem"
	$puppetagent_servername = "change_me_to_puppet_server"
	$puppetagent_noop = false
	$puppetagent_cron = false
	$puppetagent_service = true
	$puppetagent_pluginsync = true
	$puppetagent_configtimeout = '900'
	$puppetagent_croncommand = "puppet agent --test"

	case $::osfamily {
		redhat: {
			$puppet_owner = "root"
			$puppet_group = "root"
			$puppet_prefix = "/usr/bin"
			$puppetagent_pkg = "puppet"
			$puppetagent_srv = "puppet"
			$puppetmaster_pkg = "puppet-server"
			$puppetmaster_srv = "puppetmaster"
			$rack_pkg = 'rubygem-rack'
			$rack_config = '/usr/share/puppet/ext/rack/config.ru'
			$passenger_root = '/usr/lib/ruby/gems/1.8/gems/passenger-3.0.21'
		}
		openbsd: {
			$puppet_owner = "root"
			$puppet_group = "wheel"
			$puppet_prefix = "/usr/local/bin"
			$puppetagent_pkg = "puppet"
			$puppetagent_srv = "puppetd"
		}
		default: {
			fail("Unsupported platform: ${::osfamily}/${::operatingsystem}")
		}
	}
}
  

