# -*- mode: ruby -*-
# vi: set ft=ruby :
#https://github.com/ipspace/NetOpsWorkshop/blob/master/topologies/EOS-Leaf-and-Spine/Vagrantfile

# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

 
# Require Plugins
required_plugins = %w(vagrant-vbguest vagrant-host-shell)

##### START Helper functions
#def install_ssh_key()
#  puts "Adding ssh key to the ssh agent"
#  puts "ssh-add .vagrant\machines\#{host["name"]}\virtualbox\private_key"
#	system "ssh-add .vagrant\machines\#{host["name"]}\virtualbox\private_key"
#	system ""
#end

def install_plugins(required_plugins)
  plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
  if not plugins_to_install.empty?
    puts "Installing plugins: #{plugins_to_install.join(' ')}"
    if system "vagrant plugin install #{plugins_to_install.join(' ')}"
      exec "vagrant #{ARGV.join(' ')}"
    else
      abort "Installation of one or more plugins has failed. Aborting."
    end
  end
end
##### END Helper functions

# Install ssh key
# 
# Uncomment the next line if you're using ssh-agent, start ssh-agent service on windows10
#install_ssh_key
#https://devops.stackexchange.com/questions/1237/how-do-i-configure-ssh-keys-in-a-vagrant-multi-machine-setup
#https://www.phase2technology.com/blog/running-ssh-agent-vagrant
#https://www.vagrantup.com/docs/synced-folders/basic_usage.html

# Check certain plugins are installed
install_plugins required_plugins

# Require YAML module
require 'yaml'


################################################################################
#main
################################################################################
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vbguest.auto_update = false	
	config.ssh.forward_agent = true
	config.winssh.forward_agent = true
	#config.ssh.private_key_path = "C\:\\Users\\hv\\.ssh\\id_rsa" #%USERPROFILE% 
  
  #use external yaml file to create hosts 
  vagrant_root = File.dirname(__FILE__)
  hosts = YAML.load_file(vagrant_root + '/vagrant_topology.yml')

	hosts.each do |host|
	
		config.vm.define host["name"] do |node|
			node.vm.box = host["box"]
			node.vm.hostname = host["name"]

			#use yaml defined nat
			if host.key?("forwarded_ports")
				host["forwarded_ports"].each do |port|
					node.vm.network :forwarded_port, guest: port["guest"], host: port["host"], auto_correct: true
				end
			end

			#use yaml link details to create links between nodes
			if host.key?("links")
				host["links"].each do |link|
					node.vm.network "private_network", virtualbox__intnet: link["name"], auto_config: false
				end
			end

			File.open("ansible_inventory" ,'a') do |f|
				f.write "#{host["name"]} ansible_host=10.0.2.2 ansible_port=#{host["forwarded_ports"][0]["host"]} api_port=#{host["forwarded_ports"][1]["host"]} ansible_user=vagrant ansible_ssh_private_key_file=.vagrant/machines/#{host["name"]}/virtualbox/private_key \n"
		  	end

			###provisioners

			#does not work on windows...
			#call noop ansible playbook to get auto created ansible inventory 
			#node.vm.provision "ansible" do |ansible|
			#	ansible.playbook = "playbook.yml"
			#end

			if host.key?("script")
				node.vm.provision "shell", path: host["script"]
			end



		end
	end
end