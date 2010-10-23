#
# Cookbook Name:: tornom
# Recipe:: default
#

directory "/mnt/downloads" do
  action :create
  mode 0777
end

package "transmission-daemon"
package "nginx"

service "transmission-daemon" do
  supports :restart => true, :reload => true
  action :enable
end

service "nginx" do
  supports
  action
end

template "/etc/transmission-daemon/settings.json" do
  source "settings.json.erb"
  owner
  group
  mode
  notifies :reload, "service[transmission-daemon]"
end

template "/etc/nginx/sites-available/default" do
  source "nginx-default.erb"
  owner
  group
  mode
  notifies :restart, "service[nginx]"
end

