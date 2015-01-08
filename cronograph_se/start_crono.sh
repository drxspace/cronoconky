#!/bin/bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#

#rm "$(dirname "$0")"/conkyerr.log && $(which conky) -DD -c "$(dirname "$0")"/cronorc &> "$(dirname "$0")"/conkyerr.log &
# With the background property setted to yes I don't need the &

[[ $(pgrep -c -f "^conky.*cronorc$") -eq 0 ]] && {
#	[[ "$DESKTOP_SESSION" != "cinnamon" ]] && 
	sleep 15;
	#     ^^ Error of failed request:  BadWindow (invalid Window parameter)
	# There's also the X-GNOME-Autostart-Delay=25 property in .desktop file
	# that can be set in order to handle this situation
	nice -n 5 conky -q -c "$(dirname "$0")"/cronorc || {
		notify-send "Cronograph Station SE" "Conky Cronograph Station SE cannot be started." -i face-worried; exit 1;
	}
} || {
	notify-send "Cronograph Station SE" "Conky Cronograph Station SE is already on the run." -i face-plain; exit 2;
}

exit 0
