import "etckeeper.pp"
import "grml-zsh.pp"

class admin-essentials {
  $basepath = "modules/admin-essentials"

  include etckeeper
  include grml-zsh

  package { mc: ensure => latest }
  package { [htop, strace, screen, inotify-tools, debconf-utils, rlwrap, zsh, multitail, git-core, molly-guard, lsof, less, bc, dc, psmisc, tcpdump, moreutils]: ensure => installed }

  package {
    "emacs":
      name => $operatingsystem ? {
        "Ubuntu" => "emacs23",
        "Debian" => "emacs23-nox",
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
