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
	rm -f "$(dirname "$0")"/accuweather/{curr_cond,fore_cond,}
	sleep 5;
	nice -n 5 conky -q -c "$(dirname "$0")"/cronorc;
}

exit 0
