#!/bin/sh

# NOTE: Replace this with the username that you expect users to connect with.
VCSUSER="git"

if [ "$1" != "$VCSUSER" ];
then
  exit 1
fi

exec "/opt/phabricator/phabricator/bin/ssh-auth" $@
