#!/bin/sh

# Assumptions:
# You have two network locations set up in your OSX Network config:
# one for home, one for your corporate network
# Executing proxy.sh will detect whether your vpn or local connection
# to your corporate network network is up, and override your CNTLM config with
# either conf file from this script's folder.
# Additionally, it will set or unset your npm and shell proxy config
#
# Usage: ./proxy.sh [-p] [-h]
# 

PATH=/usr/local/share/nvm/versions/node/v8.5.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
NPM=npm
BREW=brew

# END OF CONFIG.
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $CURRENT_DIR"/settings.sh"

update_hash() {
	CNTLM_FILE_NAME=$CURRENT_DIR"/cntlm."$NET_LOC_IN_RANGE".conf"

	echo "Okay, let's update your NTLMv2 hash. What's your new NTLM (e.g. Active Directory) Password?"
    read -s adpw
    NTLMV2_LINE=`echo $adpw | cntlm -c $CNTLM_FILE_NAME -H | grep "^PassNTLMv2" | cut -f1 -d"#"`

    sed -i '' "s/^PassNTLMv2.*/$NTLMV2_LINE/" $CNTLM_FILE_NAME

    echo "... Your hash has been updated in $CNTLM_FILE_NAME."
}

set_cntlm() {
	FILE_NAME="/usr/local/etc/cntlm.conf"
	FILE_NAME_INP=$CURRENT_DIR"/cntlm."$1".conf"

	if [ ! -f $FILE_NAME_EX ]; then
		echo "Target File does not exist: "$FILE_NAME_EX
		exit
	fi

	cat $FILE_NAME_INP > $FILE_NAME

	$BREW services restart cntlm
}

set_npm_proxy() {
	HTTP_PROXY=$CNTLM_LISTEN
	if [ $1 "!=" $NET_LOC_IN_RANGE ]; then
		echo "removing npm proxy settings"
		$NPM config delete proxy
		$NPM config delete https-proxy
	else
		echo "setting npm proxy settings"
		$NPM config set proxy=$HTTP_PROXY
		$NPM config set https-proxy=$HTTP_PROXY
	fi
}

print_help() {
	echo "Usage: ./proxy.sh [-p] [-h]"
	echo ""
	echo "Option -p: Ask for the new AD password and update the ntlmv2 hash before restarting cntlm"
	echo "Option -h: Show this highly helpful help message."
}

while getopts "ph" opt; do
  case $opt in
    p) update_hash;; # no exit so that cntlm restarts immediately
    h) print_help; exit;;
  esac
done


TARGET_ENV=$NET_LOC_IN_RANGE
ifconfig | grep -q "inet "$IP_RANGE_PREFIX

if [ $? -ne 0 ]; then
	TARGET_ENV=$NET_LOC_OUT_RANGE
fi

echo "Switching proxy setup to "$TARGET_ENV"..."

set_cntlm $TARGET_ENV
scselect $TARGET_ENV
$AUTO_SWITCH_NPM && set_npm_proxy $TARGET_ENV

