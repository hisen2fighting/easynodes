#!/bin/bash


LOG_FILE="$HOME/alerts/nodealerts.log"

NODE_RPC="http://127.0.0.1:26657"

SIDE_RPC="http://localhost:26657"

touch $LOG_FILE
REAL_BLOCK=$(curl -s "$SIDE_RPC/status" | jq '.result.sync_info.latest_block_height' | xargs )
STATUS=$(curl -s "$NODE_RPC/status")
MONIKER=$(echo $STATUS | jq '.result.node_info.moniker')
NETWORK=$(echo $STATUS | jq '.result.node_info.network')
CATCHING_UP=$(echo $STATUS | jq '.result.sync_info.catching_up')
LATEST_BLOCK=$(echo $STATUS | jq '.result.sync_info.latest_block_height' | xargs )
VOTING_POWER=$(echo $STATUS | jq '.result.validator_info.voting_power' | xargs )
source $LOG_FILE

echo 'LAST_BLOCK="'"$LATEST_BLOCK"'"' > $LOG_FILE
echo 'LAST_POWER="'"$VOTING_POWER"'"' >> $LOG_FILE

source $HOME/.profile
curl -s "$NODE_RPC/status"> /dev/null
if [[ $? -ne 0 ]]; then
    MSG="Warning! Node $MONIKER from $NETWORK is stopped!"
    SEND=$(curl -s -X POST -H "Content-Type:multipart/form-data" "https://api.telegram.org/bot$TG_API/sendMessage?chat_id=$TG_ID&text=$MSG"); exit 1
fi

if [[ $LAST_POWER -ne $VOTING_POWER ]]; then
    DIFF=$(($VOTING_POWER - $LAST_POWER))
    if [[ $DIFF -gt 0 ]]; then
        DIFF="%2B$DIFF"
    fi
    MSG="Attention! Node $MONIKER from $NETWORK. Voting power changed on $DIFF%0A($LAST_POWER -> $VOTING_POWER)"
fi

if [[ $LAST_BLOCK -ge $LATEST_BLOCK ]]; then

    MSG="Attention! Node $MONIKER from $NETWORK is probably stuck at block >> $LATEST_BLOCK"
fi

if [[ $VOTING_POWER -lt 1 ]]; then
    MSG="Attention! Node $MONIKER from $NETWORK is inactive\jailed. Voting power $VOTING_POWER"
fi

if [[ $CATCHING_UP = "true" ]]; then
    MSG="Attention! Node $MONIKER from $NETWORK is unsync, catching up. $LATEST_BLOCK -> $REAL_BLOCK"
fi

if [[ $REAL_BLOCK -eq 0 ]]; then
    MSG="Attention! Node $MONIKER from $NETWORK can't connect to >> $SIDE_RPC"
fi

if [[ $MSG != "" ]]; then
    MSG="$NODENAME $MSG"
    SEND=$(curl -s -X POST -H "Content-Type:multipart/form-data" "https://api.telegram.org/bot$TG_API/sendMessage?chat_id=$TG_ID&text=$MSG")
fi
