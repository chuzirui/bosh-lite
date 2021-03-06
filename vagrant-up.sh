#!/usr/bin/env bash
mkdir -p ~/deployments/vbox
cd ~/deployments/vbox
wget https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.23-linux-amd64
chmod +x bosh-cli-2.0.23-linux-amd64
mv bosh-cli-2.0.23-linux-amd64 bosh
cp bosh /usr/local/bin
cd ~/workspace/bosh-lite
wget https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.3/spiff_linux_amd64.zip
unzip spiff_linux_amd64.zip -d /usr/bin
export no_proxy=192.168.50.4,xip.io
route add -net 10.244.0.0/16 gw 192.168.50.4
export BOSH_CA_CERT=~/workspace/bosh-lite/ca/certs/ca.crt
bosh -e 192.168.50.4  alias-env vbox
bosh -e vbox login
bosh -e vbox upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent
bosh -e vbox update-cloud-config /root/workspace/cf-deployment/bosh-lite/cloud-config.yml -n
wget -O cf-networking-release-1.0.0.tgz https://bosh.io/d/github.com/cloudfoundry-incubator/cf-networking-release
bosh -e vbox upload-release cf-networking-release-1.0.0.tgz
bosh -e vbox -d cf deploy ~/workspace/cf-deployment/cf-deployment.yml --vars-store deployment-vars.yml -v system_domain=bosh-lite.com -o ~/workspace/cf-deployment/operations/experimental/use-cf-networking.yml -o ~/workspace/cf-deployment/operations/use-postgres.yml -o ~/workspace/cf-deployment/operations/experimental/use-cf-networking-postgres.yml  -n

