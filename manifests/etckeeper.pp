class etckeeper {
  file {
    "/etc/etckeeper":
      ensure => directory;
    
    "etckeeper.conf":
      path    => "/etc/etckeeper/etckeeper.conf",
      content => "VCS='git'
HIGHLEVEL_PACKAGE_MANAGER=apt
LOWLEVEL_PACKAGE_MANAGER=dpkg\n";
  }

  package {
    "etckeeper":
      ensure  => installed,
      require => [ File["etckeeper.conf"],
        	   Package["git-core"] ];
  }
}
