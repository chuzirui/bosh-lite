#!/usr/bin/env bash
apt -y update
apt -y install vim
apt -y install git virtualbox vagrant
gem install bosh_cli
mkdir ~/workspace
cd ~/workspace
git clone https://github.com/cloudfoundry/bosh-lite
cd ~/workspace/bosh-lite
wget https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.3/spiff_linux_amd64.zip
unzip spiff_linux_amd64.zip -d /usr/bin
vagrant up --provider=virtualbox
export no_proxy=192.168.50.4,xip.io
bin/add-route
pushd ~/workspace/bosh-lite
vagrant ssh -c 'sudo modprobe br_netfilter'
popd
bosh target 192.168.50.4
curl -L -o bosh-lite-stemcell-latest.tgz https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent
bosh upload stemcell bosh-lite-stemcell-latest.tgz
bosh upload release https://bosh.io/d/github.com/cloudfoundry/cf-release
bosh upload release https://bosh.io/d/github.com/cloudfoundry/diego-release
bosh upload release https://bosh.io/d/github.com/cloudfoundry/garden-runc-release
bosh upload release https://bosh.io/d/github.com/cloudfoundry/cflinuxfs2-rootfs-release
bosh upload release https://bosh.io/d/github.com/cloudfoundry-incubator/cf-networking-release
pushd ~/workspace
git clone https://github.com/cloudfoundry/diego-release
git clone https://github.com/cloudfoundry/cf-release
git clone https://github.com/cloudfoundry-incubator/cf-networking-release
popd
pushd ~/workspace/cf-networking-release
./scripts/generate-bosh-lite-manifests
bosh -d bosh-lite/deployments/cf_networking.yml deploy
bosh -d bosh-lite/deployments/diego_cf_networking.yml deploy
popd

