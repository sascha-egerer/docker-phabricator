#!/usr/bin/env bash

set -e

echo "Copy ws module from global install"
cp -R /usr/local/lib/node_modules ${PHABRICATOR_DIR}/support/aphlict/server/
chown -R git:www-data ${PHABRICATOR_DIR}/support/aphlict/server/node_modules

if [ -e /config/script.pre ]; then
    echo "Applying pre-configuration script..."
    /config/script.pre
else
    echo "+++++ MISSING CONFIGURATION +++++"
    echo ""
    echo "You must specify a preconfiguration script for "
    echo "this Docker image. To do so: "
    echo ""
    echo "  Create a 'script.pre' file and add it to the"
    echo "  docker container in a directory called 'config'."
    echo "  You can do so by mounting the config folder"
    echo "  or adding the script in your custom image."
    echo ""
    echo "+++++ BOOT FAILED! +++++"
    exit 1
fi

if [ -e /config/script.premig ]; then
    echo "Applying pre-migration script..."
    /config/script.premig
fi

echo "Applying any pending DB schema upgrades..."
${PHABRICATOR_DIR}/bin/storage upgrade --force

if [ -e /config/script.post ]; then
    echo "Applying post-configuration script..."
    /config/script.post
fi

exec "$@"
