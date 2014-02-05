#!/bin/bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#

#ESC_DIR="$(printf "%q" "$(dirname "$0")")"
DIR="$(dirname "$0")"
MAININSTALLER="cronograph_conky.pkg"

if [ -t 0 ]; then
	/bin/bash "$DIR/$MAININSTALLER"
	exit
fi

TITLE="Setup Conky Cronograph Station SE"

if [[ "$KDE_FULL_SESSION" == "true" ]]; then
  TERM=$(which konsole)
else
  TERM=$(which gnome-terminal)
fi
# ...else fallback to xterm if it's here
TERM=${TERM:=$(which xterm)}

case "$TERM" in
	*konsole)
		exec "$TERM" --geometry 74x24+0+0 --caption "$TITLE" -e /bin/bash "$DIR/$MAININSTALLER"
	;;
	*gnome-terminal)
		exec "$TERM" --geometry 74x24+0+0 -t "$TITLE" -x /bin/bash "$DIR/$MAININSTALLER"
	;;
	*xterm)
		exec "$TERM" -geometry 74x24+0+0 -T "$TITLE" -e /bin/bash "$DIR"/"$MAININSTALLER"
	;;
	*)
		notify-send "Error" "Unable to install conky.\nNot an known terminal was found to execute the main installation package.\nTry to run this in your terminal.\nbash cronograph_conky.pkg" -i face-embarrassed
	;;
esac

exit
