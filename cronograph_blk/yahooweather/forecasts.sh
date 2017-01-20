#!/usr/bin/env bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#
#set -e

ForeCastScript="$(basename $0)"

dispMesg () {
	echo -e "${ForeCastScript}: ${1}" 1>&2;
}

_trapError () {
	dispMesg "Error in line ${1}: ${2:-'Unknown Error'}"
	trap - EXIT # We needed to remove the trap
	pkill -SIGCONT -o -x -f "^conky.*cronorc$" # Continue the conky process first
	exit 1
}

trap '_trapError ${LINENO} ${$?}' EXIT

# Store temporary data in this directory
cacheDir="${HOME}"/.cache/cronograph_blk
# ...but first make sure that it's clear
test -d "${cacheDir}" || mkdir -p "${cacheDir}"
# Store temporary RSS Feed in this file
cacheFile="YahooWeather.xml"

# The user's directory this script stores estimated weather condition files
# plus application settings
condDir="${HOME}"/.config/cronograph_blk
# ...but first make sure it exists
test -d "${condDir}" || mkdir -p "${condDir}"

# Read the application settings
appSet="${HOME}"/.config/cronograph_blk/cronorc
if [ -f "${appSet}" ]; then source "${appSet}"; fi
if [ -z ${WOEID} ]; then
	WOEID='12839162'
	echo "
# Navigate to https://www.yahoo.com/news/weather/ enter your or zip code to locate
# the place you want to watch and get the WOEID number at url's end e.g.
# https://www.yahoo.com/news/weather/greece/kalivia/kalivia-12839162
#                                                           ^^^^^^^^
" >> "${appSet}";
	echo "# This is my default WOEID (where on Earth ID). Next, set yours if you'd like." >> "${appSet}";
	echo "WOEID=${WOEID}" >> "${appSet}";
fi

# Uncomment next line to make use of English units
#temperature_unit='F'

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

# Yahoo Weather RSS Feed url
YahooWurl="http://query.yahooapis.com/v1/public/yql?format%3Dxml&q=select+item.condition%2C+item.forecast%0D%0Afrom+weather.forecast%0D%0Awhere+woeid+%3D+${WOEID}%0D%0Aand+u+%3D+%27${temperature_unit:-C}%27%0D%0Alimit+4%0D%0A|%0D%0Asort%28field%3D%22item.forecast.date%22%2C+descending%3D%22false%22%29%0D%0A%3B"

# User Agent String from http://www.useragentstring.com
# Suppose we're using Chrome/30.0.1599.17
#UserAgent='Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.17 Safari/537.36'
# Suppose we're using Chrome/41.0.2228.0
#UserAgent='Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36'
# Suppose we're using Firefox/43.0
UserAgent='Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:43.0) Gecko/20100101 Firefox/43.0'

# urldecode () function that decodes the given URL string
urldecode() {
	local url_encoded="${1//+/ }"
	printf '%b' "${url_encoded//%/\\x}"
}

# wrapConds () function that wraps the given string if it's >15 chars
wrapConds () {
	echo "$*" | fold -s -w 15
}

# ******************************************************************************

shortLoopCounter=4

contactYahoo () {
	dispMesg "Contacting the Yahoo server..."
#	dispMesg "Contacting the server at url:\n$(urldecode ${YahooWurl})"
	# --retry-connrefused Added in 7.52.0
	# --retry 2 --retry-max-time 5 --retry-delay 2 --max-time 35
	curl -s -N -4 --connect-timeout 10 -f -A "${UserAgent}" -o "${cacheDir}"/"${cacheFile}" "${YahooWurl}"
}

# ******************************************************************************

checkResultsOK () {
	dispMesg "Checking the results..."
	if [ -z "$(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}")" ]; then
		dispMesg " ~> yweather:forecast wasn't found in the file ${cacheFile}"
		return 1;
	else
		dispMesg " ~> Results OK"
		return 0;
	fi
}

takeAShortLoop () {
	dispMesg "Taking a short loop of ${shortLoopCounter} more attempts to contact the server..."
	until [[ ${shortLoopCounter} -eq 0 ]]; do
		contactYahoo && checkResultsOK && break;
		sleep 2;
		let shortLoopCounter-=1; # let: -=: syntax error
	done
	if [[ ${shortLoopCounter} -gt 0 ]]; then
		dispMesg "==> Loop done OK"
		sleep 2;
		return 0;
	else
		dispMesg "==> The server did not respond as expected"
		return 1;
	fi
}

# retryOrDie () function clears the cond files so that nothing would be displayed on
# the clock, writes an error on the stderr file and then tries to exit the script
# normally
retryOrDie () {
	takeAShortLoop || {
		pkill -SIGSTOP -o -x -f "^conky.*cronorc$"
		dispMesg "ERROR: Yahoo! weather server did not reply properly"
		dispMesg "Clearing the contents of existing conditions files"
		cat /dev/null > "${condDir}"/curr_cond
		cat /dev/null > "${condDir}"/fore_cond
		echo "99999" > "${condDir}"/curr_cond
		echo "weather error" >> "${condDir}"/curr_cond
		echo "Yahoo! weather server did not reply properly" >> "${condDir}"/curr_cond
		echo "Connection was tried 5 times but failed" >> "${condDir}"/curr_cond
		echo "Please, check your Internet connection" >> "${condDir}"/curr_cond
		echo "or wait a while for a retry attempt" >> "${condDir}"/curr_cond
		pkill -SIGCONT -o -x -f "^conky.*cronorc$"
		trap - EXIT; exit 2
	}
}

###
#
# Main section
#

{ contactYahoo && checkResultsOK; } || retryOrDie

# Pause the running conky process before
dispMesg "Temporary stopping conky from running"
pkill -SIGSTOP -o -x -f "^conky.*cronorc$"

dispMesg "Processing data..."
# Following commands are inspired or even totally taken from zagortenay333's Conky-Harmattan
# http://zagortenay333.deviantart.com/
# http://zagortenay333.deviantart.com/art/Conky-Harmattan-426662366

# Write the current weather conditions to file
echo "$(grep "yweather:condition" "${cacheDir}"/"${cacheFile}" | grep -o "temp=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==1')"° > "${condDir}"/curr_cond
echo "$(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "low=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==1')°/\
$(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "high=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==1' | tr '[a-z]' '[A-Z')°" >> "${condDir}"/curr_cond
getImgChr $(grep "yweather:condition" "${cacheDir}"/"${cacheFile}" | grep -o "code=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==1') >> "${condDir}"/curr_cond
wrapConds $(grep "yweather:condition" "${cacheDir}"/"${cacheFile}" | grep -o "text=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==1' | tr '[a-z]' '[A-Z]') >> "${condDir}"/curr_cond

# Write the next three days weather predictions to file
getImgChr $(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "code=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==4') > "${condDir}"/fore_cond
getImgChr $(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "code=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==6') >> "${condDir}"/fore_cond
getImgChr $(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "code=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==8') >> "${condDir}"/fore_cond
echo "$(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "low=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==2')°/\
$(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "high=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==2' | tr '[a-z]' '[A-Z')°" >> "${condDir}"/fore_cond
echo "$(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "low=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==3')°/\
$(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "high=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==3')°" >> "${condDir}"/fore_cond
echo "$(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "low=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==4')°/\
$(grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "high=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==4')°" >> "${condDir}"/fore_cond
grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "day=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==2' | tr '[a-z]' '[A-Z]' >> "${condDir}"/fore_cond
grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "day=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==3' | tr '[a-z]' '[A-Z]' >> "${condDir}"/fore_cond
grep "yweather:forecast" "${cacheDir}"/"${cacheFile}" | grep -o "day=\"[^\"]*\"" | grep -o "\"[^\"]*\"" | grep -o "[^\"]*" | awk 'NR==4' | tr '[a-z]' '[A-Z]' >> "${condDir}"/fore_cond

# Restart the paused conky process
dispMesg "Restart running the conky"
pkill -SIGCONT -o -x -f "^conky.*cronorc$"

dispMesg "Forecasts script ended up okay at $(date +%H:%M)"

# We needed to remove the trap at the end or the _trapError function would have
# been called as we exited, undoing all the script’s hard work.
trap - EXIT

exit 0
