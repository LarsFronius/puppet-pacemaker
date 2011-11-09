Vagrant::Config.run do |config|

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "site.pp"
    puppet.module_path = "modules"
  end

  config.vm.define :host01 do |config|
    config.vm.box = "squeeze64"
    config.vm.network "33.33.33.11"
    config.vm.host_name = "host01.vagrant.internal"
  end

  config.vm.define :host02 do |config|
    config.vm.box = "squeeze64"
    config.vm.network "33.33.33.12"
    config.vm.host_name = "host02.vagrant.internal"
  end

end
