# Innovation Puppet

This is a basic Puppet repository used for setting up and configuring the Innovation teams technology demonstrators.

### Installation

To make use of this project you will need Puppet and the librarian-puppet gem installed, this can most easily be achieved via the following commands on OSX.

1. Download and install puppet-agent from the offical [puppet website](https://docs.puppet.com/puppet/latest/reference/install_osx.html).
2. Install librarian-puppet via ```gem install librarian-puppet```

Then run librarian-puppet install in the root of this repository to install the puppet dependencies.

You can then make changes to the module code and deploy them.

### Deployment

To deploy changes to puppet you (at this time) need to push the changes to the relevant servers via SSH.  A script has been setup to allow you to do this for knowbot, providing you have the relevant ssh keys and aliases installed in both /etc/hosts and ~/.ssh/config.

You can find the details on how to do this in the [social-search-platform repository](https://gitlab.itsshared.net/Innovation/social-search-platform).

A script to automate the release process for knowbot can be found in the ```./files/rsync-knowbot.sh``` file.