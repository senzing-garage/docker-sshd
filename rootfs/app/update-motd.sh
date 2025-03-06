#!/usr/bin/env bash

SIGNAL_V3=/opt/senzing/g2/g2BuildVersion.json
SIGNAL_V4=/opt/senzing/er/szBuildVersion.json

if test -f ${SIGNAL_V3}; then
   cp /etc/motd.v3 /etc/motd
   exit 0
fi

# Default Message Of The Day.

cp /etc/motd.v4 /etc/motd
