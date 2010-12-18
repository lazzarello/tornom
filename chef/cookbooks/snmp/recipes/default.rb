#
# Cookbook Name:: snmp
# Recipe:: default
#
# Copyright 2010, Eric G. Wolfe
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package "snmpd" do
  case node[:platform]
  when "centos","redhat","fedora"
    package_name "net-snmp"
  when "debian","ubuntu"
    package_name "snmpd"
  end
  action :install
end

case node[:platform]
  when "debian","ubuntu"
    cookbook_file "/etc/default/snmpd" do
      mode 0644
      owner "root"
      group "root"
      source "snmpd"
    end
end

if node[:snmp][:install_utils]
  case node[:platform]
  when "centos","redhat","fedora"
    package_name "net-snmp-utils"
  when "debian","ubuntu"
    package_name "snmp"
  end
  action :install
end

if node[:snmp][:is_dnsserver]
  include_recipe "perl"
  cpan_module "version"

  cookbook_file "/usr/local/bin/snmp_rndc_stats.pl" do
    mode 0755
    owner "root"
    group "root"
    source "snmp_rndc_stats.pl"
  end
end

service node[:snmp][:service] do
  action :start
end

template "/etc/snmp/snmpd.conf" do
  mode 0644
  owner "root"
  group "root"
  source "snmpd.conf.erb"
  notifies :restart, resources(:service => node[:snmp][:service])
end
