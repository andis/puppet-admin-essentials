class grml-zsh {
  $apt_dir = "/etc/apt"
  $keyserver = "subkeys.pgp.net"
  $grml_key_id = "ECDEA787"
  $grml_key_installed = "apt-key list | grep ${grml_key_id}"

  exec {
    # get grml key from keyserver
    "gpg-recv-grml-key":
      command => "gpg --keyserver ${keyserver} --recv-keys ${grml_key_id}",
      path =>  ["/bin", "/usr/bin"],
      unless => "${grml_key_installed}";

    # add grml key to apt keyring
    "apt-add-grml-key":
      command => "gpg --export ${grml_key_id} | apt-key add -",
      path =>  ["/usr/bin", "/bin"],
      unless => "${grml_key_installed}",
      require => Exec["gpg-recv-grml-key"];

    # don't forget to run "aptitude update" after adding new repos
    "apt-update":
      command => "aptitude update",
      path =>  ["/bin", "/usr/bin"],
      refreshonly => true;

    # delete grml gpg key after we have installed grml-debian-keyring
    "gpg-del-grml-key":
      command => "gpg --batch --yes --delete-key ${grml_key_id}",
      path =>  ["/usr/bin"],
      refreshonly => true;
  }

  file {
    "${apt_dir}/sources.list.d":
      ensure => "directory";

    # add grml repos for debian
    "${apt_dir}/sources.list.d/grml.list":
      content => "deb     http://deb.grml.org/ grml-stable main
deb-src http://deb.grml.org/ grml-stable main",
      notify => Exec["apt-update"];

    "${apt_dir}/preferences.d":
      ensure => "directory";

    # install nothing but grml-etc-core and grml-debian-keyring from grml repo
    "${apt_dir}/preferences.d/grml-pin":
      content => "Package: *
Pin: release a=grml-stable
Priority: 999

Package: grml-etc-core
Pin: release a=grml-stable
Priority: 400

Package: grml-debian-keyring
Pin: release a=grml-stable
Priority: 400";
  }

  package {
    "grml-debian-keyring":
      ensure => "latest",
      notify => Exec["gpg-del-grml-key"],
      require => [ Exec["apt-add-grml-key"],
                   File["${apt_dir}/preferences.d/grml-pin"],
                   File["${apt_dir}/sources.list.d/grml.list"] ];

    "grml-etc-core":
      ensure => "latest",
      require => Package["grml-debian-keyring"];
  }

}
