#!/usr/bin/env bash

if [ ${SENZING_SSHD_SHOW_PERFORMANCE_WARNING} != "true" ]
then

	> /etc/motd
fi

echo root:${ROOT_PASSWORD} | chpasswd
/usr/sbin/sshd -D
