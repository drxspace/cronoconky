#!/bin/bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#

pkill -SIGTERM -o -x -f "^conky.*cronorc$" 2> /dev/null &&  (
	rm -f "$(dirname "$0")"/accuweather/*_cond;
	sleep 3;
	nice -n 5 conky -q -c "$(dirname "$0")"/cronorc &&  (
		sleep 5; notify-send "Cronograph Station SE" "Conky Cronograph Station SE was restarted." -i face-smile;
	) ||  (
		killall conky;
		notify-send "Cronograph Station SE" "Conky Cronograph Station SE cannot be restarted so all runnining conkies were stopped." -i face-worried; exit 1;
	)
) || (
	notify-send "Cronograph Station SE" "Conky Cronograph Station SE is not running." -i face-plain; exit 2;
)

exit 0
