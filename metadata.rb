name             "jenkins_ecosystem"
maintainer       'Jay Flowers'
maintainer_email 'jay.flowers@gmail.com'
license          'Apache 2.0'
description      "Installs/Configures jenkins_ecosystem"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0.1"

depends 'chef_commons'
depends 'java'
depends 'jenkins', '~> 2.4.0'
depends 'apache2', '~> 3.2.0'
depends 'selinux'
depends 'ec2'
depends 'sudo'
depends 'git'
depends 'java-osx', '0.1.1'
depends 'java-windows', '1.0.3'
