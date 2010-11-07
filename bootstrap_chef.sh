#!/bin/bash
apt-get update
apt-get --assume-yes upgrade
apt-get --assume-yes install ruby1.8 rubygems irb libopenssl-ruby build-essential ruby1.8-dev
gem install chef --no-rdoc --no-ri
mkdir /tmp/chef-solo
chmod 777 /tmp/chef-solo
