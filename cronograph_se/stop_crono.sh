#!/bin/bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#

#pkill -SIGKILL -o -x -f "^conky.*cronorc$" 2> /dev/null && {
pkill -SIGTERM -o -x -f "^conky.*cronorc$" 2> /dev/null && {
	notify-send "Cronograph Station SE" "Conky Cronograph Station SE successfully stopped." -i face-smile;
} || {
	notify-send "Cronograph Station SE" "Conky Cronograph Station SE is not running." -i face-plain; exit 1;
}

exit 0
