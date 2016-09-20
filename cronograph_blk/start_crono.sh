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

# The user's directory this script stores estimated weather condition files
# plus application settings
condDir="${HOME}"/.config/cronograph_blk
# ...but first make sure it exists
test -d "${condDir}" || mkdir -p "${condDir}"

# Read the application settings
ASD='10'
appSet="${HOME}"/.config/cronograph_blk/cronorc
if [ -f "${appSet}" ]; then
	source "${appSet}"
else
	echo "# Cronograph Station BLK settings

# Due to the error: “Error of failed request/BadWindow (invalid Window parameter)”
# we must delay the startup of the script for several seconds.
" > "${appSet}";
	echo "# This is my default ASD (Autostart-Delay). Next, set yours if you'd like." >> "${appSet}";
	echo "ASD=${ASD}" >> "${appSet}";
fi

[[ "$(pgrep -c -f "^conky.*cronorc$" 2> /dev/null)" ]] && {
	[[ "$DESKTOP_SESSION" =~ kde*|cinnamon ]] || sleep ${ASD};
	# There's also the X-GNOME-Autostart-Delay property in .desktop file
	nice -n 5 conky -q -c /opt/cronograph_blk/cronorc || {
		notify-send "Cronograph Station BLK" "Conky Cronograph Station BLK cannot be started." -i face-worried;
		$(${ErrorSnd}); exit 1;
	}
} || {
	notify-send "Cronograph Station BLK" "Conky Cronograph Station BLK is already on the run." -i face-plain;
	$(${ErrorSnd}); exit 2;
}

exit 0
