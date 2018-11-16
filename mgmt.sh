#programming tools
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo yum -y install code
sudo yum -y groupinstall development
sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum -y install python36u
sudo yum -y install python36u-pip
sudo yum -y install python36u-devel

#helper tools
sudo yum install -y lsof
sudo yum install -y net-tools
sudo yum install -i tcpdump
sudo yum install -y sshpass
sudo yum install -y pysnmp

#X Desktop (use directly with e.g. xming on windows host or install rdp wrapper)
sudo yum -y groupinstall "GNOME Desktop" "Graphical Administration Tools"
sudo yum -y groupinstall "Server with GUI"
sudo yum -y install terminus-fonts terminus-fonts-console
sudo systemctl isolate graphical.target
sudo systemctl set-default graphical.target

#RDP Desktop -- requires X ----
sudo yum -y install xrdp 
sudo yum -y install tigervnc-server
sudo systemctl start xrdp
sudo systemctl  enable xrdp

#experimental
sudo yum -y install graphviz

#hints 
sudo echo source pve/bin/activate >>start.sh
sudo echo ansible-playbook -i /home/vagrant/sync/ansible/ansible_inventory /home/vagrant/sync/ansible/playbooks/ansible_nclu_pull.yml >>start.sh

#Python Virtual Environment with Ansible Napalm etc
mkdir pve
python3.6 -m venv pve
source pve/bin/activate

sudo python3.6 -m pip install --upgrade pip
sudo python3.6 -m  pip install netmiko
sudo python3.6 -m  pip install ansible
sudo python3.6 -m  pip install napalm
sudo python3.6 -m  pip install pysnmp

sudo shutdown -r now