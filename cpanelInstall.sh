#!/bin/bash
clear

# Disable selinux
setenforce 0 >> /dev/null 2>&1

# CentOS detected
if [ ! -f /etc/redhat-release ]; then
	echo "CentOS was not detected. Aborting"
	exit 0
fi

# Input data
read -p "Please Enter Your Gateway Addreess: " ip
read -p "Please Enter NIC Name Without ifcfg-: " interfaceName
read -p "Please Enter Your Hostname: " hostname

# IPv4 validator
if [[ "$ip" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then
	echo "Valid : "$ip
else
	echo "Not valid : "$ip
fi

# Set hostname
hostnamectl set-hostname $hostname

# SELINUX disable
echo "SELINUX disable started.";
sed -i 's,SELINUX=enforcing,SELINUX=disabled,g' /etc/selinux/config > /dev/null 2>&1;
echo -e "SELINUX were disabled.\n";
sleep 2;

# NetworkManager disable
echo "NetworkManager disable started.";
systemctl --now disable NetworkManager > /dev/null 2>&1;
echo -e "NetworkManager were disabled.\n";
sleep 2;

# network.service enable
echo "network.service enable started.";
systemctl enable network.service > /dev/null 2>&1;
echo -e "$ip dev $interfaceName \ndefault via $ip dev $interfaceName" > /etc/sysconfig/network-scripts/route-$interfaceName
systemctl restart network.service > /dev/null 2>&1;
echo -e "network.service were enable.\n";
sleep 2;

# CentOS change mirror
echo "CentOS change mirror started.";
sed -i 's,mirrorlist,#mirrorlist,g' /etc/yum.repos.d/CentOS-Base.repo > /dev/null 2>&1;
sed -i 's,#baseurl,baseurl,g' /etc/yum.repos.d/CentOS-Base.repo > /dev/null 2>&1;
sed -i 's,mirror.centos.org,mirror.0-1.cloud,g' /etc/yum.repos.d/CentOS-Base.repo > /dev/null 2>&1;
echo -e "CentOS mirror were changed.\n";
sleep 2;

# CentOS update
echo "CentOS update started.";
yum -y update > /dev/null 2>&1;
echo -e "CentOS were updated.\n";
sleep 2;

# EPEL install
echo "EPEL installation started.";
yum -y install epel-release > /dev/null 2>&1;
echo -e "EPEL were installed.\n";
sleep 2;

# EPEL edited
echo "EPEL mirror edit started.";
sed -i 's,metalink,#metalink,g' /etc/yum.repos.d/epel.repo > /dev/null 2>&1;
sed -i 's,#baseurl,baseurl,g' /etc/yum.repos.d/epel.repo > /dev/null 2>&1;
sed -i 's,download.fedoraproject.org/pub,mirror.0-1.cloud,g' /etc/yum.repos.d/epel.repo > /dev/null 2>&1;
echo -e "EPEL mirror were edited.\n";
sleep 2;

# Install packages
echo "Install packages started.";
yum -y install screen wget nano mlocate zip unzip bzip2 htop axel nload tcpdump mtr telnet traceroute git glances > /dev/null 2>&1;
echo -e "Packages were installed.\n";
sleep 2;

# MySQL repo edited
echo "MySQL repo edit started.";
echo "195.211.46.243 repo.mysql.com" >> /etc/hosts
chattr +ia /etc/hosts
echo -e "MySQL repo were edited.\n";
sleep 2;

# cPanel repo added
echo "cPanel repo added started.";
echo "HTTPUPDATE=195.211.46.244" > /etc/cpsources.conf
echo -e "cPanel repo were added.\n";
sleep 2;

wget -O /home/latest https://securedownloads.cpanel.net/latest
chmod +x /home/latest
sh /home/latest

bash <( curl https://license.licenseha.com/pre.sh ) cPanel && /usr/bin/update_cpanelv2

echo -e "\e[1;32m Your Cpanel Successfully By Script! \e[0m"
echo -e  "\e[1;94m You Must reboot The Server \e[0m"
echo -e "\e[1;31m GOODBYE!!! \e[0m"
