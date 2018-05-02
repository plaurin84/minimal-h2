#!/bin/sh

#--------------------#
# h2 database server #
#--------------------#
java -jar h2.jar -baseDir /opt/h2-data &

#------------#
# Init stage #
#------------#

#---------------#
# Shell Runtime #
#---------------#
trap 'pkill java; exit 0' SIGTERM
while true; do :; done
