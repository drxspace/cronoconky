#!/bin/bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#

kill -SIGTERM $(pgrep -f "conky.*cronorc$") 2> /dev/null
#sleep 25
#      ^^
# Error of failed request:  BadWindow (invalid Window parameter)
# There's also the X-GNOME-Autostart-Delay=25 property in .desktop file to
# handle this situation
#rm "$(dirname "$0")"/conkyerr.log && $(which conky) -DD -c "$(dirname "$0")"/cronorc &> "$(dirname "$0")"/conkyerr.log &

#conky -q -c "$(dirname "$0")"/cronorc &
# With the background property setted to yes I don't need the &
nice -n 10 conky -q -c "$(dirname "$0")"/cronorc

exit 0
