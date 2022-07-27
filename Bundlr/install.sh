#!/bin/bash

while true
do

# Logo

echo "============================================================"
curl -s https://raw.githubusercontent.com/ericet/easynodes/master/logo.sh | bash
echo "============================================================"

# Menu

PS3='选择操作: '
options=("安装节点" "获取测试币" "运行Docker" "查看日志" "查看钱包余额" "运行验证人" "查看验证人状态" "退出")
select opt in "${options[@]}"
               do
                   case $opt in                           

"安装节点")
echo "============================================================"
echo "安装开始。。。"
echo "============================================================"

# set vars
sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install curl wget jq libpq-dev libssl-dev \
build-essential pkg-config openssl ocl-icd-opencl-dev \
libopencl-clang-dev libgomp1 -y
apt install docker-compose
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
		. $HOME/.profile
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

# Install rust
curl https://sh.rustup.rs -sSf | sh -s -- -y

# Check cargo verison
source "$HOME/.cargo/env" && \
echo -e "\n$(cargo --version).\n"

# Install nodeJs and npm
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash - && \
sudo apt-get install nodejs -y && \
echo -e "\nnodejs > $(node --version).\nnpm  >>> v$(npm --version).\n"

# Create Bundlr catalog
mkdir $HOME/bundlr; cd $HOME/bundlr

# Clone repository
git clone \
--recurse-submodules https://github.com/Bundlr-Network/validator-rust.git

# Generate "wallet.json"
cd $HOME/bundlr/validator-rust && \
cargo run --bin wallet-tool create > wallet.json

break
;;


"获取测试币")

cd $HOME/bundlr/validator-rust && \
cargo run --bin wallet-tool show-address \
--wallet wallet.json | jq ".address" | tr -d '"'

sleep 2

echo "========================================================================================================================"
echo "把上面的地址复制到 https://bundlr.network/faucet 获取测试币"
echo "========================================================================================================================"

break
;;

"查看日志")                 
cd $HOME/bundlr/validator-rust && \
docker-compose logs -f --tail 10

break
;;   

"运行Docker")
PORT=2109
echo "============================================================"
echo "Enter your wallet address"
echo "============================================================"
read ADDRESS
echo export ADDRESS=${ADDRESS} >> $HOME/.profile
echo export BUNDLR_PORT=${PORT} >> $HOME/.profile
source $HOME/.profile

sudo tee <<EOF >/dev/null $HOME/bundlr/validator-rust/.env
PORT=${BUNDLR_PORT}
VALIDATOR_KEY=./wallet.json
BUNDLER_URL=https://testnet1.bundlr.network
GW_WALLET=./wallet.json
GW_CONTRACT=RkinCLBlY4L5GZFv8gCFcrygTyd5Xm91CzKlR6qxhKA
GW_ARWEAVE=https://arweave.testnet1.bundlr.network
EOF


cd $HOME/bundlr/validator-rust && \
docker-compose up -d

sleep 2

cd $HOME/bundlr/validator-rust && \
npm i -g @bundlr-network/testnet-cli

sleep 2

echo -e 'To check logs: \e[1m\e[32mcd $HOME/bundlr/validator-rust && \
docker-compose logs -f --tail 10'
echo -e 'Close logs Control+C and continiue install'

break
;;

"查看钱包余额")

cd $HOME/bundlr/validator-rust && \
testnet-cli balance $ADDRESS

break
;;

"查看验证人状态")

cd $HOME/bundlr/validator-rust && \
testnet-cli check RkinCLBlY4L5GZFv8gCFcrygTyd5Xm91CzKlR6qxhKA $ADDRESS

break
;;

"运行验证人")

cd $HOME/bundlr/validator-rust && \
testnet-cli join RkinCLBlY4L5GZFv8gCFcrygTyd5Xm91CzKlR6qxhKA \
-w ./wallet.json \
-u "http://$(wget -qO- eth0.me):${BUNDLR_PORT}" \
-s 25000000000000

break
;;

"退出")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done
