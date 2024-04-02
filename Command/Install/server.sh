#!/usr/bin/env bash
set -e

function system()
{
    echo "#> system start"

    sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf

    apt-get -y update && apt-get -y upgrade
    apt-get -y install \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common
    cat > /usr/local/sbin/update_and_clean <<'EOF'
#!/usr/bin/env bash
apt-get -y update && \
    apt-get clean all && \
    apt-get remove $(apt-get repoquery --installonly --latest-limit=-1 -q)
EOF
    chmod +x /usr/local/sbin/update_and_clean

    echo "#> system end"
}

function wsl()
{
    echo "#> wsl start"

    cat >> /etc/wsl.conf <<-'EOF'
[automount]
options="metadata"
[boot]
systemd=true
[network]
generateResolvConf=false
EOF
    cat > /usr/local/bin/local_resolv <<-'EOF'
#!/bin/sh
sed -i '/nameserver/d' /etc/resolv.conf
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command '(Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses | ForEach-Object { "nameserver $_" }' | tr -d '\r'| tee -a /etc/resolv.conf > /dev/null
EOF
    chmod +x /usr/local/bin/local_resolv && local_resolv

    echo "#> wsl end"
}

function docker()
{
    echo "#> docker start"

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository -y \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"
    sudo apt-get -y update
    sudo apt-get -y install docker-ce
    sudo usermod -aG docker $USER

    echo "#> docker end"
}

function minik8s()
{
    echo "#> minik8s start"

    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    chmod +x ./minikube
    sudo mv ./minikube /usr/local/bin/
    minikube config set driver docker

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/

    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    echo "#> minik8s end"
}

function user_create()
{
    echo "#> user_create start"

    if [[ -z ${USERNAME} ]]; then
        echo -e "ERROR: no 'USERNAME' variable found, probably not added from WSL?"
        exit 1
    fi

    adduser --disabled-password ${USERNAME} --gecos ""
    passwd --delete ${USERNAME}
    usermod -L ${USERNAME}
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    cat >> /etc/wsl.conf <<-EOF
[user]
default=${USERNAME}
EOF

    echo "#> user_create end"
}

## main ##
# Check if the function exists (bash specific)
if declare -f "$1" > /dev/null
then
    # call arguments verbatim
    "$@"
else
    # Show a helpful error
    echo "'$1' is not a known function name" >&2
    exit 1
fi
