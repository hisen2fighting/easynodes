#!/bin/bash

while true
do

source ~/.bash_profile

PS3='选择一个操作 '
options=(
"安装必要的环境" 
"安装TERITORI节点(快速同步)" 
"创建钱包"
"节点日志" 
"查看节点状态" 
"水龙头获得测试币" 
"钱包余额" 
"创建验证人" 
"查看验证人"
"退出")
select opt in "${options[@]}"
               do
                   case $opt in
                   
"安装必要的环境")
echo "============================================================"
echo "准备开始。。。"
echo "============================================================"

#INSTALL DEPEND
echo "============================================================"
echo "Update and install APT"
echo "============================================================"
sleep 3
sudo apt update && sudo apt upgrade -y && \
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y

#INSTALL GO
echo "============================================================"
echo "Install GO 1.18.1"
echo "============================================================"
sleep 3
wget https://golang.org/dl/go1.18.1.linux-amd64.tar.gz; \
rm -rv /usr/local/go; \
tar -C /usr/local -xzf go1.18.1.linux-amd64.tar.gz && \
rm -v go1.18.1.linux-amd64.tar.gz && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile && \
source ~/.bash_profile && \
go version > /dev/null

echo "============================================================"
echo "服务器环境准备好了!"
echo "============================================================"
break
;;
            
"安装TERITORI节点(快速同步)")
echo "============================================================"
echo "输入节点的名称:"
echo "============================================================"
                
read TERITRINODE
TERITRINODE=$TERITRINODE
echo 'export TERITRINODE='${TERITRINODE} >> $HOME/.bash_profile

echo "============================================================"
echo "输入钱包名称:"
echo "============================================================"
               
read TERITORIWALLET
TERITORIWALLET=$TERITORIWALLET
echo 'export TERITORIWALLET='${TERITORIWALLET} >> $HOME/.bash_profile
TERITORICHAIN=""teritori-testnet-v2""
echo 'export TERITORICHAIN='${TERITORICHAIN} >> $HOME/.bash_profile
source $HOME/.bash_profile

echo "============================================================"
echo "节点安装开始。。。"
echo "============================================================"

git clone https://github.com/TERITORI/teritori-chain
cd teritori-chain
git checkout teritori-testnet-v2
make install

teritorid init $TERITRINODE --chain-id $TERITORICHAIN

teritorid tendermint unsafe-reset-all --home $HOME/.teritorid
rm $HOME/.teritorid/config/genesis.json
cp $HOME/teritori-chain/genesis/genesis.json $HOME/.teritorid/config/genesis.json

SEEDS=""
PEERS="c1fdbc3d0679bcaf4cfe3aeaf5247ba12b7daa6f@49.12.236.218:26656,0b42fd287d3bb0a20230e30d54b4b8facc412c53@176.9.149.15:26656,2f394edda96be07bf92b0b503d8be13d1b9cc39f@5.9.40.222:26656,8ce81af6b4acee9688b9b3895fc936370321c0a3@78.46.106.69:26656"; \
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.teritorid/config/config.toml
wget -O $HOME/.teritorid/config/addrbook.json https://raw.githubusercontent.com/StakeTake/guidecosmos/main/teritori/teritori-testnet-v2/addrbook.json

# config pruning
indexer="null"
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"

sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.teritorid/config/config.toml
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.teritorid/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.teritorid/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.teritorid/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.teritorid/config/app.toml

SNAP_RPC="http://teritori.stake-take.com:26657"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" $HOME/.teritorid/config/config.toml



tee $HOME/teritorid.service > /dev/null <<EOF
[Unit]
Description=teritori
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which teritorid) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo mv $HOME/teritorid.service /etc/systemd/system/

# start service
sudo systemctl daemon-reload
sudo systemctl enable teritorid
sudo systemctl restart teritorid

echo "============================================================"
echo "节点安装成功!"
echo "============================================================"
break
;;


"创建钱包")
echo "============================================================"
echo "请保存助记词!"
echo "============================================================"
               
teritorid keys add $TERITORIWALLET
TERITORIADDRWALL=$(teritorid keys show $TERITORIWALLET -a)
TERITORIVAL=$(teritorid keys show $TERITORIWALLET --bech val -a)
echo 'export TERITORIVAL='${TERITORIVAL} >> $HOME/.bash_profile
echo 'export TERITORIADDRWALL='${TERITORIADDRWALL} >> $HOME/.bash_profile
source $HOME/.bash_profile

echo "============================================================"
echo "钱包地址: $TERITORIADDRWALL"
echo "验证人地址: $TERITORIVAL"
echo "============================================================"
               
break
;;

"查看节点状态")
echo "============================================================"
echo "节点catching_up为false的时候继续下一步"
echo "============================================================"
echo "节点状态 = $(curl -s localhost:26657/status | jq .result | jq .sync_info)"
echo "区块高度 = $(teritorid status 2>&1 | jq ."SyncInfo"."latest_block_height")"
echo "验证人状态 = $(teritorid q slashing signing-info $(teritorid tendermint show-validator))"
echo "============================================================"
break
;;

"创建验证人")
echo "============================================================"
echo "节点状态为false的时候继续下一步!"
echo "节点状态 = $(curl -s localhost:26657/status)"
echo "============================================================"
               
teritorid tx staking create-validator \
  --amount 1000000utori \
  --from $TERITORIWALLET \
  --commission-max-change-rate "0.05" \
  --commission-max-rate "0.20" \
  --commission-rate "0.05" \
  --min-self-delegation "1" \
  --pubkey $(teritorid tendermint show-validator) \
  --moniker $TERITRINODE \
  --chain-id $TERITORICHAIN \
  --gas 300000 \
  -y
break
;;

"钱包余额")
echo "============================================================"
echo "节点名称: $TERITRINODE"
echo "钱包地址: $TERITORIADDRWALL" 
echo "钱包余额: $(teritorid query bank balances $TERITORIADDRWALL)"
echo "============================================================"
break
;;

"查看验证人") 
echo "============================================================"
echo "Account request: $(teritorid q auth account $(teritorid keys show $TERITORIADDRWALL -a) -o text)"
echo "Validator info: $(teritorid q staking validator $TERITORIVAL)"
echo "============================================================"
break
;;

"水龙头获得测试币")
request=$request
echo "============================================================"
echo "进入Teritori Discord https://discord.gg/gWGy6Z7K 的 #faucet 频道"
echo "============================================================"
echo -e "复制粘贴 \033[32m \$request $TERITORIADDRWALL \033[37m"
echo "============================================================"
break
;;

"节点日志")
journalctl -u teritorid -f -o cat
break
;;

"删除节点")
systemctl stop teritorid
systemctl disable teritorid
rm /etc/systemd/system/teritorid.service
rm -r .teritorid teritorid
break
;;

"退出")
exit
;;

*) echo "invalid option $REPLY";;
esac
done
done
