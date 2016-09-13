#!/bin/bash
# Code to rsync puppet up to the knowbot servers.

TARGETDIR="/home/ubuntu/puppet"
PUPPETDIR="$( dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" )"

# now perform the sync
echo "rsync -avh $PUPPETDIR/ ubuntu@knowbot-app:$TARGETDIR --delete"
rsync -arvh $PUPPETDIR/ ubuntu@knowbot-app:$TARGETDIR --delete

ssh -t ubuntu@knowbot-app << EOF
sudo cp -r /home/ubuntu/puppet /etc/
sudo freepuppet-run
EOF