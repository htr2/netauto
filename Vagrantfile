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

################################################################################
#main
################################################################################
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  required_plugins = ["vagrant-vbguest"] #["vagrant-vbguest", "other"]
  config.vagrant.plugins = required_plugins

  config.vbguest.auto_update = true	
  config.ssh.forward_agent = false
  config.winssh.forward_agent = false
  #config.ssh.private_key_path = "C\:\\Users\\hv\\.ssh\\id_rsa" #%USERPROFILE% 
  
  #use external yaml file to create guests 
  vagrant_root = File.dirname(__FILE__)
  guests = YAML.load_file(vagrant_root + '/vagrant_topology.yml')

	guests.each do |guest|
	
		config.vm.define guest["name"] do |node|
			node.vm.box = guest["box"]
			node.vm.hostname = guest["name"]
			
			node.vm.provider "virtualbox" do |v|
				v.name = guest["name"]
			end
	
			#enable GUI on mgmt
			if guest["box"]="centos/7"
				node.vm.provider "virtualbox" do |w|
					w.gui = true
				end
			end  

			#use yaml defined nat
			if guest.key?("forwarded_ports")
				guest["forwarded_ports"].each do |port|
					node.vm.network :forwarded_port, guest: port["guest"], host: port["host"], auto_correct: true
				end
			end

			#use yaml link details to create links between nodes
			if guest.key?("links")
				guest["links"].each do |link|
					node.vm.network "private_network", virtualbox__intnet: link["name"], auto_config: false
				end
			end

			#use yaml defined folders to sync
			if guest.key?("syncfolders")
				guest["syncfolders"].each do |syncfolder|
					node.vm.synced_folder "#{syncfolder["source"]}", "#{syncfolder["destination"]}"
				end	
			end

			#log host to forwarded port details to be copied into ansible inventory
			File.open("ansible_inventory_entry_log" ,'a') do |f|
				f.write "#{guest["name"]} ansible_host=10.0.2.2 ansible_port=#{guest["forwarded_ports"][0]["host"]} api_port=#{guest["forwarded_ports"][1]["host"]} ansible_user=vagrant ansible_password=vagrant \n"
		  	end

			###provisioners

			#does not work well ...
			#call noop ansible playbook to get auto created ansible inventory 
			#node.vm.provision "ansible" do |ansible|
			#	ansible.playbook = "./sync/ansible_noop.yml"
			#end

			if guest.key?("script")
				node.vm.provision "shell", path: guest["script"]
			end

		end
	end
end

#puts "debug output: message for #{guest["name"]}"