#!/bin/bash
# configure variables
MANIFEST_NAME_FILE=/etc/puppet/manifest
NODE_NAME_FILE=/etc/puppet/certname
LOCKFILE=/run/freepuppet-run.pid

# Pull in our enviromental settings.
echo "=================================================="
MANIFEST_NAME=$(<$MANIFEST_NAME_FILE)
echo "Reading manifest name as: ${MANIFEST_NAME}"
NODE_NAME=$(<$NODE_NAME_FILE)
echo "Reading node name as: ${NODE_NAME}"
echo "=================================================="

# lockfile mechanic
echo "Checking for lockfile existance at: ${LOCKFILE}"
if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "freepuppet-run is already running."
    exit
fi

# make sure the lockfile is removed when we exit and then claim it
trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
echo $$ > ${LOCKFILE}

echo "Creating lockfile and running puppet apply."
echo "/usr/bin/puppet apply --certname $NODE_NAME --modulepath /etc/puppet/modules --logdest syslog /etc/puppet/manifests/${MANIFEST_NAME}.pp"
/usr/bin/puppet apply --certname $NODE_NAME --modulepath /etc/puppet/modules --logdest syslog /etc/puppet/manifests/${MANIFEST_NAME}.pp


echo "Cleaning up lockfile."
rm -f ${LOCKFILE}
echo "=================================================="