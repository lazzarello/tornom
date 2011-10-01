#!/bin/bash
cd /tmp
apt-get update
apt-get --assume-yes install ruby ruby1.8 rubygems irb libopenssl-ruby build-essential ruby1.8-dev
gem install chef --no-rdoc --no-ri
mkdir /tmp/chef-solo
chmod 777 /tmp/chef-solo
wget http://tornom-installers.s3.amazonaws.com/tornom.tgz
tar -xzf tornom.tgz
cd tornom
cp -r chef/cookbooks /tmp/chef-solo/
cp chef/config/* /tmp/chef-solo/
cat profile >> /home/ubuntu/.profile
wget http://s3.amazonaws.com/ec2metadata/ec2-metadata
chmod 755 ec2-metadata
echo "tornom" > /etc/hostname
hostname -F /etc/hostname
echo "127.0.0.1 tornom localhost" > /etc/hosts
/var/lib/gems/1.8/bin/chef-solo -c /tmp/chef-solo/solo.rb -j /tmp/chef-solo/config.json
echo `curl -o - http://169.254.169.254/latest/meta-data/public-hostname` | mail -s tornom mail@example.com
