#!/usr/bin/env bash

if [ ${SENZING_SSHD_SHOW_PERFORMANCE_WARNING} != "true" ]
then

    > /etc/motd
fi

# when the root password is set externally, update the password
echo root:${ROOT_PASSWORD} | chpasswd
# then remove the root password as and env var
echo "unset ROOT_PASSWORD" >> /etc/profile
echo "export SENZING_ENGINE_CONFIGURATION_JSON='${SENZING_ENGINE_CONFIGURATION_JSON}'" >> /etc/profile
echo "export SENZING_SKIP_DATABASE_PERFORMANCE_TEST=${SENZING_SKIP_DATABASE_PERFORMANCE_TEST}" >> /etc/profile
/usr/sbin/sshd -D
