#!/bin/bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#

kill -TERM $(pgrep -f "conky -c.*cronograph_se") 2> /dev/null
sleep 25
#     ^^
# Error of failed request:  BadWindow (invalid Window parameter)
#rm "$(dirname "$0")"/conkyerr.log && $(which conky) -c "$(dirname "$0")"/conkyrc &> "$(dirname "$0")"/conkyerr.log &
# Alternative, there's also the X-GNOME-Autostart-Delay=<value> property in .desktop autostart file.
$(which conky) -c "$(dirname "$0")"/conkyrc &> /dev/null &

exit 0
