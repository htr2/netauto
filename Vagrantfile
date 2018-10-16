# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<-SCRIPT
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

Vagrant.configure("2") do |config|
  config.vm.define "mgmt" do |mgmt|
	mgmt.vm.box = "centos/7"
	mgmt.vm.hostname = "mgmt"

	mgmt.vm.network :private_network, ip: "192.168.56.10"
  end

config.vm.provision "shell", inline: $script

end
