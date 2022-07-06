# Install RVM, create system user a install system level rubies
class rvm (
  $version=undef,
  $install_from=undef,
  $install_rvm=true,
  $install_dependencies=false,
  $manage_rvmrc=true,
  $system_users=[],
  $system_rubies= {},
  $rvm_gems= {},
  $proxy_url=$rvm::params::proxy_url,
  $no_proxy=$rvm::params::no_proxy,
  Array[Hash[String[1], String[1]]] $signing_keys = $rvm::params::signing_keys,
) inherits rvm::params {
  if $install_rvm {
    # rvm has now autolibs enabled by default so let it manage the dependencies
    if $install_dependencies {
      class { 'rvm::dependencies':
        before => Class['rvm::system'],
      }
    }

    if $manage_rvmrc {
      ensure_resource('class', 'rvm::rvmrc')
    }

    class { 'rvm::system':
      version      => $version,
      proxy_url    => $proxy_url,
      no_proxy     => $no_proxy,
      signing_keys => $signing_keys,
      install_from => $install_from,
    }
  }

  rvm::system_user { $system_users: }
  create_resources('rvm_system_ruby', $system_rubies, { 'ensure' => present, 'proxy_url' => $proxy_url, 'no_proxy' => $no_proxy })
  if $rvm_gems != {} {
    validate_hash($rvm_gems)
    create_resources('rvm_gem', $rvm_gems )
  }
}
