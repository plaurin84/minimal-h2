#!/bin/sh
H2="/opt/h2/bin/h2-1.4.196.jar"

#--------------------#
# h2 database server #
#--------------------#
java -jar $H2 -baseDir /opt/h2-data &

#------------#
# Init stage #
#------------#

#---------------#
# Shell Runtime #
#---------------#
trap 'pkill java; exit 0' SIGTERM
while true; do :; done
