#!/bin/bash
scp -r chef/cookbooks ubuntu@$1:/tmp/chef-solo/
scp chef/config/* ubuntu@$1:/tmp/chef-solo/
