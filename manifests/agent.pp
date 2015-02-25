# Class: puppet::agent
#
# Class for the puppet agent module.
#
# Parameters:
#   configtimeout
#     Configuration timeout in seconds for the puppet agent, default: 900.
#
#   cron
#     Enable puppet agent runs via cron job, default: false.
#
#   noop
#     Whether puppet agent should be run in noop mode, default: false.
#
#   manage_repo
#     Enable repository management, default: false.
#
#   pluginsync
#     Enable pluginsync for the puppet agent, default: true.
#
#   servername
#     Setup servername in puppet.conf, default: puppet.
#
#   service
#     Enable puppet agent service, default: true.
#
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
# Alessio Cassibba (X-Drum) <swapon@gmail.com>
#
# Copyright 2015 Alessio Cassibba (X-Drum), unless otherwise noted.
#
class puppet::agent (
  $configtimeout = $puppet::params::puppetagent_configtimeout,
  $cron          = $puppet::params::puppetagent_cron,
  $manage_repo   = $puppet::params::manage_repo,
  $noop          = $puppet::params::puppetagent_noop,
  $pluginsync    = $puppet::params::puppetagent_pluginsync,
  $servername    = $puppet::params::puppetagent_servername,
  $service       = $puppet::params::puppetagent_service,
) inherits puppet::params {

  if $manage_repo {
    case $::osfamily {
      redhat: {
        include yum::repo::puppetlabs
      }
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
