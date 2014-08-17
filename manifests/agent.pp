# Class: puppet::agent
#
# Class for the puppet agent module.
#
# Parameters:
#   [*servername*]
#     Setup servername in puppet.conf, default: puppet.
# 
#   [*noop*]
#     Whether puppet agent should be run in noop mode, default: false.
#
#   [*cron*]
#     Enable puppet agent runs via cron job, default: false.
#
#   [*service*]
#     Enable puppet agent service, default: true.
#
#   [*pluginsync*]
#     Enable pluginsync for the puppet agent, default: true.
#
#   [*configtimeout*]
#     Configuration timeout in seconds for the puppet agent, default: 900.
#
# Requires:
# puppetlabs-inifile
# example42-yum
#
# Sample Usage:
# puppet apply --modulepath /etc/puppet/modules /etc/puppet/modules/puppet/manifests/agent.pp
#
#  class { 'puppet::agent':
#    servername => 'master.foo.bar',
#    service    => true,
#    cron       => false,
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
class puppet::agent (
  $servername = $puppet::params::puppetagent_servername,
  $noop = $puppet::params::puppetagent_noop,
  $cron = $puppet::params::puppetagent_cron,
  $service = $puppet::params::puppetagent_service,
  $pluginsync = $puppet::params::puppetagent_pluginsync,
  $configtimeout = $puppet::params::puppetagent_configtimeout,
) inherits puppet::params {

  case $::osfamily {
    redhat: {
      include yum::repo::puppetlabs
    }
  }

  package { $puppet::params::puppetagent_pkg:
    ensure => installed,
  }
  file { $puppet::params::puppet_config:
  	ensure => present,
  	owner  => $puppet::params::puppet_owner,
  	group  => $puppet::params::puppet_group,
  	mode   => '0644',
  }

  Ini_setting {
  	path   => $puppet::params::puppet_config,
  	ensure => present,
  }
  ini_setting { 'puppetagent_servername':
    section => 'agent',
    setting => 'server',
    value   => "${servername}",
  }
  ini_setting { 'puppetagent_pluginsync':
    section => 'agent',
    setting => 'pluginsync',
    value   => "${pluginsync}",
  }
  ini_setting { 'puppetagent_noop':
    section => 'agent',
    setting => 'noop',
    value   => "${noop}",
  }
  ini_setting { 'puppetagent_configtimeout':
    section => 'agent',
    setting => 'configtimeout',
    value   => "${configtimeout}",
  }

  $service_ensure = $service ? {
    true  => running,
    false => stopped,
  }

  service { $puppet::params::puppetagent_srv:
  	enable     => $service,
  	ensure     => $service_ensure,
  	hasrestart => true,
  	hasstatus  => true,
  	require    => Package[$puppet::params::puppetagent_pkg],
  	subscribe  => File[$puppet::params::puppet_config]
  }

  /*randomize cron runs..*/
  $r1 = fqdn_rand(30)
  $r2 = $r1+30

  $cron_ensure = $cron ? {
    true  => present,
    false => absent,
  }

  cron { 'puppetagent':
    ensure  => $cron_ensure,
    command => "${puppet::params::puppet_prefix}/${puppet::params::puppetagent_croncommand} --configtimeout ${puppet::params::puppetagent_configtimeout} 2>&1 >/dev/null",
    user    => $puppet::params::puppet_owner,
    minute  => [$r1,$r2],
  }
}
