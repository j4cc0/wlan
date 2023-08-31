#!/bin/bash
# WLAN: Automagically configure the correct PSK with known SSIDs on Debianistic Linuxes
# Author: github.com/j4cc0
# License: BSD 3-clause

# -- Globals, constants

declare -A WLANS

##### -- MODIFY THESE TO MATCH YOUR SSIDS & PSKS -- #####

WLANS["kilometer"]='dead tyred'
WLANS["skywalker"]='blue label'
WLANS["dreadlock"]='whipped cream'
WLANS["fictional"]='does not exist'
WLANS["braindead"]='...---...'

##### Check "ip a" if this matches your WIFI interface-name:

NIC=wlan0

##### -- NO EDITING BEYOND THIS LINE -- #####

FN="/etc/network/interfaces.d/$NIC"
STOP=0

# -- Functions

write_wlan() {
	wname="$1"
	wkey="$2"
	if [ "$#" -ne 2 ]; then
		echo "[-] Missing parameter. Aborted" >&2
		exit 1
	fi
	if [ -f "$FN" ]; then
		grep "wpa-essid $wname" "$FN" &>/dev/null
		if [ "$?" -eq 0 ]; then
			grep "wpa-psk $wkey" "$FN" &>/dev/null
			if [ "$?" -eq 0 ]; then
				echo "[-] $wname and psk are already configured" >&2
				return
			fi
		fi
		rm -f "$FN" &>/dev/null
	fi
	echo "[+] Writing $wname and $wkey to $FN"
	cat <<- ___EOF___ > "$FN"
		auto $NIC
		iface $NIC inet dhcp
		wpa-essid $wname
		wpa-psk $wkey
	___EOF___
	if [ "$?" -ne 0 ]; then
		echo "[!] No clean exit when writing $FN. Please check!" >&2
		return 1
	fi
	return
}

check_connection() {
	wname="$1"
	if [ "$#" -ne 1 ]; then
		echo "[-] Missing parameter! Skipping" >&2
		return 1
	fi
	/usr/sbin/iwgetid | grep "$NIC .*ESSID:\"$wname\"" &>/dev/null
	if [ "$?" -eq 0 ]; then
		echo "[-] Already connected to $wname via $NIC" >&2
		return
	else
		echo "[+] Not connected to $wname. Restarting network."
		systemctl restart networking
	fi
	return
}

# -- Main

/usr/sbin/iwlist $NIC scan | grep ESSID | sed 's/^.*ESSID://' | grep -v '""' | sort -u | while read ssid
do
	#echo "[i] Processing $ssid"
	for wlan in "${!WLANS[@]}"
	do
		name="\"$wlan\""
		if [ "$name" = "$ssid" ]; then
			psk="${WLANS[$wlan]}"
			echo "[+] Detected! $ssid"
			STOP=1
			break
		fi
	done
	if [ $STOP -ne 0 ]; then
		echo "[+] Using $wlan and psk"
		write_wlan "$wlan" "$psk"
		check_connection "$wlan"
		break
	fi
done

echo "[i] Done."

exit


