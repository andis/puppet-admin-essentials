import "etckeeper.pp"
import "grml-zsh.pp"

class admin-essentials {
  $basepath = "modules/admin-essentials"

  include etckeeper
  include grml-zsh

  package {
    ["mc",
     "htop",
     "strace",
     "screen",
     "inotify-tools",
     "debconf-utils",
     "rlwrap",
     "zsh",
     "multitail",
     "git-core",
     "molly-guard",
     "lsof",
     "less",
     "bc",
     "dc",
     "psmisc",
     "tcpdump",
     "moreutils",
     "ack-grep"]:
       ensure => installed;

    "emacs":
      name => $operatingsystem ? {
        "Ubuntu" => "emacs23",
        "Debian" => "emacs23-nox",
        default  => "emacs-nox",
      },
      ensure => installed;
  }

      
  file {
    "/root/.mc":
      source  => "puppet:///${basepath}/dot-midnight-commander",
      owner   => "root",
      group   => "root",
      recurse => true,
      ensure  => present,
      replace => false,
      require => Package["mc"];
    
    "/root/.emacs":
      source => "puppet:///${basepath}/dot-emacs";

    "/root/.ssh":
      ensure => directory;
    
    "/root/.ssh/config":
      content => "host *
ControlPath ~/.ssh/master-%r@%h:%p
ControlMaster auto\n",
      replace => false;

    "/root/.zshrc.local":
      content => "export EDITOR=emacs\n",
      replace => false;

    "/etc/molly-guard/rc":
      content => "ALWAYS_QUERY_HOSTNAME=true\n",
      require => Package["molly-guard"];
  }
  
  user {
    "root wants zsh":
      name    => "root",
      ensure  => present,
      require => Package["zsh"],
      shell   => "/bin/zsh";
  }

  exec {
    "ack should link to ack-grep":
      command => "ln -s /usr/bin/ack-grep /usr/bin/ack",
      path    => ["/bin", "/usr/bin"],
      unless  => "which ack",
      require => Package["ack-grep"];
  }
}
