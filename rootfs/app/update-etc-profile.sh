#!/usr/bin/env bash

SIGNAL_V3=/opt/senzing/g2/g2BuildVersion.json
SIGNAL_V4=/opt/senzing/er/szBuildVersion.json

OUTFILE=/etc/profile

# Common values.

{
   echo "export LANGUAGE=C"
   echo "export LC_ALL=C.UTF-8"
   echo "export PATH=${PATH}"
   echo "export PYTHONUNBUFFERED=1"
   echo "export NOTVISIBLE='in users profile'"
   echo "export ROOT_PASSWORD=senzingsshdpassword"
   echo "export SENZING_DOCKER_LAUNCHED=true"
   echo "export SENZING_SKIP_DATABASE_PERFORMANCE_TEST=true"
   echo "export SENZING_SSHD_SHOW_PERFORMANCE_WARNING=true"
   echo "export VISIBLE=now"
} >> ${OUTFILE}

# Senzing Version 3 values.

if test -f ${SIGNAL_V3}; then
   {
      echo "export LD_LIBRARY_PATH=/opt/senzing/g2/lib"
      echo "export PYTHONPATH=/opt/senzing/g2/python:/opt/senzing/g2/sdk/python"
   } >> ${OUTFILE}
   exit 0
fi

# Default values.

{
   echo "export LD_LIBRARY_PATH=/opt/senzing/er/lib"
   echo "export PYTHONPATH=/opt/senzing/er/bin:/opt/senzing/er/sdk/python"
} >> ${OUTFILE}