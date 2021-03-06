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

#attempt to fix DHCP error when specifying vboxnetwork for MGMT 
class VagrantPlugins::ProviderVirtualBox::Action::Network
	def dhcp_server_matches_config?(dhcp_server, config)
	  true
	end
end

################################################################################
#main
################################################################################
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  required_plugins = ["vagrant-vbguest", "vagrant-cachier", "vagrant-winnfsd"] #["vagrant-vbguest", "other"]
  config.vagrant.plugins = required_plugins

  config.cache.scope = :machine #to have different buckets for our multi machine
  config.ssh.forward_agent = false
  config.winssh.forward_agent = false
  config.winnfsd.logging = "on"
  config.winnfsd.uid = 1
  config.winnfsd.gid = 1
 
  #to enable nfs sharing this uses the winnfsd plugin (https://github.com/winnfsd/winnfsd/releases). 
  #however as it seems unreliable the 'manual' option is to uncomment the next line (and comment the plugin to prevent conflict)
  #system "start .vagrant\plugins\gems\2.4.4\gems\vagrant-winnfsd-1.4.0\bin . /export"
  #can be manually be mounted / unmounted from linux guests with 
  #sudo mount -o 'vers=3,nolock,udp' -t nfs <your_guest_ip-private_net>:/export /mnt/nfs
  #sudo umount /mnt/nfs

  vagrant_root = File.dirname(__FILE__)
  guests = YAML.load_file(vagrant_root + '/vagrant_topology.yml')
  file1 = File.open(vagrant_root + "/sync/ansible/ansible_inventory" ,'w')
  file1.puts("[all:vars] \nansible_ssh_common_args='-o StrictHostKeyChecking=no' \n[all]")
  file2 = File.open(vagrant_root + "/sync/cumulus/topology.dot" ,'w')
  file2.puts("graph g {\n node [shape=record];\n graph [nodesep=\"2\" ranksep=\"1\"];\n BFD=\"upMinTx=150,requiredMinRx=250,afi=both\" \n LLDP=\"\" ")
  

  
	guests.each do |guest|
		
		#####switches###############################################
		#create ansible inventory for switches from vagrant topology
		if guest["name"].include? "SW"
			file1.puts("#{guest["name"]} ansible_host=10.0.2.2 ansible_port=#{guest["forwarded_ports"][0]["host"]} api_port=#{guest["forwarded_ports"][1]["host"]} ansible_user=vagrant ansible_password=vagrant \n")	

			#create graphviz topology file used for cumulus prescriptive topology manager from vagrant topology	
			#using spines names (ie SW2xx) only to avoid duplicates
			if guest["name"].include? "SW2"
				if guest.key?("links")
					guest["links"].each do |link|
						file2.puts( link["name"] )
					end
				end
			end
			#for the ports
			s = "#{guest["name"]} [label=\" #{guest["name"]}"
			for i in 1..guest["switch_ports"]
				s = s + "| <swp#{i}> swp#{i}"
			end
			s = s + "\"];"
			file2.puts(s)


			config.vm.define guest["name"] do |switch|
				switch.vbguest.auto_update = false	
				switch.vbguest.auto_reboot = false 
				switch.vm.box = guest["box"]
				switch.vm.hostname = guest["name"]

				switch.vm.provider "virtualbox" do |v|
					v.name = guest["name"]
				end

				#vagrant topology defined nat
				if guest.key?("forwarded_ports")
					guest["forwarded_ports"].each do |port|
						switch.vm.network :forwarded_port, guest: port["guest"], host: port["host"], auto_correct: true
					end
				end

				#vagrant topology defined link details to create links between nodes
				if guest.key?("links")
					guest["links"].each do |link|
						switch.vm.network "private_network", virtualbox__intnet: link["name"], auto_config: false
					end
				end

				#disable default sync folder
				switch.vm.synced_folder '.', '/vagrant', diabled: true
				
			end
		end

		########MGMT###############################################
		if guest["name"].include? "MGMT"

			config.vm.define guest["name"] do |mgmt|

				mgmt.vbguest.auto_update = true	
				mgmt.vbguest.auto_reboot = true 
				mgmt.vm.box = guest["box"]
				mgmt.vm.hostname = guest["name"]

				mgmt.vm.provider "virtualbox" do |v1|
					v1.name = guest["name"]
					v1.gui = true
				end

				mgmt.vm.network "private_network", type: 'dhcp'
				#specifying the adapter with <,name: "VirtualBox Host-Only Ethernet Adapter #2", adapter: "2"> seems to break connectivity 
 
				#vagrant topology defined nat
				if guest.key?("forwarded_ports")
					guest["forwarded_ports"].each do |port|
						mgmt.vm.network :forwarded_port, guest: port["guest"], host: port["host"], auto_correct: true
					end
				end

				#vagrant topology defined folders to sync
				if guest.key?("syncfolders")
					guest["syncfolders"].each do |syncfolder|
						mgmt.vm.synced_folder "#{syncfolder["source"]}", "#{syncfolder["destination"]}", type: "nfs", mount_options: ["nolock","vers=3","udp","actimeo=1"]
					end	
				end
						
				#provision MGMT
				if guest.key?("script")
					mgmt.vm.provision "shell", path: guest["script"]
				end
			end
		end
	end
	file1.close
	file2.puts("}")
	file2.close
	system "ssh-keygen -y -f .vagrant/machines/MGMT/virtualbox/private_key > sync/id_rsa"
end
#debug template:
#puts "debug output: message for #{guest["name"]}"
puts "if vagrant up fails to mount (SWx0x vbox or MGMT nfs issue), run vagrant reload"
#http://download.virtualbox.org/virtualbox/5.2.22/virtualbox-5.2_5.2.22-126460~Debian~jessie_amd64.deb