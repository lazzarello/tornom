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
