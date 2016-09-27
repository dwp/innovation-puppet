#!/bin/bash
# Code to rsync puppet up to the knowbot servers.
TARGETDIR="/home/ubuntu/puppet"
PUPPETDIR="$( dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" )"

# now perform the sync to push data to the remote machine
rsync -avh $PUPPETDIR/ ubuntu@knowbot:$TARGETDIR/ --delete \
    --exclude .git \
    --exclude .gitignore \
    --exclude .tmp \
    --exclude .librarian

# and push it to the local /etc/puppet directory
ssh ubuntu@knowbot  << EOF
sudo rsync -avh /home/ubuntu/puppet/ /etc/puppet/ --delete --exclude certname --exclude manifest --chown root:root
sudo freepuppet-run
EOF