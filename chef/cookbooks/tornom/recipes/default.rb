#
# Cookbook Name:: tornom
# Recipe:: default
#
include_recipe "postfix"
include_recipe "snmp"

directory "/mnt/downloads" do
  action :create
  mode 0777
end

package "transmission-daemon"
package "nginx"
package "munin"
package "librrd-dev"

gem_package "librrd"
gem_package "snmp"
gem_package "sinatra"
gem_package "haml"

service "transmission-daemon" do
  supports :restart => true, :reload => true
  action :enable
end

service "nginx" do
  supports :restart => true, :reload => true
  action :enable
end

template "/etc/transmission-daemon/settings.json" do
  source "settings.json.erb"
  owner "debian-transmission"
  group "debian-transmission"
  mode 0700
  notifies :reload, "service[transmission-daemon]"
end

template "/etc/nginx/sites-available/default" do
  source "nginx-default.erb"
  owner "root"
  group "root"
  mode 0600
  notifies :restart, "service[nginx]"
end

cookbook_file "/usr/local/bin/resources_report.rb" do
  source "resources_report.rb"
  mode 0755
end

cookbook_file "/etc/init.d/tornom_resources_report" do
  source "tornom_resources_report"
  mode 0755
end

template "/etc/default/tornom" do
  source "tornom_defaults"
  mode 0644
end

log "Tornom installed, go to http://#{node.ec2.public_hostname}:9091 to operate"
