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
require 'fileutils'

################################################################################
#main
################################################################################
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  required_plugins = ["vagrant-vbguest"] #["vagrant-vbguest", "other"]
  config.vagrant.plugins = required_plugins

  config.vbguest.auto_update = true	
  config.ssh.forward_agent = false
  config.winssh.forward_agent = false
 
  vagrant_root = File.dirname(__FILE__)
  guests = YAML.load_file(vagrant_root + '/vagrant_topology.yml')
  file1 = File.open(vagrant_root + "/sync/ansible/ansible_inventory" ,'w')
  file2 = File.open(vagrant_root + "/sync/cumulus/topology.dot" ,'w')
  file2.puts("graph g { node [shape=record]; ")

  $spine_counter=0
  
	guests.each do |guest|
		
		#create ansible inventory for switches from vagrant topology
		if guest["name"].include? "SW"
			file1.puts("#{guest["name"]} ansible_host=10.0.2.2 ansible_port=#{guest["forwarded_ports"][0]["host"]} api_port=#{guest["forwarded_ports"][1]["host"]} ansible_user=vagrant ansible_password=vagrant \n")	
		end

		#create graphviz topology file used for cumulus prescriptive topology manager from vagrant topology
		#using spines link names only to avoid duplicates, number of spines also indicates required number of ports per switch
		if guest["name"].include? "SW2"
			$spine_counter += 1
			if guest.key?("links")
				guest["links"].each do |link|
					file2.puts( link["name"] )
				end
			end
		end
		puts("debug fix fixed number of port based on number of spines: #$spine_counter") 
		file2.puts("#{guest["name"]} [label=\" #{guest["name"]} | <swp1> swp1 | <swp2> swp2 \"];")



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

			#vagrant topology defined nat
			if guest.key?("forwarded_ports")
				guest["forwarded_ports"].each do |port|
					node.vm.network :forwarded_port, guest: port["guest"], host: port["host"], auto_correct: true
				end
			end

			#vagrant topology defined link details to create links between nodes
			if guest.key?("links")
				guest["links"].each do |link|
					node.vm.network "private_network", virtualbox__intnet: link["name"], auto_config: false
				end
			end

			#vagrant topology defined folders to sync
			if guest.key?("syncfolders")
				guest["syncfolders"].each do |syncfolder|
					node.vm.synced_folder "#{syncfolder["source"]}", "#{syncfolder["destination"]}"
				end	
			end

			###provisioners

			#does not work well ...
			#call noop ansible playbook to get auto created ansible inventory 
			#node.vm.provision "ansible" do |ansible|
			#	ansible.playbook = "./sync/ansible_noop.yml"
			#end

			#provision MGMT
			if guest.key?("script")
				node.vm.provision "shell", path: guest["script"]
			end

		end
	end
	file1.close
	file2.puts("}")
	file2.close
end

#puts "debug output: message for #{guest["name"]}"