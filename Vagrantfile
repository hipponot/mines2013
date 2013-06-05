# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  # All Vagrant configuration is done here. the most common configuration
  # options are documented and commented below.    For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "base32"

  # the url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"  
  # config.vm.share_folder "mines2013", "/home/vagrant/mines2013", "../../mines2013"
  
  # Boot with a GUI so you can see the screen. (Default is headless)
  # config.vm.boot_mode = :gui
  # config.vm.forward_port 80, 8080
  config.vm.forward_port 9393, 9393
  config.vm.forward_port 27017, 27017

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.


  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding 
  # some recipes and/or roles.
  #
   config.vm.provision :chef_solo, :log_level=>:debug do |chef|
    # chef.cookbooks_path = "../cookbooks"
    chef.add_recipe "apt"
    chef.add_recipe "emacs"
    chef.add_recipe "woot_api::default"
    chef.add_recipe "woot_api::github"
    chef.add_recipe "bash_setup"
    chef.add_recipe "mongo_db"
    chef.add_recipe "desktop_setup"
    chef.add_recipe "imagemagick::rmagick"
    chef.add_recipe "tesseract"
     chef.json = { 
      'emacs' => {'packages' => ['emacs'] }
     }
    chef.add_recipe "amazon"
   end
  
end
