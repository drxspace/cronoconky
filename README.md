# Cronograph Station BLK
[![ License ](https://img.shields.io/badge/license-GPLv2-blue.svg?style=flat)](LICENSE.GPL)


![Cronograph Preview](https://github.com/drxspace/cronoconky/blob/master/crono-running.gif?raw=true "Cronograph Station BLK")


So many things should go here but I'm so sorry that I can't do it with my two
plus one fingers that ms disease left me...
Anyways, if you like it as I do, drop me a "letter" telling me that :)
Have fun love and joy ...and don't forget... anything else...
put it on the weather :-)

Thank you ALL!


### Tested (by me) and WORKED under these enviroments

- Ubuntu, all flavours
- ArchLinux


## INSTALLATION

- Ubuntu, run [in terminal] the "debians_install.sh" script and follow the instructions
- ArchLinux, you need to visit my [AUR cronograph-conky] page


### CHANGES in version 8.0

2017-02-03
· texeci
· shade

2017-02-02
· high CPU usage issue
· demonize again
· better rings
· cleanex

### CHANGES in version 7.5

2017-01-26
· do not show the weather error

### CHANGES in version 7.1

2017-01-23
· do not demonize
· more persistent

2017-01-21
· I can not type
· I can not type

### CHANGES in version 7.0

2017-01-06
· new startup action
· changes in Yahoo! weather script

### CHANGES in version 6.9

2016-11-21
· Changes in the restart_crono script and in the Yahoo! weather script
· Name changed to “Cronograph Station BLK”

### CHANGES in version 6.8

2016-10-12
· restart_crono --verbose
· new startup action
· changes in Yahoo! weather script
· changes in interface look

### CHANGES in version 6.6

2016-10-06
· new startup scripts

### CHANGES in version 6.5

2016-09-20
· user profile settings

### CHANGES in version 6.1

2016-09-11
· new installer for Debian based releases

### CHANGES in version 6.0

2016-09-03
· getting ready to Arch

### CHANGES in version 5.1

2016-08-30
· added shade in seconds hand

2016-08-25
· redesign of the clock background, added something I call it shade

### CHANGES in version 5.0

2016-07-25
· redesign of the clock background and foreground

### CHANGES in version 4.0

2016-07-19
· use of the new config file syntax which uses [Lua](http://www.lua.org/) syntax

### CHANGES in version 3.1

2016-05-20
· use of YQL to retrieve the weather information

### CHANGES in version 3.0

2015-10-18
· convert it to black on white
· realign elements
· resize images

### CHANGES in version 2.4

2014-06-14
· changes on the date look

2014-03-15
· cronorc script examines if we use the fahrenheit temperature unit and draws the
  needed elements using the right colors

### CHANGES in version 2.3

2014-02-28
· The long weather condition names are wrapped and the rc script takes that into
  accound

2014-02-27
· Workaround the voffset issue that change the conky window height

### CHANGES in version 2.2

2014-02-15
· The collectgarbage() function was used
· Lua scripts cleared

2014-02-12
· Changeover from Accuweather to Yahoo! weather (free) service
· Major changes in clock interface


### CHANGES in version 2.1.1

2013-12-27
· Minor changes in clock face


### CHANGES in version 2.1

2013-12-19
· Changes inthe way that lua scripts are called. This impacts the way that the
  clock is shaped -in a better order


### CHANGES in version 2

2013-11-18
· Changes in the forecasts.sh script due to problems with clearing conditions
  files

2013-10-27
· Tweak/change multi_rings.lua to draw nicer hands

2013-10-10
· The restart_crono.sh script has changed in order to remove old *_cond files
· Changes in the forecasts.sh in order to create an error log file
  Read carefully the info tip inside this script so that you set correctly the
  accuWurl variable

2013-09-03
· Sudden application shutdown corrected

2013-09-01
· Tweak blinkingLed script
· Minor changes in the led colors of the cronorc script

2013-08-27
· Installer package updated

2013-08-22
· MEMORY LEAK PROBLEMS WAS FOUND AND CORRECTED

2013-08-18
· New icons
· Changes in the main script: short_units property was added thanks to Sector11

2013-08-17
· Error correction in the main installer package

2013-08-16
· Changed the N/A state of the HDD temperature meter
· Changed the if commands that calculate the battery images in conkyrc
· Changed the execpi commands to execi in conkyrc

2013-08-15
· Changes in lua scripts to colorize rings
· Changes in conkyrc (remove and rearrange things)
· Minor changes in the forecasts script (temporary folder is no longer /tmp it's
  the user's ~/.cache)

2013-08-07
· Errors with `sed` commands corrected

2013-07-26
· Interface changes on weather icon colors

2013-07-25
· Bug fix: if the temperature is above 35° the script's lacks an endif
· Minor changes to the install.sh script

2013-06-28
· Colorize the current weather temperature indication

2013-06-18
· Add CPU Temperature indication

2013-06-17
· Change HD fs from free/total to used/free


## HOW-TOs

- Avoid conky loading twice in KDE4:
---- Go to System Settings > Startup and Shutdown > Session Managment
     On Login section check Start witn an empty session
- How to enable compositing?
---- Visit this http://mylinuxexplore.blogspot.gr/2012/05/solved-docky-issue-in-mintubuntu-how-to.html

[AUR cronograph-conky]:https://aur.archlinux.org/packages/cronograph-conky

