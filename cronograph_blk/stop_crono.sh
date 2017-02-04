#!/usr/bin/env bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#
[[ -x "$(which paplay)" ]] && [[ -d /usr/share/sounds/freedesktop/stereo/ ]] && {
	ErrorSnd="$(which paplay) /usr/share/sounds/freedesktop/stereo/dialog-error.oga"
	KillSnd="$(which paplay) /usr/share/sounds/freedesktop/stereo/trash-empty.oga"
	StopSnd="$(which paplay) /usr/share/sounds/freedesktop/stereo/device-removed.oga"
}

pkill -SIGCONT -o -x -f "^conky.*cronorc$" 2> /dev/null && {
	pkill -SIGTERM -o -x -f "^conky.*cronorc$" 2> /dev/null
	sleep 1;
	pkill -SIGKILL -o -x -f "^conky.*cronorc$" 2> /dev/null && {
		notify-send "Cronograph Station BLK" "Conky Cronograph Station BLK cannot be stopped so it was killed." -i face-worried;
		$(${KillSnd}); exit 1;
	} || {
		notify-send "Cronograph Station BLK" "Conky Cronograph Station BLK successfully stopped." -i face-smile;
		$(${StopSnd});
	}
} || {
	notify-send "Cronograph Station BLK" "Conky Cronograph Station BLK is not running." -i face-plain;
	$(${ErrorSnd}); exit 2;
}

exit 0
