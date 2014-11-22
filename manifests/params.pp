# Class: puppet::params
#
# Parameters for the puppet module.
#
# Sample Usage:
# *Don't include directly*
#
# Alessio Cassibba (X-Drum) <swapon@gmail.com>
#
# Copyright 2014 Alessio Cassibba (X-Drum), unless otherwise noted.
#
class puppet::params {
  $puppetmaster_standalone = true
  $puppetmaster_autosign = false
  $puppetmaster_modulepath = '$confdir/modules:/usr/share/puppet/modules'
  $puppetmaster_docroot = "/etc/puppet/rack"
  $puppetmaster_cert = "/var/lib/puppet/ssl/certs/${fqdn}.pem"
  $puppetmaster_key = "/var/lib/puppet/ssl/private_keys/${fqdn}.pem"
  $puppetmaster_ca = "/var/lib/puppet/ssl/ca/ca_crt.pem"
  $puppetmaster_crl = "/var/lib/puppet/ssl/ca/ca_crl.pem"
  $puppetmaster_maintenance = false
  $puppetmaster_maintenance_retention = '90'
  $puppetmaster_maintenance_time = ["30","0"]
  $puppetagent_servername = "${fqdn}"
  $puppetagent_noop = false
  $puppetagent_cron = false
  $puppetagent_service = true
  $puppetagent_pluginsync = true
  $puppetagent_configtimeout = '900'
  $puppetagent_croncommand = "puppet agent --test"

  case $::osfamily {
  	redhat: {
      $puppet_config = "/etc/puppet/puppet.conf"
  	  $puppet_owner = "root"
  	  $puppet_group = "root"
  	  $puppet_prefix = "/usr/bin"
      $puppet_ssldir = "/var/lib/puppet/ssl"
  	  $puppetagent_pkg = "puppet"
  	  $puppetagent_srv = "puppet"
  	  $puppetmaster_pkg = "puppet-server"
  	  $puppetmaster_srv = "puppetmaster"
      $puppetmaster_reportdir = '/var/lib/puppet/reports'
      $puppetmaster_filebucketdir = '/var/lib/puppet/clientbucket'
  	  $rack_pkg = 'rubygem-rack'
  	  $rack_config = '/usr/share/puppet/ext/rack/config.ru'
  	  $passenger_root = '/usr/lib/ruby/gems/1.8/gems/passenger-3.0.21'
  	}
  	openbsd: {
      $puppet_config = "/etc/puppet/puppet.conf"
  	  $puppet_owner = "root"
  	  $puppet_group = "wheel"
  	  $puppet_prefix = "/usr/local/bin"
      $puppet_ssldir = "/etc/puppet/ssl"
  	  $puppetagent_pkg = "puppet"
  	  $puppetagent_srv = "puppetd"
  	}
    FreeBSD: {
      $puppet_config = "/usr/local/etc/puppet/puppet.conf"
      $puppet_owner = "root"
      $puppet_group = "wheel"
      $puppet_prefix = "/usr/local/bin"
      $puppet_ssldir = "/var/puppet/ssl"
      $puppetagent_pkg = "puppet"
      $puppetagent_srv = "puppet"
    }
  	default: {
      $puppet_owner = "root"
      $puppet_group = "root"
      $puppet_prefix = "/usr/bin"
      $puppet_ssldir = "/var/lib/puppet/ssl"
      $puppetagent_pkg = "puppet"
      $puppetagent_srv = "puppet"
  	}
  }
}
