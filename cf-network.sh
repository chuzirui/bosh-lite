#!/usr/bin/env bash

[ ! -d "/root/workspace/bosh-deployment"  ] && git clone https://github.com/cloudfoundry/bosh-deployment ~/workspace/bosh-deployment
[ ! -d "/root/workspace/diego-release"  ] && git clone https://github.com/cloudfoundry/diego-release ~/workspace/diego-release
[ ! -d "/root/workspace/cf-deployment"  ] && git clone https://github.com/cloudfoundry/cf-deployment ~/workspace/cf-deployment
[ ! -d "/root/workspace/cf-networking-release"  ] && git clone https://github.com/cloudfoundry-incubator/cf-networking-release ~/workspace/cf-networking-release
wget https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.23-linux-amd64
chmod +x bosh-cli-2.0.23-linux-amd64
mv bosh-cli-2.0.23-linux-amd64 bosh
cp bosh /usr/local/bin
export BOSH_CA_CERT=/root/workspace/bosh-lite/ca/certs/ca.crt
export BOSH_DEPLOYMENT=cf
export BOSH_ENVIRONMENT=vbox
bosh -e 192.168.50.4  alias-env vbox
bosh -e 192.168.50.4  login
bosh -e vbox upload-stemcell  https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent
bosh -e vbox update-cloud-config /root/workspace/cf-deployment/bosh-lite/cloud-config.yml -n
bosh -e vbox upload-release https://bosh.io/d/github.com/cloudfoundry-incubator/cf-networking-release
bosh -e vbox -d cf deploy ~/workspace/cf-deployment/cf-deployment.yml --vars-store deployment-vars.yml -v system_domain=bosh-lite.com -o ~/workspace/cf-deployment/operations/experimental/use-cf-networking.yml -o ~/workspace/cf-deployment/operations/bosh-lite-no-pg.yml -n

