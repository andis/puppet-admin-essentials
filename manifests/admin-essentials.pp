import "etckeeper.pp"
include etckeeper

class admin-essentials {
  $thisclass = "admin-essentials"
  
  package { mc: ensure => latest }
  package { [htop,strace,screen,inotify-tools,debconf-utils,rlwrap,zsh,multitail,git-core,molly-guard]: ensure => latest }

  package { [lsof,less,bc,dc]: ensure => installed; }

  package {
    "emacs":
      name => $operatingsystem ? {
        "Ubuntu" => "emacs23",
        "Debian" => "emacs22-nox",
        "default" => "emacs-nox",
      },
      ensure => latest,
  }

      
  file {
    "/root/.mc":
      source => "puppet:///${thisclass}/dot-midnight-commander",
      owner => "root", group => "root",
      recurse => true,
      ensure => present,
      replace => false,
      require => Package["mc"];
    
    "/root/.zshrc":
      source => "puppet:///${thisclass}/dot-zshrc";

    "/root/.screenrc":
      source => "puppet:///${thisclass}/dot-screenrc";

    "/root/.emacs":
      source => "puppet:///${thisclass}/dot-emacs";

    "/root/.ssh":
      ensure => "directory";
    
    "/root/.ssh/config":
      content => "host *\nControlPath ~/.ssh/master-%r@%h:%p\nControlMaster auto\n",
      replace => false;
  }
  
  user {
    "root wants zsh":
      name => "root",
      ensure  => present,
      require => Package[zsh],
      shell => '/bin/zsh',
  }

  file { 
    "/etc/molly-guard/rc":
      content => "ALWAYS_QUERY_HOSTNAME=true\n",
      require => Package["molly-guard"];
  }

}
