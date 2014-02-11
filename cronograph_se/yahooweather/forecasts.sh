#!/bin/bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#
#set -e

# getImgChr () function converts
# YAHOO! weather icon codes (http://developer.yahoo.com/weather/#codes)
# to characters for use with the ConkyWeather truetype fonts
getImgChr () {
	case $1 in
		0) # sunny
			echo a
		;;
		1) # sunny
			echo a
		;;
		2) # mostly sunny
			echo b
		;;
		3|4|5) # partly sunny | intermittent clouds | hazy sunshine
			echo c
		;;
		6) # mostly cloudy
			echo d
		;;
		7) # cloudy
			echo e
		;;
		8) # dreary
			echo f
		;;
		9) # dreary
			echo f
		;;
		10) # dreary
			echo f
		;;
		11) # fog
			echo 0
		;;
		12) # showers
			echo h
		;;
		13|14) # mostly cloudy with showers | partly sunny with showers
			echo g
		;;
		15) # thunderstorms
			echo l
		;;
		16|17) # mostly clooudy with thunderstorms | partly sunny with thundershowers
			echo k
		;;
		18) # rain
			echo i
		;;
		19) # flurries
			echo q
		;;
		20|21|23) # mostly cloudy with flurries | partly sunny with flurries | mostly cloudy with snow
			echo o
		;;
		22) # snow
			echo r
		;;
		24|31) # ice | cold
			echo E
		;;
		25) # sleet
			echo v
		;;
		26) # freezing rain
			echo x
		;;
		# icons 27-28 have been retired
		29) # rain and snow
			echo y
		;;
		30) # hot
			echo 5
		;;
		32) # windy
			echo 6
		;;
		33) # clear
			echo A
		;;
		34|35) # mostly clear | partly cloudy
			echo B
		;;
		36|37) # intermittent clouds | hazy
			echo C
		;;
		38) # mostly cloudy
			echo D
		;;
		39|40) # partly cloudy with showers | mostly cloudy with showers
			echo G
		;;
		41|42) # partly cloudy with thunder showers | mostly cloudy with thunder showers
			echo K
		;;
		43|44) # mostly cloudy with flurries | mostly cloudy with snow
			echo O
		;;
		*)
			echo -
		;;
	esac
}

# User Agent String from http://www.useragentstring.com
# Suppose we're using Chrome/30.0.1599.17
UserAgent='Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.17 Safari/537.36'

# The directory this script resides
scriptDir="$(dirname "$0")"

# Store temporary data in this directory...
cacheDir="$HOME/.cache/cronograph"
# ...but first make sure that it's clear
[[ -d "${cacheDir}" ]] && rm -f "${cacheDir}"/* || mkdir -p "${cacheDir}"

# Store temporary RSS Feed in this file
cacheFile="YahooWeather.xml"

# clearConds () function clears the contents of conditions files
clearConds () {
	cat /dev/null > "${scriptDir}"/curr_cond
	cat /dev/null > "${scriptDir}"/fore_cond
}

# errExit () function clears the cond files so that nothing would be displayed on
# the clock, writes an error on the stderr file and then exits the script
errExit () {
	echo -e "$1" >&2
	clearConds
	echo "Yahoo! Error..." > "${scriptDir}"/curr_cond
	exit 1
}

###
#
# main section
#

# INFO: Navigate to http://weather.yahoo.com/ enter your or zip code to locate
#       your place you want to watch and get the WOEID number at url's end e.g.
#       http://weather.yahoo.com/greece/attica/athens-946738/
#                                                     ^^^^^^
#       This is the WOEID (where on Earth ID) number we're talking.
#       Then replace the following one with the WOEID of your own location.
WOEID='946738'

# Uncomment next line to make use of English units
#DegreesUnits='f'

# Yahoo Weather RSS Feed url
YahooWurl="http://weather.yahooapis.com/forecastrss?w=${WOEID}&u=${DegreesUnits:-c}"

echo -e "forecasts.sh: Contacting the server at url:\n\t${YahooWurl}" >&2

wget -q -4 -t 1 --user-agent="${UserAgent}" -O "${cacheDir}"/"${cacheFile}" "${YahooWurl}" ||
	errExit "ERROR: Wget exits with error code $?."

echo "forecasts.sh: Checking the results..." >&2

[[ -z $(grep "yweather:condition" "${cacheDir}"/"${cacheFile}") ]] &&
       errExit "ERROR: Yahoo Weather server reports failure."

echo "forecasts.sh: Processing data..." >&2

# Pause the running conky process
pkill -SIGSTOP --oldest --exact --full "^conky.*cronorc$"

# Write the current weather conditions to file
echo "$(grep "yweather:condition" "${cacheDir}"/"${cacheFile}" | grep -o "temp=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*")"° > "${scriptDir}"/curr_cond
getImgChr $(grep "yweather:condition" "${cacheDir}"/"${cacheFile}" | grep -o "code=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*") >> "${scriptDir}"/curr_cond
grep "yweather:condition" "${cacheDir}"/"${cacheFile}" | grep -o "text=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | tr '[a-z]' '[A-Z]' >> "${scriptDir}"/curr_cond

# Write the next three days weather predictions to file
getImgChr $(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "code=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==1') > "${scriptDir}"/fore_cond
getImgChr $(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "code=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==2') >> "${scriptDir}"/fore_cond
getImgChr $(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "code=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==3') >> "${scriptDir}"/fore_cond
echo "$(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "low=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==2')°/\
$(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "high=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==2' | tr '[a-z]' '[A-Z')°" >> "${scriptDir}"/fore_cond
echo "$(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "low=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==3')°/\
$(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "high=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==3')°" >> "${scriptDir}"/fore_cond
echo "$(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "low=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==4')°/\
$(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "high=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==4')°" >> "${scriptDir}"/fore_cond
grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "day=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==2' | tr '[a-z]' '[A-Z]' >> "${scriptDir}"/fore_cond
grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "day=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==3' | tr '[a-z]' '[A-Z]' >> "${scriptDir}"/fore_cond
grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "day=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==4' | tr '[a-z]' '[A-Z]' >> "${scriptDir}"/fore_cond

# Restart the paused conky process
pkill -SIGCONT --oldest --exact --full "^conky.*cronorc$"

exit 0
