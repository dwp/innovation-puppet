#!/bin/bash
# Code to rsync puppet up to the knowbot servers.
TARGETDIR="/home/ubuntu/puppet"
PUPPETDIR="$( dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" )"

# now perform the sync to push data to the remote machine
rsync -arvh $PUPPETDIR/ ubuntu@knowbot-app:$TARGETDIR --delete \
    --exclude .git \
    --exclude .gitignore \
    --exclude .tmp \
    --exclude .librarian

# and push it to the local /etc/puppet directory
ssh ubuntu@knowbot-app << EOF
sudo rsync -arvh /home/ubuntu/puppet/ /etc/puppet/ --delete --exclude certname --exclude manifest
sudo freepuppet-run
EOF