#!/bin/bash

while true
do


# Menu

PS3='Select an action: '
options=("安装必要的环境" "运行全节点" "查看日志" "检查节点" "查看节点状态" "退出")
select opt in "${options[@]}"
               do
                   case $opt in                           

"安装必要的环境")
echo "============================================================"
echo "安装开始。。。"
echo "============================================================"

# set vars
sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install curl wget jq libpq-dev libssl-dev \
build-essential pkg-config openssl ocl-icd-opencl-dev \
libopencl-clang-dev libgomp1 -y
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

install() {
	cd
	if ! docker --version; then
		echo -e "${C_LGn}Docker installation...${RES}"
		sudo apt update && sudo apt upgrade -y
		sudo apt install curl apt-transport-https ca-certificates gnupg lsb-release -y
		. /etc/*-release
		wget -qO- "https://download.docker.com/linux/${DISTRIB_ID,,}/gpg" | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
		echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
		sudo apt update
		sudo apt install docker-ce docker-ce-cli containerd.io -y
		docker_version=`apt-cache madison docker-ce | grep -oPm1 "(?<=docker-ce \| )([^_]+)(?= \| https)"`
		sudo apt install docker-ce="$docker_version" docker-ce-cli="$docker_version" containerd.io -y
	fi
	if ! docker-compose --version; then
		echo -e "${C_LGn}Docker Сompose installation...${RES}"
		sudo apt update && sudo apt upgrade -y
		sudo apt install wget jq -y
		local docker_compose_version=`wget -qO- https://api.github.com/repos/docker/compose/releases/latest | jq -r ".tag_name"`
		sudo wget -O /usr/bin/docker-compose "https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-`uname -s`-`uname -m`"
		sudo chmod +x /usr/bin/docker-compose
		. $HOME/.bash_profile
	fi
	if [ "$dive" = "true" ] && ! dpkg -s dive | grep -q "ok installed"; then
		echo -e "${C_LGn}Dive installation...${RES}"
		wget https://github.com/wagoodman/dive/releases/download/v0.9.2/dive_0.9.2_linux_amd64.deb
		sudo apt install ./dive_0.9.2_linux_amd64.deb
		rm -rf dive_0.9.2_linux_amd64.deb
	fi
}
uninstall() {
	echo -e "${C_LGn}Docker uninstalling...${RES}"
	sudo dpkg -r dive
	sudo systemctl stop docker.service docker.socket
	sudo systemctl disable docker.service docker.socket
	sudo rm -rf `systemctl cat docker.service | grep -oPm1 "(?<=^#)([^%]+)"` `systemctl cat docker.socket | grep -oPm1 "(?<=^#)([^%]+)"` /usr/bin/docker-compose
	sudo apt purge docker-engine docker docker.io docker-ce docker-ce-cli -y
	sudo apt autoremove --purge docker-engine docker docker.io docker-ce -y
	sudo apt autoclean
	sudo rm -rf /var/lib/docker /etc/appasudo rmor.d/docker
	sudo groupdel docker
	sudo rm -rf /etc/docker /usr/bin/docker /usr/libexec/docker /usr/libexec/docker/cli-plugins/docker-buildx /usr/libexec/docker/cli-plugins/docker-scan /usr/libexec/docker/cli-plugins/docker-app /usr/share/keyrings/docker-archive-keyring.gpg
}

# Actions
$function
echo -e "${C_LGn}完成!${RES}"

break
;;

"运行全节点")                 
# Create sui devnet directory
sudo mkdir -p ~/sui-node/devnet && cd ~/sui-node/devnet


# Download docker file and genesis file
sudo wget -O fullnode-template.yaml https://github.com/MystenLabs/sui/raw/main/crates/sui-config/data/fullnode-template.yaml
sudo wget -O genesis.blob https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob
sudo wget -O docker-compose.yaml https://raw.githubusercontent.com/MystenLabs/sui/main/docker/fullnode/docker-compose.yaml

sudo sed -i 's/127.0.0.1:9184/0.0.0.0:9184/' fullnode-template.yaml
sudo sed -i 's/127.0.0.1:9000/0.0.0.0:9000/' fullnode-template.yaml

sudo docker-compose pull
sudo docker-compose up -d

break
;;  

"检查节点")    
echo "============================================================"
echo "获取最近五次交易，如果运行没有报错，代表运行节点成功"
echo "============================================================"             
curl --location --request POST 'http://127.0.0.1:9000/' \
    --header 'Content-Type: application/json' \
    --data-raw '{ "jsonrpc":"2.0", "id":1, "method":"sui_getRecentTransactions", "params":[5] }'
echo ""

break
;; 

"查看节点状态")
echo "============================================================"
echo "使用 https://node.sui.zvalid.com/ 检查节点状态"
echo "============================================================"       

break
;;

"查看日志")    
cd $HOME/sui-node/devnet             
docker-compose logs -f --tail 50

break
;;   


"退出")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done
