import "etckeeper.pp"

class admin-essentials {
  $basepath = "modules/admin-essentials"

  include etckeeper

  package { mc: ensure => latest }
  package { [htop,strace,screen,inotify-tools,debconf-utils,rlwrap,zsh,multitail,git-core,molly-guard]: ensure => latest }

  package { [lsof,less,bc,dc]: ensure => installed; }

  package {
    "emacs":
      name => $operatingsystem ? {
        "Ubuntu" => "emacs23",
        "Debian" => "emacs22-nox",
        default => "emacs-nox",
      },
      ensure => latest,
  }

      
  file {
    "/root/.mc":
      source => "puppet:///${basepath}/dot-midnight-commander",
      owner => "root", group => "root",
      recurse => true,
      ensure => present,
      replace => false,
      require => Package["mc"];
    
    "/root/.zshrc":
      source => "puppet:///${basepath}/dot-zshrc";

    "/root/.screenrc":
      source => "puppet:///${basepath}/dot-screenrc";

    "/root/.emacs":
      source => "puppet:///${basepath}/dot-emacs";

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
