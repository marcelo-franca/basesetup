# Class: basesetup
#
#
class basesetup::packages {
$docker_repo_installed = 'YES'
$puppet_repo_installed = 'YES'

$packages_ubuntu = [ 'apt-transport-https', 'ca-certificates', 'curl',
'gnupg-agent', 'software-properties-common' ]

$packages_centos = [ ]

$packages_docker = [ 'docker-ce', 'docker-ce-cli', 'containerd.io' ]

if $::operatingsystem == 'ubuntu' {

  case $::operatingsystemmajrelease {
    '18.04': {
      exec { 'repository_docker':
        command  => 'true; \
          cd /tmp; \
          curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - ; \
          add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"; \
          apt-get update; \
          curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
          chmod +x /usr/local/bin/docker-compose
          ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
          echo "YES" > /tmp/.install.DOCKER_REPO; ',
        onlyif   => "result=\"\$(cat /tmp/.install.DOCKER_REPO;)\"; \
          test \"\$result\" != \"${docker_repo_installed}\" ; ",
        provider => 'shell',
        path     => ['/usr/local/sbin', '/usr/local/bin','/usr/sbin','/usr/bin','/sbin','/bin'],
        timeout  => '14400',
        require  => Package[$packages_ubuntu],
      }
    }
    default: {
      fail('[ERROR] unknown OS')
    }
  }
}
else{
  fail('[ERROR] unknown OS')
}

$packages = $facts['os']['name'] ? {
    'Ubuntu' => $packages_ubuntu,
    'Centos' => $packages_centos
}

package { $packages:
  ensure => 'present'
}

package { $packages_docker:
  ensure  => 'present',
  require => Exec['repository_docker'] and Package[$packages_ubuntu or $packages_centos]

}
service { 'docker':
ensure  => 'running',
require => Package['docker-ce'],
}
}
