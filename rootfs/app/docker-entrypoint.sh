#!/usr/bin/env bash

if [ ${SENZING_SSHD_SHOW_PERFORMANCE_WARNING} != "true" ]
then

	> /etc/motd
fi

echo root:${ROOT_PASSWORD} | chpasswd
echo ${SENZING_ENGINE_CONFIGURATION_JSON} >> /etc/profile
echo ${SENZING_SKIP_DATABASE_PERFORMANCE_TEST} >> /etc/profile
/usr/sbin/sshd -D
