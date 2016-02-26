#!/usr/bin/env bash
# aphlict-wrapper.sh, version 0.1.0
#
# You cannot start aphlict in some foreground mode and
# it's more or less important that docker doesn't kill
# aphlict and its children if you stop the container.
#
# Use this script with supervisord and it will take
# care about starting and stopping aphlict correctly.
#

trap "${PHABRICATOR_DIR}/bin/aphlict stop" SIGINT
trap "${PHABRICATOR_DIR}/bin/aphlict stop" SIGTERM
trap "${PHABRICATOR_DIR}/bin/aphlict reload" SIGHUP

# start aphlict
${PHABRICATOR_DIR}/bin/aphlict start --client-host=localhost

# lets give aphlict some time to start
sleep 1

# wait until aphlict is dead (triggered by trap)
while `${PHABRICATOR_DIR}/bin/aphlict status >> /dev/null`
do
    sleep 5
done
