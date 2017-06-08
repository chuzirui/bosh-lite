# bosh-lite

this document helps to install a bosh-lite into one VM

assume you are using Ubuntu 16.10 with correct apt sources

it will take very long time if you are behind GFW

try this in your .bashrc if you are using proxy

    export http_proxy=http://<your-proxy-ip>:<proxy-port>/
    export https_proxy=$http_proxy
    export ftp_proxy=$http_proxy
    export rsync_proxy=$http_proxy
    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"


## Enable on BOSH-Lite
If your CF deployment runs on BOSH-Lite, follow these steps to enable Container-to-Container Networking.

Ensure your BOSH-Lite version is 9000.131.0 or later. If you need to upgrade, follow the instructions for Upgrading the BOSH-Lite VM.
Navigate to your bosh-lite directory, for example,

    $ cd ~/workspace/bosh-lite 
To enable bridge-netfilter on the VM running BOSH-Lite, run the following command:

    $ vagrant ssh -c 'sudo modprobe br_netfilter'

Container-to-Container Networking on BOSH-Lite requires this Linux kernel feature to enforce network policy.
Upload the latest BOSH-Lite stemcell:
    
    bosh upload stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent
To clone the required CF release repos to your workspace, enter the following commands:

    git clone https://github.com/cloudfoundry/diego-release
    git clone https://github.com/cloudfoundry/cf-release
    git clone https://github.com/cloudfoundry-incubator/cf-networking-release
    
To enable Container-to-Container Networking on BOSH-Lite, navigate to the cf-networking-release directory and run the deploy script:

    cd ~/workspace/cf-networking-release
    ./scripts/deploy-to-bosh-lite
    
(Optional) Try the Cats and Dogs example in the Container-to-Container Networking Release repository. 
In this tutorial, you deploy two apps and create a Container-to-Container Networking policy that allows them to communicate directly with each other.


## Manage Logging for Container-to-Container Networking

This section describes how to configure logging for Container-to-Container Networking events by making requests to the running virtual machines (VMs). You can also enable logging for iptables policy rules by editing the manifest in Enable on an IaaS.

Change Log Level for Debugging
By default, the Policy Server logs events at the INFO level. You can capture more information about events by increasing the log level to DEBUG.

To change the log level, follow the steps below:

SSH to either the Policy Server or the VXLAN Policy Agent.

Policy Server: SSH directly to the Policy Server VM.

VXLAN Policy Agent: SSH to the Diego cell that runs the VXLAN Policy Agent.

To change the log level, run the following command:

    curl -X POST -d 'LOG-LEVEL' localhost:PORT-NUMBER/log-level
The LOG-LEVEL is DEBUG or INFO. The PORT-NUMBER is 22222 unless you specified a different number when you edited the stub file in Enable on an IaaS above. 

The following command increases the log level to DEBUG:

    curl -X POST -d 'DEBUG' localhost:22222/log-level
The following command decreases the log level to INFO:

    curl -X POST -d 'INFO' localhost:22222/log-level
Find the logs in the following locations:

Policy Server: /var/vcap/sys/log/policy-server/policy-server.stdout.log

VXLAN Policy Agent: /var/vcap/sys/log/vxlan-policy-agent/vxlan-policy-agent.stdout.log

Enable Logging for Container-to-Container Networking Policies

By default, CF does not log iptables policy rules for Container-to-Container network traffic. 
You can enable logging for iptables policy rules in the manifest in Enable on an IaaS above, or follow the steps below:

SSH to the Diego cell that runs the VXLAN Policy Agent.

To change the log level, run the following command:

    curl -X PUT -d '{"enabled": BOOLEAN}' localhost:PORT-NUMBER/iptables-c2c-logging
The BOOLEAN is true or false. The PORT-NUMBER is 22222 unless you specified a different number when you edited the stub file in Enable on an IaaS above. 

The following command enables logging for iptables policy rules:

    curl -X PUT -d '{"enabled": true}' localhost:22222/iptables-c2c-logging
The following command disables logging for iptables policy rules:
    
    curl -X PUT -d '{"enabled": false}' localhost:22222/iptables-c2c-logging
Find the logs in /var/log/kern.log.

Use Metrics to Consume Logs
You can stream Container-to-Container Networking component metrics with the Loggregator Firehose.

Container-to-Container Networking logs include the following prefixes:

netmon
vxlan_policy_agent
policy_server
Create Policies for Container-to-Container Networking
This section describes how to create and modify Container-to-Container Networking policies using a plugin for the Cloud Foundry Command Line Interface (cf CLI).

To use the plugin, you must have either the network.write or network.admin UAA scope.

UAA Scope	Suitable for…	Allows users to create policies…
network.admin	operators	for any apps in the CF deployment
network.write	space developers	for apps in spaces that they can access
If you are a CF admin, you already have the network.admin scope. An admin can also grant the network.admin scope to a space developer.

For more information, see Creating and Managing Users with the UAA CLI (UAAC) and Orgs, Spaces, Roles, and Permissions.

## Install the Plugin
Follow these steps to download and install the Network Policy plugin for the cf CLI:

Download the network-policy-plugin for your operating system from the Container-to-Container Networking Release repository.
To change the permissions of the plugin file and complete the installation, enter the following commands:

    chmod +x ~/Downloads/network-policy-plugin
    cf install-plugin ~/Downloads/network-policy-plugin
    
## Create a Policy
To create a policy that allows direct network traffic from one app to another, enter the following command:


    cf allow-access SOURCE-APP DESTINATION-APP --protocol PROTOCOL --port PORT
Replace the placeholders in the above command as follows:

SOURCE-APP is the name of the app that will send traffic.

DESTINATION-APP is the name of the app that will receive traffic.

PROTOCOL is one of the following: tcp or udp.

PORT is the port at which to connect to the destination app. The allowed range is from 1 to 65535.

The following example command allows access from the frontend app to the backend app over TCP at port 8080:


    cf allow-access frontend backend --protocol tcp --port 8080
Allowing traffic from frontend to backend as admin...
OK 
List Policies
You can list all the policies in your deployment or just the policies for which a single app is either the source or the destination:

To list the all the policies in your deployment, enter the following command:

    cf list-access
To list the policies for an app, enter the following command:
    
    cf list-access --app MY-APP
The following example command lists policies for the app frontend:

    cf list-access --app frontend
Listing policies as admin...
OK

Source    Destination    Protocol    Port
frontend  backend        tcp         8080
Delete a Policy
To delete a policy that allows direct network traffic from one app to another, enter the following command:


    cf remove-access SOURCE-APP DESTINATION-APP --protocol PROTOCOL --port PORT
The following command deletes the policy that allowed the frontend app to communicate with the backend app over TCP on port 8080:
    
    cf remove-access frontend backend --protocol tcp --port 8080
Denying traffic from frontend to backend as admin...
OK 

