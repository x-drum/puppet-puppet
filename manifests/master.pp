# Class: puppet::master
#
# Class for the puppet master module.
#
# Parameters:
# [*standalone*]
#   Run puppetmaster in standalone mode (embedded WEBrick)
#   or using Apache (namely apache, mod_passenger and rack) [true, false]
#   default: true.
#
# [*autosign*]
#   Enable autosigning CSRs [true, false], default: false.
#   TODO: filepath support
#
# [*servername*]
#   Setup servername in puppet.conf, default: puppet.
#
# [*modulepath*]
#   Setup modulepath in puppet.conf, default: $confdir/modules:/usr/share/puppet/modules.
#
# Requires:
# puppetlabs-apache
# puppetlabs-inifile
# example42-yum
#
# Sample Usage:
# puppet apply --modulepath /etc/puppet/modules /etc/puppet/modules/puppet/manifests/master.pp
#
#  class { 'puppet::master':
#    servername => 'master.foo.bar',
#    standalone => false,
#  }
#
# === Authors
#
# Alessio Cassibba (X-Drum) <swapon@gmail.com>
#
# === Copyright
#
# Copyright 2014 Alessio Cassibba (X-Drum), unless otherwise noted.
#
class puppet::master (
	$standalone = $puppet::params::puppetmaster_standalone,
	$autosign = $puppet::params::puppetmaster_autosign,
	$servername = $puppet::params::puppetmaster_servername,
	$modulepath = $puppet::params::puppetmaster_modulepath,
) inherits puppet::params {

	case $::osfamily {
		redhat: {
			include yum::repo::puppetlabs
		}
		default: {
			fail("Unsupported platform: ${::osfamily}/${::operatingsystem}")
		}
	}

	package { $puppet::params::puppetmaster_pkg:
		ensure => installed,
	}

	Ini_setting {
		path    => $puppet::params::puppet_config,
		ensure  => present,
	}
	ini_setting { 'master_pluginsync':
		section => 'main',
		setting => 'pluginsync',
		value => 'true',
	}
	ini_setting { 'master_server':
		section => 'main',
		setting => 'server',
		value => $servername,
	}
	ini_setting { 'master_autosign':
		section => 'main',
		setting => 'autosign',
		value => $autosign,
	}
	ini_setting { 'master_modulepath':
		section => 'main',
		setting => 'modulepath',
		value => $modulepath,
	}

	if($standalone) {
		file { $puppet::params::puppet_config:
			ensure => present,
			owner => root,
			group => root,
			mode => '0644',
			require => Package[$puppet::params::puppetmaster_pkg],
			notify => Service[$puppet::params::puppetmaster_srv],
		}
		service { $puppet::params::puppetmaster_srv:
		    enable => true,
			ensure => running,
			hasrestart => true,
			hasstatus => true,
			require => Package[$puppet::params::puppetmaster_pkg],
		}
	}
	else {
		include apache::params
		file { $puppet::params::puppet_config:
			ensure => present,
			owner => root,
			group => root,
			mode => '0644',
			notify => Service[$apache::params::service_name],
		}
		service { $puppet::params::puppetmaster_srv:
		    enable => false,
			ensure => stopped,
		}
		package { $puppet::params::rack_pkg:
			ensure => installed
		}
		class { 'apache':
			default_mods => false,
			default_confd_files => false,
			default_vhost => false,
			default_ssl_vhost => false,
		}
		class { 'apache::mod::ssl': }
		class { 'apache::mod::headers': }
		class { 'apache::mod::passenger':
		  passenger_high_performance  => 'on',
		  passenger_max_pool_size => '6',
		  passenger_max_requests => '1000',
		  passenger_pool_idle_time => '600',
		  passenger_root => $puppet::params::passenger_root,
		  passenger_ruby => '/usr/bin/ruby',
		}
		apache::vhost { 'puppetmaster':
			port    => '8140',
			docroot => "${puppet::params::puppetmaster_docroot}/public/",
			docroot_owner => 'root',
			docroot_group => 'root',
			ssl => true,
			ssl_options => ['+StdEnvVars','+ExportCertData'],
			ssl_protocol => 'All -SSLv2',
			ssl_cipher => 'HIGH:!ADH:RC4+RSA:-MEDIUM:-LOW:-EXP',
			ssl_cert => $puppet::params::puppetmaster_cert,
			ssl_key => $puppet::params::puppetmaster_key,
			ssl_chain => $puppet::params::puppetmaster_ca,
			ssl_ca => $puppet::params::puppetmaster_ca,
			ssl_crl => $puppet::params::puppetmaster_crl,
			ssl_verify_client => 'optional',
			ssl_verify_depth => '1',
			directories => [
				{ 'path' => "${puppet::params::puppetmaster_docroot}",
				  'provider' => 'directory',
				  'allow' => 'from all',
				  'allow_override' => 'none',
				 },
			],
			custom_fragment => '
			RequestHeader set X-SSL-Subject %{SSL_CLIENT_S_DN}e
			RequestHeader set X-Client-DN %{SSL_CLIENT_S_DN}e
			RequestHeader set X-Client-Verify %{SSL_CLIENT_VERIFY}e'
		}
		file { $puppet::params::puppetmaster_docroot:
			owner => root,
			group => root,
			ensure => directory,
		}
		file { "${puppet::params::puppetmaster_docroot}/public/":
			owner => puppet,
			group => puppet,
			ensure => directory,
		}
		file { "${puppet::params::puppetmaster_docroot}/tmp/":
			owner => puppet,
			group => puppet,
			ensure => directory,
		}
		file { "${puppet::params::puppetmaster_docroot}/config.ru":
			owner => puppet,
			group => puppet,
			ensure => present,
			source => $puppet::params::rack_config,
		}
	}
}
