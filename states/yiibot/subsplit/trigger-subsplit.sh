#!/bin/sh
#
# Triggers the git subsplit cronjob by creating the /tmp/github-yii2.lock file
# as user www-data.
#
# The cronjob will pick up the file and run the subsplit if it exists.
# The cronjob will remove the file afterwards.
#
# It is important that the file is owned by www-data user, otherwise subsplit will not work.
#


echo "ok" | su -s /bin/bash -c "tee /tmp/github-yii2.lock" www-data

echo ""
echo "subsplit triggered, it will run within the next 2 minutes."
echo "Check logs for updates:"
echo ""
echo "tail -f /var/log/subsplit.log"
echo ""
