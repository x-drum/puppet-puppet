## This module manages puppet: master and agent nodes.

Currently supports: RHEL/CentOS, OpenBSD (agent only)

## Class: puppet::master

Class for the puppet master module.

### Parameters:
[*autosign*]  
  Enable autosigning CSRs [true, false], default: false.
  TODO: filepath support

[*maintenance*]  
  Enable the maintenance cronjob (cleanup old reports and clientbucket files) [true, false], default: false.

[*maintenance_time*]  
  Scheduled time for the maintenance cronjob [array: mm,hh], default: 00:30.

[*manage_repo*]  
  Enable repository management, default: false.

[*modulepath*]  
  Setup modulepath in puppet.conf, default: $confdir/modules:/usr/share/puppet/modules.

[*servername*]  
  Setup servername in puppet.conf, default: puppet.

[*standalone*]  
  Run puppetmaster in standalone mode (embedded WEBrick)
  or using Apache (namely apache, mod_passenger and rack) [true, false]
  default: true.

### Requires:  
* puppetlabs-apache
* puppetlabs-inifile
* example42-yum

### Sample Usage:

```
puppet apply --modulepath /etc/puppet/modules /etc/puppet/modules/puppet/manifests/master.pp
```

 ```puppet
 class { 'puppet::master':
   servername => 'master.foo.bar',
   standalone => false,
 }
 ```
## Class: puppet::agent

Class for the puppet agent module.

### Parameters:
[*configtimeout*]  
  Configuration timeout in seconds for the puppet agent, default: 900.

[*cron*]  
  Enable puppet agent runs via cron job, default: false.

[*noop*]  
  Whether puppet agent should be run in noop mode, default: false.

[*pluginsync*]  
  Enable pluginsync for the puppet agent, default: true.

[*service*]  
  Enable puppet agent service, default: true.

[*servername*]  
  Setup servername in puppet.conf, default: puppet.

### Requires:
* puppetlabs-inifile
* example42-yum

### Sample Usage:
```
puppet apply --modulepath /etc/puppet/modules /etc/puppet/modules/puppet/manifests/agent.pp
```

 ```puppet
 class { 'puppet::agent':
   servername => 'master.foo.bar',
   service => true,
   cron => false,
 }
 ```

### Copyright:
Copyright 2015 Alessio Cassibba (X-Drum), unless otherwise noted.
