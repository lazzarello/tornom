#!/bin/sh

# Script that checks for finished downloads in Transmission and
# sends email to a specified user.
# This code placed into public domain

# Requires:
#   GNU mailutils | bsd-mailx (does not work with heirloom-mailx)
#   lockfile-progs
#   transmission-cli

# History:
#----------------------------------------------------------------------------
# Date        | Author <EMail>                  | Description               |
#----------------------------------------------------------------------------
# 04 May 2009 | A.Galanin <gaa.nnov AT mail.ru> | Creation                  |
# 04 May 2009 | A.Galanin <gaa.nnov AT mail.ru> | Usage moved before locking|
#----------------------------------------------------------------------------

# default configuration options
# put it into config file ~/.checkFinishedTransmissionDownloads/config
HOST=localhost
PORT=9091

RPC_AUTH=1
USER=username
PASS=password

MAILTO=root
FROM=torrent-checker
MAIL_CONTENT="Downloading of \"%s\" has been finished.\nGo to %s to make an approriate action.\n"

#------------------------------------------------------------------------------

# files
FILEPATH="$HOME/.checkFinishedTransmissionDownloads"
CONFIG_FILE="$FILEPATH/config"
NOTIFY_FILE="$FILEPATH/notified"
ALL_FILE="/tmp/checkFinishedTransmissionDownloads.all"
TMP_FILE="/tmp/checkFinishedTransmissionDownloads.tmp"
LOCK_FILE="/tmp/checkFinishedTransmissionDownloads"

[ -f "$CONFIG_FILE" ] && . "$CONFIG_FILE"

#------------------------------------------------------------------------------

# Call transmission-remote with corresponding parameters
callTransmission () {
    if [ "$RPC_AUTH" -eq 0 ]
    then
        transmission-remote "$HOST":"$PORT" "$@"
    else
        transmission-remote "$HOST":"$PORT" -N "$TMP_FILE" "$@"
    fi
}

# Remove lock and temporary files, exit with code $1
exitAndClean () {
    kill "$LOCK_PID"
    lockfile-remove "$LOCK_FILE"
    rm -f "$TMP_FILE" "$ALL_FILE"

    exit "$1"
}

# initialization
if [ $# != 0 ]
then
    echo "$0: check for finished downloads in Transmission"
    echo "USAGE: $0"
    exit 1
fi

lockfile-create "$LOCK_FILE" || (echo "Unable to lock lockfile!"; exitAndClean 2)
lockfile-touch "$LOCK_FILE" &
LOCK_PID="$!"

trap "exitAndClean 1" HUP INT QUIT KILL

mkdir -p "$FILEPATH"
touch "$NOTIFY_FILE" "$TMP_FILE"
echo -n > "$ALL_FILE"
chmod 600 "$TMP_FILE" "$ALL_FILE"
# generate netrc file for RPC authorisation
printf "machine %s\nlogin %s\npassword %s\n" "$HOST" "$USER" "$PASS" > "$TMP_FILE"

# main
callTransmission -l | gawk '{
    if ($1 != "Sum:" && $1 != "ID") {
        print $1,$2
    }
}' | while read id percent
do
    reply="`callTransmission -t "$id" -i | grep -E '^  Name|^  Hash'`"

    name="`echo "$reply" | grep '^  Name'  | cut -c 9-`"
    hash="`echo "$reply" | grep '^  Hash'  | cut -c 9-`"

    # check that notification is not yet sent
    grep -q "$hash" "$NOTIFY_FILE"
    if [ $? = 1 -a "$percent" = "100%" ]
    then
        printf "$MAIL_CONTENT" "$name" "http://$HOST:$PORT/" | \
            mailx $MAILTO -s "Torrents info: $name" -a "From: $FROM"
        echo "$hash" >> "$NOTIFY_FILE"
    fi
    echo "$hash" >> "$ALL_FILE"
done

# remove deleted torrents from sent notifications list
sort "$NOTIFY_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$NOTIFY_FILE"

sort "$ALL_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$ALL_FILE"

comm -1 -2 "$NOTIFY_FILE" "$ALL_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$NOTIFY_FILE"

exitAndClean 0
