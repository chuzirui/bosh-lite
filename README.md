# bosh-lite

this document helps to install a bosh-lite into one VM

assume you are using Ubuntu 16.10 with correct apt sources

it will take very long time if you are behind GFW

try this in your .bashrc if you are using proxy

    export http_proxy=http://proxy.vmware.com:3128/
    export https_proxy=$http_proxy
    export ftp_proxy=$http_proxy
    export rsync_proxy=$http_proxy
    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"


