# wlan
Wifi auto-configuration shell script for known SSIDs on Debian-alike Linux. This script looks if a known SSID (in the code) is present, and writes the configuration for that to /etc/network/interfaces.d if it's not already there. It also makes the connection, if not already connected. This should allow you to roam between offices/home and automatically have the right wifi configuration up and ready.

To achieve this, you could run this script from roots' crontab (every 2 minutes or so) and be automatically connected to a known SSID when present:

`su -`

`crontab -e`

`*/2 * * * * <path-to>/wlan.sh &>/dev/null`


...Not terribly elegant, there are probably other (better) solutions, but remember: "If it's stupid but it works, then it isn't stupid."
