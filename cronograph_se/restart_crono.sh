#!/bin/bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#

pkill -SIGTERM --oldest --exact --full "^conky.*cronorc$" 2> /dev/null && {
	rm -f "$(dirname "$0")"/accuweather/*_cond
	sleep 3
	nice -n 5 conky -q -c "$(dirname "$0")"/cronorc
} || {
	notify-send "Cronograph Station SE" "Conky Cronograph Station SE isn\'t running." -i face-sad
}

exit 0
