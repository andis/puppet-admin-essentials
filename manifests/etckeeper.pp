class etckeeper {    
  file {
    "/etc/etckeeper":
      ensure => directory;
    
    "/etc/etckeeper/etckeeper.conf":
      content => "VCS='git'
HIGHLEVEL_PACKAGE_MANAGER=apt
LOWLEVEL_PACKAGE_MANAGER=dpkg\n",
  }

  package { 
    "etckeeper":
      ensure => installed,
      require => [ File["/etc/etckeeper/etckeeper.conf"],
        	   Package["git-core"] ];
  }
}
