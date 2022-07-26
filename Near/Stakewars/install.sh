#!/bin/bash
while true
do

# Logo
source $HOME/.profile

echo "============================================================"
curl -s https://raw.githubusercontent.com/ericet/easynodes/master/logo.sh | bash
echo "============================================================"

PS3='选择一个操作 '
options=(
"查看服务器是否符合要求"
"安装必要的环境"
"安装节点"
"设置节点"
"查看PING日志"
"查看节点日志"
"退出")
select opt in "${options[@]}"
               do
                   case $opt in
"查看服务器是否符合要求")
if lscpu | grep -P '(?=.*avx )(?=.*sse4.2 )(?=.*cx16 )(?=.*popcnt )' > /dev/null; then
  echo "服务器符合要求，你可以继续安装！"
else
  echo "服务器不符合要求，请更换服务器！"
  kill -SIGINT $$
fi
break
;;

"安装必要的环境")
sudo apt update && sudo apt upgrade -y && sudo apt install curl -y && sudo apt install curl jq
sudo apt install -y git binutils-dev libcurl4-openssl-dev zlib1g-dev libdw-dev libiberty-dev cmake gcc g++ python docker.io protobuf-compiler libssl-dev pkg-config clang llvm cargo || 
sudo apt install -y git binutils-dev libcurl4-openssl-dev zlib1g-dev libdw-dev libiberty-dev cmake gcc g++ docker.io protobuf-compiler libssl-dev pkg-config clang llvm cargo -y
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install build-essential nodejs -y
PATH="$PATH"
sudo apt install python3-pip -y
USER_BASE_BIN=$(python3 -m site --user-base)/bin
echo export PATH="$USER_BASE_BIN:$PATH" >> $HOME/.profile
sudo apt install clang build-essential make
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
sudo npm install -g near-cli
echo 'export NEAR_ENV=shardnet' >> $HOME/.profile
source $HOME/.profile
break
;;

"安装节点")
git clone https://github.com/near/nearcore
cd nearcore
git fetch
git checkout 0f81dca95a55f975b6e54fe6f311a71792e21698
cargo build -p neard --release --features shardnet
./target/release/neard --home ~/.near init --chain-id shardnet --download-genesis
rm ~/.near/config.json
wget -O ~/.near/config.json https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/shardnet/config.json
sudo apt-get install awscli -y
rm ~/.near/genesis.json
cd ~/.near
wget https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/shardnet/genesis.json
break
;;


"设置节点")
export NEAR_ENV=shardnet
source $HOME/.profile
echo "============================================================"
echo "复制下面链接，然后在浏览器打开。创建或者导入已创建的钱包，然后授权。"
echo "============================================================"
near login
while true; do
echo "============================================================"
echo "输入钱包名（比如: xxxx.shardnet.near)"
echo "============================================================"
read name
  echo export NAME=${name} >> $HOME/.profile
  if [[ ${#name} -gt 14 ]]; then
    near generate-key $name 
    cp ~/.near-credentials/shardnet/$name.json ~/.near/validator_key.json
    break;
  else
    echo "输入错误的钱包名！";
  fi
done
while true; do
	echo "============================================================"
	echo "输入Pool ID (比如: xxx.factory.shardnet.near)"
	echo "============================================================"
	read factoryName
  if [[ ${#factoryName} -gt 22 ]]; then
    break;
  else
    echo "你输入一个无效的Pool ID！";
  fi
done
cat ~/.near/validator_key.json | grep public_key
while true; do
	echo "============================================================"
  echo "输入上面生成的Public Key(ed25519:后面那串)"
	echo "============================================================"
	read publicKey
  if [[ ${#publicKey} -gt 35 ]]; then
    break;
  else
    echo "无效的public key!";
  fi
done
cat ~/.near/validator_key.json | grep private_key
while true; do
	echo "============================================================"
  echo "输入上面生成的Private Key(ed25519:后面那串)" 
	echo "============================================================"
	read privateKey
  if [[ ${#privateKey} -gt 35 ]]; then
      echo "{\"account_id\": \"${factoryName}\",\"public_key\": \"${publicKey}\",\"secret_key\": \"${privateKey}\"}" > ~/.near/validator_key.json;
    break;
  else
    echo "无效的private key!";
  fi
done
echo "[Unit]
Description=NEARd Daemon Service

[Service]
Type=simple
User=root
#Group=near
WorkingDirectory=/root/.near
ExecStart=/root/nearcore/target/release/neard run
Restart=on-failure
RestartSec=30
KillSignal=SIGINT
TimeoutStopSec=45
KillMode=mixed

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/neard.service
sudo systemctl daemon-reload
sudo systemctl enable neard
sudo systemctl start neard
sudo apt install ccze
while true; do
	echo "============================================================"
  echo "输入池子的名字（比如： test123)"
	echo "============================================================"
	read poolName
  echo export POOLNAME=${poolName} >> $HOME/.profile
  if [[ ${#poolName} -gt 0 ]]; then
    break;
  else
    echo "无效的池子名字";
  fi
done
while true; do
	echo "============================================================"
  echo "输入抽成 (推荐5) " 
	echo "============================================================"
	read poolCommission
  if [[ ${#poolCommission} -gt 0 ]]; then
    break;
  else
    echo "无效的抽成数量！";
  fi
done
while true; do
	echo "============================================================"
  echo "输入质押数量 (最低30 NEAR)" 
	echo "============================================================"
	read nearBalance
  if [[ ${#nearBalance} -gt 0 ]]; then
    break;
  else
    echo "无效的质押数量！";
  fi
done
near call factory.shardnet.near create_staking_pool '{"staking_pool_id": "'${poolName}'", "owner_id": "'${name}'", "stake_public_key": "'${publicKey}'", "reward_fee_fraction": {"numerator": '${poolCommission}', "denominator": 100}, "code_hash":"DD428g9eqLL8fWUxv8QSpVFzyHi1Qd16P8ephYCTmMSZ"}' --accountId="${name}" --amount=$nearBalance --gas=300000000000000
mkdir /home/${name}
mkdir /home/${name}/logs
mkdir /home/${name}/scripts
echo '#!/bin/bash
# Ping call to renew Proposal added to crontab
source ~/.profile
echo "---" >> /home/$NAME/logs/all.log
date >> /home/$NAME/logs/all.log
near call '$POOLNAME'.factory.shardnet.near ping '{}' --accountId '$NAME' --gas=300000000000000 >> /home/$NAME/logs/all.log
near proposals | grep '$POOLNAME' >> /home/$NAME/logs/all.log
near validators current | grep '$POOLNAME' >> /home/$NAME/logs/all.log
near validators next | grep '$POOLNAME' >> /home/$NAME/logs/all.log' > /home/$NAME/scripts/ping.sh
crontab -l > mycron
echo "*/5 * * * * bash /home/${name}/scripts/ping.sh" >> mycron
crontab mycron
rm mycron
break
;;

"查看PING日志")
source $HOME/.profile
tail -f /home/$NAME/logs/all.log
break
;;

"查看节点日志")
journalctl -n 100 -f -u neard | ccze -A
break
;;

"退出")
exit
;;

*) echo "无效选择 $REPLY";;
esac
done
done
