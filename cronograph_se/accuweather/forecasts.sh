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
	cat /dev/null > ${scriptdir}/curr_cond
	cat /dev/null > ${scriptdir}/fore_cond
	echo -e "$1" 1>&2
	exit 1
}

scriptdir="$(dirname "$0")"

# INFO: Use Google Maps to locate your place and find out your coordinates (slat, slon) that you should place below
Latitude='37.98'
Longitude='23.73'

# Uncomment next line to make use of English units
#metric=0

accuWurl="http://thale.accu-weather.com/widget/thale/weather-data.asp?slat=${Latitude}&slon=${Longitude}&metric=${metric:-1}"

# Store temporary data here
mkdir -p ~/.cache/cronograph

echo "forecasts.sh: Contacting the server..." 1>&2
wget -q -O ~/.cache/cronograph/accuw.xml $accuWurl ||
	errexit "$(date -R)\tERROR: Could not contact AccuWeather server. Maybe you're not online or the server wasn't ready.";

echo "forecasts.sh: Checking the results..." 1>&2
Failure=$(grep "<failure>" ~/.cache/cronograph/accuw.xml)

if [[ -n ${Failure} ]]; then
	echo "forecasts.sh: Faking the coordinates..." 1>&2
	Latitude=${Latitude}0001
	Longitude=${Longitude}0001

	echo "forecasts.sh: Contacting the server for a second time..." 1>&2
	wget -q -O ~/.cache/cronograph/accuw.xml $accuWurl ||
		errexit "$(date -R)\tERROR: Could not contact AccuWeather server. Maybe you're not online or the server wasn't ready.";

	echo "forecasts.sh: Checking the results again..." 1>&2
	Failure=$(grep "<failure>" ~/.cache/cronograph/accuw.xml)
fi

[[ -n ${Failure} ]] &&
	errexit "$(date -R)\tERROR: AccuWeather server reports failure: $(echo ${Failure} | sed -n "s|<failure>\(.*\)</failure>|\1|p" | sed "s/^[[:space:]]*//")";

echo "forecasts.sh: Processing data..." 1>&2
sed -i -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' ~/.cache/cronograph/accuw.xml
sed '/currentconditions/,/\/currentconditions/!d' ~/.cache/cronograph/accuw.xml > ~/.cache/cronograph/curr_cond.txt
sed -e '/day number="2"/,/day number="3"/!d' -e '/daycode/,/\/daytime/!d' ~/.cache/cronograph/accuw.xml > ~/.cache/cronograph/fore_1st.txt
sed -e '/day number="3"/,/day number="4"/!d' -e '/daycode/,/\/daytime/!d' ~/.cache/cronograph/accuw.xml > ~/.cache/cronograph/fore_2nd.txt
sed -e '/day number="4"/,/day number="5"/!d' -e '/daycode/,/\/daytime/!d' ~/.cache/cronograph/accuw.xml > ~/.cache/cronograph/fore_3rd.txt

pkill -SIGSTOP --oldest --exact --full "^conky.*cronorc$"
echo $(parseval 'temperature' ~/.cache/cronograph/curr_cond.txt)° > ${scriptdir}/curr_cond
getImgChr $(parseval 'weathericon' ~/.cache/cronograph/curr_cond.txt) >> ${scriptdir}/curr_cond
parseval 'weathertext' ~/.cache/cronograph/curr_cond.txt  | tr "[:lower:]" "[:upper:]" >> ${scriptdir}/curr_cond
getImgChr $(parseval 'weathericon' ~/.cache/cronograph/fore_1st.txt) > ${scriptdir}/fore_cond
getImgChr $(parseval 'weathericon' ~/.cache/cronograph/fore_2nd.txt) >> ${scriptdir}/fore_cond
getImgChr $(parseval 'weathericon' ~/.cache/cronograph/fore_3rd.txt) >> ${scriptdir}/fore_cond
{ echo $(parseval 'lowtemperature' ~/.cache/cronograph/fore_1st.txt)°/$(parseval 'hightemperature' ~/.cache/cronograph/fore_1st.txt)°; } >> ${scriptdir}/fore_cond
{ echo $(parseval 'lowtemperature' ~/.cache/cronograph/fore_2nd.txt)°/$(parseval 'hightemperature' ~/.cache/cronograph/fore_2nd.txt)°; } >> ${scriptdir}/fore_cond
{ echo $(parseval 'lowtemperature' ~/.cache/cronograph/fore_3rd.txt)°/$(parseval 'hightemperature' ~/.cache/cronograph/fore_3rd.txt)°; } >> ${scriptdir}/fore_cond
trimday $(parseval 'daycode' ~/.cache/cronograph/fore_1st.txt) >> ${scriptdir}/fore_cond
trimday $(parseval 'daycode' ~/.cache/cronograph/fore_2nd.txt) >> ${scriptdir}/fore_cond
trimday $(parseval 'daycode' ~/.cache/cronograph/fore_3rd.txt) >> ${scriptdir}/fore_cond
pkill -SIGCONT --oldest --exact --full "^conky.*cronorc$"

exit 0
