# -*- mode: ruby -*-
# vi: set ft=ruby :

# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"
 
# Require YAML module
require 'yaml'

# mgmt station shell script to install desired sw 
$script1 = <<-SCRIPT
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo yum -y install code
sudo yum -y groupinstall development

sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum -y install xrdp tigervnc-server
sudo systemctl start xrdp
sudo systemctl  enable xrdp

sudo yum -y install python36u
sudo yum -y install python36u-pip
sudo yum -y install python36u-devel

mkdir pve
python3.6 -m venv pve
source pve/bin/activate

sudo python3.6 -m pip install --upgrade pip
sudo python3.6 -m  pip install netmiko
sudo python3.6 -m  pip install ansible
sudo python3.6 -m  pip install napalm
SCRIPT

#mgmt station definition
Vagrant.configure("2") do |config|
  config.vm.define "mgmt" do |mgmt|
	mgmt.vm.box = "centos/7"
	mgmt.vm.hostname = "mgmt"
	mgmt.vm.network :forwarded_port, guest: 22, host: 20001
	mgmt.vm.network :forwarded_port, guest: 443, host: 20002
	mgmt.vm.network :forwarded_port, guest: 3389, host: 20003
	mgmt.vm.network :private_network, ip: "192.168.56.10"
	mgmt.vm.provision "shell", inline: $script1
  end

  #fabric definition (using external yaml file)
 
  # Read YAML file 
  vagrant_root = File.dirname(__FILE__)
  hosts = YAML.load_file(vagrant_root + '/fabric_topology.yml')

	hosts.each do |host|
		config.vm.define host["name"] do |sw|
			sw.vm.box = host["box"]
			sw.vm.hostname = host["name"]
			if host.key?("forwarded_ports")
				host["forwarded_ports"].each do |port|
					sw.vm.network :forwarded_port, guest: port["guest"], host: port["host"], id: port["name"]
				end
			end

			if host.key?("links")
				host["links"].each do |link|
					ipaddr = if link.key?("ip") then link["ip"] else "169.254.1.11" end
					sw.vm.network "private_network", virtualbox__intnet: link["name"], ip: ipaddr, auto_config: false
				end
			end


		end

	end

end