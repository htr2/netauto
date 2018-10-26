# -*- mode: ruby -*-
# vi: set ft=ruby :
#https://github.com/ipspace/NetOpsWorkshop/blob/master/topologies/EOS-Leaf-and-Spine/Vagrantfile
# vagrant 2.2.0
# virtualbox 5.2.20
# Windows 10 Enterprise version 1709 build 16299.726

# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

require 'yaml'
require 'vagrant-vbguest'

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

			if host.key?("syncfolders")
				host["syncfolders"].each do |syncfolder|
					node.vm.synced_folder "#{syncfolder["source"]}", "#{syncfolder["destination"]}"
				end	
			end

		end
	end
end

