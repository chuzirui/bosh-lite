#!/usr/bin/env bash
git clone https://github.com/cloudfoundry/diego-release ~/workspace/diego-release
git clone https://github.com/cloudfoundry-incubator/cf-networking-release ~/workspace/cf-networking-release
wget https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.23-linux-amd64
chmod +x bosh-cli-2.0.23-linux-amd64
mv bosh-cli-2.0.23-linux-amd64 bosh2
cp bosh2 /usr/local/bin
mkdir -p ~/deployments/vbox
cd ~/deployments/vbox
bosh2 create-env ~/workspace/bosh-deployment/bosh.yml   --state ./state.json -o ~/workspace/bosh-deployment/virtualbox/cpi.yml   -o ~/workspace/bosh-deployment/virtualbox/outbound-network.yml   -o ~/workspace/bosh-deployment/bosh-lite.yml   -o ~/workspace/bosh-deployment/bosh-lite-runc.yml   -o ~/workspace/bosh-deployment/jumpbox-user.yml   --vars-store ./creds.yml   -v director_name="Bosh Lite Director"   -v internal_ip=192.168.50.6   -v internal_gw=192.168.50.1   -v internal_cidr=192.168.50.0/24   -v outbound_network_name=NatNetwork
bosh2 -e 192.168.50.6 --ca-cert <(bosh2 int ./creds.yml --path /director_ssl/ca) alias-env vbox
bosh2 -e vbox upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh2 int ~/deployments/vbox/creds.yml --path /admin_password`
export BOSH_DEPLOYMENT=cf
export BOSH_ENVIRONMENT=vbox
export BOSH_CA_CERT=$(bosh2 int ~/deployments/vbox/creds.yml --path /director_ssl/ca)
bosh2 -e vbox update-cloud-config ~/workspace/cf-deployment/bosh-lite/cloud-config.yml
wget -O cf-networking-release-1.0.0.tgz https://bosh.io/d/github.com/cloudfoundry-incubator/cf-networking-release
bosh2 upload-release cf-networking-release-1.0.0.tgz
bosh2 deploy ~/workspace/cf-deployment/cf-deployment.yml   -o ~/workspace/cf-networking-release/manifest-generation/opsfiles/cf-networking.yml -o ~/workspace/cf-deployment/operations/bosh-lite.yml   -o ~/workspace/cf-networking-release/manifest-generation/opsfiles/postgres.yml --vars-store ~/deployments/vbox/deployment-vars.yml   -v system_domain=bosh-lite.com
