#!/bin/bash
alias apt='apy -y'
apt update
apt install vim
apt install git virtualbox vagrant
apt install vagrant
apt install virtualbox
gem install bosh_cli
mkdir ~/workspace
cd ~/workspace
git clone https://github.com/cloudfoundry/bosh-lite
git clone https://github.com/cloudfoundry/cf-release
cd ~/workspace/bosh-lite
wget https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.3/spiff_linux_amd64.zip
unzip spiff_linux_amd64.zip -d /usr/bin
vagrant up --provider=virtualbox
export no_proxy=192.168.50.4,xip.io
bin/add-route
bin/provision_cf


