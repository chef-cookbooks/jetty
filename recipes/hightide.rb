#
# Cookbook Name:: jetty
# Recipe:: hightide
#
# Copyright 2012, Opscode, Inc.
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

include_recipe "java"

package_format = value_for_platform(
  ["centos", "redhat", "suse", "fedora" ] => {
    "default" => "rpm"
  },
  ["ubuntu", "debian"] => {
    "default" => "deb"
  }
)

jetty_package = File.join(Chef::Config[:file_cache_path], "/", "jetty-#{package_format}-#{node["jetty"]["hightide"]["version"]}.#{package_format}")

remote_file jetty_package do
  source "http://dist.codehaus.org/jetty/#{package_format}/#{node["jetty"]["hightide"]["version"]}/jetty-#{package_format}-#{node["jetty"]["hightide"]["version"]}.#{package_format}"
  action :create_if_missing
end

dpkg_package "jetty" do
  source jetty_package
  action :install
end

user "jetty" do
   comment "jetty user"
   system true
   shell "/bin/false"
end

directory node["jetty"]["log_dir"] do
  owner "jetty"
  group "jetty"
  mode "0755"
  action :create
end

service "jetty" do
  case node["platform"]
  when "centos","redhat","fedora"
    service_name "jetty6"
    supports :restart => true
  when "debian","ubuntu"
    service_name "jetty"
    supports :restart => true, :status => true
    action [:enable]
  end
end

template "/etc/default/jetty" do
  source "default_jetty.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[jetty]"
end
