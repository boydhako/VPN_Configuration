#!/bin/bash

function GETALLCFGS {
	osascript -e "tell application \"/Applications/Tunnelblick.app\"" -e "get configurations" -e "end tell" | sed -e "s~configuration ~~g" -e "s~,~~g"
}
function GETCFGSTAT {
	cfg="$1"
	osascript -e "tell application \"/Applications/Tunnelblick.app\"" -e "get state of first configuration where name = \"$cfg\"" -e "end tell"
}
function DISCONNECTCFG {
	cfg="$1"
	osascript -e "tell application \"/Applications/Tunnelblick.app\"" -e "disconnect \"$cfg\"" -e "end tell"
}

function VPNSTATUS {
	for cfg in $(GETALLCFGS) ; do
		printf "=== %s ===\n" "$cfg"
		if [ "$(GETCFGSTAT $cfg)" == "WAIT" -o "$(GETCFGSTAT $cfg)" == "AUTH" ]; then
			printf "-- sleeping for 10 seconds --\n"
			sleep 10s
			if [ "$(GETCFGSTAT $cfg)" == "WAIT" -o "$(GETCFGSTAT $cfg)" == "AUTH" ]; then
				DISCONNECTCFG $cfg
			fi
		else
			GETCFGSTAT $cfg
		fi
	done
}
VPNSTATUS
