#!/bin/sh
sudo apt update
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 63667EE74BBA1F0A08A698725BA31D57EF5975CA
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install openjdk-17-jre-headless -y
sudo apt install ca-certificates
sudo apt update
sudo apt install jenkins -y
sudo apt-get update -y
sudo apt-get update && sudo apt-get install -y gpg wget
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release; echo $VERSION_CODENAME) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
sudo apt-get update && sudo apt-get install -y terraform
terraform -version
echo 'clearing screen...' && sleep 5
clear
echo 'jenkins is installed'
echo 'this is the default password :' $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
