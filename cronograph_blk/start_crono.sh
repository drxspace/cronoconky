#!/usr/bin/env bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#

# With the background property setted to yes I don't need the &
[[ "$(which paplay)" ]] && [[ -d /usr/share/sounds/freedesktop/stereo/ ]] && {
	ErrorSnd="$(which paplay) /usr/share/sounds/freedesktop/stereo/dialog-error.oga"
}

[[ "$(pgrep -c -f "^conky.*cronorc$" 2> /dev/null)" ]] && {
	[[ "$DESKTOP_SESSION" =~ kde*|cinnamon ]] || sleep 12;
	# Error of failed request:                         ^^
	# BadWindow (invalid Window parameter)
	# There's also the X-GNOME-Autostart-Delay=25 property in .desktop file
	# that can be set in order to handle this situation
	nice -n 5 conky -q -c /opt/cronograph_blk/cronorc || {
		notify-send "Cronograph Station BLK" "Conky Cronograph Station BLK cannot be started." -i face-worried;
		$(${ErrorSnd}); exit 1;
	}
} || {
	notify-send "Cronograph Station BLK" "Conky Cronograph Station BLK is already on the run." -i face-plain;
	$(${ErrorSnd}); exit 2;
}

exit 0
