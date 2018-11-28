# netauto

(ab)uses vagrant to 
    -build a management server and a leaf and spine switch fabric
    -create ansible_inventory, graphviz topology.dot
it also has a baseline switch config, ansible playbooks for cfg backup/restore, cumulus ptm etc


guests:
MGMT, management server based on centos7 with ansible etc
SW101-SW1xx (leafs), SW201-SW2xx (spines), cumulus

host
Windows 10 Enterprise version 1709 build 16299.726
virtualbox 5.2.22
vagrant 2.2.0



