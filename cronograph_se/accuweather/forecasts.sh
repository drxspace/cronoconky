#!/bin/bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#

# getImgChr function converts AccuWeather icon codes to characters for use
# with the ConkyWeather truetype fonts
getImgChr () {
	case $1 in
		01) # sunny
			echo a
		;;
		02) # mostly sunny
			echo b
		;;
		03|04|05) # partly sunny | intermittent clouds | hazy sunshine
			echo c
		;;
		06) # mostly cloudy
			echo d
		;;
		07) # cloudy
			echo e
		;;
		08) # dreary
			echo f
		;;
		# icons 9-10 have been retired
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

# parseval function parses the value of the specified tag
parseval () {
	sed -n "s|<$1>\(.*\)</$1>|\1|p" $2 | sed "s/^[[:space:]]*//"
}

# trimday function returns a 3 letters word for the given day name
trimday () {
	local day=${1^^}
	echo ${day:0:3}
}

# errexit function clears the cond files so that nothing would be displayed on
# the clock, writes an error on the stderr file and then exits the script
errexit () {
	echo -e "$1" >&2
	echo "AccuWeather Err" > ${scriptDir}/curr_cond;
	exit 1
}

###
#
# main section
#

# The directory this script resides
scriptDir="$(dirname "$0")"

# INFO: Use Google Maps to locate your place and find out your coordinates (slat, slon) that you should place below
Latitude='37.98'
Longitude='23.73'

# Uncomment next line to make use of English units
#metric=0

accuWurl="http://thale.accu-weather.com/widget/thale/weather-data.asp?slat=${Latitude}&slon=${Longitude}&metric=${metric:-1}"

# Clear the contents of conditions files
cat /dev/null > ${scriptDir}/curr_cond
cat /dev/null > ${scriptDir}/fore_cond

# Store temporary data in this directory
cacheDir="$HOME/.cache/cronograph"
mkdir -p "${cacheDir}"

echo -e "forecasts.sh: Contacting the server at url:\n\t${accuWurl}" >&2

[[ -z $(grep -v "<currentconditions>" "${cacheDir}"/accuw.xml) ]] &&
	errexit "ERROR: AccuWeather server reports failure.";

echo "forecasts.sh: Checking the results..." >&2

[[ -z $(grep -v "<currentconditions>" "${cacheDir}"/accuw.xml) ]] &&
       errexit "ERROR: AccuWeather server reports failure.";

#Failure=$(grep "<failure>" "${cacheDir}"/accuw.xml)
#if [[ -n ${Failure} ]]; then
#       echo ${Failure} >&2
#       echo "forecasts.sh: Faking the coordinates..." >&2
##      Latitude+="0001"
##      Longitude+="0001"
#       Latitude=$(bc <<< "${Latitude} + 0.01")
#       Longitude=$(bc <<< "${Longitude} + 0.01")
#       accuWurl="http://thale.accu-weather.com/widget/thale/weather-data.asp?slat=${Latitude}&slon=${Longitude}&metric=${metric:-1}"
#
#       echo -e "forecasts.sh: Contacting the server for a second time at url...\n\t${accuWurl}" >&2
#
#       wget -q -4 -t 1 --no-cache -O "${cacheDir}"/accuw.xml "${accuWurl}" ||
#               errexit "ERROR: Wget exits with error code $?.";
#
#       echo "forecasts.sh: Checking the results again..." >&2
#       Failure=$(grep "<failure>" "${cacheDir}"/accuw.xml)
#fi
#
#[[ -n ${Failure} ]] &&
#       errexit "ERROR: AccuWeather server reports failure: $(echo ${Failure} | sed -n "s|<failure>\(.*\)</failure>|\1|p" | sed "s/^[[:space:]]*//")";

echo "forecasts.sh: Processing data..." >&2

sed -i -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "${cacheDir}"/accuw.xml
sed '/currentconditions/,/\/currentconditions/!d' "${cacheDir}"/accuw.xml > "${cacheDir}"/curr_cond.txt
sed -e '/day number="2"/,/day number="3"/!d' -e '/daycode/,/\/daytime/!d' "${cacheDir}"/accuw.xml > "${cacheDir}"/fore_1st.txt
sed -e '/day number="3"/,/day number="4"/!d' -e '/daycode/,/\/daytime/!d' "${cacheDir}"/accuw.xml > "${cacheDir}"/fore_2nd.txt
sed -e '/day number="4"/,/day number="5"/!d' -e '/daycode/,/\/daytime/!d' "${cacheDir}"/accuw.xml > "${cacheDir}"/fore_3rd.txt

pkill -SIGSTOP --oldest --exact --full "^conky.*cronorc$"
echo $(parseval 'temperature' "${cacheDir}"/curr_cond.txt)° > ${scriptDir}/curr_cond
getImgChr $(parseval 'weathericon' "${cacheDir}"/curr_cond.txt) >> ${scriptDir}/curr_cond
parseval 'weathertext' "${cacheDir}"/curr_cond.txt  | tr "[:lower:]" "[:upper:]" >> ${scriptDir}/curr_cond
getImgChr $(parseval 'weathericon' "${cacheDir}"/fore_1st.txt) > ${scriptDir}/fore_cond
getImgChr $(parseval 'weathericon' "${cacheDir}"/fore_2nd.txt) >> ${scriptDir}/fore_cond
getImgChr $(parseval 'weathericon' "${cacheDir}"/fore_3rd.txt) >> ${scriptDir}/fore_cond
{ echo $(parseval 'lowtemperature' "${cacheDir}"/fore_1st.txt)°/$(parseval 'hightemperature' "${cacheDir}"/fore_1st.txt)°; } >> ${scriptDir}/fore_cond
{ echo $(parseval 'lowtemperature' "${cacheDir}"/fore_2nd.txt)°/$(parseval 'hightemperature' "${cacheDir}"/fore_2nd.txt)°; } >> ${scriptDir}/fore_cond
{ echo $(parseval 'lowtemperature' "${cacheDir}"/fore_3rd.txt)°/$(parseval 'hightemperature' "${cacheDir}"/fore_3rd.txt)°; } >> ${scriptDir}/fore_cond
trimday $(parseval 'daycode' "${cacheDir}"/fore_1st.txt) >> ${scriptDir}/fore_cond
trimday $(parseval 'daycode' "${cacheDir}"/fore_2nd.txt) >> ${scriptDir}/fore_cond
trimday $(parseval 'daycode' "${cacheDir}"/fore_3rd.txt) >> ${scriptDir}/fore_cond
pkill -SIGCONT --oldest --exact --full "^conky.*cronorc$"

exit 0
