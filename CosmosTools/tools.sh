#!/bin/bash

while true
do

# Logo
source ~/.bash_profile

echo "============================================================"
curl -s https://raw.githubusercontent.com/ericet/easynodes/master/logo.sh | bash
echo "============================================================"


PS3='选择一个操作 '
options=(
"设置链的参数"
"自动复利" 
"节点状态提醒"
"退出")
select opt in "${options[@]}"
               do
                   case $opt in
"设置链的参数")
echo "============================================================"
echo "项目服务名 比如: seid, teritorid"
echo "============================================================"
read PROJECT
echo export PROJECT=${PROJECT} >> $HOME/.bash_profile
echo "============================================================"
echo "设置链ID 比如: atlantic-1, teritori-testnet-v2"
echo "============================================================"
read CHAIN_ID
echo export CHAIN_ID=${CHAIN_ID} >> $HOME/.bash_profile
echo "============================================================"
echo "代币的单位 比如: usei, utori"
echo "============================================================"
read DENOM
echo export DENOM=${DENOM} >> $HOME/.bash_profile
echo "============================================================"
echo "设置操作费"
echo "============================================================"
read FEES
echo export FEES=${FEES} >> $HOME/.bash_profile
echo "============================================================"
echo "钱包名称"
echo "============================================================"
read WALLETNAME
echo export WALLETNAME=${WALLETNAME} >> $HOME/.bash_profile
echo "============================================================"
echo "钱包密码"
echo "============================================================"
read PWDDD
echo export PWDDD=${PWDDD} >> $HOME/.bash_profile
echo "============================================================"
echo "输入钱包密码"
echo "============================================================"
VAL_ADDR=$($PROJECT keys show $WALLETNAME --bech val -a)
echo export VAL_ADDR=${VAL_ADDR} >> $HOME/.bash_profile
echo "============================================================"
echo "输入钱包密码设置质押验证人的地址"
echo "============================================================"
DEL_ADDR=$($PROJECT keys show $WALLETNAME --bech acc -a)
echo export DEL_ADDR=${DEL_ADDR} >> $HOME/.bash_profile

break
;;

                   
"自动复利")
S3='Select an action: '
options=(
"设置自动复利" 
"开启自动复利"
"查看自动复利日志"
"退出")
select opt in "${options[@]}"
               do
                   case $opt in
"设置自动复利")
echo "============================================================"
echo "设置自动复利间隔时间(秒) 比如： 1800 (代表每30分钟自动复利)"
echo "============================================================"
read DELAY
echo export DELAY=${DELAY} >> $HOME/.bash_profile

source $HOME/.bash_profile


mkdir $HOME/autodelegate
wget -O $HOME/autodelegate/start.sh https://raw.githubusercontent.com/ericet/easynodes/master/CosmosTools/autodelegator.sh
chmod +x $HOME/autodelegate/start.sh
break
;;
            
"开启自动复利")
echo "============================================================"
echo "自动复利开启。。。"
echo "============================================================"
cd $HOME/autodelegate && ./start.sh > autodelegate.log 2>&1 &
echo "日志保存在 ~/autodelegate/autodelegate.log"

break
;;

"查看自动复利日志")
tail -f $HOME/autodelegate/autodelegate.log

break
;;

"退出")
exit
;;

*) echo "invalid option $REPLY";;
esac
done

break
;;

"节点状态提醒")
PS3='选择一个操作: '
options=(
"设置电报机器人" 
"运行机器人"
"退出")
select opt in "${options[@]}"
               do
                   case $opt in
                   
"设置电报机器人")
echo "============================================================"
echo "输入电报API Token"
echo "============================================================"
read TG_API
echo export TG_API=${TG_API} >> $HOME/.bash_profile
echo "============================================================"
echo "输入电报Chat ID"
echo "============================================================"
read TG_ID
echo export TG_ID=${TG_ID} >> $HOME/.bash_profile
source $HOME/.bash_profile

mkdir $HOME/alerts
wget -O $HOME/alerts/alerts.sh https://raw.githubusercontent.com/ericet/easynodes/master/CosmosTools/alerts.sh
chmod +x $HOME/alerts/alerts.sh
break
;;
            
"运行机器人")
echo "============================================================"
echo "机器人运行。。。"
echo "============================================================"
echo "*/1 * * * *  /bin/bash $HOME/alerts/alerts.sh"
echo "复制上面命令后按回车，粘贴设置定时运行程序"
read
crontab -e

break
;;

"Exit")
exit
;;

*) echo "invalid option $REPLY";;
esac
done

break
;;

 
"退出")
exit
;;

*) echo "invalid option $REPLY";;
esac
done
done
