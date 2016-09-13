#!/bin/bash
# Code to rsync puppet up to the knowbot servers.

TARGETDIR="/home/ubuntu/puppet"
PUPPETDIR="$( dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" )"

# now perform the sync
rsync -rv $PUPPETDIR/ ubuntu@knowbot-app:$TARGETDIR

ssh -t ubuntu@knowbot-app << EOF
sudo cp -r /home/ubuntu/puppet/* /etc/puppet
sudo freepuppet-run
EOF