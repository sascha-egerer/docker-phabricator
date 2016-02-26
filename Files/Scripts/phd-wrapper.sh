#!/usr/bin/env bash
# phd-wrapper.sh, version 0.1.0
#
# You cannot start phd in some foreground mode and
# it's more or less important that docker doesn't kill
# phd and its children if you stop the container.
#
# Use this script with supervisord and it will take
# care about starting and stopping phd correctly.
#

trap "${PHABRICATOR_DIR}/bin/phd stop" SIGINT
trap "${PHABRICATOR_DIR}/bin/phd stop" SIGTERM
trap "${PHABRICATOR_DIR}/bin/phd reload" SIGHUP

# start phd
${PHABRICATOR_DIR}/bin/phd start

# lets give phd some time to start
sleep 1

# wait until phd is dead (triggered by trap)
while `${PHABRICATOR_DIR}/bin/phd status --local >> /dev/null`
do
    sleep 5
done
