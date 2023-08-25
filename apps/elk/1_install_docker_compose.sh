#!/usr/bin/env bash
# by hank 2022-10

# 1. update os
# 2. pre install packages include as follow:
# 3. docker docker-compose

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

. "${BASE_DIR}/.env"


function init_os() {
    ostype=`cat /etc/os-release| sed -n "1p"|awk -F "\"" '{print $2}'`
    if [[ "${ostype}" = "Ubuntu" ]];then
        sudo apt update -y
	sudo apt upgrade -y
    elif [[ "${ostype}" = "CentOS Linux" ]];then
        sudo yum update -y
    else
        echo "Unknow OS Type"
    fi
}

function docker_install() {
    ostype=`cat /etc/os-release| sed -n "1p"|awk -F "\"" '{print $2}'`

    if [ ! -f /usr/bin/docker ];then
        flag=true
        echo "Docker not installed."
    else
        echo "docker version: `docker -v`"
    fi

    if [[ "${ostype}" = "Ubuntu" && "${flag}" == "true" ]];then
        echo "OS Type: ${ostype}"
        echo "Install using the repository:"
        echo "Update the apt package index and install packages to allow apt to use a repository over HTTPS"
        sudo apt-get update -y
        sudo apt-get install \
            ca-certificates \
            curl \
            gnupg \
            lsb-release -y
        echo "Add Docker's official GPG key:"
        sudo mkdir -m 0755 -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        echo "Use the following command to set up the repository:"
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        echo "Starting Install Docker Engine"
        sudo apt-get update -y
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    elif [[ "${ostype}" = "CentOS Linux" && "${flag}" == "true" ]];then
        echo "Set up the repository"
        sudo yum install -y yum-utils
        sudo yum-config-manager \
            --add-repo \
            https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi

    if [ -f /etc/docker/daemon.json ];then
        rm -f /etc/docker/daemon.json
        cp ${BASE_DIR}/../config/docker/daemon.json /etc/docker/daemon.json
    else
        cp ${BASE_DIR}/../config/docker/daemon.json /etc/docker/daemon.json
    fi
}


function compose_install() {

    if [ ! -f  /usr/local/bin/docker-compose ];then
        curl -SL https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
        sudo docker-compose -v
    else
        echo "docker-compose version: `docker-compose -v`"
    fi
}

function main() {
    init_os
    docker_install
    compose_install
}

main
