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

####### I M P O R T A N T #######
#
# Please, check the 174th line and enter the WOEID of your own location
#

# getImgChr () function converts
# YAHOO! weather icon codes (http://developer.yahoo.com/weather/#codes)
# to characters for use with the ConkyWeather truetype fonts
getImgChr () {
	case $1 in
		0) # tornado
			echo 1
		;;
		1|4|38|39) # tropical storm,thunderstorms,scattered thunderstorms
			echo l
		;;
		2) # hurricane
			echo 3
		;;
		3) # severe thunderstorms
			echo n
		;;
		5|7|18) # mixed rain and snow,mixed snow and sleet,sleet
			echo y
		;;
		6|35) # mixed rain and sleet,mixed rain and hail
			echo v
		;;
		8|9|10) # freezing drizzle,drizzle,freezing rain
			echo x
		;;
		11|12|40) # showers,scattered showers
			echo s
		;;
		13) # snow flurries
			echo p
		;;
		14|42|46) # light snow showers,scattered snow showers,snow showers
			echo o
		;;
		15) # blowing snow
			echo 8
		;;
		16) # snow
			echo q
		;;
		17) # hail
			echo u
		;;
		19) # dust
			echo 7
		;;
		20) # foggy
			echo 0
		;;
		21|29) # haze,partly cloudy (night)
			echo C
		;;
		22|24) # smoky,windy
			echo 9
		;;
		23) # blustery
			echo 2
		;;
		25) # cold
			echo E
		;;
		26) # cloudy
			echo e
		;;
		27) # mostly cloudy (night)
			echo D
		;;
		28) # mostly cloudy (day)
			echo d
		;;
		30|44) # partly cloudy (day),partly cloudy
			echo c
		;;
		31) # clear (night)
			echo A
		;;
		32) # sunny
			echo a
		;;
		33) # fair (night)
			echo B
		;;
		34) # fair (day)
			echo b
		;;
		36) # hot
			echo 5
		;;
		37|45|47) # isolated thunderstorms,thundershowers,isolated thundershowers
			echo k
		;;
		41) # heavy snow
			echo r
		;;
		43) # heavy snow
			echo r
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

# wrapConds () function wrap the given text if it's >15 chars
wrapConds () {
	fold -s -w 15 <<< "$*"
}

# errExit () function clears the cond files so that nothing would be displayed on
# the clock, writes an error on the stderr file and then exits the script
errExit () {
	echo -e "ERROR: $1" >&2
	clearConds
	echo "99999" > "${scriptDir}"/curr_cond
	echo "error!" >> "${scriptDir}"/curr_cond
	echo "$1" >> "${scriptDir}"/curr_cond
	if [[ $2 -eq 1 ]]; then
		echo "Please, check that you are connected" >> "${scriptDir}"/curr_cond
	else
		echo "Please, wait a little for retry" >> "${scriptDir}"/curr_cond
	fi
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
	errExit "Wget exits with error code $?" 1

echo "forecasts.sh: Checking the results..." >&2

[[ -z $(grep "yweather:condition" "${cacheDir}"/"${cacheFile}") ]] &&
       errExit "Yahoo! weather server did not reply properly" 2

echo "forecasts.sh: Processing data..." >&2

# Pause the running conky process
pkill -SIGSTOP --oldest --exact --full "^conky.*cronorc$"

# Following commands are inspired or even totally taken from zagortenay333's Conky-Harmattan 
# http://zagortenay333.deviantart.com/
# http://zagortenay333.deviantart.com/art/Conky-Harmattan-426662366

# Write the current weather conditions to file
echo "$(grep "yweather:condition" "${cacheDir}"/"${cacheFile}" | grep -o "temp=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*")"° > "${scriptDir}"/curr_cond
echo "$(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "low=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==1')°/\
$(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "high=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==1' | tr '[a-z]' '[A-Z')°" >> "${scriptDir}"/curr_cond
getImgChr $(grep "yweather:condition" "${cacheDir}"/"${cacheFile}" | grep -o "code=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*") >> "${scriptDir}"/curr_cond
wrapConds $(grep "yweather:condition" "${cacheDir}"/"${cacheFile}" | grep -o "text=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | tr '[a-z]' '[A-Z]') >> "${scriptDir}"/curr_cond

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
