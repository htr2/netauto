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
  config.vbguest.auto_update = true	
  config.vbguest.auto_reboot = true 
  config.ssh.forward_agent = false
  config.winssh.forward_agent = false
  config.winnfsd.logging = "on"
  config.winnfsd.uid = 1
  config.winnfsd.gid = 1
 
  #to enable nfs sharing this uses the winnfsd plugin (https://github.com/winnfsd/winnfsd/releases). 
  #however as it seems unreliable the 'manual' option is to uncomment the next line (and comment the plugin to prevent conflict)
  #system "start nfsshare/WinNFSd.exe . /export"
  #can be manually be mounted / unmounted from linux guests with 
  #sudo mount -o 'vers=3,nolock,udp' -t nfs <your_guest_ip-private_net>:/export /mnt/nfs
  #sudo umount /mnt/nfs

  vagrant_root = File.dirname(__FILE__)
  guests = YAML.load_file(vagrant_root + '/vagrant_topology.yml')
  file1 = File.open(vagrant_root + "/sync/ansible/ansible_inventory" ,'w')
  file2 = File.open(vagrant_root + "/sync/cumulus/topology.dot" ,'w')
  file2.puts("graph g {\n node [shape=record];\n graph [nodesep=\"2\" ranksep=\"1\"];\n BFD=\"upMinTx=150,requiredMinRx=250,afi=both\" \n LLDP=\"\" ")
  

  
	guests.each do |guest|
		
		#create ansible inventory for switches from vagrant topology
		if guest["name"].include? "SW"
			file1.puts("#{guest["name"]} ansible_host=10.0.2.2 ansible_port=#{guest["forwarded_ports"][0]["host"]} api_port=#{guest["forwarded_ports"][1]["host"]} ansible_user=vagrant ansible_password=vagrant \n")	
		end

		#create graphviz topology file used for cumulus prescriptive topology manager from vagrant topology
		if guest["name"].include? "SW"		
			#using spines names (ie SW2xx) only to avoid duplicates
			if guest["name"].include? "SW2"
				if guest.key?("links")
					guest["links"].each do |link|
						file2.puts( link["name"] )
					end
				end
			end
			#creating ports
			s = "#{guest["name"]} [label=\" #{guest["name"]}"
			for i in 1..guest["switch_ports"]
				s = s + "| <swp#{i}> swp#{i}"
			end
			s = s + "\"];"
			file2.puts(s)
		end


		config.vm.define guest["name"] do |node|
			node.vm.box = guest["box"]
			node.vm.hostname = guest["name"]
			
			node.vm.provider "virtualbox" do |v|
				v.name = guest["name"]
			end
	
			#enable GUI for centos devices
			if guest["box"]="centos/7"
				node.vm.provider "virtualbox" do |w|
					w.gui = true
				end
				node.vm.network "private_network", type: 'dhcp'
				#specifying the adapter with <,name: "VirtualBox Host-Only Ethernet Adapter #2", adapter: "2"> seems to break connectivity 
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
					node.vm.synced_folder "#{syncfolder["source"]}", "#{syncfolder["destination"]}", type: "nfs", mount_options: ["nolock","vers=3","udp","actimeo=1"]
				end	
			end

			###provisioners

			#does not work well ...
			#call noop ansible playbook to get auto created ansible inventory 
			#node.vm.provision "ansible" do |ansible|
			#	ansible.playbook = "./sync/.../ansible_noop.yml"
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
	system "ssh-keygen -y -f .vagrant/machines/MGMT/virtualbox/private_key > sync/id_rsa"
end
#debug template:
#puts "debug output: message for #{guest["name"]}"
puts "if vagrant up fails to mount (SWx0x vbox or MGMT nfs issue), run vagrant reload"
#http://download.virtualbox.org/virtualbox/5.2.22/virtualbox-5.2_5.2.22-126460~Debian~jessie_amd64.deb