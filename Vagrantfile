# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    config.vm.define :europe do |cfg|
        cfg.vm.box = "ubuntu1404"
        cfg.vm.box_url = "http://files.vagrantup.com/precise32.box"
        cfg.vm.hostname = "europe.vbox"
        cfg.vm.network :private_network, ip: "33.33.33.202"
        cfg.vm.network "forwarded_port", guest: 80, host: 80
        cfg.vm.provider :virtualbox do |vb|
            vb.customize ["modifyvm", :id, "--memory", "1024"]
            vb.name = "europe.vbox"
        end
    end
end
