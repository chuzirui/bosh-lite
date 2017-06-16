#!/usr/bin/env bash
apt -y update
apt -y install vim
apt -y install git virtualbox vagrant ruby

git clone https://github.com/cloudfoundry/bosh-deployment ~/workspace/bosh-deployment
mkdir -p ~/deployments/vbox
cp cloud-config.yml ~/deployments/vbox
cd ~/deployments/vbox
git clone https://github.com/cloudfoundry/diego-release ~/workspace/diego-release
git clone https://github.com/cloudfoundry/cf-deployment ~/workspace/cf-deployment
git clone https://github.com/cloudfoundry-incubator/cf-networking-release ~/workspace/cf-networking-release
wget https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.23-linux-amd64
chmod +x bosh-cli-2.0.23-linux-amd64
mv bosh-cli-2.0.23-linux-amd64 bosh
cp bosh /usr/local/bin
bosh create-env ~/workspace/bosh-deployment/bosh.yml   --state ./state.json -o ~/workspace/bosh-deployment/virtualbox/cpi.yml   -o ~/workspace/bosh-deployment/virtualbox/outbound-network.yml   -o ~/workspace/bosh-deployment/bosh-lite.yml   -o ~/workspace/bosh-deployment/bosh-lite-runc.yml   -o ~/workspace/bosh-deployment/jumpbox-user.yml   --vars-store ./creds.yml   -v director_name="Bosh Lite Director"   -v internal_ip=192.168.50.6   -v internal_gw=192.168.50.1   -v internal_cidr=192.168.50.0/24   -v outbound_network_name=NatNetwork
route add -net 10.244.0.0/16 gw 192.168.50.6
bosh -e 192.168.50.6 --ca-cert <(bosh int ./creds.yml --path /director_ssl/ca) alias-env vbox
bosh -e vbox upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh int ~/deployments/vbox/creds.yml --path /admin_password`
export BOSH_DEPLOYMENT=cf
export BOSH_ENVIRONMENT=vbox
export BOSH_CA_CERT=$(bosh int ~/deployments/vbox/creds.yml --path /director_ssl/ca)
bosh -e vbox update-cloud-config cloud-config.yml -n
wget -O cf-networking-release-1.0.0.tgz https://bosh.io/d/github.com/cloudfoundry-incubator/cf-networking-release
bosh upload-release cf-networking-release-1.0.0.tgz
bosh deploy -n ~/workspace/cf-deployment/cf-deployment.yml  -o ~/workspace/cf-networking-release/manifest-generation/opsfiles/cf-networking.yml  -o ~/workspace/cf-deployment/operations/bosh-lite.yml  -o ~/workspace/cf-networking-release/manifest-generation/opsfiles/postgres.yml  --vars-store ~/workspace/cf-networking-deployments/environments/local/deployment-vars.yml  -v system_domain=bosh-lite.com

