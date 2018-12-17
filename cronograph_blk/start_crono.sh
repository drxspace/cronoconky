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
	InfoSnd="$(which paplay) /usr/share/sounds/freedesktop/stereo/dialog-information.oga"
}

# The user's directory this script stores estimated weather condition files
# plus application settings
condDir="${HOME}"/.config/cronograph_blk
# ...but first make sure it exists
test -d "${condDir}" || mkdir -p "${condDir}"

# Read the application settings
ASD='10'
appSet="${HOME}"/.config/cronograph_blk/cronorc
if [ -f "${appSet}" ]; then
	source "${appSet}";
fi

if [[ "$(pgrep -c -f "^conky.*cronorc$")" -eq 0 ]]; then
	"$(dirname "$0")"/yahooweather/forecasts.sh &>/dev/null
	if [[ ! "$DESKTOP_SESSION" =~ kde*|cinnamon ]]; then sleep ${ASD}; fi
	# There's also the X-GNOME-Autostart-Delay property in .desktop file
	hash conky && conky -q -d -c /opt/cronograph_blk/cronorc || {
		notify-send "Cronograph Station BLK" "Conky Cronograph Station BLK cannot be started." -i face-worried;
		$(${ErrorSnd}); exit 1;
	}
else
	notify-send "Cronograph Station BLK" "Conky Cronograph Station BLK is already on the run. I'll try to restart it..." -i face-plain; $(${InfoSnd});
	restart_crono
fi

exit 0
