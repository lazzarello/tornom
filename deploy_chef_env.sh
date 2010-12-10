#!/bin/bash
scp bootstrap_chef.sh ubuntu@$1:~/
scp -r chef/cookbooks ubuntu@$1:/tmp/chef-solo/
scp chef/config/* ubuntu@$1:/tmp/chef-solo/
cat profile | ssh ubuntu@$1 "cat - >> ~/.profile"
ssh ubuntu@$1
