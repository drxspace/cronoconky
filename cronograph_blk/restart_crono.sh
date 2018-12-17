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
	RestartSnd="$(which paplay) /usr/share/sounds/freedesktop/stereo/message-new-instant.oga"
}

pkill -SIGCONT -o -x -f "^conky.*cronorc$" 2> /dev/null
pkill -SIGTERM -o -x -f "^conky.*cronorc$" 2> /dev/null && {
	# Verbose?
	if [[ $# -ge 1 ]] && [[ "$1" == @(-v|--verbose) ]]; then
		bash -c '/opt/cronograph_blk/yahooweather/forecasts.sh';
		sleep 3;
	fi
	sleep 2;
	pkill -SIGTERM -o -x -f "^conky.*cronorc$" 2> /dev/null && {
		pkill -SIGKILL -o -x -f "^conky.*cronorc$" 2> /dev/null && {
			notify-send "Cronograph Station BLK" "Conky Cronograph Station BLK couldn't be restarted so it was killed." -i face-worried;
			$(${KillSnd}); exit 1;
		}
	}
	hash conky && conky -q -d -c /opt/cronograph_blk/cronorc && {
		sleep 4;
		notify-send "Cronograph Station BLK" "Conky Cronograph Station BLK was restarted.\nYou may have to wait for a few seconds." -i face-smile;
		$(${RestartSnd});
	}
} || {
	notify-send "Cronograph Station BLK" "Conky Cronograph Station BLK is not running." -i face-plain;
	$(${ErrorSnd}); exit 2;
}

exit 0
