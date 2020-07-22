#!/bin/bash
map="$(dirname $0)/loc_vpn_cfg.txt"

function ALLVPNCFGS {
	osascript -e "tell application \"/Applications/Tunnelblick.app\"" -e "get configurations" -e "end tell" | sed -e 's~configuration ~~g' -e 's~,~~g'
}
function VPNSTAT {
	cfg="$1"
	osascript -e "tell application \"/Applications/Tunnelblick.app\"" -e "get state of first configuration where name = \"$cfg\"" -e "end tell" | sed -e 's~configuration ~~g' -e 's~,~~g'
}
function CONNECTVPN {
	cfg="$1"
	osascript -e "tell application \"/Applications/Tunnelblick.app\"" -e "connect \"$selectcfg\"" -e "end tell" > /dev/null
}
function DISCONNECTVPN {
	osascript -e "tell application \"/Applications/Tunnelblick.app\"" -e "disconnect \"$selectcfg\"" -e "end tell" > /dev/null
}

let cfgcnt="$(ALLVPNCFGS | sed 's~ ~\n~g' | wc -l)"
let activcfg="0"
for cfg in $(ALLVPNCFGS); do
	#printf "VPN Status of %s: %s\n" "$cfg" "$(VPNSTAT $cfg)"
	if [ "$(VPNSTAT $cfg)" == "CONNECTED" ]; then
		let activcfg="(($activcfg + 1))"
	fi
done

if [ "$activcfg" -lt "1" ]; then
#if [ "$activcfg" -ge "1" ]; then
	loc="$(scselect | awk '$1 == "*" {printf $NF}' | sed -e 's~(~~g' -e 's~)~~g')"
	selectcfg="$(awk -v loc="$loc" '$1 == loc {printf $2}' $map)"
	function CONNECT {
		CONNECTVPN $selectcfg
		sleep 10s
		if [ "$(VPNSTAT $selectcfg)" != "CONNECTED" ]; then
			DISCONNECTVPN $selectcfg
			sleep 10s
			CONNECT
		fi
	}
	CONNECT
fi
