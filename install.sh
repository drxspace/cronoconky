#!/usr/bin/env bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#

# -----------------------------------------------------------------------------]
__CNKDISTRO__=$(sed -n '/^ID=/s/ID=//p' /etc/*release 2>/dev/null)
__CNKDEBIANS__="debian|ubuntu|linuxmint|netrunner|elementary|zorin os"
__CNKARCHES__="arch|antergos|manjaro|apricity"
# -----------------------------------------------------------------------------]

DIR="$(dirname "$0")"
if [[ ${__CNKDISTRO__} =~ ${__CNKDEBIANS__} ]]; then
	MAININSTALLER="cronograph_conky_debians.pkg"
else
	notify-send "Error" "This installer cannot tell if you're using a supported linux distro or not and will now exit." -i face-embarrassed
	exit
fi

TERM=$(which gnome-terminal 2>/dev/null) || \
	TERM=$(which konsole 2>/dev/null) || \
	TERM=$(which mate-terminal 2>/dev/null) || \
	TERM=$(which xfce4-terminal 2>/dev/null) || \
	TERM=$(which pantheon-terminal 2>/dev/null) || \
	# ...else fallback to xterm if it's here
	TERM=${TERM:=$(which xterm 2>/dev/null)}
TITLE="Setup Cronograph Station Conky BLK (aka “crono”)"

case "$TERM" in
	*gnome-terminal)
		exec "$TERM" --geometry=94x24+0+0 -x /bin/bash "$DIR/$MAININSTALLER"
	;;
	*konsole)
		exec "$TERM" --geometry=94x24+0+0 --caption "$TITLE" -e /bin/bash "$DIR/$MAININSTALLER"
	;;
	*mate-terminal)
		exec "$TERM" --geometry=94x24+0+0 -t "$TITLE" -x /bin/bash "$DIR/$MAININSTALLER"
	;;
	*xfce4-terminal)
		exec "$TERM" --geometry=94x24+0+0 -T "$TITLE" -x /bin/bash "$DIR/$MAININSTALLER"
	;;
	*pantheon-terminal)
		exec "$TERM" -x /bin/bash "$DIR/$MAININSTALLER"
	;;
	*xterm)
		exec "$TERM" -e /bin/bash "$DIR"/"$MAININSTALLER"
	;;
	*)
		notify-send "Error" "Unable to install conky.\nNot an known terminal was found to execute the main installation package" -i face-embarrassed
	;;
esac

exit
