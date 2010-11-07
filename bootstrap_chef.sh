#!/bin/bash
apt-get update
apt-get --assume-yes upgrade
apt-get install ruby1.8 rubygems irb libopenssl-ruby build-essential
gem install chef --no-rdoc --no-ri
