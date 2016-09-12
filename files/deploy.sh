#!/bin/bash
# copies puppet to /etc/puppet
PUPPETDIR="$( dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" )"
sudo cp -r $PUPPETDIR/. /etc/puppet